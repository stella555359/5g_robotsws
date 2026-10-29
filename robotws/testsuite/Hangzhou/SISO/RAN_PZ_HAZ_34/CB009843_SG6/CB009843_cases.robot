*** Settings ***
Documentation    CA Feature CB009843 Automation.
...              Author: jun.8.chen@nokia-sbell.com
Suite Setup    Suite_Setup
Test Teardown    Case_Teardown
Suite Teardown    robot_common_operations.Common Suite Teardown
Resource    Resources/CB009843_common_keywords.robot


*** Test Cases ***
[1][1.0] General_SiSo_Auto_Cell_lock_and_unlock_with_L3call
    [Timeout]    240m
    [Setup]    Case_Setup
    General_SiSo_Auto_Cell_lock_and_unlock_with_L3call

[1][4.0] General_SiSo_Online_Cell_Addition_Deletion
    [Timeout]    240m
    [Setup]    Case_Setup
    General_SiSo_Online_Cell_Addition_Deletion
