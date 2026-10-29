*** Settings ***
Documentation  This suite contains WebEM__Wizard_Deleting_WCDMA_RAT TC

Resource  ../test_resources/WebEM__Wizard_Deleting_WCDMA_RAT.robot


*** Test Cases ***
WebEM__Wizard_Deleting_WCDMA_RAT
    [Setup]  TC Setup
    TC__WebEM__Wizard_Deleting_WCDMA_RAT
    [Teardown]  TC Teardown
