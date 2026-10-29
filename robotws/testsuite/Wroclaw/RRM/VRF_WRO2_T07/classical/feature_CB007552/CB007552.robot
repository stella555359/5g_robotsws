*** Settings ***
Documentation
...   author: Patryk Mielcarek
...   contact: patryk.mielcarek@nokia.com
...   This is the TESTSUITE file for feature CB007552

Library         taf.ue
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py
Library         ./resources/keywords_CB007552.py

Suite Setup      prepare_testline

Test Setup       test_setup_CB007552

Test Teardown    test_teardown_CB007552

Suite Teardown   sleep_well_tl


*** Test Cases ***
CB007552-5G-C_8_Management_of_UE_Bandwidth_Capabilities_FDD_30MHz_Regression_bundle_TC
    [Documentation]    Testcase checks if attach, throughput and handover
    ...                with small and big bwp profiles are handled correctly
    [Tags]   CRT
    CB007552_5G_C_8_Management_of_UE_Bandwidth_Capabilities_FDD_30MHz_Regression_bundle_TC
