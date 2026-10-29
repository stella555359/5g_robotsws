*** Settings ***
Documentation    Keywords for the CB009854_AB_B9a

Library     ute_wtssim
Library     ta5g_throughput
Resource    resources/CB009854_keywords.robot


*** Variables ***
${ULRRCMessageTransfer_9854_b9a}=    f1ap.procedureCode == 13 && nas_5gs.mm.message_type == 0x43
${DLRRCMessageTransfer_9854_b9a}=    nr-rrc.pdu_Session == 1
${ULRRCAfterPDUSessionSetup_9854_b9a}=    nr-rrc.criticalExtensions == 0 && nr-rrc.rrc_TransactionIdentifier == 2 &&
...    f1ap.procedureCode == 13
${UEContextModificationRequest_9854_b9a}=    f1ap.SCell_ToBeSetupMod_List == 4 && f1ap.nRCellIdentity == 00:00:04:00:10 &&
...    f1ap.nRCellIdentity == 00:00:04:00:40 && f1ap.nRCellIdentity == 00:00:04:00:50 &&
...    f1ap.nRCellIdentity == 00:00:04:00:60
${UEContextModificationResponse_9854_b9a}=    f1ap.procedureCode == 7 && nr-rrc.resourceSetToAddModList == 2 &&
...    nr-rrc.maxPayloadSize == 12 && nr-rrc.resourceList == 2 && nr-rrc.csi_ReportConfigToAddModList == 7 &&
...    nr-rrc.reportConfigId == 13 && nr-rrc.reportQuantity == 1 && nr-rrc.reportConfigId == 14 &&
...    nr-rrc.reportQuantity == 7 && nr-rrc.reportConfigId == 22 && nr-rrc.reportQuantity == 6 &&
...    nr-rrc.reportConfigId == 15 && nr-rrc.reportQuantity == 7 && nr-rrc.reportConfigId == 23 &&
...    nr-rrc.reportQuantity == 6 && nr-rrc.reportConfigId == 16 && nr-rrc.reportQuantity == 7 &&
...    nr-rrc.reportConfigId == 24 && nr-rrc.reportQuantity == 6


*** Keywords ***
TC__CB009854-AB-B9a_UE_configured_with_5CC_DL_CA_with_2_FDD_and_3_TDD_serving_cell_is_not_configured_with_2CC_UL_CA_due_to_interaction_with_DSS
    Attach UE And Start Data Traffic    ue_id=3    cell_id=3
    Verify Message    expectation=${ULRRCMessageTransfer_9854_b9a}
    Verify Message    expectation=${DLRRCMessageTransfer_9854_b9a}
    Verify Message    expectation=${ULRRCAfterPDUSessionSetup_9854_b9a}
    Verify Message    expectation=${UEContextModificationRequest_9854_b9a}
    Verify Message    expectation=${UEContextModificationResponse_9854_b9a}
    Start Data Traffic And Verify Traffic Scheduling On All SCell
    Verify DL DSS Traffic Is Scheduled On All Cells 5CC
    Verify UL DSS Traffic Is Scheduled On PCell

    [Teardown]    Deregister UE Without Confirmation    ue_id=all

Attach UE And Start Data Traffic
    [Arguments]    ${ue_id}    ${cell_id}    ${pdu_id}=1    ${gw_id}=3
    Set Internal Traffic Type To UEs    ue_id=${ue_id}
    Attach Ue    ue_id=${ue_id}    cell=${cell_id}
    Establish Pdu Session    ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}    nwslice=1

Set Internal Traffic Type To UEs
    [Arguments]    ${ue_id}    ${pdu_id}=1
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal

Start Data Traffic And Verify Traffic Scheduling On All SCell
    [Arguments]    ${ue_id}=3     ${pdu}=1   ${scell}=0-4    ${Inactive Timer}=10s
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu} trf_id=1 dir=dl mbps=100
    BuiltIn.Sleep    ${Inactive Timer}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu} trf_id=2 dir=dl mbps=100
    BuiltIn.Sleep    ${Inactive Timer}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu} trf_id=3 dir=dl mbps=100
    BuiltIn.Sleep    ${Inactive Timer}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu} trf_id=4 dir=dl mbps=100
    BuiltIn.Sleep    ${Inactive Timer}
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu} trf_id=5 dir=ul mbps=100
    BuiltIn.Sleep    ${Inactive Timer}
    Execute Egate Command    cmd=ue_stats_nr id=${ue_id} scell=${scell}
    BuiltIn.Sleep    ${Inactive Timer}
    BuiltIn.Sleep    60s    Wait for DSS Traffic to stabilize

Verify DL DSS Traffic Is Scheduled On All Cells 5CC
    [Arguments]    ${ue_id}=3
    Verify That Traffic Is Scheduled On All SCells    ue_id=${ue_id}    num_of_scells=4
    Expected Throughput For Ue Should Be Reached    ue_id=${ue_id}    throughput=0.5    direction=dl    selection_type=average    scells=0-4

Verify UL DSS Traffic Is Scheduled On PCell
    [Arguments]    ${ue_id}=3
    Expected Throughput For Ue Should Be Reached    ue_id=${ue_id}    throughput=1    direction=ul    selection_type=average    scells=0-0
    ...                                             cell_group=MCG

Activate And Check If Xp Link is active
    BuiltIn.Sleep    5s
    Execute Egate Command    cmd=enb_xp_param id=2 xp_peers=1
    BuiltIn.Sleep    1s
    ute_wtssim.execute egate command and wait for data    cmd=enb_xp_link_up enb=2 target=1
    ...                                                   cmd=enb_disp id=2 enb=1 type=xp_info    timeout=600
    ...                                                   pass_regexp=XpAP Link .* is up    timeout=600
    # sometimes the link falls, and come back again after 4-5 seconds, so we add a BuiltIn.Sleep here
    BuiltIn.Sleep    10s
    Log to console    \n***Activate eNBSim with XpAp interface completed ***

Start Vm Ethernet Interfaces For DSS
    Start Vm Ethernet Interface    if_name=eth3:EPCsim    ip_with_mask=10.0.1.10/24
    Start Vm Ethernet Interface    if_name=eth3:simeNB    ip_with_mask=10.0.1.11/24
    Start Vm Ethernet Interface    if_name=eth3:CRMsim    ip_with_mask=10.0.1.200/24

Setup Additional Configuration
    Execute Egate Command    cmd=script file=${CURDIR}/resources/Set_DSS_param.cfg
    ...    fail_regexp=DSS_SETUP_FAILURE Not matching cell Ids - NR DSS Setup Req not received yet    timeout=120

Verify That Traffic Is Scheduled On All SCells
    [Arguments]    ${ue_id}=1    ${num_of_scells}=3
    ${num_of_cells}=    Evaluate    int(${num_of_scells}) + int(1)
    Execute Egate Command And Wait For Data
        ...          cmd=ue_stats_nr id=${ue_id} scell=0-${num_of_scells}
        ...          pass_regexp=(CellIndex-[0-${num_of_scells}][\\s][\\s][1-9].*\\n){${num_of_cells}}