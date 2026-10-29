# Copyright (c) 2020 Nokia. All rights reserved.

*** Settings ***
Documentation    This suite contains testcases for Parallel Traffic execution
Resource    resources/Keywords/common_keywords.robot

Suite Setup       Common Optimized Suite Setup
Suite Teardown    Common Suite Teardown

*** Test Cases ***
Verify Ng Link Status
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup
    [Documentation]    -SA- Check if "NG link is UP" message can be found in egate console and egate_console.log
    NG Link Should be UP
    [Teardown]    Run Keyword If Test Passed    Log    ng_link_status_is_ok

Verify Address Distribution
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup
    [Documentation]    -SANSA- Check if "Address Distribution is complete" message can be found in APL3.log
    Address Distribution should be Successful
    [Teardown]    Run Keyword If Test Passed    Log    address_distribution_is_ok

UE SIB Decoding
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup
    [Documentation]    -SA- Check if "SystemInformationBlockType1" message can be found in egate console and egate_console.log
    UE SIB Decoding should be Successful
    sleep    5s
    [Teardown]    Run Keyword If Test Passed    Log    ue_sib_decoding_is_ok

X2 Connection
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup
    [Documentation]    -NSA- check if "X2AP Link with GNB" msg found in egate console
    X2AP Link Should be UP
    sleep    5s
    [Teardown]    Run Keyword If Test Passed    Log    x2_is_ok

Verify Cell Setup for AP
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup
    [Documentation]    -SANSA- Check if "Cell Setup completed" message can be found in APL3.log
    AP Cell Setup should be Successful
    [Teardown]    Run Keywords    Run Keyword If Test Passed    Log    cell_setup_is_ok
    ...           AND             Test Teardown for Cell Setup

UE Register
    [Tags]    FULL_RUN    Register    [flow]L3 Call
    [Documentation]    -SA- Check if UE registers
    [Setup]    Requires Tc    Verify Cell Setup for AP
    UE Register should be Successful for SANSA
    [Teardown]    Run Keywords    Test Teardown for UE_Register
    ...           AND             Run Keyword If Test Passed    Log    ue_register_is_ok

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
    [Setup]    Run Keywords    Requires Tc    X2 Connection
    ...        AND    Requires Tc    Verify Cell Setup for AP
    LTE Attach should be Successful
    [Teardown]    Run Keyword If Test Passed    Log    lte_attach_is_ok

UE Attach
    [Tags]    FULL_RUN    Attach    [flow]L3 Call
    [Documentation]    -NSA- Check if UE attaches to NR
    [Setup]    Requires Tc    LTE Attach
    UE Attach should be Successful
    [Teardown]    Run Keywords    Pre_Check
    ...           AND             Run Keyword If Test Passed    Log    ue_attach_is_ok

Traffic
    [Tags]    FULL_RUN    Traffic    [flow]L3 Call
    [Documentation]    -SA- -NSA- Traffic
    [Setup]    Run Keywords    Requires Tc    UE Reregister    AND    Requires Tc    UE Attach    AND
    ...        Test Setup for Parallel Traffic
    Start and Validate Traffic For Mixed Mode
    [Teardown]    Run Keywords
    ...    Parallel Traffic Teardown    AND
    ...    Run Keyword If Test Passed    Log    traffic_is_ok

UE 5GDetach
    [Tags]    FULL_RUN    Detach    [flow]L3 Call
    [Documentation]    -NSA- Check if UE detaches to NR
    [Setup]    Requires Tc    UE Attach
    UE 5GDetach should be Successful
    [Teardown]    Run Keyword If Test Passed    Log    5gdetach_is_ok

UE Detach
    [Tags]    FULL_RUN    Detach    [flow]L3 Call
    [Documentation]    -NSA- Check if UE detaches to LTE
    [Setup]    Requires Tc    UE Attach
    UE Detach should be Successful
    [Teardown]    Run Keyword If Test Passed    Log    detach_is_ok

UE Reattach
    [Tags]    FULL_RUN    Reattach    [flow]L3 Call
    [Documentation]    -NSA- Check if UE attaches to NR
    [Setup]    Requires Tc    UE Detach
    UE Reattach should be Successful
    [Teardown]    Run Keyword If Test Passed    Log    ue_reattach_is_ok

Check Active And Historical Alarms
    [Tags]    FULL_RUN    NSA    QT    [flow]L3 Call
    Check Alarms In Ims File    name=_all_test_    allowed_alarms=${AP_ALLOWED_ALARMS}
    [Teardown]    Run Keyword If Test Passed    Log    check_allowed_alarms_is_ok
