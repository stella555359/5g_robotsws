*** Settings ***
Documentation    Author: chun.tian@nokia-sbell.com
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
Resource    ../../5GC001795/Resources/5GC001795_common.robot
*** Variables ***

*** Keywords ***
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

Check fault Exist in faultlog in snapshot
    [Arguments]    ${ru_log_path_in_snapshot}    ${fault_filter}
    ${snapshot_alarms_string}    Run    command=cat ${ru_log_path_in_snapshot}/snapshot_status.txt
    sleep    2s
    Should Contain    ${snapshot_alarms_string}    ${fault_filter}
    ${return_time}  ${retrun_fault}    get_time_detail     ${snapshot_alarms_string}
    ${return_time}   Evaluate    ${return_time}+800
    [Return]     ${return_time}  ${retrun_fault}