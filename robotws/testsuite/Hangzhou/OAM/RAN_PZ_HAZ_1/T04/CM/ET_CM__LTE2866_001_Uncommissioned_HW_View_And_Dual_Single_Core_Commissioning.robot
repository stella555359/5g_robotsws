*** Settings ***
Documentation       Test suite for SyVe_CM
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Variables         ../test_line_specific/SBTS_SYVE_1894/My_Variables.py
Resource          ../test_resources/CM/ET_CM__LTE2866_001_Uncommissioned_HW_View_And_Dual_Single_Core_Commissioning.robot

*** Test Cases ***
ET_CM__LTE2866_001_Uncommissioned_HW_View_And_Dual_Single_Core_Commissioning
    [Setup]    CaseSetUp
    ET_CM__LTE2866_001_Uncommissioned_HW_View_And_Dual_Single_Core_Commissioning
    [Teardown]    CaseTearDown
