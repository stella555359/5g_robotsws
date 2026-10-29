*** Settings ***
Documentation  This suite contains KPI__Independent_RU_SW_Upgrade TC

Resource  ../test_resources/KPI__Independent_RU_SW_Upgrade.robot


*** Test Cases ***
KPI__Independent_RU_SW_Upgrade
    [Setup]  TC Setup
    TC__KPI__Independent_RU_SW_Upgrade
    [Teardown]  TC Teardown
