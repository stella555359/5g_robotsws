*** Settings ***
Documentation       Test suite for SyVe_CM
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Test Timeout    75h
Variables     ../test_line_specific/SBTS_SYVE_1813/My_Variables.py
Resource    ../test_resources/CM/CM__NCDR_Recommissioning_With_Site_Reset_When_Some_BBMOD_Is_Uncommission.robot

*** Test Cases ***
CM__NCDR_Recommissioning_With_Site_Reset_When_Some_BBMOD_Is_Uncommission
    [Setup]    TC Setup
    [Timeout]    72h
    [Teardown]    TC Teardown
    CM__NCDR_Recommissioning_With_Site_Reset_When_Some_BBMOD_Is_Uncommission


