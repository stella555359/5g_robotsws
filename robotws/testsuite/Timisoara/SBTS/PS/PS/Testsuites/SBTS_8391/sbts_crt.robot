*** Settings ***
Documentation
...    Author: tomasz.marchewka@nokia.com
...    Description: Suite prepared for Power Saving tests execution
...    Group in charge: I_MN_RAN_RD_VRF_TSR1_5 <I_MN_RAN_RD_VRF_TSR1_5@internal.nsn.com>
...    Sample execution:
...    robot -v CONFIGURATION:Wroclaw.10_16_UTESRAN3630 -C on -T -d /home/ute/test_results -L TRACE -b debug.log -V /home/ute/10_16_UTESRAN3630
...    testsuite/Wroclaw/OAM/RAN_PZ_WRO3_SG01/PS/Testsuites/SBTS_8391/sbts_crt.robot


Resource        ../../Testcases/PS.22_CB008800_Independent_activation_periods_and_switch_off_orders_for_LTE1103_and_LTE1203/test.robot
Resource        ../../Testcases/PS.23_PS_CB008800_Check_SR003080_interworking_with_CB008800/test.robot
Resource        ../../Testcases/PS.24_CB008800_Backward_compatibility_with_LTE1103_and_LTE1203_SR003080/test.robot
Resource        ../../Testcases/PS.25_CB008800_Power_saving_configuration_change/test.robot
Resource        ../../Testcases/PS.26_CB008800_Suspend_LTE1103_and_LTE1203_SR003080/test.robot
Resource        ../../Testcases/PS.27_CB008800_Overlapping_Cell_Periods/test.robot
Resource        ../../Testcases/PS.28_CB008745_Switching_On_Cell_NR/test.robot
Resource        ../../Testcases/PS.29_CB008745_Switching_On_Cell_LTE/test.robot
Resource        ../../Testcases/PS.30_CB008745_Switching_On_Tx_Path_LTE/test.robot
Resource        ../../Testcases/PS.39_CB010683-B_Configure_diffrent_switching_off_method_for_the_same_cell/test.robot
Resource        ../../Testcases/PS.40_CB010683-B_Cell_Locking_and_blocking_durring_load_based_power_saving/test.robot
Resource        ../../Testcases/PS.41_PS_CB010683-B_Mixed_switch_off_with_extended_configuration_change/test.robot
Resource        ../../Testcases/PS.43_CB010683-B_Mixed_switch_off_with_extended_configuration_activation_and_deactivation/test.robot


Force Tags
...           SBTS00  CRT  # Branch indicator; Test Phase indicator; Scope indicator
...           QCP_RAN_VRF  QCD_MN_RAN  ## QC project; QC domain for reporting
...           PY39  ## force python3 UTE package
...           CLOUD_SRAN_NL_10811_1ASOF_2AHFB_UTECA
...           SKIP_INSTALL_TOOLS
#...           SKIP_SCF_VALIDATION

Test Timeout  24 hours

#Suite Setup       Test Suite Setup
#Suite Teardown    Test Suite Teardown

*** Variables ***
${att_port_1}         ${tl.enbs[0].rms[0].attenuation_ports[0].port_no}
${att_port_2}         ${tl.enbs[0].rms[0].attenuation_ports[1].port_no}
${att_port_3}         ${tl.enbs[0].rms[0].attenuation_ports[2].port_no}
${att_port_4}         ${tl.enbs[0].rms[0].attenuation_ports[3].port_no}
${att_port_5}         ${tl.enbs[0].rms[1].attenuation_ports[0].port_no}
${att_port_6}         ${tl.enbs[0].rms[1].attenuation_ports[1].port_no}
${att_port_7}         ${tl.enbs[0].rms[1].attenuation_ports[2].port_no}
${att_port_8}         ${tl.enbs[0].rms[1].attenuation_ports[3].port_no}
${att_port_numbers}    ${tl.attenuator[0].attenuation_port_numbers}

*** Test Cases ***
[1][1.0] PS_CB008800_Independent_activation_periods_and_switch_off_orders_for_LTE1103_and_LTE1203
    [Setup]  Common Test Setup
    PS.22_CB008800_Independent_activation_periods_and_switch_off_orders_for_LTE1103_and_LTE1203
    [Teardown]  PS.22_CB008800_Independent_activation_periods_and_switch_off_orders_for_LTE1103_and_LTE1203.Test Case Teardown

[1][1.0] PS_CB008800_Backward_compatibility_with_LTE1103_and_LTE1203_SR003080
    [Setup]  Common Test Setup
    PS.24_CB008800_Backward_compatibility_with_LTE1103_and_LTE1203_SR003080
    [Teardown]  PS.24_CB008800_Backward_compatibility_with_LTE1103_and_LTE1203_SR003080.Test Case Teardown

[1][1.0] Automated__PS__CB008745_Switching_On_Cell_LTE
    [Setup]  common.Common Test Setup
    PS.29_CB008745_Switching_On_Cell_LTE
    [Teardown]  PS.29_CB008745_Switching_On_Cell_LTE.Test Case Teardown

[1][1.0] Automated__PS__CB008745_Swiching_On_Tx_Path_LTE
    [Setup]  common.Common Test Setup
    PS.30_CB008745_Switching_On_Tx_Path_LTE
    [Teardown]  PS.30_CB008745_Switching_On_Tx_Path_LTE.Test Case Teardown

[1][2.0] PS_CB010683-B_Configure_diffrent_switching_off_method_for_the_same_cell
    [Setup]  common.Common Test Setup
    PS.39_CB010683-B_Configure_diffrent_switching_off_method_for_the_same_cell
    [Teardown]  PS.39_CB010683-B_Configure_diffrent_switching_off_method_for_the_same_cell.Test Case Teardown

[1][2.0] PS_CB010683-B_Cell_Locking_and_blocking_durring_load_based_power_saving
    [Setup]  common.Common Test Setup
    PS.40_CB010683-B_Cell_Locking_and_blocking_durring_load_based_power_saving
    [Teardown]  PS.40_CB010683-B_Cell_Locking_and_blocking_durring_load_based_power_saving.Test Case Teardown

[1][2.0] PS_CB010683-B_Mixed_switch_off_with_extended_configuration_change
    [Setup]  common.Common Test Setup
    PS.41_PS_CB010683-B_Mixed_switch_off_with_extended_configuration_change
    [Teardown]  PS.41_PS_CB010683-B_Mixed_switch_off_with_extended_configuration_change.Test Case Teardown

[1][4.0] PS_CB010683-B_Mixed_switch_off_with_extended_configuration_activation_and_deactivation
    [Setup]  common.Common Test Setup
    PS.43_CB010683-B_Mixed_switch_off_with_extended_configuration_activation_and_deactivation
    [Teardown]  PS.43_CB010683-B_Mixed_switch_off_with_extended_configuration_activation_and_deactivation.Test Case Teardown