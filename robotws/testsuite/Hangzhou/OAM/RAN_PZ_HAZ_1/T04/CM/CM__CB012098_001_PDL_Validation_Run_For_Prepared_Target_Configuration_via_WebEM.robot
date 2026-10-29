*** Settings ***
Documentation       Test suite for SyVe_CM
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Variables         ../test_line_specific/SBTS_SYVE_1905/My_Variables.py
Resource          ../test_resources/CM/CM__CB012098_001_PDL_Validation_Run_For_Prepared_Target_Configuration_via_WebEM.robot

*** Test Cases ***
CM__CB012098_001_PDL_Validation_Run_For_Prepared_Target_Configuration_via_WebEM
    [Setup]    SetUp
    [Teardown]    CaseTearDown
    CM__CB012098_001_PDL_Validation_Run_For_Prepared_Target_Configuration_via_WebEM