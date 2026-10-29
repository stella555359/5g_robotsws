*** Settings ***
Resource     keywords_CB008159_AiC.robot
Library      keywords_CB008159_AiC.py

Documentation
...    author: Marcin Kotuła
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    release: 24R3

*** Variables ***
${TRAFFIC_DURATION_SEC_C4}=   12s

*** Keywords ***
CB008159-C-4_The_Cumulative_Time_Qos_With_Flow_5qi1_5qi2_And_5qi6_In_Session_With_Pmqap_Profiles_Activated
    Prepare Environment
    Register Ue With Default Pdu Session
    Register Ue With Default Pdu Session    ue_id=2
    Add Qos To Ue    ue_id=1    qos_to_add=2, 3
    Start Data Traffic    ue_id=1    qfi_id=3    direction=dl    duration=10s
    Sleep    ${TRAFFIC_DURATION_SEC_C4}
    Display Qfi stats    ue_id=1    qfi_id=3
    Deregister Ue    ue_id=1
    Start Data Traffic    ue_id=2    qfi_id=1    direction=dl    duration=10s
    Sleep    ${TRAFFIC_DURATION_SEC_C4}
    Display Qfi stats    ue_id=2    qfi_id=1
    Deregister Ue    ue_id=2
    Register Ue With Default Pdu Session
    Add Qos To Ue    ue_id=1    qos_to_add=2, 3, 5
    Start Data Traffic    ue_id=1    qfi_id=4    direction=ul    duration=10s
    Sleep    ${TRAFFIC_DURATION_SEC_C4}
    Display Qfi stats    ue_id=1    qfi_id=4
    Deregister Ue    ue_id=1    pass_regexp=UE1: detached
    Execute Egate Command    cmd=ue_change_location id=1 cell=2
    Register Ue With Default Pdu Session
    Start Data Traffic    ue_id=1    qfi_id=1    direction=ul    duration=10s
    Sleep    ${TRAFFIC_DURATION_SEC_C4}
    Display Qfi stats    ue_id=1    qfi_id=1
    Deregister Ue    ue_id=1
    Verify If AiC Qos Flow Duration PMQAP Counters Were Incremented


Verify If AiC Qos Flow Duration PMQAP Counters Were Incremented
    Wait For Next PM counters Interval
    Verify If AiC Pmqap Counter Is In Range Of Given Values    counter_id=${COUNTER_ID_NG_FLOW_IN_SESSION_DUR_PMQAP}
    ...    local_moid=MRBTS-1/NRBTS-1/NRCELL-1   margin=3%
    Verify If AiC Pmqap Counter Is In Range Of Given Values    counter_id=${COUNTER_ID_NG_FLOW_IN_SESSION_DUR_PMQAP}
    ...    local_moid=MRBTS-1/NRBTS-1/NRCELL-2    margin=3%
