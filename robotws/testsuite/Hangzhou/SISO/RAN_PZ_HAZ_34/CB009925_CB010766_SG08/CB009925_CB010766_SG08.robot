*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_powersaving_common_keywords.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.robot
Resource    Resources/CB009925_CB010766_common_keywords.robot
Library     lib/CB014167.py

Documentation
...    Author:wangqingqing
...    contact:qingqing.wang@nokia-sbell.com
...    squad group:SG_08

Force Tags    SBTS00
...   PY36

*** Test Cases ***
[1]General_SISO_Cell_Block_Unblock
    [Tags]    CRT_TRUNK
    General_SISO_Cell_Block_Unblock_SG08    tput_self_define=${tput_define_992_10766_common}    Max_loop=${5}    target_avg_percent=0.98
    ...    min_percent=0.85    cell_id=${cell_id_common}    duration=${120}    with_call=${False}

[1]OAM_KPI_61a_SiSo_Auto_BTS_site_reset_A15
    [Tags]    CRT_TRUNK
    General_SISO_Site_Reset_SG08    tput_self_define=${tput_define_992_10766_common}    Max_loop=${5}    target_avg_percent=0.98
    ...    min_percent=0.85    cell_id=${cell_id_common}    duration=${120}    with_call=${False}

[1]Recovery_and_reset_RAT_Reset_from_WebEM
    [Tags]    CRT_TRUNK
    General_SISO_RAT_Reset_SG08    tput_self_define=${tput_define_992_10766_common}    Max_loop=${5}    target_avg_percent=0.98
    ...    min_percent=0.85    cell_id=${cell_id_common}    duration=${120}    with_call=${False}

[1]General_SiSo_RU_lock_unlock
    [Tags]    CRT_TRUNK
    General_SISO_RU_Lock_Unlock_loop_SG08    tput_self_define=${tput_define_992_10766_common}    Max_loop=${5}    target_avg_percent=0.98
    ...    min_percent=0.85    cell_id=${cell_id_common}    duration=${120}    with_call=${False}
    Connect to gnb coam via ssl
    data_transfer_common    tput_self_define=${tput_define_992_10766_common}    cell_id=${nr_cell_2}    loop_times=${1}    duration=${300}
    ...    target_avg_percent=${0.98}    min_percent=${0.85}     process_num_ul=6

[1][1.0] General_SiSo_RAT_Block_Unblock_with_L3call
    [Tags]    CRT_TRUNK
    General_SISO_RAT_Block_Unblock_SG08    tput_self_define=${tput_define_992_10766_common}    Max_loop=${5}    target_avg_percent=0.98
    ...    min_percent=0.85    cell_id=${cell_id_common}    duration=${120}    with_call=${False}

[1][1.0] General_SiSo_RF_module_power_reset
    [Tags]    CRT_TRUNK
    General_SISO_RU_Power_Reset_SG08    tput_self_define=${tput_define_992_10766_common}    Max_loop=${5}    target_avg_percent=0.98
    ...    min_percent=0.85    cell_id=${cell_id_common}    duration=${120}    with_call=${False}

[1][1.0] CB009925-SR-A RU Recovery during deep sleep mode due to RU restart
    [Tags]    CRT_TRUNK
    RU Recovery during deep sleep mode due to RU restart loop    Max_loop=${1}

[1][1.0] CB010766-SR-A-5 Entering_Exiting_Deep_Sleep_Mode_IWK_With_CB009925
    [Tags]    CRT_TRUNK
    CB010766-SR-A-5 Entering_Exiting_Deep_Sleep_Mode_IWK_With_CB009925


[1]RU_exit_deepsleep_due_to_disbale_9925_AND_enter_due_to_cell_block
    [Tags]    CRT_TRUNK
    RU_exit_deepsleep_due_to_disbale_9925_AND_enter_due_to_cell_block

[1]RU_exit_deepsleep_due_to_10766_expire_AND_enter_due_to_cell_energysaving
    [Tags]    CRT_TRUNK
    RU_exit_deepsleep_due_to_10766_expire_AND_enter_due_to_cell_energysaving

[1]RU_exit_deepsleep_due_to_431_expire_AND_enter_due_to_cell_energysaving
    [Tags]    CRT_TRUNK
    RU_exit_deepsleep_due_to_431_expire_AND_enter_due_to_cell_energysaving

[1]General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    [Tags]    CRT_TRUNK
    ${SCF_LTE}    Replace String    ${Golden_SCF_Path}    .xml    _9925_include_lte.xml
    Commissioning SCF And Check On Air   scf_path=${SCF_LTE}
    General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot

[1][1.0] CB009925-SR-A RU entering deep sleep mode during low traffic periods with 5GC000431 enabled
    [Tags]    CDRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1
    ${SCF_LTE}    Replace String    ${Golden_SCF_Path}    .xml    _9925_include_lte.xml
    Commissioning SCF And Check On Air   scf_path=${SCF_LTE}
    CB010766-SR-A-8 Activate RU deep sleep mode when feature flag enable TL948

[1][1.0] CB010766-SR-A-3 Entering_Exiting_Deep_Sleep_Mode_IWK_With_5GC000431
    [Tags]    CRT_TRUNK
    CB010766-SR-A-3 Entering_Exiting_Deep_Sleep_Mode_IWK_With_5GC000431    if_check_counter=${False}
    data_transfer_common    tput_self_define=${tput_define_992_10766_common}    cell_id=${nr_cell_1}    loop_times=${1}    duration=${300}
    ...    target_avg_percent=${0.2}    min_percent=${0.1}    ui_version=${ui_version_xiaomi}

[1][1.0] CB010471_A_B12345_16TRX_Path_Switch_Off_On_Base_On_Pgload
    [Tags]    CRT_TRUNK
    CB010471_A_B12345_16TRX_Path_Switch_Off_On_Base_On_Pgload

[1]CB014167-SR-A_CR-A_3_ISTI_next_to_each_timestamp
    [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1
    ISTI_next_to_each_timestamp    ru_index=2

[1]CB014167-SR-A_CR-A_4_Information_about_last_RU_resets
    [Tags]    CDRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1
    Information_about_last_RU_resets    ru_index=2

[1]CB014167-SR-B_CR-B_1_SFP_info_per_SFP_slot_update_with_RU_startup
   [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1
   SFP_info_per_SFP_slot_update_with_RU_startup    ru_index=2

[1]CB014167-SR-A_CR-A_1_RU_blackbox_versioning
    [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1
    RU_blackbox_versioning    ru_index=2

[1]CB014167-SR-D_CR-D_1_RU_configuration_data
    [Tags]    CDRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1
    RU_configuration_data    ru_index=2

[1]CB005763-DC_Dying_Gasp_alarm_check_ecpri_AQQJ
    [Tags]    CRT_TRUNK
    CB005763-DC_Dying_Gasp_alarm_check_ecpri_AQQJ
