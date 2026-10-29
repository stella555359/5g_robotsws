*** Settings ***
Documentation  This suite contains WebEM__vDU__CW_Step_by_Step_view_Adding_NR_cell_group TC

Resource  ../test_resources/WebEM__vDU__CW_Step_by_Step_view_Adding_NR_cell_group.robot


*** Test Cases ***
WebEM__vDU__CW_Step_by_Step_view_Adding_NR_cell_group
    [Setup]  TC Setup
    TC__WebEM__vDU__CW_Step_by_Step_view_Adding_NR_cell_group
    [Teardown]  TC Teardown
