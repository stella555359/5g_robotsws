*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/CBTS_SBTS__STATE__Check_TRM_feature_with_FHGW_config.robot

*** Test Cases ***
[1]CBTS_SBTS__STATE__Check_TRM_feature_with_FHGW_config
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__CBTS_SBTS__STATE__Check_TRM_feature_with_FHGW_config

