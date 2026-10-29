*** Settings ***
Documentation
...    Author: tomasz.marchewka@nokia.com
...    Description: Suite prepared for Power Saving tests execution
...    Group in charge: I_MN_RAN_PZ_3_WRO_1_GMS <I_MN_RAN_PZ_3_WRO_1@internal.nsn.com>
...    Sample execution:
...    robot -v CONFIGURATION:Wroclaw.10_16_UTESRAN2058 -C on -T -d /home/ute/test_results -L TRACE -b debug.log
...    -V /home/ute/testline_configuration/10_16_UTESRAN2058
...    testsuite/Wroclaw/OAM/RAN_PZ_WRO3_SG01/PS/Testsuites/SBTS_100784/sbts_crt.robot


Resource        ../../Testcases/PS.01_Grace_Cell_Down_via_NA/test.robot
Resource        ../../Testcases/PS.04_LTE1103-A_Power_Saving_Groups_Activation_via_Admin/test.robot
Resource        ../../Testcases/PS.05_LTE1203_Reduced_Power_Saving_Activation_via_Admin/test.robot
Resource        ../../Testcases/PS.06_LTE914_5GC000501_BTS_Reboot_While_Grace_Cell_Down_via_Admin/test.robot


Force Tags    CLOUD_SRAN_LWG_1FSMF_2FBBC_2FRGS_2FXDB_1FXED_1FXCB  # Testline dedicated for CDRT - MRBTS-100784
...           STATE_COMMISSIONED  # Required state
...           SBTS22R4  SBTS22R3  CDRT  RAN_5G  RAN_5G_MP  # Branch indicator; Test Phase indicator; Scope indicator
...           QCP_RAN_ST  QCD_MN_RAN  ## QC project; QC domain for reporting
...           PY39  ## force python3 UTE package
#...           CA_RAN_PZ_WRO_3
#...           SBTS22R4 - RAN_5G_CUSTOMER - RAN_5G
#...           SBTS22R3 - RAN_5G_MP_CUSTOMER - RAN_5G_MP

Test Timeout  24 hours

Suite Setup       Test Suite Setup
Suite Teardown    Test Suite Teardown

*** Test Cases ***
[1][1.0] Automated__PS__Graceful Cell Shut Down
    [Tags]  SBTS22R4  SBTS22R3  CDRT  RAN_5G  RAN_5G_MP
    [Setup]  Run Keywords  common.Common Test Setup  AND  Setup TAF Netact
    PS.01_Grace_Cell_Down_via_NA
    [Teardown]  PS.01_Grace_Cell_Down_via_NA.Test Case Teardown

[1][1.0] Automated__PS__LTE1103-A_Power_Saving_Groups_Activation
    [Tags]  SBTS22R4  SBTS22R3  CDRT  RAN_5G  RAN_5G_MP
    [Setup]  common.Common Test Setup
    PS.04_LTE1103-A_Power_Saving_Groups_Activation_via_Admin
    [Teardown]  PS.04_LTE1103-A_Power_Saving_Groups_Activation_via_Admin.Test Case Teardown

[1][1.0] Automated__PS__LTE1203_Reduced_Power_Saving_Activation
    [Tags]  SBTS22R4  SBTS22R3  CDRT  RAN_5G  RAN_5G_MP
    [Setup]  common.Common Test Setup
    PS.05_LTE1203_Reduced_Power_Saving_Activation_via_Admin
    [Teardown]  PS.05_LTE1203_Reduced_Power_Saving_Activation_via_Admin.Test Case Teardown

#[1][1.0] Automated__PS__BTS_Reboot_While_Grace_Cell_Down
#    [Tags]  SBTS22R4  CDRT  RAN_5G
#    [Setup]  common.Common Test Setup
#    PS.06_LTE914_5GC000501_BTS_Reboot_While_Grace_Cell_Down_via_Admin
#    [Teardown]  PS.06_LTE914_5GC000501_BTS_Reboot_While_Grace_Cell_Down_via_Admin.Test Case Teardown
