FROM ghcr.io/ggml-org/whisper.cpp:main

ADD --chmod=0755 https://github.com/Rikorose/DeepFilterNet/releases/download/v0.5.6/deep-filter-0.5.6-x86_64-unknown-linux-musl /usr/local/bin/deep-filter
RUN apt-get update; apt-get -y dist-upgrade; apt-get -y --no-install-recommends install ffmpeg python3 normalize-audio; apt-get autoremove; apt-get clean
RUN mkdir -p /input /output/ /models/
ADD --chmod=0755 files/entrypoint.sh /entrypoint.sh

ENV MODEL=base
ENV DENOISE=TRUE
ENV NORMALIZE=TRUE
ENV LANG=de
ENV THREADS=2

ENTRYPOINT []
CMD [ "/bin/bash", "/entrypoint.sh" ]
