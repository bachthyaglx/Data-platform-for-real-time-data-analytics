CREATE TABLE t_k_orders
  (
    orderId          STRING,
    customerId       STRING,
    orderNumber      INT,
    product          STRING,
    backordered      BOOLEAN,
    cost             FLOAT,
    description      STRING,
    create_ts        BIGINT,
    creditCardNumber STRING,
    discountPercent  INT
  ) WITH (
    'connector' = 'kafka',
    'topic' = 'orders',
    'properties.bootstrap.servers' = 'broker:29092',
    'scan.startup.mode' = 'earliest-offset',
    'format' = 'json'
  );


SET 'execution.checkpointing.interval' = '1sec';
SET execution.runtime-mode = streaming;


CREATE TABLE t_i_orders 
  WITH (
    'connector' = 'iceberg',
    'catalog-type'='hive',
    'catalog-name'='dev',
    'warehouse' = 's3a://warehouse',
    'hive-conf-dir' = './conf'
  )
  AS 
  SELECT * FROM t_k_orders 
  WHERE cost > 100;

-- 2. Flink Job 2: Ghi dữ liệu đã lọc vào Kafka Topic cho Pinot (Real-time Analytics)

-- Định nghĩa Kafka Sink Table cho Pinot
CREATE TABLE t_k_pinot_sink (
    orderId           STRING,
    customerId        STRING,
    product           STRING,
    cost              FLOAT,
    create_ts         BIGINT
) WITH (
    'connector' = 'kafka',
    'topic' = 'pinot_orders_realtime',
    'properties.bootstrap.servers' = 'broker:9092',
    'format' = 'json'
);

-- Bắt đầu Streaming Job thứ hai (INSERT)
INSERT INTO t_k_pinot_sink
SELECT 
    orderId,
    customerId,
    product,
    cost,
    create_ts
FROM t_k_orders 
WHERE cost > 100;