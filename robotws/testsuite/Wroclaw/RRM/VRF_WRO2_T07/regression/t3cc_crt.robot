*** Settings ***
Documentation   CRT regression

Force Tags    CA_5G_RRM   STATE_SW_UPLOADED   RAN_5G   RAN_5G_TDD   RAN_5G_TDD_MP   RAN_5G_MP
...           CRT   PY36   CLOUD_5G_CLASSICAL_SA_MEDIATEK_ASILL_ABIOB1B2B3_AWHTA_AHFIC_AZHL_AZQO
...           SBTS22R4   SBTS00


Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_5GC007949/TestCases_7949.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB008053/TestCases_CB008053.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB009333/resources/keywords_9333.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/reports/reporting_portal.robot

Test Teardown     Add scout external execution id to the reporting portal

*** Test Cases ***
CB007949_A_08_Single_UE_max_Tput_with_TDD_3CC_with_different_bandwidth_and_RLQ_based_deactivation
    [Documentation]  This TC covers max throughput via 3CC feature and deactivation of SCell via RLQ
    ...              and checks if after activation CA is established and running
    ...              Cell:               pCell   sCell1  sCell2
    ...              Bandwidths:         40MHz   60MHz   40MHz
    ...              Bands:              N41     N41     n77
    ...              Cells MO:           1       2       3
    ...              Cells PhyCellID:    101     102     103
    ...              Channels:           9-12    9-12    1-4
    CB007949_A_08_Single_UE_max_Tput_with_TDD_3CC_with_different_bandwidth_and_RLQ_based_deactivation
    [Teardown]  Run Keywords
    ...        Add scout external execution id to the reporting portal

CB007949_A_11_Buffer_based_SCell_activation_TDD_2CC_DL_CA_BF_different_frame_structure_1116_0ms_1208
    [Documentation]  This TC covers activation of 2CC within scope of 3CC feature
    ...              Cell:               pCell   sCell1
    ...              Bandwidths:         40MHz   60MHz
    ...              Bands:              N79     N41
    ...              Cells MO:           0       2
    ...              Cells PhyCellID:    100     102
    ...              Channels:           13-16   9-12
    CB007949_A_11_Buffer_based_SCell_activation_TDD_2CC_DL_CA_BF_different_frame_structure_1116_0ms_1208
    [Teardown]  Run Keywords
     ...        Add scout external execution id to the reporting portal

CB007949_B_13_Inter_gNB_HO_to_non_CA_Cell_and_return
    [Documentation]  This TC covers pcell change from 3CC, to cell without CA and return
    ...              Cell:               pCell   sCell1  sCell2  -  cell
    ...              Bandwidths:         60MHz   40MHz   60MHz   -  40Mhz
    ...              Bands:              N41     N41     N77     -  N79
    ...              Cells MO:           1       2       3       -  7
    ...              Cells PhyCellID:    101     102     103     -  107
    ...              Channels:           9-12    9-12    1-4     -  13-16
    CB007949_B_13_Inter_gNB_HO_to_non_CA_Cell_and_return
    [Teardown]  Run Keywords
     ...        Add scout external execution id to the reporting portal

CB007949_D_01_TDD_FR1_DL_3CC_CA_interworking_with_5GC002200_For_Rel15_UE
    [Documentation]  This TC covers interaction with 8x4 Closed Loop Spatial Multiplexing feature enabled
    ...              Cell:               pCell   sCell1  sCell2
    ...              Bandwidths:         40MHz   60MHz   40MHz
    ...              Bands:              N41     N41     n77
    ...              Cells MO:           1       2       3
    ...              Cells PhyCellID:    101     102     103
    ...              Channels:           9-12    9-12    1-4
    CB007949_D_01_TDD_FR1_DL_3CC_CA_interworking_with_5GC002200_For_Rel15_UE
    [Teardown]  Run Keywords
     ...        Add scout external execution id to the reporting portal

CB007949_D_02_VoNR_with_and_without_DRX_3CC_TDD_DL_CA_HO
    [Documentation]  This TC covers VoNR with DRX enabled with handover to different set of 3CC cells.
    ...              Cell:               pCell   sCell1  sCell2  -  pCell   sCell1  sCell2
    ...              Bandwidths:         60MHz   40MHz   60MHz   -  60MHz   60MHz   40MHz
    ...              Bands:              N41     N41     N77     -  N77     N79     N79
    ...              Cells MO:           1       2       3       -  3       4       0
    ...              Cells PhyCellID:    101     102     103     -  103     104     100
    ...              Channels:           9-12    9-12    1-4     -  1-4     13-16   13-16
    CB007949_D_02_VoNR_with_and_without_DRX_3CC_TDD_DL_CA_HO
    [Teardown]  Run Keywords
     ...        Add scout external execution id to the reporting portal

CB007949_E_01_TDD_3CC_DL_CA_pCSI_bundling_applied_to_all_cells_SCell_released
    [Documentation]  This TC covers 3CC interaction with pCSI bundling
    ...              Cell:               pCell   sCell1  sCell2
    ...              Bandwidths:         40MHz   60MHz   40MHz
    ...              Bands:              N41     N41     n77
    ...              Cells MO:           1       2       3
    ...              Cells PhyCellID:    101     102     103
    ...              Channels:           9-12    9-12    1-4
    CB007949_E_01_TDD_3CC_DL_CA_pCSI_bundling_applied_to_all_cells_SCell_released
    [Teardown]  Run Keywords
     ...        Add scout external execution id to the reporting portal

CB009333_C_3_Single_UE_CA_interaction_with_micro_DTX_optimized_scheduling_enabled_on_SCell_FDD_TDD_SA_Buffer_based_SCell_activation_method_3CC
    [Documentation]   This Test Case describes expected Nokia gNB behaviour with FDD-TDD
     ...              interaction (with buffer based SCell activation method) and micro DTX optimized scheduling
     ...              enabled on SCell in FDD-TDD SA configuration.
     ...              Cells - 2, 5, 6           T, F, F
     ...              Others cells - blocked
    CB009333_C_3_Single_UE_CA_interaction_with_micro_DTX_optimized_scheduling_enabled_on_SCell_FDD_TDD_SA_Buffer_based_SCell_activation_method_3CC
    [Teardown]  Run Keywords
     ...        Add scout external execution id to the reporting portal

CB009333_C_6_Single_UE_CA_interaction_with_micro_DTX_optimized_scheduling_enabled_on_PCell_FDD_TDD_SA_Buffer_based_Scell_activation_method_3CC
    [Documentation]   This Test Case describes expected Nokia gNB behaviour with TDD-FDD 3CC interaction and micro DTX
     ...              optimized scheduling enabled on PCell in FDD-TDD SA configuration with buffer
     ...              based SCell activation method.
     ...              Cells - 2, 5, 6           T, F, F
     ...              Other cells - blocked
    CB009333_C_6_Single_UE_CA_interaction_with_micro_DTX_optimized_scheduling_enabled_on_PCell_FDD_TDD_SA_Buffer_based_Scell_activation_method_3CC
    [Teardown]  Run Keywords
     ...        Add scout external execution id to the reporting portal

CB008053_02_A1_based_SCell_addition_mix_inter&intra_L2RT_BF_different_frame_structure
    [Documentation]  This test case verifies the successful >>TDD FR1 DL CA up to 4CC<< feature activation
    ...              with SCell Addition set to >>covBasedA1<< for all NREL objects of all cells
    ...              where gNB performs SCell selection for 4CC TDD FR1 CA with PCell as TDD in SA mode.
    ...              Cell:               pCell   sCell1  sCell2   sCEll3
    ...              Bandwidths:         40MHz   40MHz   60MHz    5MHZ
    ...              SBands:              N41     N41     N77      N66
    ...              Cells MO:           1       2       3        5
    ...              Cells PhyCellID:    101     102     103      105
    ...              Channels:           9-12    9-12    1-4      17-20
    CB008053_02_A1_based_SCell_addition_mix_inter&intra_L2RT_BF_different_frame_structure
    [Teardown]  Run Keywords
     ...        Add scout external execution id to the reporting portal

CB008053_14_Pcell_Lock_Unlock_and_HO
    [Documentation]  The purpose of this Test Case is to check if Cell Block/Unblock procedure is working
    ...              and UE can be attached after cell unblocking, and check HO.
    ...              Cell:               pCell   sCell1  sCell2   sCEll3
    ...              Bandwidths:         40MHz   40MHz   60MHz    5MHZ
    ...              Bands:              N41     N41     N77      N66
    ...              Cells MO:           1       2       3        5
    ...              Cells PhyCellID:    101     102     103      105
    ...              Channels:           9-12    9-12    1-4      17-20
    CB008053_14_Pcell_Lock_Unlock_and_HO
    [Teardown]  Run Keywords
     ...        Add scout external execution id to the reporting portal

CB008053_03_Feature_deactivation_4CC_A2 SCell_Release_BF_beamRefinement_different_frame_structure_RSRP
    [Documentation]  The purpose of this Test Case is to check successful disabling 3TDD+1FDD DL CA
    ...              by gNB reconfiguration and SCell Release based on A2 measurement
    ...              Cell:               pCell   sCell1  sCell2  sCell3
    ...              Bandwidths:         40MHz   60MHz   60MHz   5MHz
    ...              Bands:              N41     n77     n77     n66
    ...              Cells MO:           1       3       4       5
    ...              Cells PhyCellID:    101     103     104     105
    ...              Channels:           9-12    1-4     1-4     17-20
    CB008053_03_Feature_deactivation_4CC_A2 SCell_Release_BF_beamRefinement_different_frame_structure_RSRP
    [Teardown]  Run Keywords
     ...        Add scout external execution id to the reporting portal

##### ##### ##### ##### LEGACY TESTS ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### ##### #####

#CB007949_A_01_Feature_activation_3CC_with_blind_SCell_addition_inter_L2RT_BF_same_frame_structure
#    [Documentation]  This TC covers basic activation of 3CC feature and checks if after activation CA is established
#    ...              Cell:               pCell   sCell1  sCell2
#    ...              Bandwidths:         40MHz   60MHz   40MHz
#    ...              Bands:              N41     N41     n77
#    ...              Cells MO:           1       2       3
#    ...              Cells PhyCellID:    101     102     103
#    ...              Channels:           9-12    9-12    1-4
#    CB007949_A_01_Feature_activation_3CC_with_blind_SCell_addition_inter_L2RT_BF_same_frame_structure
#
#CB007949_A_02_TDD_3CC_DL_CA_buffer_based_SCell_activation_and_deactivation_intra_L2RT_BF
#    [Documentation]  This TC covers activation of 3CC feature with buffer based SCell Activation
#    ...              and checks if after activation CA is established and running
#    ...              Cell:               pCell   sCell1  sCell2
#    ...              Bandwidths:         40MHz   60MHz   40MHz
#    ...              Bands:              N41     N41     n77
#    ...              Cells MO:           1       2       3
#    ...              Cells PhyCellID:    101     102     103
#    ...              Channels:           9-12    9-12    1-4
#    CB007949_A_02_TDD_3CC_DL_CA_buffer_based_SCell_activation_and_deactivation_intra_L2RT_BF
#
#CB007949_B_01_A1_Scell_Addition_and_A2_SCell_Release
#    [Documentation]  This TC covers buffer based SCell Addition and A2 SCell release
#    ...              Cell:               pCell   sCell1  sCell2
#    ...              Bandwidths:         40MHz   60MHz   40MHz
#    ...              Bands:              N41     N41     n77
#    ...              Cells MO:           1       2       3
#    ...              Cells PhyCellID:    101     102     103
#    ...              Channels:           9-12    9-12    1-4
#    CB007949_B_01_A1_Scell_Addition_and_A2_SCell_Release
#
#CB007949_B_04_PCell_Change_from_3CC_to_3CC
#    [Documentation]  This TC covers pcell change from 3CC, to another set of CA cells
#    ...              Cell:               pCell   sCell1  sCell2  -  pCell   sCell1  sCell2
#    ...              Bandwidths:         60MHz   40MHz   60MHz   -  60MHz   60MHz   40MHz
#    ...              Bands:              N41     N41     N77     -  N77     N79     N79
#    ...              Cells MO:           1       2       3       -  3       4       0
#    ...              Cells PhyCellID:    101     102     103     -  103     104     100
#    ...              Channels:           9-12    9-12    1-4     -  1-4     13-16   13-16
#    CB007949_B_04_PCell_Change_from_3CC_to_3CC
#
#CB007949_B_05_SCell_Change_3TDD_to_TDD_2FDD
#    [Documentation]  This TC covers pcell change from 3CC, to another set of CA cells: TDD+2FDD
#    ...              Cell:               pCell   sCell1  sCell2  -  pCell   sCell1  sCell2
#    ...              Bandwidths:         60MHz   40MHz   60MHz   -  60MHz   60MHz   40MHz
#    ...              Bands:              N41     N41     N77     -  N41     N25     N66
#    ...              Cells MO:           1       2       3       -  1/2     5       6
#    ...              Cells PhyCellID:    101     102     103     -  101/2   105     106
#    ...              Channels:           9-12    9-12    1-4     -  9-12    17-20   17-20
#    CB007949_B_05_SCell_Change_3TDD_to_TDD_2FDD
