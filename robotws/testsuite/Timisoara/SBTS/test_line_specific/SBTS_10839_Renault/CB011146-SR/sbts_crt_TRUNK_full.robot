*** Settings ***
Documentation    Test cases for CB011146 SR
Force Tags        QCD_MN_RAN    QCP_RAN_ST    CRT    CLOUD_SRAN_LWG_1ASIA_2ABIA_1FSMF_2FBBC_1FRGU_1FXED_2RFGY    SBTS00
Library           XML  use_lxml=True
Resource          taf/rfrl/scrambling_logs_collector/Keywords.robot
Resource          ../../../LOGS/LOGS__CB011146_A_SR_WebEM_Remote_Tool_Classical_BTS_CLI.robot
Resource          ../../../LOGS/LOGS__CB011146_B_SR_getSwVersion.robot
Resource          ../../../LOGS/LOGS__CB011146_D_SR_Rest_API_get_CellStatus_otherUser.robot

Suite Teardown    Suite Teardown

*** Variables ***
${SCF_ID}         01

${COMMISSIONING_PATH}
     ...    /home/ute/testline_configuration/10_18_UTESRANCLOUD1839/node1/SCF_01_TRUNK.xml


*** Test Cases ***
CB011146_D_SR_Rest_API_get_CellStatus_otherUser
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
    TC__LOGS__vDU__CB011146_D_SR_Rest_API_get_CellStatus
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
    ...    team_name=VRF1_7
    ...    input_logs_dir=${NONE}
