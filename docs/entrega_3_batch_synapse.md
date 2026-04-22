# Entrega 3: Batch + Synapse (Semanas 5-6)

## Ficha de la Entrega
* **Fase:** Batch + Synapse
* **Actividades:** Pipeline batch en Azure Data Factory, construcción de la Gold Layer, y creación de vistas SQL en Synapse.
* **Entregable:** Consultas analíticas habilitadas.

## ¿En qué consiste y para qué sirve?
Mientras que la fase anterior abordó el tiempo real, esta fase asegura las cargas históricas y periódicas (lotes o batches). Emplea Azure Data Factory para orquestar la copia, transformación y agregación de datos para construir la capa final (Gold Layer). Finalmente, sobre estos datos altamente refinados y listos para consumo del negocio, se emplea Azure Synapse Analytics para construir vistas, explotar datos y disponibilizar la información al nivel del usuario final o herramientas de BI.

## ¿Dónde se encuentra en el proyecto?
Esta entrega se distribuye entre la orquestación (Data Factory) y la analítica/transformación (Synapse):

```text
data_factory/
  └── batch_pipeline.json       -> Tipología/Definición del pipeline de Data Factory.

synapse/
  ├── analytics_notebook.ipynb  -> Notebooks (PySpark/Scala) para la limpieza y análisis.
  └── analytics_queries.sql     -> Scripts SQL para crear vistas o consultas del negocio.
```
