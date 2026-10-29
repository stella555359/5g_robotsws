*** Settings ***

Documentation    :copyright: Nokia

Resource     ../../resources/airphone/5G_SW_WRO_Keywords.robot

Variables    ta5g_global_var

Library      ta5g_testline_management
Library      ta5g_pm_counters
Library      ta5g_tshark
Library      ta5g_delta
Library      ta5g_iphy
Library      ta5g_enb

*** Variables ***
# FILTERS
${IMS_VOICE_FALLBACK_OR_RAT_FALLBACK_TRIGGERED}=    ngap.radioNetwork == 36
${REDIRECTION}=    ngap.radioNetwork == 41
${UE_CONTEXT_RELEASE_REQUEST_FALLBACK}=    ${NGAP_UE_CONTEXT_RELEASE_REQUEST} && ${REDIRECTION}
${INITIAL_CONTEXT_SETUP_RESPONSE_FALLBACK}=    ${NGAP_INITIAL_CONTEXT_SETUP_RESPONSE} && ${IMS_VOICE_FALLBACK_OR_RAT_FALLBACK_TRIGGERED}
${RRC_RELEASE_WITH_EUTRA_FREQUENCY}=   nr-rrc.eutraFrequency == 68586
${TRANSMITTED_NAS_PDU}=    ngap.protocolIEs == 3 && nas_5gs.security_header_type == 2

*** Keywords ***
Activate Additional 5QI
    Execute Egate Command    cmd=smf_param id=1 additional_qosflows_to_activate=2

Reset SMF
    Execute Egate Command    cmd=smf_param id=1 reset

Turn Voice Fallback On
    Execute Egate Command    cmd=amf_param id=1 voice_fallback=on

Turn Voice Fallback Off
    Execute Egate Command    cmd=amf_param id=1 voice_fallback=off

Turn Off Sending Registration Request
    Execute Egate Command    cmd=amf_param id=1 send_ics_registration=off

Add NAS PDU IE To Inital Context Setup Request
    Execute Egate Command    cmd=amf_ue_ics_param id=1 outer_NAS_PDU_type=configuration_update_command
