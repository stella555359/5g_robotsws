*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS ==
...      - Maciej Madej <maciej.madej@nokia.com>
...      - Mateusz Matusik <mateusz.matusik@nokia.com>
...      == MAINTAINER ==
...      - Maciej Madej <maciej.madej@nokia.com>
...      - Mateusz Matusik <mateusz.matusik@nokia.com>
...      - I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Resource    CB007564_common_keywords.robot

*** Keywords ***
Setup secondary PDU Session in UE${ue_id:\d+} with one QoS Flow
    Sleep  5s
    ${gw_id}=    Evaluate    ${ue_id} + 6
    Execute egate command
    ...   cmd=ue_pdu_session_setup ue=${ue_id} pdu=2 gw=${gw_id} nwslice=1
    ...   pass_regexp=AMF-1: PDU Session Establishment Request with PDU Session ID 2 handled successfully
    Sleep  1s

Prepare test environment A103
    Collect PM counters file

Prepare test environment A104
    Collect PM counters file

Set RRC Reconfiguration to fail for UE${ue_id:[1-9]}
    Execute egate command   cmd=ue_nr_rrc_reconf_param id=${ue_id} if_contains=any action=reestablish cause=reconfigurationFailure

Set RRC Reconfiguration to work correctly for UE${ue_id:[1-9]}
    Set UE${ue_id} to stop ignoring RRC Reconfiguration messages

Trigger PDU Session Resource Modify for UE${ue_id:[1-9]} second PDU session to add one QoS flow
    Sleep  2s
    Expect PDU modification flow for UE${ue_id} PDU Session Resource Modify with cause "radioNetwork: radio-connection-with-ue-lost"
    Expect RRC release flow for UE${ue_id}

    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCReconfiguration
    ...     alias=UE${ue_id}_RRC_Reconfiguration
    ...     overall_timeout=30

    Expect message will not occur
    ...     UE_${ue_id}:NR-RRC_RRCReconfigurationComplete
    ...     alias=UE${ue_id}_RRC_reconf_complete
    ...     overall_timeout=10

    Execute egate command   cmd=ue_pdu_session_modify ue=${ue_id} pdu=2 qosflows_to_add=6

Trigger PDU Session Resource Modify for UE${ue_id:[1-9]} second PDU session to delete unexisting QoS flow
    Sleep  2s
    Expect PDU modification flow for UE${ue_id} PDU Session Resource Modify with cause "radioNetwork: unkown-qos-flow-ID"

    Execute egate command   cmd=ue_pdu_session_modify ue=${ue_id} pdu=2 qosflows_to_del=4 by=amf validation=off

Trigger PDU Session Resource Modify for UE${ue_id:[1-9]} second PDU session with multiple QoS Flow ID instances
    Sleep  2s
    Expect PDU modification flow for UE${ue_id} PDU Session Resource Modify with cause "radioNetwork: multiple-qos-flow-ID-instances"

    Execute egate command   cmd=ue_pdu_session_modify ue=${ue_id} pdu=2 qosflows_to_add=6 qosflows_to_del=6 by=amf validation=off

Trigger PDU Session Resource Modify for UE${ue_id:[1-9]} second PDU session with not supported 5QI-1 value
    Sleep  2s
    Expect PDU modification flow for UE${ue_id} PDU Session Resource Modify with cause "radioNetwork: not-supported-5QI-value"

    Execute egate command   cmd=ue_pdu_session_modify ue=${ue_id} pdu=2 qosflows_to_add=1

Trigger PDU Session Resource Modify for UE${ue_id:[1-9]} second PDU session with new QoS flow without mandatory IE
    Sleep  2s
    Expect PDU modification flow for UE${ue_id} PDU Session Resource Modify with cause "protocol: semantic-error"

    Execute egate command   cmd=amf_ue_pdu_modify_param id=1 ue=${ue_id} action=missing_qos_param
    Execute egate command   cmd=ue_pdu_session_modify ue=${ue_id} pdu=2 qosflows_to_add=6

Trigger PDU Session Resource Modify for UE${ue_id:[1-9]} second PDU session to add one QoS flow and expect reestablishment
    Sleep  2s
    Expect PDU modification flow for UE${ue_id} PDU Session Resource Modify with cause "radioNetwork: radio-connection-with-ue-lost"

    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCReconfiguration
    ...     UE_${ue_id}:NR-RRC_RRCReestablishmentRequest as ReestablishmentRequest
    ...     alias=UE${ue_id}_RRC_Reconfiguration_fail
    ...     overall_timeout=30

    Execute egate command   cmd=ue_pdu_session_modify ue=${ue_id} pdu=2 qosflows_to_add=6

Verify that gNB does not receive RRC Reconfiguration Complete from UE${ue_id:[1-9]} and the rrcGuardTimer times out
    Flow occurred as expected  alias=UE${ue_id}_RRC_Reconfiguration
    Flow not occurred for message  alias=UE${ue_id}_RRC_reconf_complete

Verify that gNB sends PDU Session Resource Modify Response for UE${ue_id:[1-9]} with cause: "${cause_type}: ${cause_message}"
    Flow occurred as expected  alias=UE${ue_id}_PDU_modify

Verify that gNB receives from UE${ue_id:[1-9]} RRC Reestablishment Request message with the cause set to "reconfigurationFailure"
    Flow occurred as expected  alias=UE${ue_id}_RRC_Reconfiguration_fail
    Verify that message has fields
    ...  reestablishmentCause eq 'reconfigurationFailure'
    ...  message_alias=ReestablishmentRequest
    ...  flow_alias=UE${ue_id}_RRC_Reconfiguration_fail

Expect PDU modification flow for UE${ue_id:[1-9]} PDU Session Resource Modify with cause "${cause_type}: ${cause_message}"
    Expect Message Flow
    ...     AMF1:NGAP_PDUSessionResourceModifyRequest
    ...     AMF1:NGAP_PDUSessionResourceModifyResponse (cause contains (${cause_type} eq '${cause_message}'))
    ...     alias=UE${ue_id}_PDU_modify
    ...     overall_timeout=30

Block UE${ue_id:[1-9]} response to UE Capability Enquiry
    Execute egate command   cmd=ue_capability_enquiry_param id=${ue_id} if_contains=any action=drop

Unblock UE${ue_id:[1-9]} response to UE Capability Enquiry
    Execute egate command   cmd=ue_capability_enquiry_param id=${ue_id} if_contains=any action=none

Cleanup after test A103
    Set RRC Reconfiguration to work correctly for UE1
    Set RRC Reconfiguration to work correctly for UE6
    Execute egate command   cmd=amf_ue_pdu_modify_param id=1 reset
    Deregister UE1
    Deregister UE2
    Deregister UE3
    Deregister UE4
    Deregister UE5
    Deregister UE6

Cleanup after test A104
    Unblock UE1 response to UE Capability Enquiry
    Set UE2 to stop ignoring RRC Reconfiguration messages
    Deregister UE1
    Deregister UE2

Try to attach UE${ue_id:[1-9]} to gNB2 and setup initial PDU Session with one QoS Flow
    Sleep  2s
    Expect RRC messages flow for UE${ue_id} during UE Attach prcedure

    Expect Message Flow
    ...     AMF1:NGAP_InitialUEMessage as InitalMessage
    ...     AMF1:NGAP_InitialContextSetupRequest as ICS_Req
    ...     AMF1:NGAP_InitialContextSetupFailure as ICS_Fail
    ...     alias=UE${ue_id}_NGAP_attach_fail
    ...     overall_timeout=30

    Attach UE   ue_id=${ue_id}
    Execute egate command
    ...   cmd=ue_pdu_session_setup pdu=1 ue=${ue_id} gw=${ue_id} nwslice=1
    ...   pass_regexp=AMF-1: Initial Context Setup Failure for UE with AMF UE ID

Verify that gNB2 sends ICS Failure with cause: "${cause_type}: ${cause_message}" for UE${ue_id:[1-9]}
    Flow occurred as expected   alias=UE${ue_id}_RRC_attach
    Flow occurred as expected   alias=UE${ue_id}_NGAP_attach_fail
    Verify that message has fields
    ...     Cause..${cause_type} eq '${cause_message}'
    ...  message_alias=ICS_Fail
    ...  flow_alias=UE${ue_id}_NGAP_attach_fail

Prepare test environment A105
    Setup devices aliases

Cleanup after test A105
    Execute egate command  cmd=kill_ue id=1-5

Setup environment for procedure 1
    Execute egate command  cmd=amf_param id=1 emergency_service_fallback=on target_cn=epc
    Execute egate command  cmd=amf_ue_ics_param id=1 ue=1 emergency_fb=on
    Collect PM counters file

    Expect Message Flow
    ...     UE_1:NR-RRC_RRCSetupRequest as RRCSetup
    ...     UE_1:NR-RRC_RRCSetup
    ...     UE_1:NR-RRC_RRCRelease
    ...     alias=UE1_RRC_release
    ...     overall_timeout=30

    Expect Message Flow
    ...     AMF1:NGAP_InitialUEMessage as InitalMessage
    ...     AMF1:NGAP_InitialContextSetupRequest as ICS_Req
    ...     AMF1:NGAP_InitialContextSetupResponse as ICSResponse
    ...     AMF1:NGAP_UEContextReleaseRequest as ue_contex_req
    ...     AMF1:NGAP_UEContextReleaseCommand
    ...     AMF1:NGAP_UEContextReleaseComplete
    ...     alias=UE1_NGAP_ics_emer_fallback
    ...     overall_timeout=30

Setup environment for procedure 2
    Execute egate command  cmd=amf_ue_ics_param id=1 ue=2 emergency_fb=on
    Set actEmergencyFallback to false

        Expect Message Flow
    ...     UE_2:NR-RRC_RRCSetupRequest as RRCSetup
    ...     UE_2:NR-RRC_RRCSetup
    ...     UE_2:NR-RRC_RRCRelease
    ...     alias=UE2_RRC_release
    ...     overall_timeout=30

    Expect Message Flow
    ...     AMF1:NGAP_InitialUEMessage as InitalMessage
    ...     AMF1:NGAP_InitialContextSetupRequest as ICS_Req
    ...     AMF1:NGAP_InitialContextSetupFailure as ICSFailure
    ...     AMF1:NGAP_UEContextReleaseRequest as ue_contex_req
    ...     AMF1:NGAP_UEContextReleaseCommand
    ...     AMF1:NGAP_UEContextReleaseComplete
    ...     alias=UE2_NGAP_ics_fail
    ...     overall_timeout=30

Setup environment for procedure 3
    Execute egate command  cmd=amf_param id=1 voice_fallback=on
    Send delta commissioning    input_filepath=${delta_conf_procedure_3}

    Expect Message Flow
    ...     UE_3:NR-RRC_RRCRelease
    ...     alias=UE3_RRC_release
    ...     overall_timeout=30

    Expect Message Flow
    ...     AMF1:NGAP_PDUSessionResourceModifyRequest
    ...     AMF1:NGAP_PDUSessionResourceModifyResponse as pdu_mod_response
    ...     AMF1:NGAP_UEContextReleaseRequest as ue_contex_req
    ...     AMF1:NGAP_UEContextReleaseCommand
    ...     AMF1:NGAP_UEContextReleaseComplete
    ...     alias=UE3_pdu_mod_fail
    ...     overall_timeout=30

Setup environment for procedure 4
    Execute egate command  cmd=amf_param id=1 voice_fallback=on
    Send delta commissioning    input_filepath=${delta_conf_procedure_4}

    Expect Message Flow
    ...     UE_5:NR-RRC_RRCRelease
    ...     alias=UE5_RRC_release
    ...     overall_timeout=30

Try to attach UE${ue_id} to gNB2 with initial PDU Session with one QoS Flow and Emergency fallback indicator
    Attach UE   ue_id=${ue_id}
    Execute egate command  cmd=ue_pdu_session_setup pdu=1 ue=${ue_id} gw=${ue_id} nwslice=1

Verify that gNB2 sends ICS Response with cause "RadioNetwork: ims-voice-eps-fallback-or-rat-fallback-triggered"
    Flow occurred as expected  alias=UE1_NGAP_ics_emer_fallback
    Verify That Message Fulfills Query
    ...     (cause contains (radioNetwork eq 'ims-voice-eps-fallback-or-rat-fallback-triggered'))
    ...     message_alias=ICSResponse
    ...     flow_alias=UE1_NGAP_ics_emer_fallback

Verify that gNB2 sends ICS Failure with cause "RadioNetwork: Unspecified"
    Flow occurred as expected  alias=UE2_NGAP_ics_fail
    Verify That Message Fulfills Query
    ...    (cause contains (radioNetwork eq 'unspecified'))
    ...     message_alias=ICSFailure
    ...     flow_alias=UE2_NGAP_ics_fail

Verify that UE${ue_id} is released
    Flow occurred as expected  alias=UE${ue_id}_RRC_release

Set actEmergencyFallback to false
    Send delta commissioning    input_filepath=${actEmergencyFallback_disable}

Verify that gNB2 rejects 5QI-1 QoS flow setup with cause "RadioNetwork: ims-voice-eps-fallback-or-rat-fallback-triggered"
    Flow occurred as Expected  alias=UE3_pdu_mod_fail
    Verify That Message Fulfills Query
    ...     (cause contains (radioNetwork eq 'ims-voice-eps-fallback-or-rat-fallback-triggered'))
    ...     message_alias=pdu_mod_response
    ...     flow_alias=UE3_pdu_mod_fail

Try to add 5QI-1 QoS flow to UE${ue_id} initial PDU Session
    Execute egate command  cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=1 by=amf

Verify that gNB sends PDU Session Resource Modify Response with cause: "RadioNetwork: ims-voice-eps-fallback-or-rat-fallback-triggered"
    Verify That Message Fulfills Query
    ...     (cause contains (radioNetwork eq 'ims-voice-eps-fallback-or-rat-fallback-triggered'))
    ...     message_alias=PDU_Resp
    ...     flow_alias=UE5_PDU_modify
