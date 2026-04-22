"""
Script Python para emular telemetría IoT en tiempo real
y enviarla a un Azure Event Hub.
Genera un evento por segundo con métricas simuladas (temperatura, humedad).

Requerimientos:
pip install azure-eventhub
"""

import os
import json
import time
import random
from azure.eventhub import EventHubProducerClient, EventData

EVENT_HUB_CONNECTION_STR = os.environ.get("EVENT_HUB_CONNECTION_STR", "<INSERT_YOUR_CONNECTION_STRING>")
EVENT_HUB_NAME = os.environ.get("EVENT_HUB_NAME", "eh-iot-telemetry")

def generate_telemetry_event(device_id: int):
    """
    Genera un diccionario simulando la lectura del sensor IoT.
    """
    # Se introduce un factor aleatorio en la temperatura
    temperature = round(random.uniform(20.0, 35.0), 2)
    humidity = round(random.uniform(40.0, 70.0), 2)
    
    # Simula una superación de umbral esporádico (para probar alertas de ASA)
    if random.random() > 0.95:  
        temperature += 15.0

    return {
        "device_id": f"Device_{device_id:03d}",
        "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        "temperature": temperature,
        "humidity": humidity,
        "status": "OK" if temperature < 40.0 else "WARNING"
    }

def main():
    print(f"Iniciando emulador de telemetría IoT hacia el Event Hub: {EVENT_HUB_NAME}...")

    if "<INSERT_" in EVENT_HUB_CONNECTION_STR:
        print("[ERROR] No se ha configurado la cadena de conexión. Por favor configurar variable de entorno EVENT_HUB_CONNECTION_STR")
        return

    # Instanciando el cliente
    producer = EventHubProducerClient.from_connection_string(
        conn_str=EVENT_HUB_CONNECTION_STR,
        eventhub_name=EVENT_HUB_NAME
    )

    try:
        with producer:
            while True:
                # Se prepara un batch de eventos y se simulan datos de 5 dispositivos distintos
                event_data_batch = producer.create_batch()
                
                device_id = random.randint(1, 5)
                telemetry = generate_telemetry_event(device_id)
                
                event_data = EventData(json.dumps(telemetry))
                event_data_batch.add(event_data)
                
                producer.send_batch(event_data_batch)
                print(f"Evento enviado: {telemetry}")
                
                time.sleep(1)  # Enviar evento cada 1 segundo según el requerimiento

    except KeyboardInterrupt:
        print("Emulador detenido manualmente por el usuario.")
    except Exception as e:
        print(f"Error en la ejecución: {e}")

if __name__ == '__main__':
    main()
