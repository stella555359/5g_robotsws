*** Settings ***
Documentation  This suite contains WebEM__vDU__Run_Configuration_Validation_from_NMS_via_ACTION_interface TC

Resource  ../test_resources/WebEM__vDU__Run_Configuration_Validation_from_NMS_via_ACTION_interface.robot


*** Test Cases ***
WebEM__vDU__Run_Configuration_Validation_from_NMS_via_ACTION_interface
    [Setup]  TC Setup
    TC__WebEM__vDU__Run_Configuration_Validation_from_NMS_via_ACTION_interface
    [Teardown]  TC Teardown
