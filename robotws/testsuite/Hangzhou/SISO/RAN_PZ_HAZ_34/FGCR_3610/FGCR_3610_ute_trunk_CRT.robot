*** Settings ***
Documentation    Auther:xiaoxia.hao@nokia-sbell.com
Suite Setup    702 Suite Setup For UTE
Suite Teardown    702 Suite TearDown For UTE
Force Tags            5G_RAN_TDD    master_classicalbts_all
...    PY39
...           5G_RAN    SBTS00    SBTS23R4    CRT_UTE    RAN_5G    RAN_5G_TDD
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_power_reset.robot
Resource    Resources/FGCR_3610_case_common.robot
Variables    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/FGCR_3610/TestData/variables.py

*** Variables ***

*** Test Cases ***
#[1]5GC001274_008_1UE_1Sector_4DL_256QAM_MCS27_using_2SFP_100MHz
#    [Documentation]    CHBW:100MHz
#    [Timeout]    45m
#    [Setup]  702 Case SetUp For UTE
#    5GC001274_008_1UE_1Sector_4DL_256QAM_MCS27_using_2SFP_100MHz
#    [Teardown]   702 Case TearDown For UTE
#
#[1]FGCR8131_A_1UE_1Sector_4DL_256QAM_MCS27_using_2SFP+_50MHz_AWHQE
#    [Documentation]    CHBW:50MHz
#    ...    Feature_ID:FGCR-3610-C
#    [Timeout]    45m
#    [Setup]  702 Case SetUp For UTE
#    FGCR8131_A_1UE_1Sector_4DL_256QAM_MCS27_using_2SFP+_50MHz_AWHQE
#    [Teardown]   702 Case TearDown For UTE

#[1]FGCR3610_1UE_1Sector_2UL_64QAM_MCS27_using_2SFP_60MHz
#    [Documentation]    CHBW:60MHz
#    ...                Feature_ID:FGCR-3610-B
#    [Timeout]    45m
#    [Setup]  702 Case SetUp For UTE
#    FGCR3610_1UE_1Sector_2UL_64QAM_MCS27_using_2SFP_60MHz
#    [Teardown]   702 Case TearDown For UTE

#[1]FGCR4454_1UE_1Sector_2UL_64QAM_MCS27_using_2SFP_40MHz_AWHQE
#    [Documentation]    CHBW:40MHz
#    [Timeout]    45m
#    [Setup]  702 Case SetUp For UTE
#    FGCR4454_1UE_1Sector_2UL_64QAM_MCS27_using_2SFP_40MHz_AWHQE
#    [Teardown]   702 Case TearDown For UTE

#[1][1.0] General_SiSo_RU_lock_unlock
#    [Timeout]    45m
#    [Setup]  702 Case SetUp For UTE
#    RRH_common_keyword.General SiSo RU Lock Unlock
#    [Teardown]  702 Case TearDown For UTE    case_contain_special_operation=${True}

[1]FGCR3610_1UE_1Sector_2UL_64QAM_MCS27_using_2SFP_80MHz
    [Documentation]    CHBW:80MHz
    ...    Feature_ID:FGCR-3610-C
    [Timeout]    45m
    [Setup]  702 Case SetUp For UTE    update_param_name=${FRAME_TO_11163ms_80MHz_4Symbols}
    FGCR3610_1UE_1Sector_2UL_64QAM_MCS27_using_2SFP_80MHz
    [Teardown]   702 Case TearDown For UTE

[1]5GC001157_09_1UE_1Sector_2UL_64QAM_MCS27_using_2SFP_20MHz
    [Documentation]    CHBW:20MHz
    ...    Feature_ID:FGCR-3610;FGCR-3626
    [Timeout]    45m
    [Setup]  702 Case SetUp For UTE
    5GC001157_09_1UE_1Sector_2UL_64QAM_MCS27_using_2SFP_20MHz
    [Teardown]   702 Case TearDown For UTE

#[2][1.0] General_SiSo_RF_module_power_reset
#    [Timeout]    45m
#    [Setup]  702 Case SetUp For UTE
#    General_SiSo_RF_module_power_reset.General_SiSo_RF_module_power_reset
#    [Teardown]    702 Case TearDown For UTE    case_contain_special_operation=${True}

