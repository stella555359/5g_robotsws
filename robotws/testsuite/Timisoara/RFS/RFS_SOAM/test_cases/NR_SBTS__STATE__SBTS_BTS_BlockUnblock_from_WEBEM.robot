*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS__STATE__BTS_BlockUnblock_from_WEBEM.robot

*** Test Cases ***
[1]NR_SBTS__STATE__SBTS_BTS_BlockUnblock_from_WEBEM
    [Tags]    robot:skip
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS__STATE__BTS_BlockUnblock_from_WEBEM

