*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SRAN  CLOUD_SRAN_L_10472_1ASIB_3ABIC_3AEHC  STATE_COMMISSIONED
Library           XML  use_lxml=True

Resource    ../../LOGS/LOGS__CB009077_CLI_Command_Check.robot
Resource    ../../LOGS/LOGS__CB009077_EutranAccessPointPosition_Parameters_Check.robot



*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${ENB_BUILD}    SBTS00_ENB_9999_211207_000006
${COMMISSIONING_PATH}    /home/ute/testline_configuration/10_18_UTESRANCLOUD1472/node1/BTS_CLOUD_SRAN_L_10472_1ASIB_3ABIC_3AEHC_SBTS00.xml
${REQUEST_SCF_SCOUT}    ${TRUE}
${SCOUT_TL_NAME}    MRBTS-10472


*** Test Cases ***


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

