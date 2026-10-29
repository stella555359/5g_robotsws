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
# # #Suite Setup    Suite preparation
# # #Suite Teardown    Run keyword and ignore error    5GC001726_keywords.Common Suite Teardown
# # #
# # #
# # #*** Variables ***
# # #${E500_SCRIPT_PATH_11_MULTI_UE_SAME_CAPB}    #TODO: Need to be updated
# # #${E500_SCRIPT_PATH_3_MULTI_UE_DIFF_CAPB}    #TODO: Need to be updated
# # #${REPEAT_TIME_FOR_VERIFICATION}    2
# # #${UL_TPUT_IPERF}    20Mbits/sec    #TODO: tput value need to be updated based on manual testing
# # #${DL_TPUT_HIGN_IPERF}    4000Mbits/sec    #TODO: tput value need to be updated based on manual testing; packetsize>4*rdMinDataPerCCForSplit
# # #${DL_TPUT_LOW_IPERF_505}    1000Mbits/sec    #TODO: rdMinDataPerCCForSplit<packetsize<4*rdMinDataPerCCForSplit
# # #@{IPERT_UL_PORT_LIST_11_UEs}
# # #@{IPERF_UL_PORT_LIST_3_UEs_506}    5410    5411    5412    #TODO: Need to be updated
# # #${DL_TPUT_LOW_IPERF_506_UE0}    3000Mbit/sec
# # #${DL_TPUT_LOW_IPERF_506_UE1}
# # #${DL_TPUT_LOW_IPERF_506_UE2}
# # #
# # #
# # #*** Test Cases ***
# # #[1]5GC001726_GE_505_GNB-8CCDL_2CCUL_maxScell7DL1UL_contiguous_UE8DL2UL_11UE_HighThroughput_LowThroughput
# # #    [Tags]
# # #    [Documentation]  Author: Ding Binmei
# # #    ...              Case Description: Need to verify tput bler per cells for each UE
# # #    ...              11 UEs with same ue capbility
# # #    [Setup]    Test preparation    e500_script_path_multi_ue=${E500_SCRIPT_PATH_11_MULTI_UE_SAME_CAPB}    parameters_
# ...modification_via_api=${None}
# # #    tm500.Perform cell search    cell_search_script_path=${E500_SCRIPT_PATH_11_MULTI_UE_SAME_CAPB}/NSA_5G_Cell_Config.txt
# # #    ...    tm500_alias=${TMA_APP_ALIAS}
# # #    ${ue_ip_list}    Cobham_Pre.Cobham multiple UEs attach    number_of_ue=11   e500_script_path_multi_ue=${E500_SCRI
# ...PT_PATH_11_MULTI_UE_SAME_CAPB
# # }
# # #    Set test variable    ${UE_IP_LIST}    ${ue_ip_list}
# # #    Iperf send UL traffic with real epc for multiple UEs    number_of_ue=11    throughput=${UL_TPUT_IPERF}
# # #    ...    traffic_time=${600}    ul_port_list=${IPERT_UL_PORT_LIST_11_UEs}
# # #    Start data transfer with high or low throughput and verify behaviours for all UEs    dl_tput_iperf=${DL_TPUT_HIGN_IPERF}
# # #    ...    exp_cells_num_ul=2    exp_cells_num_dl=8    number_of_ue=11
# # #    Sleep    2s
# # #    Start data transfer with high or low throughput and verify behaviours for all UEs    dl_tput_iperf=${DL_TPUT_LOW_IPERF_505}
# # #    ...    exp_cells_num_ul=2    exp_cells_num_dl=4    number_of_ue=11
# # #    Cobham multiple UEs detach    number_of_ue=11    e500_script_path_multi_ue=${E500_SCRIPT_PATH_11_MULTI_UE_SAME_CAPB}
# # #    @{port_list_to_be_killed}    Combine lists    ${IPERT_UL_PORT_LIST_11_UEs}    ${DL_PORT}
# # #    Set test variable    ${IPERF_PORTS}    ${port_list_to_be_killed}
# # #    [Teardown]  Run keyword and ignore error    Test teardown    e500_script_path_multi_ue=${E500_SCRIPT_PATH_11_MULTI_UE_SAME_CAPB}
# # #    ...    iperf_port_list_to_be_killed=${IPERF_PORTS}    number_of_ue=11
# # #
# # #[1]5GC001726_GE_506_GNB-8CCDL_2CCUL_maxScell7DL1UL_non-contiguous_2UEWithDiffCaCapability_HighThroughput_LowThroughput
# # #    [Tags]
# # #    [Documentation]  Author: Ding Binmei
# # #    ...              Case Description: Need to verify tput bler per cells for each UE
# # #    ...              3 UEs with different UE capbility
# # #    [Setup]    Test preparation    e500_script_path_multi_ue=${E500_SCRIPT_PATH_3_MULTI_UE_DIFF_CAPB}
# # #    ...    parameters_modification_via_api=${MODIFY_NRARFCN_GSCN_VIA_API__NON_CON_8CC_1_1_1_1_1_1_1_1}
# # #    ${ue_ip_list}    Cobham multiple UEs attach    number_of_ue=3   e500_script_path_multi_ue=${E500_SCRIPT_PATH_3_MULTI_UE_DIFF_CAPB}
# # #    ...    is_cell_config_update_needed=${True}
# # #    Set test variable    ${UE_IP_LIST}    ${ue_ip_list}
# # #    Iperf send DL traffic with real epc for multiple UEs    number_of_ue=3    throughput=${DL_TPUT_HIGN_IPERF_505}
# # #    ...    traffic_time=${600}    dl_port=${DL_PORT}    dl_host_ip_list=${UE_IP_LIST}
# # #    Iperf send UL traffic with real epc for multiple UEs    number_of_ue=3   throughput=${UL_TPUT_IPERF}
# # #    ...    traffic_time=${600}    ul_port_list=${IPERF_UL_PORT_LIST_3_UEs_506}
# # #    Sleep    10s
# # #    Repeat keyword    ${REPEAT_TIME_FOR_VERIFICATION} times    Verify behaviours when start traffic with high or low throughput for single ue
# # #    ...    exp_cells_num_ul=2    exp_cells_num_dl=8    ue_index=0
# # #    Repeat keyword    ${REPEAT_TIME_FOR_VERIFICATION} times    Verify behaviours when start traffic with high or low throughput for single ue
# # #    ...    exp_cells_num_ul=2    exp_cells_num_dl=6    ue_index=1
# # #    # TODO: What should be the config for UE3? What's the capbility for DL
# # #    Repeat keyword    ${REPEAT_TIME_FOR_VERIFICATION} times    Verify behaviours when start traffic with high or low throughput for single ue
# # #    ...    exp_cells_num_ul=2    exp_cells_num_dl=6    ue_index=2
# # #    Iperf stop traffic from appserver and ue side    port=${DL_PORT}
# # #
# # #    Log to console    Start to decrease DL throughput for all UEs
# # #    Iperf send DL traffic with real epc    throughput=${DL_TPUT_LOW_IPERF_506_UE0}    traffic_time=${600}    port=${DL_PORT}
# # #    ...    dl_host_ip=${UE_IP_LIST[0]}
# # #    Iperf send DL traffic with real epc    throughput=${DL_TPUT_LOW_IPERF_506_UE1}    traffic_time=${600}    port=${DL_PORT}
# # #    ...    dl_host_ip=${UE_IP_LIST[1]}
# # #    Iperf send DL traffic with real epc    throughput=${DL_TPUT_LOW_IPERF_506_UE2}    traffic_time=${600}    port=${DL_PORT}
# # #    ...    dl_host_ip=${UE_IP_LIST[2]}
# # #    Sleep    5s
# # #    Repeat keyword    ${REPEAT_TIME_FOR_VERIFICATION} times    Verify behaviours when start traffic with high or low throughput for single ue
# # #    ...    exp_cells_num_ul=2    exp_cells_num_dl=4    ue_index=0
# # #    Repeat keyword    ${REPEAT_TIME_FOR_VERIFICATION} times    Verify behaviours when start traffic with high or low throughput for single ue
# # #    ...    exp_cells_num_ul=2    exp_cells_num_dl=2,3,4    ue_index=1
# # #    Repeat keyword    ${REPEAT_TIME_FOR_VERIFICATION} times    Verify behaviours when start traffic with high or low throughput for single ue
# # #    ...    exp_cells_num_ul=2    exp_cells_num_dl=1,2,3,4    ue_index=2
# # #
# # #    Cobham multiple UEs detach    number_of_ue=3    e500_script_path_multi_ue=${E500_SCRIPT_PATH_3_MULTI_UE_DIFF_CAPB}
# # #    @{port_list_to_be_killed}    Combine lists    ${IPERF_UL_PORT_LIST_3_UEs_506}    ${DL_PORT}
# # #    Set test variable    ${IPERF_PORTS}    ${port_list_to_be_killed}
# # #    [Teardown]  Run keyword and ignore error    Test teardown    e500_script_path_multi_ue=${E500_SCRIPT_PATH_3_MULTI_UE_DIFF_CAPB}
# # #    ...    iperf_port_list_to_be_killed=${IPERF_PORTS}    number_of_ue=3
# # #
# # #
# # #*** Keywords ***
# # #Test preparation
# # #    [Documentation]  Author: Ding Binmei
# # #    ...              Description: Case preparation for updating paremeters based on case level
# # #    [Arguments]      ${e500_script_path_multi_ue}    ${parameters_modification_via_api}=${None}
# # #    COAM Create log directory
# # #    Connect to gnb coam via ssl
# # #    Run keyword if     ${parameters_modification_via_api}!=${None}
# # #    ...    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters_modification_via_api}
# # #    ...        timeout=${TIMEOUT_REST_API_RESTART}
# # #    COAM Teardown gnb connections
# # #    Switch pcell for attach based on cell index    cell_index_for_attach=${PCELL_INDEX[0]}
# # #    Cobham connection and start logging    e500_script_path=${e500_script_path_multi_ue}
# # #    Wait until cluster is on cell on air status    timeout=20 min    is_all_cells_checking_needed=${True}
# # #    Synchron gNB and cobham
# # #
# # #Test teardown
# # #    [Documentation]    Author: Ding Binmei
# # #    ...                Description: case teardown part
# # #    [Arguments]    ${e500_script_path_multi_ue}    ${iperf_port_list_to_be_killed}    ${number_of_ue}
# # #    Iperf stop traffic from appserver and ue side    port=${iperf_port_list_to_be_killed}
# # #    Run keyword and ignore error    Cobham multiple UEs detach    number_of_ue=${number_of_ue}
# # #    ...    e500_script_path_multi_ue=${e500_script_path_multi_ue}
# # #    5GC001726_keywords.Collect logs in teardown    is_called_in_test_case_level=${True}
# # #    Collect tma logs to test pc
# # #    COAM Teardown gnb connections
# # #    @{ssh_alias}    Create list    ASIK Master    ABIL Master
# # #    coam_siso_common.Disconnect ssh connections    list_alias=${ssh_alias}
# # #
# # #
# # #Start data transfer with high or low throughput and verify behaviours for all UEs
# # #    [Documentation]    Author: Ding Binmei
# # #    ...                Description: Verify behaviours changes when data transfer change from high througput to low throughput
# # #    ...                             or from low througput to high throughput
# # #    ...                             Will do log capturing and verify for ${REPEAT_TIME_FOR_VERIFICATION} times
# # #    [Arguments]    ${dl_tput_iperf}    ${exp_cells_num_ul}    ${exp_cells_num_dl}    ${number_of_ue}=11
# # #    Iperf send DL traffic with real epc for multiple UEs    number_of_ue=${number_of_ue}    throughput=${dl_tput_iperf}
# # #    ...    traffic_time=${600}    dl_port=${DL_PORT}    dl_host_ip_list=${UE_IP_LIST}
# # #    Sleep    10s
# # #    Repeat keyword    ${REPEAT_TIME_FOR_VERIFICATION} times    Verify behaviours when start traffic with high or low throughput for all UEs
# # #    ...    exp_cells_num_ul=${exp_cells_num_ul}    exp_cells_num_dl=${exp_cells_num_dl}    number_of_ue=${number_of_ue}
# # #    [Teardown]  Run keyword and ignore error    Iperf stop traffic from appserver and ue side    port=${DL_PORT}
# # #
# # #Verify behaviours when start traffic with high or low throughput for all UEs
# # #    [Documentation]    Author: Ding Binmei
# # #    ...                Description: Capturing logs and do verifications as bellow:
# # #    ...                1,2,3 are verified on cobham log; 4 is on event trace log
# # #    ...                             1. throughput is maintained for all ues on expected cells
# # #    ...                             2. Bler is as expected for all ues on expected cells
# # #    ...                             3. numbers of cells changes when traffic is low or high for all ues
# # #    ...                             4. Check_DL_HARQ_feedbacks_are_received_successfully
# # #    ...                             5. max data rate as indicated by UE capability is not exceeded in any slot
# # #    ...                ${exp_cells_num_ul}: can only be num
# # #    ...                ${exp_cells_num_dl}: can be a num or a string with format like 3,4:
# # #    ...                                     it means 3 or 4 number of cells are used for dl transmission
# # #    [Arguments]    ${exp_cells_num_ul}    ${exp_cells_num_dl}    ${number_of_ue}=11
# # #    @{direction_component_list}    Create list    UL_L2LO    DL_L2LO
# # #    Connect to Capacity Unit Master
# # #    Start TTI trace log capturing
# # #    Sleep    5s
# # #    Stop TTI trace log capturing
# # #    &{dict_csv_file_path}    Convert TTI trace log and download combined csv logs to test pc
# # #
# # ##    Comment    Run keyword and continue on failure    Max data rate as indicated by UE capability is not exceeded in any slot
# # ##    Run keyword and continue on failure    Verify data transmission is over expected numbers of cells and tput bler 
# ...are all as expected for all u
# # es
# # ##    ...    exp_cells_num_ul=${exp_cells_num_ul}    exp_cells_num_dl=${exp_cells_num_ul}    dict_tput_file_paths=${file_path}
# # #    [Teardown]  Run keyword and ignore error    Stop TTI trace log capturing
# # #
# # #Verify behaviours when start traffic with high or low throughput for single ue
# # #    [Documentation]  Author: Ding Binmei
# # #    ...              Description: TODO: Need to refactor after manual confirmation
# # #    [Arguments]    ${exp_cells_num_ul}    ${exp_cells_num_dl}    ${ue_index}
# # #    ${tput_log_file_path}    viavi_common_keyword.Execute check tput command on cobham    ue_context_id=${ue_index}    radio_context=0-7
# # #    &{dict_cells_num}    verify_throughput_from_cobham_log.get_physical_cells_with_tput_exist    tput_log_file_path=${tput_log_file_path}
# # #    ...    ue_id=${ue_index}
# # #    ${act_cells_num_ul}    Get length    ${dict_cells_num['ul']}
# # #    ${act_cells_num_dl}    Get length    ${dict_cells_num['dl']}
# # #    Run keyword and continue on failure    should be equal as integers    ${act_cells_num_ul}    ${exp_cells_num_ul}
# # #    Run keyword and continue on failure    should be equal as integers    ${act_cells_num_dl}    ${exp_cells_num_dl}
# # #
