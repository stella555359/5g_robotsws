*** Settings ***
Documentation     author: Venkatesh
...               contact: venkatesh.1.venkatesh@nokia.com
...               Description: Test Cases for 5GC000509: L3 Non Standalone Call with Data Transmission.
...               This Feature is includes, UE Context Setup with additional functions in Security and IP Version
...               with above and below 6Ghz band and data trnasfer at 5G side.

Resource          ./5GC000509_Keywords.robot

Suite Setup       Suite Setup    feature_folder=5GC000509_B
Suite Teardown    Suite Teardown
Test Setup        Test Setup
Test Teardown     Test Teardown

*** Variables ***
${encryption_error_msg}    Cause : radioNetwork : encryption-and-or-integrity-protection-algorithms-not-supported
${wait_after_sgnb_addition}    5s

*** Test Cases ***
Verify the sgNB Addition Request Reject message when there is ciphering algo mismatch between 5G attaching UE and gNB-CU
    [Documentation]    This test case verifies that when there is mismatch in cipher algorithm
    ...                SgnbAddition Procedure is rejected with appropriate cause.
    [Tags]    CRT
    Ue Attach Based with null cipher
    Sgnb Addition Should Fail    expected_error=${encryption_error_msg}
    Wait After Sgnb Addition Failure
    Validate Sgnb Addition Reject From Pcap

*** Keywords ***
Test Setup
    Create Test Case Folder
    Start pcap collection in gNB and WTS
    Store Original Cipher Parameters In GNB For Revert
    Set Cipher Algorithm Parameters
    Set NullFallback Parameter
    Wait for gNB To Be Ready
    Prepare Environment Based On Run Type     cfg_type=custom
    Start WTS And Extablish X2 Link

Test Teardown
    Stop All Data Transfer    ue_id=${UE_ID}   bearer=${BEARER_ID}
    UE Detach    ue_id=${UE_ID}
    Common Test Teardown
    Revert NullFallback Parameter in GNB to Original Value
    Revert Cipher Parameters in GNB to Original Value

Wait After Sgnb Addition Failure
    Sleep    ${wait_after_sgnb_addition}

