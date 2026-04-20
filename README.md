# Plataforma de Datos con Data Lake y Procesamiento en Tiempo Real en Azure

> [!NOTE]
> Trabajo en progreso

Plataforma de datos sobre Azure: un Data Lake en Azure Data Lake Storage Gen2 estructurado en capas (Bronze/Silver/Gold), ingesta de eventos en tiempo real con Azure Event Hubs, procesamiento de streams con Azure Stream Analytics, y consultas analíticas sobre Azure Synapse Analytics.
El pipeline CI/CD en Azure Pipelines automatiza el despliegue de infraestructura y transformaciones de datos.


## Requerimientos
- Azure account
- Azure cli
- Terraform
- Python 3+

## Ejecutando

`az login`

`terraform init`
`terraform apply`

Los Stream analytics se crean y se detienen de manera explicita con la extensión de stream-analytics de la CLI de Azure o en el portal de Azure: https://github.com/Azure/azure-cli-extensions/blob/main/src/stream-analytics/README.md

`az stream-analytics job start --resource-group [GROUP] --name [NAME] --output-start-mode JobStartTime`

detener stream-analytics:
`az stream-analytics job stop --resource-group [GROUP] --name [NAME]`

para el script generator:
`pip install -r requirements.txt`

el script se puede ejecutar de forma local para probar, por ejemplo:
`python scripts/generator.py --mode stdout --interval 0.01`
`python scripts/generator.py --mode stdout --count 1000 --interval 1`

Para generar eventos y enviarlos a Azure, se debe configurar las variables de entorno EVENT_HUB_CONNECTION_STRING y EVENTHUB_NAME en el sistema, EVENT_HUB_CONNECTION_STRING se puede obtener ejecutando: `terraform output eventhub_connection_string`

`python scripts/generator.py --mode eventhub --interval 1`

Se puede monitorear lo el proceso usando el portal de Azure.

