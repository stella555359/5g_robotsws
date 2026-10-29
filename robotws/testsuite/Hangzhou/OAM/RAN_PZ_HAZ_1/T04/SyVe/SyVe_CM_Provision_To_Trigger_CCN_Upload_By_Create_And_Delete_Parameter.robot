*** Settings ***
Documentation       Test suite for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia-sbell.com
Test Timeout    75h
Variables       ../test_line_specific/SBTS_SYVE_1813/My_Variables.py
Variables       ../test_line_specific/Variables/NetActs.py
Resource        ../test_resources/SyVe/SyVe_CM_Provision_To_Trigger_CCN_Upload_By_Create_And_Delete_Parameter.robot

*** Test Cases ***
SyVe_CM_Provision_To_Trigger_CCN_Upload_By_Create_And_Delete_Parameter
    [Setup]    TC Setup
    [Timeout]    72h
    TC__SyVe_CM_Provision_To_Trigger_CCN_Upload_By_Create_And_Delete_Parameter
    [Teardown]    TC Teardown
