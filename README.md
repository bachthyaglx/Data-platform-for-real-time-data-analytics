## Techs:

![Apache Kafka](https://img.shields.io/badge/Apache%20Kafka-Event%20Streaming-black?logo=apachekafka)
![Apache Flink](https://img.shields.io/badge/Apache%20Flink-Real%20Time%20Processing-orange?logo=apacheflink)
![Apache Iceberg](https://img.shields.io/badge/Apache%20Iceberg-Table%20Format-blue?logo=apache)
![Trino](https://img.shields.io/badge/Trino-SQL%20Query%20Engine-green?logo=trino)
![Apache Pinot](https://img.shields.io/badge/%20Apache%20Pinot-Real--Time%20Analytics-black?labelColor=f68c1e)
![Docker](https://img.shields.io/badge/Docker-Enabled-blue?logo=docker)
![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?logo=kubernetes&logoColor=white)
![Prometheus](https://img.shields.io/badge/Prometheus-black?logo=prometheus&logoColor=white)
![Grafana](https://img.shields.io/badge/Grafana-F46800?logo=grafana&logoColor=white)

## Run it all
```bash
# Bring up the stack
docker compose up

# Generate log and let kafka ingest data
docker compose exec -it generate_data python producer.py

# Start job to ingest from Kafka into Iceberg
docker compose exec -it jobmanager bash -c "./bin/sql-client.sh -f /data/kafka-to-iceberg.sql"
```

## Test data in UI:
* Kafka UI (Kafdrop): http://localhost:9000
  
  ![image](https://github.com/user-attachments/assets/b47615f9-baef-4170-a165-250ef4bd9dca)

* Flink UI: http://localhost:8081
  
  ![image](https://github.com/user-attachments/assets/ab7aee08-e145-439f-b4a3-ccbbb32b34fe)

* Iceberg (HiveMetaStore + MinIO + Data): http://localhost:9001 (admin/password)
  
  ![image](https://github.com/user-attachments/assets/9816f55c-fe5a-4e06-a494-50d27b43329e)

* Continue...

## Ports 
http://localhost:9000	-> Check data ingested in kafka
http://localhost:8081	-> Check job in Flink SQL in Flink UI	
http://localhost:9001	-> Check file stored as HiveMeta, MinIO, Data at s3a://warehouse/data/ 
http://localhost:8082	-> Trino, query data from Iceberg (MinIO) -> SELECT * FROM iceberg.default.sensor_data LIMIT 10;
http://localhost:9003	-> Pinot, Real-time data from kafka 

## Plan
[x] Data faker (data source later)
[x] Kafka consumer (Kafdrop) + Docker manifest
[x] Flink processing + Docker manifest
[x] Iceberg MinIO + Docker manifest
[ ] Volume/storage checks
[ ] Trino query + Docker manifest
[ ] Kubernetes + Prometheus + Grafana monitoring deployment performance
[ ] Optional: Export api/metrics backend for each stage 
[ ] Optional: Build custom UI for each stage 


