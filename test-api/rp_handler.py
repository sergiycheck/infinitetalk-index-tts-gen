import runpod
import time
from handler import tts_worker
from utils import now_local_str

def handler(event):
#   This function processes incoming requests to your Serverless endpoint.
#
#    Args:
#        event (dict): Contains the input data and request metadata
#       
#    Returns:
#       Any: The result to be returned to the client
    
    print(f"Received event: {event}")
    print(f"Start time: {now_local_str()}")
  
    # Extract input data
    print(f"Worker Start")
    input = event['input']
    
    audio_ref_s3_key = input.get('audio_ref_s3_key')
    text_prompt = input.get('text_prompt')
    
    result = tts_worker(
        audio_ref_s3_key=audio_ref_s3_key,
        text_prompt=text_prompt
    )
    
    print(f"End time: {now_local_str()}")
    
    return result
    

if __name__ == '__main__':
    runpod.serverless.start({'handler': handler })