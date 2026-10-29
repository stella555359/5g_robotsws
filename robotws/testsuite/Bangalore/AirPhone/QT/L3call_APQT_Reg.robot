# Copyright (c) 2020 Nokia. All rights reserved.

*** Settings ***
Documentation    This suite contains testcases for sequential Traffic execution
Resource    resources/Keywords/common_keywords.robot

Suite Setup       Common Optimized Suite Setup
Suite Teardown    Common Suite Teardown


*** Test Cases ***
Verify Ng Link Status
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    SA    ecpri72
    [Documentation]    -SA- Check if "NG link is UP" message can be found in egate console and egate_console.log
    NG Link Should be UP
    [Teardown]    Run Keyword If Test Passed    Log    ng_link_status_is_ok

Verify Address Distribution
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    SA    ecpri72
    [Documentation]    -SA- Check if "Address Distribution is complete" message can be found in APL3.log
    Address Distribution should be Successful
    [Teardown]    Run Keyword If Test Passed    Log    address_distribution_is_ok

UE SIB Decoding
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    SA    ecpri72
    [Documentation]    -SA- Check if "SystemInformationBlockType1" message can be found in egate console and egate_console.log
    UE SIB Decoding should be Successful
    sleep    5s
    [Teardown]    Run Keyword If Test Passed    Log    ue_sib_decoding_is_ok

X2 Connection
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    SA    NSA
    [Documentation]    -NSA- check if "X2AP Link with GNB" msg found in egate console
    X2AP Link Should be UP
    sleep    5s
    [Teardown]    Run Keyword If Test Passed    Log   x2_is_ok

Verify Cell Setup for AP
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    SA    NSA    ecpri72
    [Documentation]    -SANSA- Check if "Cell Setup completed" message can be found in APL3.log
    AP Cell Setup should be Successful
    sleep    5s
    [Teardown]    Run Keywords    Run Keyword If Test Passed    Log    cell_setup_is_ok
    ...           AND            Test Teardown for Cell Setup

verify NG link lock and unlock
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    SA    ecpri72
    [Documentation]    -SA- Check if NG link lock and unlock success
	FOR    ${i}    IN RANGE    ${NG_LOCK_UNLOCK_ITERATION}
        NG link lock and unlock
	END
    [Teardown]    Run Keyword If Test Passed    Log    ng_link_status_is_ok

UE Register
    [Tags]    FULL_RUN    Register    [flow]L3 Call    SA    ecpri72
    [Documentation]    -SA- Check if UE registers
    [Setup]    Requires Tc    Verify Cell Setup for AP
    UE Register should be Successful for SANSA
    [Teardown]    Run Keyword If Test Passed    Log    ue_register_is_ok

LTE Attach
    [Tags]    FULL_RUN    Attach    [flow]L3 Call    NSA
    [Documentation]    -NSA- Check if UE attaches to LTE
    [Setup]    Requires Tc    Verify Cell Setup for AP
    LTE Attach should be Successful
    [Teardown]    Run Keyword If Test Passed    Log    lte_attach_is_ok

UE Attach
    [Tags]    FULL_RUN    Attach    [flow]L3 Call    NSA
    [Documentation]    -NSA- Check if UE attaches to NR
    [Setup]    Requires Tc    LTE Attach
    UE Attach should be Successful
    [Teardown]    Run Keywords    Pre_Check
    ...           AND             Run Keyword If Test Passed    Log    ue_attach_is_ok

SA Traffic
    [Tags]    FULL_RUN    Traffic    [flow]L3 Call    SA    ecpri72
    [Setup]    Run Keywords    Requires Tc   UE Register    AND    Test Setup for SA Traffic
    Traffic for SA should be Successful
    [Teardown]    Run Keywords
    ...           Test Teardown for SA Traffic    AND
    ...           Run Keyword If Test Passed    Log    sa_traffic_is_ok

NSA Traffic
    [Tags]    FULL_RUN    Traffic    [flow]L3 Call    NSA
    [Setup]    Run Keywords    Requires Tc    UE Attach    AND    Test Setup for NSA Traffic
    Traffic for NSA should be Successful
    [Teardown]    Run Keywords
    ...           NSA Traffic Teardown          AND
    ...           Run Keyword If Test Passed    Log    nsa_traffic_is_ok

UE Deregister
    [Tags]    FULL_RUN    Deregister    [flow]L3 Call    SA    ecpri72
    [Documentation]    -SA- Check if UE deregisters
    [Setup]    Requires Tc   UE Register
    UE Deregister should be Successful
    [Teardown]    Run Keyword If Test Passed    Log    ue_deregister_is_ok

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

Perform Cell Block Unblock_2
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    SA    NSA    ecpri72
    Perform Cell Block Unblock For All Cells Check
    [Teardown]    Run Keyword If Test Passed    Log    cell_setup_is_ok

UE Reregister_post_cell_block_unblock
    [Tags]    FULL_RUN    Reregister    [flow]L3 Call    SA    ecpri72
    [Documentation]    -SA- Check if UE reregisters
    [Setup]    Requires Tc    NG Link Lock and Unlock
    UE Reregister should be Successful for SANSA
    [Teardown]    Run Keyword If Test Passed    Log    ue_re-register_is_ok

LTE Attach_post_cell_block_unblock
    [Tags]    FULL_RUN    Attach    [flow]L3 Call    NSA
    [Documentation]    -NSA- Check if UE attaches to LTE
    [Setup]    Requires Tc    Verify Cell Setup for AP
    LTE Attach should be Successful
    [Teardown]    Run Keyword If Test Passed    Log    lte_attach_is_ok

UE Attach_post_cell_block_unblock
    [Tags]    FULL_RUN    Attach    [flow]L3 Call    NSA
    [Documentation]    -NSA- Check if UE attaches to NR
    [Setup]    Requires Tc    LTE Attach
    UE Attach should be Successful
    [Teardown]    Run Keywords    Pre_Check
    ...           AND             Run Keyword If Test Passed    Log    ue_attach_is_ok

SA Traffic_post_cell_block_unblock
    [Tags]    FULL_RUN    Traffic    [flow]L3 Call    SA    ecpri72
    [Setup]    Run Keywords    Requires Tc   UE Register    AND    Test Setup for SA Traffic
    Traffic for SA should be Successful
    [Teardown]    Run Keywords
    ...           Test Teardown for SA Traffic    AND
    ...           Run Keyword If Test Passed    Log    sa_traffic_is_ok

NSA Traffic_post_cell_block_unblock
    [Tags]    FULL_RUN    Traffic    [flow]L3 Call    NSA
    [Setup]    Run Keywords    Requires Tc    UE Attach    AND    Test Setup for NSA Traffic
    Traffic for NSA should be Successful
    [Teardown]    Run Keywords
    ...           NSA Traffic Teardown          AND
    ...           Run Keyword If Test Passed    Log    nsa_traffic_is_ok

UE Deregister_post_cell_block_unblock
    [Tags]    FULL_RUN    Deregister    [flow]L3 Call    SA    ecpri72
    [Documentation]    -SA- Check if UE deregisters
    [Setup]    Requires Tc   UE Register
    UE Deregister should be Successful
    [Teardown]    Run Keyword If Test Passed    Log    ue_deregister_is_ok

UE 5GDetach_post_cell_block_unblock
    [Tags]    FULL_RUN    Detach    [flow]L3 Call    NSA
    [Documentation]    -NSA- Check if UE detaches to NR
    [Setup]    Requires Tc    UE Attach
    UE 5GDetach should be Successful
    [Teardown]    Run Keyword If Test Passed    Log    5gdetach_is_ok

UE Detach_post_cell_block_unblock
    [Tags]    FULL_RUN    Detach    [flow]L3 Call    NSA
    [Documentation]    -NSA- Check if UE detaches to LTE
    [Setup]    Requires Tc    UE Attach
    UE Detach should be Successful
    [Teardown]    Run Keyword If Test Passed    Log    detach_is_ok

Check Active And Historical Alarms Before Site Reset
    [Tags]    FULL_RUN    NSA    SA    QT    [flow]L3 Call    ecpri72
    Check Alarms In Ims File For Pre Stability Test    name=_all_test_    allowed_alarms=${AP_ALLOWED_ALARMS}
    [Teardown]    Run Keywords
	...    Run Keyword If Test Passed    Log    check_allowed_alarms_is_ok    AND
	...    Collect UTE SosReport

BTS Site Reset
    [Tags]    FULL_RUN    Detach    [flow]L3 Call    NSA
    [Documentation]    -BTS Site Reset- Check if reset site success
    Reset Site and Check BTS Status
    [Teardown]    Run Keyword If Test Passed    Log    reset site_is_ok

Enable Multi BeamForming SANSA
    BeamForming Profile creation
    Enable SA Multi UE BeamForming
    Enable NSA Multi UE BeamForming

UE Register/Attach for Multi BeamForming
    [Tags]    FULL_RUN    Register    [flow]L3 Call    SA    ecpri72
    [Documentation]    -SA- Check if UE registers
    [Setup]    Requires Tc    Verify Cell Setup for AP
    UE Register should be Successful for Multi BeamForming SANSA
    LTE Attach should be Successful for Multi BeamForming
    UE Attach should be Successful for Multi BeamForming
    [Teardown]    Run Keyword If Test Passed    Log    ue_register_attach_is_ok

Check Active And Historical Alarms After Site Reset
    [Tags]    FULL_RUN    NSA    SA    QT    [flow]L3 Call    ecpri72
    Check Alarms In Ims File For Post Stability Test    name=_all_test_    allowed_alarms=${AP_ALLOWED_ALARMS}
    [Teardown]    Run Keyword If Test Passed    Log    check_allowed_alarms_is_ok
