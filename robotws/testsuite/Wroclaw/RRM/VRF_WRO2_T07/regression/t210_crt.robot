*** Settings ***
Documentation   CRT regression

Force Tags    CA_5G_RRM   STATE_SW_UPLOADED   RAN_5G   RAN_5G_TDD   RAN_5G_TDD_MP   RAN_5G_MP
...           CRT   CLOUD_SRAN_ANDROID_SA_NSA_ASILR_ABIPR_ABIPR_3AZHM_AHEC_2AHLOA_UTECA
...           SBTS00


Library         testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB009142/resources/keywords_9142.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB009215/resources/keywords_9215.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/reports/reporting_portal.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB009333/resources/keywords_9333.robot



Suite Setup      Run keywords
...              Initialise Attenuator

Suite Teardown   sleep_well_tl

Test Teardown    Run Keyword and Ignore Error    Add scout external execution id to the reporting portal


*** Test Cases ***

CB009142_01_A_Supercell_with_6_subcells_activation_deactivation_with_VoNR_SA
    [Documentation]   The purpose of this TC is to verify Subercell 6 subcells activation/deactivation o full ABIP
        ...              and call in all sub-cells.
    CB009142_01_A_Supercell_with_6_subcells_activation_deactivation_with_VoNR_SA

CB009142_01_B_Supercell_with_6_subcells_activation_deactivation_with_VoNR_establishment_on_each_subcell_SA
    [Documentation]   The purpose of this TC is to verify Subercell 6 subcells activation/deactivation o full ABIP
        ...              and call in all sub-cells.
    CB009142_01_B_Supercell_with_6_subcells_activation_deactivation_with_VoNR_stablishment_on_each_subcell_SA

CB009142_02_2_supercells_with_2_and_4_subcells_inter_freq_handover_between_supercells_NSA
   [Documentation]   The purpose of this TC is to verify configuration of 2 supercells 2 and 4 subcells on full ABIP
    ...              and inter frequency handover between 2 supercells.
    CB009142_02_2_supercells_with_2_and_4_subcells_inter_freq_handover_between_supercells_NSA

CB009142_03_Supercell_with_3_subcells_handover_to_normal_cell_TDD_NSA
   [Documentation]   The purpose of this TC is to verify configuration of supercell 3 subcells on half ABIP
    ...              and handover between supercell and normal cell TDD.
    CB009142_03_Supercell_with_3_subcells_handover_to_normal_cell_TDD_NSA

CB009142_04_3_Supercells_with_2_subcells_handover_to_normal_cell_FDD_SA
   [Documentation]   The purpose of this TC is to verify configuration of 3 supercell 2 subcells on full ABIP
    ...              and handover between supercell and normal cell FDD.
    CB009142_04_3_Supercells_with_2_subcells_handover_to_normal_cell_FDD_SA

CB009215_01_Enhancement_for_GBR_Non-GBR_load_estimation
    [Documentation]   The purpose of this test case is to check DL inter-L1 PRB Pooling takes place
    ...               when 3 UEs perform traffic GBR and non GBR in two cells.
    CB009215_01_Enhancement_for_GBR_Non-GBR_load_estimation

CB009215_02_ShortBsrLimitAdaptation
    [Documentation]   The purpose of this test case is to check UL inter-L1 PRB Pooling takes place
    ...               when 3 UEs perform traffic GBR and non GBR in two cells.
    CB009215_02_ShortBsrLimitAdaptation

CNI_124437_CB009333_G_6_Micro_DTX_optimized_and_SIB&Pagin_Common_Search_Space_Optimatization_FDD_delay_param_depends_on_traffic
   [Documentation]     This Test Case describes behavior when dtxMaxRetentionDelay is set to 0 on one DRB.
   ...                 This Test Case describes also expected Nokia gNB behavior and micro DTX optimized scheduling
   ...                 interworking with CB009550 feature on FDD deployment with NSA UEs.
   CNI_124437_CB009333_G_6_Micro_DTX_optimized_and_SIB&Pagin_Common_Search_Space_Optimatization_FDD_delay_param_depends_on_traffic

CB009333_G_6_Multi_UE_micro_DTX_optimized_scheduling_and_SIB&Pagin_Common_Search_Space_Optimatization_FDD
   [Documentation]     This Test Case describes expected Nokia gNB behavior and micro DTX optimized scheduling
    ...                interworking with CB009550 feature on FDD deployment with SA UEs.
    CB009333_G_6_Multi_UE_micro_DTX_optimized_scheduling_and_SIB&Pagin_Common_Search_Space_Optimatization_FDD

CNI113672_CB009142_01_Supercell_with_6_subcells_activation_deactivation_with_VoNR_SA_EIRP_counters
    [Documentation]     The purpose of this TC is to verify Subercell 6 subcells activation/deactivation on full ABIP
        ...             and call in all sub-cells. This test verifies also EIRP counters before and after supercell activation.
    CNI113672_CB009142_01_Supercell_with_6_subcells_activation_deactivation_with_VoNR_SA_EIRP_counters

CNI113672_02_Supercells_with_2_and_4_subcells_switch_between_different_power_reduction_factor_eirp_counters
    [Documentation]     The purpose of this TC is to verify EIRP counters.
    ...                 with different power reduction factor configured on two subcells of supercell when UE is attached
    ...                 and throughput is active.
    CNI113672_02_Supercells_with_2_and_4_subcells_switch_between_different_power_reduction_factor_eirp_counters
