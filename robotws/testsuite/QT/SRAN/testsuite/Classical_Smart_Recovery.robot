*** Settings ***
Documentation    SBTS Smart Recovery

Resource     ${CURDIR}/../resources/robot/smart_recovery.robot
Resource     ${CURDIR}/../resources/robot/log_collector.robot
Resource     ${CURDIR}/../resources/robot/common_l3call.robot
Resource     ${CURDIR}/../resources/robot/allowed_alarms.robot
Resource     ${CURDIR}/../resources/robot/common_variables.robot
Library      ${CURDIR}/../resources/python/TLHelper.py    ${tl}    WITH NAME    tl_helper
Library      ${CURDIR}/../resources/python/TestCaseRequirement.py
Library      ${CURDIR}/../resources/python/QTListener.py

Suite Setup        Smart Recovery Suite Setup
Suite Teardown     Run Keyword And Ignore Error    Smart Recovery Suite Teardown

*** Test Cases ***
Perform Yaft Or SW Update
    [Tags]     UPDATE
    ${coam_connect}    Run Keyword And Return Status    WA for coam connect    ${tl.${gnb_or_enb}s[0].cu.oam_http_connection_details.addr}
    Run Keyword If     ${coam_connect}     Run Keywords
    ...                Run Keyword And Ignore Error    Check Active Alarms
    ...       AND      Perform SW Update
    ...       ELSE     Perform Recovery With Netboot And Yaft
    Precheck For Recovery
    [Teardown]    Run Keyword And Ignore Error    coam.teardown_admin    connection=coam_admin

Precheck
    [Tags]     PRECHECK
    Precheck For Recovery    labPC_time=30s    coam_time=30s    smod_time=30s    bbmod_time=30s    rf_time=30s    onair_time=30s    alarm_time=30s
    ...                      UE_time=30s    UE_ENV_check=${UE_ENV_check}    lmp_time=30s

Smart Recovery
    [Tags]     SMART_RECOVERY
    Run Keyword If     ${RECOVERY}==${True}    Check PDU Status
    ...       ELSE     Set Test Variable    ${SET_NO_RECOVERY}    ${True}
    ${TESTLINE_OFF}    Set Variable If     '${labpc_status}'=='${False}'    ${True}    ${TESTLINE_OFF}
    Run Keyword If     '${TESTLINE_OFF}'=='${False}' and '${RECOVERY}'=='${True}'    Run Smart Recovery
    Run Keyword If     '${is_standalone}'=='${False}' and '${enb_host}'!='None'    Run Keyword And Ignore Error    Precheck NSA eNB For Recovery
    [Teardown]         Set Testline Status    ${TESTLINE_OFF}
