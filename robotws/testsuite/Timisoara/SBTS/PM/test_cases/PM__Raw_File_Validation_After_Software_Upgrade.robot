*** Settings ***
Documentation  This suite contains PM__Raw_File_Validation_After_Software_Upgrade TC

Resource  ../test_resources/PM__Raw_File_Validation_After_Software_Upgrade.robot


*** Test Cases ***
PM__Raw_File_Validation_After_Software_Upgrade
    [Setup]  TC Setup
    TC__PM__Raw_File_Validation_After_Software_Upgrade
    [Teardown]  TC Teardown