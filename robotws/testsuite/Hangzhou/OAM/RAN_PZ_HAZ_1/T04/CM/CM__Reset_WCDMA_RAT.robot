*** Settings ***
Documentation       Test suite for SyVe_CM
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Variables         ../test_line_specific/SBTS_SYVE_1894/My_Variables.py
Resource          ../test_resources/CM/CM__Reset_WCDMA_RAT.robot

*** Test Cases ***
CM__Reset_WCDMA_RAT
    [Setup]    Set Up
    CM__Reset_WCDMA_RAT
    [Teardown]    Tear Down
