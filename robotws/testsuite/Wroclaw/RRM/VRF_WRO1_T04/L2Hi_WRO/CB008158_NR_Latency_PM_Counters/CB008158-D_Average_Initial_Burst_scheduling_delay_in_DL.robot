*** Settings ***
Library     keywords_CB008158.py
Resource    keywords_CB008158.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_keywords.robot

Documentation
...    author: Mariusz Waczynski
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    release: 24R1

*** Variables ***
${TRAFFIC_DURATION}=    30s

*** Keywords ***
CB008158-D_1_Average_Initial_Burst_Scheduling_Delay_In_DL_With_PMQAP_And_SA_UE
    Register Ue With Default Pdu Session
    Start 450Mbps In Dl
    Sleep  ${TRAFFIC_DURATION}
    Display Qfi Stats    qfi_id=1
    Deregister Ue   ue_id=1
    Check If Burst Scheduling Cell And Pmqap Dl Delay Has Expected Value    expected_range=3-12
    Register Ue With Default Pdu Session
    Add Qos To Ue    ue_id=1    qos_to_add=4
    Start 1Mbps In Dl
    Sleep  ${TRAFFIC_DURATION}
    Display Qfi Stats    qfi_id=2
    Deregister Ue    ue_id=1
    Check If Burst Scheduling Cell And Pmqap Dl Delay Has Expected Value    expected_range=0.1-1

CB008158-D_2_Average_Initial_Burst_Scheduling_Delay_In_DL_With_PMQAP_And_NSA_UE
    Attach Ue With Sgnb
    Start 60Mbps In Dl
    Sleep  ${TRAFFIC_DURATION}
    Print Bearer Tput
    Detach Ue    ue_id=11
    Check If Burst Scheduling Cell And Pmqap Dl Delay Has Expected Value    expected_range=3-12

Start 60Mbps In Dl
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=11 id=2 dir=dl mbps=60

Start 1Mbps In Dl
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=2 dir=dl mbps=1
