*** Settings ***
Documentation  This suite contains PANO__5GC001104_A_13_Suppression_of_zero_values TC

Resource  ../test_resources/PANO__5GC001104_A_13_Suppression_of_zero_values.robot


*** Test Cases ***
PANO__5GC001104_A_13_Suppression_of_zero_values
    [Setup]  TC Setup
    TC__PANO__5GC001104_A_13_Suppression_of_zero_values
    [Teardown]  TC Teardown
