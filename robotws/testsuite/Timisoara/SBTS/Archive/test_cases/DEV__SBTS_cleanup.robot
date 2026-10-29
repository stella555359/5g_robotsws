*** Settings ***
Resource    ../test_resources/DEV__SBTS_cleanup.robot

*** Test Cases ***
DEV__SBTS_Testline_recovery
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__DEV__SBTS_cleanup

