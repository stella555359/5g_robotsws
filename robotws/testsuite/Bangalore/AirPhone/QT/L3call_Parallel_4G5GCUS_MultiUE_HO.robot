# Copyright (c) 2021 Nokia. All rights reserved.

*** Settings ***
Documentation    This suite contains testcases for 4G5G Fullrack Combo Testline execution
Resource    resources/Keywords/combo_mue_keywords.robot
Resource    resources/Keywords/cus_mue_keywords.robot
Library    ta_messaging

Suite Setup       Common Optimized Suite Setup
Suite Teardown    Common Suite Teardown

*** Test Cases ***
Verify Ng Link Status
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    SA    Mix_Operator
    [Documentation]    -SA- Check if "NG link is UP" message can be found in egate console and egate_console.log
    NG Link Should be UP

Verify Address Distribution
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    SA    Mix_Operator
    [Documentation]    -SA- Check if "Address Distribution is complete" message can be found in APL3.log
    Address Distribution should be Successful

UE SIB Decoding
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    SA    Mix_Operator
    [Documentation]    -SA- Check if "SystemInformationBlockType1" message can be found in egate console and egate_console.log
    UE SIB Decoding should be Successful
    sleep    5s

CUS Egate Sync
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    SA    NSA    LTE    Mix_Operator
    [Documentation]    Steps to sync between egate and CUS
    Configure CUS Executor should be Successful

Verify Cell Setup for AP
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    SA    NSA    LTE    Mix_Operator
    [Documentation]    -SANSA- Check if "Cell Setup completed" message can be found in APL3.log
    AP Cell Setup should be Successful
    sleep    10s

SA UE Register
    [Tags]    FULL_RUN     SA    [flow]L3 Call    Mix_Operator
    [Documentation]    -SA- Check if 20 UEs Register completes
    [Setup]    Requires Tc    Verify Cell Setup for AP
    SA Register for MultiUE

SA Traffic
    [Tags]    FULL_RUN    SA    [flow]L3 Call    Mix_Operator
    [Documentation]    -SA- Start SA Traffic
    [Setup]    Requires Tc    SA UE Register
    Start SA Traffic for Combo MultiUE

LTE Attach
    [Tags]    FULL_RUN    LTE    [flow]L3 Call    Mix_Operator
    [Documentation]    LTE Attach for 20 UEs Completion
    [Setup]    Requires Tc    Verify Cell Setup for AP
    LTE attach for CUS MultiUE

LTE Traffic
    [Tags]    FULL_RUN    LTE    [flow]L3 Call    Mix_Operator
    [Documentation]    Start LTE traffic
    [Setup]    Requires Tc    LTE Attach
    Start LTE Traffic For CUS MultiUE

NSA Attach
    [Tags]    FULL_RUN    NSA    [flow]L3 Call    Mix_Operator
    [Documentation]    NSA UE attach for 20 UEs
    [Setup]    Requires Tc    Verify Cell Setup for AP
    NSA Attach for CUS MultiUE

NSA Traffic
    [Tags]    FULL_RUN    NSA    [flow]L3 Call    Mix_Operator
    [Documentation]    Start NSA traffic
    [Setup]    Requires Tc    NSA Attach
    Start NSA Traffic for CUS MultiUE

Validatation of Traffic Before HO
    [Tags]    FULL_RUN    [flow]L3 Call    Mix_Operator
    [Documentation]    Validate Traffic Before Handover
    [Setup]    Run Keywords    Requires Tc    SA UE Register
    ...                        AND    Requires Tc    LTE Attach
    ...                        AND    Requires Tc    NSA Attach
    Validate SA LTE and NSA Data rates Before HO For CUS

SA NSA Forward HO
    [Tags]    FULL_RUN    SANSA    [flow]L3 Call    Mix_Operator
    [Documentation]    Start SA and NSA HO During HO During Traffic and Validate
    [Setup]    Requires Tc    Validatation of Traffic Before HO
    Start SA NSA Forward HO for CUS and Validate

SA NSA Reverse HO
    [Tags]    FULL_RUN    SANSA    [flow]L3 Call    Mix_Operator
    [Documentation]    Start SA and NSA Reverse HO During Traffic and Validate
    [Setup]    Requires Tc    SA NSA Forward HO
    Start SA NSA Reverse HO for CUS and Validate

Stop Traffic and Validate Throughput
    [Tags]    FULL_RUN    [flow]L3 Call    Mix_Operator
    [Documentation]    Stop the Ongoing Traffic and Validate the traffic
    [Setup]    Requires Tc    SA NSA Reverse HO
    Stop Traffic for SA NSA LTE and Validate Throughput for CUS
    [Teardown]    MUEs Test Failure Teardown    mix

Validate Six Operator Mix To Mix UL Traffic Split
    [Tags]    FULL_RUN    SANSA    [flow]L3 Call    Mix_Operator    Split_Traffic
    [Documentation]    This test case verifies UL Split Traffic using X2 and F1 PM Counters
    ...                with mix_to_mix config files.
    Attach NSA Split Traffic for CUS
    [Teardown]    MUEs Test Failure Teardown    Split_Traffic

L3 Call With DS Operator Settings
    [Tags]    FULL_RUN    SANSA    [flow]L3 Call    DS_Operator
    [Documentation]    This test case loads DS operator SCF and Test all the L3 call steps
    ...                like done above for mix operator
    [Setup]    Run Keywords    Bringup Setup After Commissioning    DS
    ...                        AND    NG Link Should be UP
    ...                        AND    Address Distribution should be Successful
    ...                        AND    UE SIB Decoding should be Successful
    ...                        AND    CUS and Egate Sync for DS and IPV4
    sleep    10s
    Start L3 Call and HO For CUS DS Operator and Validate
    [Teardown]    MUEs Test Failure Teardown    DS

L3 Call With IPv4 Operator Settings
    [Tags]    FULL_RUN    SANSA    [flow]L3 Call    IPv4_Operator
    [Documentation]    This test case loads DS operator SCF and Test all the L3 call steps
    ...                like done above for mix operator
    [Setup]    Run Keywords    Bringup Setup After Commissioning    IPv4
    ...                        AND    NG Link Should be UP
    ...                        AND    Address Distribution should be Successful
    ...                        AND    UE SIB Decoding should be Successful
    ...                        AND    CUS and Egate Sync for DS and IPV4
    sleep    10s
    Start L3 Call and HO For CUS IPV4 Operator and Validate
    [Teardown]    MUEs Test Failure Teardown    DS

Validate GTPU Path Supervision
    [Tags]    FULL_RUN    SANSA    [flow]L3 Call    GTPU_Path
    [Documentation]    Load SCF and verify GTPU path supervision for LTE NSA and SA
    [Setup]    Run Keywords    Copy GTPU Path Text File to eNB
    ...                        AND    Bringup Setup After Commissioning    GTPU
    sleep    10s
    Verify GTPU Alarm And ECHO Messages
    [Teardown]    GTPU Teardown


