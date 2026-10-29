*** Settings ***
Documentation  This suite contains FM__Suppression_of_toggling_transport_alarms TC

Resource  ../test_resources/FM__Suppression_of_toggling_transport_alarms.robot


*** Test Cases ***
FM__Suppression_of_toggling_transport_alarms
    [Setup]  TC Setup
    TC__FM__Suppression_of_toggling_transport_alarms
    [Teardown]  TC Teardown
