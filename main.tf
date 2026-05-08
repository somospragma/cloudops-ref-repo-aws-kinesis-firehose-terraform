# Recursos principales del módulo (PC-IAC-010, PC-IAC-020, PC-IAC-023)

################################################################################
# CloudWatch Log Groups para Firehose (PC-IAC-023 - Recurso intrínseco)
################################################################################

resource "aws_cloudwatch_log_group" "firehose" {
  provider = aws.project

  for_each = {
    for key, config in local.streams_config : key => config
    if config.cloudwatch_logging_enabled
  }

  name              = each.value.log_group_name
  retention_in_days = 30
  kms_key_id        = each.value.kms_key_arn # Cifrado en reposo (PC-IAC-020)

  tags = merge(
    { Name = each.value.log_group_name },
    local.base_module_tags,
    each.value.additional_tags
  )
}

resource "aws_cloudwatch_log_stream" "firehose" {
  provider = aws.project

  for_each = {
    for key, config in local.streams_config : key => config
    if config.cloudwatch_logging_enabled
  }

  name           = each.value.log_stream_name
  log_group_name = aws_cloudwatch_log_group.firehose[each.key].name
}

################################################################################
# Kinesis Firehose Delivery Streams - Extended S3 Destination
################################################################################

resource "aws_kinesis_firehose_delivery_stream" "extended_s3" {
  provider = aws.project

  for_each = {
    for key, config in local.streams_config : key => config
    if config.destination == "extended_s3"
  }

  name        = each.value.name
  destination = "extended_s3"

  # Configuración de fuente Kinesis Data Stream (opcional)
  dynamic "kinesis_source_configuration" {
    for_each = length(each.value.kinesis_source_stream_arn) > 0 ? [1] : []
    content {
      kinesis_stream_arn = each.value.kinesis_source_stream_arn
      role_arn           = each.value.role_arn
    }
  }

  # Configuración de destino Extended S3
  extended_s3_configuration {
    role_arn   = each.value.role_arn
    bucket_arn = each.value.s3_bucket_arn

    # Prefijos de S3
    prefix              = each.value.s3_prefix
    error_output_prefix = each.value.s3_error_prefix

    # Configuración de buffering
    buffering_size     = each.value.buffering_size
    buffering_interval = each.value.buffering_interval

    # Compresión
    compression_format = each.value.compression_format

    # Cifrado en reposo con KMS (PC-IAC-020 - Obligatorio)
    kms_key_arn = each.value.kms_key_arn

    # CloudWatch Logging
    dynamic "cloudwatch_logging_options" {
      for_each = each.value.cloudwatch_logging_enabled ? [1] : []
      content {
        enabled         = true
        log_group_name  = aws_cloudwatch_log_group.firehose[each.key].name
        log_stream_name = aws_cloudwatch_log_stream.firehose[each.key].name
      }
    }

    # S3 Backup deshabilitado por defecto (puede habilitarse según necesidad)
    s3_backup_mode = "Disabled"
  }

  # Cifrado del servidor (PC-IAC-020)
  # NOTA: No se puede usar server_side_encryption cuando hay kinesis_source_configuration
  # porque el cifrado ya viene del Data Stream de origen
  dynamic "server_side_encryption" {
    for_each = length(each.value.kinesis_source_stream_arn) == 0 ? [1] : []
    content {
      enabled  = true
      key_type = "CUSTOMER_MANAGED_CMK"
      key_arn  = each.value.kms_key_arn
    }
  }

  tags = merge(
    { Name = each.value.name },
    local.base_module_tags,
    each.value.additional_tags
  )
}

################################################################################
# Kinesis Firehose Delivery Streams - S3 Destination (Legacy)
################################################################################

resource "aws_kinesis_firehose_delivery_stream" "s3" {
  provider = aws.project

  for_each = {
    for key, config in local.streams_config : key => config
    if config.destination == "s3"
  }

  name        = each.value.name
  destination = "extended_s3" # S3 legacy usa extended_s3 internamente

  # Configuración de fuente Kinesis Data Stream (opcional)
  dynamic "kinesis_source_configuration" {
    for_each = length(each.value.kinesis_source_stream_arn) > 0 ? [1] : []
    content {
      kinesis_stream_arn = each.value.kinesis_source_stream_arn
      role_arn           = each.value.role_arn
    }
  }

  # Configuración de destino S3
  extended_s3_configuration {
    role_arn   = each.value.role_arn
    bucket_arn = each.value.s3_bucket_arn

    # Prefijos de S3
    prefix              = each.value.s3_prefix
    error_output_prefix = each.value.s3_error_prefix

    # Configuración de buffering
    buffering_size     = each.value.buffering_size
    buffering_interval = each.value.buffering_interval

    # Compresión
    compression_format = each.value.compression_format

    # Cifrado en reposo con KMS (PC-IAC-020 - Obligatorio)
    kms_key_arn = each.value.kms_key_arn

    # CloudWatch Logging
    dynamic "cloudwatch_logging_options" {
      for_each = each.value.cloudwatch_logging_enabled ? [1] : []
      content {
        enabled         = true
        log_group_name  = aws_cloudwatch_log_group.firehose[each.key].name
        log_stream_name = aws_cloudwatch_log_stream.firehose[each.key].name
      }
    }

    s3_backup_mode = "Disabled"
  }

  # Cifrado del servidor (PC-IAC-020)
  # NOTA: No se puede usar server_side_encryption cuando hay kinesis_source_configuration
  dynamic "server_side_encryption" {
    for_each = length(each.value.kinesis_source_stream_arn) == 0 ? [1] : []
    content {
      enabled  = true
      key_type = "CUSTOMER_MANAGED_CMK"
      key_arn  = each.value.kms_key_arn
    }
  }

  tags = merge(
    { Name = each.value.name },
    local.base_module_tags,
    each.value.additional_tags
  )
}
