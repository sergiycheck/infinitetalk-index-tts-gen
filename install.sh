# !/bin/sh

# all installation takes about 30 minutes
# 274gb disk space needed

# installing index-tts

# check if uv is installed

if ! command -v uv &> /dev/null
then
    echo "uv could not be found, installing..."
    pip install -U uv
else
    echo "uv is already installed"
fi

cd index-tts
uv sync --all-extras
uv pip install librosa
uv tool install "huggingface-hub[cli,hf_xet]"
uv run hf download IndexTeam/IndexTTS-2 --local-dir=checkpoints

# api deps
uv add uvicorn "fastapi[standard]" boto3 pydantic dotenv websockets

cd ..

# installing infinite-talk

cd InfiniteTalk
# we have to install globally due to flash attn issues in venv
python -m venv venv
source venv/bin/activate
# first needed deps
pip install --upgrade pip setuptools wheel

# already installed on runpod container
# pip install torch==2.4.1 torchvision==0.19.1 torchaudio==2.4.1 --index-url https://download.pytorch.org/whl/cu121
# pip install -U xformers==0.0.28 --index-url https://download.pytorch.org/whl/cu121

# compatible torch and xformers for flash attn
pip install torch torchvision --index-url https://download.pytorch.org/whl/cu124
pip install xformers --index-url https://download.pytorch.org/whl/cu124

# Error on flash attn install
# torch not found, maybe due to venv
# flash attn installation
# after installing them globally, successful installation in venv
pip install misaki[en]
pip install ninja 
pip install psutil 
pip install packaging
pip install wheel
pip install flash_attn==2.7.4.post1

# other deps
pip install -r requirements.txt
pip install librosa

# api deps
pip install uvicorn "fastapi[standard]" boto3 pydantic dotenv websockets "huggingface_hub"

# ffmpeg installation
apt update
apt install ffmpeg -y

# models download
hf download Wan-AI/Wan2.1-I2V-14B-480P --local-dir ./weights/Wan2.1-I2V-14B-480P
hf download TencentGameMate/chinese-wav2vec2-base --local-dir ./weights/chinese-wav2vec2-base
hf download TencentGameMate/chinese-wav2vec2-base model.safetensors --revision refs/pr/1 --local-dir ./weights/chinese-wav2vec2-base
hf download MeiGen-AI/InfiniteTalk --local-dir ./weights/InfiniteTalk

cd ..

echo "Installation completed."