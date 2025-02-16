#!/usr/bin/env bash

# Create directory structure
mkdir -p test/fixtures/certs/{valid,invalid,formats,bundles}

# Create a valid test certificate
openssl req -x509 -newkey rsa:2048 -keyout test/fixtures/certs/valid/test.key \
    -out test/fixtures/certs/valid/test.pem -days 1 -nodes \
    -subj "/CN=Test Certificate"

# Create a DER format certificate
openssl x509 -in test/fixtures/certs/valid/test.pem \
    -out test/fixtures/certs/formats/test.der -outform DER

# Create an invalid certificate
echo "Invalid Certificate Content" >test/fixtures/certs/invalid/bad.pem

# Create a PKCS7 bundle
openssl crl2pkcs7 -nocrl -certfile test/fixtures/certs/valid/test.pem \
    -out test/fixtures/certs/formats/bundle.p7b

# Create a mock DoD bundle
zip -j test/fixtures/certs/bundles/dod.zip test/fixtures/certs/valid/test.pem

# Set permissions
chmod 644 test/fixtures/certs/*/*.{pem,der,p7b,zip}
