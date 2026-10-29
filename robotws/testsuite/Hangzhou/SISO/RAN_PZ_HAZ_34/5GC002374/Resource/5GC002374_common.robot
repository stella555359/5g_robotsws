*** Settings ***
Documentation    Author: lijian.xia@nokia-sbell.com

Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC001795/Resources/5GC001795_common.robot

*** Variables ***

*** Keywords ***
Number_of_failure_logs_reported_in_snapshot_for_one_RU_during_1h_AEHC
    [Arguments]  ${ru_index}=1
    ${ALLOWED_FAULT_TEMP}    Copy List    ${ALLOWED_FAULT}
    Set Test Variable    ${ALLOWED_FAULT}    ${ALLOWED_FAULT_TEMP}
    Modify The SnapshotTimeoutS
    Modify Calibration File On RU Unit side    current_name=calibration_dlpath1    new_name=calibron_dlpath1_bk    ru_index=${ru_index}
    Wait until keyword succeeds    30min    30s    RU Status Should Be Failed    ru_index=${ru_index}
    log to console    \n Check Alarm Exist in RawAlarmHistory
    Wait until keyword succeeds    5min    30s    Check Alarm Exist in RawAlarmHistory    alarm_filter=1901
    sleep    120S
    ${ru_alarms_string}    Wait until keyword succeeds    5min   30s    Check fault Exist in faultlog in RU
    ...    fault_filter=1247    ru_index=${ru_index}
    ${snapshot_file_path}    COAM Save snapshot via rest api    timeout=1500
    ${snapshot_alarms_string}    Extract fault logs from snapshot    snapshot_file=${snapshot_file_path}
    should be equal as strings    ${ru_alarms_string}    ${snapshot_alarms_string}
    Modify Calibration File On RU Unit side     current_name=calibron_dlpath1_bk    new_name=calibration_dlpath1    ru_index=${ru_index}
    log to console    \n Check Fault 1901 Absent on WebUI
    Wait until keyword succeeds    5min    30s    Expect Fault Should Absent    faultId=1901
    log to console    \n Check GNB cell on air
    Wait Until Keyword Succeeds    20min    30s    COAM Wait for gnb ready and cell setup

Modify Calibration File On RU Unit side
    [Arguments]    ${current_name}    ${new_name}    ${ru_index}=1
    ${cd_cmd}   Set Variable    cd /mnt/factory/configs/unit;
    ${ru_ip_addr}    wait until keyword succeeds    5min    10s   Get RU IP Address    ru_index=${ru_index}
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    sleep    2s
    csn.send_command    command=${cd_cmd}ls -l | grep ${current_name}.bin | awk '{print $9}'     connection=RU_${ru_index}
    sleep    2s
    ${result}    csn.read_output    connection=RU_${ru_index}
    ${status}    Run Keyword And Return Status    should match regexp    ${result}    ${current_name}
    sleep    1s
    Run Keyword If    '${status}' == 'True'    csn.send_command
    ...     command=${cd_cmd}mv ${current_name}.bin ${new_name}.bin     connection=RU_${ru_index}
    sleep    2s
    Run Keyword If    '${status}' == 'True'    csn.send_command
    ...     command=${cd_cmd}mv ${current_name}.bin.md5 ${new_name}.bin.md5     connection=RU_${ru_index}
    sleep    2s
    Run Keyword If    '${status}' == 'True'    csn.Send command    command=reboot     connection=RU_${ru_index}
    Run Keyword If    '${status}' == 'True'    log to console      \n RU reboot...
    Run Keyword If    '${status}' == 'True'    sleep    120s
    csn.disconnect    connection=RU_${ru_index}
    [Teardown]    csn.disconnect    connection=ASIK Master

Modify The SnapshotTimeoutS
    [Arguments]    ${ru_alias}=RU
    Connect to gnb coam via ssl
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_alias=${ru_alias}
    ${connection}    csn.get_connection_by_alias    alias=${ru_alias}
    ${channel}    Call Method    ${connection}    invoke_shell
    Call Method    ${channel}    send    frmonShellClient localhost 2000\n
    Sleep    3 sec
    Call Method    ${channel}    recv    ${65535}
    Call Method    ${channel}    send    / action create ConfigAccess /ca /module\r\r\n
    Sleep    3 sec
    ${output}    Call Method    ${channel}    recv    ${65535}
    Should Contain    ${output}    ret / action create ConfigAccess /ca /module ==> done ok
    Call Method    ${channel}    send    /ca action fetch DECODED "fault_logger.bin" "/run/fault_logger.json"\r\r\n
    Sleep    3 sec
    ${output}    Call Method    ${channel}    recv    ${65535}
    Should Contain    ${output}    ret /ca action fetch DECODED "fault_logger.bin" "/run/fault_logger.json"  ==> done ok
    csn.execute    command=sed -i 's/"SnapshotTimeoutS": 43200,/"SnapshotTimeoutS": 240,/' /run/fault_logger.json    connection=${ru_alias}
    Sleep    3 sec
    Call Method    ${channel}    send    /ca action store PERMANENT DECODED "fault_logger.bin" "/run/fault_logger.json"\r\r\n
    Sleep    3 sec
    ${output}    Call Method    ${channel}    recv    ${65535}
    Should Contain    ${output}    ret /ca action store PERMANENT DECODED "fault_logger.bin" "/run/fault_logger.json" ==> done ok
    Call Method    ${channel}    send    /ca action update\r\r\n
    Sleep    3 sec
    ${output}    Call Method    ${channel}    recv    ${65535}
    Should Contain    ${output}    ret /ca action update ==> done ok
    Call Method    ${channel}    close
    csn.execute    command=sync    connection=${ru_alias}
    csn.execute    command=sync    connection=${ru_alias}
    csn.execute    command=sync    connection=${ru_alias}
    csn.execute    command=reboot    connection=${ru_alias}
    sleep    20s
    log to console    \n Check GNB cell on air
    Wait Until Keyword Succeeds    15min    30s    COAM Check GNB cell on air
    [Teardown]    Run Keywords    COAM Teardown gnb connections    AND    csn.Reset Cache
