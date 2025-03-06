-- Databricks notebook source
-- bootstrapServers = "b-1.itaudevkafka01.eapmog.c21.kafka.us-east-1.amazonaws.com:9096,b-2.itaudevkafka01.eapmog.c21.kafka.us-east-1.amazonaws.com:9096"
-- kafka_username = "kafka"
-- kafka_password = "228728f5d92ecff18c0f3fbfb4f9473c"

-- kafka_options = {
--   "kafka.bootstrap.servers": bootstrapServers,
--   "kafka.security.protocol": "SASL_SSL",
--   "kafka.sasl.jaas.config" : "kafkashaded.org.apache.kafka.common.security.scram.ScramLoginModule required username='{}' password='{}';".format(kafka_username, kafka_password),
--   "kafka.sasl.mechanism" : "SCRAM-SHA-512"
-- }

-- COMMAND ----------

-- DBTITLE 1,Select no MSK
CREATE OR REFRESH STREAMING TABLE bronze_clickstream 
TBLPROPERTIES (delta.enableChangeDataFeed = true)
AS
SELECT
  from_json(
    CAST(value AS STRING),
    "SESSION_ID STRING, TIMESTAMP TIMESTAMP, PAGE_NAME STRING, BROWSER_FAMILY STRING, BROWSER_VERSION STRING, OS_FAMILY STRING, DEVICE_FAMILY STRING, DEVICE_BRAND STRING, DEVICE_MODEL STRING, CITY STRING, _rescued_data STRING"
  ) AS kafka_value
FROM
  STREAM (
    read_kafka(
      bootstrapServers => 'b-1.itaudevkafka01.eapmog.c21.kafka.us-east-1.amazonaws.com:9096',
      subscribe => '${topic}',
      `kafka.security.protocol` => 'SASL_SSL',
      `kafka.sasl.jaas.config` => 'kafkashaded.org.apache.kafka.common.security.scram.ScramLoginModule required username="kafka" password="228728f5d92ecff18c0f3fbfb4f9473c";',
      `kafka.sasl.mechanism` => 'SCRAM-SHA-512'
    )
  )

-- COMMAND ----------

-- DBTITLE 1,Criando tabela "streaming" lendo da tabela raw para a tabela CLICKSTREAM
CREATE OR REFRESH STREAMING TABLE silver_clickstream
(
  CONSTRAINT session_id_not_null EXPECT (SESSION_ID IS NOT NULL)  ,
  CONSTRAINT timestamp_not_null EXPECT (TIMESTAMP IS NOT NULL) ON VIOLATION DROP ROW,
  CONSTRAINT page_name_not_null EXPECT (PAGE_NAME IS NOT NULL) ,
  CONSTRAINT browser_family_not_null EXPECT (BROWSER_FAMILY IS NOT NULL) ,
  CONSTRAINT browser_version_not_null EXPECT (BROWSER_VERSION IS NOT NULL) ,
  CONSTRAINT os_family_not_null EXPECT (OS_FAMILY IS NOT NULL) ,
  CONSTRAINT device_family_not_null EXPECT (DEVICE_FAMILY IS NOT NULL) ,
  CONSTRAINT device_brand_not_null EXPECT (DEVICE_BRAND IS NOT NULL) ,
  CONSTRAINT device_model_not_null EXPECT (DEVICE_MODEL IS NOT NULL) ,
  CONSTRAINT city_not_null EXPECT (CITY IS NOT NULL) ON VIOLATION DROP ROW,
  CONSTRAINT rescued_data EXPECT (_rescued_data IS NULL) ON VIOLATION DROP ROW
) 
AS
SELECT
  kafka_value.*
FROM
  STREAM(bronze_clickstream)

-- COMMAND ----------

-- DBTITLE 1,Criando tabelas adicionais (view materializadas)
CREATE OR REPLACE MATERIALIZED VIEW gold_clicks_total_by_os_family AS
SELECT
  OS_FAMILY,
  COUNT(*) AS Count_OS_Family
FROM
  silver_clickstream
GROUP BY
  OS_FAMILY;

CREATE OR REPLACE MATERIALIZED VIEW gold_clicks_total_by_device_family AS
SELECT
  DEVICE_FAMILY,
  COUNT(*) AS Count_Device_Family
FROM
  silver_clickstream
GROUP BY
  DEVICE_FAMILY;

CREATE OR REPLACE MATERIALIZED VIEW gold_clicks_total_by_device_model AS
SELECT
  DEVICE_MODEL,
  COUNT(*) AS Count_Device_Model
FROM
  silver_clickstream
GROUP BY
  DEVICE_MODEL;

CREATE OR REPLACE MATERIALIZED VIEW gold_clicks_total_by_city AS
SELECT
  CITY,
  COUNT(*) AS Count_City
FROM
  silver_clickstream
GROUP BY
  CITY;
