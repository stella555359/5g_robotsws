*** Settings ***
Resource    ../test_resources/FM__Enriching_alarm_content_sent_to_ONAP_ASIL.robot

*** Test Cases ***
TC__FM__Enriching_alarm_content_sent_to_ONAP_ASIL
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    FM__Enriching_alarm_content_sent_to_ONAP_ASIL
