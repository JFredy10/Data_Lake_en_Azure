# Guía de Verificación y Validación (PROYECTO 09)

Esta guía contiene los pasos exactos para verificar visualmente que todas las fases del proyecto (Streaming, Batch y Analítica) funcionan correctamente en tu entorno de Azure.

---

## 🏗️ Prueba 1: Ingesta Batch (Data Factory -> ADLS Gen2)
Esta prueba demostrará que Data Factory procesa y mueve archivos físicamente a través de la arquitectura Medallion (Bronze -> Silver -> Gold).

1. **Subir el archivo fuente:**
   - Entra al **Portal de Azure** y busca tu Storage Account (`stdataplatformdev...`).
   - Ve a **Containers** y entra a `bronze`.
   - Sube manualmente el archivo local `test.csv` que está en la raíz de tu proyecto.
2. **Ejecutar el Pipeline:**
   - En el portal, busca el recurso **Azure Data Factory** y haz clic en "Launch Studio".
   - En el menú izquierdo, ve al ícono del lápiz (**Author**) > **Pipelines** > `Pipeline_Daily_Batch_Bronze_to_Gold`.
   - En la barra superior, haz clic en **"Add Trigger"** > **"Trigger Now"** y luego en OK.
3. **Verificar Resultados (Visualmente):**
   - Ve al menú izquierdo, ícono de velocímetro (**Monitor**) > **Pipeline runs** y verifica que el estado diga `Succeeded` (puede tomar unos 2-3 minutos).
   - Vuelve a la pestaña de tu Storage Account en Azure. 
   - Revisa la carpeta `bronze`: Verás el archivo en formato Parquet crudo.
   - Revisa la carpeta `silver`: Verás la data transformada y limpia (Data Flows).
   - Revisa la carpeta `gold`: Verás la data agregada matemáticamente lista para Synapse.

---

## ⚡ Prueba 2: Ingesta en Tiempo Real (Streaming)
Esta prueba valida la recepción de eventos por segundo de dispositivos IoT y su enrutamiento a la capa Silver.

1. **Obtener llave de conexión:**
   - En la terminal de VS Code (dentro de la carpeta `infrastructure`), ejecuta:
     ```bash
     terraform output eventhub_connection_string
     ```
   - Copia la llave resultante (inicia con `Endpoint=sb://...`).
2. **Encender Stream Analytics:**
   - Ve al Portal de Azure y busca **Stream Analytics jobs**.
   - Entra a `asa-dataplatform-dev` y haz clic en el botón **"Start"** (iniciar ahora) en la parte superior.
3. **Ejecutar el Simulador (Consola):**
   - En tu terminal, exporta la variable de entorno:
     ```powershell
     $env:EVENT_HUB_CONNECTION_STR="<PEGA_AQUI_LA_LLAVE_SIN_COMILLAS>"
     ```
   - Inicia el envío de datos:
     ```bash
     python scripts/telemetry_generator.py
     ```
   - Verás mensajes de `"Evento enviado..."` en tu terminal. Déjalo correr por unos 2 o 3 minutos y luego detenlo con `Ctrl+C`.
4. **Verificar Resultados (Visualmente):**
   - Ve al portal de Azure > Storage Account > Contenedor `silver`.
   - Notarás que se generaron nuevos archivos JSON de manera automática con los datos agrupados por minuto (gracias al query de tumbling window).

---

## 📊 Prueba 3: Analítica (Synapse Analytics)
Con los datos ya en la capa Gold, validaremos que se pueden leer usando Serverless SQL.

1. **Abrir Synapse Studio:**
   - En el Portal de Azure, busca tu recurso **Azure Synapse Analytics** (`syn-ws-dataplatform-dev`).
   - Haz clic en **"Open Synapse Studio"**.
2. **Cargar los Scripts:**
   - Ve a la pestaña **Develop** (ícono de código en el menú izquierdo).
   - Expande el menú de **SQL scripts** y haz clic en "+" para crear un nuevo script SQL.
   - Abre tu archivo local `synapse/analytics_queries.sql` y copia el contenido completo.
   - Pega el código en la ventana de Synapse.
3. **Ejecutar (Visualmente):**
   - Sombrea (selecciona) la **primera consulta** completa (la de Top 5) y haz clic en el botón de **"Run"**. En la parte inferior verás la tabla de resultados.
   - Repite el proceso con la segunda y tercera consulta. 
   - *Opcional:* En el panel de resultados, puedes darle al botón "Chart" para visualizar los datos en gráficas de barras directamente en Synapse.

---

## BONUS: Conectar Power BI a la Capa Gold
 Dashboard en vivo:

1. **Abre Power BI Desktop** en tu computadora.
2. Haz clic en **Obtener Datos (Get Data)** > **Azure** > **Azure Synapse Analytics (SQL DW)**.
3. En Servidor, pega tu *Serverless SQL Endpoint*: `syn-ws-dataplatform-dev-ondemand.sql.azuresynapse.net`.
4. Selecciona el modo de conectividad de datos **DirectQuery** (para que tu tablero lea en tiempo real directo del Data Lake).
5. Despliega la pestaña **Opciones Avanzadas** y en la caja de texto SQL, pega directamente una de las consultas de tu archivo `analytics_queries.sql` (la que empieza con `SELECT... OPENROWSET...`).
6. Autentícate seleccionando "Cuenta de Microsoft / Organizacional" (usa tu correo de estudiante).
7. ¡Carga los datos y empieza a armar tus gráficas de pastel y barras! Tu Dashboard de Power BI ahora es la interfaz visual de tu Data Lake.
