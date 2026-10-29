*** Settings ***
Documentation
...  Test case for CB010683 feature. TC name is mapped from QC instance Test ID: 155955- CB010683-A_TC1_actNrExtCellSOMethod
...  activation deactivation for PSGs_RFU 64TRX
...  Feature corner: https://feature-corner.nsn-net.net/materials/clegxsads02cgkz3b0o77wtao
...  Basic TC scenario:
...  Description:   1. Commissioning with proper SCF with feature off. 2. Activate a feature using delta commissioning.
...  3. Check for no unexpected alarms have occurred.  4. Check for L3 call is possible through all cells.
...  5. Deactivate a feature using delta commissioning.  6. Check for no unexpected alarms have occurred.
...  Target testline -> 7_16_UTE5GWPTAVQL1. It is related with CLOUD_5G_CLASSICAL_QC_ASILL_ABIOB1_1xAVQL
...  topology. For now it is integrated with ute-ca sw_uploaded state.

Resource       testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/setup_teardown.robot
Resource       testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB010683/resources/tests_CB010683.robot
Library        testsuite.Wroclaw.RRM.VRF_WRO2_T01.resources.legacy.TTIDecoderInstaller    WITH NAME    tti
Library        testsuite.Wroclaw.RRM.VRF_WRO2_T01.resources.legacy.l2_trace    WITH NAME    l2_trace
Resource       testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/ute_report.robot
Resource       testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/Suite_repository.robot


Suite Setup       Suite Setup WPT

Test Setup        Test Setup WPT

Test Teardown     Test Teardown WPT

*** Variables ***
${ue_lib}    ute_ue

*** Test Cases ***
[1]CB010683-A_TC1_actNrExtCellSOMethod activation deactivation for PSGs_RFU 64TRX
    CB010683-A_TC1_actNrExtCellSOMethod activation deactivation for PSGs_RFU 64TRX
