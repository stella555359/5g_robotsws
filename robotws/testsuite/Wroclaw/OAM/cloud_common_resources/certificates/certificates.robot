*** Settings ***
Documentation    Cloud certificates keywords.
...              Authors:    Patryk Tatarek, Jagoda Kubacka
...              Contact:    patryk.tatarek@nokia.com, jagoda.kubacka@nokia.com

Resource    ../connections/connections.robot
Resource    ../parameters/parameters.robot
Resource    taf/rfrl/cbts/robot/vcu/vcu_cm.robot
Resource    taf/rfrl/cbts/robot/vdu/vdu_cm.robot
Resource    taf/rfrl/cbts/robot/webem_operations.robot

Library     taf.gnb.oam.coam.cu     WITH NAME    vcu_admin
Library     taf.gnb.oam.coam.vdu    WITH NAME    vdu_admin
Library     Collections

*** Variables ***
${CA1_Ref_Num}=        5330
${CA1_PSK}=            fnAR-zMMi-4pVz-mwrG
${CA_SERVER_IP}=       10.42.54.13
${CA_SERVER_PATH}=     pkix
${CA_DEFAULT_PORT}=    8080
&{CMP_OBJECT}=         RSA=CMP-1
...                    ECDSA=CMPECDSA-1

*** Keywords ***

#################################################### Main  Keywords ####################################################

Update CMP Server Settings
    [Documentation]    Description:    Update CMP Server Settings
    ...                Input:          hw_type = vCU/vDU
    ...                                pre-connection = preexisting connection, if not given then logged as System Admin
    ...                                                 with default username and password
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${ref_number}=${CA1_Ref_Num}    ${psk_key}=${CA1_PSK}
    ...                ${key_pool_type}=RSA    ${hw_type}=${NONE}    ${pre-connection}=${NONE}
    Run Keyword If    '${hw_type}'=='vCU'    _Update vCU CMP Server Settings    ref_number=${ref_number}
    ...                                      psk_key=${psk_key}    key_pool_type=${key_pool_type}
    ...                                      pre-conn=${pre-connection}
    ...    ELSE IF    '${hw_type}'=='vDU'    _Update vDU CMP Server Settings    ref_number=${ref_number}
    ...                                      psk_key=${psk_key}    key_pool_type=${key_pool_type}
    ...                                      pre-conn=${pre-connection}
    ...    ELSE        FAIL                  hw_type doesn't exist

Configure CMP
    [Documentation]    Description:    Configure primary CMP
    ...                Input:          hw_type = vCU/vDU
    ...                                server_type = RSA/ECDSA
    ...                                pre-connection = preexisting connection, if not given then logged as System Admin
    ...                                                 with default username and password
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${ca_subject_name}    ${server_type}=RSA    ${ca_server_host}=${CA_SERVER_IP}
    ...                ${server_path}=${CA_SERVER_PATH}    ${ca_server_port}=${CA_DEFAULT_PORT}
    ...                ${ee_subject_name}=CN=MRBTS-${MRBTS}    ${hw_type}=${NONE}    ${pre-connection}=${NONE}
    Run Keyword If    '${hw_type}'=='vCU'    _Configure CMP on vCU    ca_subject_name=${ca_subject_name}
    ...                server_type=${server_type}    ca_server_host=${ca_server_host}
    ...                server_path=${server_path}    ca_server_port=${ca_server_port}
    ...                ee_subject_name=${ee_subject_name}    pre-conn=${pre-connection}
    ...    ELSE IF    '${hw_type}'=='vDU'    _Configure CMP on vDU    ca_subject_name=${ca_subject_name}
    ...                server_type=${server_type}    ca_server_host=${ca_server_host}
    ...                server_path=${server_path}    ca_server_port=${ca_server_port}
    ...                ee_subject_name=${ee_subject_name}    pre-conn=${pre-connection}
    ...    ELSE        FAIL    hw_type doesn't exist

Configure Secondary CMP
    [Documentation]    Description:    Configure secondary CMP
    ...                Input:          hw_type = vCU/vDU
    ...                                server_type = RSA/ECDSA
    ...                                pre-connection = preexisting connection, if not given then logged as System Admin
    ...                                                 with default username and password
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${ca_subject_name}    ${server_type}=RSA    ${ca_server_host}=${CA_SERVER_IP}
    ...                ${server_path}=${CA_SERVER_PATH}    ${ca_server_port}=${CA_DEFAULT_PORT}    ${hw_type}=${NONE}
    ...                ${pre-connection}=${NONE}
    Run Keyword If    '${hw_type}'=='vCU'    _Configure Secondary CMP on vCU    ca_subject_name=${ca_subject_name}
    ...                server_type=${server_type}    ca_server_host=${ca_server_host}    server_path=${server_path}
    ...                ca_server_port=${ca_server_port}    pre-conn=${pre-connection}
    ...    ELSE IF    '${hw_type}'=='vDU'    _Configure Secondary CMP on vDU    ca_subject_name=${ca_subject_name}
    ...                server_type=${server_type}    ca_server_host=${ca_server_host}    server_path=${server_path}
    ...                ca_server_port=${ca_server_port}    pre-conn=${pre-connection}
    ...    ELSE        FAIL    hw_type doesn't exist

Configure Both CMP
    [Documentation]    Description:    Configure primary and secondary CMP at the same time
    ...                Input:          hw_type = vCU/vDU
    ...                                server_type = RSA/ECDSA
    ...                                pre-connection = preexisting connection, if not given then logged as System Admin
    ...                                                 with default username and password
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${primary_ca_subject_name}    ${secondary_ca_subject_name}    ${server_type}=RSA
    ...                ${primary_ca_server_host}=${CA_SERVER_IP}    ${secondary_ca_server_host}=${CA_SERVER_IP}
    ...                ${primary_server_path}=${CA_SERVER_PATH}    ${secondary_server_path}=${CA_SERVER_PATH}
    ...                ${primary_ca_server_port}=${CA_DEFAULT_PORT}    ${secondary_ca_server_port}=${CA_DEFAULT_PORT}
    ...                ${hw_type}=${NONE}    ${pre-connection}=${NONE}
    Run Keyword If    '${hw_type}'=='vCU'    _Configure Both CMP on vCU
    ...                primary_ca_subject_name=${primary_ca_subject_name}
    ...                secondary_ca_subject_name=${secondary_ca_subject_name}
    ...                server_type=${server_type}
    ...                primary_ca_server_host=${primary_ca_server_host}
    ...                secondary_ca_server_host=${secondary_ca_server_host}
    ...                primary_server_path=${primary_server_path}
    ...                secondary_server_path=${secondary_server_path}
    ...                primary_ca_server_port=${primary_ca_server_port}
    ...                secondary_ca_server_port=${secondary_ca_server_port}
    ...                pre-conn=${pre-connection}
    ...    ELSE IF    '${hw_type}'=='vDU'    _Configure Both CMP on vDU
    ...                primary_ca_subject_name=${primary_ca_subject_name}
    ...                secondary_ca_subject_name=${secondary_ca_subject_name}
    ...                server_type=${server_type}
    ...                primary_ca_server_host=${primary_ca_server_host}
    ...                secondary_ca_server_host=${secondary_ca_server_host}
    ...                primary_server_path=${primary_server_path}
    ...                secondary_server_path=${secondary_server_path}
    ...                primary_ca_server_port=${primary_ca_server_port}
    ...                secondary_ca_server_port=${secondary_ca_server_port}
    ...                pre-conn=${pre-connection}
    ...    ELSE        FAIL    hw_type doesn't exist

Delete Secondary CMP
    [Documentation]    Description:    Delete secondary CMP parameters values
    ...                Input:          hw_type = vCU/vDU
    ...                                server_type = RSA/ECDSA
    ...                                pre-connection = preexisting connection, if not given then logged as System Admin
    ...                                                 with default username and password
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${server_type}=RSA    ${hw_type}=${NONE}    ${pre-connection}=${NONE}
    Run Keyword If    '${hw_type}'=='vCU'    _Delete Secondary CMP on vCU    server_type=${server_type}
    ...                                                                      pre-conn=${pre-connection}
    ...    ELSE IF    '${hw_type}'=='vDU'    _Delete Secondary CMP on vDU    server_type=${server_type}
    ...                                                                      pre-conn=${pre-connection}
    ...    ELSE        FAIL                  hw_type doesn't exist

Initialize Certificate
    [Documentation]    Description:    Initialize certificate
    ...                Input:          hw_type = vCU/vDU
    ...                                key_pool_type = RSA/ECDSA
    ...                                pre-connection = preexisting connection, if not given then logged as System Admin
    ...                                                 with default username and password
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${key_pool_type}=RSA    ${hw_type}=${NONE}    ${pre-connection}=${NONE}
    Run Keyword If    '${hw_type}'=='vCU'    _Initialize vCU Certificate    key_pool_type=${key_pool_type}
    ...                                                                     pre-conn=${pre-connection}
    ...    ELSE IF    '${hw_type}'=='vDU'    _Initialize vDU Certificate    key_pool_type=${key_pool_type}
    ...                                                                     pre-conn=${pre-connection}
    ...    ELSE        FAIL                  hw_type doesn't exist

Try to Initialize Certificate and Expect Error
    [Documentation]    Description:    Initialize certificate
    ...                Input:          hw_type = vCU/vDU
    ...                                key_pool_type = RSA/ECDSA
    ...                                expected_error = expected failure reason
    ...                                pre-connection = preexisting connection, if not given then logged as System Admin
    ...                                                 with default username and password
    ...                Note:           If you're using this on vCU, run it with Wait Until Keyword Succeeds  3x  5s,
    ...                                because failure reason after first trigger could be different then expected one
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${expected_error}    ${key_pool_type}=RSA    ${hw_type}=${NONE}    ${pre-connection}=${NONE}
    Run Keyword If    '${hw_type}'=='vCU'    _Try to Initialize vCU Certificate    expected_error=${expected_error}
    ...                                      key_pool_type=${key_pool_type}    pre-conn=${pre-connection}
    ...    ELSE IF    '${hw_type}'=='vDU'    _Try to Initialize vDU Certificate    expected_error=${expected_error}
    ...                                      key_pool_type=${key_pool_type}    pre-conn=${pre-connection}
    ...    ELSE        FAIL                  hw_type doesn't exist

Check Certificates
    [Documentation]    Description:    Returns informations about installed certificates
    ...                Input:          hw_type = vCU/vDU
    ...                Output:         Output format is list of dicts
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${hw_type}=${NONE}    ${pre-connection}=${NONE}
    ${cert_list}=      Run Keyword If    '${hw_type}'=='vCU'    _Check vCU Certificates    pre-conn=${pre-connection}
    ...                ELSE IF           '${hw_type}'=='vDU'    _Check vDU Certificates    pre-conn=${pre-connection}
    ...                ELSE               FAIL                  hw_type doesn't exist
    [Return]           ${cert_list}

Delete Certificate
    [Documentation]    Description:    Delete certificate with chosen id
    ...                Input:          hw_type = vCU/vDU
    ...                                cert_id can be found using "Check Certificates" keyword
    ...                                pre-connection = preexisting connection, if not given then logged as System Admin
    ...                                                 with default username and password
    ...                Author:         patryk.tatareka@nokia.com
    [Arguments]        ${cert_id}    ${hw_type}=${NONE}    ${pre-connection}=${NONE}
    Run Keyword If    '${hw_type}'=='vCU'    _Delete Certificate on vCU    cert_id=${cert_id}
    ...                                                                    pre-conn=${pre-connection}
    ...    ELSE IF    '${hw_type}'=='vDU'    _Delete Certificate on vDU    cert_id=${cert_id}
    ...                                                                    pre-conn=${pre-connection}
    ...    ELSE        FAIL                  hw_type doesn't exist

Install Certificate
    [Documentation]    Description:    Install certificat from file
    ...                Input:          hw_type = vCU/vDU
    ...                                cert_path = local path to cert file
    ...                                cert_type = EE/CA
    ...                                cert_encoding is valid only for vDU
    ...                                pre-connection = preexisting connection, if not given then logged as System Admin
    ...                                                 with default username and password
    ...                Output:         Certificates in form of list of dicts
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${cert_path}    ${cert_type}    ${cert_encoding}=pem
    ...                ${hw_type}=${NONE}    ${pre-connection}=${NONE}
    Run Keyword If    '${hw_type}'=='vCU'    _Install Certificate on vCU    cert_path=${cert_path}
    ...                                      cert_type=${cert_type}    pre-conn=${pre-connection}
    ...    ELSE IF    '${hw_type}'=='vDU'    _Install Certificate on vDU    cert_path=${cert_path}
    ...                                      cert_type=${cert_type}    cert_encoding=${cert_encoding}
    ...                                      pre-conn=${pre-connection}
    ...    ELSE        FAIL                  hw_type doesn't exist

Restore Default Certificates on BTS
    [Documentation]    Description:    Restore default certificates
    ...                Input:          hw_type = vCU/vDU
    ...                                pre-connection = preexisting connection, if not given then logged as System Admin
    ...                                                 with default username and password
    ...                Author:         jagoda.kubackaa@nokia.com
    [Arguments]        ${hw_type}=${NONE}    ${pre-connection}=${NONE}
    Run Keyword If    '${hw_type}'=='vCU'    _Restore vCU Default Certificates    pre-conn=${pre-connection}
    ...    ELSE IF    '${hw_type}'=='vDU'    _Restore vDU Default Certificates    pre-conn=${pre-connection}
    ...    ELSE        FAIL                  hw_type doesn't exist

Check if last CRL Update was correct
    [Documentation]    Description:    Check if value of "CRL state" is equal to "LastUpdateOK"
    ...                Input:          hw_type = vCU/vDU
    ...                                pre-connection = preexisting connection, if not given then logged as System Admin
    ...                                                 with default username and password
    ...                Author:         patryk.tatareka@nokia.com
    [Arguments]        ${hw_type}=${NONE}    ${pre-connection}=${NONE}
    Run Keyword If    '${hw_type}'=='vCU'    _Check if last CRL Update was correct on vCU    pre-conn=${pre-connection}
    ...    ELSE IF    '${hw_type}'=='vDU'    _Check if last CRL Update was correct on vDU    pre-conn=${pre-connection}
    ...    ELSE        FAIL                  hw_type doesn't exist

Check if last CRL Update was incorrect
    [Documentation]    Description:    Check if value of "CRL state" is equal to "LastUpdateFailed".
    ...                Input:          hw_type = vCU/vDU
    ...                Author:         patryk.tatareka@nokia.com
    [Arguments]        ${hw_type}=${NONE}    ${pre-connection}=${NONE}
    Run Keyword If    '${hw_type}'=='vCU'    _Check if last CRL Update was incorrect on vCU
    ...                                      pre-conn=${pre-connection}
    ...    ELSE IF    '${hw_type}'=='vDU'    _Check if last CRL Update was incorrect on vDU
    ...                                      pre-conn=${pre-connection}
    ...    ELSE        FAIL                  hw_type doesn't exist

Check if CRL Update has started
    [Documentation]    Description:    Check if value of "CRL state" is equal to "LastUpdateOK"
    ...                Input:          hw_type = vCU/vDU
    ...                                pre-connection = preexisting connection, if not given then logged as System Admin
    ...                                                 with default username and password
    ...                Author:         patryk.tatareka@nokia.com
    [Arguments]        ${hw_type}=${NONE}    ${pre-connection}=${NONE}
    Run Keyword If    '${hw_type}'=='vCU'    _Check if CRL Update has started on vCU    pre-conn=${pre-connection}
    ...    ELSE IF    '${hw_type}'=='vDU'    _Check if CRL Update has started on vDU    pre-conn=${pre-connection}
    ...    ELSE        FAIL                  hw_type doesn't exist

Check if CRL Update is ongoing
    [Documentation]    Description:    Check if value of "CRL state" is equal to "LastUpdateOK"
    ...                Input:          hw_type = vCU/vDU
    ...                                pre-connection = preexisting connection, if not given then logged as System Admin
    ...                                                 with default username and password
    ...                Author:         patryk.tatareka@nokia.com
    [Arguments]        ${hw_type}=${NONE}    ${pre-connection}=${NONE}
    Run Keyword If    '${hw_type}'=='vCU'    _Check if CRL Update is ongoing on vCU    pre-conn=${pre-connection}
    ...    ELSE IF    '${hw_type}'=='vDU'    _Check if CRL Update is ongoing on vDU    pre-conn=${pre-connection}
    ...    ELSE        FAIL                  hw_type doesn't exist

Create Mutliple CRLDP Objects with Only PrimaryCRLDP
    [Documentation]    Description:    Create Multiple CRLDP Objects with values onlu in PrimaryCRLDP
    ...                Input:          hw_type = vCU/vDU
    ...                                start = id of the first object
    ...                                stop = id of the last object + 1
    ...                                primary_values = values of primaryCRLDP
    ...                                must be given as List with length = stop - start
    ...                                Use BuiltIn keyword "Create List" to create this variable
    ...                Author:         patryk.tatareka@nokia.com
    [Arguments]        ${start}    ${stop}    ${primary_values}    ${hw_type}=${NONE}
    Run Keyword If    '${hw_type}'=='vCU'    _Create Mutliple CRLDP Objects with Only PrimaryCRLDP on vCU
    ...                                      start=${start}    stop=${stop}    primary_values=${primary_values}
    ...    ELSE IF    '${hw_type}'=='vDU'    _Create Mutliple CRLDP Objects with Only PrimaryCRLDP on vDU
    ...                                      start=${start}    stop=${stop}    primary_values=${primary_values}
    ...    ELSE        FAIL                  hw_type doesn't exist

Create Mutliple CRLDP Objects with PrimaryCRLDP and SecondaryCRLDP
    [Documentation]    Description:    Create Multiple CRLDP Objects with values in PrimaryCRLDP and SecondaryCRLDP
    ...                Input:          hw_type = vCU/vDU
    ...                                start = id of the first object
    ...                                stop = id of the last object + 1
    ...                                primary_values = values of primaryCRLDP
    ...                                must be given as List with length = stop - start
    ...                                secondary_values = values of secondaryCRLDP
    ...                                must be given as List with length = stop - start
    ...                                Use BuiltIn keyword "Create List" to create those variables
    ...                Author:         patryk.tatareka@nokia.com
    [Arguments]        ${start}    ${stop}    ${primary_values}    ${secondary_values}    ${hw_type}=${NONE}
    Run Keyword If    '${hw_type}'=='vCU'    _Create Mutliple CRLDP Objects with PrimaryCRLDP and SecondaryCRLDP on vCU
    ...                                      start=${start}    stop=${stop}
    ...                                      primary_values=${primary_values}
    ...                                      secondary_values=${secondary_values}
    ...    ELSE IF    '${hw_type}'=='vDU'    _Create Mutliple CRLDP Objects with PrimaryCRLDP and SecondaryCRLDP on vDU
    ...                                      start=${start}    stop=${stop}
    ...                                      primary_values=${primary_values}
    ...                                      secondary_values=${secondary_values}
    ...    ELSE        FAIL                  hw_type doesn't exist

Delete Mutliple CRLDP Objects
    [Documentation]    Description:    Create Multiple CRLDP Objects
    ...                Input:          hw_type = vCU/vDU
    ...                                start = id of the first object
    ...                                stop = id of the last object + 1
    ...                Author:         patryk.tatareka@nokia.com
    [Arguments]        ${start}    ${stop}    ${hw_type}=${NONE}
    Run Keyword If    '${hw_type}'=='vCU'    _Delete Mutliple CRLDP Objectson vCU     start=${start}    stop=${stop}
    ...    ELSE IF    '${hw_type}'=='vDU'    _Delete Mutliple CRLDP Objects on vDU    start=${start}    stop=${stop}
    ...    ELSE        FAIL                  hw_type doesn't exist

Generate CSR
    [Documentation]    Description:    Generate CSR
    ...                Input:          hw_type = vCU/vDU
    ...                                key_pool_type = RSA/ECDSA
    ...                                pre-connection = preexisting connection, if not given then logged as System Admin
    ...                                                 with default username and password
    ...                Output:         variable with CSR as text
    ...                Author:         patryk.tatareka@nokia.com
    [Arguments]        ${key_pool_type}=RSA    ${hw_type}=${NONE}    ${pre-connection}=${NONE}
    ${csr}=            Run Keyword If    '${hw_type}'=='vCU'    _Generate CSR on vCU    key_pool_type=${key_pool_type}
    ...                                                                                 pre-conn=${pre-connection}
    ...                ELSE IF           '${hw_type}'=='vDU'    _Generate CSR on vDU    key_pool_type=${key_pool_type}
    ...                                                                                 pre-conn=${pre-connection}
    ...                ELSE               FAIL                  hw_type doesn't exist
    [Return]           ${csr}

Update CMP Key
    [Documentation]    Description:    Update CMP key
    ...                Input:          hw_type = vCU/vDU
    ...                                key_pool_type = RSA/ECDSA
    ...                                pre-connection = preexisting connection, if not given then logged as System Admin
    ...                                                 with default username and password
    ...                Author:         patryk.tatareka@nokia.com
    [Arguments]        ${key_pool_type}=RSA    ${hw_type}=${NONE}    ${pre-connection}=${NONE}
    Run Keyword If    '${hw_type}'=='vCU'    _Update CMP Key on vCU    key_pool_type=${key_pool_type}
    ...                                                                pre-conn=${pre-connection}
    ...    ELSE IF    '${hw_type}'=='vDU'    _Update CMP Key on vDU    key_pool_type=${key_pool_type}
    ...                                                                pre-conn=${pre-connection}
    ...    ELSE        FAIL                  hw_type doesn't exist

Try to Update CMP Key and Expect Error
    [Documentation]    Description:    Update CMP key
    ...                Input:          hw_type = vCU/vDU
    ...                                key_pool_type = RSA/ECDSA
    ...                                expected_error = expected failure reason
    ...                                pre-connection = preexisting connection, if not given then logged as System Admin
    ...                                                 with default username and password
    ...                Note:           If you're using this on vCU, run it with Wait Until Keyword Succeeds  3x  5s,
    ...                                because failure reason after first trigger could be different then expected one
    ...                Author:         patryk.tatareka@nokia.com
    [Arguments]        ${expected_error}    ${key_pool_type}=RSA    ${hw_type}=${NONE}    ${pre-connection}=${NONE}
    Run Keyword If    '${hw_type}'=='vCU'    _Try to Update CMP Key on vCU    expected_error=${expected_error}
    ...                                                                       key_pool_type=${key_pool_type}
    ...                                                                       pre-conn=${pre-connection}
    ...    ELSE IF    '${hw_type}'=='vDU'    _Try to Update CMP Key on vDU    expected_error=${expected_error}
    ...                                                                       key_pool_type=${key_pool_type}
    ...                                                                       pre-conn=${pre-connection}
    ...    ELSE        FAIL                  hw_type doesn't exist

################################################ Supplementary Keywords ################################################

_Update vCU CMP Server Settings
    [Arguments]        ${ref_number}=${CA1_Ref_Num}   ${psk_key}=${CA1_PSK}   ${key_pool_type}=RSA
    ...                ${pre-conn}=${NONE}
    ${temp_conn}=      Run Keyword If    "${pre-conn}"=="${NONE}"    Connect to ADMIN    hw_type=vCU
    ...                ELSE    Set Variable    ${pre-conn}
    ${output}=         vcu_admin.update_cmp_server_settings    ref_number=${ref_number}
    ...                psk_key=${psk_key}    key_pool_type=${key_pool_type}
    ...                timeout=60            connection=${temp_conn}
    Should Be True     "${output["status"]}"=="Successful"
    [Teardown]         Run Keyword If    "${pre-conn}"=="${NONE}"    Disconnect from ADMIN
    ...                                                              connection=${temp_conn}    hw_type=vCU

_Check vCU CMP Operation Should Be Expected
    [Arguments]        ${operationID}    ${expected_status}    ${connection}
    ${output}=         vcu_admin.get_trs_operation_status    operation_id=${operationID}    connection=${connection}
    Should Be True    "${output["status"]}"=="${expected_status}"

_Update vDU CMP Server Settings
    [Arguments]        ${ref_number}=${CA1_Ref_Num}   ${psk_key}=${CA1_PSK}   ${key_pool_type}=RSA
    ...                ${pre-conn}=${NONE}
    ${temp_conn}=      Run Keyword If    "${pre-conn}"=="${NONE}"    Connect to ADMIN    hw_type=vDU
    ...                ELSE    Set Variable    ${pre-conn}
    ${operationID}=    vdu_admin.update_vdu_cmp_server_settings    ref_number=${ref_number}
    ...                psk_key=${psk_key}    key_pool_type=${key_pool_type}
    ...                timeout=60            vdu_connection=${temp_conn}
    ${status}=         Wait Until Keyword Succeeds    3min    2s    _Check vDU CMP Operation Should Be Expected
    ...                operationID=${operationID}   expected_status=Successful    connection=${temp_conn}
    [Teardown]         Run Keyword If    "${pre-conn}"=="${NONE}"    Disconnect from ADMIN
    ...                                                              connection=${temp_conn}    hw_type=vDU

_Check vDU CMP Operation Should Be Expected
    [Arguments]        ${operationID}    ${expected_status}    ${connection}
    ${output}=         vdu_admin.get_trs_api_operation_status    operation_id=${operationID}
    ...                vdu_connection=${connection}
    Should Be True    "${output["status"]}"=="${expected_status}"
    [Return]           ${output}

_Check vDU CMP Operation Should Fail with Expected Reason
    [Arguments]        ${operationID}    ${expected_reason}    ${connection}
    ${output}=         vdu_admin.get_trs_api_operation_status    operation_id=${operationID}
    ...                vdu_connection=${connection}
    Should Be True    "${output["status"]}"=="Failed"
    Should Be True    "${output["reason"]}"=="${expected_reason}"
    [Return]           ${output}

_Initialize vCU Certificate
    [Arguments]        ${key_pool_type}    ${timeout}=120    ${pre-conn}=${NONE}
    ${temp_conn}=      Run Keyword If    "${pre-conn}"=="${NONE}"    Connect to ADMIN    hw_type=vCU
    ...                ELSE    Set Variable    ${pre-conn}
    ${output}=         vcu_admin.trigger_certificate_initialization    connection=${temp_conn}
    ...                key_pool_type=${key_pool_type}    timeout=${timeout}
    Should Be True     "${output["status"]}"=="Successful"
    [Teardown]         Run Keyword If    "${pre-conn}"=="${NONE}"    Disconnect from ADMIN
    ...                                                              connection=${temp_conn}    hw_type=vCU

_Initialize vDU Certificate
    [Arguments]        ${key_pool_type}    ${timeout}=120    ${pre-conn}=${NONE}
    ${temp_conn}=      Run Keyword If    "${pre-conn}"=="${NONE}"    Connect to ADMIN    hw_type=vDU
    ...                ELSE    Set Variable    ${pre-conn}
    ${operationID}=    vdu_admin.initialize_certificate    vdu_connection=${temp_conn}
    ...                key_pool_type=${key_pool_type}      timeout=${timeout}
    Wait Until Keyword Succeeds    3min    2s    _Check vDU CMP Operation Should Be Expected
    ...                operationID=${operationID}   expected_status=Successful    connection=${temp_conn}
    [Teardown]         Run Keyword If    "${pre-conn}"=="${NONE}"    Disconnect from ADMIN
    ...                                                              connection=${temp_conn}    hw_type=vDU

_Try to Initialize vCU Certificate
    [Arguments]        ${expected_error}    ${key_pool_type}    ${timeout}=60    ${pre-conn}=${NONE}
    ${temp_conn}=      Run Keyword If    "${pre-conn}"=="${NONE}"    Connect to ADMIN    hw_type=vCU
    ...                ELSE    Set Variable    ${pre-conn}
    ${output}=         vcu_admin.trigger_certificate_initialization    connection=${temp_conn}
    ...                key_pool_type=${key_pool_type}    timeout=${timeout}
    Should Be True     "${output["status"]}"=="Failed"
    Should Be True     "${output["reason"]}"=="${expected_error}"
    [Teardown]         Run Keyword If    "${pre-conn}"=="${NONE}"    Disconnect from ADMIN
    ...                                                              connection=${temp_conn}    hw_type=vCU

_Try to Initialize vDU Certificate
    [Arguments]        ${expected_error}    ${key_pool_type}    ${timeout}=60    ${pre-conn}=${NONE}
    ${temp_conn}=      Run Keyword If    "${pre-conn}"=="${NONE}"    Connect to ADMIN    hw_type=vDU
    ...                ELSE    Set Variable    ${pre-conn}
    ${operationID}=    vdu_admin.initialize_certificate    vdu_connection=${temp_conn}
    ...                key_pool_type=${key_pool_type}      timeout=${timeout}
    Wait Until Keyword Succeeds    3min    2s    _Check vDU CMP Operation Should Fail with Expected Reason
    ...                operationID=${operationID}   expected_reason=${expected_error}    connection=${temp_conn}
    [Teardown]         Run Keyword If    "${pre-conn}"=="${NONE}"    Disconnect from ADMIN
    ...                                                              connection=${temp_conn}    hw_type=vDU

_Configure CMP on vCU
    [Arguments]               ${ca_subject_name}    ${server_type}    ${ca_server_host}
    ...                       ${server_path}        ${ca_server_port}    ${ee_subject_name}    ${pre-conn}=${NONE}
    ${server_object_name}=    Get From Dictionary    ${CMP_OBJECT}    ${server_type}
    ${dn}=    Create List     MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/${server_object_name}
    ...                       MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/${server_object_name}
    ...                       MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/${server_object_name}
    ...                       MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/${server_object_name}
    ...                       MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/${server_object_name}
    ${pn}=    Create List     caSubjectName    eeSubjectName    serverHost    serverPath    serverPort
    ${pv}=    Create List     ${ca_subject_name}    ${ee_subject_name}    ${ca_server_host}
    ...                       ${server_path}        ${ca_server_port}
    ${temp_conn}=             Run Keyword If    "${pre-conn}"=="${NONE}"    Connect to ADMIN    hw_type=vCU
    ...                       ELSE    Set Variable    ${pre-conn}
    Change Multiple Parameters on BTS    ${dn}    ${pn}    ${pv}    hw_type=vCU    pre-connection=${temp_conn}
    [Teardown]                Run Keyword If    "${pre-conn}"=="${NONE}"    Disconnect from ADMIN
    ...                                                                     connection=${temp_conn}    hw_type=vCU

_Configure CMP on vDU
    [Arguments]               ${ca_subject_name}    ${server_type}    ${ca_server_host}
    ...                       ${server_path}        ${ca_server_port}    ${ee_subject_name}    ${pre-conn}=${NONE}
    ${server_object_name}=    Get From Dictionary    ${CMP_OBJECT}    ${server_type}
    ${dn}=    Create List     MRBTS-${MRBTS}/MNL-1/CERTH-1/${server_object_name}
    ...                       MRBTS-${MRBTS}/MNL-1/CERTH-1/${server_object_name}
    ...                       MRBTS-${MRBTS}/MNL-1/CERTH-1/${server_object_name}
    ...                       MRBTS-${MRBTS}/MNL-1/CERTH-1/${server_object_name}
    ...                       MRBTS-${MRBTS}/MNL-1/CERTH-1/${server_object_name}
    ${pn}=    Create List     caSubjectName    eeSubjectName    serverHost    serverPath    serverPort
    ${pv}=    Create List     ${ca_subject_name}    ${ee_subject_name}    ${ca_server_host}
    ...                       ${server_path}        ${ca_server_port}
    ${temp_conn}=             Run Keyword If    "${pre-conn}"=="${NONE}"    Connect to ADMIN    hw_type=vDU
    ...                       ELSE    Set Variable    ${pre-conn}
    Change Multiple Parameters on BTS    ${dn}    ${pn}    ${pv}    hw_type=vDU    pre-connection=${temp_conn}
    [Teardown]                Run Keyword If    "${pre-conn}"=="${NONE}"    Disconnect from ADMIN
    ...                                                                     connection=${temp_conn}    hw_type=vDU

_Configure Secondary CMP on vCU
    [Arguments]               ${ca_subject_name}    ${server_type}    ${ca_server_host}
    ...                       ${server_path}        ${ca_server_port}    ${pre-conn}=${NONE}
    ${server_object_name}=    Get From Dictionary    ${CMP_OBJECT}    ${server_type}
    ${dn}=    Create List     MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/${server_object_name}
    ...                       MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/${server_object_name}
    ...                       MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/${server_object_name}
    ...                       MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/${server_object_name}
    ...                       MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/${server_object_name}
    ${pn}=    Create List     secondaryCaSubjectName    eeSubjectName    secondaryServerHost
    ...                       secondaryServerPath       secondaryServerPort
    ${pv}=    Create List     ${ca_subject_name}    CN=MRBTS-${MRBTS_CU}    ${ca_server_host}
    ...                       ${server_path}        ${ca_server_port}
    ${temp_conn}=             Run Keyword If    "${pre-conn}"=="${NONE}"    Connect to ADMIN    hw_type=vCU
    ...                       ELSE    Set Variable    ${pre-conn}
    Change Multiple Parameters on BTS    ${dn}    ${pn}    ${pv}    hw_type=vCU    pre-connection=${temp_conn}
    [Teardown]                Run Keyword If    "${pre-conn}"=="${NONE}"    Disconnect from ADMIN
    ...                                                                     connection=${temp_conn}    hw_type=vCU

_Configure Secondary CMP on vDU
    [Arguments]               ${ca_subject_name}    ${server_type}    ${ca_server_host}
    ...                       ${server_path}        ${ca_server_port}    ${pre-conn}=${NONE}
    ${server_object_name}=    Get From Dictionary    ${CMP_OBJECT}    ${server_type}
    ${dn}=    Create List     MRBTS-${MRBTS}/MNL-1/CERTH-1/${server_object_name}
    ...                       MRBTS-${MRBTS}/MNL-1/CERTH-1/${server_object_name}
    ...                       MRBTS-${MRBTS}/MNL-1/CERTH-1/${server_object_name}
    ...                       MRBTS-${MRBTS}/MNL-1/CERTH-1/${server_object_name}
    ...                       MRBTS-${MRBTS}/MNL-1/CERTH-1/${server_object_name}
    ${pn}=    Create List     secondaryCaSubjectName    eeSubjectName    secondaryServerHost
    ...                       secondaryServerPath       secondaryServerPort
    ${pv}=    Create List     ${ca_subject_name}    CN=MRBTS-${MRBTS}    ${ca_server_host}
    ...                       ${server_path}        ${ca_server_port}
    ${temp_conn}=             Run Keyword If    "${pre-conn}"=="${NONE}"    Connect to ADMIN    hw_type=vDU
    ...                       ELSE    Set Variable    ${pre-conn}
    Change Multiple Parameters on BTS    ${dn}    ${pn}    ${pv}    hw_type=vDU    pre-connection=${temp_conn}
    [Teardown]                Run Keyword If    "${pre-conn}"=="${NONE}"    Disconnect from ADMIN
    ...                                                                     connection=${temp_conn}    hw_type=vDU

_Configure Both CMP on vCU
    [Arguments]               ${primary_ca_subject_name}    ${secondary_ca_subject_name}    ${server_type}
    ...                       ${primary_ca_server_host}     ${secondary_ca_server_host}
    ...                       ${primary_server_path}        ${secondary_server_path}
    ...                       ${primary_ca_server_port}     ${secondary_ca_server_port}    ${pre-conn}=${NONE}
    ${server_object_name}=    Get From Dictionary    ${CMP_OBJECT}    ${server_type}
    ${dn}=    Create List     MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/${server_object_name}
    ...                       MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/${server_object_name}
    ...                       MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/${server_object_name}
    ...                       MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/${server_object_name}
    ...                       MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/${server_object_name}
    ...                       MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/${server_object_name}
    ...                       MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/${server_object_name}
    ...                       MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/${server_object_name}
    ...                       MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/${server_object_name}
    ${pn}=    Create List     caSubjectName    serverHost    serverPath    serverPort    secondaryCaSubjectName
    ...                       eeSubjectName    secondaryServerHost    secondaryServerPath    secondaryServerPort
    ${pv}=    Create List     ${primary_ca_subject_name}     ${primary_ca_server_host}       ${primary_server_path}
    ...                       ${primary_ca_server_port}      ${secondary_ca_subject_name}    CN=MRBTS-${MRBTS_CU}
    ...                       ${secondary_ca_server_host}    ${secondary_server_path}        ${secondary_ca_server_port}
    ${temp_conn}=             Run Keyword If    "${pre-conn}"=="${NONE}"    Connect to ADMIN    hw_type=vCU
    ...                       ELSE    Set Variable    ${pre-conn}
    Change Multiple Parameters on BTS    ${dn}    ${pn}    ${pv}    hw_type=vCU    pre-connection=${temp_conn}
    [Teardown]                Run Keyword If    "${pre-conn}"=="${NONE}"    Disconnect from ADMIN
    ...                                                                     connection=${temp_conn}    hw_type=vCU

_Configure Both CMP on vDU
    [Arguments]               ${primary_ca_subject_name}    ${secondary_ca_subject_name}    ${server_type}
    ...                       ${primary_ca_server_host}     ${secondary_ca_server_host}
    ...                       ${primary_server_path}        ${secondary_server_path}
    ...                       ${primary_ca_server_port}     ${secondary_ca_server_port}    ${pre-conn}=${NONE}
    ${server_object_name}=    Get From Dictionary    ${CMP_OBJECT}    ${server_type}
    ${dn}=    Create List     MRBTS-${MRBTS}/MNL-1/CERTH-1/${server_object_name}
    ...                       MRBTS-${MRBTS}/MNL-1/CERTH-1/${server_object_name}
    ...                       MRBTS-${MRBTS}/MNL-1/CERTH-1/${server_object_name}
    ...                       MRBTS-${MRBTS}/MNL-1/CERTH-1/${server_object_name}
    ...                       MRBTS-${MRBTS}/MNL-1/CERTH-1/${server_object_name}
    ...                       MRBTS-${MRBTS}/MNL-1/CERTH-1/${server_object_name}
    ...                       MRBTS-${MRBTS}/MNL-1/CERTH-1/${server_object_name}
    ...                       MRBTS-${MRBTS}/MNL-1/CERTH-1/${server_object_name}
    ...                       MRBTS-${MRBTS}/MNL-1/CERTH-1/${server_object_name}
    ${pn}=    Create List     caSubjectName    serverHost    serverPath    serverPort    secondaryCaSubjectName
    ...                       eeSubjectName    secondaryServerHost    secondaryServerPath    secondaryServerPort
    ${pv}=    Create List     ${primary_ca_subject_name}     ${primary_ca_server_host}       ${primary_server_path}
    ...                       ${primary_ca_server_port}      ${secondary_ca_subject_name}    CN=MRBTS-${MRBTS}
    ...                       ${secondary_ca_server_host}    ${secondary_server_path}        ${secondary_ca_server_port}
    ${temp_conn}=             Run Keyword If    "${pre-conn}"=="${NONE}"    Connect to ADMIN    hw_type=vDU
    ...                       ELSE    Set Variable    ${pre-conn}
    Change Multiple Parameters on BTS    ${dn}    ${pn}    ${pv}    hw_type=vDU    pre-connection=${temp_conn}
    [Teardown]                Run Keyword If    "${pre-conn}"=="${NONE}"    Disconnect from ADMIN
    ...                                                                     connection=${temp_conn}    hw_type=vDU

_Delete Secondary CMP on vCU
    [Arguments]               ${server_type}    ${pre-conn}=${NONE}
    ${server_object_name}=    Get From Dictionary    ${CMP_OBJECT}    ${server_type}
    ${dn}=    Create List     MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/${server_object_name}
    ...                       MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/${server_object_name}
    ...                       MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/${server_object_name}
    ...                       MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/${server_object_name}
    ${pn}=    Create List     secondaryCaSubjectName    secondaryServerHost
    ...                       secondaryServerPath       secondaryServerPort
    ${temp_conn}=             Run Keyword If    "${pre-conn}"=="${NONE}"    Connect to ADMIN    hw_type=vCU
    ...                       ELSE    Set Variable    ${pre-conn}
    Delete Multiple Parameters on BTS    ${dn}    ${pn}    hw_type=vCU    pre-connection=${temp_conn}
    [Teardown]                Run Keyword If    "${pre-conn}"=="${NONE}"    Disconnect from ADMIN
    ...                                                                     connection=${temp_conn}    hw_type=vCU

_Delete Secondary CMP on vDU
    [Arguments]               ${server_type}    ${pre-conn}=${NONE}
    ${server_object_name}=    Get From Dictionary    ${CMP_OBJECT}    ${server_type}
    ${dn}=    Create List     MRBTS-${MRBTS}/MNL-1/CERTH-1/${server_object_name}
    ...                       MRBTS-${MRBTS}/MNL-1/CERTH-1/${server_object_name}
    ...                       MRBTS-${MRBTS}/MNL-1/CERTH-1/${server_object_name}
    ...                       MRBTS-${MRBTS}/MNL-1/CERTH-1/${server_object_name}
    ${pn}=    Create List     secondaryCaSubjectName    secondaryServerHost
    ...                       secondaryServerPath       secondaryServerPort
    ${temp_conn}=             Run Keyword If    "${pre-conn}"=="${NONE}"    Connect to ADMIN    hw_type=vDU
    ...                       ELSE    Set Variable    ${pre-conn}
    Delete Multiple Parameters on BTS    ${dn}    ${pn}    hw_type=vDU    pre-connection=${temp_conn}
    [Teardown]                Run Keyword If    "${pre-conn}"=="${NONE}"    Disconnect from ADMIN
    ...                                                                     connection=${temp_conn}    hw_type=vDU

_Restore vDU Default Certificates
    [Arguments]        ${timeout}=60    ${pre-conn}=${NONE}
    ${temp_conn}=      Run Keyword If    "${pre-conn}"=="${NONE}"    Connect to ADMIN    hw_type=vDU
    ...                ELSE    Set Variable    ${pre-conn}
    ${operationID}=    vdu_admin.restore_default_certificates    timeout=${timeout}    vdu_connection=${temp_conn}
    ${status}=         Wait Until Keyword Succeeds    3min    2s    _Check vDU CMP Operation Should Be Expected
    ...                operationID=${operationID}   expected_status=Successful    connection=${temp_conn}
    [Teardown]         Run Keyword If    "${pre-conn}"=="${NONE}"    Disconnect from ADMIN
    ...                                                              connection=${temp_conn}    hw_type=vDU

_Restore vCU Default Certificates
    [Arguments]        ${timeout}=60    ${pre-conn}=${NONE}
    ${temp_conn}=      Run Keyword If    "${pre-conn}"=="${NONE}"    Connect to ADMIN    hw_type=vCU
    ...                ELSE    Set Variable    ${pre-conn}
    ${output}=         vcu_admin.delete_all_operator_certificates    timeout=${timeout}    connection=${temp_conn}
    Should Be True    "${output["status"]}"=="Successful"
    [Teardown]         Run Keyword If    "${pre-conn}"=="${NONE}"    Disconnect from ADMIN
    ...                                                              connection=${temp_conn}    hw_type=vCU

_Check vCU Certificates
    [Arguments]      ${pre-conn}=${NONE}
    ${temp_conn}=    Run Keyword If    "${pre-conn}"=="${NONE}"    Connect to ADMIN    hw_type=vCU
    ...              ELSE    Set Variable    ${pre-conn}
    ${cert_list}=    vcu_admin.get_operator_certificate_list    connection=${temp_conn}
    [Return]         ${cert_list}
    [Teardown]       Run Keyword If    "${pre-conn}"=="${NONE}"    Disconnect from ADMIN
    ...                                                            connection=${temp_conn}    hw_type=vCU

_Check vDU Certificates
    [Arguments]      ${pre-conn}=${NONE}
    ${temp_conn}=    Run Keyword If    "${pre-conn}"=="${NONE}"    Connect to ADMIN    hw_type=vDU
    ...              ELSE    Set Variable    ${pre-conn}
    ${cert_list}=    vdu_admin.get_vdu_certificates    vdu_connection=${temp_conn}
    [Return]         ${cert_list}
    [Teardown]       Run Keyword If    "${pre-conn}"=="${NONE}"    Disconnect from ADMIN
    ...                                                            connection=${temp_conn}    hw_type=vDU

_Check if last CRL Update was correct on vDU
    [Arguments]        ${pre-conn}=${NONE}
    ${temp_conn}=      Run Keyword If    "${pre-conn}"=="${NONE}"    Connect to ADMIN    hw_type=vDU
    ...                ELSE    Set Variable    ${pre-conn}
    ${value}=          Check Parameter Value    param_name=state
    ...                dist_name=MRBTS-${MRBTS}/MNL-1/MNLENT-1/CERTHENT-1/CRLH_R-1
    ...                hw_type=vDU    pre-connection=${temp_conn}
    Should be True    "${value}"=="CRL_LastUpdateOK"
    [Teardown]         Run Keyword If    "${pre-conn}"=="${NONE}"    Disconnect from ADMIN
    ...                                                              connection=${temp_conn}    hw_type=vDU

_Check if last CRL Update was correct on vCU
    [Arguments]        ${pre-conn}=${NONE}
    ${temp_conn}=      Run Keyword If    "${pre-conn}"=="${NONE}"    Connect to ADMIN    hw_type=vCU
    ...                ELSE    Set Variable    ${pre-conn}
    ${values}=         vcu_admin.get_parameters
    ...                dist_name=MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1/CERTHENT-1/CRLH_R-1
    ...                connection=${temp_conn}
    ${all_params}=     Set Variable    ${values['parameters']}
    ${length}=         Get Length    ${all_params}
    FOR    ${param}    IN RANGE    ${length}
        ${item}=       Get From List    ${all_params}    ${param}
        ${item}=       Get From Dictionary    ${item}    simple_parameter
        ${state}=      Set Variable    'name': 'state'
        ${status}=     Run Keyword and Return Status    Should Contain    "${item}"    ${state}
        Run Keyword If    ${status}    Should Contain    "${item}"    CRL_LastUpdateOK
    END
    [Teardown]         Run Keyword If    "${pre-conn}"=="${NONE}"    Disconnect from ADMIN
    ...                                                              connection=${temp_conn}    hw_type=vCU

_Check if last CRL Update was incorrect on vDU
    [Arguments]        ${pre-conn}=${NONE}
    ${temp_conn}=      Run Keyword If    "${pre-conn}"=="${NONE}"    Connect to ADMIN    hw_type=vDU
    ...                ELSE    Set Variable    ${pre-conn}
    ${value}=          Check Parameter Value    param_name=state
    ...                dist_name=MRBTS-${MRBTS}/MNL-1/MNLENT-1/CERTHENT-1/CRLH_R-1
    ...                hw_type=vDU    pre-connection=${temp_conn}
    Should be True    "${value}"=="CRL_LastUpdateFailed"
    [Teardown]         Run Keyword If    "${pre-conn}"=="${NONE}"    Disconnect from ADMIN
    ...                                                              connection=${temp_conn}    hw_type=vDU

_Check if last CRL Update was incorrect on vCU
    [Arguments]        ${pre-conn}=${NONE}
    ${temp_conn}=      Run Keyword If    "${pre-conn}"=="${NONE}"    Connect to ADMIN    hw_type=vCU
    ...                ELSE    Set Variable    ${pre-conn}
    ${values}=         vcu_admin.get_parameters
    ...                dist_name=MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1/CERTHENT-1/CRLH_R-1
    ...                connection=${temp_conn}
    ${all_params}=     Set Variable    ${values['parameters']}
    ${length}=         Get Length    ${all_params}
    FOR    ${param}    IN RANGE    ${length}
        ${item}=       Get From List    ${all_params}    ${param}
        ${item}=       Get From Dictionary    ${item}    simple_parameter
        ${state}=      Set Variable    'name': 'state'
        ${status}=     Run Keyword and Return Status    Should Contain    "${item}"    ${state}
        Run Keyword If    ${status}    Should Contain    "${item}"    CRL_LastUpdateFailed
    END
    [Teardown]         Run Keyword If    "${pre-conn}"=="${NONE}"    Disconnect from ADMIN
    ...                                                              connection=${temp_conn}    hw_type=vCU

_Install Certificate on vCU
    [Arguments]       ${cert_path}    ${cert_type}    ${pre-conn}=${NONE}
    ${temp_conn}=     Run Keyword If    "${pre-conn}"=="${NONE}"    Connect to ADMIN    hw_type=vCU
    ...               ELSE    Set Variable    ${pre-conn}
    ${output}=        vcu_admin.install_operators_certificate    certificate_file_path=${cert_path}
    ...               certificate_type=${cert_type}    connection=${temp_conn}
    Should Be True    "${output["status"]}"=="Successful"
    [Teardown]        Run Keyword If    "${pre-conn}"=="${NONE}"    Disconnect from ADMIN
    ...                                                             connection=${temp_conn}    hw_type=vCU

_Install Certificate on vDU
    [Arguments]       ${cert_path}    ${cert_type}    ${cert_encoding}    ${pre-conn}=${NONE}
    ${temp_conn}=     Run Keyword If    "${pre-conn}"=="${NONE}"    Connect to ADMIN    hw_type=vDU
    ...               ELSE    Set Variable    ${pre-conn}
    ${oper_id}=       vdu_admin.install_vdu_certificates    cert_file_path=${cert_path}
    ...               cert_type=${cert_type}    cert_file_encoding=${cert_encoding}    vdu_connection=${temp_conn}
    Wait Until Keyword Succeeds    3min    2s    _Check if Certificate has been installed on vDU
    ...                                          oper_id=${oper_id}    conn=${temp_conn}
    [Teardown]        Run Keyword If    "${pre-conn}"=="${NONE}"    Disconnect from ADMIN
    ...                                                             connection=${temp_conn}    hw_type=vDU

_Check if Certificate has been installed on vDU
    [Arguments]       ${oper_id}    ${conn}
    ${output}=        vdu_admin.get_trs_api_operation_status    operation_id=${oper_id}    vdu_connection=${conn}
    Should Be True    "${output["status"]}"=="Successful"

_Delete Certificate on vCU
    [Arguments]       ${cert_id}    ${pre-conn}=${NONE}
    ${temp_conn}=     Run Keyword If    "${pre-conn}"=="${NONE}"    Connect to ADMIN    hw_type=vCU
    ...               ELSE    Set Variable    ${pre-conn}
    ${output}=        vcu_admin.delete_operator_certificate    certificate_id=${cert_id}    connection=${temp_conn}
    Should Be True    "${output["status"]}"=="Successful"
    [Teardown]        Run Keyword If    "${pre-conn}"=="${NONE}"    Disconnect from ADMIN
    ...                                                             connection=${temp_conn}    hw_type=vCU

_Delete Certificate on vDU
    [Arguments]       ${cert_id}    ${pre-conn}=${NONE}
    ${temp_conn}=     Run Keyword If    "${pre-conn}"=="${NONE}"    Connect to ADMIN    hw_type=vDU
    ...               ELSE    Set Variable    ${pre-conn}
    ${oper_id}=       vdu_admin.delete_certificates_by_id    id=${cert_id}    vdu_connection=${temp_conn}
    Wait Until Keyword Succeeds    3min    2s    _Check if Certificate has been installed on vDU
    ...                                          oper_id=${oper_id}    conn=${temp_conn}
    [Teardown]        Run Keyword If    "${pre-conn}"=="${NONE}"    Disconnect from ADMIN
    ...                                                             connection=${temp_conn}    hw_type=vDU

_Check if CRL Update has started on vDU
    [Arguments]        ${pre-conn}=${NONE}
    ${temp_conn}=      Run Keyword If    "${pre-conn}"=="${NONE}"    Connect to ADMIN    hw_type=vDU
    ...                ELSE    Set Variable    ${pre-conn}
    ${value}=          Check Parameter Value    param_name=state
    ...                dist_name=MRBTS-${MRBTS}/MNL-1/MNLENT-1/CERTHENT-1/CRLH_R-1
    ...                hw_type=vDU    pre-connection=${temp_conn}
    Should be True    "${value}"=="CRL_UpdateRequested"
    [Teardown]         Run Keyword If    "${pre-conn}"=="${NONE}"    Disconnect from ADMIN
    ...                                                              connection=${temp_conn}    hw_type=vDU

_Check if CRL Update has started on vCU
    [Arguments]        ${pre-conn}=${NONE}
    ${temp_conn}=      Run Keyword If    "${pre-conn}"=="${NONE}"    Connect to ADMIN    hw_type=vCU
    ...                ELSE    Set Variable    ${pre-conn}
    ${values}=         vcu_admin.get_parameters
    ...                dist_name=MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1/CERTHENT-1/CRLH_R-1    connection=${temp_conn}
    ${all_params}=     Set Variable    ${values['parameters']}
    ${length}=         Get Length    ${all_params}
    FOR    ${param}    IN RANGE    ${length}
        ${item}=       Get From List    ${all_params}    ${param}
        ${item}=       Get From Dictionary    ${item}    simple_parameter
        ${state}=      Set Variable    'name': 'state'
        ${status}=     Run Keyword and Return Status    Should Contain    "${item}"    ${state}
        Run Keyword If    ${status}    Should Contain    "${item}"    CRL_UpdateRequested
    END
    [Teardown]         Run Keyword If    "${pre-conn}"=="${NONE}"    Disconnect from ADMIN
    ...                                                              connection=${temp_conn}    hw_type=vCU

_Check if CRL Update is ongoing on vDU
    [Arguments]        ${pre-conn}=${NONE}
    ${temp_conn}=      Run Keyword If    "${pre-conn}"=="${NONE}"    Connect to ADMIN    hw_type=vDU
    ...                ELSE    Set Variable    ${pre-conn}
    ${value}=          Check Parameter Value    param_name=state
    ...                dist_name=MRBTS-${MRBTS}/MNL-1/MNLENT-1/CERTHENT-1/CRLH_R-1
    ...                hw_type=vDU    pre-connection=${temp_conn}
    Should be True    "${value}"=="CRL_UpdateOngoing"
    [Teardown]         Run Keyword If    "${pre-conn}"=="${NONE}"    Disconnect from ADMIN
    ...                                                              connection=${temp_conn}    hw_type=vDU

_Check if CRL Update is ongoing on vCU
    [Arguments]        ${pre-conn}=${NONE}
    ${temp_conn}=      Run Keyword If    "${pre-conn}"=="${NONE}"    Connect to ADMIN    hw_type=vCU
    ...                ELSE    Set Variable    ${pre-conn}
    ${values}=         vcu_admin.get_parameters
    ...                dist_name=MRBTS-${MRBTS_CU}/MNL-1/MNLENT-1/CERTHENT-1/CRLH_R-1    connection=${temp_conn}
    ${all_params}=     Set Variable    ${values['parameters']}
    ${length}=         Get Length    ${all_params}
    FOR    ${param}    IN RANGE    ${length}
        ${item}=       Get From List    ${all_params}    ${param}
        ${item}=       Get From Dictionary    ${item}    simple_parameter
        ${state}=      Set Variable    'name': 'state'
        ${status}=     Run Keyword and Return Status    Should Contain    "${item}"    ${state}
        Run Keyword If    ${status}    Should Contain    "${item}"    CRL_UpdateOngoing
    END
    [Teardown]         Run Keyword If    "${pre-conn}"=="${NONE}"    Disconnect from ADMIN
    ...                                                              connection=${temp_conn}    hw_type=vCU

_Create Mutliple CRLDP Objects with Only PrimaryCRLDP on vCU
    [Arguments]           ${start}    ${stop}    ${primary_values}
    FOR    ${nr}    IN RANGE    ${start}    ${stop}
        ${nr_int}=        Convert to Integer    ${nr}
        ${start_int}=     Convert to Integer    ${start}
        ${values_nr}=     Evaluate    $nr_int - $start_int
        ${pValue}=        Get From List    ${primary_values}    ${values_nr}
        Create Object with Single Parameter on BTS    MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-${nr}
        ...                                           primaryCRLDP    ${pValue}    hw_type=vCU
    END

_Create Mutliple CRLDP Objects with Only PrimaryCRLDP on vDU
    [Arguments]           ${start}    ${stop}    ${primary_values}
    FOR    ${nr}    IN RANGE    ${start}    ${stop}
        ${nr_int}=        Convert to Integer    ${nr}
        ${start_int}=     Convert to Integer    ${start}
        ${values_nr}=     Evaluate    $nr_int - $start_int
        ${pValue}=        Get From List    ${primary_values}    ${values_nr}
        Create Object with Single Parameter on BTS    MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-${nr}
        ...                                           primaryCRLDP    ${pValue}    hw_type=vDU
    END

_Create Mutliple CRLDP Objects with PrimaryCRLDP and SecondaryCRLDP on vCU
    [Arguments]           ${start}    ${stop}    ${primary_values}    ${secondary_values}
    FOR    ${nr}    IN RANGE    ${start}    ${stop}
        ${nr_int}=        Convert to Integer    ${nr}
        ${start_int}=     Convert to Integer    ${start}
        ${values_nr}=     Evaluate    $nr_int - $start_int
        ${pValue}=        Get From List    ${primary_values}      ${values_nr}
        ${sValue}=        Get From List    ${secondary_values}    ${values_nr}
        ${pn}=            Create List      primaryCRLDP    secondaryCRLDP
        ${pv}=            Create List      ${pValue}    ${sValue}
        Create Object with Multiple Parameters on BTS    MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-${nr}
        ...                                              ${pn}    ${pv}    hw_type=vCU
    END

_Create Mutliple CRLDP Objects with PrimaryCRLDP and SecondaryCRLDP on vDU
    [Arguments]           ${start}    ${stop}    ${primary_values}    ${secondary_values}
    FOR    ${nr}    IN RANGE    ${start}    ${stop}
        ${nr_int}=        Convert to Integer    ${nr}
        ${start_int}=     Convert to Integer    ${start}
        ${values_nr}=     Evaluate    $nr_int - $start_int
        ${pValue}=        Get From List    ${primary_values}      ${values_nr}
        ${sValue}=        Get From List    ${secondary_values}    ${values_nr}
        ${pn}=            Create List      primaryCRLDP    secondaryCRLDP
        ${pv}=            Create List      ${pValue}    ${sValue}
        Create Object with Multiple Parameters on BTS    MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-${nr}
        ...                                              ${pn}    ${pv}    hw_type=vDU
    END

_Delete Mutliple CRLDP Objects on vCU
    [Arguments]     ${start}    ${stop}
    FOR    ${nr}    IN RANGE    ${start}    ${stop}
        Delete Object on BTS    dist_name=MRBTS-${MRBTS_CU}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-${nr}    hw_type=vCU
    END

_Delete Mutliple CRLDP Objects on vDU
    [Arguments]     ${start}    ${stop}
    FOR    ${nr}    IN RANGE    ${start}    ${stop}
        Delete Object on BTS    dist_name=MRBTS-${MRBTS}/MNL-1/CERTH-1/CRLH-1/CRLDPCONFIG-${nr}    hw_type=vDU
    END

_Generate CSR on vCU
    [Arguments]        ${key_pool_type}    ${pre-conn}=${NONE}
    ${temp_conn}=      Run Keyword If    "${pre-conn}"=="${NONE}"    Connect to ADMIN    hw_type=vCU
    ...                ELSE    Set Variable    ${pre-conn}
    ${output}=         vcu_admin.generate_csr_for_ne    timeout=30    connection=${temp_conn}
    ...                                                 key_pool_type=${key_pool_type}
    Should Be True    "${output["status"]}"=="Successful"
    vcu_admin.get_csr_file    path=${OUTPUT_DIR}/csr.txt   connection=${temp_conn}    key_pool_type=${key_pool_type}
    ${csr}=            OperatingSystem.Get File    ${OUTPUT_DIR}/csr.txt
    [Return]           ${csr}
    [Teardown]         Run Keywords    Run Keyword If    "${pre-conn}"=="${NONE}"    Disconnect from ADMIN
    ...                                connection=${temp_conn}    hw_type=vCU
    ...    AND         Remove File     ${OUTPUT_DIR}/csr.txt

_Generate CSR on vDU
    [Arguments]        ${key_pool_type}    ${pre-conn}=${NONE}
    ${temp_conn}=      Run Keyword If    "${pre-conn}"=="${NONE}"    Connect to ADMIN    hw_type=vDU
    ...                ELSE    Set Variable    ${pre-conn}
    ${id}=             vdu_admin.generate_vdu_csr    timeout=30    vdu_connection=${temp_conn}
    ...                                              key_pool_type=${key_pool_type}
    Wait Until Keyword Succeeds    3min    2s    _Check vDU CMP Operation Should Be Expected
    ...                operationID=${id}    expected_status=Successful    connection=${temp_conn}
    ${csr}=            vdu_admin.get_vdu_csr    timeout=30    vdu_connection=${temp_conn}
    ...                                         key_pool_type=${key_pool_type}
    [Return]           ${csr}
    [Teardown]         Run Keyword If    "${pre-conn}"=="${NONE}"    Disconnect from ADMIN
    ...                                                              connection=${temp_conn}    hw_type=vDU

_Update CMP Key on vCU
    [Arguments]        ${key_pool_type}    ${pre-conn}=${NONE}
    ${temp_conn}=      Run Keyword If    "${pre-conn}"=="${NONE}"    Connect to ADMIN    hw_type=vCU
    ...                ELSE    Set Variable    ${pre-conn}
    ${output}=         vcu_admin.trigger_cmp_server_key_update    timeout=30    connection=${temp_conn}
    ...                                                           key_pool_type=${key_pool_type}
    Should Be True    "${output["status"]}"=="Successful"
    [Teardown]         Run Keyword If    "${pre-conn}"=="${NONE}"    Disconnect from ADMIN
    ...                                                              connection=${temp_conn}    hw_type=vCU

_Update CMP Key on vDU
    [Arguments]        ${key_pool_type}    ${pre-conn}=${NONE}
    ${temp_conn}=      Run Keyword If    "${pre-conn}"=="${NONE}"    Connect to ADMIN    hw_type=vDU
    ...                ELSE    Set Variable    ${pre-conn}
    ${id}=             vdu_admin.update_cmp_server_key    timeout=30    vdu_connection=${temp_conn}
    ...                                                   key_pool_type=${key_pool_type}
    Wait Until Keyword Succeeds    3min    2s    _Check vDU CMP Operation Should Be Expected
    ...                operationID=${id}    expected_status=Successful    connection=${temp_conn}
    [Teardown]         Run Keyword If    "${pre-conn}"=="${NONE}"    Disconnect from ADMIN
    ...                                                              connection=${temp_conn}    hw_type=vDU

_Try to Update CMP Key on vCU
    [Arguments]        ${expected_error}    ${key_pool_type}    ${pre-conn}=${NONE}
    ${temp_conn}=      Run Keyword If    "${pre-conn}"=="${NONE}"    Connect to ADMIN    hw_type=vCU
    ...                ELSE    Set Variable    ${pre-conn}
    ${output}=         vcu_admin.trigger_cmp_server_key_update    timeout=30    connection=${temp_conn}
    ...                                                           key_pool_type=${key_pool_type}
    Should Be True    "${output["status"]}"=="Failed"
    Should Be True    "${output["reason"]}"=="${expected_error}"
    [Teardown]         Run Keyword If    "${pre-conn}"=="${NONE}"    Disconnect from ADMIN
    ...                                                              connection=${temp_conn}    hw_type=vCU

_Try to Update CMP Key on vDU
    [Arguments]        ${expected_error}    ${key_pool_type}    ${pre-conn}=${NONE}
    ${temp_conn}=      Run Keyword If    "${pre-conn}"=="${NONE}"    Connect to ADMIN    hw_type=vDU
    ...                ELSE    Set Variable    ${pre-conn}
    ${id}=             vdu_admin.update_cmp_server_key    timeout=30    vdu_connection=${temp_conn}
    ...                                                   key_pool_type=${key_pool_type}
    Wait Until Keyword Succeeds    3min    2s    _Check vDU CMP Operation Should Fail with Expected Reason
    ...                operationID=${id}    expected_reason=${expected_error}    connection=${temp_conn}
    [Teardown]         Run Keyword If    "${pre-conn}"=="${NONE}"    Disconnect from ADMIN
    ...                                                              connection=${temp_conn}    hw_type=vDU
