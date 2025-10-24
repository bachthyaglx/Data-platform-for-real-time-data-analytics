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

## Prerequisites 
* Python (version >= 3.8)
* Docker 

## Run program
```bash
# All in one
docker compose \
  -f docker-compose-iceberg.yml \
  -f docker-compose-flink.yml \
  -f docker-compose-kafka.yml \
  -f docker-compose-pinot.yml \
  -f docker-compose-trino.yml \
  up
```

## Network & Ports  
- **[http://localhost:9000](http://localhost:9000)** → Kafka UI
- **[http://localhost:8081](http://localhost:8081)** → Stream processing UI
- **[http://localhost:9001](http://localhost:9001)** → Object storage UI (HiveMeta, MinIO, json data)
- **[http://localhost:9003](http://localhost:9003)** → Pinot real-time analytics
- **[http://localhost:8082](http://localhost:8090)** → Trino query engine UI

## Test data in UI
* Kafka UI (Kafdrop): http://localhost:9000
  
  ![image](images/kafdrop.png)

* Flink UI: http://localhost:8081
  
  ![image](images/flink.png)

* Iceberg UI: http://localhost:9001 (admin/password)
  
  ![image](images/minio.png)

* Pinot UI: http://localhost:9003 

  ![alt text](images/pinot.png)

* Trino UI: http://localhost:8082 

  ```bash
  docker exec -it trino trino
  ```

  Then, run following cmds to see results

  ![alt text](images/trino.png)

* Continue...

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
- [x] Trino query + Docker manifest
- [x] Pinot real-time analytics + Docker manifest
- [ ] Kubernetes + Prometheus + Grafana monitoring deployment performance
- [ ] Optional: Export api/metrics backend for each manifest
- [ ] Optional: Build custom UI for services
- [ ] !!!!Optional: Fullstack production!!!!

