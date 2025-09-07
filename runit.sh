# runit.sh

#GPU
# sudo docker build --build-arg RUNTIME=nvidia -t chatterbox:gpu .
mkdir -p hf_cache outputs   # on the host

cd Chatterbox-TTS-Server
sudo docker run --rm -it --gpus all \
  -p 8004:8004 \
  -v "$PWD/hf_cache:/opt/app/hf_cache" \
  -v "$PWD/outputs:/opt/app/outputs" \
  chatterbox:gpu

# List voices
curl -s http://localhost:8004/get_predefined_voices | jq

curl -s http://localhost:8004/get_reference_files | jq


#####################################
# Upload voice sample
curl -sS -D /tmp/h -o /tmp/body.json \
  -H "Accept: application/json" \
  -X POST http://localhost:8004/upload_reference \
  -F "files=@/home/troy/Downloads/BigCasey.mp3"

printf "\n---- UPLOAD HEADERS ----\n"; cat /tmp/h
echo; echo "---- UPLOAD BODY ----"; cat /tmp/body.json; echo


curl -s http://localhost:8004/get_reference_files | jq

########################################

curl -sS -D /tmp/h -o clone_ref.mp3 \
  -H "Content-Type: application/json" \
  -H "Accept: audio/wav" \
  -X POST http://localhost:8004/tts \
  -d '{
  "text": "This is my cloned voice.",
  "voice_mode": "clone",
  "reference_audio_filename": "BigCasey.mp3",
  "output_format": "mp3",
  "split_text": true,
  "chunk_size": 120,
  "temperature": 0.8,
  "exaggeration": 1.3,
  "cfg_weight": 0.5,
  "seed": 1,
  "speed_factor": 1.15
  }'
printf "\n---- TTS HEADERS ----\n"; cat /tmp/h

curl -X 'POST' 'http://localhost:8004/tts' \
  -H 'accept: application/json' \
  -H 'Content-Type: application/json' \
  -d '{
  "text": "This is my cloned voice.",
  "voice_mode": "clone",
  "reference_audio_filename": "BigCasey.mp3",
  "output_format": "mp3",
  "split_text": true,
  "chunk_size": 120,
  "temperature": 0.8,
  "exaggeration": 1.3,
  "cfg_weight": 0.5,
  "seed": 1,
  "speed_factor": 1,
  "language": "string"
}'

printf "\n---- TTS HEADERS ----\n"; cat /tmp/h
file clone_ref.wav

curl -sS -D /tmp/h -o clone_ref.wav \
  -H "Content-Type: application/json" \
  -H "Accept: audio/wav" \
  -X POST http://localhost:8004/tts \
  -d '{
    "text": "Hello, testing my cloned voice.",
    "voice_mode": "reference",
    "reference_audio_filenames": ["BigCasey.mp3"],
    "output_format": "wav",
    "split_text": false,
    "seed": 1
  }'

echo "---- TTS HEADERS ----"; cat /tmp/h
file clone_ref.wav

printf "\n---- HEADERS ----\n"; cat /tmp/h
file clone_ref.wav

