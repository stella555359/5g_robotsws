*** Settings ***
Test Setup        test setup
Test Teardown     test teardown
Resource          ../../resources/DevHZ5_resource.robot

*** Variables ***
@{PARAMETERS}
...    NRBTS:actExtN77Support=true
...    NRBTS:actIdlMMEnDcSteering=true

${TARGET_SCF}     ${CURDIR}/logs/target_scf.xml
${BASE_SCF}       ${CURDIR}/logs/base_scf.xml

*** Test Cases ***
Verify Parameters
    Modify Scf    ${BASE_SCF}    ${PARAMETERS}    ${CURDIR}/verify_logs/new_scf.xml
    Set Suite Variable    ${modified_done}    ${True}
    Execute Cmd On Pc    cd ${CURDIR}; python compare_scf.py ${CURDIR}/verify_logs/new_scf.xml ${TARGET_SCF} ${CURDIR}/verify_logs
    ...    timeout=60
    Copy File    ${CURDIR}/verify_logs/target_scf.xml    ${CURDIR}/verify_logs/new_scf.xml
    Copy File    ${CURDIR}/verify_logs/base_scf.xml    ${CURDIR}/verify_logs/target_scf.xml
    File Should Be Empty    ${CURDIR}/verify_logs/delta.xml

*** Keywords ***
test teardown
    Run Keyword If Test Failed    Run Keyword If    ${modified_done}    Log To Console
    ...    pls compare new_scf.xml and target_scf.xml ${CURDIR}/verify_logs
    Execute Cmd On Pc    rm -rf ${CURDIR}/verify_logs/migrated*
    Execute Cmd On Pc    rm -rf ${CURDIR}/verify_logs/*infomodel*
    teardown all aliases for enb fsmaccess

test setup
    Log To Console    ${EMPTY}
    Set Suite Variable    ${SUITE_LOG_DIRECTORY}    ${CURDIR}/verify_logs/
    Set Suite Variable    ${SAVE LOG DIRECTORY}    ${CURDIR}/verify_logs/
    Run Keyword And Ignore Error    Remove Directory    ${CURDIR}/verify_logs
    Create Directory    ${CURDIR}/verify_logs
    Set Suite Variable    ${modified_done}    ${False}
    Setup Enb Fsm Access  fallback_prompt=#  host=${FTM_IP}
    ${GNB_SW_VERSION}  Get Gnb Sw Version
    Log  activeBuildVersion\=${GNB_SW_VERSION}  level=WARN
    Set Suite Variable  ${GNB_SW_VERSION}
