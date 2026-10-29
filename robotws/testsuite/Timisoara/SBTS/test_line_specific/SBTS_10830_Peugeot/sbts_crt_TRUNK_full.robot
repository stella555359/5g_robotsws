*** Settings ***
Force Tags       QCD_MN_RAN    QCP_RAN_VRF    CRT    CLOUD_SRAN_N_ASIK_3ABIL_3AEHC    SBTS00
Documentation    Suite test cases on SBTS_10830_Peugeot
Library          XML  use_lxml=True
Resource         taf/rfrl/scrambling_logs_collector/Keywords.robot
Resource         ../../LOGS/LOGS__CB008626_B_Configuration_change_history_improvement.robot
Resource         ../../LOGS/LOGS__CB008626_D_snapshot_file_list_txt_improvement.robot
Resource         ../../LOGS/LOGS__CB008390_Quota_doest_exceed_under_folder_logs_according_to_SysInfoQuota_xml.robot
Resource
...    ../../LOGS/LOGS__CB010239-A_DC_triggered_by_uncommissioned_state_of_BTS_for_CP1_and_CP2_Config_file_presence_on_both_partitions_new.robot
Resource         ../../LOGS/LOGS__CNI-90327_AaTrblServer_configuration_formalization.robot
Resource         ../../LOGS/LOGS__CB008626_C_Snapshot_coverage_improvement_full_withoutRFlogs.robot
Resource         ../../LOGS/LOGS__CB010699_Collect_Local_SCREL.robot
Resource         ../../LOGS/LOGS__CB010699_Not_possible_to_collect_SCREL_when_snapshot_is_ongoing.robot
Resource         ../../LOGS/LOGS__CB010699-A_Collect_Remote_SCREL.robot
Resource         ../../LOGS/LOGS__CB007615-SR-A-B3-Get_the_date_and_time_value_before_the_last_reset.robot
Resource         ../../LOGS/LOGS__CB010788-A_Unsupressing_Fault_248_250_Uncorrectable_ECC_memory_BBMOD.robot
Resource         ../../LOGS/LOGS__CNI-133865_AEHC_CRT.robot
Resource         ../../LOGS/LOGS__CNI_42395_Snapshot_startup_Log_ERROR_prints_ASIA_ASIK.robot

Suite Teardown    Suite Teardown

*** Variables ***
${SCF_ID}         01

${COMMISSIONING_PATH}
    ...   /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS_10830_Peugeot/commissioning/SCF_01_TRUNK.xml

${NETACT_LAB}    &{srnclab1047}

*** Test Cases ***
[1]09_CB008626_B_Configuration_change_history_improvement
    [Setup]    Run Keywords    LOGS__CB008626_B_Configuration_change_history_improvement.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB008626_B_Configuration_change_history_improvement
    ...    AND    Set Library Search Order    LOGS__CB008626_B_Configuration_change_history_improvement
    [Timeout]    14400
    TC__LOGS__CB008626_B_Configuration_change_history_improvement
    [Teardown]    Run Keywords    LOGS__CB008626_B_Configuration_change_history_improvement.TC Teardown
    ...    AND    Restore Resource Search Order

[1]21_CB008626_D_snapshot_file_list.txt_improvement
    [Setup]    Run Keywords    LOGS__CB008626_D_snapshot_file_list_txt_improvement.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB008626_D_snapshot_file_list_txt_improvement
    ...    AND    Set Library Search Order    LOGS__CB008626_D_snapshot_file_list_txt_improvement
    [Timeout]    14400
    TC__LOGS__CB008626_D_snapshot_file_list_txt_improvement
    [Teardown]    Run Keywords    LOGS__CB008626_D_snapshot_file_list_txt_improvement.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CB008390_Quota_doest_exceed_under_folder_logs_according_to_SysInfoQuota_xml
    [Setup]    Run Keywords    LOGS__CB008390_Quota_doest_exceed_under_folder_logs_according_to_SysInfoQuota_xml.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB008390_Quota_doest_exceed_under_folder_logs_according_to_SysInfoQuota_xml
    ...    AND    Set Library Search Order    LOGS__CB008390_Quota_doest_exceed_under_folder_logs_according_to_SysInfoQuota_xml
    [Timeout]    14400
    TC__LOGS__CB008390_Quota_doest_exceed_under_folder_logs_according_to_SysInfoQuota_xml
    [Teardown]    Run Keywords    LOGS__CB008390_Quota_doest_exceed_under_folder_logs_according_to_SysInfoQuota_xml.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CB010239-A_DC_triggered_by_uncommissioned_state_of_BTS_for_CP1_and_CP2_Config_file_presence_on_both_partitions
    [Setup]    Run Keywords
    ...    LOGS__CB010239-A_DC_triggered_by_uncommissioned_state_of_BTS_for_CP1_and_CP2_Config_file_presence_on_both_partitions_new.TC Setup
    ...    AND    Modify Resource Search Order
    ...    LOGS__CB010239-A_DC_triggered_by_uncommissioned_state_of_BTS_for_CP1_and_CP2_Config_file_presence_on_both_partitions_new
    ...    AND    Set Library Search Order
    ...    LOGS__CB010239-A_DC_triggered_by_uncommissioned_state_of_BTS_for_CP1_and_CP2_Config_file_presence_on_both_partitions_new
    [Timeout]    14400
    TC__LOGS__CB010239-A_DC_triggered_by_uncommissioned_state_of_BTS_for_CP1_and_CP2_Config_file_presence_on_both_partitions
    [Teardown]    Run Keywords
    ...    LOGS__CB010239-A_DC_triggered_by_uncommissioned_state_of_BTS_for_CP1_and_CP2_Config_file_presence_on_both_partitions_new.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CNI-90327_AaTrblServer_configuration_formalization
    [Setup]    Run Keywords    LOGS__CNI-90327_AaTrblServer_configuration_formalization.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CNI-90327_AaTrblServer_configuration_formalization
    ...    AND    Set Library Search Order    LOGS__CNI-90327_AaTrblServer_configuration_formalization
    [Timeout]    14400
    TC__LOGS__CNI-90327_AaTrblServer_configuration_formalization
    [Teardown]    Run Keywords    LOGS__CNI-90327_AaTrblServer_configuration_formalization.TC Teardown
    ...    AND    Restore Resource Search Order

[1]13_CB008626_C_Snapshot_coverage_improvement_full_withoutRFlogs
    [Setup]    Run Keywords    LOGS__CB008626_C_Snapshot_coverage_improvement_full_withoutRFlogs.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB008626_C_Snapshot_coverage_improvement_full_withoutRFlogs
    ...    AND    Set Library Search Order    LOGS__CB008626_C_Snapshot_coverage_improvement_full_withoutRFlogs
    [Timeout]    14400
    TC__LOGS__CB008626_C_Snapshot_coverage_improvement_full_withoutRFlogs
    [Teardown]    Run Keywords    LOGS__CB008626_C_Snapshot_coverage_improvement_full_withoutRFlogs.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CB010699_Collect_Local_SCREL
    [Setup]    Run Keywords    LOGS__CB010699_Collect_Local_SCREL.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB010699_Collect_Local_SCREL
    ...    AND    Set Library Search Order    LOGS__CB010699_Collect_Local_SCREL
    [Timeout]    14400
    TC__LOGS__CB010699_Collect_Local_SCREL
    [Teardown]    Run Keywords    LOGS__CB010699_Collect_Local_SCREL.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CB010699_Not_possible_to_collect_SCREL_when_snapshot_is_ongoing
    [Setup]    Run Keywords    LOGS__CB010699_Not_possible_to_collect_SCREL_when_snapshot_is_ongoing.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB010699_Not_possible_to_collect_SCREL_when_snapshot_is_ongoing
    ...    AND    Set Library Search Order    LOGS__CB010699_Not_possible_to_collect_SCREL_when_snapshot_is_ongoing
    [Timeout]    14400
    TC__LOGS__CB010699_Not_possible_to_collect_SCREL_when_snapshot_is_ongoing
    [Teardown]    Run Keywords    LOGS__CB010699_Not_possible_to_collect_SCREL_when_snapshot_is_ongoing.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CB010699-A_Collect_Remote_SCREL
    [Setup]    Run Keywords    LOGS__CB010699-A_Collect_Remote_SCREL.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB010699-A_Collect_Remote_SCREL
    ...    AND    Set Library Search Order    LOGS__CB010699-A_Collect_Remote_SCREL
    [Timeout]    14400
    TC__LOGS__CB010699-A_Collect_Remote_SCREL
    [Teardown]    Run Keywords    LOGS__CB010699-A_Collect_Remote_SCREL.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CB007615-SR-A-B3-Get_the_date_and_time_value_before_the_last_reset
    [Setup]    Run Keywords    LOGS__CB007615-SR-A-B3-Get_the_date_and_time_value_before_the_last_reset.TC Setup
    ...    AND    Set Library Search Order    LOGS__CB007615-SR-A-B3-Get_the_date_and_time_value_before_the_last_reset
    ...    AND    Modify Resource Search Order    LOGS__CB007615-SR-A-B3-Get_the_date_and_time_value_before_the_last_reset
    [Timeout]    14400
    TC__LOGS__CB007615-SR-A-B3-Get_the_date_and_time_value_before_the_last_reset
    [Teardown]    Run Keywords    LOGS__CB007615-SR-A-B3-Get_the_date_and_time_value_before_the_last_reset.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated_CB010788-A_Unsupressing_Fault_248_250_Uncorrectable_ECC_memory_BBMOD
    [Setup]    Run Keywords    LOGS__CB010788-A_Unsupressing_Fault_248_250_Uncorrectable_ECC_memory_BBMOD.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB010788-A_Unsupressing_Fault_248_250_Uncorrectable_ECC_memory_BBMOD
    ...    AND    Set Library Search Order    LOGS__CB010788-A_Unsupressing_Fault_248_250_Uncorrectable_ECC_memory_BBMOD
    [Timeout]    14400
    TC__LOGS__CB010788-A_Unsupressing_Fault_248_250_Uncorrectable_ECC_memory_BBMOD    FSP_ID=fsp-1-1a    board_pos=1    SMOD_side=1
    [Teardown]    Run Keywords    LOGS__CB010788-A_Unsupressing_Fault_248_250_Uncorrectable_ECC_memory_BBMOD.TC Teardown
    ...    AND    Restore Resource Search Order

CNI-133865_AEHC_CRT
    [Setup]    Run Keywords    LOGS__CB008390_Quota_doest_exceed_under_folder_logs_according_to_SysInfoQuota_xml.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB008390_Quota_doest_exceed_under_folder_logs_according_to_SysInfoQuota_xml
    ...    AND    Set Library Search Order    LOGS__CB008390_Quota_doest_exceed_under_folder_logs_according_to_SysInfoQuota_xml
    [Timeout]    14400
    TC__LOGS__CNI-133865_AEHC_CRT
    [Teardown]    Run Keywords    LOGS__CB008390_Quota_doest_exceed_under_folder_logs_according_to_SysInfoQuota_xml.TC Teardown
    ...    AND    Restore Resource Search Order

LOGS__Snapshot_startup_Log_ERROR_prints
    [Setup]    Run Keywords    LOGS__CNI_42395_Snapshot_startup_Log_ERROR_prints_ASIA_ASIK.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CNI_42395_Snapshot_startup_Log_ERROR_prints_ASIA_ASIK
    ...    AND    Set Library Search Order    LOGS__CNI_42395_Snapshot_startup_Log_ERROR_prints_ASIA_ASIK
    [Timeout]    14400
    TC__LOGS__CNI_42395_Snapshot_startup_Log_ERROR_prints
    [Teardown]    Run Keywords    LOGS__CNI_42395_Snapshot_startup_Log_ERROR_prints_ASIA_ASIK.TC Teardown
    ...    AND    Restore Resource Search Order

*** Keywords ***
Suite Teardown
    Run keyword and ignore error    Collect and send logs for scrambling verification
    ...    team_name=VRFTSR5
    ...    input_logs_dir=${NONE}
