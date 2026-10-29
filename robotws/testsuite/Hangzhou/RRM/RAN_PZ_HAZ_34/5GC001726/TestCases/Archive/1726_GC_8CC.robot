# # #*** Settings ***
# # #Resource   ../Resources/5GC001726_keywords.robot
# # #
# # #Documentation    Suite description
# # #...   author: Ding Binmei
# # #...   contact: binmei.ding@nokia-sbell.com
# # #...   squad group: SG_04
# # #...   Feature 1726 in 5G19B program
# # #
# # #Force Tags    5G_RRM      
# # #
# # #Suite Setup    Suite preparation
# # #Suite Teardown    Run keyword and ignore error    5GC001726_keywords.Common Suite Teardown
# # #
# # #
# # #*** Variables ***
# # #${DL_TPUT_IPERF}    20Mbits/sec
# # #${UL_TPUT_IPERF}    20Mbits/sec
# # #${REPEAT_TIME_FOR_VERIFICATION}    2
# # #
# # #*** Test Cases ***
# # #[1]5GC001726_GC_302_GNB-8CCDL_2CCUL_DL_data_contiguous
# # #    [Tags]
# # #    [Documentation]  Author: Ding Binmei
# # #    ...              Case Description:
# # #    [Setup]    Test preparation    parameters_modification_via_api=${None}
# # #    Attach to pcells and do verification for througput and bler    data_transfer_direction=dl
# # #    [Teardown]    Run keyword and ignore error    Test teardown    data_transfer_direction=dl
# # #
# # #[1]5GC001726_GC_301_GNB-5CCDL_2CCUL_UL_data_contiguous
# # #    [Tags]
# # #    [Documentation]  Author: Ding Binmei
# # #    ...              Case Description:
# # #    [Setup]    Test preparation    parameters_modification_via_api=${MODIFY_VIA_API_CON_5CC_5DL_2UL}
# # #    Attach to pcells and do verification for througput and bler    data_transfer_direction=ul
# # #    [Teardown]    Run keyword and ignore error    Test teardown    data_transfer_direction=ul
# # #
# # #[1]5GC001726_GC_303_GNB-7CCDL_2CCUL_UL_and_DL_data_contiguous
# # #    [Tags]    CIT_20B   CIT_TRUNK    CIT_21A
# # #    [Documentation]  Author: Ding Binmei
# # #    ...              Case Description:
# # #    [Setup]    Test preparation    parameters_modification_via_api=${MODIFY_VIA_API_CON_7CC_7DL_2UL}
# # #    Attach to pcells and do verification for througput and bler    data_transfer_direction=both
# # #    [Teardown]    Run keyword and ignore error    Test teardown    data_transfer_direction=both
# # #
# # #[1]5GC001726_GC_307_GNB-5CCDL_2CCUL_data_non-contiguous
# # #    [Tags]
# # #    [Documentation]  Author: Ding Binmei
# # #    ...              Case Description:
# # #    [Setup]    Test preparation    parameters_modification_via_api=${MODIFY_VIA_API_NON_CON_5CC_1_1_1_2_5DL_2UL}
# # #    Attach to pcells and do verification for througput and bler    data_transfer_direction=both
# # #    [Teardown]    Run keyword and ignore error    Test teardown    data_transfer_direction=both
# # #
# # #[1]5GC001726_GC_304_GNB-5CCDL_1CCUL_UL_data_non-contiguous
# # #    [Tags]
# # #    [Documentation]  Author: Ding Binmei
# # #    ...              Case Description:
# # #    [Setup]    Test preparation    parameters_modification_via_api=${MODIFY_VIA_API_NON_CON_5CC_1_1_1_1_1_5DL_1UL}
# # #    Attach to pcells and do verification for througput and bler    data_transfer_direction=ul
# # #    [Teardown]    Run keyword and ignore error    Test teardown    data_transfer_direction=ul
# # #
# # #[1]5GC001726_GC_305_GNB-8CCDL_2CCUL_DL_data_non-contiguous
# # #    [Tags]
# # #    [Documentation]  Author: Ding Binmei
# # #    ...              Case Description:
# # #    [Setup]    Test preparation    parameters_modification_via_api=${MODIFY_VIA_API_NON_CON_8CC_2_2_2_2_8DL_2UL}
# # #    Attach to pcells and do verification for througput and bler    data_transfer_direction=dl
# # #    [Teardown]    Run keyword and ignore error    Test teardown    data_transfer_direction=dl
# # #
# # #[1]5GC001726_GC_306_GNB-8CCDL_2CCUL_data_non-contiguous
# # #    [Tags]    CIT_20B   CIT_TRUNK    CIT_21A
# # #    [Documentation]  Author: Ding Binmei
# # #    ...              Case Description:
# # #    [Setup]    Test preparation    parameters_modification_via_api=${MODIFY_VIA_API_NON_CON_8CC_2_2_2_2_8DL_2UL}
# # #    Attach to pcells and do verification for througput and bler    data_transfer_direction=both
# # #    [Teardown]    Run keyword and ignore error    Test teardown    data_transfer_direction=both
# # #
# # #[1]5GC001726_GC_308_GNB-6CCDL_2CCUL_data_non-contiguous
# # #    [Tags]
# # #    [Documentation]  Author: Ding Binmei
# # #    ...              Case Description:
# # #    [Setup]    Test preparation    parameters_modification_via_api=${MODIFY_VIA_API_NON_CON_8CC_1_1_1_1_1_1_1_1_6DL_2UL}
# # #    Attach to pcells and do verification for througput and bler    data_transfer_direction=both
# # #    [Teardown]    Run keyword and ignore error    Test teardown    data_transfer_direction=both
# # #
# # #
# # #*** Keywords ***
# # #Suite teardown
# # #    [Documentation]  Author: Ding Binmei
# # #    5GC001726_keywords.Collect logs in teardown    is_called_in_test_case_level=${True}
# # #    COAM Teardown gnb connections
# # #
# # #Test preparation
# # #    [Documentation]  Author: Ding Binmei
# # #    ...              Description: Case preparation for updating paremeters based on case level
# # #    [Arguments]      ${parameters_modification_via_api}=${None}    ${data_transfer_direction}=both
# # #    COAM Create log directory
# # #    Connect to gnb coam via ssl
# # #    Run keyword if     ${parameters_modification_via_api}!=${None}
# # #    ...    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters_modification_via_api}
# # #    ...        timeout=${TIMEOUT_REST_API_RESTART}
# # #    COAM Teardown gnb connections
# # #    Wait until cluster is on cell on air status    timeout=${TIMEOUT_CLUSTER}    is_all_cells_checking_needed=${True}
# # #    Clear uepc log on ue control pc
# # #    power_ue.Prepare UE    ue_type=${UE_TYPE}
# # #
# # #Test teardown
# # #    [Documentation]    Author: Ding Binmei
# # #    ...                Description: case teardown part
# # #    [Arguments]    ${data_transfer_direction}
# # #    5GC001726_keywords.Collect logs in teardown    is_called_in_test_case_level=${True}
# # #    Run keyword and ignore error    power_ue.UE Detach    ue_type=${UE_TYPE}
# # #    Run keyword and ignore error    Stop data transfer based on direction    data_transfer_direction=${data_transfer_direction}
# # #    Run keyword and ignore error    Stop TTI trace log capturing
# # #    android_common_keyword.Download uepc log on ue control pc
# # #    COAM Teardown gnb connections
# # #    @{ssh_alias}    Create list    ASIK Master    ABIL Master
# # #    Run keyword and ignore error    coam_siso_common.Disconnect ssh connections    list_alias=${ssh_alias}
# # #
# # #Attach to pcells and do verification for througput and bler
# # #    [Documentation]  Author: Ding Binmei
# # #    ...              Description: Attach to Pcells, and verify throughput is maintained for Pscell and bler should be less than 10%
# # #    [Arguments]  ${data_transfer_direction}
# # #    :FOR    ${pscell_index}    IN    @{PCELL_INDEX}
# # #    \    Switch pcell for attach based on cell index    cell_index_for_attach=${pscell_index}
# # #    \    Sleep    10s
# # #    \    ${5Grach_ed}    power_ue.UE Attach    ue_type=${UE_TYPE}
# # #    \    power_ue.Verify attach    ue_type=${UE_TYPE}    5Grach_ed=${5Grach_ed}
# # #    \    Start data transfer based on direction     dl_tput=${DL_TPUT_IPERF}    ul_tput=${UL_TPUT_IPERF}    duration=10 min
# # #        ...    data_transfer_direction=${data_transfer_direction}
# # #    \    Sleep    10s
# # #    \    Repeat keyword    ${REPEAT_TIME_FOR_VERIFICATION} times    Capturing logs and verify throughput and bler    
# ...pscell_index=${pscell_index}
# # #        ...    data_transfer_direction=${data_transfer_direction}
# # #    \    Stop data transfer based on direction    data_transfer_direction=${data_transfer_direction}
# # #    \    Ue detach with index
# # #    [Teardown]  Run keyword and ignore error    Run keywords    Stop data transfer based on direction
# # #    ...    data_transfer_direction=${data_transfer_direction}    AND
# # #    ...    Ue detach with index
# # #
# # #Capturing logs and verify throughput and bler
# # #    [Documentation]  Author: Ding Binmei
# # #    ...              Description: Capturing tput logs from GNB and verify througput is maintained for pscell
# # #    ...                           Capturing event trace log and verify bler is as expected
# # #    ...              ${pscell_index} refers to the cell index for sgnb addition
# # #    ...              ${data_transfer_direction}: Value can be ul,dl,both
# # #    [Arguments]  ${pscell_index}    ${data_transfer_direction}
# # #    @{direction_component_list}    Create list    UL_L2LO    DL_L2LO
# # #    Connect to Capacity Unit Master case
# # #    ${saved_tput_file_list}    check_average_throughput.start_tput_log_capturing    direction_component_list=${direction_component_list}
# # #    Start TTI trace log capturing
# # #    Sleep    3s
# # #    check_average_throughput.stop_tput_log_capturing    saved_tput_file_list=${saved_tput_file_list}
# # #    Stop TTI trace log capturing
# # #    &{dict_csv_file_path}    Convert TTI trace log and download combined csv logs to test pc
# # #    &{dict_local_tput_file_path}    check_average_throughput.download_tput_files    saved_tput_file_list=${saved_tput_file_list}
# # #    ...    download_dir=${TS_CASE_LOG_PATH}
# # #    Run keyword and continue on failure    Verify tput is maintained based on GNB log    dict_tput_log=${dict_local_tput_file_path}
# # #    ...    exp_min_ul_tput=1    list_nrCellIdentity_ul=${NR_CELL_ID_MAPPING[${pscell_index}]['nrCellIdentity']}    exp_min_dl_tput=1
# # #    ...    list_nrCellIdentity_dl=${NR_CELL_ID_MAPPING[${pscell_index}]['nrCellIdentity']}    data_transfer_direction=${data_transfer_direction}
# # #    Run keyword and continue on failure    Verify bler is as expected based on event trace log    dict_event_trace_log=${dict_csv_file_path}
# # #    ...    data_transfer_direction=${data_transfer_direction}
# # #    [Teardown]  Run keyword and ignore error    Run keywords    stop_tput_log_capturing    saved_tput_file_list=${saved_tput_file_list}    AND
# # #    ...    Stop TTI trace log capturing
