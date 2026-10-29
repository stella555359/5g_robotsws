*** Settings ***
Documentation  Tests on AUDI

Force Tags        QCD_MN_RAN    QCP_RAN_ST    CRT    CLOUD_SRAN_L_10820_1ASOF_1AZQC    SBTS00
Library           XML  use_lxml=True
Resource       taf/rfrl/scrambling_logs_collector/Keywords.robot
Resource       ../../LOGS/LOGS__fault_6504_about_utilization_of_log_dedicated_storage_device.robot
Resource       ../../LOGS/LOGS_CB009233_Synchronisation_of_WiFi_configuration_between_SCF_and_NCF_in_FDSW.robot
Resource       ../../LOGS/LOGS__CNI-90327_AaTrblServer_configuration_formalization.robot
Resource       ../../LOGS/LOGS__sn_pc_check_ASPx_on_MantaRay.robot
Resource       ../../LOGS/LOGS__CNI-132394_trigger_fault_214.robot
Resource       ../../LOGS/LOGS__CB010547_A_12_Remote_power_reset_without_snapshot_collection.robot
Resource       ../../LOGS/LOGS__CB009800_CB007040_CRT.robot
Resource       ../../LOGS/LOGS__CNI_123286_Store_SW_start_up_checkpoints_to_FPGA_logs.robot

Suite Teardown    Suite Teardown

*** Variables ***
${SCF_ID}         01

${COMMISSIONING_PATH}
    ...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS_10820_Audi/commissioning/SCF_01_TRUNK.xml

${NETACT_LAB}    &{srnclab3007}

*** Test Cases ***
LOGS__CNI_123286_Store_SW_start_up_checkpoints_to_FPGA_logs
    [Setup]    Run Keywords    LOGS__CNI_123286_Store_SW_start_up_checkpoints_to_FPGA_logs.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CNI_123286_Store_SW_start_up_checkpoints_to_FPGA_logs
    ...    AND    Set Library Search Order    LOGS__CNI_123286_Store_SW_start_up_checkpoints_to_FPGA_logs
    [Timeout]    14400
    TC__LOGS__CNI_123286_Store_SW_start_up_checkpoints_to_FPGA_logs
    [Teardown]    Run Keywords    LOGS__CNI_123286_Store_SW_start_up_checkpoints_to_FPGA_logs.TC Teardown
    ...    AND    Restore Resource Search Order

[1]CB013694_check_ASPx_on_MantaRay
    [Setup]    Run Keywords    LOGS__sn_pc_check_ASPx_on_MantaRay.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__sn_pc_check_ASPx_on_MantaRay
    ...    AND    Set Library Search Order    LOGS__sn_pc_check_ASPx_on_MantaRay
    [Timeout]    14400
    TC__LOGS__sn_pc_check_ASPx_on_MantaRay
    [Teardown]    Run Keywords    LOGS__sn_pc_check_ASPx_on_MantaRay.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS_CB009233_Synchronisation_of_WiFi_configuration_between_SCF_and_NCF_in_FDSW
    [Setup]    Run Keywords    LOGS_CB009233_Synchronisation_of_WiFi_configuration_between_SCF_and_NCF_in_FDSW.TC Setup
    ...    AND    Set Library Search Order    LOGS_CB009233_Synchronisation_of_WiFi_configuration_between_SCF_and_NCF_in_FDSW
    ...    AND    Modify Resource Search Order    LOGS_CB009233_Synchronisation_of_WiFi_configuration_between_SCF_and_NCF_in_FDSW
    [Timeout]    14400
    TC__LOGS_CB009233_Synchronisation_of_WiFi_configuration_between_SCF_and_NCF_in_FDSW
    [Teardown]    Run Keywords    LOGS_CB009233_Synchronisation_of_WiFi_configuration_between_SCF_and_NCF_in_FDSW.TC Teardown
    ...    AND    Restore Resource Search Order

[1]CB009800_Automated__LOGS_CB008390_fault_6504_about_utilization_of_log_dedicated_storage_device
    [Setup]    Run Keywords    Set Test Variable    ${SNAPSHOT_TIMEOUT}    1200
    ...    AND    LOGS__fault_6504_about_utilization_of_log_dedicated_storage_device.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__fault_6504_about_utilization_of_log_dedicated_storage_device
    ...    AND    Set Library Search Order    LOGS__fault_6504_about_utilization_of_log_dedicated_storage_device
    [Timeout]    14400
    TC__LOGS__fault_6504_about_utilization_of_log_dedicated_storage_device
    [Teardown]    Run Keywords    LOGS__fault_6504_about_utilization_of_log_dedicated_storage_device.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CNI-90327_AaTrblServer_configuration_formalization
    [Setup]    Run Keywords    LOGS__CNI-90327_AaTrblServer_configuration_formalization.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CNI-90327_AaTrblServer_configuration_formalization
    ...    AND    Set Library Search Order    LOGS__CNI-90327_AaTrblServer_configuration_formalization
    [Timeout]    14400
    TC__LOGS__CNI-90327_AaTrblServer_configuration_formalization
    [Teardown]    Run Keywords    LOGS__CNI-90327_AaTrblServer_configuration_formalization.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CNI-132394_trigger_fault_214
    [Setup]    Run Keywords    LOGS__CNI-132394_trigger_fault_214.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CNI-132394_trigger_fault_214
    ...    AND    Set Library Search Order    LOGS__CNI-132394_trigger_fault_214
    [Timeout]    14400
    TC__LOGS__CNI-132394_trigger_fault_214
    [Teardown]    Run Keywords    LOGS__CNI-132394_trigger_fault_214.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CB010547_A_12_Remote_power_reset_without_snapshot_collection
    [Setup]    Run Keywords    LOGS__CB010547_A_12_Remote_power_reset_without_snapshot_collection.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB010547_A_12_Remote_power_reset_without_snapshot_collection
    ...    AND    Set Library Search Order    LOGS__CB010547_A_12_Remote_power_reset_without_snapshot_collection
    [Timeout]    14400
    TC__LOGS__CB010547_A_12_Remote_power_reset_without_snapshot_collection
    [Teardown]    Run Keywords    LOGS__CB010547_A_12_Remote_power_reset_without_snapshot_collection.TC Teardown
    ...    AND    Restore Resource Search Order

[1]Automated__LOGS__CB009800_CB007040_CRT
    [Setup]    Run Keywords    LOGS__CB009800_CB007040_CRT.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CB009800_CB007040_CRT
    ...    AND    Set Library Search Order    LOGS__CB009800_CB007040_CRT
    [Timeout]    14400
    TC__LOGS__CB009800_CB007040_CRT
    [Teardown]    Run Keywords    LOGS__CB009800_CB007040_CRT.TC Teardown
    ...    AND    Restore Resource Search Order

*** Keywords ***
Suite Teardown
    Run keyword and ignore error    Collect and send logs for scrambling verification
    ...    team_name=VRFTSR5
    ...    input_logs_dir=${NONE}
