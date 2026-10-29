*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/SBTS_SBTS__STATE__RM_Reset_when_critical_DFE_is_broken_CNI_113670.robot

*** Test Cases ***
[1]SBTS_SBTS__STATE__RM_Reset_when_critical_DFE_is_broken_CNI_113670
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__SBTS_SBTS__STATE__RM_Reset_when_critical_DFE_is_broken_CNI_113670