import ballerina/http;
import ballerina/sql;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

type Result record {|
    string Date;
    decimal USD_rate;
|};

service /currency on new http:Listener(8082) {

    resource function get getDailyCurrency(http:Caller caller, http:Request req) returns error? {
        http:Response resp = new;

        mysql:Client mysqlClient = check new (host = "mysql-910d8c3f-ba85-4197-803c-871a29817e06-student3405976834-ch.h.aivencloud.com",
            user = "avnadmin",
            password = "AVNS_R6Pnmzl4MT4lgq38FT2",
            database = "defaultdb", port = 12845
        );

        // mysql:Client mysqlClient = check new (host = "localhost",
        //     user = "root",
        //     password = "0352222342",
        //     database = "facebook", port = 3306
        // );

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