-- compute average by minute with TumblingWindow
-- and generate alerts if temperature goes abobe 45 degrees

-- silver-output and evh-input-simulation come from resources stream_analytics_stream...
-- on stream-analytics.tf

-- write on silver layer
SELECT
    System.Timestamp() AS window_end,
    device_id,
    AVG(temperature) AS avg_temperature,
    MAX(temperature) AS max_temperature,
    AVG(humidity) AS avg_humidity,
    COUNT(*) as total_events_in_minute
INTO
    [silver-output]
FROM
    [evh-input-simulation] TIMESTAMP BY timestamp
GROUP BY
    device_id,
    TumblingWindow(minute, 1)

-- write alerts
SELECT
    System.Timestamp() AS event_time,
    device_id,
    temperature,
    status
INTO
    [silver-alert-output]
FROM
    [evh-input-simulation] TIMESTAMP BY timestamp
WHERE
    temperature > 45.0

