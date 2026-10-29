*** Settings ***
Resource   testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/classical/5GC001796/D/resources/test_specific_keywords.robot
Resource   testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/testline_preparation/testline_preparation.robot

Documentation  Test Cases for feature 5GC001796-D execution

Suite Setup     Prepare Testline
Test Teardown   Test Teardown

*** Test Cases ***
[1]5GC001796_DB_TC83_UL_LA_SingleTx_UE_Not_Impacted_By_Fallback_SINR_BW-5MHz_NSA
    [Documentation]  Test purpose is to check that this feature fallback of SINR parameter for Rank1 transmissions is
    ...              NOT performed in case of SingleTx UE when NIDD parameter is set to TRUE (default value).
    5GC001796_DB_TC83_UL_LA_SingleTx_UE_Not_Impacted_By_Fallback_SINR_BW-5MHz_NSA

[1]5GC001796_DB_TC79_UL_LA_Check_NIDD_impact_on_Fallback_SINR_BW-5MHz_NSA
    5GC001796_DB_TC79_UL_LA_Check_NIDD_impact_on_Fallback_SINR_BW-5MHz_NSA
