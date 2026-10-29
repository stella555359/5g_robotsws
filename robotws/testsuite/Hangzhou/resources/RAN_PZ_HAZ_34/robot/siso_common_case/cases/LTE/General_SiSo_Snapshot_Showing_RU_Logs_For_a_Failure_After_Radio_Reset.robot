*** Settings ***
Documentation    This is common keywords for LTE siso related cases
...              Please do not modify the file without notification to author

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/bpf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/scf_operation.robot
Variables   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/made_variable.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/LTE/basic/sync_startup.robot
*** Variables ***

*** Keywords ***
General_SiSo_Snapshot_Showing_RU_Logs_For_a_Failure_After_Radio_Reset
    [Documentation]
        ...    *****************
        ...    - [TEST PURPOSE]The purpose of this case is to check RU logs can be stored in snapshot for a failure
        ...    radio reset. Fault logs will be generated per RU fault (defined in Configuration parameters refer to[3]),
        ...    if the log numbers reach the value of maxNumOfFailureLogs  (maximum number of failure logs reported in
        ...     technical log), the new log will replace the first(oldest) one.
        ...    ******************
        ...    History of changes
        ...    ******************
        ...    - 8.25.2022 - - Created
        ...    *******************
        ...    yue.2.liu@nokia-sbell.com
    [Arguments]    ${Tdanger_trriger}=30.0    ${ru_index}=1
    ${original_value}    Get SnapshotTimeoutS original value LTE    ru_index=${ru_index}
    set test variable    ${original_value}
    Modify RU SnapshotTimeoutS LTE    SnapshotTimeoutS=${original_value}    new_timeout=300
    ${Tdanger_init}    Get Tdanger Value from Json File LTE    ru_index=${ru_index}
    log to console    ${Tdanger_init}
    set test variable    ${Tdanger_init}
    Trigger Fault 1937 LTE     Tdanger_target=${Tdanger_trriger}    ru_index=${ru_index}
    sleep    5min
    Recovery Fault 1937 LTE      Tdanger_target=${Tdanger_init}    ru_index=${ru_index}
    sleep    2min
    ${ru_alarms_string_before}    Check fault Exist in RU and snapshot LTE
    set test variable    ${ru_alarms_string_before}
    Perform RF Module Reset from GUI LTE
    Wait until keyword succeeds    20 min    20 sec    Verify all cells should be onair    cell_type=${cell_type}
    Check fault Exist in RU and snapshot LTE
    FOR    ${i}    IN RANGE    0   3
        Trigger Fault 1937 LTE     Tdanger_target=${Tdanger_trriger}    ru_index=${ru_index}
        sleep    5min
        Recovery Fault 1937 LTE      Tdanger_target=${Tdanger_init}    ru_index=${ru_index}
        sleep    2min
    END
    ${ru_alarms_string_after}    Check fault Exist in faultlog in RU LTE
    set test variable    ${ru_alarms_string_after}
    should not be equal    ${ru_alarms_string_before}    ${ru_alarms_string_after}
    [Teardown]    Test case teardown
Trigger Fault 1937 LTE
    [Arguments]   ${Tdanger_target}    ${ru_index}=1
    log to console    \n Trigger Fault 1937
    Modify Tdanger Value In Json File LTE    init_value=${Tdanger_init}    target_value=${Tdanger_target}    cmd=touch
    ...    ru_index=${ru_index}
    Perform RF Module Reset from GUI LTE
    sleep    60s
    log to console   \n Check Fault 1937 Appear On WebEM
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=https://${sbts_addr}
    ...                    username=${http_username}
    ...                    password=${http_password}
    selenium_coam.disable_message_box
    Wait until keyword succeeds    10min    30s    Expect Fault Should Present LTE    faultId=1937
    [Teardown]   Selenium Logout And Close Browser
Recovery Fault 1937 LTE
    [Arguments]   ${Tdanger_target}     ${Tdanger_trriger}=30.0   ${ru_index}=1
    log to console    \n Recovery Fault 1937
    Modify Tdanger Value In Json File LTE    init_value=${Tdanger_trriger}    target_value=${Tdanger_target}
     ...    cmd=rm -rf    ru_index=${ru_index}
    Perform RF Module Reset from GUI LTE
    sleep    60s
    log to console    \n Check Fault 1937 Disappear On WebEM
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=https://${sbts_addr}
    ...                    username=${http_username}
    ...                    password=${http_password}
    selenium_coam.disable_message_box
    Wait until keyword succeeds    10min    30s    Expect Fault Should Absent LTE    faultId=1937
    Wait until keyword succeeds    20 min    20 sec   Verify all cells should be onair    cell_type=${cell_type}
    [Teardown]   Selenium Logout And Close Browser
Modify Tdanger Value In Json File LTE
    [Arguments]    ${init_value}    ${target_value}    ${cmd}    ${ru_index}=1    ${connection}=GNB_OAM
    ...    ${tcsPath}=/var/tmp/tcs.json
    log to console    \n Modify Tdanger Value In Json File
    csn.connect to    hostname=${sbts_addr}    username=${ssh_username}    password=${ssh_password}    alias=ASIK Master
    Connect to RU With Allocated IP LTE   ru_index=${ru_index}    asik_alias=ASIK Master    ru_alias=RU_${ru_index}
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    ${cmd_temp}   Set Variable
    ...    echo "/ action create ConfigAccess /CI/ConfigAccess_Module /module"|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    sleep    2s
    ${cmd_temp}   Set Variable
    ...    echo '/CI/ConfigAccess_Module action fetch DECODED "tcs.bin" "${tcsPath}"'|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    csn.Send command  command=cat /var/tmp/tcs.json | grep -i Tdanger    connection=RU_${ru_index}
    csn.Send command
    ...    command=${sudo} sed -i 's/"Tdanger": ${init_value},/"Tdanger": ${target_value},/g' /var/tmp/tcs.json
    ...    connection=RU_${ru_index}
    sleep    2s
    csn.Send command    command=${sudo} cat /var/tmp/tcs.json | grep -i Tdanger    connection=RU_${ru_index}
    sleep    2s
    csn.Send command    command=${sudo} ${cmd} /mnt/runtime/runtime_config.txt    connection=RU_${ru_index}
    ${cmd_temp}   Set Variable
    ...    echo '/CI/ConfigAccess_Module action store PERMANENT DECODED "tcs.bin" "${tcsPath}"'|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    ${cmd_temp}   Set Variable  echo "/CI/ConfigAccess_Module action update"|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    csn.disconnect    connection=RU_${ru_index}
    [Teardown]    csn.disconnect    connection=ASIK Master
Get Tdanger Value from Json File LTE
    [Arguments]    ${ru_index}=1    ${tcsPath}=/var/tmp/tcs.json
    log to console    \n Get Tdanger Value from Json File LTE
    csn.connect to    hostname=${sbts_addr}    username=${ssh_username}    password=${ssh_password}    alias=ASIK Master
    Connect to RU With Allocated IP LTE   ru_index=${ru_index}    asik_alias=ASIK Master    ru_alias=RU_${ru_index}
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    ${cmd_temp}   Set Variable
    ...    echo "/ action create ConfigAccess /CI/ConfigAccess_Module /module"|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    sleep    2s
    ${cmd_temp}   Set Variable
    ...   echo '/CI/ConfigAccess_Module action fetch DECODED "tcs.bin" "${tcsPath}"'|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    ${output}  csn.execute  command=${sudo} cat /var/tmp/tcs.json | grep -i Tdanger    connection=RU_${ru_index}
    ${pattern}   Set Variable    "Tdanger": (.*),
    ${init_value_list}    Get Regexp Matches     ${output}    ${pattern}    1
    ${init_value}   Set Variable    ${init_value_list}[0]
    ${cmd_temp}   Set Variable
    ...    echo '/CI/ConfigAccess_Module action store PERMANENT DECODED "tcs.bin" "${tcsPath}"'|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    ${cmd_temp}   Set Variable  echo "/CI/ConfigAccess_Module action update"|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    csn.disconnect    connection=RU_${ru_index}
    csn.disconnect    connection=ASIK Master
    [Return]    ${init_value}
Check fault Exist in RU and snapshot LTE
    [Arguments]  ${ru_index}=1    ${fault_filter}=1168
    ...    ${ru_fault_log_path}=/mnt/runtime/fault-log/snapshot_status.txt
    log to console    \n Check fault Exist in RU and snapshot
    ${ru_alarms_string}    Wait until keyword succeeds    5min   30s    Check fault Exist in faultlog in RU LTE
    ...    fault_filter=${fault_filter}   ru_index=${ru_index}   ru_fault_log_path=${ru_fault_log_path}
    ${snapshot_file_path}=    COAM Save snapshot via webUI
    ...    url=https://${sbts_addr}
    ...    username=${http_username}
    ...    password=${http_password}
    ${snapshot_alarms_string}    Extract fault logs from snapshot
    ...    snapshot_file=${snapshot_file_path}    fault_id=${fault_filter}
    should be equal as strings    ${ru_alarms_string}    ${snapshot_alarms_string}
    [Return]    ${ru_alarms_string}
Check fault Exist in faultlog in RU LTE
    [Arguments]    ${fault_filter}=1168    ${ru_index}=1
    ...    ${ru_fault_log_path}=/mnt/runtime/fault-log/snapshot_status.txt
    csn.connect to    hostname=${sbts_addr}    username=${ssh_username}    password=${ssh_password}    alias=ASIK Master
    Connect to RU With Allocated IP LTE     ru_index=${ru_index}    asik_alias=ASIK Master    ru_alias=RU_${ru_index}
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    sleep    2s
    csn.send_command    command=${sudo} cat ${ru_fault_log_path}| grep ${fault_filter}    connection=RU_${ru_index}
    sleep    2s
    ${1247_alarms_string}    csn.read output    connection=RU_${ru_index}
    Should Contain    ${1247_alarms_string}    ${fault_filter}
    csn.send_command    command=${sudo} cat ${ru_fault_log_path}    connection=RU_${ru_index}
    sleep    2s
    ${ru_alarms_string}    csn.read output    connection=RU_${ru_index}
    csn.disconnect    connection=RU_${ru_index}
    [Return]    ${ru_alarms_string}

Get SnapshotTimeoutS original value LTE
    [Arguments]    ${ru_index}=1
    csn.connect to    hostname=${sbts_addr}    username=${ssh_username}    password=${ssh_password}    alias=ASIK Master
    Connect to RU With Allocated IP LTE     ru_index=${ru_index}    asik_alias=ASIK Master    ru_alias=RU_${ru_index}
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    ${cmd_temp}   Set Variable  echo "/ action create ConfigAccess /ca /module"|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain Any    ${output}    done ok    Path already taken
    sleep    2s
    ${cmd_temp}   Set Variable
    ...    echo '/ca action fetch DECODED "fault_logger.bin" "/run/fault_logger.json"'|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}   csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain    ${output}    done ok
    sleep    2s
    ${cmd_temp}    Set Variable     ${sudo} cat /run/fault_logger.json | grep -i SnapshotTimeoutS
    ${output_value}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    ${pattern}   Set Variable    "SnapshotTimeoutS": (.*),
    ${original_value_list}    Get Regexp Matches     ${output_value}    ${pattern}    1
    ${original_value}   Set Variable    ${original_value_list}[0]
    log to console   \n original Snapshot timeout value:${original_value}
    sleep    2s
    ${cmd_temp}   Set Variable
    ...    echo '/ca action store PERMANENT DECODED "fault_logger.bin" "/run/fault_logger.json"'|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain   ${output}    done ok
    sleep    2s
    ${cmd_temp}   Set Variable  echo "/ca action update"|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain   ${output}    done ok
    sleep    2s
    csn.disconnect    connection=RU_${ru_index}
    [Return]    ${original_value}
    [Teardown]    csn.disconnect    connection=ASIK Master
Modify RU SnapshotTimeoutS LTE
    [Arguments]    ${ru_index}=1    ${SnapshotTimeoutS}=43200    ${new_timeout}=300
    csn.connect to    hostname=${sbts_addr}    username=${ssh_username}    password=${ssh_password}    alias=ASIK Master
    Connect to RU With Allocated IP LTE     ru_index=${ru_index}    asik_alias=ASIK Master    ru_alias=RU_${ru_index}
    ${sudo}    csn.execute    command=which sudo    connection=RU_${ru_index}
    ${sudo}    Replace String    ${sudo}    \r\n    ${EMPTY}
    ${cmd_temp}   Set Variable  echo "/ action create ConfigAccess /ca /module"|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain Any   ${output}    done ok    Path already taken
    sleep    2s
    ${cmd_temp}   Set Variable
    ...    echo '/ca action fetch DECODED "fault_logger.bin" "/run/fault_logger.json"'|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain   ${output}    done ok
    sleep    2s
    ${cmd_temp}   Set Variable    ${sudo} cat /run/fault_logger.json | grep -i SnapshotTimeoutS
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    log to console  before Modify Snapshot timeout:${output}
    sleep    2s
    csn.Send command
    ...    command=${sudo} sed -i 's/"SnapshotTimeoutS": ${SnapshotTimeoutS},/"SnapshotTimeoutS": ${new_timeout},/' /run/fault_logger.json
    ...    connection=RU_${ru_index}
    sleep    2s
    ${cmd_temp}   Set Variable    ${sudo} cat /run/fault_logger.json | grep -i SnapshotTimeoutS
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    log to console  after Modify Snapshot timeout:${output}
    sleep    2s
    ${cmd_temp}   Set Variable
    ...    echo '/ca action store PERMANENT DECODED "fault_logger.bin" "/run/fault_logger.json"'|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain   ${output}    done ok
    sleep    2s
    ${cmd_temp}   Set Variable  echo "/ca action update"|${sudo} frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain   ${output}    done ok
    sleep    2s
    csn.disconnect    connection=RU_${ru_index}
    [Teardown]    csn.disconnect    connection=ASIK Master
Perform RF Module Reset from GUI LTE
    [Arguments]  ${ru_index}=1    ${gnb_index}=${0}     ${connection}=GNB_OAM
    log to console    \n***Perform RF Module Reset from GUI LTE***
    ${ru_index}  Convert To Integer    ${ru_index}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=https://${sbts_addr}
    ...                    username=${http_username}
    ...                    password=${http_password}
    selenium_coam.disable_message_box
    selenium_coam.reset_ru  ru_index=${ru_index}
    Run Keyword And Ignore Error    Wait Until Keyword Succeeds    5min    5s    RU Should Be Offline
    ...    ru_index=${ru_index}    connection=${connection}
    [Teardown]  Selenium Logout And Close Browser
Test case teardown
    [Arguments]    ${ru_index}=1
    Modify RU SnapshotTimeoutS LTE    SnapshotTimeoutS=300    new_timeout=${original_value}
    Recovery Fault 1937 LTE      Tdanger_target=${108}    ru_index=${ru_index}
    Selenium Logout And Close Browser
    csn.Reset Cache
