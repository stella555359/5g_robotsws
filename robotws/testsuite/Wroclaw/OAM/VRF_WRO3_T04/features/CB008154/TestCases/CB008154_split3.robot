*** Settings ***
Documentation
...     description:    Test cases for the CB008154 feature.

Resource    ../Resources/CB008154_split3_keywords_part1.robot
Resource    ../Resources/CB008154_split3_keywords.robot

*** Keywords ***
[1]CB008154_Trust_Anchor_Certificate_expiry_alarm-intermediate_CA_certificate
    CB008154_Trust_Anchor_Certificate_expiry_alarm-intermediate_CA_certificate

[1]CB008154_Trust_Anchor_Certificate_expiry_alarm- end_entity_certificate
    CB008154_Trust_Anchor_Certificate_expiry_alarm- end_entity_certificate

[1]CB008154 certificate renewal requests burst alarm WebEM
    Set Cert Update Time Param    ${last_valid}
    Generate Binary File From HEX String    hex_string_file=${TRUST_CHAIN_CERT_PATH_HEX}
    ...                                     binary_file_name=${TRUST_CHAIN_CERT_PATH_P12}
    Install Certificate On BTS    cert_file=${TRUST_CHAIN_CERT_PATH_P12}
    ...                           cert_type=${bts_cert_type_for_installation}
    ...                           cert_format=${bts_cert_type_format}
    ...                           p12password=${P12PASSWORD}
    Check CMP And BTS Trust Chain Certificates Validities
    Check If Fault Is Active
    Initialize Certificates
    Check If Fault Is Not Active
    Set Cert Update Time Param    ${neCertificateUpdateTime_last_valid}
    Check If Fault Is Active
    Set Cert Update Time Param    ${neCertificateUpdateTime_first_valid}
    Check If Fault Is Not Active
    Set Cert Update Time Param    ${first_invalid}
    Check If Fault Is Active
    Set Cert Update Time Param    ${last_valid}
    Check If Fault Is Not Active

[1]CB008154 certificate renewal requests burst alarm NetAct
    Set Cert Update Time Param With Netact    ${last_valid}
    Generate Binary File From HEX String    hex_string_file=${TRUST_CHAIN_CERT_PATH_HEX}
    ...                                     binary_file_name=${TRUST_CHAIN_CERT_PATH_P12}
    Install Certificate On BTS    cert_file=${TRUST_CHAIN_CERT_PATH_P12}
    ...                           cert_type=${bts_cert_type_for_installation}
    ...                           cert_format=${bts_cert_type_format}
    ...                           p12password=${P12PASSWORD}
    Check CMP And BTS Trust Chain Certificates Validities
    Check If Fault Is Active With Netact
    Initialize Certificates From NetAct With Timeout
    Check If Fault Is Not Active With Netact
    Set Cert Update Time Param With Netact    ${neCertificateUpdateTime_last_valid}
    Check If Fault Is Active With Netact
    Set Cert Update Time Param With Netact    ${neCertificateUpdateTime_first_valid}
    Check If Fault Is Not Active With Netact
    Set Cert Update Time Param With Netact    ${first_invalid}
    Check If Fault Is Active With Netact
    Set Cert Update Time Param With Netact    ${last_valid}
    Check If Fault Is Not Active With Netact

