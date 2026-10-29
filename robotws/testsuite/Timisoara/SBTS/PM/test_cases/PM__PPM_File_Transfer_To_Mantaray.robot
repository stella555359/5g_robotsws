*** Settings ***
Documentation  This suite contains PM__PPM_File_Transfer_To_Mantaray TC

Resource  ../test_resources/PM__PPM_File_Transfer_To_Mantaray.robot


*** Test Cases ***
PM__PPM_File_Transfer_To_Mantaray
    [Setup]  TC Setup
    TC__PM__PPM_File_Transfer_To_Mantaray
    [Teardown]  TC Teardown
