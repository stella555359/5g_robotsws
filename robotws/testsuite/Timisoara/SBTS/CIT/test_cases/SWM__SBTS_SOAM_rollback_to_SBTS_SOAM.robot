*** Settings ***
Documentation  This suite contains SWM__SBTS_SOAM_rollback_to_SBTS_SOAM TC

Resource  ../test_resources/SWM__SBTS_SOAM_rollback_to_SBTS_SOAM.robot


*** Test Cases ***
SWM__SBTS_SOAM_rollback_to_SBTS_SOAM
    [Setup]  TC Setup
    TC__SWM__SBTS_SOAM_rollback_to_SBTS_SOAM
    [Teardown]  TC Teardown
