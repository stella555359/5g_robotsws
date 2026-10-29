*** Settings ***
Documentation    Auther:xiaoxia.hao@nokia-sbell.com
Suite Setup    702 Suite Setup For UTE
Suite Teardown    702 Suite TearDown For UTE
Force Tags            5G_RAN_TDD    STATE_SW_UPLOADED    master_classicalbts_all    CLOUD_5G_CLASSICAL_ASIKL_ABILB1_2xAZQH
...    PY39
...           CIT    5G_RAN    SBTS23R4    RAN_5G    RAN_5G_TDD

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_lock_and_unlock.robot
Resource    Resources/5GC000702_common_ute.robot

*** Variables ***

*** Test Cases ***
[1]5GC000702_M_166_Configuration_Of_2S_1CC_4DL_2UL_RU_lock_unlock_AZQL
    [Documentation]    1 RU lock and unlock one by one, 5GC000702-26;5GC000702-28
    ...                CHBW:20MHz
    ...                Feature_ID:5GC000702-M;5GC001849-A;5GC002142-B
    [Timeout]    90m
    [Setup]  702 Case SetUp For UTE    scf_file_name=Configuration_26_${stream}    update_param_name=${FRAME_TO_1208_20MHz_2Symbols}
    5GC000702_M_166_Configuration_Of_2S_1CC_4DL_2UL_RU_lock_unlock_AZQL
    [Teardown]    702 Case TearDown For UTE

[1]5GC000702_M_153_Configuration_Of_2S_1CC_4DL_2UL_cell_lock_unlock_AZQH
    [Documentation]    1 cell lock and unlock one by one,5GC000702-36;5GC000702-28
    ...                CHBW:60MHz
    ...                Feature_ID:5GC000702-MG
    [Timeout]    90m
    [Setup]  702 Case SetUp For UTE    scf_file_name=Configuration_36_${stream}    update_param_name=${FRAME_TO_11160ms_60MHz_4Symbols}
    5GC000702_M_153_Configuration_Of_2S_1CC_4DL_2UL_cell_lock_unlock_AZQH
    [Teardown]    702 Case TearDown For UTE
