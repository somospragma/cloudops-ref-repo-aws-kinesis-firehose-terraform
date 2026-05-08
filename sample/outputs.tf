# Outputs del ejemplo (PC-IAC-007)

################################################################################
# Outputs de Firehose Streams
################################################################################

output "firehose_stream_arns" {
  description = "ARNs de los Kinesis Firehose Delivery Streams creados."
  value       = module.kinesis_firehose.firehose_stream_arns
}

output "firehose_stream_names" {
  description = "Nombres de los Kinesis Firehose Delivery Streams creados."
  value       = module.kinesis_firehose.firehose_stream_names
}

output "firehose_stream_ids" {
  description = "IDs de los Kinesis Firehose Delivery Streams creados."
  value       = module.kinesis_firehose.firehose_stream_ids
}

################################################################################
# Outputs de CloudWatch
################################################################################

output "cloudwatch_log_group_arns" {
  description = "ARNs de los CloudWatch Log Groups creados."
  value       = module.kinesis_firehose.cloudwatch_log_group_arns
}

output "cloudwatch_log_group_names" {
  description = "Nombres de los CloudWatch Log Groups creados."
  value       = module.kinesis_firehose.cloudwatch_log_group_names
}

################################################################################
# Outputs Agregados
################################################################################

output "all_firehose_arns" {
  description = "Lista de todos los ARNs de Firehose Streams."
  value       = module.kinesis_firehose.all_firehose_arns
}

output "all_firehose_names" {
  description = "Lista de todos los nombres de Firehose Streams."
  value       = module.kinesis_firehose.all_firehose_names
}

################################################################################
# Información de Contexto
################################################################################

output "governance_prefix" {
  description = "Prefijo de gobernanza utilizado para la nomenclatura."
  value       = local.governance_prefix
}
