# Invocación del módulo padre (PC-IAC-026)
#
# NOTA: Este archivo SOLO contiene la invocación del módulo.
# Las transformaciones están en locals.tf
# NO debe haber bloques locals {} en este archivo.

################################################################################
# Invocación del Módulo Kinesis Firehose
################################################################################

module "kinesis_firehose" {
  source = "../" # Apunta al módulo padre

  providers = {
    aws.project = aws.principal
  }

  # Variables de gobernanza (PC-IAC-003)
  client      = var.client
  project     = var.project
  environment = var.environment

  # Configuración transformada desde locals (PC-IAC-026)
  firehose_streams = local.firehose_streams_transformed
}
