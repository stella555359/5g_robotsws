*** Settings ***
Resource    ../test_resources/FM__Dictionary_compatibility_with_received_FM_event_by_ONAP_ASIL.robot

*** Test Cases ***
TC__FM__Dictionary_compatibility_with_received_FM_event_by_ONAP_ASIL
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    FM__Dictionary_compatibility_with_received_FM_event_by_ONAP_ASIL
