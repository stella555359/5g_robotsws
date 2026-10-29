*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    keywords_CB008159.robot
Library     keywords_CB008159.py

Documentation
...    author: Marek Niescioruk
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    release: 23R4

*** Variables ***
${TRAFFIC_DURATION_SEC_C1}=   12s

*** Keywords ***
CB008159-C-1_The_Cumulative_Time_With_Continuous_Qos_Flow_In_Session
    Execute Egate Command    cmd=ue_change_location id=2 cell=2
    Register Ue With Default Pdu Session
    Register Ue With Default Pdu Session    ue_id=2
    Add Qos To Ue    ue_id=1    qos_to_add=2, 3
    Add Qos To Ue    ue_id=2    qos_to_add=4
    Start Collect Gpt Message
    Start Data Traffic And Increment Insession Time    ue_id=1    qfi_id=3    direction=dl    duration=10s
    Start Data Traffic And Increment Insession Time    ue_id=2    qfi_id=2    direction=ul    duration=10s
    Sleep   ${TRAFFIC_DURATION_SEC_C1}
    Start Data Traffic Extended Period Ms    ue_id=1    qfi_id=3    direction=dl    duration=10s
    Start Data Traffic Extended Period Ms    ue_id=2    qfi_id=2    direction=ul    duration=10s
    Sleep   ${TRAFFIC_DURATION_SEC_C1}
    Stop Collect Gpt Message
    Display Uec Statistics
    Deregister Ue    ue_id=1
    Deregister Ue    ue_id=2
    Verify If Qos Flow Duration Counters Were Incremented
