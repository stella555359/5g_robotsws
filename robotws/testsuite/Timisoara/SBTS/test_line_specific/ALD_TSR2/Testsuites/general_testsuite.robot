*** Settings ***
Documentation
...    Author: tomasz.marchewka@nokia.com
...    Description: Suite prepared for ALD tests execution
...    Group in charge: I_MN_RAN_PZ_3_WRO_1_GMS <I_MN_RAN_PZ_3_WRO_1@internal.nsn.com>
...    Sample execution:
...    robot -v CONFIGURATION:Wroclaw.10_16_UTESRANxxxx -C on -T -d /home/ute/test_results -L TRACE -b debug.log
...    -V /home/ute/testline_configuration/10_16_UTESRANxxxx testsuite/Wroclaw/OAM/RAN_PZ_WRO3_SG01/ALD/Testsuites/general_testsuite.robot

Resource    taf/rfrl/uuf4all/uuf4all_test_cases.robot
Resource    taf/rfrl/uuf4all/uuf4all_keywords.robot
Resource    ../../../../RRM/VRF_WRO2_T08/resources/testline_preparation_4g/testline_preparation_4g.robot
Resource    ../Testcases/ALD.01_ALD_HW_Restart/test.robot
Resource    ../Testcases/ALD.02_ALD_SW_Restart/test.robot
Resource    ../Testcases/ALD.03_ALD_Additional_data_for_ALDs/test.robot
Resource    ../Testcases/ALD.04_ALD_BTS_Reconfiguration_with_ALDs_removal/test.robot
Resource    ../Testcases/ALD.05_ALD_BTS_Reconfiguration_with_ALDs_ALD_reassignment/test.robot
Resource    ../Testcases/ALD.06_ALD_Manual_commissioning_with_Nokia_MHA_ALDs_assigned_as_external_units/test.robot
Resource    ../Testcases/ALD.07_ALD_Manual_commissioning_with_Nokia_MHA_Passdev_as_RX_Gain/test.robot
Resource    ../Testcases/ALD.08_ALD_DC_voltage_management_in_runtime/test.robot
Resource    ../Testcases/ALD.09_ALD_DC_voltage_management_with_reset/test.robot
Resource    ../Testcases/ALD.10_ALD_HDLC_Communication_management_with_reset/test.robot
Resource    ../Testcases/ALD.11_ALD_HDLC_Communication_management_in_runtime/test.robot
Resource    ../Testcases/ALD.12_ALD_Detect_and_setup_AL_devices_Lock_Unlock/test.robot
Resource    ../Testcases/ALD.13_ALD_Detect_and_setup_RF_module_reset_with_configured_ALDs/test.robot
Resource    ../Testcases/ALD.14_ALD_Detect_and_setup_AL_devices_start-up/test.robot
Resource    ../Testcases/ALD.15_ALD_Detect_and_setup_AL_devices_SW_Update/test.robot
Resource    ../Testcases/ALD.16_ALD_Software_upgrade_for_ALDs/test.robot
Resource    ../Testcases/ALD.17_ALD_Configure_Commissioned_RET_Antenna/test.robot
Resource    ../Testcases/ALD.18_ALD_Configure_RET_Antenna_from_runtime_view/test.robot
Resource    ../Testcases/ALD.19_ALD_Planned_commissioning_with_Nokia_MHA/test.robot
Resource    ../Testcases/ALD.20_ALD_RET_No_Connection_To_Unit/test.robot
Resource    ../Testcases/ALD.21_ALD_MHA_No_Connection_To_Unit/test.robot
Resource    ../Testcases/ALD.22_ALD_Activate_MHA_auto_configure_feature_after_BTS_commissioning/test.robot
Resource    ../Testcases/ALD.23_ALD_MHA_Overcurrent_alarm_in_AISG/test.robot
Resource    ../Testcases/ALD.24_ALD_MHA_Overcurrent_alarm_in_CWA/test.robot
Resource    ../Testcases/ALD.25_ALD_MHA_Above_Current/test.robot
Resource    ../Testcases/ALD.26_ALD_MHA_Below_Current/test.robot
Resource    ../Testcases/ALD.27_ALD_RS485_Power_Failure/test.robot
Resource    ../Testcases/ALD.28_CB008605_ALD_Sharing_Management_In_ALD_Selection_Window_In_WebEM/test.robot
Resource    ../Testcases/ALD.29_CB008605_ALD_Commissioning_from_ALD_selection_window_in_WebEM/test.robot
Resource    ../Testcases/ALD.30_CB006856_ALD_RAE_Reading_2D_beamforming_weight_factors/test.robot
Resource    ../Testcases/ALD.31_CB008219_IMF_Bypass_Mode/test.robot
Resource    ../Testcases/ALD.32_CB008219_Changing_Multi_Band_MHA_Operating_Mode/test.robot
Resource    ../Testcases/CLI.01_Admin_CLI_setRETProperties/test.robot
Resource    ../Testcases/CLI.02_Admin_CLI_setTiltAngle/test.robot
Resource    ../Testcases/CLI.03_Admin_CLI_calibrateTilt/test.robot
Resource    ../Testcases/CLI.04_Admin_CLI_getRETById/test.robot
Resource    ../Testcases/CLI.05_Admin_CLI_ALDSharing/test.robot

Force Tags
...           SBTS00  SBTS22R1  SBTS22R2  SBTS22R3  SBTS22R4  CRT  # Branch indicator; Test Phase indicator; Scope indicator
...           QCP_RAN_ST    QCD_MN_RAN  ## QC project; QC domain for reporting
...           PY39  ## force python3 UTE package

#Suite Setup       Test Suite Setup
#Suite Teardown    Test Suite Teardown

*** Variables ***
${TEST_ITERATION}              1
@{CUSTOM_ALARMS}               @{EMPTY}
@{CRITICAL_FAULTS}             @{EMPTY}
${SHOULD_BE_REPORTED}          ${False}
@{CUSTOMERS_LIST}              Generic
${SOURCE_SW}                   ${None}
${TARGET_SW}                   ${None}
${TARGET_SW_PATH}              ${None}
${USE_BUILDS_STORAGE}          ${False}
${RESTORE_TO_TARGET_SW}        ${True}
${PERFORM_UBOOT_DOWNGRADE}     ${True}
${DISABLE_SYSLOG_CHECK}        ${True}
@{USER_SUSPICIOUS_PRINTS}      @{EMPTY}
${ALARM_TIMEOUT}               120
${HARDWARE_CHECK_TIMEOUT}      900
@{SYSLOG_IGNORED_PRINTS}       INF

*** Test Cases ***
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI_N-x
    [Timeout]   24h
    Set Test Variable  ${ALARM_TIMEOUT}  180
    Set Test Variable  ${HARDWARE_CHECK_TIMEOUT}  600
    Set Test Variable  @{SYSLOG_IGNORED_PRINTS}  INF
    ${SOURCE_SW}  Get Source SW
    ${TARGET_SW}  Get Target SW
    UUF4ALL_SW_UPGRADE_TEST
    ...          test_iteration=${TEST_ITERATION}
    ...          custom_alarms=${CUSTOM_ALARMS}
    ...          critical_faults=${CRITICAL_FAULTS}
    ...          should_be_reported=${SHOULD_BE_REPORTED}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          5g_source_sw=${SOURCE_SW}
    ...          5g_target_sw=${TARGET_SW}
    ...          5g_target_sw_path=${TARGET_SW_PATH}
    ...          use_builds_storage=${USE_BUILDS_STORAGE}
    ...          restore_to_target_sw=${RESTORE_TO_TARGET_SW}
    ...          perform_uboot_downgrade=${PERFORM_UBOOT_DOWNGRADE}
    ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
    ...          user_suspicious_prints=${USER_SUSPICIOUS_PRINTS}
    [Teardown]   Run Keyword If Test Failed   Set Test Failed

[1][1.0] Automated__ALD__ALD HW Restart
    [Setup]  common.Common Test Setup
    ALD.01_ALD_HW_Restart
    [Teardown]  ALD.01_ALD_HW_Restart.Test Case Teardown

[1][1.0] Automated__ALD__ALD SW Restart
    [Setup]  common.Common Test Setup
    ALD.02_ALD_SW_Restart
    [Teardown]  ALD.02_ALD_SW_Restart.Test Case Teardown

[1][2.0] Automated_ALD__Additional data for ALDs
    [Setup]  common.Common Test Setup
    ALD.03_ALD_Additional_data_for_ALDs
    [Teardown]  ALD.03_ALD_Additional_data_for_ALDs.Test Case Teardown

[1][1.1] Automated__ALD__BTS Reconfiguration with ALDs removal
    [Setup]  common.Common Test Setup
    ALD.04_ALD_BTS_Reconfiguration_with_ALDs_removal
    [Teardown]  ALD.04_ALD_BTS_Reconfiguration_with_ALDs_removal.Test Case Teardown

[1][1.1] Automated__ALD__BTS Reconfiguration with ALDs_ALD reassignment
    [Setup]  common.Common Test Setup
    ALD.05_ALD_BTS_Reconfiguration_with_ALDs_ALD_reassignment
    [Teardown]  ALD.05_ALD_BTS_Reconfiguration_with_ALDs_ALD_reassignment.Test Case Teardown

[1][1.1] Automated__ALD__Manual commissioning with Nokia MHA_ALDs assigned as external units
    [Setup]  common.Common Test Setup
    ALD.06_ALD_Manual_commissioning_with_Nokia_MHA_ALDs_assigned_as_external_units
    [Teardown]  ALD.06_ALD_Manual_commissioning_with_Nokia_MHA_ALDs_assigned_as_external_units.Test Case Teardown

[1][1.1] Automated__ALD__Manual commissioning with Nokia MHA_Passdev as RX Gain
    [Setup]  common.Common Test Setup
    ALD.07_ALD_Manual_commissioning_with_Nokia_MHA_Passdev_as_RX_Gain
    [Teardown]  ALD.07_ALD_Manual_commissioning_with_Nokia_MHA_Passdev_as_RX_Gain.Test Case Teardown

[1][1.1] Automated__ALD__DC voltage management in runtime
    [Setup]  common.Common Test Setup
    ALD.08_ALD_DC_voltage_management_in_runtime
    [Teardown]  ALD.08_ALD_DC_voltage_management_in_runtime.Test Case Teardown

[1][1.0] Automated__ALD__DC voltage management with reset
    [Setup]  common.Common Test Setup
    ALD.09_ALD_DC_voltage_management_with_reset
    [Teardown]  ALD.09_ALD_DC_voltage_management_with_reset.Test Case Teardown

[1][1.1] Automated__ALD__HDLC Communication management with reset
    [Setup]  common.Common Test Setup
    ALD.10_ALD_HDLC_Communication_management_with_reset
    [Teardown]  ALD.10_ALD_HDLC_Communication_management_with_reset.Test Case Teardown

[1][1.0] Automated__ALD__HDLC Communication management in runtime
    [Setup]  common.Common Test Setup
    ALD.11_ALD_HDLC_Communication_management_in_runtime
    [Teardown]  ALD.11_ALD_HDLC_Communication_management_in_runtime.Test Case Teardown

[1][1.0] Automated__ALD__Detect and setup AL devices Lock Unlock
    [Setup]  common.Common Test Setup
    ALD.12_ALD_Detect_and_setup_AL_devices_Lock_Unlock
    [Teardown]  ALD.12_ALD_Detect_and_setup_AL_devices_Lock_Unlock.Test Case Teardown

[1][1.1] Automated__ALD__Detect and setup__RF module reset with configured ALDs
    [Setup]  common.Common Test Setup
    ALD.13_ALD_Detect_and_setup_RF_module_reset_with_configured_ALDs
    [Teardown]  ALD.13_ALD_Detect_and_setup_RF_module_reset_with_configured_ALDs.Test Case Teardown

[1][1.1] Automated__ALD__Detect and setup AL devices Start-up
    [Setup]  common.Common Test Setup
    ALD.14_ALD_Detect_and_setup_AL_devices_start-up
    [Teardown]  ALD.14_ALD_Detect_and_setup_AL_devices_start-up.Test Case Teardown

[1][1.0] Automated__ALD__Detect_and_setup_AL_devices_SW_Update
    [Setup]  common.Common Test Setup
    ALD.15_ALD_Detect_and_setup_AL_devices_SW_Update
    [Teardown]  ALD.15_ALD_Detect_and_setup_AL_devices_SW_Update.Test Case Teardown

[1][1.0] Automated__ALD__Software upgrade for ALDs
    [Setup]  common.Common Test Setup
    ALD.16_ALD_Software_upgrade_for_ALDs
    [Teardown]  ALD.16_ALD_Software_upgrade_for_ALDs.Test Case Teardown

[1][1.1] Automated__ALD__Configure_Commissioned_RET_Antenna
    [Setup]  common.Common Test Setup
    ALD.17_ALD_Configure_Commissioned_RET_Antenna
    [Teardown]  ALD.17_ALD_Configure_Commissioned_RET_Antenna.Test Case Teardown

[1][1.0] Automated__ALD__Configure RET Antenna from runtime view
    [Setup]  common.Common Test Setup
    ALD.18_ALD_Configure_RET_Antenna_from_runtime_view
    [Teardown]  ALD.18_ALD_Configure_RET_Antenna_from_runtime_view.Test Case Teardown

[1][1.1] Automated__ALD__Planned commissioning with Nokia MHA
    [Setup]  common.Common Test Setup
    ALD.19_ALD_Planned_commissioning_with_Nokia_MHA
    [Teardown]  ALD.19_ALD_Planned_commissioning_with_Nokia_MHA.Test Case Teardown

[1][1.1] Automated__ALD__RET_AISG2.0_No_Connection_To_Unit
    [Setup]  common.Common Test Setup
    ALD.20_ALD_RET_No_Connection_To_Unit
    [Teardown]  ALD.20_ALD_RET_No_Connection_To_Unit.Test Case Teardown

[1][1.1] Automated__ALD__MHA_AISG2.0_No_Connection_To_Unit
    [Setup]  common.Common Test Setup
    ALD.21_ALD_MHA_No_Connection_To_Unit
    [Teardown]  ALD.21_ALD_MHA_No_Connection_To_Unit.Test Case Teardown

[1][1.0] Automated__ALD__Activate MHA auto configure feature after BTS commissioning
    [Setup]  common.Common Test Setup
    ALD.22_ALD_Activate_MHA_auto_configure_feature_after_BTS_commissioning
    [Teardown]  ALD.22_ALD_Activate_MHA_auto_configure_feature_after_BTS_commissioning.Test Case Teardown

[1][1.0] Automated__ALD__MHA_Overcurrent_alarm_in_AISG_mode_with_RM_Lock_Unlock
    [Setup]  Run Keywords  common.Common Test Setup
    ...  AND  Set Test Variable  ${OC_INTERFACE}  OC_MDGA
    ...  AND  Set Test Variable  ${ANTL_A}  /RMOD_A-4/ANTL_A-19
    ALD.23_ALD_MHA_Overcurrent_alarm_in_AISG
    [Teardown]  ALD.23_ALD_MHA_Overcurrent_alarm_in_AISG.Test Case Teardown

[1][1.0] Automated__ALD__MHA_Overcurrent_alarm_in_CWA_mode_with_RM_Lock_Unlock
    [Setup]  Run Keywords  common.Common Test Setup
    ...  AND  Set Test Variable  ${OC_INTERFACE}  OC_MDGA
    ...  AND  Set Test Variable  ${ANTL_A}  /RMOD_A-4/ANTL_A-19
    ALD.24_ALD_MHA_Overcurrent_alarm_in_CWA
    [Teardown]  ALD.24_ALD_MHA_Overcurrent_alarm_in_CWA.Test Case Teardown

[1][1.1] Automated__ALD__MHA Above Current alarm
    [Setup]  Run Keywords  common.Common Test Setup
    ...  AND  Set Test Variable  ${ABOVE_INTERFACE}  MHA_WMHD_ABOVE_LNA1
    ...  AND  Set Test Variable  ${ANTL_A}  /RMOD_A-5/ANTL_A-2
    ALD.25_ALD_MHA_Above_Current
    [Teardown]  ALD.25_ALD_MHA_Above_Current.Test Case Teardown

[1][1.0] Automated__ALD__MHA Below Current alarm with RM Lock Unlock
    [Setup]  Run Keywords  common.Common Test Setup
    ...  AND  Set Test Variable  ${BELOW_INTERFACE}  MHA_XJ123602576_LNA2
    ...  AND  Set Test Variable  ${ANTL_A}  /RMOD_A-5/ANTL_A-2
    ALD.26_ALD_MHA_Below_Current
    [Teardown]  ALD.26_ALD_MHA_Below_Current.Test Case Teardown

[1][1.0] Automated__ALD__RS485_Power_Failure_with_RM_Lock_Unlock
    [Setup]  Run Keywords  common.Common Test Setup
    ...  AND  Set Test Variable  ${RS485_FAILURE}  RET_RS485_FAILURE
    ...  AND  Set Test Variable  ${RMOD_A}  RMOD_A-4
    ALD.27_ALD_RS485_Power_Failure
    [Teardown]  ALD.27_ALD_RS485_Power_Failure.Test Case Teardown

[1][1.0] Automated__ALD__ALD_sharing_management_in_ALD_selection_window_in_WebEM
    [Setup]  common.Common Test Setup
    ALD.28_CB008605_ALD_Sharing_Management_In_ALD_Selection_Window_In_WebEM
    [Teardown]  ALD.28_CB008605_ALD_Sharing_Management_In_ALD_Selection_Window_In_WebEM.Test Case Teardown

[1][1.0] Automated__ALD__ALD_Commissioning_from_ALD_selection_window_in_WebEM
    [Setup]  common.Common Test Setup
    ALD.29_CB008605_ALD_Commissioning_from_ALD_selection_window_in_WebEM
    [Teardown]  ALD.29_CB008605_ALD_Commissioning_from_ALD_selection_window_in_WebEM.Test Case Teardown

[1][1.0] Automated__ALD__RAE_Reading_2D_beamforming_weight_factors
    [Setup]  common.Common Test Setup
    ALD.30_CB006856_ALD_RAE_Reading_2D_beamforming_weight_factors
    [Teardown]  ALD.30_CB006856_ALD_RAE_Reading_2D_beamforming_weight_factors.Test Case Teardown

[1][1.0] ALD__ALD MHA and IMF mode change
    [Setup]  common.Common Test Setup
    ALD.31_CB008219_IMF_Bypass_Mode
    [Teardown]  ALD.31_CB008219_IMF_Bypass_Mode.Test Case Teardown

[1][1.0] ALD__ALD Changing operating mode of Multi-band MHA
    [Setup]  common.Common Test Setup
    ALD.32_CB008219_Changing_Multi_Band_MHA_Operating_Mode
    [Teardown]  ALD.32_CB008219_Changing_Multi_Band_MHA_Operating_Mode.Test Case Teardown

[1][1.0] Automated__ALD__BTS_Remote_Tool_command_RET_Unit_ConfFile_application
    [Setup]  common.Common Test Setup
    CLI.01_Admin_CLI_setRETProperties
    CLI.02_Admin_CLI_setTiltAngle
    CLI.03_Admin_CLI_calibrateTilt
    [Teardown]  common.Common Test Teardown

[1][1.0] Automated__ALD__BTS_Remote_Tool_command_RET_Unit_Editable_Parameter_setting
    [Setup]  common.Common Test Setup
    CLI.02_Admin_CLI_setTiltAngle
    [Teardown]  CLI.02_Admin_CLI_setTiltAngle.Test Case Teardown

[1][1.0] Automated__ALD__BTS_Remote_Tool_command_RET_Unit_information_retrieving
    [Setup]  common.Common Test Setup
    CLI.04_Admin_CLI_getRETById
    [Teardown]  common.Common Test Teardown

[1]Automated__ALD__CLI support for ALD sharing
    [Setup]  common.Common Test Setup
    CLI.05_Admin_CLI_ALDSharing
    [Teardown]  CLI.05_Admin_CLI_ALDSharing.Test Case Teardown

*** Keywords ***
Set Test Failed
    Set Suite Variable  ${UPDATE_TEST_FAILED}  ${True}
