*** Settings ***
Documentation      Author: stella,lin@nokia-sbell.com
Suite Setup        8360 Suite Setup    scf_tag=D    is_do_ue_prepare=${False}    is_concurrent_enb_poweroff=${True}    if_commissioning=${True}
Suite Teardown    Suite TearDown For 8360_B
Resource     ../Resources/CB008360_keywords.robot
Resource     ../Resources/CB008360_case_steps.robot

*** Test Cases ***
[1]CB008360-5G-W_01_Cell_UL_Peak_Throughput_Two_Rank2_UEs
    [Documentation]    Author:stella.lin@nokia-sbell.com
    ...                Two UEs, SA UL 2layer, Non-CA, modify mimo layer
    ...                UE3: DINGLI UE1, chbw:40M, MCS PORT: 1/2/3/4
    ...                UE5: DINGLI UE3, chbw:40M, MCS PORT: 9/10/11/12
    [Tags]     CRT_TRUNK    CRT_24R3    CRT_23R2    CRT_25R1
    [Timeout]    120m
    [Setup]    8360_B Case SetUp    pcell_index=${tddpcell_index}
    CB008360-5G-W_01_Cell_UL_Peak_Throughput_Two_Rank2_UEs
    [Teardown]    8360 Case TearDown    ues_index=${${3},${4}}

#[1]CB008360-5G-D_01_UL_MuMIMO_with_Retransmission
#    [Documentation]    Author:stella.lin@nokia-sbell.com
#    ...                2023/05/17  delete CABLINK-57, only keep 1 cablink for 16D8U
#    ...                Two UEs, SA UL 2layer, Non-CA
#    ...                UE5: DINGLI UE3, chbw:40M, MCS PORT: 9/10/11/12
#    ...                UE6: DINGLI UE4, chbw:40M, MCS PORT: 13/14/15/16
#    [Tags]    CRT_23R1    CRT_23R2    CRT_23R3
#    [Timeout]    120m
#    [Setup]    8360_B Case SetUp    pcell_index=${tddpcell_index}
#    CB008360-5G-D_01_UL_MuMIMO_with_Retransmission
#    [Teardown]    8360 Case TearDown    ues_index=${${2},${3},${4},${5}}




