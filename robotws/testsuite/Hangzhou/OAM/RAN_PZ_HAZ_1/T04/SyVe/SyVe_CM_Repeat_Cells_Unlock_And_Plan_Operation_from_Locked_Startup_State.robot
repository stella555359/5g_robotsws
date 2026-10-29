*** Settings ***
Documentation       Test suite for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.com
Test Timeout    75h
Variables     ../test_line_specific/SBTS_SYVE_1813/My_Variables.py
Variables     ../test_line_specific/Variables/NetActs.py
Resource      ../test_resources/SyVe/SyVe_CM_Repeat_Cells_Unlock_And_Plan_Operation_from_Locked_Startup_State.robot

*** Test Cases ***
SyVe_CM_Repeat_Cells_Unlock_And_Plan_Operation_from_Locked_Startup_State
    [Setup]    TC Setup
    SyVe_CM_Repeat_Cells_Unlock_And_Plan_Operation_from_Locked_Startup_State
    [Teardown]    TC Teardown
