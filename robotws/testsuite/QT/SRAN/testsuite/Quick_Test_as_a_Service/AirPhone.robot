*** Settings ***
Force Tags    PY39    RF50

Documentation
...        author: Emilia Sadowska
...        contact: emilia.sadowska@nokia.com
...        description: Automated triggerring Quick Test as a Service testsuite for AirPhone.

Resource    ${CURDIR}/../../../../Bangalore/AirPhone/QT/resources/Keywords/common_keywords.robot
Resource    ${CURDIR}/../../../../Bangalore/AirPhone/QT/resources/Keywords/allowed_alarms.robot
Resource    ${CURDIR}/../../resources/robot/airphone.robot
Library     ${CURDIR}/../../resources/python/airphone.py

Suite Setup       Run Keywords    Run Keyword And Ignore Error    Checkout To Robotws Branch
...               AND             Set Global Variable    ${component_carrier}    2
...               AND             Set Global Variable    ${WTS_CONFIG}           ${True}
...               AND             Common Optimized Suite Setup
...               AND             Get Baseline
...               AND             Run Keyword And Ignore Error    Setup And Connect IM
Suite Teardown    Run Keywords    Common Suite Teardown
...               AND             Copy logs to test_results

*** Test Cases ***
Install gNB Package
    [Tags]    FULL_RUN    swUpgrade    SA    NSA
    [Setup]    Stop Edaemon Egate
    Install gNB package    sw_version=${sw_version}
    Check SW version
    [Teardown]    Wait until Keyword Succeeds    3x    10s    Run WTS

Verify NG Link Status
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup
    [Setup]    Requires TC    Install gNB package
    NG Link Should be UP
    Address Distribution should be Successful
    UE SIB Decoding should be Successful
    BuiltIn.Sleep    5s
    [Teardown]    Run Keyword If Test Passed    Log    ng_link_status_is_ok

Verify X2 Connection
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup
    [Setup]    Requires TC    Verify Ng Link Status
    X2AP Link Should be UP
    BuiltIn.Sleep    5s
    [Teardown]    Run Keyword If Test Passed    Log   x2_is_ok

Verify Cell Setup
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup
    [Setup]    Requires TC    X2 Connection
    AP Cell Setup should be Successful
    [Teardown]    Run Keywords    Run Keyword If Test Passed    Log    cell_setup_is_ok
    ...           AND             Test Teardown for Cell Setup

Perform Commissioning
    [Tags]    FULL_RUN    COMMISSIONING    scf    SA    NSA
    [Setup]    Requires TC    Verify Cell Setup for AP
    Perform commissioning
    [Teardown]    Wait until Keyword Succeeds    3x    10s    Run WTS

Verify NG Link Status After Commissioning
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup
    [Setup]    Requires TC    Perform Commissioning
    NG Link Should be UP
    Address Distribution should be Successful
    UE SIB Decoding should be Successful
    BuiltIn.Sleep    5s
    [Teardown]    Run Keyword If Test Passed    Log    ng_link_status_is_ok

Verify X2 Connection After Commissioning
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup
    [Setup]    Requires TC    Verify Ng Link Status After Commissioning
    X2AP Link Should be UP
    BuiltIn.Sleep    5s
    [Teardown]    Run Keyword If Test Passed    Log    x2_is_ok

Verify Cell Setup After Commissioning
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup
    [Setup]    Requires TC    X2 Connection After Commissioning
    AP Cell Setup should be Successful
    [Teardown]    Run Keywords    Run Keyword If Test Passed    Log    cell_setup_is_ok
    ...           AND             Test Teardown for Cell Setup

UE Attach
    [Tags]    FULL_RUN    Attach    [flow]L3 Call
    [Setup]    Run Keywords    Requires Tc    Verify Cell Setup for AP After Commissioning
    ...        AND             Requires TC    Install gNB package
    UE Register should be Successful for SANSA
    UE Deregister should be Successful
    UE Reregister should be Successful for SANSA
    LTE Attach should be Successful
    UE Attach should be Successful
    [Teardown]    Run Keywords    Pre_Check
    ...           AND             Run Keyword If Test Passed    Log    ue_attach_is_ok

UE Data Transfer
    [Tags]    FULL_RUN    Traffic    [flow]L3 Call
    [Setup]    Requires Tc    UE Attach
    Start and Validate Traffic For Mixed Mode
    [Teardown]    Run Keywords
    ...           Stop Attach and Data Traffic TCPDUMP    AND
    ...           Delete Pcaps from Traffic

UE Detach
    [Tags]    FULL_RUN    Detach    [flow]L3 Call
    [Setup]    Requires Tc    UE Data Transfer
    UE 5GDetach should be Successful
    UE Detach should be Successful
    [Teardown]    Run Keywords    Run Keyword If Test Passed    Log    detach_is_ok
    ...           AND             Collect gNB Snapshot via adminAPI

Install gNB Package T1
    [Tags]    FULL_RUN    T1    SA    NSA
    [Setup]    Run Keywords    Requires Tc    Verify Cell Setup for AP After Commissioning
    ...        AND             Requires TC    Install gNB package
    ...        AND             Stop Edaemon Egate
    Install gNB package    sw_version=${sw_version}    component=T1
    Wait Until Keyword Succeeds    5min    20s    Check SW version       component=T1
    [Teardown]    Wait until Keyword Succeeds    3x    10s    Run WTS

Verify NG Link Status T1
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup
    [Setup]    Requires Tc    Install gNB package T1
    NG Link Should be UP
    Address Distribution should be Successful
    UE SIB Decoding should be Successful
    BuiltIn.Sleep    5s
    [Teardown]    Run Keyword If Test Passed    Log    ng_link_status_is_ok

Verify X2 Connection T1
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup
    [Setup]    Requires Tc    Verify Ng Link Status T1
    X2AP Link Should be UP
    BuiltIn.Sleep    5s
    [Teardown]    Run Keyword If Test Passed    Log   x2_is_ok

Verify Cell Setup T1
    [Tags]    FULL_RUN    CellSetup    [flow]Cell Setup
    [Setup]    Requires Tc    X2 Connection T1
    AP Cell Setup should be Successful
    [Teardown]    Run Keywords    Run Keyword If Test Passed    Log    cell_setup_is_ok
    ...           AND             Test Teardown for Cell Setup

Check Active And Historical Alarms
    [Tags]     FULL_RUN    NSA    QT    [flow]L3 Call
    [Setup]    Append To List    ${AP_ALLOWED_ALARMS}    7308
    Check Alarms In Ims File    name=_all_test_    allowed_alarms=${AP_ALLOWED_ALARMS}
    [Teardown]    Run Keyword If Test Passed    Log    check_allowed_alarms_is_ok
