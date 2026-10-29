*** Settings ***
Documentation   Keywords including emssim connection on VM.
...             Author:     Jagoda Kubacka
...             Contact:    jagoda.kubacka@nokia.com

Library     OperatingSystem
Library     ./emssim_operation.py
Library     taf.gnb.oam.coam.cu     WITH NAME    vcu_admin
Library     taf.gnb.oam.coam.vdu    WITH NAME    vdu_admin
Resource    taf/rfrl/cbts/utilities/init_variables.robot
Resource    ../../../cloud_common_resources/connections/connections.robot
Resource    ./emssim_variables.robot

*** Keywords ***
Connect and Activate EMSSIM
    [Documentation]    Description:    Connect via EMSSIM to BTS. This KW find the address of VM and then
    ...                                integrate and connect EMSSIM with BTS. If the TLS is enabled,
    ...                                check if connection is in secured state what means secured connection.
    ...                                enable_tls - connecting with or without TLS (default is with TLS)
    ...                                hw_type =  vCU/vDU
    ...                Output:         None (the KW only succeeds/fails)
    ...                Author:         jagoda.kubacka@nokia.com
    [Arguments]      ${enable_tls}=1    ${hw_type}=${NONE}    ${cert_type}=RSA
    ${cert}    Set Variable If    '${cert_type}'=='RSA'    ${cert_RSA}    ${cert_ECDSA}
    ${key}    Set Variable If    '${cert_type}'=='RSA'     ${key_RSA}     ${key_ECDSA}
    ${cacert}    Set Variable If    '${cert_type}'=='RSA'     ${cacert_RSA}     ${cacert_ECDSA}
    ${VM_address}=    Run               ip addr | grep "scope global eth0"
    ${VM_address}=    Get Regexp Matches    ${VM_address}    \\d{1,3}[.]\\d{1,3}[.]\\d{1,3}[.]\\d{1,3}
    Log                                 Connecting with EMSSIM    console=true
    ${MRBTS}=         Set Variable If    '${hw_type}'=='vCU'    ${MRBTS_CU}      ${MRBTS}
    ${emssim_connection}                emssim_operation.Integrate EMSSIM with BTS
    ...                                 bts_id=${MRBTS}
    ...                                 host=${VM_address}[0]
    ...                                 user=flexi${MRBTS}
    ...                                 cert_type=${cert_type}
    ...                                 cert=${cert}
    ...                                 key=${key}
    ...                                 cacert=${cacert}
    ...                                 tls=${enable_tls}
    Run Keyword If  ${enable_tls} == 1
    ...      Wait until keyword succeeds    5min    30s    Wait Until NMS in Secured Status    ${hw_type}
    Log      EMSSIM connection established    console=true
    [Return]                            ${emssim_connection}

Disconnect From EMSSIM
    [Documentation]    Description:    Close connection between EMSSIM and BTS (close session with EMSSIM).
    ...                Output:         None (the KW only succeeds/fails)
    ...                Author:         jagoda.kubacka@nokia.com
    [Arguments]                         ${connection}
    ${MRBTS}=          Set Variable If    '${hw_type}'=='vCU'    ${MRBTS_CU}      ${MRBTS}
    Close Connection With EMSSIM        bts_id=${MRBTS}
    ...                                 connection=${connection}

Wait Until NMS in Secured Status
    [Documentation]    Description:    Checking if connection with EMSSIM is in secured state.
    ...                Output:         None (the KW only succeeds/fails)
    ...                Author:         jagoda.kubacka@nokia.com
    [Arguments]        ${hw_type}=${NONE}
    ${connection}=     Connect to ADMIN    hw_type=${hw_type}
    ${status}=         Run Keyword If    '${hw_type}'=='vCU'    vcu_admin.get_nms
    ...                connection=${connection}
    ...                ELSE IF    '${hw_type}'=='vDU'    vdu_admin.get_nms
    ...                vdu_connection=${connection}
    ${downlink}=       Get Dictionary Values    ${status}
    Should Be Equal    ${downlink}[0]    Succeeded
    Should Be Equal    ${downlink}[1]    Succeeded
    [Return]           ${status}
    [Teardown]         Run Keyword and Ignore Error    Disconnect from ADMIN    connection=${connection}    hw_type=${hw_type}
