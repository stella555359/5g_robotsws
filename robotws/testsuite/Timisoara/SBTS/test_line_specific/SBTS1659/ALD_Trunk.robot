*** Settings ***
Documentation
...    Author: valentin.sorescu@nokia.com

#Resource        taf/rfrl/uuf4all/uuf4all_test_cases.robot
#Resource        taf/rfrl/uuf4all/uuf4all_keywords.robot
#Resource        ../../../../../RRM/VRF_WRO2_T08/resources/testline_preparation_4g/testline_preparation_4g.robot
Resource        ../../ALD/Testcases/ALD.01_ALD_HW_Restart/test.robot
Resource        ../../ALD/Testcases/ALD.02_ALD_SW_Restart/test.robot
Resource        ../../ALD/Testcases/ALD.03_ALD_Additional_data_for_ALDs/test.robot
Resource        ../../ALD/Testcases/ALD.05_ALD_BTS_Reconfiguration_with_ALDs_ALD_reassignment/test.robot
Resource        ../../ALD/Testcases/ALD.08_ALD_DC_voltage_management_in_runtime/test.robot
Resource        ../../ALD/Testcases/ALD.10_ALD_HDLC_Communication_management_with_reset/test.robot
Resource        ../../ALD/Testcases/ALD.12_ALD_Detect_and_setup_AL_devices_Lock_Unlock/test.robot
Resource        ../../ALD/Testcases/ALD.14_ALD_Detect_and_setup_AL_devices_start-up/test.robot
Resource        ../../ALD/Testcases/ALD.16_ALD_Software_upgrade_for_ALDs/test.robot
Resource        ../../ALD/Testcases/ALD.17_ALD_Configure_Commissioned_RET_Antenna/test.robot
Resource        ../../ALD/Testcases/ALD.19_ALD_Planned_commissioning_with_Nokia_MHA/test.robot
Resource        ../../ALD/Testcases/ALD.28_CB008605_ALD_Sharing_Management_In_ALD_Selection_Window_In_WebEM/test.robot
Resource        ../../ALD/Testcases/ALD.29_CB008605_ALD_Commissioning_from_ALD_selection_window_in_WebEM/test.robot
Resource        ../../ALD/Testcases/CLI.05_Admin_CLI_ALDSharing/test.robot
Resource        ../../ALD/Testcases/CLI.06_Admin_CLI_testRET/test.robot
Resource        ../../ALD/Testcases/CLI.07_Admin_CLI_testRET_During_Exception_Conditions/test.robot
Resource        ../../ALD/Testcases/ALD.36_ALD_Site_Reset/test.robot

Force Tags
...           SBTS00    CRT           # Branch indicator; Test Phase indicator; Scope indicator
...           QCP_RAN_VRF  QCD_MN_RAN  # QC project; QC domain for reporting
...           SRAN
...           PY39  # force python3 UTE package
...           CLOUD_SRAN_L_10659_1ASIA_2ABIA_1ExtASIK_3AHLOA_2FXFC  # label
...           SKIP_INSTALL_TOOLS

#Suite Setup       Test Suite Setup
#Suite Teardown    Test Suite Teardown

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${ENB_BUILD}    SBTS00_ENB_9999_211207_000006
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    10_18_UTESRANCLOUD1659

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

[1][2.0] Automated_ALD__Additional data for ALDs
    [Setup]  common.Common Test Setup
    ALD.03_ALD_Additional_data_for_ALDs
    [Teardown]  ALD.03_ALD_Additional_data_for_ALDs.Test Case Teardown

[1][1.1] Automated__ALD__BTS Reconfiguration with ALDs_ALD reassignment
    [Setup]  common.Common Test Setup
    ALD.05_ALD_BTS_Reconfiguration_with_ALDs_ALD_reassignment
    [Teardown]  ALD.05_ALD_BTS_Reconfiguration_with_ALDs_ALD_reassignment.Test Case Teardown


[1][1.0] Automated__ALD__Detect and setup AL devices Lock Unlock
    [Setup]  common.Common Test Setup
    ALD.12_ALD_Detect_and_setup_AL_devices_Lock_Unlock
    [Teardown]  ALD.12_ALD_Detect_and_setup_AL_devices_Lock_Unlock.Test Case Teardown

[1][1.1] Automated__ALD__Detect and setup AL devices Start-up
    [Setup]  common.Common Test Setup
    ALD.14_ALD_Detect_and_setup_AL_devices_start-up
    [Teardown]  ALD.14_ALD_Detect_and_setup_AL_devices_start-up.Test Case Teardown

[1][1.0] Automated__ALD__Software upgrade for ALDs
    [Setup]  common.Common Test Setup
    run  sudo mkdir -p /media/BuildShareTimi01
    run  sudo chown ute:ute /media/BuildShareTimi01
    ${sh_command}  Catenate  sudo sh -c "echo //10.5.16.78/BuildShareTimi01 /media/BuildShareTimi01/
    ...                      cifs _netdev,noperm,username=userbuild,,nosuid,noexec,password=Aikon_123456*8 0 0 >>/etc/fstab"
    run  ${sh_command}
    run  sudo mount -a
    ALD.16_ALD_Software_upgrade_for_ALDs
    [Teardown]  ALD.16_ALD_Software_upgrade_for_ALDs.Test Case Teardown


[1][1.1] Automated__ALD__Planned commissioning with Nokia MHA
    [Setup]  common.Common Test Setup
    ALD.19_ALD_Planned_commissioning_with_Nokia_MHA
    [Teardown]  ALD.19_ALD_Planned_commissioning_with_Nokia_MHA.Test Case Teardown


[1][1.0] Automated__ALD__CLI support for ALD sharing
    [Setup]  common.Common Test Setup
    CLI.05_Admin_CLI_ALDSharing
    [Teardown]  CLI.05_Admin_CLI_ALDSharing.Test Case Teardown

[1][1.0] Automated__ALD__Send TestRET to different DNs via CLI
    [Setup]  common.Common Test Setup
    CLI.06_Admin_CLI_testRET
    [Teardown]  CLI.06_Admin_CLI_testRET.Test Case Teardown

[1][1.0] Automated__ALD__Send TestRET during exception conditions
    [Setup]  common.Common Test Setup
    CLI.07_Admin_CLI_testRET_During_Exception_Conditions
    [Teardown]  CLI.07_Admin_CLI_testRET_During_Exception_Conditions.Test Case Teardown


[1][1.0] Automated__ALD__Commissioning from ALD selection window in WebEM
    [Setup]  common.Common Test Setup
    ALD.29_CB008605_ALD_Commissioning_from_ALD_selection_window_in_WebEM
    [Teardown]  ALD.29_CB008605_ALD_Commissioning_from_ALD_selection_window_in_WebEM.Test Case Teardown


[1][1.0] Automated__ALD__sharing management in ALD selection window in WebEM
    [Setup]  common.Common Test Setup
    ALD.28_CB008605_ALD_Sharing_Management_In_ALD_Selection_Window_In_WebEM
    [Teardown]  ALD.28_CB008605_ALD_Sharing_Management_In_ALD_Selection_Window_In_WebEM.Test Case Teardown


[1][1.1] Automated__ALD__Configure_Commissioned_RET_Antenna
    [Setup]  common.Common Test Setup
    ALD.17_ALD_Configure_Commissioned_RET_Antenna
    ALD.36_ALD_Site_Reset
    [Teardown]  ALD.17_ALD_Configure_Commissioned_RET_Antenna.Test Case Teardown


[1][1.1] Automated__ALD__DC voltage management in runtime
    [Setup]  common.Common Test Setup
    ALD.08_ALD_DC_voltage_management_in_runtime
    [Teardown]  ALD.08_ALD_DC_voltage_management_in_runtime.Test Case Teardown


[1][1.1] Automated__ALD__HDLC Communication management with reset
    [Setup]  common.Common Test Setup
    ALD.10_ALD_HDLC_Communication_management_with_reset
    [Teardown]  ALD.10_ALD_HDLC_Communication_management_with_reset.Test Case Teardown
