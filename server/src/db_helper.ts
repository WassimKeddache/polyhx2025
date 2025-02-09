import { MongoClient } from 'mongodb';

const url = 'mongodb://localhost:27017';
const client = new MongoClient(url);
const database_name = 'dev'

client.connect();
const db = client.db(database_name);
const collection = db.collection('my_collection')

export { collection };
