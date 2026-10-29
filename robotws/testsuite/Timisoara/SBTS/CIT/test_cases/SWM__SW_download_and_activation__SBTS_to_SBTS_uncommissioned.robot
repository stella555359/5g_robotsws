*** Settings ***
Documentation  This suite contains SWM__SW_download_and_activation__SBTS_to_SBTS_uncommissioned TC

Resource  ../test_resources/SWM__SW_download_and_activation__SBTS_to_SBTS_uncommissioned.robot


*** Test Cases ***
SWM__SW_download_and_activation__SBTS_to_SBTS_uncommissioned
    [Setup]  TC Setup
    TC__SWM__SW_download_and_activation__SBTS_to_SBTS_uncommissioned
    [Teardown]  TC Teardown
