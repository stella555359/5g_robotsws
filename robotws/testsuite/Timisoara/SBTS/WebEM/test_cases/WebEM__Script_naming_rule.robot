*** Settings ***
Documentation  This suite contains WebEM__Script_naming_rule TC

Resource  ../test_resources/WebEM__Script_naming_rule.robot


*** Test Cases ***
WebEM__Script_naming_rule
    [Setup]  TC Setup
    TC__WebEM__Script_naming_rule
    [Teardown]  TC Teardown
