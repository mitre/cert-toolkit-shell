FROM ubuntu:22.04

# Install required packages
RUN apt-get update && apt-get install -y \
    bats \
    curl \
    openssl \
    wget \
    ca-certificates \
    sudo \
    git \
    gawk \
    unzip \
    libxml2-utils \
    vim-common \
    file \
    && rm -rf /var/lib/apt/lists/*

# Install bats test helpers in a way that works with the Ubuntu bats package
RUN mkdir -p /usr/lib/bats/bats-support \
    && git clone https://github.com/bats-core/bats-support.git /usr/lib/bats/bats-support \
    && git clone https://github.com/bats-core/bats-assert.git /usr/lib/bats/bats-assert

WORKDIR /app
COPY . .

ENV PATH="/app/src:$PATH"
ENV BATS_LIB="/usr/lib/bats"

CMD ["bats", "test"]
