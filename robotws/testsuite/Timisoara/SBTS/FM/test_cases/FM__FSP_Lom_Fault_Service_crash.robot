*** Settings ***
Documentation  This suite contains FM__FSP_Lom_Fault_Service_crash TC

Resource  ../test_resources/FM__FSP_Lom_Fault_Service_crash.robot


*** Test Cases ***
FM__FSP_Lom_Fault_Service_crash
    [Setup]  TC Setup
    TC__FM__FSP_Lom_Fault_Service_crash
    [Teardown]  TC Teardown
