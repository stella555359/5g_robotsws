# # #*** Settings ***
# # #Resource   ../../Resources/5GC001726_keywords_cobham.robot
# # #Resource   ../../Resources/5GC001726_keywords_GA.robot
# # #
# # #Documentation    Suite description
# # #...   author: Ren Biyao
# # #...   contact: biyao.ren@nokia-sbell.com
# # #...   squad group: MMW_SG1
# # #...   Feature 5GC001726-GA in 5G19B program
# # #
# # #Force Tags    5G_RRM        7.1816  1726-GA
# # #Suite Setup   5GC001726_Keywords.Suite Preparation
# # #Suite Teardown  Run keyword and ignore error    5GC001726_Keywords.Common Suite Teardown
# # #
# # #*** Test Cases ***
# # #[1]5GC001726_GA_109_GNB-8CCDL_2CCUL_maxScell7DL1UL_UE_support_less_8CC
# # #    [Documentation]    Author: Ren Biyao
# # #    ...    Verify the algorithm for scell selection when ue related capability support less than 8cc.
# # #    ...    This is one ue case.
# # #    [Setup]    Test case preparation
# # #    Connect to gnb coam via ssl
# # #    COAM Update several parameters via rest api    parameters_to_update_via_api=${MODIFY_maxNumScellsDL_5_VIA_API}
# # #    Cobham attach multi ue and verify pcap log    log_prefix=1726_GA109   number_of_ue=${1}
# # #    ...    expected_ul_scell_number=${1}   expected_dl_scell_number=${5}
# # #    [Teardown]    Run keyword and ignore error    5GC001726_Keywords.Test Case Teardown
# # #
# # #[1]5GC001726_GA_110_GNB-8CCDL_2CCUL_maxScell7DL1UL_max_UE_with_same_UE_capability_supported_8CC
# # #    [Documentation]    Author: Ren Biyao
# # #    ...    Verify the 8CC DL 2CC UL CA configuration with max UE attached which have same CA capability
# # #    [Setup]    Test case preparation
# # #    Connect to gnb coam via ssl
# # #    COAM Update several parameters via rest api    parameters_to_update_via_api=${MODIFY_maxNumScellsDL_7_VIA_API}
# # #    Cobham attach multi ue and verify pcap log    log_prefix=1726_GA110    number_of_ue=${11}
# # #    ...    expected_ul_scell_number=${1}    expected_dl_scell_number=${7}
# # #    [Teardown]    Run keyword and ignore error    5GC001726_Keywords.Test Case Teardown
# # #
# # #[1]5GC001726_GA_112_GNB-8CCDL_2CCUL_maxScell7DL1UL_mix_UE_with_CA_capability_and_UE_without_CA_capability
# # #    [Tags]    CRT_20B   CRT_TRUNK    CRT_21A
# # #    [Documentation]    Author: Ren Biyao
# # #    ...    Verify the 8CC DL 2CC UL CA configuration can support both CA capable UE and non-CA capable UE.
# # #    [Setup]    Test case preparation
# # #    Cobham attach multi ue and verify pcap log    log_prefix=1726_GA112    number_of_ue=${2}
# # #    comment    Need info about how to check multi-ue scell after manual test
# # #    [Teardown]    Run keyword and ignore error    5GC001726_Keywords.Test Case Teardown
# # #
# # #[1]5GC001726_GA_113_GNB-8CCDL_2CCUL_maxScell7DL1UL_2_UE_support_5CC_Algorithm_for_Scell_selection
# # #    [Tags]    CIT_20B   CIT_TRUNK    CIT_21A
# # #    [Documentation]    Author: Ren Biyao
# # #    ...    Verify the algorithm for SCell selection. At the time of SCell selection, consider number of 5G-UEs
# # #    ...    in each cell and select those cells that have the lowest amount of the 5G-UEs
# # #    [Setup]    Test case preparation
# # #    Cobham attach multi ue and verify pcap log    log_prefix=1726_GA113   number_of_ue=${2}
# # #    comment    checkpoint is not clear, wait further info
# # #    [Teardown]    Run keyword and ignore error    5GC001726_Keywords.Test Case Teardown
# # #
# # #[1]5GC001726_GA_111_GNB-8CCDL_2CCUL_maxScell7DL1UL_max_UE_with_diff_UE_capability_supported_8CC
# # #    [Documentation]    Author: Ren Biyao
# # #    ...    Verify the configuration of multi-UE with different CA capabilities when DL non-contiguous frequency with
# # #    ...    analog beamforming in mmW bands
# # #    [Setup]    Test case preparation
# # #    Cobham attach multi ue and verify pcap log    log_prefix=1726_GA111    number_of_ue=${11}    verification_type=ca_enable
# # #    [Teardown]    Run keyword and ignore error    5GC001726_Keywords.Test Case Teardown
# # #
# # #[1]5GC001726_GA_163_GNB-8CCDL_2CCUL_maxScell7DL1UL_contiguous_UE8DL2UL_6UE_IWK_5GC000721_PSCell_load_balancing
# # #    [Tags]    CRT_20B   CRT_TRUNK    CRT_21A
# # #    [Documentation]    Author: Ren Biyao
# # #    ...    The purpose of this test case is to check whether 5GC001726 worked together with 5GC000721 with contiguous
# # #    ...    frequency i.e., PSCell load balancing is worked when 5GC001726 worked  with contiguous frequency.
# # #    [Setup]    Test case preparation
# # #    Cobham attach multi ue and capture event trace log
# # #    [Teardown]    Run keyword and ignore error    5GC001726_Keywords.Test Case Teardown
# # #
# # #[1]5GC001726_GA_164_GNB-8CCDL_2CCUL_maxScell7DL1UL_non_contiguous_UE8DL2UL_6UE_IWK_5GC000721_PSCell_load_balancing
# # #    [Documentation]    Author: Ren Biyao
# # #    ...    The purpose of this test case is to check whether 5GC001726 worked together with 5GC000721  with non_contiguous
# # #    ...    frequency i.e., PSCell load balancing is worked when 5GC001726 worked  with non_contiguous frequency.
# # #    [Setup]    Test case preparation
# # #    Connect to gnb coam via ssl
# # #    COAM Update several parameters via rest api    parameters_to_update_via_api=${MODIFY_VIA_API_NON_CON_8CC_1_1_3_3_8DL_2UL}
# # #    ...        timeout=${TIMEOUT_REST_API_RESTART}
# # #    COAM Teardown gnb connections
# # #    Wait until cluster is on cell on air status    timeout=${TIMEOUT_CLUSTER}    is_all_cells_checking_needed=${True}
# # #    Cobham attach multi ue and capture event trace log
# # #    [Teardown]    Run keyword and ignore error    5GC001726_Keywords.Test Case Teardown
# # #
# # #[1]5GC001726_GA_143_GNB-8CCDL_2CCUL_maxScell7DL1UL_contiguous_freq_IWK_5GC000478_then_trigger_RLF
# # #    [Tags]    CIT_20B   CIT_TRUNK    CIT_21A
# # #    [Documentation]    Author: Ren Biyao
# # #    ...    Verify the 8CC DL and 2CC UL CA configuration can be enable on GNB with contiguous frequency then RLF can
# # #    ...    be triggered successfully. Note: this case use one cell to attach.
# # #    [Setup]    Test case preparation
# # #    Connect to gnb coam via ssl
# # #    COAM Update several parameters via rest api    parameters_to_update_via_api=${MODIFY_VIA_API_ENABLE_CA}
# # #    Trigger RLF and verify rlf CP messages     log_prefix=1726_GA143
# # #    [Teardown]    Run keyword and ignore error    5GC001726_Keywords.Test Case Teardown
# # #
# # #[1]5GC001726_GA_144_GNB-8CCDL_2CCUL_maxScell7DL1UL_contiguous_freq_IWK_5GC002177_A2_based_SgNB_release_SRB1
# # #    [Documentation]    Author: Ren Biyao
# # #    ...    Verify the 8CC DL and 2CC UL CA configuration can be enable on GNB with contiguous frequency then SgNB release
# # #    ...    produce is triggered successfully base on A2 measurement with SRB1. Note: this case use one cell to attach.
# # #    [Setup]    Test case preparation
# # #    ${PARA_TO_MODIFY_VIA_API}    combine lists     ${MODIFY_VIA_API_ENABLE_CA}    ${MODIFY_VIA_API_ENABLE_A2_MEAS}
# # #    COAM Update several parameters via rest api    parameters_to_update_via_api=${PARA_TO_MODIFY_VIA_API}
# # #    Trigger RLF and verify rlf CP messages     log_prefix=1726_GA144
# # #    [Teardown]    Run keyword and ignore error    5GC001726_Keywords.Test Case Teardown
# # #
# # #[1]5GC001726_GA_145_GNB-8CCDL_2CCUL_maxScell7DL1UL_non_contiguous_freq_IWK_5GC002177_A2_based_SgNB_release_SRB3
# # #    [Tags]    CRT_20B   CRT_TRUNK    CRT_21A
# # #    [Documentation]    Author: Ren Biyao
# # #    ...    Verify the 8CC DL and 2CC UL CA configuration can be enable on GNB with non-contiguous frequency then SgNB release
# # #    ...    produce is triggered successfully base on A2 measurement with SRB3.
# # #    [Setup]    Test case preparation
# # #    Connect to gnb coam via ssl
# # #    ${PARA_TO_MODIFY_VIA_API}    combine lists     ${MODIFY_VIA_API_ENABLE_CA}   ${MODIFY_VIA_API_ENABLE_A2_MEAS}    
# ...${MODIFY_VIA_API_ENABLE_SRB3}
# # #    COAM Update several parameters via rest api    parameters_to_update_via_api=${PARA_TO_MODIFY_VIA_API}
# # #    Trigger RLF and verify rlf CP messages     log_prefix=1726_GA145
# # #    [Teardown]    Run keyword and ignore error    5GC001726_Keywords.Test Case Teardown
# # #
# # #*** Keywords ***
# # #Suite Preparation
# # #    [Documentation]    Author: Ren Biyao
# # #    ...    This keyword will modify swconfig file(default is not to modify swconfig) and commission gnb and verify
# # #    ...    gnb cell on air status.
# # #    ...    ${1726_scf_parameter} is the parameters list which is related to 1726 function.
# # #    [Timeout]    20 min
# # #    [Arguments]    ${1726_scf_parameter}=${SCF_MODIFY_COMMON}    ${swconfig_modify}=${None}
# # #    ...       ${is_pdl_checking_needed}=${False}
# # #    ${cur_program}    gnb_classical_hangzhou.Get program version based on stream version
# # #    set suite variable    ${PROGRAM}    ${cur_program}
# # #    set suite variable    ${PROGRAM}    ${cur_program}
# # #    import variables    ${CURDIR}/../../TestData/1726_NIDD_modify.py
# # #    import library      event_trace_log_analysis.Event_trace_log_analysis_1726    program=${PROGRAM}
# # #    ...    WITH NAME    event_trace_analysis
# # #
# # #    Run keyword and ignore error    wait until keyword succeeds    3x    10 s    Reset Viavi via ASC
# # #    ...    tma_asc_alias=${TMA_ASC_ALIAS}
# # #    Preparation with swconfig modification and comissioning    swconfig_modify=${swconfig_modify}    scf_modify=${1726_scf_parameter}
# # #    ...    is_called_in_test_case_level=${False}    is_pdl_checking_needed=${is_pdl_checking_needed}
# # #    Wait until cluster is on cell on air status    timeout=${TIMEOUT_CLUSTER}    is_all_cells_checking_needed=${True}
# # #
# # #Cobham attach multi ue and verify pcap log
# # #    [Documentation]    Author: Ren Biyao
# # #    ...                :para ${verification_type}  can be ca_enable, ca_disable, scell_number, default type is scell_number
# # #    [Arguments]    ${log_prefix}     ${number_of_ue}    ${expected_ul_scell_number}=${1}    ${expected_dl_scell_number}=${7}
# # #    ...    ${e500_script_path_multi_ue}=${E500_SCRIPTS_MUL_UE}    ${verification_type}=scell_number
# # #    connection_alias_store.Connect to Common Unit Master
# # #    ${log_full_path_enb}    Wait until keyword succeeds    3X    3 s    Start x2 trace capturing from enb    log_prefix=${log_prefix}
# # #    Cobham multiple UEs attach    number_of_ue=${number_of_ue}    e500_script_path_multi_ue=${e500_script_path_multi_ue}
# # #    ...    e500_alias=${TMA_APP_ALIAS}
# # #    Stop Trace Capturing    log_prefix=${log_prefix}    connection_alias=ENB
# # #    ${log_full_path_ute}    Download trace log    log_full_path=${log_full_path_enb}    log_dir_ute=${log_dir_on_ute}   connection_alias=ENB
# # #
# # #    run keyword if    '${verification_type}' == 'ca_disable'    run keyword and continue on failure
# # #    ...    Verify CA is disabled in x2 log    file_path=${log_full_path_ute}
# # #    ...    ELSE IF    '${verification_type}' == 'ca_enable'    run keyword and continue on failure
# # #    ...    Verify CA is enabled in x2 log     file_path=${log_full_path_ute}
# # #    ...    ELSE IF    '${verification_type}' == 'scell_number'    run keyword and continue on failure
# # #    ...    Verify ul and dl scell number    file_path=${log_full_path_ute}
# # #    ...    expected_ul_scell_number=${expected_ul_scell_number}    expected_dl_scell_number=${expected_dl_scell_number}
# # #    ...    ELSE    Fail    msg=Unsupported verification type!
# # #    [Teardown]    run keyword and ignore error   run keywords
# # #    ...    Stop Trace Capturing    log_prefix=${log_prefix}    connection_alias=ENB
# # #    ...    AND    Download trace log    log_full_path=${log_full_path_enb}    log_dir_ute=${log_dir_on_ute}   connection_alias=ENB
# # #
# # #Cobham attach multi ue and capture event trace log
# # #    [Documentation]    Author: Ren Biyao
# # #    ...    The whole procedure is applied only for GA 163 and 164, and viavi will net be detached during the procedure.
# # #    comment    1.UE1/UE2/UE5 attached CELL0 2.UE3/UE4/UE6 attached CELL1--->need further confrim
# # #    ...        Basically, attach one ue and check event trace once.
# # #    Verify_physCellId_in_FdSchedData_event    file_path=${None}   direction=ul   physical_cell_id_for_attach=${None}
# # #
# # #Trigger RLF and verify rlf CP messages
# # #    [Documentation]    Author: Ren Biyao
# # #    [Arguments]    ${log_prefix}    ${init_atten_value}=78    ${retry_times}=10    ${delta}=4
# # #    ...    ${cell_index_for_attach}=1    ${log_dir_ute}=${TS_CASE_LOG_PATH}
# # #    log to console    modify PA to ideal value and attach...
# # #    Adjust the Attenuation
# # #    Cobham attach UE and start traffic    e500_script_path=${E500_SCRIPTS_BASE}
# # #    log to console    trigger RLF ...
# # #    FOR    ${i}    IN RANGE    ${retry_times}
# # #         ${atten_value}    evaluate    ${init_atten_value}+${i}*${delta}
# # #         ${log_full_path_enb}    Start x2 trace capturing from enb    log_prefix=${log_prefix}
# # #         Adjust the Attenuation
# # #         ${Is_RLF_triggered}   Run keyword and return status   wait until keyword succeeds   3 min    10s
# # #         ...    Evaluate no ul data transfer
# # #         sleep    3s
# # #         Stop Trace Capturing    log_prefix=${log_prefix}     connection_alias=ENB
# # #         ${rlf_trace}    Download trace log    log_full_path=${log_full_path_enb}    log_dir_ute=${log_dir_ute}
# # #         ...    connection_alias=ENB
# # #         Run keyword if    ${Is_RLF_triggered}==${False}    run    rm -f ${rlf_upue_trace}     ELSE
# # #         ...    set test variable    ${RLF_TRACE}    ${rlf_trace}
# # #         exit for loop if    ${Is_RLF_triggered}
# # #     END
# # #     should be true    ${Is_RLF_triggered}    msg='RLF is not triggered, case will be teardown'
# # #     Verify RLF CP messages    file_path=${RLF_TRACE}
# # #    [Teardown]    run keyword and ignore error   run keywords
# # #    ...    Stop Trace Capturing    log_prefix=${log_prefix}    connection_alias=ENB
# # #    ...    AND    Download trace log    log_full_path=${log_full_path_enb}    log_dir_ute=${log_dir_on_ute}   connection_alias=ENB
# # #
# # #Evaluate no ul data transfer
# # #    [Documentation]    Author: Ren Biyao
# # #    ...    This keyword is to check there is no data transmission after rlf. If the data is less than 2 x 10^-3 M,
# # #    ...    it can be recognized as there is no data at all.
# # #    ${ul_tp_l2lo}    Get UL throughput on gnb L2Lo per cell
# # #    should be true    ${ul_tp_l2lo} <= ${0.002}
# # #
# # #Verify RLF CP messages
# # #    [Documentation]    Author: Ren Biyao
# # #    [Arguments]        ${file_path}
# # #    ${all_packets}     Wait until keyword succeeds    3 min     7 s    cap.load_pcap_file    pcap_file=${file_path}
# # #    ...    command_template=${pdml_convert_f1ap_template}
# # #    ${rlf_msg}    cap.filter_packets_by_expression    pdml_entries=${all_packets}
# # #    ...    filter_expression=f1ap.radioNetwork == 12 or f1ap.radioNetwork == 1
# # #    ${frame_rlf_msg}      cap.get_field_value_by_name    pdml_entries=${rlf_msg}    field_name=frame.number
# # #
# # #    ${all_packets}     Wait until keyword succeeds    3 min     7 s    cap.load_pcap_file    pcap_file=${file_path}
# # #    ...    command_template=${command_template_with_Y}
# # #    ${rlf_msg_complete}    cap.filter_packets_by_expression    pdml_entries=${all_packets}
# # #    ...    filter_expression=f1ap.procedureCode == 6
# # #    ${frame_rlf_msg_complete}    cap.get_field_value_by_name    pdml_entries=${rlf_msg_complete}    field_name=frame.number
# # #    log to console    ${frame_rlf_msg_complete}
# # #    should be true    ${frame_rlf_msg[0]} < ${frame_rlf_msg_complete[0]}
