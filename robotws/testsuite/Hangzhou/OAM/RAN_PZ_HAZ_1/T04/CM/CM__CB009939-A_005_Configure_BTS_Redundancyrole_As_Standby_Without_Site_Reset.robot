*** Settings ***
Documentation       Test suite for SyVe_CM
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Variables         ../test_line_specific/SBTS_SYVE_1905/My_Variables.py
Resource          ../test_resources/CM/CM__CB009939-A_005_Configure_BTS_Redundancyrole_As_Standby_Without_Site_Reset.robot

*** Test Cases ***
CM__CB009939-A_005_Configure_BTS_Redundancyrole_As_Standby_Without_Site_Reset
    [Setup]    Common Test Setup SBTS    scf_check=${FALSE}
    CM__CB009939-A_005_Configure_BTS_Redundancyrole_As_Standby_Without_Site_Reset
    [Teardown]    Case Special Teardown
