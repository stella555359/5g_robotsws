*** Settings ***
Documentation       Test suite for SyVe_CM
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Variables         ../test_line_specific/SBTS_SYVE_1905/My_Variables.py
Resource          ../test_resources/CM/CM__CB009939-A_004_Configure_BTS_redundancyrole_as_standby_with_site_reset.robot

*** Test Cases ***
CM__CB009939-A_004_Configure_BTS_redundancyrole_as_standby_with_site_reset
    [Setup]    Common Test Setup SBTS    scf_check=${FALSE}
    CM__CB009939-A_004_Configure_BTS_redundancyrole_as_standby_with_site_reset
    [Teardown]    Case Special Teardown
