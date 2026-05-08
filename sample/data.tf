# Data sources del ejemplo (PC-IAC-026)
#
# Estos data sources obtienen IDs dinámicos de recursos existentes
# para inyectarlos en locals.tf

################################################################################
# Información de la Cuenta y Región
################################################################################

data "aws_caller_identity" "current" {
  provider = aws.principal
}

data "aws_region" "current" {
  provider = aws.principal
}

################################################################################
# VPC (Nomenclatura Estándar PC-IAC-003)
################################################################################

data "aws_vpc" "selected" {
  provider = aws.principal

  filter {
    name   = "tag:Name"
    values = ["${var.client}-${var.project}-${var.environment}-vpc"]
  }
}

################################################################################
# Bucket S3 de Destino (Nomenclatura Estándar PC-IAC-003)
################################################################################

data "aws_s3_bucket" "firehose_destination" {
  provider = aws.principal
  bucket   = "${var.client}-${var.project}-${var.environment}-s3-firehose"
}

################################################################################
# KMS Key para Cifrado (Nomenclatura Estándar PC-IAC-003)
################################################################################

data "aws_kms_key" "firehose" {
  provider = aws.principal
  key_id   = "alias/${var.client}-${var.project}-${var.environment}-kms-firehose"
}

################################################################################
# IAM Role para Firehose (Nomenclatura Estándar PC-IAC-003)
################################################################################

data "aws_iam_role" "firehose" {
  provider = aws.principal
  name     = "${var.client}-${var.project}-${var.environment}-role-firehose"
}
