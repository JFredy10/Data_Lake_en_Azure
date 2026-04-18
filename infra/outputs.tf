output "resource_group_name" {
  description = "nombre del resource group"
  value       = azurerm_storage_account.rg.name
}

output "storage_account_name" {
  description = "nombre del storage account"
  value       = azurerm_storage_account.adls.name
}

output "bronze_container_name" {
  description = "nombre del contenedor bronze"
  value       = azurerm_storage_container.bronze.name
}

output "silver_container_name" {
  description = "nombre del contenedor silver"
  value       = azurerm_storage_container.silver.name
}

output "gold_container_name" {
  description = "nombre del contenedor gold"
  value       = azurerm_storage_container.gold.name
}
