*** Settings ***
Documentation  This suite contains PM__Result_File_Retrieval_Failure TC

Resource  ../test_resources/PM__Result_File_Retrieval_Failure.robot


*** Test Cases ***
PM__Result_File_Retrieval_Failure
    [Setup]  TC Setup
    TC__PM__Result_File_Retrieval_Failure
    [Teardown]  TC Teardown
