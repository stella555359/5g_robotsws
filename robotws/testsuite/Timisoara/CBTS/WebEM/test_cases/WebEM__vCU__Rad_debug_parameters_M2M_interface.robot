*** Settings ***
Documentation  This suite contains WebEM__vCU__Rad_debug_parameters_M2M_interface TC

Resource  ../test_resources/WebEM__vCU__Rad_debug_parameters_M2M_interface.robot


*** Test Cases ***
WebEM__vCU__Rad_debug_parameters_M2M_interface
    [Setup]  TC Setup
    TC__WebEM__vCU__Rad_debug_parameters_M2M_interface
    [Teardown]  TC Teardown
