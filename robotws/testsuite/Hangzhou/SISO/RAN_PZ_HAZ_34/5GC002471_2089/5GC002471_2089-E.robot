*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG08_keywords_SISO_operation.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RU_lock_unlock.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_reset_from_GUI.robot
Resource    ${BASIC_PATH_5G}/BTS/General_SiSo_Peak_with_Given_Information.robot
Resource    ${BASIC_PATH_5G}/OAM_KPI_61a_SiSo_Auto_BTS_site_reset.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed_PMAX.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_alarms_without_recovery.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_alarms_with_recovery.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_BTS_startup_with_RF_delayed_startup.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_addition_in_BIM_and_WebUI.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_power_reset.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Commissioning_BTS_Template_Commissioning.robot
Resource    ${BASIC_PATH_5G}/5GC000399/5GC000399_eCPRI_Basic_configuration_over_RP1.robot
Resource    ${BASIC_PATH_5G}/5GC000399/5GC000399_eCPRI_Carier_activation.robot
Resource    ${BASIC_PATH_5G}/5GC000560/5GC000560_eLLF_sync_generic_startup_at_RU.robot
Resource    ${BASIC_PATH_5G}/5GC000560/5GC000560_eLLF_PTP_Failure.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_NR-ARFCN_check.robot

Resource     ./Resources/5GC002471_keyword.robot
Resource     ./Resources/CB009359-keywords.robot
Variables    TestData/variables_2471.py

Documentation
...    Author:Ye Michael, Gao Melinda
...    contact:tianyi.ye@nokia-sbell.com
...            melinda.gao@nokia-sbell.com
...    squad group:SG_08
...    Feature 5GC002089-E-18 in 5G21A program
...    Feature 5GC002471 made
...    Feature CB009359

Force Tags            RAN_5G_TDD    5G_RAN_TDD    RAN_5G    5G_RAN    CRT_UTE    STATE_SW_UPLOADED    SBTS00    CRT_23R3
...    PY36
...    CLOUD_5G_CLASSICAL_ANDROID_SA_ASIBL_ABIOL_AEQI    CRT_23R1

*** Variables ***
${MAX_LOOP}    20
${TS_LOG_PATH_BASE}    /home/ute
${TS_CASE_LOG_PATH}    /home/ute
${ru_type_init}    AEQI
*** Test Cases ***

[1]General_SiSo_E2E_system_setup_with_data_transfer_conducted_peak_contiguous
    [Tags]    CRT_TRUNK
    ${contiguous_SCF}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_5040_
    Commissioning SCF And Check On Air    scf_path=${contiguous_SCF}
    data_transfer_common    tput_self_define=${tput_define_contiguous}    loop_times=${1}    duration=${300}
    ...    target_avg_percent=0.95    min_percent=0.85

[1]5GC002089-E-18_04_AEQI_4DL-4UL_General_SiSo_Cell_lock_unlock
    [Tags]    CRT_TRUNK
    CB009359_General_SiSo_Cell_block_and_unblock

[1]General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    [Tags]    CRT_TRUNK
    commission 1s1cc scf if needed
    General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot

[1]General_SiSo_E2E_system_setup_with_data_transfer_conducted_80MHz
    [Tags]    CRT_TRUNK
    commission 1s1cc scf if needed
    data_transfer_common    tput_self_define=${tput_define_2471}    loop_times=${1}    duration=${300}
    ...    target_avg_percent=0.95    min_percent=0.85

[1]5GC002089-E-18_07_AEQI_4DL_4UL_General_SiSo_RU_lock_unlock_
    [Tags]    CRT_TRUNK
    commission 1s1cc scf if needed
    General_SISO_RU_Lock_Unlock_loop_SG08    tput_self_define=${tput_define_2471}    Max_loop=${10}    target_avg_percent=0.3
    ...    min_percent=0.2    duration=${300}
    
[1]5GC002089-E-18_03_AEQI_4DL-4UL_General_SiSo_RF_module_reset_from_GUI
    [Tags]    CRT_TRUNK
    commission 1s1cc scf if needed
    General_SiSo_RF_module_reset_from_GUI

[1]5GC002089-E-18_08_AEQI_4DL_4UL_General_SiSo_RF_alarms_with_recovery
    [Tags]    CRT_TRUNK
    commission 1s1cc scf if needed
    General_SiSo_RF_alarms_with_recovery

[1]General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed
    [Tags]    CRT_TRUNK
    commission 1s1cc scf if needed
    General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed_PMAX

[1]5GC000560_eLLF_PTP_Failure
    [Tags]    CRT_TRUNK
    commission 1s1cc scf if needed
    5GC000560_eLLF_PTP_Failure

#[1]General_SiSo_BTS_startup_with_RF_delayed_startup
#    [Tags]    CRT_22R1    CRT_TRUNK    CRT_22R3
#    commission 1s1cc scf if needed
#    General_SiSo_BTS_startup_with_RF_delayed_startup
#
#[1]General_SiSo_RF_module_addition_in_BIM_and_WebUI
#    [Tags]    CRT_TRUNK    CRT_22R3
#    commission 1s1cc scf if needed
#    General_SiSo_RF_module_addition_in_BIM_and_WebUI
#
#[1]General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module
#    [Tags]    CRT_TRUNK    CRT_22R3
#    commission 1s1cc scf if needed
#    General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module
#
#[1]General_SiSo_RF_module_power_reset
#    [Tags]    CRT_TRUNK    CRT_22R3
#    commission 1s1cc scf if needed
#    General_SiSo_RF_module_power_reset
#
#[1]General_SiSo_NR-ARFCN_check
#    [Tags]    CRT_TRUNK    CRT_22R3
#    commission 1s1cc scf if needed
#    General_SiSo_NR-ARFCN_check
#
#[1]General_SiSo_E2E_system_setup_with_data_transfer_conducted_40MHz_40MHz
#    [Tags]    CRT_22R1    CRT_TRUNK    CRT_22R2    CRT_22R3
#    Log to console    commisson 40+40 Frame structure 1070-A3 with manualFrameTimingAdjustment=0
#    data_transfer_2089    ue_index_list=${ue_list}    cell_list=${cell_list}
#    ...    band=40    frame_structure=1070_GP1_A3    prach_index=98    beamset=2 beams    dl_ul_layer=4DL2UL
#
#[1]General_SiSo_E2E_system_setup_with_data_transfer_conducted_50MHz_50MHz
#    [Tags]    CRT_22R1    CRT_TRUNK    CRT_22R2    CRT_22R3
#    Log to console    commisson 50+50 Frame structure 1116-3-A6-98 with manualFrameTimingAdjustment=0
#    ${2CC_SCF}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_5050_
#    Commissioning SCF And Check On Air    scf_path=${2CC_SCF}
#    data_transfer_2089    ue_index_list=${ue_list}    cell_list=${cell_list}
#    ...    band=50    frame_structure=1116_3ms_GP2_A6    prach_index=98    beamset=2 beams    dl_ul_layer=4DL2UL
#
#[1]General_SiSo_E2E_system_setup_with_data_transfer_conducted_100MHz_peak
#    [Tags]    CRT_22R1    CRT_TRUNK    CRT_22R2    CRT_22R3
#    Log to console    commisson 100MHz Frame structure 1116-0-A7-206 with manualFrameTimingAdjustment=0
#    ${100M_SCF}    Replace String    ${Golden_SCF_Path}    SCF_    SCF_100_
#    Commissioning SCF And Check On Air    scf_path=${100M_SCF}
#    General_SiSo_Peak_with_Given_Information    band=100    frame_structure=1116_0ms_GP2_A7    prach_index=206
#    ...    beamset=2 beams   dl_ul_layer=4DL2UL    enable_2197=${False}
#
#[1]5GC002089-E-18_02_AEQI_4DL-4UL_OAM_KPI_61a_SiSo_Auto_BTS_site_reset
#    [Tags]    CRT_22R1    CRT_TRUNK    CRT_22R2    CRT_22R3
#    [Timeout]    20h
#    OAM_KPI_61a_SiSo_Auto_BTS_site_reset
#
#[1]5GC002089-E-18_01_AEQI_4DL-4UL_General_SiSo_Commissioning_BTS_Template_Commissioning_LokiA+LokiB
#    [Tags]    CRT_TRUNK    CRT_22R3
#    commission 1s1cc scf if needed
#    General_SiSo_Commissioning_BTS_Template_Commissioning
#
#[1]5GC000399_eCPRI_Basic_configuration_over_RP1
#    [Tags]    CRT_TRUNK    CRT_22R3
#    commission 1s1cc scf if needed
#    5GC000399_eCPRI_Basic_configuration_over_RP1
#
#[1]5GC000399_eCPRI_Carier_activation_conducted
#    [Tags]    CRT_TRUNK    CRT_22R3
#    commission 1s1cc scf if needed
#    5GC000399_eCPRI_Carier_activation
#
#[1]5GC000560_eCPRI_sync_generic_startup_at_RU
#    [Tags]    CRT_TRUNK    CRT_22R3
#    commission 1s1cc scf if needed
#    5GC000560_eLLF_sync_generic_startup_at_RU
#
#[1]General_SiSo_RF_alarms_without_recovery
#    [Tags]    CRT_22R1    CRT_TRUNK    CRT_22R3
#    commission 1s1cc scf if needed
#    General_SiSo_RF_alarms_without_recovery

*** Keywords ***
