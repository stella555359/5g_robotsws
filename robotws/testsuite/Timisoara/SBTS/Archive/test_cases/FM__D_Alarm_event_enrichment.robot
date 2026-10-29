*** Settings ***
Resource    ../test_resources/FM__D_Alarm_event_enrichment.robot

*** Test Cases ***
FM__D_Alarm_event_enrichment
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__FM__D_Alarm_event_enrichment
