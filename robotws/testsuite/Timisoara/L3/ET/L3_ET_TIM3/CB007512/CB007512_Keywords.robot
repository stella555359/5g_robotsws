*** Settings ***
Resource     ../resources/5G_SW_WRO_Keywords.robot
Resource     ../resources/scripts/libraries_instances.robot
Library      ta5g_throughput
Library      ta5g_bearers

*** Variables ***
${X2AP_SN_STATUS_TRANSFER}=    x2ap.SNStatusTransfer_element
${X2AP_SGNB_MODIFICATION_REQUEST_REJECT}=    x2ap.SgNBModificationRequestReject_element
${X2AP_SGNB_MODIFICATION_REQUEST}=    x2ap.SgNBModificationRequest_element

*** Keywords ***
Activate CB007512 feature
     [Arguments]    ${ue_id}
    Execute egate command    cmd=ue_enb_endc_param id=${ue_id} direct_bearer_sn_modification=on

Trigger SgNB Addition
    Start Gnb Addition Procedure    ue=11    target_cells=1    target_gnb=2    bearer=1,4    dc_type=split_scg
    ...                             pass_regexp=Proxy \\(eNB 2 cell 1\\) reported successful RA

Add Two Bearers
    Add Bearers To Ue    ue_id=11    bearers_params=id=2 filter=2 precedence=2 id=3 filter=3 precedence=3 by=pgw

Attach Ue And Perform SgNBAdditionRequest
    [Arguments]    ${ue_id}
    Attach Ue To Enb    ue_id=${ue_id}
    Add Bearer    ue_id=11     pass_regexp=PGW-initiated Bearer Creation. Bearer-4 \\(EBI=6, QCI=6\\) created
    ...                        bearer_id=4    filter=1    precedence=1    by=pgw
    Trigger SgNB Addition
    Verify Tcpdump Log       packet_filter=${X2AP_SGNB_ADDITION_REQUEST_ACKNOWLEDGE}
