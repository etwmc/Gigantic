//
//  Object.cpp
//  NLP
//
//  Created by CHAN, Wai Man on 3/12/13.
//  Copyright (c) 2013 CHAN, Wai Man. All rights reserved.
//

#include "Object.h"

ObjDB::ObjDB(string address) {
    dbQueue = dispatch_queue_create("DB Queue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_barrier_async(dbQueue, ^{
        int err = sqlite3_open(address.c_str(), &db);
        if (err) {
            //cout << sqlite3_errmsg(err);
            abort();
        } else {
            char *createVersionTable = "create table _version IF NOT EXISTS (\
            Name    CHAR(10) PRIMARY KEY  NOT NULL\
            Version REAL                  NOT NULL\
            );";
            sqlite3_exec(db, createVersionTable, 0, 0, 0);
            initDB();
        }
    });
}

/*float ObjDB::tableCurrentVersion(string tableName) {
    float result = 0;
    dispatch_sync(dbQueue, ^{
        string fetch = "select Version from _version where Name='"+tableName+"';";
        sqlite3_stmt *fetchStmt;
        sqlite3_prepare_v2(db, fetch.c_str(), fetch.length(), &fetchStmt, NULL);
        if (sqlite3_step(fetchStmt)==SQLITE_DONE) {
            result = sqlite3_column_double(fetchStmt, 1);
        }
    });
    return result;
}*/

ObjDB::~ObjDB() {
    dispatch_barrier_async(dbQueue, ^{
        wrapEverything();
    });
}