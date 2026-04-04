# ---------------------------------------------
# Azure Stream Analytics Job
# ---------------------------------------------
resource "azurerm_stream_analytics_job" "asa_job" {
  name                                     = "asa-dataplatform-dev"
  resource_group_name                      = azurerm_resource_group.rg.name
  location                                 = azurerm_resource_group.rg.location
  compatibility_level                      = "1.2"
  data_locale                              = "en-US"
  events_late_arrival_max_delay_in_seconds = 60
  events_out_of_order_max_delay_in_seconds = 50
  events_out_of_order_policy               = "Adjust"
  output_error_policy                      = "Drop"
  streaming_units                          = 3

  transformation_query = file("${path.module}/../stream_analytics/query.saql")
}

# ---------------------------------------------
# ASA Input: Event Hub
# ---------------------------------------------
resource "azurerm_stream_analytics_stream_input_eventhub" "asa_input" {
  name                         = "eh-iot-input"
  stream_analytics_job_name    = azurerm_stream_analytics_job.asa_job.name
  resource_group_name          = azurerm_resource_group.rg.name
  eventhub_consumer_group_name = "$Default"
  eventhub_name                = azurerm_eventhub.hub.name
  servicebus_namespace         = azurerm_eventhub_namespace.eh_namespace.name
  shared_access_policy_key     = azurerm_eventhub_authorization_rule.eh_auth.primary_key
  shared_access_policy_name    = azurerm_eventhub_authorization_rule.eh_auth.name

  serialization {
    type     = "Json"
    encoding = "UTF8"
  }
}

# ---------------------------------------------
# ASA Outputs: ADLS Gen2 (Silver container)
# 1. Tumbling Window aggregations
# ---------------------------------------------
resource "azurerm_stream_analytics_output_blob" "asa_output_telemetry" {
  name                      = "silver-telemetry-output"
  stream_analytics_job_name = azurerm_stream_analytics_job.asa_job.name
  resource_group_name       = azurerm_resource_group.rg.name
  storage_account_name      = azurerm_storage_account.adls.name
  storage_account_key       = azurerm_storage_account.adls.primary_access_key
  storage_container_name    = azurerm_storage_data_lake_gen2_filesystem.silver.name
  path_pattern              = "telemetry/{date}/{time}"
  date_format               = "yyyy/MM/dd"
  time_format               = "HH"

  serialization {
    type            = "Json"
    encoding        = "UTF8"
    format          = "LineSeparated"
  }
}

# ---------------------------------------------
# 2. Alert generation Output
# ---------------------------------------------
resource "azurerm_stream_analytics_output_blob" "asa_output_alerts" {
  name                      = "silver-alert-output"
  stream_analytics_job_name = azurerm_stream_analytics_job.asa_job.name
  resource_group_name       = azurerm_resource_group.rg.name
  storage_account_name      = azurerm_storage_account.adls.name
  storage_account_key       = azurerm_storage_account.adls.primary_access_key
  storage_container_name    = azurerm_storage_data_lake_gen2_filesystem.silver.name
  path_pattern              = "alerts/{date}/{time}"
  date_format               = "yyyy/MM/dd"
  time_format               = "HH"

  serialization {
    type            = "Json"
    encoding        = "UTF8"
    format          = "LineSeparated"
  }
}
