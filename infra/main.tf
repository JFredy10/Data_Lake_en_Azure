# - [x] Storage Account con Hierarchical Namespace habilitado.
# - [ ] Contenedores: bronze, silver, gold con ACLs por capa.
# - [ ] Lifecycle policy: bronze data > 90 días → Cool tier; > 365 días → Archive.
# - [ ] Private Endpoint para acceso seguro desde Synapse y Data Factory.

provider "azurerm" {
	features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "adls" {
	name                     = var.storage_account_name
	resource_group_name      = azurerm_resource_group.rg.name
	location                 = azurerm_resource_group.rg.location
	account_tier             = "Standard"
	account_replication_type = "LRS"
	account_kind             = "StorageV2"
	is_hns_enabled           = "true" # activar el hierarchical namespace

  # TODO: politicas de retención (delete_retencion_policy)
}

resource "azurerm_storage_container" "bronze" {
	name                  = "bronze"
	storage_account_id    = azurerm_storage_account.adls.name
	container_access_type = "private"
}

resource "azurerm_storage_container" "silver" {
  name                  = "silver"
  storage_account_id    = azurerm_storage_account.adls.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "gold" {
	name                  = "gold"
	storage_account_id    = azurerm_storage_account.adls.name
	container_access_type = "private"
}
