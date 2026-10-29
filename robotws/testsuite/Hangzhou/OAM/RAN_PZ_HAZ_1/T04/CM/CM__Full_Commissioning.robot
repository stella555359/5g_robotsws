*** Settings ***
Documentation       Test suite for SyVe_CM
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Variables         ../test_line_specific/SBTS_SYVE_1816/My_Variables.py
Resource          ../test_resources/CM/CM__Full_Commissioning.robot

*** Test Cases ***
CM__Full_Commissioning
    [Setup]    Common Test Setup SBTS    scf_check=${FALSE}
    CM__Full_Commissioning
    [Teardown]    Common Test Teardown SBTS
