*** Settings ***
Documentation
    ...  This test is created to perform failure on ABIL baseband(from ASIB system module) and verify that the recovery mechanism works properly.
    ...  Site reset is performed to clear all counters.
    ...  One ABIL BBMOD is taken randomly.
    ...  bsh, ps aux and kill commands are used to perform the failure.
    ...  The failure must be performed four times.
    ...  The first three times, the cells deployed on BBMOD are faulty and two types of alarms are reported in WebEm and NetAct.
    ...  After every trigger all reported alarms are cleared and all services hosted by baseband unit are restored.
    ...  After the fourth trigger a new type of alarm is reported and FSP recovery reset is not performed anymore.
    ...  All the alarms must be corectly reported in NetAct.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${STARTUP_TIMEOUT}  600  # [in seconds] Timeout for SBTS to start after site reset
${RECOVERY_TIMEOUT}  600  # [in seconds] Timeout for SBTS to recover after site reset
${ALARM_TIMEOUT}  180  # [in seconds] Timeout for WebEm and NetAct alarms
${BBMOD_TYPE}  ABIL  # BBMOD type


*** Keywords ***
FM__5G_BBMOD_unit_recovery_reset_counter_exceeded
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-22426
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  22.12.2021 - https://jira3.int.net.nokia.com/browse/TAT-22426 - Initial TAT creation
    ...  07.06.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23168 - Change argument name
    ...  26.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24003 - Resolve duplicate keywords
    ...  17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  12.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25370 - Remove BTS_L_ID
    ...  22.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25397 - Remove wrong spaces from if condition
    ...  15.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25658 - Create new resources for NetAct and ONAP KWs
    ...  05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  03.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27497 - Modify keyword in resource file
    ...  26.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27703 - Tests fail due multiple keywords with the same name
    ...  29.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28007 - Add keyword perform site reset
    ...  31.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28025 - Enhancement for verifying additonalFaultID in NetAct
    ...  25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29190 - Enhancement of all test cases in regression to check fault signature
    ...  25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29459 - Enhancement of all test cases in regression to check FS component field
    ...  ******************

    Set Tags  CA-FM  OWNER-lucian.ciurel@nokia.com  AUTHOR-anna.benzar@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf
    ...  PHASE-CRT  SW-SBTS22

    Step 0: Perform Site Reset And Set Variables
    Step 1: Trigger Fault On BBMOD
    Step 2: Trigger Fault On BBMOD
    Step 3: Trigger Fault On BBMOD
    Step 4: Trigger Fault On BBMOD For The Fourth Time
    Step 5: Verify SBTS State And Perform Site Reset


Step 0: Perform Site Reset And Set Variables
    Log  \nStep0: Performing site reset and setting variables.  console=true
    Perform Site Reset
    ${bbmod_list}  Query Infomodel  get list //BBMOD_L-*
    FOR  ${it}  IN  @{bbmod_list}
        ${status}  Run Keyword And Return Status  Should Contain  ${it}[productName]  ${BBMOD_TYPE}
        IF  ${status}  Set Test Variable  ${BBMOD_L}  ${it}[dist_name]
        IF  ${status}  BREAK
    END
    ${bbmod_r_dn}  Get Runtime Object Dist_name From Logical Object Dist_name  ${BBMOD_L}
    ${vertical_pos}  Get Module Vertical Position  ${bbmod_r_dn}
    Set Test Variable  ${BBMOD_POSITION}  ${vertical_pos}
    Set Variables For Fault Signature


Step ${index}: Trigger Fault On BBMOD
    Log  \nStep ${index}: Trigger Fault On BBMOD.  console=true
    ${start_time}  Get Current Date  time_zone=UTC  result_format=datetime
    Open Ssh Connection And Perform Kill Command
    Verify Cells After Performing Kill Command

    ${fault_2087_soc_auto_rst_params}  Get String With Alarm Parameters  ${FAULT_2087_SOC_AUTO_RST}
    Assert Alarm Active  parameters=${fault_2087_soc_auto_rst_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault 2087 "${FAULT_2087_SOC_AUTO_RST}[fault_name]" was reported in WebEm.  console=true
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_2087_SOC_AUTO_RST}  time_from=${start_time}
    ...  additional_fault_id=${FAULT_2087_SOC_AUTO_RST}[fault_id]
    Log  Fault 2087 "${FAULT_2087_SOC_AUTO_RST}[fault_name]" was reported & cleared from NetAct.  console=true

    ${fault_4341_bb_auto_rst_params}  Get String With Alarm Parameters  ${FAULT_4341_BB_AUTO_RST}
    Assert Alarm Active  parameters=${fault_4341_bb_auto_rst_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault 4341 "${FAULT_4341_BB_AUTO_RST}[fault_name]" was reported in WebEm.  console=true
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4341_BB_AUTO_RST}  time_from=${start_time}
    ...  additional_fault_id=${FAULT_4341_BB_AUTO_RST}[fault_id]
    Log  Fault 4341 "${FAULT_4341_BB_AUTO_RST}[fault_name]" was reported & cleared from NetAct.  console=true

    ${status_module_cells}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  300  20
    ...  Check Bbmod And Affected Cells  Enabled  Online
    IF  ${status_module_cells}
      Log  BBMOD and cells are up and running after fault triggering.  console=true
    ELSE
      Fail  BBMOD and cells didn't manage to recover after fault triggering.
    END

    Log  Check fault signature.  console=true
    Check Fault Signature Of Alarm In WebEM  fault_id=${FAULT_2087_SOC_AUTO_RST}[fault_id]  category=${CATEGORY}
    ...  extra_info=${EXTRA_INFO}  info=${INFO}  load_name=${SW_VERSION}  minor=${MINOR_ID}  reset_counter=${RESET_COUNTER}
    ...  scope=${SCOPE}  full_product_name=${PRODUCT_NAME}  serial_number=${SERIAL_NUMBER}  vendor_unit_number=${PRODUCT_CODE}
    ...  unit_position=${UNIT_POSITION}  core_unit_position=${CORE_UNIT_POSITION}
    Check Fault Signature Of Alarm In Netact  fault_id=${FAULT_2087_SOC_AUTO_RST}[fault_id]  time_from=${start_time}
    ...  category=CATEGORY:${SPACE}${CATEGORY}  extra_info=EXTRA_INFO:${SPACE}${EXTRA_INFO}  info=INFO:${SPACE}${INFO}
    ...  load_name=LOAD_NAME:${SPACE}${SW_VERSION}  minor=MINOR:${SPACE}${MINOR_ID}  reset_counter=RESET_COUNTER:${SPACE}${RESET_COUNTER}
    ...  scope=SCOPE:${SPACE}${SCOPE}  full_product_name=${PRODUCT_NAME}  serial_number=${SERIAL_NUMBER}  vendor_unit_number=${PRODUCT_CODE}
    ...  unit_position=${UNIT_POSITION}  core_unit_position=${CORE_UNIT_POSITION}


Step 4: Trigger Fault On BBMOD For The Fourth Time
    Log  \nStep 4: Trigger Fault On BBMOD for the fourth time.  console=true
    Open Ssh Connection And Perform Kill Command
    Verify Cells After Performing Kill Command

    ${fault_2087_sw_comp_failure_params}  Get String With Alarm Parameters  ${FAULT_2087_SW_COMP_FAILURE}
    Assert Alarm Active  parameters=${fault_2087_sw_comp_failure_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault 2087 "${FAULT_2087_SW_COMP_FAILURE}[fault_name]" is reported in WebEm.  console=true
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  5s
    ...  Check Additional Information For Given Alarm And Fault  &{FAULT_2087_SW_COMP_FAILURE}
    ...  additional_fault_id=${FAULT_2087_SW_COMP_FAILURE}[fault_id]
    Log  Fault 2087 "${FAULT_2087_SW_COMP_FAILURE}[fault_name]" is reported in NetAct.  console=true

    [Teardown]  SSHLibrary.Close All Connections


Step 5: Verify SBTS State And Perform Site Reset
    Log  \nStep 5: Verifying SBTS and performing site reset.  console=true
    Perform Site Reset


Set Variables For Fault Signature
    ${module_l_parameters}  coam.Get Parameters  ${BBMOD_L}
    ${module_r_dn}  Get Module Dist Name By Serial Number And Class  ${module_l_parameters}[serialNumber]  BBMOD
    Set Test Variable  ${PRODUCT_NAME}  ${module_l_parameters}[productName]
    Set Test Variable  ${SERIAL_NUMBER}  ${module_l_parameters}[serialNumber]
    Set Test Variable  ${PRODUCT_CODE}  ${module_l_parameters}[productCode]
    Set Unit Position For Fault Signature  ${module_r_dn}
    ${sw_node}  Query Infomodel  get object ${BBMOD_L}//CORE_DUMP_L-*
    ${node_id}  Convert To Hex  ${sw_node}[nodeId]  prefix=0x
    Set Test Variable  ${MINOR_ID}  .*${node_id}.*
    Set Test Variable  ${INFO}  hwr-icom
    Set Test Variable  ${SCOPE}  SoC
    Set Test Variable  ${CATEGORY}  SW_FAILURE
    Set Test Variable  ${EXTRA_INFO}  faulty_cells=.*NR:[0-9]+.*
    Set Test Variable  ${RESET_COUNTER}  [0-9]+


Open Ssh Connection And Perform Kill Command
    ${stored_role}  Get StoredRole From MODULE_L  ${BBMOD_L}
    Open Connection To Primary Core
    IF  '${stored_role}'=='Idle'  Open Connection To Secondary Core
    Open Connection To SOC  ${BBMOD_POSITION}  1
    Perfrom Kill Command

    [Teardown]  SSHLibrary.Close All Connections


Perfrom Kill Command
    SSHLibrary.Write  ps aux | grep HWRIcom
    ${output_ps}  SSHLibrary.Read Until Prompt
    ${lines}  Get Lines Containing String  ${output_ps}  /opt/hwr/HWRIcomSExe
    ${split}  Split String  ${lines}
    ${pid}  Set Variable  ${split}[1]
    SSHLibrary.Write  kill -11 ${pid}


Verify Cells After Performing Kill Command
    ${bbmod_obj}  Query Infomodel  get object ${BBMOD_L}
    ${cells_on_bbmod}  Infomodel Get Cells Deployed On Module  ${bbmod_obj}
    ${status_cells}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  180  10
    ...  Set Number Of Affected Cells And Affected Cells List  ${cells_on_bbmod}  Disabled  Failed
    IF  ${status_cells}
      Log  ${NO_AFFECTED_CELLS} cell/s are in Faulty state after performing failure.  console=true
    ELSE
      Fail  Cells are not in faulty state after performing failure on BBMOD.
    END


Set Number Of Affected Cells And Affected Cells List
    [Arguments]  ${bbmod_cells}  ${op_state}  ${av_status}

    ${list_affected_cells}  Create List
    FOR  ${it}  IN  @{bbmod_cells}
        ${affected_cell_obj}  Query Infomodel  get object ${it}[dist_name]
        ${operational_state}  Set Variable  ${affected_cell_obj}[stateInfo][operationalState]
        ${availability_status}  Set Variable  ${affected_cell_obj}[stateInfo][availabilityStatus]
        ${condition}  Catenate  SEPARATOR=${SPACE}and${SPACE}  '${operational_state}' == '${op_state}'  '${availability_status}' == '${av_status}'
        IF  ${condition}  Append To List  ${list_affected_cells}  ${affected_cell_obj}
    END
    ${no_affected_cells}  Get Length  ${list_affected_cells}
    IF  ${no_affected_cells} == 0  Fail  No cells failed after kill command.
    Set Test Variable  ${NO_AFFECTED_CELLS}  ${no_affected_cells}
    Set Test Variable  ${AFFECTED_BBMOD_CELLS}  ${list_affected_cells}


Check Bbmod And Affected Cells
    [Arguments]  ${op_state}  ${av_status}

    ${bbmod_obj}  Query Infomodel  get object ${BBMOD_L}
    ${condition}  Catenate  SEPARATOR=${SPACE}and${SPACE}
    ...  '${bbmod_obj}[stateInfo][operationalState]' != '${op_state}'
    ...  '${bbmod_obj}[stateInfo][availabilityStatus]' != '${av_status}'
    IF  ${condition}  Fail  BBMOD did not recover after fault trigger.
    FOR  ${it}  IN  @{AFFECTED_BBMOD_CELLS}
        ${affected_cell_obj}  Query Infomodel  get object ${it}[dist_name]
        ${operational_state}  Set Variable  ${affected_cell_obj}[stateInfo][operationalState]
        ${availability_status}  Set Variable  ${affected_cell_obj}[stateInfo][availabilityStatus]
        IF  '${operational_state}' != '${op_state}' and '${availability_status}' != '${av_status}'  Fail  Not all cells are up after recovery.
    END


TC Setup
    Common Test Setup  tc_name=FM__5G_BBMOD_unit_recovery_reset_counter_exceeded
    Setup NetAct


TC Teardown
    Teardown NetAct
    Run Keyword If Test Failed  Perform Site Reset
    Common Test Teardown
