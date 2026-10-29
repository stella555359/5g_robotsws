*** Settings ***
Documentation    All T123 CRT regression TCs shall be added here for fully automated regression testing.

Force Tags    CA_5G_RRM   STATE_SW_UPLOADED   5G_RAN   5G_RAN_FDD
...           RAN_5G    RAN_5G_FDD   RAN_5G_FDD_MP   RAN_5G_MP   PY36   CRT
...           SBTS22R3__WITH__CLOUD_5G_CLASSICAL_2xANDROID_ASIB_ABIO_2xAHPF_ENB
...           SBTS22R4__WITH__CLOUD_5G_CLASSICAL_2xANDROID_ASIB_ABIO_2xAHPF_ENB
...           SBTS00__WITH__CLOUD_5G_CLASSICAL_2xANDROID_ASIB_ABIO_2xAHPF_ENB

Library         taf.ue
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_CB007552/resources/keywords_CB007552.py
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB009333/resources/keywords_9333.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/reports/reporting_portal.robot


Suite Teardown   sleep_well_tl

Test Teardown    Run Keyword and Ignore Error    Add scout external execution id to the reporting portal


*** Test Cases ***
CB007552-5G-C_8_Management_of_UE_Bandwidth_Capabilities_FDD_30MHz_Regression_bundle_TC
    [Documentation]    Testcase checks if attach, throughput and handover
    ...                with small and big bwp profiles are handled correctly
    [Setup]      test_setup_CB007552
    CB007552_5G_C_8_Management_of_UE_Bandwidth_Capabilities_FDD_30MHz_Regression_bundle_TC
    [Teardown]   Run keywords
    ...   Run keyword and ignore error   test_teardown_CB007552  AND
    ...         Run Keyword and Ignore Error    Add scout external execution id to the reporting portal

CB009333_F_2_RLC_status_PDU_for_UL_packets_scheduled_without_extra_delay_caused_by_micro-DTX_functionality_for_regulat_non-GBR_DL_data_FDD_NSA
   [Documentation]   This Test Case describes expected Nokia gNB behaviour for RLC status PDU (for UL packets)
    ...              are scheduled on DL in the same manner as any delay-sensitive data in terms of
    ...              micro-DTX functionality. Scheduling of delay-sensitive data is not impacted.
    ...              Delay-sensitive data includes: SSBs, TRS, System Information including SIB1 (optional for NSA),
    ...              other SIBs (only for SA), paging – NSA Case.
    CB009333_F_2_RLC_status_PDU_for_UL_packets_scheduled_without_extra_delay_caused_by_micro-DTX_functionality_for_regulat_non-GBR_DL_data_FDD_NSA

CB009333_G_6_Multi_UE_micro_DTX_optimized_scheduling_and_SIB&Pagin_Common_Search_Space_Optimatization_FDD
   [Documentation]     This Test Case describes expected Nokia gNB behavior and micro DTX optimized scheduling
    ...                interworking with CB009550 feature on FDD deployment with NSA UEs.
    CB009333_G_6_Multi_UE_micro_DTX_optimized_scheduling_and_SIB&Pagin_Common_Search_Space_Optimatization_FDD

CB009333_W_4_Single_UE_Ping_latency_Check_NSA_mode
   [Documentation]     This is a comparison testing ping latency under feature CB009333.
    CB009333_W_4_Single_UE_Ping_latency_Check_NSA_mode
