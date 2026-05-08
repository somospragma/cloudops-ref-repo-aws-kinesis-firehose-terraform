# Variables del ejemplo (PC-IAC-026)

################################################################################
# Variables de Gobernanza
################################################################################

variable "client" {
  description = "Nombre del cliente o unidad de negocio."
  type        = string
}

variable "project" {
  description = "Nombre del proyecto."
  type        = string
}

variable "environment" {
  description = "Entorno de despliegue (dev, qa, pdn)."
  type        = string
}

variable "region" {
  description = "Región de AWS para el despliegue."
  type        = string
  default     = "us-east-1"
}

################################################################################
# Variable de Configuración de Firehose
################################################################################

variable "firehose_streams" {
  description = "Mapa de configuración base para los Firehose Delivery Streams."
  type = map(object({
    description        = optional(string, "")
    destination        = optional(string, "extended_s3")
    s3_bucket_arn      = optional(string, "")
    s3_prefix          = optional(string, "")
    s3_error_prefix    = optional(string, "")
    buffering_size     = optional(number, 5)
    buffering_interval = optional(number, 300)
    compression_format = optional(string, "GZIP")
    kms_key_arn        = optional(string, "")
    role_arn           = optional(string, "")
  }))
  default = {}
}

################################################################################
# Tags Comunes
################################################################################

variable "common_tags" {
  description = "Tags comunes para aplicar a todos los recursos."
  type        = map(string)
  default     = {}
}
