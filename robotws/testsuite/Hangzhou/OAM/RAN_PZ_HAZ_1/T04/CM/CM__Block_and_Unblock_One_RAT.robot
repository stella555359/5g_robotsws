*** Settings ***
Documentation       Test suite for SyVe_CM
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Variables    ../test_line_specific/SBTS_SYVE_1813/My_Variables.py
Resource    ../test_resources/CM/CM__Block_and_Unblock_One_RAT.robot

*** Test Cases ***
CM__Block_and_Unblock_One_RAT
    [Setup]    Set Up
    Step 1: Block One RAT
    Step 2: Unblock One RAT
    [Teardown]    Tear Down
