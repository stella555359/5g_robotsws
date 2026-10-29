*** Settings ***
Documentation
...    Author: jakub.hirny@nokia.com
...    Description: Suite prepared for STRESS TESTING tests execution
...    Group in charge: I_MN_RAN_PZ_3_WRO_1_GMS <I_MN_RAN_PZ_3_WRO_1@internal.nsn.com>
...    Sample execution:
...    robot -v CONFIGURATION:Wroclaw.10_16_UTESRAN2161 -C on -T -d /home/ute/test_results -L TRACE -b debug.log -V /home/ute/10_16_UTESRAN2161
...    testsuite/Wroclaw/OAM/VRF_WRO3_T02/STRESS_TESTING/Testsuites/Stress/CB008880.robot


Resource        ../../Testcases/SM.31_Enhanced_RAT_Reset_via_NA/test.robot

Force Tags
...           SBTS00  SBTS23R1  SBTS22R4  CRT  # Branch indicator; Test Phase indicator; Scope indicator
...           QCP_RAN_ST  QCD_MN_RAN  ## QC project; QC domain for reporting
...           PY39  ## force python3 UTE package
...           RF50

*** Test Cases ***
CB008880-F_LTE_NR_enhanced_RAT_reset_via_NetAct
    [Setup]  Run Keywords  Common Test Setup  AND  Setup TAF Netact
    ...  AND  Set Feature On Expected Value  parameter=actRatResetEnhancement  value=true
    SM.31_Enhanced_RAT_Reset_via_NA
    [Teardown]  Run Keywords  Set Feature On Expected Value  parameter=actRatResetEnhancement  value=false
    ...  AND  Common Test Teardown  AND  Teardown TAF Netact
