*** Settings ***
Documentation  This suite contains WebEM__Robustness_Bts_power_reset_during_ongoing_remote_snapshot TC

Resource  ../test_resources/WebEM__Robustness_Bts_power_reset_during_ongoing_remote_snapshot.robot


*** Test Cases ***
WebEM__Robustness_Bts_power_reset_during_ongoing_remote_snapshot
    [Setup]  TC Setup
    TC__WebEM__Robustness_Bts_power_reset_during_ongoing_remote_snapshot
    [Teardown]  TC Teardown
