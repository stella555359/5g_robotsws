*** Settings ***
Documentation
    ...  This test case is created to trigger SoC recovery.
    ...  Test will randomly select SoC from ABIN, ABIO, ABIP or ASOE.
    ...  TC sends fault 4019 2 times in one hour on the same SoC while actForceUnitAutoReset=false.
    ...  After the first send fault 4019.
    ...  Fault id 4019 with fault name "SoC autonomous reset as recovery action" should appear in WebEM and NetAct.
    ...  After the second send fault 4019. If soc type is ASOE and one cell on soc is enabled-
    ...  Fault id 4019 with fault name "Master unit has lost connection to the slave unit" should appear in WebEM and NetAct.
    ...  Fault id 10 with fault name "No connection to unit" should appear in WebEM and NetAct.
    ...  If soc type is ABIO/ABIN/ABIP and one cell on soc is enabled-
    ...  Fault id 4019 with fault name "Master unit has lost connection to the slave unit" should appear in WebEM and NetAct.
    ...  Fault id 4714 with fault name "FSP Reset Needed" should appear in WebEM and NetAct.
    ...  If soc type is ABIO/ABIN/ABIP/ASOE and all cells are failed -
    ...  Fault id 4019 with fault name "Baseband card autonomous reset as recovery action" should appear in WebEM and NetAct
    ...  After checks, sbts reset is caused.
    ...  Also recovery action will be checked.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${STARTUP_TIMEOUT}  600  # [in seconds] Timeout for SBTS to recover after site reset
${NETACT_TIMEOUT}  180  # [in seconds] Timeout for alarm to appear in Netact
${ALARM_TIMEOUT}  600  # [in seconds] Timeout for alarm to appear in WebEM
${HW_VARIANT}  Thor  # SOC's hardware variant can be Loki or Thor
${SOC_TYPE}  ABIP  # SOC type can be ABIO, ABIN, ASOE, ABIP


*** Keywords ***
TC__FM__SoC_reset_actForceUnitAutoReset_false_same_fault_in_one_hour
    [Documentation]
    ...  [CASE LINK]:  https://jiradc.ext.net.nokia.com/browse/TAT-24347
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 26.01.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24347 - Initial TAT creation
    ...  - 12.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25370 - Remove BTS_L_ID
    ...  - 15.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25658 - Create new resources for NetAct and ONAP KWs
    ...  - 06.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26603 - Add check fault signature for faultID 4019
    ...  - 09.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26902 - Add support for ASOE
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  - 01.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27031 - Changed unitPosition variable
    ...  - 21.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27160 - Keyword enhancement in resource file
    ...  - 25.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27083 - Increase the time for checking alarm in WebEM
    ...  - 03.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27497 - Modify keyword in resource file
    ...  - 17.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27606 - Multiple keywords for checking fault signature in FM testcases
    ...  - 31.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28025 - Enhancement for verifying additonalFaultID in NetAct
    ...  ******************

    Set Tags  CA-FM  OWNER-lucian.ciurel@nokia.com  AUTHOR-cristina.adam@nokia.com  MAINTAINER-cristina.adam@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf
    ...  PHASE-CRT  SW-SBTS23  FEATURE-CB007442

    Step0: Set Parameters
    Step1: Perform Site Reset
    Step2: Send Fault For First Time And Check Alarms To Appear
    Step3: Send Fault For Second Time And Check Alarms


Step0: Set Parameters
    Log  Step0: Setting necessary parameters.  console=true
    Change Parameter ActForce(Unit)AutoReset  false  actForceUnitAutoReset
    Change Parameter AllowBbPoolRecoveryReset  true
    ${class_name}  ${fetch_soc_type}  Run Keyword If  '${SOC_TYPE}'!='ASOE'
    ...  Set Variable  BBMOD  /BBU_L
    ...  ELSE
    ...  Set Variable  SMOD  /BOARD_L
    ${soc_dn}  Get SOC Dist_name  ${HW_VARIANT}  ${SOC_TYPE}  ${class_name}
    ${smod_bbmod_r_dn}  Get Runtime Object Dist_name From Logical Object Dist_name  ${BBMOD_L_DN}
    ${value}  Fetch From Left  ${BBMOD_L_DN}  /EQM
    ${value_bts_l}  Fetch From Right  ${value}  RAT-1/
    ${status_bts_l}  Run Keyword And Return Status
    ...  Query Infomodel  get list //BTS_L-* is [storedRole=Single]  timeout=30
    ${smod_bbmod_position}  Get Module Vertical Position  ${smod_bbmod_r_dn}
    Set Test Variable  ${SMOD_BBMOD_POSITION}
    ${soc_position}  Get SoC Position Based On SoC Dist Name  ${soc_dn}
    Set Test Variable  ${SOC_POSITION}
    ${stored_role}  Get StoredRole From MODULE_L  ${BBMOD_L_DN}
    Set Test Variable  ${STORED_ROLE}
    ${cell_on_smod_bbmod}  Get Cell Mapping By Module Id  ${BBMOD_L_DN}
    Set Test Variable  ${CELL_ON_SMOD_BBMOD}
    ${dsp_parameters}  Query Infomodel  get object ${soc_dn}/SYNC_L-1
    ${node_id}  Convert To Hex  ${dsp_parameters}[nodesList][0][nodeId]
    ${node_id}  Convert To Lower Case  ${node_id}
    Set Test Variable  ${BTS_L_ID}  ${value_bts_l}
    ${id}  Fetch From Right  ${BTS_L_ID}  -
    ${smod_parameters}  Run Keyword If  '${SOC_TYPE}'=='ASOE'
    ...  Query Infomodel  get object //SMOD_R-*
    ...  ELSE IF  '${id}'=='1'
    ...  Query Infomodel  get object //SMOD_R-* is [activeRole=Primary]
    ...  ELSE
    ...  Query Infomodel  get object //SMOD_R-* is [activeRole=Secondary]
    ${smod_core_parameters}  Query Infomodel  get object ${smod_parameters}[dist_name]/SMOD_CORE_R-*
    Set Unit Position For Fault Signature  ${smod_parameters}[dist_name]

    Set Test Variable  ${PRODUCT_NAME}  ${smod_parameters}[productName]
    Set Test Variable  ${PRODUCT_CODE}  ${smod_core_parameters}[productCode]
    Set Test Variable  ${SERIAL_NUMBER}  ${smod_core_parameters}[serialNumber]

    ${short_smod_product_name}  Fetch From Left  ${smod_parameters}[productName]  ${SPACE}
    Set Test Variable  ${NODE_ID}  0x${node_id}

    Set Test Variable  ${EXTRA_INFO}  faulty_cells=(.*LTE:[0-9]+.*,)?.*NR:[0-9]+.*
    Set Test Variable  ${CATEGORY}  TIMEOUT
    Set Test Variable  ${SCOPE}  SoC
    Set Test Variable  ${INFO}  Node communication failure


Step1: Perform Site Reset
    Log  Step1: Perform site reset.  console=true
    Perform Site Reset


Step2: Send Fault For First Time And Check Alarms To Appear
    Log  Step2: Send fault for first time and check alarms to appear.  console=true
    ${time_alarm}  Get Current Date  time_zone=UTC  result_format=datetime
    Set Test Variable  ${START_TIME}  ${time_alarm}
    Open SSH Connection And Trigger SOC Crash

    ${alarm_parameters}  Get String With Alarm Parameters  ${FAULT_4019_SOC_AUTO_RST}
    ${assert_alarm_active}  Assert Alarm Active  ${alarm_parameters}  timeout=${ALARM_TIMEOUT}
    Run Keyword If  ${assert_alarm_active}
    ...  Log  Fault ${FAULT_4019_SOC_AUTO_RST}[fault_id] "${FAULT_4019_SOC_AUTO_RST}[fault_name]" is visible in WebEM. [OK]  console=True
    ...  ELSE
    ...  Fail  Fault ${FAULT_4019_SOC_AUTO_RST}[fault_id] "${FAULT_4019_SOC_AUTO_RST}[fault_name]" was not visible in WebEM. [NOK]

    ${alarm}  Set Variable  ${assert_alarm_active}[-1]
    ${default_system_time}  Run Keyword And Return Status
    ...  Should Be Equal As Strings  ${alarm}[systemTime]  Default System Time
    ${string}  Catenate  SEPARATOR=;  ${FAULT_4019_SOC_AUTO_RST}[fault_name]  Default System Time
    ${fault_name_string}  Set Variable If  ${default_system_time}  ${string}  ${FAULT_4019_SOC_AUTO_RST}[fault_name]

    ${check_fault_na}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  10
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  fault_id=${FAULT_4019_SOC_AUTO_RST}[fault_id]
    ...  fault_name=${fault_name_string}
    ...  alarm_id=${FAULT_4019_SOC_AUTO_RST}[alarm_id]
    ...  alarm_name=${FAULT_4019_SOC_AUTO_RST}[alarm_name]
    ...  severity=${FAULT_4019_SOC_AUTO_RST}[severity]
    ...  time_from=${START_TIME}
    ...  additional_fault_id=${FAULT_4019_SOC_AUTO_RST}[fault_id]
    Run Keyword If  ${check_fault_na}
    ...  Log  Given alarm and fault fields are correct in NA, alarm is present in NA [OK].  console=true
    ...  ELSE
    ...  FAIL  Given alarm and fault fields are incorrect in NA or alarm is missing in NA [NOK].

    ${assert_alarm_active}  Assert Alarm Inactive  ${alarm_parameters}  timeout=${ALARM_TIMEOUT}
    Log  Verify fault signature of fault in WebEM.  console=True
    Check Fault Signature Of Alarm In WebEM  fault_id=${FAULT_4019_SOC_AUTO_RST}[fault_id]  category=${CATEGORY}  extra_info=${EXTRA_INFO}
    ...  info=${INFO}  load_name=${SW_VERSION}  minor=${NODE_ID}  scope=${SCOPE}  full_product_name=${PRODUCT_NAME}  serial_number=${SERIAL_NUMBER}
    ...  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}  core_unit_position=${CORE_UNIT_POSITION}
    Log  Verify fault signature of fault in Netact.  console=True
    Check Fault Signature Of Alarm In Netact  fault_id=${FAULT_4019_SOC_AUTO_RST}[fault_id]  time_from=${START_TIME}
    ...  category=CATEGORY:${SPACE}${CATEGORY}  extra_info=EXTRA_INFO:${SPACE}${EXTRA_INFO}  info=INFO:${SPACE}${INFO}
    ...  load_name=LOAD_NAME:${SPACE}${SW_VERSION}  minor=MINOR:${SPACE}${NODE_ID}  scope=SCOPE:${SPACE}${SCOPE}  full_product_name=${PRODUCT_NAME}
    ...  serial_number=${SERIAL_NUMBER}  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}

    Verify Modules And Cells To Be On Air


Step3: Send Fault For Second Time And Check Alarms
    Log  Step3: Send fault for second time and check alarms.  console=true
    Open SSH Connection And Trigger SOC Crash
    ${match}  Check If One Cell On Soc Is On Air  ${CELL_ON_SMOD_BBMOD}
    ${all_cells_are_failed}  Run Keyword And Return Status
    ...  Should Be Equal As Strings  ${match}  False

    ${fid_4019_bb_auto_rst_params}  Get String With Alarm Parameters  ${FAULT_4019_BB_AUTO_RST}
    Run Keyword If  ${all_cells_are_failed}
    ...  Run Keywords
    ...  Assert Alarm Active  ${fid_4019_bb_auto_rst_params}  timeout=${ALARM_TIMEOUT}
    ...  AND
    ...  Log  The alarm with fault ${FAULT_4019_BB_AUTO_RST}[fault_id] has been activated in WebEM. [OK]  console=true
    ...  AND
    ...  Wait Until Keyword Succeeds  300  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4019_BB_AUTO_RST}  time_from=${START_TIME}
    ...  additional_fault_id=${FAULT_4019_BB_AUTO_RST}[fault_id]
    ...  AND
    ...  Log  Fault ${FAULT_4019_BB_AUTO_RST}[fault_id] is reported in NetAct.  console=true
    ...  AND
    ...  Verify Modules And Cells To Be On Air
    ...  AND
    ...  Return From Keyword

    ${fid_4019_cores_lost_conn_params}  Get String With Alarm Parameters  ${FAULT_4019_CORES_LOST_CONN}
    Assert Alarm Active  ${fid_4019_cores_lost_conn_params}  timeout=${ALARM_TIMEOUT}
    Log  The alarm with fault ${FAULT_4019_CORES_LOST_CONN}[fault_id] has been activated in WebEM. [OK]  console=true
    Wait Until Keyword Succeeds  300  10s
    ...  Check Additional Information For Given Alarm And Fault  &{FAULT_4019_CORES_LOST_CONN}
    ...  additional_fault_id=${FAULT_4019_CORES_LOST_CONN}[fault_id]
    Log  Fault ${FAULT_4019_CORES_LOST_CONN}[fault_id] is reported in NetAct.  console=true

    ${fid_10_params}  Get String With Alarm Parameters  ${FAULT_10_CRITICAL}
    ${fid_4714_params}  Get String With Alarm Parameters  ${FAULT_4714}
    Run Keyword If  '${SOC_TYPE}'=='ASOE'
    ...  Run Keywords
    ...  Assert Alarm Active  ${fid_10_params}  timeout=${ALARM_TIMEOUT}
    ...  AND
    ...  Log  The alarm with fault ${FAULT_10_CRITICAL}[fault_id] has been activated in WebEM. [OK]  console=true
    ...  AND
    ...  Wait Until Keyword Succeeds  300  10s
    ...  Check Additional Information For Given Alarm And Fault  &{FAULT_10_CRITICAL}  additional_fault_id=${FAULT_10_CRITICAL}[fault_id]
    ...  AND
    ...  Log  Fault ${FAULT_10_CRITICAL}[fault_id] is reported in NetAct.  console=true
    ...  ELSE
    ...  Run Keywords
    ...  Assert Alarm Active  ${fid_4714_params}  timeout=${ALARM_TIMEOUT}
    ...  AND
    ...  Log  The alarm with fault ${FAULT_4714}[fault_id] has been activated in WebEM. [OK]  console=true
    ...  AND
    ...  Wait Until Keyword Succeeds  300  10s
    ...  Check Additional Information For Given Alarm And Fault  &{FAULT_4714}  additional_fault_id=${FAULT_4714}[fault_id]
    ...  AND
    ...  Log  Fault ${FAULT_4714}[fault_id] is reported in NetAct.  console=true
    Perform Site Reset


Get SOC Dist_name
    [Arguments]  ${hw_variant}  ${soc_type}  ${class_name}

    ${hw_variant_soc_list}  Query Infomodel  get list //SOC_L-* is [hwVariant=${hw_variant}]
    ${soc_list}  Create List
    FOR  ${soc}  IN  @{hw_variant_soc_list}
        ${smod_bbmod_l_dn}  Run Keyword If  '${soc_type}'=='ABIO'
        ...  Fetch From Left  ${soc}[dist_name]  /BBU_L
        ...  ELSE
        ...  Fetch From Left  ${soc}[dist_name]  /BOARD_L
        ${smod_bbmod_l_parameters}  Get Parameters For  ${class_name}  ${smod_bbmod_l_dn}
        ${status_soc_product_name}  Run Keyword And Return Status
        ...  Should Contain  ${smod_bbmod_l_parameters}[productName]  ${soc_type}
        Run Keyword If  ${status_soc_product_name}
        ...  Append To List  ${soc_list}  ${soc}[dist_name]
    END
    ${status_soc_list}  Run Keyword And Return Status
    ...  Should Not Be Empty  ${soc_list}
    Run Keyword If  ${status_soc_list}==${FALSE}
    ...  Fail  There are no ${hw_variant} SOCs on ${soc_type}.
    ${soc_dn}  Evaluate  random.choice(${soc_list})  random
    Set Test Variable  ${BBMOD_L_DN}  ${smod_bbmod_l_dn}
    Set Test Variable  ${BBMOD_PARAMETERS}  ${smod_bbmod_l_parameters}

    [Return]  ${soc_dn}


Open SSH Connection And Trigger SOC Crash
    Open Connection To Primary Core
    Run Keyword If  '${STORED_ROLE}'=='Idle'
    ...  Open Connection To Secondary Core
    Open Connection To SOC  ${SMOD_BBMOD_POSITION}  ${SOC_POSITION}
    Remove SoC Routes
    SSHLibrary.Close Connection


Verify Modules And Cells To Be On Air
    Log  Verify modules and cells to be on air.  console=true
    ${status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  20
    ...  Admin Check All Required State
    Run Keyword If  ${status}
    ...  Log  Site did manage to reach on air.  console=true
    ...  ELSE
    ...  Fail  Site didn't manage to reach on air.


Check If One Cell On Soc Is On Air
    [Arguments]  ${cell_list}

    Log  Check if one cell on soc is on air.  console=true
    Sleep  20s  Sleep should be for the cells affected.
    FOR  ${id_cell}  IN  @{cell_list}
        ${cell_class_name}  Get Regexp Matches  ${id_cell}  [A-Z]{2}CEL
        ${status}  Run Keyword And Return Status
        ...  Assert  ${cell_class_name}[0]  id=${id_cell}  operationalState=${ENABLED}  timeout=60s
        Run Keyword If  ${status}
        ...  Return From Keyword  True
    END

    [Return]  False


TC Setup
    Common Test Setup  tc_name=FM__SoC_reset_actForceUnitAutoReset_false_one_hour
    Setup NetAct


TC Teardown
    Change Parameter ActForce(Unit)AutoReset  false  actForceUnitAutoReset
    Teardown NetAct
    Common Test Teardown
