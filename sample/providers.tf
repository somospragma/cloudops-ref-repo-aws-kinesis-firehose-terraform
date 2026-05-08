# Configuración de providers para el ejemplo (PC-IAC-005)

terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }

  # NOTA: El ejemplo usa estado local.
  # En producción, configurar backend S3 según PC-IAC-008
}

################################################################################
# Provider Principal (PC-IAC-005)
################################################################################

provider "aws" {
  alias  = "principal"
  region = var.region

  # Tags por defecto (PC-IAC-004)
  default_tags {
    tags = var.common_tags
  }
}
