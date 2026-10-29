*** Settings ***
Force Tags    CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CONFIGURED
...           CRT  RAN_5G_FDD    RAN_5G    SBTS00    SBTS23R1    PY36
...           NoResUsage

Documentation    :copyright: Nokia
...              :author: Radu Turcu
...              :contact: radu.turcu@nokia.com


Resource      ../../../resourcesKRK/krk3_common/main_vran.robot
Resource      ../../../resourcesKRK/krk3_common/aic/aic_common_resources.robot
Library      ta5g_tshark
#Library      ta5g_setups_and_teardowns
#Variables    ta5g_global_var
Library      ta5g_ue_mobility
Library      ute_tshark
Variables    ta5g_global_var
Library       ute_reporting_portal
Library      ta5g_pm_counters

Suite Setup       Testline Setup
Suite Teardown    Testline Teardown
Test Teardown     Test Case Teardown     pod_logs=yes    oam_logs=yes

*** Variables ***
@{IP_ADDR_EXAMPLE}    eth3:10.0.12.100/24    eth3:10.0.11.100/24
${DELTA_VCU}     ${CURDIR}/configs/delta_vcu.xml
${DELTA_VDU}     ${CURDIR}/configs/delta_vdu.json
&{CONFIG_EXAMPLE}     ip_addr=${IP_ADDR_EXAMPLE}   delta_vcu=${DELTA_VCU}   delta_vdu=${DELTA_VDU}
${AUTHENTICATION_FAILURE}              ngap.nas == 1
${NGAP_UE_CONTEXT_RELEASE_COMMAND}     ngap.UEContextReleaseCommand_element
${F1AP_UE_CONTEXT_RELEASE_COMMAND}     f1ap.UEContextReleaseCommand_element
${AMF_INITIATED_ABNORMAL_RELEASE}      f1ap.radioNetwork == 15
${NGAP_UE_CONTEXT_RELEASE_COMMAND_NAS_AUTHENTICATION_FAILURE}=    ${NGAP_UE_CONTEXT_RELEASE_COMMAND} && ${AUTHENTICATION_FAILURE}
${F1AP_UE_CONTEXT_RELEASE_COMMAND_AMF_INITIATED_ABNORMAL_RELEASE}=    ${F1AP_UE_CONTEXT_RELEASE_COMMAND} && ${AMF_INITIATED_ABNORMAL_RELEASE}
${F1AP_UE_CONTEXT_RELEASE_COMPLETE}     f1ap.UEContextReleaseComplete_element
${NGAP_UE_CONTEXT_RELEASE_COMPLETE}     ngap.UEContextReleaseComplete_element
@{PM_OBJECTS_LIST_VCU}           NNGCC    NRRCC    NF1CC
@{PM_OBJECTS_LIST_VDU}           NF1CD

*** Test Cases ***
5GC000728_W_14_Verify_Ue_Is_Released_With_Cause_AMF_Abnormal_Release
    [Setup]    Run Keywords     Log to console      Start test setup
    ...     AND       Test Case Setup    reach_on_air=without_x2_link        reboot_after_config=no

    start tcpdump on remote interface aic
    ...   alias=tshark_testcase_aic
    ...   log_filename_prefix=anypcap
    ...   log_dirpath=${OUTPUT DIR}
    Sleep   20
    ta5g_ue_mobility.Ue Nas Param    ue_id=1    autn_action=fail
    ta5g_ue_mobility.Attach Ue Without Confirmation    ue_id=1
    Verify tshark
    ...     alias=tshark_testcase_aic
    ...     packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMMAND_NAS_AUTHENTICATION_FAILURE}
    ...     pass_criteria= >=1
    ...     pcap_file_path=${OUTPUT DIR}/anypcap.pcap
    Sleep   10
    Verify tshark
    ...     alias=tshark_testcase_aic
    ...     packet_filter=${F1AP_UE_CONTEXT_RELEASE_COMMAND_AMF_INITIATED_ABNORMAL_RELEASE}
    ...     pass_criteria= >=1
    ...     pcap_file_path=${OUTPUT DIR}/anypcap.pcap
    Sleep   10
        Verify tshark
    ...     alias=tshark_testcase_aic
    ...     packet_filter=${F1AP_UE_CONTEXT_RELEASE_COMPLETE}
    ...     pass_criteria= >=1
    ...     pcap_file_path=${OUTPUT DIR}/anypcap.pcap
    Sleep   10
        Verify tshark
    ...     alias=tshark_testcase_aic
    ...     packet_filter=${NGAP_UE_CONTEXT_RELEASE_COMPLETE}
    ...     pass_criteria= >=1
    ...     pcap_file_path=${OUTPUT DIR}/anypcap.pcap
    Sleep   10
    stop tcpdump on remote interface
    Log to console    Get Next vRAN XML PM Counters Files
    ${dirpath}  Set Variable   ${OUTPUT DIR}/Logs/${TEST NAME}/
    Create Directory    ${dirpath}/vcu
    Create Directory    ${dirpath}/vdu
    &{pm_files_dict}    get_next_vran_unpacked_full_pm_counters_files    output_dirpath=${dirpath}     timeout=3600      expected_interval=5

    verify last counters in file
    ...  M55125C00501  1  NNGCC_UE_CTXT_REL_CMD_RECD
    ...  M55125C00502  1  NNGCC_UE_CTXT_REL_CMP_SENT
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...  file_path=${pm_files_dict.vcu}

    verify last counters in file
    ...  M55124C00001   1       NRRCC_RRC_RELEASE_SENT
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...  file_path=${pm_files_dict.vcu}
    ...  measurement_type=NRRCC

    verify last counters in file
    ...  M55113C01009   1       NF1CC_UECTXT_REL_CMDSENT
    ...  M55113C01010   1       NF1CC_UE_CTXT_REL_CMP_RECD
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...  file_path=${pm_files_dict.vcu}
    ...  measurement_type=NF1CC

    verify last counters in file
    ...  M55117C01010   1       NF1CD_UECTXT_REL_CMPSENT
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRDU-1
    ...  file_path=${pm_files_dict.vdu}
    ...  measurement_type=NF1CD

    Report pm counter    M55125C00501  1           Passed
	Report pm counter    M55125C00502  1           Passed
	Report pm counter    M55124C00001  1           Passed
	Report pm counter    M55113C01009  1           Passed
	Report pm counter    M55113C01010  1           Passed
	Report pm counter    M55117C01010  1           Passed

    Execute Egate Command    cmd=ue_deregister id=all by=ue ue_deregister_type=switch_off
    Execute Egate Command    cmd=reset
    Run     sudo killall edaemon egate
    sleep    4s
