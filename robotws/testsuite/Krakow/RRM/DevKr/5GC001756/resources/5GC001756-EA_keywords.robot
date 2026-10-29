*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...      - Dawid Krawczuk <dawid.krawczuk@nokia.com>
...      - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...      - Michał Szymakowski <michal.szymakowski@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Resource    ./5GC001756-common_keywords.robot

*** Keywords ***
Prepare test environment C1
    ${pcmd}    Get variable value      ${pcmd}    "True"
    Run Keyword if  ${pcmd} != "False"
    ...     Start PCMD message collection
    Execute egate command
    ...     cmd=amf_param id=1 empty_pdu_session_list=on send_ics_registration=on

Cleanup after test C1
    Reset PCMD database
    ${pcmd}    Get variable value      ${pcmd}    "True"
    Run Keyword if  ${pcmd} != "False"
    ...     Stop PCMD message collection
    Execute egate command
    ...     cmd=amf_param id=1 empty_pdu_session_list=off send_ics_registration=off
    Run keyword and ignore error    Detach UE1
    Run keyword and ignore error    Detach idle UE1

Prepare test environment C2
    Configure   ${CURDIR}/../config/yaml_config/drbInactivityTimerSA_config.yaml   name=config_C2   bts_id=1
    ${pcmd}    Get variable value      ${pcmd}    "True"
    Run Keyword if  ${pcmd} != "False"
    ...         Start PCMD message collection
    ${ue_capa_c2}=    Set Variable   01A883321A000000109800800C4DAA2FFCBFF0110389A00000010010135378000000000000115000000000000015000001002004088A00
    Execute egate command
    ...     cmd=ics_amf_ue_param id=1 include_ue_capabilities=yes ue_capabilities=${ue_capa_c2}

Cleanup after test C2
    Reset PCMD database
    ${pcmd}    Get variable value      ${pcmd}    "True"
    Run Keyword if  ${pcmd} != "False"
    ...     Stop PCMD message collection
    Run keyword and ignore error    Detach UE1
    Execute egate command   cmd=ics_amf_ue_param id=1 include_ue_capabilities=no
    Deconfigure  name=config_C2  bts_id=1

Prepare test environment C3
    ${pcmd}    Get variable value      ${pcmd}    "True"
    Run Keyword if  ${pcmd} != "False"
    ...     Start PCMD message collection
    Execute egate command   cmd=ue_nr_rrc_setup_param id=1 establishment_cause=emergency
    Execute egate command   cmd=ics_amf_ue_param id=1 ue=all emergency_fb=on

Cleanup after test C3
    Reset PCMD database
    ${pcmd}    Get variable value      ${pcmd}    "True"
    Run Keyword if  ${pcmd} != "False"
    ...     Stop PCMD message collection
    Run keyword and ignore error    Detach idle UE1
    Run keyword and ignore error    Detach UE1
    Execute egate command   cmd=ue_nr_rrc_setup_param id=1 establishment_cause=mo-Data
    Execute egate command   cmd=ics_amf_ue_param id=1 ue=all emergency_fb=off

Prepare test environment C4
    ${pcmd}    Get variable value      ${pcmd}    "True"
    Run Keyword if  ${pcmd} != "False"
    ...     Start PCMD message collection
    Execute egate command   cmd=ue_nr_rrc_reconf_param id=1 if_contains=any nth=1 action=drop

Cleanup after test C4
    Reset PCMD database
    ${pcmd}    Get variable value      ${pcmd}    "True"
    Run Keyword if  ${pcmd} != "False"
    ...     Stop PCMD message collection
    Run keyword and ignore error    Detach UE1
    Run keyword and ignore error    Detach idle UE1
    Execute egate command   cmd=ue_nr_rrc_reconf_param id=1 if_contains=any nth=1 action=none

Prepare test environment C5
    ${pcmd}    Get variable value      ${pcmd}    "True"
    Run Keyword if  ${pcmd} != "False"
    ...     Start PCMD message collection
    Execute egate command
    ...     cmd=amf_param id=1 empty_pdu_session_list=on send_ics_registration=on

Cleanup after test C5
    Reset PCMD database
    ${pcmd}    Get variable value      ${pcmd}    "True"
    Run Keyword if  ${pcmd} != "False"
    ...         Stop PCMD message collection
    Execute egate command
    ...     cmd=amf_param id=1 empty_pdu_session_list=off send_ics_registration=off
    Run keyword and ignore error    Detach UE1
    Run keyword and ignore error    Detach idle UE1

Prepare test environment C6
    Configure   ${CURDIR}/../config/yaml_config/admission_control_parameters.yaml   name=config_C6   bts_id=1
    ${pcmd}    Get variable value      ${pcmd}    "True"
    Run Keyword if  ${pcmd} != "False"
    ...     Start PCMD message collection
    Execute egate command
    ...     cmd=amf_param id=1 empty_pdu_session_list=on send_ics_registration=on
    Execute egate command
    ...     cmd=ics_amf_ue_param id=1 include_ue_capabilities=no

Cleanup after test C6
    Reset PCMD database
    ${pcmd}    Get variable value      ${pcmd}    "True"
    Run Keyword if  ${pcmd} != "False"
    ...         Stop PCMD message collection
    Run keyword and ignore error    Detach UE1
    Run keyword and ignore error    Detach idle UE1
    Execute egate command   cmd=ics_amf_ue_param id=1 include_ue_capabilities=no
    Execute egate command
    ...     cmd=amf_param id=1 empty_pdu_session_list=off send_ics_registration=off
    Deconfigure  name=config_C6  bts_id=1

Prepare test environment C7
    ${pcmd}    Get variable value      ${pcmd}    "True"
    Run Keyword if  ${pcmd} != "False"
    ...     Start PCMD message collection
    Execute egate command   cmd=ue_nr_rrc_reconf_param id=1 if_contains=any nth=4 action=drop

Cleanup after test C7
    Reset PCMD database
    ${pcmd}    Get variable value      ${pcmd}    "True"
    Run Keyword if  ${pcmd} != "False"
    ...         Stop PCMD message collection
    Run keyword and ignore error    Detach UE1
    Run keyword and ignore error    Detach idle UE1
    Execute egate command   cmd=ue_nr_rrc_reconf_param id=1 if_contains=any nth=4 action=none

Prepare test environment C8
    ${pcmd}    Get variable value      ${pcmd}    "True"
    Run Keyword if  ${pcmd} != "False"
    ...     Start PCMD message collection
    ${ue_capa_c2}=    Set Variable   01A883321A000000109800800C4DAA2FFCBFF0110389A00000010010135378000000000000115000000000000015000001002004088A00
    Execute egate command
    ...     cmd=ics_amf_ue_param id=1 include_ue_capabilities=yes ue_capabilities=${ue_capa_c2}

Cleanup after test C8
    Reset PCMD database
    ${pcmd}    Get variable value      ${pcmd}    "True"
    Run Keyword if  ${pcmd} != "False"
    ...         Stop PCMD message collection
    Run keyword and ignore error    Detach UE1
    Run keyword and ignore error    Detach idle UE1
    Execute egate command
    ...     cmd=amf_ue_pdu_release_param id=1 ue=1 reset
    Execute egate command   cmd=ics_amf_ue_param id=1 include_ue_capabilities=no

Set expected call flow for UE${ue_id:\d+} not optimized attach with ${nr_of_sessions} PDU session(s) in ICS
    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCSetupRequest
    ...     UE_${ue_id}:NR-RRC_RRCSetup
    ...     UE_${ue_id}:NR-RRC_UECapabilityEnquiry
    ...     UE_${ue_id}:NR-RRC_RRCReconfiguration as RRCReconfiguration
    ...     UE_${ue_id}:NR-RRC_RRCReconfigurationComplete
    ...     alias=UE${ue_id}_RRC_attach  overall_timeout=15

    Expect Message Flow
    ...     AMF1:NGAP_InitialUEMessage
    ...     AMF1:NGAP_InitialContextSetupRequest as InitialContextSetupRequest
    ...     AMF1:NGAP_InitialContextSetupResponse as InitialContextSetupResponse
    ...     alias=UE${ue_id}_NGAP_ICS    overall_timeout=15

    Expect Message Flow
    ...     AMF1:NGAP_UERadioCapabilityInfoIndication
    ...     alias=UE${ue_id}_NGAP_CAP    overall_timeout=15

Verify that not optimized attach was completed successfully
    Flow Occurred As Expected    alias=UE1_NGAP_ICS
    Flow Occurred As Expected    alias=UE1_RRC_attach
    Flow Occurred As Expected    alias=UE1_NGAP_CAP

Add to UE${ue_id:\d+} QoS flow to second PDU session
    Expect Message Flow
    ...     AMF1:NGAP_PDUSessionResourceModifyRequest (save_pcmd_selected_value) as PDUSessionResourceModifyRequest
    ...     AMF1:NGAP_PDUSessionResourceModifyResponse as PDUSessionResourceModifyResponse
    ...     alias=UE${ue_id}_NGAP_PDUSessionResourceModify  overall_timeout=10

    Execute egate command   cmd=ue_pdu_session_modify ue=${ue_id} pdu=2 qosflows_to_add=9 by=amf

Verify that UE1 does not send RRC ReconfigurationComplete
    Flow Not Occurred For Message    alias=UE1_NR_RRC_RRCReconfigurationComplete

Verify that UE1 attach failed
    Flow Occurred As Expected   alias=UE1_RRC_attach
    Flow Occurred As Expected   alias=UE1_NGAP_ICS

Verify that NGAP InitialContextSetupFailure contains 1 PDU session(s) on PDUSessionResourceFailedToSetupListCxtFail
    Verify That Message Fulfills Query
    ...     length(PDUSessionResourceFailedToSetupListCxtFail) eq 1
    ...     message_alias=InitialContextSetupFailure
    ...     flow_alias=UE1_NGAP_ICS

Verify that multiple PDU sessions setup ends with success for UE${ue_id}
    Flow Occurred As Expected    alias=UE${ue_id}_RRC_idle_exit
    Flow Occurred As Expected    alias=UE${ue_id}_NGAP_ICS_idle
    Flow Occurred As Expected    alias=UE${ue_id}_Reconf_idle

    Verify That Message Fulfills Query
    ...     ((length(PDUSessionResourceSetupListCxtReq) eq 2)
    ...     and
    ...     (PDUSessionResourceSetupListCxtReq contains ((pDUSessionID eq 1) and (fiveQI eq 5)))
    ...     and
    ...     (PDUSessionResourceSetupListCxtReq contains ((pDUSessionID eq 2) and (fiveQI eq 5))))
    ...     message_alias=InitialCtxSetReqMultiplePDU
    ...     flow_alias=UE${ue_id}_NGAP_ICS_idle

    Verify That Message Fulfills Query
    ...     (length(PDUSessionResourceSetupListCxtRes) eq 2)
    ...     message_alias=InitialCtxSetRespMultiplePDU
    ...     flow_alias=UE${ue_id}_NGAP_ICS_idle

    Verify That Message Fulfills Query
    ...     (length(drb-ToAddModList) eq 2)
    ...     message_alias=RRCReconfiguration
    ...     flow_alias=UE${ue_id}_Reconf_idle

Set expected call flow for UE${ue_id:\d+} setup multiple PDU sessions
    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCSetupRequest
    ...     UE_${ue_id}:NR-RRC_RRCSetup
    ...     alias=UE${ue_id}_RRC_idle_exit  overall_timeout=15

    Expect Message Flow
    ...     AMF1:NGAP_InitialUEMessage
    ...     AMF1:NGAP_InitialContextSetupRequest as InitialCtxSetReqMultiplePDU
    ...     AMF1:NGAP_InitialContextSetupResponse as InitialCtxSetRespMultiplePDU
    ...     alias=UE${ue_id}_NGAP_ICS_idle   overall_timeout=15

    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCReconfiguration as RRCReconfiguration
    ...     UE_${ue_id}:NR-RRC_RRCReconfigurationComplete
    ...     alias=UE${ue_id}_Reconf_idle  overall_timeout=10

Set expected call flow for UE${ue_id:\d+} unsuccessful PDU session addition
    Expect Message Flow
    ...     AMF1:NGAP_PDUSessionResourceSetupRequest (save_pcmd_selected_value) as PDUSessionResourceSetupRequest
    ...     AMF1:NGAP_PDUSessionResourceSetupResponse as PDUSessionResourceSetupResponse
    ...     alias=UE${ue_id}_NGAP_PDU_Session_Add  overall_timeout=10

    Expect Message Will Not Occur
    ...     UE_${ue_id}:NR-RRC_RRCReconfiguration as RRCReconfiguration
    ...     alias=UE${ue_id}_RRC_DRB_Add    overall_timeout=10

Verify PDU session addmision failed
    Flow Occurred As Expected  alias=UE1_NGAP_PDU_Session_Add
    Flow not occurred for message  alias=UE1_RRC_DRB_Add

Trigger addtitional PDU session setup for UE${ue_id:\d+}
    Execute egate command
    ...     cmd=ue_pdu_session_setup pdu=2 ue=${ue_id} gw=2 nwslice=1
    ...     pass_regexp=PDU Session Resource Setup with PDU Session ID 2 was unsuccessful due to RAN radio resources not available

Trigger additon of unknown PDU ${unknown_pdu_id:\d+} for UE_${ue_id:\d+} into PDUSessionResourceReleaseRequest
    Execute egate command
    ...     cmd=amf_ue_pdu_release_param id=1 ue=${ue_id} invalid_pdu_ids_to_add=${unknown_pdu_id}

Set expected call flow for UE${ue_id:\d+} failed PDU session release - lack of RRC:ReconfigurationComplete
    Expect Message Flow
    ...     AMF1:NGAP_PDUSessionResourceReleaseCommand as PDUSessionResourceReleaseCommand
    ...     AMF1:NGAP_PDUSessionResourceReleaseResponse as PDUSessionResourceReleaseResponse
    ...     alias=UE${ue_id}_NGAP_PDU_Session_Release  overall_timeout=10

    Expect Message Flow
    ...     AMF1:NGAP_UEContextReleaseRequest (radioNetwork eq "radio-connection-with-ue-lost")
    ...     AMF1:NGAP_UEContextReleaseCommand
    ...     AMF1:NGAP_UEContextReleaseComplete
    ...     alias=UE${ue_id}_NGAP_UEContextReleaseRequest  overall_timeout=10

    Expect Message Flow
    ...     UE_${ue_id}:NR-RRC_RRCReconfiguration as RRCReconfiguration
    ...     UE_${ue_id}:NR-RRC_RRCRelease
    ...     alias=UE${ue_id}_NR_RRC_UE_Release  overall_timeout=15

    Expect Message Will Not Occur
    ...     UE_${ue_id}:NR-RRC_RRCReconfigurationComplete
    ...     alias=UE${ue_id}_NR_RRC_RRCReconfigurationComplete  overall_timeout=10

Verify that UE1 is successfully released
    Flow Occurred As Expected  alias=UE1_NGAP_PDU_Session_Release
    Flow Occurred As Expected  alias=UE1_NR_RRC_UE_Release
