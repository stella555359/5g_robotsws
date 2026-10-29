*** Settings ***
Resource     ../resources/common_keywords_vran.robot

Documentation
...    This file contains keywords used for testing Feature CB001354 on Cloud RINLINE.

*** Keywords ***
Start Data Traffic With Tcp
    ta5g_throughput.Start Data Traffic    ues=11    bearer_id=2    direction=dl    throughput=150mbps    optional_parameters=protocol=tcp trf_id=1
    ta5g_throughput.Start Data Traffic    ues=11    bearer_id=2    direction=ul    throughput=10mbps    optional_parameters=protocol=tcp trf_id=1
    ta5g_throughput.Start Data Traffic    ues=11    bearer_id=2    direction=dl    throughput=150mbps    optional_parameters=protocol=tcp trf_id=2
    ta5g_throughput.Start Data Traffic    ues=11    bearer_id=2    direction=dl    throughput=150mbps    optional_parameters=protocol=tcp trf_id=3
    ta5g_throughput.Start Data Traffic    ues=11    bearer_id=2    direction=dl    throughput=150mbps    optional_parameters=protocol=tcp trf_id=4

Display Bearer Statistics On MCG And SCG
    [Arguments]    ${UE_ID}=${11}
    Execute Egate Command And Wait For Data    cmd=bearer_stats ue=${UE_ID} id=2 dc_cell_group=mcg
    Execute Egate Command And Wait For Data    cmd=bearer_stats ue=${UE_ID} id=2 dc_cell_group=scg

Force Packet Losts On X2-U
    Execute Egate Command    cmd=bearer_ue_gnb_param ue=11 id=2 dud_retx_indication=on
    Execute Egate Command    cmd=ue_enb_endc_param id=11 bearer=5 dud_drop_cfg=5:5

Verify If Dl Pdcp Sdus Were Transmitted For Nsa Bearer
    Verify CU Counter Value Is Bigger Than The Given Value
    ...    value=0    local_moid=MRBTS-1/NRBTS-1    counter_id=${COUNTER_ID_DL_SDU_TX_NSA_QOS_GRP_09}
    Verify CU Counter Value Is Bigger Than The Given Value
    ...    value=0    local_moid=MRBTS-1/NRBTS-1    counter_id=${COUNTER_ID_DL_VOL_TX_NSA_QOS_GRP_09}

Verify If DL Pdcp Pdu Were Sent Over Nr X2-u Dl Gtp-u Tunnel
    Verify CU Counter Value Is Bigger Than The Given Value
    ...    value=0    local_moid=MRBTS-1/NRBTS-1    counter_id=${COUNTER_ID_DL_PDCP_NUM_SNT_X2_QOS_GRP_09}

Verify If 1354-A Retx Counters Were Incremented
    Verify CU Counter Value Is Bigger Than The Given Value
    ...    value=0    local_moid=MRBTS-1/NRBTS-1    counter_id=${COUNTER_ID_DL_NUM_RETX_LRPT_X2_QOS_GRP_09}
    Verify CU Counter Value Is Bigger Than The Given Value
    ...    value=0    local_moid=MRBTS-1/NRBTS-1    counter_id=${COUNTER_ID_DL_VOL_RETX_LRPT_X2_QOS_GRP_09}

Verify If 1354-B Counters Were Incremented
    Verify CU Counter Value Is Bigger Than The Given Value
    ...    value=0    local_moid=MRBTS-1/NRBTS-1    counter_id=${COUNTER_ID_DL_NUM_DUP_X2_QOS_GRP_09}
    Verify CU Counter Value Is Bigger Than The Given Value
    ...    value=0    local_moid=MRBTS-1/NRBTS-1    counter_id=${COUNTER_ID_DL_VOL_DUP_X2_QOS_GRP_09}

Verify If 1354-C Threshld 1 Qos Grp 9 X2 Pm Counters Were Incremented
    Verify CU Counter Value Is Bigger Than The Given Value
    ...    value=0    local_moid=MRBTS-1/NRBTS-1    counter_id=${COUNTER_ID_DL_VOL_RETX_THR1_X2_QOS_GRP_09}
    Verify CU Counter Value Is Bigger Than The Given Value
    ...    value=0    local_moid=MRBTS-1/NRBTS-1    counter_id=${COUNTER_ID_DL_NUM_RETX_THR1_X2_QOS_GRP_09}

Verify If 1354-C Threshld 2 Qos Grp 9 X2 Pm Counters Were Incremented
    Verify CU Counter Value Is Bigger Than The Given Value
    ...    value=0    local_moid=MRBTS-1/NRBTS-1    counter_id=${COUNTER_ID_DL_VOL_RETX_THR2_X2_QOS_GRP_09}
    Verify CU Counter Value Is Bigger Than The Given Value
    ...    value=0    local_moid=MRBTS-1/NRBTS-1    counter_id=${COUNTER_ID_DL_NUM_RETX_THR2_X2_QOS_GRP_09}

Verify That Due To High Attenuation Some Dl Pdcp Pdus Exceeded Max Delay Allowed For Retransmissioncn Qos Group 09
    Verify CU Counter Value Is Bigger Than The Given Value
    ...    value=0    local_moid=MRBTS-1/NRBTS-1    counter_id=${COUNTER_ID_PDCP_PDU_NOT_RETX_MAX_DLY_09}

Verify If 1354-C Treshold 1 Transmission Delay Bin 1 And Bin 2 X2 Pm Counters Were Incremented
    Check If Any Counter From List Is Incremented
    ...    local_moid=MRBTS-1/NRBTS-1    counter_list=${COUNTERS_LIST_BIN_THRESH_1}

Verify If 1354-C Treshold 2 Transmission Delay Bin 1 And Bin 2 X2 Pm Counters Were Incremented
    Check If Any Counter From List Is Incremented
    ...    local_moid=MRBTS-1/NRBTS-1    counter_list=${COUNTERS_LIST_BIN_THRESH_2}

Enable AiC Carrier Aggregation With Blind Scell Activation
    Send XML CU Delta Commisioning    ${DELTA_FILES_PATH_AIC}/Carrier_Aggregation/delta_add_NRREL_For_Two_Cells_CU.xml
    Send XML DU Delta Commisioning    ${DELTA_FILES_PATH_AIC}/Carrier_Aggregation/delta_set_Various_Nrarfcn_DU.xml
    Send XML CU Delta Commisioning    ${DELTA_FILES_PATH_AIC}/Carrier_Aggregation/delta_set_Various_Nrarfcn_CU.xml
    Sleep    180s
    Send XML DU Delta Commisioning    ${DELTA_FILES_PATH_AIC}/Carrier_Aggregation/delta_enable_Ca_Fr1Tdd_Nsa_DU.xml
    Send XML CU Delta Commisioning    ${DELTA_FILES_PATH_AIC}/Carrier_Aggregation/delta_enable_Ca_Fr1Tdd_Nsa_CU.xml

Set AiC Drxlongcycle To 320ms
    Perform CU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/5GC001354/delta_set_drxLongCycle_320ms_CU.json
    Perform DU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/5GC001354/delta_set_drxLongCycle_320ms_DU.json

Enable AiC X2 And F1 Measurements
    Perform CU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/5GC001354/delta_enable_X2_And_F1_Measurements_CU.json

Enable AiC 1354-A
    Perform CU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/5GC001354/delta_enable_1354-A_CU.json

Enable AiC 1354-A_B
    Perform CU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/5GC001354/delta_enable_1354-A_B_CU.json

Enable AiC 1354-C Pdcp Delay Threshold Based Pdu Retransmission
    Perform CU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/5GC001354/delta_enable_1354-C_PDCP_Delay_Threshold_CU.json

Set Aic DlPreferredPath To F1-U
    Perform CU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/delta_set_dlPreferredPath_F1-U_CU.json
