*** Settings ***
Documentation
...    Additional robot keywords for CB009485
...    authors: Paulina Karpf Matoga

Resource    testsuite/Krakow/resources/former_l3_sw2/main_cls.robot

*** Keywords ***
Get CRNTI of UE
    [Arguments]  ${ue_id}
    ${egate_output}    Execute Egate Command And Wait For Data
    ...    cmd=ue_disp id=${ue_id}
    ...    pass_regexp=C-RNTI
    ${CRNTI_line}    Get Regexp Matches    ${egate_output}    C-RNTI .* [0-9]+
    ${Actual_CRNTI}    Get Regexp Matches  @{CRNTI_line}   [0-9]+
    [Return]    ${Actual_CRNTI}[0]

Add QoS Flow to PDU Session
    [Arguments]    ${ue_id}    ${pdu_id}    ${qosflow_id}    ${expected_5qi}
    ${cmd}    Set Variable    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qosflow_id}
    ${should_contain}    Set Variable    Added QosFlow with QFI:. 5QI:${expected_5qi}
    ${output}    Execute Egate Command Ext    cmd=${cmd}    pass_regexp=QoS Routing Table
    ${match}    ${qfi}    Should Match Regexp    ${output}    Added QosFlow with QFI:(\\d+) 5QI:${expected_5qi}
    Sleep    5s    reason=procedure completion

PDU Session Release
    [Arguments]    ${ue_id}    ${pdu_id}
    Sleep    3s    reason=PDU Session Setup procedure completion
    Execute Egate Command Ext    cmd=ue_pdu_session_release ue=${ue_id} pdu=${pdu_id} by=amf
    ...    pass_regexp=Successfully released PDU Session
    Sleep    5s    reason=procedure completion

PDU Session Modify
    [Arguments]    ${ue_id}    ${pdu_id}    ${qos_to_add}    ${qos_to_del}
    Execute Egate Command Ext
    ...    cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qos_to_add} qosflows_to_del=${qos_to_del} by=amf
    ...    pass_regexp=Pdu Session Resource Modify Response Message
    Sleep    5s    reason=procedure completion

SA UE Register with rnti check
    [Arguments]    ${ue_id}    ${timeout}=30s    ${pass_regexp}=Received REGISTRATION COMPLETE from UE
    ...    ${should_contain}=@{Empty}
    ${register_output}    Execute Egate Command Ext
    ...    cmd=ue_register id=${ue_id}    pass_regexp=${pass_regexp}    timeout=${timeout}
    ...    should_contain=${should_contain}    log_msg=Registering UE-${ue_id}
    ${match}    ${rnti}    Should Match Regexp    ${register_output}    UE performed.*crnti: (\\d+)
    ...    msg=UE-${ue_id}: Unable to find RNTI in egate output
    [Return]    ${rnti}

Add Bearer in LTE
    [Arguments]       ${ue_id}    ${bearer_id}
    Execute Egate Command Ext    cmd=bearer_add ue=${ue_id} id=${bearer_id} filter=${bearer_id} precedence=${bearer_id}
    ...    pass_regexp=Bearer.*created

NSA Establish DC bearer
    [Arguments]    ${ue_id}    ${bearer_id}
    Execute Egate Command Ext
    ...    cmd=enb_ue_dc_modify ue=${ue_id} bearer_to_add=${bearer_id} by=enb cause=RN_CauseRadioNetwork_unspecified type=split_scg
    ...    pass_regexp=Successfully reconfigured dual connectivity
    Sleep    5s    reason=procedure completion

NSA Release DC bearer
    [Arguments]    ${ue_id}    ${bearer_id}
    Execute Egate Command Ext    cmd=bearer_del ue=${ue_id} id=${bearer_id}
    ...    pass_regexp=deleted in result of PGW-initiated Bearer Deletion procedure
    Sleep    5s    reason=procedure completion

UE RRC Reestablish
    [Arguments]    ${ue_id}   ${cell_id}    ${gnb_id}    ${pass_regexp}=UE${ue_id}: NR RRC Reestablishment sucessfully completed
    ...    ${should_contain}=@{Empty}
    Execute Egate Command Ext    cmd=ue_rrc_reestablish id=${ue_id} cell=${cell_id} gnb=${gnb_id}
    ...    pass_regexp=${pass_regexp}    should_contain=${should_contain}
    Sleep    5s    reason=procedure completion

Switch HO Type To ${type} In Ext GNB
    &{values}    Create Dictionary    Xn=allowed    NG=XnHoNotAllowed
    Change NIDD Parameter Online
    ...    dist=MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1    param=handoverAllowedSA    value=${values}[${type}]

Set Sim GNB To ${type} HO and ${event} Event
    &{ho}    Create Dictionary    Xn=xn_based    NG=ng_based
    Update Sim GNB Parameters    id=3    measEvent=${event}    sa_ho=${ho}[${type}]

Prepare Ue For Inter gNB HO
    [Arguments]    ${ue_id}=1
    ${cmd1}    Set Variable
    ...    ue_history_information_list_add_ngran id=${ue_id} gnb_id=2 cell_type=large nrcgi=311:489|0x01 time_ue_stayed_in_cell=97
    ${cmd2}    Set Variable
    ...    ue_history_information_list_add_ngran id=${ue_id} gnb_id=3 cell_type=large nrcgi=311:489|0x01 time_ue_stayed_in_cell=98
    ${cmd3}    Set Variable    ue_history_information_list id=${ue_id} action=commit
    ${cmd4}    Set Variable    ue_enb_param id=${ue_id} ue_history_list=${ue_id}
    ute_wtssim.execute_egate_command    cmd=${cmd1};${cmd2};${cmd3};${cmd4}

Prepare HO to trigger Reestablishment to Target Cell
    Execute Egate Command Ext    cmd=ue_nr_rrc_reconf_param id=1 if_contains=reconfiguration_with_sync action=reestablish gnb=2 cell=1

Activate Voice Fallback AMF
    Execute Egate Command Ext    cmd=amf_param id=1 voice_fallback=on

Setup 5QI-1 and Expect Redirection
    [Arguments]    ${ue_id}    ${pdu_id}
    Execute Egate Command Ext    cmd=ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=3 by=amf
    ...    pass_regexp=Re-direction to 4G/LTE
    Sleep    5s    reason=Traces collectioon
