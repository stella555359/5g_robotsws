*** Settings ***
Documentation  This suite contains FM__low_VoltUnstable_recovered_fault_4680_cleared TC

Resource  ../test_resources/FM__low_VoltUnstable_recovered_fault_4680_cleared.robot


*** Test Cases ***
FM__low_VoltUnstable_recovered_fault_4680_cleared
    [Setup]  TC Setup
    TC__FM__low_VoltUnstable_recovered_fault_4680_cleared
    [Teardown]  TC Teardown
