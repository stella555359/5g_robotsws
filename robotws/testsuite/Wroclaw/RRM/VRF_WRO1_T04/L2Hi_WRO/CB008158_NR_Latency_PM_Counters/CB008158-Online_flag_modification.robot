*** Settings ***
Library     keywords_CB008158.py
Resource    keywords_CB008158.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2Hi_WRO/resources/common_keywords.robot

Documentation
...    author: Mariusz Waczynski
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    release: 24R1

*** Variables ***
${TRAFFIC_DURATION}=   60s

*** Keywords ***
CB008158_Online_flag_modification
    Verify If Pm Counters Exists
    Register Ue With Default Pdu Session
    Attach Ue With Sgnb
    Start 450Mbps In Dl
    Start 60Mbps In Dl And Ul
    Sleep    ${TRAFFIC_DURATION}
    Check Traffic On Mcg And Scg Leg    dir=dl
    Check Traffic On Mcg And Scg Leg    dir=ul
    Activate Bler
    Sleep    ${TRAFFIC_DURATION}
    Check Traffic On Mcg And Scg Leg    dir=dl
    Check Traffic On Mcg And Scg Leg    dir=ul
    Disable Latency Pm Counters
    Check If Rlc Am Cell And Pmqap Dl Delay Has Expected Value    cell_id=1    expected_rlc_delay=21
    Verify If Pm Counters Were Not Updated
    Deregister Ue   ue_id=1
    Detach Ue    ue_id=11

Prepare Bler Testmode In Dl And Ul
    Execute Egate Command    cmd=bler_testmode_nr profile_id=1 dl_bler=100,50,20,10
    Execute Egate Command    cmd=bler_testmode_nr profile_id=2 ul_bler=10,10,0,0,0,0,0,0

Start 60Mbps In Dl And Ul
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=11 id=2 dir=dl mbps=60
    Execute Egate Command    cmd=trf_data_start ue=11 id=2 dir=ul mbps=60

Activate Bler
    Activate Bler Testmode    ue_id=1    scell=0    profile_id=1
    Activate Bler Testmode    ue_id=11    scell=8    profile_id=1
    Activate Bler Testmode    ue_id=11    scell=8    profile_id=2

Disable Latency Pm Counters
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/Pm_counters/delta_disable_actLatencyPmCount.json
