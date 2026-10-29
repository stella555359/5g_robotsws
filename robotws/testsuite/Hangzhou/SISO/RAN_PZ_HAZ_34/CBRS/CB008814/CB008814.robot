*** Settings ***
Suite Setup          CBRS Suite Setup
Suite Teardown       CBRS Suite Teardown
Test Setup           CBRS Test Setup
Test Teardown        CBRS Test Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_from_GUI.robot
Resource    resources/CB008184_common_keywords.robot

Documentation
...    Author:wangqingqing
...    contact:qingqing.wang@nokia-sbell.com
...    squad group:SG_08
...    Feature CB008184

Force Tags    SBTS00
...   PY36

*** Variables ***

*** Test Cases ***
[1][2.0] General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    [Tags]    CRT_TRUNK
    Start SAS server
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot

[1][2.0] General_SiSo_RU_module_reset_from_GUI
    [Tags]    CRT_TRUNK
    Start SAS server
    Wait until keyword succeeds    5min    30s    verify all cells should be onair
    General_SiSo_RF_module_reset_from_GUI

[1][1.0] Manual_SiSo_SM_BTS_Site_Reset
    [Tags]    CRT_TRUNK
    CB008814_Manual_SiSo_SM_BTS_Site_Reset

[1]CB008814-AC_2_Online_add_one_higher_priority_CBRS_cell_when_only_20MHz_channel_block_available_2CC
    [Tags]    CRT_TRUNK
    CB008814-AC_2_Online_add_one_higher_priority_CBRS_cell_when_only_20MHz_channel_block_available_2CC

[1][2.0] Manual_SiSo_SM_RF_Module_lock_unlock
    [Tags]    CRT_TRUNK
    CB008814_Manual_SiSo_SM_RF_Module_lock_unlock

[1]General_SiSo_E2E_system_setup_with_data_transfer_conducted (max MCS L3 call)_2CC_30MHz+40MHz
    [Tags]    CRT_TRUNK
    General_SiSo_E2E_system_setup_with_data_transfer_conducted (max MCS L3 call)_2CC_30MHz+40MHz

[1]General_SiSo_E2E_system_setup_with_data_transfer_conducted (max MCS L3 call)_2CC_40MHz+40MHz__new_frame_prachConfig_A2
    [Tags]    CRT_TRUNK
    General_SiSo_E2E_system_setup_with_data_transfer_conducted (max MCS L3 call)_2CC_40MHz+40MHz__new_frame_prachConfig_A2

[1]CB008814-B_1_10MHz_support_channelSpacing_structure_2CC
    [Tags]    CRT_TRUNK
    CB008814-B_1_10MHz_support_channelSpacing_structure_2CC

*** Keywords ***
