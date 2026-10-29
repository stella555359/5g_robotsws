*** Settings ***
Documentation       Test suite for SyVe_CM
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Variables    ../test_line_specific/SBTS_SYVE_1813/My_Variables.py
Resource    ../test_resources/CM/CM__Lock_and_Unlock_One_RF.robot

*** Test Cases ***
CM__Lock_and_Unlock_One_RF
    [Setup]    Set Up
    CM__Lock_and_Unlock_One_RF
    [Teardown]    Tear Down
