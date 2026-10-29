*** Settings ***
Force Tags        QCD_MN_RAN    QCP_RAN_ST    CRT    CLOUD_SRAN_L_10820_1ASOF_1AWHHD    SBTS25R1
Library           XML  use_lxml=True
Resource       taf/rfrl/scrambling_logs_collector/Keywords.robot
Resource       ../../LOGS/LOGS__CNI-90327_AaTrblServer_configuration_formalization.robot

Suite Teardown    Suite Teardown

*** Variables ***
${SCF_ID}         01

${COMMISSIONING_PATH}
    ...    /home/ute/MN/UTE/robotws/testsuite/Timisoara/SBTS/test_line_specific/SBTS_10820_Audi/commissioning/SCF_01_SBTS25R1.xml

*** Test Cases ***
[1]Automated__LOGS__CNI-90327_AaTrblServer_configuration_formalization
    [Setup]    Run Keywords    LOGS__CNI-90327_AaTrblServer_configuration_formalization.TC Setup
    ...    AND    Modify Resource Search Order    LOGS__CNI-90327_AaTrblServer_configuration_formalization
    ...    AND    Set Library Search Order    LOGS__CNI-90327_AaTrblServer_configuration_formalization
    [Timeout]    14400
    TC__LOGS__CNI-90327_AaTrblServer_configuration_formalization
    [Teardown]    Run Keywords    LOGS__CNI-90327_AaTrblServer_configuration_formalization.TC Teardown
    ...    AND    Restore Resource Search Order

*** Keywords ***
Suite Teardown
    Run keyword and ignore error    Collect and send logs for scrambling verification
    ...    team_name=PZ3WRO5
    ...    input_logs_dir=${NONE}
