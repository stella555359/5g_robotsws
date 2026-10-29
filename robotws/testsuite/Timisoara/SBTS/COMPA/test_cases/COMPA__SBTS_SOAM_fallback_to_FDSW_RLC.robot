*** Settings ***
Documentation  This suite contains COMPA__SBTS_SOAM_fallback_to_FDSW_RLC TC

Resource  ../test_resources/COMPA__SBTS_SOAM_fallback_to_FDSW_RLC.robot


*** Test Cases ***
COMPA__SBTS_SOAM_fallback_to_FDSW_RLC
    [Setup]  TC Setup
    TC__COMPA__SBTS_SOAM_fallback_to_FDSW_RLC
    [Teardown]  TC Teardown
