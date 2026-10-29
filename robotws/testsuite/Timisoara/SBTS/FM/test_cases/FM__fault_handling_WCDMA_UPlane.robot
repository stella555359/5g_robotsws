*** Settings ***
Documentation  This suite contains FM__fault_handling_WCDMA_UPlane TC

Resource  ../test_resources/FM__fault_handling_WCDMA_UPlane.robot


*** Test Cases ***
FM__fault_handling_WCDMA_UPlane
    [Setup]  TC Setup
    TC__FM__fault_handling_WCDMA_UPlane
    [Teardown]  TC Teardown
