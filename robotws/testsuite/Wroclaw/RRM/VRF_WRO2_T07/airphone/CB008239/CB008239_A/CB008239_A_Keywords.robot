*** Settings ***
Documentation
...    author: Marcin Plawny, Przemyslaw Sas
...    maintainer: Marcin Plawny
...    contact: marcin.plawny@nokia.com

Resource     ../../../../resources/airphone/5G_SW_WRO_Keywords.robot
Library    testsuite/Wroclaw/RRM/resources/scout_report.py
Library    ta5g_testline_management
Library    ta5g_ue_measurements
Library    ta5g_iphy
Library    ta5g_enb
Library    ta5g_pm_counters
Library    ta5g_delta

*** Variables ***
${NRRELE_OBJECT_CREATION_TIME} =    120
${NRADJECELL_OBJECT_CREATION_TIME} =    120
${NRRELE_ID} =    256
${NRADJECELL_ID} =    5000
${FAULT_ID_MAX_RELATION_ANR} =    8300
${RECONFIGURATION_REPORT_EUTRA_CGI} =    ${RRC_RECONFIGURATION} && nr-rrc.reportType == reportCGI && nr-rrc.cellForWhichToReportCGI == 30
${RECONFIGURATION_REPORT_MEASUREMENT_GAP} =    ${RRC_RECONFIGURATION} && nr-rrc.gapUE == 0 && nr-rrc.measIdToRemoveList == 1
${RECONFIGURATION_REPORT_EUTRA_CGI_NOCONF} =    ${RRC_RECONFIGURATION_COMPLETE} && nr-rrc.rrc_TransactionIdentifier == 2
${RECONFIGURATION_A2_EVENT_ADD} =    ${RRC_RECONFIGURATION} && nr-rrc.reportConfigId == 5
${REESTABLISHMENT_DURING_RECONFIGURATION} =    ${RRC_REESTABLISHMENT} && nr-rrc.c1 == 3
${REESTABLISHMENT_COMPLETE} =    ${RRC_REESTABLISHMENT_COMPLETE} && nr-rrc.c1 == 3

${HANDOVER_SUCCESS}=    ${NGAP_UE_CONTEXT_RELEASE_COMMAND} && ${SUCCESSFUL_HANDOVER}

*** Keywords ***
Attach Ue And Establish Pdu Session And Send A2 Measurement
    [Arguments]    ${ue_id}   ${pdu_id}=1   ${gw_id}=1   ${meas_id}=1
    Attach UE    ue_id=${ue_id}
    Establish PDU Session With Traffic   ue_id=${ue_id}    pdu_id=${pdu_id}   gw_id=${gw_id}
    Sleep    2s    reason=Waiting for RRCReconfigurationComplete for A2 measurement report setup
    Send A2 Measurement  ue_id=${ue_id}    meas_id=${meas_id}
    Sleep    5s    reason=Delay between sending measurments

Attach Ue And Establish Pdu Session And Send B2 Measurement
    [Arguments]    ${ue_id}    ${pdu_id}=1    ${gw_id}=1    ${meas_id}=3  ${meas_idA2}=1  ${target_phycell_id}=30
    ...            ${nrsrq_nr}=30  ${nrsrp_nr}=60    ${pass_regexp}=measResultListEUTRA
    Attach Ue And Establish Pdu Session And Send A2 Measurement  ue_id=${ue_id}  pdu_id=${pdu_id}  gw_id=${gw_id}  meas_id=${meas_idA2}
    Execute Egate Command    cmd=ue_nr_rrc_reconf_param id=${ue_id} if_contains=report_cgi_eutra anr_cgi_delay=100
    Send B2 Measurement And Attempt Handover  ue_id=${ue_id}  meas_id=${meas_id}  target_phycell_id=${target_phycell_id}
    ...                                       nrsrp_nr=${nrsrp_nr}    nrsrq_nr=${nrsrq_nr}    pass_regexp=${pass_regexp}

Send A2 Measurement
    [Arguments]    ${ue_id}    ${meas_id}=1
    Send Custom Ue Measurement Nr    pass_regexp=ServingCellMO is not present in CellGroupConfig    get_ue_meas_cfg=1
    ...                              id=${ue_id}  meas_id=${meas_id}  event=A2  srsrp_nr=11  srsrq_nr=11  srs_result=0:11:11:0

Send B2 Measurement And Attempt Handover
    [Arguments]    ${ue_id}    ${meas_id}=7    ${target_phycell_id}=30    ${nrsrp_nr}=60    ${nrsrq_nr}=30
    ...            ${pass_regexp}=measResultListEUTRA
    Send Custom Ue Measurement Nr    pass_regexp=${pass_regexp}    id=${ue_id}  meas_id=${meas_id}  index=0    get_ue_meas_cfg=1
    ...                              nrs_result=${nrsrp_nr}:${nrsrq_nr}:0  event=B2  srsrp_nr=11  srsrq_nr=11  srs_result=0:11:11:0
    ...                              phycell_id=${target_phycell_id}  nrsrp_nr=${nrsrp_nr}  nrsrq_nr=${nrsrq_nr}  rs_type=ssb
    Sleep    2s    reason=Waiting for handover request to be processed

Unlock Handover in Amf and Attempt To Make Handover Based On A2 And B2 Measurements
    [Arguments]    ${ue_id}  ${meas_idA2}=5  ${meas_idB2}=7  ${target_phycell_id}=30  ${nrsrq_nr}=30  ${nrsrp_nr}=60
    Set Amf To Not Fail Handover Preparation
    Send A2 Measurement  ue_id=${ue_id}    meas_id=${meas_idA2}
    Sleep    2s    reason=Waiting for RRCReconfigurationComplete for B2 measurement report setup
    Send B2 Measurement And Attempt Handover  ue_id=${ue_id}  meas_id=${meas_idB2}  target_phycell_id=${target_phycell_id}
    ...                                       nrsrp_nr=${nrsrp_nr}    nrsrq_nr=${nrsrq_nr}

Set Amf To Not Fail Handover Preparation
    Execute Egate Command    cmd=amf_ue_ng_handover_param id=1 reset

Set Amf To Fail Handover Preparation
    [Arguments]    ${ue_id}
    Execute Egate Command    cmd=amf_ue_ng_handover_param id=1 ue=${ue_id} action=ho_preparation_failure cause=RN_CauseRadioNetwork_unspecified

Set Amf To Fail Handover And Send B2 Measurement
    [Arguments]    ${ue_id}  ${meas_id}=7  ${target_phycell_id}=30  ${nrsrq_nr}=30  ${nrsrp_nr}=60
    Set Amf To Fail Handover Preparation    ${ue_id}
    Send B2 Measurement And Attempt Handover  ue_id=${ue_id}  meas_id=${meas_id}  target_phycell_id=${target_phycell_id}
    ...                                       nrsrp_nr=${nrsrp_nr}    nrsrq_nr=${nrsrq_nr}

RRC Reestablish
    [Arguments]    ${ue_id}
    Ue Nr Rrc Reconf Param    ue_id=${ue_id}  if_contains=report_cgi_eutra  action=reestablish

Delay For T321 Timeout
    [Arguments]    ${ue_id}
    Ue Nr Rrc Reconf Param    ue_id=${ue_id}  if_contains=report_cgi_eutra  action=donot_send_EUTRACGI

Drop EutraCgi
    [Arguments]    ${ue_id}
    Ue Nr Rrc Reconf Param    ue_id=${ue_id}  if_contains=report_cgi_eutra action=drop

Verify Created NRADJECELL And NRRELE Objects
    Wait For Object To Exist    object_name=NRADJECELL_A-${NRADJECELL_ID}  moc=NRADJECELL_A   timeout=${NRADJECELL_OBJECT_CREATION_TIME}
    Wait For Object To Exist    object_name=NRCELL_A-1/NRRELE_A-${NRRELE_ID}    moc=NRRELE_A    timeout=${NRRELE_OBJECT_CREATION_TIME}
    &{NRADJECELL}=    Get Managed Object    object_name=NRADJECELL_A-${NRADJECELL_ID}   moc=NRADJECELL_A
    &{NRRELE}=    Get Managed Object    object_name=NRCELL_A-1/NRRELE_A-${NRRELE_ID}    moc=NRRELE_A
    Verify Created NRADJECELL Object    NRADJECELL=&{NRADJECELL}    mcc=311    mnc=489    mncLength=3    physCellId=30    ePSTrackingAreaCode=788
    ...                                  earfcnValue=2200    eNodeBId=475937    lcrId=1
    Verify Created NRRELE Object    NRRELE=&{NRRELE}    mcc=${NRRELE.ecgiPlmn.mcc}    mnc=${NRRELE.ecgiPlmn.mnc}
    ...                            mncLength=${NRRELE.ecgiPlmn.mncLength}    eNodeBId=${NRRELE.eNodeBId}    lcrId=${NRRELE.lcrId}

Verify Created NRADJECELL Object
    [Documentation]    Validate NRADJECELL object created in network plan by ANR feature.
    ...                Keyword compares requested parameters to values in SCF configuration.
    [Arguments]    ${NRADJECELL}    ${mcc}    ${mnc}    ${mncLength}    ${physCellId}    ${eNodeBId}    ${earfcnValue}    ${ePSTrackingAreaCode}
    ...            ${lcrId}
    Should Be Equal As Integers    ${NRADJECELL.enbPlmn.mcc}    ${mcc}
    Should Be Equal As Integers    ${NRADJECELL.enbPlmn.mnc}    ${mnc}
    Should Be Equal As Integers    ${NRADJECELL.enbPlmn.mncLength}    ${mncLength}
    Should Be Equal As Integers    ${NRADJECELL.ecgiPlmn.mcc}    ${mcc}
    Should Be Equal As Integers    ${NRADJECELL.ecgiPlmn.mnc}    ${mnc}
    Should Be Equal As Integers    ${NRADJECELL.ecgiPlmn.mncLength}    ${mncLength}
    Should Be Equal As Integers    ${NRADJECELL.physCellId}     ${physCellId}
    Should Be Equal As Integers    ${NRADJECELL.eNodeBId}     ${eNodeBId}
    Should Be Equal As Integers    ${NRADJECELL.earfcnValue}    ${earfcnValue}
    Should Be Equal As Integers    ${NRADJECELL.ePSTrackingAreaCode}    ${ePSTrackingAreaCode}
    Should Be Equal As Integers    ${NRADJECELL.lcrId}    ${lcrId}

Verify Created NRRELE Object
    [Documentation]    Validate NRRELE object created in network plan by ANR feature.
    ...                Keyword compares requested parameters to values in SCF configuration.
    [Arguments]    ${NRRELE}    ${mcc}    ${mnc}    ${mncLength}    ${eNodeBId}    ${lcrId}    ${removeNotAllowed}=${False}
    Should Be Equal As Integers    ${NRRELE.ecgiPlmn.mcc}    ${mcc}
    Should Be Equal As Integers    ${NRRELE.ecgiPlmn.mnc}    ${mnc}
    Should Be Equal As Integers    ${NRRELE.ecgiPlmn.mncLength}    ${mncLength}
    Should Be Equal As Integers    ${NRRELE.eNodeBId}     ${eNodeBId}
    Should Be Equal As Integers    ${NRRELE.lcrId}    ${lcrId}
    Should Be Equal    ${NRRELE.removeNotAllowed}    ${removeNotAllowed}

Start Vm Ethernet Interfaces
    Start Vm Ethernet Interface    if_name=eth3:gNB2_XN    ip_with_mask=10.0.1.101/24
    Start Vm Ethernet Interface    if_name=eth3:gNB2_NG    ip_with_mask=10.0.1.102/24
    Start Vm Ethernet Interface    if_name=eth3:S1U_1296    ip_with_mask=10.0.1.21/24
    Start Vm Ethernet Interface    if_name=eth3:S11_1296    ip_with_mask=10.0.1.22/24
    Start Vm Ethernet Interface    if_name=eth3:gNB2_X2    ip_with_mask=10.0.1.3/24
    Start Vm Ethernet Interface    if_name=eth3:eNB1_X2    ip_with_mask=10.0.1.138/24

Stop Vm Ethernet Interfaces
    Stop Vm Ethernet Interface    if_name=eth3:gNB2_XN    ip_with_mask=10.0.1.101/24
    Stop Vm Ethernet Interface    if_name=eth3:gNB2_NG    ip_with_mask=10.0.1.102/24
    Stop Vm Ethernet Interface    if_name=eth3:S1U_1296    ip_with_mask=10.0.1.21/24
    Stop Vm Ethernet Interface    if_name=eth3:S11_1296    ip_with_mask=10.0.1.22/24
    Stop Vm Ethernet Interface    if_name=eth3:gNB2_X2    ip_with_mask=10.0.1.3/24
    Stop Vm Ethernet Interface    if_name=eth3:eNB1_X2    ip_with_mask=10.0.1.138/24

Verify Traces For Reconfiguration Containing EUTRA CGI Measurement Report Configuration And InterRAT HO
    [Arguments]      ${Meas_gap}=1  ${Eutra_cgi_report}=1  ${Handover_success_msg}=1
    Verify Tcpdump Log   packet_filter=${RECONFIGURATION_REPORT_MEASUREMENT_GAP}  number_of_messages=${Meas_gap}
    Verify Tcpdump Log    packet_filter=${RECONFIGURATION_REPORT_EUTRA_CGI}  number_of_messages=${Eutra_cgi_report}
    Verify Ngap Messages    packet_filter=${HANDOVER_SUCCESS}    timeout=120  number_of_messages=${Handover_success_msg}

Verify Traces For Reconfiguration Containing EUTRA CGI Measurement Report Configuration And InterRAT HO with Reestablishment report
    [Arguments]      ${Meas_gap}=1  ${Eutra_cgi_report}=1  ${Reconf_report_noconf}=1  ${Reestablish_report}=1  ${Handover_success_msg}=0
    Verify Tcpdump Log   packet_filter=${RECONFIGURATION_REPORT_MEASUREMENT_GAP}  number_of_messages=${Meas_gap}
    Verify Tcpdump Log    packet_filter=${RECONFIGURATION_REPORT_EUTRA_CGI}  number_of_messages=${Eutra_cgi_report}
    Verify Tcpdump Log    packet_filter=${RECONFIGURATION_REPORT_EUTRA_CGI_NOCONF}    number_of_messages=${Reconf_report_noconf}
    Verify Tcpdump Log    packet_filter=${REESTABLISHMENT_DURING_RECONFIGURATION}  number_of_messages=${Reestablish_report}
    Verify Tcpdump Log    packet_filter=${REESTABLISHMENT_COMPLETE}  number_of_messages=${Reestablish_report}
    Verify Ngap Messages    packet_filter=${HANDOVER_SUCCESS}    timeout=120  number_of_messages=${Handover_success_msg}

Verify Traces For Reconfiguration Containing EUTRA CGI Measurement Report Configuration And InterRAT HO with A2 event
    [Arguments]      ${Meas_gap}=1  ${Eutra_cgi_report}=1  ${Reconf_report_noconf}=2  ${Reconf_a2}=1  ${Handover_success_msg}=0
    Verify Tcpdump Log   packet_filter=${RECONFIGURATION_REPORT_MEASUREMENT_GAP}  number_of_messages=${Meas_gap}
    Verify Tcpdump Log    packet_filter=${RECONFIGURATION_REPORT_EUTRA_CGI}  number_of_messages=${Eutra_cgi_report}
    Verify Tcpdump Log    packet_filter=${RECONFIGURATION_REPORT_EUTRA_CGI_NOCONF}    number_of_messages=${Reconf_report_noconf}
    Verify Tcpdump Log    packet_filter=${RECONFIGURATION_A2_EVENT_ADD}  number_of_messages=${Reconf_a2}
    Verify Ngap Messages    packet_filter=${HANDOVER_SUCCESS}    timeout=120  number_of_messages=${Handover_success_msg}

Verify Traces For Reconfiguration Containing EUTRA CGI Measurement Report Configuration And InterRAT HO Failure
    [Arguments]     ${Eutra_cgi_report}=1  ${Handover_required_msg}=2  ${Handover_failure}=1
    Verify Tcpdump Log    packet_filter=${RECONFIGURATION_REPORT_EUTRA_CGI}    number_of_messages=${Eutra_cgi_report}
    Verify Tcpdump Log    packet_filter=${NGAP_HANDOVER_REQUIRED}    number_of_messages=${Handover_required_msg}
    Verify Tcpdump Log    packet_filter=${NGAP_HANDOVER_PREPARATION_FAILURE}  number_of_messages=${Handover_failure}

Verify Traces For No Reconfiguration Containing EUTRA CGI Measurement Report Configuration And InterRAT HO Failure
    [Arguments]     ${Eutra_cgi_report}=0  ${Handover_required_msg}=0
    Verify Tcpdump Log    packet_filter=${RECONFIGURATION_REPORT_EUTRA_CGI}    number_of_messages=${Eutra_cgi_report}
    Verify Tcpdump Log    packet_filter=${NGAP_HANDOVER_REQUIRED}    number_of_messages=${Handover_required_msg}

Verify Traces For EUTRA CGI Reconfiguration and Successfull InterRAT HO
    [Arguments]     ${Eutra_cgi_report}=1  ${Handover_required_msg}=2  ${Handover_command_msg}=1  ${Handover_success_msg}=1
    ...  ${Handover_notify_msg}=1
    Verify Tcpdump Log    packet_filter=${RECONFIGURATION_REPORT_EUTRA_CGI}  number_of_messages=${Eutra_cgi_report}
    Verify Tcpdump Log    packet_filter=${NGAP_HANDOVER_REQUIRED}  number_of_messages=${Handover_required_msg}
    Verify Tcpdump Log    packet_filter=${NGAP_HANDOVER_COMMAND}  number_of_messages=${Handover_command_msg}
    Verify Tcpdump Log    packet_filter=${HANDOVER_SUCCESS}  number_of_messages=${Handover_success_msg}
    Verify Loopback Messages    packet_filter=${NGAP_HANDOVER_NOTIFY}  number_of_messages=${Handover_notify_msg}

Verify Traces For Failed And Successful HO Without PCI Resoultion
    [Arguments]     ${Handover_failure}=1  ${Handover_success_msg}=2
    Verify Tcpdump Log    packet_filter=${NGAP_HANDOVER_PREPARATION_FAILURE}  number_of_messages=${Handover_failure}
    Verify Tcpdump Log    packet_filter=${HANDOVER_SUCCESS}    number_of_messages=${Handover_success_msg}
