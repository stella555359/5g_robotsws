*** Settings ***
Documentation
    ...  This test case was created to trigger LTE L3Pool VN crash and recovery action multiple times
    ...  to verify the counter increment and reset after manual site reset.
    ...  To imitate LTE L3Pool VN crash recovery reset scenario the PID of L3Pool process will be found from ps -aux output.
    ...  Appropriate fields from VNU containter in IM will be checked during crash. Fault 4383 and recovery request apperance
    ...  will be checked in seperate threads. Meantime also resoningStatus from VNU will be checked.

Library  ute_async
Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${RECOVERY_TIMEOUT}  180  # Timeout for SBTS to recover after L3Pool VN crash scenario
${STARTUP_TIMEOUT}  300  # Timeout for SBTS to recover after site reset


*** Keywords ***
TC__FM__VN_recovery_reset_counter_cleared_-_manual_site_reset
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-10464
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 07.06.2018  - https://jira3.int.net.nokia.com/browse/TAT-10464 - Initial TAT creation
    ...  - 19.06.2020  - https://jira3.int.net.nokia.com/browse/TAT-19746 - Move keywords to resource file
    ...  - 24.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  - 28.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23842 - Remove Test Specific Teardown and Setup
    ...  - 17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  - 25.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26232 - Improvement for test approach
    ...  - 05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  - 29.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28007 - Add keyword perform site reset
    ...  - 25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29190 - Enhancement of all test cases in regression to check fault signature
    ...  - 25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29459 - Enhancement of all test cases in regression to check FS component field
    ...  - 01.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29773 - Enhancement minor field does not match
    ...  *******************

    Set Tags  CA-FM  OWNER-laura.craciunel@nokia.com  AUTHOR-laura.craciunel@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS20  FEATURE-RP001534

    Step0: Check All Required States
    Step1: Trigged LTE L3Pool VN Crash
    Step2: Perform Site Reset To Clear Counters
    FOR  ${loop}  IN RANGE  0  3
        Step1: Trigged LTE L3Pool VN Crash
    END


Step0: Check All Required States
    Log  \nStep0: Check all required states.  console=true
    Check Which Core Is Primary
    ${sm_variant}  Get SM Variant FM
    Set Test Variable  ${SM_VARIANT}
    Log  Check actForceAutoReset and change it to true if needed.  console=true
    ${initial_value}  Get ActForce(Unit)AutoReset Value From Infomodel  actForceAutoReset
    ${list}  Create List  actForceAutoReset
    ${object}  Get Parameter By Distname  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1  ${list}
    ${initial_value}  Set Variable  ${object}[0][parameters][actForceAutoReset]
    Set Test Variable  ${INITIAL_VALUE}
    Change FMCADM Parameter  actForceAutoReset  true
    ${vnu_l}  Query Infomodel  get list /MRBTS-1/RAT-*//SOC_L-1/SW_NODE_L-* is [rat="LTE", applicationGroup="DistributedCPlane"]  timeout=60
    ${list_length}  Get Length  ${vnu_l}
    Log  Suitable LTE DistributedCPlane found in configuration are :\n ${vnu_l} \n  console=true
    ${crashed_vn}  Evaluate  random.randint(0, ${list_length}-1)  modules=random
    Log  Random index chosen from list is : ${crashed_vn}.  console=true
    Set Test Variable  ${ELEMENT}  ${vnu_l[${crashed_vn}]}
    Set Fault Signature Variables


Step1: Trigged LTE L3Pool VN Crash
    Log  \nStep1: Trigger LTE L3Pool VN crash.  console=true
    ${start_time}  Get Current Date  time_zone=UTC  result_format=datetime
    ${node_id}  Convert To Hex  ${ELEMENT.nodeId}  prefix=0x
    ${low_node_id}  Convert To Lowercase  ${node_id}
    Crash VN On AirScale  ${ELEMENT}  ${low_node_id}

    ${vnu_status}  Query Infomodel  get list ${ELEMENT.dist_name} is [stateInfo.reasoningStatus[0]="NodeStoppedUnexpectedly"]  timeout=300
    ${fault_4383_params}  Get String With Alarm Parameters  ${FAULT_4383_PROCESSES_AUTO_RST}
    Setup Admin  bts_host=192.168.255.129  bts_port=443  use_ssl=True  alias=fault
    ${fault_status}  Run Keyword In Background  Assert Alarm Active  parameters=${fault_4383_params}  timeout=660  alias=fault
    ${reset_recovery}  Start Async  ute_admin_infomodel  Query Infomodel  get list //RECOVERY_RESET_IND-*  timeout=660  alias=recovery
    IF  ${vnu_status}
      Log  Reasoning status is NodeStoppedUnexpectedly. [OK]  console=true
    ELSE
      Set Test Restriction  Reasoning status is different than expected. [NOK]
    END

    ${status_fault}  Run Keyword And Return Status  Collect Keyword Result  ${fault_status}  timeout=660
    Should Be True  ${status_fault}  Fault 4383 "${FAULT_4383_PROCESSES_AUTO_RST}[fault_name]" didn't occurr.
    Log  Fault 4383 "${FAULT_4383_PROCESSES_AUTO_RST}[fault_name]" occured.  console=true
    ${status_reset_recovery}  ${async_result}  Run Keyword And Ignore Error  Wait For Async Result  alias=recovery
    IF  '${status_reset_recovery}'=='FAIL'
      Set Test Restriction  Recovery reset indication is not visible under FRI. [NOK]
    ELSE
      Log  Recovery reset indication is visible uder FRI. [OK]  console=true
    END
    Stop Async  alias=recovery
    Run Keyword And Continue On Failure  Teardown Admin  alias=fault

    Check WCDMA Cells  ${ACTIVE}  ${ENABLED}
    Check GSM Cells  ${ACTIVE}  ${ENABLED}
    Assert Alarm Inactive  parameters=${fault_4383_params}
    Log  Fault 4383 "${FAULT_4383_PROCESSES_AUTO_RST}[fault_name]" is not visible after recovery action.  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT} sec  65 sec  Check All Cells

    Log  Check fault signature.  console=true
    Check Fault Signature Of Alarm In WebEM  fault_id=${FAULT_4383_PROCESSES_AUTO_RST}[fault_id]  category=${CATEGORY}  info=${INFO}  scope=${SCOPE}
    ...  load_name=${SW_VERSION}  minor=${MINOR}  reset_counter=${RESET_COUNTER}  full_product_name=${PRODUCT_NAME}  serial_number=${SERIAL_NUMBER}
    ...  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}  core_unit_position=${CORE_UNIT_POSITION}
    Check Fault Signature Of Alarm In Netact  fault_id=${FAULT_4383_PROCESSES_AUTO_RST}[fault_id]  time_from=${start_time}
    ...  category=CATEGORY:${SPACE}${CATEGORY}  info=INFO:${SPACE}${INFO}  scope=SCOPE:${SPACE}${SCOPE}  load_name=LOAD_NAME:${SPACE}${SW_VERSION}
    ...  minor=MINOR:${SPACE}${MINOR}  reset_counter=RESET_COUNTER:${SPACE}${RESET_COUNTER}  full_product_name=${PRODUCT_NAME}
    ...  serial_number=${SERIAL_NUMBER}  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}  core_unit_position=${CORE_UNIT_POSITION}


Step2: Perform Site Reset To Clear Counters
    Log  \nStep2: Site reset will be performed to clear all counters.  console=true
    Perform Site Reset


Set Fault Signature Variables
    ${node_id}  Convert To Hex  ${ELEMENT}[nodeId]  prefix=0x
    ${node_id}  Convert To Lower Case  ${node_id}
    ${is_ccu}  Run Keyword And Return Status  Should Contain  ${ELEMENT}[dist_name]  CCU
    ${is_bbu}  Run Keyword And Return Status  Should Contain  ${ELEMENT}[dist_name]  BBU
    ${is_board}  Run Keyword And Return Status  Should Contain  ${ELEMENT}[dist_name]  BOARD
    ${string}  Set Variable If
    ...  ${is_ccu}  /CCU
    ...  ${is_bbu}  /BBU
    ...  ${is_board}  /BOARD
    ${module_l_dn}  Fetch From Left  ${ELEMENT}[dist_name]  ${string}
    ${module_l_parameters}  coam.Get Parameters  ${module_l_dn}
    ${is_smod}  Run Keyword And Return Status  Should Contain  ${module_l_dn}  SMOD
    ${is_bbmod}  Run Keyword And Return Status  Should Contain  ${module_l_dn}  BBMOD
    ${module_type}  Set Variable If
    ...  ${is_smod}  SMOD
    ...  ${is_bbmod}  BBMOD
    ${module_r_dn}  Get Module Dist Name By Serial Number And Class  ${module_l_parameters}[serialNumber]  ${module_type}
    Set Test Variable  ${PRODUCT_NAME}  ${module_l_parameters}[productName]
    Set Test Variable  ${SERIAL_NUMBER}  ${module_l_parameters}[serialNumber]
    Set Test Variable  ${PRODUCT_CODE}  ${module_l_parameters}[productCode]
    Set Unit Position For Fault Signature  ${module_r_dn}
    Set Test Variable  ${CATEGORY}  SW_FAILURE
    Set Test Variable  ${INFO}  CCS supervised command exited.*
    Set Test Variable  ${MINOR}  .*${node_id}
    Set Test Variable  ${RESET_COUNTER}  [0-9]+
    Set Test Variable  ${SCOPE}  Virtual Node


TC Setup
    Common Test Setup  tc_name=FM__VN_recovery_reset_counter_cleared_manual_site_reset
    Setup NetAct


TC Teardown
    Run Keyword And Ignore Error
    ...  Change Parameter ActForce(Unit)AutoReset  ${INITIAL_VALUE}  actForceAutoReset
    Step2: Perform Site Reset To Clear Counters
    Teardown NetAct
    Common Test Teardown
