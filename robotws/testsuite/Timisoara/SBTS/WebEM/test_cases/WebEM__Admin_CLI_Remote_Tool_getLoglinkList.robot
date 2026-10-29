*** Settings ***
Documentation  This suite contains WebEM__Admin_CLI_Remote_Tool_getLoglinkList TC

Resource  ../test_resources/WebEM__Admin_CLI_Remote_Tool_getLoglinkList.robot


*** Test Cases ***
WebEM__Admin_CLI_Remote_Tool_getLoglinkList
    [Setup]  TC Setup
    TC__WebEM__Admin_CLI_Remote_Tool_getLoglinkList
    [Teardown]  TC Teardown
