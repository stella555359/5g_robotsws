*** Settings ***
Documentation  This suite contains WebEM__Basic_Sanity_Check_Simplified_Site_View_Operations TC

Resource  ../test_resources/WebEM__Basic_Sanity_Check_Simplified_Site_View_Operations.robot


*** Test Cases ***
WebEM__Basic_Sanity_Check_Simplified_Site_View_Operations
    [Setup]  TC Setup
    TC__WebEM__Basic_Sanity_Check_Simplified_Site_View_Operations
    [Teardown]  TC Teardown
