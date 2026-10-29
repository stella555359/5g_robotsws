*** Settings ***
Documentation  This suite contains WebEM__User_rights_downgrade TC

Resource  ../test_resources/WebEM__User_rights_downgrade.robot


*** Test Cases ***
WebEM__User_rights_downgrade
    [Setup]  TC Setup
    TC__WebEM__User_rights_downgrade
    [Teardown]  TC Teardown
