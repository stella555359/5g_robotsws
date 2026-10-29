*** Settings ***
Resource    ./Resource/Common.robot
Variables   ./Config/15MHz_10MHz.py

Suite Setup         CB010820 Common Suite Setup
Suite Teardown      CB010820 Common Suite Teardown


*** Variables ***


*** Test Cases ***
General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing_15MHz
    [Setup]   Case Setup: General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing_15MHz
    CB010820 Common Suite Setup After Scout Connection
    General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing_15MHz
    [Teardown]   Case Teardown: General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing_15MHz


General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing_10MHz
    [Setup]   Case Setup: General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing_10MHz
    CB010820 Common Suite Setup After Scout Connection
    General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing_10MHz
    [Teardown]   Case Teardown: General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing_10MHz


*** Keywords ***
# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
# 15MHz Case
General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing_15MHz
    Log To Console   General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing_15MHz
    CB010820 L3 Call Common Keyword


Case Setup: General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing_15MHz
    robot_common_operations.Common Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=49
    Set Suite Variable   ${DEFINE_TEST_NAME}   General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing_15MHz
    CB010820 Common Case Setup
    Wait Until Keyword Succeeds   10m   1m   COAM Login
    Wait Until Keyword Succeeds   15m   1m   COAM ADMIN Check Cell Onair
    [Teardown]   Run Keyword And Ignore Error   COAM Logout


Case Teardown: General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing_15MHz
    CB010820 Common Case Teardown
    robot_common_operations.Common Case Teardown

# =========================================================================================================================================
# =========================================================================================================================================
# =========================================================================================================================================
# 10MHz Case
General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing_10MHz
    Log To Console   General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing_10MHz
    CB010820 L3 Call Common Keyword


Case Setup: General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing_10MHz
    robot_common_operations.Common Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=49
    Set Suite Variable   ${DEFINE_TEST_NAME}   General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing_10MHz
    CB010820 Common Case Setup
    Wait Until Keyword Succeeds   10m   1m   COAM Login
    Wait Until Keyword Succeeds   15m   1m   COAM ADMIN Check Cell Onair
    [Teardown]   Run Keyword And Ignore Error   COAM Logout


Case Teardown: General_SiSo_E2E_system_setup_with_data_transfer_for_configuration_feature_testing_10MHz
    CB010820 Common Case Teardown
    robot_common_operations.Common Case Teardown
