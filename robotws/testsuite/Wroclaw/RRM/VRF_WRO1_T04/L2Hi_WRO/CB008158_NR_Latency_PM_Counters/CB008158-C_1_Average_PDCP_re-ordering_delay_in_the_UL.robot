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
CB008158-C_1_Average_PDCP_re-ordering_delay_in_the_UL_with_PMQAP_and_SA_UE
    Register Ue With Default Pdu Session
    Activate Bler Testmode    ue_id=1    scell=0
    Start 180Mbps In Ul And Wait For Traffic Ends
    Display Qfi Stats    qfi_id=1
    Deactivate Bler Testmode    ue_id=1    scell=0
    Check If Cell And Pmqap Ul Delay Has Expected Value    expected_ul_delay=520    margin=25%
    Start 180Mbps In Ul And Wait For Traffic Ends
    Display Qfi Stats    qfi_id=1
    Deregister Ue   ue_id=1
    Check If Cell And Pmqap Ul Delay Has Expected Value    expected_ul_delay=0.00055

CB008158-C_2_Average_PDCP_re-ordering_delay_in_the_UL_with_PMQAP_and_NSA_UE
    Attach Ue With Sgnb
    Activate Bler Testmode   ue_id=11    scell=8
    Start 60Mbps In Ul And Wait For Traffic Ends
    Check Ul Data Traffic On Mcg And Scg Leg
    Deactivate Bler Testmode    ue_id=11    scell=8
    Check If Cell And Pmqap Ul Delay Has Expected Value    expected_ul_delay=0.35    margin=25%
    Start 60Mbps In Ul And Wait For Traffic Ends
    Check Traffic On Mcg And Scg Leg    dir=ul
    Detach Ue    ue_id=11
    Check If Cell And Pmqap Ul Delay Has Expected Value    expected_ul_delay=0.00055

Start 180Mbps In Ul And Wait For Traffic Ends
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=90 seconds=${TRAFFIC_DURATION_SEC}
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=90 trf_id=2 seconds=${TRAFFIC_DURATION_SEC}
    Sleep    ${TRAFFIC_DURATION_SEC}

Start 60Mbps In Ul And Wait For Traffic Ends
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=11 id=2 dir=ul mbps=60 seconds=${TRAFFIC_DURATION_SEC}
    Sleep    ${TRAFFIC_DURATION_SEC}

Set tReorderingUl To 3000ms PDCP 2 Profile
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Pm_counters/delta_tReorderingUl_set_to_3000ms_PDCP_2.json

Check Ul Data Traffic On Mcg And Scg Leg
    Execute Egate Command And Wait For Data    cmd=bearer_stats ue=11 id=2 dir=ul dc_cell_group=mcg
    Execute Egate Command And Wait For Data    cmd=bearer_stats ue=11 id=2 dir=ul dc_cell_group=scg
