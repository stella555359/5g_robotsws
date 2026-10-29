# *** Settings ***
# Resource          ../../Resources/5GC001726_keywords.robot
# 
# 
# Documentation    Suite description
# ...   author: Ren Biyao
# ...   contact: biyao.ren@nokia-sbell.com
# ...   squad group: MMW_SG1
# ...   Feature 5GC001726-GA in 5G19B program
# 
# Force Tags    5G_RRM          5G_RAN_TDD     STATE_SW_UPLOADED     5G_RAN
# ...    PY36
# ...    CLOUD_5G_CLASSICAL_ASIBL_ABILB1_AEWB_ENB
# Suite Setup   run keywords   Import NIDD variables    AND    5GC001726_keywords.Suite Preparation
# Suite Teardown  Run keyword and ignore error    5GC001726_Keywords.Common Suite Teardown
# 
# *** Variables ***
# ${pdml_convert_f1ap_template}       {tshark_path} -r {pcap_file} -Y  \"f1ap\"  -T pdml
# 
# *** Test Cases ***
# #[1]5GC001726_GA_103_GNB-8CCDL_2CCUL_maxScell7DL1UL_online_activation
# #    [Tags]    CRT_20B    master_classicalbts_all
# #    [Documentation]    Author: Ren Biyao
# #    ...    Verify there is no effect for UE which attached already when activate actCarrierAggregation.
# #    ...    Algorithm for scell selection when caConfigurationSupport is set to 8CCDL_4CCUL.
# #    ...    Note: this case use one cell to attach.
# #    [Setup]    Test case preparation
# #
# #    COAM Update several parameters via rest api    parameters_to_update_via_api=${MODIFY_VIA_API_DISABLE_CA}
# #    Attach to pcells and do verification for configured IE    cell_index_for_attach=${1}    log_prefix=1726_GA103    verification_type=ca_disable
# #    COAM Update several parameters via rest api    parameters_to_update_via_api=${MODIFY_VIA_API_ENABLE_CA}
# #    Attach to pcells and do verification for configured IE    cell_index_for_attach=${1}    log_prefix=1726_GA103
# #    ...    verification_type=ca_enable
# #    [Teardown]    Run keyword and ignore error    Test Case Teardown
# 
# [1]5GC001726_GA_104_GNB-8CCDL_2CCUL_maxScell7DL1UL_online_deactivation
#     [Tags]    CRT_20B   CRT_21A    master_classicalbts_all    CRT_21B    CRT_22R1    CRT_22R3    CRT_22R4    CRT_23R1
#     [Documentation]    Author: Ren Biyao
#     ...    Verify there is no effect for CA UE which attached already when deactivate actCarrierAggregation.
#     ...    Note: this case use one cell to attach.
#     [Setup]    Test case preparation
# 
#     COAM Update several parameters via rest api    parameters_to_update_via_api=${MODIFY_VIA_API_ENABLE_CA}
#     Attach to pcells and do verification for configured IE    cell_index_for_attach=${1}    log_prefix=1726_GA104    verification_type=ca_enable
#     COAM Update several parameters via rest api    parameters_to_update_via_api=${MODIFY_VIA_API_DISABLE_CA}
#     Attach to pcells and do verification for configured IE    cell_index_for_attach=${1}    log_prefix=1726_GA104
#     ...    verification_type=ca_disable
#     [Teardown]    Run keyword and ignore error    Test Case Teardown
# 
# [1]5GC001726_GA_105_GNB-8CCDL_2CCUL_maxScell7DL1UL_caConfigurationSupport_value_4DL2UL
#     [Tags]    CRT_20B   CRT_21A    master_classicalbts_all    CRT_21B   CRT_22R1    CRT_22R3    CRT_22R4    CRT_23R1
#     [Timeout]    1h
#     [Documentation]    Author: Ren Biyao
#     ...    Verify the algorithm for scell selection when caConfigurationSupport set to 2(4CCDL:2CCUL)
#     [Setup]    Test case preparation
# 
#     COAM Update several parameters via rest api    parameters_to_update_via_api=${MODIFY_caConfigurationSupport_4DL2UL_VIA_API}
#     FOR    ${pcell_index}    IN    @{PCELL_INDEX}
#       Attach to pcells and do verification for configured IE    cell_index_for_attach=${pcell_index}    log_prefix=1726_GA105
#       ...    expected_dl_scell_number=${3}    expected_ul_scell_number=${1}
#     END
#     [Teardown]    Run keyword and ignore error    Test Case Teardown
# 
# [1]5GC001726_GA_107_GNB-8CCDL_2CCUL_maxScell7DL1UL_caConfigurationSupport_online_modify
#     [Tags]    CRT_20B    CRT_21A    master_classicalbts_all    CRT_21B    CRT_22R1    CRT_22R3    CRT_22R4    CRT_23R1
#     [Documentation]    Author: Ren Biyao
#     ...    Verify there is no effect for CA UE which attached already when modify caConfigurationSupport value online.
#     [Setup]    Test case preparation
# 
#     Attach to pcells and do verification for configured IE     cell_index_for_attach=${1}    log_prefix=1726_GA107    is_need_to_detach_ue=${False}
# 
#     log to console     Modify caConfigurationSupport from 8CCDL_4CCUL to 4CCDL_2CCUL online and ue will not detach
#     COAM Update several parameters via rest api    parameters_to_update_via_api=${MODIFY_caConfigurationSupport_4DL2UL_VIA_API}
#     ${log_full_path_enb}    Wait until keyword succeeds    3X    3 s    Start x2 trace capturing from enb    log_prefix=1726_GA107
#     sleep    3s
#     Stop Trace Capturing    log_prefix=1726_GA107    connection_alias=ENB
#     ${log_full_path_ute}    Download trace log    log_full_path=${log_full_path_enb}    log_dir_ute=${TS_CASE_LOG_PATH}    connection_alias=ENB
#     run keyword and continue on failure    Verify ul and dl scell number    file_path=${log_full_path_ute}
#     ...    expected_dl_scell_number=${7}    expected_ul_scell_number=${1}
# 
#     log to console    Perform ue detach and then attach again...
#     power_ue.UE Detach    ue_type=${UE_TYPE}
#     log to console    Perform ue attach again...
#     Attach to pcells and do verification for configured IE    cell_index_for_attach=${1}    log_prefix=1726_GA107
#     ...    expected_dl_scell_number=${3}    expected_ul_scell_number=${1}
#     [Teardown]    Run keyword and ignore error    Test Case Teardown
# 
# #[1]5GC001726_GA_141_GNB-8CCDL_2CCUL_maxScell7DL1UL_contiguous_freq_IWK_5GC000772_DRX_enable_SRB1
# #    [Tags]    CRT_20B    master_classicalbts_all
# #    [Documentation]    Author: Ren Biyao
# #    ...    Verify the 8CC DL and 2CC UL CA configuration can be enable on GNB with contiguous frequency when DRX is enable with SRB1.
# #    ...    Note: this case use one cell to attach.
# #    [Setup]    Test case preparation
# #
# #    COAM Update several parameters via rest api    parameters_to_update_via_api=${MODIFY_VIA_API_ENABLE_DRX}
# #    Attach to pcells and do verification for configured IE    cell_index_for_attach=${1}    log_prefix=1726_GA141
# #    ...    verification_type=scell_number&&drx_config
# #    [Teardown]    Run keyword and ignore error    Test Case Teardown
# 
# [1]5GC001726_GA_142_GNB-8CCDL_2CCUL_maxScell7DL1UL_non_contiguous_freq_IWK_5GC000772_DRX_enable_SRB3
#    [Tags]    CIT_20B    CIT_21A    master_classicalbts_all    CIT_21B    CIT_22R1    CRT_22R1    CIT_22R3    CIT_22R4
#    ...    CDRT_22R3
#    [Documentation]    Author: Ren Biyao
#    ...    Verify the 8CC DL and 2CC UL CA configuration can be enable on GNB with non-contiguous frequency
#    ...    when DRX is enable with SRB3. And the contiguous frequency type is 1+1+1+1+1+1+1+1.
#    ...    As uplink ca can only be activated when contiguous frequency, thus non-contiguous frequency will not have ca and
#    ...    therefore there is no uplink scell. Downlink ca can be activated both contiguous and non contiguous frequency.
#    ...    Note: this case use one cell to attach.
#    ...    samsung does not support 1+1+1+1+1+1+1+1 non-con ca configuration.
#    [Setup]    Run keywords    Set variables for UTE cloud    AND    Common case setup    is_log_required=${True}
# #   Test case preparation
#    Update parameters which will cause bts restart via api    parameters_to_update_via_api=${PARA_TO_MODIFY_VIA_API_GA_142}
#    Attach to pcells and do verification for configured IE
#    ...    cell_index_for_attach=${1}    log_prefix=1726_GA142    verification_type=drx_config
#    [Teardown]    Run keyword and ignore error    Test Case Teardown
