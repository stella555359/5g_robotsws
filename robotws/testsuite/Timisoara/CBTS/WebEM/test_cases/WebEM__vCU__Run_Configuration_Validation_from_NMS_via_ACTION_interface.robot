*** Settings ***
Documentation  This suite contains WebEM__vCU__Run_Configuration_Validation_from_NMS_via_ACTION_interface TC

Resource  ../test_resources/WebEM__vCU__Run_Configuration_Validation_from_NMS_via_ACTION_interface.robot


*** Test Cases ***
WebEM__vCU__Run_Configuration_Validation_from_NMS_via_ACTION_interface
    [Setup]  TC Setup
    TC__WebEM__vCU__Run_Configuration_Validation_from_NMS_via_ACTION_interface
    [Teardown]  TC Teardown
