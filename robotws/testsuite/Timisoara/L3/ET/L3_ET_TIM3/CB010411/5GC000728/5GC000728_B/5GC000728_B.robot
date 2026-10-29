*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CONFIGURED
...           CRT  RAN_5G_FDD    RAN_5G    SBTS00    SBTS23R1    PY36
...           NoResUsage

Documentation    :copyright: Nokia
...              :author: Radu Turcu
...              :contact: radu.turcu@nokia.com


Resource      ../../../resourcesKRK/krk3_common/main_vran.robot
Resource      testsuite/Timisoara/L3/ET/L3_ET_TIM3/resourcesKRK/krk3_common/aic/aic_common_resources.robot
Library      ta5g_tshark
#Library      ta5g_setups_and_teardowns
#Variables    ta5g_global_var
Library      ta5g_ue_mobility
Library      ute_tshark
Variables    ta5g_global_var

Suite Setup       Testline Setup
Suite Teardown    Testline Teardown
Test Teardown     Test Case Teardown     pod_logs=yes    oam_logs=yes

*** Variables ***
@{IP_ADDR_EXAMPLE}    eth3:10.0.12.100/24    eth3:10.0.11.100/24
&{CONFIG_EXAMPLE}     ip_addr=${IP_ADDR_EXAMPLE}   delta_vcu=${DELTA_VCU}   delta_vdu=${DELTA_VDU}
${DELTA_VCU}     ${CURDIR}/configs/delta_vcu.xml
${DELTA_VDU}     ${CURDIR}/configs/delta_vdu.json
${delta_setup_drb_srb_timer_TC18}       ${CURDIR}/configs/delta_setup_drb_srb_timer_TC18.json
${NGAP_UE_CONTEXT_RELEASE_COMPLETE}     ngap.UEContextReleaseComplete_element

*** Test Cases ***
5GC000728_B_18_Verify_Ue_State_Remains_In_Rrc_Connected_When_At_Least_One_Drb_Is_Active_And_SRB_Is_Inactive_Already
    [Documentation]      Verifies UE state remains in RRC CONNECTED when one of the DRB is still active
    ...                  when other DRBs are INACTIVE
    ...     This testcase covers following legacy scenarios:
    ...     5GC000728_B_17
    ...     5GC000728_B_19
    ...     5GC000728_B_21
    ...     Requirement ID:  5G_RAN_USR_6193                          config=&{CONFIG_EXAMPLE}
    [Setup]    Test Case Setup    reach_on_air=without_x2_link        reboot_after_config=no

    Upload delta vdu    ${delta_setup_drb_srb_timer_TC18}
    Execute egate command    cmd=set_pdu_param ue=1 pdu=1 trf_type=internal
    Execute egate command    cmd=set_pdu_param ue=1 pdu=2 trf_type=internal
    Log to console     start test
    sleep    10s
    start tcpdump on remote interface aic
    ...   alias=tshark_testcase_aic
    ...   log_filename_prefix=anypcap
    ...   log_dirpath=${OUTPUT DIR}
    sleep    10s
    ${DRB_INACTIVITY_TIMER}=    Set Variable    50
    ta5g_ue_mobility.Attach Ue    ue_id=1
    ta5g_ue_mobility.Establish Pdu Session    ue_id=1    pdu_id=1    gw_id=1
    ta5g_ue_mobility.Establish Pdu Session    ue_id=1    pdu_id=2    gw_id=2
    Start Internal SA Downlink Traffic    ue_id=1    tput=1mbps    pdu_id=1
    Sleep     80
    Stop Internal SA Traffic    ue_id=1       pdu_id=1
    Stop Internal SA Traffic    ue_id=1       pdu_id=2

    Sleep    ${DRB_INACTIVITY_TIMER}

    Verify tshark
    ...     alias=tshark_testcase_aic
    ...     packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMPLETE}
    ...     pass_criteria= ==0
    ...     pcap_file_path=${OUTPUT_DIR}/anypcap.pcap

    stop tcpdump on remote interface
	Execute Egate Command    cmd=ue_deregister id=all by=ue ue_deregister_type=switch_off
    Execute Egate Command    cmd=reset
    Run     sudo killall edaemon egate
    sleep    4s
