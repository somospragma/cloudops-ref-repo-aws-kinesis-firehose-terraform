# Variables de entrada del módulo (PC-IAC-002)

################################################################################
# Variables de Gobernanza (Obligatorias - PC-IAC-002, PC-IAC-003)
################################################################################

variable "client" {
  description = "Nombre del cliente o unidad de negocio. Usado para nomenclatura y etiquetado."
  type        = string

  validation {
    condition     = length(var.client) > 0 && length(var.client) <= 10
    error_message = "La variable 'client' debe tener entre 1 y 10 caracteres."
  }

  validation {
    condition     = can(regex("^[a-z0-9]+$", var.client))
    error_message = "La variable 'client' solo puede contener letras minúsculas y números."
  }
}

variable "project" {
  description = "Nombre del proyecto. Usado para nomenclatura y etiquetado."
  type        = string

  validation {
    condition     = length(var.project) > 0 && length(var.project) <= 15
    error_message = "La variable 'project' debe tener entre 1 y 15 caracteres."
  }

  validation {
    condition     = can(regex("^[a-z0-9]+$", var.project))
    error_message = "La variable 'project' solo puede contener letras minúsculas y números."
  }
}

variable "environment" {
  description = "Entorno de despliegue (dev, qa, pdn)."
  type        = string

  validation {
    condition     = contains(["dev", "qa", "stg", "pdn", "prod"], var.environment)
    error_message = "La variable 'environment' debe ser uno de: dev, qa, stg, pdn, prod."
  }
}

################################################################################
# Variable de Configuración Principal (PC-IAC-002, PC-IAC-009)
################################################################################

variable "firehose_streams" {
  description = <<-EOT
    Mapa de configuración para los Kinesis Firehose Delivery Streams.
    Cada clave representa un stream único y su configuración.
    
    Atributos:
    - name: Nombre final del stream (construido en el Root según PC-IAC-025)
    - destination: Tipo de destino (s3, extended_s3)
    - s3_bucket_arn: ARN del bucket S3 de destino
    - s3_prefix: Prefijo para los objetos en S3 (opcional)
    - s3_error_prefix: Prefijo para errores en S3 (opcional)
    - buffering_size: Tamaño del buffer en MB (1-128, default: 5)
    - buffering_interval: Intervalo del buffer en segundos (0-900, default: 300)
    - compression_format: Formato de compresión (UNCOMPRESSED, GZIP, ZIP, Snappy, HADOOP_SNAPPY)
    - kms_key_arn: ARN de la llave KMS para cifrado (opcional - si es null/vacío, usa encriptación por defecto del bucket)
    - role_arn: ARN del rol IAM para Firehose
    - cloudwatch_logging_enabled: Habilitar logging en CloudWatch (default: true)
    - log_group_name: Nombre del grupo de logs de CloudWatch (opcional)
    - log_stream_name: Nombre del stream de logs (opcional)
    - kinesis_source_stream_arn: ARN del Kinesis Data Stream como fuente (opcional)
    - file_extension: Extensión de archivo para los objetos en S3 (opcional, ej: ".json", ".parquet")
    - additional_tags: Tags adicionales específicos del stream
  EOT

  type = map(object({
    name                       = string
    destination                = optional(string, "extended_s3")
    s3_bucket_arn              = string
    s3_prefix                  = optional(string, "")
    s3_error_prefix            = optional(string, "errors/")
    buffering_size             = optional(number, 5)
    buffering_interval         = optional(number, 300)
    compression_format         = optional(string, "GZIP")
    kms_key_arn                = optional(string, null)
    role_arn                   = string
    cloudwatch_logging_enabled = optional(bool, true)
    log_group_name             = optional(string, "")
    log_stream_name            = optional(string, "")
    kinesis_source_stream_arn  = optional(string, "")
    file_extension             = optional(string, "")
    additional_tags            = optional(map(string), {})
  }))

  default = {}

  validation {
    condition = alltrue([
      for k, v in var.firehose_streams : length(v.name) > 0
    ])
    error_message = "Cada stream debe tener un 'name' definido."
  }

  validation {
    condition = alltrue([
      for k, v in var.firehose_streams : contains(["s3", "extended_s3"], v.destination)
    ])
    error_message = "El destino debe ser 's3' o 'extended_s3'."
  }

  validation {
    condition = alltrue([
      for k, v in var.firehose_streams : length(v.s3_bucket_arn) > 0
    ])
    error_message = "Cada stream debe tener un 's3_bucket_arn' definido."
  }

  validation {
    condition = alltrue([
      for k, v in var.firehose_streams : length(v.role_arn) > 0
    ])
    error_message = "Cada stream debe tener un 'role_arn' definido (PC-IAC-023)."
  }

  validation {
    condition = alltrue([
      for k, v in var.firehose_streams : v.buffering_size >= 1 && v.buffering_size <= 128
    ])
    error_message = "El 'buffering_size' debe estar entre 1 y 128 MB."
  }

  validation {
    condition = alltrue([
      for k, v in var.firehose_streams : v.buffering_interval >= 0 && v.buffering_interval <= 900
    ])
    error_message = "El 'buffering_interval' debe estar entre 0 y 900 segundos."
  }

  validation {
    condition = alltrue([
      for k, v in var.firehose_streams : contains(
        ["UNCOMPRESSED", "GZIP", "ZIP", "Snappy", "HADOOP_SNAPPY"],
        v.compression_format
      )
    ])
    error_message = "El 'compression_format' debe ser uno de: UNCOMPRESSED, GZIP, ZIP, Snappy, HADOOP_SNAPPY."
  }
}
