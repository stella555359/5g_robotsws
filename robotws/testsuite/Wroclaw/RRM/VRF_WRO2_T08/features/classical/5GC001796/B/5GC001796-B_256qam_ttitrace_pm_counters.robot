*** Settings ***
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T08/features/classical/5GC001796/B/resources/test_specific_keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T08/resources/testline_preparation/testline_preparation.robot

Documentation  Test Cases for feature 5GC001796-B 256QAM execution

Force Tags      CA_VRF_WRO2

Suite Setup     Run Keywords   Prepare Testline   AND   Counters 256qam Trigger
Suite Teardown  Counters Suite Teardown
Test Setup      Set test variable    ${TESTNAME}    5GC001796_B_256qam_ttitrace_pm_counters
Test Teardown   Test Teardown

*** Test Cases ***
[1]5GC001796_BB_TC114_M55304C06000-27_Initial_and_retransmission_volume_on_PDSCH_with_256QAM_MCS_table_using_MCS_0-27
    [Documentation]  The purpose of this test case is to check that PM counter M55304C06000-27 is correctly incremented.
    5GC001796_BB_TC114_M55304C06000-27_Initial_and_retransmission_volume_on_PDSCH_with_256QAM_MCS_table_using_MCS_0-27

[1]5GC001796_BB_TC113_M55304C05000-27_Initial_transmission_volume_on_PDSCH_with_256QAM_MCS_table_using_MCS_0-27
    [Documentation]  The purpose of this test case is to check that PM counter M55304C05000-27 is correctly incremented.
    5GC001796_BB_TC113_M55304C05000-27_Initial_transmission_volume_on_PDSCH_with_256QAM_MCS_table_using_MCS_0-27

[1]5GC001796_BB_TC110_M55301C20020-35_Wideband_CQI_Histogram_when_UE_reports_related_to_256QAM_table-CQI_Level_0-15
    [Documentation]  The purpose of this test case is to check that PM counter M55301C20000-15 is correctly incremented.
    5GC001796_BB_TC110_M55301C20020-35_Wideband_CQI_Histogram_when_UE_reports_related_to_256QAM_table-CQI_Level_0-15

[1]5GC001796_BB_TC108_M55300C07000-27_Unsuccessful_PDSCH_transmissions_by_last_HARQ_reTx_with_256QAM_MCS_table_using_MCS_0-27
    [Documentation]  The purpose of this test case is to check that PM counter M55300C07000-27 is correctly incremented.
    5GC001796_BB_TC108_M55300C07000-27_Unsuccessful_PDSCH_transmissions_by_last_HARQ_reTx_with_256QAM_MCS_table_using_MCS_0-27

[1]5GC001796_BB_TC107_M55300C06000-27_Successful_PDSCH_transmissions_by_any_transmission_with_256QAM_MCS_table_using_MCS_0-27
    [Documentation]  The purpose of this test case is to check that PM counter M55300C06000-27 is correctly incremented.
    5GC001796_BB_TC107_M55300C06000-27_Successful_PDSCH_transmissions_by_any_transmission_with_256QAM_MCS_table_using_MCS_0-27

[1]5GC001796_BB_TC106_M55300C05000-27_Successful_PDSCH_transmissions_by_initial_transmission_with_256QAM_MCS_table_using_MCS_0-27
    [Documentation]  The purpose of this test case is to check that PM counter M55300C05000-27 is correctly incremented.
    5GC001796_BB_TC106_M55300C05000-27_Successful_PDSCH_transmissions_by_initial_transmission_with_256QAM_MCS_table_using_MCS_0-27

[1]5GC001796_BB_TC105_M55300C04000-27_PDSCH_initial_transmissions_with_256QAM_MCS_table_using_MCS_0-27
    [Documentation]  The purpose of this test case is to check that PM counter M55300C04000-27 is correctly incremented.
    5GC001796_BB_TC105_M55300C04000-27_PDSCH_initial_transmissions_with_256QAM_MCS_table_using_MCS_0-27
