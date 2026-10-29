*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CONFIGURED    CRT
...           PY36    RAN_5G_TDD    RAN_5G    SBTS00    SBTS23R1
...           NoResUsage


Documentation    :author: Radu Turcu
...              :email: radu.turcu@nokia.com
...              :Description: parity of 723-RA in RINLAN2
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

${ERROR_INDICATION_NOT_INCLUDED_ID}=
...    ngap.ErrorIndication_element and ngap.procedureCode == 9 and ngap.protocol == 0 and ngap.id == 10 and not ngap.id == 85
${NGAP_UE_RELEASE}=    nr-rrc && f1ap.procedureCode == 6


*** Test Cases ***
5GC002333_RA_Ngap_Error_Indication_Received_Not_Included_Ran_Ue_Ngap_Id
    [Documentation]    RA_Ngap_Error_Indication_Received_Not_Included_Ran_Ue_Ngap_Id
    ...                Requirement ID: 5G_RAN_USR_6472      config=&{CONFIG_EXAMPLE}
    [Setup]    Test Case Setup    reach_on_air=without_x2_link        reboot_after_config=no

    Log to console     start test
    start tcpdump on remote interface aic
    ...   alias=tshark_testcase_aic
    ...   log_filename_prefix=anypcap
    ...   log_dirpath=${OUTPUT DIR}
    sleep    10s
    Trigger Error Indication Without RAN UE NGAP ID
    ta5g_ue_mobility.Attach Ue Without Confirmation    ue_id=1
    sleep    10s
    Verify tshark
    ...     alias=tshark_testcase_aic
    ...     packet_filter=${NGAP_UE_RELEASE}
    ...     pass_criteria= >=1
    ...     pcap_file_path=${OUTPUT_DIR}/anypcap.pcap
    sleep    10s

    Verify tshark
    ...     alias=tshark_testcase_aic
    ...     packet_filter=${ERROR_INDICATION__NOT_INCLUDED_ID}
    ...     pass_criteria= >=1
    ...     pcap_file_path=${OUTPUT_DIR}/anypcap.pcap
    sleep    10s

    stop tcpdump on remote interface

	Execute Egate Command    cmd=ue_deregister id=all by=ue ue_deregister_type=switch_off
    Execute Egate Command    cmd=reset
    Run     sudo killall edaemon egate
    sleep    4s

*** Keywords ***
Trigger Error Indication Without RAN UE NGAP ID
    Execute Egate Command
    ...     cmd=amf_init_ue_msg_param id=1 action=error_indication_without_ran_ueid cause=PROTOCOL_transfer_syntax_error
