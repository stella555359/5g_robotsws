*** Settings ***
Documentation
...   author: Liu Zheng
...   contact: zheng.4.liu@nokia-sbell.com
...   squad group: SG_04
...   Feature 5GC001596_D 5GC001596_F 5GC001726 5GC000561

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC001596_D/Resources/merge_case_to_one_kw.robot
Resource     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001726/Resources/merge_case_to_one_kw.robot
Resource     ./1596_1726_561_Variables.robot
Library      testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC000561/Resources/get_time_relative.py
Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC000561/Resources/5GC000561_coam_keyword.robot
Variables    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC000561/5GC000561_ZA/Resources/variables.py
Resource     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB007459/Resources/CB007459_keywords.robot
#2033
Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC002033/Resources/5GC002033_Variables.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/common_resources.robot
Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC001596_F/Resources/5GC001596_F_Keywords.robot
Resource     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC001596_D/Resources/5GC001596_D_Keywords.robot
Resource     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB007459/Resources/CB007459_keywords.robot
Resource     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB007077_A/Resources/7077_keywords.robot

*** Variables ***
# tl name variables
${testline_name}      null
${CONFIGURATION}      ${None}

*** Keywords ***
Suite preparation
    [Documentation]    Author: Liu Zheng
    ...    This keyword will modify swconfig file(default is not to modify swconfig) and commission gnb and verify
    ...    gnb cell on air status.
    ...    ${CONFIGURATION} is the variable that imported robot command by -v .
    [Timeout]    1h
    ${SCF_PATH}     Get Substring    ${CURDIR}  0  -92
    ${TL_NAME}   set variable if      '${testline_name}' == 'null'    ${CONFIGURATION}    ${testline_name}
    ${pattern}   Set Variable    7_5(.*)
    ${TLNAME}    Get Regexp Matches     ${TL_NAME}    ${pattern}    1
    ${testlinename}   Set Variable    7_5${TLNAME}[0]
    ${CONFIGURATION}    Get Variable Value    ${CONFIGURATION}
    set suite variable     ${CONFIGURATION}
    set suite variable     ${SCF_PATH}
    set suite variable     ${testlinename}
    Connect to Common Unit Master    alias=ASIK Master
    run keyword if    '${CONFIGURATION}' != '${None}' and '${CONFIGURATION}' != 'null'
    ...    Create default directory for ute cloud and commission
    ...    ELSE    Create default directory for lightweight ci
    Do prepare UE return status
    import variables    commissionings/HGZ/${testlinename}/TLDelta.py
    import library      scf_process.SCFProcess    WITH NAME    scfpro
    Import NIDD variables

    Set variables for UTE cloud

Do prepare UE return status
    [Documentation]    Author: Liu Zheng
    ${PREPARE_UE_STATUS}    run keyword and return status   Get UE type and prepare UE
    set suite variable     ${PREPARE_UE_STATUS}
    [Return]    ${PREPARE_UE_STATUS}

Get UE type and prepare UE
    [Documentation]    Author: Liu Zheng
    ${UE_TYPE}     ue.translate_power_ue_type_from_testline
    set suite variable     ${UE_TYPE}
    power_ue.Prepare UE    ue_type=${UE_TYPE}    ui_version=S21UI3.1

Create default directory for ute cloud and commission
    [Documentation]    Author: Liu Zheng
    ...    Description: default dir scf and swconfig and log dir for ute cloud.
    ...    scf used by commission /home/ute/Auto5G/commissionings/HGZ/7_5_UTE5G402T043/SCF_0.800.xml
    log    output dir is ${OUTPUT DIR}
    ${cur_dir}    run    pwd
#    set suite variable     ${TS_LOG_PATH_BASE}       ${cur_dir}/../test_results
    coam create log directory      is_set_to_test_case_level=${False}
#    set suite variable     ${TS_LOG_PATH_BASE}       ${cur_dir}/../test_results
    set suite variable     ${GOLDEN_FULL_SCF_8CC}    ${SCF_PATH}/commissionings/HGZ/${testlinename}/SCF_0.800_8cc.xml
    set suite variable     ${GOLDEN_FULL_SCF_4CC}    ${SCF_PATH}/commissionings/HGZ/${testlinename}/SCF_0.800_4cc.xml
    set suite variable     ${ENB_SCF_DEFAULT_FILE_PATH}    ${SCF_PATH}/commissionings/HGZ/${testlinename}/SCF_0.800_ENB.xml
    set suite variable     ${SWCONFIG_DEFAULT_FILE_PATH}    ${SCF_PATH}/commissionings/HGZ/${testlinename}/swconfig.txt
    set suite variable     ${luashark_path}        /opt/luashark/luashark.lua
#    coam create log directory      is_set_to_test_case_level=${False}
    CI_interface.Common Suite Setup

Create default directory for lightweight ci
    [Documentation]    Author: Liu Zheng
    ...     Description: default dir scf and swconfig for lightweight ci.
    set suite variable     ${SCF_DEFAULT_FILE_PATH}          /opt/ute/scf/SCF_MMW1_TL${tl.gnbs[0].instance_id}_4cc.xml
    set suite variable     ${ENB_SCF_DEFAULT_FILE_PATH}    /opt/ute/scf/SCF_MMW1_TL${tl.gnbs[0].instance_id}_ENB.xml
    set suite variable     ${SWCONFIG_DEFAULT_FILE_PATH}    /opt/ute/swconfig/swconfig_MMW1_TL${tl.gnbs[0].instance_id}.txt
    coam create log directory      is_set_to_test_case_level=${False}
    Suite common setup preparation    is_pdl_checking_needed=${True}      enb_default_scf_file=${ENB_SCF_DEFAULT_FILE_PATH}

Suite env recovery
    [Documentation]    author: Liu Zheng
    [Timeout]    10 min
    Connect to gnb coam via ssl
    Connect to Common Unit Master    alias=${ASIK_ALIAS}
    Run keyword and continue on failure      swconf.Restore swConfig file on asik and crasign    asik_alias=${ASIK_ALIAS}
    Run keyword if    '${SUITE STATUS}' == 'FAIL'    COAM Save snapshot via webUI    download_dir=${SUITE_LOG_PATH}
    Tear down all SISO connections

Case preparation
    [Documentation]    Author: Liu Zheng
    ...                makesure the log_dir have the correct user name and user group.
    ...                e.g. sudo chown -R ute:ute /tmp
    [Arguments]    ${act_xcc_cell_number}=${8}    ${scf_template_path}=${GOLDEN_FULL_SCF_8CC}    ${scf_process_needed}=${False}
    ...    ${list_para_to_modify}=${None}   ${list_para_to_add}=${None}    ${list_para_to_delete}=${None}
    ...    ${is_set_to_test_case_level}=${False}   ${is_alias_created}=${False}
    ...    ${is_log_required}=${True}    ${is_l3_call_case}=${False}
    ...    ${name}=btslog    ${btslog_path}=/opt/btslog/btslog    ${btslog_launcher_path}=/opt/btslog/btslog_launcher
    ...    ${log_storage_dir}=/tmp/btslog2    ${host}=${tl.test_pc.default_ssh_connection_details.addr}
    ...    ${if_create_ru_alias_needed}=${False}
    coam create log directory
    Get the ru index list and cell index list and cell group index list and set to suite variable
    Connect to gnb coam via ssl
    &{pre_env_xcc_config}    coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids
    ${pre_env_xcc_config}    get length    ${pre_env_xcc_config}
    run keyword if    ${act_xcc_cell_number}!=${pre_env_xcc_config} or ${scf_process_needed}    process SCF for test case and do commission
    ...    scf_template_path=${GOLDEN_FULL_SCF_8CC}
    ...    is_set_to_test_case_level=${is_set_to_test_case_level}    list_para_to_delete=${list_para_to_delete}
    ...    list_para_to_modify=${TL_PARAMS_TO_MODIFY_8CC_CA}
    ...    list_para_to_add=${TL_PARAMS_TO_ADD_8CC_CA}
    run keyword if    '${CONFIGURATION}' != '${None}' and '${CONFIGURATION}' != 'null'     Recovery ru if sw corrupted
    Wait until cluster is on cell on air status    timeout=${RECOVERY_TIMEOUT}     is_all_cells_checking_needed=${True}
    &{NR_CELL_ID_MAPPING}    coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids
    Set test variable    ${NR_CELL_ID_MAPPING}
    run keyword if    ${is_log_required}     _capture log in case setup
    ...    name=${name}    btslog_path=${btslog_path}
    ...    btslog_launcher_path=${btslog_launcher_path}
    ...    log_storage_dir=${log_storage_dir}    host=${host}
    run keyword if    ${is_alias_created}    _create alias in case setup    if_create_ru_alias_needed=${if_create_ru_alias_needed}
    ${lncelid_enb}    run keyword if    '${is_l3_call_case}' == '${True}'    Get lncelid on enb
    run keyword if    '${is_l3_call_case}' == '${True}'    Set test variable    ${LNCELID}    ${lncelid_enb}
    run keyword if    '${is_l3_call_case}' == '${True}'
    ...    Get the ENB actDynTrigLteNrDualConnectivity and defaultLnRelGnbCellId and set them to test variable
    run keyword if    '${is_l3_call_case}' == '${True}'    run keyword and ignore error    Stop data transfer based on direction
    run keyword if    '${is_l3_call_case}' == '${True}' and '${PREPARE_UE_STATUS}'==${False}    Do prepare UE return status

process SCF for test case and do commission
    [Documentation]    normally ${PARAMS_TO_MODIFY_SCF} is [ ] which defined in None_Feature_MMW1/lib/default_testline_scf.py
    [Arguments]    ${scf_template_path}    ${list_para_to_modify}=${None}   ${list_para_to_add}=${None}
    ...    ${is_set_to_test_case_level}=${False}    ${list_para_to_delete}=${None}
    ${scf_process_folder}    set variable if    ${is_set_to_test_case_level}    ${SUITE_LOG_PATH}    ${TS_LOG_PATH_BASE}
    ${tl_scf_process_path}    scfpro.SCFProcess
    ...    scf_template_path=${scf_template_path}
    ...    scf_process_folder=${scf_process_folder}
    ...    list_para_to_delete=${list_para_to_delete}
    ...    list_para_to_modify=${list_para_to_modify}
    ...    list_para_to_add=${list_para_to_add}
    set suite variable    ${tl_scf_process_path}
    Preparation with swconfig modification and comissioning    swconfig_modify=${None}    scf_modify=${PARAMS_TO_MODIFY_SCF}
    ...    is_called_in_test_case_level=${True}    is_pdl_checking_needed=${False}
    ...    scf_template_path=${tl_scf_process_path}

Case env recovery
    [Documentation]    Author: Liu Zheng
    [Arguments]    ${operation}=${None}    ${para_update_timeout}=${TIMEOUT_MODIFY_PARA}
    ...    ${is_l3_call_case}=${False}
    ...    ${is_log_required}=${True}
    ...    ${detach_ue}=${False}
    ...    ${is_onair_check}=${False}
    ...    ${onair_timeout}=${DEFAULT_ONAIR_TIMEOUT}
    ...    ${is_close_connection}=${False}
    ...    ${is_revert_defaultlnrelgnbcellid_needed}=${False}
    ...    ${is_revert_CA_parameters_needed}=${False}
    [Timeout]    15 min
    Common case teardown    is_log_required=${is_log_required}
    ...    detach_ue=${is_l3_call_case}
    ...    is_onair_check=${is_log_required}
    ...    is_close_connection=${is_close_connection}
    Run keyword if    '${is_revert_defaultlnrelgnbcellid_needed}' == '${True}'
    ...    Recover the ENB actDynTrigLteNrDualConnectivity and defaultLnRelGnbCellId back to default
    Connect to gnb coam via ssl
    Recovery env if case failed with operations    operation=${operation}    ru_index=${1}    cell_index=${1}    cell_group_index=${0}
    Run keyword if    '${is_revert_CA_parameters_needed}' == '${True}'
    ...    COAM Update several parameters via rest api    parameters_to_update_via_api=${MODIFY_VIA_API_FOR_DEFAULT_8CC_BTS_PARAMETERS}
    Run keyword and ignore error    Tear down all SISO connections

PTP_syncE_message_should_be_provide_on_ABIL_ecpri_port_S-RF1
    COAM Wait for gnb ready and cell setup and sync status
    Capture Wireshark Log for a While from RU    filename=${RU_log_02}    time=${case_02_timer}    filter=${PTP_SyncE_filter}
    Check Message Rate of sync announce synce messages
    Check SourcePortIdentity from mac address EUI_48 to EUI_64    filename=${RU_log_02}

GA_142_GNB-8CCDL_2CCUL_maxScell7DL1UL_non_contiguous_freq_IWK_5GC000772_DRX_enable_SRB3
    Update parameters which will cause bts restart via api    parameters_to_update_via_api=${PARA_TO_MODIFY_VIA_API_GA_142}
    Attach to pcells and do verification for configured IE
    ...    cell_index_for_attach=${1}    log_prefix=1726_GA142    verification_type=drx_config

D_016_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    Call case with QCOM UE and record throughput info for many cells many times    para_update_timeout=${TIMEOUT_MODIFY_PARA}
    ...    repeat_times=${TEST_REPEAT_TIMES}     verify_duration=${VERIFY_DURATION}
    ...    ul_exp_tput=${UL_EXPECT}    dl_exp_tput=${DL_EXPECT}
    Connect to Common Unit Master    alias=ASIK Master
    @{RUS_ALIAS}    Connect to all rus with allocated IP
    Set suite variable    ${RUS_ALIAS}
    Verify RFSW Log Include In Snapshot    ru_alias=RU_1    is_get_snapshot_via_selenium=${True}

GE_502_GNB-8CCDL_2CCUL_maxScell7DL1UL_non-contiguous_UE8DL2UL_1UE_LowThroughput_HighThroughput_LowThroughput
    Switch pcell for attach based on cell index    cell_index_for_attach=${1}
    Connect to gnb coam via ssl
    Wait until keyword succeeds    2X    10 s    Power ue attach
    run keyword and continue on failure
    ...    Start data transfer with high or low throughput and verify behaviours    dl_tput_iperf=20M    expected_dl_tput=${19}
    Sleep    2s
    run keyword and continue on failure
    ...    Start data transfer with high or low throughput and verify behaviours    dl_tput_iperf=20M    expected_dl_tput=${200}
    Sleep    2s
    run keyword and continue on failure
    ...    Start data transfer with high or low throughput and verify behaviours    dl_tput_iperf=20M    expected_dl_tput=${19}

F_018_cell_addtion_deletion_on_WebUI
    ${cell_info_8}    Get Cell Parameters    cell_id=8
    ${cell_info_7}    Get Cell Parameters    cell_id=7
    Remove Cell From Configuration    cell_id=8    cell_group_id=0
    Remove Cell From Configuration    cell_id=7    cell_group_id=0
    Cell number should be as expected    expect_cell_number=${6}
    Verify all cells should be onair
    Call case with QCOM UE and record throughput info for many cells many times
    ...   para_update_timeout=${TIMEOUT_MODIFY_PARA}    repeat_times=${TEST_REPEAT_TIMES}
    ...   verify_duration=${VERIFY_DURATION}    ul_exp_tput=${UL_EXPECT}    dl_exp_tput=${DL_EXPECT}
    Add New Cell Based On Existing Cell To Configuration    cell_parameters=${cell_info_7}     cell_id_to_copy_from=${6}
    ...    nrcell_include_subobject=${True}    activate_plan_despite_errors=${True}
    Add New Cell Based On Existing Cell To Configuration    cell_parameters=${cell_info_8}     cell_id_to_copy_from=${6}
    ...    nrcell_include_subobject=${True}    activate_plan_despite_errors=${True}
    Cell number should be as expected    expect_cell_number=${8}
    Verify all cells should be onair
    Call case with QCOM UE and record throughput info for many cells many times
    ...    para_update_timeout=${TIMEOUT_MODIFY_PARA}   verify_duration=${VERIFY_DURATION}
    ...    repeat_times=${TEST_REPEAT_TIMES}     ul_exp_tput=${UL_EXPECT}    dl_exp_tput=${DL_EXPECT}

Proactive_UL_scheduling_for_a_selected_UE_performing_ping_request
    Start X2 log capture from gNB
    Retry commercial ue attach if failed    ue_type=${UE_TYPE}     prepare_ue_needed=${False}
    Connect to Common Unit Master    alias=ASIK Master
    ${x2_log_path}     Stop X2 log capture from gNB
    Check specific UE configuration take effect    tcpdump_log=${x2_log_path}
    Perform UL ping and check latency


Check Message Rate of sync announce synce messages
    Check Message Rate case    filename=${tmp_log_dir}/${loner_log_02}    filter=${sync_message}     min_rate=15.9    max_rate=16.1
    Check Message Rate case    filename=${tmp_log_dir}/${loner_log_02}    filter=${announce_message}     min_rate=7.9    max_rate=8.1
    Check Message Rate case    filename=${tmp_log_dir}/${loner_log_02}    filter=${syncE_message}     min_rate=0.9    max_rate=1.1

Check Message Rate case
    [Arguments]    ${filename}    ${filter}    ${min_rate}    ${max_rate}
    ${ptp_command}     set variable   {tshark_path} -r {pcap_file} -Y \"${filter}\" -T pdml
    ${filtered_packets}    Load pcap with filter    pcap_file=${filename}    filter_expression=${filter}
    ...    command_template=${ptp_command}
    ${pdml_logpath}    Get pdml log    tcpdump_log=${filename}
    @{msg}    get_time_relative_item    tcpdump_pdml=${pdml_logpath}
    ${cnt}=    Get Length     ${msg}
    ${time}=    Evaluate    ${msg[-1]}-${msg[0]}
    ${rate}=    Evaluate        (${cnt}-1)/${time}
    Should Be True     ${min_rate} < ${rate} < ${max_rate}

Get pdml logpath
    [Documentation]   author: Wang Yixiang
    ...    convert pcap to pdml with filter
    [Arguments]    ${tcpdump_log}
    ${tcpdump_path}    ${tcpdump_file}    Split Path     ${tcpdump_log}
    @{log_file}   List Files In Directory    path=${tcpdump_path}    pattern=*.pdml
    ${list_len}    get length    ${log_file}
    ${full_log_path}    set variable    ${tcpdump_path}${/}${log_file}[0]
    [Return]    ${full_log_path}

Check SourcePortIdentity from mac address EUI_48 to EUI_64
    [Arguments]    ${filename}
    Connect to Common Unit Master
    ${EUI_64}    csn.execute
    ...          command=ifconfig ethlmp0|grep ether|awk '{print$2}'|sed -e 's/://g' -e 's/....../0x&fffe/'|xargs echo -n
    ...          connection=${asik}
    Connect to gnb coam via ssl
    ${eCpriMasterClockIdentity}    Get SCF single Value from current xml file
    ...    parameter=eCpriMasterClockIdentity    alias=GNB_OAM    config_type=configurationAndRuntimeObjects
    ...    dist_name=MRBTS-${tl.gnbs[0].instance_id}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/ECPRIMASTERSTATUS_R-1
#    ${eCpriMasterClockIdentity}    Coam Get Parameter via webUI    dist_name=&{PARAM_561_002[0]}[dist_name]
#    ...                            filter_param=&{PARAM_561_002[0]}[filter_param]    p_name=&{PARAM_561_002[0]}[p_name]
    #${eCpriMasterClockIdentity}    Convert To Integer    ${eCpriMasterClockIdentity}
    #${EUI_64_INT}    Convert To Integer    ${EUI_64}
    ${eCpriMasterClockIdentity}    remove string    ${eCpriMasterClockIdentity}    :
    should be equal    first=0x${eCpriMasterClockIdentity}    second=${EUI_64}    ignore_case=True

    ${ptp_command}   set variable   {tshark_path} -r {pcap_file} -Y \"${sourceportid}==19 and ${clockidentity}==${EUI_64}\" -T pdml
    ${filtered_packets}    Load pcap with filter    pcap_file=${tmp_log_dir}/${filename}
    ...    filter_expression=${sourceportid}==19 and ${clockidentity}==${EUI_64}    command_template=${ptp_command}
    ${items}   pcap.get_field_value_by_name    field_name=ptp.v2.clockidentity    attribute_name=show
    should not be empty     item=${items}     msg=check clockidentity exist failed!

case prepare for 561
    Connect to gnb coam via ssl
    ${CONFIGURATION}    Get Variable Value    ${CONFIGURATION}
    run keyword if    '${CONFIGURATION}' != '${None}'    Prepare for ute cloud
    COAM Create log directory
    Set suite variable    ${tmp_log_dir}    ${LOG_PATH}

case teardown
    COAM Teardown gnb connections
    Common case teardown    is_log_required=${False}

Prepare for ute cloud
    ${SCF_PATH}     Get Substring    ${CURDIR}  0  -47
    ${pattern}   Set Variable    7_5(.*)
    ${TLNAME}    Get Regexp Matches     ${CONFIGURATION}    ${pattern}    1
    ${testlinename}   Set Variable    7_5${TLNAME}[0]
    set suite variable     ${TS_LOG_PATH_BASE}    /home/ute
    set suite variable     ${GOLDEN_FULL_SCF}    ${SCF_PATH}/commissionings/HGZ/${testlinename}/SCF_0.800.xml
    COAM Commission with scf file  scf_file_path=${GOLDEN_FULL_SCF}    timeout=600    is_pdl_checking_needed=${False}
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair

Start to Capture Wireshark Log with filter trunk
    [Arguments]    ${listen_port}     ${log_dir}     ${filename}    ${filter}    ${connection}
    csn.send command    command=ip netns exec radions tcpdump -n -i ${listen_port} -w ${log_dir}/${filename} ${filter} &>/dev/null &
    ...    connection=${connection}
    sleep    3s

Start to Capture Wireshark Log from Loner trunk
    [Arguments]    ${filename}    ${filter}=none    ${conn}=${abil1_loner}
    Connect to Capacity Unit Loner case
    Run Keyword If    ${filter} is None    Start to Capture Wireshark Log    listen_port=arb0p3     log_dir=${gnb_tmp_log_dir}
    ...                                           filename=${filename}    connection=${conn}
    ...               ELSE    Start to Capture Wireshark Log with filter trunk    listen_port=arb0p3     log_dir=${gnb_tmp_log_dir}
    ...                                           filename=${filename}    filter=${filter}    connection=${conn}

Capture Wireshark Log for a While from Loner trunk
    [Arguments]    ${filename}    ${time}    ${filter}=${None}
    Start to Capture Wireshark Log from Loner trunk    filename=${filename}    filter=${filter}
    sleep    ${time}
    Stop and Download Logs from Loner     ${filename}

common case teardown with 2033
    [Documentation]    author: Fang Ludan
    [Timeout]    20 min
    [Arguments]  ${operation}
    run Keyword and ignore Error    Make SgNBAddition on specific cell
    ...     gnb_ps_cell_index=${1}     alias=enblte
    Run Keyword And Ignore Error    Recovery env for many sectors if case failed with operations    operation=${operation}
    run Keyword and ignore Error    Common case teardown   is_log_required=${False}

#2033 *** keywords ***
A_010_General_SiSo_RU_block_unblock_config_4cc_2dl_2ul_ASIK
    Perform ru lock unlock and check throughput for many ru many times    ru_index_list=${RU_1}
    ...    para_update_timeout=${TIMEOUT_MODIFY_PARA}    duration_time=${DURATION_TIME}    verify_duration=${VERIFY_DURATION}
    ...    ul_exp_tput=${UL_EXPECT}    dl_exp_tput=${DL_EXPECT}    repeat_times=${TEST_REPEAT_TIMES}    connection=GNB_OAM

B_002_General_SiSo_Cell_lock_and_unlock_with_4Cell_2dl_2ul_and_4cell_2dl_0ul
    Perform cell lock unlock and check throughput for many cells many times    cell_index_list=${GNB_PS_CELL_INDEX_LIST}
    ...    repeat_times=${TEST_REPEAT_TIMES}    verify_duration=${VERIFY_DURATION}

B_008_General_SiSo_RU_block_unblock_with_4cc_2dl_2ul_4cc_2dl_0ul
        Perform ru lock unlock and check throughput for many ru many times    ru_index_list=${RU_1}
    ...    para_update_timeout=${TIMEOUT_MODIFY_PARA}    duration_time=${DURATION_TIME}    verify_duration=${VERIFY_DURATION}
    ...    ul_exp_tput=${UL_EXPECT}    dl_exp_tput=${DL_EXPECT}    repeat_times=${TEST_REPEAT_TIMES}    connection=GNB_OAM


B_018_cell_addtion_deletion_on_WebUI_with_4cc_2dl_2ul_4cc_2dl_0ul
    ${cell_info_8}    gnb_cell.Get Cell Parameters    cell_id=8
    ${cell_info_7}    gnb_cell.Get Cell Parameters    cell_id=7
    Remove Cell From Configuration    cell_id=8    cell_group_id=0
    Remove Cell From Configuration    cell_id=7    cell_group_id=0
    Cell number should be as expected    expect_cell_number=${6}
    Verify all cells should be onair
    Call case with QCOM UE and record throughput info for many cells many times
    ...   para_update_timeout=${TIMEOUT_MODIFY_PARA}    repeat_times=${TEST_REPEAT_TIMES}
    ...   verify_duration=${VERIFY_DURATION}    ul_exp_tput=${UL_EXPECT}    dl_exp_tput=${DL_EXPECT}
    Add New Cell Based On Existing Cell To Configuration    cell_parameters=${cell_info_7}     cell_id_to_copy_from=${6}
    ...    nrcell_include_subobject=${True}    activate_plan_despite_errors=${True}
    Add New Cell Based On Existing Cell To Configuration    cell_parameters=${cell_info_8}     cell_id_to_copy_from=${6}
    ...    nrcell_include_subobject=${True}    activate_plan_despite_errors=${True}
    Cell number should be as expected    expect_cell_number=${8}
    Verify all cells should be onair
    Call case with QCOM UE and record throughput info for many cells many times
    ...    para_update_timeout=${TIMEOUT_MODIFY_PARA}   verify_duration=${VERIFY_DURATION}
    ...    repeat_times=${TEST_REPEAT_TIMES}     ul_exp_tput=${UL_EXPECT}    dl_exp_tput=${DL_EXPECT}


A_012_cell_addtion_deletion_on_WebUI_config_4cc_2dl_2ul_ASIK
    ${cell_info_4}    gnb_cell.Get Cell Parameters    cell_id=4
    ${cell_info_3}    gnb_cell.Get Cell Parameters    cell_id=3
    Remove Cell From Configuration    cell_id=4    cell_group_id=0
    Remove Cell From Configuration    cell_id=3    cell_group_id=0
    Cell number should be as expected    expect_cell_number=${2}
    Verify all cells should be onair
    Call case with QCOM UE and record throughput info for many cells many times
    ...   para_update_timeout=${TIMEOUT_MODIFY_PARA}    repeat_times=${TEST_REPEAT_TIMES}  cell_index_list=${CELL_INDEX_DELET}
    ...   verify_duration=${VERIFY_DURATION}    ul_exp_tput=${UL_EXPECT}    dl_exp_tput=${DL_EXPECT}
    Add New Cell Based On Existing Cell To Configuration    cell_parameters=${cell_info_3}     cell_id_to_copy_from=${2}
    ...    nrcell_include_subobject=${True}    activate_plan_despite_errors=${True}
    Add New Cell Based On Existing Cell To Configuration    cell_parameters=${cell_info_4}     cell_id_to_copy_from=${2}
    ...    nrcell_include_subobject=${True}    activate_plan_despite_errors=${True}
    Cell number should be as expected    expect_cell_number=${4}
    Verify all cells should be onair
    Call case with QCOM UE and record throughput info for many cells many times
    ...    para_update_timeout=${TIMEOUT_MODIFY_PARA}   verify_duration=${VERIFY_DURATION}  cell_index_list=${GNB_PS_CELL_INDEX_LIST}
    ...    repeat_times=${TEST_REPEAT_TIMES}     ul_exp_tput=${UL_EXPECT}    dl_exp_tput=${DL_EXPECT}

Cell_Service_Status_Indication_In_Service_SA_mode
    BTS reset and capture cellsetup log     is_all_cells_checking_needed=${True}
    clean threads before do UE attach    ue_type=${UE_TYPE2}   ue_index=${1}   clean_threads_needed=${True}
    Retry commercial ue attach if failed    prepare_ue_needed=${False}
    ...    ue_type=${UE_TYPE2}    ue_index=${1}    retry_time=${2}    4G_check=${False}

deactivatedOrDisabled_to_be_activeAndEnabled_mixedModeByrecoverySctpX2ThenNG
    Connect to Common Unit Master
     Connect to gnb coam via ssl
     COAM Update several parameters via rest api   parameters_to_update_via_api=${CELL_BAR_TIMER_VIA_API}    timeout=6 min
     Drop ng link
     Wait until keyword succeeds    6min    2sec   Expect Fault Should Present     faultId=7304
     wait until keyword succeeds    6min    2sec   Cell should be barred
     Connect to gnb coam via ssl
     ${STATUS1}    run keyword and return status      Retry commercial ue attach if failed    prepare_ue_needed=${False}
     ...    ue_type=${UE_TYPE}    ue_index=${0}    retry_time=${2}    detach_request=${False}
     run keyword and continue on failure    should be true    ${STATUS1}    msg=NSA attach should succeed, but fails.
     run keyword and ignore error    power_ue.UE Detach    ue_index=${0}    ue_type=${UE_TYPE}
     Connect to Common Unit Master
     Recover ng link
     Wait until keyword succeeds    5min    2sec    Expect Fault Should Absent    faultId=7304
     wait until keyword succeeds    3min    2sec    Cell should be unbarred
     sleep    2min
     Connect to gnb coam via ssl
     Retry commercial ue attach if failed    prepare_ue_needed=${False}
     ...    ue_type=${UE_TYPE2}    ue_index=${1}    retry_time=${2}    4G_check=${False}
     power_ue.Start traffic    ue_index=${1}    direction=ul    throughput=35M    duration=900    ue_type=${UE_TYPE2}
     ...   process_num=${1}    iperf_type=via_command
     sleep    1s
     power_ue.Start traffic    ue_index=${1}    direction=dl    throughput=35M    duration=900    ue_type=${UE_TYPE2}
     ...   process_num=${1}
