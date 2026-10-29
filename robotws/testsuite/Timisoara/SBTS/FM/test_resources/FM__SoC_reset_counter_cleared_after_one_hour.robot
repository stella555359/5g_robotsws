*** Settings ***
Documentation
    ...  This test is created to perform failure on ASOE/ABIN/ABIO/ABIP.
    ...  First, module with given type is chosen.
    ...  Site reset is performed to clear all counters.
    ...  Conection to SOC is opened and fault 2087 is sent.
    ...  Fault is triggered 4 times, the last time is triggered after one hour.
    ...  For ASOE, only cells state is checked.
    ...  For other module types, the alarm must be active too.
    ...  After recovery, all services must be operational.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${MODULE_TYPE}  ${EMPTY}  # Mandatory. Could be ASOE/ABIN/ABIO/ABIP.
${STARTUP_TIMEOUT}  600  # Time for SBTS to recover from site reset.
${RECOVERY_TIMEOUT}  900  # Time for SBTS to reach onAIr state.
${ALARM_TIMEOUT}  180  # Timeout for alarms to appear or disappear


*** Keywords ***
FM__SoC_reset_counter_cleared_after_one_hour
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24350
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  23.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24350 - Initial TAT creation
    ...  12.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25370 - Remove BTS_L_ID
    ...  23.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25395 - Testcase longer waiting time required
    ...  15.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25658 - Create new resources for NetAct and ONAP KWs
    ...  05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  03.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27497 - Modify keyword in resource file
    ...  31.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28025 - Enhancement for verifying additonalFaultID in NetAct
    ...  25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29190 - Enhancement of all test cases in regression to check fault signature
    ...  25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29459 - Enhancement of all test cases in regression to check FS component field
    ...  ******************

    Set Tags  CA-FM  lucian.ciurel@nokia.com  AUTHOR-anna.benzar@nokia.com GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS23

    Step0: TC Preconditions And Site Reset
    Step1: Perform SOC Recovery Reset
    Step2: Perform SOC Recovery Reset
    Step3: Perform SOC Recovery Reset
    Step4: Perform SOC Recovery Reset For The Fourth Time


Step0: TC Preconditions And Site Reset
    Log  \nStep0: TC preconditions.  console=true
    IF  '${MODULE_TYPE}'=='${EMPTY}'  Fail  Please provide Module type (ASOE/ABIN/ABIO/ABIP).
    ${smod_bbmod_type}  Set Variable If  '${MODULE_TYPE}'=='ASOE'  SMOD  BBMOD
    ${module_object}  Get Random Module Based On Its Type  ${MODULE_TYPE}  ${smod_bbmod_type}
    ${module_r_dn}  Set Variable  ${module_object}[id]
    ${module_l_dn}  Get Module L Dist Name  ${module_object}[serialNumber]  ${smod_bbmod_type}
    ${module_position}  Get Module Vertical Position  ${module_r_dn}
    ${soc_hw_variant}  Set Variable If  '${MODULE_TYPE}'=='ABIP'  Thor  Loki
    ${soc_dn}  ${soc_position}  Get SoC Position And Dist Name Based On Hardware Variant  ${soc_hw_variant}  ${module_l_dn}
    Set Test Variable  ${MODULE_R_DN}
    Set Test Variable  ${MODULE_L_DN}
    Set Test Variable  ${MODULE_POSITION}
    Set Test Variable  ${SOC_POSITION}
    Set Test Variable  ${SOC_HW_VARIANT}
    Set Test Variable  ${SOC_DN}
    ${fault_parameters_for_assert}  Get String With Alarm Parameters  ${FAULT_2087_SOC_AUTO_RST}
    Set Test Variable  ${FAULT_PARAMETERS_FOR_ASSERT}
    Set Test Variables For Fault Signature
    Log  \nPerform site reset.  console=true
    Perform Site Reset


Step${index}: Perform SOC Recovery Reset
    Log  \nStep${index}: Perform SOC recovery reset.  console=true
    Set Affected And Unaffected Cells
    ${time_from}  Get Current Date  time_zone=UTC  result_format=datetime
    Set Test Variable  ${TIME_FROM}  ${time_from}
    Open Connection To SOC And Send Fault 2087
    IF  '${MODULE_TYPE}'=='ASOE'
      Check Affected Cells Disabled And Unaffected Cells Enabled
      Check Affected And Unaffected Cells Enabled
    ELSE
      Check Cells Status And Alarm Active
      Check All Cells Enabled And Alarm Inactive
    END
    Log  Check fault signature in alarm.  console=true
    Check Fault Signature Of Alarm In WebEM  fault_id=${FAULT_2087_SOC_AUTO_RST}[fault_id]  category=${CATEGORY}  extra_info=${EXTRA_INFO}
    ...  info=${INFO}  load_name=${SW_VERSION}  minor=${MINOR}  reset_counter=${RESET_COUNTER}  scope=${SCOPE}  full_product_name=${PRODUCT_NAME}
    ...  serial_number=${SERIAL_NUMBER}  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}  core_unit_position=${CORE_UNIT_POSITION}
    Check Fault Signature Of Alarm In Netact  fault_id=${FAULT_2087_SOC_AUTO_RST}[fault_id]  time_from=${TIME_FROM}
    ...  category=CATEGORY:${SPACE}${CATEGORY}  extra_info=EXTRA_INFO:${SPACE}${EXTRA_INFO}  info=INFO:${SPACE}${INFO}
    ...  load_name=LOAD_NAME:${SPACE}${SW_VERSION}  minor=MINOR:${SPACE}${MINOR}  reset_counter=RESET_COUNTER:${SPACE}${RESET_COUNTER}
    ...  scope=SCOPE:${SPACE}${SCOPE}  full_product_name=${PRODUCT_NAME}  serial_number=${SERIAL_NUMBER}  vendor_unit_number=${PRODUCT_CODE}
    ...  unit_position=${UNIT_POSITION}  core_unit_position=${CORE_UNIT_POSITION}


Step4: Perform SOC Recovery Reset For The Fourth Time
    Log  \nStep4: Perform SOC recovery reset for the fourth time.  console=true
    Set Affected And Unaffected Cells
    ${date_time}  Get Current Date  exclude_millis=True
    ${time}  Fetch From Right  ${date_time}  ${SPACE}
    ${time}  Add Time To Time  ${time}  60 minute  result_format=timer  exclude_millis=true
    Log  Waiting until: ${time} to trigger last crash.  console=true
    Sleep  60min  reason=Waiting for one hour to trigger last fault.
    ${time_from}  Get Current Date  time_zone=UTC  result_format=datetime
    Set Test Variable  ${TIME_FROM}  ${time_from}
    Open Connection To SOC And Send Fault 2087
    IF  '${MODULE_TYPE}'=='ASOE'
      Check Affected Cells Disabled And Unaffected Cells Enabled
      Check Affected And Unaffected Cells Enabled
    ELSE
      Check Cells Status And Alarm Active
      Check All Cells Enabled And Alarm Inactive
    END
    Log  Check fault signature in alarm.  console=true
    Check Fault Signature Of Alarm In WebEM  fault_id=${FAULT_2087_SOC_AUTO_RST}[fault_id]  category=${CATEGORY}  extra_info=${EXTRA_INFO}
    ...  info=${INFO}  load_name=${SW_VERSION}  minor=${MINOR}  reset_counter=${RESET_COUNTER}  scope=${SCOPE}  full_product_name=${PRODUCT_NAME}
    ...  serial_number=${SERIAL_NUMBER}  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}  core_unit_position=${CORE_UNIT_POSITION}
    Check Fault Signature Of Alarm In Netact  fault_id=${FAULT_2087_SOC_AUTO_RST}[fault_id]  time_from=${TIME_FROM}
    ...  category=CATEGORY:${SPACE}${CATEGORY}  extra_info=EXTRA_INFO:${SPACE}${EXTRA_INFO}  info=INFO:${SPACE}${INFO}
    ...  load_name=LOAD_NAME:${SPACE}${SW_VERSION}  minor=MINOR:${SPACE}${MINOR}  reset_counter=RESET_COUNTER:${SPACE}${RESET_COUNTER}
    ...  scope=SCOPE:${SPACE}${SCOPE}  full_product_name=${PRODUCT_NAME}  serial_number=${SERIAL_NUMBER}  vendor_unit_number=${PRODUCT_CODE}
    ...  unit_position=${UNIT_POSITION}  core_unit_position=${CORE_UNIT_POSITION}


Set Affected And Unaffected Cells
    ${affected_cells}  Get Cells Mapped On SoC And RMODs  ${MODULE_R_DN}  ${SOC_HW_VARIANT}  ${SOC_DN}
    ${unaffected_cells}  Get All Cells On Bts
    Remove Values From List  ${unaffected_cells}  @{affected_cells}
    Set Test Variable  ${AFFECTED_CELLS}
    Set Test Variable  ${UNAFFECTED_CELLS}


Open Connection To SOC And Send Fault 2087
    Open Connection To Primary Core
    ${smod_stored_role}  Get StoredRole From MODULE_L  ${MODULE_L_DN}
    IF  '${smod_stored_role}'=='Idle'  Open Connection To Secondary Core
    Open Connection To SoC  ${MODULE_POSITION}  ${SOC_POSITION}
    Kill Process On SOC  l1  application_
    SSHLibrary.Close All Connections


Check Affected Cells Disabled And Unaffected Cells Enabled
    ${affected_cells_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  300  10
    ...  Check Parameters Status For Cells  ${AFFECTED_CELLS}  operationalState=${DISABLED}
    IF  ${affected_cells_status}
      Log  Affected cells are disabled. [OK]  console=true
    ELSE
      Fail  Affected cells are not disabled. [NOK]
    END
    Check Unaffected Cells Enabled


Check Affected And Unaffected Cells Enabled
    ${affected_cells_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check Parameters Status For Cells  ${AFFECTED_CELLS}  operationalState=${ENABLED}
    IF  ${affected_cells_status}
      Log  Affected cells are enabled. [OK]  console=true
    ELSE
      Fail  Affected cells are not enabled. [NOK]
    END
    Check Unaffected Cells Enabled


Check Unaffected Cells Enabled
    ${unaffected_cells_status}  Run Keyword And Return Status
    ...  Check Parameters Status For Cells  ${UNAFFECTED_CELLS}  operationalState=${ENABLED}
    IF  ${unaffected_cells_status}
      Log  Unaffected cells are enabled. [OK]  console=true
    ELSE
      Fail  Unaffected cells are not enabled. [NOK]
    END


Check Cells Status And Alarm Active
    Check Affected Cells Disabled And Unaffected Cells Enabled
    Assert Alarm Active  parameters=${FAULT_PARAMETERS_FOR_ASSERT}  timeout=${ALARM_TIMEOUT}
    Log  Alarm ${FAULT_2087_SOC_AUTO_RST}[fault_id]: ${FAULT_2087_SOC_AUTO_RST}[fault_name], active in WebEM. [OK]  console=true
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_2087_SOC_AUTO_RST}  time_from=${TIME_FROM}
    ...  additional_fault_id=${FAULT_2087_SOC_AUTO_RST}[fault_id]
    Log  Alarm ${FAULT_2087_SOC_AUTO_RST}[fault_id]: ${FAULT_2087_SOC_AUTO_RST}[fault_name], appeared & cleared from NetAct. [OK]  console=true


Check All Cells Enabled And Alarm Inactive
    Check Affected And Unaffected Cells Enabled
    Assert Alarm Inactive  parameters=${FAULT_PARAMETERS_FOR_ASSERT}  timeout=${ALARM_TIMEOUT}
    Log  Alarm ${FAULT_2087_SOC_AUTO_RST}[fault_id]: ${FAULT_2087_SOC_AUTO_RST}[fault_name], inactive in WebEM. [OK]  console=true


Set Test Variables For Fault Signature
    ${cpu_object}  Query Infomodel  get object ${SOC_DN}/CPU_L-1
    ${node_id}  Convert To Hex  ${cpu_object}[nodeId]  prefix=0x
    ${module_l_parameters}  coam.Get Parameters  ${MODULE_L_DN}
    Set Test Variable  ${PRODUCT_NAME}  ${module_l_parameters}[productName]
    Set Test Variable  ${SERIAL_NUMBER}  ${module_l_parameters}[serialNumber]
    Set Test Variable  ${PRODUCT_CODE}  ${module_l_parameters}[productCode]
    Set Unit Position For Fault Signature  ${MODULE_R_DN}
    Set Test Variable  ${INFO}  failed process:.*l1_application_rt.*
    Set Test Variable  ${SCOPE}  SoC
    Set Test Variable  ${MINOR}  ${node_id}
    Set Test Variable  ${CATEGORY}  SW_FAILURE
    Set Test Variable  ${RESET_COUNTER}  [0-9]+
    Set Test Variable  ${EXTRA_INFO}  faulty_cells=NR:[0-9]+.*


TC Setup
    Common Test Setup  tc_name=FM__SoC_reset_counter_cleared_after_one_hour
    Setup Netact


TC Teardown
    Teardown Netact
    Common Test Teardown
