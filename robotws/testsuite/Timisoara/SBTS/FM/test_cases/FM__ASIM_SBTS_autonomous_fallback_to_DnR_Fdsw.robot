*** Settings ***
Documentation  This suite contains FM__ASIM_SBTS_autonomous_fallback_to_DnR_Fdsw TC

Resource  ../test_resources/FM__ASIM_SBTS_autonomous_fallback_to_DnR_Fdsw.robot


*** Test Cases ***
FM__ASIM_SBTS_autonomous_fallback_to_DnR_Fdsw
    [Setup]  TC Setup
    TC__FM__ASIM_SBTS_autonomous_fallback_to_DnR_Fdsw
    [Teardown]  TC Teardown
