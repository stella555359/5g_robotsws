*** Settings ***
Resource     ../resources/common_keywords.robot
Resource     ../resources/common_keywords_vran.robot
Resource     ../resources/common_variables.robot
Resource     ../resources/common_configuration.robot
Variables     ../resources/common_variables_vran.py
Library     ../resources/common_keywords.py
Library     ../resources/common_keywords_vran.py
Library     ../resources/pm_counters_validator_vran.py
Library     keywords_CB008158_cloud.py
Resource     keywords_CB008158_cloud.robot

Documentation
...    author: Marcin Kotuła
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    testline: CLOUD_5GC_dRNIC_1vDU_P_AP_LO_DC
...    release: 23R2

Suite Setup    Run Keywords    Configure SA VM interfaces AiC
...   AND   Reach OnAir AiC    lua_cfg=${EPCSIM_CFG_PATH_SANSA_TDD_FDD_AIC}
...   AND   Set Internal Traffic Type To UEs
...   AND   Prepare Bler Testmode In Ul
...   AND   Enable Latency Pm Counters Cloud
...   AND   Disable AiC Uplane Ciphering
...   AND   Set tReorderingUl To 3000ms PDCP 2 Profile


*** Variables ***
${TRAFFIC_DURATION_SEC}=   200s
${SLEEP_AFTER_TRAFFIC}=    240s

*** Test Cases ***
CB008158-C_1_Average_PDCP_re-ordering_delay_in_the_UL_with_PMQAP_and_SA_UE
    Wait For Next PM counters Interval
    Register Ue With Default Pdu Session
    Acitvate Bler Testmode    ue_id=1    scell=0
    Start 180Mbps In Ul And Wait For Traffic Ends
    Display Qfi Stats    qfi_id=1
    Deacitvate Bler Testmode    ue_id=1    scell=0
    Wait For Next PM counters Interval
    Run Keyword And Continue On Failure    Check If vCU Cell And Pmqap Ul Delay Has Expected Value SA    expected_ul_delay=1600    margin=40%
    Start 180Mbps In Ul And Wait For Traffic Ends
    Display Qfi Stats    qfi_id=1
    Deregister Ue   ue_id=1
    Wait For Next PM counters Interval
    Check If vCU Cell And Pmqap Ul Delay Has Expected Value SA    expected_ul_delay=0.0018

CB008158-C_2_Average_PDCP_re-ordering_delay_in_the_UL_with_PMQAP_and_NSA_UE
    Attach Ue And Perform SgNBAdditionRequest
    Acitvate Bler Testmode   ue_id=11    scell=8
    Start 60Mbps In Ul And Wait For Traffic Ends
    Check Ul Data Traffic On Mcg And Scg Leg
    Deacitvate Bler Testmode    ue_id=11    scell=8
    Wait For Next PM counters Interval
    Run Keyword And Continue On Failure    Check If vCU Cell And Pmqap Ul Delay Has Expected Value NSA    expected_ul_delay=0.0021    margin=25%
    Start 60Mbps In Ul And Wait For Traffic Ends
    Check Ul Data Traffic On Mcg And Scg Leg
    Detach Ue    ue_id=11
    Wait For Next PM counters Interval
    Check If vCU Cell And Pmqap Ul Delay Has Expected Value NSA    expected_ul_delay=0.0019

*** Keywords ***
Start 180Mbps In Ul And Wait For Traffic Ends
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=90 seconds=${TRAFFIC_DURATION_SEC}
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=90 trf_id=2 seconds=${TRAFFIC_DURATION_SEC}

Start 60Mbps In Ul And Wait For Traffic Ends
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=11 id=2 dir=ul mbps=60 seconds=${TRAFFIC_DURATION_SEC}
    Sleep    ${SLEEP_AFTER_TRAFFIC}

Prepare Bler Testmode In Ul
    Execute Egate Command    cmd=bler_testmode_nr profile_id=1 ul_bler=10,10,0,0,0,0,0,0

Check Ul Data Traffic On Mcg And Scg Leg
    Execute Egate Command And Wait For Data    cmd=bearer_stats ue=11 id=2 dir=ul dc_cell_group=mcg
    Execute Egate Command And Wait For Data    cmd=bearer_stats ue=11 id=2 dir=ul dc_cell_group=scg
