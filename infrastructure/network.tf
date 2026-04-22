## Virtual Network & Subnet
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-data-platform-dev"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "pe_subnet" {
  name                 = "snet-private-endpoints"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  # Deshabilitar políticas privadas temporalmente si se requiere
  private_endpoint_network_policies = "Disabled"
}

## Private DNS Zone para Blob Services (ADLS Gen2)
resource "azurerm_private_dns_zone" "pdns_blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns_link" {
  name                  = "vnet-dns-link"
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.pdns_blob.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

## Private Endpoint para el Storage Account
resource "azurerm_private_endpoint" "adls_pe" {
  name                = "pe-adls-dev"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id           = azurerm_subnet.pe_subnet.id

  private_service_connection {
    name                           = "psc-adls-blob"
    private_connection_resource_id = azurerm_storage_account.datalake.id
    subresource_names              = ["dfs"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "dns-group-adls"
    private_dns_zone_ids = [azurerm_private_dns_zone.pdns_blob.id]
  }
}
