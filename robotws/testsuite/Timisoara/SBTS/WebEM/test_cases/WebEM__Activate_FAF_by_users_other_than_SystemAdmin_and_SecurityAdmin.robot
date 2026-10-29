*** Settings ***
Documentation  This suite contains WebEM__Activate_FAF_by_users_other_than_SystemAdmin_and_SecurityAdmin TC

Resource  ../test_resources/WebEM__Activate_FAF_by_users_other_than_SystemAdmin_and_SecurityAdmin.robot


*** Test Cases ***
WebEM__Activate_FAF_by_users_other_than_SystemAdmin_and_SecurityAdmin
    [Setup]  TC Setup
    TC__WebEM__Activate_FAF_by_users_other_than_SystemAdmin_and_SecurityAdmin
    [Teardown]  TC Teardown

