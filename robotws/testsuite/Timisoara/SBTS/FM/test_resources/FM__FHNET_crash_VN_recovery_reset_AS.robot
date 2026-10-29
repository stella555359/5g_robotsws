*** Settings ***
Documentation
    ...  This test case was created to imitate FHNET VN crash recovery reset scenario. PID of FHNET process will be found from ps -aux output.
    ...  Appropriate fields from VNU containter in IM will be checked during crash. Fault 4383, recovery request apperance and affected RMs/Cells
    ...  recoovery will be checked in seperate threads. In mean time also resoningStatus from VNU will be checked.

Library  ute_async
Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${RECOVERY_TIMEOUT}  600  # [in seconds] Timeout for SBTS to recover after FHNET crash scenario.
${ALARM_TIMEOUT}  660  # [in seconds] Timeout for alarm to appear in WebEM.
${NETACT_TIMEOUT}  120  # [in seconds] Timeout for alarm to appear in Netact.


*** Keywords ***
TC__FM__FHNET_crash_VN_recovery_reset_AS
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-12780
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 22.10.2018 - https://jira3.int.net.nokia.com/browse/TAT-12780 - Initial TAT creation
    ...  - 04.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-14435 - Support for 4+3 platform added
    ...  - 11.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15037 - Replacement of depracated KW "check_if_target_is_available"
    ...  - 14.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15267 - Removed additional space
    ...  - 18.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15307 - Allign all FM TCs with RobotFramework version 3.1.0
    ...  - 05.04.2019 - https://jira3.int.net.nokia.com/browse/TAT-15296 - Reset counter clearance moved at the TC beginning
    ...  - 28.06.2019 - https://jira3.int.net.nokia.com/browse/TAT-16740 - Change the way of historical alarms verification
    ...  - 05.05.2020 - https://jira3.int.net.nokia.com/browse/TAT-19492 - Reasoning Status is different than expected after FHNET crash
    ...  - 11.05.2020 - https://jira3.int.net.nokia.com/browse/TAT-19537 - Update expected faultName after recovery action change
    ...  - 10.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  - 14.01.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22437 - Fix for alarm canceling before reset.
    ...  - 14.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24111 - Migrate from hran_ssh to taf.transport.ssh
    ...  - 15.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24688 - Add alias to async
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  - 26.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27704 - Add option to skip RMOD power check
    ...  - 29.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28007 - Add keyword perform site reset
    ...  - 05.03.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28848 - Add additional info for 4592 after FHNET crash
    ...  - 25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29190 - Enhancement of all test cases in regression to check fault signature
    ...  - 25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29459 - Enhancement of all test cases in regression to check FS component field
    ...  - 12.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29715 - Test fails at faultsignature check
    ...  *******************

    Set Tags  CA-FM  OWNER-laura.craciunel@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS17A  FEATURE-RP001534

    Step1: Check All Required States
    Step2: Trigged FHNET VN Crash
    Step3: Verify Success Of Recovery Action


Step1: Check All Required States
    [Documentation]  In this step specific states will be checked.

    Log  \nStep1: Check all required states.  console=true
    ${sw_nodes}  Query Infomodel  get list //SW_NODE_L-* is [applicationGroup="FHNET"]  timeout=60
    ${number_of_sw_nodes}  Get Length  ${sw_nodes}
    IF  ${number_of_sw_nodes} == 0  Fail  FHNET SW_NODE does not exist in configuration.
    Perform Site Reset
    ${all_rmods_power_before_reco_reset}  Create Dictionary
    Set Test Variable  ${ALL_RMODS_POWER_BEFORE_RECO_RESET}
    ${all_rmods_power_after_reco_reset}  Create Dictionary
    Set Test Variable  ${ALL_RMODS_POWER_AFTER_RECO_RESET}
    Get All Tx Power From All RMs  ${ALL_RMODS_POWER_BEFORE_RECO_RESET}
    Set Variables For Fault Signature Check


Step2: Trigged FHNET VN Crash
    [Documentation]  In this step FHNET VN crash will be triggered.

    Log  \nStep2: Trigger FHNET VN crash.  console=true
    ${start_time}  Get Current Date  time_zone=UTC  result_format=datetime
    Set Test Variable  ${START_TIME}   ${start_time}
    Connect To SMOD  ${SMOD1['IP']}
    ${command_output}  ssh.Execute  ps aux | grep FHNET  timeout=60
    Log  Found PIDs related to FHNET: \n ${command_output}  console=true
    ${regex}  Get Regexp Matches  ${command_output}  root\\s+\\d+
    ${pid_list}  Create List
    FOR  ${item}  IN  @{regex}
        ${words}  Split String  ${item}
        ${pid}  Get From List  ${words}  1
        Append To List  ${pid_list}  ${pid}
    END

    Log  Processing FHNET VN crash.  console=true
    FOR  ${pid}  IN  @{pid_list}
        ${result}  ssh.Execute  kill -9 ${pid}  timeout=60
    END
    ${alarm_parameters}  Get String With Alarm Parameters  ${FAULT_4383_SITE_AUTO_RST}
    ${fault_status}  Run Keyword In Background  Assert Alarm Active  parameters=${alarm_parameters}  timeout=${ALARM_TIMEOUT}
    ${reset_recovery}  Start Async  ute_admin_infomodel  Query Infomodel  get list //RECOVERY_RESET_IND-*  timeout=660  alias=async1
    ${vnu_status}  Run Keyword And Return Status
    ...  Query Infomodel
    ...  get list /MRBTS-1/RAT-*//SOC_L-1/SW_NODE_L-* is [applicationGroup="FHNET", stateInfo.reasoningStatus[0]="NodeStoppedUnexpectedly"]
    ...  timeout=300
    IF  ${vnu_status}
      Log  Reasoning status is NodeStoppedUnexpectedly. [OK]  console=true
    ELSE
      Set Test Restriction  Reasoning Status is different than expected. [NOK]
    END
    ${status_fault}  ${dict_result}  Run Keyword And Ignore Error  Collect Keyword Result  ${fault_status}  timeout=${ALARM_TIMEOUT}
    ${alarm_fault_4383_site}  Save Alarm For Later Checks  ${dict_result}  ${FAULT_4383_SITE_AUTO_RST}
    Set Test Variable  ${ALARM_FAULT_4383_SITE}

    IF  '${status_fault}'=='PASS'
      Log  Fault ${FAULT_4383_SITE_AUTO_RST}[fault_id] "${FAULT_4383_SITE_AUTO_RST}[fault_name]" is visible in WebEM. [OK]  console=true
    ELSE
      Set Test Restriction  Fault ${FAULT_4383_SITE_AUTO_RST}[fault_id] "${FAULT_4383_SITE_AUTO_RST}[fault_name]" didn't occurr. [NOK]
    END
    ${status_reset_recovery}  ${async_result}  Run Keyword And Ignore Error  Wait For Async Result  alias=async1
    IF  '${status_reset_recovery}'=='FAIL'
      Set Test Restriction  Recovery Reset Indication is not visible under FRI. [NOK]
    ELSE
      Log  Recovery reset indication is visible under FRI. [OK]  console=true
    END


Step3: Verify Success Of Recovery Action
    [Documentation]  In this step verification of recovery action will be checked.

    Log  \nStep3: Verify success of recovery action after FHNET VN crash was triggered.  console=true
    ${ping_loss_status}  Run Keyword And Return Status  Wait For Target To Be Not Reachable  hostname=${SMOD1['IP']}  timeout=300
    IF  ${ping_loss_status}
      Log  SBTS is in reset now.  console=true
    ELSE
      Log  SBTS did not reset.  console=true  level=ERROR
    END
    ${ping_status}  Run Keyword And Return Status  Wait For Target To Be Reachable  hostname=${SMOD1['IP']}  timeout=300
    IF  ${ping_status}
      Log  SBTS is reachable.  console=true
    ELSE
      Log  SBTS did not recoverd from reset.  console=true  level=ERROR
    END

    Wait Until Keyword Succeeds  300s  10s  Get Fsm Info  # This is here just to check when API in online.
    IF  '${ENB_BRANCH}' >= 'SBTS24R3'  Check Fault 4592 Supplementary Alarm Information  recovery
    Log  Wait for cells to be on air.  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10  Check All Cells
    ${alarm_parameters}  Get String With Alarm Parameters  ${FAULT_4383_SITE_AUTO_RST}
    Assert Alarm Inactive  parameters=${alarm_parameters}
    Log  Alarm "${FAULT_4383_SITE_AUTO_RST}[fault_name]" is not visible after recovery action. [OK]  console=true
    Get All Tx Power From All RMs  ${ALL_RMODS_POWER_AFTER_RECO_RESET}
    Compare TXs  ${ALL_RMODS_POWER_AFTER_RECO_RESET}  ${ALL_RMODS_POWER_BEFORE_RECO_RESET}
    Admin Check Active Alarms TAF

    Log  Alarm presence will be verified in Netact.  console=true
    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}s  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4383_SITE_AUTO_RST}  time_from=${START_TIME}
    ...  additional_fault_id=${FAULT_4383_SITE_AUTO_RST}[fault_id]
    Log  Fault ${FAULT_4383_SITE_AUTO_RST} reported and cleared in Netact.  console=true
    Log  Check fault signature.  console=true
    Check Fault Signature Of Saved Alarm WebEM  saved_alarm=${ALARM_FAULT_4383_SITE}  info=${INFO}  scope=${SCOPE}  minor=${MINOR}
    ...  category=${CATEGORY}  load_name=${SW_VERSION}  reset_counter=${COUNTER}  full_product_name=${PRODUCT_NAME}  serial_number=${SERIAL_NUMBER}
    ...  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}  core_unit_position=${CORE_UNIT_POSITION}
    Check Fault Signature Of Alarm In Netact  fault_id=${FAULT_4383_SITE_AUTO_RST}[fault_id]  time_from=${START_TIME}  info=INFO:${SPACE}${INFO}
    ...  scope=SCOPE:${SPACE}${SCOPE}  minor=MINOR:${SPACE}${MINOR}  category=CATEGORY:${SPACE}${CATEGORY}  load_name=LOAD_NAME:${SPACE}${SW_VERSION}
    ...  reset_counter=RESET_COUNTER:${SPACE}${COUNTER}  full_product_name=${PRODUCT_NAME}  serial_number=${SERIAL_NUMBER}
    ...  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}  core_unit_position=${CORE_UNIT_POSITION}


Set Variables For Fault Signature Check
    ${smods_list}  coam.Get Fsm Info
    FOR  ${smod}  IN  @{smods_list}
      ${status_active_role}  Run Keyword And Return Status  Should Not Be Empty  ${smod}[activeRole]
      IF  ${status_active_role}==${FALSE}  BREAK
      IF  '${smod}[activeRole]' == 'Primary'  BREAK
    END
    Set Test Variable  ${PRODUCT_CODE}  ${smod}[productCode]
    Set Test Variable  ${PRODUCT_NAME}  ${smod}[productName]
    Set Test Variable  ${SERIAL_NUMBER}  ${smod}[serialNumber]
    Set Test Variable  ${INFO}  Node communication failure
    Set Test Variable  ${MINOR}  .*FHNET.*
    Set Test Variable  ${SCOPE}  Site
    Set Test Variable  ${CATEGORY}  TIMEOUT
    Set Test Variable  ${COUNTER}  [0-9]+
    Set Test Variable  ${EXTRA_INFO}  faulty_cells=(.*GSM:[0-9]+.*,)?(.*WCDMA:[0-9]+.*,)?(.*LTE:[0-9]+.*,)?(.*NR:[0-9]+.*,)?.*
    Set Unit Position For Fault Signature  ${smod}[id][internal]


TC Setup
    Common Test Setup  tc_name=FM__FHNET_crash_VN_recovery_reset_AS
    Setup NetAct


TC Teardown
    Teardown NetAct
    Common Test Teardown
