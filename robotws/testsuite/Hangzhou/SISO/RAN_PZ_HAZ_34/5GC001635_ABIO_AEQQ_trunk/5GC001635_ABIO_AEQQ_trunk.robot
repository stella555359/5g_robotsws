*** Settings ***
Suite Setup          SISO Coam Suite Setup
Suite Teardown       SISO Coam Suite Teardown
Test Setup           SISO Coam Test Setup
Test Teardown        SISO Coam Test Teardown


Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    ${BASIC_PATH_5G}/5G_Setup_And_Teardown.robot
Resource    ${BASIC_PATH_5G}/5GC000399/5GC000399_eCPRI_Basic_configuration_over_RP1.robot
Resource    ${BASIC_PATH_5G}/5GC000399/5GC000399_eCPRI_Carier_activation.robot
Resource    ${BASIC_PATH_5G}/5GC000560/5GC000560_eLLF_sync_generic_startup_at_RU.robot
Resource    ${BASIC_PATH_5G}/5GC000560/5GC000560_eLLF_PTP_Failure.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_BTS_startup_with_RF_delayed_startup.robot
#Resource    ${BASIC_PATH_5G}/Cell/General_SiSo_Cell_lock_and_unlock.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed_PMAX.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_NR-ARFCN_check.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_addition_in_BIM_and_WebUI.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_module_power_reset.robot
#Resource    ${BASIC_PATH_5G}/General_SiSo_RU_lock_unlock.robot
Resource    ${BASIC_PATH_5G}/OAM_KPI_61a_SiSo_Auto_BTS_site_reset.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_alarms_with_recovery.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_RF_alarms_without_recovery.robot
Resource    ${BASIC_PATH_5G}/BTS/General_SiSo_E2E_system_setup_with_data_transfer_multi_cc_with_different_bandwith.robot
Resource    ${BASIC_PATH_5G}/BTS/General_SiSo_Peak_with_Given_Information.robot
Resource    ${BASIC_PATH_5G}/Cell/General_SiSo_Online_Cell_addition_deletion.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Commissioning_BTS_Template_Commissioning.robot
Resource    ${BASIC_PATH_5G}/General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module.robot
Resource     Resources/CB008941_common_keyword_AA.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BW_common_case/lib/BW_step_keywords.robot
Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC001635_ABIO_AEQQ_trunk/Resources/5GC001635_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common_keywords.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG8_common.py
Variables    Resources/variables_1635_ABIO.py

Documentation
...    Author:shufei chen
...    contact:shufei.chen@nokia-sbell.com
...    squad group:SG_08
...    Feature 5GC001635_ABIO in 5G00 program

Force Tags            5G_RAN_TDD    SBTS00
...    PY36

*** Variables ***
${MAX_LOOP}    20
@{band}    70 M    30M
@{band_1}    50M    40M
@{nr_cell_1}    ${1}
*** Test Cases ***
[1][1.0] CB010471_A_B12345_16TRX_Path_Switch_Off_On_Base_On_Pgload
    [Tags]    CRT_TRUNK
    CB010471_A_B12345_16TRX_Path_Switch_Off_On_Base_On_Pgload

[1]5GC000399_eCPRI_Basic_configuration_over_RP1
    [Tags]    CRT_22R2    CRT_TRUNK    CRT_21B    CRT_22R1
    5GC000399_eCPRI_Basic_configuration_over_RP1

[1]5GC000399_eCPRI_Carier_activation_conducted
    [Tags]    CRT_22R2    CRT_TRUNK    CRT_21B    CRT_22R1
    5GC000399_eCPRI_Carier_activation

[1]5GC000560_eCPRI_sync_generic_startup_at_RU
    [Tags]    CRT_22R2    CRT_TRUNK    CRT_21B    CRT_22R1
    5GC000560_eLLF_sync_generic_startup_at_RU

[1]5GC000560_eLLF_PTP_Failure
    [Tags]    CRT_22R2    CRT_TRUNK    CRT_21B    CRT_22R1
    5GC000560_eLLF_PTP_Failure

[1]General_SiSo_BTS_startup_with_RF_delayed_startup
    [Tags]    CRT_22R2    CRT_TRUNK    CRT_21B    CRT_22R1
    General_SiSo_BTS_startup_with_RF_delayed_startup

[1]General_SiSo_Cell_lock_and_unlock
    [Tags]    CIT_TRUNK    CRT_21B    CDRT_22R1    CRT_22R2
    Commission 1S1CC SCF If Needed
    #General_SiSo_Cell_lock_and_unlock
    General_SiSo_Cell_lock_and_unlock_SG08    tput_self_define=${tput_1635_peak_60}    target_avg_percent=${0.5}
    ...    min_percent=${0.2}

[1]General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    [Tags]    CRT_22R2    CRT_TRUNK    CRT_21B    CRT_22R1
    General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot

[1]General_SiSo_Commissioning_BTS_Template_Commissioning
    [Tags]    CRT_22R2    CRT_TRUNK    CRT_21B    CRT_22R1
    General_SiSo_Commissioning_BTS_Template_Commissioning

[1]General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module
    [Tags]    CRT_22R2    CRT_TRUNK    CRT_21B    CRT_22R1
    General_SiSo_Configuration_BPF_and_TargetBD_support_for_RF_module

#[1]General_SiSo_E2E_system_setup_with_data_transfer_conducted_20Mhz_20MHz
#   [Tags]    CRT_21A    CRT_TRUNK    CRT_21B
#   General_SiSo_E2E_system_setup_with_data_transfer    band=20    ue_num_each_call=2

#[1]General_SiSo_E2E_system_setup_with_data_transfer_conducted_40Mhz_40Mhz
#   [Tags]    CRT_21A    CRT_TRUNK    CRT_21B
#   General_SiSo_E2E_system_setup_with_data_transfer    band=40    ue_num_each_call=2

#[1]General_SiSo_E2E_system_setup_with_data_transfer_conducted_50Mhz_50MHz
#   [Tags]    CRT_21A    CRT_TRUNK    CRT_21B
#   General_SiSo_E2E_system_setup_with_data_transfer    band=50    ue_num_each_call=2

[1]General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed
    [Tags]    CRT_22R2    CRT_TRUNK    CRT_21B    CRT_22R1
    General_SiSo_Fault_1900_EFaultId_FrConfiguringFailed_PMAX

[1]General_SiSo_NR-ARFCN_check
    [Tags]    CRT_22R2    CRT_TRUNK    CRT_21B    CRT_22R1
    General_SiSo_NR-ARFCN_check

[1]General_SiSo_Online_Cell_addition_deletion
    [Tags]    CRT_22R2    CRT_TRUNK    CRT_21B    CRT_22R1
    General_SiSo_Online_Cell_addition_deletion

[1]General_SiSo_RF_module_addition_in_BIM_and_WebUI
    [Tags]    CRT_22R2    CRT_TRUNK    CRT_21B    CRT_22R1
    General_SiSo_RF_module_addition_in_BIM_and_WebUI

[1]General_SiSo_RF_module_power_reset
    [Tags]    CIT_TRUNK    CRT_21B    CRT_22R1    CRT_22R2
    Commission 1S1CC SCF If Needed
    General_SiSo_RF_module_power_reset

[1]General_SiSo_RU_lock_unlock
    [Tags]    CIT_TRUNK    CRT_21B    CDRT_22R1    CRT_22R2
    Commission 1S1CC SCF If Needed
    #General_SiSo_RU_lock_unlock
    General_SiSo_RU_lock_unlock_SG08    tput_self_define=${tput_1635_peak_60}    target_avg_percent=${0.5}
    ...    min_percent=${0.2}

[1]OAM_KPI_61a_SiSo_Auto_BTS_site_reset
    [Tags]    CRT_22R2    CRT_TRUNK    CRT_21B    CRT_22R1
    OAM_KPI_61a_SiSo_Auto_BTS_site_reset

[1]General_SiSo_RF_alarms_with_recovery
    [Tags]    CRT_22R2    CRT_TRUNK    CRT_21B    CRT_22R1
    General_SiSo_RF_alarms_with_recovery

[1]General_SiSo_RF_alarms_without_recovery
    [Tags]    CRT_22R2    CRT_TRUNK    CRT_21B    CRT_22R1
    General_SiSo_RF_alarms_without_recovery

[1]General_SiSo_E2E_system_setup_with_data_transfer_conducted_50MHz
    [Tags]    CIT_TRUNK    CRT_22R2
    Commission SCF With Specific Band If Needed    band=${band_1}
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type=${gNb_CuType}
#    update_parameter_manualFrameTimingAdjustment    new_value=0
#    General_SiSo_Commissioning_BTS_Template_Commissioning
    ${bandlist}    create list    ${50}    ${40}
#    General_SiSo_E2E_system_setup_with_data_transfer_multi_cc_with_different_bandwith    bandlist=${bandlist}
#    ...    cell_id=1    prach_index=98    iperf_type=via_command    enable_2197=${False}
    General_SiSo_E2E_system_setup_with_data_transfer_conducted_50MHz    tput_self_define=${tput_1635_peak}

[1]General_SiSo_E2E_system_setup_with_data_transfer_conducted_60MHz
    [Tags]    CRT_TRUNK    CRT_21B    CDRT_22R1
    update_parameter_manualFrameTimingAdjustment    new_value=0
    General_SiSo_Peak_with_Given_Information    band=60    frame_structure=1116_0ms_GP2_A7    iperf_type=via_command

[1]General_SiSo_E2E_system_setup_with_data_transfer_conducted_30MHz
    [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1
    update_parameter_manualFrameTimingAdjustment    new_value=0
    General_SiSo_Peak_with_Given_Information    band=30    frame_structure=1070_GP1_A3    iperf_type=via_command

[1]General_SiSo_E2E_system_setup_with_data_transfer_conducted_70MHz
    [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1
    update_parameter_manualFrameTimingAdjustment    new_value=1948.96
    General_SiSo_Peak_with_Given_Information    band=70    frame_structure=1116_0ms_GP2_A7    iperf_type=via_command

[1]General_SiSo_E2E_system_setup_with_data_transfer_conducted_90MHz
    [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1
    update_parameter_manualFrameTimingAdjustment    new_value=3000
    General_SiSo_Peak_with_Given_Information    band=90    frame_structure=1116_3ms_GP1_A5    iperf_type=via_command

[1]General_SiSo_E2E_system_setup_with_data_transfer_conducted_100MHz
    [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1
    update_parameter_manualFrameTimingAdjustment    new_value=3000
    General_SiSo_Peak_with_Given_Information    band=100    frame_structure=1208_GP1_A1    iperf_type=via_command

[1]General_SiSo_E2E_system_setup_with_data_transfer_conducted_70MHz_30MHz
    [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1
    Commission SCF With Specific Band If Needed    band=${band}
    COAM Wait gnb And Cells ready    timeout=15 min    gnb_type=${gNb_CuType}
#    ${bandlist}    create list    ${70}    ${30}
#    General_SiSo_E2E_system_setup_with_data_transfer_multi_cc_with_different_bandwith    bandlist=${bandlist}    cell_id=1
#    ...    prach_index=98    iperf_type=via_command    enable_2197=${False}
    General_SiSo_E2E_system_setup_with_data_transfer_conducted_70MHz    tput_self_define=${tput_1635_peak_70}

[1]CB008941-SR-AA-1_Cell_onair_Loki_based_DU_with_UL_PRB_muting_active_FDBF
    Cell_onair_Loki_based_DU_with_UL_PRB_muting_active_FDBF-AA-1

[1]CB008941-SR-AA-8_L3call_Loki_based_DU_with_short_PUCCH_FDBF
    L3call_Loki_based_DU_with_short_PUCCH_FDBF-AA-8

*** Keywords ***
