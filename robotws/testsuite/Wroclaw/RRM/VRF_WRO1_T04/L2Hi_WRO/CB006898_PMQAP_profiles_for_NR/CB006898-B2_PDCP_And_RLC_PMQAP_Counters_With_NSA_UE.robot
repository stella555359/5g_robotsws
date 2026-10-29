*** Settings ***
Resource    ../resources/common_variables.robot
Library     ../resources/common_keywords.py
Library     ../resources/pm_counters_validator.py

Documentation
...    author: Mariusz Waczynski
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    release: 22R3

*** Variables ***
${TRAFFIC_DURATION_SEC}=   60s
${TIME_FOR_X2_UP}=         5s

*** Keywords ***
CB006898-B2_PDCP_And_RLC_PMQAP_Counters_With_NSA_UE
    Attach Ue And Establish Session
    Start Dl And Ul Data Traffic
    Display Ue Statistics
    Check Pmqap Counters For Dl And Ul
    Detach Ue    ue_id=11

Enable NSA PMQAP Counters
    Send Delta Commissioning
    ...   input_filepath=${DELTA_FILES_PATH}/Pm_counters/delta_nsa_pmqap.json

Set Flow Control to X2
    Send Delta Commissioning
    ...   input_filepath=${DELTA_FILES_PATH}/Split_Mode/delta_dlDataSplitMode_set_to_dlOverX2U_ulDataPath_ulOverNR.json

Attach Ue And Establish Session
    Attach Ue To Enb   ue_id=11
    Start Gnb Addition Procedure    ue=11    bearer=2    target_cells=1    dc_type=split_scg
    Verify Tshark For Single Message    alias=${DEFAULT_S1_MME_ALIAS}    packet_filter=${SGNB_RECONFIG_COMPLETE}

Start Dl And Ul Data Traffic
    Start Data Traffic  ues=11    bearer_id=2    direction=dl    throughput=10mbps
    Start Data Traffic  ues=11    bearer_id=2    direction=ul    throughput=10mbps
    Sleep    ${TRAFFIC_DURATION_SEC}

Display Ue Statistics
    Execute Egate Command And Wait For Data    cmd=uec_stats display type=cell_data_pdcp enb=2 cell=1 format=long
