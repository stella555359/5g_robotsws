*** Settings ***
Documentation       Test suite for SyVe_CM
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Variables         ../test_line_specific/SBTS_SYVE_1813/My_Variables.py
Resource          ../test_resources/CM/CM__CB005868_RP002696_Feature_Activation_And_Deactivation_For_FHS_via_WebEM.robot

*** Test Cases ***
CM__CB008824_003_Do_Controlled_Switchover
    [Setup]    CaseSetUp
    CM__CB005868_RP002696_Feature_Activation_And_Deactivation_For_FHS_via_WebEM
    [Teardown]     CaseTearDown