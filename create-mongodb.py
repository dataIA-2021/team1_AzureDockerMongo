import pymongo
import json
from pymongo import MongoClient, InsertOne

client = pymongo.MongoClient("mongodb://172.17.0.2:27017")
db = client.mooc_db
collection = db.threads
requesting = []

with open(r"MOOC.forum-2022-06.json") as f:
    for jsonObj in f:
        myDict = json.loads(jsonObj)
        requesting.append(InsertOne(myDict))

result = collection.bulk_write(requesting)
client.close() 
