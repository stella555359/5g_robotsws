# *** Settings ***
# Resource    ../Resources/5GC000920_Keywords.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# Documentation
# ...   author: Liu Zheng
# ...   contact: zheng.4.liu@nokia_sbell.com
# ...   squad group: SG_04
# ...   Feature 5GC000920_A in 5G19A program
# 
# Force Tags      5G_RRM    6.38352    920
# ...    PY36
# 
# Suite Setup     Run Keywords   robot_common_operations.Common Suite Setup    Suite preparation
# 
# Suite Teardown   Run Keywords   robot_common_operations.Common Suite Teardown   AND   Run Keyword And Ignore Error   Suite env recovery
# 
# Test Timeout         30 min
# 
# *** Variables ***
# &{fault_1868}     faultId=${1868}    alarmId=${7114}    source=NRCELL-1    severity=Critical    # No connection to unit
# &{fault_61524}    faultId=${61524}    source=SMOD_R-1    #faultId:SSH_ENABLED  source:RU1
# &{fault_61652}    faultId=${61652}    source=SMOD_R-1    #faultId:R&D_SERVICE_PORT_ENABLED  source:RU1
# #&{fault_4655}     faultId=${4655}     source=SECADM-1
# &{fault_4655}     faultId=${4655}
# &{fault_4654}     faultId=${4654}     source=SMOD_R-1
# &{fault_4592}     faultId=${4592}     source=SMOD_R-1
# &{fault_61074}     faultId=${61074}     
# &{fault_61649}      faultId=${61649}        source=SMOD_R-1
# &{fault_6450}       faultId=${6450}        source=SMOD_R-1
# @{ALLOWED_FAULT_LIST}    &{fault_61524}    &{fault_61652}      &{fault_4655}    &{fault_4654}
# ...           &{fault_61074}        &{fault_4592}       &{fault_61649}      &{fault_6450}
# ${DL_TIME}          600
# ${DL_LENGTH}        1024B
# ${DL_THROUGHPUT}    600M
# ${DL_EXPECT}        0
# 
# ${TS_LOG_PATH_BASE}       /home/ute/workspace/CIT
# #${TS_CASE_LOG_PATH}    /home/ute
# 
# 
# # *** Test Cases ***
# # [1]5GC000920_BA_140_Message_flow_for_dl_4T4R_SU_MIMO_without_beamforming
# #     [Tags]    CDRT_TRUNK   SBTS00   CRT_21B   CRT_22R3
# #     [Documentation]    author: zheng.4.liu@nokia-sbell.com
# #     [Setup]     Run Keywords   robot_common_operations.Common Case Setup   Case preparation case140
# #     Call case with Commercial UE and record throughput info   ue_type=${UE_TYPE}    duration_time=60   interval_time=10
# #     ...    total_time=200    ul_exp_tput=0    dl_exp_tput=${DL_EXPECT}
# #     ...    ul_throughput=5M    dl_throughput=${DL_THROUGHPUT}    is_need_to_capture_log=${False}
# #     Collect BIP messages and verify dldata_csirssendreq message
# #     [Teardown]    Run Keywords   robot_common_operations.Common Case Teardown   AND
# #     ...    Run keyword and ignore error   Case env recovery for call case
# 
# # [1]5GC000920_BA_131_error_handling_of_beamforming_parameter_misconfiguration
# #     [Tags]    CDRT_TRUNK   SBTS00   CRT_21B   CRT_22R3
# #     [Documentation]    author: zheng.4.liu@nokia-sbell.com
# #     [Setup]    Run Keywords   robot_common_operations.Common Case Setup   Case preparation
# #     Do commission with wrong beamforming configuration and verify
# #     Setup connections for GNB and ENB
# #     ${cprt_log_path_asik}=    Update the beamforming configuration and start CPRT trace
# #     Set test variable    ${cprt_log_path_asik}
# #     Cell should be on air and RU should be online fault 1868 should absent
# #     Stop CPRT trace and verify beamforming type in CPRT itf l2 ps cellSetupReq messages    cprt_log_path=${cprt_log_path_asik}
# #     Unexpect Alarm Should Not Exist    allowed_faults=@{ALLOWED_FAULT_LIST}    file_path=${TS_CASE_LOG_PATH}    connection=${GNB_COAM_ALIAS}
# #     [Teardown]     Run Keywords   robot_common_operations.Common Case Teardown   AND   
# #     ...    Run Keyword And Ignore Error    Case env recovery
# 
# *** Keywords ***
# Suite preparation
#     #COAM Create log directory    is_set_to_test_case_level=${False}
#     ${cur_program}    gnb_classical.Get Program Version Based On Stream Version
#     set suite variable      ${program}    ${cur_program}
#     Set ru product code by program diff Hardware
#     ${UE_TYPE}    ue.translate_power_ue_type_from_testline
#     set suite variable    ${UE_TYPE}
#     ${gnb_sw_version}    Get SW version from gnb
#     Connect to Common Unit Master    alias=${ASIK_MASTER_ALIAS}
#     #${is_asib} = connection_alias_store.If ASIB card used
#     ${is_asib}    If ASIB card used
#     set suite variable      ${asib_flag}     ${is_asib}
#     [Teardown]    Run keyword and ignore error    5GC000920_Keywords.Tear down connections    log_path_alarm=${SUITE_LOG_PATH}
# 
# Suite env recovery
#     Run keyword if    '${SUITE STATUS}' == 'FAIL'    COAM Save snapshot via webUI    download_dir=${SUITE_LOG_PATH}
#     Run keyword and ignore error    5GC000920_Keywords.Tear down connections    log_path_alarm=${SUITE_LOG_PATH}
# 
# Case preparation case140
#     [Arguments]    ${swconfig_modify}=${None}    ${name}=btslog    ${btslog_path}=/opt/btslog/btslog
#     ...    ${log_storage_dir}=/tmp/btslog2    ${host}=${tl.test_pc.default_ssh_connection_details.addr}    ${is_btslog_required}=${True}
#     ...    ${btslog_launcher_path}=/opt/btslog/btslog_launcher
# 
#     COAM Create log directory
#     #${connection}    COAM Wait for gnb ready and cell setup    timeout=${timeout}  retry_interval=${retry_interval}  du_index=${du_index}
#     #...    connection=${connection}    is_need_to_setup_gnb_connection=${is_need_to_setup_gnb_connection}
#     #...    is_x2_check_from_gnb_needed=${is_x2_check_from_enb_needed}
#     run keyword if    ${is_btslog_required}    start btslog capture    name=${name}    btslog_path=${btslog_path}
#     ...    btslog_launcher_path=${btslog_launcher_path}    log_dir=${log_storage_dir}    host=${host}
#     ${scf_params_update}    Combine lists    ${PARAMS_TO_MODIFY_SCF}    ${SCF_MODIFY_VALUE_CASE_140}
#     Preparation with swconfig modification and comissioning    swconfig_modify=${swconfig_modify}
#     ...    scf_modify=${scf_params_update}    is_called_in_test_case_level=${False}
#     ...    is_pdl_checking_needed=${PDL_CHECKING}
#     Wait until cluster is on cell on air status
# 
# Case preparation
#     [Arguments]    ${name}=btslog    ${btslog_path}=/opt/btslog/btslog
#     ...    ${log_storage_dir}=/tmp/btslog2    ${host}=${tl.test_pc.default_ssh_connection_details.addr}    ${is_btslog_required}=${True}
#     ...    ${btslog_launcher_path}=/opt/btslog/btslog_launcher
#     #COAM Create log directory
#     run keyword if    ${is_btslog_required}    start btslog capture    name=${name}    btslog_path=${btslog_path}
#     ...    btslog_launcher_path=${btslog_launcher_path}    log_dir=${log_storage_dir}    host=${host}
#     Connect to gnb coam via ssl
#     Connect to eNB via ssl    connection=${ENB_ALIAS}
#     Connect to Common Unit Master    alias=${ASIK_MASTER_ALIAS}
#     run keyword if    ${asib_flag}==${False}    Connect to Common Unit Slave    alias=${ASIK_SLAVE_ALIAS}
#     ${rus_connect_success}    run keyword and return status  Connect to all rus with allocated IP
#     Should be equal as strings  ${rus_connect_success}    True
#     COAM Wait for gnb ready and cell setup    timeout=10 sec
# 
# Setup connections for GNB and ENB
#     Connect to eNB via ssl    connection=${ENB_ALIAS}
#     Connect to Common Unit Master    alias=${ASIK_MASTER_ALIAS}
#     run keyword if    ${asib_flag}==${False}    Connect to Common Unit Slave    alias=${ASIK_SLAVE_ALIAS}
# 
# Case env recovery
#     [Arguments]    ${name}=btslog    ${is_btslog_required}=${True}
#     #Run keyword if    '${TEST STATUS}' == 'FAIL'    COAM Verify if alarm exists    log_path_alarm=${TS_CASE_LOG_PATH}
#     Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot via webUI
#     run keyword if    ${is_btslog_required}    stop btslog and collect logs    status=${TEST STATUS}    name=${name}
#     ${connection}    set variable if    ${asib_flag}==${False}     ASIK Slave     ASIK Master
#     Run keyword and ignore error    Stop trace capturing    log_prefix=CPRT_131_log    connection_alias=${connection}
#     Run keyword and ignore error    csn.execute         command=rm ${cprt_log_path_asik}    connection=${ASIK_MASTER_ALIAS}
#     Run keyword and ignore error    5GC000920_Keywords.Tear down connections
# 
# Do commission with wrong beamforming configuration and verify
#     ${scf_params_update}    Combine lists    ${PARAMS_TO_MODIFY_SCF}    ${SCF_MODIFY_VALUE_CASE_131}
#     Preparation with swconfig modification and comissioning    swconfig_modify=${None}    scf_modify=${scf_params_update}
#     ...    is_called_in_test_case_level=${True}    is_pdl_checking_needed=${False}
#     Connect to gnb coam via ssl
#     Wait until keyword succeeds    5 min    1 sec    COAM verify ru detail info via rest api    ru_type=${RU_TYPE}
#     ...    ru_product_code=${RU_PRODUCT_CODE}    ru_serial_number=${RU_1_SERIAL_NUM}
#     Run keyword and continue on failure    Wait until keyword succeeds    4 min    2 sec    Check Expect Fault Should Present
#     ...    faultId=${fault_1868['faultId']}    source=${fault_1868['source']}    severity=${fault_1868['severity']}    connection=${GNB_COAM_ALIAS}
#     Run keyword and continue on failure    Cell Should Be Disabled
#     Run keyword and continue on failure    Fault 1868 should always exist for two minutes
#     Run keyword and ignore error    Wait until keyword succeeds    3 min    1 min    Check specific log in snapshot file
# 
# Update the beamforming configuration and start CPRT trace
#     [Arguments]    ${parameters_to_update_via_api}=${MODIFY_BEAMFORMING_PARAMETERS_VIA_API_131}    ${CPRT_log_prefix}=CPRT_131_log
#     #ssh.reset_cache
#     #${local_node_id}    set variable if    ${asib_flag}==${False}     0x2021     0x2011
#     #Connect to gnb coam via ssl    connection=${connection}
#     ${hostname}        ssh.execute        hostname    connection=ASIK Master                   
#     ${local_node_id}         Set Variable If    'fct-4a' in '''${hostname}'''    0x2011    0x1011
#     ssh.reset_cache
#     ${cprt_log_path_asik}=    Start CPRT trace capturing    CPRT_log_prefix=${CPRT_log_prefix}
#     ...    local_node_id=${local_node_id}    retry_time=30
#     ${update_status}=    COAM update several parameters via rest api
#     ...     parameters_to_update_via_api=${parameters_to_update_via_api}    timeout=6 min
#     Should contain    ${update_status}    PASS
#     Wait until cluster is on cell on air status
#     
#     ##${connection}    set variable if    ${asib_flag}==${False}     ASIK Slave     ASIK Master
#     ##${is_feature_1948_enabled}    Is Feature 1948 Enabled    connection_alias=ASIK Master
#     ##${local_node_id}    Set Variable If    ${is_feature_1948_enabled}==${True}    0x1021    ${local_node_id}
#     #${cprt_log_path_asik}=    Start CPRT trace capturing    CPRT_log_prefix=${CPRT_log_prefix}
#     #...    local_node_id=${local_node_id}    retry_time=30
#     [Return]    ${cprt_log_path_asik}
# 
# Cell should be on air and RU should be online fault 1868 should absent
#     Wait until keyword succeeds    10 min    5 sec    COAM Check GNB cell on air    connection=${GNB_COAM_ALIAS}
#     RU Should Be Online    ru_index=${1}    connection=${GNB_COAM_ALIAS}
#     Verify all cells should be onair
#     Wait until keyword succeeds    15 min    5 sec    Cell Should Be Unlocked    cell_idx=${1}    cell_group_idx=${0}
#     Expect fault should absent    faultId=${fault_1868['faultId']}    source=${fault_1868['source']}   connection=${GNB_COAM_ALIAS}
# 
# Fault 1868 should always exist for two minutes
#     :FOR  ${index}    IN RANGE    ${12}
#     \  Run keyword and continue on failure   Check Expect Fault Should Present    faultId=${fault_1868['faultId']}
#         ...    alarmId=${fault_1868['alarmId']}
#         ...    source=${fault_1868['source']}    severity=${fault_1868['severity']}    connection=${GNB_COAM_ALIAS}
#     \  Sleep    10 sec
# 
# Set ru product code by program diff Hardware
#     [Documentation]    author: Wang Yixiang
#     ...    This keyword is used to set ${ru_product_code} of AEQB for different TL based on program info.
#     ${program}    gnb_classical_hangzhou.Get program version based on stream version
#     run keyword if    '${program}'=='23R3'       set suite variable    ${RU_PRODUCT_CODE}    475068A.101
#     run keyword if    '${program}'=='22R3'       set suite variable    ${RU_PRODUCT_CODE}    475246A.X21
#     run keyword if    '${program}'=='master'    set suite variable    ${RU_PRODUCT_CODE}    475068A.101
#     run keyword if    '${program}'=='21B'       set suite variable    ${RU_PRODUCT_CODE}    475246A.102
#     run keyword if    '${program}'=='22R2'       set suite variable    ${RU_PRODUCT_CODE}    475246A.102
# 
# Lock unlock and check cell info
#     [Documentation]    Lock unlock and check cell info
#     ${cprt_log_path_asik}=    Lock and unlock administrativeState parameters on ENB start CPRT trace and wait until cell on air
#     ...    CPRT_log_prefix=CPRT_140
#     Set test variable    ${cprt_log_path_asik}
#     Stop CPRT trace and verify CPRT dlcell setupReq and itf l2 ps cellSetupReq messages    cprt_log_path=${cprt_log_path_asik}
#     ...    dlMimoMode_type=Open_loop
# 
# 
# Check Expect Fault Should Present
#     [Documentation]
#     ...               Description: check expect alarm exist,add severity checkpoint by journey.jin@nokia-sbell.com
#     ...               :param severity<str>: optional,value:Critical,Major,Minor,Warning
#     ...               add checkpoint alarm id and fault id should be mapped by zheng.4.liu@nokia-sbell.com
#     [Arguments]    ${faultId}    ${source}=${None}    ${connection}=GNB_OAM    ${severity}=${None}    ${alarmId}=${None}
#     ${faultId}    Convert To Integer    ${faultId}
#     run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
#     ${has_cbts}    testline_info.has_cloudBts    ${tl}
#     run keyword if    ${has_cbts}
#     ...    Cloud DU connect to gnb coam via ssl    connection=${connection}
#     ...    ELSE    Connect to gnb coam via ssl    connection=${connection}
#     @{alarms}    coam.get_active_alarms    connection=${connection}
#     ${alarm_num}    Get Length    ${alarms}
#     ${present_status}    Set Variable    ${False}
#     FOR  ${alarm}  IN  @{alarms}
#        Exit For Loop If    ${alarm_num}==${0}
#        ${present_status}    Run Keyword And Return Status    Run Keywords
#                   ...                      Dictionary Should Contain Item    ${alarm}    faultId    ${faultId}    AND
#                   ...                      Run Keyword If    '${source}'!='${None}'
#                   ...                      Should Contain     ${alarm['configObjectName']}    ${source}    case_insensitive=True    AND
#                   ...                      Run Keyword If    '${severity}'!='${None}'
#                   ...                      Should Contain     ${alarm['severity']}   ${severity}    case_insensitive=True    AND
#                   ...                      Run Keyword If    '${alarmId}'!='${None}'
#                   ...                      Should Be Equal As Strings    ${alarm['alarmId']}    ${alarmId}
#       Exit For Loop If    ${present_status}
#     END
#     Run Keyword If    ${present_status}==${False}    Fail    faultId ${faultId} reported by source ${source} is not present on gnb.
