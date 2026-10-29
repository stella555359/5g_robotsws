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
...    testline: CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    release: 22R3

Suite Setup   Send 2637 Delta Commissioning
Test Setup    Run Keywords    Configure SA VM interfaces AiC
...   AND   Reach OnAir AiC    lua_cfg=${EPCSIM_CFG_PATH_SA_TDD_AIC}
...   AND   Set Internal Traffic Type To UEs

*** Variables ***
${TRAFFIC_DURATION_SEC}=   60s

*** Test Cases ***
5GC002637-A-B1-4_Check_throughput_counters_thresholds_for_volume_and_duration
    Wait For Next PM counters Interval
    Register Ue With Default Pdu Session
    Start Ul And Dl Data Traffic Period_MS=30 Size=60
    All AiC Thput Counters Should Be Equal To 0
    Start Ul And Dl Data Traffic Period_MS=30 Size=150
    Wait For Next PM counters Interval
    All AiC Thput Counters Should Be Equal To 0
    Start Ul And Dl Data Traffic Kbps=10000
    Display Qfi stats    qfi_id=1
    Stop Ul And Dl Data Traffic
    Wait For Next PM counters Interval
    Check Throughput Counters For Sa Ue AiC    dl_tput=10000    ul_tput=11000

*** Keywords ***
Start Ul And Dl Data Traffic Period_MS=30 Size=60
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl period_ms=30 size=60
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul period_ms=30 size=60
    Sleep    ${TRAFFIC_DURATION_SEC}

Start Ul And Dl Data Traffic Period_MS=30 Size=150
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl period_ms=30 size=150
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul period_ms=30 size=150
    Sleep    ${TRAFFIC_DURATION_SEC}

Start Ul And Dl Data Traffic Kbps=10000
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl kbps=10000
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul kbps=10000
    Sleep    ${TRAFFIC_DURATION_SEC}

Stop Ul And Dl Data Traffic
    Execute Egate Command    cmd=trf_data_stop ue=1 pdu=1 dir=dl
    Execute Egate Command    cmd=trf_data_stop ue=1 pdu=1 dir=ul

Send 2637 Delta Commissioning
    Perform CU Delta Commissioning    ${CURDIR}/config/2637_CU_delta.json
    Perform DU Delta Commissioning    ${CURDIR}/config/2637_DU_delta.json
    Sleep    180s
    Reset Aic Testline
