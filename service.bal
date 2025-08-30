import ballerina/http;
import ballerina/log;
import ballerina/time;

// Dictionary service with proper CORS configuration
@http:ServiceConfig {
    cors: {
        allowOrigins: ["*"],
        allowCredentials: false,
        allowHeaders: ["*"],
        allowMethods: ["GET", "POST", "OPTIONS"],
        maxAge: 84900
    }
}
service / on new http:Listener(8080) {
    
    // Handle preflight OPTIONS requests
    resource function options .(http:RequestContext ctx, http:Request req) returns http:Response {
        http:Response response = new;
        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
        response.setHeader("Access-Control-Allow-Headers", "*");
        response.setHeader("Access-Control-Max-Age", "84900");
        response.statusCode = 200;
        return response;
    }
    
    // Health check endpoint
    resource function get health() returns json {
        return {
            "status": "healthy",
            "service": "Pocket Dictionary API",
            "timestamp": time:utcNow()
        };
    }
    
    // Test endpoint to verify API connectivity
    resource function get test(string word) returns json|error {
        http:Client testClient = check new("https://api.dictionaryapi.dev");
        
        string path = "/api/v2/entries/en/" + word;
        log:printInfo("Testing API call to: https://api.dictionaryapi.dev" + path);
        
        http:Response|http:ClientError response = testClient->get(path);
        
        if (response is http:ClientError) {
            log:printError("HTTP Client Error: " + response.message());
            return {"error": "Network error: " + response.message()};
        }
        
        log:printInfo("Response status: " + response.statusCode.toString());
        json|http:ClientError payload = response.getJsonPayload();
        
        if (payload is http:ClientError) {
            log:printError("Failed to parse JSON: " + payload.message());
            return {"error": "JSON parse error"};
        }
        
        log:printInfo("SUCCESS! Raw response received");
        return {"status": "success", "data": payload};
    }
    
    // Main definition endpoint
    resource function get define(string word) returns SimpleDefinitionResponse|ErrorResponse|error {
        log:printInfo("Looking up word: " + word);
        
        if (word.trim().length() == 0) {
            return <ErrorResponse>{
                message: "Word parameter is required and cannot be empty",
                status: 400,
                success: false
            };
        }
        
        DictionaryResponse[]|error definitionResult = fetchDefinition(word.trim());
        
        if (definitionResult is error) {
            log:printError("Error fetching definition for word: " + word, definitionResult);
            return <ErrorResponse>{
                message: "Word '" + word + "' not found. Please check the spelling and try again.",
                status: 404,
                success: false
            };
        }
        
        DictionaryResponse[] definitions = definitionResult;
        
        string? pronunciation = extractPronunciation(definitions);
        string[] meanings = extractMeanings(definitions);
        string[] synonyms = extractSynonyms(definitions);
        
        return <SimpleDefinitionResponse>{
            word: word,
            pronunciation: pronunciation,
            meanings: meanings,
            synonyms: synonyms,
            success: true
        };
    }
}