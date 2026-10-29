*** Settings ***
Resource    ../test_resources/WebEM__BTS_log_level.robot

*** Test Cases ***
WebEM__BTS_log_level
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__WebEM__BTS_log_level
