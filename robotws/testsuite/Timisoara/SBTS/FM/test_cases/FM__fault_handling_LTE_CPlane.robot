*** Settings ***
Documentation  This suite contains FM__fault_handling_LTE_CPlane TC

Resource  ../test_resources/FM__fault_handling_LTE_CPlane.robot


*** Test Cases ***
FM__fault_handling_LTE_CPlane
    [Setup]  TC Setup
    TC__FM__fault_handling_LTE_CPlane
    [Teardown]  TC Teardown
