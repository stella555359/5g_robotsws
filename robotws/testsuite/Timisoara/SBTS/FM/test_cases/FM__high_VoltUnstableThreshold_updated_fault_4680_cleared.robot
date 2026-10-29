*** Settings ***
Documentation  This suite contains FM__high_VoltUnstableThreshold_updated_fault_4680_cleared TC

Resource  ../test_resources/FM__high_VoltUnstableThreshold_updated_fault_4680_cleared.robot


*** Test Cases ***
FM__high_VoltUnstableThreshold_updated_fault_4680_cleared
    [Setup]  TC Setup
    TC__FM__high_VoltUnstableThreshold_updated_fault_4680_cleared
    [Teardown]  TC Teardown
