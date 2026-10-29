*** Settings ***
Documentation  This suite contains WebEM__vCU__Get_vCU_State_Data_By_M2M_Interface TC

Resource  ../test_resources/WebEM__vCU__Get_vCU_State_Data_By_M2M_Interface.robot


*** Test Cases ***
WebEM__vCU__Get_vCU_State_Data_By_M2M_Interface
    [Setup]  TC Setup
    TC__WebEM__vCU__Get_vCU_State_Data_By_M2M_Interface
    [Teardown]  TC Teardown
