#https://www.deepanseeralan.com/tech/generate-expired-ssl-certificates/

#! /usr/bin/env bash

# A script to generate expired SSL certificates
# using faketime and openssl.

# If run in macOS, copy system openssl (/usr/bin/openssl)
# to another directory and update OPENSSL with the new path.

generate_root_ca()
{
    # Generate the private key and self-signed cert for the root CA
    $FAKETIME 'last week' $OPENSSL req -x509 -nodes -sha256 \
        -newkey rsa:2048 -days 365 -out $1.crt -keyout $1.key \
        -subj "/C=US/ST=DE/O=MyCert, Inc./CN=mycert.com" 
}

generate_expired_cert_signed_by_root_ca()
{
    ROOT_CA=$1
    NODE=$2

    # Generate the CSR for the server
    $OPENSSL req -new -nodes -newkey rsa:2048 \
        -subj "/C=US/ST=DE/O=ExampleOrg, Inc./CN=127.0.0.1" \
        -out $NODE.csr -keyout $NODE.key

    # Generate the certificate signed by the root CA
    # The lowest validity is 1 day. we would have to wait
    # for a day for the certificate to expire. Instead, use
    # faketime to generate cert with validity starting
    # from the date specified in faketime
    $FAKETIME '3 days ago' $OPENSSL x509 -req -sha256 -days 1 \
        -in $NODE.csr -CA $ROOT_CA.crt -CAkey $ROOT_CA.key \
        -CAcreateserial -out $NODE.crt
}

show_cert_expiration()
{
    echo "Expiration dates of $1 certificate"
    $OPENSSL x509 -noout -startdate -enddate -in $1.crt
}

check_faketime_is_installed()
{
    FAKETIME=$(which faketime 2> /dev/null)
    if [[ -z $FAKETIME ]]; then
        echo "faketime is not installed. Install faketime using"
        echo "\"apt install libfaketime\" (Ubuntu) or \"brew install libfaketime\" (for macOS)"
        echo "The script will now exit."
        exit 1
    fi
}

check_faketime_is_installed

# NOTE: In case of macOS, /usr/bin/openssl is protected by SIP.
# That prevents faketime from intercepting the system calls and
# return fake date and time.
# Workaround: Copy /usr/bin/openssl to another directory and point
# that in the OPENSSL variable below.

OPENSSL=$(which openssl)
ROOT_CA=$1
NODE=$2

generate_root_ca $ROOT_CA
generate_expired_cert_signed_by_root_ca $ROOT_CA $NODE
show_cert_expiration $ROOT_CA
show_cert_expiration $NODE
