import json
from channels.generic.websocket import AsyncWebsocketConsumer

class TaskConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        await self.channel_layer.group_add("task_updates", self.channel_name)
        await self.accept()

    async def disconnect(self, close_code):
        await self.channel_layer.group_discard("task_updates", self.channel_name)

    async def receive(self, text_data):
        data = json.loads(text_data)
        print(f"Received: {data}")

    async def send_task_update(self, event):
        await self.send(text_data=json.dumps({"status": event["status"], "message": event["message"]}))
