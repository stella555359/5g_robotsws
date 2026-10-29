# # #*** Settings ***
# # #Resource   ../Resources/5GC001726_keywords_cobham.robot
# # #Library    ../Resources/check_counter.py
# # #
# # #Documentation    Suite description
# # #...   author: Wang Yixiang
# # #...   contact: yixiang.x.wang@nokia-sbell.com
# # #...   squad group: MMW_SG1
# # #...   Feature 1726 in 5G19B program
# # #
# # #Force Tags    5G_RRM      
# # #
# # #Suite Setup       Counter suite preparation
# # #Suite Teardown    Run keyword and ignore error    5GC001726_keywords.Common Suite Teardown
# # #
# # #*** Test Cases ***
# # #[1]5GC001726_GF_621_M55316C02000_M55316C02001
# # #    [Tags]
# # #    [Documentation]    author: Wang Yixiang
# # #    ...    Verify the PM counters M55316C02000 and M55316C02001 can work correctly.
# # #    ...    M55316C02000: UE_PSCELL_ACT_SCELL_DL = call duration / sample interval (100 ms) in all Cells
# # #    ...    M55316C02001: UE_PSCELL_ACT_SCELL_UL = call duration / sample interval (100 ms) in Cell 0/1 and 0 in other Cells
# # #    [Setup]    Case preparation    scf_paras_via_api=${MODIFY_VIA_API_NON_CON_1_1_1_1_1_5DL_2UL}
# # #    Cobham attach UE and start traffic counter    e500_script_path=${E500_SCRIPTS_BASE}
# # #    ${meas_id_value_list}    Get PM counters by cell
# # #    ...    file_path=${COUNTER_FILE_PATH}    cell=1,2,3,4,5    measurement_id=M55316C02000,M55316C02001
# # #
# # #    # M55316C02000: UE_PSCELL_ACT_SCELL_DL = call duration / sample interval (100 ms) in all Cells
# # #    # 5min*60s*1000ms/100ms=3000
# # #    Verify counter msg is eqaul to expect value    cell_id=1,2,3,4,5    msg_id=M55316C02000
# # #    ...    exp_value=3000    meas_id_value_list=${meas_id_value_list}
# # #
# # #    # M55316C02001: UE_PSCELL_ACT_SCELL_UL = call duration / sample interval (100 ms) in Cell 0/1 and 0 in other Cells
# # #    Verify counter msg is eqaul to expect value    cell_id=1    msg_id=M55316C02001
# # #    ...    exp_value=3000    meas_id_value_list=${meas_id_value_list}
# # #    Verify counter msg is eqaul to expect value    cell_id=2,3,4,5
# # #    ...    msg_id=M55316C02001    exp_value=0    meas_id_value_list=${meas_id_value_list}
# # #
# # #    [Teardown]     Run Keyword And Ignore Error    Test case Teardown
# # #
# # #[1]5GC001726_GF_624_M55316C03006_M55316C05006
# # #    [Tags]
# # #    [Documentation]    author: Wang Yixiang
# # #    ...    M55316C03006	PSCell UEs with 6 activated SCells in DL
# # #    ...    M55316C05006	Maximum amount of PSCell UEs with 6 activated SCells in DL
# # #
# # #    ...    M55316C03006 PSCELL_UE_6_ACT_SCELL_DL = call duration / sample interval (100 ms) in Cell 0 and 0 in other Cells
# # #    ...    M55316C05006 MAX_PSCELL_UE_6_ACT_SCELL_DL = 1 in Cell 0 and 0 in other Cells
# # #    ...    PSCELL_UE_X_ACT_SCELL_DL = 0 in all cells , X=0,1,2,3,4,5,7
# # #    ...    MAX_PSCELL_UE_X_ACT_SCELL_DL = 0 in all cells , X=0,1,2,3,4,5,7
# # #    [Setup]    Case preparation    scf_paras_via_api=${MODIFY_VIA_API_CON_7CC_7DL_2UL}
# # #    Cobham attach UE and start traffic counter    e500_script_path=${E500_SCRIPTS_BASE}
# # #    ${meas_id_str}    Get all counter ids string    pscell_ue_x_act_scell_dl=0,1,2,3,4,5,6,7   max_pscell_ue_x_act_scell_dl=0,1,2,3,4,5,6,7
# # #    ${meas_id_value_list}    Get PM counters by cell
# # #    ...    file_path=${COUNTER_FILE_PATH}    cell=1,2,3,4,5,6,7,8    measurement_id=${meas_id_str}
# # #
# # #    # M55316C03006 PSCELL_UE_6_ACT_SCELL_DL = call duration / sample interval (100 ms) in Cell 0 and 0 in other Cells
# # #    # 5min*60s*1000ms/100ms=3000
# # #    Verify counter msg is eqaul to expect value    cell_id=1    msg_id=M55316C03006
# # #    ...    exp_value=3000    meas_id_value_list=${meas_id_value_list}
# # #    Verify counter msg is eqaul to expect value    cell_id=2,3,4,5,6,7    msg_id=M55316C03006
# # #    ...    exp_value=0    meas_id_value_list=${meas_id_value_list}
# # #
# # #    # M55316C05006 MAX_PSCELL_UE_6_ACT_SCELL_DL = 1 in Cell 0 and 0 in other Cells
# # #    Verify counter msg is eqaul to expect value    cell_id=1
# # #    ...    msg_id=M55316C05006    exp_value=1    meas_id_value_list=${meas_id_value_list}
# # #    Verify counter msg is eqaul to expect value    cell_id=2,3,4,5,6,7
# # #    ...    msg_id=M55316C05006    exp_value=0    meas_id_value_list=${meas_id_value_list}
# # #
# # #    # PSCELL_UE_X_ACT_SCELL_DL = 0 in all cells , X=0,1,2,3,4,5,7
# # #    Verify counter msg is eqaul to expect value    cell_id=1,2,3,4,5,6,7
# # #    ...    msg_id=M55316C05000,M55316C05001,M55316C05002,M55316C05003,M55316C05004,M55316C05005,M55316C05007
# # #    ...    exp_value=0    meas_id_value_list=${meas_id_value_list}
# # #
# # #    # MAX_PSCELL_UE_X_ACT_SCELL_DL = 0 in all cells , X=0,1,2,3,4,5,7
# # #    Verify counter msg is eqaul to expect value    cell_id=1,2,3,4,5,6,7
# # #    ...    msg_id=M55316C03000,M55316C03001,M55316C03002,M55316C03003,M55316C03004,M55316C03005,M55316C03007
# # #    ...    exp_value=0    meas_id_value_list=${meas_id_value_list}
# # #
# # #    [Teardown]     Run Keyword And Ignore Error    Test case Teardown
# # #
# # #[1]5GC001726_GF_625_M55316C03007_M55316C05007
# # #    [Tags]
# # #    [Documentation]    author: Wang Yixiang
# # #    ...    M55316C03007 PSCELL_UE_7_ACT_SCELL_DL = call duration / sample interval (100 ms) in Cell 0 and 0 in other Cells
# # #    ...    M55316C05007 MAX_PSCELL_UE_7_ACT_SCELL_DL = 1 in Cell 0 and 0 in other Cells
# # #    ...    PSCELL_UE_X_ACT_SCELL_DL = 0 in all cells , X=0,1,2,3,4,5,6
# # #    ...    MAX_PSCELL_UE_X_ACT_SCELL_DL = 0 in all cells , X=0,1,2,3,4,5,6
# # #    [Setup]    Case preparation    scf_paras_via_api=${MODIFY_VIA_API_NON_CON_8CC_2_2_2_2_8DL_2UL}
# # #    Cobham attach UE and start traffic counter    e500_script_path=${E500_SCRIPTS_BASE}
# # #    ${meas_id_str}    Get all counter ids string    pscell_ue_x_act_scell_dl=0,1,2,3,4,5,6,7   max_pscell_ue_x_act_scell_dl=0,1,2,3,4,5,6,7
# # #    ${meas_id_value_list}    Get PM counters by cell
# # #    ...    file_path=${COUNTER_FILE_PATH}    cell=1,2,3,4,5,6,7,8    measurement_id=${meas_id_str}
# # #
# # #    # M55316C03007 PSCELL_UE_7_ACT_SCELL_DL = call duration / sample interval (100 ms) in Cell 0 and 0 in other Cells
# # #    # 5min*60s*1000ms/100ms=3000
# # #    Verify counter msg is eqaul to expect value    cell_id=1    msg_id=M55316C03007
# # #    ...    exp_value=3000    meas_id_value_list=${meas_id_value_list}
# # #    Verify counter msg is eqaul to expect value    cell_id=2,3,4,5,6,7,8    msg_id=M55316C03007
# # #    ...    exp_value=0    meas_id_value_list=${meas_id_value_list}
# # #
# # #    # M55316C05007 MAX_PSCELL_UE_7_ACT_SCELL_DL = 1 in Cell 0 and 0 in other Cells
# # #    Verify counter msg is eqaul to expect value    cell_id=1
# # #    ...    msg_id=M55316C05007    exp_value=1    meas_id_value_list=${meas_id_value_list}
# # #    Verify counter msg is eqaul to expect value    cell_id=2,3,4,5,6,7,8
# # #    ...    msg_id=M55316C05007    exp_value=0    meas_id_value_list=${meas_id_value_list}
# # #
# # #    # PSCELL_UE_X_ACT_SCELL_DL = 0 in all cells , X=0,1,2,3,4,5,6
# # #    Verify counter msg is eqaul to expect value    cell_id=1,2,3,4,5,6,7,8
# # #    ...    msg_id=M55316C05000,M55316C05001,M55316C05002,M55316C05003,M55316C05004,M55316C05005,M55316C05006
# # #    ...    exp_value=0    meas_id_value_list=${meas_id_value_list}
# # #
# # #    # MAX_PSCELL_UE_X_ACT_SCELL_DL = 0 in all cells , X=0,1,2,3,4,5,7
# # #    Verify counter msg is eqaul to expect value    cell_id=1,2,3,4,5,6,7,8
# # #    ...    msg_id=M55316C03000,M55316C03001,M55316C03002,M55316C03003,M55316C03004,M55316C03005,M55316C03006
# # #    ...    exp_value=0    meas_id_value_list=${meas_id_value_list}
# # #
# # #    [Teardown]     Run Keyword And Ignore Error    Test case Teardown
# # #
# # #[1]5GC001726_GF_626_M55316C04001_M55316C06001
# # #    [Tags]
# # #    [Documentation]    author: Wang Yixiang
# # #    ...   M55316C04001 PSCELL_UE_1_ACT_SCELL_UL = call duration / sample interval (100 ms) in Cell 0 and 0 in other Cells
# # #    ...   M55316C06001 MAX_PSCELL_UE_1_ACT_SCELL_UL = 1 in Cell 0 and 0 in other Cells
# # #    ...   PSCELL_UE_X_ACT_SCELL_UL = 0 in all cells , X=0,2,3,4,5,6,7
# # #    ...   MAX_PSCELL_UE_X_ACT_SCELL_UL = 0 in all cells , X=0,2,3,4,5,6,7
# # #
# # #    [Setup]    Case preparation    scf_paras_via_api=${MODIFY_VIA_API_NON_CON_5CC_1_1_1_2_5DL_2UL}
# # #    Cobham attach UE and start traffic counter    e500_script_path=${E500_SCRIPTS_BASE}
# # #    ${meas_id_str}    Get all counter ids string    pscell_ue_x_act_scell_ul=0,1,2,3,4,5,6,7   max_pscell_ue_x_act_scell_ul=0,1,2,3,4,5,6,7
# # #    ${meas_id_value_list}    Get PM counters by cell
# # #    ...    file_path=${COUNTER_FILE_PATH}    cell=1,2,3,4,5,6,7,8    measurement_id=${meas_id_str}
# # #
# # #    # M55316C04001 PSCELL_UE_1_ACT_SCELL_UL = call duration / sample interval (100 ms) in Cell 0 and 0 in other Cells
# # #    # 5min*60s*1000ms/100ms=3000
# # #    Verify counter msg is eqaul to expect value    cell_id=1    msg_id=M55316C04001
# # #    ...    exp_value=3000    meas_id_value_list=${meas_id_value_list}
# # #    Verify counter msg is eqaul to expect value    cell_id=2,3,4,5    msg_id=M55316C04001
# # #    ...    exp_value=0    meas_id_value_list=${meas_id_value_list}
# # #
# # #    # M55316C06001 MAX_PSCELL_UE_1_ACT_SCELL_UL = 1 in Cell 0 and 0 in other Cells
# # #    Verify counter msg is eqaul to expect value    cell_id=1
# # #    ...    msg_id=M55316C06001    exp_value=1    meas_id_value_list=${meas_id_value_list}
# # #    Verify counter msg is eqaul to expect value    cell_id=2,3,4,5
# # #    ...    msg_id=M55316C06001    exp_value=0    meas_id_value_list=${meas_id_value_list}
# # #
# # #    # PSCELL_UE_X_ACT_SCELL_DL = 0 in all cells , X=0,2,3,4,5,6,7
# # #    Verify counter msg is eqaul to expect value    cell_id=1,2,3,4,5
# # #    ...    msg_id=M55316C04000,M55316C04002,M55316C04003,M55316C04004,M55316C04005,M55316C04006,M55316C04007
# # #    ...    exp_value=0    meas_id_value_list=${meas_id_value_list}
# # #
# # #    # MAX_PSCELL_UE_X_ACT_SCELL_DL = 0 in all cells , X=0,2,3,4,5,6,7
# # #    Verify counter msg is eqaul to expect value    cell_id=1,2,3,4,5
# # #    ...    msg_id=M55316C06000,M55316C06002,M55316C06003,M55316C06004,M55316C06005,M55316C06006,M55316C06007
# # #    ...    exp_value=0    meas_id_value_list=${meas_id_value_list}
# # #
# # #    [Teardown]     Run Keyword And Ignore Error    Test case Teardown
# # #
# # #[1]5GC001726_GF_627_M55316C09000_M55316C09001_M55316C09002
# # #    [Tags]
# # #    [Documentation]    author: Wang Yixiang
# # #    ...   Verify the PM counters M55316C09000,M55316C09001 and M55316C09002 can work correctly.
# # #    ...   M55316C09000 SCELL_ACTIVATIONS = 1 in 6 configured  Scells and 0 in other Cells
# # #    ...   M55316C09001 SCELL_DEACT_BUFFER_STATUS = 0 in all cells since we are in blind
# # #    ...   M55316C09002 SCELL_DEACT_CHANNEL_STATE = 0 in all cells since we are in blind
# # #
# # #    [Setup]    Case preparation    scf_paras_via_api=${MODIFY_VIA_API_CON_8CC_CC0_CC7_6DL_2UL}
# # #    Cobham attach UE and start traffic counter    e500_script_path=${E500_SCRIPTS_BASE}
# # #    ${meas_id_value_list}    Get PM counters by cell
# # #    ...    file_path=${COUNTER_FILE_PATH}    cell=1,2,3,4,5,6,7,8
# # #    ...    measurement_id=M55316C09000,M55316C09001,M55316C09002
# # #
# # #    # M55316C09000 SCELL_ACTIVATIONS = 1 in 6 configured  Scells and 0 in other Cells
# # #    Verify counter msg is eqaul to expect value    cell_id=1,2,3,4,5,6    msg_id=M55316C09000
# # #    ...    exp_value=1    meas_id_value_list=${meas_id_value_list}
# # #    Verify counter msg is eqaul to expect value    cell_id=7,8    msg_id=M55316C09000
# # #    ...    exp_value=0    meas_id_value_list=${meas_id_value_list}
# # #
# # #    # M55316C09001 SCELL_DEACT_BUFFER_STATUS = 0 in all cells since we are in blind
# # #    Verify counter msg is eqaul to expect value    cell_id=1,2,3,4,5,6,7,8
# # #    ...    msg_id=M55316C09001    exp_value=0    meas_id_value_list=${meas_id_value_list}
# # #
# # #    # M55316C09002 SCELL_DEACT_CHANNEL_STATE = 0 in all cells since we are in blind
# # #    Verify counter msg is eqaul to expect value    cell_id=1,2,3,4,5,6,7,8
# # #    ...    msg_id=M55316C09002    exp_value=0    meas_id_value_list=${meas_id_value_list}
# # #
# # #    [Teardown]     Run Keyword And Ignore Error    Test case Teardown
# # #
# # #*** Keywords ***
# # #Case preparation
# # #    [Documentation]  Author: Wang Yixiang
# # #    ...              Description: Case preparation
# # #    [Arguments]      ${scf_paras_via_api}
# # #    COAM Create log directory
# # #    Connect to gnb coam via ssl
# # #    COAM Update several parameters via rest api    parameters_to_update_via_api=${scf_paras_via_api}
# # #    ...    timeout=${TIMEOUT_REST_API_RESTART}
# # #    Wait until cluster is on cell on air status    timeout=${TIMEOUT_CLUSTER}    is_all_cells_checking_needed=${True}
# # #    COAM Update several parameters via rest api    parameters_to_update_via_api=${MODIFY_VIA_API_COUNTER}
# # #    Connect to Capacity Unit Master case
# # #
# # #Cobham attach UE and start traffic counter
# # #    [Documentation]    Author: Wang Yixiang
# # #    [Arguments]    ${e500_script_path}    ${cell_index_for_attach}=1    ${dl_tput_size}=50    ${ul_tput_size}=20
# # #    ...            ${dl_bler_threshold}=${EXPECTED_BLER}
# # #    Switch pcell for attach based on cell index    cell_index_for_attach=${cell_index_for_attach}
# # #    Cobham connection and start logging    e500_script_path=${e500_script_path}    connection=${TMA_SSH_ALIAS}
# # #    Connect to Capacity Unit Master case
# # #    wait until keyword succeeds    2 min    10 s    Connect to cobham control pc via ssh    tma_ssh_alias=${TMA_SSH_ALIAS}
# # #    Synchron gNB and cobham    alias=ASIK Master
# # #    sleep    10s
# # #    tm500.Perform cell search    cell_search_script_path=${e500_script_path}/NSA_5G_Cell_Config.txt    tm500_alias=${TMA_APP_ALIAS}
# # #
# # #    &{pre_case_time_info}    counter.calculate_waiting_time_for_log_capturing_or_log_generation    reporting_interval=5
# # #    Sleep    ${pre_case_time_info['wait_time']} min
# # #    Wait until PM counter file is genereated    log_generate_timestamp=${pre_case_time_info['log_generator_timestamp']}
# # #
# # #    Cobham Retry ue attach if failed    e500_script_path=${e500_script_path}
# # #    Iperf send UL traffic with real epc    throughput=${ul_tput_size}    traffic_time=${99999}  port=${IPERF_UL_PORT}
# # #    Iperf send DL traffic with real epc    throughput=${dl_tput_size}    traffic_time=${99999}  port=${IPERF_DL_PORT}
# # #    sleep    2s
# # #    run keyword if    ${dl_bler_threshold}!=${None}    Cobham check DL bler    dl_bler_threshold=${dl_bler_threshold}
# # #
# # #    &{case_start_time_info}    counter.calculate_waiting_time_for_log_capturing_or_log_generation    reporting_interval=5
# # #    sleep    60s
# # #    &{case_stop_time_info}    counter.calculate_waiting_time_for_log_capturing_or_log_generation    reporting_interval=5
# # #    sleep    ${case_stop_time_info['wait_time']} min
# # #    Wait until PM counter file is genereated    log_generate_timestamp=${case_stop_time_info['log_generator_timestamp']}
# # #    @{remote_file_path}    Verify PM counter file is generated    log_generate_timestamp=${case_start_time_info['log_generator_timestamp']}
# # #    log to console    ${remote_file_path}
# # #    @{local_file_path}    counter.download_pm_counter_files_to_test_pc    remote_file_path=${remote_file_path}
# # #    ...    local_file_folder=${TS_CASE_LOG_PATH}
# # #    set test variable    ${COUNTER_FILE_PATH}    ${local_file_path}
# # #
# # #
# # #Verify counter msg is eqaul to expect value
# # #    [Documentation]    Author: Wang Yixiang
# # #    ...    cell id can be follwing:
# # #    ...    cell_id=1
# # #    ...    cell_id=1-5  means 1,2,3,4,5
# # #    ...    cell_id=1,3,5
# # #    [Arguments]    ${cell_id}    ${msg_id}    ${exp_value}    ${meas_id_value_list}
# # #    @{cell_id_list}    string2list    ${cell_id}
# # #    @{msg_id_list}    string2list    ${msg_id}
# # #    :FOR   ${cell}    IN    ${cell_id_list}
# # #    \   Traverse msg id    cell=${cell}    msg_id_list=${msg_id_list}    exp_value=${exp_value}    meas_id_value_list=${meas_id_value_list}
# # #
# # #Traverse msg id
# # #    [Documentation]    Author: Wang Yixiang   [PRIVATE]
# # #    [Arguments]    ${cell}    ${msg_id_list}    ${exp_value}    ${meas_id_value_list}
# # #    :FOR   ${msg_id}    IN    ${msg_id_list}
# # #    \    run keyword and continue on failure
# # #        ...    should be equal as integers    @{meas_id_value_list[${cell}][${msg_id}]}    ${expect_value}
# # #        ...    msg=${msg_id} not match in cell ${cell}, please check'
# # #
# # #Get all counter ids string
# # #    [Documentation]    Author: Wang Yixiang
# # #    ...    M55316C0300X, PSCELL_UE_X_ACT_SCELL_DL, X=0,1,2,3,4,5,6,7     (e.g X=0 => M55316C03000, PSCELL_UE_0_ACT_SCELL_DL)
# # #    ...    M55316C0500X, MAX_PSCELL_UE_X_ACT_SCELL_DL, X=0,1,2,3,4,5,6,7 (e.g X=0 => M55316C05000, MAX_PSCELL_UE_0_ACT_SCELL_DL)
# # #    ...    M55316C0400X, PSCELL_UE_X_ACT_SCELL_UL, X=0,1,2,3,4,5,6,7     (e.g X=1 => M55316C04001, PSCELL_UE_1_ACT_SCELL_UL)
# # #    ...    M55316C0600X, MAX_PSCELL_UE_X_ACT_SCELL_UL, X=0,1,2,3,4,5,6,7 (e.g X=1 => M55316C06001, MAX_PSCELL_UE_1_ACT_SCELL_UL)
# # #    ...    e.g
# # #    ...    ${ret}   Get all counter ids string    pscell_ue_x_act_scell_dl=0,1,2
# # #    ...                                           max_pscell_ue_x_act_scell_dl=5,6,7
# # #    ...    ${ret}: M55316C03000,M55316C03001,M55316C03002,M55316C05005,M55316C05006,M55316C05007
# # #    [Arguments]    ${pscell_ue_x_act_scell_dl}=${None}     ${max_pscell_ue_x_act_scell_dl}=${None}
# # #    ...            ${pscell_ue_x_act_scell_ul}=${None}     ${max_pscell_ue_x_act_scell_ul}=${None}
# # #    ${ids_string}    set variable     ${empty}
# # #    ${pscell_ue_x_act_scell_dl_ids}    run keyword if    ${pscell_ue_x_act_scell_dl}!=${None}
# # #    ...    Get one counter ids string    counters=${pscell_ue_x_act_scell_dl}    counter_msg_base=M55316C0300
# # #    ${max_pscell_ue_x_act_scell_dl_ids}    run keyword if    ${max_pscell_ue_x_act_scell_dl}!=${None}
# # #    ...    Get one counter ids string    counters=${max_pscell_ue_x_act_scell_dl}    counter_msg_base=M55316C0500
# # #    ${pscell_ue_x_act_scell_ul_ids}    run keyword if    ${pscell_ue_x_act_scell_ul}!=${None}
# # #    ...    Get one counter ids string    counters=${pscell_ue_x_act_scell_ul}        counter_msg_base=M55316C0400
# # #    ${max_pscell_ue_x_act_scell_ul_ids}    run keyword if    ${max_pscell_ue_x_act_scell_ul}!=${None}
# # #    ...    Get one counter ids string    counters=${max_pscell_ue_x_act_scell_ul}    counter_msg_base=M55316C0600
# # #    ${ids_string}    catenate   SEPARATOR=,   ${pscell_ue_x_act_scell_dl_ids}    ${max_pscell_ue_x_act_scell_dl_ids}
# # #    ...    ${pscell_ue_x_act_scell_ul_ids}    ${max_pscell_ue_x_act_scell_ul_ids}
# # #    ${ids_string}    Remove String    ${ids_string}    ,None
# # #    [Return]    ${ids_string}
# # #
# # #Get one counter ids string
# # #    [Documentation]    Author: Wang Yixiang   [PRIVATE]
# # #    [Arguments]    ${counters}    ${counter_msg_base}
# # #    ${ret}    set variable    ${empty}
# # #    ${counters_list}    string2list    ${counters}
# # #    :FOR    ${counter_id}     IN     @{counters_list}
# # #    \   ${ret}    catenate   SEPARATOR=,   ${ret}    ${counter_msg_base}${counter_id}
# # #    ${ret}    Get Substring    ${ret}    1
# # #    [return]    ${ret}
# # #
# # #
