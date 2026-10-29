*** Settings ***
Documentation    Author: Ding Binmei
...    Operations to TPS 1830
Library     taf.transport.ssh    WITH NAME    csn
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/lib/string_list.py

*** Variables ***
${TPS_IP}    10.57.232.20
${TPS_USERNAME}    admin
${TPS_PASSWORD}    Admin@1830


*** Keywords ***
__for_filter
    Connect to TPS
    Disconnect to TPS
    Enabe PTP ports on TPS for all RUs
    Disable PTP ports on TPS for all RUs
    Update ssmtrans level on TPS

Connect to TPS
    [Arguments]    ${hostname}=${TPS_IP}    ${username}=${TPS_USERNAME}    ${password}=${TPS_PASSWORD}
    csn.connect_to    hostname=${hostname}    username=cli    alias=TPS_CLI    look_for_keys=${False}
    ${tps_connection}    csn.get_connection_by_alias    alias=TPS_CLI
    ${channel}    Call Method    ${tps_connection}    invoke_shell
    Send command and verify  command=${username}  exp_result=Password    channel=${channel}
    Send command and verify  command=${password}  exp_result=(Y/N)?    channel=${channel}
    Send command and verify  command=Y  exp_result=Alarm Status    channel=${channel}
    [Return]    ${channel}

Disconnect to TPS
    [Arguments]    ${channel}
    Call Method    ${channel}    close
    csn.disconnect    connection=TPS_CLI

Send command and verify
    [Documentation]    Send command to TPS and verify the result
    ...    param command: executed command on TPS
    ...    param exp_result: result you want to verify on screen. Support for pattern matching.
    [Arguments]    ${command}    ${exp_result}    ${channel}
    Call Method    ${channel}    send    ${command}\n
    Sleep    3 sec
    ${output}  Call Method    ${channel}    recv    ${65535}
    ${output}    Convert To String    ${output}
    Should Match Regexp    string=${output}    pattern=${exp_result}

Update PTP port status on TPS
    [Documentation]    Author: Ding Binmei
    ...    param ports: port number list. like 2,4
    ...    param status: up / down
    [Arguments]    ${ports}    ${status}    ${channel}
    ${ports}    string2list    input_str=${ports}
    FOR    ${port}    IN    @{ports}
        ${cmd_update_port_status}    Set variable    config sync 1 ptp clock1 port${port} adminState ${status}\n
        Send command and verify    command=${cmd_update_port_status}    exp_result=${EMPTY}    channel=${channel}
        ${cmd_check_port_status}    Set variable    show sync 1 ptp clock1 port${port} \n
        Send command and verify    command=${cmd_check_port_status}    exp_result=(?i)adminState\\s*:\\s*${status}    channel=${channel}
    END

Enabe PTP ports on TPS for all RUs
    [Documentation]    Author: Ding Binmei
    [Arguments]    ${tps_ports}
    ${channel}    Connect to TPS
    Update PTP port status on TPS    ports=${tps_ports}    status=up    channel=${channel}
    [Teardown]    Disconnect to TPS    ${channel}

Disable PTP ports on TPS for all RUs
    [Documentation]    Author: Ding Binmei
    [Arguments]    ${tps_ports}
    ${channel}    Connect to TPS
    Update PTP port status on TPS    ports=${tps_ports}    status=down    channel=${channel}
    [Teardown]    Disconnect to TPS    ${channel}

Update ssmtrans level on TPS
    [Documentation]    Author: Ding Binmei
    ...    param ssmtrans_level: support value: act, eprtc, prtc, eprc, prc, ssu_a, ssu_b, esec, sec, dnu, none
    ...    param ports: port number list. like 2,4
    [Arguments]    ${ssmtrans_level}    ${tps_ports}
    ${channel}    Connect to TPS
    ${tps_ports}    string2list    input_str=${tps_ports}
    FOR    ${port}    IN    @{tps_ports}
        ${cmd_update_ssmtrans_level}    Set variable    config interface t24ps1 1/3/C${port} 25gbe ssmtrans ${ssmtrans_level}\n
        Send command and verify    command=${cmd_update_ssmtrans_level}    exp_result=${EMPTY}    channel=${channel}
        ${cmd_check_ssmtrans_level}    Set variable    show interface t24ps1 1/3/C${port} 25gbe ssmtrans \n
        Send command and verify    command=${cmd_check_ssmtrans_level}    exp_result=(?i)${ssmtrans_level}    channel=${channel}
    END
    [Teardown]    Disconnect to TPS    ${channel}
