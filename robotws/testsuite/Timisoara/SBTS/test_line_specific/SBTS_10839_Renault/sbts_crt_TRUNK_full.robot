*** Settings ***
Force Tags        QCD_MN_RAN    QCP_RAN_ST    CRT    CLOUD_SRAN_LG_10839_1ASIA_2ABIA_1FSMF_3AHFIB    SBTS00
Library           XML  use_lxml=True
Resource          taf/rfrl/scrambling_logs_collector/Keywords.robot
Resource          ../../LOGS/LOGS__CNI-29578_IP_connectivity_test.robot
Resource          ../../LOGS/LOGS__Clock_Time_Managment.robot
Resource          ../../LOGS/LOGS__Memory_dump_files_creation_in_case_of_DSP_crash.robot
Resource          ../../LOGS/LOGS__Postmortem_files_creation_in_snapshot_content_for_SMOD.robot
Resource          ../../LOGS/LOGS__Snapshot.robot
Resource          ../../LOGS/LOGS__Snapshot_Runtime_Log_Error_Prints.robot
Resource          ../../LOGS/LOGS__Check_logging_frequency_mechanism.robot
Resource          ../../LOGS/LOGS__Collecting_of_new_logfile_with_the_BTS_snapshot.robot
Resource          ../../LOGS/LOGS__Snapnshot_Collection_Triggered_By_Fault_6450_raised_after_DSP_crash.robot
Resource          ../../LOGS/LOGS__CB008390_Quota_doest_exceed_under_folder_logs_according_to_SysInfoQuota_xml.robot
Resource          ../../LOGS/LOGS__Snapshot_collection__triggered_by_Syslog_Substring_to_external_server_NetAct_via_NE3S.robot
Resource          ../../LOGS/LOGS__CB007615-SR-A-B3-Get_the_date_and_time_value_before_the_last_reset.robot
Resource          ../../LOGS/LOGS__CB011146_A_SR_WebEM_Remote_Tool_Classical_BTS_CLI.robot
Resource          ../../LOGS/LOGS__CB011146_B_SR_getSwVersion.robot
Resource          ../../LOGS/LOGS__CB011146_D_SR_Rest_API_get_CellStatus.robot
Resource          ../../LOGS/LOGS__CB011146_D_SR_Rest_API_get_CellStatus_otherUser.robot

Suite Teardown    Suite Teardown
Documentation  Test Suite for TL10839_Renault

*** Variables ***
${SCF_ID}         01

${COMMISSIONING_PATH}       /home/ute/testline_configuration/10_18_UTESRANCLOUD1839/node1/SCF_01_TRUNK.xml
${NETACT_LAB}    &{srnclab3007}

*** Test Cases ***
[1]Automated__LOGS__CB008390_Quota_doest_exceed_under_folder_logs_according_to_SysInfoQuota_xml
    [Tags]     Test
    [Setup]    Run Keywords    LOGS__CB008390_Quota_doest_exceed_under_folder_logs_according_to_SysInfoQuota_xml.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB008390_Quota_doest_exceed_under_folder_logs_according_to_SysInfoQuota_xml
    ...    AND    Set Library Search Order    LOGS__CB008390_Quota_doest_exceed_under_folder_logs_according_to_SysInfoQuota_xml
    [Timeout]    14400
    TC__LOGS__CB008390_Quota_doest_exceed_under_folder_logs_according_to_SysInfoQuota_xml
    [Teardown]    Run Keywords    LOGS__CB008390_Quota_doest_exceed_under_folder_logs_according_to_SysInfoQuota_xml.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__check_logging_frequency_mechanism
    [Setup]    Run Keywords    LOGS__Check_logging_frequency_mechanism.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Check_logging_frequency_mechanism
    ...    AND    Set Library Search Order    LOGS__check_logging_frequency_mechanism
    [Timeout]    14400
    TC__LOGS__check_logging_frequency_mechanism
    [Teardown]    Run Keywords    LOGS__Check_logging_frequency_mechanism.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__collecting_of_new_logfile_with_the_BTS_snapshot
    [Setup]    Run Keywords    Set Test Variable    ${SNAPSHOT_TIMEOUT}    900
    ...    AND    Set Test Variable    ${DOCUMENTATION_PATH}    /home/ute/btsauto/snapshot_documentation
    ...    AND    LOGS__Collecting_of_new_logfile_with_the_BTS_snapshot.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Collecting_of_new_logfile_with_the_BTS_snapshot
    ...    AND    Set Library Search Order    LOGS__Collecting_of_new_logfile_with_the_BTS_snapshot
    [Timeout]    14400
    TC__LOGS__Collecting_of_new_logfile_with_the_BTS_snapshot
    [Teardown]    Run Keywords    LOGS__Collecting_of_new_logfile_with_the_BTS_snapshot.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__Snapshot
    [Setup]    Run Keywords    Set Test Variable    ${SNAPSHOT_TIMEOUT}    600
    ...    AND    LOGS__Snapshot.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Snapshot
    ...    AND    Set Library Search Order    LOGS__Snapshot
    [Timeout]    14400
    TC__LOGS__Snapshot
    [Teardown]    Run Keywords    LOGS__Snapshot.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__Memory_dump_files_creation_in_case_of_DSP_crash
    [Setup]    Run Keywords    Set Test Variable    ${DSP_ID}    ${Empty}
    ...    AND    Set Test Variable    ${SITE_RESET}    False
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    10
    ...    AND    Set Test Variable    ${FAULT_TIMEOUT}    15
    ...    AND    Set Test Variable    ${VERIFICATION_TIMEOUT}    3
    ...    AND    Set Test Variable    ${MEMDUMP_PATTERN}    (\\d{4})\\w+MEMDUMP\\.bin\\.xz$
    ...    AND    Set Test Variable    ${DSP_MEMDUMPER_PATTERN}    memdumper_{}.+\\.log\\.xz$
    ...    AND    Set Test Variable    ${DSP_RUNTIME_PATTERN}    [1-2]011_crash_{}00_RT\\.log\\.zip$
    ...    AND    Set Test Variable    ${DSP_MEMDUMP_PATTERN}    {}00\\w+MEMDUMP\\.bin.*
    ...    AND    Set Test Variable    ${SRIO_DIO_INTERFACE_PATERN}    riomemfs-logdump
    ...    AND    LOGS__Memory_dump_files_creation_in_case_of_DSP_crash.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Memory_dump_files_creation_in_case_of_DSP_crash
    ...    AND    Set Library Search Order    LOGS__Memory_dump_files_creation_in_case_of_DSP_crash
    [Timeout]    14400
    TC__LOGS__Memory_dump_files_creation_in_case_of_DSP_crash
    [Teardown]    Run Keywords    LOGS__Memory_dump_files_creation_in_case_of_DSP_crash.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__Snapshot_content__postmortem_files_creation_for_SMOD
    [Setup]    Run Keywords    Set Test Variable    ${SNAPSHOT_FILE_PATH}    /tmp/uri/DIAGN_FILES/
    ...    AND    Set Test Variable    ${STARTUP_TIMEOUT}    10
    ...    AND    Set Test Variable    ${SNAPSHOT_TIMEOUT}    600
    ...    AND    LOGS__Postmortem_files_creation_in_snapshot_content_for_SMOD.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Postmortem_files_creation_in_snapshot_content_for_SMOD
    ...    AND    Set Library Search Order    LOGS__Postmortem_files_creation_in_snapshot_content_for_SMOD
    [Timeout]    14400
    TC__LOGS__Postmortem_files_creation_in_snapshot_content_for_SMOD
    [Teardown]    Run Keywords    LOGS__Postmortem_files_creation_in_snapshot_content_for_SMOD.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__Clock_Time_Managment
    [Setup]    Run Keywords    Set Test Variable    ${STARTUP_TIMEOUT}    10
    ...    AND    Set Test Variable    ${CLOCK_SYNCHRONIZATION_TIMEOUT}    3
    ...    AND    LOGS__Clock_Time_Managment.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Clock_Time_Managment
    ...    AND    Set Library Search Order    LOGS__Clock_Time_Managment
    [Timeout]    14400
    TC__LOGS__Clock_Time_Managment
    [Teardown]    Run Keywords    LOGS__Clock_Time_Managment.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__IP__connectivity_test_all_configured_hosts
    [Setup]    Run Keywords    Set Test Variable    ${CLOSE_BROWSER_AFTER_TEST}    True
    ...    AND    Set Test Variable    ${TESTED_IP_ADDRESS}    192.168.255.1
    ...    AND    LOGS__CNI-29578_IP_connectivity_test.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CNI-29578_IP_connectivity_test
    ...    AND    Set Library Search Order    LOGS__CNI-29578_IP_connectivity_test
    [Timeout]    14400
    TC__LOGS__CNI-29578_IP_connectivity_test.robot
    [Teardown]    Run Keywords    LOGS__CNI-29578_IP_connectivity_test.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__Snapshot_Runtime_Log_ERROR_Prints
    [Setup]    Run Keywords    Set Test Variable    ${SNAPSHOT_TIMEOUT}    600
    ...    AND    LOGS__Snapshot_Runtime_Log_Error_Prints.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Snapshot_Runtime_Log_Error_Prints
    ...    AND    Set Library Search Order    LOGS__Snapshot_Runtime_Log_Error_Prints
    [Timeout]    14400
    LOGS__Snapshot_Runtime_Log_Error_Prints
    [Teardown]    Run Keywords    LOGS__Snapshot_Runtime_Log_Error_Prints.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__Snapnshot_Collection_Triggered_By_Fault_6450_raised_after_DSP_crash
    [Setup]    Run Keywords    LOGS__Snapnshot_Collection_Triggered_By_Fault_6450_raised_after_DSP_crash.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Snapnshot_Collection_Triggered_By_Fault_6450_raised_after_DSP_crash
    ...    AND    Set Library Search Order    LOGS__Snapnshot_Collection_Triggered_By_Fault_6450_raised_after_DSP_crash
    [Timeout]    14400
    TC__LOGS__Snapnshot_Collection_Triggered_By_Fault_6450_raised_after_DSP_crash
    [Teardown]    Run Keywords    LOGS__Snapnshot_Collection_Triggered_By_Fault_6450_raised_after_DSP_crash.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__Snapshot_collection__triggered_by_Syslog_Substring_to_external_server_NetAct_via_NE3S
    [Setup]    Run Keywords    Set Test Variable    ${SNAPSHOT_COLLECTION_TIMEOUT}    2700
    ...    AND    LOGS__Snapshot_collection__triggered_by_Syslog_Substring_to_external_server_NetAct_via_NE3S.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Snapshot_collection__triggered_by_Syslog_Substring_to_external_server_NetAct_via_NE3S
    ...    AND    Set Library Search Order    LOGS__Snapshot_collection__triggered_by_Syslog_Substring_to_external_server_NetAct_via_NE3S
    [Timeout]    14400
    TC__LOGS__Snapshot_collection__triggered_by_Syslog_Substring_to_ external_server_NetAct_via_NE3S
    [Teardown]    Run Keywords    LOGS__Snapshot_collection__triggered_by_Syslog_Substring_to_external_server_NetAct_via_NE3S.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CB007615-SR-A-B3-Get_the_date_and_time_value_before_the_last_reset
    [Setup]    Run Keywords    LOGS__CB007615-SR-A-B3-Get_the_date_and_time_value_before_the_last_reset.TC Setup
    ...    AND    Set Library Search Order    LOGS__CB007615-SR-A-B3-Get_the_date_and_time_value_before_the_last_reset
    ...    AND    Modify Resource Search Order    LOGS__CB007615-SR-A-B3-Get_the_date_and_time_value_before_the_last_reset
    [Timeout]    14400
    TC__LOGS__CB007615-SR-A-B3-Get_the_date_and_time_value_before_the_last_reset
    [Teardown]    Run Keywords    LOGS__CB007615-SR-A-B3-Get_the_date_and_time_value_before_the_last_reset.TC Teardown
    ...    AND    Restore Resource Search Order

CB011146_D_SR_ROBUSTNESS_getCells_Check_All_Users
    [Setup]    Run Keywords    LOGS__CB011146_D_SR_Rest_API_get_CellStatus_otherUser.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB011146_D_SR_Rest_API_get_CellStatus_otherUser
    ...    AND    Set Library Search Order    LOGS__CB011146_D_SR_Rest_API_get_CellStatus_otherUser
    [Timeout]    14400
    TC__LOGS__CB011146_D_SR_Rest_API_get_CellStatus_otherUser
    [Teardown]    Run Keywords    LOGS__CB011146_D_SR_Rest_API_get_CellStatus_otherUser.TC Teardown
    ...    AND    Restore Resource Search Order

CB011146_D_SR_Rest_API_get_CellStatus
    [Setup]    Run Keywords    LOGS__CB011146_D_SR_Rest_API_get_CellStatus.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB011146_D_SR_Rest_API_get_CellStatus
    ...    AND    Set Library Search Order    LOGS__CB011146_D_SR_Rest_API_get_CellStatus
    [Timeout]    14400
    TC__LOGS__CB011146_D_SR_Rest_API_get_CellStatus
    [Teardown]    Run Keywords    LOGS__CB011146_D_SR_Rest_API_get_CellStatus.TC Teardown
    ...    AND    Restore Resource Search Order

[1]CB011146_A_SR_WebEM_Remote_Tool_Classical_BTS_CLI
    [Setup]    Run Keywords    LOGS__CB011146_A_SR_WebEM_Remote_Tool_Classical_BTS_CLI.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB011146_A_SR_WebEM_Remote_Tool_Classical_BTS_CLI
    ...    AND    Set Library Search Order    LOGS__CB011146_A_SR_WebEM_Remote_Tool_Classical_BTS_CLI
    [Timeout]    14400
    TC__LOGS__CB011146_A_SR_WebEM_Remote_Tool_Classical_BTS_CLI
    [Teardown]    Run Keywords    LOGS__CB011146_A_SR_WebEM_Remote_Tool_Classical_BTS_CLI.TC Teardown
    ...    AND    Restore Resource Search Order

[1]CB011146_B_SR_Rest_API_get_SoftwareVersion
    [Setup]    Run Keywords    LOGS__CB011146_B_SR_getSwVersion.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB011146_B_SR_getSwVersion
    ...    AND    Set Library Search Order    LOGS__CB011146_B_SR_getSwVersion
    [Timeout]    14400
    TC__LOGS__CB011146_B_SR_getSwVersion
    [Teardown]    Run Keywords    LOGS__CB011146_B_SR_getSwVersion.TC Teardown
    ...    AND    Restore Resource Search Order

*** Keywords ***
Suite Teardown
    Run keyword and ignore error    Collect and send logs for scrambling verification
    ...    team_name=VRFTSR5
    ...    input_logs_dir=${NONE}
