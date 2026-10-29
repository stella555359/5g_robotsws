*** Settings ***
Documentation       Test suite for SyVe_CM
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Variables         ../test_line_specific/SBTS_SYVE_1813/My_Variables.py
Resource          ../test_resources/CM/CM__CB006758_004_TLS_Cipher_Selection.robot

*** Test Cases ***
CM__CB006758_004_TLS_Cipher_Selection
    [Setup]    Common Test Setup SBTS    scf_check=${FALSE}
    CM__CB006758_004_TLS_Cipher_Selection
    [Teardown]     Common Test Teardown SBTS