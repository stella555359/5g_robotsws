*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    keywords_CB008159.robot
Library     keywords_CB008159.py

Documentation
...    author: Marek Niescioruk
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    release: 23R4

*** Keywords ***
CB008159-C-6_The_Cumulative_Time_With_Continuous_And_Burst_Flow_In_Session_With_Bearer_Delete
    Execute Egate Command    cmd=ue_change_location id=2 cell=2
    Register Ue With Default Pdu Session
    Register Ue With Default Pdu Session    ue_id=2
    Add Qos To Ue    ue_id=1    qos_to_add=2, 3
    Start Collect Gpt Message
    Start Data Traffic With Bearer Delete    ue_id=1    qfi_id=3    direction=dl    duration=10s
    Display Qfi stats    ue_id=1    qfi_id=3
    Start Data Traffic With Bearer Delete    ue_id=2    qfi_id=1    direction=dl    duration=10s
    Display Qfi stats    ue_id=2    qfi_id=1
    Stop Collect Gpt Message
    Check In Session Status    status=True
    Verify If Qos Flow Duration Counters Were Incremented
