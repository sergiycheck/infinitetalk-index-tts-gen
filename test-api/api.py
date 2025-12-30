from dotenv import load_dotenv
load_dotenv()

import os
import uuid
import json
import multiprocessing as mp
from multiprocessing import Semaphore
import asyncio

from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from pydantic import BaseModel
from typing import Dict

from boto3_utils import download_s3_file, upload_s3_file
from datetime import datetime
import time


MAX_CONCURRENT_JOBS = 1
job_semaphore = Semaphore(MAX_CONCURRENT_JOBS)

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

app = FastAPI()

active_connections: Dict[str, WebSocket] = {}

class AudioRequest(BaseModel):
    text_prompt: str
    audio_ref_s3_key: str
    

def now_local_str() -> str:
    return datetime.now().strftime("%Y-%m-%d %H:%M:%S")


def tts_worker(job_id: str, request: dict, queue: mp.Queue):
    bucket_name = os.getenv("S3_BUCKET_NAME")
    output_dir = os.path.join(BASE_DIR, "output")
    os.makedirs(output_dir, exist_ok=True)

    try:
    
        print("Downloading reference audio from S3...", now_local_str())
        time.sleep(5)
        queue.put({"status": "downloading_reference"})

        audio_ref_path = download_s3_file(
            bucket=bucket_name,
            key=request["audio_ref_s3_key"],
            local_path=output_dir
        )
        
        queue.put({"status": "loading_model"})
        print("Loading IndexTTS2 model...", now_local_str())

        # simulate initialization of  the TTS model
        time.sleep(5)

        queue.put({"status": "generating_audio"})
        print("Generating audio...", now_local_str())

        output_path = os.path.join(output_dir, f"0dc37762-b89e-4284-9093-3f594c77e87f.wav")

        # simulate audio generation time
        time.sleep(5)  

        generated_file = os.path.basename(output_path)

        queue.put({"status": "uploading_to_s3"})
        print("Uploading generated audio to S3...", now_local_str())

        upload_s3_file(
            local_path=os.path.join(output_dir, generated_file),
            bucket=bucket_name,
        )

        s3_url = f"https://{bucket_name}.s3.amazonaws.com/{generated_file}"

        queue.put({
            "status": "completed",
            "s3_url": s3_url
        })
        
        print("Job completed.", now_local_str())

    except Exception as e:
        queue.put({
            "status": "error",
            "error": str(e)
        })

    finally:
        try:
            os.remove(audio_ref_path)
            os.remove(output_path)
            job_semaphore.release()
        except Exception:
            pass


async def ws_event_forwarder(job_id: str, queue: mp.Queue):
    websocket = active_connections.get(job_id)
    if not websocket:
        return

    while True:
        msg = await asyncio.to_thread(queue.get)
        await websocket.send_text(json.dumps(msg))
        if msg["status"] in ("completed", "error"):
            break

@app.post("/generate-audio")
async def generate_audio(request: AudioRequest):

    acquired = job_semaphore.acquire(block=False)
    if not acquired:
        raise HTTPException(429, "Server busy")
    
    # job_id = str(uuid.uuid4())
    job_id = "560e6ae6-d45a-48dc-af05-707b3d60e804"
    queue = mp.Queue()

    process = mp.Process(
        target=tts_worker,
        args=(job_id, request.dict(), queue)
    )
    process.start()
    asyncio.create_task(ws_event_forwarder(job_id, queue))

    return {
        "job_id": job_id,
        "ws_url": f"/ws/{job_id}"
    }



@app.websocket("/ws/{job_id}")
async def websocket_endpoint(websocket: WebSocket, job_id: str):
    await websocket.accept()
    active_connections[job_id] = websocket

    try:
        while True:
            await websocket.receive_text()
    except WebSocketDisconnect:
        active_connections.pop(job_id, None)
