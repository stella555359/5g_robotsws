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
# # #Suite Setup    Suite preparation    1726_scf_parameter=${MODIFY_SCF_8CC_IWK_1094}
# # #Suite Teardown    Run keyword and ignore error    5GC001726_keywords.Common Suite Teardown
# # #
# # #
# # #*** Variables ***
# # #${DL_TPUT_HIGN_IPERF}    4000Mbits/sec   # Need to be updated based on manual testing
# # #${DL_TPUT_LOW_IPERF_561}    2000Mbits/sec    # Need to be updated based on manual testing
# # #${DL_TPUT_LOW_IPERF_562}    2000Mbits/sec    # Need to be updated based on manual testing
# # #${UL_TPUT_IPERF}    20Mbits/sec
# # #${REPEAT_TIME_FOR_VERIFICATION}    2
# # #
# # #
# # #*** Test Cases ***
# # #[1]5GC001726_GE_561_GNB-7CCDL_2CCUL_maxScell6DL1UL_non-contiguous_HighThroughput_LowThroughput_IWK_5GC001094_Intra-Fr
# ...equency_Intra-DU_gNB_ mobilit
# # y
# # #    [Tags]
# # #    [Documentation]  Author: Ding Binmei
# # #    ...              Case Description: high ==> low
# # #    # TODO: frequency modification need to be fufilled
# # #    # TODO: How to verify handover is done successfully is need be be checked by manual
# # #    [Setup]    Test preparation    parameters_modification_via_api=${None}
# # #    android_common_keyword.Retry ue attach if failed
# # #    Start data transfer with high or low throughput and verify numbers of cells change for transmission   dl_tput_iperf=${DL_TPUT_HIGN_IPERF}
# # #    ...    exp_cells_num_ul=2    exp_cells_num_dl=7
# # ##    Adjust the Attenuation    attenuation_of_layer1_ul=16   attenuation_of_layer0_ul=32    attenuation_of_layer0_dl=32
# # ##    ...            attenuation_of_layer1_dl=16
# # ##    Verify UE handover to cell successfully and no DL and UL data loss    cell_index=XX
# # ##    Adjust the Attenuation    attenuation_of_layer1_ul=16   attenuation_of_layer0_ul=32    attenuation_of_layer0_dl=32
# # ##    ...            attenuation_of_layer1_dl=16
# # ##    Verify UE handover to cell successfully and no DL and UL data loss    cell_index=XX
# # #    Verify numbers of cells change for transmission when start traffic with high or low throughput    exp_cells_num_ul=2    exp_cells_num_dl=7
# # #    Start data transfer with high or low throughput and verify numbers of cells change for transmission   dl_tput_iperf=${DL_TPUT_LOW_IPERF_561}
# # #    ...    exp_cells_num_ul=2    exp_cells_num_dl=3,4
# # #    Ue detach with index
# # #    [Teardown]    Run keyword and ignore error    Test teardown
# # #
# # #[1]5GC001726_GE_562_GNB-6CCDL_2CCUL_maxScell5DL1UL_non-contiguous_HighThroughput_LowThroughput_IWK_5GC001094_Intra-Fr
# ...equency_Intra-DU_gNB_ mobilit
# # y
# # #    [Tags]
# # #    [Documentation]  Author: Ding Binmei
# # #    ...              Case Description: high ==> low
# # #    [Setup]    Test preparation    parameters_modification_via_api=${None}
# # #    android_common_keyword.Retry ue attach if failed
# # #    Start data transfer with high or low throughput and verify numbers of cells change for transmission   dl_tput_iperf=${DL_TPUT_HIGN_IPERF}
# # #    ...    exp_cells_num_ul=2    exp_cells_num_dl=6
# # ##    Adjust the Attenuation    attenuation_of_layer1_ul=16   attenuation_of_layer0_ul=32    attenuation_of_layer0_dl=32
# # ##    ...            attenuation_of_layer1_dl=16
# # ##    Verify UE handover to cell successfully and no DL and UL data loss    cell_index=XX
# # ##    Adjust the Attenuation    attenuation_of_layer1_ul=16   attenuation_of_layer0_ul=32    attenuation_of_layer0_dl=32
# # ##    ...            attenuation_of_layer1_dl=16
# # ##    Verify UE handover to cell successfully and no DL and UL data loss    cell_index=XX
# # #    Verify numbers of cells change for transmission when start traffic with high or low throughput    exp_cells_num_ul=2    exp_cells_num_dl=6
# # #    Start data transfer with high or low throughput and verify numbers of cells change for transmission   dl_tput_iperf=${DL_TPUT_LOW_IPERF_562}
# # #    ...    exp_cells_num_ul=2    exp_cells_num_dl=2,3,4
# # #    Ue detach with index
# # #    [Teardown]    Run keyword and ignore error    Test teardown
# # #
# # #
# # #*** Keywords ***
# # #Test preparation
# # #    [Documentation]  Author: Ding Binmei
# # #    ...              Description: Case preparation for updating paremeters based on case level
# # #    [Arguments]      ${parameters_modification_via_api}=${None}
# # #    COAM Create log directory
# # #    Connect to gnb coam via ssl
# # #    Run keyword if     ${parameters_modification_via_api}!=${None}
# # #    ...    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters_modification_via_api}
# # #    ...        timeout=${TIMEOUT_REST_API_RESTART}
# # #    COAM Teardown gnb connections
# # #    Switch pcell for attach based on cell index    cell_index_for_attach=${PCELL_INDEX[0]}
# # #    Wait until cluster is on cell on air status    timeout=${TIMEOUT_CLUSTER}    is_all_cells_checking_needed=${True}
# # #    Clear uepc log on ue control pc
# # #    Precondition for ue attach    is_pb_exist=${False}
# # #
# # #Test teardown
# # #    [Documentation]    Author: Ding Binmei
# # #    ...                Description: case teardown part
# # #    [Arguments]    ${data_transfer_direction}=both
# # #    5GC001726_keywords.Collect logs in teardown    is_called_in_test_case_level=${True}
# # #    Run keyword and ignore error    Ue detach with index
# # #    Run keyword and ignore error    Stop data transfer based on direction    data_transfer_direction=${data_transfer_direction}
# # #    Stop the QPST progress
# # #    android_common_keyword.Download uepc log on ue control pc
# # #    COAM Teardown gnb connections
# # #    @{ssh_alias}    Create list    ASIK Master    ABIL Master
# # #    Run keyword and ignore error    coam_siso_common.Disconnect ssh connections    list_alias=${ssh_alias}
# # #
# # #Start data transfer with high or low throughput and verify numbers of cells change for transmission
# # #    [Documentation]    Author: Ding Binmei
# # #    ...                Description: Verify behaviours changes when data transfer change from high througput to low throughput
# # #    ...                             or from low througput to high throughput
# # #    ...                             Will do log capturing and verify for ${REPEAT_TIME_FOR_VERIFICATION} times
# # #    [Arguments]    ${dl_tput_iperf}    ${exp_cells_num_ul}    ${exp_cells_num_dl}
# # #    Start data transfer based on direction     dl_tput=${dl_tput_iperf}    ul_tput=${UL_TPUT_IPERF}    duration=10 min
# # #    ...    data_transfer_direction=both
# # #    Sleep    10s
# # #    Repeat keyword    ${REPEAT_TIME_FOR_VERIFICATION} times
# # #    ...    Verify numbers of cells change for transmission when start traffic with high or low throughput
# # #    ...    exp_cells_num_ul=${exp_cells_num_ul}    exp_cells_num_dl=${exp_cells_num_dl}
# # #    [Teardown]  Run keyword and ignore error    Stop data transfer based on direction    data_transfer_direction=both
# # #
# # #Verify numbers of cells change for transmission when start traffic with high or low throughput
# # #    [Documentation]    Author: Ding Binmei
# # #    ...                Description: Capturing logs and do verifications as bellow:
# # #    ...                             1. numbers of cells changes when traffic is low or high
# # #    ...                ${exp_cells_num_ul}: can only be num
# # #    ...                ${exp_cells_num_dl}: can be a num or a string with format like 3,4:
# # #    ...                                     it means 3 or 4 number of cells are used for dl transmission
# # #    [Arguments]    ${exp_cells_num_ul}    ${exp_cells_num_dl}
# # #    @{direction_component_list}    Create list    UL_L2LO    DL_L2LO
# # #    Connect to Capacity Unit Master
# # #    ${saved_tput_file_list}    check_average_throughput.start_tput_log_capturing    direction_component_list=${direction_component_list}
# # #    Sleep    5s
# # #    check_average_throughput.stop_tput_log_capturing    saved_tput_file_list=${saved_tput_file_list}
# # #    &{dict_local_tput_file_path}    check_average_throughput.download_tput_files    saved_tput_file_list=${saved_tput_file_list}
# # #    ...    download_dir=${TS_CASE_LOG_PATH}
# # #    Run keyword and continue on failure    Verify data transmission is over expected numbers of cells and tput is maintained
# # #    ...    exp_cells_num_ul=${exp_cells_num_ul}    exp_cells_num_dl=${exp_cells_num_ul}    dict_tput_file_paths=${file_path}
# # #    [Teardown]  Run keyword and ignore error    check_average_throughput.stop_tput_log_capturing
# # #    ...    saved_tput_file_list=${saved_tput_file_list}
# # #
