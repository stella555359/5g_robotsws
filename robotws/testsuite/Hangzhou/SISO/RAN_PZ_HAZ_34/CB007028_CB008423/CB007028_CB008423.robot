*** Settings ***
Suite Setup    Run keywords    SISO Coam Suite Setup    AND    Case Preparation    AND    Get PA Ports For All RUs 8953
Suite Teardown       Suite Teardown For Config Recovery
Test Setup    Run keywords    SISO Coam Test Setup    AND    Get btsName
...    AND    Set Whole Attenuator Ports    attenuator_out_ports=${PA_OUT_PORTS}    attenuator_rows=${PA_ROWS}
Test Teardown        SISO Coam Test Teardown
Test Timeout         300 min

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
...    squad group:SG_08
...    Feature CB007028  Author: xixi.chen@nokia-sbell.com
...    CA Feature CB008423  Author: lanwen.cai@nokia-sbell.com

Force Tags    RAN_5G_TDD    5G_RAN_TDD    master_classicalbts_all    RAN_5G    5G_RAN    CRT_UTE    STATE_SW_UPLOADED
...    PY36    CLOUD_5G_CLASSICAL_ANDROID_SA_ASILL_ABIOB1_AZQD_AZQF
...    SBTS00    SBTS22R2    CRT_22R4    CRT_23R1

*** Variables ***
${MAX_LOOP}    20
@{bandlist_80M}    80M
@{framestructlist_80M}    1116_0ms_GP1
@{cell_id}    ${1}
*** Test Cases ***
#[1]5GC000433-A_Counter_Update_M40002CX_ENERGY_CONSUMPTION_GNB
#    [Tags]    CRT_22R1    CRT_TRUNK    CRT_22R2    CRT_22R3
#    Check BTS Counter M40002C    interval=15min


#[1]5GC000433-A_Counter_Update_M40004CX_SM_ENERGY_CONSUMPTION
#    [Tags]    CRT_22R1    CRT_TRUNK    CRT_22R2    CRT_22R3
#    Check BTS Counter M40004C    interval=15min


#[1]5GC000433-A_Counter_Update_M40003CX_RU_ENERGY_CONSUMPTION
#    [Tags]    CRT_22R1    CRT_TRUNK    CRT_22R2    CRT_22R3
#    Check BTS Counter M40003C    interval=15min


#[1]5GC000433-A_WebEM_Voltage_and_Power_Display
#    [Tags]    CRT_22R1    CRT_TRUNK    CRT_22R2    CRT_22R3
#    sleep    5min
#    selenium login and disable screen lock
#    Check real time measurements    object_names=SMOD    interval=1min
#    Check real time measurements    object_names=RMOD    interval=1min
#    selenium logout and close browser

#[1]5GC000433-A_Energy_Consumption_Counter_Update_When_RU_locked_and_unlocked
#    [Tags]    CRT_22R1    CRT_TRUNK    CRT_22R2    CRT_22R3
#    Wait for New Interval BTS counters Generate    interval=15min
#    RU Lock Unlock and Check PM Counter Update Value    interval=15min



[1]5GC000433-A_BTS_Energy_Consumption_counters_after_RF_disconnect_and_reconnect
    [Tags]    CRT_22R1    CRT_TRUNK    CRT_22R2    CRT_22R3
    sleep    5min
    RF Power Off On and Check Energy Consumption Counters    interval=1min

[1]5GC000433-A_Enable_Disable_Energy_Consumption_Measurement_Collectection_via_WebEM
    [Tags]    CRT_22R1    CRT_TRUNK    CRT_22R2    CRT_22R3
    Wait for New Interval BTS counters Generate    interval=15min
    Disable Energy Consumption Measurement Collectection    interval=15min
    Set Power meter    power_meter=true


[1]General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    [Tags]    CRT_22R1    CRT_TRUNK    CRT_22R2    CRT_22R3
    General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot


#[1]General_SiSo_RF_module_power_reset
#    [Tags]    CRT_22R1    CRT_TRUNK    CRT_22R2    CRT_22R3
#    General_SiSo_RF_module_power_reset


#[1]General_SiSo_RF_alarms_with_recovery
#    [Tags]    CRT_22R1    CRT_TRUNK    CRT_22R2    CRT_22R3
#    ${ru_index_list}    Get All RU Index
#    FOR   ${ru_index}    IN     @{ru_index_list}
#        General_SiSo_RF_alarms_with_recovery    ru_index=${ru_index}
#    END


#[1]General_SiSo_RF_alarms_without_recovery
#    [Tags]    CRT_22R1    CRT_TRUNK    CRT_22R2    CRT_22R3
#    ${ru_index_list}    Get All RU Index
#    Log To Console    ${ru_index_list}
#    FOR   ${ru_index}    IN     @{ru_index_list}
#        General_SiSo_RF_alarms_without_recovery    ru_index=${ru_index}
#    END


#[1]General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed
#    [Tags]    CRT_22R1    CRT_TRUNK    CRT_22R2    CRT_22R3
#    ${cell_index_list}    create list    ${1}    ${6}
#    ${ru_index_list}    Get All RU Index
#    ${ru_num}     Get length    ${ru_index_list}
#    FOR   ${i}    IN RANGE    0    ${ru_num}
#        Log To Console    ${cell_index_list}[${i}], ${ru_index_list}[${i}]
#        General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed_PMAX    cell_id=${cell_index_list}[${i}]    ru_index=${ru_index_list}[${i}]
#    END


[1]General_SiSo_RU_lock_unlock
    [Tags]    CRT_22R1    CRT_TRUNK    CRT_22R2    CRT_22R3
    Set A7 Peak Matrix PA
    General_SiSo_RU_lock_unlock_A7    tput=${A7_TPUT}


#[1]General_SiSo_Cell_lock_and_unlock_A7
#    [Tags]    CRT_22R1    CRT_TRUNK    CRT_22R2    CRT_22R3
#    General_SiSo_Cell_block_and_unblock_A7


#[1][1.0] OAM_KPI_61a_SiSo_Auto_BTS_site_reset
#    [Tags]    CRT_22R1    CRT_TRUNK    CRT_22R2    CRT_22R3
#    OAM_KPI_61a_SiSo_Auto_BTS_site_reset


[1]General_SiSo_E2E_system_setup_with_data_transfer_conducted_A7
    [Tags]    CRT_22R1    CRT_TRUNK    CRT_22R2    CRT_22R3
    Set A7 Peak Matrix PA
    General_SiSo_E2E_system_setup_with_data_transfer_conducted_A7    tput=${A7_TPUT}    target_avg_percent=0.95    min_percent=0.85    duration=${300}


#[1][2.0] General_SiSo_Cell_lock_and_unlock
#    [Tags]    CRT_22R1    CRT_TRUNK    CRT_22R2    CRT_22R3
#    ${B6_SCF}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_B6_
#    ${nrCellType}    Get nrCellType value by coam
#    Run keyword if   '${nrCellType}'!='4DL4UL'    Commissioning SCF And Check On Air    scf_path=${B6_SCF}
#    Set B6 Peak PA
#    General_SiSo_Cell_block_and_unblock_A7   tput=${B6_TPUT}
#
#
#[1][1.0] General_SiSo_E2E_system_setup_with_data_transfer_conducted
#    [Tags]    CRT_22R1    CRT_TRUNK    CRT_22R2    CRT_22R3
#    ${B6_SCF}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_B6_
#    ${nrCellType}    Get nrCellType value by coam
#    Run keyword if   '${nrCellType}'!='4DL4UL'    Commissioning SCF And Check On Air    scf_path=${B6_SCF}
#    General_SiSo_E2E_system_setup_with_data_transfer_conducted_B6
#
#
#[1][1.0] OAM_KPI_651_SiSo_Auto_RF_reset_success_rate_from_WebUI
#    [Tags]    CRT_22R1    CRT_TRUNK    CRT_22R2    CRT_22R3
#    ${B6_SCF}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_B6_
#    ${nrCellType}    Get nrCellType value by coam
#    Run keyword if   '${nrCellType}'!='4DL4UL'    Commissioning SCF And Check On Air    scf_path=${B6_SCF}
#    OAM_KPI_651_SiSo_Auto_RF_reset_success_rate_from_WebUI
#
#
#[1]General_SiSo_BB_sub-unit_reset_with_L3_call
#    [Tags]    CRT_22R1    CRT_TRUNK    CRT_22R2    CRT_22R3
#    ${B6_SCF}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_B6_
#    ${nrCellType}    Get nrCellType value by coam
#    Run keyword if   '${nrCellType}'!='4DL4UL'    Commissioning SCF And Check On Air    scf_path=${B6_SCF}
#    Baseband_module_reset_via_WEBUI
#    General_SiSo_E2E_system_setup_with_data_transfer_conducted_B6    target_avg_percent=${0.5}    min_percent=${0.5}    duration=${30}
#

#[1]CB008423-5G-B-SyVe_20_CB007922_SA_ Single_UE_Peak_Throughput_20M_20M
#    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3
#    ${CA_SCF}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_CA_
#    Commissioning SCF And Check On Air    scf_path=${CA_SCF}
#    CB008423-5G-B-SyVe_20_CB007922_SA_ Single_UE_Peak_Throughput_20M_20M

#[1]CB007331-5G-C_8_General_SiSo_E2E_system_setup_with_data_transfer_conducted_max_MCS_5GC001116_SA_call_80M
#    [Tags]    CRT_TRUNK    CRT_22R2    CRT_22R3
#    Commission According Band And FrameStruct    bandlist=${bandlist_80M}    framestructlist=${framestructlist_80M}
#    Set B6 RU1 Peak PA
#    General_SiSo_E2E_system_setup_with_data_transfer_conducted_max_MCS    tput_self_define=${tput_80M}    cell_id=${cell_id}

*** Keywords ***
