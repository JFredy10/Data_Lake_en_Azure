variable "location" {
  description = "Región de Azure para despliegue de recursos"
  type        = string
  default     = "East US"
}

variable "resource_group_name" {
  description = "Nombre del grupo de recursos principal"
  type        = string
  default     = "rg-data-platform-dev"
}

variable "storage_account_name" {
  description = "Nombre del Storage Account (Data Lake Gen2). Debe ser globalmente único."
  type        = string
  default     = "stdataplatformdevcx99"
}

variable "eventhub_namespace_name" {
  description = "Nombre del Namespace de Event Hubs."
  type        = string
  default     = "evhns-dataplatform-dev"
}

variable "sql_admin_user" {
  description = "Usuario administrador de Synapse"
  type        = string
  default     = "sqladminuser"
}

variable "sql_admin_password" {
  description = "Contraseña de Synapse ingresala en ejecucion"
  type        = string
  sensitive   = true
  default     = null 
}
