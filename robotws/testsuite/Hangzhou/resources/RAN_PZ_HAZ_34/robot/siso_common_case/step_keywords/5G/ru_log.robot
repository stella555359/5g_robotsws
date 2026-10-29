*** Settings ***
Documentation    This is common keywords for siso RU related cases
...              Please do not modify the file without notification to author
...              Author: tingting.zhong@nokia-sbell.com
...              Squard: HZ SG4   HZ SG8

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource      ./basic/pre_analysis.robot
Library       taf.hw.rmod_serial_interface  WITH NAME  ru_serial
Library       yaml  WITH NAME  parser_yaml

*** Keywords ***
Capture RU logs
    [Arguments]     ${target_dir}=${SAVE LOG DIRECTORY}   ${asik_alias}=ASIK Master  ${asik_slave_alias}=ASIK Slave
    ...            ${connection}=GNB_OAM  ${asik_slave_username}=toor4nsn     ${asik_slave_password}=oZPS0POrRieRtu
    ...            ${asik_slave_addr}=fct0s0icom    ${gnb_index}=${0}
    &{hw_info}    coam.get_detected_hw_info    connection=${connection}
    @{list_ASIKs}    Set variable    ${hw_info['systemModules']}
    ${count_ASIKs}    Get length    ${list_ASIKs}
    ${not_connect_ru_list}    Create List
    ${ru_index_list}  Get All RU Index   connection=${connection}
    Connect to Common Unit Master    alias=${asik_alias}
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${ru_connect_status}    Set Variable    ${False}
        ${collect_master_log_status}    Set Variable    ${False}
        ${ru_connect_status}    Run Keyword And Return Status   Connect to RU With Allocated IP  ru_index=${ru_index}
        ...       ru_alias=RU_${ru_index}    connection=${connection}   asik_alias=${asik_alias}
        ...       ru_username=${tl.gnbs[${gnb_index}].dus[0].rus[${ru_index}-1].default_ssh_connection_details.username}
        ...       ru_password=${tl.gnbs[${gnb_index}].dus[0].rus[${ru_index}-1].default_ssh_connection_details.password}
        ${collect_master_log_status}    Run keyword if   '${ru_connect_status}'=='True'    run keyword and return status
        ...               Capture RU File and Download To TestPC   ru_index=${ru_index}
        ...                     connection=RU_${ru_index}   download_dir=${target_dir}
        ...    ELSE     Set Variable    ${False}
        ${asik_slave_status}    Set Variable    ${False}
        ${asik_slave_status}    Run keyword if   '${ru_connect_status}'=='False' and ${count_ASIKs}>1
        ...    Run Keyword And Return Status   Connect to Slave Asik   asik_slave_alias=${asik_slave_alias}
        ...               asik_slave_username=${asik_slave_username}
        ...               asik_slave_password=${asik_slave_password}
        ...               asik_slave_addr=${asik_slave_addr}  master_alias=${asik_alias}
        ...    ELSE     Set Variable    ${False}
        ${ru_slave_status}    Set Variable    ${False}
        ${ru_slave_status}    Run keyword if   '${asik_slave_status}'=='True'
        ...    Run Keyword And Return Status   Connect to RU With Allocated IP  ru_index=${ru_index}
        ...                  ru_alias=RU_${ru_index}    asik_alias=${asik_slave_alias}   connection=${connection}
        ...       ru_username=${tl.gnbs[${gnb_index}].dus[0].rus[${ru_index}-1].default_ssh_connection_details.username}
        ...       ru_password=${tl.gnbs[${gnb_index}].dus[0].rus[${ru_index}-1].default_ssh_connection_details.password}
        ...    ELSE     Set Variable    ${False}
        ${collect_slave_log_status}    Set Variable    ${False}
        ${collect_slave_log_status}    Run keyword if   '${ru_slave_status}'=='True'   Run Keyword And Return Status
        ...            Capture RU File and Download To TestPC   ${ru_index}  RU_${ru_index}   ${target_dir}
        ...    ELSE     Set Variable    ${False}
        Run keyword if   '${collect_master_log_status}'=='False' and '${collect_slave_log_status}'=='False'
        ...             Append to List    ${not_connect_ru_list}     ${ru_index}
        ...    ELSE     csn.Disconnect  connection=RU_${ru_index}
        Run keyword if   '${asik_slave_status}'=='True'    csn.Disconnect  connection=${asik_slave_alias}
    END
    ${local_required_RUs}   Create List
#    ${rus}  Create List
    ${rus}    Set Variable   ${tl.gnbs[${gnb_index}].dus[0].rus}
#    log to console    ${rus[0].lmp_connection.addr}
    ${local_RU_count}   Get Length   ${rus}
    FOR   ${index}   IN    @{not_connect_ru_list}
       Run Keyword If   ${index} <= ${local_RU_count}   Append To List   ${local_required_RUs}    ${index}
    END
#    Run Keyword And Ignore Error   coam.teardown    connection=${connection}
    Run Keyword And Ignore Error    Capture RU logs Through Local IP    target_dir=${target_dir}
    ...              asik_alias=${asik_alias}   connection=${connection}   ru_index_list=${local_required_RUs}
    Log To Console    Collecting Ru Log [DONE]

Capture RU File and Download To TestPC
    [Arguments]    ${ru_index}=1   ${connection}=RU   ${download_dir}=${TS_CASE_LOG_PATH}
    &{ru_info}    COAM get ru detial info by ru index     ru_index=${ru_index}   connection=GNB_OAM
    ${ru_serial_number}    Set variable    ${ru_info['serialNumber']}
    ${rfsw_log_path_on_ru}   Wait Until Keyword Succeeds   2 min  20 sec   Capture RFSW Log On RU    connection=${connection}
    ${ru_file_name}    Set Variable    ${rfsw_log_path_on_ru.split('/')}[-1]
    ${ru_file_name}    Set Variable    RU${ru_index}_${ru_serial_number}_${ru_file_name}
    Wait Until Keyword Succeeds   2m   5s   Check if remote file size not increased   file_path=${rfsw_log_path_on_ru}   connection=${connection}
    Wait Until Keyword Succeeds   2 min  5 sec   csn.Download file
    ...                                          remote_path=${rfsw_log_path_on_ru}
    ...                                          local_path=${download_dir}/${ru_file_name}
    ...                                          connection=${connection}
    csn.execute      command=rm -rf ${rfsw_log_path_on_ru}    connection=${connection}
    ${rfsw_log_path_on_testPC}   Join Path    ${download_dir}    ${ru_file_name}
    [Return]   ${rfsw_log_path_on_testPC}

Capture RU logs Through Local IP
    [Arguments]    ${target_dir}=${OUTPUT DIR}     ${asik_alias}=ASIK Master    ${connection}=GNB_OAM   ${ru_index_list}=[1]
    ...       ${gnb_index}=0
    Connect to Common Unit Master  alias=${asik_alias}   alias= ${asik_alias}    gnb_index=${gnb_index}
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${ru_index}   evaluate  ${ru_index}-1
        ${ru_connect_status}    Set Variable    ${False}
        ${TAF_ADDR}    Set Variable    ${tl.gnbs[${gnb_index}].dus[0].rus[${ru_index}].lmp_connection.addr}
        continue for loop if    '${TAF_ADDR}'=='1.1.1.1'
        continue for loop if    '${TAF_ADDR}'=='192.168.100.3'
        ${ru_connect_status}    Run Keyword And Return Status   Connect to RU With Local IP  ru_index=${ru_index}
        ...          ru_alias=RU_${ru_index}  taf_alias=TAF_${ru_index}
        ...          ru_username=${tl.gnbs[${gnb_index}].dus[0].rus[${ru_index}].default_ssh_connection_details.username}
        ...          ru_password=${tl.gnbs[${gnb_index}].dus[0].rus[${ru_index}].default_ssh_connection_details.password}
        ...          ru_addr=${tl.gnbs[${gnb_index}].dus[0].rus[${ru_index}].default_ssh_connection_details.addr}
        ...          taf_username=${tl.gnbs[${gnb_index}].dus[0].rus[${ru_index}].lmp_connection.username}
        ...          taf_password=${tl.gnbs[${gnb_index}].dus[0].rus[${ru_index}].lmp_connection.password}
        ...          taf_addr=${tl.gnbs[${gnb_index}].dus[0].rus[${ru_index}].lmp_connection.addr}
        Capture RU File and Download To TestPC   ru_index=${ru_index}  connection=RU_${ru_index}   download_dir=${target_dir}
        Run keyword if   '${ru_connect_status}'=='True'
        ...          csn.Disconnect  connection=TAF_${ru_index}
    END
    [Teardown]  csn.Disconnect  connection=${asik_alias}

Connect to RU With Local IP
    [Documentation]   Auther: kaihui.fan@nokia-sbell.com
    ...               Description: connect RU with LMP_connection IP 192.168.100.X
    [Arguments]  ${ru_index}=${1}   ${ru_alias}=RU  ${taf_alias}=taf_proxy
    ...          ${ru_username}=${tl.gnbs[0].dus[0].rus[${ru_index}-1].default_ssh_connection_details.username}
    ...          ${ru_password}=${tl.gnbs[0].dus[0].rus[${ru_index}-1].default_ssh_connection_details.password}
    ...          ${ru_addr}=${tl.gnbs[0].dus[0].rus[${ru_index}-1].default_ssh_connection_details.addr}
    ...          ${taf_username}=${tl.gnbs[0].dus[0].rus[${ru_index}-1].lmp_connection.username}
    ...          ${taf_password}=${tl.gnbs[0].dus[0].rus[${ru_index}-1].lmp_connection.password}
    ...          ${taf_addr}=${tl.gnbs[0].dus[0].rus[${ru_index}-1].lmp_connection.addr}
    csn.connect to    hostname=${taf_addr}
    ...                         username=${taf_username}
    ...                         password=${taf_password}
    ...                         alias=${taf_alias}
    csn.connect to    hostname=${ru_addr}
    ...                         username=${ru_username}
    ...                         password=${ru_password}
    ...                         alias=${ru_alias}
    ...                         proxy=${taf_alias}

Connect to Slave Asik
    [Documentation]   Auther: kaihui.fan@nokia-sbell.com
    ...               Description: connect Asik Slave
    [Arguments]  ${asik_slave_alias}=ASIK Slave  ${master_alias}=ASIK Master
    ...          ${asik_slave_username}=toor4nsn
    ...          ${asik_slave_password}=oZPS0POrRieRtu
    ...          ${asik_slave_addr}=fct0s0icom.local
    ${hostname}=    csn.execute    command=hostname    connection=${master_alias}
    csn.connect to    hostname=${asik_slave_addr}
    ...                         username=${asik_slave_username}
    ...                         password=${asik_slave_password}
    ...                         alias=${asik_slave_alias}
    ...                         proxy=${master_alias}

Get File Size
    [Arguments]   ${file_path}   ${connection}
    ${file_info}   csn.Execute   command=ls -la ${file_path}   connection=${connection}
    [Return]   ${file_info.split()[4]}

Check if remote file size not increased
    [Arguments]   ${file_path}   ${connection}   ${timeout}=30s
    Wait Until Keyword Succeeds   ${timeout}   5s   csn.File Exists
    ...   remote_path=${file_path}   connection=${connection}   timeout=5
    ${prev_size}   Get File Size   file_path=${file_path}   connection=${connection}
    Sleep   1s
    ${final_size}   Get File Size   file_path=${file_path}   connection=${connection}
    Should Be Equal   ${prev_size}    ${final_size}

Catch RU Serial Log
    [Timeout]   10m
    [Arguments]  ${RU_SERIAL_LOG_FLAG}=False   ${connection}=GNB_OAM    ${target_dir}=${TS_CASE_LOG_PATH}
    Return From Keyword If   not ${RU_SERIAL_LOG_FLAG}
    ${ru_index_list}  Get All RU Index   connection=${connection}
    FOR  ${ru_index}  IN  @{ru_index_list}
        ${hostname}   Set Variable   ${tl.gnbs[0].dus[0].rus[${ru_index}-1].lmp_connection.addr}
        ${username}   Set Variable   ${tl.gnbs[0].dus[0].rus[${ru_index}-1].lmp_connection.username}
        ${password}   Set Variable   ${tl.gnbs[0].dus[0].rus[${ru_index}-1].lmp_connection.password}
        Continue for loop If   '${hostname}'=='1.1.1.1' or '${hostname}'=='' or '${hostname}'=='${None}'
        ${ru_pc_connection}   Set Variable   ru_${ru_index}_serial_${hostname}
        ${status}    run keyword and return status    csn.Connect to   hostname=${hostname}   username=${username}
        ...    password=${password}    alias=${ru_pc_connection}    timeout=3m
        Return From Keyword If   not ${status}
        ${Return_Status}   csn.Execute    command=systemd-detect-virt   connection=${ru_pc_connection}
        ${if_vm}   run keyword and return status   Should Contain    ${Return_Status}    kvm
        Return From Keyword If   '${if_vm}' == '${True}'
        ${ru_serial_log_path}   Set Variable   ${target_dir}/RU_${ru_index}_SERIAL_LOG.txt
        Run Keyword And Ignore Error
        ...   csn.Download File    remote_path=/tmp/putty.txt   local_path=${ru_serial_log_path}   connection=${ru_pc_connection}
        ${kill_serial_command}   set variable  ps -ef|grep "cat /dev/ttyUSB0" |grep -v grep| awk '{print $2}' |xargs sudo kill -9
        Run Keyword And Ignore Error    csn.Execute    command=${kill_serial_command}   connection=${ru_pc_connection}
        Run Keyword And Ignore Error    csn.execute    command=sudo rm -rf /tmp/putty.txt    connection=${ru_pc_connection}
    END
    [Teardown]   Run Keyword And Ignore Error   csn.Disconnect   connection=${ru_pc_connection}
    [Return]   ${ru_serial_log_path}

RMOD Serial Port shutdown by Common KW
    [Arguments]  ${config_path}
    ${yaml}=    Get File    ${config_path}
    ${config_load}=    parser_yaml.safe_load    file=${yaml}
    ${dict}=    Set Variable   ${config_load}[file=RSI]
    FOR  ${key}  IN  @{dict.keys()}
        Log    ${key}
        ru_serial.shutdown    connection=${key}
    END

RMOD Serial Port teardown by Common KW
    [Arguments]  ${ru_port}    ${connection}
    FOR  ${item}  IN  @{ru_port}
        Log    ${item}
        ru_serial.teardown    alias=${item}
    END

Download RMOD Serial log by Common KW
    [Arguments]  ${host_alias}    ${serial_port_list}    ${config_path}=${serial_config}    ${target_dir}=${TS_CASE_LOG_PATH}
    Log    ${host_alias}
    Log    ${serial_port_list}
    ${ru_port_list}   Create List
    FOR  ${item}  IN  @{serial_port_list}
        Append To List    ${ru_port_list}    ${item}
        ${ru_serial_log_path}   Set Variable   ${target_dir}/RMOD_SERIAL_LOG/${host_alias}/${item}/RU_SERIAL_LOG.txt
        ru_serial.download_log    local_path=${ru_serial_log_path}   alias=${item}
    END
    [Teardown]   Run Keyword And Ignore Error   RMOD Serial Port teardown by Common KW   ru_port=${ru_port_list}    connection=${host_alias}

Get RMOD Serial log download by Common KW
    [Arguments]  ${rmod_serial_config_load}    ${target_dir}=${TS_CASE_LOG_PATH}
    ${testline_name}    Get Testline Name
    ${serial_config}    Set Variable    ${CURDIR}/../../../../../../../../commissionings/HGZ/${testline_name}/serial.yaml
    FOR  ${key}  IN  @{rmod_serial_config_load.keys()}
        Log    ${key}
        ${value}=    Get From Dictionary    ${rmod_serial_config_load}    ${key}
        ${sn_port_list}    Get Dictionary Keys    ${value}
        Download RMOD Serial log by Common KW    host_alias=${key}    serial_port_list=${sn_port_list}    config_path=${serial_config}
        ...    target_dir=${target_dir}
    END
    [Teardown]   Run Keyword And Ignore Error   RMOD Serial Port shutdown by Common KW   config_path=${serial_config}

Get RMOD Serial log config load by Common KW
    ${testline_name}    Get Testline Name
    ${serial_config}    Set Variable    ${CURDIR}/../../../../../../../../commissionings/HGZ/${testline_name}/serial.yaml
    ${ru_serial_info}=    ru_serial.load_config    config=${serial_config}
    [Return]     ${ru_serial_info}

Config load RMOD Serial log by Common KW
    ${testline_name}    Get Testline Name
    ${serial_config}    Set Variable    ${CURDIR}/../../../../../../../../commissionings/HGZ/${testline_name}/serial.yaml
    ${status}    ${RMOD_SERIAL_INFO}    Run Keyword And Ignore Error    Get RMOD Serial log config load by Common KW
    run keyword if    '${status}'=='FAIL'
    ...   Run Keyword And Ignore Error   RMOD Serial Port shutdown by Common KW   config_path=${serial_config}
    ...   ELSE    set suite variable    ${RMOD_SERIAL_INFO}
    #${RMOD_SERIAL_INFO}      Get From List      ${RMOD_SERIAL_INFO}      1
