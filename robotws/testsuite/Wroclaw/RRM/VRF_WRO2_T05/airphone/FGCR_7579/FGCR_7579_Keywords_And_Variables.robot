*** Settings ***
Documentation    :copyright: Nokia

Resource     ../../../resources/airphone/5G_SW_WRO_Keywords.robot

Variables    ta5g_global_var

Library      ta5g_testline_management
Library      ta5g_tshark
Library      ta5g_delta
Library      ta5g_iphy
Library      ta5g_enb

*** Variables ***
${IMS_VOICE_FALLBACK__OR_RAT_FALLBACK_TRIGGERED}=    ngap.radioNetwork == 36
${REDIRECTION}=    ngap.radioNetwork == 41
${UE_CONTEXT_RELEASE_REQUEST_FALLBACK}=    ${NGAP_UE_CONTEXT_RELEASE_REQUEST} && ${REDIRECTION}
${NOT_SUPPORTED_5QI_VALUE}=    ngap.radioNetwork == 34
${INITIAL_CONTEXT_SETUP_FAILURE_FALLBACK}=    ${NGAP_INITIAL_CONTEX_SETUP_FAILURE} && ${IMS_VOICE_FALLBACK__OR_RAT_FALLBACK_TRIGGERED}
${INITIAL_CONTEXT_SETUP_FAILURE_5QI_NOT_SUPPORTED}=    ${NGAP_INITIAL_CONTEX_SETUP_FAILURE} && ${NOT_SUPPORTED_5QI_VALUE}

*** Keywords ***
Activate Additional 5QI
    Execute Egate Command    cmd=smf_param id=1 additional_qosflows_to_activate=2

Reset SMF
    Execute Egate Command    cmd=smf_param id=1 reset

Check Successful Fallback After Initial Context Setup
    Verify Ngap Messages    packet_filter=${INITIAL_CONTEXT_SETUP_FAILURE_FALLBACK}
    Verify Ngap Messages    packet_filter=${UE_CONTEXT_RELEASE_REQUEST_FALLBACK}
    Verify Ngap Messages    packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMPLETE}

Check 5QI Setup Failure In Initial Context Setup
    Verify Ngap Messages    packet_filter=${INITIAL_CONTEXT_SETUP_FAILURE_5QI_NOT_SUPPORTED}
