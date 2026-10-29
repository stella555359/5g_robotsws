*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown
Test Timeout         60 min

Resource    ./resource/CB008941_Common_KW.robot

Documentation
...    Author: Zhang Xuewen
...    Contact: xuewen.zhang@nokia-sbell.com
...    squad group:SG_05
...    Feature CB008941 in 5G23R3 program


Force Tags    RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00    PY39    master_classicalbts_all

*** Variables ***

*** Test Cases ***
[1]CB008941-SR-C_2_L3_Call_Loki_based_DU_with_DL_PRB_muting_active_FDBF
    [Tags]    master_classicalbts_all    CRT_TRUNK    CLOUD_5G_CLASSICAL_ASIBR_ABIOB4_AQQL_ENB    CRT_UTE
    L3_Call_Loki_based_DU_with_DL_PRB_muting_active_FDBF

[2]CB008941-SR-C_2_L3_Call_Loki_based_DU_with_DL_PRB_muting_active_FDBF
    [Tags]    master_classicalbts_all    CRT_TRUNK    CDRT_TRUNK    AEQE
    L3_Call_Loki_based_DU_with_DL_PRB_muting_active_FDBF

*** Keywords ***
