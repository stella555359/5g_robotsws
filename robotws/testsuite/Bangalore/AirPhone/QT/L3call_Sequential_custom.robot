# Copyright (c) 2020 Nokia. All rights reserved.

*** Settings ***
Documentation    This suite contains testcases for sequential Traffic execution
Resource    resources/Keywords/common_keywords.robot

Suite Setup       Common Optimized Suite Setup
Suite Teardown    Common Suite Teardown

Test Timeout      60 minutes

*** Variables ***
${traffic_duration}    30s

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
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup    NSA
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
    ...           AND             Test Teardown for Cell Setup

UE Register
    [Tags]    FULL_RUN    Register    [flow]L3 Call    SA    ecpri72
    [Documentation]    -SA- Check if UE registers
    [Setup]    Requires Tc    Verify Cell Setup for AP
    UE Register should be Successful for SANSA
    [Teardown]    Run Keywords    Test Teardown for UE_Register
    ...           AND             Run Keyword If Test Passed    Log    ue_register_is_ok

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

UE Reregister
    [Tags]    FULL_RUN    Reregister    [flow]L3 Call    SA    ecpri72
    [Documentation]    -SA- Check if UE reregisters
    [Setup]    Requires Tc    UE Deregister
    UE Reregister should be Successful for SANSA
    [Teardown]    Run Keyword If Test Passed    Log    ue_re-register_is_ok

SA UE Deregister
    [Tags]    FULL_RUN    Deregister    [flow]L3 Call    SA    ecpri72
    [Setup]    Requires Tc   SA Traffic
    UE Deregister should be Successful
    [Teardown]    Run Keywords
    ...           UE Deregister Test Teardown for SANSA    AND
    ...           Run Keyword If Test Passed    Log    sa_ue_deregister_is_ok

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

Check Active And Historical Alarms
    [Tags]    FULL_RUN    NSA    QT    [flow]L3 Call
    Check Alarms In Ims File    name=_all_test_    allowed_alarms=${AP_ALLOWED_ALARMS}
    [Teardown]    Run Keyword If Test Passed    Log    check_allowed_alarms_is_ok

L3 Call after OAM Operation
    [Documentation]    Do a specific OAM operation and perform L3 call operations
    [Tags]    FULL_RUN    [flow]L3 Call    SA    NSA
    [Setup]    Run Keyword and Ignore Error    Set WTS Default Log Level to Error Level
    Set Suite Variable    ${HIGH_THROUGHPUT_FLAG}    True
    FOR    ${iter}    IN RANGE    ${OPERATION_ITERATION}
        L3 call and Operation on System
    END
    [Teardown]    Run Keywords
    ...    Run Keyword and Ignore Error    Set WTS Default Log Level to Debug    AND
    ...    Run Keyword If Test Passed    Log    OAM_Operation_with_L3_call_is_ok    AND
    ...    Run Keyword If Test Failed    Run Keyword and Ignore Error    Get Cell Info for Classical

Check Active And Historical Alarms After OAM Operation
    [Tags]    FULL_RUN    NSA    SA    QT    [flow]L3 Call    ecpri72
    Run Keyword And Ignore Error    Check Alarms In Ims File
    ...    name=_all_test_    allowed_alarms=${AP_ALLOWED_ALARMS}
    [Teardown]    Run Keyword If Test Passed    Log    check_allowed_alarms_after_oam_is_ok

*** Keywords ***
L3 Call and Operation on System
    UE Reregister should be Successful for SANSA
    Start Traffic For SA With Mixed Mode
    Start Traffic For NSA With Mixed Mode
    Perform Operation on System
    Run Keyword and Ignore Error    UE status check
    Stop Traffic For NSA With Mixed Mode
    UE Detach should be Successful
    UE Deregister should be Successful for lock and unlock
    IF    "${operation_keyword['${apConfiguration}']}" == "Perform NR Cell Lock and Unlock"
        AP Cell Setup should be Successful for multiple cellsetup
    ELSE IF    "${operation_keyword['${apConfiguration}']}" == "Perform Soft Cell Reset via Param Update for Classical gNB"
        Log To Console   For Soft Cell reset Validation already completed
    ELSE
        AP Cell Setup For Special Operation
    END
    UE Reregister should be Successful for SANSA
    UE Reattach should be Successful
    Start and Validate Traffic For Mixed Mode    duration=${traffic_duration}

AP Cell Setup For Special Operation
    ${orig_val}    Set Variable    ${component_carrier}
    ${tmp_val}    Evaluate    ${component_carrier}-1
    Set Suite Variable    ${component_carrier}    ${tmp_val}
    AP Cell Setup should be Successful for multiple cellsetup
    Set Suite Variable    ${component_carrier}    ${orig_val}
