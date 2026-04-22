resource "azurerm_data_factory" "data_factory" {
  name                = "adf-dataplatform-dev-cx99"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  identity {
    type = "SystemAssigned"
  }
}

## linked service to data-lake-gen2
resource "azurerm_data_factory_linked_service_data_lake_storage_gen2" "df_link_dl" {
  name                  = "LS_ADLS_Gen2"
  data_factory_id       = azurerm_data_factory.data_factory.id
  url                   = "https://${azurerm_storage_account.datalake.name}.dfs.core.windows.net"
  use_managed_identity  = true
}

## Otorga permisos al Managed Identity de Data Factory en el Storage Account (Blob Data Contributor)
resource "azurerm_role_assignment" "adf_blob_contributor" {
  scope                = azurerm_storage_account.datalake.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_data_factory.data_factory.identity.0.principal_id
}

## diary 2:00 AM schedule check
resource "azurerm_data_factory_trigger_schedule" "daily_batch_trigger" {
  name            = "trigger-daily-batch-2am"
  data_factory_id = azurerm_data_factory.data_factory.id
  pipeline_name   = "Pipeline_Daily_Batch_Bronze_to_Gold"
  
  interval  = 1
  frequency = "Day"
  start_time = "2024-01-01T02:00:00Z"

  depends_on = [
    # requires the existence of the pipeline
    azurerm_data_factory_pipeline.batch_pipeline
  ]
}

## Data Factory pipeline skeleton
resource "azurerm_data_factory_pipeline" "batch_pipeline" {
  name            = "Pipeline_Daily_Batch_Bronze_to_Gold"
  data_factory_id = azurerm_data_factory.data_factory.id

  # Definición importada / leida del JSON para simplificar estructura en TF
  # Se crea un framework base. Las actividades complejas (como Mapping Data Flows) 
  # habitualmente se agregan a través de integración de Repositorios en ADF o JSON
}


