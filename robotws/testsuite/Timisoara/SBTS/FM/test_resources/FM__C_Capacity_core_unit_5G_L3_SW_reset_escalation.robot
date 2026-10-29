*** Settings ***
Documentation
    ...  This TC stops four times the CPUE process, which is processing 5G cells, via pkill command.
    ...  1: ABIO or ABIN (depending on BBMOD_TYPE variable) with 5G RAT is chosed randomly.
    ...  2: Site reset is performed to clear all counters.
    ...  3: Ssh connection to SoC 0 (Snowfish) of BBMOD is established.
    ...  4: List of CPUE processes are found by sending the command ll in /ram folder on SoC 0. One CPUE process is randomly chosen to be stopped.
    ...  The first 3 operations of stopping the CPUE process cause
    ...  the fault 4383 with name: 'Internal BTS processes autonomous reset as recovery action' to appear.
    ...  ActForceAutoReset is set to True and at the 4th operation fault 4383 with name: 'RAT autonomous reset as recovery action' will appear.
    ...  If fault 'Internal BTS processes autonomous reset as recovery action' is active, cells should not be affected.
    ...  If fault 'RAT autonomous reset as recovery action' appears, all 5G cells are offline.
    ...  In the end, after the 4th operation and the proper checks, all cells must be onAir.
    ...  Site reset is performed again to clear all counters.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${CELLS_FAILED_TIMEOUT}  180
${CELLS_ONLINE_TIMEOUT}  600
${BBMOD_TYPE}  ${EMPTY}  # Mandatory, can be ABIO or ABIN


*** Keywords ***
TC__FM__C_Capacity_core_unit_5G_L3_SW_reset_escalation
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-22432
    ...
    ...  History of changes
    ...  ******************
    ...  - 23.12.2021 - https://jira3.int.net.nokia.com/browse/TAT-22432 - Initial TAT creation
    ...  - 01.02.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22577 -  ta_netact_* libary replacement with taf.nms.netact
    ...  - 08.04.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22938 - Improve TC
    ...  - 26.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24003 - Resolve duplicate keywords
    ...  - 17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  - 23.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24350 - Add common keywords
    ...  - 12.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25370 - Remove BTS_L_ID
    ...  - 15.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25658 - Create new resources for NetAct and ONAP KWs
    ...  - 05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  - 04.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27291 - Add fault for watchdog
    ...  - 03.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27497 - Modify keyword in resource file
    ...  - 29.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28007 - Add keyword perform site reset
    ...  - 31.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28025 - Enhancement for verifying additonalFaultID in NetAct
    ...  - 05.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28315 - Increase prompt timeout
    ...  - 16.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28442 - Verification of fault signature scope field for FM test cases
    ...  ******************

    Set Tags  CA-FM  OWNER-lucian.ciurel@nokia.com  AUTHOR-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS22

    Step1: Perform Site Reset To Clear All Counters
    Step2: Set Variables And Open Connection To SoC
    Step3: Cause Crash Of 5G L3 SW Component
    Step4: Cause Crash Of 5G L3 SW Component
    Step5: Cause Crash Of 5G L3 SW Component
    Step6: Cause Crash Of 5G L3 SW Component For The 4th Time


Step1: Perform Site Reset To Clear All Counters
    Log  \nStep1: Perform site reset to clear all counters.  console=true
    Perform Site Reset

Step2: Set Variables And Open Connection To SoC
    Log  \nStep2: Set variables and open connection to SoC.  console=true
    IF  ${SCF_COUNT_NR} == 0  Fail  5G RAT does not exist.
    IF  '${BBMOD_TYPE}'=='${EMPTY}'  Fail  Please provide BBMOD type (ABIO/ABIN).
    Choose Random BBMOD That Processes 5G Cells
    ${param_initial_value}  Get ActForce(Unit)AutoReset Value From Infomodel  actForceAutoReset
    Set Test Variable  ${PARAM_INITIAL_VALUE}
    Log  Setting variables for fault signature.  console=true
    Set Test Variable  ${EXPECTED_FAULT_ID}  ${FAULT_4383_PROCESSES_AUTO_RST}[fault_id]
    Set Test Variable  ${CATEGORY}  SW_FAILURE
    Set Test Variable  ${SCOPE}  Virtual Node
    Set Test Variable  ${SCOPE_RAT}  NR RAT
    Set Test Variable  ${RESET_COUNTER}  [0-9]+
    Set Test Variable  ${INFO}  CCSDaemon crash.*
    Change Parameter ActForce(Unit)AutoReset  true  actForceAutoReset
    Open Ssh Connection To SBTS
    ${process_name}  ${hex_address}  Get Name And Hex Address For Random Cpue Process
    Set Test Variable  ${CPUE_HEX_ADDRESS}  ${hex_address}
    Set Test Variable  ${MINOR}  .*(CPUE)?.*${CPUE_HEX_ADDRESS}
    ${bbmod_r_id}  Fetch From Right  ${BBMOD_R_DN}  /
    Log  ${process_name} process on ${bbmod_r_id} is chosen.  console=true


Step${count}: Cause Crash Of 5G L3 SW Component
    Log  \nStep${count}: Cause crash of 5G L3 SW component.  console=true
    Stop CPUE Process  ${CPUE_HEX_ADDRESS}

    ${time}  Get Current Date  time_zone=UTC  result_format=datetime
    ${parameters}  Get String With Alarm Parameters  ${FAULT_4383_PROCESSES_AUTO_RST}
    Assert Alarm Active  parameters=${parameters}  timeout=180
    Log  Fault 4383 "${FAULT_4383_PROCESSES_AUTO_RST}[fault_name]" is active in WebEM [OK].  console=true
    ${5_g_cells_status}  Run Keyword And Return Status  Check 5G Cells On BBMOD Are Enabled
    IF  ${5_g_cells_status}==${FALSE}  Set Test Restriction  Not all 5G cells on BBMOD are Enabled.

    ${parameters}  Get String With Alarm Parameters  ${FAULT_4383_PROCESSES_AUTO_RST}
    Assert Alarm Inactive  parameters=${parameters}  timeout=180
    Log  Fault 4383 "${FAULT_4383_PROCESSES_AUTO_RST}[fault_name]" is inactive in WebEM [OK].  console=true
    Wait Until Keyword Succeeds  180  1
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4383_PROCESSES_AUTO_RST}  time_from=${time}
    ...  additional_fault_id=${FAULT_4383_PROCESSES_AUTO_RST}[fault_id]
    Log  Fault 4383 "${FAULT_4383_PROCESSES_AUTO_RST}[fault_name]" is cleared in NetAct [OK].  console=true
    Wait Until Keyword Succeeds  ${CELLS_ONLINE_TIMEOUT}  5  Check All Cells

    Log  Check fault signature.  console=true
    Check Fault Signature Of Alarm In WebEM  fault_id=${EXPECTED_FAULT_ID}  category=${CATEGORY}  load_name=${SW_VERSION}  minor=${MINOR}
    ...  reset_counter=${RESET_COUNTER}  scope=${SCOPE}  info=${INFO}  full_product_name=${PRODUCT_NAME}  serial_number=${SERIAL_NUMBER}
    ...  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}
    Check Fault Signature Of Alarm In Netact  fault_id=${EXPECTED_FAULT_ID}  time_from=${time}  category=CATEGORY:${SPACE}${CATEGORY}
    ...  load_name=LOAD_NAME:${SPACE}${SW_VERSION}  minor=MINOR:${SPACE}${MINOR}  reset_counter=RESET_COUNTER:${SPACE}${RESET_COUNTER}
    ...  scope=SCOPE:${SPACE}${SCOPE}  info=INFO:${SPACE}${INFO}  full_product_name=${PRODUCT_NAME}  serial_number=${SERIAL_NUMBER}
    ...  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}


Step6: Cause Crash Of 5G L3 SW Component For The 4th Time
    Log  \nStep6: Cause crash of 5G L3 SW component for the 4th time.  console=true
    Stop CPUE Process  ${CPUE_HEX_ADDRESS}
    SSHLibrary.Close All Connections

    ${time}  Get Current Date  time_zone=UTC  result_format=datetime
    ${parameters}  Get String With Alarm Parameters  ${FAULT_4383_RAT_AUTO_RST}
    Assert Alarm Active  parameters=${parameters}  timeout=180
    Log  Fault 4383 "${FAULT_4383_RAT_AUTO_RST}[fault_name]" is active in WebEM [OK].  console=true

    ${5_g_cells_status}  Run Keyword And Return Status
    ...  Assert Every  NRCEL  availabilityStatus=regex"[Oo]ff\\s?line|[Ff]ailed", operationalState=${DISABLED}  timeout=${CELLS_FAILED_TIMEOUT}
    IF  ${5_g_cells_status}
      Log  5G cells are Failed/Offline. [OK]  console=true
    ELSE
      Set Test Failed  5G cells are not Failed/Offline. [NOK]
    END

    ${parameters}  Get String With Alarm Parameters  ${FAULT_4383_RAT_AUTO_RST}
    Assert Alarm Inactive  parameters=${parameters}  timeout=180
    Log  Fault 4383 "${FAULT_4383_RAT_AUTO_RST}[fault_name]" is inactive in WebEM [OK].  console=true
    Wait Until Keyword Succeeds  180  1
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4383_RAT_AUTO_RST}  time_from=${time}
    ...  additional_fault_id=${FAULT_4383_RAT_AUTO_RST}[fault_id]
    Log  Fault 4383 "${FAULT_4383_RAT_AUTO_RST}[fault_name]" is cleared in NetAct [OK].  console=true

    ${status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${CELLS_ONLINE_TIMEOUT}  5  Check All Cells
    IF  ${status}
      Log  All cells are onAir.  console=true
    ELSE
      Set Test Failed  Not all cells are onAir.
    END

    Log  Check fault signature.  console=true
    Check Fault Signature Of Alarm In WebEM  fault_id=${EXPECTED_FAULT_ID}  category=${CATEGORY}  load_name=${SW_VERSION}  minor=${MINOR}
    ...  reset_counter=${RESET_COUNTER}  scope=${SCOPE_RAT}  info=${INFO}  full_product_name=${PRODUCT_NAME}  serial_number=${SERIAL_NUMBER}
    ...  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}
    Check Fault Signature Of Alarm In Netact  fault_id=${EXPECTED_FAULT_ID}  time_from=${time}  category=CATEGORY:${SPACE}${CATEGORY}
    ...  load_name=LOAD_NAME:${SPACE}${SW_VERSION}  minor=MINOR:${SPACE}${MINOR}  reset_counter=RESET_COUNTER:${SPACE}${RESET_COUNTER}
    ...  scope=SCOPE:${SPACE}${SCOPE_RAT}  info=INFO:${SPACE}${INFO}  full_product_name=${PRODUCT_NAME}  serial_number=${SERIAL_NUMBER}
    ...  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}


Choose Random BBMOD That Processes 5G Cells
    ${bbmod_dn_list}  Create List
    ${bbmod_dns}  Get Ids For All  BBMOD
    FOR  ${bbmod_dn}  IN  @{bbmod_dns}
        ${bbmod_parameters}  coam.Get Parameters For  BBMOD  ${bbmod_dn}
        ${bbmod_type_status}  Run Keyword And Return Status  Should Contain  ${bbmod_parameters}[productName]  ${BBMOD_TYPE}
        ${cells_on_module_dns}  coam.Get Cell Mapping By Module Id  ${bbmod_dn}
        ${nr_status}  Check If NR Is Deployed On Module  ${cells_on_module_dns}
        IF  ${bbmod_type_status} and ${nr_status}  Append To List  ${bbmod_dn_list}  ${bbmod_dn}
    END
    ${length}  Get Length  ${bbmod_dn_list}
    IF  ${length} == 0  Fail  SBTS does not have ${BBMOD_TYPE} unit with 5G cells.
    ${random_bbmod_dn}  Evaluate  random.choice(${bbmod_dn_list})  random
    Set Test Variable  ${BBMOD_R_DN}  ${random_bbmod_dn}
    ${bbmod_parameters}  coam.Get Parameters  ${BBMOD_R_DN}
    Set Test Variable  ${PRODUCT_NAME}  ${bbmod_parameters}[productName]
    Set Test Variable  ${PRODUCT_CODE}  ${bbmod_parameters}[productCode]
    Set Test Variable  ${SERIAL_NUMBER}  ${bbmod_parameters}[serialNumber]
    Set Unit Position For Fault Signature  ${BBMOD_R_DN}
    ${bbmod_l_dn}  Get Module L Dist Name  ${bbmod_parameters}[serialNumber]  BBMOD
    Set Test Variable  ${BBMOD_L_DN}


Check If NR Is Deployed On Module
    [Arguments]  ${cells_on_module_dns}

    FOR  ${cell_dn}  IN  @{cells_on_module_dns}
        ${status}  Run Keyword And Return Status  Should Contain  ${cell_dn}  NRCEL
        IF  ${status}  RETURN  ${TRUE}
    END

    [Return]  ${FALSE}


Get Name And Hex Address For Random Cpue Process
    SSHLibrary.Set Client Configuration  prompt=:/ram >  timeout=30s
    SSHLibrary.Write  cd /ram
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  ls -l
    ${output_ll}  SSHLibrary.Read Until Prompt
    ${lines_concatenated}  Get Lines Containing String  ${output_ll}  /ram/node_CPUE
    ${lines}  Split To Lines  ${lines_concatenated}
    ${cpue_process}  Evaluate  random.choice(${lines})  random
    ${process_name}  Get Regexp Matches  ${cpue_process}  CPUE[a-zA-Z0-9]+
    ${node_hex}  Get Regexp Matches  ${cpue_process}  node_0x\\d+
    ${cpue_process_address}  Remove String  ${node_hex}[0]  node_

    [Return]  ${process_name}[0]  ${cpue_process_address}


Open Ssh Connection To SBTS
    ${smod_stored_role}  Get StoredRole From MODULE_L  ${BBMOD_L_DN}
    ${bbmod_vertical_position}  Get Module Vertical Position  ${BBMOD_R_DN}
    Open Connection To Primary Core
    IF  '${smod_stored_role}'=='Idle'  Open Connection To Secondary Core
    Open Connection To SoC  ${bbmod_vertical_position}  0


Stop CPUE Process
    [Arguments]  ${cpue_process_address}

    SSHLibrary.Write  pkill -11 -f '/opt/CCS/CCSDaemonExe --startup=nid=${cpue_process_address}'
    SSHLibrary.Read Until Prompt


Check 5G Cells On BBMOD Are Enabled
    ${cells_on_bbmod}  coam.Get Cell Mapping By Module Id  ${BBMOD_R_DN}
    ${5g_cells_dn}  Create List
    FOR  ${cell_dn}  IN  @{cells_on_bbmod}
        ${status}  Run Keyword And Return Status  Should Contain  ${cell_dn}  NRCEL
        IF  ${status}  Append To List  ${5g_cells_dn}  ${cell_dn}
    END
    FOR  ${cell_dn}  IN  @{5g_cells_dn}
        Assert  NRCEL  ${cell_dn}  operationalState=${ENABLED}
    END


TC Setup
    Common Test Setup  tc_name=FM__C_Capacity_core_unit_5G_L3_SW_reset_escalation
    Setup NetAct


TC Teardown
    Change Parameter ActForce(Unit)AutoReset  ${PARAM_INITIAL_VALUE}  actForceAutoReset
    Teardown NetAct
    Common Test Teardown