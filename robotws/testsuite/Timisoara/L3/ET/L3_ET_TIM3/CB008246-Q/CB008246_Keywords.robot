*** Settings ***
Resource     ../resources/5G_SW_WRO_Keywords.robot
Resource     ../resources/scripts/libraries_instances.robot
Resource     ../resourcesULM/gnb.robot
Library      ta5g_throughput
Library      ta5g_bearers
#Library      config/egate.py
Library      config/keywords_ROHC.py

*** Variables ***
${custom-scf}    ${CURDIR}/config/SBTS24R1/SCF_CB008246.xml
${lolo-scf}    ${CURDIR}/config/SBTS24R1/LOLO_Orig.xml
${X2AP_SN_STATUS_TRANSFER}=    x2ap.SNStatusTransfer_element
${X2AP_SGNB_MODIFICATION_REQUEST_REJECT}=    x2ap.SgNBModificationRequestReject_element
${X2AP_SGNB_MODIFICATION_REQUEST}=    x2ap.SgNBModificationRequest_element
${filter_1}=    x2ap.SgNBAdditionRequestAcknowledge_element && x2ap.LocationInformationSgNB_element && x2ap.pSCell_id_element
${filter_2}=    x2ap.SgNBModificationRequestAcknowledge_element && x2ap.LocationInformationSgNB_element && x2ap.pSCell_id_element
${filter_3}=    x2ap.SgNBModificationRequired_element &&x2ap.LocationInformationSgNB_element && x2ap.pSCell_id_element

*** Keywords ***
Update Requested RnD flags in SW config file
    @{A_rd_params}=  create list  0x890057=0 # rdActNrDualConnectivity
    Update SW Config file on System Module  param_list=${A_rd_params}
    Set suite variable    ${force_reboot}    ${true}

Display Qfi stats
    [Arguments]    ${ue_id}=1     ${pdu_id}=1     ${qfi_id}=3
    Execute Egate Command And Wait For Data    cmd=qfi_stats ue=${ue_id} pdu=${pdu_id} qfi=${qfi_id} trf_id=1 dir=bi

Check Data Traffic
    [Arguments]              ${ue_id}    ${pdu_id}    ${qfi_id}    ${dir}    ${throughput}    ${marg}
    Display Qfi stats    qfi_id=${qfi_id}
    Execute Egate Command And Wait For Data    cmd=uec_stats display type=cell_data_pdcp enb=2 cell=1 format=long
    Expected Throughput For Qfi Should Be Reached    ue_id=${ue_id}    pdu_id=${pdu_id}    qfi_id=${qfi_id}
    ...    expected_throughput=${throughput}    unit=mbps    margin=${marg}    direction=${dir}
#    Check Number Of Total Packets Lost    ue_id=1    pdu_id=1    qfi_id=1    packet_loss=0
#    ...    margin=0.0    direction=dl

Check Bearer Stats Traffic
    [Arguments]              ${ue_id}    ${pdu_id}    ${qfi_id}    ${dir}    ${throughput}
    Sleep    1s
    Check Bearer Stats    ue_id=${ue_id}    pdu_id=${pdu_id}    qfi_id=${qfi_id}    dir=${dir}    pass_regexp=${throughput}
    Sleep    1s

Periodic registration
    [Arguments]              ${ue_id}
    Execute Egate Command    cmd=amf_ue_ics_param id=1 ue=${ue_id} core_network_assistance_info=on ue_identity_index_value=1
    ...                      ue_specific_drx=64 periodic_registration_update_timer=1:10min plmn_id=311:489 tac_id=200

ue_nr_rrc_resume
    [Arguments]              ${ue_id}
    Execute Egate Command    cmd=ue_nr_rrc_resume_request_param id=1 gnb=2 cell=1 msg=resume_request_1 cause=mo_Signalling

Modify QOS
    [Arguments]              ${ue_id}    ${pdu_id}
    Execute Egate Command    cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=3,4 by=amf validation=on

Establish PDU Session
    [Arguments]    ${ue_id}    ${pdu_id}    ${gw_id}
    Execute egate command    cmd=ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} nwslice=1 gw=${gw_id}

Activate intra_LTE_HO
     [Arguments]    ${ue_id}
    Execute egate command    cmd=ue_ho id=${ue_id} ho_mode=INTRA_LTE enb=1 cell=2

Activate intra_NR_HO
     [Arguments]    ${ue_id}
    Execute egate command    cmd=ue_measurement_send_nr id=${ue_id} meas_id=3 event=A2 srsrp_nr=11 srsrq_nr=11 phycell_id=51 nrsrp_nr=80 nrsrq_nr=80

Activate CB007512 feature
     [Arguments]    ${ue_id}
    Execute egate command    cmd=ue_enb_endc_param id=${ue_id} direct_bearer_sn_modification=on
    sleep  5s


Activate EN-DC
     [Arguments]    ${ENB}
    Execute egate command    cmd=enb_cell_param enb=${ENB} id=1 allow_endc=on
    sleep  5s
    Execute egate command    cmd=enb_cell_param enb=${ENB} id=2 allow_endc=on
    sleep  5s

Add interfaces
     [Arguments]    ${ue_id}
    Run    sudo ip addr add 10.0.2.1/24 dev eth4
    Run    sudo ip addr add 10.0.1.121/24 dev eth3
    Run    sudo ip addr add 10.0.1.122/24 dev eth3
    Run    sudo ip addr add 10.0.1.123/24 dev eth3
    Run    sudo ip addr add 10.0.1.124/24 dev eth3
    Run    sudo ip addr add 10.0.1.125/24 dev eth3
    Run    sudo ip addr add 10.0.1.131/24 dev eth3
    Run    sudo ip addr add 10.0.1.132/24 dev eth3
    Run    sudo ip addr add 10.0.1.133/24 dev eth3
    Run    sudo ip addr add 10.0.1.134/24 dev eth3
    Run    sudo ip addr add 10.0.1.136/24 dev eth3
    Run    sudo ip addr add 10.0.2.90/24 dev eth4
    Run    sudo ip addr add 10.0.2.91/24 dev eth4
    Run    sudo ip addr add 10.0.2.92/24 dev eth4
    Run    sudo ip addr add 10.0.1.12/24 dev eth3
    Run    sudo ip addr add 10.0.1.102/24 dev eth3
    Run    sudo ip addr add 10.0.1.103/24 dev eth3
    Run    sudo ip addr add 10.0.1.104/24 dev eth3
    Run    sudo ip addr add 10.0.1.105/24 dev eth3
    Run    sudo ip addr add 10.0.1.106/24 dev eth3

Del interfaces
     [Arguments]    ${ue_id}
    Run    sudo ip addr del 10.0.2.1/24 dev eth4
    Run    sudo ip addr del 10.0.1.121/24 dev eth3
    Run    sudo ip addr del 10.0.1.122/24 dev eth3
    Run    sudo ip addr del 10.0.1.123/24 dev eth3
    Run    sudo ip addr del 10.0.1.124/24 dev eth3
    Run    sudo ip addr del 10.0.1.125/24 dev eth3
    Run    sudo ip addr del 10.0.1.131/24 dev eth3
    Run    sudo ip addr del 10.0.1.132/24 dev eth3
    Run    sudo ip addr del 10.0.1.133/24 dev eth3
    Run    sudo ip addr del 10.0.1.134/24 dev eth3
    Run    sudo ip addr del 10.0.1.136/24 dev eth3
    Run    sudo ip addr del 10.0.2.90/24 dev eth4
    Run    sudo ip addr del 10.0.2.91/24 dev eth4
    Run    sudo ip addr del 10.0.2.92/24 dev eth4
    Run    sudo ip addr del 10.0.1.12/24 dev eth3
    Run    sudo ip addr del 10.0.1.102/24 dev eth3
    Run    sudo ip addr del 10.0.1.103/24 dev eth3
    Run    sudo ip addr del 10.0.1.104/24 dev eth3
    Run    sudo ip addr del 10.0.1.105/24 dev eth3
    Run    sudo ip addr del 10.0.1.106/24 dev eth3



Trigger SgNB Addition
    Start Gnb Addition Procedure    ue=11    target_cells=1    target_gnb=2    bearer=2    dc_type=split_scg
    ...                             pass_regexp=Proxy \\(eNB 2 cell 1\\) reported successful RA

Add Two Bearers
    Add Bearers To Ue    ue_id=11    bearers_params=id=2 filter=2 precedence=2 id=3 filter=3 precedence=3 by=pgw

Attach Ue And Perform SgNBAdditionRequest
    [Arguments]    ${ue_id}
    Attach Ue To Enb    ue_id=${ue_id}
#    Add Bearer    ue_id=11     pass_regexp=PGW-initiated Bearer Creation. Bearer-2 \\(EBI=6, QCI=6\\) created
#    ...                        bearer_id=2    filter=1    precedence=1    by=pgw
    Trigger SgNB Addition
    Verify Tcpdump Log       packet_filter=${X2AP_SGNB_ADDITION_REQUEST_ACKNOWLEDGE}
