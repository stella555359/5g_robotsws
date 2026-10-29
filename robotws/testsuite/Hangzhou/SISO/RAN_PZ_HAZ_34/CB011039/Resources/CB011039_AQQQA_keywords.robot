*** Settings ***
Documentation    This is for CB011039 Fail safe boot for RU keywords
...              Author: Yang Di
...              Contact: di.yang@nokia-sbell.com
...              squad: RAN_RD_VRF_HAZ3_5

Resource    ${BASIC_PATH_5G}/General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/feature/CB010823_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/ru_operation.robot
Library     taf.rfrl.common_resources.python.SWConfig    WITH NAME    SWConfig
Library     taf.sbts.oam.coam.admin    WITH NAME    coam
Library     taf.selenium.sbts   WITH NAME   selenium_sbts
Library     random
Variables   ./variable.py

*** Variables ***
@{CHECK_POINTS_31_41}    ${31}    ${41}
@{FAULT_ID_SUSPEND_SERVICE}    10    1981

*** Keywords ***
Case Preparion Active CB011039
    ${localFilePath}  Set variable  ${CURDIR}/swconfig.txt
    wait until keyword succeeds    1min    10s    Connect to Common Unit Master   alias=ASIM    du_index=${0}
    ...    gnb_index=${0}
    SWConfig.Upload SwConfig File To Asik And Crasign     localFilePath=${localFilePath}    asik_alias=ASIM
    csn.Disconnect    connection=ASIM
    Connect to gnb coam via ssl
    coam.Reset Site   connection=GNB_OAM
    Wait Until Keyword Succeeds   7m   30s   Verify all cells should be onair
    log to console   ***upload swconfig and reboot gnb finished!***
    [Teardown]   COAM Teardown gnb connections

CB011039 Change Fail Safe Mode Value
    [Arguments]    ${target_value}=enable    ${ru_index}=1
    Connect to gnb coam via ssl
    log to console    \n Modify fail_safe_mode value
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    ${cmd_temp}   Set Variable
    ...  echo "/ action create ResetControl /CI/ResetControl/module /module"|frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain Any   ${output}    done ok    Path already taken
    sleep    2s
    ${cmd_temp}   Set Variable
    ...    echo '/CI/ResetControl/module action ${target_value}_fail_safe_mode'|frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain   ${output}    done ok
    sleep    2s
    ${cmd_temp}   Set Variable    echo '/CI/ResetControl/module get fail_safe_mode'|frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain   ${output}    done ok
    log to console  Modify fail_safe_mode:\n ${output}
    csn.disconnect    connection=RU_${ru_index}
    Sleep    3s
    [Teardown]    csn.disconnect    connection=ASIK Master

Activate Fail Safe Mode on RU
#    [Arguments]    ${ru_index}=1
    CB011039 Change Fail Safe Mode Value
    RU Reset And Boot In Fail Safe Mode
    [Teardown]    csn.Reset Cache

Deactivate Fail Safe Mode on RU
    [Arguments]    ${ru_index}=1
    ${status}    Run Keyword And Return Status    CB011039 Change Fail Safe Mode Value    disable
    Run Keyword If    ${status}    Perform RU Reset    ru_index=${ru_index}
    Wait until keyword succeeds    20 min    20 sec   RU Should Be Online
    Run keyword and ignore error   Perform RU Unlock
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    Wait Until Keyword Succeeds    10min    20 sec    COAM Check X2 link status from GNB
    [Teardown]    csn.Reset Cache

RU Should Be Failed
    [Documentation]   Auther: di.yang@nokia-sbell.com
    [Arguments]  ${ru_index}=${1}    ${connection}=GNB_OAM
    &{ru_status}    COAM get ru detial info by ru index     ru_index=${ru_index}   connection=${connection}
    Should be equal as strings    ${ru_status['status']['operationalState'].lower()}       disabled
                                  ...  msg=Current RU operationalStatus is not in Disabled status
    Should be equal as strings    ${ru_status['status']['availabilityStatus'].lower()}     failed
                                  ...  msg=Current RU availabilityStatus is not in Failed status
    Should be equal as strings    ${ru_status['status']['administrativeState'].lower()}     unlocked
                                  ...  msg=Current RU administrativeState is not in Unlocked status

Check if fault is active on RU in History log
    [Arguments]  ${text}    ${ru_index}=1
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    ${output}    csn.execute    command=ls /run -ll | grep fault_history_log_temp.txt    connection=RU_${ru_index}
    ...    timeout=60s
    ${file_status}    run keyword and return status    should not be empty    ${output}
    ${filename}    set variable if      ${file_status}    fault_history_log_temp.txt    fault_history_log.txt
    ${output}  csn.execute  command=cd /run ; cat ${filename}    connection=RU_${ru_index}
    Log to console      ${output}
    ${active}=    Fetch From Left    string=${output}   marker=InActive faults:
    Log to console      ${active}
    Should contain      ${active}    ${text}
    [Teardown]  run_keywords    csn.disconnect    connection=RU_${ru_index}  AND
    ...                         csn.disconnect    connection=ASIK Master

Suspend Selected RFSW Service Via Testability Interface
    [Arguments]  ${ru_index}=1
    log to console    \n Suspend selected RFSW service
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    ${cmd_temp}   Set Variable
    ...  echo "/ action create SoftwareService /CI/SoftwareService/module"|frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain Any   ${output}    done ok    Path already taken
    sleep    2s
    ${cmd_temp}   Set Variable
    ...    echo "/CI/SoftwareService/module get supported_services_ids"|frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    @{list}   Split String   ${output}
    sleep    2s
    ${ServiceIndex}   Set Variable    fans::instance1
    ${cmd_temp}   Set Variable
    ...    echo '/CI/SoftwareService/module action service_keep_suspend "${ServiceIndex}"'|frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain   ${output}    done ok
    log to console  Modify fail_safe_mode:\n ${output}
    csn.disconnect    connection=RU_${ru_index}
    Set Test Variable  ${ServiceIndex}
    sleep    3s
    RU Reset After Suspending RFSW Service
    Wait For Expect Fault Present    faultId=2934    timeout=6min
    [Teardown]    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master

RU Reset And Boot In Fail Safe Mode
    [Arguments]    ${ru_index}=1
    Perform RU Reset    ru_index=${ru_index}
    Wait Until Keyword Succeeds    15min    30s    RU Should Be Failed    ru_index=${ru_index}
    Cells Should Be Disabled In Fail Safe Mode    ru_index=${ru_index}

Restore The Suspending Service
    [Arguments]    ${ru_index}=1
    log to console    \n Restore the suspending service
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    ${cmd_temp}   Set Variable
    ...  echo "/ action create SoftwareService /CI/SoftwareService/module"|frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain Any   ${output}    done ok    Path already taken
    sleep    2s
    ${cmd_temp}   Set Variable
    ...    echo '/CI/SoftwareService/module action service_restore "${ServiceIndex}"'|frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain   ${output}    done ok
    sleep    3s
    Perform RU Reset    ru_index=${ru_index}
    sleep    15s
    Wait until keyword succeeds    20 min    20 sec   RU Should Be Online
    Run keyword and ignore error   Perform RU Unlock
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    Wait until keyword succeeds    10 min    20 sec   COAM Check X2 link status from GNB
    [Teardown]    csn.Reset Cache

RU Reset After Suspending RFSW Service
    [Arguments]    ${ru_index}=1
    Perform RU Reset    ru_index=${ru_index}
    Sleep    15s
    Wait Until Keyword Succeeds    20min    30s    RU Should Be Failed    ru_index=${ru_index}
    Cells Should Be Disabled In Fail Safe Mode    ru_index=${ru_index}

Trigger Fault And Its Recovery Action Need Reset Radio
    [Arguments]    ${ru_index}=1
    Modify Calibration File On RU Unit    current_name=calibration_dlpath1    new_name=calibration_dlpath1_bk
    ...    ru_index=${ru_index}
    Wait until keyword succeeds    10min    120s    RU Status Should Be Failed    ru_index=${ru_index}
    Check Alarm Exist in RawAlarmHistory    alarm_filter=1901
    Expect Fault Should Absent    faultId=1901
    Expect Fault Should Present    faultId=2934

Get Fail Safe Mode Value
    [Arguments]    ${ru_index}=1
    log to console    \n Get fail_safe_mode value
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    ${cmd_temp}   Set Variable
    ...  echo "/ action create ResetControl /CI/ResetControl/module /module"|frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain Any   ${output}    done ok    Path already taken
    sleep    2s
    ${cmd_temp}   Set Variable    echo '/CI/ResetControl/module get fail_safe_mode'|frmonShellClient 127.0.0.1 2000
    ${output}  csn.execute  command=${cmd_temp}    connection=RU_${ru_index}
    Should Contain   ${output}    done ok ACTIVE
    log to console  Get fail_safe_mode:\n ${output}
    csn.disconnect    connection=RU_${ru_index}
    [Teardown]    csn.disconnect    connection=ASIK Master

Trigger AQQQA 4681 Alarm
    [Arguments]    ${ru_index}=1    ${restore}=False
    Connect to Common Unit Master
    Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}    asik_alias=ASIK Master
    Connect To Node Via RU Connection    node_id=1    ru_alias=RU_${ru_index}    ru_index=${ru_index}
    ${cmd_temp1}   Set Variable    echo "/ action create ConfigAccess /ca /module"|frmonShellClient 127.0.0.1 2000
    ${output1}  csn.execute  command=${cmd_temp1}    connection=node_1
    ${cmd_temp2}   Set Variable
    ...    echo "/ action create ThermometerDevice /pa1 /temp/made1/pa1"|frmonShellClient 127.0.0.1 2000
    ${output2}  csn.execute  command=${cmd_temp2}    connection=node_1
    ${cmd_temp3}   Set Variable    echo "/pa1 action override FAULTY"|frmonShellClient 127.0.0.1 2000
    ${output3}  csn.execute  command=${cmd_temp3}    connection=node_1
    csn.Disconnect   connection=node_1
    ${cmd_temp4}   Set Variable    cat /ram/fault_history_log_temp.txt
    ${output4}  csn.execute  command=${cmd_temp4}    connection=RU_${ru_index}
    ${cmd_temp5}   Set Variable    echo "/pa1 action override OFF"|frmonShellClient 127.0.0.1 2000
    ${output5}    Run Keyword If    '${restore}'=='True'    run keywords    Connect To Node Via RU Connection
    ...    node_id=1    ru_alias=RU_${ru_index}    ru_index=${ru_index}   AND    csn.execute  command=${cmd_temp5}
    ...    connection=node_1
    Run Keyword And Ignore Error    csn.disconnect    connection=node_1
    Run Keyword And Ignore Error    csn.disconnect    connection=RU_${ru_index}
    Run Keyword And Ignore Error    csn.disconnect    connection=ASIK Master

Connect To Node Via RU Connection
    [Arguments]    ${node_id}    ${node_alias}=node_${node_id}    ${nodes}=${Node}    ${ru_index}=1    ${ru_alias}=RU_${ru_index}
    ${nodes_length}    Get Length    ${nodes}
    FOR    ${i}    IN RANGE    0    ${nodes_length}
        ${node_ip}    run keyword if    ${Node[${i}]}[id]==${node_id}    set variable    ${Node[${i}]}[ip]
        Exit For Loop If    '${node_ip}'!='${None}'
    END
    csn.connect to    hostname=${node_ip}
    ...               username=${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.username}
    ...               password=${tl.gnbs[0].dus[0].rus[0].default_ssh_connection_details.password}
    ...               alias=${node_alias}
    ...               proxy=${ru_alias}

Check Diagnostic Report in Snapshot
    ${time_before_start_diagnostic_check}    robot.libraries.DateTime.Get Current Date    time_zone=UTC
    ...    result_format=%Y-%m-%dT%H:%M:%S+08:00    increment=+8hours
    selenium_sbts.start_diagnostic_check    scope=Full diagnostic check
    Verify Diagnostic Report From Snapshot Normal    ${CHECK_POINTS_31_41}    ${time_before_start_diagnostic_check}
    ...    ${1011}

Trigger AQQQA 4681 and Wait Check Points NOK
    Selenium Login And Disable Screen Lock
    Trigger AQQQA 4681 Alarm
    Wait Until Keyword Succeeds    10min    30s    Check Points 31 42 NOK

Check Points 31 42 NOK
    selenium_sbts.start_diagnostic_check    scope=Full diagnostic check    timeout=300
    ${report}    selenium_sbts.get_report
    ${result}    run keyword and return status    should contain    ${Active_SW_version}    24R3
    ${module_type_1}    Set Variable If    ${result}    System module    Target distinguished name
    ${module_type_2}    Set Variable If    ${result}    Radio module    Target distinguished name
    Verify NOK Check Points On WebEM Reports    ${report['BTS diagnostic check report']}   ${module_type_1}    SMOD_R-1
    ...    31
    Verify NOK Check Points On WebEM Reports    ${report['RU diagnostic check report']}    ${module_type_2}    RMOD_R-1
    ...    42

Restore AQQQA 4681 Alarm
    Connect to gnb coam via ssl
    Trigger AQQQA 4681 Alarm    restore=True

Lock Ru and check Status
    [Arguments]      ${ru_index}=1
    Perform RU lock    ru_index=${ru_index}
    RU Should Be Locked In Fail Safe Mode     ru_index=${ru_index}
    Cells Should Be Disabled In Fail Safe Mode    ru_index=${ru_index}

RU Should Be Locked In Fail Safe Mode
    [Arguments]      ${ru_index}=${1}    ${connection}=GNB_OAM
    &{ru_status}    COAM get ru detial info by ru index     ru_index=${ru_index}   connection=${connection}
    Should be equal as strings    ${ru_status['status']['administrativeState'].lower()}    locked
                                  ...  msg=Current RU administrativeState is not in Locked status
    Should be equal as strings    ${ru_status['status']['operationalState'].lower()}       disabled
                                  ...  msg=Current RU operationalState is not in Disabled status
    Should be equal as strings    ${ru_status['status']['availabilityStatus'].lower()}      failed
                                  ...  msg=Current RU availabilityStatus is not in Failed status

Cells Should Be Disabled In Fail Safe Mode
    [Arguments]      ${ru_index}=${1}
    ${cell_list}    Get All Cell Id    ru_index=${ru_index}
    FOR     ${cell_id}    IN     @{cell_list}
        ${cellgrp_id}   Get Cell Group From Cell   cell_id=${cell_id}
        Wait until keyword succeeds    1min   10s    Cell Should Be Disabled    cell_idx=${cell_id}
        ...   cell_group_idx=${cellgrp_id}
    END

