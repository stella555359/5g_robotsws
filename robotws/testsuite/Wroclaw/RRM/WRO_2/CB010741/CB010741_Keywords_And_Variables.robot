*** Settings ***
Documentation    :copyright: Nokia

*** Variables ***
@{mplane_cells}=    5    6    9    12
${bufferMonitoring_For_UL} =     itf_l2_ps_user_BufferMonitoringInd_t.bufferMonitoring == 3
${BufferCriterion_For_UL} =       itf_l2_ps_user_BufferCriterionInd_t.bufferCriterion == 1
${sCellULConfigured} =     ((f1ap.SCell_ToBeSetupMod_List == 1) && (f1ap.sCellIndex == 3)) && (f1ap.sCellULConfigured == 1)
${allowedBC} =     ((nr-rrc.allowedBC_ListMRDC == 1) && (nr-rrc.bandCombinationIndex == 2)) && (nr-rrc.FeatureSetEntryIndex == 1)
${SCell_Upgrade_add_and_delete_SCell} =    ((nr-rrc.sCellToAddModList == 1) && (nr-rrc.sCellIndex == 3)&&(nr-rrc.sCellToReleaseList == 1)
    ...                                    && (nr-rrc.sCellIndex == 3))
${SCell_configured_already_as_DL_only} =    (((nr-rrc.sCellToAddModList == 4) && (frame[2041:9] == 40:13:20:06:00:00:01:00:81))
    ...                                     && (f1ap.nRCellIdentity == 00:00:01:00:80)) && (f1ap.radioNetwork == 17)

*** Keywords ***
Verify Counters for CB010741
    ${pm_counter_file}=    Get Next Unpacked Full Pm Counters File
    Verify Any Counters In File
    ...    M55113C00025   +1    SCELL_CONFIG_SUCC_UL_BUFFER_SA
    ...    M55138C03524   +1    GNB_UL_SCELL_1_ADMI_REQ_SA
    ...    M55138C03527   +1    GNB_UL_SCELL_1_ADMI_SUCC_SA
    ...    M55118C11058   >0    GNB_UL_SCELL_1_CONFIG_REQ_SA
    ...    M55139C05516   >0    GNB_DU_UL_SCELL_1_ADMI_REQ_SA
    ...    M55139C01003   >0    GNB_DU_SCELL_1_ADMI_REQ_SA
    ...    M55139C05519   +1    GNB_DU_UL_SCELL_1_ADMI_SUCC_SA
    ...    M55139C01004   >0    GNB_DU_SCELL_1_ADMI_SUCC_SA
    ...    M55118C10001   +1    RRC_RECONF_ADD1ULSCELL_ATT_SA
    ...    M55118C10002   +1    RRC_RECONF_ADD1ULSCELL_SUCC_SA
    ...    M55118C11108   +1    UL_RRC_STEP_SCELL_ADD_ATT_SA
    ...    M55118C11109   +1    UL_RRC_STEP_SCELL_ADD_SUCC_SA
    ...    M55118C11068   +1    GNB_UL_SCELL_1_CONFIG_SUCC_SA
    ...    M55118C00098   >0    SCELL_CONFIG_DUR_SA
    ...    M55118C00097   >0    SCELL_CONFIG_RRC_RECNFG_DUR_SA
    ...    M55118C00099   >0    SCELL_CONFIG_DUR_GNB_MAX
    ...    M55118C11106   <1    DL_RRC_STEP_SCELL_ADD_ATT_SA
    ...    M55118C11107   <1    DL_RRC_STEP_SCELL_ADD_SUCC_SA
    ...    local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-7
    ...    file_path=${PM_COUNTER_FILE}
    ...    rep.report_pm_counter=True

Verify Messages UL Buffer Triggered SCell Upgrade
    Verify Tcpdump Log    packet_filter=${bufferMonitoring_For_UL}     pcap_file_path=${OUTPUT_DIR}/tshark/gnb_F1_E1_RRC.pcap
    ...    number_of_messages=1     relation_symbol= >=    timeout=60
    Verify Tcpdump Log    packet_filter=${BufferCriterion_For_UL}     pcap_file_path=${OUTPUT_DIR}/tshark/gnb_F1_E1_RRC.pcap
    ...    number_of_messages=1     relation_symbol= >=    timeout=60
    Verify Tcpdump Log    packet_filter=${sCellULConfigured}     pcap_file_path=${OUTPUT_DIR}/tshark/gnb_F1_E1_RRC.pcap
    ...    number_of_messages=1     relation_symbol= >=    timeout=60
    Verify Tcpdump Log    packet_filter=${allowedBC}     pcap_file_path=${OUTPUT_DIR}/tshark/gnb_F1_E1_RRC.pcap
    ...    number_of_messages=1     relation_symbol= >=    timeout=60
    Verify Tcpdump Log    packet_filter=${SCell_Upgrade_add_and_delete_SCell}     pcap_file_path=${OUTPUT_DIR}/tshark/gnb_F1_E1_RRC.pcap
    ...    number_of_messages=1     relation_symbol= >=    timeout=60

Verify that SCell is configured already as DL only
    Verify Tcpdump Log    packet_filter=${SCell_configured_already_as_DL_only}    pcap_file_path=${OUTPUT_DIR}/tshark/gnb_F1_E1_RRC.pcap
    ...    number_of_messages=1     relation_symbol= >=    timeout=60

Trigger A1 Measurement
    [Arguments]    ${ue_id}=1    ${meas_id}=1    ${Inactive Timer}=1s
    Execute Egate Command    cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A1 srsrp_nr=90
    sleep    ${Inactive Timer}

Trigger A4 Measurement
    [Arguments]    ${ue_id}=1    ${meas_id}=2    ${Inactive Timer}=3s
    Execute Egate Command    cmd=ue_measurement_send_nr event=A4 phycell_id=58 nrsrp_nr=95 id=${ue_id} meas_id=${meas_id}
    sleep    ${Inactive Timer}

Attach UE And Establish PDU Session
    [Arguments]    ${ue_id}=1    ${cell_id}=7    ${pdu_id}=1    ${gw_id}=1    ${nwslice}=1
    Log  \n==== Attach SA UE And Establish PDU Session ====  console=True
    Execute Egate Command    cmd=ue_change_location id=${ue_id} cell=${cell_id}
    Execute Egate Command    cmd=ue_register id=${ue_id}
    Sleep    1
    Set Internal Traffic Type For UE    ue=1    pdu=1
    Execute Egate Command    cmd=ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} gw=${gw_id} nwslice=${nwslice}
	Sleep    2

Start UL Tput After A4SupervisionTimer expiration
    [Arguments]    ${Inactive Timer}=5s
    sleep    ${Inactive Timer}
    Execute egate command   cmd=trf_data_start ue=1 pdu=1 trf_id=4 dir=ul mbps=150

Start DL Tput
    [Arguments]    ${ue_id}=1    ${pdu_id}=1    ${qfi}=1    ${mbps_per_trf_id}=175    ${first_trf_id}=1    ${last_trf_id}=3
    Log  \n==== Start Full DL througput ====  console=True
    FOR    ${INDEX}  IN RANGE    ${first_trf_id}   ${last_trf_id}+1
        Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=${qfi} trf_id=${INDEX} dir=dl mbps=${mbps_per_trf_id}
    END
