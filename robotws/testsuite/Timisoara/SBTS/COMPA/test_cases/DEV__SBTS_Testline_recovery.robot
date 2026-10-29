*** Settings ***
Documentation  This suite contains DEV__SBTS_Testline_recovery TC

Resource  ../test_resources/DEV__SBTS_Testline_recovery.robot


*** Test Cases ***
DEV__SBTS_Testline_recovery
    [Setup]  TC Setup
    TC__DEV__SBTS_Testline_recovery
    [Teardown]  TC Teardown
