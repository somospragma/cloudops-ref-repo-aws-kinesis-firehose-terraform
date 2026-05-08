# Valores locales y transformaciones (PC-IAC-012)

locals {
  # Prefijo de gobernanza para nomenclatura (PC-IAC-003)
  governance_prefix = "${var.client}-${var.project}-${var.environment}"

  # Tipo de recurso para nomenclatura
  resource_type = "firehose"

  # Tags base del módulo (PC-IAC-004)
  base_module_tags = {
    "managed-by" = "terraform"
    "module"     = "kinesis-firehose"
  }

  # Configuración de streams con valores por defecto aplicados (PC-IAC-009)
  streams_config = {
    for key, config in var.firehose_streams : key => {
      name                       = config.name
      destination                = config.destination
      s3_bucket_arn              = config.s3_bucket_arn
      s3_prefix                  = length(config.s3_prefix) > 0 ? config.s3_prefix : "${local.governance_prefix}/${key}/"
      s3_error_prefix            = length(config.s3_error_prefix) > 0 ? config.s3_error_prefix : "${local.governance_prefix}/${key}/errors/"
      buffering_size             = config.buffering_size
      buffering_interval         = config.buffering_interval
      compression_format         = config.compression_format
      kms_key_arn                = config.kms_key_arn
      role_arn                   = config.role_arn
      cloudwatch_logging_enabled = config.cloudwatch_logging_enabled
      log_group_name             = length(config.log_group_name) > 0 ? config.log_group_name : "/aws/kinesisfirehose/${config.name}"
      log_stream_name            = length(config.log_stream_name) > 0 ? config.log_stream_name : "DestinationDelivery"
      kinesis_source_stream_arn  = config.kinesis_source_stream_arn
      additional_tags            = config.additional_tags
    }
  }

  # Filtrar streams que tienen Kinesis Data Stream como fuente
  streams_with_kinesis_source = {
    for key, config in local.streams_config : key => config
    if length(config.kinesis_source_stream_arn) > 0
  }

  # Filtrar streams sin fuente Kinesis (Direct PUT)
  streams_direct_put = {
    for key, config in local.streams_config : key => config
    if length(config.kinesis_source_stream_arn) == 0
  }
}
