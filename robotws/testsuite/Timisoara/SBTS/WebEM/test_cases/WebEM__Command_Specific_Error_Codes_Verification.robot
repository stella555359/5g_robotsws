*** Settings ***
Documentation  This suite contains WebEM__Command_Specific_Error_Codes_Verification TC

Resource  ../test_resources/WebEM__Command_Specific_Error_Codes_Verification.robot


*** Test Cases ***
WebEM__Command_Specific_Error_Codes_Verification
    [Setup]  TC Setup
    TC__WebEM__Command_Specific_Error_Codes_Verification
    [Teardown]  TC Teardown
