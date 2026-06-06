import asyncio


class MachinePoller:
    def __init__(self, command_queue, fleet_roster, polling_interval):
        self.command_queue = command_queue
        self.fleet_roster = fleet_roster
        self.polling_interval = polling_interval

    async def requestStatus(self):
        while True:
            for machine_name, machine_data in self.fleet_roster.items():
                topic = machine_name + machine_data.get('status', '/status')
                data = {
                    "machine": machine_name,
                    "payload": {"action": "status"},
                    "topic_risposta": topic
                }
                await self.command_queue.put(data)
            await asyncio.sleep(self.polling_interval)
