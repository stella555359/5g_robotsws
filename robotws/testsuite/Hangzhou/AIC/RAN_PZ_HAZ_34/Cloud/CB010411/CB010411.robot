*** Settings ***
Force Tags    PY36
Documentation
...    Author:linjiangjing
...    Contact:jiangjing.lin@nokia-sbell.com
...    Group: HGZ_SG8
...    Feature: CB010411

Suite Setup         run keywords    Setup Suite For Cloud    AND    Prepare scf for cases
...    AND    Slove ocp l2nrt container garbled code
Test Setup          Setup Test For Cloud
Test Teardown       Teardown Test For Cloud
Suite Teardown      Teardown Suite For Cloud
Resource          Resource/CB010411_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot

*** Variables ***
${scf_path_cu}    ${commissionings_path}/HGZ/${testline_name}/gnbs_0/cu
${scf_path_du}    ${commissionings_path}/HGZ/${testline_name}/gnbs_0/dus_0
${save_snapshot}    True

*** Test Cases ***
[1]CB010411-CR-H_15_Cloud_RMOD_MAX_TEMPERATURE counter – activation
    VDU Delta recommission update parameters by M2M API    delta_file=${enabled_counter}    wait_for_completion=True
    activate and deactivate rmod max temperature counter

[1]CB010411-CR-H_18_Cloud_SFP_RM_AVG_TEMPERATURE counter – activation
    VDU Delta recommission update parameters by M2M API    delta_file=${enabled_counter}    wait_for_completion=True
    activate and deactivate sfp rm avg temperature counter

[1]CB010411-CR-H_2_Cloud startup SFP power level 1-2 compatibility validation on RMOD
    sfp power compatibility validation on rmod

[1]CB010411-CR-H_9_The Cloud shall support NIDD parameter to enable and disable SFP+ or SFP28 compliance validation on RMOD
    sfpOperatorMode enable and SFP28 compliance disable

[1]CB010411-CR-E_03_Reconfiguration_from_full_TRX_mode_to_full_split_panel_mode_of_NR_NR_32TRX
    reboot_asky_or_cpe_ue    ue_index=${0}
    reboot_asky_or_cpe_ue    ue_index=${1}
    commission scf and make call    vdu_scf_path=${scf_path_du}/${scf_name_du_20M_20M}
    ...    cu_scf_path=${scf_path_cu}/${scf_name_cu_20M_20M}
    ...    tput_self_define=${tput_20M_20M}
    ...    wait_for_completion=True
#    swap cells split mode parameter    wait_for_completion=True

[1]CB010411-CR-E_04_Reconfiguration_from_full_split_panel_mode_of_NR_NR_32TRX_to_full_TRX_mode
    reboot_asky_or_cpe_ue    ue_index=${0}
    reboot_asky_or_cpe_ue    ue_index=${1}
    commission scf and make call    vdu_scf_path=${scf_path_du}/${scf_name_du_100M}
    ...    cu_scf_path=${scf_path_cu}/${scf_name_cu_100M}
    ...    tput_self_define=${tput_100M}
    ...    wait_for_completion=True

[1]CB010411-CR-E_05_Split_Mode_General_SiSo_Cell_block_and_unblock
    commission scf    vdu_scf_path=${scf_path_du}/${scf_name_du_40M_60M}    cu_scf_path=${scf_path_cu}/${scf_name_cu_40M_60M}
    ...    wait_for_completion=True
    reboot_asky_or_cpe_ue    ue_index=${0}
    reboot_asky_or_cpe_ue    ue_index=${1}
    Cell_block_and_unblock_and_make_call    tput_self_define=${tput_40M_60M}

[1]CB010411-CR-E_06_Split_Mode_General_SiSo_Ru_lock_and_unlock
    commission scf    vdu_scf_path=${scf_path_du}/${scf_name_du_40M_60M}     cu_scf_path=${scf_path_cu}/${scf_name_cu_40M_60M}
    ...    wait_for_completion=True
    reboot_asky_or_cpe_ue    ue_index=${0}
    reboot_asky_or_cpe_ue    ue_index=${1}
    Ru_lock_and_unlock_and_make_call    tput_self_define=${tput_40M_60M}

[1]CB010411-CR-E_07_Split_Mode_General_SiSo_RU_module_Reset_from_Web
    commission scf    vdu_scf_path=${scf_path_du}/${scf_name_du_50M_100M}     cu_scf_path=${scf_path_cu}/${scf_name_cu_50M_100M}
    ...    wait_for_completion=True
    reboot_asky_or_cpe_ue    ue_index=${0}
    reboot_asky_or_cpe_ue    ue_index=${1}
    RU_module_Reset_from_Web_and_make_call    tput_self_define=${tput_50M_100M}

[1]CB010411-CR-E_28_General_SiSo_alarm_trigger_with_split_mode
    trigger fault 7116

[1]RANNIC_reset_from_webem
    RANNIC_reset_from_webem

[1]RANNIC_reset_RU_lock_unlock_interworking_from_webem
    RANNIC_reset_RU_lock_unlock_interworking_from_webem

[1]RANNIC_reset_RU_reset_RU_lock_unlock_interworking_from_webem
    RANNIC_reset_RU_reset_RU_lock_unlock_interworking_from_webem_for_SWN

[1]CB012144-CR-A-RU_POST_data_verify_in_snapshot
    RU_POST_data_verify_in_snapshot

[1]CB012144-CR-A-RU_POST_data_verify_with_controlled_radio_reset
    RU_POST_data_verify_with_controlled_radio_reset

[1]CB012144-CR-A-RU_POST_data_verify_with_unexpected_radio_reset
    RU_POST_data_verify_with_unexpected_radio_reset

[1]RU module multiple lock unlock make call
    RU module multiple lock unlock make call

[1]RMOD Lock Unlock VDU reset
    RMOD Lock Unlock VDU reset

[1]RU module multiple reset make call
   RU module multiple reset make call

[1]RU module multiple lock reset unlock make call
    RU module multiple lock reset unlock make call

[1]Rmod multiple power off power on
    Rmod multiple power off power on

[1]Lock unlock VDU from VCU side
    Lock unlock VDU in VCU side

[1]Lock unlock NG link in VCU side
    Lock unlock NG link in VCU side

[1]Lock unlock cells in VCU side
    Lock unlock cells in VCU side

[1]RU lock power off unlock power on interworking
    RU lock power off unlock power on interworking

[1]NG lock VCU reset NG unlock
    NG lock VCU reset NG unlock

[1]VDU lock RU reset VDU unlock
    VDU lock RU reset VDU unlock

[1]VDU lock VDU reset VDU unlock
    VDU lock VDU reset VDU unlock

[1]NG lock VDU reset NG unlock
    NG lock VDU reset NG unlock

[1]NG lock RU reset NG unlock
    NG lock RU reset NG unlock

[1]Cells lock VCU reset Cells unlock
    Cells lock VCU reset Cells unlock

[1]Cells lock and unlock in VDU
    Cells lock and unlock in VDU

[1]cell lock unlock and RMOD deepsleep
    cell lock unlock and RMOD deepsleep


