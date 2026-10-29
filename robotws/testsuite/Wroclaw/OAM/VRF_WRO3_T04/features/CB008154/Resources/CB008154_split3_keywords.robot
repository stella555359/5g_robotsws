*** Settings ***
Documentation
...  author:  Jakub Sikora
...  contact: jakub.sikora@nokia.com

Resource    ../../../common_resources/certificates/certificates.robot
Resource    ../../../common_resources/commissioning/parameters.robot
Resource    ../../../common_resources/alarms/alarm.robot
Resource    ../../../common_resources/binary_files/binary_files.robot
Library    ../Resources/CB008154_split3_keywords.py

*** Variables ***
${TRUST_CHAIN_CERT_PATH_P12}         ${CURDIR}/Nokia_8154_default.p12
${TRUST_CHAIN_CERT_PATH_HEX}         ${CURDIR}/Nokia_8154_default_hex_string.txt
${P12PASSWORD}         YT_xk39b
${cert_fingerprint}    EB:94:67:B6:58:64:07:41:05:F9:9C:9F:45:56:AC:AF:59:2B:94:C3
${neCertificateUpdateTime_field_name}     neCertificateUpdateTime
${neCertificateUpdateTime_first_valid}    1
${neCertificateUpdateTime_last_valid}     4999
${neCertificateUpdateTime_default}        30
${fault_id}                               61011
${fault_timeout}                          10 min
${fault_ack_freq}                         30 sec
${cmp_path}                               MNL-1/CERTH-1/CMP-1
${ca_subject_name_correct}                CN\=8259_auto
${bts_cert_type_for_installation}         BtsTrustChain
${bts_cert_type_format}                   P12
${bts_cert_type_for_listing}              BTS
${add_cert_type_for_listing}              TA
${SCF_NAME}                               scf.xml
${CERT_PRESHARED_KEY}                     fnAR-zMMi-4pVz-mwrG
${CA_REFERENCE_NUMBER}                    5330
${SERVER_TYPE}                            RSA=/rom/trs_data/active/keystorage/pskRef.txt
${CONFIGURE_CMP_TIMEOUT}                  400
${PARAM_CERT_UPDATE_TIME}                 90

*** Keywords ***
Set Cert Update Time Param
    [Arguments]    ${param_value}
    Change Parameter on BTS    dist_name=MRBTS-${BTS_ID}/${cmp_path}
    ...                        param_name=${neCertificateUpdateTime_field_name}
    ...                        param_value=${param_value}

Check If Fault Is Active
    Wait until keyword succeeds    ${fault_timeout}    ${fault_ack_freq}    Alarm Should be Active In BTS    fault_id=${fault_id}

Check If Fault Is Not Active
    Wait until keyword succeeds    ${fault_timeout}    ${fault_ack_freq}    Alarm Should Not Be Active in BTS    fault_id=${fault_id}

Set CMP Configuration
    Configure CMP    ca_subject_name=${ca_subject_name_correct}
    Set CMP Server Settings

Set Cert Update Time Boundary Values
    Initialize Certificates
    ${cert_list}=    Get Certificates List    cert_type=${bts_cert_type_for_listing}
    ${sw_release}=   Get Software Release Name
    ${x}=    get_cert_validity    ${cert_list}    ${sw_release}
    Set Global Variable    ${first_invalid}    ${x}
    Set Global Variable    ${last_valid}    ${${first_invalid}-${1}}

Clear All Certs At BTS
    Clear Certificates

Check CMP And BTS Trust Chain Certificates Validities
    ${cert_list_ta}=    Get Certificates List    cert_type=${add_cert_type_for_listing}
    ${sw_release}=   Get Software Release Name
    ${add_cert_validity}=    get_cert_validity    cert_list=${cert_list_ta}   sw_release_name=${sw_release}    fingerprint=${cert_fingerprint}
    check_add_cert_validity    ${add_cert_validity}
    ${tc_cert}=    check_certs_validity    ${add_cert_validity}    ${first_invalid}
    Run Keyword If 	'${tc_cert}' == 'False'    Fail    Validity of End Entity cert from p12 file (${add_cert_validity} days is longer or equal
    ...                                                to validity of End Entity cert from CMP init (${first_invalid} days.
    ...                                                Please use cert from p12 file with validity less than ${first_invalid} days.

Check If Fault Is Active With Netact
    ${faults_output}=    Wait until keyword succeeds    5 min    30 sec    Get active faults using netact    ${NETACT_CONNECTION}
    ${is_fault_active}=    check_faults_in_output    output=${faults_output}    fauld_id=${fault_id}
    Run Keyword If 	'${is_fault_active}' == 'False'    Fail    Fault ${fault_id} does not appear at BTS

Check If Fault Is Not Active With Netact
    ${faults_output}=    Wait until keyword succeeds    5 min    30 sec    Get active faults using netact    ${NETACT_CONNECTION}
    ${is_fault_active}=    check_faults_in_output    output=${faults_output}    fauld_id=${fault_id}
    Run Keyword If 	'${is_fault_active}' == 'True'    Fail    Fault ${fault_id} appear at BTS

Initialize Certificates From NetAct With Timeout
    Wait until keyword succeeds    5 min    30 sec    Initialize Certificates From NetAct     connection=${NETACT_CONNECTION}

Get SCF From BTS
    Download SCF                          filename=${SCF_NAME}
    ...                                   local_path=${OUTPUT_DIR}

Set Cert Update Time Param With Netact
    [Arguments]    ${param_value}
    Get SCF From BTS
    ${param_changes}                      Create Dictionary
    ...                                   neCertificateUpdateTime=${param_value}

    Wait until keyword succeeds    5 min    30 sec    Set parameter using NetAct
    ...                                 dist_name=MRBTS-${BTS_ID}/${cmp_path}
    ...                                 param_changes=${param_changes}
    ...                                 path_to_scf=${OUTPUT_DIR}/${SCF_NAME}
    ...                                 na_instance=${NETACT_CONNECTION}

Set CMP Configuration With Netact
    Wait until keyword succeeds    5 min    30 sec    Configure CMP Server With NetAct    ${NETACT_CONNECTION}
        ...                                 ${CERT_PRESHARED_KEY}
        ...                                 ${CA_REFERENCE_NUMBER}
        ...                                 ${SERVER_TYPE}
        ...                                 MRBTS-${BTS_ID}/${cmp_path}
        ...                                 ${CONFIGURE_CMP_TIMEOUT}
    Get SCF From BTS
    ${param_changes}                      Create Dictionary
    ...                                   caSubjectName=${ca_subject_name_correct}
    ...                                   serverHost=${CA_SERVER_IP}
    ...                                   serverPath=${CA_SERVER_PATH}
    ...                                   serverPort=${CA_DEFAULT_PORT}
    ...                                   caCertificateUpdateTime=${PARAM_CERT_UPDATE_TIME}
    Wait until keyword succeeds    5 min    30 sec    Set Parameter Using Netact
    ...                                   dist_name=MRBTS-${BTS_ID}/${cmp_path}
    ...                                   param_changes=${param_changes}
    ...                                   path_to_scf=${OUTPUT_DIR}/${SCF_NAME}
    ...                                   na_instance=${NETACT_CONNECTION}

Set Cert Update Time Boundary Values With Netact
    Initialize Certificates From NetAct With Timeout
    ${cert_list}=    Get Certificates List    cert_type=${bts_cert_type_for_listing}
    ${sw_release}=   Get Software Release Name
    ${x}=    get_cert_validity    ${cert_list}    ${sw_release}
    Set Global Variable    ${first_invalid}    ${x}
    Set Global Variable    ${last_valid}    ${${first_invalid}-${1}}

