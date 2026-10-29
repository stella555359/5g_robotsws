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
...    author: Pawel Konieczny
...    maintainer: Bartlomiej Urbanowicz (bartlomiej.urbanowicz@nokia.com)
...    testline: CLOUD_5GC_dRNIC_1vDU_P_AP_LO_SWFH
...    release: 22R3

Test Setup    Run Keywords    Configure SA VM interfaces AiC
...   AND   Reach OnAir AiC    lua_cfg=${EPCSIM_CFG_PATH_SANSA_TDD_FDD_AIC}
...   AND   Enable AiC Vonr And Rohc

Test Teardown     Run Keywords    Deregister Ue   ue_id=1
...   AND   Sleep    3s   Waiting for deregister

*** Variables ***
${TRAFFIC_DURATION_SEC}=   20s

*** Test Cases ***
5GC000774-A-B1_Successful_Setup_Of_Voice_Over_Nr_Call_With_Rohc_Profile_0x0000_Ipv4
    Attach One 5g Ue Capable Of Supporting Rohc
    Start Dl And Ul Data Traffic For Tcp Packet Stream
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Ue Statistics
    Check If Statistics For Compressed Pdus Were Incremented
    Check If Statistics For Rohc Profile 0 Were Incremented
    Check If Expected Throughout Is Reached And There Are No Packets Lost
    Verify If Rohc Dl And Ul Header Pm Counters Arent Incremented

*** Keywords ***
Display Ue Statistics
    Display Qfi stats    qfi_id=3
    Execute Egate Command And Wait For Data    cmd=uec_stats display type=cell_data_pdcp enb=2 cell=1 format=long

Start Dl And Ul Data Traffic For Tcp Packet Stream
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=3 dir=dl trf_id=1 kbps=30 protocol=tcp
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=3 dir=ul trf_id=2 kbps=30 protocol=tcp

Check If Statistics For Compressed Pdus Were Incremented
    Rohc Statistic Greater Than Given Value    rohc_statistic_prefix=compressed_pdu    mode=am    value=0    enb_id=2    cell_id=1
    Rohc Statistic Greater Than Given Value    rohc_statistic_prefix=size_of_compressed_pdus    mode=am    value=0   enb_id=2    cell_id=1

Check If Statistics For Rohc Profile 0 Were Incremented
    Rohc Statistic Greater Than Given Value    rohc_statistic_prefix=decompressed_profile_0_pdus    mode=am    value=0    enb_id=2    cell_id=1
    Rohc Statistic Greater Than Given Value    rohc_statistic_prefix=decompressed_profile_0_bytes    mode=am    value=0    enb_id=2    cell_id=1

Check If Expected Throughout Is Reached And There Are No Packets Lost
    Expected Throughput For Qfi Should Be Reached    ue_id=1    pdu_id=1    qfi_id=3
    ...    expected_throughput=30    unit=kbps    margin=1    direction=bi
    Check Number Of Total Packets Lost    ue_id=1    pdu_id=1    qfi_id=3    packet_loss=0
    ...    margin=0.0    direction=bi

Verify If Rohc Dl And Ul Header Pm Counters Arent Incremented
    Wait For Next PM counters Interval
    Verify CU Counter Value Is Exact As Given Value
    ...    value=0    local_moid=MRBTS-1/NRBTS-1    counter_id=${COUNTER_ID_DL_NUM_ROHC_COMP_HEADER}
    Verify CU Counter Value Is Exact As Given Value
    ...    value=0    local_moid=MRBTS-1/NRBTS-1    counter_id=${COUNTER_ID_DL_VOL_ROHC_COMP_HEADER}
    Verify CU Counter Value Is Exact As Given Value
    ...    value=0    local_moid=MRBTS-1/NRBTS-1    counter_id=${COUNTER_ID_UL_NUM_ROHC_DECOMP_HEADER}
    Verify CU Counter Value Is Exact As Given Value
    ...    value=0    local_moid=MRBTS-1/NRBTS-1    counter_id=${COUNTER_ID_UL_VOL_ROHC_DECOMP_HEADER}