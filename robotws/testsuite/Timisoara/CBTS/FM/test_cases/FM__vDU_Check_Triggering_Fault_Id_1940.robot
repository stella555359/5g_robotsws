*** Settings ***
Documentation  This suite contains FM__vDU_Check_Triggering_Fault_Id_1940 TC

Resource  ../test_resources/FM__vDU_Check_Triggering_Fault_Id_1940.robot


*** Test Cases ***
FM__vDU_Check_Triggering_Fault_Id_1940
    [Setup]  TC Setup
    TC__FM__vDU_Check_Triggering_Fault_Id_1940
    [Teardown]  TC Teardown
