import ballerina/http;
import ballerina/sql;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;
import ballerina/os;


type Result record {|
    string Date;
    decimal USD_rate;
|};


service /currency on new http:Listener(8082) {

    resource function get getDailyCurrency(http:Caller caller, http:Request req) returns error? {
        http:Response resp = new;

        mysql:Client mysqlClient = check new (
            host = os:getEnv("HOST"),
            user = os:getEnv("DB_USER"),
            password = os:getEnv("PASSWORD"),
            database = os:getEnv("DATABASE"),
            port =  12845
        );


        stream<Result, sql:Error?> resultStream = mysqlClient->query(`SELECT * FROM currency`);

        // Define an array to hold JSON objects
        json[] resultOutput = [];

        check from Result {Date, USD_rate} in resultStream
            do {
                // Create a JSON object for each result and add it to the array
                resultOutput.push({"Date": Date, "USD_rate": USD_rate});
            };

        // Set the JSON payload to the array of JSON objects
        resp.setJsonPayload(resultOutput);

        // Set CORS headers
        resp.addHeader("Access-Control-Allow-Origin", "*");
        resp.addHeader("Access-Control-Allow-Methods", "GET, OPTIONS");
        resp.addHeader("Access-Control-Allow-Headers", "Content-Type");

        check caller->respond(resp);
    }}