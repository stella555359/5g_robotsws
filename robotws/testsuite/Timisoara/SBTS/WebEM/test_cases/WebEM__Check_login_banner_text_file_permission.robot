*** Settings ***
Documentation  This suite contains WebEM__Check_login_banner_text_file_permission TC

Resource  ../test_resources/WebEM__Check_login_banner_text_file_permission.robot


*** Test Cases ***
WebEM__Check_login_banner_text_file_permission
    [Setup]  TC Setup
    TC__WebEM__Check_login_banner_text_file_permission
    [Teardown]  TC Teardown
