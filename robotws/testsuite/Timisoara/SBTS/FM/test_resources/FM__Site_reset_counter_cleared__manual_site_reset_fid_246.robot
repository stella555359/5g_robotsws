*** Settings ***
Documentation
    ...  This testcase is triggering fault 246: BTS secondary core autonomous reset as recovery action one time.
    ...  First, flag 0x310001 is deleted from swconfig from both primary and secondary partitions.
    ...  Site reset is performed to clear all counters. coreRestartCounter for secondary core should be 0.
    ...
    ...  Fault 246 is triggered. Cells deployed on secondary core and the ones deployed on RMODs with synchronization
    ...  cabling linked to secondary core should be Failed and coreRestartCounter should be 1.
    ...  5G RAT reset with no alarm visible is performed after secondary core reset.
    ...  Fault 4001: RAT autonomous reset as recovery action can appear on RNC, if secondary core has WCDMA cells deployed.
    ...
    ...  Site reset is performed to clear the counters. coreRestartCounter should be 0.
    ...  In the end, testcase waits for SBTS to reach onAir state. Flag 0x310001 is added back in swconfig in case it was cleared in the first step.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${STARTUP_TIMEOUT}  600  # [in seconds] Time for SBTS to recover after site reset
${RECOVERY_TIMEOUT}  600  # [in seconds] Time for SBTS to recover after secondary core autonomous reset
${ALARM_TIMEOUT}  180  # [in seconds] Time for fault 246 to be visible in WebEM and NetAct


*** Keywords ***
TC__FM__Site_reset_counter_cleared__manual_site_reset_fid_246
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25412
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 24.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25412 - Initial TAT creation
    ...  - 05.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25670 - Improve cells check and add verification for fault 4001
    ...  - 15.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25658 - Create new resources for NetAct and ONAP KWs
    ...  - 05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  - 20.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27004 - Testcase enhancement
    ...  - 31.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28025 - Enhancement for verifying additonalFaultID in NetAct
    ...  ******************

    Set Tags  CA-FM  OWNER-florin-sebastian.nedelcu@nokia.com  AUTHOR-andrada-lavinia.baleti@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS23  CNI-81643

    Step0: Testcase Variables And Preconditions
    Step1: Perform Site Reset To Clear All Counters
    Step2: Trigger Fault 246 And Check SBTS Status
    Step3: Perform Site Reset To Clear All Counters


Step0: Testcase Variables And Preconditions
    Log  Step0: Testcase variables and preconditions.  console=True
    ${secondary_core_object}  Get Secondary Core Parameters
    Set Test Variable  ${SC_R_DN}  ${secondary_core_object}[id][internal]
    ${sc_ref}  Query Infomodel  get object ${SC_R_DN}/REF-*
    ${cells_on_secondary_core}  Get Cell Mapping By Module Id  ${SC_R_DN}
    ${affected_cells}  Get Cells On RMODs With Syncronization Cablink On Secondary Core  ${SC_R_DN}
    Append To List  ${affected_cells}  @{cells_on_secondary_core}
    ${affected_cells}  Remove Duplicates  ${affected_cells}
    ${all_cells}  Get All Cells On Bts
    Remove Values From List  ${all_cells}  @{affected_cells}
    ${5_g_cells_on_primary_core}  Get Cells Mapped On PC If RAT Is Mapped On Both PC And SC  NRCELL
    Set Test Variable  ${SC_L_DN}  ${sc_ref.distName}
    Set Test Variable  ${AFFECTED_CELLS}
    Set Test Variable  ${UNAFFECTED_CELLS}  ${all_cells}
    Set Test Variable  ${5_G_CELLS_ON_PRIMARY_CORE}
    ${sc_wcdma_cells}  Get Cells Deployed On Secondary Core By Given Rat  WCDMA
    ${length}  Get Length  ${sc_wcdma_cells}
    ${check_rat_reset}  Set Variable If  '${length}' == '0'  False  True
    Set Test Variable  ${CHECK_RAT_RESET}
    Change Parameter ActForce(Unit)AutoReset  true  actForceAutoReset


Step${index}: Perform Site Reset To Clear All Counters
    Log  \nStep${index}: Perform site reset to clear all counters.  console=true
    Perform Site Reset
    ${actual_value}  Get Core Restart Counter Value  ${SC_L_DN}
    Should Be Equal As Integers  ${actual_value}  0  msg=Secondary core restart counter did not reset
    Log  Secondary core restart counter is 0 after site reset.  console=true
    Run Keyword If  '${index}' == '3'
    ...  Change Parameter ActForce(Unit)AutoReset  false  actForceAutoReset


Step2: Trigger Fault 246 And Check SBTS Status
    Log  \nStep2: Trigger fault 246 and check SBTS status.  console=true
    ${start_time}  Get Current Date  time_zone=UTC  result_format=datetime
    Setup Admin  bts_host=192.168.255.129  bts_port=443  use_ssl=True  alias=fault
    ${fault_parameters}  Get String With Alarm Parameters  ${FAULT_246_2_ND_CORE_AUTO_RST}
    ${fault_background}  Run Keyword In Background  Assert Alarm Active  parameters=${fault_parameters}  timeout=${ALARM_TIMEOUT}  alias=fault
    Trigger Fault 246  ${SC_L_DN}  0x2062
    Wait Until Keyword Succeeds  180  10
    ...  Check Parameters Status For Cells  ${AFFECTED_CELLS}  operationalState=${DISABLED}, availabilityStatus=${FAILED}
    Check Parameters Status For Cells  ${UNAFFECTED_CELLS}  operationalState=${ENABLED}
    Wait Until Keyword Succeeds  180  10
    ...  Check Parameters Status For Cells  ${5_G_CELLS_ON_PRIMARY_CORE}  operationalState=${DISABLED}, availabilityStatus=${FAILED}
    Assert  SMOD  ${SC_R_DN}  operationalState=${ENABLED}  timeout=300
    ${actual_value}  Get Core Restart Counter Value  ${SC_L_DN}
    Should Be Equal As Integers  ${actual_value}  1  msg=Secondary core restart counter was not incressing to 1
    Log  Secondary core restart counter increased to 1.  console=true
    ${fault_rat_params}  Get String With Alarm Parameters  ${FAULT_4001_RAT_AUTO_RST}
    Run Keyword If  ${CHECK_RAT_RESET}
    ...  Run Keywords
    ...  Assert Alarm Active  parameters=${fault_rat_params}  timeout=300
    ...  AND
    ...  Assert Every  WNCEL  availabilityStatus=${FAILED}, operationalState=${DISABLED}  timeout=300
    ...  AND
    ...  Assert Alarm Inactive  parameters=${fault_rat_params}  timeout=120
    Log  Testcase will check active alarms for 2 minutes.  console=true
    FOR  ${time}  IN RANGE  0  6
        Admin Check Active Alarms TAF
        Sleep  20s
    END
    Wait Until Keyword Succeeds  120  10
    ...  Check Parameters Status For Cells  ${5_G_CELLS_ON_PRIMARY_CORE}  operationalState=${ENABLED}
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check Parameters Status For Cells  ${AFFECTED_CELLS}  operationalState=${ENABLED}
    ${fault_status_webem}  Run Keyword And Return Status
    ...  Collect Keyword Result  ${fault_background}  timeout=${ALARM_TIMEOUT}
    Run Keyword If  ${fault_status_webem}
    ...  Log  Fault ${FAULT_246_2_ND_CORE_AUTO_RST}[fault_id] - ${FAULT_246_2_ND_CORE_AUTO_RST}[fault_name] was reported in WebEM. [OK]  console=True
    ...  ELSE
    ...  Fail  Fault ${FAULT_246_2_ND_CORE_AUTO_RST}[fault_id] - ${FAULT_246_2_ND_CORE_AUTO_RST}[fault_name] was not reported in WebEM. [NOK]
    ${fault_status_netact}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_246_2_ND_CORE_AUTO_RST}  time_from=${start_time}
    ...  additional_fault_id=${FAULT_246_2_ND_CORE_AUTO_RST}[fault_id]
    Run Keyword If  ${fault_status_netact}
    ...  Log  Fault ${FAULT_246_2_ND_CORE_AUTO_RST}[fault_id] - ${FAULT_246_2_ND_CORE_AUTO_RST}[fault_name] was reported in NetAct. [OK]
    ...  console=True
    ...  ELSE
    ...  Fail  Fault ${FAULT_246_2_ND_CORE_AUTO_RST}[fault_id] - ${FAULT_246_2_ND_CORE_AUTO_RST}[fault_name] was not reported in NetAct. [NOK]


Get Cells Deployed On Secondary Core By Given Rat
    [Arguments]  ${rat}

    ${cells_m_list}  Create List
    ${cells_r_list}  Create List
    ${prefix}  Create Dictionary  GSM=GN  LTE=LN  WCDMA=WN  NR=NR
    ${item}  Set Variable  ${prefix}[${rat}]
    ${mapping_prefix}  Create Dictionary  GSM=G  LTE=L  WCDMA=W  NR=NR
    ${mapping_item}  Set Variable  ${mapping_prefix}[${rat}]
    ${dsp_list}  Create List
    ${cell_ref}  Query Infomodel  get list /MRBTS-1/RAT-1/MCTRL-*/BBTOP_M-1/MRBTS_M-1/${item}BTS_M-*/CELL_M-* is [rat=${rat}]  timeout=30
    Run Keyword If  '${rat}'=='LTE'
    ...  Remove NbIot Cells From List  ${cell_ref}
    FOR  ${cell}  IN  @{cell_ref}
        ${cell_to_pool_mapping}  Query Infomodel
        ...  get object /MRBTS-1/RAT-1/${mapping_item}TS-*/CELL_TO_POOL_MAPPING_L-* is [cellDN=${cell.dist_name}]  timeout=30
        ${dsp}  Get Cores Pool Used By Given Cell  ${cell_to_pool_mapping}
        Append To List  ${dsp_list}  @{dsp}
        ${on_secondary}  Check If DSPs Are On Secondary Core  ${dsp_list}
        Run Keyword If  ${on_secondary}
        ...  Append To List  ${cells_m_list}  ${cell}[dist_name]
    END
    FOR  ${cell}  IN  @{cells_m_list}
        ${dist_name}  Get Runtime Cell Name  ${cell}  ${item}
        Append To List  ${cells_r_list}  ${dist_name}
    END

    [Return]  ${cells_r_list}


Check If DSPs Are On Secondary Core
    [Arguments]  ${dsp_list}

    ${cabinet_l}  Fetch From Left  ${SC_L_DN}  /SMOD_L-1
    FOR  ${dsp}  IN  @{dsp_list}
        ${status}  Run Keyword And Return Status
        ...  Should Contain  ${dsp}  ${cabinet_l}
        Exit For Loop If  ${status}
    END

    [Return]  ${status}


Get Runtime Cell Name
    [Arguments]  ${cell_m_dist_name}  ${rat}

    ${string}  Set Variable If  '${rat}' == 'NR'  NRCELL_R-*  ${rat}CEL_R-*
    ${runtime_cells}  Query Infomodel  get list /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1//${string}  timeout=60
    FOR  ${cell}  IN  @{runtime_cells}
        ${cell_r}  Set Variable  ${cell}[dist_name]
        ${ref_parameters}  coam.Get Parameters  ${cell_r}/REF-100
        ${cell_m}  Set Variable  ${ref_parameters}[distName]
        ${status}  Run Keyword And Return Status
        ...  Should Be Equal As Strings  ${cell_m_dist_name}  ${cell_m}
        Exit For Loop If  ${status}
    END

    [Return]  ${cell_r}


TC Setup
    Common Test Setup  tc_name=FM__Site_reset_counter_cleared_fid_246
    Setup Netact


TC Teardown
    Run Keyword If Test Failed
    ...  Step3: Perform Site Reset To Clear All Counters
    Teardown Netact
    Common Test Teardown
