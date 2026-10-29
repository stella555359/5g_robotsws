*** Settings ***
Resource    ../Resource/Common.robot


*** Variables ***



*** Keywords ***
Test_Case_General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing
    Case Setup: General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing
    General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing
    [Teardown]   Case Teardown: General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing


General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing
    Log To Console   General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing
    CB010820 L3 Call Common Keyword


Case Setup: General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing
    Set Suite Variable   ${DEFINE_TEST_NAME}   General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing
    CB010820 Common Case Setup
    Wait Until Keyword Succeeds   10m   1m   COAM Login
    Wait Until Keyword Succeeds   15m   1m   COAM ADMIN Check Cell Onair
    [Teardown]   Run Keyword And Ignore Error   COAM Logout


Case Teardown: General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing
    CB010820 Common Case Teardown

