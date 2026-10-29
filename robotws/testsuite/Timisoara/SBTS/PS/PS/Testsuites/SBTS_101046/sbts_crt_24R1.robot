*** Settings ***
Documentation
...    Author: tomasz.marchewka@nokia.com
...    Description: Suite prepared for Power Saving tests execution
...    Group in charge: I_MN_RAN_RD_VRF_TSR1_5 <I_MN_RAN_RD_VRF_TSR1_5@internal.nsn.com>
...    Sample execution:
...    robot -v CONFIGURATION:Timisoara.10_18_UTESRANCLOUD1813 -C on -T -d /home/ute/test_results -L TRACE -b debug.log
...    -V /home/ute/testline_configuration/10_18_UTESRANCLOUD1813 testsuite/Timisoara/SBTS/PS/PS/Testsuites/SBTS_101046/sbts_crt.robot


Resource        ../../Testcases/PS.01_Grace_Cell_Down_via_NA/test.robot
Resource        ../../Testcases/PS.02_LBT4152-E_Graceful_cell_shutdown_during_SW_Upgrade/test.robot
Resource        ../../Testcases/PS.03_LBT4152-E_Graceful_cell_shutdown_during_parameter_reset/test.robot
Resource        ../../Testcases/PS.04_LTE1103-A_Power_Saving_Groups_Activation_via_Admin/test.robot
Resource        ../../Testcases/PS.05_LTE1203_Reduced_Power_Saving_Activation_via_Admin/test.robot
Resource        ../../Testcases/PS.06_LTE914_5GC000501_BTS_Reboot_While_Grace_Cell_Down_via_Admin/test.robot
Resource        ../../Testcases/PS.12_LTE3330_A_Load_based_Power_Saving_for_AirScale_SM_for_Energy_Efficiency/test.robot
Resource        ../../Testcases/PS.17_LTE2517-A_Switch_OFF_PG_2_when_useFullCapacity_set_to_false/test.robot
Resource        ../../Testcases/PS.19_SR002216_Succeeded_switching_OFF_ON_empty_PG_2/test.robot
Resource        ../../Testcases/PS.22_CB008800_Independent_activation_periods_and_switch_off_orders_for_LTE1103_and_LTE1203/test.robot
Resource        ../../Testcases/PS.23_PS_CB008800_Check_SR003080_interworking_with_CB008800/test.robot
Resource        ../../Testcases/PS.24_CB008800_Backward_compatibility_with_LTE1103_and_LTE1203_SR003080/test.robot
Resource        ../../Testcases/PS.25_CB008800_Power_saving_configuration_change/test.robot
Resource        ../../Testcases/PS.26_CB008800_Suspend_LTE1103_and_LTE1203_SR003080/test.robot
Resource        ../../Testcases/PS.27_CB008800_Overlapping_Cell_Periods/test.robot

Force Tags
...           SBTS00  CRT  # Branch indicator; Test Phase indicator; Scope indicator
...           QCP_RAN_VRF  QCD_MN_RAN  ## QC project; QC domain for reporting
...           PY39  ## force python3 UTE package
...           CLOUD_SRAN_L_10813_1ASIA_2ABIA_1ABIO_1AHFB_3FHEB
...           SKIP_INSTALL_TOOLS
#...           SKIP_SCF_VALIDATION

Test Timeout  24 hours

#Suite Setup       Test Suite Setup
#Suite Teardown    Test Suite Teardown

*** Variables ***
${att_port_1}         ${tl.enbs[0].rms[0].attenuation_ports[0].port_no}
${att_port_2}         ${tl.enbs[0].rms[0].attenuation_ports[1].port_no}
${att_port_3}         ${tl.enbs[0].rms[2].attenuation_ports[0].port_no}
${att_port_4}         ${tl.enbs[0].rms[2].attenuation_ports[1].port_no}
${att_port_5}         ${tl.enbs[0].rms[1].attenuation_ports[0].port_no}
${att_port_6}         ${tl.enbs[0].rms[1].attenuation_ports[1].port_no}
${att_port_numbers}   ${tl.attenuator[0].attenuation_port_numbers}
${ue_serial_num}      ${tl.ues[0].serial_number}
${diagnostic_port_command}    setprop sys.usb.config diag,adb

*** Test Cases ***
[1][1.0] Automated__PS__LBT4152-E_Graceful_cell_shutdown_during_SW_Upgrade
    [Setup]  common.Common Test Setup
    PS.02_LBT4152-E_Graceful_cell_shutdown_during_SW_Upgrade
    [Teardown]  PS.02_LBT4152-E_Graceful_cell_shutdown_during_SW_Upgrade.Test Case Teardown

[1][1.0] Automated__PS__Graceful Cell Shut Down
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.01_Grace_Cell_Down_via_NA
    [Teardown]  PS.01_Grace_Cell_Down_via_NA.Test Case Teardown

[1][1.0] Automated__PS__LBT4152-E_Graceful_cell_shutdown_during_parameter_change_with_eNB_reset
    [Setup]  common.Common Test Setup
    PS.03_LBT4152-E_Graceful_cell_shutdown_during_parameter_reset
    [Teardown]  PS.03_LBT4152-E_Graceful_cell_shutdown_during_parameter_reset.Test Case Teardown

[1][1.0] Automated__PS__LTE1103-A_Power_Saving_Groups_Activation
    [Setup]  common.Common Test Setup
    PS.04_LTE1103-A_Power_Saving_Groups_Activation_via_Admin
    [Teardown]  PS.04_LTE1103-A_Power_Saving_Groups_Activation_via_Admin.Test Case Teardown

[1][1.0] Automated__PS__LTE1203_Reduced_Power_Saving_Activation
    [Setup]  common.Common Test Setup
    PS.05_LTE1203_Reduced_Power_Saving_Activation_via_Admin
    [Teardown]  PS.05_LTE1203_Reduced_Power_Saving_Activation_via_Admin.Test Case Teardown