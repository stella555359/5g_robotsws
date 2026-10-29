*** Settings ***
Documentation               Variables for TLS test case

*** Variables ***
${PCAP_NAME}                8254.pcap
${P12_ECDSA}                ${CURDIR}/certificates/bts256_hex_string.txt
${P12_RSA}                  ${CURDIR}/certificates/BTSRSA_hex_string.txt
${P12_PASSWORD}             YT_xk39b
@{CIPHER_SUITES}            TLS_AES_256_GCM_SHA384  TLS_CHACHA20_POLY1305_SHA256  TLS_AES_128_GCM_SHA256
...                         TLS_AES_128_CCM_8_SHA256  TLS_AES_128_CCM_SHA256  TLS_EMPTY_RENEGOTIATION_INFO_SCSV
@{CIPHER_SUITES1_2}         TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384  TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256
...                         TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384  TLS_DHE_RSA_WITH_AES_256_GCM_SHA384
...                         TLS_DHE_RSA_WITH_AES_256_CBC_SHA256  TLS_RSA_WITH_AES_256_GCM_SHA384
...                         TLS_RSA_WITH_AES_256_CBC_SHA256  TLS_DHE_RSA_WITH_AES_128_GCM_SHA256
...                         TLS_DHE_RSA_WITH_AES_128_CBC_SHA256  TLS_RSA_WITH_AES_128_GCM_SHA256
...                         TLS_RSA_WITH_AES_128_CBC_SHA256  TLS_EMPTY_RENEGOTIATION_INFO_SCSV
@{SUPPORTED_GROUPS}         secp384r1 (0x0018)   secp256r1 (0x0017)   x25519 (0x001d)
@{SUPPORTED_GROUPS1_2}      secp384r1 (24)   secp256r1 (23)   x25519 (29)
&{SUBJECT_ALT_NAME_VALUES}      subjectAltName=test-domain-name.nokiasolutionsandnetworks.com
...                             subjectAltType=DOMAIN
@{SUBJECT_ALT_NAME_LIST}        &{SUBJECT_ALT_NAME_VALUES}
&{CMP_OBJECT}               RSA=CMP-1
...                         ECDSA=CMPECDSA-1
@{CMP_INIT_MESSAGES}            ir   1   certConf  pkiconf
@{PORTS}                    443  8443
${ECDSA_SECOND_SUBJECT_NAME}    CN = CB005999_long_validity
${CA_SERVER_IP}             10.42.54.13
${CA_SERVER_PATH}           pkix
${CA_DEFAULT_PORT}          8080
${CA_REFERENCE_NUMBER}      5330
${CERT_PRESHARED_KEY}       fnAR-zMMi-4pVz-mwrG
${SYNC_PATHS}               /ffs/stb/trs_data/active/.keystorage /ffs/stb/trs_data/active/keystorage
&{CMPSERVER_SETTINGS_FILEPATH}         ECDSA=/rom/trs_data/active/keystorage/pskRefEcdsa.txt  RSA=/rom/trs_data/active/keystorage/pskRef.txt
&{PARAMS}                   subjectAltType=DOMAIN    subjectAltName=qwerty
&{CERT_PATH}                ECDSA=/rom/trs_data/active/keystorage/certs/ec_cert.pem   RSA=/rom/trs_data/active/keystorage/certs/cert.pem
&{CA_SUBJECT_NAME_PARTIALLY}    RSA=IPSEC    ECDSA=CB005999_test
&{SECOND_SUBJECT_NAME}    RSA=C = PL, O = Nokia, CN = NetConfInsta    ECDSA=CN = CB005999_test
@{SUBJECT_ALT_CORRECT}    DOMAIN=domain.com
${TOO_LONG}  .aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa.com
${SUBJECT_ALT_NAME_INCORRECT1}    .192.168.0.1
@{SUBJECT_ALT_NAME_INCORRECT}    domain_com    domain-.com    192.168.0.-1    2001:db8:85a3::8a2e:370g:7334
${ECDSA_SUBJECT_NAME}       CN = CB005999_test
${RSA_SUBJECT_NAME}         CN = CB007672
${cert_pem}                 ${CURDIR}/certificates/8154.pem
${NETACT_CERT}              srnblrna1
&{CERTS_SUBJECT_NAME}          RSA=C=PL, O=Common, CN=IPSEC
...                            ECDSA=CN=CB005999_test