-- =========================================================
-- Vistas sobre Data Lake con Serverless SQL Pool en Synapse
-- =========================================================

-- 1. Crear Vistas sobre la capa Gold apuntando a Parquet
-- Nota: La ruta exacta puede variar según las carpetas dinámicas configuradas

CREATE OR ALTER VIEW vw_gold_telemetry AS
SELECT
    *
FROM
    OPENROWSET(
        BULK 'https://stdataplatformdev01.dfs.core.windows.net/gold/telemetry/**/*.parquet',
        FORMAT = 'PARQUET'
    ) AS [result];
GO

CREATE OR ALTER VIEW vw_silver_alerts AS
SELECT
    *
FROM
    OPENROWSET(
        BULK 'https://stdataplatformdev01.dfs.core.windows.net/silver/alerts/**/*.json',
        FORMAT = 'CSV', -- A pesar de ser JSON, OPENROWSET los lee como CSV delimitado de campo único donde hay que aplicar PARSE_JSON 
        FIELDQUOTE = '0x0b',
        FIELDTERMINATOR ='0x0b',
        ROWTERMINATOR = '0x0b'
    )
    WITH (
        jsonContent varchar(MAX)
    ) AS [result]
CROSS APPLY OPENJSON(jsonContent)
WITH (
    event_time DATETIME2,
    device_id VARCHAR(50),
    temperature FLOAT,
    status VARCHAR(20)
);
GO

-- =========================================================
-- Consultas Analíticas (3 Ejemplos requeridos)
-- =========================================================

-- Consulta #1: Tendencia Temporal (Promedio histórico de temperatura por dispositivo por hora)
SELECT 
    device_id,
    CAST(window_end AS DATE) as date_value,
    DATEPART(HOUR, window_end) as hour_value,
    AVG(avg_temperature) as mean_hourly_temp,
    MAX(max_temperature) as max_hourly_temp
FROM 
    vw_gold_telemetry
GROUP BY 
    device_id,
    CAST(window_end AS DATE),
    DATEPART(HOUR, window_end)
ORDER BY 
    date_value DESC, 
    hour_value DESC, 
    device_id;
GO

-- Consulta #2: Top-N Dispositivos (Top 5 dispositivos con más alertas emitidas en la última semana)
SELECT TOP 5
    device_id,
    COUNT(*) as total_alerts,
    MAX(temperature) as peak_temperature_registered
FROM 
    vw_silver_alerts
WHERE 
    status = 'WARNING' 
    AND event_time >= DATEADD(day, -7, GETDATE())
GROUP BY 
    device_id
ORDER BY 
    total_alerts DESC;
GO

-- Consulta #3: Agregación General y Distribución (Estadísticas generales de todo el parque IoT)
SELECT
    device_id,
    MIN(avg_temperature) as historical_min_temp,
    MAX(max_temperature) as historical_max_temp,
    AVG(avg_humidity) as avg_overall_humidity,
    SUM(total_events_in_minute) as total_readings_captured
FROM
    vw_gold_telemetry
GROUP BY
    device_id;
GO
