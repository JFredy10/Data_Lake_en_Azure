# - [x] Storage Account con Hierarchical Namespace habilitado.
# - [x] Contenedores: bronze, silver, gold con ACLs por capa.
# - [ ] Lifecycle policy: bronze data > 90 días → Cool tier; > 365 días → Archive.
# - [ ] Private Endpoint para acceso seguro desde Synapse y Data Factory.

provider "azurerm" {
	features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "datalake" {
	name                     = var.storage_account_name
	resource_group_name      = azurerm_resource_group.main.name
	location                 = azurerm_resource_group.main.location
	account_tier             = "Standard"
	account_replication_type = "LRS"
	account_kind             = "StorageV2"
	is_hns_enabled           = "true" # activar el hierarchical namespace

  # TODO: politicas de retención (delete_retencion_policy)
}

# resource "azurerm_storage_container" "bronze" {
# 	name                  = "bronze"
# 	storage_account_id    = azurerm_storage_account.datalake.id
# 	container_access_type = "private"
# }
#
# resource "azurerm_storage_container" "silver" {
#   name                  = "silver"
#   storage_account_id    = azurerm_storage_account.datalake.id
#   container_access_type = "private"
# }
#
# resource "azurerm_storage_container" "gold" {
# 	name                  = "gold"
# 	storage_account_id    = azurerm_storage_account.datalake.id
# 	container_access_type = "private"
# }

resource "azurerm_storage_data_lake_gen2_filesystem" "bronze" {
  name               = "bronze"
  storage_account_id = azurerm_storage_account.datalake.id
}

resource "azurerm_storage_data_lake_gen2_filesystem" "silver" {
  name               = "silver"
  storage_account_id = azurerm_storage_account.datalake.id
}

resource "azurerm_storage_data_lake_gen2_filesystem" "gold" {
  name               = "gold"
  storage_account_id = azurerm_storage_account.datalake.id
}
