# kafka/producer.py
from kafka import KafkaProducer
from datetime import datetime
import json
import time
import sys
import os

# Add parent directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..'))
from generate_data import generate_order

# Kafka Producer setup
producer = KafkaProducer(
    bootstrap_servers='broker:9092',
    value_serializer=lambda v: json.dumps(v).encode('utf-8')
)

# Produce messages indefinitely
while True:
    message = generate_order()
    producer.send('orders', message)
    print(f"[{datetime.now()}] Sent: {message}")
    time.sleep(5) # Produce a message every 5 seconds