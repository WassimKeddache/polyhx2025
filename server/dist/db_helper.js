"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.collection = void 0;
const mongodb_1 = require("mongodb");
const url = 'mongodb://localhost:27017';
const client = new mongodb_1.MongoClient(url);
const database_name = 'dev';
client.connect();
const db = client.db(database_name);
const collection = db.collection('my_collection');
exports.collection = collection;
//# sourceMappingURL=db_helper.js.map