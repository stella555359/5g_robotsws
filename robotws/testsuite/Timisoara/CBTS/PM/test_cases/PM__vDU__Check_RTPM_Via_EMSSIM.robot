*** Settings ***
Documentation  This suite contains PM__vDU__Check_RTPM_Via_EMSSIM TC

Resource  ../test_resources/PM__vDU__Check_RTPM_Via_EMSSIM.robot


*** Test Cases ***
PM__vDU__Check_RTPM_Via_EMSSIM
    [Setup]  TC Setup
    TC__PM__vDU__Check_RTPM_Via_EMSSIM
    [Teardown]  TC Teardown
