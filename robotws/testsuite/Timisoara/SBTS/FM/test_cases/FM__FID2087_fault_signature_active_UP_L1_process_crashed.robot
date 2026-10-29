*** Settings ***
Documentation  This suite contains FM__FID2087_fault_signature_active_UP_L1_process_crashed TC

Resource  ../test_resources/FM__FID2087_fault_signature_active_UP_L1_process_crashed.robot


*** Test Cases ***
FM__FID2087_fault_signature_active_UP_L1_process_crashed
    [Setup]  TC Setup
    TC__FM__FID2087_fault_signature_active_UP_L1_process_crashed
    [Teardown]  TC Teardown
