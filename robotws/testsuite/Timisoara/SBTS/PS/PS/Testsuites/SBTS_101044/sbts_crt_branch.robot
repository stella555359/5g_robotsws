*** Settings ***
Documentation
...    Author: valentin.suru@nokia.com
...    Description: Suite prepared for Power Saving tests execution
...    Group in charge: I_MN_RAN_RD_VRF_TSR1_5 <I_MN_RAN_RD_VRF_TSR1_5@internal.nsn.com>
...    Sample execution:
...    robot -v CONFIGURATION:Timisoara.10_18_UTESRANCLOUD1809 -C on -T -d /home/ute/test_results -L TRACE -b debug.log
...    -V /home/ute/testline_configuration/10_18_UTESRANCLOUD1809
...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/PS/PS/Testsuites/SBTS_101044/sbts_crt_branch.robot


Resource        ../../Testcases/PS.01_Grace_Cell_Down_via_NA/test.robot
Resource        ../../Testcases/PS.03_LBT4152-E_Graceful_cell_shutdown_during_parameter_reset/test.robot
Resource        ../../Testcases/PS.06_LTE914_5GC000501_BTS_Reboot_While_Grace_Cell_Down_via_Admin/test.robot
Resource        ../../Testcases/PS.22_CB008800_Independent_activation_periods_and_switch_off_orders_for_LTE1103_and_LTE1203/test.robot
Resource        ../../Testcases/PS.24_CB008800_Backward_compatibility_with_LTE1103_and_LTE1203_SR003080/test.robot

Force Tags
...           SBTS00  CRT  # Branch indicator; Test Phase indicator; Scope indicator
...           QCP_RAN_VRF  QCD_MN_RAN  ## QC project; QC domain for reporting
...           PY39  ## force python3 UTE package
...           CLOUD_SRAN_LG_10809_1FSMF_2FBBC_2FXED
...           SKIP_INSTALL_TOOLS
#...           SKIP_SCF_VALIDATION

Test Timeout  24 hours

#Suite Setup       Test Suite Setup
#Suite Teardown    Test Suite Teardown

*** Variables ***
${att_port_1}         ${tl.enbs[0].rms[2].attenuation_ports[0].port_no}
${att_port_2}         ${tl.enbs[0].rms[2].attenuation_ports[1].port_no}
${att_port_3}         ${tl.enbs[0].rms[2].attenuation_ports[2].port_no}
${att_port_4}         ${tl.enbs[0].rms[2].attenuation_ports[3].port_no}
${att_port_5}         ${tl.enbs[0].rms[0].attenuation_ports[0].port_no}
${att_port_6}         ${tl.enbs[0].rms[0].attenuation_ports[1].port_no}
${att_port_numbers}   ${tl.attenuator[0].attenuation_port_numbers}
${NETACT_ID}          1047

*** Test Cases ***
1][1.0] Automated__PS__Graceful Cell Shut Down
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.01_Grace_Cell_Down_via_NA
    [Teardown]  PS.01_Grace_Cell_Down_via_NA.Test Case Teardown

[1][1.0] Automated__PS__LBT4152-E_Graceful_cell_shutdown_during_parameter_change_with_eNB_reset
    [Setup]  common.Common Test Setup
    PS.03_LBT4152-E_Graceful_cell_shutdown_during_parameter_reset
    [Teardown]  PS.03_LBT4152-E_Graceful_cell_shutdown_during_parameter_reset.Test Case Teardown

[1][1.0] Automated__PS__BTS_Reboot_While_Grace_Cell_Down
    [Setup]  common.Common Test Setup
    PS.06_LTE914_5GC000501_BTS_Reboot_While_Grace_Cell_Down_via_Admin
    [Teardown]  PS.06_LTE914_5GC000501_BTS_Reboot_While_Grace_Cell_Down_via_Admin.Test Case Teardown

[1]PS_CB008800_Independent_activation_periods_and_switch_off_orders_for_LTE1103_and_LTE1203
    [Setup]  Common Test Setup
    PS.22_CB008800_Independent_activation_periods_and_switch_off_orders_for_LTE1103_and_LTE1203
    [Teardown]  PS.22_CB008800_Independent_activation_periods_and_switch_off_orders_for_LTE1103_and_LTE1203.Test Case Teardown

[1]PS_CB008800_Backward_compatibility_with_LTE1103_and_LTE1203_SR003080
    [Setup]  common.Common Test Setup
    PS.24_CB008800_Backward_compatibility_with_LTE1103_and_LTE1203_SR003080
    [Teardown]  PS.24_CB008800_Backward_compatibility_with_LTE1103_and_LTE1203_SR003080.Test Case Teardown
