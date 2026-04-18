variable "resource_group_name" {
	descripiton = "name of resource group"
	type        = string
}

variable "location" {
	descripiton = "location of the resource group"
	type        = string
	default     = "East US"
}

variable "storage_account_name" {
	descripiton = "name of the storage account"
	type        = string
}
