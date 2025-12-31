import multiprocessing as mp
import os
import time
from boto3_utils import download_s3_file, upload_s3_file
from utils import now_local_str

def tts_worker(job_id: str, request: dict, queue: mp.Queue, base_dir: str, job_semaphore: mp.Semaphore):

    try:
        bucket_name = os.getenv("S3_BUCKET_NAME")
    
        if not bucket_name:
            raise RuntimeError("S3_BUCKET_NAME environment variable is not set")
        
        output_dir = os.path.join(base_dir, "output")
        os.makedirs(output_dir, exist_ok=True)
    
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
        print(f"Error in tts_worker: {e}")
        queue.put({
            "status": "error",
            "error": str(e)
        })

    finally:
        try:
            # not removing files for debugging purposes
            # os.remove(audio_ref_path)
            # os.remove(output_path)
            job_semaphore.release()
            pass
        except Exception:
            pass
