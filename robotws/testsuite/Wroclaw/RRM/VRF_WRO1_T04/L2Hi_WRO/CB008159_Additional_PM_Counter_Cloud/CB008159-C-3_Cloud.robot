*** Settings ***
Resource     keywords_CB008159_AiC.robot
Library      keywords_CB008159_AiC.py

Documentation
...    author: Marcin Kotuła
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    release: 24R3

*** Variables ***
${TRAFFIC_DURATION_SEC}=    25s

*** Keywords ***
CB008159-C-3_Continuous_And_Bursty_Qos_Flow_Traffic_In_Both_Directions_Cloud
    Prepare Environment
    Register Ue With Default Pdu Session
    Register Ue With Default Pdu Session    ue_id=2
    Add Qos To Ue    ue_id=1    qos_to_add=2, 3, 5
    Start Data Traffic Above 40mbps On The Same Qos At The Same Time
    Start Data Traffic Above 40mbps On Different Qos At The Same Time
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Uec Statistics
    Deregister Ue    ue_id=1
    Deregister Ue    ue_id=2
    Verify If AiC Qos Flow Duration Counters Were Incremented


Verify If AiC Qos Flow Duration Counters Were Incremented
    Wait For Next PM counters Interval
    Verify If AiC Pm Counter Is In Range Of Given Values    counter_id=${COUNTER_ID_NG_FLOW_IN_SESSION_DUR}
    ...    local_moid=MRBTS-1/NRBTS-1/NRCELL-1    margin=3%
    Verify If AiC Pm Counter Is In Range Of Given Values    counter_id=${COUNTER_ID_NG_FLOW_IN_SESSION_DUR}
    ...    local_moid=MRBTS-1/NRBTS-1/NRCELL-2    margin=5%
