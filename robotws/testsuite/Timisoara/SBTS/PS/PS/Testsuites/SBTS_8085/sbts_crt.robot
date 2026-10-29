*** Settings ***
Documentation
...    Author: tomasz.marchewka@nokia.com
...    Description: Suite prepared for Power Saving tests execution
...    Group in charge: I_MN_RAN_RD_VRF_TSR1_5 <I_MN_RAN_RD_VRF_TSR1_5@internal.nsn.com>
...    Sample execution:
...    robot -v CONFIGURATION:Timisoara.10_18_UTESRANCLOUD1816 -C on -T -d /home/ute/test_results -L TRACE -b debug.log
...    -V /home/ute/testline_configuration/10_18_UTESRANCLOUD1816
...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/PS/PS/Testsuites/SBTS_8085/sbts_crt.robot




Resource        taf/rfrl/uuf4all/uuf4all_test_cases.robot
Resource        taf/rfrl/uuf4all/uuf4all_keywords.robot
Resource        ../../Testcases/PS.06_LTE914_5GC000501_BTS_Reboot_While_Grace_Cell_Down_via_Admin/test.robot
Resource        ../../Testcases/PS.07_5GC001553_Intelligent_Cell_Shutdown_cancelling_scenario/test.robot
Resource        ../../Testcases/PS.09_5GC001553_Intelligent_shut_down_recommissioning_during_power_break/test.robot
Resource        ../../Testcases/PS.11_5GC001553_Intelligent_shut_down_with_WCDMA_RAT_reset/test.robot
Resource        ../../Testcases/PS.21_5GC001553_Intelligent_Shutdown_of_multiple_cells/test.robot
Resource        ../../Testcases/PS.49_CB009176_RU_powerOn_through_FPFH_from_energySaving_due_to_cell_activation/test.robot
Resource        ../../Testcases/PS.50_CB009176_Power_On_FPFH_DC_PortCell_Due_To_Cell_Reconfiguration/test.robot
Resource        ../../Testcases/PS.51_CB009176_RU_PowerOn_Through_FPFH_Due_To_Time_Window_Change/test.robot
Resource        ../../Testcases/PS.52_CB009176_interaction_with_CB010766_not_overlapping_time_windows/test.robot
Resource        ../../Testcases/PS.53_CB009176_interaction_with_CB010766_overlapping_time_dcport_between_deep_sleep_windows/test.robot



Force Tags
...           SBTS00  CRT  # Branch indicator; Test Phase indicator; Scope indicator
...           QCP_RAN_VRF  QCD_MN_RAN  ## QC project; QC domain for reporting
...           PY39  ## force python3 UTE package
...           CLOUD_SRAN_NLW_10816_1ASIB_1ABIN_1ABIO_1ABIA_1AHPMDA_1AHCA_1AHEC_1FXCB_1FHEL_1AEQQ_1AENB
...           SKIP_INSTALL_TOOLS
#Suite Setup       Test Suite Setup
#Suite Teardown    Test Suite Teardown

Test Timeout  24 hours

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
${att_port_10}         ${tl.enbs[0].rms[4].attenuation_ports[0].port_no}
${att_port_11}         ${tl.enbs[0].rms[2].attenuation_ports[0].port_no}
${att_port_12}         ${tl.enbs[0].rms[2].attenuation_ports[1].port_no}
${att_port_13}         ${tl.enbs[0].rms[2].attenuation_ports[2].port_no}
${att_port_14}         ${tl.enbs[0].rms[2].attenuation_ports[3].port_no}
${att_port_17}         ${tl.enbs[0].rms[0].attenuation_ports[0].port_no}
${att_port_18}         ${tl.enbs[0].rms[0].attenuation_ports[1].port_no}
${att_port_19}         ${tl.enbs[0].rms[0].attenuation_ports[2].port_no}
${att_port_20}         ${tl.enbs[0].rms[0].attenuation_ports[3].port_no}
${att_port_21}         ${tl.enbs[0].rms[1].attenuation_ports[0].port_no}
${att_port_22}         ${tl.enbs[0].rms[1].attenuation_ports[1].port_no}
${att_port_numbers}    ${tl.attenuator[0].attenuation_port_numbers}
${ue_serial_num}      ${tl.ues[0].serial_number}
${diagnostic_port_command_1}     setprop persist.vendor.usb.config diag,diag_mdm,qdss,qdss_mdm,serial_cdev,dpl,rmnet,adb
${diagnostic_port_command_2}     setprop sys.usb.config diag,diag_mdm,qdss,qdss_mdm,serial_cdev,dpl,rmnet,adb



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

[1][1.0] Automated__PS__CB009176_RU_powerOn_through_FPFH_from_energySaving_due_to_cell_activation
     [Setup]  common.Common Test Setup
     PS.49_CB009176_RU_powerOn_through_FPFH_from_energySaving_due_to_cell_activation
     [Teardown]  PS.49_CB009176_RU_powerOn_through_FPFH_from_energySaving_due_to_cell_activation.Test Case Teardown

[1][1.0] Automated__PS__CB009176_RU_PowerOn_Through_FPFH_Due_To_Time_Window_Change
    [Setup]  common.Common Test Setup
    PS.51_CB009176_RU_PowerOn_Through_FPFH_Due_To_Time_Window_Change
    [Teardown]  PS.51_CB009176_RU_PowerOn_Through_FPFH_Due_To_Time_Window_Change.Test Case Teardown

[1][1.0] Automated__PS__CB009176_interaction_with_CB010766_overlapping_time_dcport_between_deep_sleep_windows
    [Setup]  common.Common Test Setup
    PS.53_CB009176_interaction_with_CB010766_overlapping_time_dcport_between_deep_sleep_windows
    [Teardown]  PS.53_CB009176_interaction_with_CB010766_overlapping_time_dcport_between_deep_sleep_windows.Test Case Teardown

[1][1.0] Automated__PS__CB009176_interaction_with_CB010766_not_overlapping_time_windows
    [Setup]  common.Common Test Setup
    PS.52_CB009176_interaction_with_CB010766_not_overlapping_time_windows
    [Teardown]  PS.52_CB009176_interaction_with_CB010766_not_overlapping_time_windows.Test Case Teardown
