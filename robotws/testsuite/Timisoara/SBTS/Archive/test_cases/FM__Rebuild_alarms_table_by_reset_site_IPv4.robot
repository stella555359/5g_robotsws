*** Settings ***
Resource    ../test_resources/FM__Rebuild_alarms_table_by_reset_site_IPv4.robot

*** Test Cases ***
TC__Rebuild_alarms_table_by_reset_site_IPv4
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    FM__Rebuild_alarms_table_by_reset_site_IPv4
