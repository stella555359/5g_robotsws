*** Settings ***
Documentation  This suite contains WebEM__CP_Number_of_concurrent_WebEM_Remote_Tool_user_sessions_in_a_SBTS TC

Resource  ../test_resources/WebEM__CP_Number_of_concurrent_WebEM_Remote_Tool_user_sessions_in_a_SBTS.robot


*** Test Cases ***
WebEM__CP_Number_of_concurrent_WebEM_Remote_Tool_user_sessions_in_a_SBTS
    [Setup]  TC Setup
    TC__WebEM__CP_Number_of_concurrent_WebEM_Remote_Tool_user_sessions_in_a_SBTS
    [Teardown]  TC Teardown
