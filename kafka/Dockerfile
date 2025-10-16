# kafka/Dockerfile
FROM python:3.12-slim
WORKDIR /app

# Copy all files to the container
COPY . .

# Install dependencies
RUN pip install kafka-python

# Set working directory
WORKDIR /app/kafka

CMD ["python", "producer.py"]