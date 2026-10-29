*** Settings ***
Documentation  This suite contains FM__FID4383_fault_signature_active_5G_RT_NRT_process TC

Resource  ../test_resources/FM__FID4383_fault_signature_active_5G_RT_NRT_process.robot


*** Test Cases ***
FM__FID4383_fault_signature_active_5G_RT_NRT_process
    [Setup]  TC Setup
    TC__FM__FID4383_fault_signature_active_5G_RT_NRT_process
    [Teardown]  TC Teardown
