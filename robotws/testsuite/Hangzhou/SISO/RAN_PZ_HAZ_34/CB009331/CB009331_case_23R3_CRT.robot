*** Settings ***
Documentation      Author: stella.lin@nokia-sbell.com
Suite Setup    9331 Coam Suite Setup
Suite Teardown    SISO Coam Suite Teardown
Test Setup    9331 Coam Test Setup
Test Teardown    SISO Coam Test Teardown
Force Tags            5G_RAN_TDD    STATE_SW_UPLOADED    master_classicalbts_all
...    PY36
...           CRT_UTE    CLOUD_5G_CLASSICAL_ANDROID_SA_ASILL_ABIOB1B2_3xAEHC_CMA    5G_RAN    SBTS23R3    SBTS24R1    RAN_5G    RAN_5G_TDD

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    Resources/CB009331_common.robot

*** Variables ***


*** Test Cases ***
[1]CB009331-SR-A_07_NR_only_16DL_8UL_3Sector_2CC_NR50_NR50
    [Tags]    CRT_23R3    3S-2CC-50-50
    [Timeout]    90m
    CB009331-SR-A_07_NR_only_16DL_8UL_3Sector_2CC_NR50_NR50

[1][1.0] General_SiSo_RU_lock_unlock
    [Tags]    CRT_23R3    3S-2CC-100-90
    [Timeout]    180m
    CB009331-General_SiSo_RU_lock_unlock

[1][2.0] General_SiSo_RU_module_reset_from_GUI
    [Tags]    CRT_23R3    1S-2CC-60-60
    [Timeout]    90m
    CB009331-General_SiSo_RU_module_reset_from_GUI

[1]CB008941-SR-AC_2_L3call_Loki_based_DU_with_UL_PRB_muting_active_FDBF
    [Tags]    CRT_23R3    3S-2CC-100-50
    [Timeout]    180m
    CB008941-SR-AC_2_L3call_Loki_based_DU_with_UL_PRB_muting_active_FDBF

[1][1.0] Manual_SiSo_SM_BTS_Site_Reset
    [Tags]    CRT_23R3    3S-2CC-100-80
    CB009331-Manual_SiSo_SM_BTS_Site_Reset
