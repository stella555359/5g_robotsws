*** Settings ***
Documentation  This suite contains FM__Robustness_trigger_different_faults_RMOD TC

Resource  ../test_resources/FM__Robustness_trigger_different_faults_RMOD.robot


*** Test Cases ***
FM__Robustness_trigger_different_faults_RMOD
    [Setup]  TC Setup
    TC__FM__Robustness_trigger_different_faults_RMOD
    [Teardown]  TC Teardown
