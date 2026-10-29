*** Settings ***
Documentation       Test suite for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.com
Test Timeout    75h
Variables     ../test_line_specific/SBTS_SYVE_1813/My_Variables.py
Variables     ../test_line_specific/Variables/NetActs.py
Resource      ../test_resources/SyVe/SyVe_CM_CB005891_005_Action_Provision_Request_Message_Verify_From_Wireshark.robot

*** Test Cases ***
SyVe_CM_CB005891_005_Action_Provision_Request_Message_Verify_From_Wireshark
    [Setup]    TC Setup
    [Timeout]    72h
    SyVe_CM_CB005891_005_Action_Provision_Request_Message_Verify_From_Wireshark
    [Teardown]    TC Teardown
