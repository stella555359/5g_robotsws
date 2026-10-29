*** Settings ***
Documentation  This suite contains PM__vCU__Check_RTPM_Via_EMSSIM TC

Resource  ../test_resources/PM__vCU__Check_RTPM_Via_EMSSIM.robot


*** Test Cases ***
PM__vCU__Check_RTPM_Via_EMSSIM
    [Setup]  TC Setup
    TC__PM__vCU__Check_RTPM_Via_EMSSIM
    [Teardown]  TC Teardown
