*** Settings ***
Resource    ../test_resources/WebEM__BTS_Block_Unblock.robot

*** Test Cases ***
WebEM__BTS_Block_Unblock
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__WebEM__BTS_Block_Unblock

