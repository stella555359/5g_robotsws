*** Settings ***
Documentation
...    Author: tomasz.marchewka@nokia.com
...    Description: Suite prepared for ALD tests execution
...    Group in charge: I_MN_RAN_PZ_3_WRO_1_GMS <I_MN_RAN_PZ_3_WRO_1@internal.nsn.com>
...    Sample execution:
...    robot -v CONFIGURATION:Timisoara.10_18_UTESRANCLOUD1752 -C on -T -d /home/ute/test_results -L TRACE -b debug.log
...    -V /home/ute/testline_configuration/10_18_UTESRANCLOUD1752
...    testsuite/Timisoara/SBTS/test_line_specific/Elisa3.3_eNB_10752/ALD_Trunk.robot


#Resource        taf/rfrl/uuf4all/uuf4all_test_cases.robot
#Resource        taf/rfrl/uuf4all/uuf4all_keywords.robot
#Resource        ../../../../../RRM/VRF_WRO2_T08/resources/testline_preparation_4g/testline_preparation_4g.robot
Resource        ../../ALD/Testcases/ALD.03_ALD_Additional_data_for_ALDs/test.robot
Resource        ../../ALD/Testcases/ALD.05_ALD_BTS_Reconfiguration_with_ALDs_ALD_reassignment/test.robot
Resource        ../../ALD/Testcases/ALD.06_ALD_Manual_commissioning_with_Nokia_MHA_ALDs_assigned_as_external_units/test.robot
Resource        ../../ALD/Testcases/ALD.07_ALD_Manual_commissioning_with_Nokia_MHA_Passdev_as_RX_Gain/test.robot
Resource        ../../ALD/Testcases/ALD.08_ALD_DC_voltage_management_in_runtime/test.robot
Resource        ../../ALD/Testcases/ALD.12_ALD_Detect_and_setup_AL_devices_Lock_Unlock/test.robot
Resource        ../../ALD/Testcases/ALD.14_ALD_Detect_and_setup_AL_devices_start-up/test.robot
Resource        ../../ALD/Testcases/ALD.17_ALD_Configure_Commissioned_RET_Antenna/test.robot
Resource        ../../ALD/Testcases/ALD.18_ALD_Configure_RET_Antenna_from_runtime_view/test.robot
Resource        ../../ALD/Testcases/ALD.19_ALD_Planned_commissioning_with_Nokia_MHA/test.robot
Resource        ../../ALD/Testcases/ALD.20_ALD_RET_No_Connection_To_Unit/test.robot
Resource        ../../ALD/Testcases/ALD.21_ALD_MHA_No_Connection_To_Unit/test.robot
Resource        ../../ALD/Testcases/ALD.26_ALD_MHA_Below_Current/test.robot
Resource        ../../ALD/Testcases/CLI.01_Admin_CLI_setRETProperties/test.robot
Resource        ../../ALD/Testcases/CLI.02_Admin_CLI_setTiltAngle/test.robot
Resource        ../../ALD/Testcases/CLI.03_Admin_CLI_calibrateTilt/test.robot
Resource        ../../ALD/Testcases/CLI.04_Admin_CLI_getRETById/test.robot
Resource        ../../ALD/Testcases/ALD.36_ALD_Site_Reset/test.robot

Force Tags
...           SBTS00    CRT    RAN_5G  # Branch indicator; Test Phase indicator; Scope indicator
...           QCP_RAN_VRF  QCD_MN_RAN  ## QC project; QC domain for reporting
...           CA_RAN_PZ_TSR_1
...           PY39  ## force python3 UTE package
...           BTS_CLOUD_SRAN_L_10752_1FSMF_2FBBC_1FRMC_1FXED_1FRGU  # label
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

[1][2.0] Automated_ALD__Additional data for ALDs
    [Setup]  common.Common Test Setup
    ALD.03_ALD_Additional_data_for_ALDs
    [Teardown]  ALD.03_ALD_Additional_data_for_ALDs.Test Case Teardown

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

[1][1.0] Automated__ALD__Detect and setup AL devices Lock Unlock
    [Setup]  common.Common Test Setup
    ALD.12_ALD_Detect_and_setup_AL_devices_Lock_Unlock
    [Teardown]  ALD.12_ALD_Detect_and_setup_AL_devices_Lock_Unlock.Test Case Teardown

[1][1.1] Automated__ALD__Detect and setup AL devices Start-up
    [Setup]  common.Common Test Setup
    ALD.14_ALD_Detect_and_setup_AL_devices_start-up
    [Teardown]  ALD.14_ALD_Detect_and_setup_AL_devices_start-up.Test Case Teardown

[1][1.1] Automated__ALD__Configure_Commissioned_RET_Antenna
    [Setup]  common.Common Test Setup
    ALD.17_ALD_Configure_Commissioned_RET_Antenna
    [Teardown]  ALD.17_ALD_Configure_Commissioned_RET_Antenna.Test Case Teardown

[1][1.0] Automated__ALD__Site_reset
    [Setup]  common.Common Test Setup
    ALD.36_ALD_Site_Reset
    [Teardown]  ALD.36_ALD_Site_Reset.Test Case Teardown

[1][1.0] Automated__ALD__Configure RET Antenna from runtime view
    [Setup]  common.Common Test Setup
    ALD.18_ALD_Configure_RET_Antenna_from_runtime_view
    [Teardown]  Run Keywords  ALD.18_ALD_Configure_RET_Antenna_from_runtime_view.Test Case Teardown
    ...  AND  Kill All Instances Of Chrome

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

[1][1.1] Automated__ALD__MHA Below Current alarm
    [Setup]  Run Keywords  common.Common Test Setup
    ...  AND  Set Test Variable  ${BELOW_INTERFACE}  MHA_XJ102602062
    ...  AND  Set Test Variable  ${ANTL_A}  /RMOD_A-2/ANTL_A-7
    ALD.26_ALD_MHA_Below_Current
    [Teardown]  ALD.26_ALD_MHA_Below_Current.Test Case Teardown

[1][1.0] Automated__ALD__BTS_Remote_Tool_command_RET_Unit_Editable_Parameter_setting
    [Setup]  common.Common Test Setup
    CLI.02_Admin_CLI_setTiltAngle
    [Teardown]  CLI.02_Admin_CLI_setTiltAngle.Test Case Teardown

[1][1.0] Automated__ALD__BTS_Remote_Tool_command_RET_Unit_ConfFile_application
    [Setup]  common.Common Test Setup
    run  sudo mkdir -p /media/BuildShareTimi01
    run  sudo chown ute:ute /media/BuildShareTimi01
    ${map_buildshare_command}  Catenate  sudo sh -c "echo //10.5.16.78/BuildShareTimi01 /media/BuildShareTimi01/
    ...  cifs _netdev,noperm,username=userbuild,,nosuid,noexec,password=Aikon_123456*8 0 0 >>/etc/fstab"
    run  ${map_buildshare_command}
    run  sudo mount -a
    CLI.01_Admin_CLI_setRETProperties
    CLI.02_Admin_CLI_setTiltAngle
    CLI.03_Admin_CLI_calibrateTilt
    [Teardown]  common.Common Test Teardown

#*** Keywords ***
#Set Test Failed
#    Set Suite Variable  ${UPDATE_TEST_FAILED}  ${True}
