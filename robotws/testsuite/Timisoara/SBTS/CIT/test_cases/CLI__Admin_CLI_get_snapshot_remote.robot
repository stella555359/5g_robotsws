*** Settings ***
Documentation  This suite contains CLI__Admin_CLI_get_snapshot_remote TC

Resource  ../test_resources/CLI__Admin_CLI_get_snapshot_remote.robot


*** Test Cases ***
CLI__Admin_CLI_get_snapshot_remote
    [Setup]  TC Setup
    TC__CLI__Admin_CLI_get_snapshot_remote
    [Teardown]  TC Teardown
