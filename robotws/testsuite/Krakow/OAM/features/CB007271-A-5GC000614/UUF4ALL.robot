*** Settings ***
Documentation
...   Test suite for UUF tests in regression
...   author: Karol Lapczyk [karol.lapczyk@nokia.com]
...   maintainer: Marek Bodziony [marek.bodziony@nokia.com]

Resource     taf/rfrl/uuf4all/uuf4all_test_cases.robot
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Force Tags        CRT

Test Setup        common_setups_and_teardowns.Common Preconditions
Test Teardown     common_setups_and_teardowns.Common Postconditions

*** Variables ***
${SHOULD_BE_REPORTED}=  False
@{critical_faults}       10
${runs_of_uuf_upgrade}    ${3}
${runs_of_uuf_resets}    ${10}
${5G_SOURCE_SW}=    SBTS23R3_ENB_0000_000373_000000
${5G_TARGET_SW}=    SBTS00_ENB_9999_230703_000008

*** Test Cases ***
UUF4ALL_SITE_RESET_TEST
    UUF4ALL_SITE_RESET_TEST
    ...     test_iteration=${runs_of_uuf_resets}
    ...     should_be_reported=${SHOULD_BE_REPORTED}

UUF4ALL_UPGRADE
    UUF4ALL_SW_UPGRADE_TEST
    ...    test_iteration=${runs_of_uuf_upgrade}
    ...    should_be_reported=${SHOULD_BE_REPORTED}
    ...    5g_source_sw=${5G_SOURCE_SW}
    ...    5g_target_sw=${5G_TARGET_SW}
    ...    use_builds_storage=${False}
    ...    restore_to_target_sw=${True}
