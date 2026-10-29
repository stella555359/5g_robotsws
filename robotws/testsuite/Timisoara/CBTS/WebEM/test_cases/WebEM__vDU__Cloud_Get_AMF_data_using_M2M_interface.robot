*** Settings ***
Documentation  This suite contains WebEM__vDU__Cloud_Get_AMF_data_using_M2M_interface TC

Resource  ../test_resources/WebEM__vDU__Cloud_Get_AMF_data_using_M2M_interface.robot


*** Test Cases ***
WebEM__vDU__Cloud_Get_AMF_data_using_M2M_interface
    [Setup]  TC Setup
    TC__WebEM__vDU__Cloud_Get_AMF_data_using_M2M_interface
    [Teardown]  TC Teardown
