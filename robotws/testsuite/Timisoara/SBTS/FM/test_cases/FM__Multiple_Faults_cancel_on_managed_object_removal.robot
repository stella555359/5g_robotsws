*** Settings ***
Documentation  This suite contains FM__Multiple_Faults_cancel_on_managed_object_removal TC

Resource  ../test_resources/FM__Multiple_Faults_cancel_on_managed_object_removal.robot


*** Test Cases ***
TC__FM__Multiple_Faults_cancel_on_managed_object_removal
    [Setup]  TC Setup
    FM__Multiple_Faults_cancel_on_managed_object_removal
    [Teardown]  TC Teardown
