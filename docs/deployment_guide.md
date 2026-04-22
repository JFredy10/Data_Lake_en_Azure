# Guía de Ejecución y Despliegue: Plataforma de Datos Azure

Esta guía detalla los pasos cronológicos que debes realizar para desplegar, ejecutar y validar la arquitectura Lambda y Medallion construida en el proyecto.

---

## Fase 1: Prerrequisitos y Autenticación Azure

### 1.1 Iniciar sesión en Azure CLI
Abre la terminal de PowerShell en la carpeta raíz y verifica que tienes instalada la [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli).
```powershell
az login
```
*Se abrirá el navegador para que ingreses tus credenciales.*

### 1.2 Configurar la Suscripción
Verifica que estás en la suscripción correcta:
```powershell
# Lista tus suscripciones
az account list -o table

# Configura tu suscripción activa por defecto (reemplaza por tu ID)
az account set --subscription "<TU_SUBSCRIPTION_ID>"
```

---


## Fase 2: Despliegue de Infraestructura con Terraform

> **Nota:** Puedes ejecutar este paso desde tu máquina local, usando tu usuario autenticado con `az login`.

### 2.1 Ajustar Terraform para uso local
Abre el archivo `infrastructure/providers.tf` y asegúrate de que el proveedor use autenticación por CLI.

### 2.2 Inicializar y aplicar Terraform
Ubícate en la carpeta `infrastructure`:
```powershell
cd infrastructure
```

Inicializa Terraform:
```powershell
terraform init
```

Valida el plan de despliegue:
```powershell
terraform plan
```

Aplica los cambios (esto creará todos los recursos en Azure):
```powershell
terraform apply -auto-approve
```

### 2.3 Obtén el valor de `eventhub_connection_string`
Al finalizar, ejecuta:
```powershell
terraform output eventhub_connection_string
```
Copia el valor que te muestra, por ejemplo:
```
eventhub_connection_string = "Endpoint=sb://<NOMBRE>.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=XXXXXXXXXXXX;EntityPath=<eventhub>"
```
Este valor lo usarás en la configuración del generador de eventos.

---

## Fase 3: Ejecución de Flujos en Tiempo Real (Streaming E2E)

### 3.1 Iniciar el Stream Analytics Job
1. Ve al [Portal de Azure (portal.azure.com)](https://portal.azure.com/).
2. Busca el *Resource Group* creado (`rg-data-platform-dev`).
3. Busca el servicio **Stream Analytics Job** con nombre `asa-dataplatform-dev`.
4. Ábrelo, evalúa que su entrada (*inputs*) y salidas (*outputs*) existan, dale clic al botón **"Start" (Iniciar)** y selecciona **"Now"**.


### 3.2 Correr el Generador de Telemetría (Python)
1. Instala la librería necesaria para Python:
```powershell
cd ..  # Volver a la raíz del proyecto
pip install azure-eventhub
```

2. Exporta la variable de entorno con la cadena de conexión real que copiaste del paso anterior:
```powershell
$env:EVENT_HUB_CONNECTION_STR="<valor_de_eventhub_connection_string>"
```
Ejemplo:
```powershell
$env:EVENT_HUB_CONNECTION_STR="Endpoint=sb://...;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=...;EntityPath=..."
```

3. Ejecuta el generador de eventos:
```powershell
python scripts/telemetry_generator.py
```
Déjalo corriendo al menos 3 a 5 minutos. Luego revisa en el Data Lake (Storage Account `stdataplatformdevcx99`) el contenedor `silver` para validar que se generen archivos.

---

## Fase 4: Desencadenar el Flujo Batch (ADF)

Azure Data Factory se despliega solo con el contorno (Factory base), ya que el código del pipeline batch quedó formalizado en tu archivo `data_factory/batch_pipeline.json`. Para probarlo en real:
1. Ve al Portal de Azure e ingresa al **Azure Data Factory** (`adf-dataplatform-dev-01`). Selecciona "**Launch Studio**".
2. En caso de requerirlo, enlazas localmente el json mediante el panel izquierdo de "*Author*" importando el archivo en la lista de "*Pipelines*".
3. Dado que simula la ingesta de CSV, asegúrate que manualmente subas cualquier archivo tonto de CSV de prueba a un origen definido si el prompt es real de la escuela. En caso de que no debas simularlo, puedes obviar que fluya.
4. Oprime "**Trigger > Trigger Now**" para forzar el flujo diario al momento.

---

## Fase 5: Analítica de los datos Generados (Synapse)

1. En el Portal de Azure, ve a tu **Synapse Analytics Workspace** (`syn-ws-dataplatform-dev`) y abre el **"Synapse Studio"**.
2. En el panel lateral izquierdo, ve a "*Develop*" o "*Data*". Tienes dos opciones para importar nuestro código:
   - Toma el código SQL plano desde la ruta de tu PC `synapse/analytics_queries.sql` y pégalo en un nuevo **SQL script** interno. Presiona *Run*.
   - O importa directamente el Notebook que construimos en `synapse/analytics_notebook.ipynb` asociándolo un Spark/SQL Kernel.
3. Asegurate de conectarte arriba en la pestaña al pool llamado **"Built-in"** (Serverless SQL Pool).
4. Corre las sentadas mágicas para validar las 3 consultas (Tendencias, top N, Agregaciones). Si procesaste todo hasta la capa Gold, y dejaste correr el script Python varios minutos junto con el Stream Analytics encendido, vas a obtener tablas en pantalla con análisis tangibles.

### 6. Fase Final: Limpieza (Para no cobrar facturas de Microsoft)
Una vez presentas o validas el proyecto integral y el flujo batch, apaga Stream Analytics. Si deseas eliminar todo para no generar un centavo adicional de costo:

```powershell
cd infrastructure
terraform destroy -auto-approve
```

---

## Guía rápida para probar TODO el proyecto (End-to-End)

### 1. Despliega toda la infraestructura
```bash
cd infrastructure
terraform apply -auto-approve
```
- Espera a que termine y copia el valor de `eventhub_connection_string` que aparece al final.

### 2. Inicia el Job de Stream Analytics
- Ve al portal de Azure, busca el recurso **Stream Analytics Job** (`asa-dataplatform-dev`).
- Haz clic en **Start** para iniciarlo.

### 3. Ejecuta el generador de eventos (Python)
- Instala la librería necesaria:
  ```bash
  pip install azure-eventhub
  ```
- Exporta la variable de entorno con la cadena de conexión:
  ```powershell
  $env:EVENT_HUB_CONNECTION_STR="<tu_cadena_de_conexion>"
  ```

- Ejecuta el script:
  ```bash
  python scripts/telemetry_generator.py
  ```
- Deja correr el script al menos 2-3 minutos.

### 4. Ejecuta el pipeline batch de Data Factory
- Ve al portal de Azure > Data Factory (`adf-dataplatform-dev-01`).
- Sube un archivo CSV de prueba al Storage Account (contenedor de origen definido en tu pipeline).
- En Data Factory Studio, ejecuta manualmente el pipeline batch (Trigger Now).

### 5. Analiza los datos en Synapse Analytics
- Ve al portal de Azure > Synapse Analytics Workspace (`syn-ws-dataplatform-dev`).
- Abre Synapse Studio y carga el notebook `synapse/analytics_notebook.ipynb` o el script SQL.
- Ejecuta las consultas sobre la capa Gold y Silver.

### 6. Verifica los resultados
- En el Storage Account, revisa los contenedores `silver` y `gold` para ver los archivos generados.
- En Synapse, valida que las consultas devuelvan datos coherentes.
- Si todo esto funciona, ¡el proyecto está probado End-to-End!

### 7. Limpieza (opcional)
- Cuando termines, destruye los recursos para evitar costos:
```bash
cd infrastructure
terraform destroy -auto-approve
```



---
