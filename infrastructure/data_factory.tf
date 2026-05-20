# ---------------------------------------------
# Azure Data Factory Base
# ---------------------------------------------
resource "azurerm_data_factory" "adf" {
  name                = "adf-dataplatform-dev-cx99-v2"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  identity {
    type = "SystemAssigned"
  }
}

# ---------------------------------------------
# Linked Service to Data Lake Gen2
# ---------------------------------------------
resource "azurerm_data_factory_linked_service_data_lake_storage_gen2" "adf_ls_adls" {
  name                  = "LS_ADLS_Gen2"
  data_factory_id       = azurerm_data_factory.adf.id
  url                   = "https://${azurerm_storage_account.adls.name}.dfs.core.windows.net"
  use_managed_identity  = true
}

# Otorga permisos al Managed Identity de Data Factory en el Storage Account (Blob Data Contributor)
resource "azurerm_role_assignment" "adf_blob_contributor" {
  scope                = azurerm_storage_account.adls.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_data_factory.adf.identity.0.principal_id
}

# ---------------------------------------------
# Triggers: Schedule Diario a las 2:00 AM
# ---------------------------------------------
resource "azurerm_data_factory_trigger_schedule" "daily_batch_trigger" {
  name            = "trigger-daily-batch-2am"
  data_factory_id = azurerm_data_factory.adf.id
  pipeline_name   = "Pipeline_Daily_Batch_Bronze_to_Gold"
  
  interval  = 1
  frequency = "Day"
  start_time = "2024-01-01T02:00:00Z"

  depends_on = [
    # Requiere que exista la pipeline
    azurerm_data_factory_pipeline.batch_pipeline
  ]
}

# ---------------------------------------------
# Data Factory Pipeline Skeleton
# ---------------------------------------------
resource "azurerm_data_factory_pipeline" "batch_pipeline" {
  name            = "Pipeline_Daily_Batch_Bronze_to_Gold"
  data_factory_id = azurerm_data_factory.adf.id

  # Decodificamos el archivo original y extraemos solo el array "activities"
  activities_json = jsonencode(
    jsondecode(file("${path.module}/../data_factory/batch_pipeline.json")).properties.activities
  )

  depends_on = [
    azurerm_data_factory_dataset_delimited_text.ds_csv,
    azurerm_data_factory_dataset_parquet.ds_parquet,
    azurerm_data_factory_dataset_parquet.ds_silver,
    azurerm_data_factory_dataset_parquet.ds_gold,
    azurerm_data_factory_data_flow.df_clean,
    azurerm_data_factory_data_flow.df_gold
  ]
}

resource "azurerm_data_factory_dataset_delimited_text" "ds_csv" {
  name                = "DS_Source_CSV"
  data_factory_id     = azurerm_data_factory.adf.id
  linked_service_name = azurerm_data_factory_linked_service_data_lake_storage_gen2.adf_ls_adls.name
  azure_blob_fs_location {
    file_system = "bronze"
    filename    = "source.csv"
  }
}

resource "azurerm_data_factory_dataset_parquet" "ds_parquet" {
  name                = "DS_Bronze_Parquet"
  data_factory_id     = azurerm_data_factory.adf.id
  linked_service_name = azurerm_data_factory_linked_service_data_lake_storage_gen2.adf_ls_adls.name
  azure_blob_fs_location {
    file_system = "bronze"
    filename    = "output.parquet"
  }
}

resource "azurerm_data_factory_dataset_parquet" "ds_silver" {
  name                = "DS_Silver_Parquet"
  data_factory_id     = azurerm_data_factory.adf.id
  linked_service_name = azurerm_data_factory_linked_service_data_lake_storage_gen2.adf_ls_adls.name
  azure_blob_fs_location {
    file_system = "silver"
    filename    = "data.parquet"
  }
}

resource "azurerm_data_factory_dataset_parquet" "ds_gold" {
  name                = "DS_Gold_Parquet"
  data_factory_id     = azurerm_data_factory.adf.id
  linked_service_name = azurerm_data_factory_linked_service_data_lake_storage_gen2.adf_ls_adls.name
  azure_blob_fs_location {
    file_system = "gold"
    filename    = "data.parquet"
  }
}

resource "azurerm_data_factory_data_flow" "df_clean" {
  name            = "DF_Clean_Nulls_Dates"
  data_factory_id = azurerm_data_factory.adf.id

  source {
    name = "BronzeSource"
    dataset {
      name = azurerm_data_factory_dataset_parquet.ds_parquet.name
    }
  }

  sink {
    name = "SilverSink"
    dataset {
      name = azurerm_data_factory_dataset_parquet.ds_silver.name
    }
  }

  script = <<EOT
source(allowSchemaDrift: true,
	validateSchema: false,
	ignoreNoFilesFound: false,
	format: 'parquet') ~> BronzeSource
BronzeSource derive(timestamp = toTimestamp(timestamp, 'yyyy-MM-dd\'T\'HH:mm:ss\'Z\''),
		temperature = iif(isNull(temperature), 0.0, toDouble(temperature)),
		humidity = iif(isNull(humidity), 0.0, toDouble(humidity))) ~> CleanData
CleanData sink(allowSchemaDrift: true,
	validateSchema: false,
	format: 'parquet',
	umask: 0022,
	preCommands: [],
	postCommands: [],
	skipDuplicateMapInputs: true,
	skipDuplicateMapOutputs: true) ~> SilverSink
EOT
}

resource "azurerm_data_factory_data_flow" "df_gold" {
  name            = "DF_Gold_Aggregations"
  data_factory_id = azurerm_data_factory.adf.id

  source {
    name = "SilverSource"
    dataset {
      name = azurerm_data_factory_dataset_parquet.ds_silver.name
    }
  }

  sink {
    name = "GoldSink"
    dataset {
      name = azurerm_data_factory_dataset_parquet.ds_gold.name
    }
  }

  script = <<EOT
source(allowSchemaDrift: true,
	validateSchema: false,
	ignoreNoFilesFound: false,
	format: 'parquet') ~> SilverSource
SilverSource aggregate(groupBy(device_id),
	avg_temperature = round(avg(temperature), 2),
	max_humidity = round(max(humidity), 2)) ~> AggregateData
AggregateData sink(allowSchemaDrift: true,
	validateSchema: false,
	format: 'parquet',
	umask: 0022,
	preCommands: [],
	postCommands: [],
	skipDuplicateMapInputs: true,
	skipDuplicateMapOutputs: true) ~> GoldSink
EOT
}
