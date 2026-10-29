*** Settings ***
Library     keywords_CB008158.py
Resource    keywords_CB008158.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_keywords.robot

Documentation
...    author: Mariusz Waczynski
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    release: 24R1

*** Variables ***
${TRAFFIC_DURATION_SEC}=   240s

*** Keywords ***
CB008158-A_1_Counter_for_measuring_Average_DL_Air-Interface_delay_for_AM_RLC_SA_UE_PMQAP
    Register Ue With Default Pdu Session
    Start 450Mbps In Dl And Activate Bler
    BuiltIn.Sleep    ${TRAFFIC_DURATION_SEC}
    Display Qfi Stats    qfi_id=1
    Deactivate Bler Testmode    ue_id=1    scell=0
    Intercell Handover Trigger By A3    ue_id=1    dst_cell=2    dst_phy_cell_id=51
    Check If Rlc Am Cell And Pmqap Dl Delay Has Expected Value    cell_id=1    expected_rlc_delay=34
    BuiltIn.Sleep    ${TRAFFIC_DURATION_SEC}
    Display Qfi Stats    qfi_id=1
    ta5g_ue_mobility.Deregister Ue    ue_id=1
    Check If Rlc Am Cell And Pmqap Dl Delay Has Expected Value    cell_id=2    expected_rlc_delay=20

CB008158-A_2_Counter_for_measuring_Average_DL_Air-Interface_delay_for_AM_RLC_NSA_UE_PMQAP
    Attach Ue With Sgnb
    Start 60Mbps In Dl And Activate Bler
    BuiltIn.Sleep    ${TRAFFIC_DURATION_SEC}
    Check Traffic On Mcg And Scg Leg    dir=dl
    Deactivate Bler Testmode    ue_id=11    scell=8
    Check If Rlc Am Cell And Pmqap Dl Delay Has Expected Value    cell_id=1    expected_rlc_delay=73
    BuiltIn.Sleep    ${TRAFFIC_DURATION_SEC}
    Check Traffic On Mcg And Scg Leg    dir=dl
    ta5g_ue_mobility.Detach Ue    ue_id=11
    Check If Rlc Am Cell And Pmqap Dl Delay Has Expected Value    cell_id=1    expected_rlc_delay=32

Start 450Mbps In Dl And Activate Bler
    Execute Egate Command    cmd=sim_debug_log level=6
    Activate Bler Testmode    ue_id=1    scell=0
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 trf_id=2
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 trf_id=3
