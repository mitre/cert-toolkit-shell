FROM registry.access.redhat.com/ubi9/ubi-minimal

RUN microdnf install -y \
    bats \
    curl \
    openssl \
    wget \
    ca-certificates \
    sudo

WORKDIR /app
COPY . .

CMD ["bats", "test"]
