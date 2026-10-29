*** Settings ***
Suite Setup    Run keywords    SISO Coam Suite Setup    AND    Get PA Ports For All RUs 8953
...    AND    Get expect tput for each cell
Suite Teardown    Suite Teardown For Config Recovery
Test Setup    Run keywords    SISO Coam Test Setup    AND    Get btsName
...    AND    Set Whole Attenuator Ports    attenuator_out_ports=${PA_OUT_PORTS}    attenuator_rows=${PA_ROWS}
Test Teardown    SISO Coam Test Teardown
Test Timeout    300 min
#Suite Setup          SISO Coam Suite Setup
#Suite Teardown       SISO Coam Suite Teardown
#Test Setup           SISO Coam Test Setup
#Test Teardown        SISO Coam Test Teardown


Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_power_reset.robot
Resource    ${BASIC_PATH_5G}/OAM_KPI_61a_SiSo_Auto_BTS_site_reset.robot
Resource    ${BASIC_PATH_5G}/Baseband_module_reset_via_WEBUI.robot
Resource     Resources/CB008953_common_keyword.robot
Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/AZQR_SG08/Resources/5GC000433_common_keywords.robot
Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/AZQR_SG08/Resources/CB006487_keyword.robot
Resource     ../CB006976_CB007308/Resources/CB006796_common_keywords.robot
Resource     Resources/CB008423_common_keywords.robot
Variables    Resources/TestData.py
Variables    TestData/8953_variables.py
Resource     Resources/CB007028_SG08_kw.robot
Library      taf.hw.rf_attenuator    WITH NAME    attenuator
Resource    ../CB007331_SG08/Resources/CB007331_common_keyword.robot




Documentation
...    Author:XIXI CHEN
...    contact:xixi.chen@nokia-sbell.com
...    squad group:SG_08
...    Feature CB008953


Force Tags    RAN_5G_TDD    5G_RAN_TDD    master_classicalbts_all    RAN_5G    5G_RAN    CRT_UTE    STATE_SW_UPLOADED
...    PY36    CLOUD_5G_CLASSICAL_ANDROID_SA_ASOE_AZQD_AZQF
...    SBTS00

*** Variables ***
${MAX_LOOP}    20
@{bandlist_80M}    80M
@{framestructlist_80M}    1116_0ms_GP1
@{cell_id}    ${1}
@{nr_cell_1}    ${1}
@{nr_cell_2}    ${2}
@{nr_cell_3}    ${3}
@{nr_cell_4}    ${4}
@{lte_cell_401}    ${11}
@{lte_cell_402}    ${12}
@{lte_cell_403}    ${13}
@{lte_cell_404}    ${14}
@{lte_cell_405}    ${15}
@{lte_cell_406}    ${16}

*** Test Cases ***
[1]5GC000433-A_BTS_Energy_Consumption_counters_after_RF_disconnect_and_reconnect
    [Tags]    CRT_22R1    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_23R4    CRT_23R3    CRT_23R2
    sleep    5min
    RF Power Off On and Check Energy Consumption Counters    interval=1min

[1]5GC000433-A_Enable_Disable_Energy_Consumption_Measurement_Collectection_via_WebEM
    [Tags]    CRT_22R1    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_23R4    CRT_23R3    CRT_23R2
    Wait for New Interval BTS counters Generate    interval=15min
    Disable Energy Consumption Measurement Collectection    interval=15min
    Set Power meter    power_meter=true

[1]General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    [Tags]    CRT_22R1    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_23R4    CRT_23R3    CRT_23R2
    General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot

[1]General_SiSo_RU_lock_unlock
    [Tags]    CRT_22R1    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_23R4    CRT_23R3    CRT_23R2
    Set A7 Peak Matrix PA
    General_SiSo_RU_lock_unlock_A7    tput=${A7_TPUT}

[1]General_SiSo_E2E_system_setup_with_data_transfer_conducted_A7
    [Tags]    CRT_22R1    CRT_TRUNK    CRT_22R2    CRT_22R3    CRT_23R4    CRT_23R3    CRT_23R2
    Set A7 Peak Matrix PA
    General_SiSo_E2E_system_setup_with_data_transfer_conducted_A7    tput=${A7_TPUT}    target_avg_percent=0.98
    ...    min_percent=0.85    duration=${300}

[1][1.0] General_SiSo_E2E_system_setup_with_data_transfer
    [Tags]    CRT_TRUNK    CRT_23R4
    General_SiSo_E2E_system_setup_with_data_transfer_common_config

[1][2.0] General_SiSo_E2E_system_setup_with_data_transfer_conducted
    [Tags]    CRT_TRUNK    CRT_23R4
    General_SiSo_E2E_system_setup_with_data_transfer_common_config

[1][3.0] General_SiSo_Cell_block_and_unblock
    [Tags]    CRT_TRUNK    CRT_23R4
    General_SiSo_Cell_block_and_unblock_common_config

[1][2.0] Manual_SiSo_SM_NR_RAT_reset
    [Tags]    CRT_TRUNK    CRT_23R4
    Manual_SiSo_SM_NR_RAT_reset_common_config

#[1][2.0] Manual_SiSo_SM_RF_Module_lock_unlock
#    [Tags]    CRT_TRUNK    CRT_23R4
#    Manual_SiSo_SM_RF_Module_lock_unlock_common_config
