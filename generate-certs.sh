#!/bin/bash

DIR=${DIR:-"$(pwd)/tls"}
mkdir -p "$DIR"
cd "$DIR"

CA_KEY=${CA_KEY:-"ca.key"}
CA_CERT=${CA_CERT:-"ca.crt"}
CERT_KEY=${CERT_KEY:-"server.key"}
CERT_CSR=${CERT_CSR:-"server.csr"}
CERT_CERT=${CERT_CERT:-"server.crt"}
DAYS_VALID=${DAYS_VALID:-365}

[ -z "$DOMAIN_NAME" ] && { echo "Error: DOMAIN_NAME not set."; exit 1; }

COUNTRY_NAME=${COUNTRY_NAME:-"BR"}
STATE_NAME=${STATE_NAME:-"State"}
LOCALITY_NAME=${LOCALITY_NAME:-"City"}
ORG_NAME=${ORG_NAME:-"MyOrg"}
CN=${CN:-"MyAD-CA"}

# Generate CA key and certificate without interaction
openssl genrsa -out "$CA_KEY" 2048
openssl req -x509 -new -nodes -key "$CA_KEY" -sha256 \
    -days "$DAYS_VALID" -out "$CA_CERT" \
    -subj "/C=$COUNTRY_NAME/ST=$STATE_NAME/L=$LOCALITY_NAME/O=$ORG_NAME/CN=$CN"

# Generate server key
openssl genrsa -out "$CERT_KEY" 2048

# Generate server CSR without interaction
openssl req -new -key "$CERT_KEY" -out "$CERT_CSR" \
    -subj "/C=$COUNTRY_NAME/ST=$STATE_NAME/L=$LOCALITY_NAME/O=$ORG_NAME/CN=$DOMAIN_NAME" \
    -addext "subjectAltName=DNS:$DOMAIN_NAME,DNS:*.$DOMAIN_NAME"

# Sign the certificate with the CA
openssl x509 -req -in "$CERT_CSR" -CA "$CA_CERT" -CAkey "$CA_KEY" -CAcreateserial \
    -out "$CERT_CERT" -days "$DAYS_VALID" -sha256 \
    -extfile <(printf "subjectAltName=DNS:$DOMAIN_NAME,DNS:*.$DOMAIN_NAME")

echo "Certificates generated in: $DIR"
