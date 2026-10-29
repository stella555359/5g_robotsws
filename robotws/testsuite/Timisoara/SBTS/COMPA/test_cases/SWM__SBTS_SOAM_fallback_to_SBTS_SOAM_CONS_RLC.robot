*** Settings ***
Documentation  This suite contains SWM__SBTS_SOAM_fallback_to_SBTS_SOAM_CONS_RLC TC

Resource  ../test_resources/SWM__SBTS_SOAM_fallback_to_SBTS_SOAM_CONS_RLC.robot


*** Test Cases ***
SWM__SBTS_SOAM_fallback_to_SBTS_SOAM_CONS_RLC
    [Setup]  TC Setup
    TC__SWM__SBTS_SOAM_fallback_to_SBTS_SOAM_CONS_RLC
    [Teardown]  TC Teardown
