*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CONFIGURED  CRT  RAN_5G_TDD
...           RAN_5G    SBTS00    SBTS23R1    PY36
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Radu Turcu
...              :maintainer: Maciej Katra

Resource      ../../../resourcesKRK/krk3_common/main_vran.robot
Resource      testsuite/Timisoara/L3/ET/L3_ET_TIM3/resourcesKRK/krk3_common/aic/aic_common_resources.robot
#Resource     RM_5GC0001944_WA_Keywords.robot
Library      ta5g_tshark
#Library      ta5g_setups_and_teardowns
#Variables    ta5g_global_var
Library      ta5g_ue_mobility
Library     ute_tshark

Suite Setup       Testline Setup
Suite Teardown    Testline Teardown
Test Teardown     Test Case Teardown     pod_logs=yes    oam_logs=yes


*** Variables ***
@{IP_ADDR_EXAMPLE}    eth3:10.0.12.100/24    eth3:10.0.11.100/24
&{CONFIG_EXAMPLE}     ip_addr=${IP_ADDR_EXAMPLE}   delta_vcu=${DELTA_VCU}   delta_vdu=${DELTA_VDU}
${DELTA_VCU}     ${CURDIR}/configs/delta_vcu.xml
${DELTA_VDU}     ${CURDIR}/configs/delta_vdu.json
${CU_SCF}     /home/ute/Downloads/scfc_cu.xml
${DU_SCF}     /home/ute/Downloads/scfc_du.xml

${NG_SETUP_REQUEST_WITH_UE_RETENTION}=    ((ngap.NGSetupRequest_element)&&(ngap.UERetentionInformation == 0))
${NG_SETUP_RESPONSE_WITHOUT_UE_RETENTION}=    ((ngap.NGSetupResponse_element)&&(ngap.protocolIEs == 5))
${SCTP_ABORT}=    sctp.abort_t_bit
${F1AP_RESET}    f1ap.Reset_element
${E1AP_RESET}    e1ap.Reset_element

*** Test Cases ***
5GC0001944_WA_3_NGSetupResponse_Without_IE_UERetentionInformation
    [Documentation]   This is Optimized TC, and covers following legacy scenarios:
    ...               5GC0001944_WA_2_NgUeRetentionTmr_Expiration_UE_Retention_Enabled
    ...               Requirement ID  : 5G_RAN_USR_11840
    [Setup]    Test Case Setup    reach_on_air=without_x2_link     config=&{CONFIG_EXAMPLE}    reboot_after_config=no

#    ${cu_status}  ${du_status}=  Activate CU and DU plan  ${CU_SCF}  ${DU_SCF}

    start tcpdump on remote interface aic
    ...   alias=tshark_testcase_aic
    ...   log_filename_prefix=anypcap
    ...   log_dirpath=${OUTPUT DIR}
    sleep    10s

    ta5g_ue_mobility.Attach Ue    ue_id=1
    ta5g_ue_mobility.Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    ta5g_ue_mobility.Invoke Sctp Failure On Ng Interface      by=amf:1     to=gnb:2
    sleep    10s
    Verify tshark
    ...     alias=tshark_testcase_aic
    ...     packet_filter=${SCTP_ABORT}
    ...     pass_criteria= >=1
    ...     pcap_file_path=${OUTPUT_DIR}/anypcap.pcap
    sleep    60s
    Verify tshark
    ...     alias=tshark_testcase_aic
    ...     packet_filter=${NG_SETUP_RESPONSE_WITHOUT_UE_RETENTION}
    ...     pass_criteria= >=1
    ...     pcap_file_path=${OUTPUT_DIR}/anypcap.pcap
    sleep    30s
    Verify tshark
    ...     alias=tshark_testcase_aic
    ...     packet_filter=${F1AP_RESET}
    ...     pass_criteria= >=1
    ...     pcap_file_path=${OUTPUT_DIR}/anypcap.pcap
    Verify tshark
    ...     alias=tshark_testcase_aic
    ...     packet_filter=${E1AP_RESET}
    ...     pass_criteria= >=1
    ...     pcap_file_path=${OUTPUT_DIR}/anypcap.pcap
    sleep    10s
    stop tcpdump on remote interface

    Execute Egate Command    cmd=ue_deregister id=all by=ue ue_deregister_type=switch_off
    Execute Egate Command    cmd=reset
    Run     sudo killall edaemon egate
    sleep    4s
