# *** Settings ***
# Resource    ./../Resources/CB007271_keywords.robot
# Library   ./../Resources/UCI_verification.py
# 
# Documentation    Suite description
# ...    author: Wu rong
# ...    contact: rong.2.wu@nokia-sbell.com
# ...    squad group: MMW_SG1l
# ...    Feature 5GC002139-peak-tput
# 
# Suite Setup  7271 Suite preparation
# Suite Teardown  run keyword and ignore error    CA Suite teardown
# 
# *** Variables ***
# ${FDD_UL_EXP_TPUT_20M}     80
# ${FDD_DL_EXP_TPUT_20M}     380
# ${FDD_DL_EXP_TPUT_20M_2534}     350
# ${PREFERENCE_FILE}       ${CURDIR}/../TestData/preferences_4x4_csi_report
# 
# #*** Test Cases ***
# #CB007271_C_5GC002139_B_026_Dl_Closed_loop_4x4_rank4_CSI-RS_on PUCCH_PDSCH_transmission_fixed_mcs23
# #    [Tags]    CRT_TRUNK    CRT_22R3    CRT_22R4    CRT_23R1
# #    [Documentation]     Author: Wu Rong
# #    ...    Description:This case is to verify peak tput of FDD:20M
# #    ...    step 1>  Barred TDD
# #    ...    step 2>  Attach UE to FDD
# #    ...    step 3>  UE start uL/dL data transfer
# #
# #    [Setup]     Common case setup   NSA_SA=${NSA_SA}
# #
# #    L3 call check tput via power UE
# #    ...    dl_tput=${DL_TPUT}    ul_tput=${UL_TPUT}
# #    ...    exp_dl=${FDD_DL_EXP_TPUT_20M}
# #    ...    exp_ul=${FDD_UL_EXP_TPUT_20M}
# #    ...    tput_check_duration=300s
# #
# #    [Teardown]  run keyword and ignore error    Common case teardown    detach_ue=${True}
# #
# #CB007271-5G-C-5GC000885_E_TC01_UCI_reception_jointly_via_PUCCH_or_via_PUSCH_SA_
# #    [Tags]    CRT_TRUNK    CRT_22R3    CRT_22R4    CRT_23R1
# #    [Documentation]    Author: Lingxue Cui
# #    ...    Description: This case is to verify successful UCI transmission on PUCCH and PUSCH.
# #    [Setup]    run keywords    Common case setup    NSA_SA=${NSA_SA}
# #    ...    AND    Prepare Preference file for wireshark    preference_filepath=${PREFERENCE_FILE}
# #    ${attach_log_path}    Attach UE and capture F1AP log    attach_log_name=basic_l3call
# #    ${pcsi_config}    Get pCSI config from RRC Reconfiguration    attach_log_path=${attach_log_path}
# #    ${sr_config}      Get SR config from RRC Reconfiguration    attach_log_path=${attach_log_path}
# #
# #    Start data transfer and verify tput    data_transfer_direction=both
# #    ${bip_log_path_both}    Capture bip log    target_file_name=l1l2bip_log_both
# #    Stop data transfer based on direction    data_transfer_direction=both
# #
# #    Start data transfer and verify tput    data_transfer_direction=ul
# #    ${bip_log_path_ul}    Capture bip log    target_file_name=l1l2bip_log_ul
# #    Stop data transfer based on direction    data_transfer_direction=ul
# #
# #    Start data transfer and verify tput    data_transfer_direction=dl
# #    ${bip_log_path_dl}    Capture bip log    target_file_name=l1l2bip_log_dl
# #    Stop data transfer based on direction    data_transfer_direction=dl
# #
# #    # bip log verification
# #    run keyword and continue on failure    verify_csi_report_in_multiple_files
# #    ...    pcsi_period=${pcsi_config}[periodicity]    pcsi_offset=${pcsi_config}[offset]    bip_log_list=${bip_log_path_both}
# #    run keyword and continue on failure    Verify multiplex of pCSI and HARQ D on PUSCH
# #    ...    bip_log_path=${bip_log_path_both}[${0}]    harq_d_check=${True}
# #
# #    run keyword and continue on failure    verify_csi_report_in_multiple_files
# #    ...    pcsi_period=${pcsi_config}[periodicity]    pcsi_offset=${pcsi_config}[offset]    bip_log_list=${bip_log_path_ul}
# #    run keyword and continue on failure    Verify multiplex of pCSI and HARQ D on PUSCH
# #    ...    bip_log_path=${bip_log_path_ul}[${0}]    harq_d_check=${False}
# #
# #    run keyword and continue on failure    verify_csi_report_in_multiple_files
# #    ...    pcsi_period=${pcsi_config}[periodicity]    pcsi_offset=${pcsi_config}[offset]    bip_log_list=${bip_log_path_dl}
# #    run keyword and continue on failure    verify_sr_report_in_multiple_files
# #    ...    sr_period=${sr_config}[periodicity]    sr_offset=${sr_config}[offset]    bip_log_list=${bip_log_path_dl}
# #    Verify multiplex of pCSI SR and HARQ D on PUCCH    bip_log_path=${bip_log_path_dl}[${0}]
# #    [Teardown]    run keyword and ignore error    run keywords
# #    ...    Remove Preference file for wireshark    AND
# #    ...    Common case teardown
# #
# #CB007271-5G-C-5GC002534-A_001_PDSCH_traffic_at_SSB_slot_SA_chBW_20MHz
# #    [Tags]    CRT_TRUNK    CRT_22R3    CRT_22R4    CRT_23R1
# #    [Documentation]     Author: Jin Journey
# #    ...    Description:The purpose of this test is to verify that gNB can support PDSCH scheduling at SSB slot without Ct
# #    ...    step 1>  Enable feature,attach to FDD and check tput
# #    ...    step 2>  Capture bip log and check pdsch at ssb slot
# #    ...    step 3>  Check PM counter M55308C00015 M55308C00016 M55308C00005 M55308C00008
# #    ...    step 4>  Disable feature,attach to FDD and check tput
# #    ...    step 5>  Verify dl avg tput of feature enable is bigger than feature disable
# #
# #    [Setup]     Common case setup   NSA_SA=${NSA_SA}
# #
# #    ${tput_feature_enable}    L3 call and check tput for each cell    cell_id=${FDD_CELL_ID}    dl_throughput=${DL_TPUT}
# #    ...    ul_throughput=${UL_TPUT}    exp_dl=${FDD_DL_EXP_TPUT_20M_2534}    exp_ul=${FDD_UL_EXP_TPUT_20M}
# #    ${starting_log_timestamp}    Prepare for counter log
# #    run keyword and continue on failure    Capture bip log and verify pdsch at ssb slot
# #    run keyword and continue on failure    Check PM counter M55308C00015 M55308C00016 M55308C00005 M55308C00008
# #    ...    starting_log_timestamp=${starting_log_timestamp['log_generator_timestamp']}
# #    run keyword and continue on failure    Stop data transfer based on direction
# #    run keyword and continue on failure    Retry commercial ue detach if failed
# #    ${tput_feature_disable}    Disable 2534 and check tput
# #    Verify dl avg tput of feature enable is bigger than feature disable
# #    ...    tput_feature_enable=${tput_feature_enable}    tput_feature_disable=${tput_feature_disable}
# #
# #    [Teardown]  run keyword and ignore error    Common case teardown    detach_ue=${True}    restapi_restore_nidd=${RESTAPI_ENABLE_2534}
