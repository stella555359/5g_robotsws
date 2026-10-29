# Copyright (c) 2020 Nokia. All rights reserved.

*** Settings ***
Documentation    This contains testcase for 6G

Resource    resources/Keywords/common_keywords.robot
Suite Setup    Suite Setup for 6G
Suite Teardown    Common Suite Teardown

*** Test Cases ***
Verify Ng Link Status
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    SA
    [Documentation]    -SA- Check if "NG link is UP" message can be found in egate console and egate_console.log
    NG Link Should be UP
    [Teardown]    Run Keyword If Test Passed    Log    ng_link_status_is_ok

Verify Address Distribution
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    SA
    [Documentation]    -SA- Check if "Address Distribution is complete" message
    Address Distribution should be Successful For 6G
    [Teardown]    Run Keyword If Test Passed    Log    address_distribution_is_ok

UE SIB Decoding
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    SA
    [Documentation]    -SA- Check if "SystemInformationBlockType1" message can be found in egate console and egate_console.log
    UE SIB Decoding should be Successful For 6G
    sleep    5s
    [Teardown]    Run Keyword If Test Passed    Log    ue_sib_decoding_is_ok

Verify Cell Setup for AP
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    SA    NSA
    [Documentation]    -SANSA- Check if "Cell Setup completed" message can be found in APL3.log
    AP Cell Setup should be Successful For 6G
    sleep    5s
    [Teardown]    Run Keyword If Test Passed    Log    cell_setup_is_ok

UE Register
    [Tags]    FULL_RUN    Register    [flow]L3 Call    SA
    [Documentation]    -SA- Check if UE registers
    [Setup]    Requires Tc    Verify Cell Setup for AP
    UE Register should be Successful for SANSA For 6G
    [Teardown]    Run Keyword If Test Passed    Log    ue_register_is_ok

UE Deregister
    [Tags]    FULL_RUN    Deregister    [flow]L3 Call    SA
    [Documentation]    -SA- Check if UE deregisters
    [Setup]    Requires Tc   UE Register
    UE Deregister should be Successful For 6G
    [Teardown]    Run Keyword If Test Passed    Log    ue_deregister_is_ok

UE Reregister
    [Tags]    FULL_RUN    Reregister    [flow]L3 Call    SA
    [Documentation]    -SA- Check if UE reregisters
    [Setup]    Run Keywords    Requires Tc    UE Deregister    AND    UE Register Test Setup for SANSA
    UE Reregister should be Successful for SANSA for 6G
    [Teardown]    Run Keyword If Test Passed    Log    ue_re-register_is_ok

SA Traffic
    [Tags]    FULL_RUN    Traffic    [flow]L3 Call    SA
    [Setup]    Requires Tc   UE Reregister
    Traffic for SA should be Successful for 6G
    [Teardown]    Run Keywords
    ...           Stop Attach and Data Traffic TCPDUMP    AND
    ...           Run Keyword If Test Passed    Log    sa_traffic_is_ok

SA UE Deregister
    [Tags]    FULL_RUN    Deregister    [flow]L3 Call    SA
    [Setup]    Requires Tc   UE Reregister
    UE Deregister should be Successful For 6G
    [Teardown]    Run Keyword If Test Passed    Log    sa_ue_deregister_is_ok

Check Active And Historical Alarms
    [Tags]    FULL_RUN    NSA    SA    QT    [flow]L3 Call
    Run Keyword And Ignore Error    Check Alarms In Ims File    name=_all_test_    allowed_alarms=${AP_ALLOWED_ALARMS}
    [Teardown]    Run Keyword If Test Passed    Log    check_allowed_alarms_is_ok

*** Keywords ***
Suite Setup for 6G
    [Documentation]    Local Suite setup keyword for 6G suite
    Update sysctl values suitable for Airphone
    Update UPF IPs for VM
    Common Optimized Suite Setup

