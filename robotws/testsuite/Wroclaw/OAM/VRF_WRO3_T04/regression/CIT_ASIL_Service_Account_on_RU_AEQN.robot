*** Settings ***
Documentation   Suite for cOAM CRT regression

Resource        ../features/CB006017/TestCases/6017_TestCases.robot
Resource        ../common_resources/gathering_logs/gathering_logs.robot
Resource        ../common_resources/variables/variables.robot

Suite Setup     Suite Setup
Suite Teardown  Suite Teardown

Test Setup      Test Setup
Test Teardown   Test Teardown

*** Test Cases ***
[1]CB006017-5G-A-AEQN2_14_SSH_Login_parameters_Synchronization
	[Tags]          #RESPONSIBLE_TESTER=shamilov
	...     [1]CB006017-5G-A-AEQN2_14_SSH_Login_parameters_Synchronization
    CB006017-5G-A_14_SSH_Login_parameters_Synchronization

*** Keywords ***
Suite Setup
    Common Gathering Logs for Common Suite Setup
    CB006017 Setup
    Run Keyword And Ignore Error    Wait until BTS reach Configured or OnAir state

Suite Teardown
    Common Gathering Logs for Common Suite Teardown

Test Setup
    Common Gathering Logs for Test Setup

Test Teardown
    Common Gathering Logs for Test Teardown
