*** Settings ***
Documentation
...         author: Shushu Huang
...         contact: shushu.huang@nokia.com
...         squad group: NSB MN RAN RD VRF HAZ 4
...         CB014095 CRT

Suite Setup    Run keywords    robot_common_operations.Common Suite Setup    AND    CI_interface.Common Suite Setup
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
[1]CB04095-B
    [Tags]    HAZ3_T03
    [Setup]    Test Case setup
    Add Test Flags To Swconfig
    step1: Check CB014095 status
    step2: Configuration the NRPGRP-111
    step3: UE attach and start DL traffic
    step4: Modify the parameter actNrLBmMimoRTXPowerSaving
    step5: Check the Energy saving state
    step6: Check the L3 call status
    [Teardown]    Test teardown



*** Keywords ***
step1: Check CB014095 status
    log to console    "step1: Check CB014095 status"
    Check CB014095 status    json_name=CP_beamSet_6_10578_173309957.json
    [teardown]    Run Keyword And Ignore error    COAM Logout

step2: Configuration the NRPGRP-111
    log to console    "step2: Configuration the NRPGRP-111"
    Conect to DU COAM
    admin_cli.perform_delta_recommissioning    delta_file=${NRPGRP-111}
    ...    skip_parameter_relation_errors=True    should_activate=True    timeout=600    connection=COAM
    Update LbpsPeriodList With Current Time
    Wait Until Keyword Succeeds   10m   1m   COAM Check BTS All Cells Onair
    [teardown]    Run Keyword And Ignore error    COAM Logout

step3: UE attach and start DL traffic
    L3 call setup for CB014095
    Start Traffic DL for CB014095

step4: Modify the parameter actNrLBmMimoRTXPowerSaving
    log to console    "step4： Modify the parameter actNrLBmMimoRTXPowerSaving"
    Conect to DU COAM
    Set parameter    key=actNrLBmMimoRTXPowerSaving    value=${true}    dict_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}
    Wait Until Keyword Succeeds   10m   1m   COAM Check BTS All Cells Onair
    [teardown]    Run Keyword And Ignore error    COAM Logout

step5: Check the Energy saving state
    log to console    "step5: Check the Energy saving state"
    wait until keyword succeeds   10m   1m    Check TX muting Status

step6: Check the L3 call status
    Check power ue Tput for CB014095    dl_throughput=100    cell1=${173309957}



Test teardown
    Remove Test Flags From Swconfig
    Run Keyword And Ignore Error    Stop Traffic And Detach UE
    robot_common_operations.Common Case Teardown
    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}
    CI_interface.Common Case Teardown