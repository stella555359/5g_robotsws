# Copyright (c) 2020 Nokia. All rights reserved.

*** Settings ***
Documentation     This contains testcase for VRAN 2.0 which can be merged with L3 Parallel suit once log collection procedures are added.
...               :author Abhishek P

Resource      resources/Keywords/common_keywords.robot

Suite Setup       Run Keywords    Common VDU Suite Setup
Suite Teardown    Run Keywords    Common Suite Teardown

*** Variables ***
${Disable_gNB_Log_Collection}    True
${traffic_duration}    90s
@{cell_ids}    1    3

*** Test Cases ***

X2 Connection
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup
    X2AP Link Should be UP
    sleep    5s
    [Teardown]    Run Keyword If Test Passed    Log    x2_is_ok

UE SIB Decoding
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup
    [Documentation]    -SA- Check if "SystemInformationBlockType1" message can be found in egate console and egate_console.log
    UE SIB Decoding should be Successful
    sleep    5s
    [Teardown]    Run Keyword If Test Passed    Log    ue_sib_decoding_is_ok

Verify Cell Setup for AP
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup
    [Documentation]    -SANSA- Check if "Cell Setup completed" message can be found in APL3.log
    AP Cell Setup should be Successful
    [Teardown]    Run Keyword If Test Passed    Log    cell_setup_is_ok

UE Register
    [Tags]    FULL_RUN    Register    [flow]L3 Call
    [Documentation]    -SA- Check if UE registers
    [Setup]    Run Keywords    Requires Tc    Verify Cell Setup for AP   AND    UE Register Test Setup for SANSA
    UE Register should be Successful for SANSA
    sleep    5s
    [Teardown]    Run Keyword If Test Passed    Log    ue_register_is_ok

UE Deregister
    [Tags]    FULL_RUN    Deregister    [flow]L3 Call
    [Documentation]    -SA- Check if UE deregisters
    [Setup]    Requires Tc   UE Register
    UE Deregister should be Successful
    [Teardown]    Run Keyword If Test Passed    Log    ue_deregister_is_ok

UE Reregister
    [Tags]    FULL_RUN    Reregister    [flow]L3 Call
    [Documentation]    -SA- Check if UE reregisters
    [Setup]    Requires Tc    UE Deregister
    UE Reregister should be Successful for SANSA
    [Teardown]    Run Keyword If Test Passed    Log    ue_re-register_is_ok

LTE Attach
    [Tags]    FULL_RUN    Attach    [flow]L3 Call
    [Documentation]    -NSA- Check if UE attaches to LTE
    [Setup]    Requires Tc    X2 Connection
    LTE Attach should be Successful
    [Teardown]    Run Keyword If Test Passed    Log    lte_attach_is_ok

UE Attach
    [Tags]    FULL_RUN    Attach    [flow]L3 Call
    [Documentation]    -NSA- Check if UE attaches to NR
    [Setup]    Requires Tc    LTE Attach
    UE Attach should be Successful
    [Teardown]    Run Keyword If Test Passed    Log    ue_attach_is_ok

Traffic
    [Tags]    FULL_RUN    Traffic    [flow]L3 Call
    [Documentation]    -SA- -NSA- Traffic
    [Setup]    Run Keywords    Requires Tc    UE Reregister    AND    Requires Tc    UE Attach
    Start and Validate Traffic For Mixed Mode
    [Teardown]    Run Keywords
    ...           Stop Attach and Data Traffic TCPDUMP    AND
    ...           Delete Pcaps from Traffic     AND
    ...           Run Keyword If Test Passed    Log    traffic_is_ok

UE 5GDetach
    [Tags]    FULL_RUN    Detach    [flow]L3 Call
    [Documentation]    -NSA- Check if UE detaches to NR
    UE 5GDetach should be Successful
    [Teardown]    Run Keyword If Test Passed    Log    5gdetach_is_ok

UE Detach
    [Tags]    FULL_RUN    Detach    [flow]L3 Call
    [Documentation]    -NSA- Check if UE detaches to LTE
    UE Detach should be Successful
    [Teardown]    Run Keyword If Test Passed    Log    detach_is_ok

UE Reattach
    [Tags]    FULL_RUN    Reattach    [flow]L3 Call
    [Documentation]    -NSA- Check if UE attaches to NR
    UE Reattach should be Successful
    [Teardown]    Run Keyword If Test Passed    Log    ue_reattach_is_ok

Lock Unlock Cells and Perform L3 call
    [Documentation]    Lock Cell-1 and Cell-3, then unlock cells and perform L3 call operations
    [Tags]    FULL_RUN    vDU_Cell_Lock_Unlock    [flow]L3 Call    SA    NSA
    Disconnect UEs
    Lock Cell In vDU    ${cell_ids}
    Unlock Cell In vDU    ${cell_ids}
    sleep    ${Total_Timeout}
    AP Cell Setup should be Successful
    UE Reregister should be Successful for SANSA
    UE Reattach should be Successful
    Start and Validate Traffic For Mixed Mode    duration=${traffic_duration}
    [Teardown]    Run Keyword If Test Passed    Log    Lock_unlock_is_ok
