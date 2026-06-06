import websocketClient
import mqtt_client
import machine_poller
import asyncio
import json



def load_configuration(path):
        try:
            with open(path, "r") as file:
                configurazione = json.load(file)#trasformo in un dizionario python
                return configurazione
                
        except FileNotFoundError:
            print(f"Errore: Il file {path} non è stato trovato!")
            return None
        except json.JSONDecodeError:
            print(f"Errore: Il file {path} non è un JSON formattato correttamente!")
            return None
        



async def main():
    configuration_file = load_configuration(path="config.json")

    if configuration_file is None:
        print("Configurazione non valida. Uscita.")
        return

    system = configuration_file.get("SystemSettings", {})
    polling_time = system.get("polling_interval_sec", 5)
    fleet_roster = configuration_file.get("FleetRoster", {})

    command_queue = asyncio.Queue()
    response_queue = asyncio.Queue()

    socketClient = websocketClient.WebSocketClient(command_queue=command_queue, response_queue=response_queue, configuration_file=configuration_file)
    mqttClient = mqtt_client.mqttClientClass(command_queue=command_queue, response_queue=response_queue, configuration_file=configuration_file)
    machinePoller = machine_poller.MachinePoller(command_queue=command_queue, fleet_roster=fleet_roster, polling_interval=polling_time)

    print("Avvio dei servizi in corso...")
    await asyncio.gather(
        socketClient.run(),
        mqttClient.run(),
        machinePoller.requestStatus()
    )


asyncio.run(main())
