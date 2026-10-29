*** Settings ***
Documentation
...    Author: Lan Shifu
...    Author:shifu.lan@nokia-sbell.com
...    Team group: VRF_HAZ4_T04
...    Feature Owner: Shi Gaofan & Chen Zhendong
...    Feature 'CB012532 FR1 TDD Habrok 32/64 with eCPRI 7-2 enhanced FH' in SBTS25R3 program phase

Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup    fail_with_alarms=${True}    is_ru_log_collecting_enable=${True}
Test Teardown        SISO Coam Test Teardown
Test Timeout         4h

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_from_GUI.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB009563/Resource/CB009563_common_keyword.robot
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB012532_SG4/Resource/CB012532_common_keywords.robot

Force Tags     RAN_5G     RAN_5G_TDD    STATE_SW_UPLOADED    SBTS00    PY310    master_classicalbts_all    HAZ4_T04

*** Test Cases ***
[1]CB012532-SR-D-D2_02_SiSo_Online_Change_72A_72E_OnAir_L3Call
    [Documentation]    Test online parameter change between 72A and 72E modes
    ...                1. Get all cells in BTS
    ...                2. Configure 72A parameters for all cells online
    ...                3. Check if all cells are OnAir
    ...                4. Make L3 call and check throughput
    ...                5. Configure 72E parameters for all cells online
    ...                6. Check if all cells are OnAir
    ...                7. Make L3 call and check throughput
    [Tags]    1S-2CC-72E
    ${ue_num_each_call}    Get Tput ue Number    given_num=2
    SiSo_Online_Change_72A_72E_OnAir_L3Call    with_call=${True}    with_peak=${True}    duration=${300}
    ...    ue_num_each_call=${ue_num_each_call}    ru_index=${1}    suite_name=${SUITE NAME}
    ...    test_name=${TEST NAME}

[1]CB012532-SR-D-D3_03_4CC_16DL4UL_72E_L3call
    [Documentation]    CB012532 Test Case - 4CC_16DL4UL_72E_L3call
    [Tags]  1S-4CC-72E
    ${ue_num_each_call}    Get Tput ue Number    given_num=2
    L3Call_setup_with_data_transfer_conducted    with_call=${True}    with_peak=${True}    duration=${300}
    ...    ue_num_each_call=${ue_num_each_call}    ru_index=${1}    suite_name=${SUITE NAME}    test_name=${TEST NAME}

[1]CB012532-SR-F-F5_03_4CC_10Mhz_with_CB009527
    [Documentation]    CB012532 Test Case - 4CC 10MHz bandwidth with CB009527 feature
    ...                1. Configure 4CC with 10MHz bandwidth
    ...                2. Enable CB009527 feature
    ...                3. Verify cells are OnAir
    ...                4. Make L3 call and check throughput
    [Tags]    1S-4CC-72E-10M
    ${ue_num_each_call}    Get Tput ue Number    given_num=4
    # WA: cell id 3 need not test for sub-Band BF, because of it's attached UE(Fastmile Gateway 3.1) does not support sub-Band feature
    # TODO: Fastmile Gateway 3.1 should be replaced in future
    # Below cell ID should be sync with test line https://jiradc.ext.net.nokia.com/browse/LEOPARD-2478
    ${ignored_cell_list}    Create List    ${143}
    4CC_10Mhz_with_CB009527    with_call=${True}    duration=${300}    ue_num_each_call=${ue_num_each_call}
    ...    ru_index=${1}    ignored_cell_list=${ignored_cell_list}

[1]CB012532-SR-F-F1_AVHQA_General_SiSo_RU_module_reset_from_GUI
    [Documentation]    CB012532 Test Case - General SiSo RU module reset from GUI
    [Tags]  1S-2CC-72E
    ${ue_num_each_call}    Get Tput ue Number    given_num=2
    General_SiSo_RF_module_reset_from_GUI    with_call=${True}    with_peak=${True}    duration=${300}
    ...    ue_num_each_call=${ue_num_each_call}    suite_name=${SUITE NAME}    test_name=${TEST NAME}

[1]CB012532-SR-F-F1_06_Different_frame_structures_configuration_with_gNB_timing_shifter
    [Documentation]    CB012532 Test Case - Different frame structures configuration with gNB timing shifter
    [Tags]  1S-2CC-72E
    NR Feature CB007597 ON/OFF and max frameStartOffset min sfnOffset

[1]CB012532-SR-G_US1_ABIP_Fisto_E2E_system_setup_with_data_transfer_CB009472#14
    [Documentation]    CB012532 Test Case - System setup with data transfer
    [Tags]  2S-4CC-CB012532
    ${ue_num_each_call}    Get Tput ue Number    given_num=2
    L3Call_setup_with_data_transfer_conducted    with_call=${True}    with_peak=${True}    duration=${300}
    ...    ue_num_each_call=${ue_num_each_call}    ru_index=${2}
