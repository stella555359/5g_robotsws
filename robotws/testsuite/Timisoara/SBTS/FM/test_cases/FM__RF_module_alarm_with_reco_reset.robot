*** Settings ***
Documentation  This suite contains FM__RF_module_alarm_with_reco_reset TC

Resource  ../test_resources/FM__RF_module_alarm_with_reco_reset.robot


*** Test Cases ***
FM__RF_module_alarm_with_reco_reset
    [Setup]  TC Setup
    TC__FM__RF_module_alarm_with_reco_reset
    [Teardown]  TC Teardown
