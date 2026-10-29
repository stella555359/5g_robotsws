*** Settings ***
Documentation
...    Author: dorin.nadasan@nokia.com
...    Description: Suite prepared for Power Saving tests execution in scope of CB0010969
...    Group in charge: I_MN_RAN_RD_VRF_TSR1_5 <I_MN_RAN_RD_VRF_TSR1_5@internal.nsn.com>
...    Sample execution:
...    robot -v CONFIGURATION:Timisoara.10_18_UTESRANCLOUD1807 -C on -T -d /home/ute/test_results -L TRACE -b debug.log
...    -V /home/ute/testline_configuration/10_18_UTESRANCLOUD1807 testsuite/Timisoara/SBTS/PS/PS/Testsuites/SBTS_1807/sbts_crt.robot


Resource        ../../Testcases/PS.22_CB008800_Independent_activation_periods_and_switch_off_orders_for_LTE1103_and_LTE1203/test.robot
Resource        ../../Testcases/PS.37_CB008745_Suspend_Power_Saving_NR/test.robot
Resource        ../../Testcases/PS.27_CB008800_Overlapping_Cell_Periods/test.robot
Resource        ../../Testcases/PS.43_CB010683-B_Mixed_switch_off_with_extended_configuration_activation_and_deactivation/test.robot
Resource        ../../Testcases/PS.34_CB006830_Automated_Graceful_Cell_Shutdown_during_5G_Cell_Group_reset_VIA_CLI/test.robot
Resource        ../../Testcases/PS.76_LTE1103-A_Power_Saving_Groups_Activation_via_Admin_NB_IOT_INBAND/test.robot

Force Tags
...           SBTS00  CRT  # Branch indicator; Test Phase indicator; Scope indicator
...           QCP_RAN_VRF  QCD_MN_RAN  ## QC project; QC domain for reporting
...           PY39  ## force python3 UTE package
...           CLOUD_SRAN_NLG_10807_1ASOG_3AHPMDG_1AHCA
...           SKIP_INSTALL_TOOLS
#...           SKIP_SCF_VALIDATION

Test Timeout  24 hours

#Suite Setup       Test Suite Setup
#Suite Teardown    Test Suite Teardown

*** Variables ***
${att_port_1}         ${tl.enbs[0].rms[0].attenuation_ports[0].port_no}
${att_port_2}         ${tl.enbs[0].rms[1].attenuation_ports[0].port_no}
${att_port_3}         ${tl.enbs[0].rms[2].attenuation_ports[0].port_no}
${att_port_4}         ${tl.enbs[0].rms[3].attenuation_ports[0].port_no}
${att_port_numbers}   ${tl.attenuator[0].attenuation_port_numbers}
${ue_serial_num}      ${tl.ues[0].serial_number}
${diagnostic_port_command}    setprop sys.usb.config diag,adb

*** Test Cases ***

[1][1.0] PS_CB008800_Independent_activation_periods_and_switch_off_orders_for_LTE1103_and_LTE1203
    [Setup]  common.Common Test Setup
    PS.22_CB008800_Independent_activation_periods_and_switch_off_orders_for_LTE1103_and_LTE1203
    [Teardown]  PS.22_CB008800_Independent_activation_periods_and_switch_off_orders_for_LTE1103_and_LTE1203.Test Case Teardown

[1][1.0] PS_CB010683-B_Mixed_switch_off_with_extended_configuration_activation_and_deactivation
    [Setup]  common.Common Test Setup
    PS.43_CB010683-B_Mixed_switch_off_with_extended_configuration_activation_and_deactivation
    [Teardown]  PS.43_CB010683-B_Mixed_switch_off_with_extended_configuration_activation_and_deactivation.Test Case Teardown

[1][1.0] CB006830_Automated_Graceful_Cell_Shutdown_during_5G_Cell_Group_reset_VIA_CLI
    [Setup]  common.Common Test Setup
    PS.34_CB006830_Automated_Graceful_Cell_Shutdown_during_5G_Cell_Group_reset_VIA_CLI
    [Teardown]  PS.34_CB006830_Automated_Graceful_Cell_Shutdown_during_5G_Cell_Group_reset_VIA_CLI.Test Case Teardown

[1][1.0] CNI123836_PS_LTE1103_Cell_switchoff_with_NbIot_attached_device
    [Setup]  common.Common Test Setup
    PS.76_LTE1103-A_Power_Saving_Groups_Activation_via_Admin_NB_IOT_INBAND
    [Teardown]  PS.76_LTE1103-A_Power_Saving_Groups_Activation_via_Admin_NB_IOT_INBAND.Test Case Teardown
