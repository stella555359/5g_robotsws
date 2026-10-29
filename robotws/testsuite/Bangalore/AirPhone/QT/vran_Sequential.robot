# Copyright (c) 2020 Nokia. All rights reserved.

*** Settings ***
Documentation     This contains testcase for VRAN 4.0 which can be merged with L3 Parallel suit once log collection procedures are added.
...               :author Sudha V

Resource    resources/Keywords/common_keywords.robot

Suite Setup       Run Keywords    Common VDU Suite Setup
Suite Teardown    Run Keywords    Common Suite Teardown

*** Variables ***
${Disable_gNB_Log_Collection}    True
${TOPOLOGY}    CLOUD_5GC_dRNIC_1vDU_O_AP_LO_SA_FS_CPRI_CMWV_FDD
${traffic_duration}    30s
@{cell_ids}    1    3

*** Test Cases ***
Verify Ng Link Status
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    SA 
    [Documentation]    -SA- Check if "NG link is UP" message can be found in egate console and egate_console.log
    NG Link Should be UP
    [Teardown]    Run Keyword If Test Passed    Log    ng_link_status_is_ok

X2 Connection
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    NSA
    [Documentation]    -NSA- check if "X2AP Link with GNB" msg found in egate console 
    X2AP Link Should be UP
    sleep    5s
    [Teardown]    Run Keyword If Test Passed    Log   x2_is_ok

Verify Address Distribution
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    SA    NSA
    [Documentation]    -SA- Check if "Address Distribution is complete" message can be found in APL3.log
    Address Distribution should be Successful
    [Teardown]    Run Keyword If Test Passed    Log    address_distribution_is_ok

UE SIB Decoding
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    SA    NSA
    [Documentation]    -SA- Check if "SystemInformationBlockType1" message can be found in egate console and egate_console.log
    UE SIB Decoding should be Successful
    sleep    5s
    [Teardown]    Run Keyword If Test Passed    Log    ue_sib_decoding_is_ok

Verify Cell Setup for AP
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    SA    NSA
    [Documentation]    -SANSA- Check if "Cell Setup completed" message can be found in APL3.log
    AP Cell Setup should be Successful
    sleep    5s
    [Teardown]    Run Keyword If Test Passed    Log    cell_setup_is_ok

UE Register
    [Tags]    FULL_RUN    Register    [flow]L3 Call    SA
    [Documentation]    -SA- Check if UE registers
    [Setup]    Run Keywords    Requires Tc    Verify Cell Setup for AP    AND    UE Register Test Setup for SA
    UE Register should be Successful for SA
    [Teardown]    Run Keyword If Test Passed    Log    ue_register_is_ok

UE Deregister
    [Tags]    FULL_RUN    Deregister    [flow]L3 Call    SA
    [Documentation]    -SA- Check if UE deregisters
    [Setup]    Requires Tc   UE Register
    UE Deregister should be Successful for SA
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
    [Teardown]    Run Keyword If Test Passed    Log    sa_traffic_is_ok

SA UE Deregister
    [Tags]    FULL_RUN    Deregister    [flow]L3 Call    SA
    [Setup]    Requires Tc   SA Traffic
    UE Deregister should be Successful
    [Teardown]    Run Keywords
    ...           UE Deregister Test Teardown for SANSA    AND
    ...           Run Keyword If Test Passed    Log    sa_ue_deregister_is_ok

LTE Attach
    [Tags]    FULL_RUN    Attach    [flow]L3 Call    NSA
    [Documentation]    -NSA- Check if UE attaches to LTE 
    [Setup]    Run Keywords    Requires Tc    Verify Cell Setup for AP
    ...     AND    UE Attach test setup for NSA
    LTE Attach should be Successful
    [Teardown]    Run Keyword If Test Passed    Log    lte_attach_is_ok

UE Attach
    [Tags]    FULL_RUN    Attach    [flow]L3 Call    NSA
    [Documentation]    -NSA- Check if UE attaches to NR
    [Setup]    Requires Tc    LTE Attach
    UE Attach should be Successful
    [Teardown]    Run Keywords    Pre_Check
    ...           AND             Run Keyword If Test Passed    Log    ue_attach_is_ok

NSA Traffic
    [Tags]    FULL_RUN    Traffic    [flow]L3 Call    NSA
    [Setup]    Requires Tc    UE Attach
    Traffic for NSA should be Successful
    [Teardown]    Run Keywords    
    ...           NSA Traffic Teardown          AND
    ...           Delete Pcaps from Traffic     AND
    ...           Run Keyword If Test Passed    Log    nsa_traffic_is_ok

UE 5GDetach
    [Tags]    FULL_RUN    Detach    [flow]L3 Call    NSA
    [Documentation]    -NSA- Check if UE detaches to NR
    [Setup]    Requires Tc    UE Attach
    UE 5GDetach should be Successful
    [Teardown]    Run Keyword If Test Passed    Log    5gdetach_is_ok

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
    [Teardown]    Run Keyword If Test Passed    Log    reattach_is_ok
    
Lock Unlock Cells and Perform L3 call
    [Documentation]    Lock Cell-1 and Cell-3, then unlock cells and perform L3 call operations
    [Tags]    FULL_RUN    vDU_Cell_Lock_Unlock    [flow]L3 Call    SA    NSA
    Disconnect UEs
    Lock Cell In vDU    ${cell_ids}
    Unlock Cell In vDU    ${cell_ids}
    AP Cell Setup should be Successful
    UE Reregister should be Successful for SANSA
    UE Reattach should be Successful
    Start and Validate Traffic For Mixed Mode    duration=${traffic_duration}
    [Teardown]    Disconnect UEs
