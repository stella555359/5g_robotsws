*** Settings ***
Resource    ../test_resources/WebEM__Remote_Tool_checkPower_Linux_remote.robot

*** Test Cases ***
WebEM__Remote_Tool_checkPower_Linux_remote
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__WebEM__Remote_Tool_checkPower_Linux_remote
