*** Settings ***
Documentation  This suite contains KPI__vDU__Software_Signing_For_RU TC

Resource  ../test_resources/KPI__vDU__Software_Signing_For_RU.robot

*** Test Cases ***
KPI__vDU__Software_Signing_For_RU
    [Setup]  TC Setup
    TC__KPI__vDU__Software_Signing_For_RU
    [Teardown]  TC Teardown