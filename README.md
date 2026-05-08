# Kinesis Firehose Module

Módulo de referencia Terraform para la creación de Amazon Kinesis Data Firehose Delivery Streams con destino S3.

## Descripción

Este módulo implementa Kinesis Firehose Delivery Streams siguiendo las mejores prácticas de seguridad del AWS Well-Architected Framework y las reglas de gobernanza PC-IAC de Pragma.

### Características

- Soporte para destinos S3 y Extended S3
- Cifrado obligatorio en reposo con KMS (PC-IAC-020)
- Integración con CloudWatch Logs para monitoreo
- Soporte para Kinesis Data Stream como fuente
- Configuración flexible de buffering y compresión
- Nomenclatura estándar según PC-IAC-003
- Etiquetado según PC-IAC-004

## Uso

```hcl
module "kinesis_firehose" {
  source = "git::https://github.com/org/kinesis-firehose-module.git?ref=v1.0.0"

  providers = {
    aws.project = aws.principal
  }

  # Variables de gobernanza
  client      = var.client
  project     = var.project
  environment = var.environment

  # Configuración de streams (transformada en locals del Root)
  firehose_streams = local.firehose_streams_transformed
}
```

## Requisitos

| Nombre | Versión |
|--------|---------|
| terraform | >= 1.0.0 |
| aws | >= 5.0.0 |

## Providers

| Nombre | Versión |
|--------|---------|
| aws.project | >= 5.0.0 |

## Inputs

| Nombre | Descripción | Tipo | Default | Requerido |
|--------|-------------|------|---------|-----------|
| client | Nombre del cliente o unidad de negocio | `string` | n/a | sí |
| project | Nombre del proyecto | `string` | n/a | sí |
| environment | Entorno de despliegue (dev, qa, pdn) | `string` | n/a | sí |
| firehose_streams | Mapa de configuración para los Firehose Delivery Streams | `map(object)` | `{}` | no |

### Estructura de `firehose_streams`

```hcl
firehose_streams = {
  "stream-key" = {
    name                       = string       # Nombre final del stream (obligatorio)
    destination                = string       # "s3" o "extended_s3" (default: "extended_s3")
    s3_bucket_arn              = string       # ARN del bucket S3 destino (obligatorio)
    s3_prefix                  = string       # Prefijo en S3 (opcional)
    s3_error_prefix            = string       # Prefijo para errores (default: "errors/")
    buffering_size             = number       # Tamaño buffer MB 1-128 (default: 5)
    buffering_interval         = number       # Intervalo buffer seg 0-900 (default: 300)
    compression_format         = string       # UNCOMPRESSED, GZIP, ZIP, Snappy, HADOOP_SNAPPY
    kms_key_arn                = string       # ARN de KMS para cifrado (obligatorio)
    role_arn                   = string       # ARN del rol IAM (obligatorio)
    cloudwatch_logging_enabled = bool         # Habilitar logging (default: true)
    log_group_name             = string       # Nombre del log group (opcional)
    log_stream_name            = string       # Nombre del log stream (opcional)
    kinesis_source_stream_arn  = string       # ARN de Kinesis Data Stream fuente (opcional)
    additional_tags            = map(string)  # Tags adicionales (opcional)
  }
}
```

## Outputs

| Nombre | Descripción |
|--------|-------------|
| firehose_stream_arns | Mapa de ARNs de los Firehose Delivery Streams |
| firehose_stream_names | Mapa de nombres de los Firehose Delivery Streams |
| firehose_stream_ids | Mapa de IDs de los Firehose Delivery Streams |
| cloudwatch_log_group_arns | Mapa de ARNs de los CloudWatch Log Groups |
| cloudwatch_log_group_names | Mapa de nombres de los CloudWatch Log Groups |
| all_firehose_arns | Lista de todos los ARNs de Firehose Streams |
| all_firehose_names | Lista de todos los nombres de Firehose Streams |

## Cumplimiento de Reglas PC-IAC

| Regla | Descripción | Implementación |
|-------|-------------|----------------|
| PC-IAC-001 | Estructura de Módulo | Estructura completa con todos los archivos obligatorios |
| PC-IAC-002 | Variables | Variables tipadas con validaciones obligatorias |
| PC-IAC-003 | Nomenclatura | Prefijo de gobernanza `{client}-{project}-{environment}` |
| PC-IAC-004 | Etiquetas | Tags base del módulo + additional_tags por recurso |
| PC-IAC-005 | Providers | Alias consumidor `aws.project` obligatorio |
| PC-IAC-006 | Versiones | Pinning de versiones en versions.tf |
| PC-IAC-007 | Outputs | Outputs granulares (ARNs, IDs, nombres) |
| PC-IAC-010 | For_Each | Uso de `for_each` para colecciones de streams |
| PC-IAC-020 | Seguridad | Cifrado KMS obligatorio, CloudWatch Logs |
| PC-IAC-023 | Responsabilidad Única | Solo recursos intrínsecos a Firehose |

## Decisiones de Diseño

### Cifrado Obligatorio (PC-IAC-020)

El módulo requiere obligatoriamente un `kms_key_arn` para cada stream. Esto asegura:
- Cifrado en reposo de los datos en tránsito hacia S3
- Cifrado del servidor del delivery stream
- Cifrado de los CloudWatch Logs asociados

### Roles IAM Externos (PC-IAC-023)

Siguiendo el principio de responsabilidad única, el módulo **no crea** roles IAM. El `role_arn` debe ser proporcionado desde el dominio de Seguridad. El rol debe tener permisos para:
- `s3:PutObject`, `s3:GetBucketLocation` en el bucket destino
- `kms:Encrypt`, `kms:Decrypt`, `kms:GenerateDataKey` en la llave KMS
- `logs:PutLogEvents` en el CloudWatch Log Group

### CloudWatch Logging

El logging está habilitado por defecto para facilitar el troubleshooting. Los log groups se crean automáticamente con:
- Retención de 30 días
- Cifrado con la misma llave KMS del stream

### Destinos Soportados

Actualmente el módulo soporta:
- **extended_s3**: Destino S3 con características extendidas (recomendado)
- **s3**: Destino S3 legacy (usa extended_s3 internamente)

Para otros destinos (Redshift, OpenSearch, Splunk, HTTP), se recomienda extender el módulo o crear módulos específicos.

## Ejemplo

Ver el directorio `sample/` para un ejemplo completo de uso del módulo.

```bash
cd sample/
terraform init
terraform plan -var-file="terraform.tfvars"
```

## Referencias

- [AWS Kinesis Data Firehose Documentation](https://docs.aws.amazon.com/firehose/latest/dev/what-is-this-service.html)
- [Terraform AWS Provider - Kinesis Firehose](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kinesis_firehose_delivery_stream)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
