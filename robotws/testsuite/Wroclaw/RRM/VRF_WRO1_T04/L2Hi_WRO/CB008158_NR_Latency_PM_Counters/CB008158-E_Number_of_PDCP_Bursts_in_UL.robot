*** Settings ***
Library     keywords_CB008158.py
Resource    keywords_CB008158.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_keywords.robot

Documentation
...    author: Mariusz Waczynski
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    release: 24R1

*** Keywords ***
CB008158-E_1_Number_of_PDCP_Bursts_in_UL_with_PMQAP_and_SA_UE
    Register Ue With Default Pdu Session
    Activate Bler Testmode   ue_id=1    scell=0
    Start Ul Data Traffic With Repetition    repeat=3
    Deregister Ue   ue_id=1
    Check If Cell And Pmqap Burst Has Expected Value    expected_value=3

CB008158-E_2_Number_of_PDCP_Bursts_in_UL_with_PMQAP_and_NSA_UE
    Attach Ue With Sgnb
    Activate Bler Testmode   ue_id=11    scell=8
    Start Ul Data Traffic With Repetition    repeat=2
    Detach Ue    ue_id=11
    Check If Cell And Pmqap Burst Has Expected Value    expected_value=2
