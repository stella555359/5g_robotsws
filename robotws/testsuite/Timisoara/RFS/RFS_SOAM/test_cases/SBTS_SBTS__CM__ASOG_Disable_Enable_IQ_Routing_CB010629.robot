*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS__CM__ASOG_Disable_Enable_IQ_Routing_CB010629.robot

*** Test Cases ***
[1]SBTS_SBTS__CM__ASOG_Disable_Enable_IQ_Routing_CB010629
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS__CM__ASOG_Disable_Enable_IQ_Routing_CB010629