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
${HANDOVER_INTERRAT_DONE}=    ${NGAP_UE_CONTEXT_RELEASE_COMMAND} && ${SUCCESSFUL_HANDOVER}
${RAT_TYPE_NR}=	${UE_CAPABILITY_ENQUIRY} && (nr-rrc.rat_Type == 0)
${RAT_TYPE_EUTRA}=	${UE_CAPABILITY_ENQUIRY} && (nr-rrc.rat_Type == 2)
${UE_CAPABILITY_ENQUIRY}=	(f1ap.DLRRCMessageTransfer_element) && (nr-rrc.ue_CapabilityRAT_RequestList == 1)


*** Keywords ***
Attach Ue And Establish Pdu Session And Send A2 Measurement
    [Arguments]    ${ue_id}=1   ${pdu_id}=1   ${gw_id}=1   ${meas_id}=1
    Attach UE    ue_id=${ue_id}
    Establish PDU Session With Traffic   ue_id=${ue_id}    pdu_id=${pdu_id}   gw_id=${gw_id}
    Sleep    5s    reason=Waiting for RRCReconfigurationComplete for A2 measurement report setup
    Send A2 Measurement  ue_id=${ue_id}    meas_id=${meas_id}
    Sleep    5s    reason=Delay between sending measurements

Send A2 Measurement
    [Arguments]    ${ue_id}=1    ${meas_id}=1    ${srsrp_nr}=19    ${additional_arguments}=srsrq_nr=17 srs_result=0:19:17:0
    Send Custom Ue Measurement Nr    pass_regexp=ServingCellMO is not present in CellGroupConfig
    ...                              id=${ue_id}  meas_id=${meas_id}  event=A2  srsrp_nr=${srsrp_nr}    ${additional_arguments}
    Sleep    5s    reason=Delay between sending measurements

Send B2 Measurement
    [Arguments]    ${ue_id}=1   ${meas_id}=3    ${target_phycell_id}=11    ${nrsrp_nr}=19    ${nrsrq_nr}=17
    Send Custom Ue Measurement Nr    pass_regexp=measResultListEUTRA    id=${ue_id}  meas_id=${meas_id}  index=0
    ...                              nrs_result=${nrsrp_nr}:${nrsrq_nr}:0  event=B2  srsrp_nr=19  srsrq_nr=17  srs_result=0:19:17:0
    ...                              phycell_id=${target_phycell_id}  nrsrp_nr=${nrsrp_nr}  nrsrq_nr=${nrsrq_nr}  rs_type=ssb

Verify Successfull InterRAT HO
    Verify Tcpdump Log    packet_filter=${NGAP_HANDOVER_REQUIRED}
    Verify Tcpdump Log    packet_filter=${NGAP_HANDOVER_COMMAND}
    Verify Tcpdump Log    packet_filter=${HANDOVER_INTERRAT_DONE}
    Verify Loopback Messages    packet_filter=${NGAP_HANDOVER_NOTIFY}

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
