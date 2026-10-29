*** Settings ***
Force Tags    CLOUD_5GC_dRNIC_1vDU_P_AP_LO_SWFH    CONFIGURED  CRT  RAN_5G_TDD
...           RAN_5G    SBTS00    PY36
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Cristinel Sava
...              :maintainer: Cristinel Sava

Resource      ../../resourcesKRK/krk3_common/main_vran.robot
Resource      ../../resourcesKRK/krk3_common/aic/aic_common_resources.robot
Library      ta5g_tshark
Library      ta5g_ue_mobility
Library      ute_tshark
Variables    ta5g_global_var
Resource    ../../resourcesKRK/tl_init.robot
Suite Setup       Testline Setup
Suite Teardown    Testline Teardown
Test Teardown     Test Case Teardown     pod_logs=yes    oam_logs=yes


*** Variables ***
@{IP_ADDR_EXAMPLE}    eth3:10.0.12.100/24    eth3:10.0.11.100/24
&{CONFIG_PM_5min}     ip_addr=${IP_ADDR_EXAMPLE}   delta_vcu=${DELTA_VCU_5}   delta_vdu=${DELTA_VDU_5}
${DELTA_VCU_5}     ${CURDIR}/configs/CU_Delta_5min.xml
${DELTA_VDU_5}     ${CURDIR}/configs/DU_Delta_5min.xml
${NGAP_INITIAL_CONTEX_SETUP_FAILURE}    ngap.InitialContextSetupFailure_element
${FAILURE_IN_RADIO_INTERFACE_PROCEDURE}    ngap.radioNetwork == 24
${NGAP_UE_CONTEXT_RELEASE_COMPLETE}    ngap.UEContextReleaseComplete_element
${F1AP_UE_CONTEXT_RELEASE_COMPLETE}    f1ap.UEContextReleaseComplete_element



*** Test Cases ***
5GC000865_E_1_5GC000866_E_1_Security_Mode_Failure_During_Initial_As_Security_Activation
    [Documentation]    This test case describes NG Full Reset initiated by gNB
    ...                5G_RAN_USR_RRM_1229
    ...                Test case checks:
    ...                - if counters NG_CU_RESET_ACK_RCV and NG_CU_RESET_REQ_SENT are incremented properly
    ...                author:    Cristinel Sava
    ...                contact:   cristinel.sava@nokia.com
    [Setup]    Run Keywords     Log to console      Start test setup
    ...     AND    Test Case Setup    reach_on_air=yes     reboot_after_config=no

    sleep    10s
    start tcpdump on remote interface aic
    ...   alias=tshark_testcase_aic
    ...   log_filename_prefix=anypcap
    ...   log_dirpath=${OUTPUT DIR}
    sleep    5s
    Log to console    send egate command:ue_rrc_sec_mode_param id=2 if_contains=any action=failure
    Execute egate command    cmd=ue_rrc_sec_mode_param id=2 if_contains=any action=failure
    sleep    3s
    log to console    ue_register id=2
    Execute egate command    cmd=ue_register id=2
    sleep    3s
    Execute egate command    cmd=ue_register id=2
    sleep    3s
    log to console    ue_pdu_session_setup ue=2 pdu=2 nwslice=1 gw=2
    Execute egate command    cmd=ue_pdu_session_setup ue=2 pdu=2 nwslice=1 gw=2
    sleep    5s
    Log to console    Verify tshark NGAP_INITIAL_CONTEX_SETUP_FAILURE and FAILURE_IN_RADIO_INTERFACE_PROCEDURE
    Verify tshark
    ...     alias=tshark_testcase_aic
    ...     packet_filter=${NGAP_INITIAL_CONTEX_SETUP_FAILURE} && ${FAILURE_IN_RADIO_INTERFACE_PROCEDURE}
    ...     pass_criteria= >=1
    ...     pcap_file_path=${OUTPUT_DIR}/anypcap.pcap
    sleep    5s
    Log to console    Verify tshark NGAP_UE_CONTEXT_RELEASE_COMPLETE
    Verify tshark
    ...     alias=tshark_testcase_aic
    ...     packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMPLETE}
    ...     pass_criteria= >=1
    ...     pcap_file_path=${OUTPUT_DIR}/anypcap.pcap
    sleep    5s
    Log to console    Verify tshark F1AP_UE_CONTEXT_RELEASE_COMPLETE
    Verify tshark
    ...     alias=tshark_testcase_aic
    ...     packet_filter=${F1AP_UE_CONTEXT_RELEASE_COMPLETE}
    ...     pass_criteria= >=1
    ...     pcap_file_path=${OUTPUT_DIR}/anypcap.pcap
    sleep    5s
    stop tcpdump on remote interface
    Execute Egate Command    cmd=ue_deregister id=2 by=ue ue_deregister_type=switch_off
    Log to console    ue_deregistered id=2
    Execute Egate Command    cmd=reset
    Log to console    Egate reseted
    Run     sudo killall edaemon egate
    Log to console    Egate killed
    sleep    5s
