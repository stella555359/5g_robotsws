# *** Settings ***
# Suite Setup     run keywords    Suite preparation    AND    robot_common_operations.Common Suite Setup
# Suite Teardown    CB007403 Suite Teardown
# 
# Documentation    Suite description
# 
# 
# Resource          ../5GC000523_samsung/Resources/5GC000523_common_keyword.robot
# Resource          ./Resources/CB007403_E_523_common_keywords.robot
# Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/TTI_Trace_Analysis_MMW4.py
# Resource          ../5GC001937_Classical/Resources/5GC001937_classical_keywords.robot
# Resource          ../5GC001937_OTA/resources/5GC001937_mmw4_common_keyword.robot
# Library           taf.transport.ssh    WITH NAME    csn
# Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# Library           ./Resources/CB007403_common.py
# 
# *** Variables ***
# ${TS_CASE_LOG_PATH}    ${output_dir}
# ${UL_DL_csv_file_path_dict}    ${TS_CASE_LOG_PATH}    ${output_dir}
# ${LUA_SCRIPT_PATH}      /home/ute/Downloads/lua/generated_luashark/luashark.lua
# ${ul_throughput}    200M
# ${dl_throughput}    200M
# ${dl_tput_udp_05}          800M
# ${duration}         ${600}
# ${ul_tput_udp}          100M
# ${dl_tput_udp}          200M
# ${ul_tput_tcp}          30M
# ${dl_tput_tcp}          100M
# ${log_time}             30s
# ${exp_ul}               ${160}
# ${exp_dl}               ${3600}
# ${deviation}            10%
# ${total_count}          ${10}
# ${exp_txnum}            ${18}
# ${exp_crc}              ${98}
# ${EXP_ACK}              ${0.85}
# ${UL_tp_exp}            ${5}
# ${DL_tp_exp}            ${50}
# ${UL_bler_exp}          ${11}
# ${DL_bler_exp}          ${11}
# ${total_count}          ${10}
# ${ue_number}            ${2}
# ${ue_number_05}            ${2}
# ${except_rrmDlUsedMcs_txnum}    0.2
# ${except_rrmDlUsedMcs_cqi}      0.2
# ${exp_num_sinrDerivedMcs}       0.1
# ${exp_num_numOfPrb}             0.1
# ${exp_rrmDlUsedMcs_false}       0.2
# ${gNB_ip1}             ${tl.gnbs[1].dus[0].f1_m_ip_addr}
# 
# 
# *** Test Cases ***
# #[1]CB007403-5G-E-SyVe-1854+523-005_E_PRB_and_MCS_Reduction_2UE_UL_Abf
# #    [Tags]    CB007403    CRT_22R1
# #    ${versiontitle}    Get Version
# #    set suite variable    ${versiontitle}
# #    Run keyword if    '${versiontitle}'=='SBTS22R1'
# #    ...    Change the configure true_22R1
# #    ...    ELSE IF    '${versiontitle}'=='SBTS22R3'
# #    ...    Change the configure true_22R3
# #    ...    ELSE IF    '${versiontitle}'=='SBTS22R4'
# #    ...    Change the configure true_trunk
# #    ...    ELSE
# #    ...    Change the configure true_22R2
# #    UE attach by Spark    ue_num=${ue_number_05}
# #    sleep    10s
# #    CB007403_E_523_common_keywords.start tti trace
# #    sleep    3s
# #    Stop TTI trace log capturing
# #    sleep    3s
# #    ${UL_DL_csv_file_path_dict}    Convert TTI trace log and download combined csv logs to test pc     local_path=${TS_CASE_LOG_PATH}
# #    ...    is_need_to_close_connection=${False}    connection_for_abil=${None}   connection_for_asik=${None}
# #    ${Ul_path}    get from dictionary    ${UL_DL_csv_file_path_dict}    UL
# #    ${Dl_path}    get from dictionary    ${UL_DL_csv_file_path_dict}    DL
# #    ${except_rrmDlUsedMcs_false}    run keyword and continue on failure    check_rrmDlUsedMcs_equal_rrmDlProposedMcs_19B
# #    ...    file_path=${Dl_path}    equal_flag=${False}
# #     run keyword and continue on failure    should be true    ${except_rrmDlUsedMcs_false}<${exp_rrmDlUsedMcs_false}
# #    ${exp_num_numOfPrb_false}    run keyword and continue on failure    get_FdSchedData_numofprb_19B    file_path=${Ul_path}
# #    ...    direction=UL    except_value=${66}    equal_flag=${False}
# #     run keyword and continue on failure    should be true    ${exp_num_numOfPrb_false}<${exp_num_numOfPrb}
# #    Start data traffic and Record TP Log and Aasys Log
# #    ...    ue_num=${ue_number_05}    ul_throughput=${ul_tput_udp}    dl_throughput=${dl_tput_udp_05}   ul_duration=${duration}
# #    ...    dl_duration=${duration}
# #    ...    protocol=udp    if_ul=${True}    if_dl=${True}    file_name=Asys_ul_dl_udp.txt    time=${log_time}
# #    sleep    10s
# #    CB007403_E_523_common_keywords.start tti trace
# #    sleep    3s
# #    Stop TTI trace log capturing
# #    sleep    3s
# #    ${UL_DL_csv_file_path_dict1}    Convert TTI trace log and download combined csv logs to test pc     local_path=${TS_CASE_LOG_PATH}
# #    ...    is_need_to_close_connection=${False}    connection_for_abil=${None}   connection_for_asik=${None}
# #    Stop data traffic and Stop Record TP Log and Aasys Log    ue_num=${ue_number_05}    if_ul=${True}    if_dl=${True}    protocol=udp
# #    ...    spark_log_name=spark_ul_dl_udp
# #    ${total_result_list}    Get Each UE TP From Spark    ue_num=${ue_number_05}    spark_log_name=spark_ul_dl_udp    list_length=${total_count}
# #    ${total_result_dict}    set variable    @{total_result_list}[-1]
# #    run keyword and continue on failure    check TP and bler    total_result_list=${total_result_dict}
# #    ${Ul_path1}    get from dictionary    ${UL_DL_csv_file_path_dict1}    UL
# #    ${Dl_path1}    get from dictionary    ${UL_DL_csv_file_path_dict1}    DL
# #    ${except_rrmDlUsedMcs_txnum_true}    ${except_rrmDlUsedMcs_cqi_true}    run keyword and continue on failure
# #    ...    check_rrmDlUsedMcs_equal_rrmDlProposedMcs_19B    file_path=${Dl_path1}    equal_flag=${True}
# #     run keyword and continue on failure    should be true    ${except_rrmDlUsedMcs_txnum_true}<${except_rrmDlUsedMcs_txnum}
# #     run keyword and continue on failure    should be true    ${except_rrmDlUsedMcs_cqi_true}<${except_rrmDlUsedMcs_cqi}
# #    ${exp_num_sinrDerivedMcs_true}    run keyword and continue on failure    get_FdSchedData_numofprb_19B    file_path=${Ul_path1}
# #    ...    direction=UL    except_value=${66}    equal_flag=${True}
# #    run keyword and continue on failure    should be true    ${exp_num_sinrDerivedMcs_true}<${exp_num_sinrDerivedMcs}
# #    [Teardown]    run keyword and continue on failure    523 case teardown    ue_number=${ue_number_05}
# 
# [1]CB007403-5G-E-SyVe-1854+523-003_AB_Multi_UE_ULDL_data_schedulling_4UEs_mmWaves
#     [Tags]    CB007403    CRT_22R1    CRT_TRUNK    CRT_22R2
#     [Setup]      robot_common_operations.Common Case Setup      
#     ${versiontitle}    Get Version
#     set suite variable    ${versiontitle}
#     Run keyword if    '${versiontitle}'=='SBTS22R1' or '${versiontitle}'=='SBTS22R2'
#     ...    Change the configure_22R1_22R2
#     ...    ELSE
#     ...    Change the configure_trunk_22R3_22R4
#     UE attach by Spark    ue_num=${ue_number}
#     sleep    5s
#     Start data traffic and Record TP Log and Aasys Log
#     ...    ue_num=${ue_number}    ul_throughput=${ul_tput_udp}    dl_throughput=${dl_tput_udp}   ul_duration=${duration}    dl_duration=${duration}
#     ...    protocol=udp    if_ul=${True}    if_dl=${True}    file_name=Asys_ul_dl_udp.txt    time=${log_time}
#     CB007403_E_523_common_keywords.start tti trace
#     sleep    5s
#     Stop TTI trace log capturing
#     ${UL_DL_csv_file_path_dict}    Convert TTI trace log and download combined csv logs to test pc     local_path=${TS_CASE_LOG_PATH}
#     ...    is_need_to_close_connection=${False}    connection_for_abil=${None}   connection_for_asik=${None}
#     sleep    3s
#     Stop data traffic and Stop Record TP Log and Aasys Log    ue_num=${ue_number}    if_ul=${True}    if_dl=${True}    protocol=udp
#     ...    spark_log_name=spark_ul_dl_udp
#     run keyword and continue on failure    check 4UE tti trace    UL_DL_csv_file_path_dict=${UL_DL_csv_file_path_dict}
#     ...    direction=UL    ue_number=${ue_number}
#     run keyword and continue on failure    check 4UE tti trace    UL_DL_csv_file_path_dict=${UL_DL_csv_file_path_dict}
#     ...    direction=DL    ue_number=${ue_number}
#     ${Dl_path}    get from dictionary    ${UL_DL_csv_file_path_dict}    DL
#     ${Ul_path}    get from dictionary    ${UL_DL_csv_file_path_dict}    UL
#     ${crc}    get_ulHarqRxData_crcResult_19b    file_path=${Ul_path}
#     ...    crcResult=OK
#     run keyword and continue on failure    should be true    ${crc}>${exp_crc}
#     ${ack}    get_dlHarqRxDataArray_rnti_ackNack_19B    file_path=${Dl_path}
#     run keyword and continue on failure    check ACK    ack=${ack}
#     ${total_result_list}    Get Each UE TP From Spark    ue_num=${ue_number}    spark_log_name=spark_ul_dl_udp    list_length=${total_count}
#     ${total_result_dict}    set variable    @{total_result_list}[-1]
#     run keyword and continue on failure    check TP and bler    total_result_list=${total_result_dict}
#     [Teardown]    run keyword and continue on failure    523 case teardown    ue_number=${ue_number}
# 
# [1]CB007403-5G-E-SyVe-1854+523-004_AB_Multi_UE_ULDL_Proactive_Scheduling_mmWaves
#     [Tags]    CB007403    CRT_22R1    CRT_TRUNK    CRT_22R2
#     [Setup]      robot_common_operations.Common Case Setup
#     ${versiontitle}    Get Version
#     set suite variable    ${versiontitle}
#     Run keyword if    '${versiontitle}'=='SBTS22R1' or '${versiontitle}'=='SBTS22R2'
#     ...    Change the configure_22R1_22R2
#     ...    ELSE
#     ...    Change the configure_trunk_22R3_22R4
#     UE attach by Spark    ue_num=${ue_number}
#     CB007403_E_523_common_keywords.start tti trace
#     sleep    5s
#     Stop TTI trace log capturing
#     ${UL_DL_csv_file_path_dict}    Convert TTI trace log and download combined csv logs to test pc     local_path=${TS_CASE_LOG_PATH}
#     ...    is_need_to_close_connection=${False}    connection_for_abil=${None}   connection_for_asik=${None}
# #    ${UL_DL_csv_file_path_dict}    replace_csv_content    ${UL_DL_csv_file_path_dict}
#     ${Ul_path}    get from dictionary    ${UL_DL_csv_file_path_dict}    UL
#     ${Ul_path}    replace_csv_content    ${Ul_path}
#     ${tbsize_value}    get_ulFdSchedData_rrmBufferedDataUlTotal_bytes_tbsize_19B    file_path=${Ul_path}    except_value
# ...=${984}    Preschedule=False
#     run keyword and continue on failure    should be true    ${tbsize_value}>${0.95}
#     FOR    ${ue_index}    In range    ${ue_number}
#         Run Keyword And Ignore error    samsung_spark.detach_ue    ue_alias=UE_${ue_index}
#     END
#     Run keyword if    '${versiontitle}'=='SBTS22R1' or '${versiontitle}'=='SBTS22R2'
#     ...    Change the configure true_22R1_22R2    value=true
#     ...    ELSE
#     ...    Change the configure true_trunk_22R3_22R4    value=true
#     UE attach by Spark    ue_num=${ue_number}
#     CB007403_E_523_common_keywords.start tti trace
#     sleep    5s
#     Stop TTI trace log capturing
#     ${UL_DL_csv_file_path_dict1}    Convert TTI trace log and download combined csv logs to test pc     local_path=${TS_CASE_LOG_PATH}
#     ...    is_need_to_close_connection=${False}    connection_for_abil=${None}   connection_for_asik=${None}
# #    ${UL_DL_csv_file_path_dict}    replace_csv_content    ${UL_DL_csv_file_path_dict}
#     ${Ul_path1}    get from dictionary    ${UL_DL_csv_file_path_dict1}    UL
#     ${Ul_path1}    replace_csv_content    ${Ul_path1}
#     ${tbsize_value1}    get_ulFdSchedData_rrmBufferedDataUlTotal_bytes_tbsize_19B   file_path=${Ul_path1}    except_value=${4040}
#     ...    Preschedule=True
#     run keyword and continue on failure    should be true    ${tbsize_value1}>${0.95}
#     Start data traffic and Record TP Log and Aasys Log
#     ...    ue_num=${ue_number}    ul_throughput=${ul_tput_udp}    dl_throughput=${dl_tput_udp}    ul_duration=${duration
# ...}    dl_duration=${duration}
#     ...    protocol=udp    if_ul=${True}    if_dl=${True}    file_name=Asys_ul_dl_udp.txt    time=${log_time}
#     sleep    3s
#     Stop data traffic and Stop Record TP Log and Aasys Log    ue_num=${ue_number}    if_ul=${True}    if_dl=${True}    protocol=udp
#     ...    spark_log_name=spark_ul_dl_udp
#     ${total_result_list}    Get Each UE TP From Spark    ue_num=${ue_number}    spark_log_name=spark_ul_dl_udp    list_length=${total_count}
#     ${total_result_dict}    set variable    @{total_result_list}[-1]
#     run keyword and continue on failure    check TP and bler    total_result_list=${total_result_dict}
#     [Teardown]    run keyword and continue on failure    523 case teardown    ue_number=${ue_number}
# 
# *** Keywords ***
# Suite preparation
#     conmission SCF
#     Adjust Enb    index=8   dist_name=MRBTS-${tl.enbs[0].global_bts_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-1
#     ...    parameter=defaultLnRelGnbCellId
# #    Perform RU Lock And Check RU State    bts_host=${gNB_ip1}
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
# #    ${versiontitle}    Get Version
# #    Run keyword if    '${versiontitle}'=='SBTS22R1'
# #    ...    teardown SCF reduct
# #    ...    scf_file_path=${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/SCF_SBTS22R1_523.xml
# #    ...    ELSE IF    '${versiontitle}'=='SBTS22R4'
# #    ...    teardown SCF reduct
# #    ...    scf_file_path=${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/SCF_Trunk_523.xml
# #    ...    ELSE IF    '${versiontitle}'=='SBTS22R3'
# #    ...    teardown SCF reduct
# #    ...    scf_file_path=${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/SCF_22R3_523.xml
# #    ...    ELSE    teardown SCF reduct
# #    ...    scf_file_path=${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/SCF_SBTS22R2_523.xml
# #    Check BTS is in On Air
# 
# conmission SCF CA_true
#     ${versiontitle}    Get Version
#     Run keyword if    '${versiontitle}'=='SBTS22R1'
#     ...    teardown SCF reduct
#     ...    scf_file_path=${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/SCF_SBTS22R1_523_CA_true.xml
#     ...    ELSE IF    '${versiontitle}'=='SBTS22R4'
#     ...    teardown SCF reduct
#     ...    scf_file_path=${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/SCF_Trunk_523.xml
#     ...    ELSE IF    '${versiontitle}'=='SBTS22R3'
#     ...    teardown SCF reduct
#     ...    scf_file_path=${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/SCF_22R3_523.xml
#     ...    ELSE    teardown SCF reduct
#     ...    scf_file_path=${CURDIR}/../../../../../commissionings/HGZ/${testline_name}/SCF_SBTS22R2_523.xml
#     Check BTS is in On Air
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
#     ${sum_UL_exp}    set variable    ${0}
#     ${count}     set variable    ${0}
#     FOR    ${eatch_result}    IN    @{total_result_list}
#         ${count}    Evaluate    ${count}+1
#         ${DL_bler}    get from dictionary    ${eatch_result}    DL_bler
#         ${DL_tp}    get from dictionary    ${eatch_result}    DL_tp
#         ${UL_bler}    get from dictionary    ${eatch_result}    UL_bler
#         ${UL_tp}    get from dictionary    ${eatch_result}    UL_tp
#         ${sum_UL_exp}    evaluate    ${sum_UL_exp}+${${UL_tp}[0]}
#         run keyword if    ${eatch_result}==${2}
#         ...    Should Be True    ${${UL_tp}[0]}>${0}
#         ...    ELSE    Should Be True    ${${UL_tp}[0]}>${UL_tp_exp}
#         should be true    ${${UL_tp}[0]}>${UL_tp_exp}
#         should be true    ${${DL_tp}[0]}>${DL_tp_exp}
#         should be true    ${${UL_bler}[0]}<${UL_bler_exp}
#         should be true    ${${DL_bler}[0]}<${DL_bler_exp}
#     END
#     should be true    ${sum_UL_exp}>${30}
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
#     [Arguments]    ${value}=false    ${dist1_actProactUlScheduling}=MRBTS-5388/NRBTS-2/NRCELL-5
#     ...    ${dist2_actProactUlScheduling}=MRBTS-5388/NRBTS-2/NRCELL-6
#     ...    ${dist3_actProactUlScheduling}=MRBTS-5388/NRBTS-2/NRCELL-7
#     ...    ${dist4_actProactUlScheduling}=MRBTS-5388/NRBTS-2/NRCELL-8
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
#     ${modify5}    Create Dictionary    dist_name=MRBTS-5388/NRBTS-2
#     ...    parameter=actCarrierAggregation    value=${value}
#     ${modify6}    Create Dictionary    dist_name=MRBTS-5388/NRBTS-2
#     ...    parameter=caConfigurationSupport    value=none
#     @{modify_param}    Create List     ${modify1}    ${modify2}    ${modify3}    ${modify4}    ${modify5}    ${modify6}
#     COAM Update several parameters via rest api    parameters_to_update_via_api=${modify_param}    connection=${conn}    timeout=600
# #    perform muti Parameter recommissioning    dist_name=${dist1_actProactUlScheduling}    parameter=${parameter}
# #    ...    value=${value}    operation=update
# #    perform muti Parameter recommissioning    dist_name=${dist2_actProactUlScheduling}    parameter=${parameter}
# #    ...    value=${value}    operation=update
# #    perform muti Parameter recommissioning    dist_name=${dist3_actProactUlScheduling}    parameter=${parameter}
# #    ...    value=${value}    operation=update
# #    perform muti Parameter recommissioning    dist_name=${dist4_actProactUlScheduling}    parameter=${parameter}
# #    ...    value=${value}    operation=update
# #    perform muti Parameter recommissioning    dist_name=MRBTS-5388/NRBTS-2    parameter=actCarrierAggregation
# #    ...    value=${value}    operation=update
# #    perform muti Parameter recommissioning    dist_name=MRBTS-5388/NRBTS-2    parameter=caConfigurationSupport
# #    ...    value=none    operation=update
#     [Teardown]    Disconnect from DU
# 
# #Change the configure_22R3
# #     [Arguments]    ${value}=false    ${dist1_actProactUlScheduling}=MRBTS-5388/NRBTS-2/NRCELL-5
# #    ...    ${dist2_actProactUlScheduling}=MRBTS-5388/NRBTS-2/NRCELL-6
# #    ...    ${dist3_actProactUlScheduling}=MRBTS-5388/NRBTS-2/NRCELL-7
# #    ...    ${dist4_actProactUlScheduling}=MRBTS-5388/NRBTS-2/NRCELL-8
# #    ...    ${parameter}=actProactUlScheduling
# #    Connect to DU
# #    perform muti Parameter recommissioning    dist_name=${dist1_actProactUlScheduling}    parameter=${parameter}
# #    ...    value=${value}    operation=update
# #    perform muti Parameter recommissioning    dist_name=${dist2_actProactUlScheduling}    parameter=${parameter}
# #    ...    value=${value}    operation=update
# #    perform muti Parameter recommissioning    dist_name=${dist3_actProactUlScheduling}    parameter=${parameter}
# #    ...    value=${value}    operation=update
# #    perform muti Parameter recommissioning    dist_name=${dist4_actProactUlScheduling}    parameter=${parameter}
# #    ...    value=${value}    operation=update
# #    perform muti Parameter recommissioning    dist_name=MRBTS-5388/NRBTS-2    parameter=actCarrierAggregation
# #    ...    value=${value}    operation=update
# #    perform muti Parameter recommissioning    dist_name=MRBTS-5388/NRBTS-2    parameter=caConfigurationSupport
# #    ...    value=none    operation=update
# #    [Teardown]    Disconnect from DU
# 
# #Change the configure_22R2
# #    [Arguments]    ${value}=false    ${dist_actProactUlScheduling}=MRBTS-5388/NRBTS-2/NRCELLGRP-2
# #    ...    ${parameter}=actProactUlScheduling
# #    Connect to DU
# #    perform muti Parameter recommissioning    dist_name=${dist_actProactUlScheduling}    parameter=${parameter}
# #    ...    value=${value}    operation=update
# #    perform muti Parameter recommissioning    dist_name=MRBTS-5388/NRBTS-2    parameter=actCarrierAggregation
# #    ...    value=${value}    operation=update
# #    perform muti Parameter recommissioning    dist_name=MRBTS-5388/NRBTS-2    parameter=caConfigurationSupport
# #    ...    value=none    operation=update
# #    [Teardown]    Disconnect from DU
# 
# Change the configure_22R1_22R2
#     [Arguments]    ${value}=false    ${dist_actProactUlScheduling}=MRBTS-5388/NRBTS-2/NRCELLGRP-2
#     ...    ${parameter}=actProactUlScheduling
#     ${conn}    Connect to DU
#     ${modify1}    Create Dictionary    dist_name=${dist_actProactUlScheduling}
#     ...    parameter=${parameter}    value=${value}
#     ${modify2}    Create Dictionary    dist_name=MRBTS-5388/NRBTS-2
#     ...    parameter=actCarrierAggregation    value=${value}
#     ${modify3}    Create Dictionary    dist_name=MRBTS-5388/NRBTS-2
#     ...    parameter=caConfigurationSupport    value=none
#     @{modify_param}    Create List     ${modify1}    ${modify2}    ${modify3}
#     COAM Update several parameters via rest api    parameters_to_update_via_api=${modify_param}    connection=${conn}    timeout=600
# #    perform muti Parameter recommissioning    dist_name=${dist_actProactUlScheduling}    parameter=${parameter}
# #    ...    value=${value}    operation=update
# #    perform muti Parameter recommissioning    dist_name=MRBTS-5388/NRBTS-2    parameter=actCarrierAggregation
# #    ...    value=${value}    operation=update
# #    perform muti Parameter recommissioning    dist_name=MRBTS-5388/NRBTS-2    parameter=caConfigurationSupport
# #    ...    value=none    operation=update
#     [Teardown]    Disconnect from DU
# 
# Change the configure true_trunk_22R3_22R4
#     [Arguments]    ${value}=false    ${dist1_actProactUlScheduling}=MRBTS-5388/NRBTS-2/NRCELL-5
#     ...    ${dist2_actProactUlScheduling}=MRBTS-5388/NRBTS-2/NRCELL-6
#     ...    ${dist3_actProactUlScheduling}=MRBTS-5388/NRBTS-2/NRCELL-7
#     ...    ${dist4_actProactUlScheduling}=MRBTS-5388/NRBTS-2/NRCELL-8
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
#     ${modify5}    Create Dictionary    dist_name=MRBTS-5388/NRBTS-2
#     ...    parameter=actCarrierAggregation    value=true
#     ${modify6}    Create Dictionary    dist_name=MRBTS-5388/NRBTS-2
#     ...    parameter=caConfigurationSupport    value=4CCDL_2CCUL
#     @{modify_param}    Create List     ${modify1}    ${modify2}    ${modify3}    ${modify4}    ${modify5}    ${modify6}
#     COAM Update several parameters via rest api    parameters_to_update_via_api=${modify_param}    connection=${conn}    timeout=600
# #    perform muti Parameter recommissioning    dist_name=${dist1_actProactUlScheduling}    parameter=${parameter}
# #    ...    value=${value}    operation=update
# #    perform muti Parameter recommissioning    dist_name=${dist2_actProactUlScheduling}    parameter=${parameter}
# #    ...    value=${value}    operation=update
# #    perform muti Parameter recommissioning    dist_name=${dist3_actProactUlScheduling}    parameter=${parameter}
# #    ...    value=${value}    operation=update
# #    perform muti Parameter recommissioning    dist_name=${dist4_actProactUlScheduling}    parameter=${parameter}
# #    ...    value=${value}    operation=update
# #    perform muti Parameter recommissioning    dist_name=MRBTS-5388/NRBTS-2    parameter=actCarrierAggregation
# #    ...    value=true    operation=update
# #    perform muti Parameter recommissioning    dist_name=MRBTS-5388/NRBTS-2    parameter=caConfigurationSupport
# #    ...    value=4CCDL_2CCUL    operation=update
#     [Teardown]    Disconnect from DU
# 
# #Change the configure true_22R3
# #    [Arguments]    ${value}=false    ${dist1_actProactUlScheduling}=MRBTS-5388/NRBTS-2/NRCELL-5
# #    ...    ${dist2_actProactUlScheduling}=MRBTS-5388/NRBTS-2/NRCELL-6
# #    ...    ${dist3_actProactUlScheduling}=MRBTS-5388/NRBTS-2/NRCELL-7
# #    ...    ${dist4_actProactUlScheduling}=MRBTS-5388/NRBTS-2/NRCELL-8
# #    ...    ${parameter}=actProactUlScheduling
# #    Connect to DU
# #    perform muti Parameter recommissioning    dist_name=${dist1_actProactUlScheduling}    parameter=${parameter}
# #    ...    value=${value}    operation=update
# #    perform muti Parameter recommissioning    dist_name=${dist2_actProactUlScheduling}    parameter=${parameter}
# #    ...    value=${value}    operation=update
# #    perform muti Parameter recommissioning    dist_name=${dist3_actProactUlScheduling}    parameter=${parameter}
# #    ...    value=${value}    operation=update
# #    perform muti Parameter recommissioning    dist_name=${dist4_actProactUlScheduling}    parameter=${parameter}
# #    ...    value=${value}    operation=update
# #    perform muti Parameter recommissioning    dist_name=MRBTS-5388/NRBTS-2    parameter=actCarrierAggregation
# #    ...    value=true    operation=update
# #    perform muti Parameter recommissioning    dist_name=MRBTS-5388/NRBTS-2    parameter=caConfigurationSupport
# #    ...    value=4CCDL_2CCUL    operation=update
# #    [Teardown]    Disconnect from DU
# 
# #Change the configure true_22R2
# #    [Arguments]    ${value}=false    ${dist_actProactUlScheduling}=MRBTS-5388/NRBTS-2/NRCELLGRP-2
# #    ...    ${parameter}=actProactUlScheduling
# #    Connect to DU
# #    perform muti Parameter recommissioning    dist_name=${dist_actProactUlScheduling}    parameter=${parameter}
# #    ...    value=${value}    operation=update
# #    perform muti Parameter recommissioning    dist_name=MRBTS-5388/NRBTS-2    parameter=actCarrierAggregation
# #    ...    value=true    operation=update
# #    perform muti Parameter recommissioning    dist_name=MRBTS-5388/NRBTS-2    parameter=caConfigurationSupport
# #    ...    value=4CCDL_2CCUL    operation=update
# #    [Teardown]    Disconnect from DU
# 
# Change the configure true_22R1_22R2
#     [Arguments]    ${value}=false    ${dist_actProactUlScheduling}=MRBTS-5388/NRBTS-2/NRCELLGRP-2
#     ...    ${parameter}=actProactUlScheduling
#     ${conn}    Connect to DU
#     ${modify1}    Create Dictionary    dist_name=${dist_actProactUlScheduling}
#     ...    parameter=${parameter}    value=${value}
#     ${modify2}    Create Dictionary    dist_name=MRBTS-5388/NRBTS-2
#     ...    parameter=actCarrierAggregation    value=true
#     ${modify3}    Create Dictionary    dist_name=MRBTS-5388/NRBTS-2
#     ...    parameter=caConfigurationSupport    value=4CCDL_2CCUL
#     @{modify_param}    Create List     ${modify1}    ${modify2}    ${modify3}
#     COAM Update several parameters via rest api    parameters_to_update_via_api=${modify_param}    connection=${conn}    timeout=600
# #    perform muti Parameter recommissioning    dist_name=${dist_actProactUlScheduling}    parameter=${parameter}
# #    ...    value=${value}    operation=update
# #    perform muti Parameter recommissioning    dist_name=MRBTS-5388/NRBTS-2    parameter=actCarrierAggregation
# #    ...    value=true    operation=update
# #    perform muti Parameter recommissioning    dist_name=MRBTS-5388/NRBTS-2    parameter=caConfigurationSupport
# #    ...    value=4CCDL_2CCUL    operation=update
#     [Teardown]    Disconnect from DU
# 
# check 4UE tti trace
#     [Arguments]    ${UL_DL_csv_file_path_dict}    ${direction}    ${cell_id}=229    ${ue_number}=${3}
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
#     Adjust Enb    index=3   dist_name=MRBTS-${tl.enbs[0].global_bts_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-1
#     ...    parameter=defaultLnRelGnbCellId
#     run keyword and ignore error    CI_interface.Common Case Teardown
#     robot_common_operations.Common Case Teardown
# 
# Perform RU Lock And Check RU State
#     [Documentation]   Auther: Stella.lin@nokia-sbell.com
#     [Arguments]    ${bts_host}    ${ru_index}=${1}   ${download_dir}=${output_dir}
#     ${ru_index}  Convert To Integer    ${ru_index}
#     COAM Navigate to login page via webUI    url=https://${bts_host}    download_dir=${download_dir}
#     selenium_coam.lock_ru  ru_index=${ru_index}
#     Sleep   30 sec
#     Check RU State    bts_host=${bts_host}    state=${1}    ru_index=${ru_index}
#     [Teardown]  COAM selenium logout
# 
# Perform RU UnLock And Check RU State
#     [Documentation]   Auther: Stella.lin@nokia-sbell.com
#     [Arguments]    ${bts_host}    ${ru_index}=${1}   ${download_dir}=${output_dir}
#     ${ru_index}  Convert To Integer    ${ru_index}
#     COAM Navigate to login page via webUI    url=https://${bts_host}    download_dir=${download_dir}
#     selenium_coam.unlock_ru  ru_index=${ru_index}
#     Sleep   30 sec
#     Check RU State    bts_host=${bts_host}    state=${0}    ru_index=${ru_index}
#     [Teardown]  COAM selenium logout
# 
# Check RU State
#     [Arguments]  ${bts_host}    ${state}    ${ru_index}=${1}    ${connection}=GNB_OAM
#     Connect to gnb coam via ssl    bts_host=${bts_host}    username=${WEBEM_USERNAME}    password=${WEBEM_PASSWORD}
#     ...    connection=${connection}
#     Run Keyword If     '${state}'=='1'    RU Should Be Locked     ru_index=${ru_index}    connection=${connection}
#     Run Keyword If     '${state}'=='0'    RU Should Be Unlocked     ru_index=${ru_index}    connection=${connection}
#     [Teardown]    Run Keyword And Ignore Error   coam.Teardown  connection=${connection}
# 
# CB007403 Suite Teardown
#     robot_common_operations.Common Suite Teardown
#     Perform RU UnLock And Check RU State    bts_host=${gNB_ip1}
