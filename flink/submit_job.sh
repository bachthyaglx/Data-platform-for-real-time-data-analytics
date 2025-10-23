#!/bin/bash
set -e

echo "=== Starting Flink JobManager ==="
/docker-entrypoint.sh jobmanager &
JM_PID=$!

# Function to check if JobManager is ready
wait_for_jobmanager() {
    echo "Waiting for JobManager REST API..."
    local max_wait=120
    local counter=0
    
    until curl -sf http://localhost:8081/overview > /dev/null 2>&1; do
        counter=$((counter + 1))
        if [ $counter -gt $max_wait ]; then
            echo "ERROR: JobManager failed to start within ${max_wait}s"
            exit 1
        fi
        echo "Attempt $counter/$max_wait..."
        sleep 1
    done
    echo "✓ JobManager is ready"
}

# Function to check TaskManagers
wait_for_taskmanagers() {
    echo "Waiting for TaskManagers..."
    local max_wait=60
    local counter=0
    
    until [ $(curl -sf http://localhost:8081/taskmanagers 2>/dev/null | grep -o '"id"' | wc -l) -ge 1 ]; do
        counter=$((counter + 1))
        if [ $counter -gt $max_wait ]; then
            echo "WARNING: No TaskManagers after ${max_wait}s"
            return 0
        fi
        sleep 1
    done
    echo "✓ TaskManagers registered"
}

# Function to check Hive Metastore
wait_for_hms() {
    echo "Waiting for Hive Metastore..."
    local max_wait=60
    local counter=0
    
    until timeout 2 bash -c '</dev/tcp/hive-metastore/9083' 2>/dev/null; do
        counter=$((counter + 1))
        if [ $counter -gt $max_wait ]; then
            echo "ERROR: HMS not ready after ${max_wait}s"
            exit 1
        fi
        sleep 2
    done
    echo "✓ Hive Metastore is ready"
}

# Function to check MinIO
wait_for_minio() {
    echo "Waiting for MinIO..."
    local max_wait=60
    local counter=0
    
    until curl -sf http://minio:9000/minio/health/live > /dev/null 2>&1; do
        counter=$((counter + 1))
        if [ $counter -gt $max_wait ]; then
            echo "ERROR: MinIO not ready after ${max_wait}s"
            exit 1
        fi
        echo "MinIO check attempt $counter/$max_wait..."
        sleep 2
    done
    echo "✓ MinIO is ready"
}

# Function to check if bucket exists
wait_for_bucket() {
    echo "Waiting for warehouse bucket..."
    local max_wait=60
    local counter=0
    
    sleep 10  # Give createbuckets time to run
    
    until curl -sf http://minio:9000/minio/health/ready > /dev/null 2>&1; do
        counter=$((counter + 1))
        if [ $counter -gt $max_wait ]; then
            echo "ERROR: MinIO/Bucket not ready after ${max_wait}s"
            exit 1
        fi
        echo "Bucket check attempt $counter/$max_wait..."
        sleep 2
    done
    echo "✓ Warehouse bucket is ready"
}

# Function to verify Flink job is running
wait_for_flink_job() {
    echo "Verifying Flink job is running..."
    local max_wait=60
    local counter=0
    
    until [ $(curl -sf http://localhost:8081/jobs 2>/dev/null | grep -o '"status":"RUNNING"' | wc -l) -ge 1 ]; do
        counter=$((counter + 1))
        if [ $counter -gt $max_wait ]; then
            echo "ERROR: No running jobs detected after ${max_wait}s"
            curl -sf http://localhost:8081/jobs 2>/dev/null || echo "Cannot fetch job list"
            exit 1
        fi
        echo "Checking for running jobs... ($counter/$max_wait)"
        sleep 2
    done
    echo "✓ Flink job is RUNNING"
}

# Wait for all dependencies in order
wait_for_minio
wait_for_bucket
wait_for_jobmanager
wait_for_taskmanagers
wait_for_hms

# Execute SQL script
echo "=== Executing SQL Bootstrap Script ==="
if /opt/flink/bin/sql-client.sh -f /data/flink/jobs/kafka-to-iceberg.sql; then
    echo "✓ SQL script executed successfully"
else
    echo "✗ SQL script failed"
    exit 1
fi

# Wait for job to be running
sleep 5
wait_for_flink_job

# Create marker file to signal job is ready
echo "=== Creating ready marker file ==="
touch /tmp/flink-job-ready
echo "✓✓✓ FLINK JOB IS READY TO CONSUME DATA ✓✓✓"

echo "=== Initialization complete, JobManager running ==="
wait $JM_PID