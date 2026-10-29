*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/CBTS_SBTS__STATE__FHGW_RINLINE_Link_Break.robot

*** Test Cases ***
[1]CBTS_SBTS__STATE__FHGW_RINLINE_Link_Break
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__CBTS_SBTS__STATE__FHGW_RINLINE_Link_Break
