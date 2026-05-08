# Data sources del módulo (PC-IAC-011)
#
# NOTA: Según PC-IAC-011, los Data Sources deben declararse en el Módulo Raíz (IaC Root),
# no en los Módulos de Referencia. Los IDs y ARNs necesarios deben ser pasados
# como variables de entrada al módulo.
#
# Este archivo se mantiene vacío intencionalmente para cumplir con la estructura
# obligatoria PC-IAC-001, pero no debe contener Data Sources de recursos externos.
#
# Excepción permitida: Data Sources genéricos como aws_region o aws_caller_identity
# pueden usarse si son necesarios para la lógica interna del módulo.

data "aws_caller_identity" "current" {
  provider = aws.project
}

data "aws_region" "current" {
  provider = aws.project
}
