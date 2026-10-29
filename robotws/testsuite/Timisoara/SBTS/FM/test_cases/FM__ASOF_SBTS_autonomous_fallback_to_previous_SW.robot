*** Settings ***
Documentation  This suite contains FM__ASOF_SBTS_autonomous_fallback_to_previous_SW TC

Resource  ../test_resources/FM__ASOF_SBTS_autonomous_fallback_to_previous_SW.robot


*** Test Cases ***
FM__ASIM_SBTS_autonomous_fallback_to_DnR_Fdsw
    [Setup]  TC Setup
    FM__ASOF_SBTS_autonomous_fallback_to_previous_SW
    [Teardown]  TC Teardown
