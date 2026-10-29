*** Settings ***
Documentation  This suite contains KPI__SW_download_and_activation__SBTS_to_SBTS TC

Resource  ../test_resources/KPI__SW_download_and_activation__SBTS_to_SBTS.robot


*** Test Cases ***
KPI__SW_download_and_activation__SBTS_to_SBTS
    [Setup]  TC Setup
    TC__KPI__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]  TC Teardown
