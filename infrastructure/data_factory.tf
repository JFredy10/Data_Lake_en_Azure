# ---------------------------------------------
# Azure Data Factory Base
# ---------------------------------------------
resource "azurerm_data_factory" "adf" {
  name                = "adf-dataplatform-dev-cx99"
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

  # Definición importada / leida del JSON para simplificar estructura en TF
  # Se crea un framework base. Las actividades complejas (como Mapping Data Flows) 
  # habitualmente se agregan a través de integración de Repositorios en ADF o JSON
}
