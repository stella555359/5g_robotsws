# *** Settings ***
# #Suite Setup     Suite preparation
# #Suite Teardown
# 
# Suite Setup     Run keywords    Suite preparation    AND    robot_common_operations.Common Suite Setup
# Suite Teardown  robot_common_operations.Common Suite Teardown
# 
# Documentation    Suite description
# 
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# Resource          ../5GC000523_samsung/Resources/5GC000523_common_keyword.robot
# Resource          ./Resources/CB007608_A_523_common_keywords.robot
# Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/TTI_Trace_Analysis_MMW4.py
# Resource          ../5GC001937_Classical/Resources/5GC001937_classical_keywords.robot
# Resource          ../5GC001937_OTA/resources/5GC001937_mmw4_common_keyword.robot
# Library           taf.transport.ssh    WITH NAME    csn
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Library           ./Resources/CB007608_common.py
# 
# *** Variables ***
# ${LUA_SCRIPT_PATH}      /home/ute/Downloads/lua/generated_luashark/luashark.lua
# ${TS_CASE_LOG_PATH}    ${output_dir}
# ${UL_DL_csv_file_path_dict}    ${TS_CASE_LOG_PATH}    ${output_dir}
# ${ul_throughput}    200M
# ${dl_throughput}    200M
# ${duration}         ${600}
# ${ul_tput_udp}          100M
# ${dl_tput_udp}          200M
# ${dl_tput_udp_05}          800M
# ${ul_tput_tcp}          30M
# ${dl_tput_tcp}          100M
# ${log_time}             30S
# ${exp_ul}               ${160}
# ${exp_dl}               ${3600}
# ${deviation}            10%
# ${total_count}          ${10}
# ${ue_number}            ${4}
# ${exp_txnum}            ${18}
# ${exp_crc}              ${98}
# ${EXP_ACK}              ${0.85}
# ${UL_tp_exp}            ${10}
# ${DL_tp_exp}            ${100}
# ${UL_bler}              ${10}
# ${DL_bler}              ${10}
# ${total_count}          ${10}
# ${ue_number_05}            ${2}
# ${except_rrmDlUsedMcs_txnum}    0.2
# ${except_rrmDlUsedMcs_cqi}      0.2
# ${exp_num_sinrDerivedMcs}       0.1
# ${exp_num_numOfPrb}             0.1
# ${exp_rrmDlUsedMcs_false}       0.2
# 
# *** Test Cases ***
# [1]CB007608-5G-A-1854+523-005_E_PRB_and_MCS_Reduction_2UE_UL_Abf
#     [Tags]    CB007608    CRT_22R1    CRT_22R2
#     ${versiontitle}    Get Version
#     set suite variable    ${versiontitle}
#     Run keyword if    '${versiontitle}'=='SBTS22R1' or '${versiontitle}'=='SBTS22R2'
#     ...    Change the configure ca_22R1_22R2
#     ...    ELSE
#     ...    Change the configure ca_trunk_22R3_22R4
#     UE attach by Spark    ue_num=${ue_number_05}
#     sleep    1s
#     CB007608_A_523_common_keywords.start tti trace
#     sleep    3s
#     Stop TTI trace log capturing
#     sleep    3s
#     ${UL_DL_csv_file_path_dict}    Convert TTI trace log and download combined csv logs to test pc
#     ...    local_path=${TS_CASE_LOG_PATH}    is_need_to_close_connection=${False}    connection_for_abil=${None}
#     ...    connection_for_asik=${None}
#     ${Ul_path}    get from dictionary    ${UL_DL_csv_file_path_dict}    UL
#     ${Dl_path}    get from dictionary    ${UL_DL_csv_file_path_dict}    DL
#     ${Ul_path}    replace_csv_content    file_path=${Ul_path}
#     ${Dl_path}    replace_csv_content    file_path=${Dl_path}
#     ${except_rrmDlUsedMcs_false}    run keyword and continue on failure    check_rrmDlUsedMcs_equal_rrmDlProposedMcs_19B
#     ...    file_path=${Dl_path}    equal_flag=${False}
#      run keyword and continue on failure    should be true    ${except_rrmDlUsedMcs_false}<${exp_rrmDlUsedMcs_false}
#     ${exp_num_numOfPrb_false}    run keyword and continue on failure    get_FdSchedData_numofprb_19B
#     ...    file_path=${Ul_path}    direction=UL    except_value=${66}    equal_flag=${False}
#     run keyword and continue on failure    should be true    ${exp_num_numOfPrb_false}<${exp_num_numOfPrb}
#     Start data traffic and Record TP Log and Aasys Log
#     ...    ue_num=${ue_number_05}    ul_throughput=${ul_tput_udp}    dl_throughput=${dl_tput_udp_05}
#     ...    ul_duration=${duration}    dl_duration=${duration}
#     ...    protocol=udp    if_ul=${True}    if_dl=${True}    file_name=Asys_ul_dl_udp.txt    time=${log_time}
#     sleep    3s
#     CB007608_A_523_common_keywords.start tti trace
#     sleep    1s
#     Stop TTI trace log capturing
#     sleep    3s
#     ${UL_DL_csv_file_path_dict1}    Convert TTI trace log and download combined csv logs to test pc
#     ...     local_path=${TS_CASE_LOG_PATH}
#     ...    is_need_to_close_connection=${False}    connection_for_abil=${None}   connection_for_asik=${None}
#     Stop data traffic and Stop Record TP Log and Aasys Log    ue_num=${ue_number_05}    if_ul=${True}    if_dl=${True}
#     ...    protocol=udp    spark_log_name=spark_ul_dl_udp
#     ${Ul_path1}    get from dictionary    ${UL_DL_csv_file_path_dict1}    UL
#     ${Dl_path1}    get from dictionary    ${UL_DL_csv_file_path_dict1}    DL
#     ${except_rrmDlUsedMcs_txnum_true}    ${except_rrmDlUsedMcs_cqi_true}    run keyword and continue on failure
#     ...    check_rrmDlUsedMcs_equal_rrmDlProposedMcs_19B    file_path=${Dl_path1}    equal_flag=${True}
#      run keyword and continue on failure    should be true
#      ...    ${except_rrmDlUsedMcs_txnum_true}<${except_rrmDlUsedMcs_txnum}
#      run keyword and continue on failure    should be true    ${except_rrmDlUsedMcs_cqi_true}<${except_rrmDlUsedMcs_cqi}
#     ${exp_num_sinrDerivedMcs_true}    run keyword and continue on failure    get_FdSchedData_numofprb_19B
#     ...    file_path=${Ul_path1}    direction=UL    except_value=${66}    equal_flag=${True}
#     run keyword and continue on failure    should be true    ${exp_num_sinrDerivedMcs_true}<${exp_num_sinrDerivedMcs}
#     ${total_result_list}    Get Each UE TP From Spark    ue_num=${ue_number_05}    spark_log_name=spark_ul_dl_udp
#     ...    list_length=${total_count}
#     ${total_result_dict}    set variable    @{total_result_list}[-1]
#     run keyword and continue on failure    check TP and bler    total_result_list=${total_result_dict}
#     [Teardown]    run keyword and continue on failure    523 case teardown    ue_number=${ue_number_05}
# 
# [1]CB007608-5G-A-1854+523-003_AB_Multi_UE_ULDL_data_schedulling_4UEs_mmWaves
#     [Tags]    CB007608    CRT_22R1    CRT_22R2
#     ${versiontitle}    Get Version
#     set suite variable    ${versiontitle}
#     Run keyword if    '${versiontitle}'=='SBTS22R1' or '${versiontitle}'=='SBTS22R2'
#     ...    Change the configure_22R1_22R2
#     ...    ELSE
#     ...    Change the configure_trunk_22R3_22R4
# #   Run keyword if    '${versiontitle}'=='SBTS22R1'
# #   ...    Change the configure_22R1
# #   ...    ELSE IF    '${versiontitle}'=='SBTS22R3'
# #   ...    Change the configure_22R3
# #   ...    ELSE IF    '${versiontitle}'=='SBTS22R4'
# #   ...    Change the configure_trunk
# #   ...    ELSE
# #   ...    Change the configure_22R2
#     UE attach by Spark    ue_num=${ue_number}
#     Start data traffic and Record TP Log and Aasys Log
#     ...    ue_num=${ue_number}    ul_throughput=${ul_tput_udp}    dl_throughput=${dl_tput_udp}    ul_duration=${duration}
#     ...    dl_duration=${duration}    protocol=udp    if_ul=${True}    if_dl=${True}    file_name=Asys_ul_dl_udp.txt
#     ...    time=${log_time}
#     CB007608_A_523_common_keywords.start tti trace
#     sleep    5s
#     Stop TTI trace log capturing
#     sleep    5s
#     ${UL_DL_csv_file_path_dict}    Convert TTI trace log and download combined csv logs to test pc
#     ...    local_path=${TS_CASE_LOG_PATH}    is_need_to_close_connection=${False}    connection_for_abil=${None}
#     ...    connection_for_asik=${None}
#     Stop data traffic and Stop Record TP Log and Aasys Log    ue_num=${ue_number}    if_ul=${True}    if_dl=${True}
#     ...    protocol=udp    spark_log_name=spark_ul_dl_udp
#     run keyword and continue on failure    check 4UE tti trace    UL_DL_csv_file_path_dict=${UL_DL_csv_file_path_dict}
#     ...    direction=UL    ue_number=${ue_number}
#     run keyword and continue on failure    check 4UE tti trace    UL_DL_csv_file_path_dict=${UL_DL_csv_file_path_dict}
#     ...    direction=DL    ue_number=${ue_number}
#     ${Dl_path}    get from dictionary    ${UL_DL_csv_file_path_dict}    DL
#     ${Ul_path}    get from dictionary    ${UL_DL_csv_file_path_dict}    UL
#     ${crc}    get_ulHarqRxData_crcResult_19b    file_path=${Ul_path}
#     ...    crcResult=OK
#     should be true    ${crc}>${exp_crc}
#     ${ack}    get_dlHarqRxDataArray_rnti_ackNack_19B    file_path=${Dl_path}
#     run keyword and continue on failure    check ACK    ack=${ack}
#     ${total_result_list}    Get Each UE TP From Spark    ue_num=${ue_number}    spark_log_name=spark_ul_dl_udp
#     ...    list_length=${total_count}
#     ${total_result_dict}    set variable    @{total_result_list}[-1]
#     run keyword and continue on failure    check TP and bler    total_result_list=${total_result_dict}
#     [Teardown]    run keyword and continue on failure    523 case teardown    ue_number=${ue_number}
# 
# [1]CB007608-5G-A-1854+523-004_AB_Multi_UE_ULDL_Proactive_Scheduling_mmWaves
#     [Tags]    CB007608    CRT_22R1    CRT_TRUNK
#     ${versiontitle}    Get Version
#     set suite variable    ${versiontitle}
#     Run keyword if    '${versiontitle}'=='SBTS22R1' or '${versiontitle}'=='SBTS22R2'
#     ...    Change the configure ca_22R1_22R2
#     ...    ELSE
#     ...    Change the configure ca_trunk_22R3_22R4
# #   Run keyword if    '${versiontitle}'=='SBTS22R1'
# #   ...    Change the configure ca_22R1
# #   ...    ELSE IF    '${versiontitle}'=='SBTS22R3'
# #   ...    Change the configure ca_22R3
# #   ...    ELSE IF    '${versiontitle}'=='SBTS22R4'
# #   ...    Change the configure ca_trunk
# #   ...    ELSE
# #   ...    Change the configure ca_22R2
#     UE attach by Spark    ue_num=${ue_number}
#     CB007608_A_523_common_keywords.start tti trace
#     sleep    5s
#     Stop TTI trace log capturing
#     ${UL_DL_csv_file_path_dict}    Convert TTI trace log and download combined csv logs to test pc
#     ...    local_path=${TS_CASE_LOG_PATH}    is_need_to_close_connection=${False}    connection_for_abil=${None}
#     ...    connection_for_asik=${None}
#     ${Ul_path}    get from dictionary    ${UL_DL_csv_file_path_dict}    UL
#     ${tbsize_value}    run keyword and continue on failure    get_ulFdSchedData_rrmBufferedDataUlTotal_bytes_tbsize_19B
#     ...    file_path=${Ul_path}    except_value=${984}    Preschedule=False
#     run keyword and continue on failure    should be true    ${tbsize_value}>${0.95}
#     FOR    ${ue_index}    In range    ${ue_number}
#         Run Keyword And Ignore error    samsung_spark.detach_ue    ue_alias=UE_${ue_index}
#     END
#     Run keyword if    '${versiontitle}'=='SBTS22R1' or '${versiontitle}'=='SBTS22R2'
#     ...    Change the configure ca_22R1_22R2    value=true
#     ...    ELSE
#     ...    Change the configure ca_trunk_22R3_22R4    value=true
# #   Run keyword if    '${versiontitle}'=='SBTS22R1'
# #   ...    Change the configure ca_22R1    value=true
# #   ...    ELSE IF    '${versiontitle}'=='SBTS22R3'
# #   ...    Change the configure ca_22R3    value=true
# #   ...    ELSE IF    '${versiontitle}'=='SBTS22R4'
# #   ...    Change the configure ca_trunk    value=true
# #   ...    ELSE
# #   ...    Change the configure ca_22R2    value=true
#     UE attach by Spark    ue_num=${ue_number}
#     CB007608_A_523_common_keywords.start tti trace
#     sleep    5s
#     Stop TTI trace log capturing
#     ${UL_DL_csv_file_path_dict1}    Convert TTI trace log and download combined csv logs to test pc
#     ...    local_path=${TS_CASE_LOG_PATH}    is_need_to_close_connection=${False}    connection_for_abil=${None}
#     ...    connection_for_asik=${None}
#     ${Ul_path1}    get from dictionary    ${UL_DL_csv_file_path_dict1}    UL
#     ${tbsize_value1}    run keyword and continue on failure    get_ulFdSchedData_rrmBufferedDataUlTotal_bytes_tbsize_19B
#     ...    file_path=${Ul_path1}    except_value=${4040}    Preschedule=True
#     run keyword and continue on failure    should be true    ${tbsize_value1}>${0.95}
#     ${exp_value}    run keyword and continue on failure    get_ulTdSchedSubcellData_resReqClassPrio_19B
#     ...    file_path=${Ul_path1}    input_value=${20}
#     run keyword and continue on failure    should be true    ${exp_value}>${0.90}
#     Start data traffic and Record TP Log and Aasys Log
#     ...    ue_num=${ue_number}    ul_throughput=${ul_tput_udp}    dl_throughput=${dl_tput_udp}    ul_duration=${duration}
#     ...    dl_duration=${duration}     protocol=udp    if_ul=${True}    if_dl=${True}    file_name=Asys_ul_dl_udp.txt
#     ...    time=${log_time}
#     sleep    3s
#     Stop data traffic and Stop Record TP Log and Aasys Log    ue_num=${ue_number}    if_ul=${True}    if_dl=${True}
#     ...    protocol=udp    spark_log_name=spark_ul_dl_udp
#     ${total_result_list}    Get Each UE TP From Spark    ue_num=${ue_number}    spark_log_name=spark_ul_dl_udp
#     ...    list_length=${total_count}
#     ${total_result_dict}    set variable    @{total_result_list}[-1]
#     run keyword and continue on failure    check TP and bler    total_result_list=${total_result_dict}
#     [Teardown]    run keyword and continue on failure    523 case teardown    ue_number=${ue_number}
# 
# #[1]CB007608-5G-A-1854+523-007_D_CSI_RS_CSI_reports_check_MultiUE_4UE_UE_ULDL_goodRF_aBF
# #    [Tags]    CB007608    CRT_22R2    CRT_22R3    CRT_TRUNK
# #    ${versiontitle}    Get Version
# #    set suite variable    ${versiontitle}
# #    Run keyword if    '${versiontitle}'=='SBTS22R1' or '${versiontitle}'=='SBTS22R2'
# #    ...    Change the configure ca_22R1_22R2
# #    ...    ELSE
# #    ...    Change the configure ca_trunk_22R3_22R4
# #    Check BTS is in On Air
# #    UE attach by Spark    ue_num=${ue_number}
# #    Start data traffic and Record TP Log and Aasys Log
# #    ...    ue_num=${ue_number}    ul_throughput=${ul_tput_udp}    dl_throughput=${dl_tput_udp}    ul_duration=${duration}
# #    ...    dl_duration=${duration}
# #    ...    protocol=udp    if_ul=${True}    if_dl=${True}    file_name=Asys_ul_dl_udp.txt    time=${log_time}
# #    ${UL_DL_csv_file_path_dict}    Capture TTI log    log_time=3
# #    ${Dl_path}    Get From Dictionary    ${UL_DL_csv_file_path_dict}    DL
# #    ${bip_log_path}    run keyword and continue on failure    523 Capture BIP log
# #    Stop data traffic and Stop Record TP Log and Aasys Log    ue_num=${ue_number}    if_ul=${True}    if_dl=${True}
# #    ...    protocol=udp    spark_log_name=spark_ul_dl_udp
# #    run keyword and continue on failure    check BIP LOG    bip_log_path=${bip_log_path}
# #    run keyword and continue on failure    TTI_Stream.get_csiSrReportData_reportType_ulChannel    file_path=${Dl_path}
# #    run keyword and continue on failure    TTI_Stream.get_csiSrReportData_rnti_sfn_diff    file_path=${Dl_path}    except_value=${4}
# #    ${total_result_list}    Get Each UE TP From Spark    ue_num=${ue_number}    spark_log_name=spark_ul_dl_udp
# #    ...    list_length=${total_count}
# #    ${total_result_dict}    set variable    @{total_result_list}[-1]
# #    run keyword and continue on failure    check TP and bler    total_result_list=${total_result_dict}
# #    [Teardown]    run keyword and continue on failure    523 case teardown    ue_number=${ue_number}
# 
# *** Keywords ***
# Suite preparation
#     conmission SCF
# 
# conmission SCF
#     [Arguments]      ${BTS_Host}=${DU_IP}
#      ${default_scf}    Get BTS Version And Perare SCF       gNB_ip=${BTS_Host}
#      Connect to gnb coam via ssl    bts_host=${BTS_Host}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}
#      COAM Commission with scf file    scf_file_path=${default_scf}     is_pdl_checking_needed=${False}
#      Run keyword and ignore error     coam.teardown    connection=GNB_OAM
#      Check BTS is in On Air
#      [Teardown]    Run keyword and ignore error     COAM Teardown gnb connections
# 
# #conmission SCF
# #   ${versiontitle}    Get Version
# #   set suite variable    ${versiontitle}
# #   Run keyword if    '${versiontitle}'=='SBTS22R1'
# #   ...    teardown SCF reduct
# #   ...    scf_file_path=${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/SCF_SBTS22R1_523.xml
# #   ...    ELSE IF    '${versiontitle}'=='SBTS22R4'
# #   ...    teardown SCF reduct
# #   ...    scf_file_path=${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/SCF_Trunk_523.xml
# #   ...    ELSE IF    '${versiontitle}'=='SBTS22R3'
# #   ...    teardown SCF reduct
# #   ...    scf_file_path=${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/SCF_22R3_523.xml
# #   ...    ELSE    teardown SCF reduct
# #   ...    scf_file_path=${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/SCF_SBTS22R2_523.xml
# #   Check BTS is in On Air
# 
# teardown SCF reduct
#     [Arguments]    ${scf_file_path}
#     ${conn}    Connect to DU
#     COAM Commission with scf file ignore error    scf_file_path=${scf_file_path}    connection=${conn}
#     RUN KEYWORD AND IGNORE ERROR    Disconnect from DU
# 
# set default scf
#     ${conn}    Connect to DU
#     COAM Commission with scf file ignore error    connection=${conn}
#     RUN KEYWORD AND IGNORE ERROR    Disconnect from DU
#     Check BTS is in On Air
# 
# Check BTS is in On Air
#     [Arguments]
#     Connect to DU
#     ADMIN Wait Until BTS OnAir
#     [Teardown]    Disconnect from DU
# 
# Check TP From Aasyslog
#     [Arguments]  ${file_name}
#     ${total_tp_list}    Get UL And DL TP From Aaslog    file_name=${file_name}
#     log to console  @{total_tp_list}[4]
#     log to console  @{total_tp_list}[1]
# 
# check BIP LOG
#     [Arguments]    ${bip_log_path}
#     run keyword and continue on failure    Check BIP log data not empty    source=${bip_log_path}
#     ...    command=grep startSymbol
#     run keyword and continue on failure    Check BIP log data not empty    source=${bip_log_path}
#     ...    command=grep csiRsScramblingSequenceInt
#     run keyword and continue on failure    Check BIP log data not empty    source=${bip_log_path}
#     ...    command=grep density
#     run keyword and continue on failure    Check BIP log data not empty    source=${bip_log_path}
#     ...    command=grep densityDot5PrbLocation
#     run keyword and continue on failure    Check BIP log data not empty    source=${bip_log_path}
#     ...    command=grep startPrb
#     run keyword and continue on failure    Check BIP log data not empty    source=${bip_log_path}
#     ...    command=grep numOfPrb
#     run keyword and continue on failure    Check BIP log data not empty    source=${bip_log_path}
#     ...    command=grep csiRsConfig
#     run keyword and continue on failure    Check BIP log data not empty    source=${bip_log_path}
#     ...    command=grep freqDomainAllocationKi
# 
# check TP and bler
#     [Arguments]    ${total_result_list}
#     log to console    check TP...
#     ${sum_UL_exp}    set variable    ${0}
#     FOR    ${eatch_result}    IN    @{total_result_list}
#         ${DL_bler}    get from dictionary    ${eatch_result}    DL_bler
#         ${DL_tp}    get from dictionary    ${eatch_result}    DL_tp
#         ${UL_bler}    get from dictionary    ${eatch_result}    UL_bler
#         ${UL_tp}    get from dictionary    ${eatch_result}    UL_tp
#         ${sum_UL_exp}    evaluate    ${sum_UL_exp}+${${UL_tp}[0]}
#             should be true    ${${UL_tp}[0]}>${UL_tp_exp}
#             should be true    ${${DL_tp}[0]}>${DL_tp_exp}
#             should be true    ${${UL_bler}[0]}<${${UL_bler}[3]}
#             should be true    ${${DL_bler}[0]}<${${DL_bler}[3]}
#     END
#     should be true    ${sum_UL_exp}>${70}
# 
# check ACK
#     [Arguments]    ${ack}
#    ${rnti}    get dictionary keys    ${ack}
#     FOR    ${eatch_result}    IN    @{rnti}
#         ${ACK_RESULT}   get from dictionary    ${ack}    ${eatch_result}
#         ${ACK_1}    get from dictionary    ${ACK_RESULT}    ACK
#         should be true    ${ACK_1}>${EXP_ACK}
#     END
# 
# Change the configure_trunk_22R3_22R4
#     [Arguments]    ${value}=false    ${dist1_actProactUlScheduling}=MRBTS-5411/NRBTS-1/NRCELL-1
#     ...    ${dist2_actProactUlScheduling}=MRBTS-5411/NRBTS-1/NRCELL-2
#     ...    ${dist3_actProactUlScheduling}=MRBTS-5411/NRBTS-1/NRCELL-3
#     ...    ${dist4_actProactUlScheduling}=MRBTS-5411/NRBTS-1/NRCELL-4
#     ...    ${parameter}=actProactUlScheduling
#     ${conn}    Connect to DU
#     ${modify1}    Create Dictionary    dist_name=${dist1_actProactUlScheduling}
#     ...    parameter=${parameter}    value=${value}
#     ${modify2}    Create Dictionary    dist_name=${dist2_actProactUlScheduling}
#     ...    parameter=${parameter}    value=${value}
#     ${modify3}    Create Dictionary    dist_name=${dist3_actProactUlScheduling}
#     ...    parameter=${parameter}    value=${value}
#     ${modify4}    Create Dictionary    dist_name=${dist4_actProactUlScheduling}
#     ...    parameter=${parameter}    value=${value}
#     ${modify5}    Create Dictionary    dist_name=MRBTS-5411/NRBTS-1
#     ...    parameter=actCarrierAggregation    value=${value}
#     ${modify6}    Create Dictionary    dist_name=MRBTS-5411/NRBTS-1
#     ...    parameter=caConfigurationSupport    value=none
#     @{modify_param}    Create List     ${modify1}    ${modify2}    ${modify3}    ${modify4}    ${modify5}    ${modify6}
#     COAM Update several parameters via rest api    parameters_to_update_via_api=${modify_param}    connection=${conn}    timeout=600
# #   perform muti Parameter recommissioning    dist_name=${dist1_actProactUlScheduling}    parameter=${parameter}
# #   ...    value=${value}    operation=update
# #   perform muti Parameter recommissioning    dist_name=${dist2_actProactUlScheduling}    parameter=${parameter}
# #   ...    value=${value}    operation=update
# #   perform muti Parameter recommissioning    dist_name=${dist3_actProactUlScheduling}    parameter=${parameter}
# #   ...    value=${value}    operation=update
# #   perform muti Parameter recommissioning    dist_name=${dist4_actProactUlScheduling}    parameter=${parameter}
# #   ...    value=${value}    operation=update
# #   perform muti Parameter recommissioning    dist_name=MRBTS-5411/NRBTS-1    parameter=actCarrierAggregation
# #   ...    value=${value}    operation=update
# #   perform muti Parameter recommissioning    dist_name=MRBTS-5411/NRBTS-1    parameter=caConfigurationSupport
# #   ...    value=none    operation=update
#     [Teardown]    Disconnect from DU
# 
# #Change the configure_22R3
# #   [Arguments]    ${value}=false    ${dist1_actProactUlScheduling}=MRBTS-5411/NRBTS-1/NRCELL-1
# #   ...    ${dist2_actProactUlScheduling}=MRBTS-5411/NRBTS-1/NRCELL-2
# #   ...    ${dist3_actProactUlScheduling}=MRBTS-5411/NRBTS-1/NRCELL-3
# #   ...    ${dist4_actProactUlScheduling}=MRBTS-5411/NRBTS-1/NRCELL-4
# #   ...    ${parameter}=actProactUlScheduling
# #   Connect to DU
# #   perform muti Parameter recommissioning    dist_name=${dist1_actProactUlScheduling}    parameter=${parameter}
# #   ...    value=${value}    operation=update
# #   perform muti Parameter recommissioning    dist_name=${dist2_actProactUlScheduling}    parameter=${parameter}
# #   ...    value=${value}    operation=update
# #   perform muti Parameter recommissioning    dist_name=${dist3_actProactUlScheduling}    parameter=${parameter}
# #   ...    value=${value}    operation=update
# #   perform muti Parameter recommissioning    dist_name=${dist4_actProactUlScheduling}    parameter=${parameter}
# #   ...    value=${value}    operation=update
# #   perform muti Parameter recommissioning    dist_name=MRBTS-5411/NRBTS-1    parameter=actCarrierAggregation
# #   ...    value=${value}    operation=update
# #   perform muti Parameter recommissioning    dist_name=MRBTS-5411/NRBTS-1    parameter=caConfigurationSupport
# #   ...    value=none    operation=update
# #   [Teardown]    Disconnect from DU
# 
# Change the configure_22R1_22R2
#     [Arguments]    ${value}=false    ${dist_actProactUlScheduling}=MRBTS-5411/NRBTS-1/NRCELLGRP-0
#     ...    ${parameter}=actProactUlScheduling
#     ${conn}    Connect to DU
#     ${modify1}    Create Dictionary    dist_name=${dist_actProactUlScheduling}
#     ...    parameter=${parameter}    value=${value}
#     ${modify2}    Create Dictionary    dist_name=MRBTS-5411/NRBTS-1
#     ...    parameter=actCarrierAggregation    value=${value}
#     ${modify3}    Create Dictionary    dist_name=MRBTS-5411/NRBTS-1
#     ...    parameter=caConfigurationSupport    value=none
#     @{modify_param}    Create List     ${modify1}    ${modify2}    ${modify3}
#     COAM Update several parameters via rest api    parameters_to_update_via_api=${modify_param}    connection=${conn}    timeout=600
# #   perform muti Parameter recommissioning    dist_name=${dist_actProactUlScheduling}    parameter=${parameter}
# #   ...    value=${value}    operation=update
# #   perform muti Parameter recommissioning    dist_name=MRBTS-5411/NRBTS-1    parameter=actCarrierAggregation
# #   ...    value=${value}    operation=update
# #   perform muti Parameter recommissioning    dist_name=MRBTS-5411/NRBTS-1    parameter=caConfigurationSupport
# #   ...    value=none    operation=update
#     [Teardown]    Disconnect from DU
# 
# #Change the configure_22R2
# #   [Arguments]    ${value}=false    ${dist_actProactUlScheduling}=MRBTS-5411/NRBTS-1/NRCELLGRP-0
# #   ...    ${parameter}=actProactUlScheduling
# #   Connect to DU
# #   perform muti Parameter recommissioning    dist_name=${dist_actProactUlScheduling}    parameter=${parameter}
# #   ...    value=${value}    operation=update
# #   perform muti Parameter recommissioning    dist_name=MRBTS-5411/NRBTS-1    parameter=actCarrierAggregation
# #   ...    value=${value}    operation=update
# #   perform muti Parameter recommissioning    dist_name=MRBTS-5411/NRBTS-1    parameter=caConfigurationSupport
# #   ...    value=none    operation=update
# #   [Teardown]    Disconnect from DU
# 
# Change the configure ca_trunk_22R3_22R4
#     [Arguments]    ${value}=false    ${dist1_actProactUlScheduling}=MRBTS-5411/NRBTS-1/NRCELL-1
#     ...    ${dist2_actProactUlScheduling}=MRBTS-5411/NRBTS-1/NRCELL-2
#     ...    ${dist3_actProactUlScheduling}=MRBTS-5411/NRBTS-1/NRCELL-3
#     ...    ${dist4_actProactUlScheduling}=MRBTS-5411/NRBTS-1/NRCELL-4
#     ...    ${parameter}=actProactUlScheduling
#     ${conn}    Connect to DU
#     ${modify1}    Create Dictionary    dist_name=${dist1_actProactUlScheduling}
#     ...    parameter=${parameter}    value=${value}
#     ${modify2}    Create Dictionary    dist_name=${dist2_actProactUlScheduling}
#     ...    parameter=${parameter}    value=${value}
#     ${modify3}    Create Dictionary    dist_name=${dist3_actProactUlScheduling}
#     ...    parameter=${parameter}    value=${value}
#     ${modify4}    Create Dictionary    dist_name=${dist4_actProactUlScheduling}
#     ...    parameter=${parameter}    value=${value}
#     ${modify5}    Create Dictionary    dist_name=MRBTS-5411/NRBTS-1
#     ...    parameter=actCarrierAggregation    value=true
#     ${modify6}    Create Dictionary    dist_name=MRBTS-5411/NRBTS-1
#     ...    parameter=caConfigurationSupport    value=4CCDL_2CCUL
#     @{modify_param}    Create List     ${modify1}    ${modify2}    ${modify3}    ${modify4}    ${modify5}    ${modify6}
#     COAM Update several parameters via rest api    parameters_to_update_via_api=${modify_param}    connection=${conn}    timeout=600
# #   perform muti Parameter recommissioning    dist_name=${dist1_actProactUlScheduling}    parameter=${parameter}
# #   ...    value=${value}    operation=update
# #   perform muti Parameter recommissioning    dist_name=${dist2_actProactUlScheduling}    parameter=${parameter}
# #   ...    value=${value}    operation=update
# #   perform muti Parameter recommissioning    dist_name=${dist3_actProactUlScheduling}    parameter=${parameter}
# #   ...    value=${value}    operation=update
# #   perform muti Parameter recommissioning    dist_name=${dist4_actProactUlScheduling}    parameter=${parameter}
# #   ...    value=${value}    operation=update
# #   perform muti Parameter recommissioning    dist_name=MRBTS-5411/NRBTS-1    parameter=actCarrierAggregation
# #   ...    value=true    operation=update
# #   perform muti Parameter recommissioning    dist_name=MRBTS-5411/NRBTS-1    parameter=caConfigurationSupport
# #   ...    value=4CCDL_2CCUL    operation=update
#     [Teardown]    Disconnect from DU
# 
# #Change the configure ca_22R3
# #   [Arguments]    ${value}=false    ${dist1_actProactUlScheduling}=MRBTS-5411/NRBTS-1/NRCELL-1
# #   ...    ${dist2_actProactUlScheduling}=MRBTS-5411/NRBTS-1/NRCELL-2
# #   ...    ${dist3_actProactUlScheduling}=MRBTS-5411/NRBTS-1/NRCELL-3
# #   ...    ${dist4_actProactUlScheduling}=MRBTS-5411/NRBTS-1/NRCELL-4
# #   ...    ${parameter}=actProactUlScheduling
# #   Connect to DU
# #   perform muti Parameter recommissioning    dist_name=${dist1_actProactUlScheduling}    parameter=${parameter}
# #   ...    value=${value}    operation=update
# #   perform muti Parameter recommissioning    dist_name=${dist2_actProactUlScheduling}    parameter=${parameter}
# #   ...    value=${value}    operation=update
# #   perform muti Parameter recommissioning    dist_name=${dist3_actProactUlScheduling}    parameter=${parameter}
# #   ...    value=${value}    operation=update
# #   perform muti Parameter recommissioning    dist_name=${dist4_actProactUlScheduling}    parameter=${parameter}
# #   ...    value=${value}    operation=update
# #   perform muti Parameter recommissioning    dist_name=MRBTS-5411/NRBTS-1    parameter=actCarrierAggregation
# #   ...    value=true    operation=update
# #   perform muti Parameter recommissioning    dist_name=MRBTS-5411/NRBTS-1    parameter=caConfigurationSupport
# #   ...    value=4CCDL_2CCUL    operation=update
# #   [Teardown]    Disconnect from DU
# 
# Change the configure ca_22R1_22R2
#     [Arguments]    ${value}=false    ${dist_actProactUlScheduling}=MRBTS-5411/NRBTS-1/NRCELLGRP-0
#     ...    ${parameter}=actProactUlScheduling
#     ${conn}    Connect to DU
#     ${modify1}    Create Dictionary    dist_name=${dist_actProactUlScheduling}
#     ...    parameter=${parameter}    value=${value}
#     ${modify2}    Create Dictionary    dist_name=MRBTS-5411/NRBTS-1
#     ...    parameter=actCarrierAggregation    value=true
#     ${modify3}    Create Dictionary    dist_name=MRBTS-5411/NRBTS-1
#     ...    parameter=caConfigurationSupport    value=4CCDL_2CCUL
#     @{modify_param}    Create List     ${modify1}    ${modify2}    ${modify3}
#     COAM Update several parameters via rest api    parameters_to_update_via_api=${modify_param}    connection=${conn}    timeout=600
# #   perform muti Parameter recommissioning    dist_name=${dist_actProactUlScheduling}    parameter=${parameter}
# #   ...    value=${value}    operation=update
# #   perform muti Parameter recommissioning    dist_name=MRBTS-5411/NRBTS-1    parameter=actCarrierAggregation
# #   ...    value=true    operation=update
# #   perform muti Parameter recommissioning    dist_name=MRBTS-5411/NRBTS-1    parameter=caConfigurationSupport
# #   ...    value=4CCDL_2CCUL    operation=update
#     [Teardown]    Disconnect from DU
# 
# #Change the configure ca_22R2
# #   [Arguments]    ${value}=false    ${dist_actProactUlScheduling}=MRBTS-5411/NRBTS-1/NRCELLGRP-0
# #   ...    ${parameter}=actProactUlScheduling
# #   Connect to DU
# #   perform muti Parameter recommissioning    dist_name=${dist_actProactUlScheduling}    parameter=${parameter}
# #   ...    value=${value}    operation=update
# #   perform muti Parameter recommissioning    dist_name=MRBTS-5411/NRBTS-1    parameter=actCarrierAggregation
# #   ...    value=true    operation=update
# #   perform muti Parameter recommissioning    dist_name=MRBTS-5411/NRBTS-1    parameter=caConfigurationSupport
# #   ...    value=4CCDL_2CCUL    operation=update
# #   [Teardown]    Disconnect from DU
# 
# check 4UE tti trace
#     [Arguments]    ${UL_DL_csv_file_path_dict}    ${direction}    ${cell_id}=50    ${ue_number}=${3}
#     log to console    check 4UE tti trace...
#     ${Ul_path}    get from dictionary    ${UL_DL_csv_file_path_dict}    UL
#     ${Dl_path}    get from dictionary    ${UL_DL_csv_file_path_dict}    DL
#     ${file_path}    set variable if    '${direction}'=='UL'    ${Ul_path}     ${Dl_path}
#     run keyword and continue on failure     get_one_sfn_cycle_rnti_proportion_19b    file_path=${file_path}
#     ...    cell_id=${cell_id}    rnti_num=${ue_number}    direction=${direction}    unuse_ranti_num=${10}
#     run keyword and continue on failure    check_one_sfn_cycle_with_diff_slot_19b    file_path=${file_path}
#     ...    cell_id=${cell_id}    direction=${direction}
#     ${txnNum}    get_one_sfn_cycle_txNumber_19b    file_path=${file_path}
#     ...    cell_id=${cell_id}    direction=${direction}
#     should be true    ${txnNum}<${exp_txnum}
# 
# 523 case teardown
#     [Arguments]  ${ue_number}
#     FOR    ${ue_index}    In range    ${ue_number}
#         Run Keyword And Ignore error    samsung_spark.detach_ue    ue_alias=UE_${ue_index}
#     END
#     run keyword and ignore error    CI_interface.Common Case Teardown
# 
# 
