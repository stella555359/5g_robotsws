*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__Common_Startup.robot

*** Test Cases ***
[1]SBTS_SBTS__STATE__BTS1_BTS2_Common_Startup
    [Tags]    robot:skip
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS_SBTS_SBTS__STATE__Common_Startup

