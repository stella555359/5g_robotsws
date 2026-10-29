*** Settings ***
Force Tags    PY36
Documentation      Author: stella,lin@nokia-sbell.com
Suite Setup        8360 Suite Setup    scf_tag=B    is_do_ue_prepare=${False}    is_concurrent_enb_poweroff=${True}
Suite Teardown    Suite TearDown For 8360_B
Resource     ../Resources/CB008360_keywords.robot
Resource     ../Resources/CB008360_case_steps.robot

*** Test Cases ***
#[1]CB008360-5G-B_03_Two_Rank2_UEs_Paired_or_Unpaired_with_online_parameters_change
#    [Documentation]    Author:stella.lin@nokia-sbell.com
#    ...                Two UEs, SA UL 2layer, Non-CA, modify mimo layer
#    ...                UE3: DINGLI UE2, chbw:40M, MCS PORT: 1/2/3/4
#    ...                UE5: DINGLI UE3, chbw:40M, MCS PORT: 9/10/11/12
#    [Tags]     CRT_23R1    CRT_23R3    CRT_23R4
#    [Timeout]    120m
#    [Setup]    8360_B Case SetUp    pcell_index=${tddpcell_index}
#    CB008360-5G-B_03_Two_Rank2_UEs_Paired_or_Unpaired_with_online_parameters_change
#    [Teardown]    8360 Case TearDown    ues_index=${${3},${4}}
#
#[1]CB008360-5G-W_06_Cell_Performance_With_Two_Rank2_UEs_and_2C4_Subcell_UL_MuMimo_On_VS_OFF_AWGN
#    [Documentation]    Author:lei.jia@nokia-sbell.com
#    ...                Two UEs, SA UL 2layer, Non-CA, modify mimo layer
#    ...                UE3: DINGLI UE1, chbw:40M, MCS PORT: 1/2/3/4
#    ...                UE4: DINGLI UE2, chbw:40M, MCS PORT: 5/6/7/8, ue4 in θ poll
#    [Tags]     CRT_23R1    CRT_23R2
#    [Timeout]    240m
#    [Setup]    8360_B Case SetUp    pcell_index=${tddpcell_index}
#    CB008360-5G-W_06_Cell_Performance_With_Two_Rank2_UEs_and_2C4_Subcell_UL_MuMimo_On_VS_OFF_AWGN
#    [Teardown]    8360 Case TearDown    ues_index=${${2},${3}}

[1]CB008360-5G-B_04_One_Rank2_UE_and_Two_Rank1_UEs_Paired_or_Notpaired_with_online_parameters_change
    [Documentation]    Author:lei.jia@nokia-sbell.com
    ...                  Three UEs, 1 SA UL 2layer, 2 NSA UL llayer; Non-CA, modify actUlMuMimoTapering = true/false
    ...                  UE1: DINGLI UE1, chbw:40M, MCS PORT: 1/2/3/4
    ...                  UE3: DINGLI UE3, chbw:40M, MCS PORT: 9/10/11/12
    ...                  UE4: DINGLI UE4, chbw:40M, MCS PORT: 13/14/15/16
    [Tags]     CIT_TRUNK    CIT_24R3    CRT_23R1    CRT_25R1
    [Timeout]    180m
    [Setup]    8360_B Case SetUp    pcell_index=${tddpcell_index}
    CB008360-5G-B_04_One_Rank2_UE_and_Two_Rank1_UEs_Paired_or_Notpaired_with_online_parameters_change
    [Teardown]    8360 Case TearDown    ues_index=${${1},${3},${4}}

[1]CB008360-5G-B_05_Four_Rank1_UEs_Paired_or_Notpaired_with_online_parameters_change
    [Documentation]    Author:stella.lin@nokia-sbell.com
    ...                Four UEs, NSA UL 1layer, Non-CA
    ...                UE1: DINGLI UE1, chbw:40M, MCS PORT: 1/2/3/4
    ...                UE2: DINGLI UE2, chbw:40M, MCS PORT: 5/6/7/8
    ...                UE3: DINGLI UE3, chbw:40M, MCS PORT: 9/10/11/12
    ...                UE4: DINGLI UE4, chbw:40M, MCS PORT: 13/14/15/16
    [Tags]     CRT_TRUNK    CRT_24R3    CRT_23R2    CRT_23R3    CRT_23R4    CRT_24R1    CRT_25R1
    [Timeout]    120m
    [Setup]    8360_B Case SetUp    pcell_index=${tddpcell_index}
    CB008360-5G-B_05_Four_Rank1_UEs_Paired_or_Notpaired_with_online_parameters_change
    [Teardown]    8360 Case TearDown    ues_index=${${1},${2},${3},${4}}

#[1]CB008360-5G-B_09_Eight_UEs_Paired_with_rdactUlMuMimoEnhance=false
#    [Documentation]    Author:lei.jia@nokia-sbell.com
#    ...                Four UEs, NSA UL 1layer, Non-CA
#    ...                UE3: DINGLI UE1, chbw:40M, MCS PORT: 1/2/3/4
#    ...                UE4: DINGLI UE2, chbw:40M, MCS PORT: 5/6/7/8
#    ...                UE5: DINGLI UE3, chbw:40M, MCS PORT: 9/10/11/12
#    ...                UE6: DINGLI UE4, chbw:40M, MCS PORT: 13/14/15/16
#    [Tags]    CRT_23R1    CRT_23R2
#    [Timeout]    120m
#    [Setup]    8360_B Case SetUp    pcell_index=${tddpcell_index}
#    CB008360-5G-B_09_Eight_UEs_Paired_with_rdactUlMuMimoEnhance=false
#    [Teardown]    8360 Case TearDown    ues_index=${${2},${3},${4},${5}}
#
#[1]CB008360-5G-B_10_Eight_UEs_Paired_with_rdactUlMuMimoEnhance=true
#    [Documentation]    Author:lei.jia@nokia-sbell.com
#    ...                Four UEs, NSA UL 1layer, Non-CA
#    ...                UE3: DINGLI UE1, chbw:40M, MCS PORT: 1/2/3/4
#    ...                UE4: DINGLI UE2, chbw:40M, MCS PORT: 5/6/7/8
#    ...                UE5: DINGLI UE3, chbw:40M, MCS PORT: 9/10/11/12
#    ...                UE6: DINGLI UE4, chbw:40M, MCS PORT: 13/14/15/16
#    [Tags]     CRT_23R1
#    [Timeout]    120m
#    [Setup]    8360_B Case SetUp    pcell_index=${tddpcell_index}
#    CB008360-5G-B_10_Eight_UEs_Paired_with_rdactUlMuMimoEnhance=true
#    [Teardown]    8360 Case TearDown    ues_index=${${2},${3},${4},${5}}
#
#[1]CB008360-5G-W_02_Cell_UL_Peak_Throughput_Four_Rank1_Ues
#    [Documentation]    Author:lei.jia@nokia-sbell.com
#    ...                Four UEs, NSA UL 1layer, Non-CA, UL256QAM OFF, 1208+100M
#    ...                Note for dingli UE, no TAS ue capability, dl tput very low with wrong beam angle
#    ...                UE3: DINGLI UE1, chbw:100M, MCS PORT: 1/2/3/4
#    ...                UE4: DINGLI UE2, chbw:100M, MCS PORT: 5/6/7/8
#    ...                UE5: DINGLI UE3, chbw:100M, MCS PORT: 9/10/11/12
#    ...                UE6: DINGLI UE4, chbw:100M, MCS PORT: 13/14/15/16
#    [Tags]     CRT_23R1
#    [Timeout]    120m
#    [Setup]    8360_B Case SetUp    pcell_index=${tddpcell_index}
#    CB008360-5G-W_02_Cell_UL_Peak_Throughput_Four_Rank1_Ues
#    [Teardown]    8360 Case TearDown    ues_index=${${2},${3},${4},${5}}