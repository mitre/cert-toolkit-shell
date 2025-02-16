FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    bats \
    curl \
    openssl \
    wget \
    ca-certificates \
    sudo

WORKDIR /app
COPY . .

CMD ["bats", "test"]
