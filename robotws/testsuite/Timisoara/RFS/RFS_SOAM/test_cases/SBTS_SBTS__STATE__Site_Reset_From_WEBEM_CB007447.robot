*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS__STATE__Site_Reset_From_WEBEM_CB007447.robot

*** Test Cases ***
[1]SBTS_SBTS__STATE__Site_Reset_From_WEBEM_CB007447
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS__STATE__Site_Reset_From_WEBEM_CB007447
