*** Settings ***
Resource    ../test_resources/FM__FID6918_fault_signature_active__RTHWAPI_UP_process_crashed.robot

*** Test Cases ***
FM__FID6918_fault_signature_active__RTHWAPI_UP_process_crashed
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC_FM__FID6918_fault_signature_active__RTHWAPI_UP_process_crashed
