# Entrega 4: CI/CD + Monitor (Semanas 7-8)

## Ficha de la Entrega
* **Fase:** CI/CD + Monitor
* **Actividades:** Configuración de integraciones en Azure Pipelines (IaC), monitoreo y métricas en Synapse/Azure, y documentación profunda de la arquitectura.
* **Entregable:** Plataforma completa operativa, automatizada y documentada.

## ¿En qué consiste y para qué sirve?
La última fase madura la solución para llevarla al estándar de producción y la filosofía DevOps. Incluye generar el framework de Integración y Despliegue Continuo (CI/CD) para la infraestructura. Asimismo, envuelve las estrategias de observabilidad (Monitor) para detectar caídas de rendimiento o alertas de error. Paralelamente, se completa la documentación formal y robusta de la arquitectura desplegada y las guías de uso paso a paso. Se consolida el proyecto completo.

## ¿Dónde se encuentra en el proyecto?
Esta fase involucra aspectos transversales de documentación técnica, pero a la vez, se centra en los manuales de plataforma:

```text
docs/
  ├── architecture_report.md    -> Documento que describe la decisión de arquitectura general.
  └── deployment_guide.md       -> Guía de pasos manuales y CI/CD para ejecutar todo el proyecto.

(Nota: En esta fase, de tener pipelines de Azure DevOps o GitHub Actions, típicamente se agregaría un archivo `azure-pipelines.yml` o `.github/workflows/deploy.yml` a la raíz del repositorio).
```