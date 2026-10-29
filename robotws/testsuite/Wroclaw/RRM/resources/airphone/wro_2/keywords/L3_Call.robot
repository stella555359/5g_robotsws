*** Settings ***
Documentation    Keywords for L3 Call
Resource    taf/rfrl/common_resources/robot/libraries_instances.robot


*** Keywords ***
Attach UE And Establish PDU Session
    [Arguments]    ${ue_id}    ${cell_id}    ${enb_id}=1    ${pdu_id}=1    ${gw_id}=1    ${pdu_session_setup_timeout}=15
    ...    ${nwslice}=1
    Attach UE    ue_id=${ue_id}    cell=${cell_id}    enb=${enb_id}
    ...    pass_regexp=Received REGISTRATION COMPLETE from UE
    Set Internal Traffic Type To UE    ue_id=${ue_id}    pdu_id=${pdu_id}
    Establish PDU Session    ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}    nwslice=${nwslice}
    ...    timeout=${pdu_session_setup_timeout}
    ...    pass_regexp=UE${ue_id}: Established PDU session ID=${pdu_id} using PDU Gateway ID=

Set Internal Traffic Type To UE
    [Arguments]    ${ue_id}    ${pdu_id}
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal

Release PDU Session
    [Arguments]    ${ue_id}    ${pdu_id}=1
    Execute Egate Command    cmd=ue_pdu_session_release ue=${ue_id} pdu=${pdu_id}
    ...    pass_regexp=Successfully released PDU Session with ID ${pdu_id}
    BuiltIn.Sleep  1s
