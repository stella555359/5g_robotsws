*** Settings ***
Documentation    :copyright: Nokia
Resource    ../../../resources/airphone/5G_SW_WRO_Keywords.robot
Library    ta5g_testline_management
Library    ta5g_ue_measurements
Library    ta5g_enb
Library    ta5g_pm_counters
Library    ta5g_delta
Library    ta5g_iphy
Library    ta5g_throughput
Library    ta5g_syslog

*** Variables ***
${NRRRC_MCC} =    nr-rrc.MCC_MNC_Digit == 3 && nr-rrc.MCC_MNC_Digit == 1 && nr-rrc.MCC_MNC_Digit == 1
${NRRRC_MNC} =    nr-rrc.MCC_MNC_Digit == 4 && nr-rrc.MCC_MNC_Digit == 8 && nr-rrc.MCC_MNC_Digit == 9
${NRREL_OBJECT_CREATION_TIME} =    70
${NRADJNRCELL_OBJECT_CREATION_TIME} =    70
${EXPECTED_NRREL_OBJECTID}=    256
${EXPECTED_NRADJNRCELL_OBJECTID}=    12288
${CGI_REPORT_FOR_CELL_151}=    ${F1AP_UE_CONTEXT_MODIFICATION_REQUEST} && nr-rrc.cellForWhichToReportCGI == 151
${CGI_REPORT_FOR_CELL_60}=    ${F1AP_UE_CONTEXT_MODIFICATION_REQUEST} && nr-rrc.cellForWhichToReportCGI == 60
${MEASGAPCONFIG_AFTER_FIRST_A5_EVENT_FROM_UE}=    nr-rrc.reportConfigId == 3 && nr-rrc.gapUE == 1 && nr-rrc.eventId == 4
${MEASGAPCONFIG_AFTER_SECOND_A5_EVENT_FROM_UE}=    nr-rrc.reportConfigId == 7 && nr-rrc.gapUE == 1 && nr-rrc.eventId == 4
${DRX_CONFIG_AFTER_A5_EVENT_FROM_UE}=    nr-rrc.drx_Config == 0 && nr-rrc.gapUE == 1
${RECONFIGURATION_REPORT_NR_CGI} =    ${RRC_RECONFIGURATION} && nr-rrc.reportType == reportCGI && nr-rrc.cellForWhichToReportCGI
${RECONFIGURATION_REPORT_MEASUREMENT_GAP_1} =    ${RRC_RECONFIGURATION} && nr-rrc.gapUE == 0 && nr-rrc.measIdToRemoveList == 1
${RECONFIGURATION_REPORT_MEASUREMENT_GAP_2} =    ${RRC_RECONFIGURATION} && nr-rrc.gapUE == 0 && nr-rrc.measIdToRemoveList == 2
${UE_CONTEXT_MODIFICATION_MEASUREMENT_GAP_RELEASE}=    ${F1AP_UE_CONTEXT_MODIFICATION_RESPONSE} && f1ap.DUtoCURRCInformation_element
...    && nr-rrc.MeasGapConfig_element && nr-rrc.release_element && nr-rrc.gapUE == 0
${UE_CONTEXT_MODIFICATION_MEASUREMENT_GAP_DRX_RELEASE}=    ${F1AP_UE_CONTEXT_MODIFICATION_RESPONSE} && f1ap.DUtoCURRCInformation_element
...    && nr-rrc.MeasGapConfig_element && nr-rrc.release_element && nr-rrc.drx_Config == 0 && nr-rrc.gapUE == 1
${DRX_PROFILE}=    ${F1AP_DL_RRC_MESSAGE_TRANSFER} && nr-rrc.drx_Config && nr-rrc.drx_InactivityTimer == 14 && nr-rrc.drx_LongCycleStartOffset == 11
${RECONFIGURATION_REPORT_NR_CGI_NOCONF} =    ${RRC_RECONFIGURATION_COMPLETE} && nr-rrc.rrc_TransactionIdentifier == 2
${HANDOVER_SUCCESS}=    ${F1AP_UE_CONTEXT_MODIFICATION_RESPONSE} && nr-rrc.physCellId == 51 && f1ap.protocolIEs == 3
${HANDOVER_REQUIRED_TRANSFER}=    ${NGAP_HANDOVER_REQUIRED_TRANSFER} && ngap.NRCellIdentity == 0x0000010006
${NG_HANDOVER_SUCCESS} =    ${NGAP_UE_CONTEXT_RELEASE_COMMAND} && ${SUCCESSFUL_HANDOVER}

${F1AP_UE_CONTEXT_MODIFICATION_REQUEST_SEND_TO_DU}=    ${F1AP_UE_CONTEXT_MODIFICATION_REQUEST} && nr-rrc.measIdToAddModList == 1
...    && nr-rrc.cellForWhichToReportCGI == 30
${F1AP_UE_CONTEXT_MODIFICATION_RESPONSE_MEAS_GAP_SET_TO_RELEASE}=    ${F1AP_UE_CONTEXT_MODIFICATION_RESPONSE}
...    && nr-rrc.cellGroupId == 0 && nr-rrc.gapUE == 0
${F1AP_UE_CONTEXT_MODIFICATION_REQUEST_INTERRAT}=    ${F1AP_UE_CONTEXT_MODIFICATION_REQUEST} && nr-rrc.cellForWhichToReportCGI == 30
${F1AP_UE_CONTEXT_MODIFICATION_RESPONSE_INTERRAT}=    ${F1AP_UE_CONTEXT_MODIFICATION_RESPONSE} && nr-rrc.drx_Config == 1 &&
...    nr-rrc.mAC_CellGroupConfig.skipUplinkTxDynamic == 0 && !nr-rrc.physCellId == 50
${HANDOVER_INTERRAT_DONE}=    ${NGAP_UE_CONTEXT_RELEASE_COMMAND} && ${SUCCESSFUL_HANDOVER}

${MEAS_GAP_RELEASE}=    x2ap.SgNBModificationRequest_element && nr-rrc.measGapConfig == 0
${DRX_SETUP}=    x2ap.SgNBModificationRequired_element && nr-rrc.drx_Config == 1
${FAILED_HO_REGEXP}=    Bearer-type change from SCG-split to MCG is successful
${SUCCESSFUL_HO_REGEXP}=    Proxy \\(eNB 2 cell 2\\) reported successful RA
${RRC_RECONFIGURATION_MEASGAPCONFIG_UE2}=    iphy.ue_id == 2 && nr-rrc.MeasId == 6 && nr-rrc.gapUE == 1

*** Keywords ***
Attach Ue And Establish Pdu Session And Send A2 Measurement 9009
    [Arguments]    ${ue_id}=1   ${pdu_id}=1   ${gw_id}=1   ${meas_id}=1
    Attach UE    ue_id=${ue_id}
    Establish PDU Session With Traffic   ue_id=${ue_id}    pdu_id=${pdu_id}   gw_id=${gw_id}
    Sleep    5s    reason=Waiting for RRCReconfigurationComplete for A2 measurement report setup
    Send A2 Measurement  ue_id=${ue_id}    meas_id=${meas_id}
    Sleep    5s    reason=Delay between sending measurments

Send B2 Measurement
    [Arguments]    ${ue_id}=1   ${meas_id}=3    ${target_phycell_id}=30    ${nrsrp_nr}=60    ${nrsrq_nr}=30
    Send Custom Ue Measurement Nr    pass_regexp=measResultListEUTRA  get_ue_meas_cfg=1  id=${ue_id}  meas_id=${meas_id}  index=0
    ...                              nrs_result=${nrsrp_nr}:${nrsrq_nr}:0  event=B2  srsrp_nr=11  srsrq_nr=11  srs_result=0:11:11:0
    ...                              phycell_id=${target_phycell_id}  nrsrp_nr=${nrsrp_nr}  nrsrq_nr=${nrsrq_nr}  rs_type=ssb

Verify Successfull InterRAT HO
    Verify Tcpdump Log    packet_filter=${NGAP_HANDOVER_REQUIRED}
    Verify Tcpdump Log    packet_filter=${NGAP_HANDOVER_COMMAND}
    Verify Tcpdump Log    packet_filter=${HANDOVER_INTERRAT_DONE}
    Verify Loopback Messages    packet_filter=${NGAP_HANDOVER_NOTIFY}

Verify Existing NRREL
    Wait For Object To Exist    object_name=NRCELL_A-2/NRREL_A-${EXPECTED_NRREL_OBJECTID}    moc=NRREL_A    timeout=${NRREL_OBJECT_CREATION_TIME}

Verify Existing NRRELE
    Wait For Object To Exist    object_name=NRCELL_A-1/NRRELE_A-${EXPECTED_NRREL_OBJECTID}    moc=NRRELE_A
    ...    timeout=${NRREL_OBJECT_CREATION_TIME}

Attach Ue And Establish Pdu Session
    [Arguments]    ${ue_id}    ${pdu_id}=1    ${gw_id}=1
    Attach UE    ue_id=${ue_id}
    Establish PDU Session With Traffic    ue_id=${ue_id}  pdu_id=${pdu_id}  gw_id=${gw_id}
    Sleep    2s  reason=Waiting for RRCReconfigurationComplete for A2 measurement report setup

Attach Ue And Establish Pdu Session And Send A2 Measurement
    [Arguments]    ${ue_id}    ${pdu_id}=1    ${gw_id}=1    ${meas_id}=1
    Attach Ue And Establish Pdu Session    ue_id=${ue_id}  pdu_id=${pdu_id}  gw_id=${gw_id}
    Send A2 Measurement    ue_id=${ue_id}  meas_id=${meas_id}

Send A2 Measurement
    [Arguments]    ${ue_id}    ${meas_id}=1
    Send Custom Ue Measurement Nr    pass_regexp=ServingCellMO is not present in CellGroupConfig  get_ue_meas_cfg=1
    ...                              id=${ue_id}  meas_id=${meas_id}  event=A2  srsrp_nr=11  srsrq_nr=11  srs_result=0:11:11:0
    Sleep    3s  reason=Waiting for A5 measurement report setup

Send A5 Measurement And Attempt Handover
    [Arguments]    ${ue_id}    ${meas_id}=3    ${target_phycell_id}=51    ${nrsrp_nr}=60    ${nrsrq_nr}=30
    Execute Egate Command    cmd=ue_nr_rrc_reconf_param id=${ue_id} if_contains=report_cgi anr_cgi_delay=200
    Sleep    1s    reason=Waiting for delay request to be processed
    Send Custom Ue Measurement Nr    pass_regexp=measResultListNR  get_ue_meas_cfg=1  id=${ue_id}  meas_id=${meas_id}  index=0
    ...                              nrs_result=${nrsrp_nr}:${nrsrq_nr}:0  event=A5  srsrp_nr=11  srsrq_nr=11  srs_result=0:11:11:0
    ...                              phycell_id=${target_phycell_id}  nrsrp_nr=${nrsrp_nr}  nrsrq_nr=${nrsrq_nr}  rs_type=ssb
    Sleep    3s  reason=Waiting for handover request to be processed

Send A5 Measurement And Attempt Handover Without Delay
    [Arguments]    ${ue_id}    ${meas_id}=3    ${target_phycell_id}=51    ${nrsrp_nr}=60    ${nrsrq_nr}=30
    Send Custom Ue Measurement Nr    pass_regexp=measResultListNR  get_ue_meas_cfg=1  id=${ue_id}  meas_id=${meas_id}  index=0
    ...                              nrs_result=${nrsrp_nr}:${nrsrq_nr}:0  event=A5  srsrp_nr=11  srsrq_nr=11  srs_result=0:11:11:0
    ...                              phycell_id=${target_phycell_id}  nrsrp_nr=${nrsrp_nr}  nrsrq_nr=${nrsrq_nr}  rs_type=ssb
    Sleep    3s  reason=Waiting for handover request to be processed

Attach Ue And Establish Pdu Session And Send A5 Measurement For Inter Freq HO
    [Arguments]    ${ue_id}    ${pdu_id}=1    ${gw_id}=1    ${meas_id}=3    ${meas_idA2}=1    ${target_phycell_id}=51
    ...            ${nrsrp_nr}=60    ${nrsrq_nr}=30
    Attach Ue And Establish Pdu Session And Send A2 Measurement    ue_id=${ue_id}  pdu_id=${pdu_id}  gw_id=${gw_id}  meas_id=${meas_idA2}
    Send A5 Measurement And Attempt Handover    ue_id=${ue_id}  meas_id=${meas_id}  target_phycell_id=${target_phycell_id}
    ...                                         nrsrp_nr=${nrsrp_nr}  nrsrq_nr=${nrsrq_nr}

Set Ue Nr Rrc To Reestablish After Failed Handover
    [Arguments]    ${ue_id}=3
    Execute Egate Command    cmd=ue_nr_rrc_reconf_param if_contains=reconfiguration_with_sync action=reestablish cause=handoverFailure id=${ue_id}

Set Gnb To Fail Handover Preparation
    [Arguments]    ${gnb_id}=3
    Execute Egate Command    cmd=gnb_xn_handover_preparation_param action=force_failure id=${gnb_id}

Reset Gnb Param For Successfull Handover Preparation
    [Arguments]    ${gnb_id}=3
    Execute Egate Command    cmd=gnb_xn_handover_preparation_param id=${gnb_id} reset

Set Ue To Fail Handover And Send A5 Measurement
    [Arguments]    ${ue_id}    ${meas_id}=3    ${target_phycell_id}=51    ${nrsrp_nr}=60    ${nrsrq_nr}=30
    Set Ue Nr Rrc To Reestablish After Failed Handover    ue_id=${ue_id}
    Send A5 Measurement And Attempt Handover    ue_id=${ue_id}  meas_id=${meas_id}  target_phycell_id=${target_phycell_id}
    ...                                         nrsrp_nr=${nrsrp_nr}  nrsrq_nr=${nrsrq_nr}

Send A2 Measurement And Send Failing A5 Measurement
    [Arguments]    ${ue_id}    ${meas_idA2}=1    ${meas_idA5}=3    ${target_phycell_id}=51    ${nrsrp_nr}=60
    ...            ${nrsrq_nr}=30
    Send A2 Measurement    ue_id=${ue_id}  meas_id=${meas_idA2}
    Set Ue To Fail Handover And Send A5 Measurement    ue_id=${ue_id}  meas_id=${meas_idA5}  target_phycell_id=${target_phycell_id}
    ...                                                nrsrp_nr=${nrsrp_nr}  nrsrq_nr=${nrsrq_nr}

Wait And Verify Created NRREL Object
    [Arguments]    ${gnb_id}=3    ${NRREL_ID}=256
    Wait For Object To Exist    object_name=NRCELL_A-1/NRREL_A-${NRREL_ID}  moc=NRREL_A  timeout=${NRREL_OBJECT_CREATION_TIME}
    &{NRREL}=    Get Managed Object    object_name=NRCELL_A-1/NRREL_A-${NRREL_ID}    moc=NRREL_A
    Verify Created NRREL Object    NRREL=&{NRREL}  mcc=${NRREL.gnbPlmn.mcc}  mnc=${NRREL.gnbPlmn.mnc}
    ...                            mncLength=${NRREL.gnbPlmn.mncLength}  gNbId=${gnb_id}  gNbIdLength=${NRREL.gNbIdLength}
    ...                            lcrId=${NRREL.lcrId}

Verify Created NRADJNRCELL And NRREL Objects
    [Arguments]    ${PCI}=151     ${gNB_id}=3    ${NRADJNRCELL_ID}=12288    ${fiveGsTac}=788    ${NRREL_ID}=256
    Wait For Object To Exist    object_name=NRADJNRCELL_A-${NRADJNRCELL_ID}  moc=NRADJNRCELL_A  timeout=${NRADJNRCELL_OBJECT_CREATION_TIME}
    Wait For Object To Exist    object_name=NRCELL_A-1/NRREL_A-${NRREL_ID}  moc=NRREL_A  timeout=${NRREL_OBJECT_CREATION_TIME}
    &{NRADJNRCELL}=    Get Managed Object  object_name=NRADJNRCELL_A-${NRADJNRCELL_ID}  moc=NRADJNRCELL_A
    &{NRREL}=    Get Managed Object  object_name=NRCELL_A-1/NRREL_A-${NRREL_ID}  moc=NRREL_A
    Verify Created NRADJNRCELL Object    NRADJNRCELL=&{NRADJNRCELL}  mcc=${NRADJNRCELL.gnbPlmn.mcc}  mnc=${NRADJNRCELL.gnbPlmn.mnc}
    ...                            mncLength=${NRADJNRCELL.gnbPlmn.mncLength}  physCellId=${PCI}  cellDepType=SA+NSA
    ...                            nrarfcn=636000  ssbFrequency=636000  gNbId=${gNB_id}  gNbIdLength=${NRADJNRCELL.gNbIdLength}
    ...                            lcrId=${NRADJNRCELL.lcrId}
    ...                            fiveGsTac=${fiveGsTac}
    Verify Created NRREL Object    NRREL=&{NRREL}  mcc=${NRREL.gnbPlmn.mcc}  mnc=${NRREL.gnbPlmn.mnc}
    ...                            mncLength=${NRREL.gnbPlmn.mncLength}  gNbId=${gNB_id}  gNbIdLength=${NRREL.gNbIdLength}
    ...                            lcrId=${NRREL.lcrId}

Wait And Verify NRREL Object Still Exist
    [Arguments]    ${timeout}=120s    ${gnb_id}=1
    Sleep    ${timeout}  reason=Verify that NRREL isnt deleted before last failing measurement
    Wait And Verify Created NRREL Object    gnb_id=${gnb_id}

Verify Traces For Reconfiguration Containing EUTRA CGI Measurement Report Configuration And Inter Frequency HO
    [Arguments]    ${Meas_gap}=1    ${Nr_cgi_report}=2    ${Handover_success_msg}=1    ${Meas_gap_release}=1    ${Meas_gap_drx_release}=1
    ...            ${meas_id_to_remove_list}=1
    ${RECONFIGURATION_REPORT_MEASUREMENT_GAP}    Set Variable If    ${meas_id_to_remove_list} == 1    ${RECONFIGURATION_REPORT_MEASUREMENT_GAP_1}
    ...    ${RECONFIGURATION_REPORT_MEASUREMENT_GAP_2}
    Verify Tcpdump Log    packet_filter=${RECONFIGURATION_REPORT_MEASUREMENT_GAP}  number_of_messages=${Meas_gap}
    Verify Tcpdump Log    packet_filter=${UE_CONTEXT_MODIFICATION_MEASUREMENT_GAP_RELEASE}  number_of_messages=${Meas_gap_release}
    Verify Tcpdump Log    packet_filter=${UE_CONTEXT_MODIFICATION_MEASUREMENT_GAP_DRX_RELEASE}  number_of_messages=${Meas_gap_drx_release}
    Verify Tcpdump Log    packet_filter=${RECONFIGURATION_REPORT_NR_CGI}  number_of_messages=${Nr_cgi_report}
    Verify Tcpdump Log    packet_filter=${DRX_PROFILE}
    Verify Tcpdump Log    packet_filter=${HANDOVER_SUCCESS}  timeout=120  number_of_messages=${Handover_success_msg}

Start Vm Ethernet Interfaces
    Start Vm Ethernet Interface    if_name=eth3:gNB2_XN  ip_with_mask=10.0.1.101/24
    Start Vm Ethernet Interface    if_name=eth3:gNB2_NG  ip_with_mask=10.0.1.102/24
    Start Vm Ethernet Interface    if_name=eth3:gNB4_XN  ip_with_mask=10.0.1.103/24
    Start Vm Ethernet Interface    if_name=eth3:gNB4_NG  ip_with_mask=10.0.1.104/24
    Start Vm Ethernet Interface    if_name=eth3:gNB2_X2    ip_with_mask=10.0.1.3/24
    Start Vm Ethernet Interface    if_name=eth3:eNB1_X2    ip_with_mask=10.0.1.138/24

Stop Vm Ethernet Interfaces
    Stop Vm Ethernet Interface    if_name=eth3:gNB2_XN  ip_with_mask=10.0.1.101/24
    Stop Vm Ethernet Interface    if_name=eth3:gNB2_NG  ip_with_mask=10.0.1.102/24
    Stop Vm Ethernet Interface    if_name=eth3:gNB4_XN  ip_with_mask=10.0.1.103/24
    Stop Vm Ethernet Interface    if_name=eth3:gNB4_NG  ip_with_mask=10.0.1.104/24
    Stop Vm Ethernet Interface    if_name=eth3:gNB2_X2    ip_with_mask=10.0.1.3/24
    Stop Vm Ethernet Interface    if_name=eth3:eNB1_X2    ip_with_mask=10.0.1.138/24

RRC Reestablish
    [Arguments]    ${ue_id}
    Ue Nr Rrc Reconf Param    ue_id=${ue_id}  if_contains=report_cgi  action=reestablish

Delay For T321 Timeout
    [Arguments]    ${ue_id}
    Ue Nr Rrc Reconf Param    ue_id=${ue_id}  if_contains=report_cgi  action=donot_send_NRCGI

Drop NrCgi
    [Arguments]    ${ue_id}
    Ue Nr Rrc Reconf Param    ue_id=${ue_id}  if_contains=report_cgi  action=drop

Report NoSIB1
    [Arguments]    ${ue_id}
    Ue Nr Rrc Reconf Param    ue_id=${ue_id}  if_contains=report_cgi  action=report_noSIB1

Verify Traces For No Reconfiguration Containing NR CGI Measurement Report Configuration
    [Arguments]    ${Report_CGI}=0    ${XNAP_HO_Req}=0
    Verify Tcpdump Log    packet_filter=${RECONFIGURATION_REPORT_NR_CGI}  number_of_messages=${Report_CGI}
    Verify Tcpdump Log    packet_filter=${XNAP_HANDOVER_REQUEST}  number_of_messages=${XNAP_HO_Req}

Verify Traces For Reconfiguration Containing NR CGI Measurement Report Configuration And HO
    [Arguments]    ${Meas_gap}=1    ${NR_CGI_report}=1    ${Handover_success_msg}=1
    Verify Tcpdump Log    packet_filter=${RECONFIGURATION_REPORT_MEASUREMENT_GAP_1}  number_of_messages=${Meas_gap}
    Verify Tcpdump Log    packet_filter=${RECONFIGURATION_REPORT_NR_CGI}  number_of_messages=${NR_cgi_report}
    Verify Ngap Messages    packet_filter=${HANDOVER_SUCCESS}  timeout=120  number_of_messages=${Handover_success_msg}

Verify Traces For Xn Handover
    [Arguments]    ${Meas_gap}=1    ${NR_CGI_report}=1    ${Handover_success_msg}=1    ${Handover_request_msg}=1    ${UE_CtxRel_msg}=1
    Verify Tcpdump Log    packet_filter=${RECONFIGURATION_REPORT_MEASUREMENT_GAP_2}  number_of_messages=${Meas_gap}
    Verify Tcpdump Log    packet_filter=${RECONFIGURATION_REPORT_NR_CGI}  number_of_messages=${NR_cgi_report}
    Verify Tcpdump Log    packet_filter=${XNAP_HANDOVER_REQUEST}  timeout=120  number_of_messages=${Handover_request_msg}
    Verify Tcpdump Log    packet_filter=${XNAP_HANDOVER_REQUEST_ACK}  timeout=120  number_of_messages=${Handover_success_msg}
    Verify Tcpdump Log    packet_filter=${XNAP_SN_STATUS_TRANSFER}  timeout=120  number_of_messages=${Handover_success_msg}
    Verify Tcpdump Log    packet_filter=${XNAP_UE_CONTEXT_RELEASE}  timeout=120  number_of_messages=${Handover_success_msg}
    Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_RELEASE_COMPLETE}  timeout=120  number_of_messages=${UE_CtxRel_msg}

Check Bearer Stats
    [Arguments]              ${ue_id}=5    ${pdu_id}=1    ${qfi_id}=1    ${dir}=dl    ${pass_regexp}=12
    Execute Egate Command    cmd=bearer_stats ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} dir=${dir}    pass_regexp=\(${pass_regexp}\.\\d K\)

Verify Traces For MeasGapConfig After A2 Event From UE2
    Verify Uu Messages    packet_filter=${RRC_RECONFIGURATION_MEASGAPCONFIG_UE2}

Verify Traces For Ng Handover
    Verify Ngap Messages    packet_filter=${HANDOVER_REQUIRED_TRANSFER}
    Verify Ngap Messages    packet_filter=${NG_HANDOVER_SUCCESS}

Verify Traces For Handover
    [Arguments]    ${number_of_messages}=0
    Verify Ngap Messages    packet_filter=${HANDOVER_SUCCESS}    timeout=120    number_of_messages=${number_of_messages}

Verify Traces For cellForWhichToReportCGI_151
    Verify Tcpdump Log    packet_filter=${CGI_REPORT_FOR_CELL_151}

Verify Traces For cellForWhichToReportCGI_60
    Verify Tcpdump Log    packet_filter=${CGI_REPORT_FOR_CELL_60}

Verify Traces For MeasGapConfig After First A5 Event From UE
    Verify Uu Messages    packet_filter=${MEASGAPCONFIG_AFTER_FIRST_A5_EVENT_FROM_UE}

Verify Traces For MeasGapConfig After Second A5 Event From UE
    Verify Uu Messages    packet_filter=${MEASGAPCONFIG_AFTER_SECOND_A5_EVENT_FROM_UE}

Verify Traces For DRX Config Release After A5 Event From UE
    [Arguments]    ${number_of_messages}=1
    Verify Uu Messages    packet_filter=${DRX_CONFIG_AFTER_A5_EVENT_FROM_UE}    number_of_messages=${number_of_messages}
