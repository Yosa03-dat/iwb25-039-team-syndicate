# Pocket Dictionary API

A lightweight Ballerina-based API service that provides word definitions, pronunciations, and synonyms.

## Features
- Get word definitions from Free Dictionary API
- Extract phonetic pronunciation
- Retrieve synonyms
- Clean JSON responses
- Error handling for invalid/missing words
- CORS enabled for web applications

## Endpoints

### GET /define?word=WORD
Returns definition, pronunciation, and synonyms for a given word.

**Example Request:**