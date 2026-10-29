*** Settings ***
Resource    ../CNI-86916_PDCP_status_handling_during_SANSA_Mobility/keywords_CNI-86916.robot
Library     ../CNI-86916_PDCP_status_handling_during_SANSA_Mobility/keywords_CNI-86916.py
Library     ta5g_tshark
Library     ta5g_pm_counters

Documentation
...    This file contains general keywords used for testing Feature CB001354.

*** Variables ***
${DDDS_THSARK_ALIAS}=     Ddds_tshark
${DDDS_FILTER}=     nr_u.PDU.Type == 1
${UE_NR_CAPA}=    21000000010800000004DE4D0780720800000520800001520800002524A000034C00454000000000000054
${UE_EUTRA_NR_CAPA}=    A10180902C100389A0000008800B0400F89A000008000800080402004008
${a3_params}=    event=A3 srsrp_nr=11 srsrq_nr=11 ssinr_nr=11 phycell_id=51 nrsrp_nr=30 nrsrq_nr=30 nsinr_nr=30

*** Keywords ***
Enable 1354-A
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/5GC001354/delta_1354-A_On.json

Enable 1354-A With Retxbasedonfc
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/5GC001354/delta_1354-A_On_retxBasedOnFC.json

Enable 1354-B
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/5GC001354/delta_1354-B_On.json

Enable 1354-C
    Enable X2 Measurments
    Enable F1 Measurments
    Enable Split F1UX2U
    Enable 1354-C Pdcp Delay Threshold Based Pdu Retransmission For Two Pdcp Instances

Enable 1354-C Pdcp Delay Threshold Based Pdu Retransmission For Two Pdcp Instances
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/5GC001354/delta_1354-C_PDCP_Delay_Threshold_based_PDU_retransmission_2_PDCP.json

Enable 1354-C Pdcp Delay Threshold Based Pdu Retransmission
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/5GC001354/delta_1354-C_PDCP_Delay_Threshold_based_PDU_retransmission.json
    Sleep    180s

Set Drxlongcycle To 320ms
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/delta_set_drxLongCycle_320ms.json

Set Dlmaxretx Threshold To T1 And Dltpollretr To Ms5
    Send Delta Commissioning    input_filepath=${DELTA_FILES_PATH}/5GC001354/delta_set_dlMaxRetxThreshold_to_t1_and_dlTPollRetr_to_ms5.json


Add Nr Cappa
    Execute Egate Command   cmd=ue_param id=${UE_DC_ID} ue_nr_capabilities=${UE_NR_CAPA}
    Execute Egate Command   cmd=ue_param id=${UE_DC_ID} ue_eutra_nr_capabilities=${UE_EUTRA_NR_CAPA}

Start Dl Data Traffic
    [Arguments]    ${ue_id}=11    ${bearer_id}=2    ${mbps}=5mbps    ${protocol}=tcp
    Execute Egate Command    cmd=debug_log level=6
    Start Data Traffic    ues=${ue_id}    bearer_id=${bearer_id}    direction=dl    throughput=${mbps}    optional_parameters=protocol=${protocol}

Trigger Handover to second cell
    Execute Egate Command   cmd=ue_measurement_send_nr id=${UE_DC_ID} meas_id=1 ${a3_params}

Trigger Egate Command For Max Attenuation
    Execute Egate Command    cmd=bler_testmode_nr profile_id=1 num_harq_nack=7
    Execute Egate Command    cmd=ue_testmode_set_nr id=11 testmode=bler action=activate profile_id=1 scell=8

Display Bearer Stats
    [Arguments]    ${ue_id}=11    ${bearer_id}=2
    Execute Egate Command And Wait For Data    cmd=bearer_stats ue=${ue_id} id=${bearer_id}

Force Packet Losts On X2-U
    Execute Egate Command    cmd=bearer_ue_gnb_param ue=11 id=2 dud_retx_indication=on
    Execute Egate Command    cmd=ue_enb_endc_param id=11 bearer=5 dud_drop_cfg=5:5

Verify If 1354-A Counters For Qos Group 06 Were Incremented
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_DL_NUM_RETX_LRPT_X2_QOS_GRP_06}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_DL_VOL_RETX_LRPT_X2_QOS_GRP_06}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}

Verify If 1354-B Counters For Qos Group 06 Were Incremented
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_DL_NUM_DUP_X2_QOS_GRP_06}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_DL_VOL_DUP_X2_QOS_GRP_06}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}

Verify If 1354-B Counters For Qos Group 09 Were Incremented
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_DL_NUM_DUP_X2_QOS_GRP_09}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_DL_VOL_DUP_X2_QOS_GRP_09}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}

Verify If 1354-C Threshld 1 Qos Grp 6 X2 Pm Counters Were Incremented
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_DL_VOL_RETX_THR1_X2_QOS_GRP_06}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_DL_NUM_RETX_THR1_X2_QOS_GRP_06}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}

Verify If 1354-C Treshold 1 Transmission Delay Bin Pm Counters Were Incremented
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Any Pm Counters Are Bigger Than Given Value    counter_id=${COUNTERS_LIST_BIN_THRESH_1}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}

Verify If 1354-C Threshld 2 Qos Grp 6 X2 Pm Counters Were Incremented
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_DL_VOL_RETX_THR2_X2_QOS_GRP_06}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_DL_NUM_RETX_THR2_X2_QOS_GRP_06}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}

Verify If 1354-C Treshold 2 Transmission Delay Bin Pm Counters Were Incremented
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Any Pm Counters Are Bigger Than Given Value    counter_id=${COUNTERS_LIST_BIN_THRESH_2}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}

Verify If Dl Pdcp Sdus Were Transmitted For Nsa Bearer
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_DL_SDU_TX_NSA_QOS_GRP_06}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_DL_VOL_TX_NSA_QOS_GRP_06}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}

Verify If DL Pdcp Pdu Were Sent Over Nr X2-u Dl Gtp-u Tunnel
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_DL_PDCP_NUM_SNT_X2_QOS_GRP_06}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}

Verify If 1354-A X2 Retx Grp6 Counters Were Incremented
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_DL_NUM_RETX_LRPT_X2_QOS_GRP_06}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_DL_VOL_RETX_LRPT_X2_QOS_GRP_06}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}

Verify If 1354-A F1 Retx Grp6 Counters Were Incremented
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_DL_NUM_RETX_LRPT_F1_QOS_GRP_06}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_DL_VOL_RETX_LRPT_F1_QOS_GRP_06}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}

Verify That Due To High Attenuation Some Dl Pdcp Pdus Exceeded Max Delay Allowed For Retransmissioncn Qos Group 06
    ${PM_COUNTERS}=    Get Latest Unpacked Full Pm Counters File
    Verify If Latest Pm Counter Is Bigger Than The Given Value    counter_id=${COUNTER_ID_PDCP_PDU_NOT_RETX_MAX_DLY_06}
    ...    value=0    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1    filepath=${PM_COUNTERS}

Check For Ddds Messages Existence Due To Periodic Duplicate Transmission
    Start tshark
    ...    log_filename=wireshark_eth3.pcap
    ...    eth_interface=eth3
    ...    alias=${DDDS_THSARK_ALIAS}
    Start counting packets
    ...    timeout=60
    ...    packet_filter=${DDDS_FILTER}
    ...    alias=${DDDS_THSARK_ALIAS}
    Wait for given packets number    packet_number=20    alias=${DDDS_THSARK_ALIAS}    timeout=60
    Stop counting packets    alias=${DDDS_THSARK_ALIAS}
    Stop Capturing    alias=${DDDS_THSARK_ALIAS}
    Stop tshark    alias=${DDDS_THSARK_ALIAS}
