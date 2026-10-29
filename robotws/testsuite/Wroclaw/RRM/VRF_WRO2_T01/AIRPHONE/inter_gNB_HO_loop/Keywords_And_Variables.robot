*** Settings ***
Documentation    :copyright: Nokia
Resource         testsuite/Wroclaw/RRM/resources/airphone/5G_SW_WRO_Keywords.robot
Resource         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/ute_report.robot
Library          testsuite/Wroclaw/RRM/resources/airphone/multignb_testlines_variables.py
Library          ta5g_testline_management
Library          ta5g_ue_measurements
Library          ta5g_pm_counters
Library          ta5g_throughput
Library          ta5g_ue_mobility
Library          ta5g_iphy
Library          ta5g_enb
Library          ta_messaging
Resource         testsuite/Wroclaw/RRM/resources/airphone/5G_SW_WRO_Keywords.robot

*** Variables ***
@{REMOTE_HOSTS} =                   ${EMPTY}
${XNAP_nGRANnodeConfigurationUpdate}=        xnap.procedureCode == 18
${X2AP_endcX2Setup}=                         x2ap.procedureCode == 36
${NRRRC_measResultServingMOList}=            nr-rrc.measResultServingMOList == 1
${NRRRC_measResultNeighCells_for_50}=        (nr-rrc.measResultNeighCells == 0) && (nr-rrc.physCellId == 50)
${NRRRC_measResultNeighCells_for_54}=        (nr-rrc.measResultNeighCells == 0) && (nr-rrc.physCellId == 54)
${NRRRC_measResultNeighCells_for_55}=        (nr-rrc.measResultNeighCells == 0) && (nr-rrc.physCellId == 55)
${XN_HandoverRequest_and_Acknowledge}=       xnap.procedureCode == 0


*** Keywords ***
Send Command To establish X2 link setup
    [Arguments]     ${enb_id}=1    ${enb_MN_id}=2    ${enb_SN_id}=3
    Execute Egate Command   cmd=x2_link_up_enb enb=${enb_id} target=${enb_MN_id}
    BuiltIn.Sleep  4s    Wait for X2 link setup for enb: ${enb_id} and target: ${enb_MN_id}

    Execute Egate Command   cmd=x2_link_up_enb enb=${enb_id} target=${enb_SN_id}
    BuiltIn.Sleep  4s    Wait for X2 link setup for enb: ${enb_id} and target: ${enb_SN_id}


Attach UE${ue_id:\d+} And Establish PDU Session On GNB${gnb_id:\d+}
    BuiltIn.Sleep    2s
    Attach_ue    ue_id=${ue_id}    enb=${gnb_id}    cell=1
    Set Internal Traffic Type For UE    ue_id=${ue_id}    pdu_id=1
    Establish Pdu Session        ue_id=${ue_id}    timeout=30


Trigger A${event_id:\d+} event for UE${ue_id:\d+} with inter-HO to NRCELL-${nrcell_id:\d+} and SSB Frequency ${ssbFrequency:\d+}
    Execute egate command  cmd=ue_disp id=${ue_id}
    BuiltIn.Sleep    2s
    Execute egate command  cmd=ue_meas_cfg_disp id=${ue_id}
    BuiltIn.Sleep    2s
    Execute egate command  cmd=ue_ho_nr ue_id=${ue_id} tgt_phycell_id=${nrcell_id} meas_type=A${event_id} tgt_cell_ssb_frequency=${ssbFrequency}


Trigger A${event_id:\d+} event for UE${ue_id:\d+} with intra-GNB-HO to NRCELL-${nrcell_id:\d+} and SSB Frequency ${ssbFrequency:\d+}
    Execute egate command  cmd=ue_disp id=${ue_id}
    BuiltIn.Sleep    2s
    Execute egate command  cmd=ue_meas_cfg_disp id=${ue_id}
    BuiltIn.Sleep    2s
    Execute egate command  cmd=ue_ho_nr ue_id=${ue_id} tgt_phycell_id=${nrcell_id} meas_type=A${event_id} tgt_cell_ssb_frequency=${ssbFrequency}


Expect RRC messages flow for UE${ue_id:[1-9]} during UE Attach prcedure
   Expect Message Flow
   ...     UE_${ue_id}:NR-RRC_RRCSetupRequest as RRCSetup
   ...     UE_${ue_id}:NR-RRC_RRCSetup
   ...     UE_${ue_id}:NR-RRC_RRCSetupComplete
   ...     alias=UE${ue_id}_RRC_attach
   ...     overall_timeout=30


Expect NGAP messages flow for UE${ue_id:[1-9]} during UE Attach prcedure
   Expect Message Flow
   ...     AMF1:NGAP_InitialUEMessage as InitalMessage
   ...     AMF1:NGAP_InitialContextSetupRequest as ICS_Req
   ...     AMF1:NGAP_InitialContextSetupResponse
   ...     alias=UE${ue_id}_NGAP_attach
   ...     overall_timeout=30


Verify Primary Node Flow for UE
    Verify Tcpdump Log    packet_filter=${X2AP_endcX2Setup}                          number_of_messages=2
    Verify Tcpdump Log    packet_filter=${NRRRC_measResultServingMOList}             number_of_messages=6
    Verify Tcpdump Log    packet_filter=${XN_HandoverRequest_and_Acknowledge}        number_of_messages=4     relation_symbol= >=
    Verify Tcpdump Log    packet_filter=${NRRRC_measResultNeighCells_for_54}
    Verify Tcpdump Log    packet_filter=${NRRRC_measResultNeighCells_for_55}
    Verify Tcpdump Log    packet_filter=${NRRRC_measResultNeighCells_for_50}         number_of_messages=3


Verify PM counters on MasterNode gNB and SecondaryNode gNB sides
    ${pm_counter_file_after_test_MN}=     Get Next Unpacked Raw Pm Counters File
    ${pm_counter_file_after_test_SN}=     Get Latest Unpacked Raw Pm Counters File      remote_host=${REMOTE_HOST_1_IP}


    Verify Any Counters In File
    ...    M55147C00024   2    TOT_INTER_FREQ_HO_DECISION_A3       # PCell on MN gNB1 side cell-50
    ...    M55143C00001   2    XN_HO_REQ_ACK_RECEIVED              # PCell on MN gNB1 side cell-50
    ...    local_moid=MRBTS-1/NRBTS-1/NRCELL-1                     # MN gNB1 side cell-50
    ...    file_path=${pm_counter_file_after_test_MN}
    ...    taf_report.report_pm_counter=True


    Verify Any Counters In File
    ...    M55147C00024   1    TOT_INTER_FREQ_HO_DECISION_A3       # PCell on MN gNB2 side cell-55
    ...    M55143C00001   1    XN_HO_REQ_ACK_RECEIVED              # PCell on MN gNB2 side cell-55
    ...    local_moid=MRBTS-1/NRBTS-2/NRCELL-6                     # MN gNB2 side cell-55
    ...    file_path=${pm_counter_file_after_test_SN}
    ...    taf_report.report_pm_counter=True


    Verify Any Counters In File
    ...    M55147C00024   1    TOT_INTER_FREQ_HO_DECISION_A3       # PCell on MN gNB2 side cell-54
    ...    M55143C00001   1    XN_HO_REQ_ACK_RECEIVED              # PCell on MN gNB2 side cell-54
    ...    local_moid=MRBTS-1/NRBTS-2/NRCELL-5                     # MN gNB2 side cell-54
    ...    file_path=${pm_counter_file_after_test_SN}
    ...    taf_report.report_pm_counter=True


    Verify Any Counters In File
    ...    M55147C00024   1    TOT_INTER_FREQ_HO_DECISION_A3        # PCell on MN gNB1 side cell-51
    ...    local_moid=MRBTS-1/NRBTS-1/NRCELL-2                      # MN gNB1 side cell-51
    ...    file_path=${pm_counter_file_after_test_MN}
    ...    taf_report.report_pm_counter=True


    Verify Any Counters In File
    ...    M55147C00024   1    TOT_INTER_FREQ_HO_DECISION_A3       # PCell on MN gNB2 side cell-54
    ...    M55143C00001   1    XN_HO_REQ_ACK_RECEIVED              # PCell on MN gNB2 side cell-54
    ...    local_moid=MRBTS-1/NRBTS-2/NRCELL-5                     # MN gNB side cell-54
    ...    file_path=${pm_counter_file_after_test_SN}
    ...    taf_report.report_pm_counter=True
