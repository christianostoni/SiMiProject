import asyncio
from websockets.asyncio.client import connect
from websockets.connection import State
import json

RECV_TIMEOUT_SEC = 5.0


class WebSocketClient:

    def __init__(self, command_queue, response_queue, configuration_file):
        self.command_queue = command_queue
        self.response_queue = response_queue
        self.fleet_roster = configuration_file.get("FleetRoster", {})
        self.websockets = {}  # machine_name -> websocket aperto

    async def _get_socket(self, machine_name):
        """Restituisce il socket aperto, riconnettendosi se necessario."""
        ws = self.websockets.get(machine_name)
        if ws is not None and ws.state is State.OPEN:
            print("websocket gia aperto")
            return ws
        machine_data = self.fleet_roster.get(machine_name)
        if not machine_data:
            print(f"[WS] Macchina '{machine_name}' non trovata nel roster")
            return None
        address = machine_data.get('ESPAddress')
        try:
            ws = await connect(address)
            self.websockets[machine_name] = ws
            print(f"[WS] Connesso a {machine_name} ({address})")
            return ws
        except Exception as e:
            print(f"[WS] Connessione a {machine_name} fallita: {e}")
            await self._close_socket(machine_name)
            return None

    async def _close_socket(self, machine_name):
        ws = self.websockets.get(machine_name)
        if ws is not None and ws.state is State.OPEN:
            try:
                await ws.close()
            except Exception:
                pass
        self.websockets[machine_name] = None

    async def run(self):
        # Tentativo di connessione iniziale a tutte le macchine
        for machine_name in self.fleet_roster:
            await self._get_socket(machine_name)

        while True:
            command_data = await self.command_queue.get()
            action = command_data.get('payload', {}).get('action')

            if action == "write":
                await self._handle_write(command_data)

            elif action == "status":
                await self._handle_status(command_data)

    async def _handle_write(self, command_data):
        machine = command_data.get('machine')
        ws = await self._get_socket(machine)
        if ws is None:
            print(f"[WS] {machine} non raggiungibile, comando write ignorato")
            return

        write_request = json.dumps({
            "type": "writeMarker",
            "marker": command_data['payload']['markerNumber'],
            "value": command_data['payload']['value']
        })
        success = False
        try:
            await ws.send(write_request)
            raw = await asyncio.wait_for(ws.recv(), timeout=RECV_TIMEOUT_SEC)
            success = json.loads(raw).get('success', False)
        except asyncio.TimeoutError:
            print(f"[WS] Timeout write su {machine}")
            await self._close_socket(machine)
        except Exception as e:
            print(f"[WS] Errore write su {machine}: {e}")
            await self._close_socket(machine)

        response = {
            "machine": machine,
            "payload": {"action": "write", "state": success},
            "topic_risposta": command_data.get('topic_risposta', '')
        }
        await self.response_queue.put(response)

    async def _handle_status(self, command_data):
        machine = command_data.get('machine')
        topic_risposta = command_data.get('topic_risposta', machine + '/status')
        ws = await self._get_socket(machine)
        if ws is None:
            return

        try:
            await ws.send(json.dumps({"type": "status"}))
            raw = await asyncio.wait_for(ws.recv(), timeout=RECV_TIMEOUT_SEC)
            json_response = json.loads(raw)

            if json_response.get('state') is True:
                response = {
                    "machine": machine,
                    "payload": json_response,
                    "topic_risposta": topic_risposta
                }
                await self.response_queue.put(response)
        except asyncio.TimeoutError:
            print(f"[WS] Timeout status da {machine}")
            await self._close_socket(machine)
        except Exception as e:
            print(f"[WS] Errore status su {machine}: {e}")
            await self._close_socket(machine)
