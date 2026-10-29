*** Settings ***
Documentation  This suite contains STATE__Site_power_reset TC

Resource  ../test_resources/STATE__Site_power_reset.robot


*** Test Cases ***
STATE__Site_power_reset
    [Setup]  TC Setup
    TC__STATE__Site_power_reset
    [Teardown]  TC Teardown
