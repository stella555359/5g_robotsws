*** Settings ***
Documentation       Test suite for SyVe_CM
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Variables         ../test_line_specific/SBTS_SYVE_1813/My_Variables.py
Resource          ../test_resources/CM/CM__Activate_Service_Account_And_platLoginBannerText_Synchronize_To_RM_Via_WebEM.robot

*** Test Cases ***
CM__Activate_Service_Account_And_platLoginBannerText_Synchronize_To_RM_Via_WebEM
    [Setup]    SetUp
    CM__Activate_Service_Account_And_platLoginBannerText_Synchronize_To_RM_Via_WebEM
    [Teardown]    TearDown