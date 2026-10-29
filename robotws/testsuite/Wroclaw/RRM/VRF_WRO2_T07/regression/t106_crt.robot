*** Settings ***
Documentation   CRT regression

Force Tags    CA_5G_RRM   STATE_SW_UPLOADED   RAN_5G   RAN_5G_FDD   RAN_5G_FDD_MP   RAN_5G_MP   RAN_5G_FDD_MP_CUSTOMER
...           CRT   CLOUD_5G_CLASSICAL_SA_VIAVI_ASIKL_ABILB1_2xAHCA_AHFIB
...           SBTS00

Library          taf.ue
Library          testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py
Library          testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Library          testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/rue/attach_utils.py
Library          testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_5GC000732/F/resources/keywords_732_F.py
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_CB008238/A/resources/keywords_8238_A.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_CB008238/B/resources/keywords_8238_B.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_CB008238/C/resources/keywords_8238_C.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_CB008238/E/resources/keywords_8238_E.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_CB008238/F/resources/keywords_8238_F.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_CB008238/W/resources/keywords_8238_W.robot
Resource         taf/rfrl/common_resources/common_step/interface.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/reports/reporting_portal.robot

Suite Setup      prepare_testline      second_wind=${True}

Test Setup      Run Keywords
...             initialise_attenuator                                           AND
...             nullify_attenuation_on_all_ports

Suite Teardown   Run keywords
...              Run keyword and ignore error   interface.Common step trigger       AND
...              sleep_well_tl


*** Test Cases ***
5GC000732-F_7_FDD_TDD_RLF_RRC_Connection_Re-establishment_Same_Serving_Cell_Valid_UE_Context_int_2640
    [Documentation]    This TC checks whether reestablishment works correctly with carrier aggregation.
    [Tags]   SBTS22R4
    keywords_732_F.TC_5GC000732_F_7
    [Teardown]  Run Keywords
    ...          keywords_732_F.F_7_teardown                 AND
    ...              Run Keyword and Ignore Error    Add scout external execution id to the reporting portal

CB008238_A_09_Single-UE_small_packet_timer_higher_than_dtxMaxRetentionDelay_on_NSA+SA (SA)
    [Documentation]   This TC shall verify the optimized DTX algorithm when traffic interval is HIGHER than dtxMaxRetentionDelay.
    [Tags]   CDRT
    ...      SBTS22R4
    CB008238_A_09_Single-UE_small_packet_timer_higher_than_dtxMaxRetentionDelay_on_NSA+SA (SA)
    [Teardown]  Run Keywords
    ...          TC_teardown_8238_A                AND
    ...              Run Keyword and Ignore Error    Add scout external execution id to the reporting portal

CB008238-5G-B_1_Single-UE_non_GBR_traffic_and_delay_sensitive_data_interaction_evaluation
    [Tags]   SBTS22R4
    [Documentation]   This TC shall verify the interaction between optimized DTX and PdschAtSsbSlot.
    CB008238-5G-B_1_Single-UE_non_GBR_traffic_and_delay_sensitive_data_interaction_evaluation
    [Teardown]   Run Keywords
    ...          TC_teardown_B_1                AND
    ...              Run Keyword and Ignore Error    Add scout external execution id to the reporting portal

CB008238-5G-C_1_Single_UE_Data_Schedule_Exceed_dtxPrbThreshold_low_value_and_high_value
    [Documentation]   This TC verifies whether optimized DTX is turned off and on correctly when dtxPrbThreshold is exceeded.
    [Tags]   CDRT
    ...      SBTS22R4
    CB008238-5G-C_1_Single_UE_Data_Schedule_Exceed_dtxPrbThreshold_low_value_and_high_value
    [Teardown]   Run Keywords
    ...          TC_teardown_C_1                AND
    ...              Run Keyword and Ignore Error    Add scout external execution id to the reporting portal

CB008238-5G-C_6_Single_UE_Max_Throughput
    [Documentation]   This TC verifies whether feature CB008238-C doesn't negatively affect throughput.
    [Tags]   SBTS22R4
    CB008238-5G-C_6_Single_UE_Max_Throughput
    [Teardown]   Run Keywords
    ...          TC_teardown_C_6                AND
    ...              Run Keyword and Ignore Error    Add scout external execution id to the reporting portal

CB008238-5G-E_1_Single_UE_CA_interaction_with_micro_DTX_optimized_scheduling_SA_mode_FDD_FDD
    [Documentation]  This TC checks whether CB008238 is turned on and off correctly, when SCell activates/deactivates.
    CB008238-5G-E_1_Single_UE_CA_interaction_with_micro_DTX_optimized_scheduling_SA_mode_FDD_FDD
    [Teardown]   Run Keywords
    ...          TC_teardown_E                AND
    ...              Run Keyword and Ignore Error    Add scout external execution id to the reporting portal

CB008238-5G-E_3_Single_UE_CA_interaction_with_micro_DTX_optimized_scheduling_for_SA_mode_for_blind_method_activation_FDD_FDD
    [Documentation]  This TC checks whether CB008238 is turned on and off correctly, when SCell activates/deactivates.
    CB008238-5G-E_3_Single_UE_CA_interaction_with_micro_DTX_optimized_scheduling_for_SA_mode_for_blind_method_activation_FDD_FDD
    [Teardown]   Run Keywords
    ...          TC_teardown_E                AND
    ...              Run Keyword and Ignore Error    Add scout external execution id to the reporting portal

CB008238-5G-F_4_Single-UE_conditional_buffering_based_on_the_delay_since_last_scheduling_with_counters_not_incremented_M55308C33000_M55308C33001_SA
    [Documentation]  This TC verifies whether delaySinceLastScheduled works correctly for tput ABOVE threshold.
    [Tags]   SBTS22R4
    CB008238-5G-F_4
    [Teardown]   Run Keywords
    ...          TC_teardown_F_4                AND
    ...              Run Keyword and Ignore Error    Add scout external execution id to the reporting portal

CB008238-5G-F_7_Single-UE_conditional_buffering_based_on_the_delay_since_last_scheduling_with_counters_incremented_M55308C33000_5308C33001_SA
    [Documentation]  This TC verifies whether delaySinceLastScheduled works correctly for tput BELOW threshold.
    [Tags]   CDRT
    ...      SBTS22R4
    CB008238-5G-F_7
    [Teardown]   Run Keywords
    ...          TC_teardown_F_7                AND
    ...              Run Keyword and Ignore Error    Add scout external execution id to the reporting portal

CB008238-5G-W_4_Single_UE_Ping_latency_Check_SA_mode
    [Documentation]   This TC checks whether ping latency is not degraded, when CB008238 is turned on.
    [Tags]   CDRT
    ...      SBTS22R4
    CB008238-5G-W_4_Single_UE_Ping_latency_Check_SA_mode
    [Teardown]   Run Keywords
    ...          TC_teardown_W                AND
    ...              Run Keyword and Ignore Error    Add scout external execution id to the reporting portal
