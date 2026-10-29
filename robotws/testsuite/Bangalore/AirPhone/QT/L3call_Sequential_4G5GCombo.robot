# Copyright (c) 2020 Nokia. All rights reserved.

*** Settings ***
Resource    resources/Keywords/common_keywords.robot

Suite Setup       Common Optimized Suite Setup
Suite Teardown    Common Suite Teardown

*** Test Cases ***
Verify Ng Link Status
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    SA
    [Documentation]    -SA- Check if "NG link is UP" message can be found in egate console and egate_console.log
    NG Link Should be UP
    [Teardown]    Run Keyword If Test Passed    Log    ng_link_status_is_ok

Verify Address Distribution
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    SA
    [Documentation]    -SA- Check if "Address Distribution is complete" message can be found in APL3.log
    Address Distribution should be Successful
    [Teardown]    Run Keyword If Test Passed    Log    address_distribution_is_ok

UE SIB Decoding
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    SA
    [Documentation]    -SA- Check if "SystemInformationBlockType1" message can be found in egate console and egate_console.log
    UE SIB Decoding should be Successful
    sleep    5s
    [Teardown]    Run Keyword If Test Passed    Log    ue_sib_decoding_is_ok

Verify Cell Setup for AP
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    SA    NSA    LTE
    [Documentation]    -SANSA- Check if "Cell Setup completed" message can be found in APL3.log
    AP Cell Setup should be Successful
    sleep    5s
    [Teardown]    Run Keywords
    ...           Stop Tcpdump For Init    AND
    ...           Run Keyword If Test Passed    Log    cell_setup_is_ok

UE Attach with eNB
    [Tags]    FULL_RUN    Attach    [flow]L3 Call    LTE
    [Documentation]    -LTE- Check if UE attaches to LTE
    [Setup]     Requires Tc    Verify Cell Setup for AP    
    UE Attach should be Successful with eNB
    [Teardown]    Run Keyword If Test Passed    Log    4g_attach_is_ok

LTE Traffic
    [Tags]    FULL_RUN    Traffic    [flow]L3 Call    LTE
    [Documentation]    -LTE- Check for LTE Traffic
    [Setup]    Requires Tc    UE Attach with eNB
    LTE Traffic should be Successful
    [Teardown]    Run Keyword If Test Passed    Log    traffic_is_ok

UE Detach with eNB
    [Tags]    FULL_RUN    Detach    [flow]L3 Call    LTE
    [Documentation]    -LTE- Check if UE detaches to LTE
    [Setup]    Requires Tc    UE Attach with eNB
    UE Detach should be Successful with eNB
    [Teardown]    Run Keyword If Test Passed    Log    4g_detach_is_ok

UE Reattach with eNB
    [Tags]    FULL_RUN    Reattach    [flow]L3 Call    LTE
    [Documentation]    -LTE- Check if UE attaches to LTE
    [Setup]    Requires Tc    UE Detach with eNB
    UE Reattach should be Successful with eNB
    [Teardown]    Run Keyword If Test Passed    Log    4g_reattach_is_ok
   
UE Register
    [Tags]    FULL_RUN    Register    [flow]L3 Call    SA
    [Documentation]    -SA- Check if UE registers
    [Setup]    Run Keywords    Requires Tc    Verify Cell Setup for AP
    ...                        AND    Start Attach and Data Traffic TCPDUMP
    UE Register should be Successful for SANSA
    [Teardown]    Run Keyword If Test Passed    Log    ue_register_is_ok

UE Deregister
    [Tags]    FULL_RUN    Deregister    [flow]L3 Call    SA
    [Documentation]    -SA- Check if UE deregisters
    [Setup]    Requires Tc   UE Register
    UE Deregister should be Successful
    [Teardown]    Run Keyword If Test Passed    Log    ue_deregister_is_ok

UE Reregister
    [Tags]    FULL_RUN    Reregister    [flow]L3 Call    SA
    [Documentation]    -SA- Check if UE reregisters
    [Setup]    Requires Tc    UE Deregister
    UE Reregister should be Successful for SANSA
    [Teardown]    Run Keyword If Test Passed    Log    ue_re-register_is_ok

SA Traffic
    [Tags]    FULL_RUN    Traffic    [flow]L3 Call    SA
    [Setup]    Requires Tc   UE Reregister
    Traffic for SA should be Successful
    [Teardown]    Run Keyword If Test Passed    Log    traffic_is_ok

SA UE Deregister
    [Tags]    FULL_RUN    Deregister    [flow]L3 Call    SA
    [Setup]    Requires Tc   SA Traffic
    UE Deregister should be Successful
    [Teardown]    Run Keywords
    ...           UE Deregister Test Teardown for SANSA   AND
    ...           Run Keyword If Test Passed    Log    ue_deregister_is_ok

LTE Attach
    [Tags]    FULL_RUN    Attach    [flow]L3 Call    NSA
    [Documentation]    -NSA- Check if UE attaches to LTE
    [Setup]    Run Keywords    Requires Tc    Verify Cell Setup for AP 
    ...                        AND    Start Attach and Data Traffic TCPDUMP
    LTE Attach should be Successful
    [Teardown]    Run Keyword If Test Passed    Log    lte_attach_nsa_is_ok

UE Attach
    [Tags]    FULL_RUN    Attach    [flow]L3 Call    NSA 
    [Documentation]    -NSA- Check if UE attaches to NR
    [Setup]    Requires Tc    LTE Attach
    UE Attach should be Successful for 4G5GCombo
    [Teardown]    Run Keyword If Test Passed    Log    ue_attach_is_ok

NSA Traffic
    [Tags]    FULL_RUN    Traffic    [flow]L3 Call    NSA
    [Setup]    Requires Tc    UE Attach
    Traffic for NSA should be Successful
    [Teardown]    Run Keywords
    ...           Stop Attach and Data Traffic TCPDUMP    AND    Delete Pcaps from Traffic    AND
    ...           Run Keyword If Test Passed    Log    traffic_is_ok

UE Detach
    [Tags]    FULL_RUN    Detach    [flow]L3 Call    NSA  
    [Documentation]    -NSA- Check if UE detaches to LTE
    [Setup]    Requires Tc    UE Attach
    UE Detach should be Successful
    [Teardown]    Run Keyword If Test Passed    Log    detach_is_ok

UE Reattach
    [Tags]    FULL_RUN    Reattach    [flow]L3 Call    NSA    
    [Documentation]    -NSA- Check if UE attaches to NR
    [Setup]    Requires Tc    UE Detach
    UE Reattach should be Successful
    [Teardown]    Run Keyword If Test Passed    Log    ue_reattach_nsa_is_ok
