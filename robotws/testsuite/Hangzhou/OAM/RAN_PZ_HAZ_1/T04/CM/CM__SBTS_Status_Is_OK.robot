*** Settings ***
Documentation       Test suite for SyVe_CM
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Variables    ../test_line_specific/SBTS_SYVE_1813/My_Variables.py
Resource    ../test_resources/CM/CM__SBTS_Status_Is_OK.robot

*** Test Cases ***
CM__SBTS_Status_Is_OK
    CM__SBTS_Status_Is_OK
    [Teardown]    Tear Down
