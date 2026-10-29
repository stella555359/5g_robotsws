*** Settings ***
Library     testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/counter_helpers.py
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/multi_ue.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T01/CB013206/resources/keywords.resource


*** Variables ***
@{ues}    UE_1


*** Keywords ***
[1]CB013206-A#1_NonPMQAP_NX2CC_RAB_IN_SESSION_DUR
    Perform commissioning CB013206
    detach ues from cell    ${ues}
    attach ues to cell    ${ues}
    Start ULDL for UEs    ${ues}    duration=3m

    Wait for counter interval
    run keyword and ignore error    Stop all datatransfers
    detach ues from cell    ${ues}

    ${last_counter_v}    Get M55350C00038 counter
    check_counters_are_greater_than_zero    ${last_counter_v}

    Wait for counter interval
    Wait for counter interval
    ${last_counter_v}    Get M55350C00038 counter
    check_counters_are_zero    ${last_counter_v}
