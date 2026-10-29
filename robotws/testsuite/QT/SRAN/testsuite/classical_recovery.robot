*** Settings ***
Force Tags    PY39    RF50
Documentation      Classical Recovery
Library      ${CURDIR}/../resources/python/QTListener.py
Resource     ${CURDIR}/../resources/robot/recovery.robot
Resource     ${CURDIR}/../resources/robot/log_collector.robot
Resource     ${CURDIR}/../resources/robot/common_variables.robot

Suite Setup        Recovery Suite Setup
Suite Teardown     Run Keyword And Ignore Error    Recovery Suite Teardown

*** Test Cases ***
Preconditions For Recovery
    [Tags]     PRECONDITIONS
    [Setup]    WA for coam connect
    Verify Cells Setup For Recovery    time=1min
    [Teardown]    coam.teardown      connection=coam_admin

Site Reset
    [Tags]     SITE_RESET
    Perform Site Reset
    Verify BTS State By Ping    not_pingable=False
    Verify BTS After Recovery

Power Reset
    [Tags]     POWER_RESET
    Perform Power Reset
    Verify BTS State By Ping
    Verify BTS After Recovery

Rollback Software
    [Tags]     ROLLBACK
    [Setup]    Check If Alarm SW Fallback Exists
    Run Keyword If    ${sw_fallback}    Log    SW fallback fault is visible - SW rollback will be not performed!    WARN
    ...       ELSE    Run Keywords      Perform Rollback
    ...        AND                      Wait Until Keyword Succeeds    360s    30s    Verify Rollback
    ...        AND                      Verify BTS After Recovery


