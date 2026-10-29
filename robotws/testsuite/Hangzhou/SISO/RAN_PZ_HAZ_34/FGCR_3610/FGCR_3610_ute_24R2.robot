*** Settings ***
Documentation    Auther:xiaoxia.hao@nokia-sbell.com
Suite Setup    702 Suite Setup For UTE    is_reset_all_RF=${True}
Suite Teardown    702 Suite TearDown For UTE
Force Tags            5G_RAN_TDD    master_classicalbts_all
...    PY39
...           5G_RAN    SBTS00    SBTS24R2    SBTS23R3    SBTS23R4    SBTS24R1    CIT
...           RAN_5G    RAN_5G_TDD
Resource    Resources/FGCR_3610_case_common.robot
Variables    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/FGCR_3610/TestData/variables.py

*** Variables ***

*** Test Cases ***
[1]FGCR8131_A_1UE_1Sector_4DL_256QAM_MCS27_using_2SFP+_90MHz_AWHQE
    [Documentation]    CHBW:90MHz
    ...                Feature_ID:CNI-69677
    [Timeout]    90m
    [Setup]  702 Case SetUp For UTE
    FGCR8131_A_1UE_1Sector_4DL_256QAM_MCS27_using_2SFP+_90MHz_AWHQE
    [Teardown]   702 Case TearDown For UTE


[1][1.0] General_SiSo_Cell_lock_and_unlock
    [Documentation]    Feature_ID:5GC001274-A;FGCR-3610;FGCR-4454
    [Setup]  702 Case SetUp For UTE
    General_SiSo_Cell_lock_and_unlock    with_call=${False}
    [Teardown]   run keywords    Run Keyword If Test Failed     Run Keyword And Ignore Error    Unlock All Cell For Recover Env    AND
    ...                          702 Case TearDown For UTE    case_contain_special_operation=${True}

