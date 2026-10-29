*** Settings ***
Documentation       Test suite for SyVe_CM
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Variables         ../test_line_specific/SBTS_SYVE_1813/My_Variables.py
Resource          ../test_resources/CM/CM__CB005868_RP002695_SSH_Configuration_Update_via_WebEM.robot

*** Test Cases ***
CM__CB005868_RP002695_SSH_Configuration_Update_via_WebEM
    [Setup]    CaseSetUp
	Log    CM__SSH_Configuration_Update_via_WebEM_CB005868_RP002695
    CM__CB005868_RP002695_SSH_Configuration_Update_via_WebEM
    [Teardown]    CaseTearDown