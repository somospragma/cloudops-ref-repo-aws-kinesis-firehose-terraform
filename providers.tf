# Configuración de providers (PC-IAC-005)
# 
# NOTA: Este módulo de referencia NO configura el provider directamente.
# El provider debe ser inyectado desde el Módulo Raíz (IaC Root) utilizando
# el alias aws.project definido en versions.tf.
#
# Ejemplo de inyección desde el Root:
#
# module "kinesis_firehose" {
#   source = "git::https://repo/kinesis-firehose-module.git?ref=v1.0.0"
#   
#   providers = {
#     aws.project = aws.principal
#   }
#   
#   # ... variables
# }
