*** Settings ***
Force Tags    CLOUD_5GC_dRNIC_1vDU_P_AP_LO_SWFH    CONFIGURED  CRT  RAN_5G_TDD
...           RAN_5G    SBTS00    PY36
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Cristinel Sava
...              :maintainer: Cristinel Sava

Resource      ../../../resourcesKRK/krk3_common/main_vran.robot
Resource      ../../../resourcesKRK/krk3_common/aic/aic_common_resources.robot
Library      ta5g_tshark
Library      ta5g_ue_mobility
Library      ute_tshark

Suite Setup       Testline Setup
Suite Teardown    Testline Teardown
Test Teardown     Test Case Teardown     pod_logs=yes    oam_logs=yes


*** Variables ***
@{IP_ADDR_EXAMPLE}    eth3:10.0.12.100/24    eth3:10.0.11.100/24
&{CONF_EX}     ip_addr=${IP_ADDR_EXAMPLE}   delta_vcu=${DELTA_VCU}   delta_vdu=${DELTA_VDU}
${DELTA_VCU}     ${CURDIR}/configs/CU_DELTA_7799_1.xml
${DELTA_VDU}     ${CURDIR}/configs/DU_DELTA_7799_1.xml

${wts_f}  ${CURDIR}/configs/7799.cfg
${RRC_VOICE_FALLBACK_INDICATION_INCLUDED} =    nr-rrc.voiceFallbackIndicationEPS_r16
${VOICE_FALLBACK_TRIGGERED} =                  ngap.radioNetwork == 36
${NGAP_UE_CONTEXT_RELEASE_REQUEST} =           ngap.UEContextReleaseRequest_element
${NGAP_UE_CONTEXT_RELEASE_COMMAND} =           ngap.UEContextReleaseCommand_element
${NGAP_UE_CONTEXT_RELEASE_COMPLETE} =          ngap.UEContextReleaseComplete_element
${F1AP_UE_CONTEXT_RELEASE_COMMAND} =           f1ap.UEContextReleaseCommand_element
${E1AP_BEARER_CONTEXT_RELEASE_COMMAND} =       e1ap.BearerContextReleaseCommand_element

*** Test Cases ***
CB007799-C_B1_Redirection_With_VoiceFallbackIndication_Success_Case
    [Documentation]    Testcase verifies the successful voice fallback to LTE with redirection procedure. If UE
    ...                capabilities indicate it supports voiceFallbackIndicationEPS-r16, the RRCRelease message
    ...                sent for redirection includes the voiceFallIndication-r16 IE.
    [Setup]    Test Case Setup    reach_on_air=without_x2_link  wts=${wts_f}  config=&{CONF_EX}  reboot_after_config=no
    start tcpdump on remote interface aic
    ...   alias=tshark_testcase_aic
    ...   log_filename_prefix=anypcap
    ...   log_dirpath=${OUTPUT DIR}
    sleep    30s
    ta5g_ue_mobility.Attach Ue    ue_id=1
    ta5g_ue_mobility.Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    ta5g_ue_mobility.Modify PDU Session    qos_to_add=2
    ...                       ue_id=1
    ...                      pdu_id=1
    ...                     pass_regexp=RRCConnectionRelease contains voiceFallbackIndication_r16.*
    sleep    30s
    log to console    verify RRC_VOICE_FALLBACK_INDICATION_INCLUDED
    Verify tshark
    ...     alias=tshark_testcase_aic
    ...     packet_filter=${RRC_VOICE_FALLBACK_INDICATION_INCLUDED}
    ...     pass_criteria= >=1
    ...     pcap_file_path=${OUTPUT_DIR}/anypcap.pcap
    sleep    2s
    log to console    verify VOICE_FALLBACK_TRIGGERED
    Verify tshark
    ...     alias=tshark_testcase_aic
    ...     packet_filter=${VOICE_FALLBACK_TRIGGERED}
    ...     pass_criteria= >=1
    ...     pcap_file_path=${OUTPUT_DIR}/anypcap.pcap
    sleep    2s
    log to console    verify NGAP_UE_CONTEXT_RELEASE_REQUEST
    Verify tshark
    ...     alias=tshark_testcase_aic
    ...     packet_filter=${NGAP_UE_CONTEXT_RELEASE_REQUEST}
    ...     pass_criteria= >=1
    ...     pcap_file_path=${OUTPUT_DIR}/anypcap.pcap
    sleep    2s
    log to console    verify NGAP_UE_CONTEXT_RELEASE_COMMAND
    Verify tshark
    ...     alias=tshark_testcase_aic
    ...     packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMMAND}
    ...     pass_criteria= >=1
    ...     pcap_file_path=${OUTPUT_DIR}/anypcap.pcap
    sleep    2s
    log to console    verify NGAP_UE_CONTEXT_RELEASE_COMPLETE
    Verify tshark
    ...     alias=tshark_testcase_aic
    ...     packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMPLETE}
    ...     pass_criteria= >=1
    ...     pcap_file_path=${OUTPUT_DIR}/anypcap.pcap
    sleep    2s
    log to console    verify F1AP_UE_CONTEXT_RELEASE_COMMAND
    Verify tshark
    ...     alias=tshark_testcase_aic
    ...     packet_filter=${F1AP_UE_CONTEXT_RELEASE_COMMAND}
    ...     pass_criteria= >=1
    ...     pcap_file_path=${OUTPUT_DIR}/anypcap.pcap
    sleep    2s
        log to console    verify E1AP_BEARER_CONTEXT_RELEASE_COMMAND
    Verify tshark
    ...     alias=tshark_testcase_aic
    ...     packet_filter=${E1AP_BEARER_CONTEXT_RELEASE_COMMAND}
    ...     pass_criteria= >=1
    ...     pcap_file_path=${OUTPUT_DIR}/anypcap.pcap
    sleep    2s
    stop tcpdump on remote interface
    Execute Egate Command    cmd=ue_deregister id=1 by=ue ue_deregister_type=switch_off
    Execute Egate Command    cmd=reset
    Run     sudo killall edaemon egate
    sleep    4s
