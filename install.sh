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
hf download IndexTeam/IndexTTS-2 --local-dir=checkpoints

cd ..

# installing infinite-talk

cd InfiniteTalk
python -m venv venv
source venv/bin/activate
# first needed deps
pip install --upgrade pip setuptools wheel
pip install torch==2.4.1 torchvision==0.19.1 torchaudio==2.4.1 --index-url https://download.pytorch.org/whl/cu121
pip install -U xformers==0.0.28 --index-url https://download.pytorch.org/whl/cu121

# flash attn installation
pip install misaki[en]
pip install ninja 
pip install psutil 
pip install packaging
pip install wheel
pip install flash_attn==2.7.4.post1

# other deps
pip install -r requirements.txt
pip install librosa

# ffmpeg installation
apt install ffmpeg ffmpeg-devel

# models download
huggingface-cli download Wan-AI/Wan2.1-I2V-14B-480P --local-dir ./weights/Wan2.1-I2V-14B-480P
huggingface-cli download TencentGameMate/chinese-wav2vec2-base --local-dir ./weights/chinese-wav2vec2-base
huggingface-cli download TencentGameMate/chinese-wav2vec2-base model.safetensors --revision refs/pr/1 --local-dir ./weights/chinese-wav2vec2-base
huggingface-cli download MeiGen-AI/InfiniteTalk --local-dir ./weights/InfiniteTalk

cd ..

echo "Installation completed."