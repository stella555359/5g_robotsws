*** Settings ***
Documentation    Suite for parity feature CB010546_CB007426_CB008154 on ABIQ and ASIM.

Resource    ../features/Security_UUF/TestCases/TestCases.robot
Resource    ../common_resources/UUF/upgrade.robot

Resource    ../common_resources/gathering_logs/gathering_logs.robot
Resource    ../common_resources/variables/variables.robot

Suite Setup       Suite Setup
Suite Teardown    Suite Teardown

*** Test Cases ***
[1]Security_UUF_Certificates
    [Tags]
    Upgrade_with_Certificates

[2]Security_UUF_Nmap
    [Tags]
    Upgrade_with_Nmap

[1]Upgrade_and_Rollback_N_With_Security
    [Tags]
    Upgrade_with_Security

[1]Upgrade_and_Rollback_N-1_With_Security
    [Tags]
    Upgrade_with_Security

[1]Upgrade_and_Rollback_N-2_With_Security
    [Tags]
    Upgrade_with_Security

[1]Upgrade_and_Rollback_N-3_With_Security
    [Tags]
    Upgrade_with_Security

*** Keywords ***
Suite Setup
    Common Gathering Logs for Common Suite Setup
    Run Keyword And Ignore Error    Wait until BTS reach Configured or OnAir state

Suite Teardown
    Common Gathering Logs for Common Suite Teardown
