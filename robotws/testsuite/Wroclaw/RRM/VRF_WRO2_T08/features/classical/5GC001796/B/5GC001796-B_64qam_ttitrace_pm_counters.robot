*** Settings ***
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/classical/5GC001796/B/resources/test_specific_keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/testline_preparation/testline_preparation.robot

Documentation  Test Cases for feature 5GC001796-B 64QAM execution

Force Tags      CA_VRF_WRO2

Suite Setup   Run Keywords   Prepare Testline   AND   Counters 64qam Trigger
Suite Teardown   Counters Suite Teardown
Test Setup   Set test variable   ${TESTNAME}   5GC001796_B_64qam_ttitrace_pm_counters
Test Teardown   Test Teardown

*** Test Cases ***
[1]5GC001796_BB_TC112_M55303C06001-25_Received_UE_related_SINR_in_Rank_2_for_PUSCH_Level_01-25
    [Documentation]  The purpose of this test case is to check that PM counter M55303C06001-25 is correctly incremented.
    5GC001796_BB_TC112_M55303C06001-25_Received_UE_related_SINR_in_Rank_2_for_PUSCH_Level_01-25

[1]5GC001796_BB_TC111_M55303C05001-25_Received_UE_related_SINR_in_Rank_1_for_PUSCH_Level_01-25
    [Documentation]  The purpose of this test case is to check that PM counter M55303C05001-25 is correctly incremented.
    5GC001796_BB_TC111_M55303C05001-25_Received_UE_related_SINR_in_Rank_1_for_PUSCH_Level_01-25

[1]5GC001796_BB_TC109_M55301C19020-35_Wideband_CQI_Histogram_when_UE_reports_related_to_64QAM_table-CQI_Level_0-15
    [Documentation]  The purpose of this test case is to check that PM counter M55301C19000-15 is correctly incremented.
    5GC001796_BB_TC109_M55301C19020-35_Wideband_CQI_Histogram_when_UE_reports_related_to_64QAM_table-CQI_Level_0-15
