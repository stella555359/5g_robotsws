*** Settings ***
Documentation  This suite contains WebEM__Activate_FAF_on_SBTS_with_pure_WCDMA_GSM_RAT TC

Resource  ../test_resources/WebEM__Activate_FAF_on_SBTS_with_pure_WCDMA_GSM_RAT.robot


*** Test Cases ***
WebEM__Activate_FAF_on_SBTS_with_pure_WCDMA_GSM_RAT
    [Setup]  TC Setup
    TC__WebEM__Activate_FAF_on_SBTS_with_pure_WCDMA_GSM_RAT
    [Teardown]  TC Teardown

