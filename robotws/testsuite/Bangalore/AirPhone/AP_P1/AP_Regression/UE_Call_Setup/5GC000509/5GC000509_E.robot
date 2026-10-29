*** Settings ***
Documentation     author: Venkatesh
...               contact: venkatesh.1.venkatesh@nokia.com
...               Description: Test Cases for 5GC000509: L3 Non Standalone Call with Data Transmission.
...               This Feature is includes, UE Context Setup with additional functions in Security and IP Version
...               with above and below 6Ghz band and data trnasfer at 5G side.

Resource          ./5GC000509_Keywords.robot

Suite Setup       Suite Setup    feature_folder=5GC000509_E
Suite Teardown    Suite Teardown
Test Setup        Test Setup
Test Teardown     Test Teardown

*** Test Cases ***
UE Context Setup and Release success_Null Ciphering_BearerSetup with IPV4_DL-UL traffic Below6GHz
    [Tags]    CRT
    Ue Attach Based with null cipher
    Add X2AP ID Extension IE
    Start Data Transfer And Verify It is Through MCG
    Store Packets Sent and Received Before Sgnb Addition
    Perform SGNB Addition For Bearer
    Wait After Sgnb Addition    sleep_timer=2min
    Store Packets Sent and Received After Sgnb Addition
    Verify Data Transmission on SCG

UE Context Setup and Release success_AESCiphering_BearerSetup with IPV6_DL_UL traffic Below6GHz
    [Tags]    CRT
    Ue Attach Based with aes cipher
    Add X2AP ID Extension IE
    Start Data Transfer And Verify It is Through MCG
    Store Packets Sent and Received Before Sgnb Addition
    Perform SGNB Addition For Bearer
    Wait After Sgnb Addition    sleep_timer=2min
    Store Packets Sent and Received After Sgnb Addition
    Verify Data Transmission on SCG

*** Keywords ***
Test Setup
    Create Test Case Folder
    Start pcap collection in gNB and WTS
    Store Original DL Forward Parameters In GNB For Revert
    Disable DL Forwarding Feature in gNB
    Wait for gNB To Be Ready
    Prepare Environment Based On Run Type     cfg_type=custom
    Start WTS And Extablish X2 Link

Test Teardown
    Stop All Data Transfer    ue_id=${UE_ID}   bearer=${BEARER_ID}
    UE Detach    ue_id=${UE_ID}
    Common Test Teardown
    Revert DL Forwarding Parameter in GNB to original Value

Add X2AP ID Extension IE
    Update Enb Param with X2AP ID Extension    ue_id=${UE_ID}    extension=${SEND_EXTENSION}
