*** Settings ***
Resource    ../test_resources/WebEM__Baseband_module_lock_unlock.robot

*** Test Cases ***
WebEM__Baseband_module_lock_unlock
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__WebEM__Baseband_module_lock_unlock
