FROM python:3.12-slim

WORKDIR /app

# Copy kafka producer code
COPY kafka/ ./kafka/

# Copy generate_data module
COPY generate_data/ ./generate_data/

# Install dependencies
RUN pip install kafka-python

# Run producer
CMD ["python", "/app/kafka/producer.py"]
