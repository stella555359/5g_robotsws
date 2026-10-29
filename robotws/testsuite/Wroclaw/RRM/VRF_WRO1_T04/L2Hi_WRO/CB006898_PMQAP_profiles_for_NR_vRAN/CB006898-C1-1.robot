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
...    author: Marcin Kotuła
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    release: 22R3

Suite Setup   Send 6898-C Delta Commissioning
Test Setup    Run Keywords    Configure SA VM interfaces AiC
...   AND   Reach OnAir AiC    lua_cfg=${EPCSIM_CFG_PATH_SANSA_TDD_FDD_AIC}
...   AND   Set Internal Traffic Type To UEs
...   AND   Wait For Next PM counters Interval
Test Teardown     Run Keywords    Deregister Ue   ue_id=1
...   AND   Sleep    3s   Waiting for deregister

*** Variables ***
${TRAFFIC_DURATION_SEC}=   60s

*** Test Cases ***
CB006898-C1-1_PDCP_And_RLC_Throughput_Counters_With_Single_Ue
    Register Ue With Default Pdu Session
    Start 10Mbps Ul And Dl Data Traffic
    Check Data Traffic
    Wait For Next PM counters Interval
    Verify Counters

*** Keywords ***
Start 10Mbps Ul And Dl Data Traffic
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=10
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=10

Check Data Traffic
    Sleep  ${TRAFFIC_DURATION_SEC}
    Display Qfi stats    qfi_id=1
    Execute Egate Command And Wait For Data    cmd=uec_stats display type=cell_data_pdcp enb=2 cell=1 format=long
    Expected Throughput For Qfi Should Be Reached    ue_id=1    pdu_id=1    qfi_id=1
    ...    expected_throughput=10    unit=mbps    margin=0.2    direction=bi
    Check Number Of Total Packets Lost    ue_id=1    pdu_id=1    qfi_id=1    packet_loss=0
    ...    margin=0.0    direction=bi

Verify Counters
    Verify CU Counters Value And Compare Them    first_counter_name=${COUNTER_ID_DL_PDCP_VOL_UE_TPUT_TOT}
    ...    second_counter_name=${COUNTER_ID_DL_PDCP_VOL_UE_TPUT_QOS08}     local_moid1=MRBTS-1/NRBTS-1/NRCELL-1
    ...    local_moid2=MRBTS-1/NRBTS-1/NRCELL-1
    Verify CU Counters Value And Compare Them    first_counter_name=${COUNTER_ID_DL_PDCP_TIME_UE_TPUT}
    ...    second_counter_name=${COUNTER_ID_DL_PDCP_TIME_UE_TPUT_QOS_8}     local_moid1=MRBTS-1/NRBTS-1/NRCELL-1
    ...    local_moid2=MRBTS-1/NRBTS-1/NRCELL-1
    Verify DU Counters Value And Compare Them    first_counter_name=${COUNTER_ID_UL_RLC_VOL_UE_TPUT_TOT}
    ...    second_counter_name=${COUNTER_ID_UL_RLC_VOL_UE_TPUT_QOS_8}     local_moid1=MRBTS-1/NRBTS-1/NRCELL-1
    ...    local_moid2=MRBTS-1/NRBTS-1/NRCELL-1
    Verify DU Counters Value And Compare Them    first_counter_name=${COUNTER_ID_UL_RLC_TIME_UE_TPUT}
    ...    second_counter_name=${COUNTER_ID_UL_RLC_TIME_UE_TPUT_QOS_8}     local_moid1=MRBTS-1/NRBTS-1/NRCELL-1
    ...    local_moid2=MRBTS-1/NRBTS-1/NRCELL-1

Send 6898-C Delta Commissioning
    Perform CU Delta Commissioning    ${CURDIR}/config/6898-C_CU_delta.json
    Perform DU Delta Commissioning    ${CURDIR}/config/6898-C_DU_delta.json
    Sleep    180s
    Reset Aic Testline