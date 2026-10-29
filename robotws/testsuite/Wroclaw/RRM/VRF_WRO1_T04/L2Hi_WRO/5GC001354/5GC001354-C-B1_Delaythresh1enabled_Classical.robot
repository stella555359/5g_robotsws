*** Settings ***
Resource    CB001354_keywords.robot

Documentation
...    author: Pawel Konieczny
...    maintainer: Pawel Konieczny (pawel.konieczny@nokia.com)
...    release: 23R1

*** Variables ***
${TRAFFIC_DURATION_SEC}=   10s

*** Keywords ***
5GC001354-C-B1_Nsa_Non_Gbr_Drb_Pdcp_Delay_Threshold_Based_Pdu_Retransmission_Delaythresh1enabled_Classical
    Attach Ue With Sgnb
    Start Dl Data Traffic    mbps=150mbps
    Trigger Egate Command For Max Attenuation
    Sleep    ${TRAFFIC_DURATION_SEC}
    Display Bearer Stats
    Wait For Next Full Pm Interval
    Verify If 1354-C Threshld 1 Qos Grp 6 X2 Pm Counters Were Incremented
    Verify If 1354-C Threshld 2 Qos Grp 6 X2 Pm Counters Have Value 0
    Verify If 1354-C Treshold 1 Transmission Delay Bin Pm Counters Were Incremented
    Verify If 1354-C Treshold 2 Transmission Delay Bin 1 And Bin 2 X2 Pm Counters Have Value 0
    Verify That Due To High Attenuation Some Dl Pdcp Pdus Exceeded Max Delay Allowed For Retransmissioncn Qos Group 06
    Detach Ue    ue_id=11

Enable 1354-C With Only Treshold 1 Enabled
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/5GC001354/delta_1354-C_On_Only_Treshol1_Enabled.json

Verify If 1354-C Threshld 2 Qos Grp 6 X2 Pm Counters Have Value 0
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_DL_VOL_RETX_THR2_X2_QOS_GRP_06}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_DL_NUM_RETX_THR2_X2_QOS_GRP_06}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}

Verify If 1354-C Treshold 2 Transmission Delay Bin 1 And Bin 2 X2 Pm Counters Have Value 0
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_PDCP_PDU_RETX_DLY_THR2_BIN_01}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Has Exact Value    counter_id=${COUNTER_ID_PDCP_PDU_RETX_DLY_THR2_BIN_02}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
