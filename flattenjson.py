import pymongo
import pandas as pd
from function_flatten import flatten_json, extract_key_from_flatten_thread
from vaderSentiment_fr.vaderSentiment import SentimentIntensityAnalyzer

client = pymongo.MongoClient("mongodb://group1cosmosdb:CfcGBJtg80smn8ZG2SSfbvKL9qTxh7RUW3VSQ5EQrrt3cjAUj7yywWemM9TjZwJWxSOKzhevyjCnPxReeUKiqA==@group1cosmosdb.mongo.cosmos.azure.com:10255/?ssl=true&retrywrites=false&replicaSet=globaldb&maxIdleTimeMS=120000&appName=@group1cosmosdb@")
db = client.moocdb
collection = db.mooc

list_text = []
list_id = []
list_endorsed = []
list_course_id = []
count = 0
threads_dict = {'thread_id': list_id, 'text': list_text, 'endorsed': list_endorsed, 'course_id' : list_course_id}

lst = []

def sentiments_liste(data):
    sentiments = {}
    for i,k in enumerate(data):
        print('enum =',i)
        score = SentimentIntensityAnalyzer().polarity_scores(k)
        print('score =',score)
        if score['compound'] >= 0.05:
            tendance = "positive"
        elif score['compound'] <= -0.05:
            tendance = "negative"
        else :
            tendance = "neutre"
        sentiments[k] =  tendance

    return(sentiments)

for thread in collection.find().limit(10):

    flatten_thread = flatten_json(thread)
    list_id.append(flatten_thread["content_id"])
    list_text.append(extract_key_from_flatten_thread(flatten_thread, 'body'))
    list_course_id.append(flatten_thread["content_course_id"])
    list_endorsed.append(flatten_thread["content_endorsed"])


for thread in list_text:
    lst.append(thread[0])


lsttest = sentiments_liste(lst)
print(len(lsttest))
#print(lsttest)
