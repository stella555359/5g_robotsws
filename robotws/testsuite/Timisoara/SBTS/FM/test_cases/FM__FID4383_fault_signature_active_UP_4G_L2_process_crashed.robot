*** Settings ***
Documentation  This suite contains FM__FID4383_fault_signature_active_UP_4G_L2_process_crashed TC

Resource  ../test_resources/FM__FID4383_fault_signature_active_UP_4G_L2_process_crashed.robot


*** Test Cases ***
FM__FID4383_fault_signature_active_UP_4G_L2_process_crashed
    [Setup]  TC Setup
    TC__FM__FID4383_fault_signature_active_UP_4G_L2_process_crashed
    [Teardown]  TC Teardown
