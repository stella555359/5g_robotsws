*** Settings ***
Documentation
...    Author: tomasz.marchewka@nokia.com
...    Description: Suite prepared for Power Saving tests execution
...    Group in charge: I_MN_RAN_RD_VRF_TSR1_5 <I_MN_RAN_RD_VRF_TSR1_5@internal.nsn.com>
...    Sample execution:
...    robot -v CONFIGURATION:Wroclaw.10_16_UTESRAN2161 -C on -T -d /home/ute/test_results -L TRACE -b debug.log
...    -V /home/ute/testline_configuration/10_16_UTESRAN2161
...    testsuite/Wroclaw/OAM/RAN_PZ_WRO3_SG01/PS/Testsuites/SBTS_101006/sbts_crt.robot


Resource        ../../Testcases/PS.56_LTE1203_Reduced_Power_Saving_Activation_For_Cell_Level_PSGRPs_Via_Admin/test.robot
Resource        ../../Testcases/PS.57_LTE1103_Cell_Level_Power_Saving_Groups_Activation_Via_Admin/test.robot


Force Tags
...           SBTS00  SBTS24R3  CRT  # Branch indicator; Test Phase indicator; Scope indicator
...           QCP_RAN_VRF  QCD_MN_RAN  ## QC project; QC domain for reporting
...           PY39  ## force python3 UTE package
...           CLOUD_SRAN_NLG_10808_1ASIM_1ABIA_1ABIP_1ABIN_1ASIL_1ABIA_1ABIN_1ABIN_1FXEB_1AHEGA_1AHLOA_1FRHF_2FXEF_1AKQI_1AHCA
...           SKIP_INSTALL_TOOLS

Test Timeout  24 hours

Suite Setup       Test Suite Setup
Suite Teardown    Test Suite Teardown

*** Test Cases ***
[1][1.0]PS__CNI122964_LTE1103 Cell level power saving groups activation via Admin
    [Setup]  common.Common Test Setup
    PS.57_LTE1103_Cell_Level_Power_Saving_Groups_Activation_Via_Admin
    [Teardown]  PS.57_LTE1103_Cell_Level_Power_Saving_Groups_Activation_Via_Admin.Test Case Teardown

[1][1.0]PS__CNI122964_LTE1203 Reduced power saving activation for cell level PSGRPs via Admin
    [Setup]  common.Common Test Setup
    PS.56_LTE1203_Reduced_Power_Saving_Activation_For_Cell_Level_PSGRPs_Via_Admin
    [Teardown]  PS.56_LTE1203_Reduced_Power_Saving_Activation_For_Cell_Level_PSGRPs_Via_Admin.Test Case Teardown
