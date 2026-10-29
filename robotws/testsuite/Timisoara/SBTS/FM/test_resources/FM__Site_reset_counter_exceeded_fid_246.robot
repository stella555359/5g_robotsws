*** Settings ***
Documentation
    ...  This TC is triggering fault 246 for 3 times after setting the parameter actForceAutoReset to False.
    ...  First, site reset is performed. coreRestartCounter for secondary core should be 0.
    ...  For 2 times, BTS secondary core autonomous reset as recovery action is triggered and coreRestartCounter
    ...  for secondary core should be incremented. Cells on secondary core and cells on RMODs with syncronization
    ...  cablink linked to secondary core should be Failed.
    ...  5G RAT reset with no alarm visible is performed after secondary core reset.
    ...  Fault 4001: RAT autonomous reset as recovery action should appear on RNC.
    ...  For the third time, Critical fault 246: I2cBus Failure is triggered. Autonomous recovery is not performed
    ...  and cells which are Failed stand at this status.
    ...  In the end, TC performs site reset to clear Critical fault 246 and waits until SBTS is reaching
    ...  onAir state.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${STARTUP_TIMEOUT}  600  # Time for SBTS to recover after Site reset
${RECOVERY_TIMEOUT}  600  # Time for SBTS to recover after SC autonomous reset
${ALARM_TIMEOUT}  180  # Time for fault 246 to be visible in WebEM and NetAct


*** Keywords ***
TC__FM__Site_reset_counter_exceeded_fid_246
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25413
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 24.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25413 - Initial TAT creation
    ...  - 05.07.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25670 - Improve cells check and add verification for fault 4001
    ...  - 15.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25658 - Create new resources for NetAct and ONAP KWs
    ...  - 05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  - 31.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28025 - Enhancement for verifying additonalFaultID in NetAct
    ...  ******************

    Set Tags  CA-WebEM  OWNER-florin-sebastian.nedelcu@nokia.com  AUTHOR-andrada-lavinia.baleti@nokia.com
    ...  MAINTAINER-andrada-lavinia.baleti@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS23  CNI-81643

    Step0: TC Variables And Preconditions
    Step1: Perform Site Reset To Clear All Counters
    Step2: Trigger Fault 246 And Check SBTS Status
    Step3: Trigger Fault 246 And Check SBTS Status
    Step4: Trigger Critical Fault 246 And Check SBTS Status
    Step5: Perform Site Reset To Clear All Counters


Step0: TC Variables And Preconditions
    ${secondary_core_object}  Get Secondary Core Parameters
    Set Test Variable  ${SC_R_DN}  ${secondary_core_object}[id][internal]
    ${sc_ref}  Query Infomodel  get object ${SC_R_DN}/REF-*
    ${msg_ids}  Create List  0x2062  0x206B
    ${cells_on_secondary_core}  Get Cell Mapping By Module Id  ${SC_R_DN}
    ${affected_cells}  Get Cells On RMODs With Syncronization Cablink On Secondary Core  ${SC_R_DN}
    Append To List  ${affected_cells}  @{cells_on_secondary_core}
    ${affected_cells}  Remove Duplicates  ${affected_cells}
    ${all_cells}  Get All Cells On Bts
    Remove Values From List  ${all_cells}  @{affected_cells}
    ${5_g_cells_on_primary_core}  Get Cells Mapped On PC If RAT Is Mapped On Both PC And SC  NRCELL
    Set Test Variable  ${SC_L_DN}  ${sc_ref.distName}
    Set Test Variable  ${MSG_IDS}
    Set Test Variable  ${AFFECTED_CELLS}
    Set Test Variable  ${UNAFFECTED_CELLS}  ${all_cells}
    Set Test Variable  ${5_G_CELLS_ON_PRIMARY_CORE}
    Change Parameter ActForce(Unit)AutoReset  false  actForceAutoReset


Step${index}: Perform Site Reset To Clear All Counters
    Log  \nStep${index}: Perform site reset to clear all counters  console=true
    Perform Site Reset
    ${actual_value}  Get Core Restart Counter Value  ${SC_L_DN}
    Should Be Equal As Integers  ${actual_value}  0  msg=Secondary core restart counter did not reset
    Log  Secondary core restart counter is 0 after site reset.  console=true


Step${index}: Trigger Fault 246 And Check SBTS Status
    Log  \nStep${index}: Trigger fault 246 and check SBTS status  console=true
    ${start_time}  Get Current Date  time_zone=UTC  result_format=datetime
    Trigger Fault 246  ${SC_L_DN}  ${MSG_IDS}[0]
    Wait Until Keyword Succeeds  180  10
    ...  Check Parameters Status For Cells  ${AFFECTED_CELLS}  operationalState=${DISABLED}, availabilityStatus=${FAILED}
    Check Parameters Status For Cells  ${UNAFFECTED_CELLS}  operationalState=${ENABLED}
    ${fid_246_2nd_core_auto_rst_params}  Get String With Alarm Parameters  ${FAULT_246_2_ND_CORE_AUTO_RST}
    Assert Alarm Active  parameters=${fid_246_2nd_core_auto_rst_params}  timeout=${ALARM_TIMEOUT}
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_246_2_ND_CORE_AUTO_RST}  time_from=${start_time}
    ...  additional_fault_id=${FAULT_246_2_ND_CORE_AUTO_RST}[fault_id]
    Wait Until Keyword Succeeds  180  10
    ...  Check Parameters Status For Cells  ${5_G_CELLS_ON_PRIMARY_CORE}  operationalState=${DISABLED}, availabilityStatus=${FAILED}
    Assert  SMOD  ${SC_R_DN}  operationalState=${ENABLED}  timeout=300
    ${expected_value}  Evaluate  ${index}-1
    ${actual_value}  Get Core Restart Counter Value  ${SC_L_DN}
    Should Be Equal As Integers  ${actual_value}  ${expected_value}  msg=Secondary core restart counter did not increase to ${expected_value}
    Log  Secondary core restart counter increased to ${expected_value}.  console=true
    ${fid_4001_rat_auto_rst_params}  Get String With Alarm Parameters  ${FAULT_4001_RAT_AUTO_RST}
    Run Keyword If  ${SCF_COUNT_WCDMA}
    ...  Run Keywords
    ...  Assert Alarm Active  parameters=${fid_4001_rat_auto_rst_params}  timeout=300
    ...  AND
    ...  Assert Every  WNCEL  availabilityStatus=${FAILED}, operationalState=${DISABLED}  timeout=300
    ...  AND
    ...  Assert Alarm Inactive  parameters=${fid_4001_rat_auto_rst_params}  timeout=120
    Log  TC will check active alarms for 2 minutes.  console=true
    FOR  ${time}  IN RANGE  0  6
        Admin Check Active Alarms TAF
        Sleep  20s
    END
    Wait Until Keyword Succeeds  120  10
    ...  Check Parameters Status For Cells  ${5_G_CELLS_ON_PRIMARY_CORE}  operationalState=${ENABLED}
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check Parameters Status For Cells  ${AFFECTED_CELLS}  operationalState=${ENABLED}


Step4: Trigger Critical Fault 246 And Check SBTS Status
    Log  \nStep4: Trigger Critical fault 246 and check SBTS status  console=true
    Trigger Fault 246  ${SC_L_DN}  ${MSG_IDS}[1]
    Wait Until Keyword Succeeds  180  10
    ...  Check Parameters Status For Cells  ${AFFECTED_CELLS}  operationalState=${DISABLED}, availabilityStatus=${FAILED}
    ${fid_246_i2cbus_failure_params}  Get String With Alarm Parameters  ${FAULT_246_I2_CBUS_FAILURE}
    Assert Alarm Active  parameters=${fid_246_i2cbus_failure_params}  timeout=300
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault  &{FAULT_246_I2_CBUS_FAILURE}
    ...  additional_fault_id=${FAULT_246_I2_CBUS_FAILURE}[fault_id]
    Log  TC will check active alarms for 2 minutes.  console=true
    FOR  ${time}  IN RANGE  0  6
        Admin Check Active Alarms TAF
        Sleep  20s
    END


TC Setup
    Common Test Setup  tc_name=FM__Site_reset_counter_exceeded_fid_246
    Setup Netact


TC Teardown
    Teardown Netact
    Common Test Teardown
