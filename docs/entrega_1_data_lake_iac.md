# Entrega 1: Data Lake + IaC (Semanas 1-2)

## Ficha de la Entrega
* **Fase:** Data Lake + IaC
* **Actividades:** ADLS Gen2 con capas (Bronze, Silver, Gold), políticas de ciclo de vida (lifecycle policy) y Terraform para aprovisionar todos los recursos.
* **Entregable:** Data Lake estructurado y código de Infraestructura como Código (IaC).

## ¿En qué consiste y para qué sirve?
Esta es la primera fase del proyecto. Consiste en definir y desplegar la infraestructura base que soportará el ciclo de vida de los datos, utilizando Infraestructura como Código (Terraform) para que el despliegue sea automatizado, replicable y seguro. El elemento central es un Azure Data Lake Storage (ADLS) Gen2 estructurado en capas lógicas de procesamiento (como bronze, silver, gold), junto con políticas que gestionan el costo mediante el movimiento o eliminación de datos antiguos.

## ¿Dónde se encuentra en el proyecto?
Todos los archivos de esta entrega se ubican principalmente en la carpeta de infraestructura:

```text
infrastructure/                 -> Carpeta principal de la Entrega 1
  ├── storage.tf                -> Definición del Data Lake (ADLS Gen2) y sus políticas.
  ├── network.tf                -> Configuraciones de red (VNet, subnets, etc.).
  ├── providers.tf              -> Configuración de proveedores (AzureRM).
  ├── variables.tf              -> Variables globales de Terraform.
  ├── data_factory.tf           -> Aprovisionamiento de Azure Data Factory.
  ├── event_hubs.tf             -> Aprovisionamiento de Azure Event Hubs.
  ├── stream_analytics.tf       -> Aprovisionamiento de Azure Stream Analytics.
  └── synapse.tf                -> Aprovisionamiento de Azure Synapse Analytics.
```

## Comandos de Despliegue

Para desplegar la infraestructura en Azure

### 1. Autenticación en Azure
```bash
# Iniciar sesión en tu cuenta de Azure
az login

# Listar tus suscripciones disponibles
az account list --output table

# Seleccionar la suscripción 
az account set --subscription "<Nombre o ID de la suscripción>"
```

### 2. Aprovisionamiento con Terraform
```bash
# carpeta de infraestructura donde están los archivos .tf
cd infrastructure

# Inicializar Terraform
terraform init

# Crear (Planificación)
terraform plan

# Aplicar los cambios y crear los recursos en Azure automáticamente
terraform apply -auto-approve
```

### 3. Destrucción de recursos

```bash
# Eliminar todos los recursos creados por Terraform
terraform destroy -auto-approve
```
