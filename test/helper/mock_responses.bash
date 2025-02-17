#!/usr/bin/env bash

# OpenSSL certificate responses
OPENSSL_VERSION_OUTPUT="OpenSSL 3.1.1 30 May 2023 (Library: OpenSSL 3.1.1 30 May 2023)"
OPENSSL_VERIFY_SUCCESS="verify OK"
OPENSSL_VERIFY_FAILURE="unable to load certificate
140735233253184:error:0909006C:PEM routines:get_name:no start line:../crypto/pem/pem_lib.c:745:Expecting: TRUSTED CERTIFICATE"
OPENSSL_EXPIRED="verify error:num=10:certificate has expired
error 10 at 0 depth lookup: certificate has expired"

# Package manager responses
APT_INSTALLED="Package: openssl
Status: install ok installed
Priority: optional
Section: utils"

YUM_INSTALLED="Installed Packages
openssl.x86_64    1:3.1.1-1.fc38    @System"

DNF_INSTALLED="Installed Packages
openssl.x86_64    1:3.1.1-1.fc38    @System"

# HTTP responses
CURL_SUCCESS="HTTP/2 200
content-type: application/x-x509-ca-cert
content-length: 2145
date: Sat, 16 Dec 2023 12:00:00 GMT"

CURL_FAILURE="curl: (60) SSL certificate problem: unable to get local issuer certificate
More details here: https://curl.haxx.se/docs/sslcerts.html"

# Real certificate responses
X509_PEM_SUCCESS="subject=CN = Test Certificate
issuer=CN = Test CA
validity:
    notBefore=Dec 16 00:00:00 2023 GMT
    notAfter=Dec 16 00:00:00 2024 GMT"

X509_DER_SUCCESS="subject=CN = Test DER Certificate
issuer=CN = Test CA
validity:
    notBefore=Dec 16 00:00:00 2023 GMT
    notAfter=Dec 16 00:00:00 2024 GMT"

PKCS7_SUCCESS="-----BEGIN CERTIFICATE-----
MIIDXzCCAkegAwIBAgIUEGUwGSC6tZWv4V9xhCqrc00qnrswDQYJKoZIhvcNAQEL
... (truncated for brevity) ...
-----END CERTIFICATE-----"
