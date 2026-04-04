resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# ---------------------------------------------
# Azure Data Lake Storage Gen2
# ---------------------------------------------
resource "azurerm_storage_account" "adls" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = true

  tags = {
    environment = "dev"
    project     = "data-platform"
  }
}

# ---------------------------------------------
# Medallion Architecture Containers (Bronze/Silver/Gold)
# ---------------------------------------------
resource "azurerm_storage_data_lake_gen2_filesystem" "bronze" {
  name               = "bronze"
  storage_account_id = azurerm_storage_account.adls.id
}

resource "azurerm_storage_data_lake_gen2_filesystem" "silver" {
  name               = "silver"
  storage_account_id = azurerm_storage_account.adls.id
}

resource "azurerm_storage_data_lake_gen2_filesystem" "gold" {
  name               = "gold"
  storage_account_id = azurerm_storage_account.adls.id
}

# ---------------------------------------------
# Lifecycle Management Policy para Bronze
# > 90 días a Cool tier; > 365 días a Archive
# ---------------------------------------------
resource "azurerm_storage_management_policy" "adls_lifecycle" {
  storage_account_id = azurerm_storage_account.adls.id

  rule {
    name    = "bronze-lifecycle-policy"
    enabled = true
    filters {
      prefix_match = ["bronze/"]
      blob_types   = ["blockBlob"]
    }
    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than    = 90
        tier_to_archive_after_days_since_modification_greater_than = 365
      }
    }
  }
}
