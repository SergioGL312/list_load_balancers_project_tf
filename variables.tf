variable "tenant_name" {
  description = "Nombre del tenant a buscar en el archivo de configuración"
  type        = string
  default     = "DEFAULT"
}

variable "compartment_id" {
  description = "OCID del compartment donde buscar recursos (vacío para toda la tenancy)"
  type        = string
  default     = ""
}

data "local_file" "oci_config" {
  filename = pathexpand("~/.oci/config")
}