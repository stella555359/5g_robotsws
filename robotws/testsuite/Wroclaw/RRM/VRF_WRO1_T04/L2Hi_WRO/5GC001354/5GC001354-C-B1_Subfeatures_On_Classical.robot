*** Settings ***
Resource    CB001354_keywords.robot

Documentation
...    author: Pawel Konieczny
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    release: 23R1

*** Variables ***
${TRAFFIC_DURATION_SEC}=    10s

*** Keywords ***
5GC001354-C-B1_Nsa_Non_Gbr_Drb_Pdcp_Delay_Threshold_Based_Pdu_Retransmission_Subfeatures_On_Classical
    Attach Ue With Sgnb
    Start Dl Data Traffic    mbps=120mbps
    Sleep    ${TRAFFIC_DURATION_SEC}
    Force Packet Losts On X2-U
    Sleep    ${TRAFFIC_DURATION_SEC}
    Triggering Attenuation For Treshold Counters
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Bearer Stats
    Wait For Next Full Pm Interval
    Verify If 1354-B Counters For Qos Group 06 Were Incremented
    Verify If Dl Pdcp Sdus Were Transmitted For Nsa Bearer
    Verify If DL Pdcp Pdu Were Sent Over Nr X2-u Dl Gtp-u Tunnel
    Verify If 1354-A Counters Were Incremented
    Verify If 1354-C Threshld 1 X2 Qos Grp 6 Pm Counter Was Incremented
    Verify If 1354-C Threshld 2 X2 Qos Grp 6 Pm Counter Was Incremented
    Detach Ue    ue_id=11

Triggering Attenuation For Treshold Counters
    Execute Egate Command    cmd=bler_testmode_nr profile_id=1 num_harq_nack=5
    Execute Egate Command    cmd=ue_testmode_set_nr id=11 testmode=bler action=activate profile_id=1 scell=8

Verify If 1354-A Counters Were Incremented
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_DL_NUM_RETX_LRPT_X2_QOS_GRP_06}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_DL_VOL_RETX_LRPT_X2_QOS_GRP_06}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}

Verify If 1354-C Threshld 1 X2 Qos Grp 6 Pm Counter Was Incremented
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_DL_NUM_RETX_THR1_X2_QOS_GRP_06}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_DL_VOL_RETX_THR1_X2_QOS_GRP_06}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}

Verify If 1354-C Threshld 2 X2 Qos Grp 6 Pm Counter Was Incremented
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_DL_NUM_RETX_THR2_X2_QOS_GRP_06}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_DL_VOL_RETX_THR2_X2_QOS_GRP_06}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
