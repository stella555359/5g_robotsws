*** Settings ***
Documentation
...  Author:        Tomasz Mozola
...  Contact:       tomasz.mozola@nokia.com, grzegorz.krukar@nokia.com
...  Feature owner: Grzegorz Krukar
...  Description:   None

Resource          testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/Suite_repository.robot
Resource          testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB009543/resources/tests_9543.robot
Resource          testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/ute_report.robot


Force Tags        CA_VRF_WRO2   CRT

Suite Setup       Suite Setup for CB009543

Suite Teardown    Suite Teardown for CB009543

*** Test Cases ***
CB009543_07_C03_FDDsuper_FDDsuper_intra_gNB_HO_via_ANR_triggered_by_grfl_SA
    [Tags]   C03
    [Setup]     Test Setup for CB009543
    CB009543_07_C03_FDDsuper_FDDsuper_intra_gNB_HO_via_ANR_triggered_by_grfl_SA
    [Teardown]  Test Teardown for CB009543
