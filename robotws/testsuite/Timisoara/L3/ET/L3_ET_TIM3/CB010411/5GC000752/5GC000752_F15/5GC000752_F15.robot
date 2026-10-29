*** Settings ***
Force Tags    CLOUD_5GC_dRNIC_1vDU_P_AP_LO_SWFH
...           CONFIGURED    RAN_5G_FDD    RAN_5G    CRT    SBTS00    SBTS23R1    PY36
...           NoResUsage

Documentation    :copyright: Nokia
...              :author:Dan Moldovan
...              :contact: dan.moldovan@nokia.com


Resource      ../../../resourcesKRK/krk3_common/main_vran.robot
Resource      ../../../resourcesKRK/krk3_common/aic/aic_common_resources.robot
Library      ta5g_tshark
Library      ta5g_ue_mobility
Library      ute_tshark
Library      ta5g_pm_counters
Library      ute_reporting_portal

Variables    ta5g_global_var

Suite Setup       Testline Setup
Suite Teardown    Testline Teardown
Test Teardown     Run Keywords    log to console     Suite Setup Keywords
...             AND     Teardown Ap and Interface
...             AND     Test Case Teardown     pod_logs=yes    oam_logs=yes

*** Variables ***

${PDU_SESSION_RES_SETUP_RESP}=   ngap.PDUSessionResourceSetupResponse_element
${PDU_SETUP_LIST_FAILED}=   ngap.PDUSessionResourceFailedToSetupListSURes == 1
${PDU_SESSION_RESOURCE_SETUP_RESPONSE_PDU_FAILED}=   ${PDU_SESSION_RES_SETUP_RESP} && ${PDU_SETUP_LIST_FAILED}


@{PM_OBJECTS_LIST_VCU}           NNGCC    NRRCC

*** Test Cases ***

5GC000752-F_15_Unsuccessful_PDU_Session_Resource_Setup_752-D_6_USBasicCall-D_EC26_PM_Counters

    [Setup]    Test Case Setup    reach_on_air=without_x2_link        reboot_after_config=no

    start tcpdump on remote interface aic
    ...   alias=tshark_testcase_aic
    ...   log_filename_prefix=anypcap
    ...   log_dirpath=${OUTPUT DIR}

    ta5g_ue_mobility.Attach Ue    ue_id=3
    ta5g_ue_mobility.Establish Pdu Session    ue_id=3    pdu_id=3    gw_id=3
    Trigger Dropping Rrc Reconfiguration During Pdu Session Setup
    Establish Pdu Session Without Confirmation    ue_id=3    pdu_id=4    gw_id=4

    Sleep   10
    Verify tshark
    ...     alias=tshark_testcase_aic
    ...     packet_filter=${PDU_SESSION_RES_SETUP_RESP}
    ...     pass_criteria= >=1
    ...     pcap_file_path=${OUTPUT DIR}/anypcap.pcap

    ${dirpath}  Set Variable   ${OUTPUT DIR}/Logs/${TEST NAME}/
    Create Directory    ${dirpath}/vcu
    Create Directory    ${dirpath}/vdu
    &{pm_files_dict}    get_next_vran_unpacked_full_pm_counters_files    output_dirpath=${dirpath}     timeout=3600      expected_interval=5

    verify last counters in file
    ...  M55125C02506   1       NNGCC_PDU_SES_STP_NACK_SENT
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...  file_path=${pm_files_dict.vcu}
    ...  measurement_type=NNGCC

    verify last counters in file
    ...  M55124C03006   1       NRRCC_RRC_RECONF_CMP_TMR
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1/NRCELL-1
    ...  file_path=${pm_files_dict.vcu}
    ...  measurement_type=NRRCC

    Report pm counter    id=M55125C02506    value=1    result=Passed
    Report pm counter    id=M55124C03006    value=1    result=Passed


*** Keywords ***
Trigger Dropping Rrc Reconfiguration During Pdu Session Setup
    Execute Egate Command    cmd=ue_nr_rrc_reconf_param id=3 if_contains=any action=drop

Teardown Ap and Interface
    stop tcpdump on remote interface
    Execute Egate Command    cmd=ue_deregister id=all by=ue ue_deregister_type=switch_off
    Execute Egate Command    cmd=reset
    Run     sudo killall edaemon egate
    sleep    4s
