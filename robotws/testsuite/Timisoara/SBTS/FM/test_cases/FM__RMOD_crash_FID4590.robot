*** Settings ***
Documentation  This suite contains FM__RMOD_crash_FID4590 TC

Resource  ../test_resources/FM__RMOD_crash_FID4590.robot


*** Test Cases ***
FM__RMOD_crash_FID4590
    [Setup]  TC Setup
    TC__FM__RMOD_crash_FID4590
    [Teardown]  TC Teardown
