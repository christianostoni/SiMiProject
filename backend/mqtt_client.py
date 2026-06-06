import asyncio
import aiomqtt
import json
import os
import ssl
from dotenv import load_dotenv


class mqttClientClass:

    def __init__(self, command_queue, response_queue, configuration_file):
        load_dotenv()
        self.MQTT_USERNAME = os.getenv("MQTT_BROKER_USER")
        self.MQTT_PASSWORD = os.getenv("MQTT_BROKER_PASS")
        self.command_queue = command_queue
        self.response_queue = response_queue
        self.configuration_file = configuration_file

        mqtt_config = configuration_file.get("SystemSettings", {}).get("MQTTData", {})
        self.broker_address = mqtt_config.get("address", "localhost")
        print(f"broker address: {self.broker_address}")
        self.broker_port = mqtt_config.get("port", 1883)
        self.tls_enabled = mqtt_config.get("SSL/TLSEncryption", False)

    def _build_tls_context(self):
        cert_path = os.path.join(os.path.dirname(__file__), "emqxsl-ca.crt")
        return ssl.create_default_context(cafile=cert_path)

    async def receiveRequest(self, client):
        fleet_roster = self.configuration_file.get("FleetRoster", {})
        for machine_name, machine_data in fleet_roster.items():
            topic = machine_name + machine_data.get('command', '/command')
            await client.subscribe(topic=topic)
            print(f"[MQTT] Subscribed: {topic}")

        async for message in client.messages:
            message_decoded = message.payload.decode()
            try:
                json_data = json.loads(message_decoded)
                await self.command_queue.put(json_data)
            except json.JSONDecodeError:
                print(f"[MQTT] Payload non valido ignorato: '{message_decoded}'")

    async def publishMessage(self, client):
        while True:
            data = await self.response_queue.get()
            machine = data.get('machine')
            topic = data.get('topic_risposta')
            action = data.get('payload', {}).get('action')
            print(action)
            if action == "write":
                state = data['payload']['state']
                payload = json.dumps({'machine': machine, 'payload': {'action': action, 'state': state}})
                await client.publish(topic, payload=payload)
        
            elif action == "status":
                payload = json.dumps(data['payload'])

                await client.publish(topic, payload=payload)
                print(f"[MQTT] Stato di {machine} pubblicato su {topic}")

    async def run(self):
        tls_params = {"tls_context": self._build_tls_context()} if self.tls_enabled else {}
        async with aiomqtt.Client(
            hostname=self.broker_address,
            port=self.broker_port,
            username=self.MQTT_USERNAME,
            password=self.MQTT_PASSWORD,
            **tls_params
        ) as client:
            print(f"[MQTT] Connesso al broker {self.broker_address}:{self.broker_port}")
            await asyncio.gather(
                self.receiveRequest(client),
                self.publishMessage(client)
            )
