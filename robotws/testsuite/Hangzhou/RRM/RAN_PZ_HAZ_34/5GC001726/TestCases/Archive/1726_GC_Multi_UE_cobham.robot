# # #*** Settings ***
# # #Resource   ../Resources/5GC001726_keywords_cobham.robot
# # #
# # #Documentation    Suite description
# # #...   author: Ding Binmei
# # #...   contact: binmei.ding@nokia-sbell.com
# # #...   squad group: SG_04
# # #...   Feature 1726 in 5G19B program
# # #
# # #Force Tags    5G_RRM      
# # #
# # #Suite Setup    run keywords    Commission on LTE    enb_default_scf_file=${ENB_SCF_DEFAULT_FILE_PATH_2CC}     AND
# # #...                            Suite preparation
# # #Suite Teardown    Run keyword and ignore error    Suite teardown
# # #
# # #
# # #*** Variables ***
# # #${DL_TPUT_IPERF}    20Mbits/sec    #TODO: tput value need to be updated based on manual testing
# # #${UL_TPUT_IPERF}    20Mbits/sec    #TODO: tput value need to be updated based on manual testing
# # #${ENB_SCF_DEFAULT_FILE_PATH_1CC}    #TODO: will be add when get file
# # #${ENB_SCF_DEFAULT_FILE_PATH_2CC}    #TODO: will be add when get file
# # #${E500_SCRIPT_PATH_MULTI_UE_ATTACH_DIFF_CELLS}
# # #${E500_SCRIPT_PATH_MULTI_UE_ATTACH_SAME_CELL}
# # #
# # #*** Test Cases ***
# # #[1]5GC001726_GC_310_GNB-8CCDL_2CCUL_data_max_ue_attach_different_cell_contiguous
# # #    [Tags]
# # #    [Documentation]  Author: Ding Binmei
# # #    ...              Case Description: Attach to different cells and verify bler and tput,
# # #    ...                               require ENB_SCF_DEFAULT_FILE_PATH_2CC for commission on ENB, which is done on suite setup
# # #    [Setup]    Test preparation    e500_script_path_multi_ue=${E500_SCRIPT_PATH_MULTI_UE_ATTACH_DIFF_CELLS}
# # #    ...    parameters_modification_via_api=${None}    enb_scf_file_path=${None}
# # #    Attach to pcells and do verification for througput and bler    e500_script_path_multi_ue=${E500_SCRIPT_PATH_MULTI_UE_ATTACH_DIFF_CELLS}
# # #    ...    number_of_ue=11
# # #    [Teardown]    Run keyword and ignore error    Test teardown
# # #
# # #[1]5GC001726_GC_312_GNB-8CCDL_2CCUL_data_max_ue_attach_different_cell_non-contiguous_
# # #    [Tags]
# # #    [Documentation]  Author: Ding Binmei
# # #    ...              Case Description: Attach to different cells and verify bler and
# # #    ...                               require ENB_SCF_DEFAULT_FILE_PATH_2CC for commission on ENB, which is done on suite setup
# # #    [Setup]    Test preparation    e500_script_path_multi_ue=${E500_SCRIPT_PATH_MULTI_UE_ATTACH_DIFF_CELLS}
# # #    ...    parameters_modification_via_api=${MODIFY_NRARFCN_GSCN_VIA_API_NON_CON_8CC_2_2_2_2}    enb_scf_file_path=${None}
# # #    Attach to pcells and do verification for througput and bler    e500_script_path_multi_ue=${E500_SCRIPT_PATH_MULTI_UE_ATTACH_DIFF_CELLS}
# # #    ...    number_of_ue=11
# # #    [Teardown]    Run keyword and ignore error    Test teardown
# # #
# # #[1]5GC001726_GC_309_GNB-8CCDL_2CCUL_data_max_ue_attach_same_cell_contiguous
# # #    [Tags]
# # #    [Documentation]  Author: Ding Binmei
# # #    ...              Case Description: Attach to different cells and verify bler and tput
# # #    ...                               require ENB_SCF_DEFAULT_FILE_PATH_1CC for commission on ENB
# # #    [Setup]    Test preparation    e500_script_path_multi_ue=${E500_SCRIPT_PATH_MULTI_UE_ATTACH_DIFF_CELLS}
# # #    ...    parameters_modification_via_api=${MODIFY_NRARFCN_GSCN_VIA_API_CON_8CC_CC0_CC7}    enb_scf_file_path=${ENB_SCF_DEFAULT_FILE_PATH_1CC}
# # #    Attach to pcells and do verification for througput and bler    e500_script_path_multi_ue=${E500_SCRIPT_PATH_MULTI_UE_ATTACH_SAME_CELL}
# # #    ...    number_of_ue=11
# # #    [Teardown]    Run keyword and ignore error    Test teardown
# # #
# # #[1]5GC001726_GC_311_GNB-8CCDL_2CCUL_data_max_ue_attach_same_cell_non-contiguous
# # #    [Tags]
# # #    [Documentation]  Author: Ding Binmei
# # #    ...              Case Description: Attach to different cells and verify bler and tput
# # #    ...                               require ENB_SCF_DEFAULT_FILE_PATH_1CC for commission on ENB
# # #    [Setup]    Test preparation    e500_script_path_multi_ue=${E500_SCRIPT_PATH_MULTI_UE_ATTACH_DIFF_CELLS}
# # #    ...    parameters_modification_via_api=${MODIFY_NRARFCN_GSCN_VIA_API_NON_CON_8CC_1_1_1_1_2_2}
# # #    ...    enb_scf_file_path=${ENB_SCF_DEFAULT_FILE_PATH_1CC}
# # #    Attach to pcells and do verification for througput and bler    e500_script_path_multi_ue=${E500_SCRIPT_PATH_MULTI_UE_ATTACH_SAME_CELL}
# # #    ...    number_of_ue=11
# # #    [Teardown]    Run keyword and ignore error    Test teardown
# # #
# # #*** Keywords ***
# # #Commission on LTE
# # #    [Documentation]  Author: Ding Binmei
# # #    ...              Description: Commission on LTE since case 310 and 312 need 2cc configured on lte and
# # #    ...                           for case 309 and 311 only 1cc is needed on lte
# # #    ...              ${is_called_in_test_case_level}: available values: ${True} ${False},
# # #    ...                                               default to ${False} which means keyword is called in test suite setup phase
# # #    [Arguments]  ${enb_default_scf_file}    ${is_called_in_test_case_level}=${False}
# # #    ${local_log_file_folder}    set variable if  ${is_called_in_test_case_level}==${True}    ${TS_CASE_LOG_PATH}    ${SUITE_LOG_PATH}
# # #     ${enb_scf_file}    Copy file    source=${enb_default_scf_file}    destination=${local_log_file_folder}
# # #    enb_lte.Connect to eNB via ssl    connection=enblte
# # #    coam_gnb_classical.COAM Commission with scf file     scf_file_path=${enb_default_scf_file}    connection=enblte    timeout=600
# # #    [Teardown]  enb_lte.Enblte close down    connection=enblte
# # #
# # #Suite teardown
# # #    [Documentation]  Author: Ding Binmei
# # #    ...              Description: Restore LTE commission file to 1CC so that other cases won't be affected
# # #    5GC001726_keywords.Collect logs in teardown    is_called_in_test_case_level=${True}
# # #    Commission on LTE    enb_default_scf_file=${ENB_SCF_DEFAULT_FILE_PATH_1CC}    is_called_in_test_case_level=${False}
# # #    Wait until cluster is on cell on air status    timeout=${TIMEOUT_CLUSTER}    is_all_cells_checking_needed=${True}
# # #    COAM Teardown gnb connections
# # #
# # #Test preparation
# # #    [Documentation]  Author: Ding Binmei
# # #    ...              Description: Case preparation for updating paremeters based on case level
# # #    [Arguments]      ${e500_script_path_multi_ue}    ${parameters_modification_via_api}=${None}    ${enb_scf_file_path}=${None}
# # #    COAM Create log directory
# # #    Run keyword if    ${enb_scf_file_path}!=${None}
# # #    ...    Run keywords    Commission on LTE    enb_default_scf_file=${enb_scf_file_path}    is_called_in_test_case_level=${True}    AND
# # #    ...                    Sleep    30 sec
# # #    Connect to gnb coam via ssl
# # #    Run keyword if     ${parameters_modification_via_api}!=${None}
# # #    ...    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters_modification_via_api}
# # #    ...        timeout=${TIMEOUT_REST_API_RESTART}
# # #    COAM Teardown gnb connections
# # #    Cobham connection and start logging    e500_script_path=${e500_script_path_multi_ue}
# # #    Wait until cluster is on cell on air status    timeout=20 min    is_all_cells_checking_needed=${True}
# # #    wait until keyword succeeds    20 sec    2 sec     connection_alias_store.Connect to Common Unit Master
# # #    Synchron gNB and cobham
# # #    tm500.Perform cell search    cell_search_script_path=${e500_script_path_multi_ue}/NSA_5G_Cell_Config.txt
# # #
# # #Test teardown
# # #    [Documentation]    Author: Ding Binmei
# # #    ...                Description: case teardown part
# # #    5GC001726_keywords.Collect logs in teardown    is_called_in_test_case_level=${True}
# # #    Collect tma logs to test pc
# # #    COAM Teardown gnb connections
# # #    @{ssh_alias}    Create list    ASIK Master    ABIL Master
# # #    Run keyword and ignore error    coam_siso_common.Disconnect ssh connections    list_alias=${ssh_alias}
# # #
# # #Attach to pcells and do verification for througput and bler
# # #    [Documentation]  Author: Ding Binmei
# # #    ...              Description: Attach to Pcells, and verify throughput is maintained and bler should be less than 10%
# # #    [Arguments]  ${e500_script_path_multi_ue}    ${number_of_ue}=11    ${dl_tput}=${DL_TPUT_IPERF}    ${ul_tput}=${UL_TPUT_IPERF}
# # #    FOR    ${pcell_index}    IN    @{PCELL_INDEX}
# # #       Switch pcell for attach based on cell index    cell_index_for_attach=${pcell_index}
# # #       Sleep    5s
# # #       ${ue_ip_list}    Cobham multiple UEs attach    number_of_ue=${number_of_ue}
# # #       ...    e500_script_path_multi_ue=${e500_script_path_multi_ue}
# # #       Iperf send DL traffic with real epc for multiple UEs    number_of_ue=${number_of_ue}    throughput=${dl_tput}
# # #       ...    traffic_time=${600}    dl_port=${DL_PORT}    dl_host_ip_list=${ue_ip_list}
# # #       Iperf send UL traffic with real epc for multiple UEs    number_of_ue=${number_of_ue}    throughput=${ul_tput}
# # #       ...    traffic_time=${600}    ul_port_list=${IPERF_UL_PORT_LIST}
# # #       Sleep    10s
# # #       Repeat keyword    30 sec    Verify throughput or bler for all ue(s) from cobham    number_of_ue=${number_of_ue}    direction=both
# # #       ...    exp_tput_ul=1    exp_tput_dl=1    bler_threshold=${EXPECTED_BLER}    is_bler_checking_needed=${True}
# # #       Iperf stop traffic from appserver and ue side    port=${IPERF_UL_PORT_LIST_TO_KILL}
# # #       Cobham multiple UEs detach    number_of_ue=${number_of_ue}    e500_script_path_multi_ue=${e500_script_path_multi_ue}
# # #    END
# # #    [Teardown]  Run keyword and ignore error    Run keywords    Iperf stop traffic from appserver and ue side
# # #    ...    port=${IPERF_UL_PORT_LIST_TO_KILL}    AND
# # #    ...    Cobham multiple UEs detach    number_of_ue=${number_of_ue}    e500_script_path_multi_ue=${e500_script_path_multi_ue}
# # #
