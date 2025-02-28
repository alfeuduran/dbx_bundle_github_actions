from unittest.mock import MagicMock, patch
from pyspark.sql import SparkSession, DataFrame
import pytest

# Importar as funções que queremos testar
from dbx_bundle_github_actions.main import get_taxis

# Criar um mock para o SparkSession
@pytest.fixture
def mock_spark():
    spark = MagicMock(spec=SparkSession)
    # Configurar o mock para retornar um DataFrame quando read.table for chamado
    mock_df = MagicMock(spec=DataFrame)
    mock_df.count.return_value = 10  # Simular que o DataFrame tem 10 linhas
    spark.read.table.return_value = mock_df
    return spark

# Teste usando o mock
def test_main(mock_spark):
    # Testar a função get_taxis com o mock do SparkSession
    taxis = get_taxis(mock_spark)
    # Verificar se a função read.table foi chamada com o argumento correto
    mock_spark.read.table.assert_called_once_with("samples.nyctaxi.trips")
    # Verificar se o DataFrame retornado tem o número esperado de linhas
    assert taxis.count() == 10
