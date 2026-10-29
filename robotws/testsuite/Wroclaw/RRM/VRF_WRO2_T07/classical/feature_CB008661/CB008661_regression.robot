*** Settings ***
Documentation      CRT regression TCs for CB008661_A shall be added here for fully automated regression testing.

Resource           testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/feature_CB008661/A/resources/keywords_8661_A.robot

Suite Setup        Run keywords
...                prepare_testline                         AND
...                initialise_attenuator                    AND
...                nullify_attenuation_on_all_ports


*** Test Cases ***
CB008661-A_1_Unscheduled_ping_latency_for_FDD_FR1_for_feature_5GC000836__SA
    [Documentation]   This TC ...
    CB008661-A_1_Unscheduled_ping_latency_for_FDD_FR1_for_feature_5GC000836__SA
    [Teardown]   TC_teardown_8661_A

CB008661-A_2_Scheduled_ping_latency_for_FDD_FR1_for_feature_5GC000836_SA
    [Documentation]   This TC ...
    CB008661-A_2_Scheduled_ping_latency_for_FDD_FR1_for_feature_5GC000836_SA
    [Teardown]   TC_teardown_8661_A

CB008661-A_3_Unscheduled_ping_latency_for_FDD_FR1_5GC000836_actAdaptiveSr_TRUE_srPeriodicityMin_5slots_SA
    [Documentation]   This TC ...
    CB008661-A_3_Unscheduled_ping_latency_for_FDD_FR1_5GC000836_actAdaptiveSr_TRUE_srPeriodicityMin_5slots_SA
    [Teardown]   TC_teardown_8661_A

CB008661-A_4_Scheduled_ping_latency_for_FDD_FR1_5GC000836_actUlTxSkip_TRUE_ulProGrantTimerTxSkip_1000ms_SA
    [Documentation]   This TC ...
    CB008661-A_4_Scheduled_ping_latency_for_FDD_FR1_5GC000836_actUlTxSkip_TRUE_ulProGrantTimerTxSkip_1000ms_SA
    [Teardown]   TC_teardown_8661_A

CB008661_A_5__Call_setup_Call_release_latency_for_NSA
    [Documentation]   This TC ...
    CB008661_A_5__Call_setup_Call_release_latency_for_NSA
    [Teardown]   TC_teardown_8661_A

CB008661_A_6__Call_setup_Call_release_latency_for_SA
    [Documentation]   This TC ...
    CB008661_A_6__Call_setup_Call_release_latency_for_SA
    [Teardown]   TC_teardown_8661_A

CB008661_A_7__VoNR_Call_setup_call_release_latency_for_SA
    [Documentation]   This TC ...
    CB008661_A_7__VoNR_Call_setup_call_release_latency_for_SA
    [Teardown]   TC_teardown_8661_A

CB008661_A_11_SA_Voice_call_handover_interruption_time
    [Documentation]   This TC ...
    CB008661_A_11_SA_Voice_call_handover_interruption_time
    [Teardown]   TC_teardown_8661_A_11
