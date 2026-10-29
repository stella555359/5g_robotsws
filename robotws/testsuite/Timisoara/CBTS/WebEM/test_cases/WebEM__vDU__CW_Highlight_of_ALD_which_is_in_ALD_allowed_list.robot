*** Settings ***
Documentation  This suite contains WebEM__vDU__CW_Highlight_of_ALD_which_is_in_ALD_allowed_list TC

Resource  ../test_resources/WebEM__vDU__CW_Highlight_of_ALD_which_is_in_ALD_allowed_list.robot


*** Test Cases ***
WebEM__vDU__CW_Highlight_of_ALD_which_is_in_ALD_allowed_list
    [Setup]  TC Setup
    TC__WebEM__vDU__CW_Highlight_of_ALD_which_is_in_ALD_allowed_list
    [Teardown]  TC Teardown
