### index tts api

Command to start api index tts

```bash
uv run uvicorn api:app --host 0.0.0.0 --port 8011
```

Command to start api infinitetalk

```bash
uvicorn api:app --host 0.0.0.0 --port 8012
```

### Test index tts api

```json

{
  "text_prompt": "Hi, this is my daily makeup routine. First I start with a cleanser to wash my face...",
  "audio_ref_s3_key": "s3://index-tts-infinite-talk-gen/ref.mp3"
}
```

### infinite talk api

Command to start api

```bash
uv run uvicorn api:app --host 0.0.0.0 --port 8012
```
