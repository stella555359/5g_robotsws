*** Settings ***
Documentation    Testsuite for TL10741_Hyundai ASOG_A102
Force Tags        QCD_MN_RAN    QCP_RAN_ST    CRT    CLOUD_SRAN_NL_10741_1ASOG_1AHLOB_1AEHC     SBTS00
Library           XML  use_lxml=True
Resource       taf/rfrl/scrambling_logs_collector/Keywords.robot

Resource       ../../LOGS/LOGS_CB009233_Synchronisation_of_WiFi_configuration_between_SCF_and_NCF_in_FDSW.robot


Suite Teardown    Suite Teardown

*** Variables ***
${SCF_ID}         01

${COMMISSIONING_PATH}
    ...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS_10741_Hyundai/commissioning/SCF_01_TRUNK.xml

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
    ...    team_name=VRFTSR5
    ...    input_logs_dir=${NONE}
