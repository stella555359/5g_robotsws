# robocop: off=unused-argument
*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>


*** Keywords ***
Get measId matching reportConfig with ${event_id:[^\s]+} for UE${ue_id:\d+}
    get_active_measurements     UE_${ue_id}         enable_logging=${True}
    ${report_id}=    Get reportConfigId field value from reportConfig with (${event_id} is present) for UE_${ue_id}
    ${meas_id}=      Get measId field value from measId with (reportConfigId eq ${report_id}) for UE_${ue_id}
    RETURN        ${meas_id}

Perform ${freq_type:intra|inter}-frequency intra-gNB handover from gNB${gnb_id} cell${src_cell} to cell${tgt_cell} for UE${ue_id:\d+}
    ${freq_type}=    Set Variable  ${freq_type}

    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC MeasurementReport triggering intra-gNB HO
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration with target cell configuration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

    Run keyword and continue on failure
    ...     UE${ue_id} triggers Intra-gNB Handover from gNB2 cell${src_cell} to cell${tgt_cell} by sending A3 measurement

    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC MeasurementReport triggering intra-gNB HO
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration with target cell configuration
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

UE${ue_id:\d+} triggers successful NG HO from simulated_gNB to real_gNB
    EXPECT FLOW[timeout=10]: AMF1 NGAP handoverPreparation
    EXPECT FLOW[timeout=10]: AMF1 NGAP handoverResourceAllocation
    EXPECT FLOW[timeout=10]: AMF1 NGAP uplinkRANStatusTransfer
    EXPECT FLOW[timeout=10]: AMF1 NGAP downlinkRANStatusTransfer
    EXPECT FLOW[timeout=10]: AMF1 NGAP handoverNotification
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

    Run keyword and continue on failure
    ...     UE${ue_id} triggers Inter-gNB Handover from simulated gNB3 to real gNB2 by sending A5 measurement

    PASS FLOW[timeout=10]: AMF1 NGAP handoverPreparation
    PASS FLOW[timeout=10]: AMF1 NGAP handoverResourceAllocation
    PASS FLOW[timeout=10]: AMF1 NGAP uplinkRANStatusTransfer
    PASS FLOW[timeout=10]: AMF1 NGAP downlinkRANStatusTransfer
    PASS FLOW[timeout=10]: AMF1 NGAP handoverNotification
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

UE${ue_id:\d+} triggers successful XN HO from simulated_gNB to real_gNB
    EXPECT FLOW[timeout=10]: gNB3 XNAP handoverPreparation
    EXPECT FLOW[timeout=10]: gNB3 XNAP sNStatusTransfer
    EXPECT FLOW[timeout=10]: AMF1 NGAP pathSwitchRequest
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

    UE${ue_id} triggers Inter-gNB Handover from simulated gNB3 to real gNB2 by sending A3 measurement

    PASS FLOW[timeout=10]: gNB3 XNAP handoverPreparation
    PASS FLOW[timeout=10]: gNB3 XNAP sNStatusTransfer
    PASS FLOW[timeout=10]: AMF1 NGAP pathSwitchRequest
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

Try to perform ${freq_type}-frequency inter-gNB handover from simulated gNB${gnb_src} to real gNB${gnb_tgt} for UE${ue_id} and expcet fail
    ${freq_type}=    Set Variable  ${freq_type}
    Execute egate command
    ...     cmd=ue_measurement_send_nr id=${ue_id} meas_id=5 event=A5 srsrp_nr=18 phycell_id=50 nrsrp_nr=85
    ...     pass_regexp=UE${ue_id}: Unsuccessful outcome for XnAP::HandoverPreparation is received. Handover canceled.

UE${ue_id:\d+} triggers Intra-gNB Handover from gNB${gnb_id} cell${cell_src} to cell${cell_tgt} by sending ${event_id:A3|A5} measurement
    IF  "${cell_tgt}" == "1"
         Execute egate command   cmd=ue_measurement_send_nr id=${ue_id} meas_id=1 event=${event_id} srsrp_nr=18 phycell_id=50 nrsrp_nr=85
    ELSE IF  "${cell_tgt}" == "2"
         Execute egate command   cmd=ue_measurement_send_nr id=${ue_id} meas_id=1 event=${event_id} srsrp_nr=18 phycell_id=51 nrsrp_nr=85
    END

UE${ue_id:\d+} triggers Inter-gNB Handover from real gNB${gnb_src} to simulated gNB${gnb_tgt} by sending ${event_id:A3|A5} measurement
    ${meas_id}=     Get measId matching reportConfig with event${event_id} for UE${ue_id}
    Execute egate command
    ...     cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_id} srsrp_nr=19 srsrq_nr=10 phycell_id=52 nrsrp_nr=85 nrsrq_nr=31
    ...     pass_regexp=UE${ue_id}: Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1 performed
    Sleep  1

UE${ue_id:\d+} triggers Inter-gNB Handover from simulated gNB${gnb_src} to real gNB${gnb_tgt} by sending ${event_id:A3|A5} measurement
    Execute egate command   cmd=ue_measurement_send_nr id=${ue_id} meas_id=5 event=${event_id} srsrp_nr=18 phycell_id=50 nrsrp_nr=85
    ...     pass_regexp=UE${ue_id}: Inter-eNB handover from ENB-3.1 to EXT_ENB-2.1 performed
    Sleep  1

UE${ue_id:\d+} triggers Inter-gNB Handover from real gNB${gnb_src} to simulated gNB${gnb_tgt} by sending ${event_id:A3|A5} measurement id=${meas_id}
    Execute egate command
    ...     cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_id} srsrp_nr=19 srsrq_nr=10 phycell_id=52 nrsrp_nr=85 nrsrq_nr=31
    ...     pass_regexp=UE${ue_id}: Inter-eNB handover from EXT_ENB-2.1 to ENB-3.1 performed
    Sleep  1

UE${ue_id:\d+} triggers Inter-gNB Handover from simulated gNB${gnb_src} to real gNB${gnb_tgt} by sending ${event_id:A3|A5} measurement id=${meas_id}
    Execute egate command   cmd=ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=${event_id} srsrp_nr=18 phycell_id=50 nrsrp_nr=85
    ...     pass_regexp=UE${ue_id}: Inter-eNB handover from ENB-3.1 to EXT_ENB-2.1 performed
    Sleep  1

Perform inter-gNB handover from simulated gNB${gnb_src} to gnb${gnb_tgt} for UE${ue_id:\d+} with 5QI${5qi_gbr}
    EXPECT FLOW[timeout=10]: gNB${gnb_src}_XN XNAP handoverPreparation,sNStatusTransfer
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    EXPECT FLOW[timeout=10]: AMF1 NGAP pathSwitchRequest

    UE${ue_id} triggers Inter-gNB Handover from simulated gNB${gnb_src} to real gNB${gnb_tgt} by sending A5 measurement
    Verify that XNAP Inter-gNB Handover was completed successfully for UE${ue_id} with 1 nonGBR and 1 GBR 5QI${5qi_gbr} QoS flow

Set up inter gNB Handover for UE${ue_id:\d+}
    Execute egate command
    ...     cmd=ue_history_information_list_add_ngran id=1 gnb_id=3 cell_type=medium nrcgi=311:489|0x01 time_ue_stayed_in_cell=100
    Execute egate command
    ...     cmd=ue_history_information_list_add_ngran id=1 gnb_id=2 cell_type=medium nrcgi=311:489|0x01 time_ue_stayed_in_cell=100
    Execute egate command   cmd=ue_history_information_list id=1 action=commit
    Execute egate command   cmd=ue_enb_param id=${ue_id} ue_history_list=1

Configure AMFs[${amf_list}] to include HO capabilities when UE attaches
    ${ue_capa_c2}=    Set Variable   015082821200000010980080004daa01100268000400404d4de0000000000000454000000000000054044500
    Execute egate command
    ...     cmd=ics_amf_ue_param id=${amf_list} include_ue_capabilities=yes ue_capabilities=${ue_capa_c2}

Deconfigure AMFs[${amf_list}] from including HO capabilities when UE attaches
    Execute egate command
    ...     cmd=ics_amf_ue_param id=${amf_list} include_ue_capabilities=no

Perform inter RAT handover to LTE for UE${ue_id:\d+}
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC MeasurementReport A2
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration with measurement B2 installation
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    Save last measurement count   UE_${ue_id}
    ${meas_id}=         Get measId matching reportConfig with eventA2 for UE${ue_id}
    Send measurement report for UE${ue_id} with parameters: meas_id=${meas_id} event=A2 srsrp_nr=10

    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC MeasurementReport A2
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration with measurement B2 installation
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC MeasurementReport B2
    EXPECT FLOW[timeout=10]: AMF1 NGAP handoverPreparation
    EXPECT FLOW[timeout=10]: AMF1 NGAP handoverResourceAllocation
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC MobilityFromNRCommand
    EXPECT FLOW[timeout=10]: AMF1 NGAP handoverNotification
    EXPECT FLOW[timeout=10]: AMF1 NGAP uEContextRelease

    Wait for next measurement after saved       UE_${ue_id}
    ${meas_id}=     Get measId matching reportConfig with eventB2 for UE${ue_id}
    Send measurement report for UE${ue_id} with parameters: meas_id=${meas_id} event=B2 srsrp_nr=19 srsrq_nr=10 phycell_id=11 nrsrp_nr=85 nrsrq_nr=31

    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC MeasurementReport B2
    PASS FLOW[timeout=10]: AMF1 NGAP handoverPreparation
    PASS FLOW[timeout=10]: AMF1 NGAP handoverResourceAllocation
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC MobilityFromNRCommand
    PASS FLOW[timeout=10]: AMF1 NGAP handoverNotification
    PASS FLOW[timeout=10]: AMF1 NGAP uEContextRelease

Perform unsuccessfull inter RAT handover to LTE due to handover preparation failure for UE${ue_id:\d+}
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC MeasurementReport A2
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration with measurement B2 installation
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

    Send measurement report for UE${ue_id} with parameters: meas_id=1 event=A2 srsrp_nr=10

    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC MeasurementReport A2
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfiguration with measurement B2 installation
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete

    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC MeasurementReport B2
    EXPECT FLOW[timeout=10]: AMF1 NGAP handoverPreparationFailure

    Send measurement report for UE${ue_id} with parameters: meas_id=2 event=B2 srsrp_nr=19 srsrq_nr=10 phycell_id=11 nrsrp_nr=85 nrsrq_nr=31

    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC MeasurementReport B2
    PASS FLOW[timeout=10]: AMF1 NGAP handoverPreparationFailure

Perform inter RAT handover from LTE to 5G for UE${ue_id:\d+}
    EXPECT FLOW[timeout=10]: AMF1 NGAP handoverPreparation
    EXPECT FLOW[timeout=10]: AMF1 NGAP handoverResourceAllocation
    EXPECT FLOW[timeout=10]: UE_${ue_id} RRC MobilityFromEUTRACommand
    EXPECT FLOW[timeout=10]: AMF1 NGAP handoverNotification
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    EXPECT FLOW[timeout=10]: AMF1 NGAP uEContextRelease

    Trigger inter RAT handover from LTE to 5G for UE${ue_id}

    PASS FLOW[timeout=10]: AMF1 NGAP handoverPreparation
    PASS FLOW[timeout=10]: AMF1 NGAP handoverResourceAllocation
    PASS FLOW[timeout=10]: UE_${ue_id} RRC MobilityFromEUTRACommand
    PASS FLOW[timeout=10]: AMF1 NGAP handoverNotification
    PASS FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    PASS FLOW[timeout=10]: AMF1 NGAP uEContextRelease

#   This will cause dryrun fail until messageing is available
    ${flow_alias_rrc}=     Get flow name
    ...     MobilityFromEUTRACommand
    ...     device=UE_${ue_id}
    ...     protocol=RRC

    Verify That Message Fulfills Query
    ...     (spCellConfigDedicated is present)
    ...     message_alias=MobilityFromEUTRACommand
    ...     flow_alias=${flow_alias_rrc}

Perform inter-gNB handover from sim gNB${gnb_src} to real gNB${gnb_tgt} for UE${ue_id:\d+} with 5QI${5qi_gbr} for FDD-TDD configuration
    EXPECT FLOW[timeout=10]: gNB${gnb_src}_XN XNAP handoverPreparation,sNStatusTransfer
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    EXPECT FLOW[timeout=10]: AMF1 NGAP pathSwitchRequest

    Execute egate command   cmd=ue_measurement_send_nr id=${ue_id} meas_id=1 event=A2 srsrp_nr=5 phycell_id=50 nrsrp_nr=85
    ...     pass_regexp=UE${ue_id}: Filling Freq Band IndicatorNR with band :78
    ...     pass_regexp=UE${ue_id}: Filling Freq Band IndicatorNR with band :71
    Sleep  2

    Execute egate command   cmd=ue_measurement_send_nr id=${ue_id} meas_id=11 event=A5 srsrp_nr=18 phycell_id=50 nrsrp_nr=85
    ...     pass_regexp=UE${ue_id}: Inter-eNB handover from ENB-3.1 to EXT_ENB-2.1 performed
    Sleep  1

    Verify that XNAP Inter-gNB Handover was completed successfully for UE${ue_id} with 1 nonGBR and 1 GBR 5QI${5qi_gbr} QoS flow

Perform inter-gNB handover from simulated gNB${gnb_src} to real gnb${gnb_tgt} for UE${ue_id:\d+} with 5QI${5qi_gbr} and DRX
    EXPECT FLOW[timeout=10]: gNB${gnb_src}_XN XNAP handoverPreparation,sNStatusTransfer
    EXPECT FLOW[timeout=10]: UE_${ue_id} 2 times NR-RRC RRCReconfiguration
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    EXPECT FLOW[timeout=10]: AMF1 NGAP pathSwitchRequest

    UE${ue_id} triggers Inter-gNB Handover from simulated gNB${gnb_src} to real gNB${gnb_tgt} by sending A5 measurement
    Verify that XNAP Inter-gNB Handover was completed successfully for UE${ue_id} with 1 nonGBR and 1 GBR 5QI${5qi_gbr} QoS flow

Perform inter-gNB handover from sim gNB${gnb_src} to gNB${gnb_tgt} for UE${ue_id:\d+} with 5QI1, 5QI5 and 5QI${5qi_gbr:\d+}
    EXPECT FLOW[timeout=10]: gNB${gnb_src}_XN XNAP handoverPreparation,sNStatusTransfer
    EXPECT FLOW[timeout=10]: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    EXPECT FLOW[timeout=10]: AMF1 NGAP pathSwitchRequest

    UE${ue_id} triggers Inter-gNB Handover from simulated gNB${gnb_src} to real gNB${gnb_tgt} by sending A5 measurement
    Verify that XNAP Inter-gNB Handover was completed successfully for UE${ue_id} with 5QI1, 5QI5 and 5QI${5qi_id} QoS flows

Perform intra-gNB A5 handover from gNB${gnb_id} cell${src_cell} to cell${tgt_cell} for UE${ue_id:\d+}
    EXPECT FLOW: UE_${ue_id} NR-RRC MeasurementReport triggering intra-gNB HO
    EXPECT FLOW: UE_${ue_id} NR-RRC RRCReconfiguration with target cell configuration
    EXPECT FLOW: UE_${ue_id} NR-RRC RRCReconfigurationComplete

    Send measurement report for UE1 with parameters: meas_id=2 event=A5 srsrp_nr=18 phycell_id=51 nrsrp_nr=85

    PASS FLOW: UE_${ue_id} NR-RRC MeasurementReport triggering intra-gNB HO
    PASS FLOW: UE_${ue_id} NR-RRC RRCReconfiguration with target cell configuration
    PASS FLOW: UE_${ue_id} NR-RRC RRCReconfigurationComplete
    Verify that UE${ue_id} RRCReconfiguration that target PCI: 51 is present

Try to perform inter RAT handover from LTE to 5G for UE${ue_id:\d+} and fail with cause=${cause:\S+}
    EXPECT FLOW[timeout=10]: AMF1 NGAP handoverPreparationFailure
    Trigger inter RAT handover from LTE to 5G for UE${ue_id}
    PASS FLOW[timeout=10]: AMF1 NGAP handoverPreparationFailure

    Verify handover preparation failure during incoming interRAT HO with cause=${cause}

Send measurement report for UE${ue_id:\d+} with parameters: ${params}
    Execute egate command  cmd=ue_send_measurement_nr id=${ue_id} ${params}

Trigger inter RAT handover from LTE to 5G for UE${ue_id:\d+}
    Execute egate command  cmd=5g_gnb_trigger_inter_rat_handover_to ue=${ue_id} target_gnb=2 target_cell=1 plmn=311:489
