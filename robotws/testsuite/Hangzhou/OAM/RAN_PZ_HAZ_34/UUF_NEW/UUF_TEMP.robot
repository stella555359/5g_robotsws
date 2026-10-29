*** Settings ***
Documentation
    ...    Author: yin.4.chen@nokia-sbell.com

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

Suite Setup    Common Suite Setup

*** Test Cases ***
UUF Template Case
    [Setup]    Common Test Setup
    Log To Console   UUF Template Case
    [Teardown]    Common Test teardown


*** Keywords ***
Common Suite Setup
    robot_common_operations.Common Suite Setup
    CI_interface.Common Suite Setup
    Log To Console   Common Suite Setup

Common Test Setup
    robot_common_operations.Common Case Setup
    Log To Console   Common Test Setup

Common Test teardown
    robot_common_operations.Common Case Teardown
    Log To Console   Common Test teardown
    CI_interface.Common Case Teardown

