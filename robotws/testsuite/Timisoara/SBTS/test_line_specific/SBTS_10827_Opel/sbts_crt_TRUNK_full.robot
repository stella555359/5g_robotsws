*** Settings ***
Documentation  Tests for Opel
Force Tags        QCD_MN_RAN    QCP_RAN_VRF    CRT    CLOUD_SRAN_L_10827_1ASIB_3ABIC_1AEQP    SBTS00
Library           XML  use_lxml=True
Resource          taf/rfrl/scrambling_logs_collector/Keywords.robot
Resource          ../../LOGS/LOGS__Snapshot.robot
Resource          ../../LOGS/LOGS__CB009077_CLI_Command_Check.robot
Resource          ../../LOGS/LOGS__CB009077_EutranAccessPointPosition_Parameters_Check.robot
Resource          ../../LOGS/LOGS__CNI-19956_Log_File_Documentation_Availability_Check.robot
Resource          ../../LOGS/LOGS__CNI-19956_Log_File_Documentation_Content_Check.robot
Resource          ../../LOGS/LOGS__Snapshot_on-hold_triggered_by_Multiple_Fault_to_NMS_via_NE3S_is_dropped_when_destination_is_re-configured.robot
Resource          ../../LOGS/LOGS__CB008390_Quota_doest_exceed_under_folder_logs_according_to_SysInfoQuota_xml.robot
Resource          ../../LOGS/LOGS__CB010239-D_01_Diagnostic_check_started_for_the_single_BTS_via_NetAct_REST_API.robot
Resource          ../../LOGS/LOGS__CNI-90327_AaTrblServer_configuration_formalization.robot
Resource          ../../LOGS/LOGS__CB009077_SRM6_RU_check.robot
Resource          ../../LOGS/LOGS__CNI-93026_03_Logs_present_in_new_SSD_location.robot
Resource          ../../LOGS/LOGS__CNI_124706_TC_01_CE_and_UE_are_stored_in_the_separated_Blackbox_files.robot
Resource          ../../LOGS/LOGS__CNI_124706_TC_02_Memory_ECC_error_monitoring_service.robot

Suite Teardown    Suite Teardown

*** Variables ***
${SCF_ID}         01

${COMMISSIONING_PATH}
    ...  /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS_10827_Opel/commissioning/SCF_01_TRUNK.xml

${NETACT_LAB}    &{srnclab3008}

*** Test Cases ***
LOGS__CNI_124706_TC_01_CE_and_UE_are_stored_in_the_separated_Blackbox_files
    [Setup]    Run Keywords    LOGS__CNI_124706_TC_01_CE_and_UE_are_stored_in_the_separated_Blackbox_files.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CNI_124706_TC_01_CE_and_UE_are_stored_in_the_separated_Blackbox_files
    ...    AND    Set Library Search Order    LOGS__CNI_124706_TC_01_CE_and_UE_are_stored_in_the_separated_Blackbox_files
    [Timeout]    14400
    TC__LOGS__CNI_124706_TC_01_CE_and_UE_are_stored_in_the_separated_Blackbox_files
    [Teardown]    Run Keywords    LOGS__CNI_124706_TC_01_CE_and_UE_are_stored_in_the_separated_Blackbox_files.TC Teardown
    ...    AND    Restore Resource Search Order

LOGS__CNI_124706_TC_02_Memory_ECC_error_monitoring_service
    [Setup]    Run Keywords    LOGS__CNI_124706_TC_02_Memory_ECC_error_monitoring_service.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CNI_124706_TC_02_Memory_ECC_error_monitoring_service
    ...    AND    Set Library Search Order    LOGS__CNI_124706_TC_02_Memory_ECC_error_monitoring_service
    [Timeout]    14400
    TC__LOGS__CNI_124706_TC_02_Memory_ECC_error_monitoring_service
    [Teardown]    Run Keywords    LOGS__CNI_124706_TC_02_Memory_ECC_error_monitoring_service.TC Teardown
    ...    AND    Restore Resource Search Order

LOGS__CNI-93026_03_Logs_present_in_new_SSD_location
    [Tags]  ReTest
    [Setup]    Run Keywords    LOGS__CNI-93026_03_Logs_present_in_new_SSD_location.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CNI-93026_03_Logs_present_in_new_SSD_location
    ...    AND    Set Library Search Order    LOGS__CNI-93026_03_Logs_present_in_new_SSD_location
    [Timeout]    14400
    TC__LOGS__CNI-93026_03_Logs_present_in_new_SSD_location
    [Teardown]    Run Keywords    LOGS__CNI-93026_03_Logs_present_in_new_SSD_location.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CB008390_Quota_doest_exceed_under_folder_logs_according_to_SysInfoQuota_xml
    [Setup]    Run Keywords    LOGS__CB008390_Quota_doest_exceed_under_folder_logs_according_to_SysInfoQuota_xml.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB008390_Quota_doest_exceed_under_folder_logs_according_to_SysInfoQuota_xml
    ...    AND    Set Library Search Order    LOGS__CB008390_Quota_doest_exceed_under_folder_logs_according_to_SysInfoQuota_xml
    [Timeout]    14400
    TC__LOGS__CB008390_Quota_doest_exceed_under_folder_logs_according_to_SysInfoQuota_xml
    [Teardown]    Run Keywords    LOGS__CB008390_Quota_doest_exceed_under_folder_logs_according_to_SysInfoQuota_xml.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__Snapshot
    [Setup]    Run Keywords    Set Test Variable    ${SNAPSHOT_TIMEOUT}    1200
    ...    AND    LOGS__Snapshot.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__Snapshot
    ...    AND    Set Library Search Order    LOGS__Snapshot
    [Timeout]    28800
    TC__LOGS__Snapshot
    [Teardown]    Run Keywords    LOGS__Snapshot.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CNI-19956_Log_File_Documentation_Availability_Check
    [Setup]    Run Keywords    LOGS__CNI-19956_Log_File_Documentation_Availability_Check.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CNI-19956_Log_File_Documentation_Availability_Check
    ...    AND    Set Library Search Order    LOGS__CNI-19956_Log_File_Documentation_Availability_Check
    [Timeout]    14400
    TC__LOGS__CNI-19956_Log_File_Documentation_Availability_Check.robot
    [Teardown]    Run Keywords    LOGS__CNI-19956_Log_File_Documentation_Availability_Check.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CNI-19956_Log_File_Documentation_Content_Check
    [Setup]    Run Keywords    LOGS__CNI-19956_Log_File_Documentation_Content_Check.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CNI-19956_Log_File_Documentation_Content_Check
    ...    AND    Set Library Search Order    LOGS__CNI-19956_Log_File_Documentation_Content_Check
    [Timeout]    14400
    TC__LOGS__CNI-19956_Log_File_Documentation_Content_Check.robot
    [Teardown]    Run Keywords    LOGS__CNI-19956_Log_File_Documentation_Content_Check.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CB010239-D_01_Diagnostic_check_started_for_the_single_BTS_via_NetAct_REST_API
    [Setup]    Run Keywords    LOGS__CB010239-D_01_Diagnostic_check_started_for_the_single_BTS_via_NetAct_REST_API.TC Setup
    ...    AND    Set Library Search Order    LOGS__CB010239-D_01_Diagnostic_check_started_for_the_single_BTS_via_NetAct_REST_API
    ...    AND    Modify Resource Search Order    LOGS__CB010239-D_01_Diagnostic_check_started_for_the_single_BTS_via_NetAct_REST_API
    [Timeout]    14400
    TC__LOGS__CB010239-D_01_Diagnostic_check_started_for_the_single_BTS_via_NetAct_REST_API
    [Teardown]    Run Keywords    LOGS__CB010239-D_01_Diagnostic_check_started_for_the_single_BTS_via_NetAct_REST_API.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__Snapshot_on-hold_triggered_by_Multiple_Fault_to_NMS_via_NE3S_is_dropped_when_destination_is_re-configured
    [Setup]   Run Keywords   LOGS__Snapshot_on-hold_triggered_by_Multiple_Fault_to_NMS_via_NE3S_is_dropped_when_destination_is_re-configured.TC Setup
    ...    AND    Modify Resource Search Order
    ...           LOGS__Snapshot_on-hold_triggered_by_Multiple_Fault_to_NMS_via_NE3S_is_dropped_when_destination_is_re-configured
    ...    AND    Set Library Search Order
    ...           LOGS__Snapshot_on-hold_triggered_by_Multiple_Fault_to_NMS_via_NE3S_is_dropped_when_destination_is_re-configured
    [Timeout]     14400
    TC__LOGS__Snapshot_on-hold_triggered_by_Multiple_Fault_to_NMS_via_NE3S_is_dropped_when_destination_is_re-configured
    [Teardown]    Run Keywords
    ...           LOGS__Snapshot_on-hold_triggered_by_Multiple_Fault_to_NMS_via_NE3S_is_dropped_when_destination_is_re-configured.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CB009077_CLI_Command_Check
    [Setup]    Run Keywords    LOGS__CB009077_CLI_Command_Check.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB009077_CLI_Command_Check
    ...    AND    Set Library Search Order    LOGS__CB009077_CLI_Command_Check
    [Timeout]    14400
    TC__LOGS__CB009077_CLI_Command_Check
    [Teardown]    Run Keywords    LOGS__CB009077_CLI_Command_Check.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CB009077_EutranAccessPointPosition_Parameters_Check
    [Setup]    Run Keywords    LOGS__CB009077_EutranAccessPointPosition_Parameters_Check.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB009077_EutranAccessPointPosition_Parameters_Check
    ...    AND    Set Library Search Order    LOGS__CB009077_EutranAccessPointPosition_Parameters_Check
    [Timeout]    14400
    TC__LOGS__CB009077_EutranAccessPointPosition_Parameters_Check
    [Teardown]    Run Keywords    LOGS__CB009077_EutranAccessPointPosition_Parameters_Check.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CNI-90327_AaTrblServer_configuration_formalization
    [Setup]    Run Keywords    LOGS__CNI-90327_AaTrblServer_configuration_formalization.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CNI-90327_AaTrblServer_configuration_formalization
    ...    AND    Set Library Search Order    LOGS__CNI-90327_AaTrblServer_configuration_formalization
    [Timeout]    14400
    TC__LOGS__CNI-90327_AaTrblServer_configuration_formalization
    [Teardown]    Run Keywords    LOGS__CNI-90327_AaTrblServer_configuration_formalization.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CB009077_SRM6_RU_check
    [Setup]    Run Keywords    LOGS__CB009077_SRM6_RU_check.TC Setup
    ...    AND    Set Library Search Order    LOGS__CB009077_SRM6_RU_check
    ...    AND    Modify Resource Search Order    LOGS__CB009077_SRM6_RU_check
    [Timeout]    14400
    TC_LOGS__CB009077_SRM6_RU_check
    [Teardown]    Run Keywords    LOGS__CB009077_SRM6_RU_check.TC Teardown
    ...    AND    Restore Resource Search Order

*** Keywords ***
Suite Teardown
    Run keyword and ignore error    Collect and send logs for scrambling verification
    ...    team_name=VRFTSR5
    ...    input_logs_dir=${NONE}
