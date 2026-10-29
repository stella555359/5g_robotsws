*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS__CM__RMOD_Sync_change_CB007963.robot

*** Test Cases ***
[1]NR_SBTS__CM__RMOD_Sync_change_CB007963
    [Tags]    robot:skip
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS__CM__RMOD_Sync_change_CB007963