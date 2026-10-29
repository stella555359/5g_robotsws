*** Settings ***
Documentation
...    Author: tomasz.marchewka@nokia.com
...    Description: Suite prepared for ALD tests execution
...    Group in charge: I_MN_RAN_PZ_3_WRO_1_GMS <I_MN_RAN_PZ_3_WRO_1@internal.nsn.com>
...    Sample execution:
...    robot -v CONFIGURATION:Wroclaw.10_16_UTESRAN3898 -C on -T -d /home/ute/test_results -L TRACE -b debug.log
...    -V /home/ute/testline_configuration/10_16_UTESRAN3898 testsuite/Wroclaw/OAM/RAN_PZ_WRO3_SG01/ALD/Testsuites/SBTS_9040_Rins/sbts_crt.robot


#Resource        taf/rfrl/uuf4all/uuf4all_test_cases.robot
#Resource        taf/rfrl/uuf4all/uuf4all_keywords.robot
#Resource        ../../../../../RRM/VRF_WRO2_T08/resources/testline_preparation_4g/testline_preparation_4g.robot
Resource         ../../ALD/Testcases/ALD.14_ALD_Detect_and_setup_AL_devices_start-up/test.robot
Resource         ../../ALD/Testcases/ALD.28_CB008605_ALD_Sharing_Management_In_ALD_Selection_Window_In_WebEM/test.robot
Resource         ../../ALD/Testcases/ALD.29_CB008605_ALD_Commissioning_from_ALD_selection_window_in_WebEM/test.robot
Resource         ../../ALD/Testcases/ALD.30_CB006856_ALD_RAE_Reading_2D_beamforming_weight_factors/test.robot
Resource         ../../ALD/Testcases/ALD.33_CB006856_ALD_Read_RAE_sensor_telemetry_periodically_Netact/test.robot
Resource         ../../ALD/Testcases/ALD.34_CB006856_ALD_Read_RAE_sensor_telemetry_on_demand/test.robot
Resource         ../../ALD/Testcases/ALD.35_CB006856_ALD_RAE_Reading_1D_beamforming_weight_factors/test.robot
Resource         ../../ALD/Testcases/CLI.05_Admin_CLI_ALDSharing/test.robot

Force Tags
...           SBTS00    CRT    RAN_5G  # Branch indicator; Test Phase indicator; Scope indicator
...           QCP_RAN_VRF  QCD_MN_RAN  ## QC project; QC domain for reporting
...           SRAN
...           PY39  ## force python3 UTE package
...           CLOUD_SRAN_NL_10364_1ASOF_1AHCE_2AHEJ  # label
...           SKIP_INSTALL_TOOLS
#...           SKIP_SCF_VALIDATION

#Suite Setup       Test Suite Setup
#Suite Teardown    Test Suite Teardown


*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${ENB_BUILD}    SBTS00_ENB_9999_211207_000006
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1364
${COMMISSIONING_PATH}  /home/ute/testline_configuration/10_18_UTESRANCLOUD1364/node1/BTS_CLOUD_SRAN_NL_10364_1ASOF_1AHCE_2AHEJ_SBTS25R1.xml

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

[1][1.1] Automated__ALD__Detect and setup AL devices Start-up
    [Setup]  common.Common Test Setup
    ALD.14_ALD_Detect_and_setup_AL_devices_start-up
    [Teardown]  ALD.14_ALD_Detect_and_setup_AL_devices_start-up.Test Case Teardown

[1][1.0] Automated__ALD__sharing management in ALD selection window in WebEM
    [Setup]  common.Common Test Setup
    ALD.28_CB008605_ALD_Sharing_Management_In_ALD_Selection_Window_In_WebEM
    [Teardown]  ALD.28_CB008605_ALD_Sharing_Management_In_ALD_Selection_Window_In_WebEM.Test Case Teardown

[1][1.0] Automated__ALD__Commissioning from ALD selection window in WebEM
    [Setup]  common.Common Test Setup
    ALD.29_CB008605_ALD_Commissioning_from_ALD_selection_window_in_WebEM
    [Teardown]  ALD.29_CB008605_ALD_Commissioning_from_ALD_selection_window_in_WebEM.Test Case Teardown

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

[1][1.0] Automated__ALD__CLI support for ALD sharing
    [Setup]  common.Common Test Setup
    CLI.05_Admin_CLI_ALDSharing
    [Teardown]  CLI.05_Admin_CLI_ALDSharing.Test Case Teardown
