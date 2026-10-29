# *** Settings ***
# Documentation
# ...    author: Liu Zheng
# ...    contact: zheng.4.liu@nokia-sbell.com
# ...    squad group: 5G_PZ_MMW_HZ_1_SG
# ...    feature : 5GC002056
# 
# 
# Resource    ../Resources/5GC002056_Keywords.robot
# 
# Force Tags    CA_5G_RRM            0.800    11.800
# ...    PY36
# 
# Suite Setup    Suite preparation
# 
# Suite Teardown     Run Keyword And Ignore Error    Suite env recovery
# 
# *** Test Cases ***
# [1]5GC002056-AGAS_003_Ciphering_algo_list_and_priorities_in_OAM_for_NEA3_and_NEA2
#     [Documentation]
#     ...    The purpose of this test case is to check that ciphering algorithm list (NEA2, NEA3) and related
#     ...    priorities can be configured on gNB OAM and applied in gNB-CU (L2-Hi).
#     [Tags]    CRT_21A    CRT_21B    CRT_22R1     CRT_22R2
#     [Timeout]    1 hour
#     [Setup]    Case preparation
#     run keyword and continue on failure    Should be true    ${PDL_VALIDATION_RESULT}!=${False}
#     ...    msg=Commissioned with error exists, pdl validation result is not in OK status.
#     Update nullFallback parameter and NEA Ciphering value
#     ...     nea0_value=0    nea1_value=0    nea2_value=4    nea3_value=5
#     UE attach and verify ciphering algorithm and security key    ciphering=3
#     [Teardown]    Run Keyword And Ignore Error    Case env recovery
# 
# [1]5GC002056-AGAS_004_Ciphering_algo_NEA1_NEA2_and_NEA3_with_same_priorities_check_NEA2_is_selected
#     [Documentation]
#     ...    The purpose of this test case is to check that when ciphering algorithms are configured with
#     ...    the same priority in O&M, the NEA2(AES) shall be selected.
#     ...    need add to CIT_21A
#     [Tags]    CRT_21A    CRT_TRUNK    CRT_21B    CRT_22R1     CRT_22R2    CRT_22R3    CRT_22R4    CRT_23R1
#     [Timeout]    1 hour
#     [Setup]    run keyword and ignore error    Case preparation
#     Update nullFallback parameter and NEA Ciphering value
#     ...    nea0_value=0    nea1_value=7    nea2_value=7    nea3_value=7
#     UE attach and verify ciphering algorithm and security key    ciphering=2
#     [Teardown]    Run Keyword And Ignore Error    Case env recovery
# 
# [1]5GC002056-AGAS_005_Simultaneous_UL_and_DL_data_traffic_using_NEA1_algorithm
#     [Documentation]
#     ...    The purpose of this test case is to check that SgNB successfully handle the data transmission
#     ...    using NEA1(SNOW 3G) ciphering algorithm.
#     ...    Case pass should meet three requirements:
#     ...    1． Avg Ciphering_TP > Avg none_ciphering_TP*90%
#     ...    2． Max Ciphering_TP < Avg none_ciphering_TP*150%
#     ...    3． Min  Ciphering_TP > Avg none_ciphering_TP*85%
#     ...    need add to CIT_21A
#     [Tags]    CRT_21A    CRT_21B    CRT_22R1     CRT_22R2
#     [Timeout]    1 hour
#     [Setup]    Case preparation
#     run keyword and continue on failure    Should be true    ${PDL_VALIDATION_RESULT}!=${False}
#     ...    msg=Commissioned with error exists, pdl validation result is not in OK status.
#     ${dict_tput_info}    Update NEA ciphering to none ciphering and return the average throughput
#     ...   if_use_default_value_1=${False}    duration_time=${120}
#     Update NEA ciphering check throughput ciphering and SgNBSecurityKey
#     ...    nea0_value=0    nea1_value=7    nea2_value=3    nea3_value=0
#     ...    ul_exp_tput=${dict_tput_info['ul_tput_avg']}    dl_exp_tput=${dict_tput_info['dl_tput_avg']}
#     ...    verify_duration=${120}    ciphering=1
#     ...    is_cpu_check_needed=${False}
#     [Teardown]    Run Keyword And Ignore Error    Case env recovery
# 
# 
# *** Keywords ***
# Suite preparation
#     [Documentation]    author: Liu Zheng
#     [Timeout]    30 min
#     COAM Create log directory    is_set_to_test_case_level=${False}
#     Suite common setup preparation    is_pdl_checking_needed=${True}      enb_default_scf_file=${ENB_SCF_DEFAULT_FILE_PATH}
#     ${ue_type}    ue.translate_power_ue_type_from_testline    ue_index=${0}
#     set suite variable    ${UE_TYPE}    ${ue_type}
#     power_ue.Prepare UE    ue_type=${UE_TYPE}
#     ${program}    gnb_classical_hangzhou.Get program version based on stream version
#     set suite variable    ${PROGRAM}    ${program}
# 
#     import variables    commissionings/HGZ/${testlinename}/__init__.py
#     Run keyword if    '${tl.attenuators}'!='[None]'
#     ...    Initialize attenuator values for testline    pa_values_mapping=${INIT_PA}    if_change_ENB_PA=${False}
#     ...    NSA_SA=NSA
# 
# Suite env recovery
#     [Documentation]    author: Liu Zheng
#     [Timeout]    10 min
#     Connect to gnb coam via ssl
#     Connect to Common Unit Master    alias=ASIK Master
#     Run keyword and continue on failure      swconf.Restore swConfig file on asik and crasign    asik_alias=ASIK Master
# #    Run keyword if    '${SUITE STATUS}' == 'FAIL'
# #    ...    COAM Save snapshot via webUI    download_dir=${SUITE_LOG_PATH}
#     Run keyword if    '${SUITE STATUS}' == 'FAIL'    COAM Save snapshot via rest api    log_path=${SUITE_LOG_PATH}    timeout=960s
#     Tear down all SISO connections
# 
# Case preparation
#     [Documentation]    Author: Liu Zheng
#     [Arguments]    ${is_btslog_required}=${True}
#     Case preparation common    is_btslog_required=${is_btslog_required}
#     Run keyword and ignore error    Stop data transfer based on direction    data_transfer_direction=both
# 
# Case env recovery
#     [Documentation]    Author: Liu Zheng
#     [Arguments]    ${is_need_to_wait_cluster_ready}=${True}    ${is_btslog_required}=${True}
#     Collect logs in teardown    is_btslog_required=${is_btslog_required}
#     Run keyword and ignore error    Stop data transfer based on direction    data_transfer_direction=both
#     Run keyword and ignore error    power_ue.UE Detach    ue_type=${UE_TYPE}
#     Case env recovery common    is_need_to_wait_cluster_ready=${is_need_to_wait_cluster_ready}
#     ...    timeout=3 min    is_all_cells_checking_needed=${True}
