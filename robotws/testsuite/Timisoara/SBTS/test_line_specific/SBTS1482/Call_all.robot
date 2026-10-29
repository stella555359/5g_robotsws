*** Settings ***
Force Tags  QCD_MN_RAN  QCP_RAN_ST  SRAN  CLOUD_SRAN_NL_10482_1ASIB_2ABIL_3AEQE  STATE_COMMISSIONED
Library           XML  use_lxml=True

Resource    ../../UE/test_resources/UE__NR_PS_call.robot
Resource    ../../UE/test_resources/UE__LTE_PS_call.robot
Resource    ../../UE/test_resources/UE__GSM_PS_call.robot
Resource    ../../UE/test_resources/UE__GSM_Voice_call.robot

*** Variables ***
${SCF_ID}    01
${HW_LOCATION_CODE}      Timisoara
${REQUEST_SCF_SCOUT}     ${TRUE}
${SCOUT_TL_NAME}         10_18_UTESRANCLOUD1482
${TESTLINE_NAME}         10_18_UTESRANCLOUD1482

*** Test Cases ***
[1]UE NR PS call
    [Setup]    Run Keywords    Set Test Variable    ${MIN_NR_THROUGHPUT}   120 Mbits/sec
    ...    AND    Set Test Variable    ${PS_DURATION}   69s
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220'], ['faultId', '6283', 'alarmId', '7111']]
    ...    AND    Modify Resource Search Order    UE__NR_PS_call
    ...    AND    UE__NR_PS_call.TC Setup

    [Timeout]    99 minutes
    TC__UE__NR_PS_call
    [Teardown]    Run Keywords    UE__NR_PS_call.TC Teardown
    ...    AND    Restore Resource Search Order


[1]UE LTE PS call
    [Setup]    Run Keywords    Set Test Variable    ${MIN_LTE_THROUGHPUT}   10 Mbits/sec
    ...    AND    Set Test Variable    ${MIN_LTE_THROUGHPUT}   69s
    ...    AND    Set Test Variable    ${ADDITIONAL_IGNORED_ALARMS}
    ...    [['faultId', '4655', ' alarmId ', '7220'], ['faultId', '4654', 'alarmId', '7220'], ['faultId', '6283', 'alarmId', '7111']]
    ...    AND    Modify Resource Search Order    UE__LTE_PS_call
    ...    AND    UE__LTE_PS_call.TC Setup

    [Timeout]    99 minutes
    TC__UE__LTE_PS_call
    [Teardown]    Run Keywords    UE__LTE_PS_call.TC Teardown
    ...    AND    Restore Resource Search Order


