*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS ==
...      - Maciej Madej <maciej.madej@nokia.com>
...      - Mateusz Matusik <mateusz.matusik@nokia.com>
...      - Tomasz Pyrek <tomasz.pyrek@nokia.com>

Resource    CB007564_common_keywords.robot

*** Variables ***
${cmd_to_block_sctp_on_f1_link_in_gnb_ipv4}=    iptables -t filter -A OUTPUT -p sctp --dport 38472 -j DROP
${cmd_to_block_sctp_on_f1_link_in_gnb_ipv6}=    ip6tables -t filter -A OUTPUT -p sctp --dport 38472 -j DROP
${cmd_to_unblock_sctp_on_f1_link_in_gnb_ipv4}=  iptables -t filter -D OUTPUT -p sctp --dport 38472 -j DROP
${cmd_to_unblock_sctp_on_f1_link_in_gnb_ipv6}=  ip6tables -t filter -D OUTPUT -p sctp --dport 38472 -j DROP

*** Keywords ***
Cleanup after test B102
    Deregister UE1
    Deregister UE2
    Deregister UE3
    Deregister UE4
    Deregister UE5
    Execute egate command   cmd=trf_data_stop ue=1-5
    Execute egate command   cmd=ue_testmode_set_nr id=1 testmode=rlf action=deactivate profile_id=1
    Execute enb command    cmd=${cmd_to_unblock_sctp_on_f1_link_in_gnb_ipv4}
    Execute enb command    cmd=${cmd_to_unblock_sctp_on_f1_link_in_gnb_ipv6}

Cleanup after test B102 with cell lock
    Deregister UE1
    Deregister UE2
    Deregister UE3
    Deregister UE4
    Deregister UE5
    Execute egate command   cmd=trf_data_stop ue=1-5
    Execute egate command   cmd=ue_testmode_set_nr id=1 testmode=rlf action=deactivate profile_id=1
    Unlock Single Cell    cell_id=1

Cleanup after test B101
    Deregister UE1
    Deregister UE2
    Deregister UE3
    Deregister UE4

Deactivate Radio Link Failure for UE${ue_id:\d+}
    Execute egate command   cmd=ue_testmode_set_nr id=${ue_id} testmode=rlf action=deactivate profile_id=1

Prepare test environment B101_UE_lost
    Enable internal mirroring for alias  gNB2
    Collect PM counters file

Prepare test environment B102
    Enable internal mirroring for alias  gNB2
    Collect PM counters file

Start DL traffic over UE${ue_id:[1-9]} PDU Session
    Execute egate command   cmd=trf_data_start ue=${ue_id} pdu=1 dir=dl mbps=1

Start DL traffic over UE5 secondary PDU Session
    Sleep  5s
    Execute egate command   cmd=trf_data_start ue=5 pdu=2 dir=dl mbps=1

Start tshark collecting
    Start tshark
    ...   log_filename=eth3.pcap
    ...   eth_interface=eth3
    ...   alias=gtp_alias

Stop tshark collecting
    Stop tshark   alias=gtp_alias

Trigger NG Reset from AMF${amf_id:[1-9]} for UE${ue_id:[1-9]} only
    ${ics_ue_ran_id}=    Extract UE RAN ID from ICS   UE${ue_id}_NGAP_attach  ICS_Req
    Expect Message Flow
    ...     AMF1:NGAP_NGReset (ResetType contains (partOfNG-Interface contains (rAN-UE-NGAP-ID eq ${ics_ue_ran_id}))) as NG_Reset
    ...     AMF1:NGAP_NGResetAcknowledge
    ...     alias=AMF${amf_id}_NG_reset
    ...     overall_timeout=30

    Execute egate command   cmd=ng_link_reset by=amf:${amf_id} ue=${ue_id}

Trigger NG Reset from gNB2 for all UEs by breaking SCTP on F1 interface
    Expect Message Flow
    ...     AMF1:NGAP_NGReset (ResetType contains (nG-Interface eq 'reset-all')) as NG_Reset
    ...     AMF1:NGAP_NGResetAcknowledge
    ...     alias=gNB2_NG_reset
    ...     overall_timeout=300

    Execute enb command    cmd=${cmd_to_block_sctp_on_f1_link_in_gnb_ipv4}
    Execute enb command    cmd=${cmd_to_block_sctp_on_f1_link_in_gnb_ipv6}

Trigger NG Reset from gNB2 by locking cell
    [Arguments]     ${cell_id}=1
    Expect Message Flow
    ...     AMF1:NGAP_NGReset
    ...     AMF1:NGAP_NGResetAcknowledge
    ...     AMF1:NGAP_NGReset
    ...     AMF1:NGAP_NGResetAcknowledge
    ...     alias=gNB2_lock_cell_NG_reset
    ...     overall_timeout=300

    Lock Single Cell    cell_id=${cell_id}

Trigger Radio Link Failure for UE${ue_id:\d+}
    Expect NGAP UE Context Release Request flow for UE${ue_id} with cause "radioNetwork: unspecified"
    Expect RRC release flow for UE${ue_id}

    Expect Message Flow
    ...     gNB2:F1AP_UEContextModificationRequired (Cause contains (radioNetwork eq 'rl-failure-others'))
    ...     alias=UE${ue_id}_f1ap_msg
    ...     overall_timeout=30

    Execute egate command   cmd=rlf_testmode_nr profile_id=1 num_stop_csi_report=2000 num_stop_dlharq_tx=3000
    Execute egate command   cmd=ue_testmode_set_nr id=${ue_id} testmode=rlf action=activate profile_id=1

Trigger sending GTP-U Error Indication message to gNB2 for UE${ue_id:\d+}
    Expect NGAP UE Context Release Request flow for UE${ue_id} with cause "transport: unspecified"
    Expect RRC release flow for UE${ue_id}

    Expect Message Flow
    ...     gNB2:E1AP_BearerContextModificationRequired (Cause contains (transport eq 'transport-resource-unavailable'))
    ...     alias=UE${ue_id}_e1ap_msg
    ...     overall_timeout=30

    Start tshark collecting
    Execute egate command    cmd=upf_ue_pdu_inject_error_ind id=1 ue=${ue_id} pdu=1 abnormal_scenario=none

Block sending RRC Reconfiguration Complete from UE${ue_id:[1-9]} during PDU Session Setup procedure
    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCRelease
    ...     alias=UE${ue_id}_RRC_release
    ...     overall_timeout=30

    Expect Message Flow
    ...     AMF1:NGAP_PDUSessionResourceSetupResponse (cause contains (radioNetwork eq 'failure-in-radio-interface-procedure'))
    ...     alias=UE${ue_id}_PDU_session_setup_fail
    ...     overall_timeout=30

    Expect NGAP UE Context Release Request flow for UE${ue_id} with cause "radioNetwork: radio-connection-with-ue-lost"

    Execute egate command    cmd=ue_nr_rrc_reconf_param id=${ue_id} if_contains=any action=drop nth=1

Block sending RRC Reconfiguration Complete from UE${ue_id:[1-9]} during PDU Session Release procedure
    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCRelease
    ...     alias=UE${ue_id}_RRC_release
    ...     overall_timeout=30

    Expect Message Flow
    ...     AMF1:NGAP_PDUSessionResourceReleaseCommand (cause contains (nas eq 'normal-release'))
    ...     AMF1:NGAP_PDUSessionResourceReleaseResponse
    ...     alias=UE${ue_id}_PDU_session_release
    ...     overall_timeout=10

    Expect NGAP UE Context Release Request flow for UE${ue_id} with cause "radioNetwork: radio-connection-with-ue-lost"

    Execute egate command    cmd=ue_nr_rrc_reconf_param id=${ue_id} if_contains=any action=drop nth=1
    Sleep   2s

Trigger A2 measurement send to gNB2 for UE${ue_id:[1-9]}
    Expect NGAP UE Context Release Request flow for UE${ue_id} with cause "radioNetwork: radio-connection-with-ue-lost"

    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCRelease
    ...     alias=UE${ue_id}_RRC_release
    ...     overall_timeout=30

    Execute egate command    cmd=ue_measurement_send_nr id=${ue_id} meas_id=1 event=A2 srsrp_nr=10

Block sending RRC Reconfiguration Complete from UE_${ue_id:[1-9]}
    Execute egate command    cmd=ue_nr_rrc_reconf_param id=${ue_id} if_contains=any action=drop nth=1

Unblock sending RRC Reconfiguration Complete from UE${ue_id:[1-9]}
    Execute egate command    cmd=ue_nr_rrc_reconf_param id=${ue_id} reset

Trigger PDU session release for UE${ue_id:[1-9]}
    Execute egate command    cmd=ue_pdu_session_release ue=${ue_id} pdu=1 by=ue

Wait 10s for drbInactivityTimerSA to expire for UE${ue_id:[1-9]}
    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCRelease
    ...     alias=UE${ue_id}_RRC_release
    ...     overall_timeout=30

    Expect NGAP UE Context Release Request flow for UE${ue_id} with cause "radioNetwork: user-inactivity"

    Expect Message Flow
    ...     AMF1:NGAP_UEContextReleaseRequest (Cause contains (radioNetwork eq 'user-inactivity'))
    ...     AMF1:NGAP_UEContextReleaseCommand
    ...     AMF1:NGAP_UEContextReleaseComplete
    ...     alias=UE${ue_id}_UEContextRelease_inact
    ...     overall_timeout=30

Verify that gNB2 received GTP-U error indication message
    Sleep  5s
    Stop capturing  alias=gtp_alias
    Verify tshark
    ...   alias=gtp_alias
    ...   packet_filter=gtp.message==0x1a
    ...   pass_criteria= >=1
    ...   timeout=30
    Stop tshark collecting

Verify that gNB2 received NG Reset message from AMF1
    Flow occurred as expected   alias=AMF1_NG_reset
    #gNB does not send UEContextReleaseRequest to AMF so we need to manually kill UE in AP
    Execute egate command    cmd=ue_kill id=3

Verify that gNB2 sent E1AP: Bearer Context Modification Required message with cause "transport-resource-unavailable" for UE${ue_id:[1-9]}
    Flow occurred as expected   alias=UE${ue_id}_e1ap_msg

Verify that gNB2 sent F1AP: UE Context Modification Required message with cause "rl-failure-others" for UE${ue_id:[1-9]}
    Flow occurred as expected   alias=UE${ue_id}_f1ap_msg

Verify that gNB2 sent NG Reset message to AMF1
    Flow occurred as expected   alias=gNB2_NG_reset

Verify that gNB2 sent NG Reset message to AMF1 after cell lock
    Flow occurred as expected   alias=gNB2_lock_cell_NG_reset

Verify that gNB2 sent UE Context Release Request to AMF1 with cause: "Transport: unspecified" for UE${ue_id:[1-9]}
    Flow occurred as expected   alias=UE${ue_id}_UE_Context_Release

Verify that gNB2 sent UE Context Release Request to AMF1 with cause: "radioNetwork: radio-connection-with-ue-lost" for UE${ue_id:[1-9]}
    Flow occurred as expected   alias=UE${ue_id}_UE_Context_Release

Verify that gNB2 sent UE Context Release Request to AMF1 with cause: "radioNetwork: user-inactivity" for UE${ue_id:[1-9]}
    Flow occurred as expected   alias=UE${ue_id}_UE_Context_Release

Verify that gNB2 sent PDU Session Resource Setup Response with failed PDU session and cause "radioNetwork: failure-in-radio-interface-procedure"
    Flow occurred as expected   alias=UE2_PDU_session_setup_fail

Verify that gNB2 sent PDU Session Resource Release Command with cause "nas: normal-release"
    Flow occurred as expected   alias=UE3_PDU_session_release

Setup second QoS FLow for UE_${ue_id:[1-9]}
    Expect Message Flow
    ...     AMF1:NGAP_PDUSessionResourceModifyRequest as PDU_Req
    ...     AMF1:NGAP_PDUSessionResourceModifyResponse as PDU_Resp
    ...     alias=UE${ue_id}_PDU_modify_5qi_6
    ...     overall_timeout=30

    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCReconfiguration
    ...     UE_${ue_id}:NR-RRC_RRCReconfigurationComplete
    ...     alias=UE${ue_id}_RRC_Reconfiguration_5qi_6
    ...     overall_timeout=30

    Execute egate command   cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=6 by=amf

    Flow occurred as expected  alias=UE${ue_id}_PDU_modify_5qi_6
    Flow occurred as expected  alias=UE${ue_id}_RRC_Reconfiguration_5qi_6

Set observers for redirection for UE_${ue_id:[1-9]}
    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCRelease
    ...     alias=UE_${ue_id}_RRC_Release
    ...     overall_timeout=30

    Expect Message Flow
    ...     AMF1:NGAP_UEContextReleaseRequest as UEContRelReq
    ...     AMF1:NGAP_UEContextReleaseCommand
    ...     AMF1:NGAP_UEContextReleaseComplete
    ...     alias=UE${ue_id}_NGAP_UEContextRelease
    ...     overall_timeout=30

Trigger sending A2 measurement
    Expect Message Flow
    ...     UE_1:NR-RRC_MeasurementReport
    ...     alias=UE_1_RRCMeasurementReport
    ...     overall_timeout=30
    Sleep  1
    Execute egate command  cmd=ue_measurement_send_nr id=1 meas_id=1 event=A2 srsrp_nr=4 srsrq_nr=4 phycell_id=1 nrsrp_nr=34 nrsrq_nr=34
    Flow occurred as expected  alias=UE_1_RRCMeasurementReport

Verify that RRC Connection Release for UE_${ue_id:[1-9]} was sent
    Flow occurred as expected  alias=UE_${ue_id}_RRC_Release

Verify that NgAP:UEContextReleaseRequest for UE_${ue_id:[1-9]} was sent with IE "value PDUSessionResourceListCxtRelReq" and cause "redirection"
    Flow occurred as expected  alias=UE${ue_id}_NGAP_UEContextRelease
    Verify That Message Fulfills Query
    ...     (Cause contains (radioNetwork eq 'redirection') and (PDUSessionResourceListCxtRelReq contains (pDUSessionID eq 1)))
    ...     message_alias=UEContRelReq
    ...     flow_alias=UE${ue_id}_NGAP_UEContextRelease

Prepare test environment B103
   Collect PM counters file

Trigger PDU Session Modify to delete QoS flow from UE${ue_id:[1-9]} second PDU session with cause: "${cause_type}: ${cause_message}"
    Sleep  2s
    Expect PDU modification flow for UE${ue_id} with cause "${cause_type}: ${cause_message}"
    Expect RRC reconfiguration flow for UE${ue_id}

    Execute egate command   cmd=amf_ue_pdu_modify_param id=1 ue=${ue_id} action=override_ie qos_flow_to_del_cause=RN_radio_connection_with_ue_lost
    Execute egate command   cmd=ue_pdu_session_modify ue=${ue_id} pdu=2 qosflows_to_del=${second_qfi_id}

Trigger PDU Session Resource Release for UE${ue_id:[1-9]} second PDU session with cause: "nas: normal-release"
    Sleep  2s
    Expect PDU release flow for UE${ue_id} PDU Session Resource Release with cause "nas: normal-release"
    Expect RRC reconfiguration flow for UE${ue_id}

    Execute egate command   cmd=amf_ue_pdu_release_param id=1 reset
    Execute egate command
    ...   cmd=pdu_session_ue_release ue=${ue_id} pdu=2
    ...   pass_regexp=AMF-1: Successfully released PDU Session with ID 2

Trigger PDU Session Resource Release for UE${ue_id:[1-9]} second PDU session with cause: "protocol: message-not-compatible-with-receiver-state"
    Sleep  2s
    Expect PDU release flow for UE${ue_id} PDU Session Resource Release with cause "protocol: message-not-compatible-with-receiver-state"
    Expect RRC reconfiguration flow for UE${ue_id}

    Execute egate command   cmd=amf_ue_pdu_release_param id=1 ue=1 cause=PROTOCOL_message_not_compatible_with_receiver_state
    Execute egate command
    ...   cmd=pdu_session_ue_release ue=${ue_id} pdu=2
    ...   pass_regexp=AMF-1: Successfully released PDU Session with ID 2

Trigger PDU Session Resource Release for UE${ue_id:[1-9]} second PDU session with cause: "radioNetwork: radio-connection-with-ue-lost"
    Sleep  2s
    Expect PDU release flow for UE${ue_id} PDU Session Resource Release with cause "radioNetwork: radio-connection-with-ue-lost"
    Expect RRC reconfiguration flow for UE${ue_id}

    Execute egate command   cmd=amf_ue_pdu_release_param id=1 ue=1 cause=RN_radio_connection_with_ue_lost
    Execute egate command
    ...   cmd=pdu_session_ue_release ue=${ue_id} pdu=2
    ...   pass_regexp=AMF-1: Successfully released PDU Session with ID 2

Trigger PDU Session Resource Release for UE${ue_id:[1-9]} second PDU session with normal cause
    Sleep  2s
    Expect PDU release flow for UE${ue_id} PDU Session Resource Release with cause "nas: normal-release"
    Expect NGAP UE Context Release Request flow for UE${ue_id} with cause "radioNetwork: radio-connection-with-ue-lost"

    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCReconfiguration (drb-ToReleaseList is present)
    ...     alias=UE${ue_id}_RRC_Reconfiguration
    ...     overall_timeout=30

    Expect message will not occur
    ...     UE_${ue_id}:NR-RRC_RRCReconfigurationComplete
    ...     alias=UE${ue_id}_RRC_reconf_complete
    ...     overall_timeout=10

    Execute egate command   cmd=amf_ue_pdu_release_param id=1 reset
    Execute egate command
    ...   cmd=pdu_session_ue_release ue=1 pdu=2

Trigger UE${ue_id:[1-9]} context release with cause: "radioNetwork: slice-not-supported"
    Sleep  2s
    Expect NGAP UE Context Release Command flow for UE${ue_id} with cause "radioNetwork: slice-not-supported"

    Execute egate command   cmd=ue_ng_ctx_release id=${ue_id} by=amf cause=RN_slice_not_supported

Expect PDU release flow for UE${ue_id:[1-9]} PDU Session Resource Release with cause "${cause_type}: ${cause_message}"
    Expect Message Flow
    ...     AMF1:NGAP_PDUSessionResourceReleaseCommand (cause contains (${cause_type} eq '${cause_message}'))
    ...     AMF1:NGAP_PDUSessionResourceReleaseResponse
    ...     alias=UE${ue_id}_PDU_release
    ...     overall_timeout=30

Expect NGAP UE Context Release Command flow for UE${ue_id:[1-9]} with cause "${cause_type}: ${cause_message}"
    Expect Message Flow
    ...     AMF1:NGAP_UEContextReleaseCommand (Cause contains (${cause_type} eq '${cause_message}'))
    ...     AMF1:NGAP_UEContextReleaseComplete
    ...     alias=UE${ue_id}_UE_Context_Release
    ...     overall_timeout=30

Expect NGAP UE Context Release Request flow for UE${ue_id:[1-9]} with cause "${cause_type}: ${cause_message}"
    Expect Message Flow
    ...     AMF1:NGAP_UEContextReleaseRequest (Cause contains (${cause_type} eq '${cause_message}'))
    ...     AMF1:NGAP_UEContextReleaseCommand (Cause contains (${cause_type} eq '${cause_message}'))
    ...     AMF1:NGAP_UEContextReleaseComplete
    ...     alias=UE${ue_id}_UE_Context_Release
    ...     overall_timeout=30

Expect PDU modification flow for UE${ue_id:[1-9]} with cause "${cause_type}: ${cause_message}"
    Expect Message Flow
    ...   AMF1:NGAP_PDUSessionResourceModifyRequest (cause contains (${cause_type} eq '${cause_message}'))
    ...   AMF1:NGAP_PDUSessionResourceModifyResponse
    ...   alias=UE${ue_id}_PDU_Modify
    ...   overall_timeout=30

Verify that modification of UE${ue_id:[1-9]} second PDU Session succeded
    Flow occurred as expected  alias=UE${ue_id}_PDU_Modify
    Flow occurred as expected  alias=UE${ue_id}_RRC_Reconfiguration

Verify that second UE${ue_id:[1-9]} PDU Session Resource Release failed
    Flow occurred as expected  alias=UE${ue_id}_PDU_release
    Flow occurred as expected  alias=UE${ue_id}_RRC_Reconfiguration
    Flow not occurred for message  alias=UE${ue_id}_RRC_reconf_complete

Verify that second UE${ue_id:[1-9]} PDU session was released with cause: "radioNetwork: radio-connection-with-ue-lost"
    Flow occurred as expected  alias=UE${ue_id}_PDU_release
    Flow occurred as expected  alias=UE${ue_id}_RRC_Reconfiguration
    Verify that message has fields
    ...  drb-ToReleaseList is present
    ...  message_alias=UE_${ue_id}:NR-RRC_RRCReconfiguration
    ...  flow_alias=UE${ue_id}_RRC_Reconfiguration

Verify that second UE${ue_id:[1-9]} PDU session was released with cause: "nas: normal-release"
    Flow occurred as expected  alias=UE${ue_id}_PDU_release
    Flow occurred as expected  alias=UE${ue_id}_RRC_Reconfiguration
    Verify that message has fields
    ...  drb-ToReleaseList is present
    ...  message_alias=UE_${ue_id}:NR-RRC_RRCReconfiguration
    ...  flow_alias=UE${ue_id}_RRC_Reconfiguration

Verify that second UE${ue_id:[1-9]} PDU session was released with cause: "protocol: message-not-compatible-with-receiver-state"
    Flow occurred as expected  alias=UE${ue_id}_PDU_release
    Flow occurred as expected  alias=UE${ue_id}_RRC_Reconfiguration
    Verify that message has fields
    ...  drb-ToReleaseList is present
    ...  message_alias=UE_${ue_id}:NR-RRC_RRCReconfiguration
    ...  flow_alias=UE${ue_id}_RRC_Reconfiguration

Cleanup after test B103
    Set UE1 to stop ignoring RRC Reconfiguration messages
    Deregister UE1
    Deregister UE2
    Execute egate command   cmd=amf_ue_pdu_release_param id=1 reset
    Execute egate command   cmd=amf_ue_pdu_modify_param id=1 reset
