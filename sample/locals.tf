# Transformaciones del ejemplo (PC-IAC-026)
#
# Este archivo contiene TODAS las transformaciones e inyecciones dinámicas.
# El archivo main.tf solo debe consumir valores de local.*

locals {
  # Prefijo de gobernanza (PC-IAC-003, PC-IAC-025)
  governance_prefix = "${var.client}-${var.project}-${var.environment}"

  # Transformar configuración de streams inyectando IDs dinámicos (PC-IAC-009, PC-IAC-026)
  firehose_streams_transformed = {
    for key, config in var.firehose_streams : key => {
      # Nombre final construido en el Root (PC-IAC-025)
      name = "${local.governance_prefix}-firehose-${key}"

      # Configuración base
      destination        = config.destination
      buffering_size     = config.buffering_size
      buffering_interval = config.buffering_interval
      compression_format = config.compression_format

      # Inyección dinámica de S3 Bucket ARN
      s3_bucket_arn = length(config.s3_bucket_arn) > 0 ? config.s3_bucket_arn : data.aws_s3_bucket.firehose_destination.arn

      # Construcción de prefijos S3 con nomenclatura estándar
      s3_prefix = length(config.s3_prefix) > 0 ? config.s3_prefix : "${local.governance_prefix}/${key}/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/"

      s3_error_prefix = length(config.s3_error_prefix) > 0 ? config.s3_error_prefix : "${local.governance_prefix}/${key}/errors/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/"

      # Inyección dinámica de KMS Key ARN (PC-IAC-020)
      kms_key_arn = length(config.kms_key_arn) > 0 ? config.kms_key_arn : data.aws_kms_key.firehose.arn

      # Inyección dinámica de IAM Role ARN (PC-IAC-023)
      role_arn = length(config.role_arn) > 0 ? config.role_arn : data.aws_iam_role.firehose.arn

      # CloudWatch Logging habilitado por defecto
      cloudwatch_logging_enabled = true
      log_group_name             = ""
      log_stream_name            = ""

      # Sin fuente Kinesis Data Stream en este ejemplo
      kinesis_source_stream_arn = ""

      # Tags adicionales específicos del stream
      additional_tags = {
        Description = config.description
        StreamKey   = key
      }
    }
  }
}
