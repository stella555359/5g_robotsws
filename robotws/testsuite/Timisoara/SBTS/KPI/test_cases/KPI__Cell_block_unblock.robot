*** Settings ***
Documentation  This suite contains KPI__Cell_block_unblock TC

Resource  ../test_resources/KPI__Cell_block_unblock.robot


*** Test Cases ***
KPI__Cell_block_unblock
    [Setup]  TC Setup
    TC__KPI__Cell_block_unblock
    [Teardown]  TC Teardown
