#!/bin/bash
WHISPER_BIN="/app/build/bin/whisper-cli"

sh /app/models/download-ggml-model.sh $MODEL /models

shopt -s nullglob
for fn in /input/*; do
    if [ ! -f "$fn" ]; then
        echo "File not found: $fn"
        continue
    fi

    fn_base_full="$(basename "${fn}")"
    fn_base="${fn_base_full%.*}"
    fn_wav_48k="/tmp/${fn_base}-48k.wav"
    fn_wav_16k="/tmp/${fn_base}-16k.wav"
    echo "$fn_base: Starting"

    if [ -f "/output/${fn_base}.txt" ]; then
        echo "$fn_base: Already transcribed"
        continue
    fi

    echo "$fn_base: Converting to wav"
    ffmpeg -hide_banner -loglevel error -y -i "$fn" -vn -c:a pcm_s16le -ar 48000 "${fn_wav_48k}"

    if [ "${NORMALIZE,,}" == "true" ]; then
        echo "$fn_base: Normalizing"
        normalize-audio "${fn_wav_48k}"
    fi

    if [ "${DENOISE,,}" == "true" ]; then
        echo "$fn_base: Denoising"
        deep-filter -o /tmp/ "${fn_wav_48k}"
    fi

    echo "$fn_base: Converting to 16k wav"
    ffmpeg -hide_banner -loglevel error -y -i "${fn_wav_48k}" -vn -c:a pcm_s16le -ar 16000 "${fn_wav_16k}"

    echo "$fn_base: Starting Whisper"
    $WHISPER_BIN -l $LANG -np -m /models/ggml-$MODEL.bin -p 1 -t $THREADS -otxt -osrt -f "$fn_wav_16k" -of "/output/${fn_base}"

    echo "$fn_base: Done. Cleanup."
    rm -f /tmp/*.wav
done

shopt -u nullglob
