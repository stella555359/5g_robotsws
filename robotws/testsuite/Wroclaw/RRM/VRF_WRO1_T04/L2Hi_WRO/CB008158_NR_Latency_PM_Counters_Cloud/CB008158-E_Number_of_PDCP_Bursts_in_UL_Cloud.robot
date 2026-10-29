*** Settings ***
Resource     ../resources/common_keywords.robot
Resource     ../resources/common_keywords_vran.robot
Resource     ../resources/common_variables.robot
Resource     keywords_CB008158_cloud.robot
Resource     ../resources/common_configuration.robot
Variables     ../resources/common_variables_vran.py
Library     ../resources/common_keywords.py
Library     ../resources/common_keywords_vran.py
Library     ../CB008158_NR_Latency_PM_Counters/keywords_CB008158.py
Library     keywords_CB008158_cloud.py

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

Test Setup     Wait For Next PM counters Interval

*** Test Cases ***
CB010414-E_1_Number_of_PDCP_Bursts_in_UL_with_PMQAP_and_SA_UE_NR_Latency_Pm_Counter_Cloud
    Register Ue With Default Pdu Session
    Acitvate Bler Testmode   ue_id=1    scell=0
    Start Ul Data Traffic With Repetition    repeat=3
    Deregister Ue   ue_id=1
    Wait For Next PM counters Interval
    Check If Cell And Pmqap Burst Has Expected Value For Cloud    expected_value=3

CB010414-E_2_Number_of_PDCP_Bursts_in_UL_with_PMQAP_and_NSA_UE_NR_Latency_Pm_Counter_Cloud
    Attach Ue And Perform SgNBAdditionRequest
    Acitvate Bler Testmode   ue_id=11    scell=8
    Start Ul Data Traffic With Repetition    repeat=2
    Detach Ue    ue_id=11
    Wait For Next PM counters Interval
    Check If Cell And Pmqap Burst Has Expected Value For Cloud   expected_value=2

*** Keywords ***
Prepare Bler Testmode In Ul
    Execute Egate Command    cmd=bler_testmode_nr profile_id=1 ul_bler=10,10,0,0,0,0,0,0

Acitvate Bler Testmode
    [Arguments]    ${ue_id}    ${scell}
    Execute Egate Command    cmd=ue_testmode_set_nr id=${ue_id} testmode=bler action=activate profile_id=1 scell=${scell}

Attach Ue And Perform SgNBAdditionRequest
    Attach Ue To Enb    ue_id=11
    Execute Egate Command    cmd=ue_dc_enb_start ue=11 target_gnb=2 target_cells=1 bearer=2 type=split_scg
    Sleep    5s
