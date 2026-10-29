*** Settings ***
Documentation  This suite contains FM__Snapshot_Collection_after_autonomous_reset_reported_using_FIDs_which_support_faultsignature TC

Resource  ../test_resources/FM__Snapshot_Collection_after_autonomous_reset_reported_using_FIDs_which_support_faultsignature.robot


*** Test Cases ***
FM__Snapshot_Collection_after_autonomous_reset_reported_using_FIDs_which_support_faultsignature
    [Setup]  TC Setup
    FM__Snapshot_Collection_after_autonomous_reset_reported_using_FIDs_which_support_faultsignature
    [Teardown]  TC Teardown
