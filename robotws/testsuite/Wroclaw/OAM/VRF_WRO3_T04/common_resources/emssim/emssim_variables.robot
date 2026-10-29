*** Settings ***
Documentation   Variables for EMSSIM.
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

&{TLS1_3_PARAMS}               actEnableTLSv13=${TRUE}
...                            tls12Enabled=${FALSE}
...                            tls11Enabled=${FALSE}

&{TLS1_2_PARAMS}               actEnableTLSv13=${FALSE}
...                            tls12Enabled=${TRUE}
...                            tls11Enabled=${FALSE}

&{TLS1_3_PARAMS_WITHOUT_TLS_1_1}               actEnableTLSv13=${TRUE}
...                                            tls12Enabled=${FALSE}

&{TLS1_2_PARAMS_WITHOUT_TLS_1_1}               actEnableTLSv13=${FALSE}
...                                            tls12Enabled=${TRUE}

&{TLS_VERSIONS}                1_3=${TLS1_3_PARAMS}
...                            1_2=${TLS1_2_PARAMS}
...                            1_3_WITHOUT_1_1=${TLS1_3_PARAMS_WITHOUT_TLS_1_1}
...                            1_2_WITHOUT_1_1=${TLS1_2_PARAMS_WITHOUT_TLS_1_1}

@{BRANCHES_WITH_TLS_1_1}       SBTS23R3    SBTS23R2   SBTS23R1    SBTS22R4    SBTS22R3    SBTS22R2    SBTS22R1

&{CMP_OBJECT}                   RSA=CMP-1
...                             ECDSA=CMPECDSA-1
&{CA_SUBJECT_NAMES}             RSA=${RSA_CA_SUBJECT_NAME}
...                             ECDSA=${ECDSA_CA_SUBJECT_NAME}
&{EE_SUBJECT_NAMES}             RSA=${RSA_EE_SUBJECT_NAME_2}
...                             ECDSA=${ECDSA_EE_SUBJECT_NAME_2}
${RSA_CA_SUBJECT_NAME}          CN=CB010265
${ECDSA_CA_SUBJECT_NAME}        CN=CB010265_1
${RSA_EE_SUBJECT_NAME_2}        CN=MRBTS-${BTS_ID}
${ECDSA_EE_SUBJECT_NAME_2}      CN=MRBTS-${BTS_ID}
${CA_SERVER_IP}             10.42.54.13
${CA_SERVER_PATH}           pkix
${CA_DEFAULT_PORT}          8080
&{STRUCTURAL_ATTRIBUTES}        RSA=CMP-1-1-1
...                             ECDSA=CMPECDSA-1-1-1
