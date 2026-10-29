*** Settings ***
Documentation       Test suite for CM__Repeat_Recommission_With_One_Set_Different_Impact_Parameter_via_AdminAPI
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Variables         ../test_line_specific/SBTS_SYVE_37376/My_Variables.py
Resource          ../test_resources/CM/CM__Repeat_Recommission_With_One_Set_Different_Impact_Parameter_via_AdminAPI.robot

*** Test Cases ***
CM__Repeat_Recommission_With_One_Set_Different_Impact_Parameter_via_AdminAPI
    [Setup]    Common Test Setup SBTS    scf_check=${FALSE}
    CM__Repeat_Recommission_With_One_Set_Different_Impact_Parameter_via_AdminAPI
    [Teardown]    Common Test Teardown SBTS