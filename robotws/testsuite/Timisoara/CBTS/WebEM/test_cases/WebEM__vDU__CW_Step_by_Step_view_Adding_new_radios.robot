*** Settings ***
Documentation  This suite contains WebEM__vDU__CW_Step_by_Step_view_Adding_new_radios TC

Resource  ../test_resources/WebEM__vDU__CW_Step_by_Step_view_Adding_new_radios.robot


*** Test Cases ***
WebEM__vDU__CW_Step_by_Step_view_Adding_new_radios
    [Setup]  TC Setup
    TC__WebEM__vDU__CW_Step_by_Step_view_Adding_new_radios
    [Teardown]  TC Teardown
