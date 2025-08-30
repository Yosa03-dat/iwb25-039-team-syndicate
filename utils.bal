import ballerina/http;
import ballerina/log;

// HTTP client for Free Dictionary API
http:Client dictionaryClient = check new("https://api.dictionaryapi.dev");

// Function to fetch word definition from Free Dictionary API
public function fetchDefinition(string word) returns DictionaryResponse[]|error {
    string path = "/api/v2/entries/en/" + word;
    log:printInfo("Fetching from: https://api.dictionaryapi.dev" + path);
    
    http:Response|http:ClientError response = dictionaryClient->get(path);
    
    if (response is http:ClientError) {
        log:printError("HTTP Client Error: " + response.message());
        return error("Network error: " + response.message());
    }
    
    // response is http:Response at this point
    log:printInfo("Response status: " + response.statusCode.toString());
    
    if (response.statusCode != 200) {
        log:printError("API returned status: " + response.statusCode.toString());
        return error("Word not found");
    }
    
    json|http:ClientError payload = response.getJsonPayload();
    
    if (payload is http:ClientError) {
        log:printError("Failed to parse JSON: " + payload.message());
        return error("Failed to parse response");
    }
    
    // payload is json at this point
    log:printInfo("Raw JSON response: " + payload.toString());
    DictionaryResponse[]|error definitions = payload.cloneWithType();
    
    if (definitions is error) {
        log:printError("Type conversion error: " + definitions.message());
        return error("Failed to convert response format");
    }
    
    return definitions;
}

// Function to extract pronunciation from dictionary response
public function extractPronunciation(DictionaryResponse[] definitions) returns string? {
    foreach DictionaryResponse def in definitions {
        // Try to get phonetic from main phonetic field
        if (def.phonetic is string) {
            return def.phonetic;
        }
        
        // Try to get phonetic from phonetics array
        if (def.phonetics != ()) {
            Phonetic[] phonetics = <Phonetic[]>def.phonetics;
            foreach Phonetic phonetic in phonetics {
                if (phonetic.text is string) {
                    return phonetic.text;
                }
            }
        }
    }
    return ();
}

// Function to extract meanings from dictionary response
public function extractMeanings(DictionaryResponse[] definitions) returns string[] {
    string[] meanings = [];
    
    foreach DictionaryResponse def in definitions {
        foreach Meaning meaning in def.meanings {
            foreach Definition definition in meaning.definitions {
                string meaningText = meaning.partOfSpeech + ": " + definition.definition;
                meanings.push(meaningText);
            }
        }
    }
    
    return meanings;
}

// Function to extract synonyms from dictionary response
public function extractSynonyms(DictionaryResponse[] definitions) returns string[] {
    string[] allSynonyms = [];
    
    foreach DictionaryResponse def in definitions {
        foreach Meaning meaning in def.meanings {
            if (meaning.synonyms != ()) {
                string[] meaningSynonyms = <string[]>meaning.synonyms;
                foreach string synonym in meaningSynonyms {
                    allSynonyms.push(synonym);
                }
            }
            
            foreach Definition definition in meaning.definitions {
                if (definition.synonyms != ()) {
                    string[] definitionSynonyms = <string[]>definition.synonyms;
                    foreach string synonym in definitionSynonyms {
                        allSynonyms.push(synonym);
                    }
                }
            }
        }
    }
    
    // Remove duplicates
    string[] uniqueSynonyms = [];
    foreach string synonym in allSynonyms {
        boolean exists = false;
        foreach string existing in uniqueSynonyms {
            if (existing == synonym) {
                exists = true;
                break;
            }
        }
        if (!exists) {
            uniqueSynonyms.push(synonym);
        }
    }
    
    return uniqueSynonyms;
}