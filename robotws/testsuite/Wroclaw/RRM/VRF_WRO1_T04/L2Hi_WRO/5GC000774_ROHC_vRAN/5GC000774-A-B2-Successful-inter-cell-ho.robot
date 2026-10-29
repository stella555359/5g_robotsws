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
...    maintainer: Michal Brychcy (michal.brychcy@nokia.com)
...    testline: CLOUD_5GC_dRNIC_1vDU_P_AP_LO_SWFH
...    release: 22R3

Test Setup    Run Keywords    Update Gscn In Iphy File    GSCN_1=7853    GSCN_2=7853
...   AND   Enable AiC Inter Cell HO
...   AND   Wait For Radio Online Status
...   AND   Configure SA VM interfaces AiC
...   AND   Reach OnAir AiC    lua_cfg=${EPCSIM_CFG_PATH_SA_TDD_AIC}
...   AND   Enable AiC Vonr And Rohc
...   AND   Wait For Next PM counters Interval

Test Teardown     Run Keywords    Deregister Ue   ue_id=1
...   AND   Sleep    3s   Waiting for deregister

*** Variables ***
${TRAFFIC_DURATION_SEC}=   20s
${srsrp_part}=    srsrp_nr=11 srsrq_nr=11 ssinr_nr=11
${nrsrp_part}=    nrsrp_nr=30 nrsrq_nr=30 nsinr_nr=30

*** Test Cases ***
5GC000774-A-B2_Successful_Intra_frequency_intra_DU_intra_gNB_Voice_Over_Nr_handover_With_Rohc_Profile_0x0001_Ipv4
    Attach One 5g Ue Capable Of Supporting Rohc With CS2 HO
    Start VoNR Call
    Check DL And Ul Traffic
    Trigger Handover To Second Cell
    Check DL And Ul Traffic After Handover
    Verify Rohc Contexts Pm Counters Values

*** Keywords ***
Wait For Radio Online Status
    Wait Until Keyword Succeeds    5min    30s    vdu.Check Radio Status
    ...    expected_status=on line

Enable AiC Inter Cell HO
    Perform CU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/Inter_Cell_HO_CU_delta.json
    Perform DU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/Inter_Cell_HO_DU_delta.json
    Sleep    180s

Attach One 5g Ue Capable Of Supporting Rohc With CS2 HO
    Execute Egate Command    cmd=ue_param id=1 ue_nr_capabilities=${UE_CAPA_CS2_HO}
    Attach One 5g Ue Capable Of Supporting Rohc

Start VoNR Call
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=3 dir=dl rtp_codec=amr_wb_23_85
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=3 dir=ul rtp_codec=amr_wb_23_85

Check DL And Ul Traffic
    Sleep    ${TRAFFIC_DURATION_SEC}
    Rohc Statistic Greater Than Given Value    rohc_statistic_prefix=compressed_pdu    mode=am    value=0    enb_id=2    cell_id=1
    Expected Throughput For Qfi Should Be Reached    ue_id=1    pdu_id=1    qfi_id=3
    ...    expected_throughput=20    unit=kbps    margin=0.2    direction=bi
    Check Number Of Total Packets Lost    ue_id=1    pdu_id=1    qfi_id=3    packet_loss=0
    ...    margin=0.0    direction=bi

Trigger Handover To Second Cell
    Execute Egate Command    cmd=ue_measurement_send_nr id=1 meas_id=3 event=A5 srsrp_nr=1 srsrq_nr=10 phycell_id=51 nrsrp_nr=85 nrsrq_nr=101
    ...                      pass_regexp=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed

Check DL And Ul Traffic After Handover
    Sleep    ${TRAFFIC_DURATION_SEC}
    Rohc Statistic Greater Than Given Value    rohc_statistic_prefix=compressed_pdu    mode=am    value=0    enb_id=2    cell_id=2
    Expected Throughput For Qfi Should Be Reached    ue_id=1    pdu_id=1    qfi_id=3
    ...    expected_throughput=20    unit=kbps    margin=0.2    direction=bi
    Check Number Of Total Packets Lost    ue_id=1    pdu_id=1    qfi_id=3    packet_loss=1
    ...    margin=1.0    direction=bi

Verify Rohc Contexts Pm Counters Values
    Wait For Next PM counters Interval
    Verify CU Counter Value Is Exact As Given Value
    ...    value=4    local_moid=MRBTS-1/NRBTS-1    counter_id=${COUNTER_ID_NE1CS_ROHC_DRB_CTX_REQ_SENT}
    Verify CU Counter Value Is Exact As Given Value
    ...    value=4    local_moid=MRBTS-1/NRBTS-1    counter_id=${COUNTER_ID_NE1CS_ROHC_DRB_CTX_RESP_RECD}
    Verify CU Counter Value Is Exact As Given Value
    ...    value=2    local_moid=MRBTS-1/NRBTS-1/NRCELL-2    counter_id=${COUNTER_ID_NRRCC_ROHC_DRB_CTX_REQ_SENT}
    Verify CU Counter Value Is Exact As Given Value
    ...    value=2    local_moid=MRBTS-1/NRBTS-1/NRCELL-2    counter_id=${COUNTER_ID_NRRCC_ROHC_DRB_CTX_CMP_RECD}
