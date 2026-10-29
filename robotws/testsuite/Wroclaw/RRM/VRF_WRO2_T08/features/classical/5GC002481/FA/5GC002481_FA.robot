*** Settings ***
Documentation  Author and maintainer: tomasz.sobania@nokia.com
Resource       ./resources/test_specific_keywords.robot

Force Tags      CA_VRF_WRO2

Suite Setup  Setup
Suite Teardown  Teardown
Test Setup  Set TESTNAME without spaces

*** Test Cases ***
[1]5GC002177_TC03_5GC002481_FA_003_SgNB_release_based_on_A2_based on RSRP_without_SRB3
    [1]5GC002177_TC03_5GC002481_FA_003_SgNB_release_based_on_A2_based_on_RSRP_without_SRB3
    [Teardown]  Test Case 03 Teardown

[1]5GC002177_TC08_5GC002481_FA_008_Intra_gNB_PSCell_change_A5_enable_and_configured_A2_RSRP_RSRQ
    [1]5GC002177_TC08_5GC002481_FA_008_Intra_gNB_PSCell_change_A5_enable_and_configured_A2_RSRP_RSRQ
    [Teardown]  Test Case 08 Teardown
