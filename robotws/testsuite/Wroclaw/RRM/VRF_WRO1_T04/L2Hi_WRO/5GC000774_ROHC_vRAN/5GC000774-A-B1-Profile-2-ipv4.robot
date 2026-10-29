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
${UE_CAPA_CS12}=    01A01380310900000004D0100389A000001E000000000000045400000000000005400000400801022280

*** Test Cases ***
5GC000774-A-B1_Successful_Setup_Of_Voice_Over_Nr_Call_With_Rohc_Profile_0x0002_Ipv4
    Attach One 5g Ue Capable Of Supporting Rohc With Ipv4
    Start Dl And Ul Data Traffic For Udp Packet Stream For Certain Amount Of Packets
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Ue Statistics
    Check That Amount Of Compressed And Decompressed Pdus For Profile 2 Is Incremented As Expected
    Check That Difference Between Compressed And Decompressed Bytes For Profile 2 Is As Expected
    Check That There Are No Packets Lost
    Verify If Rohc Dl And Ul Header Pm Counters Have Expected Values
    Verify Rohc Contexts Pm Counters Values

*** Keywords ***
Attach One 5g Ue Capable Of Supporting Rohc With Ipv4
    Execute Egate Command    cmd=ue_param id=1 ue_nr_capabilities=${UE_CAPA_CS12}
    Attach One 5g Ue Capable Of Supporting Rohc

Display Ue Statistics
    Display Qfi stats    qfi_id=3
    Execute Egate Command And Wait For Data    cmd=uec_stats display type=cell_data_pdcp enb=2 cell=1 format=long

Start Dl And Ul Data Traffic For Udp Packet Stream For Certain Amount Of Packets
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=3 dir=dl trf_id=1 kbps=30 packets=50
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=3 dir=ul trf_id=2 kbps=30 packets=50

Check That Amount Of Compressed And Decompressed Pdus For Profile 2 Is Incremented As Expected
    Rohc Statistic Equal To Given Value    rohc_statistic_prefix=compressed_pdu    mode=am    value=50    enb_id=2    cell_id=1
    Rohc Statistic Equal To Given Value    rohc_statistic_prefix=decompressed_profile_2_pdus    mode=am    value=50    enb_id=2    cell_id=1

Check That Difference Between Compressed And Decompressed Bytes For Profile 2 Is As Expected
    Rohc Statistic Equal To Given Value    rohc_statistic_prefix=size_of_compressed_pdus    mode=am    value=54976   enb_id=2    cell_id=1
    Rohc Statistic Equal To Given Value    rohc_statistic_prefix=decompressed_profile_2_bytes    mode=am    value=56250    enb_id=2    cell_id=1

Check That There Are No Packets Lost
    Check Number Of Total Packets Lost    ue_id=1    pdu_id=1    qfi_id=3    packet_loss=0
    ...    margin=0.0    direction=bi

Verify If Rohc Dl And Ul Header Pm Counters Have Expected Values
    Wait For Next PM counters Interval
    Verify CU Counter Value Is Exact As Given Value
    ...    value=50    local_moid=MRBTS-1/NRBTS-1    counter_id=${COUNTER_ID_DL_NUM_ROHC_COMP_HEADER}
    Verify CU Counter Value Is Exact As Given Value
    ...    value=126    local_moid=MRBTS-1/NRBTS-1    counter_id=${COUNTER_ID_DL_VOL_ROHC_COMP_HEADER}
    Verify CU Counter Value Is Exact As Given Value
    ...    value=50    local_moid=MRBTS-1/NRBTS-1    counter_id=${COUNTER_ID_UL_NUM_ROHC_DECOMP_HEADER}
    Verify CU Counter Value Is Exact As Given Value
    ...    value=1400    local_moid=MRBTS-1/NRBTS-1    counter_id=${COUNTER_ID_UL_VOL_ROHC_DECOMP_HEADER}

Verify Rohc Contexts Pm Counters Values
    Verify CU Counter Value Is Exact As Given Value
    ...    value=5    local_moid=MRBTS-1/NRBTS-1    counter_id=${COUNTER_ID_NE1CS_ROHC_DRB_CTX_REQ_SENT}
    Verify CU Counter Value Is Exact As Given Value
    ...    value=5    local_moid=MRBTS-1/NRBTS-1    counter_id=${COUNTER_ID_NE1CS_ROHC_DRB_CTX_RESP_RECD}
    Verify CU Counter Value Is Exact As Given Value
    ...    value=5    local_moid=MRBTS-1/NRBTS-1/NRCELL-1    counter_id=${COUNTER_ID_NRRCC_ROHC_DRB_CTX_REQ_SENT}
    Verify CU Counter Value Is Exact As Given Value
    ...    value=5    local_moid=MRBTS-1/NRBTS-1/NRCELL-1    counter_id=${COUNTER_ID_NRRCC_ROHC_DRB_CTX_CMP_RECD}
