*** Settings ***
Documentation     author: Venkatesh
...               contact: venkatesh.1.venkatesh@nokia.com
...               Description: Test Cases for 5GC000509: L3 Non Standalone Call with Data Transmission.
...               This Feature is includes, UE Context Setup with additional functions in Security and IP Version
...               with above and below 6Ghz band and data trnasfer at 5G side.

Resource          ./5GC000509_Keywords.robot

Suite Setup       Suite Setup    feature_folder=5GC000509_G
Suite Teardown    Suite Teardown

*** Variables ***
${sgnb_addition_completion_wait}    5s
&{CFG_NAME}                         FS_TDD_NSA=basic_fullstack_nsa_call_tdd_cmwv_CFRA.cfg
...                                 FS_FDD_NSA=basic_fullstack_nsa_call_fdd_cmwv_CFRA.cfg

*** Test Cases ***
UE Context set up with CBRA continues when no dedicated preambles are allocated
    [Documentation]    To verify UE contention Based RACH during Initial Access followed by
    ...                continous DL & UL data when no dedicated preambles
    [Tags]    CRT
    [Setup]    CBRA Test Setup
    Ue Attach Based with null cipher
    Start Data Transfer And Verify It is Through MCG
    Perform SGNB Addition For Bearer
    Wait For Sgnb Addition Completion
    RACH Dedicated IE Should Not Present in RRC Reconfiguration
    [Teardown]    CBRA Test Teardown

UE Context Set Up with CFRA and UL-DL Data transfer Below 6Ghz
    [Documentation]    To verify contention Free RACH during Initial Access followed by
                       ...   continous DL & UL data
    [Tags]    CRT
    [Setup]    CFRA Test Setup
    Attach to Default UE
    Start Data Transfer And Verify It is Through MCG
    Perform SGNB Addition For Bearer
    Wait For Sgnb Addition Completion
    RACH Dedicated IE Should Present in RRC Reconfiguration
    CFRA Preamble Value Should Present in RRC Reconfiguration
    [Teardown]    CFRA Test Teardown

*** Keywords ***
CBRA Test Setup
    Create Test Case Folder
    Start pcap collection in gNB and WTS
    Prepare Environment Based On Run Type     cfg_type=custom
    Start WTS And Extablish X2 Link

CFRA Test Setup
    Create Test Case Folder
    Store Original CBRA Preamble Parameter In GNB For Revert
    Set CFRA Dedicated Preambles
    Reboot Airphone For Recovery
    Start pcap collection in gNB and WTS
    Prepare Environment Based On Run Type
    ${file_name}    Get Config File Based On Run Type
    Update Config File in WTS    ${CURDIR}/cfg/${file_name}
    Start WTS And Extablish X2 Link

CFRA Test Teardown
    Stop All Data Transfer    ue_id=${UE_ID}   bearer=${BEARER_ID}
    UE Detach    ue_id=${UE_ID}
    Common Test Teardown
    Revert Original CBRA Preamble Parameter in GNB to original Value
    Reboot Airphone For Recovery

CBRA Test Teardown
    Stop All Data Transfer    ue_id=${UE_ID}   bearer=${BEARER_ID}
    UE Detach    ue_id=${UE_ID}
    Common Test Teardown

Wait For Sgnb Addition Completion
    Sleep    ${sgnb_addition_completion_wait}

Get Config File Based On Run Type
   ${file_name}    Set Variable     ${CFG_NAME['${RUN_TYPE}']}
   [Return]    ${file_name}
