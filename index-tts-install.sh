# !/bin/sh

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