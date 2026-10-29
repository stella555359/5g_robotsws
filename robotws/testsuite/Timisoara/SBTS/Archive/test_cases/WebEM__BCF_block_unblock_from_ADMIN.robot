*** Settings ***
Resource    ../test_resources/WebEM__BCF_block_unblock_from_ADMIN.robot

*** Test Cases ***
WebEM__BCF_block_unblock_from_ADMIN
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__WebEM__BCF_block_unblock_from_ADMIN
