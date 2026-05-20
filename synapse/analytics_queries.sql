-- =============================================================================
-- CONSULTAS ANALÍTICAS PARA SYNAPSE ANALYTICS SERVERLESS SQL POOL
-- PROYECTO 09 - CAPA GOLD
-- =============================================================================
-- Nota: Estas consultas leen directamente de la capa Gold en el Data Lake.
-- Asegúrate de que la URL apunte al nombre correcto de tu Storage Account.
-- =============================================================================

-- 1. CONSULTA TOP-N: Los 5 dispositivos con la temperatura promedio más alta
SELECT TOP 5
    device_id,
    avg_temperature,
    max_humidity
FROM
    OPENROWSET(
        BULK 'https://stdataplatformdevcx99v2.dfs.core.windows.net/gold/*.parquet',
        FORMAT = 'PARQUET'
    ) AS [gold_data]
ORDER BY
    avg_temperature DESC;


-- 2. CONSULTA DE AGREGACIONES GENERALES: Promedio de todo el ecosistema
SELECT
    ROUND(AVG(avg_temperature), 2) AS general_avg_temp,
    ROUND(AVG(max_humidity), 2) AS general_avg_humidity
FROM
    OPENROWSET(
        BULK 'https://stdataplatformdevcx99v2.dfs.core.windows.net/gold/*.parquet',
        FORMAT = 'PARQUET'
    ) AS [gold_data];


-- 3. CONSULTA DE TENDENCIAS/CATEGORIZACIÓN: Estatus de humedad por dispositivo
SELECT
    device_id,
    max_humidity,
    CASE 
        WHEN max_humidity > 60 THEN 'Humedad Crítica'
        WHEN max_humidity BETWEEN 40 AND 60 THEN 'Operación Normal'
        ELSE 'Humedad Baja'
    END AS alert_status
FROM
    OPENROWSET(
        BULK 'https://stdataplatformdevcx99v2.dfs.core.windows.net/gold/*.parquet',
        FORMAT = 'PARQUET'
    ) AS [gold_data]
ORDER BY
    max_humidity DESC;
