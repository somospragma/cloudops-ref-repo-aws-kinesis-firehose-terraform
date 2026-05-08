# Outputs del módulo (PC-IAC-007, PC-IAC-014)

################################################################################
# Outputs de Firehose Delivery Streams
################################################################################

output "firehose_stream_arns" {
  description = "Mapa de ARNs de los Kinesis Firehose Delivery Streams creados."
  value = merge(
    { for key, stream in aws_kinesis_firehose_delivery_stream.extended_s3 : key => stream.arn },
    { for key, stream in aws_kinesis_firehose_delivery_stream.s3 : key => stream.arn }
  )
}

output "firehose_stream_names" {
  description = "Mapa de nombres de los Kinesis Firehose Delivery Streams creados."
  value = merge(
    { for key, stream in aws_kinesis_firehose_delivery_stream.extended_s3 : key => stream.name },
    { for key, stream in aws_kinesis_firehose_delivery_stream.s3 : key => stream.name }
  )
}

output "firehose_stream_ids" {
  description = "Mapa de IDs de los Kinesis Firehose Delivery Streams creados."
  value = merge(
    { for key, stream in aws_kinesis_firehose_delivery_stream.extended_s3 : key => stream.id },
    { for key, stream in aws_kinesis_firehose_delivery_stream.s3 : key => stream.id }
  )
}

################################################################################
# Outputs de CloudWatch Log Groups
################################################################################

output "cloudwatch_log_group_arns" {
  description = "Mapa de ARNs de los CloudWatch Log Groups creados para los streams."
  value       = { for key, log_group in aws_cloudwatch_log_group.firehose : key => log_group.arn }
}

output "cloudwatch_log_group_names" {
  description = "Mapa de nombres de los CloudWatch Log Groups creados para los streams."
  value       = { for key, log_group in aws_cloudwatch_log_group.firehose : key => log_group.name }
}

################################################################################
# Outputs Agregados (Splat Expressions - PC-IAC-014)
################################################################################

output "all_firehose_arns" {
  description = "Lista de todos los ARNs de Firehose Delivery Streams creados."
  value = concat(
    values(aws_kinesis_firehose_delivery_stream.extended_s3)[*].arn,
    values(aws_kinesis_firehose_delivery_stream.s3)[*].arn
  )
}

output "all_firehose_names" {
  description = "Lista de todos los nombres de Firehose Delivery Streams creados."
  value = concat(
    values(aws_kinesis_firehose_delivery_stream.extended_s3)[*].name,
    values(aws_kinesis_firehose_delivery_stream.s3)[*].name
  )
}
