*** Settings ***
Documentation
...   This is for 1937 common keywords
...   author: Ren Biyao
...   contact: biyao.ren@nokia-sbell.com
...   squad group: MMW_SG1
Resource    ./1937_variables.robot
Variables   ./1937_variables.py
Variables   ./../TestData/1937_SCF_modify.py
Resource    ../../5GC001726/Resources/5GC001726_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/rrm_log_check.robot
Library     ./avg_calculate.py
Resource    ../../common/l3_call_ota_2drb_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/log/collect_logs.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py    WITH NAME    ue_type
Library     ute_reporting_portal
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/kpi_reporter.py
Library     kpi_reporter.KpiReporter    WITH NAME    KpiReporter
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Variables    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/lib/NIDD_modify_merge_scf.py

*** Keywords ***
Pre Condition
    [Documentation]    Author: Ren Biyao
    ...    This keyword will set the default path for scf which will be used for ute cloud or lightweight CI.
    [Timeout]    20 min
    [Arguments]     ${scf_modify}=${PARAMS_TO_MODIFY_SCF}
    Import NIDD variables     # import 1726 variable ${MODIFY_SCF_FOR_4CC_CELL_PARAMETERS}
    ${SCF_PATH}     Get Substring    ${CURDIR}  0  -53
    ${TL_NAME}   set variable if      '${testline_name}' == 'null'    ${CONFIGURATION}    ${testline_name}
    ${pattern}   Set Variable    7_5(.*)
    ${TLNAME}    Get Regexp Matches     ${TL_NAME}    ${pattern}    1
    ${testlinename}   Set Variable    7_5${TLNAME}[0]
    ${CONFIGURATION}    Get Variable Value    ${CONFIGURATION}
    set suite variable     ${CONFIGURATION}
    set suite variable     ${SCF_PATH}
    set suite variable     ${testlinename}
    import variables    commissionings/HGZ/${testlinename}/TLDelta.py
    import library      scf_process.SCFProcess    WITH NAME    scfpro
    Connect to Common Unit Master    alias=ASIK Master
    run keyword if    '${CONFIGURATION}' != '${None}' and '${CONFIGURATION}' != 'null'
    ...    Default directory for ute cloud
    ...    ELSE    Default directory for lightweight ci   scf_modify=${scf_modify}
    ${UE_TYPE}     ue_type.translate_power_ue_type_from_testline
    set suite variable     ${UE_TYPE}
    power_ue.Prepare UE    ue_type=${UE_TYPE}
    Tput value with deviation


Default directory for lightweight ci
    [Documentation]    Author: Ren Biyao
    ...     Description: default dir scf and swconfig for lightweight ci.
    [Arguments]     ${scf_modify}=${PARAMS_TO_MODIFY_SCF}
    set suite variable     ${BTS_ID}                 ${tl.gnbs[0].instance_id}
    ${cur_program}    gnb_classical_hangzhou.Get program version based on stream version
    set suite variable    ${PROGRAM}    ${cur_program}
    ${GOLDEN_FULL_SCF_8CC_TMP}     Set variable if     '${PROGRAM}'=='22R2'
    ...    /home/ute/Projects/mmw1_config/${testline_name}/scf/SCF_MMW1_TL${BTS_ID}_8cc_22R2.xml
    ...    /home/ute/Projects/mmw1_config/${testline_name}/scf/SCF_MMW1_TL${BTS_ID}.xml
    ${ABIO_0CC_DEL}     Set variable if     '${PROGRAM}'=='22R2'
    ...    ${None}     ${ABIO_0CC_DEL}
    set suite variable   ${GOLDEN_FULL_SCF_8CC}    ${GOLDEN_FULL_SCF_8CC_TMP}
    set suite variable   ${SWCONFIG_DEFAULT_FILE_PATH}
    ...     /home/ute/Projects/mmw1_config/${testline_name}/swconfig/swconfig_MMW1_TL${BTS_ID}.txt
    coam create log directory      is_set_to_test_case_level=${False}

    ${tl_scf_process_path}    scfpro.SCFProcess
    ...    scf_template_path=${GOLDEN_FULL_SCF_8CC}
    ...    scf_process_folder=${SUITE_LOG_PATH}/8cc_CA
    ...    list_para_to_delete=${ABIL_DL8CC_UL2CC_DEL}
    ...    list_para_to_modify=${TL_PARAMS_TO_MODIFY_8CC_CA}
    ...    list_para_to_add=${None}

    ${4cc_tl_scf_process_path}   scfpro.SCFProcess
    ...    scf_template_path=${tl_scf_process_path}
    ...    scf_process_folder=${SUITE_LOG_PATH}/4cc_CA
    ...    list_para_to_delete=${TL_PARAMS_TO_DELETE_4Cell}
    ...    list_para_to_modify=${None}
    ...    list_para_to_add=${None}

    ${6cc_tl_scf_process_path}   scfpro.SCFProcess
    ...    scf_template_path=${tl_scf_process_path}
    ...    scf_process_folder=${SUITE_LOG_PATH}/6cc_CA
    ...    list_para_to_delete=${TL_PARAMS_TO_DELETE_2Cell}
    ...    list_para_to_modify=${None}
    ...    list_para_to_add=${None}

    ${7cc_tl_scf_process_path}   scfpro.SCFProcess
    ...    scf_template_path=${tl_scf_process_path}
    ...    scf_process_folder=${SUITE_LOG_PATH}/7cc_CA
    ...    list_para_to_delete=${TL_PARAMS_TO_DELETE_1Cell}
    ...    list_para_to_modify=${None}
    ...    list_para_to_add=${None}

    set suite variable    ${tl_scf_process_path}
    set suite variable    ${GOLDEN_FULL_SCF_4CC}    ${4cc_tl_scf_process_path}
    set suite variable    ${GOLDEN_FULL_SCF_6CC}    ${6cc_tl_scf_process_path}
    set suite variable    ${GOLDEN_FULL_SCF_7CC}    ${7cc_tl_scf_process_path}
    Preparation with swconfig modification and comissioning    swconfig_modify=${None}    scf_modify=${scf_modify}
    ...    is_called_in_test_case_level=${False}    is_pdl_checking_needed=${False}
    ...    scf_template_path=${tl_scf_process_path}
    Wait until cluster is on cell on air status    timeout=${TIMEOUT_CLUSTER}    is_all_cells_checking_needed=${True}

Default directory for ute cloud
    [Documentation]    Author: Ren Biyao
    ...     Description: default dir scf and swconfig and log dir for ute cloud.
    ${cur_dir}    run    pwd
    set suite variable     ${TS_LOG_PATH_BASE}       ${cur_dir}/../test_results
    set suite variable     ${GOLDEN_FULL_SCF_8CC}    ${SCF_PATH}/commissionings/HGZ/${testlinename}/SCF_0.800_8cc.xml
    set suite variable     ${GOLDEN_FULL_SCF_4CC}    ${SCF_PATH}/commissionings/HGZ/${testlinename}/SCF_0.800_4cc.xml
    set suite variable     ${GOLDEN_FULL_SCF_3CC}    ${SCF_PATH}/commissionings/HGZ/${testlinename}/SCF_0.800_3cc.xml
    set suite variable     ${GOLDEN_FULL_SCF_2CC}    ${SCF_PATH}/commissionings/HGZ/${testlinename}/SCF_0.800_2cc.xml
    set suite variable     ${GOLDEN_FULL_SCF_6CC}    ${SCF_PATH}/commissionings/HGZ/${testlinename}/SCF_0.800_6cc.xml
    set suite variable     ${GOLDEN_FULL_SCF_7CC}    ${SCF_PATH}/commissionings/HGZ/${testlinename}/SCF_0.800_7cc.xml
    set suite variable     ${SWCONFIG_DEFAULT_FILE_PATH}    ${SCF_PATH}/commissionings/HGZ/${testlinename}/swconfig.txt
    set suite variable     ${luashark_path}        /opt/luashark/luashark.lua
    set suite variable     ${RETRY_TIME_TCP}        ${1}
    coam create log directory      is_set_to_test_case_level=${False}
    CI_interface.Common Suite Setup
    ${tl_scf_process_path}    scfpro.SCFProcess
    ...    scf_template_path=${GOLDEN_FULL_SCF_8CC}
    ...    scf_process_folder=${SUITE_LOG_PATH}
    ...    list_para_to_delete=${None}
    ...    list_para_to_modify=${TL_PARAMS_TO_MODIFY_8CC_CA}
    ...    list_para_to_add=${TL_PARAMS_TO_ADD_8CC_CA}
    set suite variable    ${tl_scf_process_path}

Case preparation
    [Arguments]     ${scf_template_path}     ${act_xcc_cell_number}    ${swconfig_modify}=${None}     ${scf_modify}=${MODIFY_TL_NAME}
    ...     ${is_pdl_checking_needed}=${False}    ${cell_index_for_attach}=${1}    ${is_need_to_process_scf}=${False}
    ...     ${is_log_required}=${True}
    ...     ${name}=btslog    ${btslog_path}=/opt/btslog/btslog    ${btslog_launcher_path}=/opt/btslog/btslog_launcher
    ...     ${log_storage_dir}=/tmp/btslog2    ${host}=${tl.test_pc.default_ssh_connection_details.addr}    ${is_btslog_required}=${True}

    coam create log directory
    Connect to gnb coam via ssl
    &{pre_env_xcc_config}    get_relation_mapping_between_cell_index_and_other_ids
    ${pre_env_xcc_config}    get length    ${pre_env_xcc_config}

    run keyword if    ${act_xcc_cell_number}!=${pre_env_xcc_config} or ${is_need_to_process_scf}
    ...    Preparation with swconfig modification and comissioning    swconfig_modify=${swconfig_modify}    scf_modify=${scf_modify}
    ...    is_called_in_test_case_level=${True}    is_pdl_checking_needed=${is_pdl_checking_needed}
    ...    scf_template_path=${scf_template_path}
    run keyword if    '${CONFIGURATION}' != '${None}' and '${CONFIGURATION}' != 'null'     Recovery ru if sw corrupted
    Wait until cluster is on cell on air status    timeout=${TIMEOUT_CLUSTER}    is_all_cells_checking_needed=${True}

    &{NR_CELL_ID_MAPPING}    get_relation_mapping_between_cell_index_and_other_ids
    Set test variable    ${NR_CELL_ID_MAPPING}

    _capture log in case setup    is_log_required=${is_log_required}
    ...    name=${name}    btslog_path=${btslog_path}
    ...    btslog_launcher_path=${btslog_launcher_path}
    ...    log_storage_dir=${log_storage_dir}    host=${host}

    Switch pcell for attach based on cell index    cell_index_for_attach=${cell_index_for_attach}
    connect to common unit master
    run keyword and ignore error
    ...    Connect to Capacity Unit Loner case    alias=ABIL Loner_1
    Connect to Capacity Unit Slave case


Case Teardown
    [Documentation]    Author: Ren Biyao
    [Timeout]    20 min
    [Arguments]    ${log_path}=${TS_CASE_LOG_PATH}    ${protocol}=udp    ${is_log_required}=${True}
    ...    ${is_need_to_clear_unused_logs}=${True}
    COAM Teardown gnb connections
    power_ue.UE Detach    ue_type=${UE_TYPE}
    Stop data transfer based on direction    data_transfer_direction=both   protocol=${protocol}
    run keyword if    ${is_log_required}    Collect logs in teardown classical and cloud
    ...    is_called_in_test_case_level=${True}    name=btslog    is_btslog_required=${True}
    run keyword and ignore error    run keyword if    ${is_need_to_clear_unused_logs}
    ...    Clear unuseful log in teardown    log_path=${TS_CASE_LOG_PATH}   is_called_in_test_case_level=${True}
    CI_interface.Common Case Teardown
    run keyword and ignore error    Close all connection


Post conditions
    [Documentation]    Author: Ren Biyao
    [Timeout]    25 min
    run keyword and ignore error    Close all connection

Tput value with deviation
    [Arguments]     ${tcp_ul_deviation}=${TCP_UL_DEVIATION}    ${tcp_dl_deviation}=${TCP_DL_DEVIATION}
    ...    ${udp_ul_deviation}=${UDP_UL_DEVIATION}    ${udp_dl_deviation}=${UDP_DL_DEVIATION}
    [Documentation]     Author: Ren Biyao
    ...       :para${deviation}: percentage
    ${UL_EXPECT_TPUT_TCP}           evaluate     ${UL_EXPECT_TPUT}*${tcp_ul_deviation}
    ${UL_EXPECT_TPUT_UDP}           evaluate     ${UL_EXPECT_TPUT}*${udp_ul_deviation}
    ${2CC_2DL_2UL_DL_EXPECT_TCP}    evaluate     ${2CC_2DL_2UL_DL_EXPECT}*${tcp_dl_deviation}
    ${2CC_2DL_2UL_DL_EXPECT_UDP}    evaluate     ${2CC_2DL_2UL_DL_EXPECT}*${udp_dl_deviation}
    ${3CC_3DL_2UL_DL_EXPECT_TCP}    evaluate     ${3CC_3DL_2UL_DL_EXPECT}*${tcp_dl_deviation}
    ${3CC_3DL_2UL_DL_EXPECT_UDP}    evaluate     ${3CC_3DL_2UL_DL_EXPECT}*${udp_dl_deviation}
    ${4CC_4DL_2UL_DL_EXPECT_TCP}    evaluate     ${4CC_4DL_2UL_DL_EXPECT}*${tcp_dl_deviation}
    ${4CC_4DL_2UL_DL_EXPECT_UDP}    evaluate     ${4CC_4DL_2UL_DL_EXPECT}*${udp_dl_deviation}
    ${6CC_6DL_2UL_DL_EXPECT_TCP}    evaluate     ${6CC_6DL_2UL_DL_EXPECT}*${tcp_dl_deviation}
    ${6CC_6DL_2UL_DL_EXPECT_UDP}    evaluate     ${6CC_6DL_2UL_DL_EXPECT}*${udp_dl_deviation}
    ${7CC_7DL_2UL_DL_EXPECT_TCP}    evaluate     ${7CC_7DL_2UL_DL_EXPECT}*${tcp_dl_deviation}
    ${7CC_7DL_2UL_DL_EXPECT_UDP}    evaluate     ${7CC_7DL_2UL_DL_EXPECT}*${udp_dl_deviation}
    ${8CC_8DL_2UL_DL_EXPECT_TCP}    evaluate     ${8CC_8DL_2UL_DL_EXPECT}*${tcp_dl_deviation}
    ${8CC_8DL_2UL_DL_EXPECT_UDP}    evaluate     ${8CC_8DL_2UL_DL_EXPECT}*${udp_dl_deviation}

    set suite variable    ${UL_EXPECT_TPUT_TCP}
    set suite variable    ${UL_EXPECT_TPUT_UDP}
    set suite variable    ${2CC_2DL_2UL_DL_EXPECT_TCP}
    set suite variable    ${2CC_2DL_2UL_DL_EXPECT_UDP}
    set suite variable    ${3CC_3DL_2UL_DL_EXPECT_TCP}
    set suite variable    ${3CC_3DL_2UL_DL_EXPECT_UDP}
    set suite variable    ${4CC_4DL_2UL_DL_EXPECT_TCP}
    set suite variable    ${4CC_4DL_2UL_DL_EXPECT_UDP}
    set suite variable    ${6CC_6DL_2UL_DL_EXPECT_TCP}
    set suite variable    ${6CC_6DL_2UL_DL_EXPECT_UDP}
    set suite variable    ${7CC_7DL_2UL_DL_EXPECT_TCP}
    set suite variable    ${7CC_7DL_2UL_DL_EXPECT_UDP}
    set suite variable    ${8CC_8DL_2UL_DL_EXPECT_TCP}
    set suite variable    ${8CC_8DL_2UL_DL_EXPECT_UDP}

Attach and check peak tput
   [Documentation]     Author: Ren Biyao
   ...    For TCP, no need to capture and check BIP
    [Arguments]   ${act_dl_tput}   ${act_ul_tput}    ${exp_ul_tput}    ${exp_dl_tput}    ${cell_number}
    ...    ${duration_time_for_once}=${300}    ${local_log_folder}=${TS_CASE_LOG_PATH}
    ...    ${buffer_size}=1400B
    ...    ${retry_time}=${5}
    ...    ${data_transfer_direction}=both
    ...    ${process_num}=${60}
    ...    ${protocol}=tcp
    ...    ${is_need_to_send_rp}=${True}
    ${list_cell_number}    string2list    ${cell_number}
    ${traffic_time}    evaluate    ${duration_time_for_once}*2
    @{list_tput_info}    Create list

    FOR   ${x_time}  IN RANGE  ${retry_time}

          ${attach_status}    run keyword and return status     Wait until keyword succeeds    2X    10 s    Power ue attach
          continue for loop if     ${attach_status}==${False}

          wait until keyword succeeds    3x    5s    Start data transfer based on direction
          ...    dl_tput=${act_dl_tput}   ul_tput=${act_ul_tput}   duration=${traffic_time}
          ...    buffer_size=${buffer_size}    protocol=${protocol}    data_transfer_direction=${data_transfer_direction}
          ...    process_num=${3}    seg_size=${1350}    window=10M
          ${time_stamp_start}    DateTime.get current date    result_format=epoch    exclude_millis=True
          ${pre_tput_check}    join path   ${local_log_folder}   Tput_check_${time_stamp_start}
          create directory     ${pre_tput_check}
          sleep   15s
          log to console       ${x_time} times, tput starts at ${time_stamp_start} seconds!

          Wait until keyword succeeds    1 min    10 sec    Connect to Common Unit Master
          ${tput_log_dir_on_gnb}    Start tput log capture
          sleep    ${duration_time_for_once}
          @{tput_file_list}    Split tput log to ul and dl files
          run keyword and ignore error    check_average_throughput.stop_tput_aasyslog_capturing    asik_alais=ASIK Master
           run keyword and ignore error      Stop data transfer based on direction
           &{dict_local_tput_file_path}    Download tput file to test pc    ul_dl_tput_file_paths_gnb=${tput_file_list}
           ...    local_log_folder=${pre_tput_check}
           ${time_stamp_stop}    DateTime.get current date    result_format=epoch    exclude_millis=True
           ${time_duration}    evaluate     ${time_stamp_stop}-${time_stamp_start}
           log to console       ${x_time} times, tput stops at ${time_stamp_stop} seconds, duration is ${time_duration} seconds!
           ${ul_tput_avg}   ${ul_tput_max}   ${ul_tput_min}   ${ul_detail_peak_tput_info}
           ...    verify_tput.get_details_of_peak_tput_all_cells   tput_file=${dict_local_tput_file_path['UL_L2LO']}
           ...    list_cell=${list_cell_number}    nr_cell_id_mapping=${NR_CELL_ID_MAPPING}
           ${dl_tput_avg}   ${dl_tput_max}   ${dl_tput_min}   ${dl_detail_peak_tput_info}
           ...    verify_tput.get_details_of_peak_tput_all_cells   tput_file=${dict_local_tput_file_path['DL_L2LO']}
           ...    list_cell=${list_cell_number}    nr_cell_id_mapping=${NR_CELL_ID_MAPPING}
           ${status}    run keyword and return status     should be true    ${ul_tput_avg}>=${exp_ul_tput} and ${dl_tput_avg}>=${exp_dl_tput}
           run keyword if    ${status}==${False}     run keyword and ignore error     run keywords
          ...    UE detach should be successed    AND
          ...    Stop data transfer based on direction    protocol=${protocol}    data_transfer_direction=${data_transfer_direction}    AND
          ...    check_average_throughput.stop_tput_aasyslog_capturing    asik_alais=ASIK Master
          log to console    this is ${x_time} time. ul_tput_avg/ul_tput_max is ${ul_tput_avg}/${ul_tput_max};
          ...    dl_tput_avg/dl_tput_max is ${dl_tput_avg}/${dl_tput_max}
          &{dict_tput_info}    Create dictionary
          Set to dictionary    ${dict_tput_info}    this_is_all_tput_info_for_x_time=${x_time}
          Set to dictionary    ${dict_tput_info}    ul_tput_peak_all_cells_avg=${ul_tput_avg}
          Set to dictionary    ${dict_tput_info}    ul_tput_peak_all_cells_max=${ul_tput_max}
          Set to dictionary    ${dict_tput_info}    ul_tput_peak_all_cells_min=${ul_tput_min}
          Set to dictionary    ${dict_tput_info}    dl_tput_peak_all_cells_avg=${dl_tput_avg}
          Set to dictionary    ${dict_tput_info}    dl_tput_peak_all_cells_max=${dl_tput_max}
          Set to dictionary    ${dict_tput_info}    dl_tput_peak_all_cells_min=${dl_tput_min}
          set to dictionary    ${dict_tput_info}    ul_tput_peak_all_cells_details=${ul_detail_peak_tput_info}
          set to dictionary    ${dict_tput_info}    dl_tput_peak_all_cells_details=${dl_detail_peak_tput_info}
          Append to list    ${list_tput_info}    ${dict_tput_info}
          exit for loop if    ${status}
    END
    should be true    ${attach_status}    msg=attach fail.
    run keyword and continue on failure      should be true    ${status}
    ...    msg=dir_${data_transfer_direction} tput check fail.
    run keyword and continue on failure      set test variable    ${dict_tput_info}
    ${TEST STATUS}     set variable if    ${status}       ${status}        FAIL
    [Teardown]         run keyword and ignore error    run keywords
    ...    power_ue.UE Detach    ue_type=${UE_TYPE}    AND
    ...    check_average_throughput.stop_tput_aasyslog_capturing    AND
    ...    Stop data transfer based on direction    protocol=${protocol}    data_transfer_direction=${data_transfer_direction}    AND
    ...    run keyword if    ${is_need_to_send_rp}    Send data to rp based on direction
    ...    dl_avg=${dict_tput_info}[dl_tput_peak_all_cells_avg] Mbits/sec
    ...    dl_max=${dict_tput_info}[dl_tput_peak_all_cells_max] Mbits/sec
    ...    dl_min=${dict_tput_info}[dl_tput_peak_all_cells_min] Mbits/sec
    ...    ul_avg=${dict_tput_info}[ul_tput_peak_all_cells_avg] Mbits/sec
    ...    ul_max=${dict_tput_info}[ul_tput_peak_all_cells_max] Mbits/sec
    ...    ul_min=${dict_tput_info}[ul_tput_peak_all_cells_min] Mbits/sec
    ...    protocol=${protocol}
    ...    exp_dl=${exp_dl_tput} Mbits/sec    exp_ul=${exp_ul_tput} Mbits/sec
    ...    data_transfer_direction=${data_transfer_direction}
    ...    logs_dir=${pre_tput_check}

Send data to rp based on direction
    [Documentation]     Author: Ren Biyao
    ...    Description: this kw is to send tput result to rp.
    ...    para:${data_transfer_direction}: both, ul, dl
    [Arguments]     ${exp_dl}    ${dl_avg}    ${dl_max}    ${dl_min}    ${exp_ul}    ${ul_avg}    ${ul_max}    ${ul_min}
    ...    ${protocol}    ${data_transfer_direction}    ${deviation}=0%    ${logs_dir}=${TS_CASE_LOG_PATH}

    Run keyword if    '${data_transfer_direction}'=='both'
    ...    Run keywords     KpiReporter.add_dl_throughput_into_report_list
    ...    exp_dl=${exp_dl}    dl_avg=${dl_avg}    dl_max=${dl_max}    dl_min=${dl_min}    AND
    ...    KpiReporter.add_ul_throughput_into_report_list
    ...    exp_ul=${exp_ul}    ul_avg=${ul_avg}    ul_max=${ul_max}    ul_min=${ul_min}

    ...    ELSE IF    '${data_transfer_direction}'=='ul'
    ...    KpiReporter.add_ul_throughput_into_report_list
    ...    exp_ul=${exp_ul}    ul_avg=${ul_avg}    ul_max=${ul_max}    ul_min=${ul_min}

    ...    ELSE IF    '${data_transfer_direction}'=='dl'
    ...    KpiReporter.add_dl_throughput_into_report_list
    ...    exp_dl=${exp_dl}    dl_avg=${dl_avg}    dl_max=${dl_max}    dl_min=${dl_min}
    ...    ELSE    Should be true    ${False}    msg=Invalid input for data_transfer_direction, supported values are: both, ul, dl
    KpiReporter.report_tput_kpi    protocol=${protocol}    deviation=${deviation}    logs_dir=${logs_dir}
    [Teardown]      KpiReporter.clear_report_list

Recovery ru if sw corrupted
    [Documentation]  Author: Ren Biyao
    ...    Description: this keyword is to recovery the env if "sw corrupted" show up, fault id is 1850, retry time is 2x.
    [Arguments]     ${connection}=GNB_OAM    ${reset_times}=${2}
    FOR    ${x_time}    IN RANGE    ${reset_times}
        Wait until keyword succeeds    10min    5sec    Connect to gnb coam via ssl    connection=${connection}
        Wait until keyword succeeds    10min    5sec    COAM Check GNB ASIK status    connection=${connection}
        ${if_sw_corrupted_shows}    run keyword and return status
        ...   Wait until keyword succeeds    1min    5sec   Expect Fault Should Present     faultId=1850
        run keyword if    ${if_sw_corrupted_shows}    run keywords    coam.reset_site    connection=${connection}    AND
        ...    coam.teardown   connection=${connection}    AND
        ...    Wait until keyword succeeds    10min    5sec    Connect to gnb coam via ssl    connection=${connection}    AND
         ...    Wait until keyword succeeds    10min    5sec    COAM Check GNB ASIK status    connection=${connection}
        ${if_sw_corrupted_shows}    run keyword and return status
        ...   Wait until keyword succeeds    1min    5sec   Expect Fault Should Present     faultId=1850
        exit for loop if     ${if_sw_corrupted_shows}==${False}
    END
    should not be true    ${if_sw_corrupted_shows}    msg=after 2x recovery, the ru still shows sw corrupted!

Step 1: ue attach
    [Arguments]   ${ue_type}=${UE_TYPE}    ${ue_index}=${0}
    Wait until keyword succeeds    2X    10 s    Power ue attach    ue_type=${ue_type}    ue_index=${ue_index}

Step 2: start traffic
     [Arguments]    ${act_dl_tput}   ${act_ul_tput}    ${data_transfer_direction}=both    ${protocol}=udp
     ...    ${buffer_size}=1400B    ${traffic_time}=1200
     ${process_num_dl}    set variable if
     ...    ${BTS_ID}==245 and '${protocol}'=='tcp'   ${3}
     ...    ${BTS_ID}==256 and '${protocol}'=='tcp'   ${3}
     ...    ${BTS_ID}==245 and '${protocol}'=='udp'   ${2}
     ...    ${BTS_ID}==256 and '${protocol}'=='udp'   ${2}
     ${process_num_ul}    set variable if     ${BTS_ID}==245     ${3}
     ...    ${BTS_ID}==256    ${3}
     ${window}    set variable if     ${BTS_ID}==245     13M
     ...    ${BTS_ID}==256    12M

     wait until keyword succeeds    3x    5s    Start data transfer based on direction 1937
     ...    dl_tput=${act_dl_tput}   ul_tput=${act_ul_tput}   duration=${traffic_time}
     ...    buffer_size=${buffer_size}    protocol=${protocol}    data_transfer_direction=${data_transfer_direction}
     ...    process_num_dl=${process_num_dl}    process_num_ul=${process_num_ul}    seg_size=${1350}    window=${window}

Step 3: collect aasyslog
    [Arguments]    ${ue_type}=${UE_TYPE}    ${gnb_index}=0    ${du_index}=0    ${duration}=5m    ${ignore_time}=30s
    ${tput_log}    power_ue.Collect Tput   ue_type=${ue_type}    gnb_index=${gnb_index}    du_index=${du_index}
    ...    duration=${duration}   ignore_time=${ignore_time}
    set test variable    ${tput_log}
    run keyword and ignore error     Connect to Appserver and check iperf process
    [Return]    ${tput_log}

Step 4: stop traffic
    [Arguments]    ${protocol}=udp    ${data_transfer_direction}=both
    run keyword and ignore error      wait until keyword succeeds    3x    5s
    ...    Stop data transfer based on direction    protocol=${protocol}    data_transfer_direction=${data_transfer_direction}

Step 5: Check tput
    [Arguments]     ${nr_cell_id_mapping}=${NR_CELL_ID_MAPPING}    ${data_transfer_direction}=both    ${ue_type}=${UE_TYPE}
    ...          ${exp_ul_tput}=400    ${exp_dl_tput}=1950    ${protocol}=udp    ${is_need_to_send_rp}=${True}
    ...            ${target_avg_percent}=1.0    ${actCarrierAggregation}=${True}     ${log}=${TPUT_LOG}
    ${info}   get dictionary values    ${nr_cell_id_mapping}
    ${list_of_cell_ids}    create list
    FOR    ${cur_info}    IN    @{info}
           ${cur_nridentiity}    set variable   ${cur_info}[nrCellIdentity]
           ${cur_nridentiity}   convert to string    ${cur_nridentiity}
           append to list    ${list_of_cell_ids}   ${cur_nridentiity}
    END
    ${ul_tput}    run keyword if    '${data_transfer_direction}'=='ul'   run keyword and continue on failure
    ...    power_ue.Check Tput    direction=UL    ue_type=${ue_type}   log=${log}    cells=${list_of_cell_ids}
    ...            target_throughput=${exp_ul_tput}     target_avg_percent=${target_avg_percent}
    ...            actCarrierAggregation=${actCarrierAggregation}

    run keyword and ignore error     run keyword if     '${data_transfer_direction}'=='ul'    Send data to rp based on direction
    ...    dl_avg=None    ul_avg=${ul_tput[0]}[average] Mbits/sec
    ...    dl_max=None    ul_max=${ul_tput[0]}[peak] Mbits/sec
    ...    dl_min=None    ul_min=${ul_tput[0]}[minimum] Mbits/sec
    ...    logs_dir=${TS_CASE_LOG_PATH}
    ...    protocol=${protocol}
    ...    exp_dl=None    exp_ul=${exp_ul_tput} Mbits/sec
    ...    data_transfer_direction=${data_transfer_direction}

    ${dl_tput}    run keyword if    '${data_transfer_direction}'=='dl'    run keyword and continue on failure
    ...    power_ue.Check Tput    direction=DL    ue_type=${ue_type}   log=${log}    cells=${list_of_cell_ids}
    ...            target_throughput=${exp_dl_tput}     target_avg_percent=${target_avg_percent}
    ...            actCarrierAggregation=${actCarrierAggregation}

    run keyword and ignore error     run keyword if     '${data_transfer_direction}'=='dl'    Send data to rp based on direction
    ...    dl_avg=${dl_tput[0]}[average] Mbits/sec    ul_avg=None
    ...    dl_max=${dl_tput[0]}[peak] Mbits/sec       ul_max=None
    ...    dl_min=${dl_tput[0]}[minimum] Mbits/sec    ul_min=None
    ...    logs_dir=${TS_CASE_LOG_PATH}
    ...    protocol=${protocol}
    ...    exp_dl=${exp_dl_tput} Mbits/sec    exp_ul=None
    ...    data_transfer_direction=${data_transfer_direction}

    ${ul_tput}   ${dl_tput}    run keyword if    '${data_transfer_direction}'=='both'
    ...    power_ue.Check Bi Tput    ue_type=${ue_type}   log=${log}    cells=${list_of_cell_ids}
    ...            ultarget_throughput=${exp_ul_tput}   dltarget_throughput=${exp_dl_tput}     target_avg_percent=${target_avg_percent}
    ...            actCarrierAggregation=${actCarrierAggregation}

    run keyword and ignore error     run keyword if     '${data_transfer_direction}'=='both'    Send data to rp based on direction
    ...    dl_avg=${dl_tput[0]}[average] Mbits/sec
    ...    dl_max=${dl_tput[0]}[peak] Mbits/sec
    ...    dl_min=${dl_tput[0]}[minimum] Mbits/sec
    ...    ul_avg=${ul_tput[0]}[average] Mbits/sec
    ...    ul_max=${ul_tput[0]}[peak] Mbits/sec
    ...    ul_min=${ul_tput[0]}[minimum] Mbits/sec
    ...    logs_dir=${TS_CASE_LOG_PATH}
    ...    protocol=${protocol}
    ...    exp_dl=${exp_dl_tput} Mbits/sec    exp_ul=${exp_ul_tput} Mbits/sec
    ...    data_transfer_direction=${data_transfer_direction}

Connect to Appserver and check iperf process
    [Documentation]    Author: Wang Yixiang
    ...    Connect to Appserver and check iperf process
    traffic_via_iperf.Connect to APPserver
    ${iperf_ret}   csn.execute    command=ps -ef|grep iperf    connection=APPserver
    log    ${iperf_ret}
    [Teardown]    csn.disconnect    connection=APPserver

Start data transfer based on direction 1937
    [Documentation]  Author: Wang Yixiang
    ...              Description: Start data transfer based on direction
    ...                           data_transfer_direction: supported values are both, ul, dl
    ...              ${UE_TYPE} is gotten from keyword <translate_power_ue_type_from_testline> and set to suite variable.
    [Arguments]    ${dl_tput}    ${ul_tput}    ${duration}    ${protocol}=udp    ${process_num_dl}=${3}    ${process_num_ul}=${3}
    ...    ${data_transfer_direction}=both    ${ue_index}=${0}      ${seg_size}=1350
    ...    ${ue_alias}=UE_${ue_index}    ${iperf_ul}=${None}    ${iperf_dl}=${None}    ${buffer_size}=1400B
    ...    ${iperf_type_ul}=via_command    ${window}=16M
    ${data_transfer_direction}=    Convert To Lowercase    ${data_transfer_direction}
    ${iperf_ul}    Set variable if    '${UE_TYPE}' == 'inseego' or '${UE_TYPE}' == 'mtk'  ${iperf_ul}
    ...  '${UE_TYPE}' == 'askey'    default
    ...  '${UE_TYPE}' != 'askey' and '${UE_TYPE}' != 'inseego' and '${UE_TYPE}' != 'mtk'
    ...   ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
    ${iperf_dl}    Set variable if   '${UE_TYPE}' == 'inseego' or '${UE_TYPE}' == 'mtk'   ${iperf_dl}
    ...  '${UE_TYPE}' == 'askey'    default
    ...  '${UE_TYPE}' != 'askey' and '${UE_TYPE}' != 'inseego' and '${UE_TYPE}' != 'mtk'  ${tl.ues[${ue_index}].iperf_details.port}
    ${iperf_type_ul}    Set variable if    '${UE_TYPE}' == 'samsung'
    ...    ${iperf_type_ul}    via_app
    Run keyword if    '${data_transfer_direction}'=='both'
    ...        Run keywords     power_ue.Start traffic    ue_type=${UE_TYPE}    direction=ul   throughput=${ul_tput}    duration=${duration}
    ...        dt_name=dt_ul    iperf_port=${iperf_ul}    ue_alias=${ue_alias}    buffer_size=${buffer_size}    window=${window}
    ...        iperf_type=${iperf_type_ul}     protocol=${protocol}    process_num=${process_num_ul}     seg_size=${seg_size}    AND
    ...        sleep    2s      AND
    ...        power_ue.Start traffic    ue_type=${UE_TYPE}    direction=dl   throughput=${dl_tput}    duration=${duration}
    ...        dt_name=dt_dl    iperf_port=${iperf_dl}    ue_alias=${ue_alias}    buffer_size=${buffer_size}
    ...        protocol=${protocol}    process_num=${process_num_dl}     seg_size=${seg_size}    window=${window}

    ...    ELSE IF  '${data_transfer_direction}'=='dl'
    ...        power_ue.Start traffic    ue_type=${UE_TYPE}    direction=dl   throughput=${dl_tput}    duration=${duration}    dt_name=dt_dl
    ...            iperf_port=${iperf_dl}    ue_alias=${ue_alias}    buffer_size=${buffer_size}     protocol=${protocol}
    ...            process_num=${process_num_dl}     seg_size=${seg_size}    window=${window}
    ...    ELSE IF  '${data_transfer_direction}'=='ul'
    ...        power_ue.Start traffic    ue_type=${UE_TYPE}    direction=ul   throughput=${ul_tput}    duration=${duration}    dt_name=dt_ul
    ...            iperf_port=${iperf_ul}    ue_alias=${ue_alias}    buffer_size=${buffer_size}    window=${window}
    ...            iperf_type=${iperf_type_ul}     protocol=${protocol}     process_num=${process_num_ul}     seg_size=${seg_size}
    ...    ELSE    Should be true    ${False}    msg=Invalid input for data_transfer_direction, supported values are: both, ul, dl


TL256 4UL check
    [Documentation]  Author:Fang ludan
    ...              Description: prepare of TL256 4UL UDP check
    ...              commission 4UL SCF ,change UL TPUT
    [Arguments]  ${swconfig_modify}=${None}
    ...      ${is_pdl_checking_needed}=${False}
    Run keyword if  '${BTS_ID}'=='256'   Preparation with swconfig modification and comissioning
    ...    swconfig_modify=${swconfig_modify}    scf_modify=${MODIFY_TL_NAME}    scf_template_path=${GOLDEN_FULL_SCF_8CC_4UL}
    ...    is_called_in_test_case_level=${True}    is_pdl_checking_needed=${is_pdl_checking_needed}
