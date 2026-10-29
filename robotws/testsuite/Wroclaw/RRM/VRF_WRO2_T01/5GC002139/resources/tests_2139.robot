*** Settings ***
Documentation  This file contains test logic.

Resource  testsuite/Wroclaw/RRM/VRF_WRO2_T01/5GC002139/resources/keywords.robot
Library   testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/counter_helpers.py

*** Variables ***
${ue_id}  1

*** Keywords ***
[1][1.0] 5GC002139-A_Func_1Call1S_MaxTput_FDD_Class_1S-4UL4DL_NSA_FDM_PDSCH_Dl_Closed_loop_4x4_rank4_in_GOOD_RC
    [Documentation]  Test checks initial value of rank4 tput counter and post tput value.
    ...              Initial value should be 0.
    ...              Post tput should be greater than 0.

    detach all ues
    Perfom commissioning for 5GC002139

    Wait for counter interval
    ${initial_value}  Get M55301C10004 counter
    check_counters_are_zero  ${initial_value}

    Attach ue to cell and perform tput

    Wait for counter interval
    ${initial_value}  Get M55301C10004 counter
    check_counters_are_greater_than_zero  ${initial_value}
