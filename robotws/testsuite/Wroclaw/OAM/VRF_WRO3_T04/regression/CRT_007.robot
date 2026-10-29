*** Settings ***
Documentation       Suite for feature CB008254 on ASOF.
...
...                 author:     Jagoda Kubacka
...                 contact:    jagoda.kubacka@nokia.com

Resource            ../features/CB008254/TestCases/CB008254.robot
Resource            ../common_resources/gathering_logs/gathering_logs.robot
Resource            ../common_resources/variables/variables.robot

Suite Setup         Suite Setup
Suite Teardown      Suite Teardown

Test Setup          Test Setup
Test Teardown       Test Teardown

*** Test Cases ***
[1]CB009799_CB008254_Differentiator_for_RSA_and_ECDSA_operations_error_code_ASOF
    CB008254_Differentiator_for_RSA_and_ECDSA_operations_error_code

[1]CB010265_CB008254_BTS_as_Server_use_RSA_certificate_for_TLS_when_NMS_has_ECDSA_certificate
    CB008254_BTS_as_Server_use_RSA_certificate_for_TLS_when_NMS_has_ECDSA_certificate

*** Keywords ***
Suite Setup
    Common Gathering Logs for Common Suite Setup
    Set CMP Server Settings         key_pool_type=ECDSA
    Set CMP Server Settings         key_pool_type=RSA

Suite Teardown
    Common Gathering Logs for Common Suite Teardown
    Run keyword and ignore error    Collect and send logs for scrambling verification   team_name=PZ3WRO4
    ...                             input_logs_dir=${NONE}

Test Setup
    Common Gathering Logs for Test Setup

Test Teardown
    Common Gathering Logs for Test Teardown
