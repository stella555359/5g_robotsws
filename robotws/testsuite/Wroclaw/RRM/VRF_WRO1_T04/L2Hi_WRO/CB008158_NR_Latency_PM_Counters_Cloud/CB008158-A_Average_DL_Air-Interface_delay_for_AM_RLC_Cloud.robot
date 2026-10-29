*** Settings ***
Resource     ../resources/common_keywords.robot
Resource     ../resources/common_keywords_vran.robot
Resource     ../resources/common_variables.robot
Resource     ../resources/common_configuration.robot
Variables     ../resources/common_variables_vran.py
Library     ../resources/common_keywords.py
Library     ../resources/common_keywords_vran.py
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
...   AND   Prepare Bler Testmode In Dl
...   AND   Enable Latency Pm Counters Cloud
...   AND   Enable AiC Inter Cell HO


*** Variables ***
${TRAFFIC_DURATION_SEC}=   240s

*** Test Cases ***
CB008158-A_1_Counter_for_measuring_Average_DL_Air-Interface_delay_for_AM_RLC_SA_UE_PMQAP
    Wait For Next PM counters Interval
    Register Ue With Default Pdu Session
    Start 450Mbps In Dl And Activate Bler
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Qfi Stats    qfi_id=1
    Deacitvate Bler Testmode    ue_id=1    scell=0
    Intercell Handover Trigger By A3    ue_id=1    dst_cell=2    dst_phy_cell_id=51
    Wait For Next PM counters Interval
    Run Keyword And Continue On Failure    Check If Rlc Am Cell And Pmqap Dl Delay Has Expected Value
    ...    cell_id=1    expected_rlc_delay=90
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Qfi Stats    qfi_id=1
    Deregister Ue    ue_id=1
    Wait For Next PM counters Interval
    Check If Rlc Am Cell And Pmqap Dl Delay Has Expected Value
    ...    cell_id=2    expected_rlc_delay=34

CB008158-A_2_Counter_for_measuring_Average_DL_Air-Interface_delay_for_AM_RLC_NSA_UE_PMQAP
    Attach Ue And Perform SgNBAdditionRequest
    Start 60Mbps In Dl
    Sleep    ${TRAFFIC_DURATION_SEC}
    Check Traffic On Mcg And Scg Leg    dir=dl
    Deacitvate Bler Testmode    ue_id=11    scell=8
    Wait For Next PM counters Interval
    Run Keyword And Continue On Failure    Check If Rlc Am Cell And Pmqap Dl Delay Has Expected Value
    ...    cell_id=1    expected_rlc_delay=36
    Sleep    ${TRAFFIC_DURATION_SEC}
    Check Traffic On Mcg And Scg Leg    dir=dl
    Detach Ue    ue_id=11
    Wait For Next PM counters Interval
    Check If Rlc Am Cell And Pmqap Dl Delay Has Expected Value
    ...    cell_id=1    expected_rlc_delay=32

*** Keywords ***
Start 450Mbps In Dl And Activate Bler
    Execute Egate Command    cmd=sim_debug_log level=6
    Acitvate Bler Testmode    ue_id=1    scell=0
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 trf_id=2
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 trf_id=3

Start 60Mbps In Dl
    Execute Egate Command    cmd=sim_debug_log level=6
    Acitvate Bler Testmode    ue_id=11    scell=8
    Execute Egate Command    cmd=trf_data_start ue=11 id=2 dir=dl mbps=60

Enable AiC Inter Cell HO
    Perform CU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/Inter_Cell_HO_CU_delta.json
    Sleep    180s
