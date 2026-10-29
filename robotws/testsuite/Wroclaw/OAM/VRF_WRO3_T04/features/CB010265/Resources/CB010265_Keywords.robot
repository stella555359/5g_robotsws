*** Settings ***
Documentation
...  author:     Patryk Tatarek
...  contact:    patryk.tatarek@nokia.com

Library     BuiltIn
Library    ../Resources/CB010265_Keywords.py
Resource    taf/rfrl/cbts/utilities/init_variables.robot
Resource    ../../../../cloud_common_resources/parameters/parameters.robot
Resource    ../../../../cloud_common_resources/logs/logs.robot
Resource    ../../../../cloud_common_resources/certificates/certificates.robot
Resource    ../../../../cloud_common_resources/resets/resets.robot

*** Variables ***
${cert_expire_alarm}=           Operator Certificate About to Expire or Expired
${cert_time_mismatch_alarm}=    End Entity Certificate Update Time Mismatch
${crl_update_alarm}=            CRL Update failure or certificate revoked
${primary_param_value}=    10.42.54.11:389/CN=CB007672,OU=People,DC=nodomain?certificateRevocationList;binary

${TOO_LONG}  .aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa.com
@{SUBJECT_ALT_INCORRECT}    domain com    domain_com    -domain.com    domain-.com    domain-.com    (
...    192.168.0.-1    2001:db8:85a3::8a2e:370g:7334
${SUBJECT_ALT_NAME_INCORRECT1}    .192.168.0.1
@{SUBJECT_ALT_NAME_CORRECT}    domain.com    192.168.0.1
${REGEX}    ^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$
${RSA_SUBJECT_NAME}=        C=PL, O=Common, CN=IPSEC
${ECDSA_SUBJECT_NAME}=      CN=CB005999_test

*** Keywords ***
Delete incorrect CRLDPCONFIG objects
    FOR    ${nr}    IN RANGE    2    21
        Log    Deleting CRLDPCONFIG-${nr} object    console=True
        Wait Until Keyword Succeeds    3x    10s    Delete Object on BTS
        ...                                         dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-${nr}
        ...                                         hw_type=vDU
    END

Delete Downloaded and Installed Certificates
    FOR    ${nr}    IN RANGE    1    13
        Run    rm /home/ute/ca${nr}.pem
    END
    ${certs_list}=      Check Certificates    hw_type=vDU
    ${certs_string}=    Convert to String    ${certs_list}
    ${list}=            Get Regexp Matches    ${certs_string}    CACERT_R[0-9][0-9']
    FOR    ${cert}    IN    @{list}
        ${status}=      Run Keyword and Return Status    Should Contain    ${cert}    '
        ${cert_adj}=    Remove String Using Regexp    ${cert}    '
        ${cert_id}=     Set Variable If    ${status}    ${cert_adj}    ${cert}
        Delete Certificate    cert_id=${cert_id}    hw_type=vDU
    END

CRL should be empty on vDU
    ${temp_conn}=      Connect to ADMIN    hw_type=vDU
    ${crl_info}=       vdu_admin.get_vdu_crl_information    vdu_connection=${temp_conn}
    Should be True    "${crl_info}"=="{'crlinfo_list': []}"
    [Teardown]         Disconnect from ADMIN    connection=${temp_conn}    hw_type=vDU

Modify eeSubjectAltNames Structure
    [Documentation]    Description:    Modify the eeSubjectAltNames structure by adding or deleting the
    ...                                structure.
    ...                Arguments:      hw_type = vCU/vDU
    ...                                object = CMP/CMPECDSA
    ...                                add_or_remove = Add/Remove
    ...                                param = needed only when add_or_remove = Add; fill with the value that
    ...                                        will be added to subjectAltName and subjectAltType parameters
    ...                                path = path to SCF file
    ...                Author:         jagoda.kubacka@nokia.com
    [Arguments]      ${hw_type}    ${object}=CMP    ${add_or_remove}=Remove    ${param}=${None}    ${path}=${None}
    ${temp_conn}         Connect to ADMIN    hw_type=${hw_type}
    ${MRBTS}=            Set Variable If    '${hw_type}'=='vCU'    ${MRBTS_CU}      ${MRBTS}
    Run Keyword If       '${hw_type}'=='vDU'    vdu_admin.get_current_plan_file
    ...                  local_dir_path=${path}    filename=${TEST_NAME}.xml
    ...                  include_runtime_data=${False}    vdu_connection=${temp_conn}
    ...                  ELSE IF           '${hw_type}'=='vCU'    vcu_admin.get_current_plan_file
    ...                  path=${path}/${TEST_NAME}.xml   include_runtime_data=${False}
    ...                  connection=${temp_conn}
    ...                  ELSE               FAIL                  hw_type doesn't exist
    Run Keyword If    '${add_or_remove}'=='Add'    add_parama_to_scf    ${MRBTS}     ${object}    ${param}
    ...                                           ${path}/${TEST_NAME}.xml
    ...                ELSE    remove_structure_from_scf    ${MRBTS}     ${object}    ${path}/${TEST_NAME}.xml
    Run Keyword If    '${hw_type}'=='vDU'    vdu_admin.perform_commissioning
    ...    scf_file=${OUTPUT_DIR}/${TEST_NAME}/${TEST_NAME}.xml    vdu_connection=${temp_conn}
    ...    ELSE IF    '${hw_type}'=='vCU'    vcu_admin.perform_commissioning    scf_file=${OUTPUT_DIR}/${TEST_NAME}/${TEST_NAME}.xml
    ...                                      connection=${temp_conn}
    [Teardown]    Run Keyword and Ignore Error    Disconnect from ADMIN    connection=${temp_conn}    hw_type=${hw_type}

Verification the eeSubjectAltNames parameters
    [Arguments]    ${cert_type}=RSA    ${hw_type}=${None}
    ${object}=    Set Variable If    '${cert_type}'=='RSA'    CMP    CMPECDSA
    Log    Step 1: Clearing certificates before test starts    console=true
    Configure CMP                   ca_subject_name=wrong    server_type=${cert_type}    hw_type=${hw_type}
    Configure CMP                   ca_subject_name=wrong    server_type=${cert_type}    hw_type=${hw_type}
    Run Keyword and Ignore Error    Delete All Certificates    hw_type=${hw_type}
    Run Keyword and Ignore Error    Restore Default Certificates on BTS    hw_type=${hw_type}
    Log    Step 2: Setting the eeSubjectAltNames parameters to allowed values    console=true
    &{SUBJECT_ALT_NAME1}=    Create Dictionary    subjectAltName=domain    subjectAltType=DOMAIN
    @{SUBJECT_ALT_NAME}=    Create List    ${SUBJECT_ALT_NAME1}
    Create Directory     ${OUTPUT_DIR}/${TEST_NAME}
    Change Parameter on BTS            dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/${object}-1
    ...                                param_name=eeSubjectAltNames
    ...                                param_value=${SUBJECT_ALT_NAME}
    ...                                hw_type=vDU
    Log    Step 3: Setting the eeSubjectAltNames parameters to too long value    console=true
    &{SUBJECT_ALT_NAME_DICT}=    Create Dictionary    subjectAltName=${TOO_LONG}    subjectAltType=DOMAIN
    @{parameter}=    Create List    ${SUBJECT_ALT_NAME_DICT}
    Log    Step 4: Changing the subjectAltName with wrong value (too long): ${TOO_LONG}    console=true
    Run Keyword And Expect Error    *too long*    Change Parameter on BTS
    ...                                dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/${object}-1
    ...                                param_name=eeSubjectAltNames
    ...                                param_value=${parameter}
    ...                                hw_type=${hw_type}
    Log    Step 5: Changing the subjectAltName with wrong value: ${SUBJECT_ALT_NAME_INCORRECT1}    console=true
    &{SUBJECT_ALT_NAME_DICT_INCORR}=   Create Dictionary    subjectAltName=${SUBJECT_ALT_NAME_INCORRECT1}  subjectAltType=IP Address
    @{parameter}=                          Create List    ${SUBJECT_ALT_NAME_DICT_INCORR}
    Run Keyword And Expect Error    *subjectAltName shall be of IPV4 or IPV6*    Change Parameter on BTS
    ...                                    dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/${object}-1
    ...                                    param_name=eeSubjectAltNames
    ...                                    param_value=${parameter}
    ...                                    hw_type=${hw_type}
    Log    Step 6: Changing the subjectAltNames with wrong values    console=true
    FOR    ${i}    IN    @{SUBJECT_ALT_INCORRECT}
        Log    Changing the subjectAltName with the following value: ${i}    console=true
        &{SUBJECT_ALT_NAME}=    Create Dictionary    subjectAltName=${i}    subjectAltType=DOMAIN
        @{parameter}=    Create List    ${SUBJECT_ALT_NAME}
        Run Keyword And Expect Error    *is not match required regex*    Change Parameter on BTS
        ...                                dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/${object}-1
        ...                                param_name=eeSubjectAltNames
        ...                                param_value=${parameter}
        ...                                hw_type=${hw_type}
    END
    Log    Step 7: Changing the subjectAltNames with correct values and checking the PCAP    console=true
    FOR    ${i}    IN    @{SUBJECT_ALT_NAME_CORRECT}
        ${CRAN}=    Set Variable If    '${hw_type}'=='vCU'    ${CRAN_VCU}    ${CRAN_VDU}
        ${certs}=    Set Variable If    '${cert_type}'=='RSA'    ${RSA_SUBJECT_NAME}    ${ECDSA_SUBJECT_NAME}
        ${status}=    Get Regexp Matches    ${i}    ${REGEX}
        ${type}=      Set Variable If    "${status}"!= "[]"    IP Address    DOMAIN
        Run Keyword and Ignore Error    Delete All Certificates    hw_type=${hw_type}
        Run Keyword and Ignore Error    Restore Default Certificates on BTS    hw_type=${hw_type}
        Log    Changing the subjectAltName with the following value: ${i}    console=true
        &{SUBJECT_ALT_NAME}=       Create Dictionary    subjectAltName=${i}    subjectAltType=${type}
        @{parameter}=              Create List    ${SUBJECT_ALT_NAME}
        Change Parameter on BTS    dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/${object}-1
        ...                        param_name=eeSubjectAltNames
        ...                        param_value=${parameter}
        ...                        hw_type=${hw_type}
        Wait Until Keyword Succeeds     2 min  15 sec
        ...    Start TCPdump                   capture_type=pod    pod_names=po-oamext-0    hw_type=${hw_type}
        Update CMP Server Settings      key_pool_type=${cert_type}    hw_type=${hw_type}
        Configure CMP                   ca_subject_name=${certs}    server_type=${cert_type}    hw_type=${hw_type}
        Wait Until Keyword Succeeds     5x    1min      Initialize Certificate    key_pool_type=${cert_type}    hw_type=${hw_type}
        ${pcap_path}=                   Stop TCPdump and Download Pcap    pod_name=po-oamext-0     hw_type=${hw_type}
        Get subjectAltName value from PCAP    ${pcap_path}    ${i}    ${type}
        Configure CMP                         ca_subject_name=wrong    server_type=${cert_type}    hw_type=${hw_type}
    END
    [Teardown]    Run Keywords    Modify eeSubjectAltNames Structure    hw_type=${hw_type}    object=${object}
    ...                           add_or_remove=Remove    path=${OUTPUT_DIR}/${TEST_NAME}    AND
    ...                           Wait Until Keyword Succeeds  10 min  60 sec  Check if Unit Status is OnAir    hw_type=${hw_type}

Get subjectAltName value from PCAP
    [Documentation]      Description:    Checking the if the PCAP file has the proper value in CMP IR message.
    ...                                  The value from PCAP is comapred to the value from the subjectAltName parameter.
    ...                  Author:         jagoda.kubacka@nokia.com
    [Arguments]    ${path}    ${subjectAltName}    ${domain_or_IP}=DOMAIN
    ${cipher_suite_domain}=    Catenate      cmp and x509ce.dNSName
    ${cipher_suite_ip}=    Catenate    cmp and x509ce.IPAddress.ipv4
    ${grep_filters}=    Set Variable If    '${domain_or_IP}'=='DOMAIN'    dNSName:    iPAddress:
    ${cipher_suite_filters}=    Set Variable If    '${domain_or_IP}'=='DOMAIN'    ${cipher_suite_domain}    ${cipher_suite_ip}
    ${cipher_suite}=            Run    tshark -r ${path} -Y "${cipher_suite_filters}" -V | grep -A 20 "${grep_filters}"
    Should Contain    ${cipher_suite}    ${subjectAltName}
