*** Settings ***
Documentation
    ...  Test case will verify fault signature reporting function for UP and application crashes introduced with feature CB008506.
    ...  Testing will involve provoking L1 process crash to check if autonomous recovery actions for fault 2087 are selected,
    ...  handled and reported by sOAM in line with specification, and moreover to check if the fault signature for fault 2087 works as properly.
    ...  l1_application_rt process will be killed during test.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${ALARM_TIMEOUT}  360  # Timeout for alarm to appear in WebEM
${NETACT_TIMEOUT}  180  # Timeout for alarm to appear in Netact
${RECOVERY_TIMEOUT}  300  # Timeout for SBTS to recover after crash


*** Keywords ***
TC__FM__FID2087_fault_signature_active_UP_L1_process_crashed
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-27497
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  15.05.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27497 - Initial TAT creation
    ...  17.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27606 - Multiple keywords for checking fault signature in FM testcases
    ...  31.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28025 - Enhancement for verifying additonalFaultID in NetAct
    ...  ******************

    Set Tags  CA-FM  OWNER-lucian.ciurel@nokia.com  AUTHOR-laura.craciunel@nokia.com  MAINTAINER-laura.craciunel@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf
    ...  PHASE-CRT  SW-SBTS24  FEATURE-CB008506

    Step0: Set Test Preconditions
    Step1: Perform Site Reset
    Step2: Provoke L1 Process Crash
    Step3: Provoke L1 Process Crash
    Step4: Provoke L1 Process Crash
    Step5: Perform Site Reset


Step0: Set Test Preconditions
    Log  Step0: Set test preconditions.  console=True
    Set SOC To Kill
    Set Variables For Fault Signature
    Set Affected And Unaffected Cells


Step${index}: Perform Site Reset
    Log  Step${index}: Perform site reset.  console=True
    Perform Site Reset


Step${index}: Provoke L1 Process Crash
    Log  Step${index}: Provoke L1 process crash.  console=True
    ${date_netact}  Get Current Date  time_zone=UTC  result_format=datetime
    Set Test Variable  ${DATE_NETACT}
    Setup Admin  bts_host=${OAM_BTS_IP}  bts_port=443  use_ssl=True  alias=fault_check
    ${alarm_parameters}  Get String With Alarm Parameters  ${FAULT_2087_SOC_AUTO_RST}
    ${fault_background}  Run Keyword In Background  Assert alarm active  parameters=${alarm_parameters}  timeout=${ALARM_TIMEOUT}  alias=fault_check
    Open Ssh Connection And Perform Kill Command
    Check Affected Cells Disabled
    Check Unaffected Cells Enabled
    ${fault_status_webem}  Run Keyword And Return Status
    ...  Collect Keyword Result  ${fault_background}  timeout=${ALARM_TIMEOUT}
    Run Keyword If  ${fault_status_webem}
    ...  Log  Fault ${FAULT_2087_SOC_AUTO_RST}[fault_id] with name ${FAULT_2087_SOC_AUTO_RST}[fault_name] was reported in WebEM. [OK]  console=True
    ...  ELSE
    ...  Fail  Fault ${FAULT_2087_SOC_AUTO_RST}[fault_id] with name ${FAULT_2087_SOC_AUTO_RST}[fault_name] was not reported in WebEM. [NOK]
    Teardown Admin  alias=fault_check
    ${fault_status_netact}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  30
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_2087_SOC_AUTO_RST}  time_from=${DATE_NETACT}
    ...  additional_fault_id=${FAULT_2087_SOC_AUTO_RST}[fault_id]
    Run Keyword If  ${fault_status_netact}
    ...  Log  Fault ${FAULT_2087_SOC_AUTO_RST}[fault_id] - ${FAULT_2087_SOC_AUTO_RST}[fault_name] was reported in NetAct. [OK]  console=True
    ...  ELSE
    ...  Fail  Fault ${FAULT_2087_SOC_AUTO_RST}[fault_id] - ${FAULT_2087_SOC_AUTO_RST}[fault_name] was not reported in NetAct. [NOK]
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check Modules And Cells
    Check Fault Signature In WebEM And Netact


Set SOC To Kill
    [Documentation]
    ...  Keyword sets SoC where crash will be provoked.
    ...  A randowm Loki, Thor or Magni SoC will be selected from configuration.
    ...  *AUTHOR* laura.craciunel@nokia.com

    ${soc_type}  Create List  Loki  Thor  Magni
    ${soc_match}  Create List
    ${soc_list}  Query Infomodel  get list //SOC_L-*
    FOR  ${soc}  IN  @{soc_list}
        ${status}  Run Keyword And Return Status
        ...  List Should Contain Value  ${soc_type}  ${soc}[hwVariant]
        Run Keyword If  ${status}
        ...  Append To List  ${soc_match}  ${soc}
    END
    ${random_soc}  Evaluate  random.choice(${soc_match})  random
    Set Test Variable  ${SOC_DN}  ${random_soc}[dist_name]
    ${is_bbu}  Run Keyword And Return Status
    ...  Should Contain  ${random_soc}[dist_name]  BBU_L
    ${module_dn}  Run Keyword If  ${is_bbu}
    ...  Fetch From Left  ${SOC_DN}  /BBU_L
    ...  ELSE
    ...  Fetch From Left  ${SOC_DN}  /BOARD_L
    ${is_bbmod}  Run Keyword And Return Status
    ...  Should Contain  ${module_dn}  BBMOD
    ${type}  Set Variable If  ${is_bbmod}  BBMOD  SMOD
    ${module_parameters}  coam.Get Parameters For  ${type}  ${module_dn}
    Set Test Variable  ${MODULE_L_DN}  ${module_parameters}[id]
    Set Test Variable  ${MODULE_PARAMETERS}  ${module_parameters}


Set Variables For Fault Signature
    ${dsp_parameters}  Query Infomodel  get object ${SOC_DN}/SYNC_L-1
    ${node_id}  Convert To Hex  ${dsp_parameters}[nodesList][0][nodeId]
    Set Test Variable  ${MINOR}  0x${node_id}
    ${module_r_dn}  Get Runtime Object Dist_name From Logical Object Dist_name  ${MODULE_L_DN}
    ${unit_position}  Get Module Vertical Position  ${module_r_dn}
    Set Test Variable  ${UNIT_POSITION}  ${unit_position}
    ${soc_position}  Get SOC Position  ${SOC_DN}  ${MODULE_PARAMETERS}[productName]
    Set Test Variable  ${SOC_POSITION}  ${soc_position}
    Set Test Variable  ${SCOPE}  SoC
    Set Test Variable  ${CATEGORY}  SW_FAILURE
    Set Test Variable  ${INFO}  failed process: /usr/bin/l1.*application.* got signal: 11
    Set Test Variable  ${EXTRA_INFO}  faulty_cells=(.*LTE:[0-9]+.*,)?.*NR:[0-9]+.*
    Set Test Variable  ${PRODUCT_NAME}  ${MODULE_PARAMETERS}[productName]
    Set Test Variable  ${SERIAL_NUMBER}  ${MODULE_PARAMETERS}[serialNumber]
    Set Test Variable  ${PRODUCT_CODE}  ${MODULE_PARAMETERS}[productCode]


Set Affected And Unaffected Cells
    ${affected_cells}  Get Cell Mapping By Module Id  ${SOC_DN}
    ${unaffected_cells}  Get All Cells On Bts
    Remove Values From List  ${unaffected_cells}  @{affected_cells}
    Set Test Variable  ${AFFECTED_CELLS}
    Set Test Variable  ${UNAFFECTED_CELLS}


Check Affected Cells Disabled
    ${affected_cells_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  300  10
    ...  Check Parameters Status For Cells  ${AFFECTED_CELLS}  operationalState=${DISABLED}
    Run Keyword If  ${affected_cells_status}
    ...  Log  Affected cells are disabled. [OK]  console=True
    ...  ELSE
    ...  Fail  Affected cells are not disabled. [NOK]


Check Unaffected Cells Enabled
    ${unaffected_cells_status}  Run Keyword And Return Status
    ...  Check Parameters Status For Cells  ${UNAFFECTED_CELLS}  operationalState=${ENABLED}
    Run Keyword If  ${unaffected_cells_status}
    ...  Log  Unaffected cells are enabled. [OK]  console=True
    ...  ELSE
    ...  Fail  Unaffected cells are not enabled. [NOK]


Open Ssh Connection And Perform Kill Command
    ${stored_role}  Get StoredRole From MODULE_L  ${MODULE_L_DN}
    Open Connection To Primary Core
    Run Keyword If  '${stored_role}'=='Idle'
    ...  Open Connection To Secondary Core
    Open Connection To SoC  ${UNIT_POSITION}  ${SOC_POSITION}
    ${name_process}  Kill Process On SOC  l1  _application
    Set Test Variable  ${NAME_PROCESS}  ${name_process}


Check Fault Signature In WebEM And Netact
    Log  Verify fault signature of fault in WebEM.  console=True
    Check Fault Signature Of Alarm In WebEM  fault_id=${FAULT_2087_SOC_AUTO_RST}[fault_id]  category=${CATEGORY}  extra_info=${EXTRA_INFO}
    ...  info=${INFO}  load_name=${SW_VERSION}  minor=${MINOR}  scope=${SCOPE}  full_product_name=${PRODUCT_NAME}  serial_number=${SERIAL_NUMBER}
    ...  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}
    Log  Verify fault signature of fault in Netact.  console=True
    Check Fault Signature Of Alarm In Netact  fault_id=${FAULT_2087_SOC_AUTO_RST}[fault_id]  time_from=${DATE_NETACT}
    ...  category=CATEGORY:${SPACE}${CATEGORY}  extra_info=EXTRA_INFO:${SPACE}${EXTRA_INFO}  info=INFO:${SPACE}${INFO}
    ...  load_name=LOAD_NAME:${SPACE}${SW_VERSION}  minor=MINOR:${SPACE}${MINOR}  scope=SCOPE:${SPACE}${SCOPE}  full_product_name=${PRODUCT_NAME}
    ...  serial_number=${SERIAL_NUMBER}  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}


TC Setup
    Common Test Setup  tc_name=FM__FID2087_fault_signature_active_UP_L1_process_crashed
    Setup NetAct


TC Teardown
    Teardown NetAct
    Common Test Teardown
