# *** Settings ***
# Resource    ./../Resources/1596_1726_561_Keywords.robot
# 
# Documentation
# ...   author: Liu Zheng
# ...   contact: zheng.4.liu@nokia-sbell.com
# ...   squad group: MMW_SG1
# ...   Feature 5GC001596 in 5G19B program, RU type:AEWD
# 
# Force Tags    RAN_5G    RAN_5G_TDD
# ...    PY39
# ...           5G_RAN_TDD     STATE_SW_UPLOADED     5G_RAN    CLOUD_5G_CLASSICAL_ASIBL_ABILB1_AEWB_ENB
# ...           master_classicalbts_all    20Bb1_classicalbts    21A_classicalbts    SBTS00
# 
# 
# Suite Setup     1596_1726_561_Keywords.Suite preparation
# 
# Suite Teardown  Run Keyword And Ignore Error    5GC001596_D_Keywords.Suite env recovery
# 
# 
# *** Test Cases ***
# #[1]5GC001596_D_003_BTS_Commissioning_several_times
# #    [Tags]    CRT_UTE
# #    [Setup]    1596_1726_561_Keywords.Case preparation    act_xcc_cell_number=${4}    scf_template_path=${GOLDEN_FULL_SCF_8CC}
# #    ...    list_para_to_delete=${TL_PARAMS_TO_DELETE_4CC_1596}    list_para_to_modify=${TL_PARAMS_TO_MODIFY_4CC_CONTINOUS_1956}
# #    ...    scf_process_needed=${False}
# #    1596_BTS_Commissioning_several_times    is_pdl_checking_needed=${True}    scf_template_path=${GOLDEN_FULL_SCF_4CC}
# #    [Teardown]    Run Keyword And Ignore Error    Case env recovery
# 
# 
# [1]5GC001596_D_005_General_SiSo_RF_module_reset_from_GUI
#     [Tags]    CRT_UTE
#     [Setup]    run keyword and ignore error    Common case setup    is_log_required=${False}
#     1596_1726_561_Keywords.Case preparation    act_xcc_cell_number=${4}    scf_template_path=${GOLDEN_FULL_SCF_8CC}
#     ...    list_para_to_delete=${TL_PARAMS_TO_DELETE_4CC_1596}    list_para_to_modify=${TL_PARAMS_TO_MODIFY_4CC_CONTINOUS_1956}
#     ...    scf_process_needed=${True}
# #    1596_BTS_Commissioning_several_times    is_pdl_checking_needed=${True}    scf_template_path=${GOLDEN_FULL_SCF_4CC}
#     1596_General_SiSo_RF_module_reset_from_GUI
#     [Teardown]     Run Keyword And Ignore Error    Case env recovery
# 
# [1]5GC001596_D_006_General_SiSo_RF_module_power_reset
#     [Tags]    CRT_UTE
#     [Setup]    run keyword and ignore error    Common case setup    is_log_required=${False}
#     1596_1726_561_Keywords.Case preparation    act_xcc_cell_number=${4}    scf_template_path=${GOLDEN_FULL_SCF_8CC}
#     ...    list_para_to_delete=${TL_PARAMS_TO_DELETE_4CC_1596}    list_para_to_modify=${TL_PARAMS_TO_MODIFY_4CC_CONTINOUS_1956}
#     ...    scf_process_needed=${False}
#     1596_General_SiSo_RF_module_power_reset
#     [Teardown]    Run Keyword And Ignore Error    Case env recovery    operation=ru_power_on
# 
# [1]5GC001596_D_002_OAM_report_alarm_while_configuration_error
#     [Tags]    CRT_UTE
#     [Setup]    run keyword and ignore error    Common case setup    is_log_required=${False}
#     1596_1726_561_Keywords.Case preparation    act_xcc_cell_number=${4}    scf_template_path=${GOLDEN_FULL_SCF_8CC}
#     ...    list_para_to_delete=${TL_PARAMS_TO_DELETE_4CC_1596}    list_para_to_modify=${TL_PARAMS_TO_MODIFY_4CC_CONTINOUS_1956}
#     ...    scf_process_needed=${False}
#     1596_OAM_report_alarm_while_configuration_error
#     [Teardown]    Run Keyword And Ignore Error    Case env recovery
# 
# [1]5GC001596_D_014_Stability_Start-up_time_measurement_for_cell_onair
#     [Tags]    CRT_UTE
#     [Setup]    run keyword and ignore error    Common case setup    is_log_required=${False}
#     1596_1726_561_Keywords.Case preparation    act_xcc_cell_number=${4}    scf_template_path=${GOLDEN_FULL_SCF_8CC}
#     ...    list_para_to_delete=${TL_PARAMS_TO_DELETE_4CC_1596}    list_para_to_modify=${TL_PARAMS_TO_MODIFY_4CC_CONTINOUS_1956}
#     ...    scf_process_needed=${False}
#     1596_Stability_Start-up_time_measurement_for_cell_onair
#     [Teardown]    Run Keyword And Ignore Error    Case env recovery
# 
# #[1]5GC001596_D_010_General_SiSo_E2E_system_setup_with_data_transfer
# #    [Tags]    CRT_UTE
# #    [Setup]    1596_1726_561_Keywords.Case preparation    act_xcc_cell_number=${4}    scf_template_path=${GOLDEN_FULL_SCF_8CC}
# #    ...    list_para_to_delete=${TL_PARAMS_TO_DELETE_4CC_1596}    list_para_to_modify=${TL_PARAMS_TO_MODIFY_4CC_CONTINOUS_1956}
# #    ...    scf_process_needed=${False}    is_l3_call_case=${True}
# #    Call case with QCOM UE and record throughput info for many cells many times
# #    ...    repeat_times=${TEST_REPEAT_TIMES}     verify_duration=${VERIFY_DURATION}
# #    ...    ul_exp_tput=${UL_EXPECT}    dl_exp_tput=${DL_EXPECT}    exp_tput_percentage=${EXP_TPUT_PERCENTAGE}
# #    [Teardown]    Run Keyword And Ignore Error    Case env recovery    is_revert_defaultlnrelgnbcellid_needed=${True}
# 
# [1]5GC001596_D_019_cell_onair_successful_without_alarm_non_contiguous_freq
#     [Tags]    CRT_UTE
#     [Documentation]    author: Cui Lingxue
#     ...    qc pass crt
#     ...    Verify whether gNB can be onair status successfully without any unexpected alarms with classical gNB configuration with
#     ...    mmWave eCPRI configuration block 1S-2CC-2DL-2UL-2CC-2DL-0UL using 1 single ABIL and non-contiguous frequency.
#     [Setup]    run keyword and ignore error    Common case setup    is_log_required=${False}
#     1596_1726_561_Keywords.Case preparation    act_xcc_cell_number=${4}    scf_template_path=${GOLDEN_FULL_SCF_8CC}
#     ...    list_para_to_delete=${TL_PARAMS_TO_DELETE_4CC_1596}    list_para_to_modify=${TL_PARAMS_TO_MODIFY_4CC_NON_CONTINOUS_1956}
#     ...    scf_process_needed=${True}    is_l3_call_case=${True}
#     Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist
#     ...    allowed_faults=@{ALLOWED_FAULT_LIST}    file_path=${TS_LOG_PATH_BASE}    connection=GNB_OAM
#     Call case with QCOM UE and record throughput info for many cells many times    para_update_timeout=${TIMEOUT_MODIFY_PARA}
#     ...    repeat_times=${TEST_REPEAT_TIMES}    verify_duration=${VERIFY_DURATION}
#     ...    ul_exp_tput=${UL_EXPECT}    dl_exp_tput=${DL_EXPECT}
#     [Teardown]    Run Keyword And Ignore Error    Case env recovery    is_revert_defaultlnrelgnbcellid_needed=${True}
# 
# #[1]5GC001596_F_003_BTS_Commissioning_several_times
# #    [Tags]    CRT_UTE
# #    [Setup]    1596_1726_561_Keywords.Case preparation    act_xcc_cell_number=${8}    scf_template_path=${GOLDEN_FULL_SCF_8CC}
# #    ...    scf_process_needed=${False}
# #    1596_BTS_Commissioning_several_times    is_pdl_checking_needed=${True}    scf_template_path=${GOLDEN_FULL_SCF_8CC}
# #    [Teardown]    Run Keyword And Ignore Error    Case env recovery
# 
# [1]5GC001596_F_004_General_SiSo_RF_module_reset_triggered_by_user_as_part_of_BTS_reset
#     [Tags]    CRT_UTE
#     [Setup]    run keyword and ignore error    Common case setup    is_log_required=${False}
#     1596_1726_561_Keywords.Case preparation    act_xcc_cell_number=${8}    scf_template_path=${GOLDEN_FULL_SCF_8CC}
#     ...    scf_process_needed=${True}    is_alias_created=${True}    if_create_ru_alias_needed=${True}
# #    1596_BTS_Commissioning_several_times    is_pdl_checking_needed=${True}    scf_template_path=${GOLDEN_FULL_SCF_8CC}
#     1596_General_SiSo_RF_module_reset_triggered_by_user_as_part_of_BTS_reset
#     [Teardown]    Run Keyword And Ignore Error    Case env recovery
# 
# [1]5GC001596_F_006_General_SiSo_RF_module_power_reset
#     [Tags]    CRT_UTE
#     [Setup]    run keyword and ignore error    Common case setup    is_log_required=${False}
#     1596_1726_561_Keywords.Case preparation    act_xcc_cell_number=${8}    scf_template_path=${GOLDEN_FULL_SCF_8CC}
#     ...    scf_process_needed=${False}
#     1596_General_SiSo_RF_module_power_reset
#     [Teardown]    Run Keyword And Ignore Error    Case env recovery    operation=ru_power_on
# 
# [1]5GC001596_F_014_Stability_Start-up_time_measurement_for_cell_onair
#     [Tags]    CRT_UTE
#     [Setup]    run keyword and ignore error    Common case setup    is_log_required=${False}
#     1596_1726_561_Keywords.Case preparation    act_xcc_cell_number=${8}    scf_template_path=${GOLDEN_FULL_SCF_8CC}
#     ...    scf_process_needed=${False}
#     1596_Stability_Start-up_time_measurement_for_cell_onair
#     [Teardown]    Run Keyword And Ignore Error    Case env recovery
# 
# #[1]5GC001596_F_010_General_SiSo_E2E_system_setup_with_data_transfer
# #    [Tags]    CRT_UTE
# #    [Setup]     1596_1726_561_Keywords.Case preparation    act_xcc_cell_number=${8}    scf_template_path=${GOLDEN_FULL_SCF_8CC}
# #    ...    scf_process_needed=${False}    is_l3_call_case=${True}
# #    Call case with QCOM UE and record throughput info for many cells many times    para_update_timeout=${TIMEOUT_MODIFY_PARA}
# #    ...    repeat_times=${TEST_REPEAT_TIMES}    verify_duration=${VERIFY_DURATION}
# #    ...    ul_exp_tput=${UL_EXPECT}    dl_exp_tput=${DL_EXPECT}
# #    [Teardown]    Run Keyword And Ignore Error    Case env recovery    is_revert_defaultlnrelgnbcellid_needed=${True}
# 
# #[1]5GC001726_GA_103_GNB-8CCDL_2CCUL_maxScell7DL1UL_online_activation
# #    [Tags]    CRT_UTE
# ##    [Tags]    CRT_UTE    QC_57964
# #    [Documentation]    original CRT    Verify there is no effect for UE which attached already when activate actCarrierAggregation.
# #    ...    Algorithm for scell selection when caConfigurationSupport is set to 8CCDL_4CCUL.
# #    ...    Note: this case use one cell to attach.
# #    [Setup]    1596_1726_561_Keywords.Case preparation    act_xcc_cell_number=${8}    scf_template_path=${GOLDEN_FULL_SCF_8CC}
# #    ...    scf_process_needed=${True}
# #    ...    list_para_to_modify=${TL_PARAMS_TO_MODIFY_8CC_CA}
# #    ...    list_para_to_add=${TL_PARAMS_TO_ADD_8CC_CA}
# #    update parameters for CA and attach and verify    cell_index_for_attach=${1}    log_prefix=1726_GA103
# #    ...    verification_type=ca_disable    parameters_to_update_via_api=${MODIFY_VIA_API_DISABLE_CA}
# #    update parameters for CA and attach and verify    cell_index_for_attach=${1}    log_prefix=1726_GA103
# #    ...    verification_type=ca_enable    parameters_to_update_via_api=${MODIFY_VIA_API_ENABLE_CA}
# #    [Teardown]    Run keyword and ignore error    Case env recovery    is_revert_CA_parameters_needed=${True}
# 
# [1]5GC001726_GA_104_GNB-8CCDL_2CCUL_maxScell7DL1UL_online_deactivation
#     [Tags]    CRT_UTE
# #    [Tags]    CRT_UTE    QC_57967
#     [Documentation]    original CRT    Verify there is no effect for CA UE which attached already when deactivate actCarrierAggregation.
#     ...    Note: this case use one cell to attach.
#     [Setup]    run keyword and ignore error    Common case setup    is_log_required=${False}
#     1596_1726_561_Keywords.Case preparation    act_xcc_cell_number=${8}    scf_template_path=${GOLDEN_FULL_SCF_8CC}
#     ...    scf_process_needed=${True}
#     ...    list_para_to_modify=${TL_PARAMS_TO_MODIFY_8CC_CA}
#     ...    list_para_to_add=${TL_PARAMS_TO_ADD_8CC_CA}
#     update parameters for CA and attach and verify    cell_index_for_attach=${1}    log_prefix=1726_GA104
#     ...    verification_type=ca_enable    parameters_to_update_via_api=${MODIFY_VIA_API_ENABLE_CA}
#     update parameters for CA and attach and verify    cell_index_for_attach=${1}    log_prefix=1726_GA104
#     ...    verification_type=ca_disable    parameters_to_update_via_api=${MODIFY_VIA_API_DISABLE_CA}
#     [Teardown]    Run keyword and ignore error    Case env recovery    is_revert_CA_parameters_needed=${True}
# 
# [1]5GC001726_GA_105_GNB-8CCDL_2CCUL_maxScell7DL1UL_caConfigurationSupport_value_4DL2UL
#     [Tags]    CRT_UTE
# #    [Tags]    CRT_UTE    QC_57968
#     [Documentation]    original CRT Verify the algorithm for scell selection when caConfigurationSupport set to 2(4CCDL:2CCUL)
#     [Setup]    run keyword and ignore error    Common case setup    is_log_required=${False}
#     1596_1726_561_Keywords.Case preparation    act_xcc_cell_number=${8}    scf_template_path=${GOLDEN_FULL_SCF_8CC}
#     ...    list_para_to_modify=${TL_PARAMS_TO_MODIFY_8CC_CA}
#     ...    list_para_to_add=${TL_PARAMS_TO_ADD_8CC_CA}    scf_process_needed=${False}
#     8CCDL_2CCUL_maxScell7DL1UL_caConfigurationSupport_value_4DL2UL
#     [Teardown]    Run keyword and ignore error    Case env recovery    is_revert_CA_parameters_needed=${True}
# 
# [1]5GC001726_GA_107_GNB-8CCDL_2CCUL_maxScell7DL1UL_caConfigurationSupport_online_modify
#     [Tags]    CRT_UTE
# #    [Tags]    CRT_UTE    QC_57957
#     [Documentation]   original CRT    Verify there is no effect for CA UE which attached already when modify caConfigurationSupport value online.
#     [Setup]    run keyword and ignore error    Common case setup    is_log_required=${False}
#     1596_1726_561_Keywords.Case preparation    act_xcc_cell_number=${8}    scf_template_path=${GOLDEN_FULL_SCF_8CC}
#     ...    list_para_to_modify=${TL_PARAMS_TO_MODIFY_8CC_CA}
#     ...    list_para_to_add=${TL_PARAMS_TO_ADD_8CC_CA}    scf_process_needed=${False}
#     8CCDL_2CCUL_maxScell7DL1UL_caConfigurationSupport_online_modify
#     [Teardown]    Run keyword and ignore error    Case env recovery    is_revert_CA_parameters_needed=${True}
# 
# #[1]5GC001726_GA_141_GNB-8CCDL_2CCUL_maxScell7DL1UL_contiguous_freq_IWK_5GC000772_DRX_enable_SRB1
# #    [Tags]    CRT_UTE
# ##    [Tags]    CRT_UTE    QC_57970
# #    [Documentation]    original CRT
# #    ...    Verify the 8CC DL and 2CC UL CA configuration can be enable on GNB with contiguous frequency when DRX is enable with SRB1.
# #    ...    Note: this case use one cell to attach.
# #    [Setup]    1596_1726_561_Keywords.Case preparation    act_xcc_cell_number=${8}    scf_template_path=${GOLDEN_FULL_SCF_8CC}
# #    ...    list_para_to_modify=${TL_PARAMS_TO_MODIFY_8CC_CA}
# #    ...    list_para_to_add=${TL_PARAMS_TO_ADD_8CC_CA}    scf_process_needed=${False}
# #    update parameters for CA and attach and verify    cell_index_for_attach=${1}    log_prefix=1726_GA141
# #    ...    verification_type=scell_number&&drx_config    parameters_to_update_via_api=${MODIFY_VIA_API_ENABLE_DRX}
# #    [Teardown]    Run keyword and ignore error    Case env recovery    is_revert_CA_parameters_needed=${True}
# 
# #[1]5GC001726_GH_861_GNB-8CCDL_2CCUL_maxScell7DL1UL_contiguous_with_new_deployment_IWK_5GC000918_ecpri_analog_beamforming_32beam
# #    [Tags]    CRT_UTE
# ##    [Tags]    CRT_UTE    QC_57966
# #    [Documentation]    author: Wang Yixiang
# #    ...    Verify new deployment throughput  for one ue when contiguous frequency 8CC DL and 2CC UL with 5GC000918(eCPRI Analog beamforming)
# #    ...    with 32 beam in mmW bands
# #    ...    20200630: confim with QJ that will use 1 drb instead, as FGCR introduced and 1 drb can reach peak. And confi
# ...rm with Hangjun and zhenghua
# #    ...              that no need to check deployment.
# #    ...    20201208: the 8cc peak cases have been overed by 1937, thus modify the case
# #    [Setup]    1596_1726_561_Keywords.Case preparation    act_xcc_cell_number=${8}    scf_template_path=${GOLDEN_FULL_SCF_8CC}
# #    ...    list_para_to_modify=${TL_PARAMS_TO_MODIFY_8CC_CA}
# #    ...    list_para_to_add=${TL_PARAMS_TO_ADD_8CC_CA}    scf_process_needed=${False}
# #    ${status}    run keyword and return status    Attach and check peak tput
# #    ...    act_dl_tput=${4000}
# #    ...    act_ul_tput=${100}
# #    ...    exp_ul_tput=${1}
# #    ...    exp_dl_tput=${1}
# #    ...    cell_number=1-4
# #    ...    duration_time_for_once=${10}
# #    ...    retry_time=${1}
# #    [Teardown]    Run Keyword And Ignore Error    Case env recovery    is_revert_CA_parameters_needed=${True}
# 
# #[1]5GC001726_GH_862_GNB-8CCDL_2CCUL_maxScell7DL1UL_non_contiguous_with_new_deployment_IWK_5GC000918_ecpri_analog_beamforming_32beam
# #    [Tags]     CRT_UTE
# ##    [Tags]     CRT_UTE    QC_57965
# #    [Documentation]    author: Wang Yixiang
# #    ...    Verify new deployment throughput  for one ue when contiguous frequency 8CC DL and 2CC UL with 5GC000918(eCPRI Analog beamforming)
# #    ...    with 32 beam in mmW bands
# #    ...    20200630: confim with QJ that will use 1 drb instead, as FGCR introduced and 1 drb can reach peak.
# #    ...    20201208: the 8cc peak cases have been overed by 1937, thus modify the case
# #    [Setup]    1596_1726_561_Keywords.Case preparation    act_xcc_cell_number=${8}    scf_template_path=${GOLDEN_FULL_SCF_8CC}
# #    ...    list_para_to_modify=${TL_PARAMS_TO_MODIFY_8CC_CA}
# #    ...    list_para_to_add=${TL_PARAMS_TO_ADD_8CC_CA}    scf_process_needed=${False}
# #    ${status}    run keyword and return status    Attach and check peak tput
# #    ...    act_dl_tput=${4000}
# #    ...    act_ul_tput=${100}
# #    ...    exp_ul_tput=${1}
# #    ...    exp_dl_tput=${1}
# #    ...    cell_number=1-4
# #    ...    duration_time_for_once=${10}
# #    ...    retry_time=${1}
# #    [Teardown]    Run Keyword And Ignore Error    Case env recovery    is_revert_CA_parameters_needed=${True}
# 
# [1]5GC001726_GF_608_GNB-8CCDL_2CCUL_maxScell7DL1UL_non-contiguous_UE8DL2UL_1UE_enhanced_csi-rs_configure_and_simultaneousCSI-ReportsAllCC
#     [Tags]    CRT_UTE
# #    [Tags]    CRT_UTE    QC_57971
#     [Documentation]    author: Wang Yixiang
#     ...    Verify enhanced CSI configuration and reporting support when non-contiguous frequency
#     ...    8CC DL and 2CC UL with analog beamforming in mmW bands
#     [Setup]    run keyword and ignore error    Common case setup    is_log_required=${False}
#     1596_1726_561_Keywords.Case preparation    act_xcc_cell_number=${8}    scf_template_path=${GOLDEN_FULL_SCF_8CC}
#     ...    list_para_to_modify=${TL_PARAMS_TO_MODIFY_8CC_CA}
#     ...    list_para_to_add=${TL_PARAMS_TO_ADD_8CC_CA}    scf_process_needed=${False}
#     GF_608_GNB-8CCDL_2CCUL_maxScell7DL1UL_non-contiguous_UE8DL2UL_1UE_enhanced_csi-rs_configure_and_simultaneousCSI-ReportsAllCC
#     [Teardown]    Run Keyword And Ignore Error    Case env recovery    is_revert_CA_parameters_needed=${False}
#     ...    detach_ue=${True}
# 
# [1]5GC001726_GA_122_M55118C02008_M55118C03008
#     [Tags]    CRT_UTE
#     [Documentation]    author: Wang Yixiang
#     ...    Verify enhanced CSI configuration and reporting support when non-contiguous frequency
#     ...    8CC DL and 2CC UL with analog beamforming in mmW bands
#     [Setup]    run keyword and ignore error    Common case setup    is_log_required=${False}
#     1596_1726_561_Keywords.Case preparation    act_xcc_cell_number=${8}    scf_template_path=${GOLDEN_FULL_SCF_8CC}
#     ...    list_para_to_modify=${TL_PARAMS_TO_MODIFY_8CC_CA}
#     ...    list_para_to_add=${TL_PARAMS_TO_ADD_8CC_CA}    scf_process_needed=${True}
# 
#     ${CELL_ID}  create list  1  2  3  4  5  6  7  8
#     1726_GA_122_M55118C02008_M55118C03008     cell_id=${CELL_ID}    num_cells_with_expected_counter_work=${1}
#     [Teardown]    Run Keyword And Ignore Error    Case env recovery    is_revert_CA_parameters_needed=${False}
#     ...    detach_ue=${True}
# 
# [1]5GC001726_GA_126_M55118C04006_M55118C05006
#     [Tags]    CRT_UTE
#     [Documentation]    author: Wang Yixiang
#     ...    Verify enhanced CSI configuration and reporting support when non-contiguous frequency
#     ...    8CC DL and 2CC UL with analog beamforming in mmW bands
#     [Setup]    run keyword and ignore error    Common case setup    is_log_required=${False}
#     1596_1726_561_Keywords.Case preparation    act_xcc_cell_number=${8}    scf_template_path=${GOLDEN_FULL_SCF_8CC}
#     ...    list_para_to_modify=${TL_PARAMS_TO_MODIFY_8CC_CA}
#     ...    list_para_to_add=${TL_PARAMS_TO_ADD_8CC_CA}    scf_process_needed=${True}
#     1726_GA_126_M55118C04006_M55118C05006
#     [Teardown]    Run Keyword And Ignore Error    Case env recovery    is_revert_CA_parameters_needed=${False}
#     ...    detach_ue=${True}
# 
# [1]5GC000561_002_PTP_syncE_message_should_be_provide_on_ABIL_ecpri_port_S-RF1
#     [Tags]
#     [Documentation]
#     ...    PTP_syncE_message_should_be_provide_on_ABIL_ecpri_port_S-RF1
#     [Setup]    run keyword and ignore error    Common case setup    is_log_required=${False}
#     Connect to Common Unit Master    alias=ASIK Master
#     ${status}    run keyword and return status
#     ...    PTP_syncE_message_should_be_provide_on_ABIL_ecpri_port_S-RF1
#     [Teardown]    run keyword and ignore error    Common case teardown    is_log_required=${False}
# 
# [1]5GC001596_F_019_cell_onair_successful_without_alarm_non_contiguous_freq
#     [Tags]
#     [Documentation]
#     ...    Verify whether gNB can be onair status successfully without any unexpected alarms with classical gNB configuration with
#     ...    mmWave eCPRI configuration block 1S-2CC-2DL-2UL-6CC-2DL-0UL using 1 single ABIL and non-contiguous frequency.
#     [Setup]    run keyword and ignore error    Common case setup    is_log_required=${False}
#     Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist
#     ...    allowed_faults=@{ALLOWED_FAULT_LIST}    file_path=${TS_CASE_LOG_PATH}    connection=GNB_OAM
#     Call case with QCOM UE and record throughput info for many cells many times
#     ...    para_update_timeout=${TIMEOUT_MODIFY_PARA}
#     ...    repeat_times=${TEST_REPEAT_TIMES}    verify_duration=${VERIFY_DURATION}
#     ...    ul_exp_tput=${UL_EXPECT}    dl_exp_tput=${DL_EXPECT}
#     [Teardown]    run keyword and ignore error    Common case teardown    is_log_required=${False}
# 
# [1]5GC001596_D_004_General_SiSo_RF_module_reset_triggered_by_user_as_part_of_BTS_reset
#     [Tags]    CRT_UTE
#     [Setup]    run keyword and ignore error    Common case setup    is_log_required=${False}
#     ${status}    run keyword and return status
#     ...    1596_General_SiSo_RF_module_reset_triggered_by_user_as_part_of_BTS_reset
#     [Teardown]    run keyword and ignore error    Common case teardown    is_log_required=${False}
# 
# [1]5GC001596_F_005_General_SiSo_RF_module_reset_from_GUI
#     [Tags]
#     [Setup]    run keyword and ignore error    Common case setup    is_log_required=${False}
#     1596_General_SiSo_RF_module_reset_from_GUI
#     [Teardown]    run keyword and ignore error    Common case teardown    is_log_required=${False}
# 
# #[1]5GC001726_GA_129_M55118C04012_M55118C05012
# #    [Documentation]    Author: Ren Biyao
# #    ...    Terminal is qcom ue. Verify the PM counters M55118C04012 and M55118C05012 can work correctly.
# #    ...    The contiguous frequency type is 2+2+1+1+1+1.
# #    ...    The case needs to check the counter which can record a period of attach time.
# #    ...    The design idea is to make ue attach for more than 5min, and the counter will be generated every 5min. Then the
# #    ...    last file generated will record number 300 in representative of attach 5min. But in the current bts version,
# #    ...    299, 301 may also happen and can be regard as correct value.
# #    [Tags]     CRT_UTE
# ##    [Tags]     CRT_UTE    QC_57969
# #    [Setup]    1596_1726_561_Keywords.Case preparation    act_xcc_cell_number=${8}    scf_template_path=${GOLDEN_FULL_SCF_8CC}
# #    ...    list_para_to_modify=${TL_PARAMS_TO_MODIFY_8CC_CA}
# #    ...    list_para_to_add=${TL_PARAMS_TO_ADD_8CC_CA}    scf_process_needed=${False}
# #    1726_GA_129_M55118C04012_M55118C05012
# #    [Teardown]    Run keyword and ignore error   Case env recovery    is_revert_CA_parameters_needed=${False}
# 
# #[1]5GC002033_A_012_cell_addtion_deletion_on_WebUI_config_4cc_2dl_2ul_ASIK
# #    [Tags]    CRT_UTE
# #    [Documentation]    author: fang ludan
# #    [Setup]    run keyword and ignore error    Common case setup    is_log_required=${True}
# #    ${status}    run keyword and return status
# #    ...    A_012_cell_addtion_deletion_on_WebUI_config_4cc_2dl_2ul_ASIK
# #    [Teardown]   Run Keyword And Ignore Error    Common case teardown   is_log_required=${True}  detach_ue=${True}
# [1]5GC001596_F_002_OAM_report_alarm_while_configuration_error
#     [Tags]    CRT_UTE
#     [Setup]    run keyword and ignore error    Common case setup    is_log_required=${False}
#     ${status}    run keyword and return status
#     ...    1596_OAM_report_alarm_while_configuration_error
#     [Teardown]    run keyword and ignore error    Common case teardown    is_log_required=${False}
# 
# [1]5GC001596_D_016_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
#     [Tags]
#     [Setup]    run keyword and continue on failure     Common case setup    is_log_required=${False}
#     D_016_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
#     [Teardown]    run keyword and ignore error    Common case teardown    is_log_required=${False}
# 
# [1]5GC001596_F_017_General_SiSo_Cell_group_lock_and_unlock
#     [Tags]    CRT_UTE
#     [Setup]    run keyword and ignore error    Common case setup    is_log_required=${False}
#     ${status}    run keyword and return status
#     ...    Perform cell group lock unlock and check throughput for many cell group many times    cellgrp_index_list=${CELLGRP_INDEX_LIST}
#     ...    para_update_timeout=${TIMEOUT_MODIFY_PARA}    repeat_times=${TEST_REPEAT_TIMES}    verify_duration=${VERIFY_DURATION}
#     ...    ul_exp_tput=${UL_EXPECT}    dl_exp_tput=${DL_EXPECT}    connection=GNB_OAM
#     [Teardown]    run keyword and ignore error    Common case teardown    is_log_required=${False}
# 
# [1]CB007459-A-7_Proactive_UL_scheduling_for_a_selected_UE_performing_ping_request
#     [Tags]
#     [Setup]    run keyword and ignore error    Common case setup    is_log_required=${False}
#     ${status}    run keyword and return status    log
#     ...    Proactive_UL_scheduling_for_a_selected_UE_performing_ping_request
#     [Teardown]    run keyword and ignore error    Common case teardown    is_log_required=${False}
# 
# 
# [1]CB007886_01_Cell_Service_Status_Indication_In_Service_SA_mode
#     [Tags]
#     [Documentation]     The purpose of this test case is to test gNB behaviour for handling cell service status
#     ...    indication at the time of SA mode cell set up (In-Service Status).
#     [Setup]    run keyword and ignore error    Common case setup    is_log_required=${False}
#     ${status}    run keyword and return status   log
#     ...    Cell_Service_Status_Indication_In_Service_SA_mode
#     [Teardown]    run keyword and ignore error    Common case teardown    is_log_required=${False}
# 
# [1]CB007077_A_13_deactivatedOrDisabled_to_be_activeAndEnabled_mixedModeByrecoverySctpX2ThenNG
# #    [Tags]    CRT_UTE
#     [Documentation]
#     ...    This scenario addresses gNB behavior for the case wherein both an associated NG link and an assosiated X2
#     ...    link of a Mixed NSA 3x + SA 2 mode cell are recovered and cell is activated and operational in mixed mode
#     ...    ADD cp: check 5min SA tput, both ul and dl at least 30M
#     [Setup]    run keyword and ignore error    Common case setup    is_log_required=${False}
#     ${status}    run keyword and return status   log
#     ...    deactivatedOrDisabled_to_be_activeAndEnabled_mixedModeByrecoverySctpX2ThenNG
#     [Teardown]    run keyword and ignore error    Common case teardown    is_log_required=${False}
# 
# [1]5GC002056-AGAS_004_Ciphering_algo_NEA1_NEA2_and_NEA3_with_same_priorities_check_NEA2_is_selected
#     [Documentation]
#     ...    The purpose of this test case is to check that when ciphering algorithms are configured with
#     ...    the same priority in O&M, the NEA2(AES) shall be selected.
#     ...    need add to CIT_21A
# #    [Tags]    CRT_UTE
#     [Timeout]    1 hour
#     [Setup]    run keyword and ignore error    Common case setup    is_log_required=${False}
#     ${status}    run keyword and return status   log
#     ...    Ciphering_algo_NEA1_NEA2_and_NEA3_with_same_priorities_check_NEA2_is_selected
#     [Teardown]    run keyword and ignore error    Common case teardown    is_log_required=${False}
# 
# [1]5GC002056-AIAJ_003_SgNB_release_based_on_A2_without_SRB3
#    [Documentation]    author: Ren Biyao
#    ...    This case verify SgNB release based on A2 without SRB3
# #   [Tags]    CRT_UTE
#    [Setup]    run keyword and ignore error    Common case setup    is_log_required=${False}
#    ${status}    run keyword and return status   log
#    ...    SgNB_release_based_on_A2_without_SRB3
#    [Teardown]    run keyword and ignore error    Common case teardown    is_log_required=${False}
# 
# *** Keywords ***
# 
