*** Settings ***
Documentation  This suite contains PANO__5GC001104_Break_connection_to_ONAP_and_toggle_counters_format TC

Resource  ../test_resources/PANO__5GC001104_Break_connection_to_ONAP_and_toggle_counters_format.robot

*** Test Cases ***
PANO__5GC001104_Break_connection_to_ONAP_and_toggle_counters_format
    [Setup]  TC Setup
    [Teardown]  TC Teardown
    TC__PANO__5GC001104_Break_connection_to_ONAP_and_toggle_counters_format
