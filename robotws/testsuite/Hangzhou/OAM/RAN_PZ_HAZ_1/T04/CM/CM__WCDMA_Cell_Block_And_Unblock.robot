*** Settings ***
Documentation       Test suite for SyVe_CM
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Variables         ../test_line_specific/SBTS_SYVE_1894/My_Variables.py
Resource          ../test_resources/CM/CM__WCDMA_Cell_Block_And_Unblock.robot

*** Test Cases ***
CM__WCDMA_Cell_Block_And_Unblock
    [Setup]    Set Up
    CM__WCDMA_Cell_Block_And_Unblock
    [Teardown]    Tear Down
