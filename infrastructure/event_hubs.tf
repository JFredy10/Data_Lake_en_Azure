# ---------------------------------------------
# Azure Event Hubs (Generador de Eventos / Ingesta Tiempo Real)
# ---------------------------------------------
resource "azurerm_eventhub_namespace" "eh_namespace" {
  name                = var.eventhub_namespace_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
  capacity            = 1
}

# Hub de 4 particiones, retención de 7 días
resource "azurerm_eventhub" "hub" {
  name                = "eh-iot-telemetry"
  namespace_name      = azurerm_eventhub_namespace.eh_namespace.name
  resource_group_name = azurerm_resource_group.rg.name

  partition_count   = 4
  message_retention = 7
}

resource "azurerm_eventhub_authorization_rule" "eh_auth" {
  name                = "RootManageSharedAccessKey"
  namespace_name      = azurerm_eventhub_namespace.eh_namespace.name
  eventhub_name       = azurerm_eventhub.hub.name
  resource_group_name = azurerm_resource_group.rg.name

  listen = true
  send   = true
  manage = true
}

output "eventhub_connection_string" {
  value     = azurerm_eventhub_authorization_rule.eh_auth.primary_connection_string
  sensitive = true
}
