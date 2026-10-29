*** Settings ***
Documentation  This suite contains FM__vDU__RMOD_Fault_4590_Fault_Signature TC

Resource  ../test_resources/FM__vDU__RMOD_Fault_4590_Fault_Signature.robot


*** Test Cases ***
FM__vDU__RMOD_Fault_4590_Fault_Signature
    [Setup]  TC Setup
    TC__FM__vDU__RMOD_Fault_4590_Fault_Signature
    [Teardown]  TC Teardown
