*** Settings ***
Documentation
    ...  This test case is created to trigger SoC recovery.
    ...  Test will randomly select SoC from ABIN, ABIO, ABIP or ASOE.
    ...  TC sends fault 4019 2 times in one hour on the same SoC.
    ...  For ABIN, ABIO, ABIP parameter actForceUnitAutoReset=true and for ASOE actForceAutoReset=true.
    ...  After the first send fault 4019.
    ...  Fault id 1815 is verified if appear in WebEM.
    ...  Fault id 4019 with fault name "SoC autonomous reset as recovery action" should appear in WebEM and NetAct.
    ...  After the second send fault 4019. If soc type is ASOE
    ...  Fault id 4019 with fault name "BTS site autonomous reset as recovery action" should appear in WebEM and NetAct.
    ...  If soc type is ABIO/ABIN/ABIP
    ...  Fault id 4019 with fault name "Baseband card autonomous reset as recovery action" should appear in WebEM and NetAct.
    ...  Also recovery action will be checked.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${STARTUP_TIMEOUT}  900  # Timeout for SBTS to recover after site reset
${PING_TIMEOUT}  600  # Timeout for ping regain during site reset
${HW_VARIANT}  Loki  # SOC's hardware variant can be Loki, Thor
${SOC_TYPE}  ${EMPTY}  # Mandatory! SOC type can be ABIO, ABIN, aSOE, ABIP


*** Keywords ***
TC__FM__SoC_reset_actForceUnitAutoReset_true_same_fault_in_one_hour
    [Documentation]
    ...  [CASE LINK]:  https://jiradc.ext.net.nokia.com/browse/TAT-24348
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 27.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24348 - Initial TAT creation
    ...  - 12.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25370 - Remove BTS_L_ID
    ...  - 15.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25658 - Create new resources for NetAct and ONAP KWs
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  - 03.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27497 - Modify keyword in resource file
    ...  - 31.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28025 - Enhancement for verifying additonalFaultID in NetAct
    ...  ******************

    Set Tags  CA-FM  OWNER-lucian.ciurel@nokia.com  AUTHOR-cristina.adam@nokia.com  MAINTAINER-cristina.adam@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf
    ...  PHASE-CRT  SW-SBTS23  FEATURE-CB007442

    Step0: Set Parameters
    Step1: Perform Site Reset
    Step2: Send Fault For First Time And Check Alarms To Appear
    Step3: Send Fault For Second Time And Check Alarms


Step0: Set Parameters
    Log  \nStep0: Setting necessary parameters...  console=true
    Change Parameter ActForce(Unit)AutoReset  true  actForceUnitAutoReset
    Run Keyword If  '${SOC_TYPE}'=='ASOE'
    ...  Change Parameter ActForce(Unit)AutoReset  true  actForceAutoReset
    Change Parameter AllowBbPoolRecoveryReset  true
    ${class_name}  ${fetch_soc_type}  Run Keyword If  '${SOC_TYPE}'!='ASOE'
    ...  Set Variable  BBMOD  /BBU_L
    ...  ELSE
    ...  Set Variable  SMOD  /BOARD_L
    ${soc_dn}  Get SOC Dist_name  ${HW_VARIANT}  ${SOC_TYPE}  ${class_name}  ${fetch_soc_type}
    Set Test Variable  ${SOC_DN}
    ${smod_bbmod_l_dn}  Fetch From Left  ${SOC_DN}  ${fetch_soc_type}
    ${smod_bbmod_r_dn}  Get Runtime Object Dist_name From Logical Object Dist_name  ${smod_bbmod_l_dn}
    Set Test Variable  ${SMOD_BBMOD_R_DN}
    ${status_bts_l}  Run Keyword And Return Status
    ...  Query Infomodel  get list //BTS_L-* is [storedRole=Single]  timeout=30
    ${smod_bbmod_position}  Get Module Vertical Position  ${SMOD_BBMOD_R_DN}
    Set Test Variable  ${SMOD_BBMOD_POSITION}
    ${soc_position}  Get SoC Position Based On SoC Dist Name  ${SOC_DN}
    Set Test Variable  ${SOC_POSITION}
    ${stored_role}  Get StoredRole From MODULE_L  ${smod_bbmod_l_dn}
    Set Test Variable  ${STORED_ROLE}
    ${affected_cells}  Get Cells Mapped On SoC And RMODs  ${SMOD_BBMOD_R_DN}  ${SOC_TYPE}  ${SOC_DN}
    Set Test Variable  ${AFFECTED_CELLS}


Step1: Perform Site Reset
    Log  \nStep1: Perform site reset.  console=true
    Perform Site Reset


Step2: Send Fault For First Time And Check Alarms To Appear
    Log  \nStep2: Send fault for first time and check alarms to appear  console=true
    ${time_alarm}  Get Current Date  time_zone=UTC  result_format=datetime
    Set Test Variable  ${TIME_ALARM}  ${time_alarm}
    Open SSH Connection And Trigger SOC Crash
    Check Affected Cells
    Check Unaffected Cells
    Check Fault 1815 In Case It Will Be Visible  ${SMOD_BBMOD_R_DN}  ${SOC_TYPE}  ${SOC_DN}
    ${alarm_parameters}  Get String With Alarm Parameters  ${FAULT_4019_SOC_AUTO_RST}
    Assert Alarm Active  ${alarm_parameters}  timeout=180
    Log  Fault ${FAULT_4019_SOC_AUTO_RST}[fault_id] has been activated in WebEM.  console=true

    Wait Until Keyword Succeeds  300  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4019_SOC_AUTO_RST}  time_from=${TIME_ALARM}
    ...  additional_fault_id=${FAULT_4019_SOC_AUTO_RST}[fault_id]
    Log  Fault ${FAULT_4019_SOC_AUTO_RST}[fault_id] is reported in NetAct.  console=true
    Verify Modules And Cells To Be On Air


Step3: Send Fault For Second Time And Check Alarms
    Log  \nStep3: Send fault for second time and check alarms  console=true
    Open SSH Connection And Trigger SOC Crash
    ${fault_bb_auto_rst_params}  Get String With Alarm Parameters  ${FAULT_4019_BB_AUTO_RST}
    ${fault_site_auto_rst_params}  Get String With Alarm Parameters  ${FAULT_4019_SITE_AUTO_RST}
    Run Keyword If  '${SOC_TYPE}'!='ASOE'
    ...  Run Keywords
    ...  Assert Alarm Active  ${fault_bb_auto_rst_params}  timeout=180
    ...  AND
    ...  Log  Fault ${FAULT_4019_BB_AUTO_RST}[fault_id] has been activated in WebEM.  console=true
    ...  AND
    ...  Wait Until Keyword Succeeds  300  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4019_BB_AUTO_RST}  time_from=${TIME_ALARM}
    ...  additional_fault_id=${FAULT_4019_BB_AUTO_RST}[fault_id]
    ...  AND
    ...  Log  Fault ${FAULT_4019_BB_AUTO_RST}[fault_id] is reported in NetAct.  console=true
    ...  ELSE
    ...  Run Keywords
    ...  Assert Alarm Active  ${fault_site_auto_rst_params}  timeout=180
    ...  AND
    ...  Log  Fault ${FAULT_4019_SITE_AUTO_RST}[fault_id] has been activated in WebEM.  console=true
    ...  AND
    ...  Check SBTS Status During Recovery Site Reset  ${PING_TIMEOUT}
    ...  AND
    ...  Run Keyword And Ignore Error
    ...  Wait Until Keyword Succeeds  300  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4019_SITE_AUTO_RST}  time_from=${TIME_ALARM}
    ...  additional_fault_id=${FAULT_4019_SITE_AUTO_RST}[fault_id]
    ...  AND
    ...  Log  Fault ${FAULT_4019_SITE_AUTO_RST}[fault_id] is reported in NetAct.  console=true
    Verify Modules And Cells To Be On Air


Get SOC Dist_name
    [Arguments]  ${hw_variant}  ${soc_type}  ${class_name}  ${fetch_soc_type}

    ${hw_variant_soc_list}  Query Infomodel  get list //SOC_L-* is [hwVariant=${hw_variant}]
    ${soc_list}  Create List
    FOR  ${soc}  IN  @{hw_variant_soc_list}
        ${smod_bbmod_l_dn}  Fetch From Left  ${soc}[dist_name]  ${fetch_soc_type}
        ${smod_bbmod_l_parameters}  Get Parameters For  ${class_name}  ${smod_bbmod_l_dn}
        ${status_soc_product_name}  Run Keyword And Return Status
        ...  Should Contain  ${smod_bbmod_l_parameters}[productName]  ${soc_type}
        Run Keyword If  ${status_soc_product_name}
        ...  Append To List  ${soc_list}  ${soc}[dist_name]
    END
    ${status_soc_list}  Run Keyword And Return Status
    ...  Should Not Be Empty  ${soc_list}
    Run Keyword If  ${status_soc_list} == ${FALSE}
    ...  Fail  There are no ${hw_variant} SOCs on ${soc_type}.
    ${soc_dn}  Evaluate  random.choice(${soc_list})  random

    [Return]  ${soc_dn}


Open SSH Connection And Trigger SOC Crash
    Open Connection To Primary Core
    Run Keyword If  '${STORED_ROLE}'=='Idle'
    ...  Open Connection To Secondary Core
    Open Connection To SOC  ${SMOD_BBMOD_POSITION}  ${SOC_POSITION}
    Remove SoC Routes
    SSHLibrary.Close Connection


Verify Modules And Cells To Be On Air
    Log  Verify modules and cells to be on air  console=true
    ${status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  20
    ...  Admin Check All Required State
    Run Keyword If  ${status}
    ...  Log  Site did manage to reach on air.  console=true
    ...  ELSE
    ...  Fail  Site didn't manage to reach on air.


Check Unaffected Cells
    Log  Check unaffected cells to be enabled  console=true
    ${cells_list}  Get All Cells On Bts
    Remove Values From List  ${cells_list}  @{AFFECTED_CELLS}
    ${status}  Run Keyword And Return Status
    ...  Check Parameters Status For Cells  ${cells_list}  operationalState=${ENABLED}
    Run Keyword If  ${status}
    ...  Log  The other cells are enabled. [OK]  console=true
    ...  ELSE
    ...  Set Test Failed  The other cells are not enabled. [NOK]


Check Affected Cells
    Log  Check affected cells  console=true
    ${status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  120  5
    ...  Check Parameters Status For Cells  ${AFFECTED_CELLS}  operationalState=${DISABLED}
    Run Keyword If  ${status}
    ...  Log  Cells on soc are disabled. [OK]  console=true
    ...  ELSE
    ...  Set Test Failed  Cells on soc are not disabled. [NOK]


TC Setup
    Common Test Setup  tc_name=FM__SoC_reset_actForceUnitAutoReset_true_one_hour
    Setup NetAct


TC Teardown
    Change Parameter ActForce(Unit)AutoReset  false  actForceUnitAutoReset
    Change Parameter ActForce(Unit)AutoReset  false  actForceAutoReset
    Teardown NetAct
    Common Test Teardown
