*** Settings ***
Documentation       Variables for EMSSIM.
...             Author:     Jagoda Kubacka
...             Contact:    jagoda.kubacka@nokia.com

*** Variables ***
&{CERTS_PATH}                  RSA=${CURDIR}/certificates/RSA
...                            ECDSA=${CURDIR}/certificates/ECDSA

&{CERTS_SUBJECT_NAME}          RSA=C=PL, O=Common, CN=IPSEC
...                            ECDSA=CN=CB005999_test

${cert_RSA}                    ${CURDIR}/certificates/RSA/servercert.pem
${key_RSA}                     ${CURDIR}/certificates/RSA/serverprivkey.pem
${cacert_RSA}                  ${CURDIR}/certificates/RSA/cacert.pem
${cert_ECDSA}                  ${CURDIR}/certificates/ECDSA/servercert.pem
${key_ECDSA}                   ${CURDIR}/certificates/ECDSA/serverprivkey.pem
${cacert_ECDSA}                ${CURDIR}/certificates/ECDSA/cacert.pem

${emssim_ssl_path}             /opt/emssim/proxy/ssl/
${emssim_apache_key}           /etc/apache2/ssl.key/
${emssim_apache_crt}           /etc/apache2/ssl.crt/
