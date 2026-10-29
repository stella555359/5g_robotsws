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
...   AND   Prepare Bler Testmode In Dl
...   AND   Enable Latency Pm Counters Cloud


*** Variables ***
${TRAFFIC_DURATION_SEC}=   60s

*** Test Cases ***
CB008158-A_3_Counter_For_Measuring_Percentile_Of_Average_Dl_Air-Interface_Delay_For_AM_RLC_SA_UE
    Wait For Next PM counters Interval
    Set Dl Delay Threshold to 10ms
    Register Ue With Default Pdu Session
    Start 150Mbps In Dl And Activate Bler
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Qfi Stats
    Deregister Ue    ue_id=1    pass_regexp=UE1: detached
    Set Dl Delay Threshold to 60ms
    Execute Egate Command    cmd=ue_change_location id=1 cell=2
    Register Ue With Default Pdu Session
    Start 1Mbps In Dl And Deactivate Bler
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Qfi Stats
    Deregister Ue    ue_id=1
    Verify TH PMQAP Counters    cell_id=1
    Verify If TH PMQAP Counters Were Not Incremented    cell_id=2

CB008158-A_4_Counter_For_Measuring_Percentile_Of_Average_Dl_Air-Interface_Delay_For_AM_RLC_NSA_UE
    Set Dl Delay Threshold to 10ms
    Attach Ue And Perform SgNBAdditionRequest
    Start 60Mbps In Dl And Activate Bler
    Sleep    ${TRAFFIC_DURATION_SEC}
    Check Traffic On Mcg And Scg Leg    dir=dl
    Detach Ue    ue_id=11
    Set Dl Delay Threshold to 60ms
    Execute Egate Command    cmd=ue_change_location id=11 cell=2
    Attach Ue And Perform SgNBAdditionRequest
    Sleep    ${TRAFFIC_DURATION_SEC}
    Check Traffic On Mcg And Scg Leg    dir=dl
    Detach Ue    ue_id=11
    Verify TH PMQAP Counters    cell_id=1
    Verify If TH PMQAP Counters Were Not Incremented    cell_id=2

*** Keywords ***
Start 150Mbps In Dl And Activate Bler
    Execute Egate Command    cmd=sim_debug_log level=6
    Acitvate Bler Testmode    ue_id=1    scell=0
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=150 trf_id=1

Start 60Mbps In Dl And Activate Bler
    Execute Egate Command    cmd=sim_debug_log level=6
    Acitvate Bler Testmode    ue_id=11    scell=8
    Execute Egate Command    cmd=trf_data_start ue=11 id=2 dir=dl mbps=60

Start 1Mbps In Dl And Deactivate Bler
    Deacitvate Bler Testmode    ue_id=1    scell=0
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=1

Start 500kbps In Dl And Deactivate Bler
    Deacitvate Bler Testmode    ue_id=11    scell=8
    Execute Egate Command    cmd=trf_data_start ue=11 id=2 dir=dl kbps=500

Verify TH PMQAP Counters
    [Arguments]    ${cell_id}
    Wait For Next PM counters Interval
    ${PM_VALUE}=    keywords_CB008158_cloud.get_du_counter    counter_id=${COUNTER_ID_DL_RLC_AM_DLY_AIR_IF_TH_PMQAP}
    ...    local_moid=MRBTS-1/NRBTS-1/NRCELL-${cell_id}/NRPMQAP-1
    compare_counter_value   value=150000    counter_value=${PM_VALUE}
    ...    counter_id=${COUNTER_ID_DL_RLC_AM_DLY_AIR_IF_TH_PMQAP}    comparison_type=bigger

Verify If TH PMQAP Counters Were Not Incremented
    [Arguments]    ${cell_id}
    ${PM_VALUE}=    keywords_CB008158_cloud.get_du_counter    counter_id=${COUNTER_ID_DL_RLC_AM_DLY_AIR_IF_TH_PMQAP}
    ...    local_moid=MRBTS-1/NRBTS-1/NRCELL-${cell_id}/NRPMQAP-1
    compare_counter_value    value=5    counter_value=${PM_VALUE}
    ...    counter_id=${COUNTER_ID_DL_RLC_AM_DLY_AIR_IF_TH_PMQAP}    comparison_type=lower
