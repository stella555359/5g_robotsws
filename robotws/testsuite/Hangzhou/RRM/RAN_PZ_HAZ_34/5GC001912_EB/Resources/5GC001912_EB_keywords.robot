*** Settings ***
Documentation
...   This is for 1912-EB TA common keywords
...   author: Cui Lingxue
...   contact: lingxue.cui@nokia-sbell.com
...   squad group: MMW_SG1

Library     String
Library     OperatingSystem
Library     DateTime
Library     Collections
Library     XML
Resource    ./5GC001912_EB_variables.robot
Variables   ../TestData/5GC001912_EB_nidd_parameters.py
Variables   ../TestData/5GC001912_EB_cplane_msg_checkpoints.py
Resource    ./5GC001912_EB_keywords_pcap.robot
Resource    ./5GC001912_EB_keywords_viavi.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/common_resources.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/logs.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/container_log_capturing.robot
Library     taf.rfrl.common_resources.python.ssh_common_commands

*** Keywords ***
1095 Case preparation
    [Arguments]    ${is_srb3}=${False}    ${timeout}=2 min
    Common case setup
    run keyword if    ${is_srb3}    ENABLE SRB3 on gNB    ELSE    DISABLE SRB3 on gNB
    COAM GNB Wait CU and DU cells are on air status    timeout=${timeout}
    Precondition for attach with retry

1095 Case teardown
    [Arguments]    ${cpif_log_name}=CPIF_log    ${is_btslog_required}=${False}
    run keyword and ignore error    Delete route from control pc to appserver
    run keyword and ignore error    Stop tcpdump log collection    tcpdump_collector_name=${cpif_log_name}
    Run Keyword And Ignore Error    Cobham UE detach
    run keyword and ignore error    Kill tma process    tma_telnet_alias=${TMA_SSH_ALIAS}
    Collect tma logs to test pc    connection=${TMA_SSH_ALIAS}
    DISABLE SRB3 on gNB
    run keyword and ignore error    coam_gnb_classical.COAM Teardown gnb connections    connection=GNB_OAM_du1
    Common case teardown    is_btslog_required=${is_btslog_required}

Swconfig modification
    [Arguments]    ${swconfig_template_path}=${SWCONFIG_DEFAULT_FILE_PATH}    ${swconfig_modify}=${None}    ${du_index}=${0}
    ...    ${log_path}=${SUITE_LOG_PATH}
    Connect to Common Unit Master    du_index=${du_index}    alias=ASIK Master
    ${default_swconfig_file_path}    Copy file    source=${swconfig_template_path}    destination=${log_path}
    run keyword if    ${swconfig_modify}!=${None}
    ...    swconf.modify swconfig file    parametersList=${swconfig_modify}    filePath=${default_swconfig_file_path}
    swconf.Upload swConfig file to asik and crasign    localFilePath=${default_swconfig_file_path}    asik_alias=ASIK Master
    [Teardown]    ssh.disconnect    connection=ASIK Master

Modify DU parameter and commission
    [Arguments]    ${scf_file_path}    ${scf_parameters_list}    ${connection}=DU416    ${du_index}=${0}
    ...    ${timeout}=300    ${is_pdl_checking_needed}=${False}    ${local_scf_path}=${SUITE_LOG_PATH}
    ${default_du_scf_file_path}    Copy file    ${scf_file_path}    ${local_scf_path}
    ${modified_du_scf_file_path}    run keyword if    ${scf_parameters_list}!=${None}    coam_gnb_classical.COAM Modify scf file
    ...    scf_file_path=${default_du_scf_file_path}
    ...    scf_parameters_list=${scf_parameters_list}
    ...    ELSE    set variable    ${default_du_scf_file_path}
    Cloud DU connect to gnb coam via ssl    connection=${connection}    bts_host=${tl.gnbs[0].dus[${du_index}].f1_m_ip_addr}
    &{result}    coam.perform_commissioning    scf_file=${modified_du_scf_file_path}
    ...    timeout=${timeout}    skip_parameter_relation_errors=${True}    connection=${connection}
    Should be equal as strings    ${result['commissioningResult']['activationResult']['resultNode']['parameters']['result']}    Success
    ...    msg=Commissioned with error exists, activation result is not in success status.    ignore_case=${True}
    Should be equal as strings    ${result['validationResult']['niddValidationResult']['status']}    OK
    ...    msg=Commissioned with error exists, nidd validation result is not in OK status    ignore_case=${True}
    Run keyword if    ${is_pdl_checking_needed}==${True}
    ...    Should be equal as strings    ${result['validationResult']['pdlValidationResult']['status']}    OK
    ...        msg=Commissioned with error exists, pdl validation result is not in OK status.    ignore_case=${True}
    [Teardown]    COAM Teardown gnb connections    connection=${connection}

Online modify NIDD parameters on eNB
    [Arguments]    ${parameters_to_update_via_api}    ${enb_index}=${0}    ${connection}=ENB_OAM
    Cloud DU connect to gnb coam via ssl    connection=${connection}
    ...    bts_host=${tl.enbs[${enb_index}].airscale.common_units[0].lmp_connection.addr}
    coam_gnb_classical.COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters_to_update_via_api}
    ...    connection=${connection}
    coam.get_current_scf_file    local_dir_path=${TS_LOG_PATH_BASE}    file_name=SCF_eNB_${tl.enbs[${enb_index}].instance_id}.xml
    ...    connection=${connection}
    [Teardown]    COAM Teardown gnb connections    connection=${connection}

Set default nr cell on enb
    [Arguments]    ${enb_index}=${0}    ${parameters_to_update_via_api}=${ENB_DEFAULT_NR_CELL}    ${connection}=ENB_OAM
    Online modify NIDD parameters on eNB    parameters_to_update_via_api=${parameters_to_update_via_api}    enb_index=${enb_index}
    ...    connection=${connection}

Get current value of NIDD paramter on gNB CU
    [Arguments]    ${parameter_name}    ${cu_ip}=${tl.gnbs[${0}].cu.oam_http_connection_details.addr}
    ${para_dict}   get_parameters_of_current_plan    parameter_name=${parameter_name}    cu_ip=${cu_ip}
    ${new_para}    evaluate    dict(${para_dict})
    ${para_value}    set variable    ${new_para['items'][0]['parameter']['simple_parameter']['value']}
    [Return]    ${para_value}

ENABLE SRB3 on gNB
    [Arguments]    ${log_dir}=${TS_CASE_LOG_PATH}
    ${SRB3_ON}    evaluate    {'MRBTS-${tl.gnbs[0].cu.instance_id}/NRBTS-${tl.gnbs[0].cu.global_bts_id}': {'srb3SupportEnabled': 'true'}}
    ${is_srb3}    Get current value of NIDD paramter on gNB CU    parameter_name=srb3SupportEnabled
    run keyword if    '${is_srb3}'=='false'    CU Delta Commission update    parameters=${SRB3_ON}    log_dir=${log_dir}
    ${is_srb3}    Get current value of NIDD paramter on gNB CU    parameter_name=srb3SupportEnabled
    should be equal    ${is_srb3}    true

DISABLE SRB3 on gNB
    [Arguments]    ${log_dir}=${TS_CASE_LOG_PATH}
    ${SRB3_OFF}    evaluate    {'MRBTS-${tl.gnbs[0].cu.instance_id}/NRBTS-${tl.gnbs[0].cu.global_bts_id}': {'srb3SupportEnabled': 'false'}}
    ${is_srb3}    Get current value of NIDD paramter on gNB CU    parameter_name=srb3SupportEnabled
    run keyword if    '${is_srb3}'=='true'    CU Delta Commission update    parameters=${SRB3_OFF}    log_dir=${log_dir}
    ${is_srb3}    Get current value of NIDD paramter on gNB CU    parameter_name=srb3SupportEnabled
    should be equal    ${is_srb3}    false

Connect to pppoe network on control pc
    [Arguments]    ${pppoe_network}=TM500    ${pppoe_user}=tm500    ${pppoe_pw}=tm500    ${cpc_alias}=cygwin
#    Connect to cobham control pc via ssh    tma_ssh_alias=${cpc_alias}
    ${connect_success_msg}    set variable    Successfully connected to ${pppoe_network}
    ssh.send_command    command=rasdial ${pppoe_network} ${pppoe_user} ${pppoe_pw}    connection=${cpc_alias}
    ${output}    ssh.read_output_until    match=${connect_success_msg}    connection=${cpc_alias}    timeout=1min
    ssh.send_command    command=route print    connection=${cpc_alias}
    ${output}    ssh.read_output    connection=${cpc_alias}
    should contain    ${output}    ${pppoe_network}
    log to console    Successfully connected to pppoe network.
#    [Teardown]    Disconnect from cobham control pc via ssh    tma_ssh_alias=${cpc_alias}

Add route from control pc to appserver
    [Documentation]    Author: Cui Lingxue
    ...    ${UE_IP} is set as suite variable in kw 'Cobham retry ue attach if failed'
    ...    ${ue_gateway_ip} is the last IP of ue ip address pool, usually end with .254
    [Arguments]    ${ue_gateway_ip}=169.254.203.1    ${appserver_ip}=${APPSRV_IP}    ${cpc_alias}=cygwin
#    wait until keyword succeeds  1min  5sec  Connect to cobham control pc via ssh    tma_ssh_alias=${cpc_alias}
    ssh.send_command    command=route delete ${appserver_ip}    connection=${cpc_alias}
    ssh.send_command    command=route -p add ${appserver_ip} mask 255.255.255.255 ${ue_gateway_ip} metric 1   connection=${cpc_alias}
    ${output}    ssh.read_output    connection=${cpc_alias}
    should contain    ${output}    OK!
    ssh.send_command    command=route print    connection=${cpc_alias}
    ${output}    ssh.read_output    connection=${cpc_alias}
    log to console    Route to appserver is added.
#    [Teardown]    Disconnect from cobham control pc via ssh    tma_ssh_alias=${cpc_alias}

Delete route from control pc to appserver
    [Arguments]    ${appserver_ip}=${APPSRV_IP}    ${cpc_alias}=cygwin
    Connect to cobham control pc via ssh    tma_ssh_alias=${cpc_alias}
    ssh.send_command    command=route delete ${appserver_ip}    connection=${cpc_alias}
    ssh.send_command    command=route print    connection=${cpc_alias}
    ${output}    ssh.read_output    connection=${cpc_alias}
    should not contain    ${output}    ${appserver_ip}
    [Teardown]    Disconnect from cobham control pc via ssh    tma_ssh_alias=${cpc_alias}

Download file from FTP server to control PC using sftp
    [Documentation]    Author: Cui Lingxue
    ...    To login without password, ssh key need to be installed on FTP server in advance.
    ...    Generate ssh key using ssh-keygen, then copy ssh key to appserver by command:
    ...    > ssh-copy-id -i .ssh/id_rsa.pub  mmw_sg1@10.57.162.4
    ...    ${speed_limit} is in kbit/s unit.
    [Arguments]    ${filepath_on_srv}=${FILE_TO_DOWNLOAD}    ${dir_on_cpc}=${DIR_ON_CPC}
    ...    ${ftp_srv_ip}=${FTP_SRV_IP}    ${ftp_srv_user}=${FTP_SRV_USER}
    ...    ${cpc_alias}=cygwin    ${speed_limit}=10000
    ${file_name}    fetch_from_right    string=${filepath_on_srv}    marker=/
    ${filepath_on_cpc}    join_path    ${dir_on_cpc}    ${file_name}
    wait until keyword succeeds  1min  5sec  Connect to cobham control pc via ssh    tma_ssh_alias=${cpc_alias}
    Connect to pppoe network on control pc
    Add route from control pc to appserver
    ssh.send_command    command=rm ${filepath_on_cpc}    connection=${cpc_alias}
    sleep    1s    reason=Wait for removing old file
    ${scp_cmd}    set variable    scp -l ${speed_limit} ${ftp_srv_user}@${ftp_srv_ip}:${filepath_on_srv} ${dir_on_cpc} &
    ssh.send_command    command=${scp_cmd}    connection=${cpc_alias}
    sleep    5s    reason=Wait for scp process to start!!
    ssh.send_command    command=ps -ef | grep scp;ls -l ${filepath_on_cpc}    connection=${cpc_alias}
    ${scp_process}    ssh.read_output    connection=${cpc_alias}
    run keyword and continue on failure  should contain    ${scp_process}    scp
    run keyword and continue on failure  should contain    ${scp_process}    ${filepath_on_cpc}
    [Return]    ${filepath_on_cpc}
#    [Teardown]    Disconnect from cobham control pc via ssh    tma_ssh_alias=${cpc_alias}

process should be killed on cpc
    [Arguments]    ${process_name}=scp    ${cpc_alias}=cygwin
    ${is_process_exist}    ssh_common_commands.is_process_exist    process_name=${process_name}    connection=${cpc_alias}
    should not be true    ${is_process_exist}

Verify traffic is lossless
    [Arguments]    ${filepath_on_cpc}    ${exp_file_checksum}=${EXP_FILE_CHECKSUM}    ${exp_file_size}=${EXP_FILE_SIZE}
    ...    ${timeout}=5 min    ${cpc_alias}=cygwin
    Connect to cobham control pc via ssh    tma_ssh_alias=${cpc_alias}
    wait until keyword succeeds    ${timeout}    5 sec    process should be killed on cpc    process_name=scp

    ssh.send_command    command=cksum ${filepath_on_cpc} |awk '{print $1}'    connection=${cpc_alias}
    ${cksum_on_cpc}    ssh.read_output    connection=${cpc_alias}
    ssh.send_command    command=cksum ${filepath_on_cpc} |awk '{print $2}'    connection=${cpc_alias}
    ${filesize_on_cpc}    ssh.read_output    connection=${cpc_alias}

    run keyword and continue on failure  should be equal as strings    ${exp_file_checksum}    ${cksum_on_cpc.strip()}
    run keyword and continue on failure  should be equal as strings    ${exp_file_size}    ${filesize_on_cpc.strip()}
    [Teardown]    Disconnect from cobham control pc via ssh    tma_ssh_alias=${cpc_alias}

Attach and trigger measurement report
    [Arguments]    ${cpif_log_name}    ${meas_report_type}=A1    ${is_need_to_download_file}=${False}    ${is_srb3}=${True}
    ...    ${log_path}=${TS_CASE_LOG_PATH}
    Start X2 log capture on gNB CU    x2_log_name=${cpif_log_name}_x2
    Start F1 log capture on gNB CU    f1_log_name=${cpif_log_name}_f1

    Cobham retry ue attach if failed
    ${filepath_on_cpc}    run keyword if    ${is_need_to_download_file}    Download file from FTP server to control PC using sftp
    run keyword if    ${is_need_to_download_file}    set test variable    ${PATH_OF_DOWNLOADED_FILE}    ${filepath_on_cpc}
    Trigger A2 measurement report    is_srb3=${is_srb3}
    run keyword if    '${meas_report_type}'=='A1'    Trigger A1 measurement report    is_srb3=${is_srb3}
    ...    ELSE    Trigger A3 meas report if not triggered auto
    sleep    ${TRACE_CAPTURE_DELAY}

    ${x2_log_path}    Stop tcpdump on CPIF and rename downloaded file    cpif_log_name=${cpif_log_name}_x2
    ${f1_log_path}    Stop tcpdump on CPIF and rename downloaded file    cpif_log_name=${cpif_log_name}_f1
    ${merged_log_path}    set variable    ${log_path}/${cpif_log_name}.pcap
    run    mergecap -w ${merged_log_path} ${x2_log_path} ${f1_log_path}
    [Return]    ${merged_log_path}
    [Teardown]    run keyword and ignore error  run keywords    Stop tcpdump log collection    tcpdump_collector_name=${cpif_log_name}_x2    AND
    ...    Stop tcpdump log collection    tcpdump_collector_name=${cpif_log_name}_f1

Stop tcpdump on CPIF and rename downloaded file
    [Documentation]    Description: Stop tcpdump log capturing and rename it and move it to folder ${TS_LOG_PATH_BASE}.
    ...    log path on UTE set as test variable ${CPIF_LOG}
    [Arguments]    ${cpif_log_name}    ${rename_prefix}=Ori
    ${cpif_log_fullname}    Stop tcpdump log collection    tcpdump_collector_name=${cpif_log_name}
    ${cpif_log_fullname_renamed}    rename downloaded file    log_path=${cpif_log_fullname}    rename_prefix=${rename_prefix}
    [Return]    ${cpif_log_fullname_renamed}

Rename downloaded file
    [Documentation]    Author: Cui Lingxue
    ...    Description: rename file and move to ${TS_CASE_LOG_PATH} or ${SUITE_LOG_PATH}.
    [Arguments]    ${log_path}    ${rename_prefix}=Ori    ${is_set_to_test_case_level}=${True}
    ${log_name}    fetch_from_right    string=${log_path}    marker=/
    ${new_log_dir}    set variable if    ${is_set_to_test_case_level}    ${TS_CASE_LOG_PATH}    ${SUITE_LOG_PATH}
    ${log_path_renamed}    join path    ${new_log_dir}    ${rename_prefix}_${log_name}
    run    mv ${log_path} ${log_path_renamed}
    [Return]    ${log_path_renamed}

# [OBSELETE]
