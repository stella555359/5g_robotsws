*** Settings ***
Resource     ../resources/5G_SW_WRO_Keywords.robot
Resource     ../resources/scripts/libraries_instances.robot
Library      ta5g_throughput
Library      ta5g_bearers

*** Variables ***
${X2AP_SN_STATUS_TRANSFER}=    x2ap.SNStatusTransfer_element
${X2AP_SGNB_MODIFICATION_REQUEST_REJECT}=    x2ap.SgNBModificationRequestReject_element
${X2AP_SGNB_MODIFICATION_REQUEST}=    x2ap.SgNBModificationRequest_element
${filter_1}=    x2ap.SgNBAdditionRequestAcknowledge_element && x2ap.LocationInformationSgNB_element && x2ap.pSCell_id_element
${filter_2}=    x2ap.SgNBModificationRequestAcknowledge_element && x2ap.LocationInformationSgNB_element && x2ap.pSCell_id_element
${filter_3}=    x2ap.SgNBModificationRequired_element &&x2ap.LocationInformationSgNB_element && x2ap.pSCell_id_element

*** Keywords ***
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
