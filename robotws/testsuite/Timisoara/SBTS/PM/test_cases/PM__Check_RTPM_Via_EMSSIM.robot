*** Settings ***
Documentation  This suite contains PM__Check_RTPM_Via_EMSSIM TC

Resource  ../test_resources/PM__Check_RTPM_Via_EMSSIM.robot


*** Test Cases ***
PM__Check_RTPM_Via_EMSSIM
    [Setup]  TC Setup
    TC__PM__Check_RTPM_Via_EMSSIM
    [Teardown]  TC Teardown
