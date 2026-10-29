*** Settings ***
Documentation
    ...  The purpose of this test case is to verify that site and unit recovers back to operational state after some application is killed from FCM.

Library  SSHLibrary
Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
@{SPURIOUS_RES_APPS}  Create List  BTSOMexe  bm  SysAdapter
${PROCESS_NAME}  RROMexe
${ENB_ROOT_USER}  toor4nsn
${ENB_ROOT_PASS}  oZPS0POrRieRtu


*** Keywords ***
TC__FM__Ping_lost_between_node_CCandS_and_application_FSM_RROM
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-21651
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  -  24.09.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21651 - TAT to adapt the test from docker to HRAN_TA
    ...  -  10.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  -  08.02.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22602 - FM__Ping_lost_between_node_CCandS_and_application_FSM_RROM is failed
    ...  -  14.03.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22779 - Fix for cells check
    ...  -  17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  -  05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  -  05.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27299 - Add fault for watchdog monitoring
    ...  *******************

    Set Tags  CA-FM  OWNER-laura.craciunel@nokia.com  AUTHOR-valentin.suru@nokia.com  MAINTAINER-valentin.suru@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf
    ...  PHASE-CRT  SW-SBTS20  FEATURE-RP001534

    Step1: Check ENB State
    Step2: Kill RROMexe Process
    Step3: Check ENB State After Reset


Step1: Check ENB State
    [Documentation]  This step checks eNB is onAir and no unallowed alrms are visible

    Log  Step 1: Check all required states.  console=true
    Check If Cells OnAir Or PowerSaving Enabled
    Check GSM And WCDMA Cells Are Enabled
    Admin Check Active Alarms TAF


Step2: Kill RROMexe Process
    [Documentation]  Login by SSHLibrary to MPlane and kill the process RROMexe followed by eNB state check.

    Log  Step 2: Kill RROMexe process.  console=true
    Kill Process  ${PROCESS_NAME}
    Check Required State And Alarm
    Wait Until Keyword Succeeds  10x  1min
    ...  Check If Cells OnAir Or PowerSaving Enabled


Step3: Check ENB State After Reset
    [Documentation]  This step checks eNB is onAir and no unallowed alrms are visible

    Log  Step3: Check eNB state after reset.  console=true
    ${check_all_cells}  Run Keyword And Return Status
    ...  Check All Cells  ${ON_AIR_DONE}  ${ENABLED}  ${ACTIVE}
    Run Keyword If  ${check_all_cells}
    ...  Log  All cells are enabled after reset.  console=true
    ...  ELSE
    ...  Set Test Restriction  Not all cells are enabled after reset.
    Admin Check Active Alarms TAF


Kill Process
    [Arguments]  ${process_name}

    SSHLibrary.Open Connection  host=${MPLANE_IP}
    Sleep  5s
    SSHLibrary.Login  username=${ENB_ROOT_USER}  password=${ENB_ROOT_PASS}
    Sleep  5s
    SSHLibrary.Execute Command  killall -9 ${process_name}


Check GSM And WCDMA Cells Are Enabled
    Run Keyword If  ${SCF_COUNT_GSM}
    ...  Assert Every  GNCEL  operationalState=${ENABLED}  timeout=90
    Run Keyword If  ${SCF_COUNT_WCDMA}
    ...  Assert Every  WNCEL  operationalState=${ENABLED}  timeout=90


Check Required State And Alarm
    Log  Check eNB state and active alarms.  console=true
    ${fault_parameters}  Get String With Alarm Parameters  ${FAULT_4383_RAT_AUTO_RST}
    ${status_fault}  Run Keyword And Return Status
    ...  Assert Alarm Active  parameters=${fault_parameters}  timeout=90
    ${status_check_cells}  Run Keyword And Return Status
    ...  Check Cell State
    Run Keyword If  ${status_fault}
    ...  Log  Fault 4383 "${FAULT_4383_RAT_AUTO_RST}[fault_name]" occured [OK]  console=TRUE
    ...  ELSE
    ...  Set Test Restriction  Fault 4383 with name "${FAULT_4383_RAT_AUTO_RST}[fault_name]" didn't occurr [NOK]
    Run Keyword If  ${status_check_cells}
    ...  Log  Cell status as expected after reset [OK]  console=TRUE
    ...  ELSE
    ...  Set Test Failed  Incorrect cell status after reset [NOK]


Check Cell State
    Run Keyword If  ${SCF_COUNT_LTE}
    ...  Assert Every  LNCEL  operationalState=${DISABLED}  timeout=90
    Run Keyword If  ${SCF_COUNT_WCDMA}
    ...  Assert Every  WNCEL  operationalState=${ENABLED}  timeout=90
    Run Keyword If  ${SCF_COUNT_GSM}
    ...  Assert Every  GNCEL  operationalState=${ENABLED}  timeout=90
    Run Keyword If  ${SCF_COUNT_NR}
    ...  Assert Every  NRCEL  operationalState=${ENABLED}  timeout=90


TC Setup
    Common Test Setup  tc_name=FM__Ping_lost_between_node_CCandS_and_app_FSM_RROM


TC Teardown
    Common Test Teardown
