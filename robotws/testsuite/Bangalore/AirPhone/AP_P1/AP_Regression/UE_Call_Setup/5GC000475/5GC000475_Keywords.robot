*** Settings ***
Documentation    This file contains 5GC000475 ConfigManagement Admin keywords

Library       ute_wtssim

Resource    ../../../Resources/robot/gnb.robot
Resource    ../../../Resources/robot/ute_setup.robot
Resource    ../../../Resources/robot/wts.robot
Resource    ../../../Resources/Variables/Common_Variables.robot
Resource    ./5GC000475_ConfigManagement_Admin.robot
Resource    ../../../Resources/robot/suite_common_keywords.robot
Resource    ../Resources/Common_Keywords.robot

*** Variables ***
${MAX_DIFF_PKTS}              200
${ENDC_RELEASE_WAIT_TIME}     2min
${sgnb_release_req_wait}      5s

*** Keywords ***
Suite Setup
    Suite Common Keywords    feature_folder=5GC000475
    Wait for gNB To Be Ready
    Store Original DL Forward Parameters in GNB For Revert
    Enable DL Forwarding Feature in gNB
    Wait for gNB To Be Ready
    Prepare Environment Based On Run Type

Suite Teardown
    Common Suite Teardown Keywords
    Revert DL Forwarding Parameter in GNB to original Value

Test Teardown
    Stop All Data Transfer    ue_id=${UE_ID}   bearer=${BEARER_ID}
    UE Detach    ue_id=${UE_ID}
    Common Test Teardown

CleanUp
    ute_wtssim.Teardown All Aliases For Wts

Store Packets Before ENDC Bearer Release
    ${total_pkts_sent_scg}    ${total_pkts_recieved_scg}    ${total_pkts_sent_mcg}    ${total_pkts_recieved_mcg}
    ...    Get Packets Sent And Received For SCG and MCG
    Set Test Variable    ${total_pkts_sent_scg}
    Set Test Variable    ${total_pkts_recieved_scg}
    Set Test Variable    ${total_pkts_sent_mcg}
    Set Test Variable    ${total_pkts_recieved_mcg}

Store Packets After ENDC Bearer Release
    ${total_pkts_sent_after_release_scg}    ${total_pkts_recieved_after_release_scg}    ${total_pkts_sent_after_release_mcg}
    ...    ${total_pkts_recieved_after_release_mcg}    Get Packets Sent And Received For SCG and MCG
    Set Test Variable    ${total_pkts_sent_after_release_scg}
    Set Test Variable    ${total_pkts_recieved_after_release_scg}
    Set Test Variable    ${total_pkts_sent_after_release_mcg}
    Set Test Variable    ${total_pkts_recieved_after_release_mcg}

Verify Data Trasmission is Over 4G Network
    Packet Difference Should be With In Range    ${total_pkts_sent_after_release_scg}    ${total_pkts_sent_scg}
    Packet Difference Should be With In Range    ${total_pkts_recieved_after_release_scg}    ${total_pkts_recieved_scg}
    Should be True    ${${total_pkts_sent_after_release_mcg}} > ${${total_pkts_sent_mcg}}
    ...    msg = Data Transmission didnt happen over 4G after scg release
    Should be True    ${${total_pkts_recieved_after_release_mcg}} > ${${total_pkts_recieved_mcg}}
    ...    msg = Data Transmission didnt happen over 4G after scg release

Wait After ENDC Release
    Sleep    ${ENDC_RELEASE_WAIT_TIME}

Packet Difference Should be With In Range
    [Arguments]    ${packet_2}    ${packet_1}    ${allowed_difference}=${MAX_DIFF_PKTS}
    ${pkts_diff}    Evaluate    ${${packet_2}} - ${${packet_1}}
    Should be True    ${${pkts_diff}} <= ${${allowed_difference}}
    ...    msg = Data Transmission didnt happen over 4G after scg release

Test Setup
    Create Test Case Folder
    Start pcap collection in gNB and WTS
    Start WTS And Extablish X2 Link

Wait For Sgnb Release Required
    Sleep    ${sgnb_release_req_wait}