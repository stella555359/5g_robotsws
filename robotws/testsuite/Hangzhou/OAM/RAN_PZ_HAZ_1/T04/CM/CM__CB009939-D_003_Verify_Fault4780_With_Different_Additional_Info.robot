*** Settings ***
Documentation       Test suite for SyVe_CM
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Variables         ../test_line_specific/SBTS_SYVE_1905/My_Variables.py
Resource          ../test_resources/CM/CM__CB009939-D_003_Verify_Fault4780_With_Different_Additional_Info.robot

*** Test Cases ***
CM__CB009939-D_003_Verify_Fault4780_With_Different_Additional_Info
    [Setup]    Common Test Setup SBTS    scf_check=${FALSE}
    CM__CB009939-D_003_Verify_Fault4780_With_Different_Additional_Info
    [Teardown]    Case Special Teardown
