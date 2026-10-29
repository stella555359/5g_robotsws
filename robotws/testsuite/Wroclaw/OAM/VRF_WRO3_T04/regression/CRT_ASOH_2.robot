*** Settings ***
Documentation
...     Contact:        pawel.surma@nokia.com
...     michalina.kalenik@nokia.com


Resource        ../features/CB007672-I/TestCases/7672-I_TestCases.robot
Resource        ../features/CB007672-G/TestCases/7672-G_TestCases.robot
Resource        ../features/5GC001049/TestCases/CB001049_TestCases.robot
Resource        ../features/CB009131/TestCases/9131_TestCases_A.robot
Resource        ../features/CB009131/TestCases/9131_TestCases_B.robot

Resource        ../common_resources/gathering_logs/gathering_logs.robot
Resource        ../common_resources/variables/variables.robot

Suite Setup     Suite Setup
Suite Teardown  Suite Teardown

Test Setup      Test Setup
Test Teardown   Test Teardown

*** Test Cases ***
[1]CB010971_CB007672-G-SyVe_Firewall_update_new_port_ASOH
    [Tags]
    CB007672-G-SyVe_Firewall_update_new_port

[1]CB010971_5GC001049-B17_Robustness_Frequent_addition_removal_of_firewall_rules_ASOH
    [Tags]
    Robustness_Frequent_addition_removal_of_firewall_rules_ASOF

[1]CB010971_CB009131-A_11_Add_modify_remove_trusted_gNB_neighbor_in_firewall_configuration_ASOH
    [Tags]
    CB009131_Add_modify_remove_trusted_gNB_neighbor_in_firewall_configuration

[1]CB010971_CB007672-5G-I_Verifying_DSCP_setting_for_CRL_IPv4_traffic_ASOH
    [Tags]
    CB007672-5G-I-Verifying_DSCP_setting_for_CRL_IPv4_traffic

*** Keywords ***
Suite Setup
    Common Gathering Logs for Common Suite Setup
    Add Alarm To Allowed Alarms     61675     WiFi Configuration Issue

Suite Teardown
    Common Gathering Logs for Common Suite Teardown
    Run keyword and ignore error    Collect and send logs for scrambling verification   team_name=PZ3WRO4
    ...                             input_logs_dir=${NONE}

Test Setup
    Common Gathering Logs for Test Setup

Test Teardown
    Common Gathering Logs for Test Teardown
