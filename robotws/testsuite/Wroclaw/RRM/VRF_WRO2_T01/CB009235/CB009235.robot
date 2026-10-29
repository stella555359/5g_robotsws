*** Settings ***
Resource       testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB009235/resources/tests_9235.robot
Resource       testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/setup_teardown.robot
Library        testsuite.Wroclaw.RRM.VRF_WRO2_T01.resources.legacy.TTIDecoderInstaller    WITH NAME    tti
Library        testsuite.Wroclaw.RRM.VRF_WRO2_T01.resources.legacy.l2_trace    WITH NAME    l2_trace
Resource       testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/ute_report.robot
Resource       testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/Suite_repository.robot

Documentation  Target testline -> 7_16_UTE5GWPTAVQL1. It is related with CLOUD_5G_CLASSICAL_QC_ASILL_ABIOB1_1xAVQL
...            topology. For now it is integrated with ute-ca sw_uploaded state.

Suite Setup       Suite Setup WPT

Test Setup        Test Setup WPT

Test Teardown     Test Teardown WPT

*** Variables ***
${ue_lib}    ute_ue

*** Test Cases ***
[1]TC09_CB009235-C-Verify_selected_Enhanced_PM_Counters_DL-MUMIMO
    [1]TC09_CB009235-C-Verify_selected_Enhanced_PM_Counters_DL-MUMIMO
    set suite variable  ${8305_pass}  ${True}

[1]TC05_CB009235-B-Support_DL_pairing_for_Ues_with_MAC_CE_on_5G_NSA_mode
    [Setup]  log to console  dummy setup
    Variable Should Exist  ${8305_pass}  msg=Parent's requirements didn't pass.
    [Teardown]  log to console  dummy teardown

