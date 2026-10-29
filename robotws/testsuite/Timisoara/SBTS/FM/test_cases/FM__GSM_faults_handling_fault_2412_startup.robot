*** Settings ***
Documentation  This suite contains FM__GSM_faults_handling_fault_2412_startup TC

Resource  ../test_resources/FM__GSM_faults_handling_fault_2412_startup.robot


*** Test Cases ***
FM__GSM_faults_handling_fault_2412_startup
    [Setup]  TC Setup
    TC__FM__GSM_faults_handling_fault_2412_startup
    [Teardown]  TC Teardown
