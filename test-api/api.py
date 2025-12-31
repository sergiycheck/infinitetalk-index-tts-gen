from dotenv import load_dotenv
load_dotenv()

import os
import json
import multiprocessing as mp
import asyncio

from fastapi import FastAPI, WebSocket, WebSocketDisconnect, HTTPException
from pydantic import BaseModel
from typing import Dict
from handler import tts_worker

MAX_CONCURRENT_JOBS = 1
job_semaphore = mp.Semaphore(MAX_CONCURRENT_JOBS)
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
app = FastAPI()
active_connections: Dict[str, WebSocket] = {}
queues: Dict[str, mp.Queue] = {}

class AudioRequest(BaseModel):
    text_prompt: str
    audio_ref_s3_key: str
    

async def ws_event_forwarder(job_id: str, queues: mp.Queue):
    try:
        websocket = active_connections.get(job_id)
        if not websocket:
            return

        while True:
            msg = await asyncio.to_thread(queues[job_id].get)
            await websocket.send_text(json.dumps(msg))
            if msg["status"] in ("completed", "error"):
                break
    except Exception as e:
        print(f"Error in ws_event_forwarder: {e}")
        raise e

@app.post("/generate-audio")
async def generate_audio(request: AudioRequest):
    try:
        acquired = job_semaphore.acquire(block=False)
        if not acquired:
            raise HTTPException(429, "Server busy")
        # job_id = str(uuid.uuid4())
        job_id = "560e6ae6-d45a-48dc-af05-707b3d60e804"
        queue = mp.Queue()
        queues[job_id] = queue

        process = mp.Process(
            target=tts_worker,
            args=(job_id, request.dict(), queue, BASE_DIR, job_semaphore)
        )
        process.start()
        asyncio.create_task(ws_event_forwarder(job_id, queues))

        return {
            "job_id": job_id,
            "ws_url": f"/ws/{job_id}"
        }
        
    except Exception as e:
        print(f"Error in generate_audio: {e}")
        if isinstance(e, HTTPException):
            raise e
        raise HTTPException(500, "Internal server error")

@app.websocket("/ws/{job_id}")
async def websocket_endpoint(websocket: WebSocket, job_id: str):
    try:
        await websocket.accept()
        active_connections[job_id] = websocket

        try:
            while True:
                await websocket.receive_text()
        except WebSocketDisconnect:
            active_connections.pop(job_id, None)
    except Exception as e:
        print(f"Error in websocket_endpoint: {e}")
        raise e