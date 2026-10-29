*** Settings ***
Documentation  This suite contains FM__vCU__Fault_4592_WebEM_Fault_Signature TC

Resource  ../test_resources/FM__vCU__Fault_4592_WebEM_Fault_Signature.robot


*** Test Cases ***
FM__vCU__Fault_4592_WebEM_Fault_Signature
    [Setup]  TC Setup
    TC__FM__vCU__Fault_4592_WebEM_Fault_Signature
    [Teardown]  TC Teardown
