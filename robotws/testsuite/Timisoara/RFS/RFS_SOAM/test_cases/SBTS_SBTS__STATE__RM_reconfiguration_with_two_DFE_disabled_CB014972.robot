*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS__STATE__RM_reconfiguration_with_two_DFE_disabled_CB014972.robot

*** Test Cases ***
[1]SBTS_SBTS__STATE__RM_reconfiguration_with_two_DFE_disabled_CB014972
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS__STATE__RM_reconfiguration_with_two_DFE_disabled_CB014972

