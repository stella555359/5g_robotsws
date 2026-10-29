*** Settings ***
Documentation  This suite contains WebEM__CNI-119323_Country_Code_Modification_via_Netact TC

Resource  ../test_resources/WebEM__Country_Code_Modification_via_Netact.robot


*** Test Cases ***
WebEM__Country_Code_Modification_via_Netact
    [Setup]  TC Setup
    TC__WebEM__Country_Code_Modification_via_Netact
    [Teardown]  TC Teardown
