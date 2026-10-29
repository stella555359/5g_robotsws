*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CONFIGURED    CRT
...           PY36    RAN_5G_TDD    RAN_5G    SBTS00    SBTS23R1
...           NoResUsage


Documentation    :author: Radu Turcu
...              :email: radu.turcu@nokia.com
...              :Description: parity of 723-J in RINLAN2
...                            Refined to match ET Scope


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
${delta_maxNumOfRrcSA_to_1}       ${CURDIR}/configs/delta_maxNumOfRrcSA_to_1.json

${F1AP_UE_CONTEXT_RELEASE_COMPLETE}=        f1ap.UEContextReleaseComplete_element
${RRC_REJECTION_FOR_UE2}=                   nr-rrc.c1 == 0 && f1ap.protocolIEs == 5 && f1ap.SRBID == 0
${F1AP_UE_2_CONTEXT_RELEASE_COMPLETE}=      f1ap.F1AP_PDU == 1 && ${F1AP_UE_CONTEXT_RELEASE_COMPLETE}


*** Test Cases ***
5GC00723-J_RRC_Reject_Procedure_After_Admission_Control_Failure_On_gNB_DU
    [Documentation]    This test case covers rejection of ue attach and cleaning its Context when there are two users
    ...                trying to attach but parameter MaxNumOfRrcSa is set to 1 and there are no resources fot the
    ...                second UE. Covered
    ...                5GC000723_D_7_Check_RRC_Rejection_On_DU
    ...                Requirement ID: 5G_RAN_USR_6472      config=&{CONFIG_EXAMPLE}
    [Setup]    Test Case Setup    reach_on_air=without_x2_link        reboot_after_config=no
    Upload delta vdu    ${delta_maxNumOfRrcSA_to_1}
    Log to console     start test
    start tcpdump on remote interface aic
    ...   alias=tshark_testcase_aic
    ...   log_filename_prefix=anypcap
    ...   log_dirpath=${OUTPUT DIR}
    sleep    10s

    ta5g_ue_mobility.Attach Ue    ue_id=1
    ta5g_ue_mobility.Attach Ue Without Confirmation    ue_id=2
    sleep    10s
    Verify tshark
    ...     alias=tshark_testcase_aic
    ...     packet_filter=${RRC_REJECTION_FOR_UE2}
    ...     pass_criteria= >=1
    ...     pcap_file_path=${OUTPUT_DIR}/anypcap.pcap
    sleep    10s

    Verify tshark
    ...     alias=tshark_testcase_aic
    ...     packet_filter=${RRC_REJECTION_FOR_UE2}
    ...     pass_criteria= >=1
    ...     pcap_file_path=${OUTPUT_DIR}/anypcap.pcap
    sleep    10s

    stop tcpdump on remote interface

    Execute Egate Command    cmd=ue_deregister id=1 by=ue ue_deregister_type=switch_off
    Execute Egate Command    cmd=ue_deregister id=2 by=ue ue_deregister_type=switch_off
    Execute Egate Command    cmd=reset
    Run     sudo killall edaemon egate
    sleep    4s


