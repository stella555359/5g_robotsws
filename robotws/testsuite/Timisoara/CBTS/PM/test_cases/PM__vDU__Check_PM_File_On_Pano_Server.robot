*** Settings ***
Documentation  This suite contains PM__vDU__Check_PM_File_On_Pano_Server TC

Resource  ../test_resources/PM__vDU__Check_PM_File_On_Pano_Server.robot


*** Test Cases ***
PM__vDU__Check_PM_File_On_Pano_Server
    [Setup]  TC Setup
    TC__PM__vDU__Check_PM_File_On_Pano_Server
    [Teardown]  TC Teardown
