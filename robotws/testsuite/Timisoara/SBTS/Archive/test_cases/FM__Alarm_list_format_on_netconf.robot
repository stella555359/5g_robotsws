*** Settings ***
Resource    ../test_resources/FM__Alarm_list_format_on_netconf.robot

*** Test Cases ***
TC__FM__Alarm_list_format_on_netconf
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    FM__Alarm_list_format_on_netconf
