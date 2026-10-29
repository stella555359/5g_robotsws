*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    PY36
...           CONFIGURED    CRT    RAN_5G_TDD    RAN_5G    SBTS00    SBTS23R1
...           NoResUsage

Documentation    :copyright: Nokia
...              :author: Julia Szymczak
...              :contact: julia.szymczak@nokia.com

Resource     ../resources/5G_SW_WRO_Keywords.robot

Suite Setup     Run Keywords    Start Default Logging
...             AND             Find Scfc And Send Delta Commissioning    scfc_filename=delta_7799_C_B1.json
...             AND             Reach Onair    lua_cfg=${CURDIR}/config/egate_7799_sa.lua

Suite Teardown     Run Keywords     Find Scfc And Send Delta Commissioning    scfc_filename=delta_7799_C_B1_revert.json
...                AND              Stop Default Processes And Gather Logs And Compress Logs
*** Variables ***
${RRC_VOICE_FALLBACK_INDICATION_INCLUDED} =    nr-rrc.voiceFallbackIndication_r16 == 0 && ${RRC_RELEASE}

*** Test Cases ***
CB007799-C_B1_Redirection_With_VoiceFallbackIndication_Success_Case
    [Documentation]    Testcase verifies the successful voice fallback to LTE with redirection procedure. If UE
    ...                capabilities indicate it supports voiceFallbackIndicationEPS-r16, the RRCRelease message
    ...                sent for redirection includes the voiceFallIndication-r16 IE.

   Attach Ue    ue_id=1
   Establish PDU Session
   Modify PDU Session    qos_to_add=2    ue_id=1    pdu_id=1    pass_regexp=RRCConnectionRelease contains voiceFallbackIndication_r16.*
   Verify Tcpdump Log    packet_filter=${RRC_VOICE_FALLBACK_INDICATION_INCLUDED}
   Verify Ngap Messages    packet_filter=${VOICE_FALLBACK_TRIGGERED}
   Verify Ngap Messages    packet_filter=${NGAP_UE_CONTEXT_RELEASE_REQUEST}
   Verify Ngap Messages    packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMMAND}
   Verify Ngap Messages    packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMPLETE}
   Verify Tcpdump Log    packet_filter=${F1AP_UE_CONTEXT_RELEASE_COMMAND}
   Verify Tcpdump Log    packet_filter=${E1AP_BEARER_CONTEXT_RELEASE_COMMAND}




