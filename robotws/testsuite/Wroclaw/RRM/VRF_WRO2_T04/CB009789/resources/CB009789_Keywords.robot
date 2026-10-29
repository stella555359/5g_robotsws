*** Settings ***

Documentation    :copyright: Nokia

Resource    ../../../resources/airphone/5G_SW_WRO_Keywords.robot
Library     ta5g_pm_counters
Library     ta5g_iphy
Library     ta5g_enb
Library     ta5g_testline_management
Library     ta5g_ue_measurements
Library     CB009789.py

*** Keywords ***
Start Additional Vm Ethernet Interfaces
    Start Vm Ethernet Interface    if_name=eth3:GNB3_NG    ip_with_mask=10.0.11.100/24
    Start Vm Ethernet Interface    if_name=eth3:GNB3_XN    ip_with_mask=10.0.12.100/24
    Start Vm Ethernet Interface    if_name=eth3:GNB3_S1U_X2    ip_with_mask=10.0.1.11/24
    Start Vm Ethernet Interface    if_name=eth3:GNB3_PROXY   ip_with_mask=10.0.2.90/24
    Start Vm Ethernet Interface    if_name=eth3:ENB2_S1_ADDR    ip_with_mask=10.0.1.138/24

Stop Additional Vm Ethernet Interfaces
    Stop Vm Ethernet Interface    if_name=eth3:GNB3_NG    ip_with_mask=10.0.11.100/24
    Stop Vm Ethernet Interface    if_name=eth3:GNB3_XN    ip_with_mask=10.0.12.100/24
    Stop Vm Ethernet Interface    if_name=eth3:GNB3_S1U_X2    ip_with_mask=10.0.1.11/24
    Stop Vm Ethernet Interface    if_name=eth3:GNB3_PROXY   ip_with_mask=10.0.2.90/24
    Stop Vm Ethernet Interface    if_name=eth3:ENB2_S1_ADDR    ip_with_mask=10.0.1.138/24

Attach UE To Enb And Gnb
    [Arguments]    ${ue_id}=1
    Sleep    5s    reason=Problem with establishing x2ap link
    ta5g_ue_mobility.Attach Ue To Enb    ue_id=${ue_id}    optional_parameters=profile=1
    Start Gnb Addition Procedure    ue=${ue_id}    target_gnb=2    target_cells=1    bearer=2    dc_type=split_scg
    ...                             pass_regexp=Proxy \\(eNB 2 cell 1\\) reported successful RA
    Verify Ngap Messages       packet_filter=${SN_STATUS_TRANSFER}    continue_on_failure=${False}

Trigger Test Line Reset
    Trigger Site Reset Aic Vdu    vdu=1
    Trigger Site Reset Aic Vcu
    Execute Wts Command    cmd=system-module-reboot
    Sleep    20s    reason=Waiting for F1 link unavailability
    Wait For F1 Links To Be Available Aic    timeout=600

Wait For postSgnbAdditionAckProcedure Finish On gNB And Check UE Capabilities
    Verify Ngap Messages    packet_filter=${SGNBADDITION_REQ_WITH_CGI_REPORTING_ENDC}

Set Cell UE Capacity
    [Arguments]    ${cell_dist_name}=MRBTS-1/NRBTS-1/NRCELL-2    ${cell_capacity}=0
    Perform Parameter Commissioning Aic    dist_name=${cell_dist_name}     parameter=maxNumOfCaUsersNRCell
    ...                                    value=${cell_capacity}
    Perform Parameter Commissioning Aic    dist_name=${cell_dist_name}     parameter=maxNumOfRrcSA
    ...                                    value=${cell_capacity}
    Perform Parameter Commissioning Aic    dist_name=${cell_dist_name}     parameter=maxNumOfSCellAlloc
    ...                                    value=${cell_capacity}
    Perform Parameter Commissioning Aic    dist_name=${cell_dist_name}     maxNumOfUsersPerCell
    ...                                    value=${cell_capacity}
    Perform Parameter Commissioning Aic    dist_name=${cell_dist_name}     maxNumOfUsersPerNRCell
    ...                                    value=${cell_capacity}

Send A2 Measurement
    [Arguments]    ${ue_id}    ${meas_id}=1
    Send Custom Ue Measurement Nr    pass_regexp=ServingCellMO is not present in CellGroupConfig
    ...                              id=${ue_id}  meas_id=${meas_id}  event=A2  srsrp_nr=11
    ...                              srsrq_nr=11  srs_result=0:11:11:0

Send A5 Event To Trigger Ho
    [Arguments]    ${ue_id}=1   ${srsrq_nr}=1    ${srsrp_nr}=1    ${ssinr_nr}=1    ${phycell_id}=2
    ...            ${nrsrq_nr}=122    ${nrsrp_nr}=122    ${nsinr_nr}=122    ${timeout}=30
    ...            ${pass_regexp}=message c1 : rrcReconfigurationComplete

    Send Ue Measurement Nr Event A5 With Aligned Meas Id    ue_id=${ue_id}    carrier_freq=632928
    ...                              pass_regexp=${pass_regexp}    srsrq_nr=${srsrq_nr}    srsrp_nr=${srsrp_nr}
    ...                              ssinr_nr=${ssinr_nr}    phycell_id=${phycell_id}    nrsrq_nr=${nrsrq_nr}
    ...                              nrsrp_nr=${nrsrp_nr}    nsinr_nr=${nsinr_nr}    timeout=${timeout}

Send B2 Measurement And Attempt Handover
    [Arguments]    ${ue_id}    ${meas_id}=7    ${target_phycell_id}=54    ${nrsrp_nr}=60    ${nrsrq_nr}=30
    ...            ${pass_regexp}=measResultListEUTRA
    Send Custom Ue Measurement Nr    pass_regexp=${pass_regexp}    id=${ue_id}  meas_id=${meas_id}  index=0
    ...                              nrs_result=${nrsrp_nr}:${nrsrq_nr}:0  event=B2  srsrp_nr=11  srsrq_nr=11
    ...                              srs_result=0:11:11:0  phycell_id=${target_phycell_id}
    ...                              nrsrp_nr=${nrsrp_nr}  nrsrq_nr=${nrsrq_nr}  rs_type=ssb
    Sleep    2s    reason=Waiting for handover request to be processed

Verify Created NRADJECELL And NRRELE Objects
    Wait For Object To Exist Aic    dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRREL-${SECOND_NRREL_ID}
    ...                             timeout=${NRREL_OBJECT_CREATION_TIME}
    Wait For Object To Exist Aic    dist_name=MRBTS-1/NRBTS-1/NRADJNRCELL-${NRADJCELL_ID}
    ...                             timeout=${NRREL_OBJECT_CREATION_TIME}

Verify Created XNLINK And NRADJGNB Objects
    Wait For Object To Exist Aic    dist_name=MRBTS-1/NRBTS-1/XNLINK-1
    ...                             timeout=${NRREL_OBJECT_CREATION_TIME}
    Wait For Object To Exist Aic    dist_name=MRBTS-1/NRBTS-1/NRADJGNB-1
    ...                             timeout=${NRREL_OBJECT_CREATION_TIME}

Attach Ue And Establish Pdu Session And Send B2 Measurement
    [Arguments]    ${ue_id}    ${pdu_id}=1    ${gw_id}=1    ${meas_id}=3  ${meas_idA2}=1  ${target_phycell_id}=54
    ...            ${nrsrq_nr}=30  ${nrsrp_nr}=60    ${pass_regexp}=measResultListEUTRA
    Attach Ue And Establish Pdu Session And Send A2 Measurement  ue_id=${ue_id}  pdu_id=${pdu_id}  gw_id=${gw_id}
    ...                                                          meas_id=${meas_idA2}
    Execute Egate Command    cmd=ue_nr_rrc_reconf_param id=${ue_id} if_contains=report_cgi_eutra anr_cgi_delay=100
    Send B2 Measurement And Attempt Handover  ue_id=${ue_id}  meas_id=${meas_id}  target_phycell_id=${target_phycell_id}
    ...                                       nrsrp_nr=${nrsrp_nr}    nrsrq_nr=${nrsrq_nr}    pass_regexp=${pass_regexp}

Attach Ue And Establish Pdu Session And Send A2 Measurement
    [Arguments]    ${ue_id}   ${pdu_id}=1   ${gw_id}=1   ${meas_id}=1
    ta5g_ue_mobility.Attach UE    ue_id=${ue_id}
    Establish PDU Session With Traffic   ue_id=${ue_id}    pdu_id=${pdu_id}   gw_id=${gw_id}
    Sleep    2s    reason=Waiting for RRCReconfigurationComplete for A2 measurement report setup
    Send A2 Measurement  ue_id=${ue_id}    meas_id=${meas_id}
    Sleep    5s    reason=Delay between sending measurments

Verify Traces For EUTRA CGI Measurement Report Configuration And InterRAT HO
    [Arguments]      ${Meas_gap}=1  ${Eutra_cgi_report}=1  ${Handover_success_msg}=1
    Verify Tcpdump Log   packet_filter=${REPORT_MEASUREMENT_GAP}  number_of_messages=${Meas_gap}
    Verify Tcpdump Log    packet_filter=${REPORT_EUTRA_CGI}  number_of_messages=${Eutra_cgi_report}
    Verify Ngap Messages    packet_filter=${HANDOVER_SUCCESS}    timeout=120  number_of_messages=${Handover_success_msg}

