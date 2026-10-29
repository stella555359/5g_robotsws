*** Settings ***
Documentation
...    Author: tomasz.marchewka@nokia.com
...    Description: Suite prepared for ALD tests execution
...    Group in charge: I_MN_RAN_PZ_3_WRO_1_GMS <I_MN_RAN_PZ_3_WRO_1@internal.nsn.com>
...    Sample execution:
...    robot -v CONFIGURATION:Timisoara.10_18_UTESRANCLOUD1683 -C on -T -d /home/ute/test_results -L TRACE -b debug.log
...    -V /home/ute/testline_configuration/10_18_UTESRANCLOUD1683
...    testsuite/Timisoara/SBTS/test_line_specific/SBTS1683/ALD_683.robot


#Resource        taf/rfrl/uuf4all/uuf4all_test_cases.robot
#Resource        taf/rfrl/uuf4all/uuf4all_keywords.robot
#Resource        ../../ALD/../../ALD/../RRM/VRF_WRO2_T08/resources/testline_preparation_4g/testline_preparation_4g.robot
Resource        ../../ALD/Testcases/ALD.03_ALD_Additional_data_for_ALDs/test.robot
Resource        ../../ALD/Testcases/ALD.04_ALD_BTS_Reconfiguration_with_ALDs_removal/test.robot
Resource        ../../ALD/Testcases/ALD.05_ALD_BTS_Reconfiguration_with_ALDs_ALD_reassignment/test.robot
Resource        ../../ALD/Testcases/ALD.06_ALD_Manual_commissioning_with_Nokia_MHA_ALDs_assigned_as_external_units/test.robot
Resource        ../../ALD/Testcases/ALD.07_ALD_Manual_commissioning_with_Nokia_MHA_Passdev_as_RX_Gain/test.robot
Resource        ../../ALD/Testcases/ALD.08_ALD_DC_voltage_management_in_runtime/test.robot
Resource        ../../ALD/Testcases/ALD.10_ALD_HDLC_Communication_management_with_reset/test.robot
Resource        ../../ALD/Testcases/ALD.12_ALD_Detect_and_setup_AL_devices_Lock_Unlock/test.robot
Resource        ../../ALD/Testcases/ALD.14_ALD_Detect_and_setup_AL_devices_start-up/test.robot
Resource        ../../ALD/Testcases/ALD.17_ALD_Configure_Commissioned_RET_Antenna/test.robot
Resource        ../../ALD/Testcases/ALD.18_ALD_Configure_RET_Antenna_from_runtime_view/test.robot
Resource        ../../ALD/Testcases/ALD.19_ALD_Planned_commissioning_with_Nokia_MHA/test.robot
Resource        ../../ALD/Testcases/ALD.20_ALD_RET_No_Connection_To_Unit/test.robot
Resource        ../../ALD/Testcases/ALD.21_ALD_MHA_No_Connection_To_Unit/test.robot
Resource        ../../ALD/Testcases/ALD.23_ALD_MHA_Overcurrent_alarm_in_AISG/test.robot
Resource        ../../ALD/Testcases/ALD.25_ALD_MHA_Above_Current/test.robot
Resource        ../../ALD/Testcases/CLI.01_Admin_CLI_setRETProperties/test.robot
Resource        ../../ALD/Testcases/CLI.02_Admin_CLI_setTiltAngle/test.robot
Resource        ../../ALD/Testcases/CLI.03_Admin_CLI_calibrateTilt/test.robot
Resource        ../../ALD/Testcases/ALD.36_ALD_Site_Reset/test.robot

Force Tags

...           SBTS00    CRT    RAN_5G  # Branch indicator; Test Phase indicator; Scope indicator
...           QCP_RAN_VRF  QCD_MN_RAN  ## QC project; QC domain for reporting
...           CA_VRF_TSR1
...           PY36  ## force python3 UTE package
...           BTS_CLOUD_SRAN_LWG_10683_1ASIA_1ABIA_1FSMF_2FBBC_1AHED_1AHEGB_1FRGU_1FXDB  # label
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

[1]Automated__SWM__SW_download_and_activation__SBTS_to_SBTS
    [Tags]    STOPONFAIL
    [Timeout]    14400
    [Setup]    Run Keywords    Set Test Variable    ${Target SW name}    ${None}
    ...    AND    Set Test Variable    ${Target SW dir}    /home/ute/TARGET_SW
    ...    AND    Set Test Variable    ${SW Update Timeout}    3600
    ...    AND    Set Test Variable    ${Ping loss timeout}    900
    ...    AND    Set Test Variable    ${Ping regain timeout}    1900
    ...    AND    Set Test Variable    ${onAir Check Number}    150
    ...    AND    Set Test Variable    ${First Cell On Air Timeout}    35
    ...    AND    Set Test Variable    ${Ping stable timeout}    409
    ...    AND    Set Test Variable    ${Test Timeout}    120
    ...    AND    Modify Resource Search Order    SWM__SW_download_and_activation__SBTS_to_SBTS
    ...    AND    SWM__SW_download_and_activation__SBTS_to_SBTS.TC Setup

    Run  mkdir ${Target SW dir}
    Run  sudo chmod 777 ${Target SW dir} -R
    Download and check software package  ${ENB_BUILD}  ${Target SW dir}
    TC__SWM__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]    Run Keywords    SWM__SW_download_and_activation__SBTS_to_SBTS.TC Teardown
    ...    AND    Restore Resource Search Order


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

[1][1.1] Automated__ALD__HDLC Communication management with reset
    [Setup]  common.Common Test Setup
    ALD.10_ALD_HDLC_Communication_management_with_reset
    [Teardown]  ALD.10_ALD_HDLC_Communication_management_with_reset.Test Case Teardown

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
    ALD.36_ALD_Site_Reset
    [Teardown]  ALD.17_ALD_Configure_Commissioned_RET_Antenna.Test Case Teardown

[1][1.0] Automated__ALD__Configure RET Antenna from runtime view
    [Setup]  common.Common Test Setup
    ALD.18_ALD_Configure_RET_Antenna_from_runtime_view
    [Teardown]  ALD.18_ALD_Configure_RET_Antenna_from_runtime_view.Test Case Teardown

[1][1.1] Automated__ALD__Planned commissioning with Nokia MHA
    [Setup]  common.Common Test Setup
    ALD.19_ALD_Planned_commissioning_with_Nokia_MHA
    [Teardown]  ALD.19_ALD_Planned_commissioning_with_Nokia_MHA.Test Case Teardown

[1][1.0] Automated__ALD__BTS_Remote_Tool_command_RET_Unit_ConfFile_application
    [Setup]  common.Common Test Setup
    CLI.01_Admin_CLI_setRETProperties
    CLI.02_Admin_CLI_setTiltAngle
    CLI.03_Admin_CLI_calibrateTilt
    [Teardown]  common.Common Test Teardown

[1][1.1] Automated__ALD__RET_AISG2.0_No_Connection_To_Unit
    [Setup]  common.Common Test Setup
    ALD.20_ALD_RET_No_Connection_To_Unit
    [Teardown]  ALD.20_ALD_RET_No_Connection_To_Unit.Test Case Teardown

[1][1.1] Automated__ALD__MHA_AISG2.0_No_Connection_To_Unit
    [Setup]  common.Common Test Setup
    ALD.21_ALD_MHA_No_Connection_To_Unit
    [Teardown]  ALD.21_ALD_MHA_No_Connection_To_Unit.Test Case Teardown

[1][1.0] Automated__ALD__MHA_Overcurrent_alarm_in_AISG_mode_with_RM_Lock_Unlock
    [Setup]  Run Keywords  common.Common Test Setup
    ...  AND  Set Test Variable  ${OC_INTERFACE}  OC_FLGC
    ...  AND  Set Test Variable  ${ANTL_A}  /RMOD_A-1/ANTL_A-1
    ALD.23_ALD_MHA_Overcurrent_alarm_in_AISG
    [Teardown]  ALD.23_ALD_MHA_Overcurrent_alarm_in_AISG.Test Case Teardown

[1][1.1] Automated__ALD__MHA Above Current alarm
    [Setup]  Run Keywords  common.Common Test Setup
    ...  AND  Set Test Variable  ${ABOVE_INTERFACE}  AC_WMHD
    ...  AND  Set Test Variable  ${ANTL_A}  /RMOD_A-2/ANTL_A-6
    ALD.25_ALD_MHA_Above_Current
    [Teardown]  ALD.25_ALD_MHA_Above_Current.Test Case Teardown



#*** Keywords ***
#Set Test Failed
#    Set Suite Variable  ${UPDATE_TEST_FAILED}  ${True}
