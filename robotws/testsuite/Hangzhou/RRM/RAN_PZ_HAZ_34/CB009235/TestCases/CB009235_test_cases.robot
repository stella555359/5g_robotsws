*** Settings ***
Force Tags    PY39
Documentation      Author: xiaoxia.hao@nokia-sbell.com
Suite Setup        9235 Suite Setup
Suite Teardown    Suite TearDown For 9235
Resource     ../Resources/CB009235_keywords.robot
Resource     ../Resources/CB009235_case_steps.robot

*** Test Cases ***
[1]CB009235-SR-C_001_PM_counter_MU_MIMO_PAIR_DL_SUCC
    [Documentation]    Author:xiaoxia.hao@nokia-sbell.com
    ...                Two UEs, SA UL 2layer, Non-CA, modify mimo layer
    [Tags]     CRT_TRUNK    CRT_24R2    CRT_24R3    CRT_25R1    CRT_25R2
    [Timeout]    180m
    [Setup]    9235 Case SetUp
    CB009235-SR-C_001_PM_counter_MU_MIMO_PAIR_DL_SUCC
    [Teardown]    8360 Case TearDown    ues_index=${${2},${3}}

[1]CB009235-SR-B_004_Support_DL_pairing_for_UEs_with_MAC_CE_1_UE_non-GBR_initial_transmission_and_multiplexed_with_MAC_CE
    [Tags]     CRT_TRUNK    CRT_24R2    CRT_24R3    CRT_25R1    CRT_25R2
    [Timeout]    180m
    [Setup]    9235 Case SetUp
    CB009235-SR-B_004_Support_DL_pairing_for_UEs_with_MAC_CE_1_UE_non-GBR_initial_transmission_and_multiplexed_with_MAC_CE
    [Teardown]    8360 Case TearDown    ues_index=${${3},${4}}

[1]CB009235-SR-A_002_MU_aware_TD_scheduling_with_default_condition
    [Documentation]    Author:xiaoxia.hao@nokia-sbell.com
    ...                Two UEs, SA UL 2layer, Non-CA, modify mimo layer
    [Tags]     CIT_TRUNK    CRT_24R3    CRT_25R1    CRT_25R2
    [Timeout]    2400m
    [Setup]    9235 Case SetUp
    CB009235-SR-A_002_MU_aware_TD_scheduling_with_default_condition
    [Teardown]    8360 Case TearDown    ues_index=${${2},${3},${4},${5}}
