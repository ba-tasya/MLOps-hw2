import csv
import json

from confluent_kafka import Producer

producer = Producer({
    "bootstrap.servers": "localhost:9092",
    "queue.buffering.max.messages": 1000000,
})

with open("data/train.csv", encoding="utf-8") as f:
    for row in csv.DictReader(f):
        producer.produce("transactions", json.dumps(row))
        producer.poll(0)

producer.flush()
print("OK")