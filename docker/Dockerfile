FROM ubuntu:24.04

RUN apt-get update && apt-get install -y \
    sqlite3 \
    git \
    curl \
    bash \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

CMD ["bash"]
