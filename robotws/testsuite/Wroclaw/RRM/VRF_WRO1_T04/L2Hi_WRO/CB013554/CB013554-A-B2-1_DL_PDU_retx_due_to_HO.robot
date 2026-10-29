*** Settings ***
Resource    CB013554_keywords.robot

Documentation
...    author: Paweł Konieczny
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    release: 25R1

*** Variables ***
${TRAFFIC_DURATION_SEC}=   30s
${srsrp_part}=    srsrp_nr=11 srsrq_nr=11 ssinr_nr=11
${nrsrp_part}=    nrsrp_nr=30 nrsrq_nr=30 nsinr_nr=30
${UE_NR_CAPA}=    21000000010800000004DE4D0780720800000520800001520800002524A000034C00454000000000000054
${UE_EUTRA_NR_CAPA}=    A10180902C100389A0000008800B0400F89A000008000800080402004008
@{RETX_QOS_COUNTERS_GRP_06_09}=
...    ${COUNTER_ID_DL_NUM_RETX_HO_X2_QOS_GRP_09}
...    ${COUNTER_ID_DL_VOL_RETX_HO_X2_QOS_GRP_09}
...    ${COUNTER_ID_DL_NUM_RETX_HO_F1_QOS_GRP_06}
...    ${COUNTER_ID_DL_VOL_RETX_HO_F1_QOS_GRP_06}
...    ${COUNTER_ID_DL_NUM_DUP_X2_QOS_GRP_06}
...    ${COUNTER_ID_DL_VOL_DUP_X2_QOS_GRP_06}

@{RETX_PMQAP_COUNTERS_HO}=
...    ${COUNTER_ID_DL_NUM_RETX_HO_X2_PMQAP}
...    ${COUNTER_ID_DL_VOL_RETX_HO_X2_PMQAP}
...    ${COUNTER_ID_DL_NUM_RETX_HO_F1_PMQAP}
...    ${COUNTER_ID_DL_VOL_RETX_HO_F1_PMQAP}
...    ${COUNTER_ID_DL_NUM_DUP_X2_PMQAP}
...    ${COUNTER_ID_DL_VOL_DUP_X2_PMQAP}

*** Keywords ***
CB013554-A-B2-1_DL_PDU_Retx_Due_To_HO_And_Duplication
    Enable Pdcp And Rlc Counters Update At Qos Level
    Attach SA And NSA Ues And Start Gnb Addition
    Start Multi UE Udp Dl Data Traffic
    Trigger Handover To Second Cell For Ue 1 And 14
    Display Bearer Stats For NSA Ue 11 And 14
    Detach Multiple Ues
    Verify If Handover Qos Grp 9 X2 and F1 Pm Counters Were Incremented
    Enable Pdcp And Rlc Counters Update At NRPMQAP Level
    Execute Egate Command    cmd=ue_change_location id=1 cell=1
    Attach SA And NSA Ues And Start Gnb Addition
    Start Multi UE Udp Dl Data Traffic
    Trigger Handover To Second Cell For Ue 1 And 14
    Display Bearer Stats For NSA Ue 11 And 14
    Detach Multiple Ues
    Verify If Handover Pmqap X2 and F1 Pm Counters Were Incremented

Start Multi UE Udp Dl Data Traffic
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=120
    Execute Egate Command    cmd=trf_data_start ue=11 id=2 dir=dl mbps=60
    Execute Egate Command    cmd=trf_data_start ue=14 id=2 dir=dl mbps=60
    BuiltIn.Sleep    ${TRAFFIC_DURATION_SEC}

Display Bearer Stats For NSA Ue 11 And 14
    BuiltIn.Sleep    ${TRAFFIC_DURATION_SEC}
    Execute Egate Command And Wait For Data    cmd=bearer_stats ue=11 id=2 dir=dl
    Execute Egate Command And Wait For Data    cmd=bearer_stats ue=14 id=2 dir=dl
    Execute Egate Command And Wait For Data    cmd=qfi_stats ue=1 pdu=1 qfi=1 dir=dl

Trigger Handover To Second Cell For Ue 1 And 14
    Intercell Handover Trigger By A3    ue_id=1    dst_cell=2    dst_phy_cell_id=51
    Execute Egate Command   cmd=ue_measurement_send_nr id=14 meas_id=1 event=A3 ${srsrp_part} phycell_id=51 ${nrsrp_part}
    BuiltIn.Sleep    5s

Attach SA And NSA Ues And Start Gnb Addition
    Register Ue With Default Pdu Session
    Execute Egate Command    cmd=ue_param id=14 ue_nr_capabilities=${UE_NR_CAPA}
    Execute Egate Command    cmd=ue_param id=14 ue_eutra_nr_capabilities=${UE_EUTRA_NR_CAPA}
    Attach Ue With Sgnb
    Attach Ue With Sgnb    ue_id=14

Verify If Handover Qos Grp 9 X2 and F1 Pm Counters Were Incremented
    Wait For Next Full Pm Interval
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counters From The List Are Bigger Than The Given Value    counter_list=${RETX_QOS_COUNTERS_GRP_06_09}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1  filepath=${PM_COUNTERS}
    Verify If Latest Pm Counters In Counter Id List Have Exact Value    counter_id_list=${RETX_PMQAP_COUNTERS_HO}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1      filepath=${PM_COUNTERS}

Verify If Handover Pmqap X2 and F1 Pm Counters Were Incremented
    Wait For Next Full Pm Interval
    ${PM_COUNTERS2}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counters From The List Are Bigger Than The Given Value    counter_list=${RETX_PMQAP_COUNTERS_HO}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1    filepath=${PM_COUNTERS2}
    Verify If Latest Pm Counters In Counter Id List Have Exact Value    counter_id_list=${RETX_QOS_COUNTERS_GRP_06_09}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS2}

Detach Multiple Ues
    Detach Ue    ue_id=11
    Detach Ue    ue_id=14
    Deregister Ue    ue_id=1
