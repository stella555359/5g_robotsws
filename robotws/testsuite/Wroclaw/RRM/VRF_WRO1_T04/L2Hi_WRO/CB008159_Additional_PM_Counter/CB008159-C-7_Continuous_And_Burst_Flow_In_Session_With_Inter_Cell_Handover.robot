*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    keywords_CB008159.robot
Library     keywords_CB008159.py

Documentation
...    author: Marek Niescioruk
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    release: 23R4

*** Keywords ***
CB008159-C-7_The_Cumulative_Time_With_Continuous_And_Burst_Flow_In_Session_With_Inter_Cell_Handover
    Execute Egate Command    cmd=ue_change_location id=2 cell=2
    Set Internal Traffic Type To UEs    ue_id=2
    Register Ue With Default Pdu Session
    Register Ue With Default Pdu Session    ue_id=2
    Add Qos To Ue    ue_id=1    qos_to_add=2, 3
    Start Collect Gpt Message
    Start Data Traffic With Ho    ue_id=1    qfi_id=3    direction=dl    duration=20s    time_to_handover=5s    dst_cell=2    dst_phy_cell_id=51
    Display Qfi stats    ue_id=1    qfi_id=3
    Deregister Ue    ue_id=1
    Start Data Traffic With Ho    ue_id=2    qfi_id=1    direction=dl    duration=20s    time_to_handover=10s    dst_cell=1    dst_phy_cell_id=50
    Stop Collect Gpt Message
    Display Qfi stats    ue_id=2    qfi_id=1
    Deregister Ue    ue_id=2
    Verify If Qos Flow Duration Counters Were Incremented
