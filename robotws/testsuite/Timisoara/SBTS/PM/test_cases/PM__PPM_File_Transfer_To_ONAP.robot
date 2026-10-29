*** Settings ***
Documentation  This suite contains PM__PPM_File_Transfer_To_ONAP TC

Resource  ../test_resources/PM__PPM_File_Transfer_To_ONAP.robot


*** Test Cases ***
PM__PPM_File_Transfer_To_ONAP
    [Setup]  TC Setup
    TC__PM__PPM_File_Transfer_To_ONAP
    [Teardown]  TC Teardown
