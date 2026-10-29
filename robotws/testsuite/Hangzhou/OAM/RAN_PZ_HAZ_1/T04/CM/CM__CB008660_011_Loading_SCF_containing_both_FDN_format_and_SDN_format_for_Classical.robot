*** Settings ***
Documentation       Test suite for SyVe_CM
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Variables         ../test_line_specific/SBTS_SYVE_1905/My_Variables.py
Resource          ../test_resources/CM/CM__CB008660_011_Loading_SCF_containing_both_FDN_format_and_SDN_format_for_Classical.robot

*** Test Cases ***
CM__CB008660_011_Loading_SCF_containing_both_FDN_format_and_SDN_format_for_Classical
    [Setup]    SetUp
    CM__CB008660_011_Loading_SCF_containing_both_FDN_format_and_SDN_format_for_Classical
    [Teardown]    CaseTearDown


