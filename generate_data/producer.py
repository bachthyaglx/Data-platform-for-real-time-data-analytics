# generate_data/producer.py
from kafka import KafkaProducer
import json
import random
import time
import uuid
from datetime import datetime

producer = KafkaProducer(
    bootstrap_servers='broker:9092',
    value_serializer=lambda v: json.dumps(v).encode('utf-8')
)

def generate_order():
    return {
        "orderId": str(uuid.uuid4()),
        "customerId": str(uuid.uuid4()),
        "orderNumber": random.randint(1000, 9999),
        "product": random.choice(["sensor-a", "sensor-b", "sensor-c"]),
        "backordered": random.choice([True, False]),
        "cost": round(random.uniform(10, 200), 2),
        "description": "auto-generated sensor event",
        "create_ts": int(time.time() * 1000),
        "creditCardNumber": "0000-0000-0000-0000",
        "discountPercent": random.randint(0, 15)
    }

while True:
    message = generate_order()
    producer.send('orders', message)
    print(f"[{datetime.now()}] Sent: {message}")
    time.sleep(1)  # gửi 1 bản tin mỗi giây
