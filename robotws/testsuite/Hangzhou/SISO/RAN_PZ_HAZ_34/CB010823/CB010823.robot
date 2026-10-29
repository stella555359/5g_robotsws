*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           Run Keywords  AlarmWatchdog.Add allow alarms  fault_id=4681  AND  SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown
Test Timeout         2h

Resource    ./resource/CB010823_Common_KW.robot

Documentation
...    Author: Zhang Xuewen
...    Contact: xuewen.zhang@nokia-sbell.com
...    squad group:SG_05
...    Feature CB010823 in SBTS24R1 program

Force Tags    RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00    PY39    master_classicalbts_all

*** Test Cases ***
#[1]CB010823-SR-A_1_Run FULL Diagnostic check from WebEM
#    [Tags]    SBTS00
#    FULL Diagnostic check from WebEM
[1]CB010823-SR-A_2_Run RF Diagnostic check online from WebEM
    [Tags]    CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AEQE    CRT_UTE
    RF Diagnostic check online from WebEM

[1]CB010823-SR-A_9_Automatic Execution of Diagnostic check from webEM with cell onAir
    [Tags]    CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AEQE    CRT_UTE
    Automatic Execution of Diagnostic check from webEM with cell onAir

[1]CB010823-SR-A_7_Check 4681 fault in NOK cases
    [Tags]    CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AEQE    CRT_UTE
    Check 4681 fault in NOK cases

[1]CB010823-SR-A_8_Scheduled Execution of Diagnostic check from WebEM
    [Tags]    CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AEQE    CRT_UTE
    Scheduled Execution of Diagnostic check from WebEM

[1]CB010823-SR-A_d_1_Run FULL Diagnostic check from WebEM_CP40_NOK
    [Tags]    CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AEQE    CRT_UTE
    Check from WebEM CP40 NOK

[1]CB010823-SR-B_3_Check 4681 fault in NOK cases
    [Tags]    CLOUD_5G_CLASSICAL_SA_ASIKL_ABILB1_AEQE    CRT_UTE
    Check from WebEM CP43 NOK
