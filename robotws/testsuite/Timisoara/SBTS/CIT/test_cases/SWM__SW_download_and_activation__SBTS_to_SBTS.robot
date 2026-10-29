*** Settings ***
Documentation  This suite contains SWM__SW_download_and_activation__SBTS_to_SBTS TC

Resource  ../test_resources/SWM__SW_download_and_activation__SBTS_to_SBTS.robot


*** Test Cases ***
SWM__SW_download_and_activation__SBTS_to_SBTS
    [Setup]  TC Setup
    TC__SWM__SW_download_and_activation__SBTS_to_SBTS
    [Teardown]  TC Teardown
