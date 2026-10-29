*** Settings ***
Documentation  This suite contains STATE__Site_reset TC

Resource  ../test_resources/STATE__Site_reset.robot


*** Test Cases ***
STATE__Site_reset
    [Setup]  TC Setup
    TC__STATE__Site_reset
    [Teardown]  TC Teardown
