*** Settings ***
Documentation  This suite contains WebEM__UAM_Update_alias_and_password_for_local_users TC

Resource  ../test_resources/WebEM__UAM_Update_alias_and_password_for_local_users.robot


*** Test Cases ***
WebEM__UAM_Update_alias_and_password_for_local_users
    [Setup]  TC Setup
    TC__WebEM__UAM_Update_alias_and_password_for_local_users
    [Teardown]  TC Teardown
