*** Settings ***
Force Tags    PY36
Documentation      Author: xiangyue.zhou@nokia-sbell.com
Suite Setup        8015 Suite Setup
Suite Teardown    8015 Suite Teardown
Resource     ../../CB008015/Resources/CB008015_case_steps.robot

*** Variables ***
${fdd_pcell_index}             ${1}
${tdd_pcell_index}             ${3}
${mobility_fdd_pcell_index}    ${2}

*** Test Cases ***
[1]CB008015_A_23_Online_modification_of_parameter_a1ThresholdSCellAddSsbRsrpTDD_and_a1ThresholdSCellAddSsbRsrpFDD
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    ...                  CA: PCELL FDD, FDD DSS ratio: 70%, PRB blanking enabled
    ...                  position A: pcell rsrp above a1threshold TDD
    ...                  position B: pcell rsrp between a1threshold TDD and FDD
    ...                  position C: pcell rsrp below a1threshold FDD.
    ...                  scell sort list: cell3 > cell4 > cell0+2 > cell2 > cell0
    ...                  Check no Scell change from FDD 3CC(postiion B) to new position(modify a1threshold TDD) via adjust PA.
    [Tags]     CRT_TRUNK    CRT_22R4    CRT_23R1
    [Setup]    8015 Case SetUp    pcell_index=${fdd_pcell_index}
    CB008015_A_23_Online_modification_of_parameter_a1ThresholdSCellAddSsbRsrpTDD    pcell_index=${fdd_pcell_index}
    [Teardown]    8015 Case TearDown

[1]CB008015_B_02_SCell_selection_based_on_weighted_SCell_bandwidth_for_SA_call
    [Documentation]    Author:lei.jia@nokia-sbell.com
    ...                  CA: PCELL TDD, FDD DSS ratio: 70%, PRB blanking enabled
    ...                  for T+T CA, UL layer2 no need to check ul peak. for T+F CA, UL layer1 ul peak need to check
    ...                  position A: pcell rsrp above a1threshold TDD
    ...                  position B: pcell rsrp between a1threshold TDD and FDD
    ...                  position C: pcell rsrp below a1threshold FDD.
    ...                  scell selection based on weighted scell bandwidth in postion A&B&C
    ...                  SCELL sort list: cell 4> cell2> cell1 > cell0
    ...                  in postion A, check peak tput for T + T(for T+T, UL tput will not check) and T + F CA(UL TPUT should be checked)
    ...                  in position B, T + F CA. in position C, no scell selection.
    [Tags]     CIT_TRUNK    CRT_22R3    CDRT_22R3    CDRT_22R4    CDRT_23R1    CRT_23R1    CIT_23R3
    [Setup]    8015 Case SetUp    pcell_index=${tdd_pcell_index}
    CB008015_B_02_SCell_selection_based_on_weighted_SCell_bandwidth_for_SA_call_of_T_F_CA    pcell_index=${tdd_pcell_index}
    [Teardown]    run keywords    run keyword and ignore error    Perfrom Scell Unlock    AND    8015 Case TearDown

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
    [Tags]     CRT_TRUNK    CRT_24R3    CRT_23R1    CRT_23R2    CRT_24R1    CRT_25R1
    [Setup]    8015 Case SetUp    pcell_index=${tdd_pcell_index}
    CB008015_B_03_SCell_selection_based_on_weighted_SCell_bandwidth_and_cell_load_for_SA_call_of_T_F_CA    pcell_index=${tdd_pcell_index}
    [Teardown]    8015 Case TearDown

[1]CB008015_A_15_A1_measurement_of_PCell_based_SCell_change_for_SA_call_RSRP_for_mixed_mode_of_F_F_and_F_T_CA
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    ...                  CA: pcell FDD, FDD DSS ratio: 70%, PRB blanking enabled
    ...                  position A: pcell rsrp above a1threshold TDD
    ...                  position B: pcell rsrp between a1threshold TDD and FDD
    ...                  position C: pcell rsrp below a1threshold FDD.
    ...                  Scell sort list: cell3 > cell4 > cell0+2 > cell2 > cell0
    ...                  Check Scell change from FDD 3CC(postiion B) to F + T(position A) via adjust PA.
    [Tags]     CIT_TRUNK    CRT_24R3    CRT_23R4    CRT_23R3    CIT_23R4    CDRT_23R3    CIT_24R1    CRT_24R2    CDRT_24R2    CIT_25R1
    [Setup]    8015 Case SetUp    pcell_index=${fdd_pcell_index}    AEHC_PA_value=10
    CB008015_A_15_A1_measurement_of_PCell_based_SCell_change_for_SA_call_RSRP_for_mixed_mode_of_F_F_and_F_T_CA    pcell_index=${fdd_pcell_index}
    [Teardown]    8015 Case TearDown

[1]CB008015_B_05_A1_measurement_of_PCell_based_SCell_change_for_SA_call_with_different_value_for_a1Thresholdscelladdssbrsrp_of_TDD_and_FDD
    [Documentation]    Author:lei.jia@nokia-sbell.com
    ...                  CA: pcell tdd, FDD DSS ratio: 70%, PRB blanking enabled
    ...                  for T+T CA, UL layer2 ul peak not care. for T+F CA, UL layer1 ul peak should be chedked
    ...                  position A: pcell rsrp above a1threshold TDD
    ...                  position B: pcell rsrp between a1threshold TDD and FDD
    ...                  position C: pcell rsrp below a1threshold FDD.
    ...                  scell sort list: (cell 4> cell2> cell1 > cell0)
    ...                  scell change from position B(T+F)(UL TPUT should be checked) CA to postion A(T+T)(for T+T, UL tput will not check)
    [Tags]     CRT_TRUNK    CDRT_22R3    CDRT_22R4    CDRT_23R1    CDRT_23R2    CRT_23R1    CRT_23R3    CRT_23R4    CRT_24R1    CRT_24R2
    [Setup]    8015 Case SetUp    pcell_index=${tdd_pcell_index}
    CB008015_B_05_A1_measurement_of_PCell_based_SCell_change_from_FDD_to_TDD_of_T_F_CA    pcell_index=${tdd_pcell_index}
    [Teardown]    8015 Case TearDown

[1]CB008015_D_06_FDD_Cell_lock_with_graceful_cell_shutdown_for_SA_call_when_locked_cell_with_A1_based_scell_addition_and_cell_center_Ues
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    ...                  CA:pcell TDD(cell3), T+F(UL peak TPUT should be checked)
    ...                  position A: pcell rsrp above a1threshold TDD
    ...                  position B: pcell rsrp between a1threshold TDD and FDD
    ...                  position C: pcell rsrp below a1threshold FDD.
    ...                  scell sort list: scell weight:cell2(F)>cell4(T)>cell1(F)>cell0(F),
    ...                  check bulk release via scell graceful shutdown at cell center with T + F(postiion A).
    ...                  FDD DSS ratio: 70%, PRB blanking enabled at cell center
    [Tags]
    [Setup]    8015 Case SetUp    pcell_index=${tdd_pcell_index}
    CB008015_D_06_FDD_Cell_lock_with_graceful_cell_shutdown_for_SA_call_with_A1_based_scell_addition_and_cell_center_Ues
    ...                           pcell_index=${tdd_pcell_index}
    [Teardown]    8015 Case TearDown

[1]CB008015_D_07_FDD_Cell_lock_with_graceful_cell_shutdown_for_SA_call_when_locked_cell_with_A1_based_scell_addition_and_cell_edge_Ues
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    ...                  CA:pcell Fdd(cell1), FDD DSS ratio: 70%, PRB blanking enabled
    ...                  Scell sort list: cell3 > cell4 > cell0+2 > cell2 > cell0
    ...                  Check Scell release via scell graceful shutdown(cell0) at cell edge with FDD 3CC(postiion B) to FDD 2CC(postiion B f1+f2).
    ...                  position A: pcell rsrp above a1threshold TDD
    ...                  position B: pcell rsrp between a1threshold TDD and FDD
    ...                  position C: pcell rsrp below a1threshold FDD.
    ...                  vara shutdownStepAmount =10, the cell power is reduced by 3 db for each step, 3db * 10(shutdownStepAmount) = 30db
    ...                  shutdownWindow=60 indicated that the whole cell shutdown operation is 60sec, thus capture scell0 release cpif 100sec.
    ...                  scell in cell edge: (scell rsrp) - (scell_with_shutdwon_pa_upddate_value) - 30dB <  a2ThresholdSCellRelSsbRsrp(cell0)
    [Tags]     CRT_TRUNK    CRT_22R4    CRT_23R1
    [Setup]    8015 Case SetUp    pcell_index=${fdd_pcell_index}
    CB008015_D_07_FDD_Cell_lock_with_graceful_cell_shutdown_for_SA_call_when_locked_cell_with_A1_based_scell_addition_and_cell_edge_Ues
    ...                           pcell_index=${fdd_pcell_index}
    [Teardown]    8015 Case TearDown

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
#    [Setup]    8015 Case SetUp    pcell_index=${mobility_fdd_pcell_index}    scf_name=SCF_CB008015_C.xml    is_commission=True    AEHC_PA_value=10
#    CB008015_C_01_Mobility_based_on_rsrp_involving_two_TDD_cells_with_same_coverage_SA    pcell_index=${mobility_fdd_pcell_index}
#    ...    new_pcell_index=${tdd_pcell_index}
#    [Teardown]    8015 Case TearDown

[1]CB008015_C_03_Mobility_based_on_rsrp_involving_one_TDD_cell_SA
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    ...                  CA: based on A2 pcell change,FDD DSS ratio: 70%, PRB blanking enabled
    ...                  position A: pcell rsrp above a1threshold TDD
    ...                  position B: pcell rsrp between a1threshold TDD and FDD
    ...                  position C: pcell rsrp below a1threshold FDD.
    ...                  original pcell TDD, scell sort list: cell2(F)>cell4(T)>cell1(F)>cell0(F)
    ...                  after a2 pcell change, scell sort list is cell3 > cell4 > cell0+1 > cell1 > cell0
    ...                  Check Pcell Change,T(pcell)+F(scell) --> F(pcell)+T(scell)(scell selection based on sortlist)
    ...                  Pcell change based on A2, increase pcell PA to trigger (make pcell rsrp lower than a2ThresholdPCellSwitchSsbRsrp)
    [Tags]     CRT_TRUNK    CRT_22R3    CDRT_22R3    CDRT_22R4    CDRT_23R1    CRT_23R1
    [Setup]    8015 Case SetUp    pcell_index=${tdd_pcell_index}   is_commission=True
    CB008015_C_03_Mobility_based_on_rsrp_involving_one_TDD_cell_SA    pcell_index=${tdd_pcell_index}    new_pcell_index=${mobility_fdd_pcell_index}
    [Teardown]    8015 Case TearDown

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
    [Tags]     CRT_24R3      CRT_25R1
    [Setup]    8015 Case SetUp    pcell_index=${mobility_fdd_pcell_index}    is_commission=True    AEHC_PA_value=20
    CB008015_C_01_Mobility_based_on_rsrp_involving_two_TDD_cells_with_same_coverage_SA    pcell_index=${mobility_fdd_pcell_index}
    ...    new_pcell_index=${tdd_pcell_index}
    [Teardown]    8015 Case TearDown