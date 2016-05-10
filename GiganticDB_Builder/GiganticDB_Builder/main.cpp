//
//  main.cpp
//  GiganticDB_Builder
//
//  Created by Wai Man Chan on 1/9/14.
//  Copyright (c) 2014 Wai Man Chan. All rights reserved.
//

#import <iostream>
#import <sqlite3.h>
#import <iomanip>
using namespace std;

inline sqlite3 *dbHandlerFromAddress(const char *addr) {
    sqlite3 *db;
    int err = sqlite3_open(addr, &db);
    if (db == NULL && err) {
        cout << "Can't open db at " << addr << " , receive error code: " << err << endl;
        exit(-1);
    }
    return db;
}

inline sqlite3 *openDB() {
    char address[64];
    cout << "DB Address: ";
    cin.getline(address, 64);
    return dbHandlerFromAddress(address);
}

sqlite3 *currentDB;
char tableName[64];



void printData(const char **data, int numberOfRow, int numberOfColumn) {
    cout << "Current Data: " << endl;
    
    //Header
    for (int currentColumn = 0; currentColumn < numberOfColumn; currentColumn++) {
        cout << setw(20) << data[currentColumn];
    }
    cout << endl;
    
    for (int currentColumn = 0; currentColumn < numberOfColumn; currentColumn++) {
        cout << "--------------------";
    }
    cout << endl;
    
    //Rows
    for (int currentRow = 1; currentRow <= numberOfRow; currentRow++) {
        
        for (int currentColumn = 0; currentColumn < numberOfColumn; currentColumn++) {
            cout << setw(20) << data[numberOfColumn*currentRow+currentColumn];
        }
        cout << endl;
        
    }
    cout << endl;
    
}

void printData(sqlite3 *db) {
    char buffer[1024];
    snprintf(buffer, 1024, "select * from %s", tableName);
    char **result;  int row, column;    char *errMsg;
    int err = sqlite3_get_table(db, buffer, &result, &row, &column, &errMsg);
    if (err) cout << "Print Data Error: " << errMsg << endl;
    else printData((const char**)result, row, column);
    sqlite3_free_table(result);
}

void dbInteraction() {
    while (true) {
        cout << "Choose Table: ";
        cin.getline(tableName, 64);
        printData(currentDB);
    }
}

int main(int argc, const char * argv[]) {
    // insert code here...
    while (true) {
        currentDB = openDB();
        
        dbInteraction();
        
        sqlite3_close(currentDB);

    }
    return 0;
}
