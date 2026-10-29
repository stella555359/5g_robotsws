*** Settings ***
Documentation  This suite contains KPI__CBTS__Configure_Common_UPlane_CPlane_tracing TC

Resource  ../test_resources/KPI__CBTS__Configure_Common_UPlane_CPlane_tracing.robot


*** Test Cases ***
KPI__CBTS__Configure_Common_UPlane_CPlane_tracing
    [Setup]  TC Setup
    TC__KPI__CBTS__Configure_Common_UPlane_CPlane_tracing
    [Teardown]  TC Teardown
