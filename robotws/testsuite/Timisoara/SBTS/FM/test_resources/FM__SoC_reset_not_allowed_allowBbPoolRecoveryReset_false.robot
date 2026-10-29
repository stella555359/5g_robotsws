*** Settings ***
Documentation
    ...  This TC is triggering 4019 fault on ASOE/ABIO/ABIN/ABIP by removing all routes from the chosen
    ...  Loki SoC (ASOE,ABIO,ABIN) or Thor SoC (ABIP). The unit and the SoC are randomly chosen.
    ...  Test cases:
    ...  1. ASOE - if all cells from ASOE are mapped on the chosen SoC, then fault 4019: 'BTS site autonomous
    ...  reset as recovery action' is active; if at least one cell from ASOE is Enabled, then fault 4019: 'Master unit
    ...  has lost connection to the slave unit' and fault 10: 'No connection to unit' are active.
    ...  2. ABIN and ABIP - they only have one Loki SoC. All cells from BBMOD are going to be Failed and fault
    ...  4019: 'Baseband card autonomous reset as recovery action' is active.
    ...  3. ABIO - if all cells from ABIO are Failed, then the bahavior is exactly the same as in case of ABIN or ABIP;
    ...  if any cell on ABIO is Enabled, then fault 4019: 'Master unit has lost connection to the slave unit' and
    ...  fault 4714: 'FSP Reset Needed' are active.
    ...  Fault 1815 is checked at first. It can appear on each CABLINK from SoC or not. It depends on 2 statuses:
    ...  reasoningStatus of CABLNK_L should be BasebandBusSyncronizationFailed and RMOD_L/RU_L (the second end point of
    ...  CABLINK_R) should be Online.
    ...  Faults are checked in WebEM and NetAct.
    ...  First, TC is performing site reset to clear all counters.
    ...  In case of fault 4019 without autonomous reset, TC will perform Site reset for ASOE and FSP reset for ABIO/ABIN/ABIP
    ...  to recover the units.
    ...  In the end, TC will wait until SBTS is reaching onAir state.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${BBMOD_TYPE}  ABIP  # Mandatory. Could be ASOE, ABIO, ABIN or ABIP.
${STARTUP_TIMEOUT}  600  # [in seconds] Time for SBTS to recover from site reset.
${RECOVERY_TIMEOUT}  900  # [in seconds] Time for SBTS to reach onAIr state after testcase functionality.
${ALARM_TIMEOUT}  600  # [in seconds] Timeout for alarms to appear or disappear


*** Keywords ***
TC__FM__SoC_reset_not_allowed_allowBbPoolRecoveryReset_false
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24349
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  22.12.2022 - https://jiradc.int.net.nokia.com/browse/TAT-24349 - Initial TAT creation
    ...  23.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24350 - Add common keywords
    ...  12.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25370 - Remove BTS_L_ID
    ...  23.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25396 - Testcase needs timeouts adjustments
    ...  15.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25658 - Create new resources for NetAct and ONAP KWs
    ...  19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  03.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27497 - Modify keyword in resource file
    ...  26.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27703 - Tests fail due multiple keywords with the same name
    ...  31.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28025 - Enhancement for verifying additonalFaultID in NetAct
    ...  25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29190 - Enhancement of all test cases in regression to check fault signature
    ...  25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29459 - Enhancement of all test cases in regression to check FS component field
    ...  ******************

    Set Tags  CA-FM  OWNER-lucian.ciurel@nokia.com  AUTHOR-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS22  FEATURE-CB007442

    Step0: Testcase Preconditions
    Step1: Trigger FID 4019
    Step2: Check Cells And Alarms And Wait Until SBTS Is OnAir


Step0: Testcase Preconditions
    Log  \nStep0: TC preconditions.  console=true
    IF  '${BBMOD_TYPE}'=='${EMPTY}'  Fail  Please provide BBMOD type (ASOE/ABIO/ABIN/ABIP).
    Change Parameter AllowBbPoolRecoveryReset  false
    ${soc_hw_variant}  Set Variable If  '${BBMOD_TYPE}'=='ABIP'  Thor  Loki
    Set Test Variable  ${SOC_HW_VARIANT}
    Set BBMOD Distnames And Position
    ${soc_dist_name}  ${soc_position}  Get SoC Position And Dist Name Based On Hardware Variant  ${SOC_HW_VARIANT}  ${BBMOD_L_DN}
    Set Test Variable  ${SOC_DIST_NAME}
    Set Test Variable  ${SOC_POSITION}
    ${affected_cells}  Get Cells Mapped On SoC And RMODs  ${BBMOD_R_DN}  ${SOC_HW_VARIANT}  ${SOC_DIST_NAME}
    Set Test Variable  ${AFFECTED_CELLS}
    ${unaffected_cells}  Get All Cells On Bts
    Remove Values From List  ${unaffected_cells}  @{AFFECTED_CELLS}
    Set Test Variable  ${UNAFFECTED_CELLS}
    Set Test Variable  ${CHECK_4019_IN_NETACT_AT_THE_END}  ${FALSE}
    Set Test Variables For Fault Signature
    Perform Site Reset


Step1: Trigger FID 4019
    Log  \nStep1: Trigger FID 4019.  console=true
    ${time_from}  Get Current Date  time_zone=UTC  result_format=datetime
    Set Test Variable  ${NETACT_TIME_FROM}  ${time_from}
    IF  '${BBMOD_TYPE}'=='ASOE'
      Open Connection To Primary Core
    ELSE
      Open Connection To MSM Or ESM
    END
    Open Connection To SoC  ${BBMOD_POSITION}  ${SOC_POSITION}
    Remove SoC Routes
    SSHLibrary.Close All Connections


Step2: Check Cells And Alarms And Wait Until SBTS Is OnAir
    Log  \nStep2: Check cells and alarms and wait until SBTS is onAir.  console=true
    ${affected_cells_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  180  10
    ...  Check Affected Cells To Be Failed
    IF  ${affected_cells_status}
      Log  Affected cells are failed.  console=true
    ELSE
      Set Test Failed  Affected cells are not failed.
    END
    ${unaffected_cells_status}  Run Keyword And Return Status  Check Parameters Status For Cells  ${UNAFFECTED_CELLS}  operationalState=${ENABLED}
    IF  ${unaffected_cells_status}
      Log  Unaffected cells are enabled.  console=true
    ELSE
      Set Test Failed  Unaffected cells are not enabled.
    END
    Check Faults On SBTS
    IF  ${CHECK_4019_IN_NETACT_AT_THE_END}
      Check SBTS Status During Recovery Site Reset  ping_timeout=180
      Run Keyword And Ignore Error
      ...  Wait Until Keyword Succeeds  300  10
      ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4019_SITE_AUTO_RST}  time_from=${NETACT_TIME_FROM}
      ...  additional_fault_id=${FAULT_4019_SITE_AUTO_RST}[fault_id]
    END
    ${fault_4019_cores_lost_conn_params}  Get String With Alarm Parameters  ${FAULT_4019_CORES_LOST_CONN}
    ${status_4019_critical}  Run Keyword And Return Status  Assert Alarm Active  parameters=${fault_4019_cores_lost_conn_params}  timeout=10
    IF  ${status_4019_critical}  Perform Recovery Action
    Log  \nWait for all cells to be onAir.  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10  Admin Check All Required State


Set BBMOD Distnames And Position
    ${module}  Set Variable If  '${BBMOD_TYPE}'=='ASOE'  SMOD  BBMOD
    Set Test Variable  ${MODULE}
    ${bbmod_object}  Get Random Module Based On Its Type  ${BBMOD_TYPE}  ${MODULE}
    Set Test Variable  ${BBMOD_R_DN}  ${bbmod_object}[id]
    ${bbmod_l_dn}  Get Module L Dist Name  ${bbmod_object}[serialNumber]  ${MODULE}
    Set Test Variable  ${BBMOD_L_DN}
    ${bbmod_position}  Get Module Vertical Position  ${BBMOD_R_DN}
    Set Test Variable  ${BBMOD_POSITION}


Open Connection To MSM Or ESM
    ${smod_stored_role}  Get StoredRole From MODULE_L  ${BBMOD_L_DN}
    Open Connection To Primary Core
    IF  '${smod_stored_role}'=='Idle'  Open Connection To Secondary Core


Check If Any Cell On BBMOD Is Enabled
    ${cells_on_bbmod}  Get Cell Mapping By Module Id  ${BBMOD_R_DN}
    FOR  ${cell_id}  IN  @{cells_on_bbmod}
        ${cell_type}  Get Regexp Matches  ${cell_id}  [A-Z]{2}CEL
        ${status}  Run Keyword And Return Status  Assert  ${cell_type}[0]  ${cell_id}  operationalState=${ENABLED}
        IF  ${status}  RETURN  true
    END

    [Return]  false


Check Affected Cells To Be Failed
    FOR  ${cell_id}  IN  @{AFFECTED_CELLS}
        ${cell_type}  Get Regexp Matches  ${cell_id}  [A-Z]{2}CEL
        Assert  ${cell_type}[0]  ${cell_id}  availabilityStatus=${FAILED}, operationalState=${DISABLED}
    END


Check Faults On SBTS
    Check Fault 1815 In Case It Will Be Visible  ${BBMOD_R_DN}  ${SOC_HW_VARIANT}  ${SOC_DIST_NAME}
    ${cells_status}  Check If Any Cell On BBMOD Is Enabled
    IF  '${cells_status}'=='true'
      Check Faults If At Least One Cell Is Enabled
    ELSE
      Check Faults If All Cells Are Failed
    END


Check Faults If At Least One Cell Is Enabled
    ${fault_4019_cores_lost_conn_params}  Get String With Alarm Parameters  ${FAULT_4019_CORES_LOST_CONN}
    Assert Alarm Active  parameters=${fault_4019_cores_lost_conn_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${FAULT_4019_CORES_LOST_CONN}[fault_id]: ${FAULT_4019_CORES_LOST_CONN}[fault_name] is active in WebEM.  console=true
    Wait Until Keyword Succeeds  120  10
    ...  Check Additional Information For Given Alarm And Fault  &{FAULT_4019_CORES_LOST_CONN}
    ...  additional_fault_id=${FAULT_4019_CORES_LOST_CONN}[fault_id]
    Log  Fault ${FAULT_4019_CORES_LOST_CONN}[fault_id]: ${FAULT_4019_CORES_LOST_CONN}[fault_name] is active in NetAct.  console=true

    ${fault_10_params}  Get String With Alarm Parameters  ${FAULT_10_CRITICAL}
    ${fault_4714_params}  Get String With Alarm Parameters  ${FAULT_4714}
    IF  '${BBMOD_TYPE}'=='ASOE'
      Assert Alarm Active  parameters=${fault_10_params}  timeout=${ALARM_TIMEOUT}
      Log  Fault ${FAULT_10_CRITICAL}[fault_id]: ${FAULT_10_CRITICAL}[fault_name] is active in WebEM.  console=true
      Wait Until Keyword Succeeds  120  10
      ...  Check Additional Information For Given Alarm And Fault  &{FAULT_10_CRITICAL}  additional_fault_id=${FAULT_10_CRITICAL}[fault_id]
      Log  Fault ${FAULT_10_CRITICAL}[fault_id]: ${FAULT_10_CRITICAL}[fault_name] is active in NetAct.  console=true
    ELSE
      Assert Alarm Active  parameters=${fault_4714_params}  timeout=${ALARM_TIMEOUT}
      Log  Fault ${FAULT_4714}[fault_id]: ${FAULT_4714}[fault_name] is active in WebEM.  console=true
      Wait Until Keyword Succeeds  120  10
      ...  Check Additional Information For Given Alarm And Fault  &{FAULT_4714}  additional_fault_id=${FAULT_4714}[fault_id]
      Log  Fault ${FAULT_4714}[fault_id]: ${FAULT_4714}[fault_name] is active in NetAct.  console=true
    END


Check Faults If All Cells Are Failed
    ${fault_site_auto_rst_params}  Get String With Alarm Parameters  ${FAULT_4019_SITE_AUTO_RST}
    ${fault_bb_auto_rst_params}  Get String With Alarm Parameters  ${FAULT_4019_BB_AUTO_RST}
    IF  '${BBMOD_TYPE}'=='ASOE'
      Assert Alarm Active  parameters=${fault_site_auto_rst_params}  timeout=${ALARM_TIMEOUT}
      Log  Fault ${FAULT_4019_SITE_AUTO_RST}[fault_id]: ${FAULT_4019_SITE_AUTO_RST}[fault_name] is active in WebEM.  console=true
      Set Test Variable  ${CHECK_4019_IN_NETACT_AT_THE_END}  ${TRUE}
      RETURN
    ELSE
      Assert Alarm Active  parameters=${fault_bb_auto_rst_params}  timeout=${ALARM_TIMEOUT}
      Log  Fault ${FAULT_4019_BB_AUTO_RST}[fault_id]: ${FAULT_4019_BB_AUTO_RST}[fault_name] is active in WebEM.  console=true
      Wait Until Keyword Succeeds  180  10
      ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4019_BB_AUTO_RST}  time_from=${NETACT_TIME_FROM}
      ...  additional_fault_id=${FAULT_4019_BB_AUTO_RST}[fault_id]
      Log  Fault ${FAULT_4019_BB_AUTO_RST}[fault_id]: ${FAULT_4019_BB_AUTO_RST}[fault_name] is cleared in NetAct.  console=true
    END
    Sleep  2min  Wait for alarm update in history.
    Log  Check fault signature in alarm.  console=true
    Check Fault Signature Of Alarm In WebEM  fault_id=${FAULT_4019_BB_AUTO_RST}[fault_id]  category=${CATEGORY}  extra_info=${EXTRA_INFO}
    ...  info=${INFO}  load_name=${SW_VERSION}  minor=${MINOR}  reset_counter=${RESET_COUNTER}  scope=${SCOPE}  full_product_name=${PRODUCT_NAME}
    ...  serial_number=${SERIAL_NUMBER}  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}  core_unit_position=${CORE_UNIT_POSITION}
    Check Fault Signature Of Alarm In Netact  fault_id=${FAULT_4019_BB_AUTO_RST}[fault_id]  time_from=${NETACT_TIME_FROM}
    ...  category=CATEGORY:${SPACE}${CATEGORY}  extra_info=EXTRA_INFO:${SPACE}${EXTRA_INFO}  info=INFO:${SPACE}${INFO}
    ...  load_name=LOAD_NAME:${SPACE}${SW_VERSION}  minor=MINOR:${SPACE}${MINOR}  reset_counter=RESET_COUNTER:${SPACE}${RESET_COUNTER}
    ...  scope=SCOPE:${SPACE}${SCOPE}  full_product_name=${PRODUCT_NAME}  serial_number=${SERIAL_NUMBER}  vendor_unit_number=${PRODUCT_CODE}
    ...  unit_position=${UNIT_POSITION}  core_unit_position=${CORE_UNIT_POSITION}


Set Test Variables For Fault Signature
    ${is_ccu}  Run Keyword And Return Status  Should Contain  ${SOC_DIST_NAME}  /CCU
    ${is_bbu}  Run Keyword And Return Status  Should Contain  ${SOC_DIST_NAME}  /BBU
    ${is_board}  Run Keyword And Return Status  Should Contain  ${SOC_DIST_NAME}  /BOARD
    IF  ${is_ccu}
       ${module_l_dn}  Fetch From Left  ${SOC_DIST_NAME}  /CCU_L
    ELSE IF  ${is_bbu}
       ${module_l_dn}  Fetch From Left  ${SOC_DIST_NAME}  /BBU_L
    ELSE IF  ${is_board}
      ${module_l_dn}  Fetch From Left  ${SOC_DIST_NAME}  /BOARD_L
    END
    ${module_l_parameters}  coam.Get Parameters  ${module_l_dn}
    ${is_bbmod}  Run Keyword And Return Status  Should Contain  ${SOC_DIST_NAME}  BBMOD
    ${module_type}  Set Variable If  ${is_bbmod}  BBMOD  SMOD
    ${module_r_dn}  Get Module Dist Name By Serial Number And Class  ${module_l_parameters}[serialNumber]  ${module_type}
    Set Test Variable  ${PRODUCT_NAME}  ${module_l_parameters}[productName]
    Set Test Variable  ${SERIAL_NUMBER}  ${module_l_parameters}[serialNumber]
    Set Test Variable  ${PRODUCT_CODE}  ${module_l_parameters}[productCode]
    Set Unit Position For Fault Signature  ${module_r_dn}
    Set Test Variable  ${CATEGORY}  TIMEOUT
    Set Test Variable  ${EXTRA_INFO}  faulty_cells=.*NR:[0-9]+.*
    Set Test Variable  ${INFO}  Node communication failure
    ${cpu_object}  Query Infomodel  get object ${SOC_DIST_NAME}/CPU_L-1
    ${node_id}  Convert To Hex  ${cpu_object}[nodeId]  prefix=0x
    Set Test Variable  ${MINOR}  ${node_id}
    Set Test Variable  ${RESET_COUNTER}  [0-9]+
    Set Test Variable  ${SCOPE}  (Board|Site)


Perform Recovery Action
    Log  \nTC will perform recovery action.  console=true
    IF  '${BBMOD_TYPE}'=='ASOE'
      coam.Reset Site  timeout=600
    ELSE
      coam.Reset Unit  ${BBMOD_R_DN}  reset_type=WARM  timeout=300
    END


TC Setup
    Common Test Setup  tc_name=FM__SoC_reset_not_allowed_allowBbPoolRecoveryReset_false
    Setup NetAct


TC Teardown
    Change Parameter AllowBbPoolRecoveryReset  true
    Teardown NetAct
    Common Test Teardown
