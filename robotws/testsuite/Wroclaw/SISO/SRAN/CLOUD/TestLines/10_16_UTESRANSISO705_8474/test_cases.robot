*** Settings ***
Documentation
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn

Resource    ../../resources/Robot/setup_teardown.robot
Resource    ../../resources/Robot/sbts_setup_teardown.robot
Resource    ../../TestCases/SM/Cloud_SM_Cell_Block_Unblock.robot
#Resource    ../../TestCases/SM/Cloud_SM_Radio_Modules_Lock_Unlock.robot
#Resource    ../../TestCases/SM/Cloud_SM_RF_Reset_From_GUI.robot
#Resource    ../../TestCases/REC/Cloud_REC_Radio_Modules_Hot_Remove_Hot_Insert.robot
#Resource    ../../TestCases/STARTUP/Cloud_STARTUP_Radio_Modules_Power_Reset.robot
#Resource    ../../TestCases/STARTUP/Cloud_STARTUP_vDU_Reset.robot
#Resource    ../../TestCases/STARTUP/Cloud_STARTUP_vCU_Reset.robot
#Resource    ../../TestCases/CM/Cloud_CM_vDU_Commissioning.robot
#Resource    ../../TestCases/CM/Cloud_CM_vDU_Delta_Recommissioning.robot
#Resource    ../../TestCases/CALL/Cloud_CALL_NR_Data_Transfer.robot
#Resource     ../../TestCases/PM/Cloud_PM_Activation_Deactivation_Of_Energy_Consumption_Measurement.robot
#Resource     ../../TestCases/PM/Cloud_PM_Cell_Availability_Monitoring_With_Energy_Efficiency_Enhancement.robot
#Resource    ../../TestCases/PM/Cloud_PM_MicroDTX_Activation_Verification.robot
#Resource    ../../TestCases/PM/Cloud_PM_PIM_Alarms_Triggering.robot
#Resource    ../../TestCases/PM/Cloud_PM_PIMC_Counters.robot
#Resource    ../../TestCases/PM/Cloud_PM_Radio_Module_Fan_Speed_Counters_Monitoring.robot
#Resource    ../../TestCases/PM/Cloud_PM_Radio_Module_Thermal_Counters_Monitoring.robot
#Resource    ../../TestCases/PM/Cloud_PM_Radio_Module_Thermal_Counters_Monitoring_And_Alarm_Triggering.robot
#Resource    ../../TestCases/REC/Cloud_REC_RU_Entering_Deep_Sleep_Mode_And_Power_Reset_Recovery_Action.robot
#Resource    ../../TestCases/REC/Cloud_REC_RU_Entering_Deep_Sleep_Mode_And_Returning_By_One_Cell_Unblock.robot
#Resource    ../../TestCases/REC/Cloud_REC_Sync_Source_Switch_Over_From_Primary_To_Secondary.robot
#Resource    ../../TestCases/TEST/Cloud_TEST_Online_RF_Scanning.robot
#Resource    ../../TestCases/TEST/Cloud_TEST_TDS_RF_Scanning.robot
#Resource    ../../TestCases/TEST/Cloud_TEST_Start_Stop_NR_TestModels.robot
#Resource    ../../TestCases/STARTUP/Cloud_STARTUP_LTE_vDU_Reset.robot
#Resource    ../../TestCases/CM/Cloud_CM_LTE_vDU_Commissioning.robot
#Resource    ../../TestCases/SM/CloudSBTS_SBTS_SM_Cell_Block_Unblock.robot
#Resource    ../../TestCases/SM/SBTS_SM_Cell_Block_Unblock.robot
#Resource    ../../TestCases/SM/SBTS_SM_Radio_Modules_Lock_Unlock.robot
#Resource    ../../TestCases/SM/CloudSBTS_SBTS_SM_Radio_Modules_Lock_Unlock.robot
#Resource    ../../TestCases/N_A/Cloud_STARTUP_Radio_Modules_Reset.robot
#Resource    ../../TestCases/N_A/SBTS_STARTUP_Radio_Modules_Reset.robot
#Resource    ../../TestCases/STARTUP/CloudSBTS_SBTS_STARTUP_Radio_Modules_Reset.robot

#Suite Setup       Shared Suite Setup
#                  ...  sbts_scfc_file_path=${SBTS_SCF_PATH}
#Suite Teardown    Shared Suite Teardown
Suite Setup       AiC Suite Setup
Suite Teardown    AiC Suite Teardown  get_logs=${True}
#Suite Setup       SBTS Suite Setup  scfc_file_path=${SBTS_SCF_PATH}
#Suite Teardown    SBTS Suite Teardown

*** Variables ***
#${VDU_SCF_PATH}=             ${CURDIR}/SCF/SCFC_vDU.xml
${VDU_SCF_PATH}=             ${CURDIR}/SCF/SCFC_vDU_runtime.xml
${VCU_SCF_PATH}=             ${CURDIR}/SCF/SCFC_vCU.xml
#${SBTS_SCF_PATH}=             ${CURDIR}/SCF/SCFC_CA_CATM_R4BN9_ARGA_AREA.xml
${SBTS_SCF_PATH}=             ${CURDIR}/SCF/SCFC_CA_CATM_R4BN9_ARGA_AREA_runtime.xml

#${VDU_SCF_PATH}=             ${CURDIR}/SCF_8714_shared/SCFC_vDU.xml
#${VCU_SCF_PATH}=             ${CURDIR}/SCF_8714_shared/SCFC_vCU.xml
#${SBTS_SCF_PATH}=            ${CURDIR}/SCF_8714_shared/SCFC_SBTS.xml

#${RMOD_SN}=        K9181046216
#@{RMOD_SN_LIST}=  K9175116255
@{CBTS_RMOD_SN_LIST}=  K9175116255
@{SBTS_RMOD_SN_LIST}=  CUS001001C7
#@{RMOD_SN_LIST}=  @{EMPTY}
#@{SBTS_CELL_LIST}=  3  7  1
@{CBTS_CELL_LIST}=  3  5

*** Test Cases ***
[1][1.0] Automated_AIC_Cell_Block_Unblock
    [Setup]  AiC Test Setup
    TC__Cloud_SM_Cell_Block_Unblock
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  cbts_cells_id_list=${CBTS_CELL_LIST}
    [Teardown]  AiC Test Teardown
    ...  get_logs=${True}

#[1][1.0] Automated_Cell_Block_Unblock
#    TC__SBTS_SM_Cell_Block_Unblock
#    ...  sbts_scfc_file_path=${SBTS_SCF_PATH}
#    [Teardown]  SBTS Test Teardown
#
#[1][1.0] Automated_Cell_Block_Unblock
#    [Setup]  Shared Test Setup
#    TC__Cloud_SBTS_CM_Cell_Block_Unblock
#    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
#    ...  sbts_scfc_file_path=${SBTS_SCF_PATH}
#    ...  cbts_cells_id_list=${CBTS_CELL_LIST}
#    ...  sbts_cells_id_list=${SBTS_CELL_LIST}
#    ...  get_kpi=${True}
#    ...  vdu_connection=${VDU_CONNECTION_DEFAULT}
#    ...  admin_connection=${ADMIN_CONNECTION_DEFAULT}
#    [Teardown]  Shared Test Teardown
#    ...  cbts_get_logs=${False}

#[1][1.0] Automated_AIC_RF_Module_Lock_Unlock
#    [Setup]  AiC Test Setup
#    TC__Cloud_SM_Radio_Modules_Lock_Unlock
#    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
#    ...  cbts_rmods_sn=${RMOD_SN_LIST}
#    [Teardown]  AiC Test Teardown
#    ...  get_logs=${True}

#[1][1.0] Automated_RF_Module_Lock_Unlock
#    TC__SBTS_SM_Radio_Modules_Lock_Unlock
#    ...  sbts_scfc_file_path=${SBTS_SCF_PATH}
##    [Teardown]  SBTS Teardown Test Case

#[1][1.0] Automated_RF_Module_Lock_Unlock
#    TC__Cloud_SBTS_SM_Radio_Modules_Lock_Unlock
#    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
#    ...  sbts_scfc_file_path=${SBTS_SCF_PATH}
##    [Teardown]  SBTS Teardown Test Case

#[1][1.0] Automated_RF_Module_Lock_Unlock
#    [Setup]  Shared Test Setup
#    TC__Cloud_SBTS_SM_Radio_Modules_Lock_Unlock
#    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
#    ...  sbts_scfc_file_path=${SBTS_SCF_PATH}
##    ...  cbts_rmod_sn_list=${CBTS_RMOD_SN_LIST}
##    ...  sbts_rmod_sn_list=${SBTS_RMOD_SN_LIST}
#    ...  sbts_rmod_sn_count=1
#    ...  cbts_rmod_sn_count=1
#    ...  vdu_connection=${VDU_CONNECTION_DEFAULT}
#    ...  admin_connection=${ADMIN_CONNECTION_DEFAULT}
#    [Teardown]  Shared Test Teardown

#[1][1.0] Automated_AIC_Radio_Modules_Reset
#    [Setup]  AiC Test Setup
#    TC__Cloud_STARTUP_Radio_Modules_Reset
#    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
#    ...  cbts_rmod_sn_list=${RMOD_SN_LIST}
#    [Teardown]  AiC Test Teardown
#    ...  get_logs=False

#[1][1.0] Automated_Radio_Modules_Reset
#    TC__SBTS_STARTUP_Radio_Modules_Reset
#    ...  sbts_scfc_file_path=${SBTS_SCF_PATH}
#    ...  sbts_rmod_sn_list=${RMOD_SN_LIST}
#    ...  get_kpi=${True}
#    [Teardown]  SBTS Teardown Test Case

#[1][1.0] Automated_RF_Module_Reset
#    [Setup]  Shared Test Setup
#    TC__Cloud_SBTS_STARTUP_Radio_Modules_Reset
#    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
#    ...  sbts_scfc_file_path=${SBTS_SCF_PATH}
#    ...  cbts_rmod_sn_list=${CBTS_RMOD_SN_LIST}
#    ...  sbts_rmod_sn_list=${SBTS_RMOD_SN_LIST}
#    ...  get_kpi=${True}
#    ...  vdu_connection=${VDU_CONNECTION_DEFAULT}
#    ...  admin_connection=${ADMIN_CONNECTION_DEFAULT}
#    [Teardown]  Shared Test Teardown

#
#*** Keywords ***
#Shared Suite Setup
#    [Arguments]  ${sbts_scfc_file_path}  ${swconfig_file_path}=${SWCONFIG_FILE_PATH}
#    ...  ${logs_dir_path}=${SUITE_LOGS_DIR_PATH}  ${set_prefix}=${True}  ${log_to_console}=${True}
#    [Documentation]
#    ...  Description:
#    ...  Keyword prepares the test environment to start sharing CBTS-SBTS test cases.
#    ...
#    ...  Arguments:
#    ...  +========================+======+============================================================================+
#    ...  | Argument               | Man. | Description                                                                |
#    ...  +========================+======+============================================================================+
#    ...  | sbts_scfc_file_path    | Yes  | Path to the default SBTS scfc file.                                        |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...  | swconfig_file_path     | Yes  | Path to the default SBTS swconfig file.                                    |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...  | logs_dir_path          | Yes  | Path to directory where logs file should be stored.                        |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...  | set_prefix             |  No  | Set (or not) log prefix to message.                                        |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...  | log_to_console         |  No  | Log text to console.                                                       |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...
#    ...  Author: slawomir.jastrzebski@nokia.com
#    ...  Maintainer: slawomir.jastrzebski@nokia.com
#
#    AiC Suite Setup
#    ...  set_prefix=${set_prefix}
#    ...  log_to_console=${log_to_console}
#    SBTS Suite Setup
#    ...  scfc_file_path=${sbts_scfc_file_path}
#    ...  swconfig_file_path=${swconfig_file_path}
#    ...  logs_dir_path=${logs_dir_path}
#    ...  set_prefix=${set_prefix}
#    ...  log_to_console=${log_to_console}
#
#Shared Suite Teardown
#    [Arguments]  ${cbts_get_logs}=${True}  ${logs_dir_path}=${SUITE_LOGS_DIR_PATH}  ${log_to_console}=${True}
#    [Documentation]
#    ...  Description:
#    ...  Teardown keyword for shared suite execution.
#    ...
#    ...  ${cbts_get_logs} argument settings:
#    ...  ${cbts_get_logs}=${False} - logs are not collected, but only if the test is successful
#    ...                         and there are no unexpected alarms
#    ...  ${cbts_get_logs}=${True} - logs are always collected
#    ...
#    ...  Arguments:
#    ...  +========================+======+============================================================================+
#    ...  | Argument               | Man. | Description                                                                |
#    ...  +========================+======+============================================================================+
#    ...  | cbts_get_logs          |  No  | Collect logs or not.                                                       |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...  | logs_dir_path          | Yes  | Path to directory where logs files should be stored.                       |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...
#    ...  Author: slawomir.jastrzebski@nokia.com
#    ...  Maintainer: slawomir.jastrzebski@nokia.com
#
#    AiC Suite Teardown
#    ...  get_logs=${cbts_get_logs}
#    ...  log_to_console=${log_to_console}
#    SBTS Suite Teardown
#    ...  logs_dir_path=${logs_dir_path}
#    ...  log_to_console=${log_to_console}
#
#Shared Test Setup
#    [Arguments]  ${run_index}=1  ${log_to_console}=True
#    [Documentation]
#    ...  Description:
#    ...  Keyword prepares the test environment and hardware to start sharing test cases.
#    ...
#    ...  Arguments:
#    ...  +========================+======+============================================================================+
#    ...  | Argument               | Man. | Description                                                                |
#    ...  +========================+======+============================================================================+
#    ...  | run_index              |  No  | Number of single test execution.                                           |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...  | log_to_console         |  No  | Show or not the information on the console.                                |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...
#    ...  Author: slawomir.jastrzebski@nokia.com
#    ...  Maintainer: slawomir.jastrzebski@nokia.com
#
#    AiC Test Setup
#    ...  run_index=${run_index}
#    ...  log_to_console=${log_to_console}
#
#Shared Test Teardown
#    [Arguments]  ${run_index}=1  ${cbts_get_logs}=${False}  ${logs_dir_path}=${SUITE_LOGS_DIR_PATH}
#    ...  ${test_case_syslog}=${True}  ${log_to_console}=${True}
#    [Documentation]
#    ...  Description:
#    ...  Teardown keyword for shared test execution.
#    ...
#    ...  Usage:
#    ...  ${cbts_get_logs}=${False} - logs are not collected, but only if the test is successful
#    ...                         and there are no unexpected alarms
#    ...  ${cbts_get_logs}=${True} - logs are always collected
#    ...
#    ...  Arguments:
#    ...  +========================+======+============================================================================+
#    ...  | Argument               | Man. | Description                                                                |
#    ...  +========================+======+============================================================================+
#    ...  | run_index              |  No  | Number of test execution.                                                  |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...  | cbts_get_logs          |  No  | Collect logs or not.                                                       |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...  | logs_dir_path          | Yes  | Path to directory where logs files should be stored.                       |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...  | test_case_syslog       |  No  | Collect syslog file separately for each test or not.                       |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...  | log_to_console         |  No  | Logs the given message to console.                                         |
#    ...  +------------------------+------+----------------------------------------------------------------------------+
#    ...
#    ...  Author: slawomir.jastrzebski@nokia.com
#    ...  Maintainer: slawomir.jastrzebski@nokia.com
#
#    AiC Test Teardown
#    ...  run_index=${run_index}
#    ...  get_logs=${cbts_get_logs}
#    ...  log_to_console=${log_to_console}
#    SBTS Test Teardown
#    ...  logs_dir_path=${logs_dir_path}
#    ...  run_index=${run_index}
#    ...  test_case_syslog=${test_case_syslog}
#    ...  log_to_console=${log_to_console}
