*** Settings ***
Documentation
...    author: Ji Jian
...    contact: jian.ji@nokia-sbell.com
...    Group: HGZ_SG2

Library     taf.sw.dcap.rd               WITH NAME    rd
Library     taf.analyzer.pcap            WITH NAME    pcap
Library     taf.sbts.oam.coam.admin      WITH NAME    coam
#Library     taf.hw.channel_emulator     WITH NAME    Vertex
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/image_output.py
Library     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001655/Resources/py_script.py
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG2/Resources/spark_license.py
Resource    taf/rfrl/common_resources/robot/coam_selenium.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/btslog.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/log/l1l2bip_collect.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/gnb_classical_hangzhou.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BIP_trace/BIP_trace_collector.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/alarm_checking.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/Power_ue_supports/power_ue_throughput.robot

*** Variables ***
${tmp_swconfig_dir}            /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/swconfig.txt
${MR_NR_NAME}                  MRBTS-${tl.gnbs[0].global_bts_id}/NRBTS-${tl.gnbs[0].global_bts_id}
${MR_NR_NRPMRNL_NAME}          MRBTS-${tl.gnbs[0].global_bts_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRPMRNL-1
${MR_NR_CELLGRP_NAME}          MRBTS-${tl.gnbs[0].global_bts_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELLGRP-0
${MR_NR_NRSYSINFO_NAME}        MRBTS-${tl.gnbs[0].global_bts_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRSYSINFO_PROFILE-1
${MR_NR_CELL_NAME}             MRBTS-${tl.gnbs[0].global_bts_id}/NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-${tl.gnbs[0].instance_id}
${arti}                        https://artifactory-espoo1.int.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release/
${bip_log}                     bip_log
@{btslog_dirs}                 /opt/btslog     /opt/ute/tools/btslog      none
${ue_index}                    0
${ul_port}                     ${tl.appserver.iperf_details.port}
${dl_port}                     ${tl.ues[0].iperf_details.port}
${tmp_swconfig_dir_bak}        /home/ute/Downloads/swconfig/swconfig_bak.txt
${TSHARK_PATH}                 /usr/bin/tshark
${gnb_index}                   0
${dcap_user}                   dcapuser
${dcap_password}               dcapadmin!
${rd_version}                  dcapv1
${bts_host}                    ${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
${bts_username}                ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
${bts_password}                ${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
${apn1}                        wap1.nokia.com

*** Keywords ***

#------------------------------------------------Suite Setup------------------------------------------------#

Common Suite Setup for COAM
    Run Keyword And Continue On Failure    Generate suite log path
    Run Keyword And Continue On Failure    Connect to gnb coam via ssl
    Run Keyword And Continue On Failure    Get relevant suite variable
    Run Keyword And Continue On Failure    Recover swconfig file
    Run Keyword And Continue On Failure    COAM Commission with scf file     scf_file_path=${_scf_file_path_4x4}
    Run Keyword And Continue On Failure    Reset UE for andriod    ue_index=${ue_index}
    COAM Wait for gnb ready and cell setup     timeout=20 min    gnb_type='SA'
    Run Keyword And Continue On Failure    robot_common_operations.Common Suite Setup
    Run Keyword And Continue On Failure    COAM Teardown gnb connections
    
Common Suite Teardown for COAM
    Run Keyword And Continue On Failure    Clear Needless Files
    Run Keyword And Continue On Failure    robot_common_operations.Common Suite Teardown
    Run Keyword and ignore error    COAM Teardown gnb connections

#------------------------------------------------Case Setup------------------------------------------------#

Case Setup
    COAM Create log directory
    Run Keyword And Continue On Failure    Connect to gnb coam via ssl
    Run Keyword And Continue On Failure    Aasyslog precondition    aa_sys_mode=5    aa_sys_addr=0xC0A8FF7E    aa_sys_udp_port=0xC738
    Run Keyword And Continue On Failure	   Btslog Setup Collector
    ${onair_status}    Run keyword and Return Status    COAM Check GNB cell on air
    Run Keyword And Continue On Failure    robot_common_operations.Common Case Setup
    Run keyword If    ${onair_status}==${False}    Perform BTS Site Reset
    COAM Wait for gnb ready and cell setup    gnb_type='SA'
    Run Keyword And Continue On Failure     COAM Teardown gnb connections

Case Teardown
    Run Keyword And Continue On Failure    Connect to gnb coam via ssl
    Run Keyword And Continue On Failure    Run Keyword If Test Failed
    ...    COAM Save snapshot via rest api    connection=GNB_OAM    log_path=${LOG_PATH}    timeout=${600}
    Run Keyword And Continue On Failure    Btslog Teardown Collector
    Run Keyword And Continue On Failure    CI_interface.Common Case Teardown
    Run Keyword And Continue On Failure    robot_common_operations.Common Case Teardown
    Run keyword and ignore error    COAM Teardown gnb connections

#------------------------------------------------Attach------------------------------------------------#

Common UE Attach
    [Arguments]    ${ue_index}=${0}    ${attach_mode}=5G_SA
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    #Check eNB and start collect X2 log on enb_lte
    Sleep    3s
    ${5Grach_ed}    Run Keyword And Return Status    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    attach_mode=${attach_mode}
    ${status}    run keyword and return status    wait until keyword succeeds    8min    30s    Get UE ip
    Run Keyword If    '${status}'=='False'    Run Keyword And Continue On Failure    Reset UE for andriod    ue_index=${ue_index}
    Run Keyword If    '${status}'=='False'    wait until keyword succeeds     3min    10s    Get UE ip
#    ${5Grach_status}    Run Keyword And Continue On Failure
#    ...    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=False
#    log to console     \n 5Grach_status=${5Grach_status[0]}
#    [Teardown]    Run Keyword And Continue On Failure     Run keywords    Common Capture BIP log and download to testPC
#    ...    AND    Check eNB and stop and download X2 log on enb_lte

#------------------------------------------------Throughput------------------------------------------------#

Start DLUL traffic and Capture BIP
    [Arguments]     ${data_transfer_dl}     ${data_transfer_ul}     ${Expected_Throughput_DL}     ${Expected_Throughput_UL}
    ...     ${bip_log}     ${buffer_size}=1400B
    Get UE Type for Power UE from File
    Wait until keyword succeeds    10 min    5 s    Common UE Attach
    Run Keyword And Continue On Failure    Wait until keyword succeeds    5 min    5 s     power_ue.Start traffic
    ...    ue_type=${ue_type}     direction=ul     throughput=${data_transfer_ul}
    ...    duration=900     iperf_port=${ul_port}     buffer_size=${buffer_size}
    Run Keyword And Continue On Failure    power_ue.Start traffic     ue_type=${ue_type}     direction=dl     throughput=${data_transfer_dl}
    ...    duration=900     iperf_port=${dl_port}     buffer_size=${buffer_size}
    Sleep    10s
	${tput_log}    Run Keyword And Continue On Failure    power_ue.Collect Tput    ue_type=${ue_type}    duration=2m
    #------------------------------------------------Check UL Tput------------------------------------------------#
	${real_ul_tput}    Run Keyword And Continue On Failure    power_ue.Check Tput
    ...    ue_type=${ue_type}    direction=UL    cells=${list_of_cell_ids}    log=${tput_log}    target_throughput=${Expected_Throughput_UL}
    Log To Console    \nreal_ul_tput=${real_ul_tput}\n
    #------------------------------------------------Check DL Tput------------------------------------------------#
	${real_dl_tput}    Run Keyword And Continue On Failure    power_ue.Check Tput
    ...    ue_type=${ue_type}    direction=DL    cells=${list_of_cell_ids}    log=${tput_log}    target_throughput=${Expected_Throughput_DL}
    Log To Console    \nreal_dl_tput=${real_dl_tput}\n
    #------------------------------------------------Check DL Tput------------------------------------------------#
    Run Keyword And Continue On Failure    Wait until keyword succeeds    1 min    3 s    Common Capture BIP log and download to testPC
    Run Keyword And Continue On Failure    Aasyslog precondition    aa_sys_mode=5    aa_sys_addr=0xC0A8FF7E    aa_sys_udp_port=0xC738
    Run Keyword and ignore error    Check channel quality in BIP    pcap_file=${bip_log_path}
    [Teardown]     Run Keyword And Continue On Failure     Run keywords
    ...    power_ue.Stop traffic     ue_type=${ue_type}     direction=ul     iperf_port=${ul_port}
    ...    AND     power_ue.Stop traffic     ue_type=${ue_type}     direction=dl     iperf_port=${dl_port}
    ...    AND     power_ue.UE Detach     ue_type=${ue_type}

Start Getting Tput List
    [Arguments]     ${nr_cell_index}=1     ${gnb_index}=0     ${asik_alias}=ASIK Master     ${du_index}=0
    ${nr_cell_index}     Convert to integer     ${nr_cell_index}
    Connect to gnb coam via ssl
    Connect to Common Unit Master
    ${timestamp}     Get time from GNB     asik_alias=${asik_alias}
    ${tput_log_file_path_gnb}     Start tput log capture     gnb_index=${gnb_index}     asik_alias=${asik_alias}     du_index=${du_index}
    set test variable    ${tput_log_file_path_gnb}
    [Return]     ${tput_log_file_path_gnb}

Stop And Save Getting Tput List
    [Arguments]     ${nr_cell_index}=1     ${gnb_index}=0     ${asik_alias}=ASIK Master    ${max_retry_time}=5
    ...    ${local_log_folder}=${TS_CASE_LOG_PATH}     ${gnb_ssl_connection}=GNB_OAM
    FOR     ${time}     IN RANGE     ${max_retry_time}
        @{saved_tput_file_list}     Split tput log to ul and dl files     gnb_index=${gnb_index}
        ...     asik_alias=${asik_alias}     tput_log_file_path_gnb_combined=${tput_log_file_path_gnb}
        ${are_tput_file_generated_successfully}     check_average_throughput.are_tuput_files_neither_empty
        ...     list_file_path=${saved_tput_file_list}     asik_alias=${asik_alias}
        Run keyword if     ${are_tput_file_generated_successfully}==${False}     Run keywords     Log to console
        ...     No content captured in throughput file, will try capturing
        ...     AND     Sleep     5 s
        ...     ELSE     exit for loop
    END
    wait until keyword succeeds     10s     200ms     check_average_throughput.stop_tput_aasyslog_capturing     asik_alais=${asik_alias}
    ${are_tput_file_generated_successfully}     check_average_throughput.are_tuput_files_neither_empty
    ...     list_file_path=${saved_tput_file_list}     asik_alias=${asik_alias}
    Should be true     ${are_tput_file_generated_successfully}
    ...     msg=Throughput file are not generated with content even with ${max_retry_time} times retry
    &{dict_local_tput_file_path}     Download tput file to test pc     ul_dl_tput_file_paths_gnb=${saved_tput_file_list}
    ...     local_log_folder=${local_log_folder}     asik_alias=${asik_alias}
    &{ul_tput}     check_average_throughput.get_tput_info_for_l2lo     tput_file=${dict_local_tput_file_path['UL_L2LO']}
    &{dl_tput}     check_average_throughput.get_tput_info_for_l2lo     tput_file=${dict_local_tput_file_path['DL_L2LO']}
    &{cell_mapping}     coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids     connection_alias=${gnb_ssl_connection}
    ${nrCellIdentity}     Set variable     ${cell_mapping[${nr_cell_index}]['nrCellIdentity']}
    ${ul_tput_list}    Set variable    ${ul_tput[${nrCellIdentity}]['detail_tput_info']}
    Set test variable    ${ul_tput_list}
    ${dl_tput_list}    Set variable    ${dl_tput[${nrCellIdentity}]['detail_tput_info']}
    Set test variable    ${dl_tput_list}
    [Teardown]     Run Keyword And Continue On Failure     Run keywords    
    ...    check_average_throughput.stop_tput_aasyslog_capturing     asik_alais=${asik_alias}
    ...    AND    Csn.Disconnect    connection=ASIK Master
    ...    AND    COAM Teardown gnb connections
    [Return]    ${ul_tput_list}     ${dl_tput_list}

Get dl tput list from GNB
    [Arguments]     ${nr_cell_index}=1     ${duration}=300s     ${max_retry_time}=2     ${local_log_folder}=${TS_CASE_LOG_PATH}     ${gnb_index}=0
    ...     ${gnb_ssl_connection}=GNB_OAM     ${asik_alias}=ASIK Master     ${du_index}=0
    ${nr_cell_index}     Convert to integer     ${nr_cell_index}
    Connect to gnb coam via ssl
    Connect to Common Unit Master
    ${timestamp}     Get time from GNB     asik_alias=${asik_alias}
    @{saved_tput_file_list}     Run Keyword And Continue On Failure     Retry log capturing if file content is empty     gnb_index=${gnb_index}
    ...     duration=${duration}     max_retry_time=${max_retry_time}     asik_alias=${asik_alias}     du_index=${du_index}
    &{dict_local_tput_file_path}     Download tput file to test pc     ul_dl_tput_file_paths_gnb=${saved_tput_file_list}
    ...     local_log_folder=${local_log_folder}     asik_alias=${asik_alias}
    &{dl_tput}     check_average_throughput.get_tput_info_for_l2lo     tput_file=${dict_local_tput_file_path['DL_L2LO']}
    &{cell_mapping}     coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids     connection_alias=${gnb_ssl_connection}
    ${nrCellIdentity}     Set variable     ${cell_mapping[${nr_cell_index}]['nrCellIdentity']}
    ${dl_tput_list}    Set variable    ${dl_tput[${nrCellIdentity}]['detail_tput_info']}
    Set test variable    ${dl_tput_list}
    Log to console        \ndl_tput_list=\n${dl_tput_list}
    image_output    lists=${dl_tput_list}    output_dir=${LOG_PATH}
    [Teardown]     Run Keyword And Continue On Failure     Run keywords    
    ...   check_average_throughput.stop_tput_aasyslog_capturing     asik_alais=${asik_alias}
    ...    AND    Csn.Disconnect    connection=ASIK Master
    ...    AND    COAM Teardown gnb connections
    [Return]     ${dl_tput_list}

Start Capture Aasyslog
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${type}=MCU   ${duration}=600s
    ...            ${log_ip}=127.0.0.1    ${gnb_path}=/tmp/    ${log_name}=aasys_tput.txt
    ...            ${aa_sys_mode}=2    ${aa_sys_addr}=0x7F000001    ${aa_sys_udp_port}=0xC738    ${filter}=${EMPTY}
    ...            ${host}=${EMPTY}
    ...            ${username}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...            ${password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ${host}   Run Keyword If   '${host}'==''   Get Host IP from gNB   gnb_index=${gnb_index}   du_index=${du_index}
    ...    ELSE   Set Variable   ${host}
    Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
    ...                                    host=${host}    username=${username}    password=${password}
    Aasyslog precondition    gnb_index=${gnb_index}    du_index=${du_index}    type=${type}
    ...                      aa_sys_mode=${aa_sys_mode}    aa_sys_addr=${aa_sys_addr}    aa_sys_udp_port=${aa_sys_udp_port}
    ...                      host=${host}    username=${username}    password=${password}
    Start the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}    filter=${filter}
    ...                                 gnb_path=${gnb_path}    log_name=${log_name}
    ...                                 host=${host}    username=${username}    password=${password}
    ...                                 log_ip=${log_ip}    timeout=${duration}

Stop Capture Aasyslog
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${Teardown_after_finished}=${True}
    ...            ${gnb_path}=/tmp/    ${log_name}=aasys_tput.txt
    ...            ${host}=${EMPTY}
    ...            ${username}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...            ${password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ${current_time}    DateTime.Get Current Date
    ${local_path}    set variable    ${OUTPUT_DIR}/${current_time}_${log_name}
    Download Aasyslog File From GNB    log_path=${gnb_path}${log_name}    local_path=${local_path}
    ...                                gnb_index=${gnb_index}    du_index=${du_index}
    ...                                host=${host}    username=${username}    password=${password}
	set test variable    ${local_path}
    [Teardown]    Run Keyword And Ignore Error    Run keywords
    ...    Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
    ...    host=${host}    username=${username}    password=${password}
    ...    AND    COAM Teardown gnb connections
    [Return]    ${local_path}

Check Aasyslog Throughput
    #------------------------------------------------Check UL Tput------------------------------------------------#
	${real_ul_tput}    Run Keyword And Continue On Failure    power_ue_throughput.__Standard Check Aasyslog Throughput
    ...    direction=ul    cells=${list_of_cell_ids}    log=${local_path}
    ...    target_throughput=${Expected_Throughput_UL}
    ${real_ul_tput}    set variable    ${real_ul_tput[0]['average']}
    Log To Console    \nreal_ul_tput=${real_ul_tput}\n	
    #------------------------------------------------Check DL Tput------------------------------------------------#
    ${real_dl_tput}    Run Keyword And Continue On Failure    power_ue_throughput.__Standard Check Aasyslog Throughput
    ...    direction=dl    cells=${list_of_cell_ids}    log=${local_path}
    ...    target_throughput=${Expected_Throughput_DL}
    ${real_dl_tput}    set variable    ${real_dl_tput[0]['average']}
    Log To Console    \nreal_dl_tput=${real_dl_tput}\n	

#---------------------------------------------------------Adjust PA ---------------------------------------------------------#	

Adjust PA Value One By One
    [Arguments]    ${start}=0     ${end}=90    ${step}=1
    ${attenuation_port_numbers}    gnb_classical_hangzhou.Get Attenuation Channels For RU
    Set Test Variable    ${attenuation_port_numbers}
    FOR    ${att_value}    IN RANGE    ${start}    ${end}    ${step}
        Adjust PA Value One Step    attenuation_port_numbers=${attenuation_port_numbers}    att_value=${att_value}    step=${step}
    END

Adjust PA Value One Step
    [Arguments]    ${attenuation_port_numbers}    ${att_value}    ${step}
    FOR    ${port}    IN    @{attenuation_port_numbers}
        Wait until keyword succeeds    3 min    5 s    attenuator.Set Attenuation    port=${port}    value=${att_value} 
        gnb_classical_hangzhou.Verify Attenuation Value is updated    port=${port}    value=${att_value}
    END
    sleep    ${step}s
    Log To Console    \n change attenuation ${attenuation_port_numbers} to ${att_value}
	
Get Initial Attenuation Values
    [Arguments]    ${RU_id}=0    ${vendor}=TopYoung    ${gnb_id}=0    ${att_id}=${None}
    ${attenuation_port_numbers} =     gnb_classical_hangzhou.Get Attenuation Channels For RU    RU_id=${RU_id}    gnb_id=${gnb_id}
    Set Test Variable    ${attenuation_port_numbers}
    ${att_obj_in_ru_port}    Set Variable    ${tl.gnbs[${gnb_id}].dus[0].rus[${RU_id}].attenuation_ports[0].attenuator}
    ${att_index}    Get Index From List    ${tl.attenuators}    ${att_obj_in_ru_port}
    ${is_single_att_used}    Get Variable Value    ${tl.attenuator.vendor}
    ${ip_addr}    set variable if    '${is_single_att_used}'!='${None}'    ${tl.attenuator.ip_addr}    ${tl.attenuators[${att_index}].ip_addr}
    ${port}    set variable if    '${is_single_att_used}'!='${None}'    ${tl.attenuator.port}    ${tl.attenuators[${att_index}].port}
    ${vendor}    set variable if    '${is_single_att_used}'!='${None}'    ${tl.attenuator.vendor}    ${tl.attenuators[${att_index}].vendor}
    ${model}    set variable if    '${is_single_att_used}'!='${None}'    ${tl.attenuator.model}    ${tl.attenuators[${att_index}].model}
    ${configured_attenuator}    attenuator.setup_attenuator
    ...    ip_addr=${ip_addr}
    ...    port=${port}
    ...    attenuation_port_numbers=${attenuation_port_numbers}
    ...    vendor=${vendor}
    ...    model=${model}
    Set Test Variable    ${configured_attenuator}
    ${initial_att_values}    Create List
    FOR  ${port}    IN    @{attenuation_port_numbers}
       ${values}=    attenuator.read_attenuation     port=${port}    attenuator_device=${configured_attenuator}
       ${values} =    Convert To Integer    ${values}
       Append To List     ${initial_att_values}     ${values}
    END
    Set Test Variable    ${initial_att_values}
    [Return]    ${initial_att_values}
	
Restore Attenuation Values
    [Arguments]    ${initial_att_values}    ${RU_id}=0    ${vendor}=TopYoung    ${gnb_id}=0
    ${attenuation_port_numbers} =     gnb_classical_hangzhou.Get Attenuation Channels For RU    RU_id=${RU_id}    gnb_id=${gnb_id}
    Set Test Variable    ${attenuation_port_numbers}
    ${att_obj_in_ru_port}    Set Variable    ${tl.gnbs[${gnb_id}].dus[0].rus[${RU_id}].attenuation_ports[0].attenuator}
    ${att_index}    Get Index From List    ${tl.attenuators}    ${att_obj_in_ru_port}
    ${is_single_att_used}    Get Variable Value    ${tl.attenuator.vendor}
    ${ip_addr}    set variable if    '${is_single_att_used}'!='${None}'    ${tl.attenuator.ip_addr}    ${tl.attenuators[${att_index}].ip_addr}
    ${port}    set variable if    '${is_single_att_used}'!='${None}'    ${tl.attenuator.port}    ${tl.attenuators[${att_index}].port}
    ${vendor}    set variable if    '${is_single_att_used}'!='${None}'    ${tl.attenuator.vendor}    ${tl.attenuators[${att_index}].vendor}
    ${model}    set variable if    '${is_single_att_used}'!='${None}'    ${tl.attenuator.model}    ${tl.attenuators[${att_index}].model}
    ${configured_attenuator}    attenuator.setup_attenuator
    ...    ip_addr=${ip_addr}
    ...    port=${port}
    ...    attenuation_port_numbers=${attenuation_port_numbers}
    ...    vendor=${vendor}
    ...    model=${model}
    Set Test Variable    ${configured_attenuator}
    FOR    ${port}    ${value}    IN ZIP    ${attenuation_port_numbers}    ${initial_att_values}
        ${value} =    Convert To Integer    ${value}
        wait until keyword succeeds   5 min   5 sec    attenuator.Set Attenuation    port=${port}    value=${value}
        gnb_classical_hangzhou.Verify Attenuation Value is updated    port=${port}    value=${value}
    END

Setup Attenuation
    [Arguments]    ${RU_id}=0    ${vendor}=TopYoung    ${gnb_id}=0
    ${attenuation_port_numbers} =     gnb_classical_hangzhou.Get Attenuation Channels For RU    RU_id=${RU_id}    gnb_id=${gnb_id}
    Set Test Variable    ${attenuation_port_numbers}
    ${att_obj_in_ru_port}    Set Variable    ${tl.gnbs[${gnb_id}].dus[0].rus[${RU_id}].attenuation_ports[0].attenuator}
    ${att_index}    Get Index From List    ${tl.attenuators}    ${att_obj_in_ru_port}
    ${is_single_att_used}    Get Variable Value    ${tl.attenuator.vendor}
    ${ip_addr}    set variable if    '${is_single_att_used}'!='${None}'    ${tl.attenuator.ip_addr}    ${tl.attenuators[${att_index}].ip_addr}
    ${port}    set variable if    '${is_single_att_used}'!='${None}'    ${tl.attenuator.port}    ${tl.attenuators[${att_index}].port}
    ${vendor}    set variable if    '${is_single_att_used}'!='${None}'    ${tl.attenuator.vendor}    ${tl.attenuators[${att_index}].vendor}
    ${model}    set variable if    '${is_single_att_used}'!='${None}'    ${tl.attenuator.model}    ${tl.attenuators[${att_index}].model}
    ${configured_attenuator}    attenuator.setup_attenuator
    ...    ip_addr=${ip_addr}
    ...    port=${port}
    ...    attenuation_port_numbers=${attenuation_port_numbers}
    ...    vendor=${vendor}
    ...    model=${model}
    Set Test Variable    ${configured_attenuator}

#------------------------------------------------BIP------------------------------------------------#
Start Bip Capture for all release
    [Arguments]    ${target_file_name}=l1l2bip_log
    ...            ${nr_phy_cell_ids}=${None}
    ...            ${gnb_index}=0
    ...            ${timeout}=900
    ...            ${interface}=L1-L2
    ...            ${destination}=Local
    Run Keyword If    '${program}'=='SBTS23R1'    Collect Interface Mirroring Bip Collector
    ...                                target_file_name=${target_file_name}
    ...                                nr_phy_cell_ids=${nr_phy_cell_ids}
    ...                                gnb_index=${gnb_index}
    ...                                timeout=${timeout}
    ...                                interface=${interface}
    ...                                destination=${destination}
    ...                                host_ip=${bts_host}
    ...                                username=${bts_username}
    ...                                password=${bts_password}
    ...       ELSE    Bip Capture with gnbMirroring scripts with retry

Stop Bip Capture for all release
    [Arguments]      ${target_file_name}=l1l2bip_log    ${pattern}=*.pcap    ${target_dir}=${TS_CASE_LOG_PATH}
	${asib_interface}    set variable if  '${bbmod_type}'=='ABIO'    eths3    eths2    
    ${list_log_path_local}    Run Keyword If    '${program}'=='SBTS23R1'
    ...        Get Bip Log Via Interface Mirroring Collector
    ...        target_file_name=${target_file_name}
    ...        pattern=${pattern}
    ...        target_dir=${target_dir}
    ...        ELSE    Stop BIP capture on ASIK if needed and download BIP Logs to testPC    log_path=${target_dir}
    ...        asib_interface=${asib_interface}
    set test variable    ${bip_log_path}    ${list_log_path_local}[0]
    [Return]    ${bip_log_path}

Common Capture BIP log and download to testPC
    [Arguments]    ${duration}=3s
    Run Keyword And Continue On Failure    Start Bip Capture for all release
    Sleep    ${duration}
    [Teardown]    Run Keyword And Continue On Failure    Stop Bip Capture for all release
    [Return]    ${bip_log_path}	

Create Commission Parameter List
    [Arguments]     ${value_list}
    @{PARAMS_list}    Create list
    FOR    ${p_name}    ${value}    IN ZIP    ${p_name_list}    ${value_list}    
        ${PARAMS}    Create Dictionary    p_name=${p_name}    dist_name=${MR_NR_CELL_NAME}    value=${value}
        Append to list    ${PARAMS_list}    ${PARAMS}
    END
    Set test variable    ${PARAMS_list}

Create Update Parameter List
    [Arguments]     ${value_list}
    @{PARAMS_list}    Create list
    FOR    ${abbr}    ${filter_param}    ${value}    IN ZIP    ${abbr_list}    ${filter_param_list}    ${value_list}    
        ${PARAMS}    Create Dictionary    abbr=${abbr}    dist_name=${MR_NR_CELL_NAME}    filter_param=${filter_param}    new_value=${value}
        Append to list    ${PARAMS_list}    ${PARAMS}
    END
    Set test variable    ${PARAMS_list}

Modify Case SCF and Commission
    [Arguments]    ${PARAMS_TO_MODIFY_SCF}    ${scf_file}=${scf_file_path}
    ${new_scf_file}    COAM Modify scf file    scf_file_path=${scf_file}
    ...    scf_parameters_list=${PARAMS_TO_MODIFY_SCF}
    Connect to gnb coam via ssl
    Run Keyword And Continue On Failure    COAM Commission with scf file    scf_file_path=${new_scf_file}
    Remove File    ${new_scf_file}
    COAM Wait for gnb ready and cell setup    timeout=20 min    gnb_type='SA'
    COAM Teardown gnb connections

Check eNB and start collect X2 log on enb_lte
    ${enbs}    testline_info.has_enb    tl=${tl}
    Run Keyword If    ${enbs}    Start to collect the X2 log on eNB

Check eNB and stop and download X2 log on enb_lte
    ${enbs}    testline_info.has_enb    tl=${tl}
    Run Keyword If    ${enbs}    Stop and download X2 Logs on eNB

Start to Capture X2 Log on Asik
    [Arguments]    ${filename}
    Connect to Common Unit Master
    csn.send command    command=killall tcpdump    connection=ASIK Master
    Start to Capture wireshark Log    listen_port=fp0    log_dir=${gnb_tmp_log_dir}    filename=${filename}
    ...    connection=ASIK Master

Start to Capture wireshark Log
    [Arguments]    ${listen_port}    ${log_dir}    ${filename}    ${connection}
    csn.send command    command=tcpdump -n -i ${listen_port} -w ${log_dir}/${filename} &>/dev/null &
    ...    connection=${connection}
    sleep    3s

Modify parameters in swconfig file
    [Arguments]    ${params}    ${Local_filePath}=${tmp_swconfig_dir}
    Connect to Common Unit Master
    Copy File    ${tmp_swconfig_dir}    ${tmp_swconfig_dir_bak}
    Modify_swConfig_file    parametersList=@{params}    filePath=${Local_filePath}
    Upload_swConfig_file_to_asik_and_crasign    localFilePath=${Local_filePath}    asik_alias=ASIK Master
    Copy File    ${tmp_swconfig_dir_bak}    ${tmp_swconfig_dir}
    Run Keyword And Continue On Failure     Csn.Disconnect     connection=ASIK Master

Modify Swconfig and SCF
    [Arguments]    ${sw_params}    ${SCF}    ${scf_file}=${scf_file_path}
    Modify parameters in swconfig file    params=${sw_params}
    Modify Case SCF and Commission    PARAMS_TO_MODIFY_SCF=${SCF}    scf_file=${scf_file}
    COAM Wait for gnb ready and cell setup    timeout=15 min    gnb_type='SA'

Get PARAM Value from Wireshark Log
    [Arguments]    ${check_param}    ${element_idx}=${0}    ${default_value}=False    ${condition_expression}=${None}
    ${value}=    cap.Get Element Value    element_expression=${check_param}    element_idx=${element_idx}
    ...    default_value=${default_value}    condition_expression=${condition_expression}
    [Return]    ${value}

Read Wireshark Log
    [Arguments]    ${filename}    ${filter}=${None}
    cap.Read Cap    cap_file=${LOG_PATH}/${filename}    display_filter=${filter}

Recover swconfig file
    Connect to Common Unit Master
    Upload_swConfig_file_to_asik_and_crasign    localFilePath=${tmp_swconfig_dir}    asik_alias=ASIK Master
    Run Keyword And Continue On Failure     Csn.Disconnect     connection=ASIK Master

Wait cell OnAir
    wait until keyword succeeds    10x    1min    COAM Check GNB cell on air

Get Current Parameter Value By WEBUI
    [Arguments]    ${dist_name}    ${filter_param}    ${abbr}=${None}
    ...    ${node_index}=${None}    ${timeout}=60
	COAM Navigate to login page via webUI     download_dir=${TS_CASE_LOG_PATH}
    ${current_value}    selenium_coam.get_parameter_value    dist_name=${dist_name}
    ...    filter_param=${filter_param}    node_index=${node_index}    abbr=${abbr}    timeout=${timeout}
    [Teardown]     Run Keyword And Continue On Failure     Run keywords     selenium_coam.logout
    ...     AND     selenium_coam.disable_virtual_display
    [Return]    ${current_value}

Login WEBUI
    [Arguments]    ${url}    ${username}=Nemuadmin    ${password}=nemuuser
    selenium_coam.login    url=${url}    username=${username}    password=${password}

Set Parameter Value By WEBUI
    [Arguments]    ${dist_name}    ${filter_param}    ${new_value}=${NULL}
    ...    ${node_index}=${NULL}    ${abbr}=${NULL}    ${timeout}=60
    selenium_coam.set_parameter_value    dist_name=${dist_name}    filter_param=${filter_param}
    ...    new_value=${new_value}    node_index=${node_index}    abbr=${abbr}    timeout=${timeout}

###Power_ue Keyword###
Get UE ip
    [Arguments]    ${ue_index}=${0}
    Get Commercial UE IP     ue_index=${ue_index}
    should not be empty     ${UE_IP}
    should not contain     ${UE_IP}     127.0.0.1

Reset UE for andriod
    [Arguments]     ${ue_index}     ${hostname}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...     ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc via cygwin     hostname=${hostname}     ue_index=${ue_index}
    csn.send_command     command=adb -s ${serial_number} reboot     connection=cygwin
    sleep     5s
    csn.disconnect     connection=cygwin

#------------------------------------------------Vertex------------------------------------------------#

Vertex Setup and Load Remote System Setting File
    [Arguments]     ${Vertex_Remote_System_Setting_File}     ${Vertex_Model}=${tl.channel_emulators.model}     ${Vertex_Alias}=Vertex_sg2
    ...     ${Vertex_Host}=${tl.channel_emulators.ip_addr}     ${Vertex_Port}=${tl.channel_emulators.port}     ${Vertex_Vendor}=spirent
    ...     ${Vertex_Proxy}=${tl.channel_emulators.proxy.addr}     ${Vertex_Proxy_User}=${tl.channel_emulators.proxy.username}
    ...     ${Vertex_Proxy_Pwd}=${tl.channel_emulators.proxy.password}
    Vertex.Setup     vendor=${Vertex_Vendor}     model=${Vertex_Model}     alias=${Vertex_Alias}     host=${Vertex_Host}     port=${Vertex_Port}
    ...     proxy=${Vertex_Proxy}     proxy_username=${Vertex_Proxy_User}     proxy_password=${Vertex_Proxy_Pwd}     timeout=${Vertex_Cmd_Timeout}
    Vertex.Load Remote System Setting File     ${Vertex_Remote_System_Setting_File}     emulator=${Vertex_Alias}
    sleep    60s

Load Remote IQPlayback and start
    [Arguments]     ${Vertex_Remote_Iq_Playback_File}     ${Vertex_Alias}=Vertex_sg2
    Vertex.Load Remote Iq Playback File     ${Vertex_Remote_Iq_Playback_File}     emulator=${Vertex_Alias}
    sleep    180s
    Vertex.Enable Iq Playback    emulator=${Vertex_Alias}
    sleep    120s
    Vertex.Start Channel Emulation     emulator=${Vertex_Alias}
    sleep    30s

Vertex Teardown
    [Arguments]    ${Vertex_Alias}=Vertex_sg2
    Vertex.Stop Channel Emulation     emulator=${Vertex_Alias}
    sleep    30s
    Vertex.Disable Iq Playback    emulator=${Vertex_Alias}
    sleep    30s
    Vertex.Teardown     emulator=${Vertex_Alias}

#------------------------------------------------Btslog------------------------------------------------#

Btslog Setup Collector
    Run Keyword And Continue On Failure     run     command=if [ ! -d /tmp/btslog2 ]; then mkdir /tmp/btslog2; fi
    btslog.create_btslog_collector
    ...   name=btslog
    ...   btslog_path=/opt/btslog/btslog
    ...   btslog_launcher_path=/opt/btslog/btslog_launcher
    ...   log_dir=/tmp/btslog2
    btslog.Set Global Alias     btslog
    core.setup_collectors      names=btslog
    core.start_collectors      names=btslog

Btslog Teardown Collector
    Run Keyword And Continue On Failure     Wait until keyword succeeds    2 min    5 s    core.teardown_collectors      names=btslog
    ${time_btslog}    Get timestamp
    set test variable	${time_btslog}
    run    command=cd /tmp/btslog2 ; ls -altr ; cat SYSLOG_*.LOG > SYSLOG_${time_btslog}.LOG
    run    command=cd /tmp/btslog2 ; mv SYSLOG_${time_btslog}.LOG ${LOG_PATH}/.
    run    command=cd /tmp/btslog2 ; rm -rf SYSLOG_*.LOG ; rm -rf SYSLOG_*.bin

#------------------------------------------------Btslog------------------------------------------------#
	
Get current program in WebUI
    ${current_software}     Wait until keyword succeeds    3 min    5 s    selenium_coam.check_current_software_version
	${program}    Set variable    ${current_software['Active'].split('_')[0]}
	set test variable    ${program}
    [Return]     ${program}
    
Check BTS Counters via webUI
    [Arguments]    ${counter_id}
    ${counters}    selenium_coam.get_bts_counters_info    counter_id=${counter_id}
    ${counters}    Get Dictionary Values    ${counters}
    [Return]    ${counters}

Get_parameter_value
    [Arguments]    ${abbr}    ${filter_param}    ${dist_name}=MRBTS-24/NRBTS-1024/NRCELL-1
    ${value}    selenium_coam.get_parameter_value    abbr=${abbr}    filter_param=${filter_param}    dist_name=${dist_name}
    [Return]    ${value}

#------------------------------------------------handle pcap file------------------------------------------------#
Creat pcap filter_expression
    ${filter_expression}	catenate    SEPARATOR=${EMPTY}
    ...    !(3gpp.rnti == 65535)
    set test variable    ${filter_expression}
    [return]    ${filter_expression}

Get Average UL MCS from BIP log
    Log To Console    \nGet Average UL MCS from BIP log\n
    ${mcs_ul}    pcap.get_field_value_by_xpath     xpath=.//UlData_puschReceiveReqGrant_t.mcs
    @{mcs_ul_list}    Create list
    ${sum_mcs_ul}    set variable    0
    FOR    ${value}    IN    @{mcs_ul}
	    ${mcs_ul}    Convert to integer    ${value}
        Append to list    ${mcs_ul_list}    ${mcs_ul}
        ${sum_mcs_ul}    Evaluate    ${sum_mcs_ul} + ${mcs_ul}
    END
    log to console    mcs_ul_list=\n${mcs_ul_list[:200]}\n
    ${count}    get length    ${mcs_ul_list}
    ${average_mcs_ul}    Run Keyword If    ${count}==0    Set Variable    ${0}    ELSE    Evaluate    ${sum_mcs_ul}.0/${count}.0
    ${average_mcs_ul}    Evaluate	round(${average_mcs_ul}, 1)
    log to console    average_mcs_ul=${average_mcs_ul}\n

Get Average DL MCS from BIP log
    Log To Console    \nGet Average DL MCS from BIP log\n
    @{mcs_dl}     pcap.get_field_value_by_xpath     xpath=.//DlData_PdschGrant.mcs
    @{mcs_dl_list}    Create list
    ${sum_mcs_dl}    set variable    0
    FOR    ${value}    IN    @{mcs_dl}
	    ${mcs_dl}    Convert to integer    ${value}
        Append to list    ${mcs_dl_list}    ${mcs_dl}
        ${sum_mcs_dl}    Evaluate    ${sum_mcs_dl} + ${mcs_dl}
    END
    log to console    mcs_dl_list=\n${mcs_dl_list[:200]}\n
    ${count}    get length    ${mcs_dl_list}
    ${average_mcs_dl}    Run Keyword If    ${count}==0    Set Variable    ${0}    ELSE    Evaluate    ${sum_mcs_dl}.0/${count}.0
    ${average_mcs_dl}    Evaluate	round(${average_mcs_dl}, 1)
    log to console    average_mcs_dl=${average_mcs_dl}\n

Get Bler from BIP log
    Log To Console    -------------------Check bler for ackNack-------------------
    ${ackNack_list}     Run Keyword And Continue On Failure    pcap.get_field_value_by_xpath     xpath=.//data.data
    ${ackNack_sum}    Get Length    ${ackNack_list}
    ${count_80}    Get Match Count    ${ackNack_list}    80:00:00:00:00:00:00
    ${count_c0}    Get Match Count    ${ackNack_list}    c0:00:00:00:00:00:00
    ${count_f0}    Get Match Count    ${ackNack_list}    f0:00:00:00:00:00:00
    ${count_f8}    Get Match Count    ${ackNack_list}    f8:00:00:00:00:00:00
    ${count_e0}    Get Match Count    ${ackNack_list}    e0:00:00:00:00:00:00
    ${count_00}    Get Match Count    ${ackNack_list}    00:00:00:00:00:00:00
    ${count_40}    Get Match Count    ${ackNack_list}    40:00:00:00:00:00:00	
    ${ack_sum}    Evaluate    ${count_80}+${count_c0}+${count_f0}+${count_f8}+${count_e0}
    ${Nack_sum}    Evaluate    ${ackNack_sum}-${ack_sum}
    ${bler_avg}    Run Keyword If    ${ackNack_sum}==0    Log To Console    ackNack_sum=0
    ...    ELSE    Evaluate    round(round(${Nack_sum},1)/round(${ackNack_sum},1),4)*100
    Log To Console    bler_avg=${bler_avg}%\n
    #  --------------------------------------------------------------------------#
    Log To Console    -------------------Check bler for rvIndex-------------------
    ${rvIndex_list}    pcap.get_field_value_by_xpath     xpath=.//DlData_PdschGrant.rvIndex
    ${rvIndex_sum}    Get Length    ${rvIndex_list}
    ${rvIndex_count_0}    Get Match Count    ${rvIndex_list}    0
    ${bler_rvIndex}    Run Keyword If    ${rvIndex_sum}==0    Log To Console    rvIndex_sum=0
    ...    ELSE    Evaluate    round(round(${rvIndex_sum}-${rvIndex_count_0},1)/round(${rvIndex_sum},1),4)*100
    Log To Console    bler_rvIndex=${bler_rvIndex}%\n
    #  --------------------------------------------------------------------------#
    Log To Console    -------------------Check bler for crc-------------------
    ${crc_list}    pcap.get_field_value_by_xpath     xpath=.//UlData_UePuschReceiveRespHarqU_t.crc
    ${crc_sum}    Get Length    ${crc_list}
    ${crc_count_1}    Get Match Count    ${crc_list}    1
    ${bler_ul}    Run Keyword If    ${crc_sum}==0    Log To Console    crc_sum=0
    ...    ELSE    Evaluate    round(round(${crc_count_1},1)/round(${crc_sum},1),4)*100
    Log To Console    bler_ul=${bler_ul}%\n

Get dlul numOfLayers from BIP log
    #  --------------------------------------------------------------------------#
    ${numofLaysers_ul}     pcap.get_field_value_by_xpath     xpath=.//UlData_puschReceiveReqGrant_t.numOfLayers
    Log To Console    numofLaysers_ul=\n${numofLaysers_ul[:200]}\n
    #  --------------------------------------------------------------------------#
    ${numofLaysers_dl}     pcap.get_field_value_by_xpath     xpath=.//DlData_PdschGrant.numOfLayers
    Log To Console    numofLaysers_dl=\n${numofLaysers_dl[:200]}\n
	
Get rnit from BIP log
    ${rnti}    pcap.get_field_value_by_xpath     xpath=.//3gpp.rnti
    ${rnti}    Remove Duplicates    ${rnti}
    set test variable    ${rnti}
    Log To Console    rnti=\n${rnti}\n

Check channel quality in BIP
    [Arguments]     ${pcap_file}
    Log To Console    \nCheck channel quality in BIP\n
    Creat pcap filter field name
    Creat pcap filter_expression 
	${pkts_after_filter}    Run Keyword And Continue On Failure    Load pcap file with filter    pcap_file=${pcap_file}    field_name=${field_name}
    ...    filter_expression=${filter_expression}
    Run Keyword And Continue On Failure    Get Average UL MCS from BIP log
    Run Keyword And Continue On Failure    Get Average DL MCS from BIP log
    Run Keyword And Continue On Failure    Get Bler from BIP log
    Run Keyword And Continue On Failure    Get dlul numOfLayers from BIP log
    Run Keyword And Continue On Failure    Get rnit from BIP log

Creat pcap filter field name
    ${field_name}	catenate    SEPARATOR=${EMPTY}
    ...    dldata_pdschsendreq||
    ...    uldata_puschreceivereq||
    ...    uldata_pucchreceiverespharqd||
    ...    dldata_pdschsendreq||
    ...    uldata_puschreceiverespharqu
    set test variable    ${field_name}
    [return]    ${field_name}

Check value from pcap log
    [Arguments]    ${parameter_name}    ${field_name}    ${expected_value}
    Log to console    \nCheck ${parameter_name} value
    ${values}    pcap.get_field_value_by_xpath     xpath=.//${field_name}    filter=${filter_expression}
    Run Keyword And Continue On Failure     should be true    '${values[0]}'=='${expected_value}'
    Run Keyword And Continue On Failure     log to console   \n${parameter_name}=${values[0]}

Load pcap file
    [Arguments]    ${pcap_file}    ${field_name}    ${tshark_path}=${TSHARK_PATH}
    ${command_template}    set variable
    ...    {tshark_path} -r {pcap_file} -Y \"${field_name}\" -T pdml
    ${packets}    pcap.load_pcap_file    pcap_file=${pcap_file}
    ...                                  tshark_path=${tshark_path}
    ...                                  command_template=${command_template}
    set test variable    ${packets}
    [Return]    ${packets}

Load pcap file with filter
    [Arguments]    ${pcap_file}    ${field_name}    ${tshark_path}=${TSHARK_PATH}    ${filter_expression}=${None}
    ${command_template}    set variable
    ...    {tshark_path} -r {pcap_file} -Y \"${field_name}\" -T pdml
    ${packets}    pcap.load_pcap_file    pcap_file=${pcap_file}
    ...                                  tshark_path=${tshark_path}
    ...                                  command_template=${command_template}
    ${filter_packets}    pcap.filter_packets_by_expression    filter_expression=${filter_expression}
    set test variable    ${filter_packets}
    [Return]    ${filter_packets}

#------------------------------------------------    ------------------------------------------------#

Collect TTI
    Create default connection
    Start TTI trace log capturing
    sleep     2s
    Stop TTI trace log capturing
    sleep     10s
    &{dict_csv_file_path}    Convert TTI trace log and download combined csv logs to test pc    local_path=${TS_CASE_LOG_PATH}
    Set suite variable    ${CSV_PATH_UL}       ${dict_csv_file_path['UL']}
    Set suite variable    ${CSV_PATH_DL}       ${dict_csv_file_path['DL']}

Zip And Remove Test Log 
    OperatingSystem.Run    cd ${SUITE_LOG_PATH} ; zip -q -j -r ${SUITE_LOG_PATH}/${TEST NAME}.zip ${LOG_PATH}
    OperatingSystem.Run    rm -rf ${LOG_PATH}

Clear Needless Files
    [Arguments]     ${file_path}=/opt/transformers.dynamic.nsn-net.net/
    run    command=df -lh | grep /dev/vda2;
    Run Keyword And Continue On Failure    run    command=find . -name 'disconnect*.ims2' -type f -print -exec rm -rf {} \\;
    Run Keyword And Continue On Failure    run    command=find /opt/ -name '*A54.zip' -type f -print -exec rm -rf {} \\;
    Run Keyword And Continue On Failure    run    command=find ${file_path} -ctime +2 -type d -name 'robotws' -print -exec rm -rf {} \\;
    Run Keyword And Continue On Failure    run
    ...    command=find ${file_path} -ctime +2 -type d -name 'testline_configuration' -print -exec rm -rf {} \\;
    run    command=df -lh | grep /dev/vda2;


#------------------------------------------------Get relevant suite variable------------------------------------------------#
Get program
    ${sw_version}    coam.Get Sw Version    connection=GNB_OAM
    ${program}    set variable    ${sw_version.split('_')[0]}
    set suite variable    ${program}
	
Get UE Type for Power UE from File
    [Arguments]     ${ue_index}=${0}
    ${ue_type}     translate_power_ue_type_from_testline     ue_index=${ue_index}
    ${ue_type}     set suite variable     ${ue_type}

Get systemModules type
    [Arguments]     ${connection}=GNB_OAM
    ${hw_info}     Wait until keyword succeeds    3 min    5 s    coam.get_detected_hw_info     connection=${connection}
    ${productName}     Set variable    ${hw_info['systemModules'][0]['productName']}
    ${systemModules}     Set variable    ${productName.split(' ')[0]}
    Set suite variable    ${systemModules}
    [Return]     ${systemModules}

Get bbmod type
    [Arguments]     ${connection}=GNB_OAM
    ${hw_info}     Wait until keyword succeeds    3 min    5 s    coam.get_detected_hw_info     connection=${connection}
    ${productName}     Set variable    ${hw_info['basebandModules'][0]['productName']}
    ${bbmod_type}     Set variable    ${productName.split(' ')[0]}
    Set suite variable    ${bbmod_type}
    [Return]     ${bbmod_type}
    
Get gNbCuType value in WebUI
    ${MR_NR_NAME}    set variable    MRBTS-${tl.gnbs[0].global_bts_id}/NRBTS-${tl.gnbs[0].global_bts_id}
    ${gNbCuType}     selenium_coam.get_parameter_value     dist_name=${MR_NR_NAME}     filter_param=gNB CU type
    ...     abbr=gNbCuType     timeout=${120}
    ${gnb_type}    set variable if
    ...            '${gNbCuType}'=='NSA'    'NSA'
    ...            '${gNbCuType}'!='NSA'    'SA'
    set test variable	${gnb_type}
    [Return]     ${gnb_type}

Get list of cell ids
    &{NR_CELL_ID_MAPPING}    get_relation_mapping_between_cell_index_and_other_ids
    Set Suite Variable    ${NR_CELL_ID_MAPPING}
    ${info}   get dictionary values    ${nr_cell_id_mapping}
    ${list_of_cell_ids}    create list
    FOR    ${cur_info}    IN    @{info}
           ${cur_nridentiity}    set variable   ${cur_info}[nrCellIdentity]
           ${cur_nridentiity}   convert to string    ${cur_nridentiity}
           append to list    ${list_of_cell_ids}   ${cur_nridentiity}
    END
    Set Suite Variable    ${list_of_cell_ids}
    [return]    ${list_of_cell_ids}

Get nrCellIdentity
    &{NR_CELL_ID_MAPPING}    get_relation_mapping_between_cell_index_and_other_ids
    Set Suite Variable    ${NR_CELL_ID_MAPPING}
    ${nrCellIdentity}   set variable    ${nr_cell_id_mapping[${tl.gnbs[0].instance_id}]}[nrCellIdentity]
    Set suite variable    ${nrCellIdentity}
    [return]    ${nrCellIdentity}

Get Ue serial number
    [Arguments]     ${ue_index}=${0}
    [Documentation]     Get Ue serial number
    ...     :param ue_index: The list index from tl.ues[]
    Connect to control pc via cygwin     ue_index=${ue_index}
    sleep     2s
    csn.send_command     command=adb devices |grep device | tail -n 1 | awk '{print $1}'     connection=cygwin
    sleep     5s
    ${serial_number}     wait until keyword succeeds     30s     1s     csn.Read Output     connection=cygwin
    ${tl.ues[0].serial_number}=     Strip String     ${serial_number}
    Should not be empty     ${tl.ues[0].serial_number}     msg=Fail to Get Ue serial number, please check your ue status
    Set Suite Variable     ${tl.ues[0].serial_number}
    [Teardown]     csn.disconnect     connection=cygwin
    [Return]     ${tl.ues[0].serial_number}

Get lua script path
    [Arguments]   ${package_store_path}=/home/ute/Downloads/Lua
    ${sw_version}    coam.Get Sw Version    connection=GNB_OAM
    ${program}    set variable    ${sw_version.split('_')[0]}
    set suite variable      ${program}
    ${version}=    set variable if    '${program}'=='SBTS23R2'    SBTS00${sw_version[8:]}    ${sw_version}
    set suite variable      ${version}
    Run    rm -rf ${package_store_path}/${program}/*.zip
#    Run    rm -rf ${package_store_path}/${program}/generated_luashark
    ${lua_url}    set variable 
    ...    http://files.ute.nsn-rdnet.net/builds/enb/base/${version}/${version}_luashark.zip
    ${sw_url}=    Catenate     sudo wget ${lua_url}  -nv -P ${package_store_path}/${program}
    log to console  download ${version}_luashark.zip from artifactory
    OperatingSystem.Run    ${sw_url}
    OperatingSystem.Run    sudo chmod 777 ${package_store_path}/${program}
    Run    unzip -o ${package_store_path}/${program}/${version}_luashark.zip -d ${package_store_path}/${program}
    ${lua_script_path}    set variable    ${package_store_path}/${program}/generated_luashark/luashark.lua
    set suite variable    ${lua_script_path}
    [Return]    ${lua_script_path}

Get SCF path
    [Arguments]   ${scf_path}=/home/ute/Downloads/SCF/
	${_scf_file_path_4x4}=    OperatingSystem.Join Path    ${scf_path}    ${program}    ${scf_file}
	${_scf_file_path_2x2}=    OperatingSystem.Join Path    ${scf_path}    ${program}    common_2x2.xml
    set suite variable     ${_scf_file_path_4x4}
    set suite variable     ${_scf_file_path_2x2} 
    [Return]    ${_scf_file_path_4x4}    ${_scf_file_path_2x2}
	
Get relevant suite variable
    Get program
    Get SCF path
    Get systemModules type
    Get bbmod type
    Get UE Type for Power UE from File
    Get list of cell ids
    Get nrCellIdentity

#------------------------------------------------capture tcpdump------------------------------------------------#	
Start tcpdump
    [Arguments]    ${pcap_name}    ${connection}=ASIK Master
    Connect to Common Unit Master
    ${timestamp}=         DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    set test variable    ${tcpdump_log_name}    Wireshark_${pcap_name}_${timestamp}.pcap
    ${start_process_command}    set variable if
    ...    '${bbmod_type}' == 'ABIL'    bsh 0:1 tcpdump -i any -w /user/toor4nsn/${tcpdump_log_name}
    ...    '${bbmod_type}' == 'ABIO' or '${bbmod_type}' == 'ABIN'    tcpdump -i any -w /user/toor4nsn/${tcpdump_log_name}
    ${check_process_command}    set variable if    '${bbmod_type}' == 'ABIL'
    ...    bsh 0:1 ps -ef | grep ${tcpdump_log_name} | grep -v grep | awk '{print $2}'
    ...    '${bbmod_type}' == 'ABIO' or '${bbmod_type}' == 'ABIN'    ps -ef | grep ${tcpdump_log_name} | grep -v grep | awk '{print $2}'
    FOR    ${index}    IN RANGE    1    6
        Log To Console    \n===============Start tcpdump Time: ${index}==============
        ssh.send command    command=${start_process_command}    connection=${connection}
        ${process_number}    csn.execute     command=${check_process_command}     connection=${connection}
        ${is_process_on}=     run keyword and return status    should not be empty    ${process_number}
        Exit For Loop If    ${is_process_on}
    END
#    [Teardown]     Run Keyword And Continue On Failure     Csn.Disconnect     connection=ASIK Master
    [Return]    ${tcpdump_log_name}

Stop tcpdump and download to testPC
    [Arguments]     ${connection}=ASIK Master
    ...             ${log_path}=${TS_CASE_LOG_PATH}
    Connect to Common Unit Master
    Run keyword if     '${bbmod_type}' == 'ABIL'
    ...    ssh.send_command    command=bsh 0:1 ps -ef | grep tcpdump | grep -v grep | awk '{print $2}' | xargs kill -2   connection=${connection}
    ...    ELSE IF     '${bbmod_type}' == 'ABIO' or '${bbmod_type}' == 'ABIN'
    ...    ssh.send_command    command=ps -ef | grep tcpdump | grep -v grep | awk '{print $2}' | xargs kill -2   connection=${connection}    
    sleep  3s
    ssh.download_file   /user/toor4nsn/${tcpdump_log_name}  ${log_path}/${tcpdump_log_name}  connection=${connection}
    set test variable    ${tcpdump_log_path}    ${log_path}/${tcpdump_log_name}
    sleep  15s
    ssh.execute  command= rm /user/toor4nsn/${tcpdump_log_name}  connection=${connection}
    [Teardown]     Run Keyword And Continue On Failure     Csn.Disconnect     connection=ASIK Master
    [Return]    ${tcpdump_log_path}

#------------------------------------------------capture Emil log------------------------------------------------#	
Start Collect Emil log
    [Arguments]    ${dcap_server_ip}=host-10-70-230-72    ${dcap_server_port}=443    ${secure}=True
    Log to console   ++++++++++Start Collect Emil log++++++++++
    @{trace_type}    create list    cp_5g    syslog_5g    immediateSnapshot_5g    SCF5g    L2Ps_Component    L2Ps_Sherpa
    ...    L2Lo_Component    L2Lo_Sherpa    L2HiRlc_Component    L2HiRlc_Sherpa    L2HiPdcp_Component    L2HiPdcp_Sherpa    
    &{bts_info}   Create Dictionary    host=${bts_host}    username=${bts_username}
    ...                                password=${bts_password}    port=${443}
    Run Keyword And Continue On Failure    rd.connect_to    host=${dcap_server_ip}
    ...    port=${dcap_server_port}    username=${dcap_user}    password=${dcap_password}    rd_version=${rd_version}    secure=${secure}
    Run Keyword And Continue On Failure    rd.create_bts    host=${bts_host}
    ${trace_info}    Run Keyword And Continue On Failure    rd.start_trace    bts=&{bts_info}    gnb_custom_profile=${trace_type}
	${trace_id}    set variable    ${trace_info['id']}
	set test variable    ${trace_id}

Stop Collect Emil log
    [Arguments]    ${EMIL_LOG_PATH}=${TS_CASE_LOG_PATH}    ${dcap_server_ip}=host-10-70-230-72    ${dcap_server_port}=443    ${secure}=True
    Log to console   ++++++++++Stop Collect Emil log++++++++++
    Run Keyword And Continue On Failure    rd.connect_to    host=${dcap_server_ip}
    ...    port=${dcap_server_port}    username=${dcap_user}    password=${dcap_password}    rd_version=${rd_version}    secure=${secure}
    Run Keyword And Continue On Failure    Get bts id
    #Run Keyword And Continue On Failure    rd.stop_trace    trace_id=${trace_id}
    Run Keyword And Continue On Failure    wait until keyword succeeds     10min     10s     rd.stop_trace    trace_id=${trace_id}
    Run Keyword And Continue On Failure    Wait for trace ready
    ${trace_logpath}    Run Keyword And Continue On Failure    rd.get_results
    #run    command=if [ ! -d ${EMIL_LOG_PATH} ]; then mkdir ${EMIL_LOG_PATH}; fi
    #run    command=cd ${EMIL_LOG_PATH};rm -r *
    run    command=cp ${trace_logpath} ${EMIL_LOG_PATH}
    run    command=rm -f ${trace_logpath}
    Run Keyword And Continue On Failure    rd.delete_trace    trace_id=${trace_id}
    Run Keyword And Continue On Failure    rd.delete_bts    bts_id=${bts_id}

Get trace id 
    ${get_all_trace_info}=    Run Keyword And Continue On Failure    rd.get_all_trace_info
    FOR    ${index}    IN    @{get_all_trace_info}
        ${trace_id}    set variable    ${index['id']}
        Exit for loop If    '${index['targets'][0]['host']}'=='${bts_host}'
    END
    set test variable    ${trace_id}
    [Return]     ${trace_id}
	
Get trace status
    ${get_all_trace_info}=    Run Keyword And Continue On Failure    rd.get_all_trace_info
    FOR    ${index}    IN    @{get_all_trace_info}
        ${trace_status}    set variable    ${index['status']}
        Exit for loop If    '${index['id']}'=='${trace_id}'
    END
    set test variable    ${trace_status}
    [Return]     ${trace_status}

Get bts id
    ${get_all_bts_info}=    Run Keyword And Continue On Failure    rd.get_all_bts_info
    FOR    ${index}    IN    @{get_all_bts_info}
        ${bts_id}    set variable    ${index['id']}
        Exit for loop If    '${index['host']}'=='${bts_host}'
    END
    set test variable    ${bts_id}
   [Return]     ${bts_id}

Wait for trace ready
    FOR    ${i}    IN RANGE    1    10
        sleep    1min
        Get trace status
        Exit for loop If    '${trace_status}'=='ready'
    END

Perform cell block
    [Arguments]    ${cell_idx}=${1}    ${connection}=GNB_OAM    ${timeout}=60    ${gnb_id}=0
    ${nr_bts_id}    Set variable    ${tl.gnbs[${gnb_id}].global_bts_id}
    coam.lock    dist_name=MRBTS-${nr_bts_id}/NRBTS-${nr_bts_id}/NRCELL-${cell_idx}    timeout=${timeout}    connection=${connection}

Perform cell unblock
    [Arguments]    ${cell_idx}=${1}    ${connection}=GNB_OAM    ${timeout}=60    ${gnb_id}=0
    ${nr_bts_id}    Set variable    ${tl.gnbs[${gnb_id}].global_bts_id}
    coam.unlock    dist_name=MRBTS-${nr_bts_id}/NRBTS-${nr_bts_id}/NRCELL-${cell_idx}    timeout=${timeout}    connection=${connection}
