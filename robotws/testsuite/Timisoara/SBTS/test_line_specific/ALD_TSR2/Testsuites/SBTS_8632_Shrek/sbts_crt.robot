*** Settings ***
Documentation
...    Author: tomasz.marchewka@nokia.com
...    Description: Suite prepared for ALD tests execution
...    Group in charge: I_MN_RAN_PZ_3_WRO_1_GMS <I_MN_RAN_PZ_3_WRO_1@internal.nsn.com>
...    Sample execution:
...    robot -v CONFIGURATION:Wroclaw.10_16_UTESRAN3232 -C on -T -d /home/ute/test_results -L TRACE -b debug.log
...    -V /home/ute/testline_configuration/10_16_UTESRAN3232 testsuite/Wroclaw/OAM/RAN_PZ_WRO3_SG01/ALD/Testsuites/SBTS_8632_Shrek/sbts_crt.robot


#Resource        taf/rfrl/uuf4all/uuf4all_test_cases.robot
#Resource        taf/rfrl/uuf4all/uuf4all_keywords.robot
#Resource        ../../../../../RRM/VRF_WRO2_T08/resources/testline_preparation_4g/testline_preparation_4g.robot
Resource         ../../Testcases/ALD.01_ALD_HW_Restart/test.robot
Resource         ../../Testcases/ALD.02_ALD_SW_Restart/test.robot
Resource         ../../Testcases/ALD.03_ALD_Additional_data_for_ALDs/test.robot
Resource         ../../Testcases/ALD.04_ALD_BTS_Reconfiguration_with_ALDs_removal/test.robot
Resource         ../../Testcases/ALD.11_ALD_HDLC_Communication_management_in_runtime/test.robot
Resource         ../../Testcases/ALD.13_ALD_Detect_and_setup_RF_module_reset_with_configured_ALDs/test.robot
Resource         ../../Testcases/ALD.14_ALD_Detect_and_setup_AL_devices_start-up/test.robot
Resource         ../../Testcases/ALD.17_ALD_Configure_Commissioned_RET_Antenna/test.robot
Resource         ../../Testcases/ALD.28_CB008605_ALD_Sharing_Management_In_ALD_Selection_Window_In_WebEM/test.robot
Resource         ../../Testcases/ALD.29_CB008605_ALD_Commissioning_from_ALD_selection_window_in_WebEM/test.robot
Resource         ../../Testcases/ALD.30_CB006856_ALD_RAE_Reading_2D_beamforming_weight_factors/test.robot
Resource         ../../Testcases/ALD.31_CB008219_IMF_Bypass_Mode/test.robot
Resource         ../../Testcases/ALD.32_CB008219_Changing_Multi_Band_MHA_Operating_Mode/test.robot
Resource         ../../Testcases/ALD.33_CB006856_ALD_Read_RAE_sensor_telemetry_periodically_Netact/test.robot
Resource         ../../Testcases/ALD.34_CB006856_ALD_Read_RAE_sensor_telemetry_on_demand/test.robot
Resource         ../../Testcases/ALD.35_CB006856_ALD_RAE_Reading_1D_beamforming_weight_factors/test.robot
Resource         ../../Testcases/CLI.02_Admin_CLI_setTiltAngle/test.robot
Resource         ../../Testcases/CLI.04_Admin_CLI_getRETById/test.robot
Resource         ../../Testcases/CLI.05_Admin_CLI_ALDSharing/test.robot

Force Tags
...           SBTS00    CRT    RAN_5G  # Branch indicator; Test Phase indicator; Scope indicator
...           QCP_RAN_ST  QCD_MN_RAN  ## QC project; QC domain for reporting
...           CA_RAN_PZ_WRO_3
...           PY39  ## force python3 UTE package
...           CLOUD_SRAN_NLW_1ASIL_1ABIA_1ABIP_1ABIQ_1AHEGA_1FXEB_1AZQW_1AHPMDA_UTECA  # label
...           SKIP_INSTALL_TOOLS
#...           SKIP_SCF_VALIDATION

#Suite Setup       Test Suite Setup
#Suite Teardown    Test Suite Teardown

#*** Variables ***
#${TEST_ITERATION}              1
#@{CUSTOM_ALARMS}               @{EMPTY}
#@{CRITICAL_FAULTS}             @{EMPTY}
#${SHOULD_BE_REPORTED}          ${False}
#@{CUSTOMERS_LIST}              Generic
#${SOURCE_SW}                   ${None}
#${TARGET_SW}                   ${None}
#${TARGET_SW_PATH}              ${None}
#${USE_BUILDS_STORAGE}          ${False}
#${RESTORE_TO_TARGET_SW}        ${True}
#${PERFORM_UBOOT_DOWNGRADE}     ${True}
#${DISABLE_SYSLOG_CHECK}        ${True}
#@{USER_SUSPICIOUS_PRINTS}      @{EMPTY}

*** Test Cases ***
#E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI_N-x
#    [Timeout]   24h
#    ${SOURCE_SW}  Get Source SW
#    ${TARGET_SW}  Get Target SW
#    UUF4ALL_SW_UPGRADE_TEST
#    ...          test_iteration=${TEST_ITERATION}
#    ...          custom_alarms=${CUSTOM_ALARMS}
#    ...          critical_faults=${CRITICAL_FAULTS}
#    ...          should_be_reported=${SHOULD_BE_REPORTED}
#    ...          customers_list=${CUSTOMERS_LIST}
#    ...          5g_source_sw=${SOURCE_SW}
#    ...          5g_target_sw=${TARGET_SW}
#    ...          5g_target_sw_path=${TARGET_SW_PATH}
#    ...          use_builds_storage=${USE_BUILDS_STORAGE}
#    ...          restore_to_target_sw=${RESTORE_TO_TARGET_SW}
#    ...          perform_uboot_downgrade=${PERFORM_UBOOT_DOWNGRADE}
#    ...          disable_syslog_check=${DISABLE_SYSLOG_CHECK}
#    ...          user_suspicious_prints=${USER_SUSPICIOUS_PRINTS}
#    [Teardown]   Run Keyword If Test Failed   Set Test Failed

[1][1.1] Automated__ALD__ALD HW Restart
    [Setup]  common.Common Test Setup
    ALD.01_ALD_HW_Restart
    [Teardown]  ALD.01_ALD_HW_Restart.Test Case Teardown

[1][1.1] Automated__ALD__ALD SW Restart
    [Setup]  common.Common Test Setup
    ALD.02_ALD_SW_Restart
    [Teardown]  ALD.02_ALD_SW_Restart.Test Case Teardown

[1][1.1] Automated__ALD__HDLC Communication management in runtime
    [Setup]  common.Common Test Setup
    ALD.11_ALD_HDLC_Communication_management_in_runtime
    [Teardown]  ALD.11_ALD_HDLC_Communication_management_in_runtime.Test Case Teardown

[1][2.0] Automated_ALD__Additional data for ALDs
    [Setup]  common.Common Test Setup
    ALD.03_ALD_Additional_data_for_ALDs
    [Teardown]  ALD.03_ALD_Additional_data_for_ALDs.Test Case Teardown

[1][1.1] Automated__ALD__Detect and setup AL devices Start-up
    [Setup]  common.Common Test Setup
    ALD.14_ALD_Detect_and_setup_AL_devices_start-up
    [Teardown]  ALD.14_ALD_Detect_and_setup_AL_devices_start-up.Test Case Teardown

[1][1.0] ALD__ALD MHA and IMF mode change
    [Setup]  common.Common Test Setup
    ALD.31_CB008219_IMF_Bypass_Mode
    [Teardown]  ALD.31_CB008219_IMF_Bypass_Mode.Test Case Teardown

[1][1.0] ALD__ALD Changing operating mode of Multi-band MHA
    [Setup]  common.Common Test Setup
    ALD.32_CB008219_Changing_Multi_Band_MHA_Operating_Mode
    [Teardown]  ALD.32_CB008219_Changing_Multi_Band_MHA_Operating_Mode.Test Case Teardown

[1][1.0] Automated__ALD__Commissioning from ALD selection window in WebEM
    [Setup]  common.Common Test Setup
    ALD.29_CB008605_ALD_Commissioning_from_ALD_selection_window_in_WebEM
    [Teardown]  ALD.29_CB008605_ALD_Commissioning_from_ALD_selection_window_in_WebEM.Test Case Teardown

[1][1.0] Automated__ALD__sharing management in ALD selection window in WebEM
    [Setup]  common.Common Test Setup
    ALD.28_CB008605_ALD_Sharing_Management_In_ALD_Selection_Window_In_WebEM
    [Teardown]  ALD.28_CB008605_ALD_Sharing_Management_In_ALD_Selection_Window_In_WebEM.Test Case Teardown

[1][1.0] Automated__ALD__CLI support for ALD sharing
    [Setup]  common.Common Test Setup
    CLI.05_Admin_CLI_ALDSharing
    [Teardown]  CLI.05_Admin_CLI_ALDSharing.Test Case Teardown

[1][1.0] Automated__ALD__RAE_Reading_2D_beamforming_weight_factors
    [Setup]  common.Common Test Setup
    ALD.30_CB006856_ALD_RAE_Reading_2D_beamforming_weight_factors
    [Teardown]  ALD.30_CB006856_ALD_RAE_Reading_2D_beamforming_weight_factors.Test Case Teardown

[1][1.0] Automated__ALD__Read_RAE_sensor_telemetry_periodically_Netact
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    ALD.33_CB006856_ALD_Read_RAE_sensor_telemetry_periodically_Netact
    [Teardown]  ALD.33_CB006856_ALD_Read_RAE_sensor_telemetry_periodically_Netact.Test Case Teardown

[1][1.0] Automated__ALD__Read_RAE_sensor_telemetry_on_demand_with_radio_reset
    [Setup]  common.Common Test Setup
    ALD.34_CB006856_ALD_Read_RAE_sensor_telemetry_on_demand
    [Teardown]  ALD.34_CB006856_ALD_Read_RAE_sensor_telemetry_on_demand.Test Case Teardown

[1][1.0] Automated__ALD__RAE_Reading_1D_beamforming_weight_factors
    [Setup]  common.Common Test Setup
    ALD.35_CB006856_ALD_RAE_Reading_1D_beamforming_weight_factors
    [Teardown]  ALD.35_CB006856_ALD_RAE_Reading_1D_beamforming_weight_factors.Test Case Teardown

[1][1.0] Automated__ALD__BTS_Remote_Tool_command_RET_Unit_Editable_Parameter_setting
    [Setup]  common.Common Test Setup
    CLI.02_Admin_CLI_setTiltAngle
    [Teardown]  CLI.02_Admin_CLI_setTiltAngle.Test Case Teardown

[1][1.0] Automated__ALD__BTS_Remote_Tool_command_RET_Unit_information_retrieving
    [Setup]  common.Common Test Setup
    CLI.04_Admin_CLI_getRETById
    [Teardown]  common.Common Test Teardown

[1][1.1] Automated__ALD__Detect and setup__RF module reset with configured ALDs
    [Setup]  common.Common Test Setup
    ALD.13_ALD_Detect_and_setup_RF_module_reset_with_configured_ALDs
    [Teardown]  ALD.13_ALD_Detect_and_setup_RF_module_reset_with_configured_ALDs.Test Case Teardown

[1][1.1] Automated__ALD__Configure_Commissioned_RET_Antenna
    [Setup]  common.Common Test Setup
    ALD.17_ALD_Configure_Commissioned_RET_Antenna
    [Teardown]  ALD.17_ALD_Configure_Commissioned_RET_Antenna.Test Case Teardown

[1][1.1] Automated__ALD__BTS Reconfiguration with ALDs removal
    [Setup]  common.Common Test Setup
    ALD.04_ALD_BTS_Reconfiguration_with_ALDs_removal
    [Teardown]  ALD.04_ALD_BTS_Reconfiguration_with_ALDs_removal.Test Case Teardown

#*** Keywords ***
#Set Test Failed
#    Set Suite Variable  ${UPDATE_TEST_FAILED}  ${True}
