# kafka/generator.py
import random
import uuid
import time

def generate_order():
    """Generate fake order data"""
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