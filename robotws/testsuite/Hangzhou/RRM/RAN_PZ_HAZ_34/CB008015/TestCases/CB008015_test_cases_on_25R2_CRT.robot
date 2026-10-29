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


*** Test Cases ***
[1]CB008015_A_15_A1_measurement_of_PCell_based_SCell_change_for_SA_call_RSRP_for_mixed_mode_of_F_F_and_F_T_CA
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    ...                  CA: pcell FDD, FDD DSS ratio: 70%, PRB blanking enabled
    ...                  position A: pcell rsrp above a1threshold TDD
    ...                  position B: pcell rsrp between a1threshold TDD and FDD
    ...                  position C: pcell rsrp below a1threshold FDD.
    ...                  Scell sort list: cell3 > cell4 > cell0+2 > cell2 > cell0
    ...                  Check Scell change from FDD 3CC(postiion B) to F + T(position A) via adjust PA.
    [Timeout]    120m
    [Setup]    8015 Case SetUp    pcell_index=${fdd_pcell_index}    AEHC_PA_value=20
    CB008015_A_15_A1_measurement_of_PCell_based_SCell_change_for_SA_call_RSRP_for_mixed_mode_of_F_F_and_F_T_CA    pcell_index=${fdd_pcell_index}
    [Teardown]    8015 Case TearDown

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
