*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS_SBTS_SBTS__LOGS__SBTS_snapshot_from_WEBEM.robot

*** Test Cases ***
[1]NR_SBTS__LOGS__NR_SBTS_snapshot_from_WEBEM
    [Tags]    robot:skip
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS_SBTS_SBTS__LOGS__SBTS_snapshot_from_WEBEM

