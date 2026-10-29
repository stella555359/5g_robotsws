*** Settings ***
Resource    ../test_resources/WebEM__RF_Module_lock_unlock.robot

*** Test Cases ***
WebEM__RF_Module_lock_unlock
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__WebEM__RF_Module_lock_unlock
