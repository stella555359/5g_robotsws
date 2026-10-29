*** Settings ***
Documentation
...   author: Adrian Jakobik
...   contact: adrian.jakobik@nokia.com
...   This is the TESTSUITE file for feature CB009333


Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB009333/resources/keywords_9333.robot

Suite Setup      Run Keywords
...              testline_preparation.Prepare Testline        AND
...              Initialise Attenuator


*** Test Cases ***
CB009333_B_6_Multi_UE_interaction_with_micro_DTX_optimized_scheduling_enabled_on_Multiple_TDD_cell_on_Same_PA_SA_only
    [Documentation]   This Test Case describes expected Nokia gNB behavior and micro DTX optimized scheduling enabled
     ...              on multiple cells in TDD SA configuration.
    CB009333_B_6_Multi_UE_interaction_with_micro_DTX_optimized_scheduling_enabled_on_Multiple_TDD_cell_on_Same_PA_SA_only

CB009333_C_3_Single_UE_CA_interaction_with_micro_DTX_optimized_scheduling_enabled_on_SCell_FDD_TDD_SA_Buffer_based_SCell_activation_method_3CC
    [Documentation]   This Test Case describes expected Nokia gNB behaviour with FDD-TDD
     ...              interaction (with buffer based SCell activation method) and micro DTX optimized scheduling
     ...              enabled on SCell in FDD-TDD SA configuration.
    CB009333_C_3_Single_UE_CA_interaction_with_micro_DTX_optimized_scheduling_enabled_on_SCell_FDD_TDD_SA_Buffer_based_SCell_activation_method_3CC

CB009333_C_6_Single_UE_CA_interaction_with_micro_DTX_optimized_scheduling_enabled_on_PCell_FDD_TDD_SA_Buffer_based_Scell_activation_method_3CC
    [Documentation]   This Test Case describes expected Nokia gNB behaviour with TDD-FDD 3CC interaction and micro DTX
     ...              optimized scheduling enabled on PCell in FDD-TDD SA configuration with buffer
     ...              based SCell activation method.
    CB009333_C_6_Single_UE_CA_interaction_with_micro_DTX_optimized_scheduling_enabled_on_PCell_FDD_TDD_SA_Buffer_based_Scell_activation_method_3CC

CB009333_D_1_Micro-DTX_scheduler_with_DRX_configured
    [Documentation]   This Test Case describes expected Nokia gNB behaviour for UE with configured DRX is scheduled
     ...              during the DRX Active time
    CB009333_D_1_Micro-DTX_scheduler_with_DRX_configured

CB009333_F_1_RLC_status_PDU_for_UL_packets_scheduled_without_extra_delay_caused_by_micro-DTX_functionality_for_regulat_non-GBR_DL_data_FDD_SA
    [Documentation]   This Test Case describes expected Nokia gNB behaviour for RLC status PDU (for UL packets)
    ...               are scheduled on DL in the same manner as any delay-sensitive data in terms of
    ...               micro-DTX functionality. Scheduling of delay-sensitive data is not impacted.
    ...               Delay-sensitive data includes: SSBs, TRS, System Information including SIB1 (optional for NSA),
    ...               other SIBs (only for SA), paging – SA Case.
    CB009333_F_1_RLC_status_PDU_for_UL_packets_scheduled_without_extra_delay_caused_by_micro-DTX_functionality_for_regulat_non-GBR_DL_data_FDD_SA

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
