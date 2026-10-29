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
...    maintainer: Marcin Kotula (marcin.kotula@nokia.com)
...    testline: CLOUD_5GC_dRNIC_1vDU_P_AP_LO_SWFH
...    release: 22R3

Test Setup    Run Keywords    Configure SA VM interfaces AiC
...   AND   Reach OnAir AiC    lua_cfg=${EPCSIM_CFG_PATH_SANSA_TDD_FDD_AIC}
...   AND   Enable AiC Vonr And Rohc
...   AND   Enable AiC Maxcidallowed 1

Test Teardown     Run Keywords    Deregister Ue   ue_id=1
...   AND   Sleep    3s   Waiting for deregister

*** Variables ***
${TRAFFIC_DURATION_SEC}=   20s

*** Test Cases ***
5GC000774-A-B1_Maxcidallowed_Value_1_Rtp
    Attach One 5g Ue Capable Of Supporting Rohc
    Start Dl And Ul Data Traffic For Rtp Packet Stream
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Ue Statistics
    Check That Amount Of Compresed And Decompresed Pdus For Profile 1 Is Incremented As Expected For This Traffic Time
    Check That Difference Between Compressed And Decompressed Bytes For Profile 1 Is In Expected Range For This Traffic Time
    Check If Expected Throughout Is Reached And There Are No Packets Lost
    Verify If Rohc Dl And Ul Header Pm Counters Are Incremented

*** Keywords ***
Display Ue Statistics
    Display Qfi stats    qfi_id=3
    Execute Egate Command And Wait For Data    cmd=uec_stats display type=cell_data_pdcp enb=2 cell=1 format=long

Start Dl And Ul Data Traffic For Rtp Packet Stream
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=3 dir=dl rtp_codec=amr_wb_23_85
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=3 dir=ul rtp_codec=amr_wb_23_85

Check That Amount Of Compresed And Decompresed Pdus For Profile 1 Is Incremented As Expected For This Traffic Time
    Rohc Statistic Greater Than Given Value    rohc_statistic_prefix=compressed_pdu    mode=am    value=530    enb_id=2    cell_id=1
    Rohc Statistic Greater Than Given Value    rohc_statistic_prefix=decompressed_profile_1_pdus    mode=am    value=530    enb_id=2    cell_id=1

Check That Difference Between Compressed And Decompressed Bytes For Profile 1 Is In Expected Range For This Traffic Time
    Verify Rohc Compression Ratio    compression_prefix=size_of_compressed_pdus    decompression_prefix=decompressed_profile_1_bytes
    ...    mode=am    value=0.6    margin=0.1    enb_id=2    cell_id=1

Check If Expected Throughout Is Reached And There Are No Packets Lost
    Expected Throughput For Qfi Should Be Reached    ue_id=1    pdu_id=1    qfi_id=3
    ...    expected_throughput=20    unit=kbps    margin=0.2    direction=bi
    Check Number Of Total Packets Lost    ue_id=1    pdu_id=1    qfi_id=3    packet_loss=0
    ...    margin=0.0    direction=bi

Verify If Rohc Dl And Ul Header Pm Counters Are Incremented
    Wait For Next PM counters Interval
    Verify CU Counter Value Is Bigger Than The Given Value
    ...    value=0    local_moid=MRBTS-1/NRBTS-1    counter_id=${COUNTER_ID_DL_NUM_ROHC_COMP_HEADER}
    Verify CU Counter Value Is Bigger Than The Given Value
    ...    value=0    local_moid=MRBTS-1/NRBTS-1    counter_id=${COUNTER_ID_DL_VOL_ROHC_COMP_HEADER}
    Verify CU Counter Value Is Bigger Than The Given Value
    ...    value=0    local_moid=MRBTS-1/NRBTS-1    counter_id=${COUNTER_ID_UL_NUM_ROHC_DECOMP_HEADER}
    Verify CU Counter Value Is Bigger Than The Given Value
    ...    value=0    local_moid=MRBTS-1/NRBTS-1    counter_id=${COUNTER_ID_UL_VOL_ROHC_DECOMP_HEADER}
