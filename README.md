## Techs

![Apache Kafka](https://img.shields.io/badge/Apache%20Kafka-Event%20Streaming-black?logo=apachekafka)
![Apache Flink](https://img.shields.io/badge/Apache%20Flink-Real%20Time%20Processing-orange?logo=apacheflink)
![Apache Iceberg](https://img.shields.io/badge/Apache%20Iceberg-Table%20Format-blue?logo=apache)
![Trino](https://img.shields.io/badge/Trino-SQL%20Query%20Engine-green?logo=trino)
![Apache Pinot](https://img.shields.io/badge/%20Apache%20Pinot-Real--Time%20Analytics-black?labelColor=f68c1e)
![Docker](https://img.shields.io/badge/Docker-Enabled-blue?logo=docker)
![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?logo=kubernetes&logoColor=white)
![Prometheus](https://img.shields.io/badge/Prometheus-black?logo=prometheus&logoColor=white)
![Grafana](https://img.shields.io/badge/Grafana-F46800?logo=grafana&logoColor=white)

## Run program
```bash
# All in one
docker compose up
```

## Test data in UI
* Kafka UI (Kafdrop): http://localhost:9000
  
  ![image](https://github.com/user-attachments/assets/b47615f9-baef-4170-a165-250ef4bd9dca)

* Flink UI: http://localhost:8081
  
  ![image](https://github.com/user-attachments/assets/ab7aee08-e145-439f-b4a3-ccbbb32b34fe)

* Iceberg UI: http://localhost:9001 (admin/password)
  
  ![image](https://github.com/user-attachments/assets/9816f55c-fe5a-4e06-a494-50d27b43329e)

* Pinot UI: http://localhost:9003 

  ![alt text](image.png)
  
* Continue...

## Ports 
- **[http://localhost:9000](http://localhost:9000)** → Check data ingested in Kafka  
- **[http://localhost:8081](http://localhost:8081)** → Check job in Flink SQL via Flink UI
- **[http://localhost:9001](http://localhost:9001)** → Check files stored as HiveMeta**, MinIO, and data at `s3a://warehouse/data/`  
- **[http://localhost:9003](http://localhost:9003)** → Pinot for real-time analytics from kafka
- **[http://localhost:8082](http://localhost:8082)** → Trino query batch data from Iceberg

## Troubleshooting
### Kafka producer not sending data
```bash
docker logs -f kafka_producer
docker restart kafka_producer
```
### Flink job fails
```bash
docker logs taskmanager
docker logs jobmanager
```
### Query Iceberg data with PyIceberg
```bash
docker exec -it pyiceberg python

from pyiceberg.catalog import load_catalog
catalog = load_catalog("default")
table = catalog.load_table("default.t_i_orders")
df = table.scan().to_pandas()
print(df.head())
print(f"Total rows: {len(df)}")
```
### No data in Iceberg
```bash
- Check Flink job is running: http://localhost:8081
- Check checkpoint interval: default is 60s
- Check MinIO: http://localhost:9001 (admin/password)
```

## Plan
- [x] Data faker (data source later)
- [x] Kafka consumer (Kafdrop) + Docker manifest
- [x] Flink processing + Docker manifest
- [x] Iceberg MinIO + Docker manifest
- [x] Volume/storage checks
- [ ] Trino query + Docker manifest
- [x] Pinot real-time analytics + Docker manifest
- [ ] Kubernetes + Prometheus + Grafana monitoring deployment performance
- [ ] Optional: Export api/metrics backend for each stage 
- [ ] Optional: Build custom UI for each stage 
- [ ] !!!!Optional: Fullstack production!!!!

