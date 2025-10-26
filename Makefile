# ============ CONFIG ===============
GREEN=
YELLOW=
NC=

COMPOSE_PROJECT_NAME := thesis
HMS_PORT=9083
KAFKA_UI_PORT=9000
FLINK_UI_PORT=8081
MINIO_UI_PORT=9001
PINOT_CONTROLLER_PORT=9003
TRINO_PORT=8090

# ============ MAIN PIPELINE ===============
.PHONY: all setup-network setup-infra setup-flink setup-pinot setup-trino start-producer info clean

all: setup-network setup-infra setup-flink start-producer setup-pinot setup-trino info

# ------------------------------------------
# 0️⃣ NETWORK
# ------------------------------------------
setup-network:
	@echo ==========================================================
	@echo 0. Checking shared Docker network \(zaphod\)...
	@echo ==========================================================
	@docker network create zaphod || echo "Network zaphod already exists."
	@echo ✓ Network zaphod ready.

# ------------------------------------------
# 1️⃣ SETUP INFRA
# ------------------------------------------
setup-infra:
	@echo ==========================================================
	@echo 1. Starting core infrastructure \(MinIO, HMS, Kafka, Flink\)...
	@echo ==========================================================
	docker compose -f docker-compose-iceberg.yml up -d minio createbuckets hive-metastore pyiceberg
	docker compose -f docker-compose-kafka.yml up -d zookeeper kafka kafdrop
	docker compose -f docker-compose-flink.yml up -d jobmanager taskmanager
	@echo ""
	@echo "Waiting for services to be ready..."

	@echo "Waiting for Kafka Broker..."
	@powershell -Command "while (-not (Test-NetConnection localhost -Port 9092 -InformationLevel Quiet)) { Start-Sleep -Seconds 2; Write-Host '   ↳ waiting for Kafka...' }"
	@echo ✓ Kafka Broker ready!

	@echo "Waiting for Hive Metastore..."
	@powershell -Command "while (-not (Test-NetConnection localhost -Port $(HMS_PORT) -InformationLevel Quiet)) { Start-Sleep -Seconds 2; Write-Host '   ↳ waiting for HMS...' }"
	@echo ✓ Hive Metastore ready!

	@echo "Waiting for Flink JobManager..."
	@powershell -Command "while ((Invoke-WebRequest -Uri http://localhost:$(FLINK_UI_PORT)/jobs -UseBasicParsing -ErrorAction SilentlyContinue).StatusCode -ne 200) { Start-Sleep -Seconds 3; Write-Host '   ↳ waiting for Flink JobManager...' }"
	@echo ✓ Flink JobManager ready!

# ------------------------------------------
# 2️⃣ SETUP FLINK
# ------------------------------------------
setup-flink:
	@echo ==========================================================
	@echo 2. Submitting Flink SQL job: Kafka → Iceberg
	@echo ==========================================================
	docker exec jobmanager /opt/flink/bin/sql-client.sh -f /data/flink/jobs/kafka-to-iceberg.sql
	@echo ""
	@echo ✓ Flink Kafka→Iceberg job submitted successfully.


# ------------------------------------------
# 3️⃣ START PRODUCER
# ------------------------------------------
start-producer:
	@echo ==========================================================
	@echo 3. Starting Kafka Producer
	@echo ==========================================================
	@echo Waiting for Flink REST API before starting Producer...
	@powershell -Command "while ((Invoke-WebRequest -Uri http://localhost:$(FLINK_UI_PORT)/jobs -UseBasicParsing -ErrorAction SilentlyContinue).StatusCode -ne 200) { Start-Sleep -Seconds 3; Write-Host '   ↳ waiting for Flink...' }"
	@echo ✓ Flink ready, starting Kafka Producer...
	docker compose -f docker-compose-kafka.yml up -d kafka_producer
	@echo ✓ Kafka Producer started.
	@powershell -Command "Start-Sleep -Seconds 10"

# ------------------------------------------
# 4️⃣ SETUP TRINO
# ------------------------------------------
setup-trino:
	@echo ==========================================================
	@echo 4. Starting Trino SQL engine
	@echo ==========================================================
	docker compose -f docker-compose-trino.yml up -d trino
	@echo ""
	@echo Waiting for Trino REST API to become ready...
	@powershell -Command "$$max=60; $$i=0; while ($$i -lt $$max) { try { $$res = Invoke-WebRequest -Uri http://localhost:$(TRINO_PORT)/v1/info -UseBasicParsing -TimeoutSec 5; if ($$res.StatusCode -eq 200) { Write-Host '✓ Trino ready!'; exit 0 } } catch { Write-Host '   ↳ waiting for Trino...'; Start-Sleep -Seconds 3; $$i = $$i + 1 } }; Write-Host '⚠ Timeout waiting for Trino after 60s' "

# ------------------------------------------
# 5️⃣ SETUP PINOT
# ------------------------------------------
setup-pinot:
	@echo ==========================================================
	@echo 5. Setting up Apache Pinot
	@echo ==========================================================
	@echo "Starting Pinot core services (ZK, Controller, Broker, Server)..."
	docker compose -f docker-compose-pinot.yml up -d pinot-zookeeper pinot-controller pinot-broker pinot-server
	@echo ""
	@echo "Waiting for Pinot Controller REST API to respond..."
	@powershell -Command "$$max=60; $$i=0; while ($$i -lt $$max) { try { $$res = Invoke-WebRequest -Uri http://localhost:$(PINOT_CONTROLLER_PORT)/health -UseBasicParsing -TimeoutSec 5; if ($$res.StatusCode -eq 200) { Write-Host '✓ Pinot Controller reachable'; break } } catch { Write-Host '   ↳ waiting for Pinot Controller...'; Start-Sleep -Seconds 3; $$i = $$i + 1 } }; if ($$i -ge $$max) { Write-Host '⚠ Timeout waiting for Pinot Controller after 180s'; exit 1 }"
	@echo ""
	@echo "Starting Pinot table setup (auto-retry until success)..."
	@powershell -Command "$$attempt=0; $$max=10; $$success=$$false; while (-not $$success -and $$attempt -lt $$max) { $$attempt++; Write-Host ('▶ Attempt ' + $$attempt + ' to add table...'); $$output = docker compose -f docker-compose-pinot.yml up --no-deps --force-recreate -d pinot-setup 2>&1; if ($$LASTEXITCODE -eq 0) { Start-Sleep -Seconds 3; $$logs = docker logs pinot-setup 2>&1; if ($$logs -match 'successfully added') { Write-Host '✓ Pinot table setup successful!'; $$success=$$true; break } else { Write-Host '   ↳ Pinot setup did not confirm success yet...'; Start-Sleep -Seconds 5 } } else { Write-Host '   ↳ Pinot setup container failed to run. Retrying...'; Start-Sleep -Seconds 5 } }; if (-not $$success) { Write-Host '❌ Pinot setup failed after 10 attempts.'; exit 1 }"
	@echo ""
	@echo ✓ Pinot setup completed successfully!

# ------------------------------------------
# 6️⃣ INFO
# ------------------------------------------
info:
	@echo ==========================================================
	@echo ✅ PIPELINE READY
	@echo ----------------------------------------------------------
	@echo Flink UI:   http://localhost:$(FLINK_UI_PORT)
	@echo Kafka UI:   http://localhost:$(KAFKA_UI_PORT)
	@echo Pinot UI:   http://localhost:$(PINOT_CONTROLLER_PORT)
	@echo MinIO UI:   http://localhost:$(MINIO_UI_PORT)  \(admin/password\)
	@echo Trino UI:   http://localhost:$(TRINO_PORT)
	@echo ==========================================================

# ------------------------------------------
# 🧹 CLEANUP
# ------------------------------------------
clean:
	@echo Cleaning up all containers and volumes...
	-docker compose -f docker-compose-flink.yml down -v
	-docker compose -f docker-compose-iceberg.yml down -v
	-docker compose -f docker-compose-kafka.yml down -v
	-docker compose -f docker-compose-pinot.yml down -v
	-docker compose -f docker-compose-trino.yml down -v
	@echo ✓ All cleaned up.
