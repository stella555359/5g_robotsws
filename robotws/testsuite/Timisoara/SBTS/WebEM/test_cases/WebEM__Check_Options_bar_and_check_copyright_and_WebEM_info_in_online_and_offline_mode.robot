*** Settings ***
Documentation  This suite contains WebEM__Check_Options_bar_and_check_copyright_and_WebEM_info_in_online_and_offline_mode TC

Resource  ../test_resources/WebEM__Check_Options_bar_and_check_copyright_and_WebEM_info_in_online_and_offline_mode.robot


*** Test Cases ***
WebEM__Check_Options_bar_and_check_copyright_and_WebEM_info_in_online_and_offline_mode
    [Setup]  TC Setup
    TC__WebEM__Check_Options_bar_and_check_copyright_and_WebEM_info_in_online_and_offline_mode
    [Teardown]  TC Teardown
