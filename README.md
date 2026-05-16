# Proyecto: Plataforma de Datos End-to-End en Azure (Arquitectura Lambda/Medallion)

Este proyecto implementa una plataforma de datos moderna y escalable sobre Microsoft Azure empleando Infraestructura como Código (IaC). La arquitectura soporta la ingesta tanto en tiempo real (Streaming) como por lotes (Batch), almacenando información bajo los principios de la Arquitectura Medallón (Bronze, Silver, Gold).

A continuación se detalla el desglose y propósito técnico de cada una de las fases o entregas del proyecto:

## Entrega 1: Fundamentos, Data Lake e IaC
* **Propósito:** Sentar las bases del proyecto, la seguridad y el almacenamiento centralizado automatizando la creación de todos los recursos en la nube sin intervenir manualmente en el portal.
* **Funcionamiento Técnico:** Utiliza **Terraform** (`/infrastructure`) para aprovisionar la arquitectura base. Crea un **Azure Data Lake Storage Gen2** estructurado en tres contenedores lógicos (`bronze`, `silver`, `gold`). Implementa políticas de ciclo de vida (Lifecycle Management) para enviar datos antiguos a capas de almacenamiento frías (Cool/Archive).

## Entrega 2: Ingesta en Tiempo Real (Streaming)
* **Propósito:** Capturar telemetría IoT sobre la marcha para analítica en tiempo casi real y detección de anomalías.
* **Funcionamiento Técnico:** Un script en Python (`/scripts/telemetry_generator.py`) emula sensores IoT enviando eventos a **Azure Event Hubs**. Desde allí, **Azure Stream Analytics** los consume de forma ininterrumpida, aplicando ventanas de tiempo fijas (Tumbling Windows) mediante código SAQL para agregar promedios por minuto y desviar lecturas anómalas (alertas de temperatura) directamente hacia la capa `Silver` del Data Lake.

## Entrega 3: Orquestación Batch y Analítica (Data Factory + Synapse)
* **Propósito:** Procesar cargas de datos históricas (por lote) aplicando transformaciones y habilitar la capa de consumo analítico para el negocio.
* **Funcionamiento Técnico:** Se orquesta un pipeline programado con **Azure Data Factory** (`/data_factory`) que copia los datos desde orígenes hacia la capa `Bronze`, y utiliza Data Flows en clústeres Spark iterando la información hacia la capa `Silver`, para finalmente guardar la información más limpia y agregada como archivos _Parquet_ en la capa `Gold`. Sobre esto, **Azure Synapse Analytics** (Serverless SQL Pool) se acopla al Data Lake para exponer estos datos refinados mediante Vistas Lógicas SQL (`/synapse`), permitiendo interceder en los datos con sentencias convencionales para Business Intelligence.

## Entrega 4: CI/CD, DevOps y Monitoreo
* **Propósito:** Llevar el proyecto a un estándar de grado de producción asegurando despliegues confiables y observabilidad activa (Monitorización).
* **Funcionamiento Técnico:** Se configura un flujo de despliegue continuo e integración (CI/CD) mediante un pipeline de **GitHub Actions** (`.github/workflows/deploy.yml`) que evalúa (`terraform plan`) y aprueba los despliegues de la infraestructura (`terraform apply`) ante fusiones (push) en la rama `main`. Conjuntamente, un **Log Analytics Workspace** centralizado captura de forma automatizada las métricas de uso y los logs de consultas ejecutadas en Synapse, habilitando el perfil operativo y la depuración del sistema.

---


## 🚀 Flujo de Datos y Arquitectura (Lambda)

El siguiente diagrama ilustra cómo viajan los datos desde su origen hasta el modelo de consumo analítico una vez la plataforma está operando:

```mermaid
graph TD
    subgraph 1. Ingesta
        A[Generador IoT Python] -->|Telemetría E2E| B(Azure Event Hubs)
        C[Fuentes Batch / CSV] -->|Carga de Origen| D[(ADLS Bronze)]
    end

    subgraph 2. Procesamiento Streaming 'Hot Path'
        B -->|Eventos Friccionales| E{Stream Analytics}
        E -->|Anomalías > 45°C| F[(ADLS Silver Alertas)]
        E -->|Ventanas de 1 min| G[(ADLS Silver Telemetry)]
    end

    subgraph 3. Procesamiento Batch 'Cold Path'
        D -.->|Triggers / Copy Activity| H[Azure Data Factory]
        H -.->|DataFlow Transforma| I[(ADLS Silver Limpio)]
        I -.->|DataFlow Agrega| J[(ADLS Gold Parquet)]
    end
    
    subgraph 4. Analítica y Consumo
        F -->|Consulta| K[Synapse Serverless SQL]
        J -->|Consulta| K
        G -->|Consulta| K
        K --> L((Vistas Analíticas y BI))
    end

    classDef ingesta fill:#e1f5fe,stroke:#311b92,stroke-width:2px;
    classDef hot path fill:#ffebee,stroke:#b71c1c,stroke-width:2px;
    classDef cold path fill:#e8f5e9,stroke:#0d47a1,stroke-width:2px;
    classDef storage fill:#fff8e1,stroke:#f57f17,stroke-width:2px;
    classDef analytics fill:#f3e5f5,stroke:#1b5e20,stroke-width:2px;
    
    class A,B,C ingesta;
    class E,F,G hot path;
    class D,I,J,H cold path;
    class K,L analytics;
```

### ¿Cómo interpretar el flujo?
1. **Ingesta:** Los datos entran al ecosistema por dos vías. En tiempo real a través de los Event Hubs (Telemetría IoT) o mediante cargas masivas de datos históricos (Batch Archivos).
2. **Hot Path (Velocidad):** Stream Analytics evalúa los eventos sin detenerse. Detecta de inmediato si hay una anomalía térmica y deposita conclusiones de minuto a minuto listos para ser consumidos en la Capa *Silver*.
3. **Cold Path (Profundidad):** Data Factory toma los datos pesados y estructurados de la capa *Bronze* y los hornea a fuego lento mediante transformaciones (DataFlows) subiéndolos a *Silver* y culminando en el estatus dorado (*Gold*).
4. **Consumo:** Synapse asume su rol de orquestador analítico, leyendo tanto los datos rápidos (Hot Path) como los enriquecidos (Cold Path) para presentarlos listos para cualquier herramienta de Business Intelligence (ej. Power BI).

---
*Si deseas desplegar o interactuar con este proyecto, consulta el documento `docs/deployment_guide.md`.*
