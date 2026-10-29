# *** Settings ***
# Resource    ../Resources/5GC000920_Keywords.robot
# Resource    ../../5GC002139/Resources/5GC002139_Keywords.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# Documentation
# ...   author: Wang Yixiang
# ...   contact: yixiang.x.wang@nokia_sbell.com
# ...   squad group: MMW_SG1
# ...   Feature 5GC000920 in 5G19A program
# 
# Force Tags      5G_RRM
# ...    PY36
# 
# Suite Setup     Run Keywords   robot_common_operations.Common Suite Setup    Suite preparation
# 
# Suite Teardown  Run Keywords   robot_common_operations.Common Suite Teardown   AND   Run Keyword And Ignore Error   Suite env recovery
# 
# *** Variables ***
# ${DL_TIME}            600
# ${DL_LENGTH}          1024B
# ${DL_THROUGHPUT}      600M
# ${DL_THROUGHPUT_CASE141}      1500M
# ${DL_TPUT_CASE141}     1130
# ${MCS_EXPECT}         23
# 
# ${TS_LOG_PATH_BASE}       /home/ute/workspace/CIT
# 
# 
# # *** Test Cases ***
# # [1]5GC000920_BA_141_semi_open_loop_rank4_PDSCH_transmission_when_fixed_mcs23_256QAM
# #     [Tags]    CRT_TRUNK   CRT_20B
# #     [Documentation]    author: yixiang.x.wang@nokia-sbell.com
# #     [Setup]    Run Keywords   robot_common_operations.Common Case Setup   AND
# #     ...        Case preparation case141     scf_modify_para=${SCF_MODIFY_VALUE_CASE_141}
# #     #Precondition for bip capture with gnbMirroring scripts
# #     #Bip Capture with gnbMirroring scripts with retry
# #     #Start TTI trace log capturing case
# #     #Connect to Common Unit Master    alias=${ASIK_MASTER_ALIAS}
# #     Call case with Commercial UE and record throughput info   ue_type=${UE_TYPE}    duration_time=300   interval_time=10
# #     ...    total_time=300    ul_exp_tput=0    dl_exp_tput=${DL_TPUT_CASE141}
# #     ...    ul_throughput=5M    dl_throughput=${DL_THROUGHPUT_CASE141}    is_need_to_capture_log=${False}
# #     Connect to Common Unit Master
# #     Connect to All Capacity Unit Master
# #     Connect to eNB via ssl    connection=${ENB_ALIAS}
# #     Connect to Capacity Unit Slave case
# #     #Connect to Capacity Unit Master case
# #     Start TTI trace log capturing case
# #     Sleep    5s
# #     run keyword and continue on failure    TTI_Trace.Stop TTI trace log capturing
# #     Connect to Common Unit Master    alias=${ASIK_MASTER_ALIAS}
# #     #BIP_trace_collector.Precondition For Bip Capture With GnbMirroring Scripts
# #     #BIP_trace_collector.Bip Capture with gnbMirroring scripts with retry
# #     #sleep    10s
# #     #${list_log_path_local}    run keyword and continue on failure    Stop BIP capture on ASIK if needed and download BIP Logs to testPC
# #     &{dict_csv_file_path}    Convert TTI trace log and download combined csv logs to test pc    
# #     Set Suite Variable     ${dict_csv_file_path['DL']}
# #     Run keyword and continue on failure      Check_numOfLayers_single_ue      file_path=${dict_csv_file_path['DL']}
# #     Run keyword and continue on failure      Check_fixed_mcs_single_ue      file_path=${dict_csv_file_path['DL']}
# 
# #     ${dldata_pdcchPrecoding_filter}   set variable    DlData_PdschGrant.mcsTable == 1
# #     #Verify specific tcpdump messages frame number should exist    file_path=${list_log_path_local[0]}
# #     #...    display_filter=${dldata_pdcchPrecoding_filter}    lua_script=${LUA_SCRIPT_PATH}
# 
# #     [Teardown]     Run Keywords   robot_common_operations.Common Case Teardown   AND
# #     ...            Run Keyword And Ignore Error    Case env recovery for call case
# 
# *** Keywords ***
# Suite preparation
#     [Documentation]    author: Wang Yixiang
#     COAM Create log directory    is_set_to_test_case_level=${False}
#     Set ru product code by program diff Hardware
#     ${UE_TYPE}    ue.translate_power_ue_type_from_testline
#     set suite variable    ${UE_TYPE}
#     ${gnb_sw_version}    Get SW version from gnb
#     ${not_asib_flag}    Run keyword and return status    Should not contain     ${gnb_sw_version}    ASIB
#     set suite variable    ${not_asib_flag}    ${false}
#     [Teardown]    Run keyword and ignore error    5GC000920_Keywords.Tear down connections    log_path_alarm=${SUITE_LOG_PATH}
# 
# Suite env recovery
#     [Documentation]    author: Wang Yixiang
#     ...    suite environment recovery
#     Connect to gnb coam via ssl
#     Connect to Common Unit Master    alias=${ASIK_MASTER_ALIAS}
#     swconf.Restore swConfig file on asik and crasign    asik_alias=${ASIK_MASTER_ALIAS}
#     Run keyword if    '${SUITE STATUS}' == 'FAIL'    COAM Save snapshot via webUI    download_dir=${SUITE_LOG_PATH}
#     Run keyword and ignore error    5GC000920_Keywords.Tear down connections    log_path_alarm=${SUITE_LOG_PATH}
# 
# Case preparation case141
#     [Documentation]    author: Wang Yixiang
#     ...    Commission and wait cell onair
#     [Arguments]    ${scf_modify_para}    ${swconfig_modify}=${None}    ${name}=btslog    ${btslog_path}=/opt/btslog/btslog
#     ...    ${log_storage_dir}=/tmp/btslog2    ${host}=${tl.test_pc.default_ssh_connection_details.addr}    ${is_btslog_required}=${True}
#     ...    ${btslog_launcher_path}=/opt/btslog/btslog_launcher
#     COAM Create log directory
#     run keyword if    ${is_btslog_required}    start btslog capture    name=${name}    btslog_path=${btslog_path}
#     ...    btslog_launcher_path=${btslog_launcher_path}    log_dir=${log_storage_dir}    host=${host}
#     ${scf_params_update}    Combine lists    ${PARAMS_TO_MODIFY_SCF}    ${scf_modify_para}
#     Preparation with swconfig modification and comissioning    swconfig_modify=${swconfig_modify}
#     ...    scf_modify=${scf_params_update}    is_called_in_test_case_level=${False}
#     ...    is_pdl_checking_needed=${PDL_CHECKING}
#     Wait until cluster is on cell on air status
#     Connect to gnb coam via ssl
#     Connect to eNB via ssl    connection=${ENB_ALIAS}
#     Connect to Common Unit Master    alias=${ASIK_MASTER_ALIAS}
#     run keyword if    ${not_asib_flag}==${True}    Connect to Common Unit Slave    alias=${ASIK_SLAVE_ALIAS}
#     Connect to Capacity Unit Slave case
#     ${rus_connect_success}    run keyword and return status  Connect to all rus with allocated IP
#     Should be equal as strings  ${rus_connect_success}    True
#     ${EXP_TPUT_PERCENTAGE}    set variable if   '${UE_TYPE}'=='huawei'    0.8    0.95
#     set test variable    ${EXP_TPUT_PERCENTAGE}
# 
# Set ru product code by program diff Hardware
#     [Documentation]    author: Wang Yixiang
#     ...    This keyword is used to set ${ru_product_code} of AEQB for different TL based on program info.
#     ${PROGRAM}    gnb_classical_hangzhou.Get program version based on stream version
#     set suite variable    ${PROGRAM}
#     run keyword if    '${PROGRAM}'=='23R3'       set suite variable    ${RU_PRODUCT_CODE}    475068A.101
#     run keyword if    '${PROGRAM}'=='19B'       set suite variable    ${RU_PRODUCT_CODE}    475068A.101
#     run keyword if    '${PROGRAM}'=='master'    set suite variable    ${RU_PRODUCT_CODE}    475068A.101
# 
# Collect BIP messages and verify 256qam message
#     [Documentation]    Author: Wang Yixiang
#     ...    Verify 256 QAM message
#     [Timeout]    15 min
#     Connect to Common Unit Master    alias=${ASIK_MASTER_ALIAS}
#     Precondition for bip capture with gnbMirroring scripts
#     Bip Capture with gnbMirroring scripts with retry
#     sleep    5 sec
#     ${list_log_path_local}    Stop BIP capture on ASIK if needed and download BIP Logs to testPC
# 
#     #mcsTable (Enum): 1 (l1_common_mcsTable_t.max256QAM)
#     ${dldata_pdcchPrecoding_filter}   set variable    DlData_PdschGrant.mcsTable == 1
#     Verify specific tcpdump messages frame number should exist    file_path=${list_log_path_local[0]}
#     ...    display_filter=${dldata_pdcchPrecoding_filter}    lua_script=${LUA_SCRIPT_PATH}
