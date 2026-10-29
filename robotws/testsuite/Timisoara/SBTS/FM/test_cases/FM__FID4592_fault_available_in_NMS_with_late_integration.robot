*** Settings ***
Documentation  This suite contains FM__FID4592_fault_available_in_NMS_with_late_integration TC

Resource    ../test_resources/FM__FID4592_fault_available_in_NMS_with_late_integration.robot

*** Test Cases ***
FM__FID4592_fault_available_in_NMS_with_late_integration
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__FM__FID4592_fault_available_in_NMS_with_late_integration