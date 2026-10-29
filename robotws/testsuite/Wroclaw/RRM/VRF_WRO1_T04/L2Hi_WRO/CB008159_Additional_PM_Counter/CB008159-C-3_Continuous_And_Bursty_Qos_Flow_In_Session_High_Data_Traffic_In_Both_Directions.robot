*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    keywords_CB008159.robot
Library     keywords_CB008159.py

Documentation
...    author: Marek Niescioruk
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    release: 23R4

*** Variables ***
${TRAFFIC_DURATION_SEC_C3}=   25s

*** Keywords ***
CB008159-C-3_The_Cumulative_Time_With_Continuous_And_Bursty_Qos_Flow_In_Session_High_Data_Traffic_In_Both_Directions
    Execute Egate Command    cmd=ue_change_location id=2 cell=2
    Register Ue With Default Pdu Session
    Register Ue With Default Pdu Session    ue_id=2
    Add Qos To Ue    ue_id=1    qos_to_add=2, 3, 4
    Start Data Traffic Above 60mbps On The Same Qos At The Same Time
    Start Data Traffic Above 60mbps On Different Qos At The Same Time
    Sleep   ${TRAFFIC_DURATION_SEC_C3}
    Display Uec Statistics
    Deregister Ue    ue_id=1
    Deregister Ue    ue_id=2
    Check In Session Status    status=False
    Verify If Qos Flow Duration Counters Were Incremented
