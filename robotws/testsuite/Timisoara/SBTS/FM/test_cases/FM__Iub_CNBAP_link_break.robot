*** Settings ***
Documentation  This suite contains FM__Iub_CNBAP_link_break TC

Resource  ../test_resources/FM__Iub_CNBAP_link_break.robot


*** Test Cases ***
FM__Iub_CNBAP_link_break
    [Setup]  TC Setup
    TC__FM__Iub_CNBAP_link_break
    [Teardown]  TC Teardown
