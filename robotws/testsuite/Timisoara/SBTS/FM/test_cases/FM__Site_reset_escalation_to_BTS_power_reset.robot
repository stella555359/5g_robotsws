*** Settings ***
Documentation  This suite contains FM__Site_reset_escalation_to_BTS_power_reset TC

Resource  ../test_resources/FM__Site_reset_escalation_to_BTS_power_reset.robot


*** Test Cases ***
FM__Site_reset_escalation_to_BTS_power_reset
    [Setup]  TC Setup
    TC__FM__Site_reset_escalation_to_BTS_power_reset
    [Teardown]  TC Teardown
