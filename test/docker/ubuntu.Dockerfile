FROM ubuntu:22.04

# Install base packages
RUN apt-get update && apt-get install -y \
    bats \
    ca-certificates \
    curl \
    file \
    gawk \
    git \
    libxml2-utils \
    ncurses-bin \
    openssl \
    sudo \
    unzip \
    vim-common \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Copy MITRE CA bundle for SSL verification
COPY test/fixtures/certs/mitre-ca-bundle.pem /usr/local/share/ca-certificates/mitre-ca-bundle.crt

# Update CA store with MITRE certificates
RUN update-ca-certificates

# Install bats test helpers in a way that works with the Ubuntu bats package
RUN mkdir -p /usr/lib/bats/bats-support \
    && git clone https://github.com/bats-core/bats-support.git /usr/lib/bats/bats-support \
    && git clone https://github.com/bats-core/bats-assert.git /usr/lib/bats/bats-assert

WORKDIR /app
COPY . .

ENV PATH="/app/src:$PATH"
ENV BATS_LIB="/usr/lib/bats"

CMD ["bats", "test"]
