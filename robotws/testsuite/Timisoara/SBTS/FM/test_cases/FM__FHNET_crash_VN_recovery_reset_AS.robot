*** Settings ***
Documentation  This suite contains FM__FHNET_crash_VN_recovery_reset_AS TC

Resource  ../test_resources/FM__FHNET_crash_VN_recovery_reset_AS.robot


*** Test Cases ***
FM__FHNET_crash_VN_recovery_reset_AS
    [Setup]  TC Setup
    TC__FM__FHNET_crash_VN_recovery_reset_AS
    [Teardown]  TC Teardown
