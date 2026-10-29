*** Settings ***
Documentation      CRT regression TCs for CB008238 shall be added here for fully automated regression testing.

Resource           testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_CB008238/A/resources/keywords_8238_A.robot
Resource           testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_CB008238/B/resources/keywords_8238_B.robot
Resource           testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_CB008238/C/resources/keywords_8238_C.robot
Resource           testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_CB008238/D/resources/keywords_8238_D.robot
Resource           testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_CB008238/E/resources/keywords_8238_E.robot
Resource           testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_CB008238/F/resources/keywords_8238_F.robot
Resource           testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_CB008238/W/resources/keywords_8238_W.robot

Suite Setup        prepare_testline     custom_swconfig_flags=${swconfig_flags_8238_d}


*** Test Cases ***
CB008238_A_03_Single-UE_small_packet_timer_lower_than_dtxMaxRetentionDelay_on_NSA
    [Documentation]   This TC shall verify the optimized DTX algorithm when traffic interval is LOWER than dtxMaxRetentionDelay.
    CB008238_A_03_Single-UE_small_packet_timer_lower_than_dtxMaxRetentionDelay_on_NSA
    [Teardown]   TC_teardown_8238_A

CB008238_A_09_Single-UE_small_packet_timer_higher_than_dtxMaxRetentionDelay_on_NSA+SA (SA)
    [Documentation]   This TC shall verify the optimized DTX algorithm when traffic interval is HIGHER than dtxMaxRetentionDelay.
    CB008238_A_09_Single-UE_small_packet_timer_higher_than_dtxMaxRetentionDelay_on_NSA+SA (SA)
    [Teardown]   TC_teardown_8238_A

CB008238-5G-B_1_Single-UE_non_GBR_traffic_and_delay_sensitive_data_interaction_evaluation
    [Documentation]   This TC shall verify the interaction between optimized DTX and PdschAtSsbSlot.
    CB008238-5G-B_1_Single-UE_non_GBR_traffic_and_delay_sensitive_data_interaction_evaluation
    [Teardown]   TC_teardown_B_1

CB008238-5G-B_2_Multi-UE_SA_DTX_interactions_with_non_GBR_traffic
    [Documentation]   This TC shall verify optimized DTX for mutli UE scenario.
    CB008238-5G-B_2_Multi-UE_SA_DTX_interactions_with_non_GBR_traffic
    [Teardown]   TC_teardown_B_2

CB008238-5G-B_4_Multi-UE_interactions_with_delay_sensitive_data_(VoNR)
    [Documentation]   This TC shall verify optimized DTX for mutli UE scenario with VoNr data flow.
    CB008238-5G-B_4_Multi-UE_interactions_with_delay_sensitive_data_(VoNR)
    [Teardown]   TC_teardown_B_4

CB008238-5G-C_1_Single_UE_Data_Schedule_Exceed_dtxPrbThreshold_low_value_and_high_value
    [Documentation]   This TC verifies whether optimized DTX is turned off and on correctly when dtxPrbThreshold is exceeded.
    CB008238-5G-C_1_Single_UE_Data_Schedule_Exceed_dtxPrbThreshold_low_value_and_high_value
    [Teardown]   TC_teardown_C_1

CB008238-5G-C_6_Single_UE_Max_Throughput
    [Documentation]   This TC verifies whether feature CB008238-C doesn't negatively affect throughput.
    CB008238-5G-C_6_Single_UE_Max_Throughput
    [Teardown]   TC_teardown_C_6

CB008238-5G-D_01_DTX_Scheduler_Enabling_Disabling_Based_On_Ues_In_C1_List
    [Documentation]  This TC verifies whether csList is being modified.
    CB008238-5G-D_01_DTX_Scheduler_Enabling_Disabling_Based_On_Ues_In_C1_List
    [Teardown]  TC_teardown_D_1

CB008238-5G-E_1_Single_UE_CA_interaction_with_micro_DTX_optimized_scheduling_SA_mode_FDD_FDD
    [Documentation]  This TC checks whether CB008238 is turned on and off correctly, when SCell activates/deactivates.
    CB008238-5G-E_1_Single_UE_CA_interaction_with_micro_DTX_optimized_scheduling_SA_mode_FDD_FDD
    [Teardown]   TC_teardown_E

CB008238-5G-E_3_Single_UE_CA_interaction_with_micro_DTX_optimized_scheduling_for_SA_mode_for_blind_method_activation_FDD_FDD
    [Documentation]  This TC checks whether CB008238 is turned on and off correctly, when SCell activates/deactivates.
    CB008238-5G-E_3_Single_UE_CA_interaction_with_micro_DTX_optimized_scheduling_for_SA_mode_for_blind_method_activation_FDD_FDD
    [Teardown]   TC_teardown_E

CB008238-5G-F_4_Single-UE_conditional_buffering_based_on_the_delay_since_last_scheduling_with_counters_not_incremented_M55308C33000_M55308C33001_SA
    [Documentation]  This TC verifies whether delaySinceLastScheduled works correctly for tput ABOVE threshold.
    CB008238-5G-F_4
    [Teardown]   TC_teardown_F_4

CB008238-5G-F_7_Single-UE_conditional_buffering_based_on_the_delay_since_last_scheduling_with_counters_incremented_M55308C33000_5308C33001_SA
    [Documentation]  This TC verifies whether delaySinceLastScheduled works correctly for tput BELOW threshold.
    CB008238-5G-F_7
    [Teardown]   TC_teardown_F_7

CB008238-5G-W_4_Single_UE_Ping_latency_Check_SA_mode
    [Documentation]   This TC checks whether ping latency is not degraded, when CB008238 is turned on.
    CB008238-5G-W_4_Single_UE_Ping_latency_Check_SA_mode
    [Teardown]   TC_teardown_W
