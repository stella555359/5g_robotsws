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
${DEFAULT_S1_MME_SCTP}=     sctp
${DEFAULT_UU_LESS_1000}=     less 1000
${DEFAULT_NG_XN_TSHARK_ALIAS}=    default_s1_x2
${NGAP_UE_AMF_ID}=     ngap.AMF_UE_NGAP_ID
${NGAP_UE_RAN_ID}=     ngap.RAN_UE_NGAP_ID


*** Test Cases ***
5GC000752-E_1_USBasicCall-E_EC3_Unsuccessful_PDU_Session_Release_not_last_PDU_session_5G_UE_no_response_lack_of_RRC_Reconfiguration_Complete
    [Documentation]      Verifies UE state remains in RRC CONNECTED when one of the DRB is still active
    ...                  when other DRBs are INACTIVE
    ...     This testcase covers following legacy scenarios:
    ...     5GC000728_B_17
    ...     5GC000728_B_19
    ...     5GC000728_B_21
    ...     Requirement ID:  5G_RAN_USR_6193                          config=&{CONFIG_EXAMPLE}
    [Setup]    Test Case Setup    reach_on_air=without_x2_link        reboot_after_config=no

    Log to console     start test
    start default tshark on s1 mme and uu interfaces aic     log_dirpath=${OUTPUT DIR}
    sleep    10s

    ta5g_ue_mobility.Attach Ue    ue_id=3
    ta5g_ue_mobility.Establish Pdu Session    ue_id=3    pdu_id=1    gw_id=4
    ta5g_ue_mobility.Establish Pdu Session    ue_id=3    pdu_id=2    gw_id=5
    Set Ue NR RRC Reconf Param    ue_id=3   value=drop
    ta5g_ue_mobility.Release Pdu Session     ue_id=3    pdu_id=2    initiator=ue
    Verify Tshark For Ngap Ue Context Release With Automatic Id Allocation
    Deregister Ue Without Confirmation    ue_id=3
    stop existing default tshark on s1 mme and uu interfaces

    Execute Egate Command    cmd=ue_deregister id=all by=ue ue_deregister_type=switch_off
    Execute Egate Command    cmd=reset
    Run     sudo killall edaemon egate
    sleep    4s

*** Keywords ***
Set Ue NR RRC Reconf Param
    [Arguments]    ${ue_id}    ${value}
	Execute Egate Command    cmd=ue_nr_rrc_reconf_param id=${ue_id} if_contains=any action=${value}

Verify Tshark For Ngap Ue Context Release With Automatic Id Allocation
    @{id}=    ta5g_ue_mobility.Get AMF And Ran Id    alias=${DEFAULT_NG_XN_TSHARK_ALIAS}
    ...    output_filepath=${OUTPUT_DIR}/${TEST_NAME}/id.pdml
    Verify Tshark For Ngap Ue Context Release    ran_id=@{id}[1]    amf_id=@{id}[0]    alias=${DEFAULT_NG_XN_TSHARK_ALIAS}
