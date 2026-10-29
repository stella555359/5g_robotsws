*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SRAN  CLOUD_SRAN_L_10470_1ASIA_3ABIA_2FXED_1FXED_3FRGU_2FXDB_1FRMF  STATE_COMMISSIONED
Library           XML  use_lxml=True

Resource    ../../UE/test_resources/UE__NR_PS_call.robot
Resource    ../../UE/test_resources/UE__LTE_PS_call.robot
Resource    ../../UE/test_resources/UE__GSM_PS_call.robot
Resource    ../../UE/test_resources/UE__GSM_Voice_call.robot

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${REQUEST_SCF_SCOUT}     ${TRUE}
${SCOUT_TL_NAME}         10_18_UTESRANCLOUD1470
${TESTLINE_NAME}         10_18_UTESRANCLOUD1470

*** Test Cases ***

[1]UE GSM Voice call
    [Setup]    Run Keywords    Set Test Variable    ${NUMBER}   00104
    ...    AND    Set Test Variable    ${VOICE_CALL_TIMEOUT}   69s
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220'], ['faultId', '6283', 'alarmId', '7111']]
    ...    AND    Modify Resource Search Order    UE__GSM_Voice_call
    ...    AND    UE__GSM_Voice_call.TC Setup

    [Timeout]    99 minutes
    TC__UE__GSM_Voice_call
    [Teardown]    Run Keywords    UE__GSM_Voice_call.TC Teardown
    ...    AND    Restore Resource Search Order

