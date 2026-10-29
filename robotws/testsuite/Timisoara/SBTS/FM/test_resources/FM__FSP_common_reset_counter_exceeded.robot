*** Settings ***
Documentation
    ...  Test case will verify handling of FSP power reset and warm resets are counted together.
    ...  Testing will involve provoking multiple faulty situations to check if autonomous recovery actions are selected,
    ...  handled and reported by sOAM in line with specification.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${BBMOD_TYPE}  ${EMPTY}  # Optional. BBMOD type for test.
${STARTUP_TIMEOUT}  900  # [in seconds] Timeout for SBTS to recover after site reset.
${RECOVERY_TIMEOUT}  600  # [in seconds] Timeout for SBTS to recover after test scenario.
${ALARM_TIMEOUT}  300  # [in seconds] Timeout for alarm to appear in WebEM.
${NETACT_TIMEOUT}  60  # [in seconds] Timeout for alarm to appear in Netact.


*** Keywords ***
TC__FM__FSP_common_reset_counter_exceeded
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25764
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  14.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25764 - Initial TAT creation
    ...  29.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26175 - Fix for master on right side
    ...  02.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26377 - Update query based board
    ...  14.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26439 - Enhancement for alarm check in Netact
    ...  15.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25658 - Create new resources for NetAct and ONAP KWs
    ...  29.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26527 - Testcase does not catch active alarm in Netact
    ...  05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  17.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27606 - Multiple keywords for checking fault signature in FM testcases
    ...  05.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27779 - Add check fault 4592 supplementary info
    ...  13.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27947 - Check FID 4753 only for newer releases
    ...  08.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28207 - Fix verification for BBMODs
    ...  31.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28025 - Enhancement for verifying additonalFaultID in NetAct
    ...  27.03.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28938 - Move keyword to resource
    ...  27.06.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29365 - Enhancement for CB008708
    ...  04.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29516 - Skip CB008708 for software versions below 25R3
    ...  16.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30319 - Added maintenance window cleanup in case the test failed
    ...  24.01.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30440 - Add alarm 4352 check on secondary core
    ...  ******************

    Set Tags  CA-FM  OWNER-nanciu.dragos@nokia.com  AUTHOR-laura.craciunel@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf
    ...  PHASE-CRT  SW-SBTS23  FEATURE-CB010883  FEATURE-CB007964-SR-A

    Step0: Set Test Variables
    Step1: Trigger FSP Warm Reset With Fault 2078
    Step2: Trigger FSP Warm Reset With Fault 2078
    Step3: Trigger FSP Power Reset With Fault 2078
    Step4: Trigger Fourth Fault 2078
    Step5: Activate Maintenance Window
    Step6: Deactivate Maintenance Window
    Step7: Perform Site Reset To Recover Services


Step0: Set Test Variables
    Log  \nStep0: Set test variables.  console=true
    IF  '${ENB_BRANCH}' >= 'SBTS24R3'  Change FMCADM Parameter  fault4592CancellationTimer  90
    Set BBMOD From Configuration
    Set Variables For Fault Generation
    Set Cells Mapped On FSP
    Perform Site Reset


Step${index}: Trigger FSP Warm Reset With Fault 2078
    Log  \nStep${index}: Trigger FSP warm reset with fault 2078.  console=true
    Setup Admin  bts_host=${OAM_BTS_IP}  bts_port=443  use_ssl=True  alias=check_warm_reset
    ${time_from}  Get Current Date  time_zone=UTC  result_format=datetime

    ${alarm_parameters}  Get String With Alarm Parameters  ${FAULT_2078_BB_AUTO_RST}
    ${alarm_webem}  Run Keyword In Background  Assert Alarm Active  parameters=${alarm_parameters}  timeout=${ALARM_TIMEOUT}  alias=check_warm_reset
    Send Hwapi Api2 Alarm Msg  ${SENDER}  ${RECEIVER}  1  ${FAULT_2078_BB_AUTO_RST}[fault_id]  ${NODE_ID}  2
    ${states}  Catenate  stateInfo.availabilityStatus=Failed,  stateInfo.administrativeState=Unlocked
    ${status_bbu}  Run Keyword And Return Status  Query Infomodel  check ${BBU_L}[dist_name] is [${states}]  timeout=${ALARM_TIMEOUT}
    IF  ${status_bbu}
      Log  BBU is in expected state: ${states}.  console=true
    ELSE
      Set Test Restriction  BBU is not in expected state: ${states}.
    END
    Wait Until Keyword Succeeds  120  10  Checking Cells On The Given FSP  ${CELLS_LIST_ON_FSP}  ${FAILED}  ${DISABLED}

    Log  Alarm presence will be checked in WebEM.  console=true
    ${check_alarm_webem}  Run Keyword And Return Status  Collect Keyword Result  ${alarm_webem}  timeout=${ALARM_TIMEOUT}
    Should Be True  ${check_alarm_webem}  Fault ${FAULT_2078_BB_AUTO_RST} was not active in WebEm.
    Log  Fault ${FAULT_2078_BB_AUTO_RST} was active in WebEm.  console=true

    Log  Alarm presence will be checked in Netact.  console=true
    ${check_alarm_netact}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  15
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_2078_BB_AUTO_RST}  time_from=${time_from}
    ...  additional_fault_id=${FAULT_2078_BB_AUTO_RST}[fault_id]
    Should Be True  ${check_alarm_netact}  Fault ${FAULT_2078_BB_AUTO_RST} was not reported to Netact.
    Log  Fault ${FAULT_2078_BB_AUTO_RST} was reported and cleared from NetAct.  console=true

    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10  Check All Cells
    Run Keyword And Continue On Failure  Teardown Admin  alias=check_warm_reset


Step3: Trigger FSP Power Reset With Fault 2078
    Log  \nStep3: Trigger FSP power reset with fault 2078.  console=true
    Setup Admin  bts_host=${OAM_BTS_IP}  bts_port=443  use_ssl=True  alias=check_power_reset
    ${time_from}  Get Current Date  time_zone=UTC  result_format=datetime

    ${alarm_parameters}  Get String With Alarm Parameters  ${FAULT_2078_BB_POWER_AUTO_RST}
    ${alarm_webem}  Run Keyword In Background  Assert Alarm Active  parameters=${alarm_parameters}  timeout=${ALARM_TIMEOUT}  alias=check_power_reset
    Send Hwapi Api2 Alarm Msg  ${SENDER}  ${RECEIVER}  1  ${FAULT_2078_BB_POWER_AUTO_RST}[fault_id]  ${NODE_ID}  2
    ${states}  Catenate  stateInfo.availabilityStatus=Failed,  stateInfo.administrativeState=Unlocked
    ${status_bbu}  Run Keyword And Return Status  Query Infomodel  check ${BBU_L}[dist_name] is [${states}]  timeout=${ALARM_TIMEOUT}
    IF  ${status_bbu}
      Log  BBU is in expected state: ${states}.  console=true
    ELSE
      Set Test Restriction  BBU is not in expected state: ${states}.
    END
    Wait Until Keyword Succeeds  120  10  Checking Cells On The Given FSP  ${CELLS_LIST_ON_FSP}  ${FAILED}  ${DISABLED}

    Log  Alarm presence will be checked in WebEM.  console=true
    ${check_alarm_webem}  Run Keyword And Return Status  Collect Keyword Result  ${alarm_webem}  timeout=${ALARM_TIMEOUT}
    Should Be True  ${check_alarm_webem}  Fault ${FAULT_2078_BB_POWER_AUTO_RST} was not active in WebEm.
    Log  Fault ${FAULT_2078_BB_POWER_AUTO_RST} was active in WebEm.  console=true

    Log  Alarm presence will be checked in Netact.  console=true
    ${check_alarm_netact}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  15
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_2078_BB_POWER_AUTO_RST}  time_from=${time_from}
    ...  additional_fault_id=${FAULT_2078_BB_POWER_AUTO_RST}[fault_id]
    Should Be True  ${check_alarm_netact}  Fault ${FAULT_2078_BB_POWER_AUTO_RST} was not reported in Netact.
    Log  Fault 2078 ${FAULT_2078_BB_POWER_AUTO_RST} was reported and cleared from NetAct.  console=true

    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10  Check All Cells
    Run Keyword And Continue On Failure  Teardown Admin  alias=check_power_reset


Step4: Trigger Fourth Fault 2078
    Log  \nStep4: Trigger fourth fault 2078.  console=true
    Send Hwapi Api2 Alarm Msg  ${SENDER}  ${RECEIVER}  1  ${FAULT_2078_EEPROM_READ_ERR}[fault_id]  ${NODE_ID}  2
    Log  Alarm presence will be checked in WebEM.  console=true
    ${alarm_parameters}  Get String With Alarm Parameters  ${FAULT_2078_EEPROM_READ_ERR}
    ${check_alarm_webem}  Run Keyword And Return Status  Assert Alarm Active  parameters=${alarm_parameters}  timeout=${ALARM_TIMEOUT}
    Should Be True  ${check_alarm_webem}  Fault ${FAULT_2078_EEPROM_READ_ERR} was not active in WebEm.
    Log  Fault ${FAULT_2078_EEPROM_READ_ERR} is active in WebEm.  console=true

    ${states}  Catenate  stateInfo.availabilityStatus=Failed,  stateInfo.administrativeState=Locked
    ${status_bbu}  Run Keyword And Return Status  Query Infomodel  check ${BBU_L}[dist_name] is [${states}]  timeout=${ALARM_TIMEOUT}
    IF  ${status_bbu}
      Log  BBU is in expected state: ${states}.  console=true
    ELSE
      Set Test Restriction  BBU is not in expected state: ${states}.
    END
    Wait Until Keyword Succeeds  120  10  Checking Cells On The Given FSP  ${CELLS_LIST_ON_FSP}  ${FAILED}  ${DISABLED}

    Log  Alarm presence will be checked in Netact.  console=true
    ${check_alarm_netact}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  30
    ...  Check Additional Information For Given Alarm And Fault  &{FAULT_2078_EEPROM_READ_ERR}
    ...  additional_fault_id=${FAULT_2078_EEPROM_READ_ERR}[fault_id]
    Should Be True  ${check_alarm_netact}  Fault ${FAULT_2078_EEPROM_READ_ERR} was not reported to Netact.
    Log  Fault ${FAULT_2078_EEPROM_READ_ERR} is active in NetAct.  console=true


Step5: Activate Maintenance Window
    IF  '${ENB_BRANCH}' < 'SBTS25R3'  RETURN
    Log  \nStep5: Activate Maintenance Window.  console=true
    Create Maintenance Window
    ${smod_r}  Query Infomodel  get object //SMOD_R-* is [activeRole=Secondary]
    IF  '${STORED_ROLE}'=='Active'
        ${recovery_execution_result}  Set Variable  BTS site recovery reset:MRBTS-${BTS_ID}
    ELSE
        ${value}  Fetch From Right  ${smod_r}[configDN]  /BTS_L-
        ${value_bts_r}  Fetch From Left  ${value}  /BTS_CONF
        ${right_side_smod_r}  Fetch From Right  ${smod_r}[dist_name]  MRBTS_R-${value_bts_r}/
        ${recovery_execution_result}  Set Variable  BTS secondary core recovery reset:MRBTS-${BTS_ID}/${right_side_smod_r}
        Check Alarm 4352
    END
    Wait Until Keyword Succeeds  900s  10s
    ...  Check All Cells

    ${list}  Create List  maintenanceWindowResult
    Log  Verifying maintenance window result in Parameter Editor to be equal to recoveryExecutionResult from Info Model.  console=true
    ${maintenance_window_result_object}  Get Parameter By Distname  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1/FMCADM_R-1  ${list}
    ${actual_value}  Set Variable  ${maintenance_window_result_object}[0][parameters][maintenanceWindowResult]
    Check Equality For Force Recovery Parameter  ${recovery_execution_result}  ${actual_value}
    ...  Maintenance Window Result did not matched.
    Log  Maintenance Window Result from Parameter Editor was correctly completed.  console=true


Step6: Deactivate Maintenance Window
    IF  '${ENB_BRANCH}' < 'SBTS25R3'  RETURN
    Log  \nStep6: Deactivate Maintenance Window.  console=true
    Delete Maintenance Window


Step7: Perform Site Reset To Recover Services
    Log  \nStep7: Perform site reset to recover services.  console=true
    Perform Site Reset


Set BBMOD From Configuration
    ${bbmods_list}  Get Parameters For All  BBMOD
    ${bbmods_for_test}  Create List
    ${type}  Create List
    Append To List  ${type}  NRCELL  LNCEL
    FOR  ${object}  IN  @{bbmods_list}
        ${cells_on_bbmod}  Get Cell Mapping By Module Id  ${object}[id]
        ${empty_status}  Run Keyword And Return Status  Should Not Be Empty  ${cells_on_bbmod}
        Continue For Loop If  not(${empty_status})
        ${cells_match}  Check Cells Type  ${cells_on_bbmod}  ${type}
        IF  ${cells_match}  Append To List  ${bbmods_for_test}  ${object}
    END
    ${status}  Run Keyword And Return Status  Should Not Be Empty  ${bbmods_for_test}
    IF  ${status}
      Log  BBMOD with cells ${type} found in configuration.  console=true
    ELSE
      Fail  BBMOD with cells ${type} not found in configuration.
    END
    ${is_bbmod_defined}  Run Keyword And Return Status  Should Not Be Empty  ${BBMOD_TYPE}
    ${bbmod_chosen}  Evaluate  random.choice(${bbmods_list})  random

    IF  ${is_bbmod_defined}
      Set Chosen BBMOD Object From Available BBMODs  ${bbmods_for_test}
    ELSE
      Set Test Variable  ${BBMOD}  ${bbmod_chosen}
    END
    Log  BBMOD for test is: ${BBMOD}  console=true
    Set Test Variable  ${BBMOD_DN}  ${BBMOD}[id]
    ${bbmod_l}  Query Infomodel  get object //BBMOD_L-* is [serialNumber=${BBMOD}[serialNumber]]
    Set Test Variable  ${BBMOD_L}  ${bbmod_l}


Set Chosen BBMOD Object From Available BBMODs
    [Arguments]  ${bbmods_list}

    ${defined_bbmods}  Create List
    FOR  ${bbmod}  IN  @{bbmods_list}
        ${match}  Run Keyword And Return Status  Should Contain  ${bbmod}[productName]  ${BBMOD_TYPE}
        IF  ${match}  Append To List  ${defined_bbmods}  ${bbmod}
    END
    ${status}  Run Keyword And Return Status  Should Not Be Empty  ${defined_bbmods}
    IF  ${status}
      Log  ${BBMOD_TYPE} for test found in configuration.  console=true
    ELSE
      Fail  ${BBMOD_TYPE} for test not found in configuration.
    END
    ${bbmod_chosen}  Evaluate  random.choice(${defined_bbmods})  random
    Set Test Variable  ${BBMOD}  ${bbmod_chosen}


Set Variables For Fault Generation
    ${bbmod_horizontal_position}  Get Module Horizontal Position  ${BBMOD_DN}
    ${receiver}  Set Variable If  '${bbmod_horizontal_position}' == '1'  269554178  537989634
    ${bbu_exist}  Run Keyword And Return Status  Query Infomodel  check ${BBMOD_L}[dist_name]/BBU_L-1
    ${bbu_string}  Set Variable If  ${bbu_exist}  ${BBMOD_L}[dist_name]/BBU_L-1  ${BBMOD_L}[dist_name]/BOARD_L-1
    ${cpu_l}  Query Infomodel  get object ${bbu_string}/POWER_GROUP_L-1/SOC_L-1/CPU_L-1
    ${stored_role}  Get StoredRole From MODULE_L  ${BBMOD_L}[dist_name]
    ${cpu_nodeid}  Convert To Hex  ${cpu_l}[nodeId]
    ${sender}  Convert To Integer  0X${cpu_nodeid}04B5
    Set Test Variable  ${SENDER}  ${sender}
    Set Test Variable  ${RECEIVER}  ${receiver}
    ${bbu_l}  Query Infomodel  get object ${bbu_string}
    Set Test Variable  ${NODE_ID}  ${bbu_l}[nodeId]
    Set Test Variable  ${STORED_ROLE}  ${stored_role}


Recovery Action If Test Fails
    Maintenance Window Cleanup
    Perform Site Reset


Check Alarm 4352
    ${start_time}  Get Current Date  time_zone=UTC  result_format=datetime
    ${4352_webem_check}  Get String With Alarm Parameters  ${FAULT_4352_2ND_CORE_AUTO_RST}
    Assert Alarm Active  parameters=${4352_webem_check}  timeout=${ALARM_TIMEOUT}
    Log  Alarm 4352 ${FAULT_4352_2ND_CORE_AUTO_RST}[fault_name] is active in WebEM.  console=true

    ${4352_webem_check}  Get String With Alarm Parameters  ${FAULT_4352_CORES_NOT_CONN}
    Assert Alarm Active  parameters=${4352_webem_check}  timeout=${ALARM_TIMEOUT}
    Log  Alarm 4352 ${FAULT_4352_CORES_NOT_CONN}[fault_name] is active in WebEM.  console=true

    Set To Dictionary  ${FAULT_4352_RAT_RST_RECOVERY}  alarm_name=BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION
    ${4352_webem_check}  Get String With Alarm Parameters  ${FAULT_4352_RAT_RST_RECOVERY}
    Assert Alarm Active  parameters=${4352_webem_check}  timeout=${ALARM_TIMEOUT}
    Log  Alarm 4352 ${FAULT_4352_RAT_RST_RECOVERY}[fault_name] is active in WebEM.  console=true

    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  15
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4352_2ND_CORE_AUTO_RST}
    ...  time_from=${start_time}
    Log  Alarm 4352 ${FAULT_4352_2ND_CORE_AUTO_RST}[fault_name] is cleared in NetAct.  console=true

    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  15
    ...  Check Additional Information For Given Alarm And Fault  &{FAULT_4352_CORES_NOT_CONN}
    Log  Alarm 4352 ${FAULT_4352_CORES_NOT_CONN}[fault_name] is active in NetAct.  console=true

    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  15
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4352_RAT_RST_RECOVERY}
    ...  time_from=${start_time}
    Log  Alarm 4352 ${FAULT_4352_RAT_RST_RECOVERY}[fault_name] is cleared in NetAct.  console=true


TC Setup
    Common Test Setup  tc_name=FM__FSP_common_reset_counter_exceeded
    Setup NetAct


TC Teardown
    IF  '${ENB_BRANCH}' >= 'SBTS24R3'  Change FMCADM Parameter  fault4592CancellationTimer  30
    Run Keyword If Test Failed  Recovery Action If Test Fails
    Teardown NetAct
    Common Test Teardown