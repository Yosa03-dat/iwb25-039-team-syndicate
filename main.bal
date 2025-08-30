import ballerina/log;

public function main() returns error? {
    log:printInfo("Starting Pocket Dictionary API...");
    log:printInfo("Server will be available at: http://localhost:8080");
    log:printInfo("Try: http://localhost:8080/define?word=hello");
    log:printInfo("Health check: http://localhost:8080/health");
}