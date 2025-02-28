from pyspark.sql import SparkSession, DataFrame
import os


def get_taxis(spark: SparkSession) -> DataFrame:
    return spark.read.table("samples.nyctaxi.trips")


# Create a new Databricks Connect session. If this fails,
# check that you have configured Databricks Connect correctly.
# See https://docs.databricks.com/dev-tools/databricks-connect.html.
def get_spark() -> SparkSession:
    try:
        from databricks.connect import DatabricksSession

        # Usar o ID do cluster fornecido como variável de ambiente
        cluster_id = os.environ.get("DATABRICKS_CLUSTER_ID")
        
        # Configurar a sessão com o ID do cluster
        return DatabricksSession.builder.remote(
            host=os.environ.get("DATABRICKS_HOST"),
            token=os.environ.get("DATABRICKS_TOKEN"),
            cluster_id=cluster_id
        ).getOrCreate()
    except ImportError:
        return SparkSession.builder.getOrCreate()


def main():
    get_taxis(get_spark()).show(5)


if __name__ == "__main__":
    main()
