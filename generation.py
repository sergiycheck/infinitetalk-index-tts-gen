import subprocess
import uuid
import os
import json

def indextts_audio_generation():
  audio_ref = "temp/ref.wav"
  output_audio_dir = "generated_audio"
  generated_audio_name = f"gen_{uuid.uuid4().hex}.wav"
  
  if not os.path.exists(audio_ref):
      raise FileNotFoundError(f"Reference audio not found: {audio_ref}")
  
  if not os.path.exists(output_audio_dir):
      os.makedirs(output_audio_dir, exist_ok=True)

  result = subprocess.run(
      [
          "uv",
          "run",
          "index-tts/run_tts.py",
          "--target_text", "This is my daily makeup routine. First, I start with cleanser.",
          "--audio_ref", audio_ref,
          "--output_dir", output_audio_dir,
          "--audio_name", generated_audio_name,
      ],
      capture_output=True,
      text=True,
      check=True,
  )

  generated_wav = result.stdout.strip()
  print("Generated:", generated_wav)
  
  return generated_wav


def infinitedtalk_video_generation(generated_audio_path: str, prompt: str, image_path: str):
  
  generated_video_name = f"infinitetalk_{uuid.uuid4().hex}.mp4"
  
  input_json_content = {
    "prompt": prompt,
    "cond_video": image_path,
    "cond_audio": {
      "person1": generated_audio_path
    }
  }
  
  result = subprocess.run(
      [
          "python",
          "InfiniteTalk/generate_infinitetalk.py",
          "--ckpt_dir", "weights/Wan2.1-I2V-14B-480P",
          "--wav2vec_dir", "weights/chinese-wav2vec2-base",
          "--infinitetalk_dir", "weights/InfiniteTalk/single/infinitetalk.safetensors",
          "--input_json", json.dumps(input_json_content),
          "--size", "infinitetalk-480",
          "--sample_steps", "40",
          "--mode", "streaming",
          "--motion_frame", "9",
          "--save_file", generated_video_name,
      ],
  )
  
  print("Generated video:", generated_video_name)
  return generated_video_name
  
  
def main():
    generated_audio_path = indextts_audio_generation()
    prompt = "A person is talking about their daily makeup routine."
    image_path = "temp/cond_image.jpg"
    infinitedtalk_video_generation(generated_audio_path, prompt, image_path)

if __name__ == "__main__":
    main()