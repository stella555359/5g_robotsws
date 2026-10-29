*** Settings ***
Documentation
...    Author: tomasz.marchewka@nokia.com
...    Description: Suite prepared for Power Saving tests execution
...    Group in charge: I_MN_RAN_PZ_3_WRO_1_GMS <I_MN_RAN_PZ_3_WRO_1@internal.nsn.com>
...    Sample execution:
...    robot -v CONFIGURATION:Wroclaw.10_16_UTESRAN2021 -C on -T -d /home/ute/test_results -L TRACE -b debug.log -V /home/ute/10_16_UTESRAN2021
...    testsuite/Wroclaw/OAM/RAN_PZ_WRO3_SG01/PS/Testsuites/SBTS_55201/sbts_crt.robot

Resource        ../../Testcases/PS.37_CB008745_Suspend_Power_Saving_NR/test.robot
Resource        ../../Testcases/PS.38_CB008745_Backward_compatibility_NR/test.robot
Resource        ../../Testcases/PS.24_CB008800_Backward_compatibility_with_LTE1103_and_LTE1203_SR003080/test.robot


Force Tags
...           SBTS00  CRT  # Branch indicator; Test Phase indicator; Scope indicator
...           QCP_RAN_ST  QCD_MN_RAN  ## QC project; QC domain for reporting
...           CA_RAN_PZ_WRO_3
...           PY39  ## force python3 UTE package
...           CLOUD_SRAN_N_1ASIM_1ABIP_1ABIQ_2AZNA_1AZHA_UTECA
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
${att_port_9}         ${tl.enbs[0].rms[2].attenuation_ports[0].port_no}
${att_port_10}        ${tl.enbs[0].rms[2].attenuation_ports[1].port_no}
${att_port_11}        ${tl.enbs[0].rms[2].attenuation_ports[2].port_no}
${att_port_12}        ${tl.enbs[0].rms[2].attenuation_ports[3].port_no}
${att_port_numbers}    ${tl.attenuator[0].attenuation_port_numbers}

*** Test Cases ***
[1][1.0] Automated__PS__CB008745_Suspend_Power_Saving_NR
    [Setup]  common.Common Test Setup
    PS.37_CB008745_Suspend_Power_Saving_NR
    [Teardown]  PS.37_CB008745_Suspend_Power_Saving_NR.Test Case Teardown
	
[1][1.0] Automated__PS__CB008745_ Backward_compatibility_NR
    [Setup]  common.Common Test Setup
    PS.38_CB008745_Backward_compatibility_NR
    [Teardown]  PS.38_CB008745_Backward_compatibility_NR.Test Case Teardown	

[1][1.0] PS_CB008800_Backward_compatibility_with_LTE1103_and_LTE1203_SR003080
    [Setup]  common.Common Test Setup
    PS.24_CB008800_Backward_compatibility_with_LTE1103_and_LTE1203_SR003080
    [Teardown]  PS.24_CB008800_Backward_compatibility_with_LTE1103_and_LTE1203_SR003080.Test Case Teardown
