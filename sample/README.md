# Ejemplo de Uso del Módulo Kinesis Firehose

Este directorio contiene un ejemplo funcional de cómo consumir el módulo de Kinesis Firehose siguiendo el patrón de transformación PC-IAC-026.

## Flujo de Datos

```
terraform.tfvars → variables.tf → data.tf → locals.tf → main.tf → ../
     (config)        (tipos)     (consulta)  (transform)  (invoca módulo padre)
```

## Requisitos Previos

Antes de ejecutar este ejemplo, asegúrese de tener:

1. **VPC existente** con nomenclatura estándar: `{client}-{project}-{environment}-vpc`
2. **Bucket S3** para destino de Firehose
3. **Llave KMS** para cifrado con alias: `alias/{client}-{project}-{environment}-kms-firehose`
4. **Rol IAM** para Firehose con los permisos necesarios

## Ejecución

```bash
# Inicializar Terraform
terraform init

# Revisar el plan
terraform plan -var-file="terraform.tfvars"

# Aplicar (solo en ambientes de prueba)
terraform apply -var-file="terraform.tfvars"

# Destruir recursos
terraform destroy -var-file="terraform.tfvars"
```

## Estructura de Archivos

| Archivo | Propósito |
|---------|-----------|
| `terraform.tfvars` | Configuración declarativa sin IDs hardcodeados |
| `variables.tf` | Definición de tipos de variables |
| `data.tf` | Data sources para obtener IDs dinámicos |
| `locals.tf` | Transformaciones e inyección de IDs |
| `main.tf` | Invocación del módulo padre |
| `outputs.tf` | Outputs del ejemplo |
| `providers.tf` | Configuración del provider AWS |

## Notas

- Este ejemplo usa estado local (no configurado backend S3)
- Los IDs de recursos se obtienen dinámicamente via Data Sources
- La nomenclatura sigue el patrón `{client}-{project}-{environment}-{type}-{key}`
