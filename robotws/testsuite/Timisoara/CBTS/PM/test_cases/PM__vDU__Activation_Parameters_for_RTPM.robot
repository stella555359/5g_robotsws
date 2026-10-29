*** Settings ***
Documentation  This suite contains PM__vDU__Activation_Parameters_for_RTPM TC

Resource  ../test_resources/PM__vDU__Activation_Parameters_for_RTPM.robot


*** Test Cases ***
PM__vDU__Activation_Parameters_for_RTPM
    [Setup]  TC Setup
    TC__PM__vDU__Activation_Parameters_for_RTPM
    [Teardown]  TC Teardown
