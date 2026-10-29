*** Settings ***
Documentation  This suite contains WebEM__Activation_deactivation_fault_6506_EFaultId_SsdLogStorageOverdrawAI TC

Resource  ../test_resources/WebEM__Activation_deactivation_fault_6506_EFaultId_SsdLogStorageOverdrawAI.robot


*** Test Cases ***
WebEM__Activation_deactivation_fault_6506_EFaultId_SsdLogStorageOverdrawAI
    [Setup]  TC Setup
    TC__WebEM__Activation_deactivation_fault_6506_EFaultId_SsdLogStorageOverdrawAI
    [Teardown]  TC Teardown
