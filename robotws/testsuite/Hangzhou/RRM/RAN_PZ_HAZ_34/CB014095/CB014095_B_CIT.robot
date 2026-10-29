*** Settings ***
Documentation
...         author: Shushu Huang
...         contact: shushu.huang@nokia.com
...         squad group: NSB MN RAN RD VRF HAZ 4
...         CB014095 CRT

Suite Setup    Run keywords    robot_common_operations.Common Suite Setup
...    AND    Wait For GNSS Update To Complete
...    AND    CI_interface.Common Suite Setup
Suite Teardown    robot_common_operations.Common Suite Teardown


Library    OperatingSystem
Resource    ./Resources/CB014095_Common_Keywords.robot
Library    taf.sbts.oam.coam.admin   WITH NAME   admin_cli

*** Variables ***
${MRBTS_ID}                  ${tl.gnbs[0].instance_id}
${NRBTS_ID}                  ${tl.gnbs[0].global_bts_id}
${cell12}     68719475340
${CELL_ID}    12
${connection}    COAM
${NRPGRP-111}    ${CURDIR}/Resources/ADD_NRPGRP.json


*** Test Cases ***
[1]CB014095-B_B2_Online activation of NRBTS.actNrLBmMimoRTXPowerSaving parameter
    [Tags]    HAZ3_T03
    [Setup]    Test Case setup
    Prepare for CB014095
    step1: Check CB014095 status
    step2: Configuration the NRPGRP-111
    step3: UE attach and start DL traffic
    step4: Modify the parameter actNrLBmMimoRTXPowerSaving
    step5: Check the Energy saving state
    step6: Check the L3 call status
    [Teardown]    Test teardown



*** Keywords ***
Prepare for CB014095
    log to console    "Scf commission and  Add Test Flags "
    Scf commission and wait on-air    scf_name=SCF_SBTS00_CB014095.xml
    Add Test Flags To Swconfig

step1: Check CB014095 status
    log to console    "step1: Check CB014095 status"
    Check CB014095 status    json_name=CP_beamSet_2_4294967208_${cell12}.json
    [teardown]    Run Keyword And Ignore error    COAM Logout

step2: Configuration the NRPGRP-111
    log to console    "step2: Configuration the NRPGRP-111"
    Conect to DU COAM
    Update LbpsPeriodList With Current Time
    ${run_status}    run keyword and return status    Wait Until Keyword Succeeds   10m   1m   COAM Check BTS All Cells Onair
    ${alarm_status}    run keyword and return status    Check No Unexpected Active Alarm
    ${history_alarm_status}  run keyword and return status    Check No Unexpected History Alarm
    ${alarm_status}  Evaluate  ${alarm_status} and ${history_alarm_status}
    ${status}    Set Variable If    "${run_status}"=="True" and "${alarm_status}"=="True"    pass    fail
    ${snapshot_file}    Run Keyword If    '${status}'=='fail'    Run Keyword And Ignore error    Collect snapshot logs
    Should Be Equal    ${status}    pass
    [teardown]    Run Keyword And Ignore error    COAM Logout

step3: UE attach and start DL traffic
    L3 call setup for CB014095
    Start Traffic DL for CB014095

step4: Modify the parameter actNrLBmMimoRTXPowerSaving
    log to console    "step4： Modify the parameter actNrLBmMimoRTXPowerSaving"
    Conect to DU COAM
    Set parameter    key=actNrLBmMimoRTXPowerSaving    value=${true}    dict_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    ${run_status}    run keyword and return status    Wait Until Keyword Succeeds   10m   1m   COAM Check BTS All Cells Onair
    ${alarm_status}    run keyword and return status    Check No Unexpected Active Alarm
    ${history_alarm_status}  run keyword and return status    Check No Unexpected History Alarm
    ${alarm_status}  Evaluate  ${alarm_status} and ${history_alarm_status}
    ${status}    Set Variable If    "${run_status}"=="True" and "${alarm_status}"=="True"    pass    fail
    ${snapshot_file}    Run Keyword If    '${status}'=='fail'    Run Keyword And Ignore error    Collect snapshot logs
    Should Be Equal    ${status}    pass
    [teardown]    Run Keyword And Ignore error    COAM Logout

step5: Check the Energy saving state
    log to console    "step5: Check the Energy saving state"
    ${run_status}    run keyword and return status    Wait Until Keyword Succeeds   10m   1m   Check TX muting Status
    ${alarm_status}    run keyword and return status    Check No Unexpected Active Alarm
    ${history_alarm_status}  run keyword and return status    Check No Unexpected History Alarm
    ${alarm_status}  Evaluate  ${alarm_status} and ${history_alarm_status}
    ${status}    Set Variable If    "${run_status}"=="True" and "${alarm_status}"=="True"    pass    fail
    ${snapshot_file}    Run Keyword If    '${status}'=='fail'    Run Keyword And Ignore error    Collect snapshot logs
    Should Be Equal    ${status}    pass
    [teardown]    Run Keyword And Ignore error    COAM Logout

step6: Check the L3 call status
    Check power ue Tput for CB014095    dl_throughput=100    cell1=${cell12}

Wait For GNSS Update To Complete
    [Documentation]    Wait for GNSS firmware upgrade fault 4420 to clear before commissioning in Suite Setup
    log to console    Checking if GNSS SW update fault 4420 is active...
    Connect to gnb coam via ssl    connection=${connection}
    Wait Until Keyword Succeeds    30m   3m    Verify Fault 4420 Is Absent    connection=${connection}
    Run Keyword And Ignore Error    COAM Logout

Verify Fault 4420 Is Absent
    [Documentation]    Verify that GNSS SW update fault 4420 is not active
    [Arguments]    ${connection}=${connection}
    log to console    Check if GNSS SW updating
    @{alarms}    coam.get_active_alarms    connection=${connection}
    FOR    ${alarm}    IN    @{alarms}
        Should Be True    ${alarm['faultId']} != 4420
    END

Test teardown
    Run Keyword And Ignore Error    Stop Traffic And Detach UE
    Run Keyword And Ignore Error    Remove Test Flags From Swconfig
    Run Keyword And Ignore Error    Suite Teardown with SCF
    robot_common_operations.Common Case Teardown
    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}
    CI_interface.Common Case Teardown

Suite Teardown with SCF
    log to console    Suite Teardown with SCF
    Scf commission and wait on-air    scf_name=SCF_SBTS00.xml