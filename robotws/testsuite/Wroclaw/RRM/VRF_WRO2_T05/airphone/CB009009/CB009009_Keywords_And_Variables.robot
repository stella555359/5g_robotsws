*** Settings ***
Documentation    :copyright: Nokia

Resource     ../../../resources/airphone/5G_SW_WRO_Keywords.robot
Library      ta5g_testline_management
Library      ta5g_ue_measurements
Library      ta5g_pm_counters
Library      ta5g_delta
Library      ta5g_iphy
Library      ta5g_enb


*** Variables ***
${NRREL_OBJECT_CREATION_TIME}=    120
${EXPECTED_NRREL_OBJECTID}=    256
${MODIFICATION_REQ_DRX_RELEASE}=    ${F1AP_UE_CONTEXT_MODIFICATION_REQUEST} && f1ap.DRXConfigurationIndicator == 0
${MODIFICATION_RESP_DRX_RELEASE}=    ${F1AP_UE_CONTEXT_MODIFICATION_RESPONSE} && nr-rrc.drx_Config == 0
${FAILED_HO_REGEXP}=    Bearer-type change from SCG-split to MCG is successful
${SUCCESSFUL_GNB_ADD}=    Proxy \\(eNB 2 cell 1\\) reported successful RA
${NRCGI_REPORT_MEASUREMENT_OBJECT_CONFIGURATION}=    nr-rrc.cellGroupId == 1 && nr-rrc.pSCellFrequency == 636666
...    && nr-rrc.ssbFrequency == 636576
${REPORT_CGI_FOR_CELL}=    nr-rrc.cellForWhichToReportCGI == 51
${DRX_CONFIG_SETUP}=    nr-rrc.drx_Config == 1 && nr-rrc.drx_LongCycleStartOffset == 9
${DRX_RELEASE}=    nr-rrc.drx_Config == 0
${MEAS_GAP_SETUP}=    x2ap.SgNBModificationRequest_element && nr-rrc.measGapConfig == 1
${MEAS_GAP_RELEASE}=    x2ap.SgNBModificationRequest_element && nr-rrc.measGapConfig == 0
${MEAS_CONFIG_SN_EMPTY}=    !nr-rrc.measConfigSN_element
${F1AP_UE_CONTEXT_MODIFICATION_REQ_MEAS_GAP_CONFIG}=    ${F1AP_UE_CONTEXT_MODIFICATION_REQUEST} && nr-rrc.measGapConfig == 0
${X2AP_SGNB_MODIFICATION_REQUEST_ACKNOWLEDGE_MEAS_GAP_CONFIG}=    ${X2AP_SGNB_MODIFICATION_REQUEST_ACKNOWLEDGE} &&
...    nr-rrc.reportConfigToRemoveList == 1
${X2AP_SGNB_MODIFICATION_CONFIRM_RRC_RECONFIG_COMPLETE}=    ${X2AP_SGNB_MODIFICATION_CONFIRM} && nr-rrc.criticalExtensions == 0
${F1AP_UE_CONTEXT_MODIFICATION_REQUEST_REPORT_CGI}=    ${F1AP_UE_CONTEXT_MODIFICATION_REQUEST} && nr-rrc.cellForWhichToReportCGI == 51
${F1AP_UE_CONTEXT_MODIFICATION_RESPONSE_DRX_SETUP}=    ${F1AP_UE_CONTEXT_MODIFICATION_RESPONSE} && nr-rrc.drx_Config == 1
${F1AP_UE_CONTEXT_MODIFICATION_REQUEST_INTERRAT}=    ${F1AP_UE_CONTEXT_MODIFICATION_REQUEST} && nr-rrc.cellForWhichToReportCGI == 30
${F1AP_UE_CONTEXT_MODIFICATION_RESPONSE_INTERRAT}=    ${F1AP_UE_CONTEXT_MODIFICATION_RESPONSE} && nr-rrc.drx_Config == 1 &&
...    nr-rrc.mAC_CellGroupConfig.skipUplinkTxDynamic == 0 && !nr-rrc.physCellId == 50
${F1AP_DL_RRC_RECONFIGURATION}=    f1ap.DLRRCMessageTransfer_element
${F1AP_UL_RRC_RECONFIGURATION}=    f1ap.ULRRCMessageTransfer_element
${F1AP_UE_CONTEXT_MODIFICATION_REQUEST_SEND_TO_DU}=    ${F1AP_UE_CONTEXT_MODIFICATION_REQUEST} && nr-rrc.measIdToAddModList == 2
${F1AP_UE_CONTEXT_MODIFICATION_RESPONSE_MEAS_GAP_SET_TO_RELEASE}=    ${F1AP_UE_CONTEXT_MODIFICATION_RESPONSE}
...    && nr-rrc.cellGroupId == 0 && nr-rrc.gapUE == 0
${X2AP_SGNB_MODIFICATION_REQUIRED_NRCGI_SSB_BAND}=    ${X2AP_SGNB_MODIFICATION_REQUIRED} &&
...    nr-rrc.cellGroupId == 1 && nr-rrc.measId == 4 && nr-rrc.fr_Type == 0 && nr-rrc.ssbFrequency == 637152
${X2AP_SGNB_MODIFICATION_REQUEST_SCF_FAILURE_INFO}=    ${X2AP_SGNB_MODIFICATION_REQUEST} && nr-rrc.failureType == 3

${DEDICATED_DRX_SETUP}=    x2ap.SgNBModificationRequired_element && nr-rrc.drx_Config == 1 && nr-rrc.drx_RetransmissionTimerDL == 0
${DEFAULT_DRX_SETUP}=    x2ap.SgNBModificationRequired_element && nr-rrc.drx_Config == 1 && nr-rrc.drx_RetransmissionTimerDL == 6
${DEDICATED_DRX_SETUP_AND_SKIP_UL_TX_DYNAMIC}=    f1ap.UEContextModificationResponse_element && nr-rrc.drx_Config == 1 &&
...    nr-rrc.drx_RetransmissionTimerDL == 0 && nr-rrc.mAC_CellGroupConfig.skipUplinkTxDynamic == 0
${DRX_DEFAULT_SETUP}=    f1ap.UEContextModificationResponse_element && nr-rrc.drx_RetransmissionTimerDL == 6

${NR_RRC_MEASUREMENT_REPORT_WITH_NOSIB1_IE}=    nr-rrc.measResults_element && nr-rrc.noSIB1_element
${NR_RRC_NO_MEASUREMENT_REPORT_WITH_NRCGI}=    nr-rrc.measResults_element && nr-rrc.cgi_Info_element
${SKIP_UL_TX_DYNAMIC}=    nr-rrc.mAC_CellGroupConfig.skipUplinkTxDynamic == 0
${HANDOVER_INTERRAT_DONE}=    ${NGAP_UE_CONTEXT_RELEASE_COMMAND} && ${SUCCESSFUL_HANDOVER}

*** Keywords ***
Set Ue NR RRC Reconf Param
    [Arguments]    ${ue_id}    ${contains}    ${value}
    Execute Egate Command    cmd=ue_nr_rrc_reconf_param id=${ue_id} if_contains=${contains} action=${value}
    Sleep                    5s    reason=Delay for processing of RRC Reconfiguration

Set Ue RRC Reconf Param
    [Arguments]    ${ue_id}    ${contains}    ${value}
    Execute Egate Command    cmd=ue_rrc_reconf_param id=${ue_id} if_contains=${contains} action=${value}
    Sleep                    5s    reason=Delay for processing of RRC Reconfiguration

Trigger SgNB Change Refuse
    Execute Egate Command
    ...    cmd=gnb_endc_param id=3 sgnb_failure_scenario=reject_sgnb_addition_request

Turn On DRX And Measurement Gap
    [Arguments]  ${ue_id}
    Execute Egate Command
    ...  cmd=ue_enb_param id=${ue_id} drx_config=on measurement_gap=gp0:0 gap_trigger=gnb_triggered

Attach Ue And Establish Pdu Session And Send A2 Measurement
    [Arguments]    ${ue_id}=1   ${pdu_id}=1   ${gw_id}=1   ${meas_id}=1
    Attach UE    ue_id=${ue_id}
    Establish PDU Session With Traffic   ue_id=${ue_id}    pdu_id=${pdu_id}   gw_id=${gw_id}
    Sleep    5s    reason=Waiting for RRCReconfigurationComplete for A2 measurement report setup
    Send A2 Measurement  ue_id=${ue_id}    meas_id=${meas_id}
    Sleep    5s    reason=Delay between sending measurements

Send A2 Measurement
    [Arguments]    ${ue_id}=1    ${meas_id}=1    ${srsrp_nr}=11    ${additional_arguments}=srsrq_nr=11 srs_result=0:11:11:0
    Send Custom Ue Measurement Nr    pass_regexp=ServingCellMO is not present in CellGroupConfig
    ...                              id=${ue_id}  meas_id=${meas_id}  event=A2  srsrp_nr=${srsrp_nr}    ${additional_arguments}
    Sleep    5s    reason=Delay between sending measurements

Send A5 Measurement
    [Arguments]    ${ue_id}    ${meas_id}
    Send Custom Ue Measurement Nr    id=${ue_id}    meas_id=${meas_id}    event=A5    srsrp_nr=19
    ...                              phycell_id=51    nrsrp_nr=68    timeout=5
    ...                              pass_regexp=Intra-eNB handover from EXT_ENB-2.1 to EXT_ENB-2.2 performed

Send B2 Measurement
    [Arguments]    ${ue_id}=1   ${meas_id}=3    ${target_phycell_id}=30    ${nrsrp_nr}=60    ${nrsrq_nr}=30
    Send Custom Ue Measurement Nr    pass_regexp=measResultListEUTRA    id=${ue_id}  meas_id=${meas_id}  index=0
    ...                              nrs_result=${nrsrp_nr}:${nrsrq_nr}:0  event=B2  srsrp_nr=11  srsrq_nr=11  srs_result=0:11:11:0
    ...                              phycell_id=${target_phycell_id}  nrsrp_nr=${nrsrp_nr}  nrsrq_nr=${nrsrq_nr}  rs_type=ssb

Wait For Timer X2AP interface up
	Sleep    15s    reason=Wait For Timer X2AP interface up

Verify Existing NRREL
    Wait For Object To Exist    object_name=NRCELL_A-1/NRREL_A-${EXPECTED_NRREL_OBJECTID}    moc=NRREL_A
    ...    timeout=${NRREL_OBJECT_CREATION_TIME}

Verify Existing NRRELE
    Wait For Object To Exist    object_name=NRCELL_A-1/NRRELE_A-${EXPECTED_NRREL_OBJECTID}    moc=NRRELE_A
    ...    timeout=${NRREL_OBJECT_CREATION_TIME}

Verify Successfull InterRAT HO
    Verify Tcpdump Log    packet_filter=${NGAP_HANDOVER_REQUIRED}
    Verify Tcpdump Log    packet_filter=${NGAP_HANDOVER_COMMAND}
    Verify Tcpdump Log    packet_filter=${HANDOVER_INTERRAT_DONE}
    Verify Loopback Messages    packet_filter=${NGAP_HANDOVER_NOTIFY}

Start Multiple Vms Interfaces
    Start Vm Ethernet Interface    if_name=eth3:gNB2_X2     ip_with_mask=10.0.1.3/24
    Start Vm Ethernet Interface    if_name=eth3:gNB3_X2     ip_with_mask=10.0.1.4/24
    Start Vm Ethernet Interface    if_name=eth3:gNB_S1U     ip_with_mask=10.0.1.112/24

Stop Multiple Vms Interfaces
    Stop Vm Ethernet Interface     if_name=eth3:gNB2_X2     ip_with_mask=10.0.1.3/24
    Stop Vm Ethernet Interface     if_name=eth3:gNB3_X2     ip_with_mask=10.0.1.4/24
    Stop Vm Ethernet Interface     if_name=eth3:gNB_S1U     ip_with_mask=10.0.1.112/24

Start Vm Ethernet Interfaces
    Start Vm Ethernet Interface    if_name=eth3:gNB2_XN    ip_with_mask=10.0.1.101/24
    Start Vm Ethernet Interface    if_name=eth3:gNB2_NG    ip_with_mask=10.0.1.102/24
    Start Vm Ethernet Interface    if_name=eth3:S1U        ip_with_mask=10.0.1.21/24
    Start Vm Ethernet Interface    if_name=eth3:S11        ip_with_mask=10.0.1.22/24
    Start Vm Ethernet Interface    if_name=eth3:gNB2_X2    ip_with_mask=10.0.1.3/24
    Start Vm Ethernet Interface    if_name=eth3:eNB1_X2    ip_with_mask=10.0.1.138/24

Stop Vm Ethernet Interfaces
    Stop Vm Ethernet Interface    if_name=eth3:gNB2_XN    ip_with_mask=10.0.1.101/24
    Stop Vm Ethernet Interface    if_name=eth3:gNB2_NG    ip_with_mask=10.0.1.102/24
    Stop Vm Ethernet Interface    if_name=eth3:S1U        ip_with_mask=10.0.1.21/24
    Stop Vm Ethernet Interface    if_name=eth3:S11        ip_with_mask=10.0.1.22/24
    Stop Vm Ethernet Interface    if_name=eth3:gNB2_X2    ip_with_mask=10.0.1.3/24
    Stop Vm Ethernet Interface    if_name=eth3:eNB1_X2    ip_with_mask=10.0.1.138/24
