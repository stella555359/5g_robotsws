*** Settings ***
Documentation    Test Suite
Resource    ../test_resources/PM__RFS__KPI_PM_Counters_benchmarking.robot

*** Test Cases ***
[1]PM__RFS__KPI_PM_Counters_benchmarking
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__PM__RFS__KPI_PM_Counters_benchmarking