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
&{CONF_DRB}     ip_addr=${IP_ADDR_EXAMPLE}   delta_vcu=${DELTA_C_DRB}   delta_vdu=${DELTA_D_DRB}
${DELTA_C_DRB}     ${CURDIR}/configs/CU_DELTA_DRB_same_LOLO.xml
${DELTA_D_DRB}     ${CURDIR}/configs/DU_DELTA_DRB_same_LOLO.xml
${DELTA_VCU}     ${CURDIR}/configs/CU_Delta_7512_EC1.xml
${DELTA_VDU}     ${CURDIR}/configs/DU_Delta_7512_EC1.xml

${wts_f}  ${CURDIR}/configs/7512.cfg

${X2AP_SGNB_MODIFICATION_REQUEST}  x2ap.SgNBModificationRequest_element
${E1AP_BEARER_CONTEXT_MODIFICATION_RESPONSE}    e1ap.BearerContextModificationResponse_element
${F1AP_UE_CONTEXT_MODIFICATION_RESPONSE}        f1ap.UEContextModificationResponse_element
${X2AP_SGNB_MODIFICATION_REQUEST_ACKNOWLEDGE}   x2ap.SgNBModificationRequestAcknowledge_element
${RRC_RECONFIGURATION_COMPLETE}                 nr-rrc.rrcReconfigurationComplete_element
${X2AP_SGNB_RECONFIGURATION_COMPLETE}           x2ap.SgNBReconfigurationComplete_element
${X2AP_SN_STATUS_TRANSFER}                      x2ap.SNStatusTransfer_element
${X2AP_SGNB_RELEASE_REQUIRED}                   x2ap.SgNBReleaseRequired_element

${DEFAULT_S1_MME_SCTP}=     sctp
${DEFAULT_UU_LESS_1000}=     less 1000
*** Test Cases ***
CB007512_A_EC1_Unsuccessful_addition_of_SN_terminated_split_bearer_without_PDCP_anchor_change_by_MeNB_initiated_SgNB_Modification_Preparation
    [Setup]    Test Case Setup    reach_on_air=yes  wts=${wts_f}      reboot_after_config=no
    sleep    10s
    start tcpdump on remote interface aic
    ...   alias=tshark_testcase_aic
    ...   log_filename_prefix=anypcap
    ...   log_dirpath=${OUTPUT DIR}
    sleep    10s
    log to console    ue_enb_endc_param id=101 direct_bearer_sn_modification=on
    Execute egate command    cmd=ue_enb_endc_param id=101 direct_bearer_sn_modification=on
    log to console    ue_attach id=101
    Execute egate command    cmd=ue_attach id=101
    sleep    5s
    log to console    bearer_add ue=101 id=4 filter=1 precedence=1 by=pgw
    Execute egate command    cmd=bearer_add ue=101 id=4 filter=1 precedence=1 by=pgw
    sleep    5s
    log to console    ue_dc_enb_start ue=101 target_gnb=2 target_cells=1 bearer=1,4 type=split_scg
    Execute egate command    cmd=ue_dc_enb_start ue=101 target_gnb=2 target_cells=1 bearer=1,4 type=split_scg
    sleep    5s
    log to console    bearer_add ue=101 id=2 filter=2 precedence=2 id=3 filter=3 precedence=3 by=pgw
    Execute egate command    cmd=bearer_add ue=101 id=2 filter=2 precedence=2 id=3 filter=3 precedence=3 by=pgw
    log to console    verify X2AP_SGNB_MODIFICATION_REQUEST
    Verify tshark
    ...     alias=tshark_testcase_aic
    ...     packet_filter=${X2AP_SGNB_MODIFICATION_REQUEST}
    ...     pass_criteria= >=1
    ...     pcap_file_path=${OUTPUT_DIR}/anypcap.pcap
    sleep    2s
    log to console    verify E1AP_BEARER_CONTEXT_MODIFICATION_RESPONSE
    Verify tshark
    ...     alias=tshark_testcase_aic
    ...     packet_filter=${E1AP_BEARER_CONTEXT_MODIFICATION_RESPONSE}
    ...     pass_criteria= >=1
    ...     pcap_file_path=${OUTPUT_DIR}/anypcap.pcap
    sleep    2s
    log to console    F1AP_UE_CONTEXT_MODIFICATION_RESPONSE
    Verify tshark
    ...     alias=tshark_testcase_aic
    ...     packet_filter=${F1AP_UE_CONTEXT_MODIFICATION_RESPONSE}
    ...     pass_criteria= >=1
    ...     pcap_file_path=${OUTPUT_DIR}/anypcap.pcap
    sleep    2s
    log to console    verify X2AP_SGNB_MODIFICATION_REQUEST_ACKNOWLEDGE
    Verify tshark
    ...     alias=tshark_testcase_aic
    ...     packet_filter=${X2AP_SGNB_MODIFICATION_REQUEST_ACKNOWLEDGE}
    ...     pass_criteria= >=1
    ...     pcap_file_path=${OUTPUT_DIR}/anypcap.pcap
    sleep    2s
    log to console    verify RRC_RECONFIGURATION_COMPLETE
    Verify tshark
    ...     alias=tshark_testcase_aic
    ...     packet_filter=${RRC_RECONFIGURATION_COMPLETE}
    ...     pass_criteria= >=1
    ...     pcap_file_path=${OUTPUT_DIR}/anypcap.pcap
    sleep    2s
    log to console    verify X2AP_SGNB_RECONFIGURATION_COMPLETE
    Verify tshark
    ...     alias=tshark_testcase_aic
    ...     packet_filter=${X2AP_SGNB_RECONFIGURATION_COMPLETE}
    ...     pass_criteria= >=1
    ...     pcap_file_path=${OUTPUT_DIR}/anypcap.pcap
    sleep    2s
    log to console    verify X2AP_SN_STATUS_TRANSFER
    Verify tshark
    ...     alias=tshark_testcase_aic
    ...     packet_filter=${X2AP_SN_STATUS_TRANSFER}
    ...     pass_criteria= >=1
    ...     pcap_file_path=${OUTPUT_DIR}/anypcap.pcap
    sleep    2s
    log to console    verify X2AP_SGNB_RELEASE_REQUIRED
    Verify tshark
    ...     alias=tshark_testcase_aic
    ...     packet_filter=${X2AP_SGNB_RELEASE_REQUIRED}
    ...     pass_criteria= >=1
    ...     pcap_file_path=${OUTPUT_DIR}/anypcap.pcap
    sleep    2s
    Start Internal NSA Bidirectional Traffic    ue_id=101
    sleep    10s
    Stop Internal NSA Traffic    ue_id=101
    sleep    2s

    stop tcpdump on remote interface
    Execute Egate Command    cmd=ue_deregister id=101 by=ue ue_deregister_type=switch_off
    Execute Egate Command    cmd=reset
    Run     sudo killall edaemon egate
    sleep    4s
