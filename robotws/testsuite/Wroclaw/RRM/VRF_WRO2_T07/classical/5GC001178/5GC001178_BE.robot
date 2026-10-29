*** Settings ***
Documentation
...   author: Krystian Wojakiewicz
...   contact: krystian.wojakiewicz@nokia.com
...   This is the TESTSUITE file for feature 5GC001178_BE for Real UE

Force Tags    PY36

Library          testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py   WITH NAME   testline_preparation
Library          testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/logs/btslog.py
Resource        ./resources/keywords_1178_BE.robot

Suite Setup      testline_preparation.prepare_testline

Test Setup       start_btslog_on_local_machine

Test Teardown    Run Keywords
    ...          stop_and_collect_btslog                          AND
    ...          Teardown TTI Traces in Streaming mode            AND
    ...          TcpdumpSmod.teardown_tcpdump_on_smod


*** Test Cases ***
[1]5GC001178_BE_13_Proactive_scheduling_4UEs_20MHz_bandwidth
    [Documentation]  The purpose of this test case is to check the proactive scheduling of UEs.
    [1]5GC001178_BE_13_Proactive_scheduling_4UEs_20MHz_bandwidth


[1]5GC001178_BE_7_MCS_Reduction_4UEs_DL_goodRC_20MHz_bandwidth
    [Documentation]  The purpose of this test case is to check DL MCS reduction due to
    ...              low amount of data in buffer for multi Ues scenario.
    [1]5GC001178_BE_7_MCS_Reduction_4UEs_DL_goodRC_20MHz_bandwidth


[1]5GC001178_BE_3_Attach_UE_GoodCondition_WithoutTraffic_CSI-RS_CSI report_check_20MHz_bandwidth
    [Documentation]  The puropose of the test is to check if CSI-RS in SS slot are received by the UE and the
     ...             CSI reports for channel measurement are sent periodically by the UE on the PUCCH.
    [1]5GC001178_BE_3_Attach_UE_GoodCondition_WithoutTraffic_CSI-RS_CSI report_check_20MHz_bandwidth


[1]5GC001178_BE_10_RACH_Priority_Handling_2UEs_goodRC_20MHz_bandwidth
    [Documentation]  The purpose of this TC is to check the RACH procedure for
    ...              initial attach of two UEs on the same timeslot.
    [1]5GC001178_BE_10_RACH_Priority_Handling_2UEs_goodRC_20MHz_bandwidth


[1]5GC001178_BE_4_2UE_UL&DL_TimingCheck_UlDataPucchReceiveReq and UlDataPucchReceiveRespPs_CSI-RS_SSBslot_check_CSI-RS_CSI_report_20MHz_bandwidth
    [Documentation]  The purpose of this test case is to validate the timing of UlDataPucchReceiveRespPs
    ...              and UlDataPucchReceiveReq. They should be sent on the same SFN and slot.
    [1]5GC001178_BE_4_2UE_UL&DL_TimingCheck_UlDataPucchReceiveReq and UlDataPucchReceiveRespPs_CSI-RS_SSBslot_check_CSI-RS_CSI_report_20MHz_bandwidth


[1]5GC001178_BE_6_SR_handling_10UE_UL_DL_20MHz_bandwidth
    [Documentation]  The purpose of this test case is to validate scheduling request handling.
    [1]5GC001178_BE_6_SR_handling_10UE_UL_DL_20MHz_bandwidth
