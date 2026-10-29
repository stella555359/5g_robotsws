*** Settings ***
Resource     ../resources/common_keywords.robot
Resource     ../resources/common_keywords_vran.robot
Resource     ../resources/common_variables.robot
Variables     ../resources/common_variables_vran.py
Library     ../resources/common_keywords.py
Library     ../resources/common_keywords_vran.py
Library     ../5GC000774_ROHC/keywords_ROHC.py
Library     ../resources/pm_counters_validator_vran.py
Documentation
...    author: Mariusz Waczynski
...    maintainer: Mariusz Waczynski (mmariusz.waczynski@nokia.com)
...    testline: CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_FDD_ORAN
...    release: 22R3

Suite Setup  Send 2637 Delta Commissioning
Test Setup    Run Keywords    Configure SA VM interfaces AiC
...   AND   Reach OnAir AiC    lua_cfg=${EPCSIM_CFG_PATH_SA_TDD_AIC}
...   AND   Set Internal Traffic Type To UEs

*** Variables ***
${TRAFFIC_DURATION_SEC}=   60s

*** Test Cases ***
5GC002637-A-B1-1_PDCP_and_RLC_throughput_counters_with_SA_UE
    Wait For Next PM counters Interval
    Register Ue With Default Pdu Session
    Start 10Mbps Ul And Dl Data Traffic
    Check Data Traffic
    Stop Ul And Dl Data Traffic
    Wait For Next PM counters Interval
    Check Throughput Counters For Sa Ue AiC    dl_tput=10000    ul_tput=11000

*** Keywords ***
Start 10Mbps Ul And Dl Data Traffic
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=10
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=10

Stop Ul And Dl Data Traffic
    Execute Egate Command    cmd=trf_data_stop ue=1 pdu=1 dir=dl
    Execute Egate Command    cmd=trf_data_stop ue=1 pdu=1 dir=ul

Check Data Traffic
    Sleep  ${TRAFFIC_DURATION_SEC}
    Display Qfi stats    qfi_id=1
    Execute Egate Command And Wait For Data    cmd=uec_stats display type=cell_data_pdcp enb=2 cell=1 format=long
    Expected Throughput For Qfi Should Be Reached    ue_id=1    pdu_id=1    qfi_id=1
    ...    expected_throughput=10    unit=mbps    margin=0.2    direction=bi
    Check Number Of Total Packets Lost    ue_id=1    pdu_id=1    qfi_id=1    packet_loss=0
    ...    margin=0.0    direction=bi

Send 2637 Delta Commissioning
    Perform CU Delta Commissioning    ${CURDIR}/config/2637_CU_delta.json
    Perform DU Delta Commissioning    ${CURDIR}/config/2637_DU_delta.json
    Sleep    180s
    Reset Aic Testline
