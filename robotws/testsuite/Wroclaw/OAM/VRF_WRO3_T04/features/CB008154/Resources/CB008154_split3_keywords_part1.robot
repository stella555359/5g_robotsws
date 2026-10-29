*** Settings ***
Documentation
...    author:    Marta Gal
...    contact:   marta.gal@nokia.com

Resource    ../../../common_resources/certificates/certificates.robot
Resource    ../../../common_resources/commissioning/parameters.robot
Resource    ../../../common_resources/alarms/alarm.robot
Resource    ../../../common_resources/binary_files/binary_files.robot

*** Variables ***
${cert_pem}                ${CURDIR}/Split3/8154.pem
${cert_pem_fingerprint}    12:A6:17:17:8A:F9:E3:57:1C:DB:69:22:16:33:5D:6A:01:57:51:51
${cert_p12_hex}            ${CURDIR}/Split3/cert_8154_hex_string.txt
${cert_p12}                8154.p12
${P12PASSWORD}             YT_xk39b

*** Keywords ***
CB008154_Trust_Anchor_Certificate_expiry_alarm-intermediate_CA_certificate
    Install Certificate On BTS     cert_file=${cert_pem}
    ...                            cert_type=AdditionalCa
    ...                            cert_format=PEM
    Change Parameter on BTS        dist_name=MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMP-1
    ...                            param_name=caCertificateUpdateTime
    ...                            param_value=3660
    Wait until keyword succeeds    10 min    30 sec    Alarm Should be Active In BTS    fault_id=61618
    [Teardown]    Clear Certificates

CB008154_Trust_Anchor_Certificate_expiry_alarm- end_entity_certificate
    Generate Binary File From HEX String    hex_string_file=${cert_p12_hex}
    ...                                     binary_file_name=8154.p12
    Install Certificate On BTS     cert_file=${cert_p12}
    ...                            cert_type=BtsTrustChain
    ...                            cert_format=P12
    ...                            p12password=${P12PASSWORD}
    Change Parameter on BTS        dist_name=MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMP-1
    ...                            param_name=neCertificateUpdateTime
    ...                            param_value=3660
    Wait until keyword succeeds    10 min    30 sec    Alarm Should be Active In BTS    fault_id=61618
    [Teardown]    Clear Certificates
