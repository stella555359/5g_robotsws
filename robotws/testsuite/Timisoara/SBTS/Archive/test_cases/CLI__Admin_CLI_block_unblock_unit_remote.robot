*** Settings ***
Resource    ../test_resources/CLI__Admin_CLI_block_unblock_unit_remote.robot

*** Test Cases ***
CLI__Admin_CLI_block_unblock_unit_remote
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__CLI__Admin_CLI_block_unblock_unit_remote

