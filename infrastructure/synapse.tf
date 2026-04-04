# Comentado para la Entrega 1 por restricciones de region
/*
resource "azurerm_synapse_workspace" "synapse_ws" {
  name                                 = "syn-ws-dataplatform-dev"
  resource_group_name                  = azurerm_resource_group.rg.name
  location                             = azurerm_resource_group.rg.location
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.bronze.id

  # Cuenta por defecto y credenciales
  sql_administrator_login              = var.sql_admin_user
  sql_administrator_login_password     = var.sql_admin_password # Las contraseñas deben estar seguras

  identity {
    type = "SystemAssigned"
  }
}

# Dar permisos al Managed Identity de Synapse en el Storage Account general
resource "azurerm_role_assignment" "synapse_blob_contributor" {
  scope                = azurerm_storage_account.adls.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_synapse_workspace.synapse_ws.identity.0.principal_id
}
*/

# ---------------------------------------------
# Azure Monitor / Logs para Synapse
# ---------------------------------------------
resource "azurerm_log_analytics_workspace" "law" {
  name                = "law-dataplatform-dev"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
}

/*
resource "azurerm_monitor_diagnostic_setting" "synapse_diag" {
  name                       = "synapse-diagnostic-settings"
  target_resource_id         = azurerm_synapse_workspace.synapse_ws.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  enabled_log {
    category = "SynapseRbacOperations"
  }

  enabled_log {
    category = "GatewayApiRequests"
  }

  enabled_log {
    category = "BuiltinSqlReqsEnded"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
*/
