*** Settings ***
Documentation  This suite contains TC__FM__RMOD_crash_fault_signature_check TC

Resource  ../test_resources/FM__RMOD_crash_fault_signature_check.robot


*** Test Cases ***
TC__FM__RMOD_crash_fault_signature_check
    [Setup]  TC Setup
    FM__RMOD_crash_fault_signature_check
    [Teardown]  TC Teardown
