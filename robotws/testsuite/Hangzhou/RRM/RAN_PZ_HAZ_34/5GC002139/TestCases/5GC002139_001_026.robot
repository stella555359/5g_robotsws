# *** Settings ***
# Resource    ../Resources/5GC002139_Keywords.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# Documentation
# ...   author: Wang Yixiang
# ...   contact: yixiang.x.wang@nokia_sbell.com
# ...   squad group: MMW_SG1
# ...   Feature 5GC002139_B in 5G19B program
# 
# Force Tags      5G_RRM
# ...    PY36
# 
# Suite Setup     Run Keywords   robot_common_operations.Common Suite Setup    Suite preparation
# 
# Suite Teardown  Run Keywords   robot_common_operations.Common Suite Teardown   AND   Run Keyword And Ignore Error    Suite env recovery
# 
# *** Variables ***
# ${DL_TIME}            600
# ${DL_LENGTH}          1024B
# ${DL_THROUGHPUT}      600M
# ${DL_THROUGHPUT_CASE26}      1500M
# ${DL_TPUT_CASE1}      0
# ${DL_TPUT_CASE26}     1130
# ${MCS_EXPECT}         23
# 
# ${TS_LOG_PATH_BASE}      /home/ute/workspace/CIT
# 
# 
# *** Test Cases ***
# [1]5GC002139_B_001_Message_flow_for_dl_4T4R_SU_MIMO_without_beamforming
#     [Tags]    CDRT_TRUNK   SBTS00    CRT_22R3
#     [Documentation]    author: yixiang.x.wang@nokia-sbell.com
#     [Setup]    Run Keywords   robot_common_operations.Common Case Setup   AND   
#     ...    Case preparation case1    swconfig_modify=${SWCONFIG_MODIFY_CASE1}
#     L3 Call with Commercial UE and record throughput info   ue_type=${UE_TYPE}    duration_time=30   interval_time=10
#     ...    total_time=30    ul_exp_tput=0    dl_exp_tput=${DL_TPUT_CASE1}
#     ...    ul_throughput=5M    dl_throughput=${DL_THROUGHPUT}    is_need_to_capture_log=${False}
#     Collect BIP messages and verify dldata_csirssendreq message
#     [Teardown]    Run Keywords   robot_common_operations.Common Case Teardown   AND   
#     ...    Run keyword and ignore error   Case env recovery for call case
# 
# [1]5GC002139_B_026_Dl_Closed_loop_4x4_rank4_CSI-RS_on PUCCH_PDSCH_transmission_fixed_mcs23
#     [Tags]    CRT_TRUNK    CRT_22R3
#     [Documentation]    author: yixiang.x.wang@nokia-sbell.com
#     [Setup]    Run Keywords   robot_common_operations.Common Case Setup   AND   
#     ...    Case preparation case26     scf_modify_para=${MODIFY_MCS_CASE26}   swconfig_modify=${SWCONFIG_MODIFY_CASE26}
#     Call case with Commercial UE and record throughput info   ue_type=${UE_TYPE}    duration_time=60   interval_time=10
#     ...    total_time=60    ul_exp_tput=0    dl_exp_tput=${DL_TPUT_CASE26}
#     ...    ul_throughput=5M    dl_throughput=${DL_THROUGHPUT_CASE26}    is_need_to_capture_log=${False}
#     Collect BIP messages and verify rdPdcchPrecodingOption4x4 message    PdcchOLPrecodingOption4X4=1
#     Capture logs and verify numOfLayers MCS
# 
#     #Collect BIP messages and verify rdPdcchPrecodingOption4x4 message    PdcchOLPrecodingOption4X4=1
#     [Teardown]     Run Keywords   robot_common_operations.Common Case Teardown   AND   
#     ...    Run Keyword And Ignore Error    Case env recovery
# 
# *** Keywords ***
# Suite preparation
#     COAM Create log directory    is_set_to_test_case_level=${False}
#     Set ru product code by program diff Hardware
#     ${gnb_sw_version}    Get SW version from gnb
#     ${not_asib_flag}    Run keyword and return status    Should not contain     ${gnb_sw_version}    ASIB
#     set suite variable    ${not_asib_flag}
#     [Teardown]    Run keyword and ignore error    5GC000920_Keywords.Tear down connections    log_path_alarm=${SUITE_LOG_PATH}
# 
# Suite env recovery
#     Connect to gnb coam via ssl
#     Connect to Common Unit Master    alias=${ASIK_MASTER_ALIAS}
#     swconf.Restore swConfig file on asik and crasign    asik_alias=${ASIK_MASTER_ALIAS}
#     Run keyword if    '${SUITE STATUS}' == 'FAIL'    COAM Save snapshot via webUI    download_dir=${SUITE_LOG_PATH}
#     Run keyword and ignore error    5GC000920_Keywords.Tear down connections    log_path_alarm=${SUITE_LOG_PATH}
# 
# Case preparation case1
#     [Arguments]    ${swconfig_modify}=${None}    ${name}=btslog    ${btslog_path}=/opt/btslog/btslog
#     ...    ${log_storage_dir}=/tmp/btslog2    ${host}=${tl.test_pc.default_ssh_connection_details.addr}    ${is_btslog_required}=${True}
#     ...    ${btslog_launcher_path}=/opt/btslog/btslog_launcher
#     COAM Create log directory
#     run keyword if    ${is_btslog_required}    start btslog capture    name=${name}    btslog_path=${btslog_path}
#     ...    btslog_launcher_path=${btslog_launcher_path}    log_dir=${log_storage_dir}    host=${host}
#     ${scf_params_update}    Combine lists    ${PARAMS_TO_MODIFY_SCF}    ${SCF_MODIFY_VALUE_COMMON}
#     Preparation with swconfig modification and comissioning    swconfig_modify=${swconfig_modify}
#     ...    scf_modify=${scf_params_update}    is_called_in_test_case_level=${False}
#     ...    is_pdl_checking_needed=${PDL_CHECKING}
#     Wait until cluster is on cell on air status
# 
# Case preparation case26
#     [Arguments]    ${scf_modify_para}    ${swconfig_modify}=${None}    ${name}=btslog    ${btslog_path}=/opt/btslog/btslog
#     ...    ${log_storage_dir}=/tmp/btslog2    ${host}=${tl.test_pc.default_ssh_connection_details.addr}    ${is_btslog_required}=${True}
#     ...    ${btslog_launcher_path}=/opt/btslog/btslog_launcher
#     COAM Create log directory
#     run keyword if    ${is_btslog_required}    start btslog capture    name=${name}    btslog_path=${btslog_path}
#     ...    btslog_launcher_path=${btslog_launcher_path}    log_dir=${log_storage_dir}    host=${host}
#     ${scf_params_update}    Combine lists    ${PARAMS_TO_MODIFY_SCF}    ${SCF_MODIFY_VALUE_COMMON}    ${scf_modify_para}
#     Preparation with swconfig modification and comissioning    swconfig_modify=${swconfig_modify}
#     ...    scf_modify=${scf_params_update}    is_called_in_test_case_level=${False}
#     ...    is_pdl_checking_needed=${PDL_CHECKING}
#     Wait until cluster is on cell on air status
#     ${EXP_TPUT_PERCENTAGE}    set variable if   '${UE_TYPE}'=='huawei'    0.8    0.95
#     set test variable    ${EXP_TPUT_PERCENTAGE}
# 
# Case env recovery
#     [Arguments]    ${ue_type}=${UE_TYPE}    ${name}=btslog    ${is_btslog_required}=${True}
#     Run keyword if     '${ue_type}' == 'huawei'    wait until keyword succeeds    1 min    10 sec    Connect to EPC APP
#     Run Keyword And Ignore Error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl
#     ...                        dt_name=dt_dl    iperf_port=${tl.ues[0].iperf_details.port}
#     Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}
#     Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot via webUI
#     run keyword if    ${is_btslog_required}    stop btslog and collect logs    status=${TEST STATUS}    name=${name}
#     Run keyword and ignore error    csn.execute         command=rm ${cprt_log_path_asik}    connection=${ASIK_MASTER_ALIAS}
#     Run keyword and ignore error    5GC000920_Keywords.Tear down connections
# 
# Case env recovery for call case
#     [Arguments]    ${name}=btslog    ${is_btslog_required}=${True}
#     Run keyword if     '${ue_type}' == 'huawei'    wait until keyword succeeds    1 min    10 sec    Connect to EPC APP
#     Run Keyword And Ignore Error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl
#     ...                        dt_name=dt_dl    iperf_port=${tl.ues[0].iperf_details.port}
#     Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}
#     Run keyword if    '${TEST STATUS}' == 'FAIL'    Run keyword and continue on failure    COAM Save snapshot via webUI
#     run keyword if    ${is_btslog_required}    stop btslog and collect logs    status=${TEST STATUS}    name=${name}
#     ${connection}    set variable if    ${not_asib_flag}==${True}     ASIK Slave     ASIK Master
#     Run keyword and ignore error    Stop trace capturing    log_prefix==CPRT_001    connection_alias=${connection}
#     Run keyword and ignore error    csn.execute         command=rm ${cprt_log_path_asik}    connection=${ASIK_MASTER_ALIAS}
#     Run keyword and ignore error    5GC000920_Keywords.Tear down connections
# 
# Collect BIP messages and verify dldata_csirssendreq message
#     [Timeout]    15 min
#     Connect to Common Unit Master    alias=${ASIK_MASTER_ALIAS}
#     Precondition for bip capture with gnbMirroring scripts
#     Bip Capture with gnbMirroring scripts with retry
#     sleep    5 sec
#     ${list_log_path_local}    Stop BIP capture on ASIK if needed and download BIP Logs to testPC
#     ${dldata_CsiRsSendReq_filter}=    Catenate    DlData_CsiRsResource_t.csiRsConfig == 0x04
#     ...                                           and DlData_CsiRsResource_t.antennaStream == 0x0f
#     ${dldata_pdcchPrecoding_filter}   set variable    DlData_DciInfo.pdcchPrecodingOption4x4 == 0x00
#     Verify specific tcpdump messages frame number should exist    file_path=${list_log_path_local[0]}
#     ...    display_filter=${dldata_CsiRsSendReq_filter}    lua_script=${LUA_SCRIPT_PATH}
#     Verify specific tcpdump messages frame number should exist    file_path=${list_log_path_local[0]}
#     ...    display_filter=${dldata_pdcchPrecoding_filter}    lua_script=${LUA_SCRIPT_PATH}
# 
# Set ru product code by program diff Hardware
#     [Documentation]    author: Wang Yixiang
#     ...    This keyword is used to set ${ru_product_code} of AEQB for different TL based on program info.
#     ${PROGRAM}    gnb_classical_hangzhou.Get program version based on stream version
#     set suite variable    ${PROGRAM}
#     run keyword if    '${PROGRAM}'=='22R3'       set suite variable    ${RU_PRODUCT_CODE}    475246A.X21
#     run keyword if    '${PROGRAM}'=='19B'       set suite variable    ${RU_PRODUCT_CODE}    475068A.101
#     run keyword if    '${PROGRAM}'=='master'    set suite variable    ${RU_PRODUCT_CODE}    475068A.101
#     ${UE_TYPE}    ue.translate_power_ue_type_from_testline
#     set suite variable    ${UE_TYPE}
# 
# Lock unlock and check cell info
#     [Documentation]    Lock unlock and check cell info
#     ${cprt_log_path_asik}=    Lock and unlock administrativeState parameters on ENB start CPRT trace and wait until cell on air
#     ...    CPRT_log_prefix=CPRT_001
#     Set test variable    ${cprt_log_path_asik}
#     Stop CPRT trace and verify CPRT dlcell setupReq and itf l2 ps cellSetupReq messages    cprt_log_path=${cprt_log_path_asik}
#     ...    dlMimoMode_type=Close_loop
