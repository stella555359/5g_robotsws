*** Settings ***
Documentation
...    Author: tomasz.marchewka@nokia.com
...    Description: Suite prepared for Power Saving tests execution
...    Group in charge: I_MN_RAN_RD_VRF_TSR1_5 <I_MN_RAN_RD_VRF_TSR1_5@internal.nsn.com>
...    Sample execution:
...    robot -v CONFIGURATION:Timisoara.10_18_UTESRANCLOUD1814 -C on -T -d /home/ute/test_results -L TRACE -b debug.log
...    -V /home/ute/testline_configuration/10_18_UTESRANCLOUD1814 testsuite/Timisoara/SBTS/PS/PS/Testsuites/SBTS_101035/sbts_crt.robot


Resource        ../../Testcases/PS.01_Grace_Cell_Down_via_NA/test.robot
Resource        ../../Testcases/PS.04_LTE1103-A_Power_Saving_Groups_Activation_via_Admin/test.robot
Resource        ../../Testcases/PS.05_LTE1203_Reduced_Power_Saving_Activation_via_Admin/test.robot
Resource        ../../Testcases/PS.06_LTE914_5GC000501_BTS_Reboot_While_Grace_Cell_Down_via_Admin/test.robot


Force Tags    CLOUD_SRAN_L_10814_1ASIA_2ABIA_1AHFB_2FXEF_2FRMF  # Testline dedicated for CDRT - MRBTS-10814
...           STATE_COMMISSIONED  # Required state
...           SBTS00  SBTS26R2	SBTS26R1	SBTS25R3  CDRT  RAN_5G  RAN_5G_MP  # Branch indicator; Test Phase indicator; Scope indicator
...           QCP_RAN_VRF  QCD_MN_RAN  ## QC project; QC domain for reporting
...           PY39  ## force python3 UTE package
#...           CA_VRF_TSR1_T05
#...           SBTS00 - RAN_5G_CD - RAN_5G
#...           SBTS23R2 - RAN_5G_CUSTOMER - RAN_5G
#...           SBTS23R1 - RAN_5G_CUSTOMER - RAN_5G
#...           SBTS22R4 - RAN_5G_CUSTOMER - RAN_5G
#...           SBTS22R3 - RAN_5G_MP_CUSTOMER - RAN_5G_MP

Test Timeout  24 hours

Suite Setup       Test Suite Setup
Suite Teardown    Test Suite Teardown

*** Variables ***
${att_port_1}         ${tl.enbs[0].rms[0].attenuation_ports[0].port_no}
${att_port_2}         ${tl.enbs[0].rms[1].attenuation_ports[0].port_no}
${att_port_3}         ${tl.enbs[0].rms[0].attenuation_ports[1].port_no}
${att_port_4}         ${tl.enbs[0].rms[1].attenuation_ports[1].port_no}
${att_port_5}         ${tl.enbs[0].rms[0].attenuation_ports[2].port_no}
${att_port_6}         ${tl.enbs[0].rms[1].attenuation_ports[2].port_no}
${att_port_numbers}    ${tl.attenuator[0].attenuation_port_numbers}

*** Test Cases ***
[1][1.0] Automated__PS__Graceful Cell Shut Down
    [Tags]  SBTS25R1	SBTS24R3  CDRT  RAN_5G  RAN_5G_MP
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.01_Grace_Cell_Down_via_NA
    [Teardown]  PS.01_Grace_Cell_Down_via_NA.Test Case Teardown

[1][1.0] Automated__PS__LTE1103-A_Power_Saving_Groups_Activation
    [Tags]  SBTS00  SBTS25R2	SBTS25R1	SBTS24R3  CDRT  RAN_5G  RAN_5G_MP
    [Setup]  common.Common Test Setup
    PS.04_LTE1103-A_Power_Saving_Groups_Activation_via_Admin
    [Teardown]  PS.04_LTE1103-A_Power_Saving_Groups_Activation_via_Admin.Test Case Teardown

[1][1.0] Automated__PS__LTE1203_Reduced_Power_Saving_Activation
    [Tags]  SBTS00  SBTS25R2	SBTS25R1	SBTS24R3  CDRT  RAN_5G  RAN_5G_MP
    [Setup]  common.Common Test Setup
    PS.05_LTE1203_Reduced_Power_Saving_Activation_via_Admin
    [Teardown]  PS.05_LTE1203_Reduced_Power_Saving_Activation_via_Admin.Test Case Teardown

[1][1.0] Automated__PS__BTS_Reboot_While_Grace_Cell_Down
    [Tags]  SBTS00  SBTS25R2	CDRT  RAN_5G  RAN_5G_MP
    [Setup]  common.Common Test Setup
    PS.06_LTE914_5GC000501_BTS_Reboot_While_Grace_Cell_Down_via_Admin
    [Teardown]  PS.06_LTE914_5GC000501_BTS_Reboot_While_Grace_Cell_Down_via_Admin.Test Case Teardown
