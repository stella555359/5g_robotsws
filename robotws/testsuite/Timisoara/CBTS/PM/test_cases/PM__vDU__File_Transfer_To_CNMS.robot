*** Settings ***
Documentation  This suite contains PM__vDU__File_Transfer_To_CNMS TC

Resource  ../test_resources/PM__vDU__File_Transfer_To_CNMS.robot


*** Test Cases ***
PM__vDU__File_Transfer_To_CNMS
    [Setup]  TC Setup
    TC__PM__vDU__File_Transfer_To_CNMS
    [Teardown]  TC Teardown