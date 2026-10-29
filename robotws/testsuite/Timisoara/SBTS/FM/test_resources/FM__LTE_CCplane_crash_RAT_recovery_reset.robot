*** Settings ***
Documentation
    ...  This test case was created to imitate CCplane crash RAT recovery reset scenario.
    ...  PID of CCplane process will be found from lxc-attach -n$(hex_node_id) and kill -9 20.

Library  ute_async
Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${RECOVERY_TIMEOUT}  300  # [in seconds] Timeout for SBTS to recover after crash scenario
${NETACT_TIMEOUT}  180  # [in seconds] Timeout for alarm to be reported in Netact


*** Keywords ***
TC__FM__LTE_CCplane_crash_RAT_recovery_reset
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-10140
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  15.05.2018 - https://jira3.int.net.nokia.com/browse/TAT-10140 - Initial TAT creation
    ...  09.04.2020 - https://jira3.int.net.nokia.com/browse/TAT-19328 - Remove VNU_L and replace it with SW_NODE_L
    ...  19.06.2020 - https://jira3.int.net.nokia.com/browse/TAT-19746 - Move keywords to resource file
    ...  09.11.2021 - https://jira3.int.net.nokia.com/browse/TAT-22019 - Modify for configuration with 4G and NR on same ABIO
    ...  24.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  14.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24111 - Migrate from hran_ssh to taf.transport.ssh
    ...  17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  21.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26964 - Support for CB008880 check actRatResetEnhancement=FALSE
    ...  01.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27018 - Skip parameter change for older sw releases
    ...  19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  26.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27704 - Add option to skip RMOD power check
    ...  29.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28007 - Add keyword perform site reset
    ...  11.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28355 - Add check for CB010846
    ...  15.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27608 - Add check for fault signature
    ...  14.01.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28614 - Test fails when changing parameter
    ...  25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29190 - Enhancement of all test cases in regression to check fault signature
    ...  25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29459 - Enhancement of all test cases in regression to check FS component field
    ...  *******************

    Set Tags  CA-FM  OWNER-laura.craciunel@nokia.com  AUTHOR-piotr.szlegel@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS17A  FEATURE-RP001534  FEATURE-CB008880  FEATURE-CB010846

    Step0: Check All Required States
    Step1: Triger CCplane Crash
    Step2: Check Fault Signature
    Step3: Check BTS After Test Steps


Step0: Check All Required States
    [Documentation]  This step provides check all preconditions like - commisioned technology - LTE, actForceAutoReste - FALSE
    ...   Site reset is performed to clear all reset counters.

    Log  \nStep:0 Check all required states.  console=true
    Check Commissioned Technologies  LTE
    Perform Site Reset
    Check Links Status  Available
    Check Which Core Is Primary
    ${all_rmods_power_before_reco_reset}  Create Dictionary
    Set Test Variable  ${ALL_RMODS_POWER_BEFORE_RECO_RESET}
    ${all_rmods_power_after_reco_reset}  Create Dictionary
    Set Test Variable  ${ALL_RMODS_POWER_AFTER_RECO_RESET}
    Get All Tx Power From All RMs  ${ALL_RMODS_POWER_BEFORE_RECO_RESET}
    Check Links Status  Available
    Set Test Parameters
    ${list}  Create List  actForceAutoReset
    ${object}  Get Parameter By Distname  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1  ${list}
    ${initial_value}  Set Variable  ${object}[0][parameters][actForceAutoReset]
    Set Test Variable  ${INITIAL_VALUE}
    Log  Check actForceAutoReset and change for FALSE if needed.  console=true
    Change FMCADM Parameter  actForceAutoReset  false
    ${date}  Get Current Date  time_zone=UTC  result_format=datetime
    Set Test Variable  ${START_TIME}  ${date}


Step1: Triger CCplane Crash
    [Documentation]  In this step LTE CCplane VN crash will be triggered.

    Log  \nStep1: Trigger LTE CCplane VN crash.  console=true

    ${vnu_l}  Query Infomodel  get list /MRBTS-1/RAT-*//SOC_L-1/SW_NODE_L-* is [rat="LTE", applicationGroup="CentralCPlane"]  timeout=60
    ${element}  Get From List  ${vnu_l}  0
    Set Test Variable  ${ELEMENT}
    ${node_id}  Convert To Hex  ${element.nodeId}  prefix=0x
    ${low_node_id}  Convert To Lowercase  ${node_id}
    ${ru_uptime_before_crash}  Get CPRI And ECPRI RMODS Uptime
    Set Test Variables For Fault Signature In LTE CCplane crashes
    Setup Admin  bts_host=192.168.255.129  bts_port=443  use_ssl=True  alias=fault
    Crash VN  ${element}  ${low_node_id}

    ${fault_4383_params}  Get String With Alarm Parameters  ${FAULT_4383_RAT_AUTO_RST}
    ${fault_status}  Run Keyword In Background  Assert Alarm Active  parameters=${fault_4383_params}  timeout=90  alias=fault
    Start Async  ute_admin_infomodel  Query Infomodel  get list //RECOVERY_RESET_IND-*  timeout=660  alias=recovery
    ${vnu_status}  Run Keyword And Return Status
    ...  Query Infomodel  get list ${element.dist_name} is [stateInfo.reasoningStatus[0]="NodeStoppedUnexpectedly"]  timeout=300
    IF  ${vnu_status}
      Log  Reasoning status is NodeStoppedUnexpectedly. [OK]  console=true
    ELSE
      Set Test Restriction  message=Reasoning Status is different than expected. [NOK]
    END

    ${status_fault}  Run Keyword And Return Status  Collect Keyword Result  ${fault_status}  timeout=660
    Should Be True  ${status_fault}  Fault ${FAULT_4383_RAT_AUTO_RST} was not visible in WebEM. [NOK]
    Log  Fault ${FAULT_4383_RAT_AUTO_RST} is visible in WebEM. [OK]  console=true

    ${status_reset_recovery}  ${async_result}  Run Keyword And Ignore Error  Wait For Async Result  alias=recovery
    IF  '${status_reset_recovery}'=='FAIL'
      Set Test Restriction  Recovery Reset Indication is not visible under FRI. [NOK]
    ELSE
      Log  RAT reset indication is visible uder FRI. [OK]  console=true
    END
    Stop Async  alias=recovery
    Run Keyword And Continue On Failure  Teardown Admin  alias=fault
    IF  ${SCF_COUNT_WCDMA}  Check WCDMA Cells  ${ACTIVE}  ${ENABLED}
    IF  ${SCF_COUNT_GSM}  Check GSM Cells  ${ACTIVE}  ${ENABLED}

    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT} sec  65 sec  Check All Cells
    Assert Alarm Inactive  parameters=${fault_4383_params}
    Log  Fault ${FAULT_4383_RAT_AUTO_RST} is not visible after recovery action. [OK]  console=true
    Get All Tx Power From All RMs  ${ALL_RMODS_POWER_AFTER_RECO_RESET}
    Compare TXs  ${ALL_RMODS_POWER_AFTER_RECO_RESET}  ${ALL_RMODS_POWER_BEFORE_RECO_RESET}
    Admin Check Active Alarms TAF
    Check CPRI And ECPRI Did Not Reset  ${ru_uptime_before_crash}

    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  30
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4383_RAT_AUTO_RST}  time_from=${START_TIME}
    ...  additional_fault_id=${FAULT_4383_RAT_AUTO_RST}[fault_id]
    Log  Fault ${FAULT_4383_RAT_AUTO_RST} reported and cleared in Netact.  console=true


Step2: Check Fault Signature
    [Documentation]  This step is checking fault signature in alarm.

    Log  \nStep2: Check fault signature.  console=true
    Check Fault Signature Of Alarm In WebEM  fault_id=${EXPECTED_FAULT_ID}  category=${CATEGORY}  extra_info=${EXTRA_INFO}  info=${INFO}
    ...  load_name=${SW_VERSION}  minor=${MINOR}  reset_counter=${RESET_COUNTER}  scope=${SCOPE}  full_product_name=${PRODUCT_NAME}
    ...  serial_number=${SERIAL_NUMBER}  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}  core_unit_position=${CORE_UNIT_POSITION}
    Check Fault Signature Of Alarm In Netact  fault_id=${EXPECTED_FAULT_ID}  time_from=${START_TIME}  category=CATEGORY:${SPACE}${CATEGORY}
    ...  extra_info=EXTRA_INFO:${SPACE}${EXTRA_INFO}  info=INFO:${SPACE}${INFO}  load_name=LOAD_NAME:${SPACE}${SW_VERSION}
    ...  minor=MINOR:${SPACE}${MINOR}  reset_counter=RESET_COUNTER:${SPACE}${RESET_COUNTER}  scope=SCOPE:${SPACE}${SCOPE}
    ...  full_product_name=${PRODUCT_NAME}  serial_number=${SERIAL_NUMBER}  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}
    ...  core_unit_position=${CORE_UNIT_POSITION}


Step3: Check BTS After Test Steps
    [Documentation]  This step is checking all cells after recovery action. ActForceAutoReset set to initial state.

    Log  \nCheck BTS after test steps  console=true
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT} sec  65 sec  Check All Cells
    Log  \nactForceAutoReset Initial state  console=true
    Change FMCADM Parameter  actForceAutoReset  ${INITIAL_VALUE}


Crash VN
    [Documentation]  This KW is created to crash VN using kill-9 <PID> command.
    [Arguments]  ${vnu_dist_name}  ${low_node_id}

    Log  ${vnu_dist_name.dist_name}  console=true
    ${status}  Run Keyword And Return Status  Should Not Contain  ${vnu_dist_name.dist_name}  ${PRIMARY_CORE_BTS_L}
    IF  ${status}
      Set Test Variable  ${SMOD}  192.168.255.119
    ELSE
      Set Test Variable  ${SMOD}  192.168.255.129
    END
    Connect To SMOD  ${SMOD}
    ${result}  ssh.Execute  lxc-attach -n ${low_node_id} ps aux | grep btssw
    ${regex}  Get Regexp Matches  ${result}  btssw\\s+\\d+
    ${length_list}  Get Length  ${regex}
    ${random_regex}  Evaluate  random.randint(0, ${length_list}-1)  modules=random
    ${from_list}  Get From List  ${regex}  ${random_regex}
    ${words}  Split String  ${from_list}
    ${process_id}  Get From List  ${words}  1
    ssh.Execute  lxc-attach -n ${low_node_id} -- bash -c '{ sleep 1; } | kill -9 ${process_id}'


Set Test Parameters
    Log  Set parameters for test.  console=true
    ${break_time_value}  Set Variable If  '${ENB_BRANCH}' >= 'SBTS25R2'  220  180
    IF  '${ENB_BRANCH}'>='SBTS24R2' or '${ENB_BRANCH}'=='SBTS00'  Change FEATCADM Parameter  actRatResetEnhancement  false
    IF  '${ENB_BRANCH}'>='SBTS25R1' or '${ENB_BRANCH}'=='SBTS00'  Change FEATCADM Parameter  actRuResetResiliency  true
    IF  '${ENB_BRANCH}'>='SBTS25R1' or '${ENB_BRANCH}'=='SBTS00'  Change FEATCADM Parameter  cntrldResetMplaneBreakTime   ${break_time_value}


TC Setup
    Common Test Setup  tc_name=FM__LTE_CCplane_crash_RAT_recovery_reset
    Setup NetAct

TC Teardown
    Teardown NetAct
    Common Test Teardown
