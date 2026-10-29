# Copyright (c) 2020 Nokia. All rights reserved.

*** Settings ***
Documentation    This suite contains testcases for 4G5G Fullrack Combo Testline execution
Resource    resources/Keywords/common_keywords.robot
Library    ta_messaging

Suite Setup       Common Optimized Suite Setup
Suite Teardown    Common Suite Teardown

*** Variables ***
${SAVE_WTS_PCAP_FLAG}    False

*** Test Cases ***
Verify Ng Link Status
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    SA
    [Documentation]    -SA- Check if "NG link is UP" message can be found in egate console and egate_console.log
    NG Link Should be UP

Verify Address Distribution
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    SA
    [Documentation]    -SA- Check if "Address Distribution is complete" message can be found in APL3.log
    Address Distribution should be Successful

UE SIB Decoding
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    SA
    [Documentation]    -SA- Check if "SystemInformationBlockType1" message can be found in egate console and egate_console.log
    UE SIB Decoding should be Successful
    [Teardown]    Run Keyword If Test Passed    Log    ue_sib_decoding_is_ok

CUS Egate Sync
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    SA    NSA    LTE
    [Documentation]    Steps to sync between egate and CUS
    Configure CUS Executor should be Successful
    Check LTE cell status

Verify Cell Setup for AP
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    SA    NSA    LTE
    [Documentation]    -SANSA- Check if "Cell Setup completed" message can be found in APL3.log
    [Setup]    Requires Tc    CUS Egate Sync
    AP Cell Setup should be Successful
    sleep    5s
    [Teardown]    Run Keywords
    ...           Stop Tcpdump For Init    AND
    ...           Run Keyword If Test Passed    Log    cell_setup_is_ok

UE Attach with eNB
    [Tags]    FULL_RUN    Attach    [flow]L3 Call    LTE
    [Documentation]    -LTE- Check if UE attaches to LTE
    [Setup]     Requires Tc    Verify Cell Setup for AP
    UE Attach should be Successful with CUS
    [Teardown]    Run Keyword If Test Passed    Log    4g_attach_is_ok

UE Register
    [Tags]    FULL_RUN    Register    [flow]L3 Call    SA
    [Documentation]    -SA- Check if UE registers
    [Setup]    Run Keywords    Requires Tc    Verify Cell Setup for AP
    ...                        AND    Start Attach and Data Traffic TCPDUMP
    UE Register should be Successful for SANSA

UE Deregister
    [Tags]    FULL_RUN    Deregister    [flow]L3 Call    SA
    [Documentation]    -SA- Check if UE deregisters
    [Setup]    Requires Tc   UE Register
    UE Deregister should be Successful

UE Reregister
    [Tags]    FULL_RUN    Reregister    [flow]L3 Call    SA
    [Documentation]    -SA- Check if UE reregisters
    [Setup]    Requires Tc    UE Deregister
    UE Reregister should be Successful for SANSA

LTE Attach
    [Tags]    FULL_RUN    Attach    [flow]L3 Call    NSA
    [Documentation]    -NSA- Check if UE attaches to LTE
    [Setup]    Requires Tc    Verify Cell Setup for AP
    LTE Attach should be Successful with CUS
    [Teardown]    Run Keyword If Test Passed    Log    lte_attach_nsa_is_ok

UE Attach
    [Tags]    FULL_RUN    Attach    [flow]L3 Call    NSA
    [Documentation]    -NSA- Check if UE attaches to NR
    [Setup]    Requires Tc    LTE Attach
    UE Attach should be Successful for 4G5GCUS
    [Teardown]    Run Keyword If Test Passed    Log    ue_attach_is_ok

Traffic
    [Tags]    FULL_RUN    Traffic    [flow]L3 Call    LTE
    [Documentation]    -LTE- Check for LTE Traffic
    [Setup]    Run Keywords    Requires Tc    UE Attach with eNB
    ...                        AND    Requires Tc    UE Register
    ...                        AND    Requires Tc    UE Attach
    Start and Validate Traffic For 4G5G_CUS Mixed Mode
    [Teardown]    Run Keywords
    ...           Stop Attach and Data Traffic TCPDUMP    AND    Delete Pcaps from Traffic    AND
    ...           Run Keyword If Test Passed    Log    traffic_is_ok

UE Detach with eNB
    [Tags]    FULL_RUN    Detach    [flow]L3 Call    LTE
    [Documentation]    -LTE- Check if UE detaches to LTE
    [Setup]    Requires Tc    UE Attach with eNB
    UE Detach should be Successful with CUS
    [Teardown]    Run Keyword If Test Passed    Log    4g_detach_is_ok

UE Reattach with eNB
    [Tags]    FULL_RUN    Reattach    [flow]L3 Call    LTE
    [Documentation]    -LTE- Check if UE attaches to LTE
    [Setup]    Requires Tc    UE Detach with eNB
    UE Reattach should be Successful with CUS
    [Teardown]    Run Keyword If Test Passed    Log    4g_reattach_is_ok

UE Detach
    [Tags]    FULL_RUN    Detach    [flow]L3 Call    NSA
    [Documentation]    -NSA- Check if UE detaches to LTE
    [Setup]    Requires Tc    UE Attach
    UE Detach for NSA should be Successful
    [Teardown]    Run Keyword If Test Passed    Log    ue_detach_nsa_is_ok

UE Reattach
    [Tags]    FULL_RUN    Reattach    [flow]L3 Call    NSA
    [Documentation]    -NSA- Check if UE attaches to NR
    [Setup]    Requires Tc    UE Detach
    UE Reattach for NSA should be Successful
    [Teardown]    Run Keyword If Test Passed    Log    ue_reattach_nsa_is_ok
