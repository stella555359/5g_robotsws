*** Settings ***
Documentation  This suite contains WebEM__vDU__Rad_debug_parameters_M2M_interface TC

Resource  ../test_resources/WebEM__vDU__Rad_debug_parameters_M2M_interface.robot


*** Test Cases ***
WebEM__vDU__Rad_debug_parameters_M2M_interface
    [Setup]  TC Setup
    TC__WebEM__vDU__Rad_debug_parameters_M2M_interface
    [Teardown]  TC Teardown
