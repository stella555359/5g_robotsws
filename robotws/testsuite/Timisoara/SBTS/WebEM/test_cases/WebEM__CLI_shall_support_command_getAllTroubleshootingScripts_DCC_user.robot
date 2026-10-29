*** Settings ***
Documentation  This suite contains WebEM__CLI_shall_support_command_getAllTroubleshootingScripts_DCC_user TC

Resource  ../test_resources/WebEM__CLI_shall_support_command_getAllTroubleshootingScripts_DCC_user.robot


*** Test Cases ***
WebEM__CLI_shall_support_command_getAllTroubleshootingScripts_DCC_user
    [Setup]  TC Setup
    TC__WebEM__CLI_shall_support_command_getAllTroubleshootingScripts_DCC_user
    [Teardown]  TC Teardown
