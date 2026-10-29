*** Settings ***
Documentation       Test suite for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.com
Test Timeout    3h
Variables     ../test_line_specific/SBTS_SYVE_1813/My_Variables.py
Variables     ../test_line_specific/Variables/NetActs.py
Resource      ../test_resources/SyVe/SyVe_CM_CB008708_001_Verify_NE3S_Feedback_when_Recovery_Reset_is_Executed_via_NMS_Action_Provision.robot

*** Test Cases ***
SyVe_CM_CB008708_001_Verify_NE3S_Feedback_when_Recovery_Reset_is_Executed_via_NMS_Action_Provision
    [Setup]    TC Setup
    [Timeout]    3h
    SyVe_CM_CB008708_001_Verify_NE3S_Feedback_when_Recovery_Reset_is_Executed_via_NMS_Action_Provision
    [Teardown]    TC Teardown
