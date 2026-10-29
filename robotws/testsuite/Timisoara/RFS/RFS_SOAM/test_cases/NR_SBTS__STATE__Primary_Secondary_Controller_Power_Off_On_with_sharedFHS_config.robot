*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS__STATE__BTS_Power_Off_On.robot

*** Test Cases ***
[1]NR_SBTS__STATE__Primary_Secondary_Controller_Power_Off_On_with_sharedFHS_config
    [Tags]    robot:skip
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS__STATE__BTS_Power_Off_On

