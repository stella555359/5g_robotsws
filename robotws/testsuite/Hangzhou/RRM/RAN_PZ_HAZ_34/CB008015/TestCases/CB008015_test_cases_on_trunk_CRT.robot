*** Settings ***
Force Tags            5G_RAN_TDD    master_classicalbts_all
...    PY310
...           CIT    5G_RAN    SBTS00    RAN_5G    RAN_5G_TDD    TOOLS_PROFILE_5G_TTI
Documentation      Author: xiangyue.zhou@nokia-sbell.com
Suite Setup        Suite Setup For RFS On UTE Cloud
Suite Teardown    Suite TearDown For CB007737    is_need_enable_uboot=${True}
Resource     ../../CB008015/Resources/CB008015_case_steps.robot
Resource    ../../CB007737/Resources/CB007737_Case_Step.robot
Resource    ../../CB009058/Resources/CB009058_Case_Step.robot
Resource    ../../CB009109/Resources/CB009109_Case_Step.robot
Resource    ../../CB007538/Resources/CB007538_Case_Step.robot

*** Variables ***
@{swconfig_enable_cprt_log}    0x590072=1    0x41001b=1    0x5901C4=1    0x420068=2
@{cell_ld_list}    3    14    15
${fdd_pcell_index}             ${1}
${tdd_pcell_index}             ${3}
${mobility_fdd_pcell_index}    ${2}


*** Test Cases ***
#[1]CB008015_A_23_Online_modification_of_parameter_a1ThresholdSCellAddSsbRsrpTDD_and_a1ThresholdSCellAddSsbRsrpFDD
#    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
#    ...                  CA: PCELL FDD, FDD DSS ratio: 70%, PRB blanking enabled
#    ...                  position A: pcell rsrp above a1threshold TDD
#    ...                  position B: pcell rsrp between a1threshold TDD and FDD
#    ...                  position C: pcell rsrp below a1threshold FDD.
#    ...                  scell sort list: cell3 > cell4 > cell0+2 > cell2 > cell0
#    ...                  Check no Scell change from FDD 3CC(postiion B) to new position(modify a1threshold TDD) via adjust PA.
#    [Timeout]    120m
#    [Setup]    8015 Case SetUp    pcell_index=${fdd_pcell_index}
#    CB008015_A_23_Online_modification_of_parameter_a1ThresholdSCellAddSsbRsrpTDD    pcell_index=${fdd_pcell_index}
#    [Teardown]    8015 Case TearDown

[1]CB008015_B_03_SCell_selection_based_on_weighted_SCell_bandwidth_and_cell_load_for_SA_call
    [Documentation]    Author:lei.jia@nokia-sbell.com
    ...                  CA: pcell tdd, FDD DSS ratio: 70%, PRB blanking enabled
    ...                  for T+T CA, UL layer2. for T+F CA, UL layer1
    ...                  position A: pcell rsrp above a1threshold TDD
    ...                  position B: pcell rsrp between a1threshold TDD and FDD
    ...                  position C: pcell rsrp below a1threshold FDD.
    ...                  make cell2 in high load, the new scell sort list is (cell 4> cell1 > cell0)
    ...                  in postion A, check peak tput for T + T(for T+T, UL tput will not check) and T + F CA(UL TPUT should be checked)
    ...                  in position B, T + F CA. in position C, no scell selection.
    [Timeout]    120m
    [Setup]    8015 Case SetUp    pcell_index=${tdd_pcell_index}
    CB008015_B_03_SCell_selection_based_on_weighted_SCell_bandwidth_and_cell_load_for_SA_call_of_T_F_CA    pcell_index=${tdd_pcell_index}
    [Teardown]    8015 Case TearDown
#
#[1]CB008015_B_05_A1_measurement_of_PCell_based_SCell_change_for_SA_call_with_different_value_for_a1Thresholdscelladdssbrsrp_of_TDD_and_FDD
#    [Documentation]    Author:lei.jia@nokia-sbell.com
#    ...                  CA: pcell tdd, FDD DSS ratio: 70%, PRB blanking enabled
#    ...                  for T+T CA, UL layer2 ul peak not care. for T+F CA, UL layer1 ul peak should be chedked
#    ...                  position A: pcell rsrp above a1threshold TDD
#    ...                  position B: pcell rsrp between a1threshold TDD and FDD
#    ...                  position C: pcell rsrp below a1threshold FDD.
#    ...                  scell sort list: (cell 4> cell2> cell1 > cell0)
#    ...                  scell change from position B(T+F)(UL TPUT should be checked) CA to postion A(T+T)(for T+T, UL tput will not check)
#    [Tags]     CRT_TRUNK    CDRT_22R3    CDRT_22R4    CDRT_23R1    CDRT_23R2    CRT_23R1    CRT_23R3
#    [Setup]    8015 Case SetUp    pcell_index=${tdd_pcell_index}
#    CB008015_B_05_A1_measurement_of_PCell_based_SCell_change_from_FDD_to_TDD_of_T_F_CA    pcell_index=${tdd_pcell_index}
#    [Teardown]    8015 Case TearDown

#[1]CB008015_C_01_Mobility_based_on_rsrp_involving_two_TDD_cells_with_same_coverage_SA
#    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
#    ...                  CA: original pcell Fdd, after a1 pcell switch pcell TDD.
#    ...                  FDD DSS ratio: 70%, PRB blanking enabled
#    ...                  position A: pcell rsrp above a1threshold TDD
#    ...                  position B: pcell rsrp between a1threshold TDD and FDD
#    ...                  position C: pcell rsrp below a1threshold FDD.
#    ...                  for pcell FDD, scell sort list: cell3 > cell4 > cell0+1 > cell1 > cell0
#    ...                  after a1 pcell switch, for pcell TDD, scell sort list: (cell 4> cell2> cell1 > cell0)
#    ...                  Check A1 based Pcell switch,F(pcell: cell2)+T(scell: cell3) -> T(pcell: cell3)+T(scell: cell4)
#    ...                  Pcell change based on A1, decrease scell PA to trigger (scell rsrp larger than a1ThresholdPCellSwitchSsbRsrp)
##    [Tags]     CIT_22R1    CIT_22R2   CIT_TRUNK
#    [Setup]    8015 Case SetUp    pcell_index=${mobility_fdd_pcell_index}    is_commission=True    AEHC_PA_value=20
#    CB008015_C_01_Mobility_based_on_rsrp_involving_two_TDD_cells_with_same_coverage_SA    pcell_index=${mobility_fdd_pcell_index}
#    ...    new_pcell_index=${tdd_pcell_index}
#    [Teardown]    8015 Case TearDown

[1]CB007538-A_001_Monitoring_of_the_PCMD-content_related_to_Cell_specific_CSI-RS_UE_measurements_from_SA_UE_using_beamforming
    [Tags]    Classical    CIT_TRUNK
    [Timeout]    90m
    [Setup]  Case SetUp For DSS On UTE CLoud
    CB007538-A_001_Monitoring_of_the_PCMD-content_related_to_Cell_specific_CSI-RS_UE_measurements_from_SA_UE_using_beamforming
    ...                                                                                                       pcell_index=${tdd_pcell_index}
    [Teardown]   8015 Case TearDown

#[1]CB008015_D_07_FDD_Cell_lock_with_graceful_cell_shutdown_for_SA_call_when_locked_cell_with_A1_based_scell_addition_and_cell_edge_Ues
#    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
#    ...                  CA:pcell Fdd(cell1), FDD DSS ratio: 70%, PRB blanking enabled
#    ...                  Scell sort list: cell3 > cell4 > cell0+2 > cell2 > cell0
#    ...                  Check Scell release via scell graceful shutdown(cell0) at cell edge with FDD 3CC(postiion B) to FDD 2CC(postiion B f1+f2).
#    ...                  position A: pcell rsrp above a1threshold TDD
#    ...                  position B: pcell rsrp between a1threshold TDD and FDD
#    ...                  position C: pcell rsrp below a1threshold FDD.
#    ...                  vara shutdownStepAmount =10, the cell power is reduced by 3 db for each step, 3db * 10(shutdownStepAmount) = 30db
#    ...                  shutdownWindow=60 indicated that the whole cell shutdown operation is 60sec, thus capture scell0 release cpif 100sec.
#    ...                  scell in cell edge: (scell rsrp) - (scell_with_shutdwon_pa_upddate_value) - 30dB <  a2ThresholdSCellRelSsbRsrp(cell0)
#    [Timeout]    120m
#    [Setup]    8015 Case SetUp    pcell_index=${fdd_pcell_index}
#    CB008015_D_07_FDD_Cell_lock_with_graceful_cell_shutdown_for_SA_call_when_locked_cell_with_A1_based_scell_addition_and_cell_edge_Ues
#    ...                           pcell_index=${fdd_pcell_index}
#    [Teardown]    8015 Case TearDown

#[1]CB008015_C_03_Mobility_based_on_rsrp_involving_one_TDD_cell_SA
#    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
#    ...                  CA: based on A2 pcell change,FDD DSS ratio: 70%, PRB blanking enabled
#    ...                  position A: pcell rsrp above a1threshold TDD
#    ...                  position B: pcell rsrp between a1threshold TDD and FDD
#    ...                  position C: pcell rsrp below a1threshold FDD.
#    ...                  original pcell TDD, scell sort list: cell2(F)>cell4(T)>cell1(F)>cell0(F)
#    ...                  after a2 pcell change, scell sort list is cell3 > cell4 > cell0+1 > cell1 > cell0
#    ...                  Check Pcell Change,T(pcell)+F(scell) --> F(pcell)+T(scell)(scell selection based on sortlist)
#    ...                  Pcell change based on A2, increase pcell PA to trigger (make pcell rsrp lower than a2ThresholdPCellSwitchSsbRsrp)
#    [Timeout]    120m
#    [Setup]    8015 Case SetUp    pcell_index=${tdd_pcell_index}    scf_name=SCF_CB008015_C.xml    is_commission=True
#    CB008015_C_03_Mobility_based_on_rsrp_involving_one_TDD_cell_SA    pcell_index=${tdd_pcell_index}    new_pcell_index=${mobility_fdd_pcell_index}
#    [Teardown]    8015 Case TearDown

#[1]CB007737_A_02_two_FDD_cells_mapping_on_the_same_core_of_one_L2RT_instance_without_CA_relationship_ABIO
#    [Timeout]    120m
#    [Setup]    Case SetUp For NR Only on UTE CLoud    is_get_same_core_infor=${False}
#    CB007737_A_02_two_FDD_cells_mapping_on_the_same_core_of_one_L2RT_instance_without_CA_relationship_ABIO    pcell_index=${fdd_pcell_index}
#    [Teardown]   Case TearDown For CB007737

#[1]CB009531_A1_02_DRX_Retransmission_timer_support_in_DL_and_UL_for_non_VoNR_TDD_HarqRtt
#    [Timeout]    120m
#    [Setup]  Case SetUp For DSS On UTE CLoud    scf_file_name=SCF_${stream}
#    CB009531_A1_02_DRX_Retransmission_timer_support_in_DL_and_UL_for_non_VoNR_TDD_HarqRtt    pcell_index=${tdd_pcell_index}
#    [Teardown]   Case TearDown For CB007737

[1]CB009531_A2_09_DRX_Retransmission_timer_support_in_DL_and_UL_for_VoNR_TDD
    [Timeout]    120m
    [Setup]  Case SetUp For DSS On UTE CLoud    scf_file_name=Configuration_VONR_${stream}
    CB009531_A2_09_DRX_Retransmission_timer_support_in_DL_and_UL_for_VoNR_TDD    pcell_index=${tdd_pcell_index}
    [Teardown]   Case TearDown For CB007737

#[1]CB009531_PDL_Removel_csiReportPeriodicity_Out_of_OndurationTime
#    [Timeout]    120m
#    [Setup]  Case SetUp For DSS On UTE CLoud    scf_file_name=Configuration_9531_CSIREPORT_${stream}
#    CB009531_PDL_Removel_csiReportPeriodicity_Out_of_OndurationTime    pcell_index=${tdd_pcell_index}
#    [Teardown]   Case TearDown For CB007737

#[1]CB007737_A_07_two_FDD_cells_mapping_on_the_same_core_of_one_L2RT_instance_with_CA_relationship_ABIO_after_lock_unlock_cell
#    [Timeout]    120m
#    [Setup]    Case SetUp For NR Only on UTE CLoud    is_get_same_core_infor=${True}
#    CB007737_A_07_two_FDD_cells_mapping_on_the_same_core_of_one_L2RT_instance_with_CA_relationship_ABIO_after_lock_unlock_cell
#    ...                                                                                                     pcell_index=${fdd_pcell_index}
#    [Teardown]   Case TearDown For CB007737

#[1]CB007737_A_10_mix intra_core_and_inter_core_CA_relationship_on_ABIO
#    [Documentation]    For this case on TL307, as cell interfere with each other, tput will be 0.
#    [Timeout]    90m
#    [Setup]    Case SetUp For NR Only on UTE CLoud
#    CB007737_A_10_mix intra_core_and_inter_core_CA_relationship_on_ABIO    pcell_index=${fdd_pcell_index}
#    [Teardown]   Case TearDown For CB007737

#[1]CB009058_B_01_three_TDD_cells_each_L2_subpool_one_cell_on_half_ABIO
#    [Timeout]    120m
#    [Setup]  Case SetUp For NR Only on UTE CLoud    scf_file_name=Configuration_CB009058    swconfig_modify=${swconfig_enable_cprt_log}
#    CB009058_B_01_three_TDD_cells_each_L2_subpool_one_cell_on_half_ABIO    pcell_index=${tdd_pcell_index}
#    [Teardown]   Case TearDown For CB007737    is_recover_swconfig=${True}
#
#[1]CB009109_A_09_Modify_default_assiciated_DRXDN_followed_by_SA_call_with_nonGBR_DRX_Bearer
#    [Timeout]    120m
#    [Setup]  Case SetUp For NR Only on UTE CLoud    scf_file_name=Configuration_CB009109
#    CB009109_A_09_Modify_default_assiciated_DRXDN_followed_by_SA_call_with_nonGBR_DRX_Bearer    pcell_index=${tdd_pcell_index}
#    [Teardown]   Case TearDown For CB007737
#
#[1]CB009109_B_02_SA_non-VONR_call_setup_when_feature_deactivate_then_activate_feature_and_setup_VoNR_Bearer
#    [Timeout]    180m
#    [Setup]  Case SetUp For NR Only on UTE CLoud    scf_file_name=Configuration_CB009109_B
#    CB009109_B_02_SA_non-VONR_call_setup_when_feature_deactivate_then_activate_feature_and_setup_VoNR_Bearer    pcell_index=${tdd_pcell_index}
#    [Teardown]   Case TearDown For CB007737
#
#[1]CB009109_B_05_SA_VONR_call_setup_with_VoNR_Bearer_5QI-1_with_cell_level_associated_lower_priority_DRX
#    [Timeout]    120m
#    [Setup]  Case SetUp For NR Only on UTE CLoud    scf_file_name=Configuration_CB009109_B_5
#    CB009109_B_05_SA_VONR_call_setup_with_VoNR_Bearer_5QI-1_with_cell_level_associated_lower_priority_DRX    pcell_index=${tdd_pcell_index}
#    [Teardown]   Case TearDown For CB007737
#
#[1]CB009109_B_10_SA_inter_frequency_ANR_HO_with_parameter_fallback
#    [Timeout]    120m
#    [Setup]  Case SetUp For NR Only on UTE CLoud    scf_file_name=Configuration_CB009109_B_10
#    CB009109_B_10_SA_inter_frequency_ANR_HO_with_parameter_fallback    pcell_index=${tdd_pcell_index}
#    [Teardown]   Run keywords     gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    value=20   RU_id=3
#    ...     AND    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    value=20   RU_id=4
#    ...     AND    Case TearDown For CB007737
