variable "resource_group_name" {
	description = "name of resource group"
	type        = string
}

variable "location" {
	description = "location of the resource group"
	type        = string
	default     = "East US"
}

variable "storage_account_name" {
	description = "name of the storage account"
	type        = string
}
