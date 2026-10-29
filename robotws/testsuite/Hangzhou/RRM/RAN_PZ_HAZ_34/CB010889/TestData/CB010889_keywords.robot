*** Settings ***
Documentation    This is for feature CB008247 related common keywords.
...              Please do not modify the file without notification to author
...              Author:lei.jia@nokia-sbell.com
...              Squard: HZ SG6

Variables   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/CA/TestData.py
Variables   testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB009235/Resources/TestCaseVariables.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/Resources.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008360/Resources/CB008360_keywords.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/counter_check.robot
Library    taf.config.scf    WITH NAME    scf

*** Variables ***
${MRBTS_ID}    ${tl.gnbs[0].instance_id}
${NRBTS_ID}    ${tl.gnbs[0].global_bts_id}
&{fault_6450}    faultId=${6450}
&{fault_10}    faultId=${10}
&{fault_1901}    faultId=${1901}
&{fault_23}    faultId=${23}
&{fault_4681}    faultId=${4681}
&{fault_16}    faultId=${16}
&{fault_4298}    faultId=${4298}
&{fault_4547}    faultId=${4547}
&{fault_7312}    faultId=${7312}
@{FAULT_ID_LIST}   &{fault_6450}    &{fault_4681}
@{HISTORY_FAULT_ID_LIST}    &{fault_10}    &{fault_1901}    &{fault_23}
@{ALLOWED_HISTORY_FAULT_IN_UTE}    &{fault_23}

*** Keywords ***
10889 Suite Setup
    [Documentation]    Author:xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${connection}=GNB_OAM
    robot_common_operations.Common Suite Setup
    run keyword and ignore error    clear vm pid before run case
    Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version    connection=${connection}
    set suite variable      ${Active_SW_version}
    ${stream}    get stream from version    ${Active_SW_version}
    Set Suite Variable     ${stream}
#    ${Golden_SCF_Path}    Get Golden SCF Path
#    set suite variable      ${Golden_SCF_Path}
    Get SCF File Path
    ${Golden_SCF_Path}    Join Path    ${scf_full_path}    SCF_${stream}_3S-1CC.xml
    Set Suite Variable    ${Golden_SCF_Path}
    Generate suite log path
    set suite variable      ${SAVE LOG DIRECTORY}    ${SUITE_LOG_PATH}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ${gNb_CuType}   Get gNB CU type    connection=${connection}
    set suite variable      ${gNb_CuType}
    ${mrbtsID}    ${nrbtsID}   Get mrbtsID and nrbtsID via SCF for gNB    scf_path=${Golden_SCF_Path}
    log to console  MRBTS_ID:${mrbtsID}, NRBTS_ID:${nrbtsID}


Suite TearDown For 10889
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    robot_common_operations.Common Suite Teardown
    ${scf_file_name}    Set Variable If    '${stream}'=='SBTS25R1'    SCF_${stream}_3S-1CC    SCF_${stream}
    Recommission With Backup SCF File And Wait Gnb On Air    scf_file_name=${scf_file_name}
    Run Keyword And Ignore Error    COAM Teardown gnb connections

10889 Case SetUp
    [Documentation]   Author:xiaoxia.hao@nokia-sbell.com
    ...                 for 8360-A NSA call, keep all NR cell barred
    [Arguments]    ${scf_file_name}
    robot_common_operations.Common Case Setup
    Wait Until Keyword Succeeds    5 min    5 sec    connection_alias_store.Connect to Common Unit Master
    Connect to Capacity Unit Master
    Connect to Capacity Unit Slave
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    COAM Create log directory
    Recommission With Backup SCF File And Wait Gnb On Air    scf_file_name=${scf_file_name}


##    Get Ue Type for UES    ues_index=${ues_index}
##    Generate Pcell Mapping Info    pcell_index=${pcell_index}
#    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
#    Change status for parameter cellBarred on GNB    exp_status=notBarred   list_cell_ids=${pcell_index}    timeout=${180}

10889 Case TearDown
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${case_contain_special_operation}=${False}    ${is_recover_env}=${False}    ${is_recover_swconfig}=${False}    ${timeout}=900
    ...            ${connection}=GNB_OAM    ${is_x2_check_from_gnb_needed}=${True}    ${ASIK_MASTER_ALIAS}=ASIK Master
    robot_common_operations.Common Case Teardown
    run keyword and ignore error    COAM Teardown gnb connections
    run keyword and ignore error    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl
    Connect to Common Unit Master    alias=${ASIK_MASTER_ALIAS}
    @{ALLOWED_FAULT}    Combine Lists    ${ALLOWED_FAULT}    ${FAULT_ID_LIST}
    ${active_alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    Run Keyword And Ignore Error    Unexpect History Alarm Should Not Exist    allowed_faults=${ALLOWED_HISTORY_FAULT}
    run keyword if    not ${active_alarm_status} and not ${case_contain_special_operation}
    ...               Run Keyword And Ignore Error    COAM Save snapshot via rest api    connection=${connection}    timeout=${timeout}
    run keyword if    ${is_recover_env}    run keywords
    ...               run keyword if    ${is_recover_swconfig}    swconf.restore_swConfig_file_on_asik_and_crasign    asik_alias=ASIK Master    AND
    ...               COAM Commission with scf file    scf_file_path=${Golden_SCF_Path}    timeout=600    AND
    ...               COAM Wait For Gnb Ready And Cell Setup    timeout=25 min    is_x2_check_from_gnb_needed=${is_x2_check_from_gnb_needed}    AND
    ...               Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    Run Keyword And Ignore Error   csn.disconnect    connection=ABIL Loner
    Run Keyword And Ignore Error   csn.disconnect    connection=RU
    Run Keyword And Ignore Error   csn.disconnect    connection=ABIL Slave
    Run Keyword And Ignore Error   csn.disconnect    connection=ABIL Master
    Run Keyword And Ignore Error   csn.disconnect    connection=ASIK Master
    run keyword and ignore error   COAM Teardown gnb connections
    Run Keyword And Ignore Error    run    command=ps -ef | grep firefox |awk '{print $2}' | xargs kill -9
    run keyword if    not ${case_contain_special_operation}    CI_interface.Common Case Teardown


Recommission With Backup SCF File And Wait Gnb On Air
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${scf_file_name}    ${is_pdl_checking_needed}=${False}    ${asik_alais}=ASIK Master    ${is_x2_check_from_gnb_needed}=${False}
    Get SCF File Path
#    Get gNB Stream Version
#    ${scf_file_full_name}    set variable    ${scf_file_name}_${stream}.xml
    ${scf_file_full_name}    set variable    ${scf_file_name}.xml
    ${scf_file}    Join Path    ${scf_full_path}    ${scf_file_full_name}
    Wait Until Keyword Succeeds    3 min    5 sec    Connect To Gnb Coam Via SSL
    Connect to Common Unit Master    alias=${asik_alais}
    Recommission With Backup SCF File    backup_scf_file=${scf_file}
    ...                                                   is_pdl_checking_needed=${is_pdl_checking_needed}
    COAM Wait For Gnb Ready And Cell Setup    timeout=25 min    is_x2_check_from_gnb_needed=${is_x2_check_from_gnb_needed}
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair
    Set Suite Variable    ${old_scf_file_name}    ${scf_file_name}
    [Teardown]  run keyword and ignore error   COAM Teardown gnb connections

Recommission With Backup SCF File
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${backup_scf_file}    ${is_pdl_checking_needed}=${True}    ${timeout}=900    ${connection}=GNB_OAM
    ${status}    Run Keyword And Return Status     COAM Commission with scf file
    ...                                            scf_file_path=${backup_scf_file}
    ...                                            timeout=${timeout}
    ...                                            connection=${connection}
    ...                                            is_pdl_checking_needed=${is_pdl_checking_needed}
    Run Keyword If  ${status}==${False}    Fail    recovery with backup scf file failed.

Check Mustatus And NumberofCorrCalcDuringSelectUes on TTI
    [Arguments]    ${cell_index}=3
    ...            ${gnb_logs_script_path}=/home/ute/gnb_logs
    ...            ${gnb_index}=0
    ...            ${du_index}=0
    ...            ${target_dir}=${TS_CASE_LOG_PATH}
    ...            ${remove_files_needed}=${True}
    Log To Console    \nCapture TTI with gnb logs
    ${ttitrace_dl_file}    Get Specific TTItrace File    target_dir=${target_dir}
    ...                                                             cell_index=${cell_index}
    ...                                                             gnb_logs_script_path=${gnb_logs_script_path}
    ...                                                             direction=dl
    ...                                                             gnb_index=${gnb_index}    du_index=${du_index}
    ...                                                             remove_files_needed=${remove_files_needed}
    ${mupair}    ${numberOfCorrCalcDuringSelectUes_percent}    calculate_dl_muStatus_and_dl_numberOfCorrCalcDuringSelectUes
    ...                                                                                                       file_path=${ttitrace_dl_file[0]}
    run keyword and continue on failure    Should Be True    ${mupair}>0
    run keyword and continue on failure    Should Be True    ${numberOfCorrCalcDuringSelectUes_percent}<1

Check Mustatus Contain NOPAIR_LITTLEDATANOTNEEDPAIR on TTI
    [Arguments]    ${cell_index}=3
    ...            ${gnb_logs_script_path}=/home/ute/gnb_logs
    ...            ${gnb_index}=0
    ...            ${du_index}=0
    ...            ${target_dir}=${TS_CASE_LOG_PATH}
    ...            ${remove_files_needed}=${True}
    Log To Console    \nCapture TTI with gnb logs
    ${ttitrace_dl_file}    Get Specific TTItrace File    target_dir=${target_dir}
    ...                                                             cell_index=${cell_index}
    ...                                                             gnb_logs_script_path=${gnb_logs_script_path}
    ...                                                             direction=dl
    ...                                                             gnb_index=${gnb_index}    du_index=${du_index}
    ...                                                             remove_files_needed=${remove_files_needed}
    ${no_pair_littledatanotneedpair}    calculate_dl_muStatus_no_pair_littledatanotneedpair_Counter    file_path=${ttitrace_dl_file[0]}
    run keyword and continue on failure    Should Be True    ${no_pair_littledatanotneedpair}>0

Check Mustatus Not Contain NOPAIR_LITTLEDATANOTNEEDPAIR And Contain MUPAIR on TTI
    [Arguments]    ${cell_index}=3
    ...            ${gnb_logs_script_path}=/home/ute/gnb_logs
    ...            ${gnb_index}=0
    ...            ${du_index}=0
    ...            ${target_dir}=${TS_CASE_LOG_PATH}
    ...            ${remove_files_needed}=${True}
    Log To Console    \nCapture TTI with gnb logs
    ${ttitrace_dl_file}    Get Specific TTItrace File    target_dir=${target_dir}
    ...                                                             cell_index=${cell_index}
    ...                                                             gnb_logs_script_path=${gnb_logs_script_path}
    ...                                                             direction=dl
    ...                                                             gnb_index=${gnb_index}    du_index=${du_index}
    ...                                                             remove_files_needed=${remove_files_needed}
    ${no_pair_littledatanotneedpair}    calculate_dl_muStatus_no_pair_littledatanotneedpair_Counter    file_path=${ttitrace_dl_file[0]}
    run keyword and continue on failure    Should Be True    ${no_pair_littledatanotneedpair}<1
    ${mupair}    ${muStatus_value_count}    calculate_dl_muStatus_mupair_Counter    file_path=${ttitrace_dl_file[0]}
    run keyword and continue on failure    Should Be True    ${mupair}>1

Set MCS Phase And ATT For CA
    ${mcs_type}    mcs_common.Get MCS Type    mcs_index=${1}
    Set Test Variable    ${mcs_type}
    mcs_common.Setup MCS    mcs_type=${mcs_type}    frequency=${None}    mcs_index=${1}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${1}   first_beam_end_output_port=${2}
    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}
    ...    first_beam_horizontal_angle=${-35}    second_beam_horizontal_angle=${-50}    vertical_angle=${-6}
    ...    vertical_distance=${2}    end_input_port=${16}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=5
    ...    first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}    end_input_port=${32}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${5}   first_beam_end_output_port=${6}
    ...    second_beam_begin_output_port=${7}    second_beam_end_output_port=${8}
    ...    first_beam_horizontal_angle=${35}    second_beam_horizontal_angle=${50}    vertical_angle=${-6}
    ...    vertical_distance=${2}    end_input_port=${16}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=25
    ...    first_beam_begin_output_port=${5}    second_beam_end_output_port=${8}    end_input_port=${32}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${9}   first_beam_end_output_port=${10}
    ...    second_beam_begin_output_port=${11}    second_beam_end_output_port=${12}
    ...    first_beam_horizontal_angle=${-7}    second_beam_horizontal_angle=${-15}    vertical_angle=${-6}
    ...    vertical_distance=${2}    end_input_port=${16}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=23
    ...    first_beam_begin_output_port=${9}    second_beam_end_output_port=${12}    end_input_port=${32}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${13}   first_beam_end_output_port=${14}
    ...    second_beam_begin_output_port=${15}    second_beam_end_output_port=${16}
    ...    first_beam_horizontal_angle=${7}    second_beam_horizontal_angle=${22}    vertical_angle=${-6}
    ...    vertical_distance=${2}    end_input_port=${16}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=22
    ...    first_beam_begin_output_port=${13}    second_beam_end_output_port=${16}    end_input_port=${32}

Set MCS Phase And ATT For CA For Branch
    ${mcs_type}    mcs_common.Get MCS Type    mcs_index=${1}
    Set Test Variable    ${mcs_type}
    mcs_common.Setup MCS    mcs_type=${mcs_type}    frequency=${None}    mcs_index=${1}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${1}   first_beam_end_output_port=${2}
    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}
    ...    first_beam_horizontal_angle=${-30}    second_beam_horizontal_angle=${-45}    vertical_angle=${-6}
    ...    vertical_distance=${2}    end_input_port=${16}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=20
    ...    first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}    end_input_port=${32}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${5}   first_beam_end_output_port=${6}
    ...    second_beam_begin_output_port=${7}    second_beam_end_output_port=${8}
    ...    first_beam_horizontal_angle=${35}    second_beam_horizontal_angle=${50}    vertical_angle=${-6}
    ...    vertical_distance=${2}    end_input_port=${16}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=25
    ...    first_beam_begin_output_port=${5}    second_beam_end_output_port=${8}    end_input_port=${32}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${9}   first_beam_end_output_port=${10}
    ...    second_beam_begin_output_port=${11}    second_beam_end_output_port=${12}
    ...    first_beam_horizontal_angle=${-7}    second_beam_horizontal_angle=${-22}    vertical_angle=${-6}
    ...    vertical_distance=${2}    end_input_port=${16}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=25
    ...    first_beam_begin_output_port=${9}    second_beam_end_output_port=${12}    end_input_port=${32}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${13}   first_beam_end_output_port=${14}
    ...    second_beam_begin_output_port=${15}    second_beam_end_output_port=${16}
    ...    first_beam_horizontal_angle=${7}    second_beam_horizontal_angle=${22}    vertical_angle=${-6}
    ...    vertical_distance=${2}    end_input_port=${16}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=25
    ...    first_beam_begin_output_port=${13}    second_beam_end_output_port=${16}    end_input_port=${32}

Check UL MUMO Tput And DL CA With Power UE
    [Arguments]    ${expect_ul_tput}=${None}
    ...            ${expect_dl_tput_pcell}=${None}
    ...            ${expect_dl_tput_scell}=${None}
    ...            ${duration}=300
    ...            ${pcell_id}=1
    ...            ${scell_id}=2
    ...            ${connection}=GNB_OAM
    ...            ${gnb_index}=0
    ...            ${du_index}=0
    ...            ${ignore_time}=1min
    ...            ${target_avg_percent}=0.95
    ...            ${min_percent}=0.85
    ...            ${actCarrierAggregation}=${False}
    ...            ${all_cell_ids}=${False}
    ...            ${check_source}=spark
    ...            ${ue_type}=${ue_type}
    ${pcell_nrcell_ids}    Get NRCELLID based on CELLID    cellid=${pcell_id}    connection=${connection}    list_all_cell_ids=${all_cell_ids}
    ${scell_nrcell_ids}    Get NRCELLID based on CELLID    cellid=${scell_id}    connection=${connection}    list_all_cell_ids=${all_cell_ids}
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    gnb_index=${gnb_index}
    ...    du_index=${du_index}    duration=${duration}    ignore_time=${ignore_time}    check_source=${check_source}
    Run Keyword And Continue On Failure    Power_ue.Check Tput    ue_type=${ue_type}    direction=UL
    ...                                                           log=${tput_log}    cells=${pcell_nrcell_ids}
    ...                                                           target_throughput=${expect_ul_tput}
    ...                                                           target_avg_percent=${target_avg_percent}
    ...                                                           actCarrierAggregation=${actCarrierAggregation}
    ...                                                           check_source=${check_source}
    ...                                                           min_percent=${min_percent}
    Run Keyword And Continue On Failure    Power_ue.Check Tput    ue_type=${ue_type}    direction=UL
    ...                                                           log=${tput_log}    cells=${scell_nrcell_ids}
    ...                                                           target_throughput=${expect_ul_tput}
    ...                                                           target_avg_percent=${target_avg_percent}
    ...                                                           actCarrierAggregation=${actCarrierAggregation}
    ...                                                           check_source=${check_source}
    ...                                                           min_percent=${min_percent}
    Run Keyword And Continue On Failure    Power_ue.Check Tput    ue_type=${ue_type}    direction=DL
    ...                                                           log=${tput_log}    cells=${pcell_nrcell_ids}
    ...                                                           target_throughput=${expect_dl_tput_pcell}
    ...                                                           target_avg_percent=${target_avg_percent}
    ...                                                           actCarrierAggregation=${actCarrierAggregation}
    ...                                                           check_source=${check_source}
    ...                                                           min_percent=${min_percent}
    Run Keyword And Continue On Failure    Power_ue.Check Tput    ue_type=${ue_type}    direction=DL
    ...                                                           log=${tput_log}    cells=${scell_nrcell_ids}
    ...                                                           target_throughput=${expect_dl_tput_scell}
    ...                                                           target_avg_percent=${target_avg_percent}
    ...                                                           actCarrierAggregation=${actCarrierAggregation}
    ...                                                           check_source=${check_source}
    ...                                                           min_percent=${min_percent}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections

Lock Cell
    [Arguments]    ${cell_id}=1    ${connection}=GNB_OAM
    Connect to gnb coam via ssl
    Log To Console    Cell ${cell_id} Locked
    perform_cell_lock_via_admin    cell_id=${cell_id}    connection=${connection}    lock_timeout=300
    sleep    60s    #wait for cell locked

Unlock Cell
    [Arguments]    ${cell_id}=1    ${connection}=GNB_OAM
    Log To Console    Cell ${cell_id} Unlocked
    Connect to gnb coam via ssl
    perform_cell_unlock_via_admin    cell_id=${cell_id}    connection=${connection}    lock_timeout=300
    sleep    60s    #wait for cell unlocked

Check UE1 and UE2 Pair on Cell1 And UE3 and UE4 Pair on Cell2 on TTI
    [Arguments]    ${collector_names}=l2stream3_ttitrace    ${duration}=2
    ...            ${eth_port_on_ute}=eth0    ${log_dir}=${TS_CASE_LOG_PATH}/ttitrace_streaming
    Log To Console    \nCapture TTI with gnb
    Start Ttitrace With Streaming Mode    collector_names=${collector_names}    eth_port_on_ute=${eth_port_on_ute}
    Sleep    ${duration}s    reason=Wait for logs
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${file_path}    Stop Ttitrace    collector_names=${collector_names}    log_dir=${log_dir}/ttitrace_streaming_${timestamp}
    ${ttitrace_ul_file}    Decode Ttitrace Logs    file_path=${file_path}    direction=ul
    ${ttitrace_dl_file}    Decode Ttitrace Logs    file_path=${file_path}    direction=dl
    Run Keyword And Continue On Failure    Check UE Paried Status Via TTITrace    ttitrace_filt_path=${ttitrace_ul_file}
    Run Keyword And Continue On Failure    Evaluate Single UE Average Tput For UL With TTI    file_path=${ttitrace_ul_file}
    ...                                                expect_tput_value=105
    ${mupair}    ${muStatus_value_count}    calculate_dl_muStatus_mupair_Counter    file_path=${ttitrace_dl_file}
    run keyword and continue on failure    Should Be True    ${mupair}>1
