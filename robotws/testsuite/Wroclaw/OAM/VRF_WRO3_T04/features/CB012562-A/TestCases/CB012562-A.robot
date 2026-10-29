*** Settings ***
Documentation   The KW for CB012562 feature

Resource        ../../../common_resources/admin/admin.robot
Resource        ../../../common_resources/ip_traffic/ip_traffic.robot
Resource        ../Resources/keywords.robot
Resource        ../../../common_resources/emssim/emssim_setup.robot
Resource        ../../../common_resources/emssim/emssim.robot

Library         taf.sbts.oam.coam.admin  WITH NAME    coam_admin

*** Keywords ***
CB012562-A_08_Subject_Name_(SN)_and_Subject_Alternative_Names_(SANs)_autocompletion_on_Target_SW_After_Reset
    ${RSA_EE_SUBJECT_NAME}          Set Variable   CN=.MRBTS-${BTS_ID}
    ${RSA_EE_SUBJECT_NAME_2}        Set Variable   CN=MRBTS-${BTS_ID}
    ${ECDSA_EE_SUBJECT_NAME}        Set Variable   CN=.MRBTS-${BTS_ID}
    ${ECDSA_EE_SUBJECT_NAME_2}      Set Variable   CN=MRBTS-${BTS_ID}
    Clear Certificates
    ${connection}    Connect to ADMIN
    ${bts_info} =    coam_admin.Get Bts Info    connection=${connection}
    ${SERIAL_NR}=    Set Variable    ${bts_info['systemModules'][0]['serialNumber']}
    ${SERIAL_NUMBER}          Set Variable       CN = ${SERIAL_NR}.MRBTS-${BTS_ID}
    Set CMP Server Settings
    Configure CMP with EE Subject Name       ca_subject_name=${RSA_CA_SUBJECT_NAME}
    ...                                      ee_subject_name=${RSA_EE_SUBJECT_NAME}
    Configure CMP with EE Subject Name       ca_subject_name=${ECDSA_CA_SUBJECT_NAME}
    ...                                      ee_subject_name=${ECDSA_EE_SUBJECT_NAME}
    ...                                      server_type=ECDSA
    Change Parameter on BTS          dist_name=MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMP-1
    ...                              param_name=eeSubjectAltNames
    ...                              param_value=${SUBJECT_ALT_NAME_LIST_RSA}
    Change Parameter on BTS          dist_name=MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMPECDSA-1
    ...                              param_name=eeSubjectAltNames
    ...                              param_value=${SUBJECT_ALT_NAME_LIST_RSA}
    Create eeSubjectAltNames Structure
    Sleep                                   300
    ...                                     reason=Wait until certificates expired
    Check Serial Number For EE Certs
    Check Serial Number For EE Certs        ECDSA
    Delete Parameter From BTS               MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMP-1
    ...                                     eeSubjectAltNames
    Delete Parameter From BTS               MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMPECDSA-1
    ...                                     eeSubjectAltNames
    Configure CMP with EE Subject Name       ca_subject_name=${RSA_CA_SUBJECT_NAME_2}
    ...                                      ee_subject_name=${RSA_EE_SUBJECT_NAME_2}
    Configure CMP with EE Subject Name       ca_subject_name=${ECDSA_CA_SUBJECT_NAME_2}
    ...                                      ee_subject_name=${ECDSA_EE_SUBJECT_NAME_2}
    ...                                      server_type=ECDSA
    Change Parameter on BTS          dist_name=MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMP-1
    ...                              param_name=eeSubjectAltNames
    ...                              param_value=${ECDSA_PARAMS_LIST_3}
    Change Parameter on BTS          dist_name=MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMPECDSA-1
    ...                              param_name=eeSubjectAltNames
    ...                              param_value=${ECDSA_PARAMS_LIST_3}
    Create eeSubjectAltNames Structure      ${ECDSA_PARAMS_4}
    ${cert_list}=  Create Issuers List
    Should Contain           ${cert_list}           CN = CB010265_First
    Should contain           ${cert_list}           CN = CB010265_First_ECDSA
    Configure CMP with EE Subject Name       ca_subject_name=${RSA_CA_SUBJECT_NAME_2}
    ...                                      ee_subject_name=${RSA_EE_SUBJECT_NAME}
    Configure CMP with EE Subject Name       ca_subject_name=${ECDSA_CA_SUBJECT_NAME_2}
    ...                                      ee_subject_name=${ECDSA_EE_SUBJECT_NAME}
    ...                                      server_type=ECDSA
    Change Parameter on BTS          dist_name=MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMP-1
    ...                              param_name=eeSubjectAltNames
    ...                              param_value=${SUBJECT_ALT_NAME_LIST_RSA}
    Change Parameter on BTS          dist_name=MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMPECDSA-1
    ...                              param_name=eeSubjectAltNames
    ...                              param_value=${SUBJECT_ALT_NAME_LIST_RSA}
    Create eeSubjectAltNames Structure
    ${cert_list}=  Create IssuedTo List
    Should Not Contain           ${cert_list}           ${SERIAL_NUMBER}
    Initialize Certificates                 key_pool_type=RSA
    Initialize Certificates                 key_pool_type=ECDSA
    Sleep                                   30
    ...                                     reason=Wait until certificates initialization completed
    ${cert_list}=  Create IssuedTo List
    Should Contain               ${cert_list}           ${SERIAL_NUMBER}
    Reset Site And Reconnect
    Wait Until Keyword Succeeds  20x  30s  Wait until BTS reach Configured or OnAir state
    ${cert_list}=  Create IssuedTo List
    Should Contain               ${cert_list}           ${SERIAL_NUMBER}
    [Teardown]                   Run Keywords           Clear Certificates
    ...                          AND                    Delete CMP Objects

CB012562-A_06_Subject_Alternative_Names_(SANs)_depends_on_NumberOfSAN_parameter_expired_certificate_WebEM_and_NMS
    ${RSA_EE_SUBJECT_NAME}          Set Variable   CN=.MRBTS-${BTS_ID}
    ${RSA_EE_SUBJECT_NAME_2}        Set Variable   CN=MRBTS-${BTS_ID}
    ${ECDSA_EE_SUBJECT_NAME}        Set Variable   CN=.MRBTS-${BTS_ID}
    ${ECDSA_EE_SUBJECT_NAME_2}      Set Variable   CN=MRBTS-${BTS_ID}
    Clear Certificates
    Configure CMP with EE Subject Name       ca_subject_name=${RSA_CA_SUBJECT_NAME}
    ...                                      ee_subject_name=${RSA_EE_SUBJECT_NAME_2}
    Change parameter on BTS                  MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMP-1
    ...                                      btsNumberOfSAN
    ...                                      ${default_SAN}
    Configure CMP with EE Subject Name       ca_subject_name=${ECDSA_CA_SUBJECT_NAME}
    ...                                      ee_subject_name=${ECDSA_EE_SUBJECT_NAME_2}
    ...                                      server_type=ECDSA
    Change parameter on BTS                  MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMPECDSA-1
    ...                                      btsNumberOfSAN
    ...                                      ${default_SAN}
    Change Parameter on BTS          dist_name=MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMP-1
    ...                              param_name=eeSubjectAltNames
    ...                              param_value=@{ECDSA_PARAMS_LIST_3}
    Change Parameter on BTS          dist_name=MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMPECDSA-1
    ...                              param_name=eeSubjectAltNames
    ...                              param_value=@{ECDSA_PARAMS_LIST_3}
    Create eeSubjectAltNames Structure      ${ECDSA_PARAMS_4}
    Sleep                                   600
    ...                                     reason=Wait until certificates expired
    ${cert_list}=                           Create Issuers List
    Should Contain                          ${cert_list}               CN = CB010265
    Should Contain                          ${cert_list}               CN = CB010265_1
    Configure CMP with EE Subject Name       ca_subject_name=${RSA_CA_SUBJECT_NAME}
    ...                                      ee_subject_name=${RSA_EE_SUBJECT_NAME}
    Configure CMP with EE Subject Name       ca_subject_name=${ECDSA_CA_SUBJECT_NAME}
    ...                                      ee_subject_name=${ECDSA_EE_SUBJECT_NAME}
    ...                                      server_type=ECDSA
    Change Parameter on BTS          dist_name=MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMP-1
    ...                              param_name=eeSubjectAltNames
    ...                              param_value=${SUBJECT_ALT_NAME_LIST_RSA}
    Change Parameter on BTS          dist_name=MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMPECDSA-1
    ...                              param_name=eeSubjectAltNames
    ...                              param_value=${SUBJECT_ALT_NAME_LIST_RSA}
    Create eeSubjectAltNames Structure
    Sleep                                   600
    ...                                     reason=Wait until certificates expired
    Check Serial Number For EE Certs
    Check Serial Number For EE Certs        ECDSA
    Clear Certificates
    Delete CMP Objects
    Change Parameter on BTS          dist_name=MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMP-1
    ...                              param_name=eeSubjectAltNames
    ...                              param_value=${ECDSA_PARAMS_LIST_3}
    Change Parameter on BTS          dist_name=MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMPECDSA-1
    ...                              param_name=eeSubjectAltNames
    ...                              param_value=${ECDSA_PARAMS_LIST_4}
    Configure CMP with EE Subject Name       ca_subject_name=${RSA_CA_SUBJECT_NAME}
    ...                                      ee_subject_name=${RSA_EE_SUBJECT_NAME_2}
    Change parameter on BTS                  MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMP-1
    ...                                      btsNumberOfSAN
    ...                                      1
    Configure CMP with EE Subject Name       ca_subject_name=${ECDSA_CA_SUBJECT_NAME}
    ...                                      ee_subject_name=${ECDSA_EE_SUBJECT_NAME_2}
    ...                                      server_type=ECDSA
    Change parameter on BTS                  MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMPECDSA-1
    ...                                      btsNumberOfSAN
    ...                                      8
    Sleep                                    600
    ...                                      reason=Wait until certificates expired
    ${connection}=       Connect with SSH    ${LMP_IP}  ${LOGIN}  ${PASSWORD}  conn
    ${out}=  Execute   ls -la /rom/trs_data/active/keystorage/certs  conn
    ${output_ecdsa}=  Execute
    ...    openssl x509 -in /rom/trs_data/active/keystorage/certs/ec_cert.pem -text | grep "X509v3 Subject Alternative Name:" -A1   conn
    ${output_rsa}=  Execute
    ...    openssl x509 -in /rom/trs_data/active/keystorage/certs/cert.pem -text | grep "X509v3 Subject Alternative Name:" -A1   conn
    ${connection}    Connect to ADMIN
    ${bts_info} =    coam_admin.Get Bts Info    connection=${connection}
    ${SERIAL_NR}=    Set Variable    ${bts_info['systemModules'][0]['serialNumber']}
    ${SUBJECT_ALT_NAME_RSA}     Set Variable     ${SERIAL_NR}.id1.qwerty
    ${SUBJECT_ALT_NAME_ECDSA}   Set Variable     ${SERIAL_NR}.id8.mobile-network.com
    ${SUBJECT_ALT_NAME_ECDSA1}  Set Variable     ${SERIAL_NR}.id8..mobile-network.com
    Should Contain               ${output_rsa}           ${SUBJECT_ALT_NAME_RSA}
    Should Contain               ${output_ecdsa}           ${SUBJECT_ALT_NAME_ECDSA}
    Configure CMP with EE Subject Name       ca_subject_name=${RSA_CA_SUBJECT_NAME}
    ...                                      ee_subject_name=${RSA_EE_SUBJECT_NAME}
    Change Parameter on BTS          dist_name=MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMP-1
    ...                              param_name=eeSubjectAltNames
    ...                              param_value=${SUBJECT_ALT_NAME_LIST_RSA}
    Configure CMP with EE Subject Name       ca_subject_name=${ECDSA_CA_SUBJECT_NAME}
    ...                                      ee_subject_name=${ECDSA_EE_SUBJECT_NAME}
    ...                                      server_type=ECDSA
    Change Parameter on BTS          dist_name=MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMPECDSA-1
    ...                              param_name=eeSubjectAltNames
    ...                              param_value=${SUBJECT_ALT_NAME_LIST_ECDSA}
    Sleep                                    600
    ...                                      reason=Wait until certificates expired
    ${connection}=       Connect with SSH    ${LMP_IP}  ${LOGIN}  ${PASSWORD}  conn
    ${out}=  Execute   ls -la /rom/trs_data/active/keystorage/certs  conn
    ${output_ecdsa}=  Execute
    ...    openssl x509 -in /rom/trs_data/active/keystorage/certs/ec_cert.pem -text | grep "X509v3 Subject Alternative Name:" -A1   conn
    ${output_rsa}=  Execute
    ...    openssl x509 -in /rom/trs_data/active/keystorage/certs/cert.pem -text | grep "X509v3 Subject Alternative Name:" -A1   conn
    ${CHECKED_SERIAL}            Set Variable              ${SERIAL_NR}.id1..qwerty
    Should Contain               ${output_rsa}             ${CHECKED_SERIAL}
    Should Contain               ${output_ecdsa}           ${SUBJECT_ALT_NAME_ECDSA1}
    ${cert_list}=  Create IssuedTo List
    ${SERIAL_NUMBER}          Set Variable       CN = ${SERIAL_NR}.MRBTS-${BTS_ID}
    Should Contain           ${cert_list}           ${SERIAL_NUMBER}
    Clear Certificates
    Change parameter on BTS                  MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMP-1
    ...                                      btsNumberOfSAN
    ...                                      ${default_SAN}
    Change parameter on BTS                  MRBTS-${BTS_ID}/MNL-1/CERTH-1/CMPECDSA-1
    ...                                      btsNumberOfSAN
    ...                                      ${default_SAN}
    Delete CMP Objects
EMSSIM
    Clear Certificates
    Set CMP Server Settings
    Setup environment for EMSSIM                 cert_type=RSA
    ${emssim_connection}                         Connect and Activate EMSSIM    cert_type=RSA
    EMSSIM Configure CMP with EE Subject Name And EE Subject AltName    ${ECDSA_PARAMS_3}
    ...                                                                 ECDSA
    Edit Parameter with EMSSIM                   ${emssim_connection}
    ...                                          CMPECDSA-1-1-1
    ...                                          btsNumberOfSAN
    ...                                          ${default_SAN}
    ${cert_list}=                           Create Issuers List
    Should Contain                          ${cert_list}               CN = CB010265_1
    Edit Parameter with EMSSIM          ${emssim_connection}
    ...                                 CMPECDSA-1-1-1
    ...                                 eeSubjectName
    ...                                 ${ECDSA_EE_SUBJECT_NAME}
    EMSSIM Change EE SubjectAltName                ${ECDSA_PARAMS_1}
    ...                                            ECDSA
    Sleep                                   300
    ...                                     reason=Wait until certificates expired
    Check Serial Number For EE Certs        ECDSA
    EMSSIM Change EE SubjectAltName                ${ECDSA_PARAMS_4}
    ...                                            ECDSA
    Edit Parameter with EMSSIM          ${emssim_connection}
    ...                                 CMPECDSA-1-1-1
    ...                                 eeSubjectName
    ...                                 ${ECDSA_EE_SUBJECT_NAME_2}
    Edit Parameter with EMSSIM                   ${emssim_connection}
    ...                                          CMPECDSA-1-1-1
    ...                                          btsNumberOfSAN
    ...                                          8
    Sleep                                   300
    ...                                     reason=Wait until certificates expired
    ${connection}=       Connect with SSH    ${LMP_IP}  ${LOGIN}  ${PASSWORD}  conn
    ${out}=  Execute   ls -la /rom/trs_data/active/keystorage/certs  conn
    ${output_ecdsa}=  Execute
    ...    openssl x509 -in /rom/trs_data/active/keystorage/certs/ec_cert.pem -text | grep "X509v3 Subject Alternative Name:" -A1   conn
    ${alt_name}=    Get From Dictionary    ${SUBJECT_ALT_NAME_VALUES_ECDSA}    subjectAltName
    Should Contain               ${output_ecdsa}           ${alt_name}
    Edit Parameter with EMSSIM          ${emssim_connection}
    ...                                 CMPECDSA-1-1-1
    ...                                 eeSubjectName
    ...                                 ${ECDSA_EE_SUBJECT_NAME}
    EMSSIM Change EE SubjectAltName            ${ECDSA_PARAMS_4}
    ...                                        ECDSA
    [Teardown]                          Run Keywords           Clear Certificates
    ...                                 AND                    emssim.Disconnect From EMSSIM
    ...                                 connection=${emssim_connection}
