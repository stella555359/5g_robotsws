*** Settings ***
Documentation       Test suite for CM__Repeat_Recommission_With_All_LTE_And_NR_Cells_Locking_via_AdminAPI
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Variables         ../test_line_specific/SBTS_SYVE_1905/My_Variables.py
Resource          ../test_resources/CM/CM__Repeat_Recommission_With_All_LTE_And_NR_Cells_Locking_via_AdminAPI.robot

*** Test Cases ***
CM__Repeat_Recommission_With_All_LTE_And_NR_Cells_Locking_via_AdminAPI
    [Setup]    Common Test Setup SBTS    scf_check=${FALSE}
    CM__Repeat_Recommission_With_All_LTE_And_NR_Cells_Locking_via_AdminAPI
    [Teardown]    Common Test Teardown SBTS