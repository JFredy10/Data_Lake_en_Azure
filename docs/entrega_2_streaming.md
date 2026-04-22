# Entrega 2: Streaming (Semanas 3-4)

## Ficha de la Entrega
* **Fase:** Streaming
* **Actividades:** Configuración de Event Hubs, desarrollo de generador de eventos, Stream Analytics job, y enrutamiento de datos a la capa Silver.
* **Entregable:** Pipeline de streaming End-to-End (E2E).

## ¿En qué consiste y para qué sirve?
Esta entrega establece la ingesta de datos en tiempo real (streaming). Utilizando Azure Event Hubs como puerta de enlace de eventos, un script que simula o genera telemetría (datos continuos), y Azure Stream Analytics que procesa esos mensajes sobre la marcha. El flujo transforma los datos que entran y los envía listos a la capa correspondiente del Data Lake (típicamente Silver). Sirve para tener analítica en tiempo casi real y detectar problemas, picos de uso o comportamientos normales del sistema al instante.

## ¿Dónde se encuentra en el proyecto?
Los archivos correspondientes a esta entrega abarcan la infraestructura de mensajería, el generador de datos y las consultas de procesamiento:

```text
scripts/
  └── telemetry_generator.py    -> Script en Python para generar eventos a Event Hubs.

stream_analytics/
  └── query.saql                -> Consulta SAQL del procesamiento de los streams.

infrastructure/
  ├── event_hubs.tf             -> Definición de IaC para Event Hubs (creado en fase 1).
  └── stream_analytics.tf       -> Definición de IaC para Stream Analytics.
```

## ¿Cómo probar y verificar la entrega 2?

### 1. Despliega la infraestructura
- Abre una terminal en la raíz del proyecto y ejecuta:
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

### 4. Verifica los resultados en Azure
- Ve al portal de Azure > Storage Account > Contenedor `silver`.
- Deberías ver archivos JSON generados por Stream Analytics (telemetría y alertas).
- Puedes descargar y abrir los archivos para ver los datos procesados.

### 5. Validación final
- Si ves archivos nuevos en el contenedor `silver` y el script Python muestra "Evento enviado: ...", ¡la entrega 2 está funcionando!
- Si tienes errores, revisa los logs del Job de Stream Analytics y la consola de Python para detalles.

¿Necesitas una guía visual o ayuda para interpretar los resultados?
