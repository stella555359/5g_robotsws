*** Settings ***
Documentation    Suite for testcases from Pack B for NESAS.

Resource        ../features/NESAS/Pack_A/TestCases/NESAS-A.robot
Resource        ../common_resources/swconfig/swconfig.robot
Resource        ../common_resources/scf/scf_sender.robot
Resource        ../common_resources/connections/connections.robot
Resource        ../common_resources/scout/scout_operations.robot
Resource        ../common_resources/alarms/alarm.robot
Resource        ../common_resources/variables/variables.robot
Resource        ../common_resources/gathering_logs/gathering_logs.robot
Resource        taf/rfrl/common_resources/common_step/interface.robot
Resource        taf/rfrl/scrambling_logs_collector/Keywords.robot

Library         ../common_resources/robot_extensions/robot_extensions.py

Force Tags      CA_RAN_PZ_WRO_3
...             RESPONSIBLE_TESTER=kubacka

Suite Setup       Suite Setup
Suite Teardown    Suite Teardown

Test Setup        Test Setup
Test Teardown     Test Teardown

*** Test Cases ***

[1]NESAS-A_Unencrypted_Private_Keys_Check_Bin
    [Tags]
    Unencrypted_Private_Keys_Check_Bin

[1]NESAS-A_Crypto_Agent_Initialization_To_Protect_Private_Keys_And_Secure_Storage_Of_The_Files
    [Tags]
    Crypto_Agent_Initialization_To_Protect_Private_Keys_And_Secure_Storage_Of_The_Files

[1]NESAS-A_Crypto_Agent_Secure_Storage_Of_The_Keys_Vendor_Certificate
    [Tags]
    Crypto_Agent_Secure_Storage_Of_The_Keys_Vendor_Certificate

[1]NESAS-A_Default_Users_Pass_Check_Unprotected_Files
    [Tags]
    Default_Users_Pass_Check_Unprotected_Files

[1]NESAS-A_Echo_Reply_Send_Check_ICMP_IPv4
    [Tags]
    Echo_Reply_Send_Check_ICMP_IPv4

[1]NESAS-A_Echo_Reply_Send_Check_ICMP_IPv6
    [Tags]
    Echo_Reply_Send_Check_ICMP_IPv6

[1]NESAS-A_FW_egress_rules_check_ICMP_IPv4
    [Tags]
    Egress_rules_check_ICMP_IPv4

[1]NESAS-A_FW_egress_rules_check_ICMP_IPv6
    [Tags]
    Egress_rules_check_ICMP_IPv6

[1]NESAS-A_FW_ingress_rules_check_ICMP_IPv4
    [Tags]
    Ingress_rules_check_ICMP_IPv4

[1]NESAS-A_FW_ingress_rules_check_ICMP_IPv6_extended
    [Tags]
    Ingress_rules_check_ICMP_IPv6_extended

[1]NESAS-A_gNB_Unencrypted_Password_New_User
    [Tags]
    Unencrypted_Password_New_User

[1]NESAS-A_gNB_Unencrypted_Password_wsuser
    [Tags]
    Unencrypted_Password_wsuser

[1]NESAS-A_gNB_Unencrypted_Private_Keys_Check
    [Tags]
    Unencrypted_Private_Keys_Check

[1]NESAS-IPv4_packet_with_and_without_IP_options
    [Tags]
    IPv4_packet_with_and_without_IP_options

[1]NESAS-A_IPv6_packet_with_and_without_extension_header_Mplane
    [Tags]
    IPv6_packet_with_and_without_extension_header_Mplane

[1]NESAS-A_process_check_ICMP_IPv4
    [Tags]
    Process_check_ICMP_IPv4

[1]NESA-A_process_check_ICMP_IPv6
    [Tags]
    Process_check_ICMP_IPv6

[1]NESAS-A_respond_check_ICMP_IPv4_set1
    [Tags]
    Respond_check_ICMP_IPv4_set1

[1]NESAS-A_respond_check_ICMP_IPv6_set1
    [Tags]
    Respond_check_ICMP_IPv6_set1

[1]NESAS-A_Timestamp_reply_send_check_ICMP_IPv4
    [Tags]
    Timestamp_reply_send_check_ICMP_IPv4

*** Keywords ***
Suite Setup
    Common Gathering Logs for Common Suite Setup

Suite Teardown
    Common Gathering Logs for Common Suite Teardown
    Run keyword and ignore error   Collect and send logs for scrambling verification   team_name=PZ3WRO4
    ...                            input_logs_dir=${NONE}

Test Setup
    Common Gathering Logs for Test Setup

Test Teardown
    Common Gathering Logs for Test Teardown
