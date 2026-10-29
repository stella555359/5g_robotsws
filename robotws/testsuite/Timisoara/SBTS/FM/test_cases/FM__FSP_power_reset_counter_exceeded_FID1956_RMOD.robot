*** Settings ***
Documentation  This suite contains FM__FSP_power_reset_counter_exceeded_FID1956_RMOD TC

Resource  ../test_resources/FM__FSP_power_reset_counter_exceeded_FID1956_RMOD.robot


*** Test Cases ***
FM__FSP_power_reset_counter_exceeded_FID1956_RMOD
    [Setup]  TC Setup
    TC__FM__FSP_power_reset_counter_exceeded_FID1956_RMOD
    [Teardown]  TC Teardown
