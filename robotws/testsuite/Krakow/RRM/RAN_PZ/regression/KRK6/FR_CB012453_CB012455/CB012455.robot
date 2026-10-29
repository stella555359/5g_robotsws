*** Settings ***
Documentation
...   author: Sara Nowak
...   contact: sara.nowak@nokia.com
...   maintainer: sara.nowak@nokia.com

Resource    ./resources/suite_specific_keywords.robot

Suite Setup       Suite Setup
Suite Teardown    Suite Teardown

*** Test Cases ***

General_SiSo_Online_Cell_Addition_Deletion

    [Setup]    run keywords        Test Setup    AND    Prepare UEs for L3 Call    AND
    ...                            Get delta configuration path

    Prepare 16 Cells and 10 Cells Deltas
    Add 6 Cells to NRCELLGRP-70
    Attach UE3 With Cell Verification
    Start and Verify UDP 8CC DL and 4CC UL data transfer for UE3
    Detach UE3

    Remove 6 Cells from NRCELLGRP-70
    Attach UE3 With Cell Verification
    Start and Verify UDP 8CC DL and 4CC UL data transfer for UE3
    Detach UE3

    [Teardown]    Test Teardown

General_SiSo_SFP_lock_unlock_for_configuration_testing

    [Setup]    run keywords    Test Setup

    Upload configuration 25R3_N_CB012455_5b
    Verify Allowed Alarms

    Check Link Mode And Set Additional Alarms    sfp_id=1
    Lock and unlock SFP    sfp_id=1

    Check Link Mode And Set Additional Alarms    sfp_id=2
    Lock and unlock SFP    sfp_id=2

    [Teardown]    Common Postconditions
