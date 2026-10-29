*** Settings ***
Documentation  This suite contains WebEM__vDU__Switching_from_CW_to_another_tab_and_come_back TC

Resource  ../test_resources/WebEM__vDU__Switching_from_CW_to_another_tab_and_come_back.robot


*** Test Cases ***
WebEM__vDU__Switching_from_CW_to_another_tab_and_come_back
    [Setup]  TC Setup
    TC__WebEM__vDU__Switching_from_CW_to_another_tab_and_come_back
    [Teardown]  TC Teardown
