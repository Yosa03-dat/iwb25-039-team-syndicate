// Data types for the dictionary API

// Response from Free Dictionary API
public type DictionaryResponse record {
    string word;
    string phonetic?;
    Phonetic[] phonetics?;
    Meaning[] meanings;
    License license?;
    string[] sourceUrls?;
};

public type Phonetic record {
    string text?;
    string audio?;
    string sourceUrl?;
    License license?;
};

public type License record {
    string name;
    string url;
};

public type Meaning record {
    string partOfSpeech;
    Definition[] definitions;
    string[] synonyms?;
    string[] antonyms?;
};

public type Definition record {
    string definition;
    string example?;
    string[] synonyms?;
    string[] antonyms?;
};

// Our simplified response
public type SimpleDefinitionResponse record {
    string word;
    string pronunciation?;
    string[] meanings;
    string[] synonyms;
    boolean success;
};

public type ErrorResponse record {
    string message;
    int status;
    boolean success;
};