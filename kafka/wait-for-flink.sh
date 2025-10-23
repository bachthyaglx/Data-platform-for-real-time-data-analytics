#!/bin/bash
set -e

echo "Waiting for Flink job to be ready..."
MAX_WAIT=300  # 5 minutes
COUNTER=0

until docker exec jobmanager test -f /tmp/flink-job-ready 2>/dev/null; do
    COUNTER=$((COUNTER + 1))
    if [ $COUNTER -gt $MAX_WAIT ]; then
        echo "ERROR: Flink job not ready after ${MAX_WAIT}s"
        exit 1
    fi
    echo "Waiting for Flink job... ($COUNTER/$MAX_WAIT)"
    sleep 1
done

echo "✓ Flink job is ready, starting Kafka producer..."