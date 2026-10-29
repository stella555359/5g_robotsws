*** Settings ***
Documentation  This suite contains PM__LTE_DL_UL_Throughput_Check TC

Resource  ../test_resources/PM__LTE_DL_UL_Throughput_Check.robot

*** Test Cases ***
PM__LTE_DL_UL_Throughput_Check
    [Setup]  TC Setup
    TC__PM__LTE_DL_UL_Throughput_Check
    [Teardown]  TC Teardown
