*** Settings ***
Documentation  This suite contains WebEM__vDU__Check_vDU_WebEm_for_Radio_FAN_parameters TC

Resource  ../test_resources/WebEM__vDU__Check_vDU_WebEm_for_Radio_FAN_parameters.robot


*** Test Cases ***
WebEM__vDU__Check_vDU_WebEm_for_Radio_FAN_parameters
    [Setup]  TC Setup
    TC__WebEM__vDU__Check_vDU_WebEm_for_Radio_FAN_parameters
    [Teardown]  TC Teardown
