*** Settings ***
Resource    CB013554_keywords.robot

Documentation
...    author: Paweł Konieczny
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    release: 25R1

*** Variables ***
${TRAFFIC_DURATION}=   120s
@{RETX_PMQAP_COUNTERS_THR}=
...    ${COUNTER_ID_DL_VOL_RETX_THR1_X2_PMQAP}
...    ${COUNTER_ID_DL_NUM_RETX_THR1_X2_PMQAP}
...    ${COUNTER_ID_DL_VOL_RETX_THR2_X2_PMQAP}
...    ${COUNTER_ID_DL_NUM_RETX_THR2_X2_PMQAP}
...    ${COUNTER_ID_DL_VOL_RETX_THR1_F1_PMQAP}
...    ${COUNTER_ID_DL_NUM_RETX_THR1_F1_PMQAP}
...    ${COUNTER_ID_DL_WOPDU_NUM_SNT_F1_PMQAP}
...    ${COUNTER_ID_DL_WOPDU_NUM_SNT_X2_PMQAP}
...    ${COUNTER_ID_DL_NUM_RETX_LRPT_F1_PMQAP}
...    ${COUNTER_ID_DL_VOL_RETX_LRPT_F1_PMQAP}
...    ${COUNTER_ID_DL_NUM_RETX_LRPT_X2_PMQAP}
...    ${COUNTER_ID_DL_VOL_RETX_LRPT_X2_PMQAP}

@{RETX_QOS_COUNTERS_GRP_06}=
...    ${COUNTER_ID_DL_VOL_RETX_THR1_X2_QOS_GRP_06}
...    ${COUNTER_ID_DL_NUM_RETX_THR1_X2_QOS_GRP_06}
...    ${COUNTER_ID_DL_VOL_RETX_THR2_X2_QOS_GRP_06}
...    ${COUNTER_ID_DL_NUM_RETX_THR2_X2_QOS_GRP_06}
...    ${COUNTER_ID_DL_VOL_RETX_THR1_F1_QOS_GRP_06}
...    ${COUNTER_ID_DL_NUM_RETX_THR1_F1_QOS_GRP_06}
...    ${COUNTER_ID_DL_WOPDU_NUM_SNT_F1_QoS_GRP_06}
...    ${COUNTER_ID_DL_WOPDU_NUM_SNT_X2_QoS_GRP_06}
...    ${COUNTER_ID_NUM_RETRANS_QoS_GRP_06}
...    ${COUNTER_ID_VOL_RETRANS_QoS_GRP_06}
...    ${COUNTER_ID_DL_NUM_RETX_LRPT_F1_QOS_GRP_06}
...    ${COUNTER_ID_DL_VOL_RETX_LRPT_F1_QOS_GRP_06}
...    ${COUNTER_ID_DL_NUM_RETX_LRPT_X2_QOS_GRP_06}
...    ${COUNTER_ID_DL_VOL_RETX_LRPT_X2_QOS_GRP_06}

*** Keywords ***
CB013554-A-B2_2_DL_PDU_Retx_Due_To_Thr_Exceeding
    Enable Pdcp And Rlc Counters Update At Qos Level
    Attach Ue To Enb    ue_id=11
    Start Gnb Addition Procedure    ue=11    bearer=2    target_cells=1    dc_type=split_scg
    Start High Udp Dl Data Traffic
    Force Packet Losts On X2-u
    Trigger Egate Command For Max Attenuation
    Display Bearer Stats For NSA Ue 11
    Detach Ue    ue_id=11
    Verify If Legacy Qos Threshold Retx Counters Were Incremented
    Enable Pdcp And Rlc Counters Update At NRPMQAP Level
    Attach Ue To Enb    ue_id=11
    Start Gnb Addition Procedure    ue=11    bearer=2    target_cells=1    dc_type=split_scg
    Start High Udp Dl Data Traffic
    Force Packet Losts On X2-u
    Trigger Egate Command For Max Attenuation
    Display Bearer Stats For NSA Ue 11
    Detach Ue    ue_id=11
    Verify If NRPMQAP Threshold Retx Counters Were Incremented

Enable 1354-C Pdcp Delay Threshold Based Pdu Retransmission
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/5GC001354/delta_1354-C_PDCP_Delay_Threshold_based_PDU_retransmission.json

Start High Udp Dl Data Traffic
    Execute Egate Command    cmd=trf_data_start ue=11 id=2 dir=dl mbps=175 trf_id=1
    Execute Egate Command    cmd=trf_data_start ue=11 id=2 dir=dl mbps=175 trf_id=2

Force Packet Losts On X2-u
    Execute Egate Command    cmd=bearer_ue_gnb_param ue=11 id=2 dud_retx_indication=on
    Execute Egate Command    cmd=ue_enb_endc_param id=11 bearer=5 dud_drop_cfg=8:5

Display Bearer Stats For NSA Ue 11
    BuiltIn.Sleep    ${TRAFFIC_DURATION}
    Execute Egate Command And Wait For Data    cmd=bearer_stats ue=11 id=2 dir=dl dc_cell_group=mcg
    Execute Egate Command And Wait For Data    cmd=bearer_stats ue=11 id=2 dir=dl dc_cell_group=scg

Trigger Egate Command For Max Attenuation
    Execute Egate Command    cmd=bler_testmode_nr profile_id=1 num_harq_nack=3
    Execute Egate Command    cmd=ue_testmode_set_nr id=11 testmode=bler action=activate profile_id=1 scell=8

Verify If Legacy Qos Threshold Retx Counters Were Incremented
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counters From The List Are Bigger Than The Given Value    counter_list=${RETX_QOS_COUNTERS_GRP_06}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1  filepath=${PM_COUNTERS}
    Verify If Latest Pm Counters In Counter Id List Have Exact Value    counter_id_list=${RETX_PMQAP_COUNTERS_THR}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1      filepath=${PM_COUNTERS}

Verify If NRPMQAP Threshold Retx Counters Were Incremented
    Wait For Next Full Pm Interval
    ${PM_COUNTERS2}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counters From The List Are Bigger Than The Given Value    counter_list=${RETX_PMQAP_COUNTERS_THR}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1    filepath=${PM_COUNTERS2}
    Verify If Latest Pm Counters In Counter Id List Have Exact Value    counter_id_list=${RETX_QOS_COUNTERS_GRP_06}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS2}
