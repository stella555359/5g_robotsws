*** Settings ***
Force Tags        QCD_MN_RAN    QCP_RAN_ST    CRT    CLOUD_SRAN_L_10820_1ASOF_1AZQC    SBTS24R3
Library           XML  use_lxml=True
Resource       taf/rfrl/scrambling_logs_collector/Keywords.robot
Resource       ../../LOGS/LOGS__CB008626_FullWithoutRFLogs_Snapshot_With_Filter_Keywords.robot
Resource       ../../LOGS/LOGS__fault_6504_about_utilization_of_log_dedicated_storage_device.robot
Resource       ../../LOGS/LOGS_CB009233_Synchronisation_of_WiFi_configuration_between_SCF_and_NCF_in_FDSW.robot

Suite Teardown    Suite Teardown

*** Variables ***
${SCF_ID}         01

${COMMISSIONING_PATH}
    ...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS_10820_Audi/commissioning/SCF_01_SBTS24R3.xml

*** Test Cases ***
[1]Automated__LOGS_CB009233_Synchronisation_of_WiFi_configuration_between_SCF_and_NCF_in_FDSW
    [Setup]    Run Keywords    LOGS_CB009233_Synchronisation_of_WiFi_configuration_between_SCF_and_NCF_in_FDSW.TC Setup
    ...    AND    Set Library Search Order    LOGS_CB009233_Synchronisation_of_WiFi_configuration_between_SCF_and_NCF_in_FDSW
    ...    AND    Modify Resource Search Order    LOGS_CB009233_Synchronisation_of_WiFi_configuration_between_SCF_and_NCF_in_FDSW
    [Timeout]    14400
    TC__LOGS_CB009233_Synchronisation_of_WiFi_configuration_between_SCF_and_NCF_in_FDSW
    [Teardown]    Run Keywords    LOGS_CB009233_Synchronisation_of_WiFi_configuration_between_SCF_and_NCF_in_FDSW.TC Teardown
    ...    AND    Restore Resource Search Order

*** Keywords ***
Suite Teardown
    Run keyword and ignore error    Collect and send logs for scrambling verification
    ...    team_name=PZ3WRO5
    ...    input_logs_dir=${NONE}
