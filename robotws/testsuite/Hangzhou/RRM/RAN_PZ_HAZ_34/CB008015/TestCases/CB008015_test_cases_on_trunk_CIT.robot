*** Settings ***
Force Tags            5G_RAN_TDD    master_classicalbts_all
...    PY310
...           CIT    5G_RAN    SBTS00    RAN_5G    RAN_5G_TDD    TOOLS_PROFILE_5G_TTI
Documentation      Author: xiangyue.zhou@nokia-sbell.com
Suite Setup        Suite Setup For RFS On UTE Cloud
Suite Teardown    Suite TearDown For CB007737    is_need_enable_uboot=${True}
Resource     ../../CB008015/Resources/CB008015_case_steps.robot
Resource    ../../CB007737/Resources/CB007737_Case_Step.robot
Resource    ../../CB007538/Resources/CB007538_Case_Step.robot
Resource    ../../CB009109/Resources/CB009109_Case_Step.robot

*** Variables ***
${fdd_pcell_index}             ${1}
${tdd_pcell_index}             ${3}
${mobility_fdd_pcell_index}    ${2}

*** Test Cases ***
#[1]CB008015_B_02_SCell_selection_based_on_weighted_SCell_bandwidth_for_SA_call
#    [Documentation]    Author:lei.jia@nokia-sbell.com
#    ...                  CA: PCELL TDD, FDD DSS ratio: 70%, PRB blanking enabled
#    ...                  for T+T CA, UL layer2 no need to check ul peak. for T+F CA, UL layer1 ul peak need to check
#    ...                  position A: pcell rsrp above a1threshold TDD
#    ...                  position B: pcell rsrp between a1threshold TDD and FDD
#    ...                  position C: pcell rsrp below a1threshold FDD.
#    ...                  scell selection based on weighted scell bandwidth in postion A&B&C
#    ...                  SCELL sort list: cell 4> cell2> cell1 > cell0
#    ...                  in postion A, check peak tput for T + T(for T+T, UL tput will not check) and T + F CA(UL TPUT should be checked)
#    ...                  in position B, T + F CA. in position C, no scell selection.
#    [Timeout]    120m
#    [Setup]    8015 Case SetUp    pcell_index=${tdd_pcell_index}
#    CB008015_B_02_SCell_selection_based_on_weighted_SCell_bandwidth_for_SA_call_of_T_F_CA    pcell_index=${tdd_pcell_index}
#    [Teardown]    run keywords    run keyword and ignore error    Perfrom Scell Unlock    AND    8015 Case TearDown
#
#[1]CB008015_A_15_A1_measurement_of_PCell_based_SCell_change_for_SA_call_RSRP_for_mixed_mode_of_F_F_and_F_T_CA
#    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
#    ...                  CA: pcell FDD, FDD DSS ratio: 70%, PRB blanking enabled
#    ...                  position A: pcell rsrp above a1threshold TDD
#    ...                  position B: pcell rsrp between a1threshold TDD and FDD
#    ...                  position C: pcell rsrp below a1threshold FDD.
#    ...                  Scell sort list: cell3 > cell4 > cell0+2 > cell2 > cell0
#    ...                  Check Scell change from FDD 3CC(postiion B) to F + T(position A) via adjust PA.
#    [Timeout]    120m
#    [Setup]    8015 Case SetUp    pcell_index=${fdd_pcell_index}    AEHC_PA_value=20
#    CB008015_A_15_A1_measurement_of_PCell_based_SCell_change_for_SA_call_RSRP_for_mixed_mode_of_F_F_and_F_T_CA    pcell_index=${fdd_pcell_index}
#    [Teardown]    8015 Case TearDown

[1]CB008015_C_01_Mobility_based_on_rsrp_involving_two_TDD_cells_with_same_coverage_SA
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    ...                  CA: original pcell Fdd, after a1 pcell switch pcell TDD.
    ...                  FDD DSS ratio: 70%, PRB blanking enabled
    ...                  position A: pcell rsrp above a1threshold TDD
    ...                  position B: pcell rsrp between a1threshold TDD and FDD
    ...                  position C: pcell rsrp below a1threshold FDD.
    ...                  for pcell FDD, scell sort list: cell3 > cell4 > cell0+1 > cell1 > cell0
    ...                  after a1 pcell switch, for pcell TDD, scell sort list: (cell 4> cell2> cell1 > cell0)
    ...                  Check A1 based Pcell switch,F(pcell: cell2)+T(scell: cell3) -> T(pcell: cell3)+T(scell: cell4)
    ...                  Pcell change based on A1, decrease scell PA to trigger (scell rsrp larger than a1ThresholdPCellSwitchSsbRsrp)
#    [Tags]     CIT_22R1    CIT_22R2   CIT_TRUNK
    [Setup]    8015 Case SetUp    pcell_index=${mobility_fdd_pcell_index}    is_commission=True    AEHC_PA_value=20
    CB008015_C_01_Mobility_based_on_rsrp_involving_two_TDD_cells_with_same_coverage_SA    pcell_index=${mobility_fdd_pcell_index}
    ...    new_pcell_index=${tdd_pcell_index}
    [Teardown]    8015 Case TearDown

#[1]CB007538-A_001_Monitoring_of_the_PCMD-content_related_to_Cell_specific_CSI-RS_UE_measurements_from_SA_UE_using_beamforming
#    [Tags]    Classical    CIT_TRUNK
#    [Timeout]    90m
#    [Setup]  Case SetUp For DSS On UTE CLoud
#    CB007538-A_001_Monitoring_of_the_PCMD-content_related_to_Cell_specific_CSI-RS_UE_measurements_from_SA_UE_using_beamforming
#    ...                                                                                                       pcell_index=${tdd_pcell_index}
#    [Teardown]   8015 Case TearDown
#
#[1]CB009109_A_09_Modify_default_assiciated_DRXDN_followed_by_SA_call_with_nonGBR_DRX_Bearer
#    [Timeout]    120m
#    [Setup]  Case SetUp For NR Only on UTE CLoud    scf_file_name=Configuration_CB009109
#    CB009109_A_09_Modify_default_assiciated_DRXDN_followed_by_SA_call_with_nonGBR_DRX_Bearer    pcell_index=${tdd_pcell_index}
#    [Teardown]   Case TearDown For CB007737

#[1]CB007737_A_06_two_FDD_cells_mapping_on_the_same_core_of_one_L2RT_instance_with_CA_relationship_ABIO
#    [Timeout]    120m
#    [Setup]    Case SetUp For NR Only on UTE CLoud
#    CB007737_A_06_two_FDD_cells_mapping_on_the_same_core_of_one_L2RT_instance_with_CA_relationship_ABIO    pcell_index=${fdd_pcell_index}
#    [Teardown]   Case TearDown For CB007737
