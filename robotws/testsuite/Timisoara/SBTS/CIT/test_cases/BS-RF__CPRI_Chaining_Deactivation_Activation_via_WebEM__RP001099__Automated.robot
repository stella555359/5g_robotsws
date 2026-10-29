*** Settings ***
Documentation  This suite contains BS-RF__CPRI_Chaining_Deactivation_Activation_via_WebEM__RP001099__Automated TC

Resource  ../test_resources/BS-RF__CPRI_Chaining_Deactivation_Activation_via_WebEM__RP001099__Automated.robot


*** Test Cases ***
BS-RF__CPRI_Chaining_Deactivation_Activation_via_WebEM__RP001099__Automated
    [Setup]  TC Setup
    TC__BS-RF__CPRI_Chaining_Deactivation_Activation_via_WebEM__RP001099__Automated
    [Teardown]  TC Teardown
