*** Settings ***
Documentation  This suite contains PM__vDU__PPM_3GPP_File_Lifecycle TC

Resource  ../test_resources/PM__vDU__PPM_3GPP_File_Lifecycle.robot


*** Test Cases ***
PM__vDU__PPM_3GPP_File_Lifecycle
    [Setup]  TC Setup
    TC__PM__vDU__PPM_3GPP_File_Lifecycle
    [Teardown]  TC Teardown
