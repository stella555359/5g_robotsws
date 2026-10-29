*** Settings ***
Documentation    Cloud setup/teardown DCAP keywords.
...              Authors:    Patryk Tatarek
...              Contact:    patryk.tatarek@nokia.com
...
...              How to use it:
...              Test Setup
...                  ${dcap_trace_id}=     DCAP Test Setup    hw_type=vCU/vDU
...                  Set Suite Variable    ${dcap_trace_id}
...
...              Test Teardown
...                  DCAP Test Teardown    trace_id=${dcap_trace_id}    hw_type=vCU/vDU
...
...              If your test name ends with its hw_type, you can use this as the first keyword in Test Setup/Teardown:
...              ${hw_type}=    Get Substring    ${TEST_NAME}    -3

Resource         ../../../cloud_common_resources/logs/dcap.robot

*** Variables ***

${wro3_t4_ip}=           10.42.158.188
${wro3_t4_port}=         443
${wro3_t4_username}=     utfuser
${wro3_t4_password}=     utfadmin!
${default_alias}=        dcap_collector

*** Keywords ***

#################################################### Main  Keywords ####################################################

DCAP Test Setup
    [Documentation]    Description:    Create DCAP connection and start gathering logs.
    ...                                Use it as Test Setup
    ...                Input:          hw_type = vCU/vDU
    ...                Output:         Started trace id
    ...                Author:         patryk.tatarek@nokia.com
    [Arguments]        ${hw_type}=${NONE}
    ${trace_id}=       Run Keyword If    '${hw_type}'=='vCU'    _DCAP Test Setup for vCU
    ...                ELSE IF           '${hw_type}'=='vDU'    _DCAP Test Setup for vDU
    ...                ELSE               FAIL                  hw_type doesn't exist
    [Return]           ${trace_id}

DCAP Test Teardown
    [Documentation]       Description:    Stop gathering and download logs, teardown DCAP connection.
    ...                                   Use it as Test Teardown
    ...                   Input:          hw_type = vCU/vDU
    ...                                   trace_id = output from "DCAP Test Setup" keyword
    ...                   Output:         Path to the DCAP log file
    ...                   Author:         patryk.tatarek@nokia.com
    [Arguments]           ${trace_id}    ${hw_type}=${NONE}
    ${dcap_file_path}=    Run Keyword If    '${hw_type}'=='vCU'    _DCAP Test Teardown for vCU    trace_id=${trace_id}
    ...                   ELSE IF           '${hw_type}'=='vDU'    _DCAP Test Teardown for vDU    trace_id=${trace_id}
    ...                   ELSE               FAIL                  hw_type doesn't exist
    [Return]              ${dcap_file_path}

################################################ Supplementary Keywords ################################################

_DCAP Test Setup for vCU
    Create DCAP Connection    host_ip=${wro3_t4_ip}    port=${wro3_t4_port}    username=${wro3_t4_username}
    ...                       password=${wro3_t4_password}    alias=${default_alias}    hw_type=vCU
    ${trace_id}=              Start Gathering DCAP Logs Using Trace Profile
    ...                       log_profile=immediateSnapshot
    ...                       alias=${default_alias}
    ...                       hw_type=vCU
    [Return]                  ${trace_id}

_DCAP Test Setup for vDU
    Create DCAP Connection    host_ip=${wro3_t4_ip}    port=${wro3_t4_port}    username=${wro3_t4_username}
    ...                       password=${wro3_t4_password}    alias=${default_alias}    hw_type=vDU
    ${trace_id}=              Start Gathering DCAP Logs Using Trace Profile
    ...                       log_profile=immediateSnapshot
    ...                       alias=${default_alias}
    ...                       hw_type=vDU
    [Return]                  ${trace_id}

_DCAP Test Teardown for vCU
    [Arguments]      ${trace_id}
    Stop Gathering DCAP Logs    trace_id=${trace_id}    alias=${default_alias}    hw_type=vCU
    ${dcap_file}=    Download DCAP Logs    trace_id=${trace_id}    alias=${default_alias}    hw_type=vCU
    [Return]         ${dcap_file}
    [Teardown]       Close DCAP Connection

_DCAP Test Teardown for vDU
    [Arguments]      ${trace_id}
    Stop Gathering DCAP Logs    trace_id=${trace_id}    alias=${default_alias}    hw_type=vDU
    ${dcap_file}=    Download DCAP Logs    trace_id=${trace_id}    alias=${default_alias}    hw_type=vDU
    [Return]         ${dcap_file}
    [Teardown]       Close DCAP Connection
