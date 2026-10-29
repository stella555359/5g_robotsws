*** Settings ***
Documentation  This suite contains FM__AEHC_noncritical_DFE_runtime_crash TC

Resource  ../test_resources/FM__AEHC_noncritical_DFE_runtime_crash.robot


*** Test Cases ***
FM__Autonomous_Power_Cycle_Reset_for_MPlane_Loss
    [Setup]  TC Setup
    TC__FM__AEHC_noncritical_DFE_runtime_crash
    [Teardown]  TC Teardown
