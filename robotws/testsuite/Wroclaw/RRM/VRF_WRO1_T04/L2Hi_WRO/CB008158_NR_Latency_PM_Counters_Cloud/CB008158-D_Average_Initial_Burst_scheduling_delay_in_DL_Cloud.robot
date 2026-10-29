*** Settings ***
Resource     ../resources/common_keywords.robot
Resource     ../resources/common_keywords_vran.robot
Resource     ../resources/common_variables.robot
Resource     keywords_CB008158_cloud.robot
Resource     ../resources/common_configuration.robot
Variables     ../resources/common_variables_vran.py
Library     ../resources/common_keywords.py
Library     ../resources/common_keywords_vran.py
Library     keywords_CB008158_cloud.py

Documentation
...    author: Marcin Kotuła
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    testline: CLOUD_5GC_dRNIC_1vDU_P_AP_LO_DC
...    release: 23R2

Suite Setup    Run Keywords    Configure SA VM interfaces AiC
...   AND   Reach OnAir AiC    lua_cfg=${EPCSIM_CFG_PATH_SANSA_TDD_FDD_AIC}
...   AND   Set Internal Traffic Type To UEs
...   AND   Prepare Bler Testmode In Dl
...   AND   Configure VM interfaces For Second Gnb
...   AND   Disable AiC Uplane Ciphering
...   AND   Enable Latency Pm Counters Cloud

Test Setup     Wait For Next PM counters Interval


*** Variables ***
${TRAFFIC_DURATION_SEC}=   60s

*** Test Cases ***
CB010414-D_1_Average_Initial_Burst_Scheduling_Delay_In_DL_For_PMQAP_And_Cell_SA_UE_NR_Latency_Pm_Counter_Cloud
    Register Ue With Default Pdu Session
    Start 450Mbps In Dl
    Sleep  ${TRAFFIC_DURATION_SEC}
    Display Qfi Stats    qfi_id=1
    Deregister Ue   ue_id=1
    Wait For Next PM counters Interval
    Check If Burst Scheduling Cell And Pmqap Dl Delay Has Expected Value For Cloud   expected_range=3-12

CB010414-D_1_Average_Initial_Burst_Scheduling_Delay_In_DL_For_PMQAP_And_Cell_NSA_UE_NR_Latency_Pm_Counter_Cloud
    Attach Ue And Perform SgNBAdditionRequest
    Start 60Mbps In Dl
    Sleep  ${TRAFFIC_DURATION_SEC}
    Print Bearer Tput
    Detach Ue    ue_id=11
    Wait For Next PM counters Interval
    Check If Burst Scheduling Cell And Pmqap Dl Delay Has Expected Value For Cloud   expected_range=3-12

*** Keywords ***
Prepare Bler Testmode In Dl
    Execute Egate Command    cmd=bler_testmode_nr profile_id=1 dl_bler=100,50,20,10

Start 450Mbps In Dl
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 trf_id=2
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 trf_id=3

Start 60Mbps In Dl
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=11 id=2 dir=dl mbps=60

Attach Ue And Perform SgNBAdditionRequest
    Attach Ue To Enb    ue_id=11
    Execute Egate Command    cmd=ue_dc_enb_start ue=11 target_gnb=2 target_cells=1 bearer=2 type=split_scg
    Sleep    5s
