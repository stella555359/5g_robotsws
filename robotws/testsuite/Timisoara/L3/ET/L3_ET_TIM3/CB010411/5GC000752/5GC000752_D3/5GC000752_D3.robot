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
Library      ute_reporting_portal
Library      ta5g_pm_counters

Variables    ta5g_global_var

Suite Setup       Testline Setup
Suite Teardown    Testline Teardown
Test Teardown     Run Keywords    log to console     Suite Setup Keywords
...             AND     Teardown Ap and Interface
...             AND     Test Case Teardown     pod_logs=yes    oam_logs=yes

*** Variables ***

${UE_INTEGRITY_PROTECTION_NOT_POSSIBLE} =    ngap.radioNetwork == 37

*** Test Cases ***

5GC000752-D_3_USBasicCall-D_EC27_Unsuccessful_PDU_Session_Setup_subsequent_PDU_session_gNB-CU-CP_rejection
    [Documentation]   Correct handling of unsuccessful PDU Session Setup without PDU session
    ...    when 5GUE rejects AS Security Activation which in turn cause RRC Security Mode Failure


    [Setup]    Test Case Setup    reach_on_air=without_x2_link        reboot_after_config=no

    start tcpdump on remote interface aic
    ...   alias=tshark_testcase_aic
    ...   log_filename_prefix=anypcap
    ...   log_dirpath=${OUTPUT DIR}

    ta5g_ue_mobility.Attach Ue    ue_id=2
    ta5g_ue_mobility.Establish Pdu Session    ue_id=2    pdu_id=3    gw_id=3
    Change SMF Security Indication
    ta5g_ue_mobility.Establish PDU Session Without Confirmation    ue_id=2    pdu_id=4    gw_id=4
    Check If Ues Are Active    expected_ues=1

    Verify tshark
    ...     alias=tshark_testcase_aic
    ...     packet_filter=${UE_INTEGRITY_PROTECTION_NOT_POSSIBLE}
    ...     pass_criteria= >=1
    ...     pcap_file_path=${OUTPUT_DIR}/anypcap.pcap



*** Keywords ***

Change SMF Security Indication
    Execute Egate Command    cmd=smf_param id=1 security_indication=pdu_session_setup:required:required max_data_rate=5mbps

Teardown Ap and Interface
    stop tcpdump on remote interface
    Execute Egate Command    cmd=ue_deregister id=all by=ue ue_deregister_type=switch_off
    Execute Egate Command    cmd=reset
    Run     sudo killall edaemon egate
    sleep    4s
