*** Settings ***
Documentation  This suite contains BS-SM__GSM_RAT_reset_from_ADMIN TC

Resource  ../test_resources/BS-SM__GSM_RAT_reset_from_ADMIN.robot


*** Test Cases ***
BS-SM__GSM_RAT_reset_from_ADMIN
    [Setup]  TC Setup
    TC__BS-SM__GSM_RAT_reset_from_ADMIN
    [Teardown]  TC Teardown
