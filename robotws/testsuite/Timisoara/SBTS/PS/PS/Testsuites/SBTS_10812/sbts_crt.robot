*** Settings ***
Documentation
...    Author: tomasz.marchewka@nokia.com
...    Description: Suite prepared for Power Saving tests execution
...    Group in charge: I_MN_RAN_RD_VRF_TSR1_5 <I_MN_RAN_RD_VRF_TSR1_5@internal.nsn.com>
...    Sample execution:
...    robot -v CONFIGURATION:Timisoara.10_18_UTESRANCLOUD1812 -C on -T -d
...    /home/ute/test_results -L TRACE -b debug.log -V /home/ute/testline_configuration/10_18_UTESRANCLOUD1812
...    testsuite/Timisoara/SBTS/PS/PS/Testsuites/SBTS_53103/sbts_crt.robot

Resource        ../../Testcases/PS.02_LBT4152-E_Graceful_cell_shutdown_during_SW_Upgrade/test.robot
Resource        ../../Testcases/PS.03_LBT4152-E_Graceful_cell_shutdown_during_parameter_reset/test.robot
Resource        ../../Testcases/PS.06_LTE914_5GC000501_BTS_Reboot_While_Grace_Cell_Down_via_Admin/test.robot
Resource        ../../Testcases/PS.07_5GC001553_Intelligent_Cell_Shutdown_cancelling_scenario/test.robot
Resource        ../../Testcases/PS.08_5GC001553_Intelligent_Shutdown_cells_block_unblock/test.robot
Resource        ../../Testcases/PS.09_5GC001553_Intelligent_shut_down_recommissioning_during_power_break/test.robot
Resource        ../../Testcases/PS.11_5GC001553_Intelligent_shut_down_with_WCDMA_RAT_reset/test.robot
Resource        ../../Testcases/PS.18_SR003080_Reduced_Power_Saving_Online_Activation_via_Admin/test.robot
Resource        ../../Testcases/PS.21_5GC001553_Intelligent_Shutdown_of_multiple_cells/test.robot
Resource        ../../Testcases/PS.28_CB008745_Switching_On_Cell_NR/test.robot
Resource        ../../Testcases/PS.29_CB008745_Switching_On_Cell_LTE/test.robot
Resource        ../../Testcases/PS.30_CB008745_Switching_On_Tx_Path_LTE/test.robot
Resource        ../../Testcases/PS.31_5GC000431_Cell_Switch_Off_Suspend_Un-suspend_Load-Based_Power_Saving/test.robot
Resource        ../../Testcases/PS.36_5GC000431_Cell_Switch_Off_Determine_Cell_PS_Mode_And_Handle_Cell_Outage_Cell_Locking/test.robot
Resource        ../../Testcases/PS.81_CB010869_NR_Determine_cell_Switch_OFF_and_ON_list/test.robot
Resource        ../../Testcases/PS.80_CB010869_NR_Determine_Cell_TX_Switch_OFF_and_ON_list/test.robot
Resource        ../../Testcases/PS.78_CB010869_LTE_Activation_and_deactivation_Energy_Saving_Load_threshold_per_Time_window_and_SO_method/test.robot
Resource        ../../Testcases/PS.79_CB010869_LTE_Determine_Cell_TX_Switch_OFF_and_ON_list/test.robot

Force Tags
...           SBTS00  CRT  # Branch indicator; Test Phase indicator; Scope indicator
...           QCP_RAN_VRF  QCD_MN_RAN  ## QC project; QC domain for reporting
...           PY39  ## force python3 UTE package
...           CLOUD_SRAN_NLG_10812_1ASIM_1ABIO_1ABIA_1ASIM_3ABIP_3AHLOA_6AHFIB_3AEHC
...           SKIP_INSTALL_TOOLS
#...           SKIP_SCF_VALIDATION

Test Timeout  24 hours

#Suite Setup       Test Suite Setup
#Suite Teardown    Test Suite Teardown

*** Variables ***
${att_port_1}         ${tl.enbs[0].rms[0].attenuation_ports[0].port_no}
${att_port_2}         ${tl.enbs[0].rms[0].attenuation_ports[0].port_no}
${att_port_3}         ${tl.enbs[0].rms[1].attenuation_ports[0].port_no}
${att_port_4}         ${tl.enbs[1].rms[1].attenuation_ports[0].port_no}
${att_port_5}         ${tl.enbs[1].rms[1].attenuation_ports[0].port_no}
${att_port_6}         ${tl.enbs[1].rms[0].attenuation_ports[0].port_no}
${att_port_7}         ${tl.enbs[1].rms[1].attenuation_ports[0].port_no}
${att_port_8}         ${tl.enbs[1].rms[1].attenuation_ports[0].port_no}
${att_port_numbers}   ${tl.attenuator[0].attenuation_port_numbers}
${ue_serial_num}      ${tl.ues[0].serial_number}
${diagnostic_port_command}    setprop sys.usb.config diag,adb

*** Test Cases ***

[1][1.0] PS_CB010869_NR_Determine_cell_Switch_OFF_and_ON_list
    [Setup]  common.Common Test Setup
    PS.81_CB010869_NR_Determine_cell_Switch_OFF_and_ON_list
    [Teardown]  PS.81_CB010869_NR_Determine_cell_Switch_OFF_and_ON_list.Test Case Teardown

[1][1.0] PS_CB010869_NR_Determine_Cell_TX_Switch_OFF_and_ON_list
    [Setup]  common.Common Test Setup
    PS.80_CB010869_NR_Determine_Cell_TX_Switch_OFF_and_ON_list
    [Teardown]  PS.80_CB010869_NR_Determine_Cell_TX_Switch_OFF_and_ON_list.Test Case Teardown

[1][1.0] PS_CB010869_LTE_Activation_and_deactivation_Energy_Saving_Load_threshold_per_Time_window_and_SO_method
    [Setup]  common.Common Test Setup
    PS.78_CB010869_LTE_Activation_and_deactivation_Energy_Saving_Load_threshold_per_Time_window_and_SO_method
    [Teardown]  PS.78_CB010869_LTE_Activation_and_deactivation_Energy_Saving_Load_threshold_per_Time_window_and_SO_method.Test Case Teardown

[1][1.0] PS_CB010869_LTE_Determine_Cell_TX_Switch_OFF_and_ON_list
    [Setup]  common.Common Test Setup
    PS.79_CB010869_LTE_Determine_Cell_TX_Switch_OFF_and_ON_list
    [Teardown]  PS.79_CB010869_LTE_Determine_Cell_TX_Switch_OFF_and_ON_list.Test Case Teardown
