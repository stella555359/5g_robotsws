*** Settings ***
Resource    ../test_resources/FM__Problem_sending_VES_event_to_ONAP_VES_Endpoint.robot

*** Test Cases ***
TC__FM__Problem_sending_VES_event_to_ONAP_VES_Endpoint
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    FM__Problem_sending_VES_event_to_ONAP_VES_Endpoint
