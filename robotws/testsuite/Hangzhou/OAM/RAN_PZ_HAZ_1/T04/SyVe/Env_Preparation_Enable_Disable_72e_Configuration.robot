*** Settings ***
Documentation       Test suite for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.com
Test Timeout    5h
Variables     ../test_line_specific/SBTS_SYVE_1813/My_Variables.py
Variables     ../test_line_specific/Variables/NetActs.py
Resource      ../test_resources/SyVe/Env_Preparation_Enable_Disable_72e_Configuration.robot

*** Test Cases ***
Env_Preparation_Enable_Disable_72e_Configuration
    [Setup]    TC Setup
    [Timeout]    2h
    Env_Preparation_Enable_Disable_72e_Configuration
    [Teardown]    TC TearDown
