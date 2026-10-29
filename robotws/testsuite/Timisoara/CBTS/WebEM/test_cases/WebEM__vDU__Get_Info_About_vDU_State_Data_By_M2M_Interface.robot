*** Settings ***
Documentation  This suite contains WebEM__vDU__Get_Info_About_vDU_State_Data_By_M2M_Interface TC

Resource  ../test_resources/WebEM__vDU__Get_Info_About_vDU_State_Data_By_M2M_Interface.robot


*** Test Cases ***
WebEM__vDU__Get_Info_About_vDU_State_Data_By_M2M_Interface
    [Setup]  TC Setup
    TC__WebEM__vDU__Get_Info_About_vDU_State_Data_By_M2M_Interface
    [Teardown]  TC Teardown
