*** Settings ***
Documentation  This suite contains FM__link_break_IuB_DNBAP_short TC

Resource  ../test_resources/FM__link_break_IuB_DNBAP_short.robot


*** Test Cases ***
FM__link_break_IuB_DNBAP_short
    [Setup]  TC Setup
    TC__FM__link_break_IuB_DNBAP_short
    [Teardown]  TC Teardown
