*** Settings ***
Documentation  This suite contains CIT__RF_sharing_with_radio_reset TC

Resource  ../test_resources/CIT__RF_sharing_with_radio_reset.robot


*** Test Cases ***
CIT__RF_sharing_with_radio_reset
    [Setup]  TC Setup
    TC__CIT__RF_sharing_with_radio_reset
    [Teardown]  TC Teardown
