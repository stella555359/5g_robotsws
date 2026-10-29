*** Settings ***
Documentation
...   author: tingting.zhong@nokia-sbell.com
...   contact: tingting.zhong@nokia-sbell.com
...   Description:
...   This test case is used to check vDU default snapshot fault list

# Test Setup    Case Setup
# Test Teardown    Case Teardown
Suite Setup         Cloud Suite Setup
Suite Teardown      Cloud Suite Teardown
Test Setup          Cloud Test Setup
Test Teardown       Cloud Test Teardown
Test Timeout        120 minutes

Force Tags
...    PY36
...    CLOUD_5G_AIC                               #TL_TYPE
...    STATE_ON_AIR                               #gNB_STATE
...    5G_RAN                                     #CA
...    master_allincloud_int                      #vDU_Branch_name
...    RAN_PZ_HAZ_34                              #Orginazation
...    TA_LEVEL_22_FULL_AUTOMATED_CIT_CRT         #Detailed Automation Level


Library           String
Library           testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/py_tool/time_convert.py
Library           testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Cloud/CB006483/Resources/utils.py
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Cloud/CB006483/Resources/CB006483_keywords.robot
Resource          testsuite/Hangzhou/AIC/RAN_PZ_HAZ_34/Resources/vdu_oam_fm.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_Cloud.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/Cloud/Cloud_Setup_and_Teardown.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/Cloud/General_SiSo_RU_module_reset_from_GUI_Cloud.robot
Library           taf.gnb.oam.coam.vdu   WITH NAME   coam_vdu
#Resource          common.robot


*** Test Cases ***
[1]CB006483_5G_C_Add_modify_remove_the triggers_Remote_Tool
    [Documentation]    *****************
    ...    Basic information
    ...    *****************
    ...    Description in reStructuredText format on what is tested
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of the test case is to verify if user can remove triggers by disabling feature CB006483.
    ...    (CB006483-A-C，CB006796-SR-A)
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 31.03.2022 - - Created
    ...    *******************
    ...    Notice: if cell group has servals cell, get ue failed
    ...    *******************
    ...    Owner_tingting.zhong@nokia-sbell.com
    [Tags]  CRT_TRUNK    RF50
    [Setup]    Case Setup
    Set Active Default Trigger Value to True by Fullscf
    Check Default Snapshot Fault List    contain=${True}
    ${faultSnapshotTriggers}    Get Snapshot Fault list
    ${update_alarm}    set variable    ${faultSnapshotTriggers[0]}
    Operate a Alarm From the Default List    alarm_dict=${update_alarm}    alarm_operation=update
    ${operation_alarm}    set variable    ${faultSnapshotTriggers[1]}
    Operate a Alarm From the Default List    alarm_dict=${operation_alarm}    alarm_operation=delete
    Operate a Alarm From the Default List    alarm_dict=${operation_alarm}    alarm_operation=add
    # for feature 6796,  check audit log
    Set Active Defalut Trigger to False and Check Auditlog
    Check Default Snapshot Fault List    contain=${False}
    [Teardown]    Case Teardown

[1]CB006483-5G-D_Max_number_of_snapshots_by_fault_triggers_per_day_NetAct
    [Documentation]    *****************
    ...    Basic information
    ...    *****************
    ...    Description in reStructuredText format on what is tested
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of the test case is to verify max number of spanshot
    ...    (CB006483-A-C, CB006483-A-D, CB006483-B-E)
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 13.06.2022 - - Created
    ...    - 07.12.2022 - - Add step https://jiradc.ext.net.nokia.com/browse/LEOPARD-909
    ...    - 23.06.2025 - - Refactor TC and Add checkpoints https://jiradc.ext.net.nokia.com/browse/REX-23542
    ...    *******************
    ...    Notice: if cell group has servals cell, get ue failed
    ...    *******************
    ...    Owner_xiaomian.zhang@nokia-sbell.com
    [Tags]  CRT_TRUNK    RF50
    [Setup]    Case Setup
    Step1:Update max number of snapshots by fault triggers per day
    Step2:Testing block cell trigger vdu snapshot collection for 1st time
    Step3:Testing block cell trigger vdu snapshot collection for 2nd time
    Step4:Testing block cell trigger vdu snapshot collection failure for 3rd time
    Step5:Check Diagnostic Snapshot Collection via substring trigger for 4th time
    Step6:Testing block cell trigger vdu snapshot collection failure for 5th time
    [Teardown]    Case Teardown

[1]CB006483-5G-F_Reporting_of_transient_alarm_to_Inform_snapshot transfer_failures_ST_LSS
    [Documentation]    *****************
    ...    Basic information
    ...    *****************
    ...    Description in reStructuredText format on what is tested
    ...    *****************
    ...    - [TEST PURPOSE] The purpose of the test case is to verify alarm 4523
    ...    (CB006483-B-A, CB006483-A-F)
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 13.06.2022 - - Created
    ...    *******************
    ...    Notice: if cell group has servals cell, get ue failed
    ...    *******************
    ...    Owner_tingting.zhong@nokia-sbell.com
    [Tags]  CRT_TRUNK    RF50
    Add Trigger Fault 49
    Update Snapshot Configuration to Incorrect LSS
    Reset VDU
    wait until keyword succeeds     15min    30s     vDU Verify All Cells Status Should Be Onair
    sleep    60    reason=wait for vdu ready to operate
    ${time}    Get vdu time
    ${cell_list}    vDU Get Cells ID list
    Block Cell by Rest    cell_id=${cell_list[0]}
    wait until keyword succeeds    3min    5sec    Check Alarm exsit in active Alarm    fault_id=49    alarming_object=NRCELL-${cell_list[0]}
    ...    exsit=${True}
    wait until keyword succeeds    10min    5sec    Check Alarm exsit in active Alarm    fault_id=4523
    ...    exsit=${True}
    wait until keyword succeeds    3min    5sec    Check Alarm exsit in active Alarm    fault_id=4523
    ...    exsit=${False}
    Unblock Cell by Rest    cell_id=${cell_list[0]}
    wait until keyword succeeds    10min    5sec    vDU Verify All Cells Status Should Be Onair

[1]CB010411-CR-I1_3_05_CB006796-SR-A_check_rannic_crash_event_log
    [Documentation]    *****************
    ...    Basic information
    ...    *****************
    ...    Description in reStructuredText format on what is tested
    ...    *****************
    ...    - [TEST PURPOSE] BTS shall optimize the "additionalText" in the event-log and is applicable to additionalText content only.
    ...    OAM shall do the optimization by logging the content with new structure in JSON format itself thereby saving memory.
    ...    -Creation of new object as "key":"added".
    ...    *******************
    ...    History of changes
    ...    ******************
    ...    - 28.02.2024 - - Created
    ...    *******************
    ...    Owner_tingting.zhong@nokia-sbell.com
    [Tags]    RF50
    [Setup]    Case Setup
    Log to console    Step1: Get the CST time From vDU platform
    ${Original_time}   Get vDU Time Cst
    ${CASE_OPERATION_START_TIME}=    Replace String    ${Original_time}    \r\n    ${EMPTY}
    Log to console    CASE_OPERATION_START_TIME is:${CASE_OPERATION_START_TIME}
    Log to console    Step2: Trigger Rannic Reset and Verify Cell status
    Trigger Rannic Reset and Verify Cell status
    Log to console    Step3: Check Rannic Reset in Auditlog
    Check Rannic Reset in Auditlog
    Log to console    Step4: Check rannic reset operation history from webem
    Check rannic reset operation history from webem    operation_start_time=${CASE_OPERATION_START_TIME}
    Log to console    Step5: Wait Site Normal after Rannic Reset
    Wait Site Normal after Rannic Reset
    Log to console    Step6: L3 Call And Throughput with Customize CELL List
    L3 Call And Throughput with Customize CELL List    with_call=${True}
    [Teardown]    Case Teardown

*** Keywords ***
Step1:Update max number of snapshots by fault triggers per day
    Log to console    Step1:update max number of snapshots by fault triggers per day
    Add Trigger Fault 49
    Update Snapshot Configuration to NetAct
    Reset VDU
    wait until keyword succeeds     15min    30s     vDU Verify All Cells Status Should Be Onair
    sleep    60    reason=wait for vdu ready to operate
    ${cell_list}    vDU Get Cells ID list

Step2:Testing block cell trigger vdu snapshot collection for 1st time
    Log to console  Step2: Testing block cell trigger vdu snapshot collection for 1st time
    ${time}    Get vdu time
    ${cell_list}    vDU Get Cells ID list
    ${origion_bts_name}    Get Bts Name by Rest
    Block Cell by Rest    cell_id=${cell_list[0]}
    wait until keyword succeeds    3min    5sec     Check Alarm exsit in active Alarm    fault_id=49    alarming_object=NRCELL-${cell_list[0]}
    ...    exsit=${True}
    wait until keyword succeeds    1min    10sec    Check Diagnostic Snapshot Collection Info
    ...   diagSnapAddInfo=49 - On fault detection    diagSnapState=Collection    diagSnapFilename=${EMPTY}
    wait until keyword succeeds    10min    20sec    Check Diagnostic Snapshot Collection Info
    ...    diagSnapAddInfo=49 - On fault detection    diagSnapState=Upload completed    diagSnapFilename=${origion_bts_name}
    Unblock Cell by Rest    cell_id=${cell_list[0]}
    wait until keyword succeeds    3min    5sec     Check Alarm exsit in active Alarm    fault_id=49    alarming_object=NRCELL-${cell_list[0]}
    ...    exsit=${False}
    wait until keyword succeeds    10min    5sec    vDU Verify All Cells Status Should Be Onair
    sleep    15min

Step3:Testing block cell trigger vdu snapshot collection for 2nd time
    Log to console    Step3: Testing block cell trigger vdu snapshot collection for 2nd time
    ${time}    Get vdu time
    ${cell_list}    vDU Get Cells ID list
    ${origion_bts_name}    Get Bts Name by Rest
    Block Cell by Rest   cell_id=${cell_list[0]}
    wait until keyword succeeds    3min    5sec    Check Alarm exsit in active Alarm    fault_id=49    alarming_object=NRCELL-${cell_list[0]}
    ...    exsit=${True}
    wait until keyword succeeds    1min    10sec    Check Diagnostic Snapshot Collection Info
    ...    diagSnapAddInfo=49 - On fault detection    diagSnapState=Collection    diagSnapFilename=${EMPTY}
    wait until keyword succeeds    10min    20sec    Check Diagnostic Snapshot Collection Info
    ...    diagSnapAddInfo=49 - On fault detection    diagSnapState=Upload completed    diagSnapFilename=${origion_bts_name}
    Unblock Cell by Rest    cell_id=${cell_list[0]}
    wait until keyword succeeds    3min    5sec    Check Alarm exsit in active Alarm    fault_id=49    alarming_object=NRCELL-${cell_list[0]}
    ...    exsit=${False}
    sleep    15min

Step4:Testing block cell trigger vdu snapshot collection failure for 3rd time
    Log to console    Step4: Testing block cell trigger vdu snapshot collection failure for 3rd time
    ${time}    Get vdu time
    ${cell_list}    vDU Get Cells ID list
    Block Cell by Rest    cell_id=${cell_list[0]}
    wait until keyword succeeds    3min    5sec    Check Alarm exsit in active Alarm    fault_id=49    alarming_object=NRCELL-${cell_list[0]}
    ...    exsit=${True}
    check upload failed in snapshot history
    Unblock Cell by Rest    cell_id=${cell_list[0]}
    wait until keyword succeeds    3min    5sec    Check Alarm exsit in active Alarm    fault_id=49    alarming_object=NRCELL-${cell_list[0]}
    ...    exsit=${False}
    wait until keyword succeeds    10min    5sec    vDU Verify All Cells Status Should Be Onair
    sleep    15min

Step5:Check Diagnostic Snapshot Collection via substring trigger for 4th time
    Log to console    Step5: Check Diagnostic Snapshot Collection via substring trigger for 4th time
    ${time}    Get vdu time
    ${cell_list}    vDU Get Cells ID list
    Recovery Snapshot Configuration to NetAct
    ${origion_bts_name}    Get Bts Name by Rest
    ${set_value}    set variable    cell state is disabled, procedure is CellInIdle
    Set Syslog Substring Trigger Value    set_value=${set_value}
    ...    operation=add
    VDU Reset Cell   cell_id=${cell_list[0]}
    wait until keyword succeeds    10min    10sec    Check Diagnostic Snapshot Collection Info
    ...    diagSnapAddInfo=substring cell state is disabled, procedure is CellInIdle trigger snapshot
    ...    diagSnapState=Collection ongoing    diagSnapFilename=${EMPTY}
    wait until keyword succeeds    10min    20sec    Check Diagnostic Snapshot Collection Info
    ...    diagSnapAddInfo=substring cell state is disabled, procedure is CellInIdle trigger snapshot
    ...    diagSnapState=Upload completed    diagSnapFilename=Snapshot_MRBTS-607_${origion_bts_name}
    wait until keyword succeeds    10min    5sec    vDU Verify All Cells Status Should Be Onair
    sleep    15min

Step6:Testing block cell trigger vdu snapshot collection failure for 5th time
    Log to console   Step6: Testing block cell trigger vdu snapshot collection failure for 5rd time
    ${time}    Get vdu time
    ${cell_list}    vDU Get Cells ID list
    Block Cell by Rest    cell_id=${cell_list[0]}
    wait until keyword succeeds    3min    5sec    Check Alarm exsit in active Alarm    fault_id=49    alarming_object=NRCELL-${cell_list[0]}
    ...    exsit=${True}
    check upload failed in snapshot history
    Unblock Cell by Rest    cell_id=${cell_list[0]}
    wait until keyword succeeds    3min    5sec    Check Alarm exsit in active Alarm    fault_id=49    alarming_object=NRCELL-${cell_list[0]}
    ...    exsit=${False}
    wait until keyword succeeds    10min    5sec    vDU Verify All Cells Status Should Be Onair