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
&{CONFIG_EXAMPLE}     ip_addr=${IP_ADDR_EXAMPLE}   delta_vcu=${DELTA_VCU}   delta_vdu=${DELTA_VDU}
${DELTA_VCU}     ${CURDIR}/configs/Delta_638_V_vCU.xml
${DELTA_VDU}     ${CURDIR}/configs/Delta_638_V_vDU.xml

${NG_SETUP_REQUEST_WITH_UE_RETENTION}=    ((ngap.NGSetupRequest_element)&&(ngap.UERetentionInformation == 0))
${NG_SETUP_RESPONSE_WITHOUT_UE_RETENTION}=    ((ngap.NGSetupResponse_element)&&(ngap.protocolIEs == 5))
${SCTP_ABORT}=    sctp.abort_t_bit
${F1AP_RESET}    f1ap.Reset_element
${E1AP_RESET}    e1ap.Reset_element

*** Test Cases ***
5GC000638_V_2_Failure_Of_The_Already_Established_SCTP_Association_On_NG_Interface
    [Documentation]   Checks whether SCTP reestablishment in NG interface is done properly.
    ...               UE shall estabish PDU session and after Ng link failure UE should be released
    ...               and Ng link should be inactive.
    ...               Covers: 5GC000638_V_1_SCTP_Failure_On_NG_Interface_EFaultId_NgSctpEndpointBrokenAl
    [Setup]    Test Case Setup    reach_on_air=without_x2_link      config=&{CONFIG_EXAMPLE}     reboot_after_config=no
    start tcpdump on remote interface aic
    ...   alias=tshark_testcase_aic
    ...   log_filename_prefix=anypcap
    ...   log_dirpath=${OUTPUT DIR}
    sleep    30s
    ta5g_ue_mobility.Attach Ue    ue_id=1
    ta5g_ue_mobility.Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    ta5g_ue_mobility.Invoke Sctp Failure On Ng Interface      by=amf:1     to=gnb:2
    sleep    30s
    log to console    Verify tshark F1AP_RESET
    Verify tshark
    ...     alias=tshark_testcase_aic
    ...     packet_filter=${F1AP_RESET}
    ...     pass_criteria= >=1
    ...     pcap_file_path=${OUTPUT_DIR}/anypcap.pcap
    sleep    20s
    log to console    Verify tshark E1AP_RESET
    Verify tshark
    ...     alias=tshark_testcase_aic
    ...     packet_filter=${E1AP_RESET}
    ...     pass_criteria= >=1
    ...     pcap_file_path=${OUTPUT_DIR}/anypcap.pcap
    sleep    20s
    stop tcpdump on remote interface
    Execute Egate Command    cmd=ue_deregister id=2 by=ue ue_deregister_type=switch_off
    Log to console    ue_deregistered id=1
    Execute Egate Command    cmd=reset
    Log to console    Egate reseted
    Run     sudo killall edaemon egate
    Log to console    Egate killed
    sleep    5s
