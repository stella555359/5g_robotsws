*** Settings ***
Documentation  vDU full commissioning
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn
Library    taf.vran.vdu.enb.rest.interface.LTEvDU    WITH NAME    ltevdu

Resource    ../../resources/Robot/ltevdu_oam_operations.robot
Resource    ../../resources/Robot/vdu_oam_operations.robot
Resource    ../../../resources/Robot/scfc.robot
Resource    ../../resources/variables.robot
Resource    ../../resources/Robot/lte_cloud_setup_teardown.robot

*** Variables ***
@{VDU_COMMISSIONING_LTE_VDU_ALLOWED_HIST_ALARMS}=  faultId=23, severity=critical
...                                                faultId=4592, severity=minor

*** Keywords ***
TC__Cloud_CM_LTE_vDU_Commissioning
    [Arguments]  ${lte_scfc_file_path}  ${lte_vdu_connection}=default_lte  ${log_to_console}=True
    [Documentation]
    ...  Description:
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_VRF_SISO-19046
    ...  Feature: CB012447 - LTE on Cloud veNB - basic L3 call
    ...  Feature CB012447 implements initial 4G-vDU solution and deployment capabilities.
    ...  Feature CB012447 is a first step in LTE on Cloud solution development.
    ...
    ...  FeatureCB012447-F - Bring up FDD DRAN Configuration in SNO Deployment
    ...  Test case performs 4G-vDU commissioning.
    ...  After the test case is completed 4G-vDU CNF is deployed successfully
    ...  and fronthaul interface (CPRI) is successfully established to RU.
    ...  Fault 4592 (BTS reset cause) is raised due to the 4G-vDU restart.
    ...  Fault 4592 raised until the time defined by parameter "fault4592CancellationTimer" elapses.
    ...
    ...  Exceptions:
    ...  If Radio software version is incompatible with 4G-vDU software version then fault 23
    ...  will be raised and automatic radio software upgrade will be triggered.
    ...  Fault 23 will be cancelled once radio software upgrade is finished.
    ...
    ...  Step 1: Initial Check Lte vDU Commissioning
    ...  a) Radio modules expected states:
    ...                         administrativeState = unlocked
    ...                         operationalState = enabled
    ...                         availabilityStatus = on line
    ...  b) Cells expected states:
    ...                         operationalState = enabled
    ...                         administrativeState = unlocked
    ...                         availabilityStatus = on line
    ...  c) vDU expected state:
    ...                        operationalState = onAir
    ...  Step 2: Perform Lte vDU Commissioning
    ...  a) Bts Reset Cause (faultID=4592) alarm checking
    ...  Step 3: Postconditions Lte vDU Commissioning
    ...  a) Radio modules expected states:
    ...                         administrativeState = unlocked
    ...                         operationalState = enabled
    ...                         availabilityStatus = on line
    ...  b) Cells expected states:
    ...                         operationalState = enabled
    ...                         administrativeState = unlocked
    ...                         availabilityStatus = on line
    ...  c) vDU expected state:
    ...                        operationalState = onAir
    ...  No unexpected alarm is visible
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | lte_scfc_file_path     | Yes  | Path to the LTE vDU scfc file.                                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | lte_vdu_connection     |  No  | LTEvDU connection object or string name alias if used.                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: slawomir.jastrzebski@nokia.com
    ...  Maintainer: slawomir.jastrzebski@nokia.com

    Set Test Variable  ${lte_scfc_file_path}
    Set Test Variable  ${lte_vdu_connection}
    Set Test Variable  ${log_to_console}
    Log  ${start_prefix_green}Test Case: LTE_vDU_Commissioning  console=${log_to_console}
    Step 1: Initial Check Lte vDU Commissioning
    Step 2: Perform Lte vDU Commissioning
    Step 3: Postconditions Lte vDU Commissioning
    Log  ${done_prefix_green}Test Case: LTE_vDU_Commissioning  console=${log_to_console}
    [Teardown]  Run Keyword And Ignore Error  LTEvDU Rest Logout  lte_vdu_connection=${lte_vdu_connection}

Step 1: Initial Check Lte vDU Commissioning
    Log  ${dots_prefix_green}Step 1: Initial check LTE vDU commissioning  console=${log_to_console}
    Append To List  ${LTE_VDU_HISTORICAL_ALLOWED_ALARMS}  @{VDU_COMMISSIONING_LTE_VDU_ALLOWED_HIST_ALARMS}
    LTEvDU Rest Login  lte_vdu_connection=${lte_vdu_connection}
#Wait Until all radio modules are on line
    ${rmods_count}=  vDU SCFC Get RMODs Count  scfc_file_path=${lte_scfc_file_path}
    Wait Until All Radio Modules Are Online  lte_rmods_count=${rmods_count}
    ...  timeout=30s  lte_vdu_connection=${lte_vdu_connection}
    Log  ${info_prefix}All radio modules are on line  console=${log_to_console}
#Wait until all cells are OnAir
    ${lcells_count}=  vDU SCFC Get LCELL Count  scfc_file_path=${lte_scfc_file_path}
    Set Test Variable  ${lcells_count}
    Wait Until All Cells Are OnAir  lcells_count=${lcells_count}
    ...  timeout=30s  lte_vdu_connection=${lte_vdu_connection}
    Log  ${info_prefix}All LTE cells are OnAir  console=${log_to_console}
#Check vDU operational state
    vDU Wait For Expected Operational State  vdu_state_value=onAir
    ...  vdu_check=${False}  lte_vdu_check=${True}
    ...  lte_vdu_connection=${lte_vdu_connection}
    Log  ${info_prefix}LTE vDU operational state is onAir  console=${log_to_console}
    Log  ${ok_prefix_green}Step 1: Initial check LTE vDU commissioning  console=${log_to_console}

Step 2: Perform Lte vDU Commissioning
    Log  ${dots_prefix_green}Step 2: Perform LTE vDU commissioning  console=${log_to_console}
    Log  ${info_prefix}LTE vDU commissioning has been started. Please wait ...  console=${log_to_console}
    ${commissioning_result}=  ltevdu.Perform Commissioning  scf_file=${lte_scfc_file_path}
    ...  timeout=${ACTIVATE_PLAN_TIMEOUT}  connection=${lte_vdu_connection}
    Log  ${info_prefix}LTE vDU commissioning operation status: ${commissioning_result['1']}  console=${log_to_console}
    Log  ${info_prefix}LTE vDU commissioning has been completed successfully  console=${log_to_console}
    Log  ${info_prefix}Bts Reset Cause (faultID=4592) alarm checking  console=${log_to_console}
    LTEvDU Check Bts Reset Cause Alarm  timeout=120s  fault_timeout=180s
    ...  lte_vdu_connection=${lte_vdu_connection}   log_prefix=${below_info_prefix}
    Log  ${info_prefix}Bts Reset Cause (faultID=4592) alarm has been checked  console=${log_to_console}
    Log  ${ok_prefix_green}Step 2: Perform LTE vDU commissioning  console=${log_to_console}

Step 3: Postconditions Lte vDU Commissioning
    Log  ${dots_prefix_green}Step 3: Postconditions LTE vDU commissioning console=${log_to_console}
#Wait Until all radio modules are on line
    ${rmods_count}=  vDU SCFC Get RMODs Count  scfc_file_path=${lte_scfc_file_path}
    Wait Until All Radio Modules Are Online  lte_rmods_count=${rmods_count}
    ...  timeout=30s  lte_vdu_connection=${lte_vdu_connection}
    Log  ${info_prefix}All radio modules are on line  console=${log_to_console}
#Wait until all cells are OnAir
    ${lcells_count}=  vDU SCFC Get LCELL Count  scfc_file_path=${lte_scfc_file_path}
    Set Test Variable  ${lcells_count}
    Wait Until All Cells Are OnAir  lcells_count=${lcells_count}
    ...  timeout=30s  lte_vdu_connection=${lte_vdu_connection}
    Log  ${info_prefix}All LTE cells are OnAir  console=${log_to_console}
#Check vDU operational state
    vDU Wait For Expected Operational State  vdu_state_value=onAir
    ...  vdu_check=${False}  lte_vdu_check=${True}
    ...  lte_vdu_connection=${lte_vdu_connection}
    Log  ${info_prefix}LTE vDU operational state is onAir  console=${log_to_console}
    Log  ${ok_prefix_green}Step 3: Postconditions LTE vDU commissioning  console=${log_to_console}
