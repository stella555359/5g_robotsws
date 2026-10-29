*** Settings ***
Documentation    author：shanshan zhang
...              contact: shanshan.zhang@nokia-sbell.com
...              squad group: mmw_SG_04

Resource        testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource        testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource        testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BIP_trace/BIP_trace_collector.robot
Resource          ../../CB007608_B-573/Resources/5GC000573_common_keyword.robot
Resource        taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource        testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/log/l1l2bip_collect.robot
Library           BuiltIn
Library           taf.ul.oam.selenium_megazone           WITH NAME    selenium_megazone
Library           taf.collectors.btslog                  WITH NAME    btslog
Library           taf.collectors.core                    WITH NAME    core
Library           taf.config.scf                         WITH NAME    scf
Library           taf.transport.ssh                      WITH NAME    csn
Library           taf.analyzer.pcap                      WITH NAME    cap
Library           taf.gnb.oam.coam.admin                 WITH NAME    admin
Library           taf.selenium.gnb.oam.coam.classical    WITH NAME    selenium_coam
Library           taf.ul.mobile.ui.android               WITH NAME    android_mobile


*** Variables ***
${gNB_ip}                     ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${gNB_username}               ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gNB_password}               ${tl.gnbs[0].cu.oam_http_connection_details.password}
${DU_OAM_SSH_USERNAME}        ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${DU_OAM_SSH_PASSWORD}        ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${TEST_PC_IP}                 ${tl.test_pc.default_ssh_connection_details.addr}
${TEST_PC_USERNAME}           ${tl.test_pc.default_ssh_connection_details.username}
${TEST_PC_PASSWORD}           ${tl.test_pc.default_ssh_connection_details.password}
${Control_PC_IP}              ${tl.ues[0].ssh_connection_details.addr}
${Control_PC_USERNAME}        ${tl.ues[0].ssh_connection_details.username}
${Control_PC_PASSWORD}        ${tl.ues[0].ssh_connection_details.password}
${UE_Serial_Number}           ${tl.ues[0].serial_number}
${bip_log_file}               biplog
${gnb737_cell_dist_name}      /MRBTS-1/RAT-1/NRTS-1/NRBTS_L-10432/NRCELL_L-1
${gnb7372_cell_dist_name}     /MRBTS-1/RAT-1/NRTS-4/NRBTS_L-10431/NRCELL_L-1
${instance_id}              MRBTS-${tl.gnbs[0].instance_id}/
${global_bts_id}            NRBTS-${tl.gnbs[0].global_bts_id}
${BTS_NRCELL}               ${instance_id}${global_bts_id}/NRCELL-1
${BTS1_NRCELL}              ${instance_id}${global_bts_id}/NRCELL-1


*** Keywords ***
Setup Commission SCF for 2056
    [Arguments]      ${BTS_Host}=${gNB_ip}
     ${default_scf}    Get BTS Version And Perare SCF for 2056       gNB_ip=${BTS_Host}
     Connect to gnb coam via ssl    bts_host=${BTS_Host}    username=${gNB_username}    password=${gNB_password}
     COAM Commission with scf file    scf_file_path=${default_scf}     is_pdl_checking_needed=${False}
     Run keyword and ignore error     coam.teardown    connection=GNB_OAM
     Connect to gnb coam via ssl    bts_host=${BTS_Host}    username=${gNB_username}    password=${gNB_password}
     Wait Until Keyword Succeeds   16min   2min   Check cell on air for 2056
     [Teardown]    Run keyword and ignore error     COAM Teardown gnb connections

Get BTS Version And Perare SCF for 2056
    [Arguments]    ${gNB_ip}=${gNB_ip}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl     bts_host=${gNB_ip}
    ${version}    coam.get_sw_version    connection=${connection}
    ${scf_name}    5GC008423_common.Covert_BTS_Version    version=${version}
    ${default_scf}    set variable    ${CURDIR_path_2056}/${scf_name}
    log to console   ${default_scf}
    [Return]    ${default_scf}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections

Check cell on air for 2056
    log_to_console    Check cell on air
    ${status}            coam.get_bts_statuses       connection=GNB_OAM
    ${bts_status}        get from dictionary     ${status}     proceduralState
    should be equal      ${bts_status}      OnAir

Swconfig modification or comissioning
    [Documentation]  Author: Ding Binmei
    ...              Description: Do modification for swconfig file and scf file.
    ...              ${swconfig_modify}: Can be a list for the modified R&D parameters, example input with python format:
    ...                                 ['0x580002=0', '0x580121=0']
    ...              ${is_called_in_test_case_level}: available values: ${True} ${False},
    ...                                               default to ${False} which means keyword is called in test suite setup phase
    [Arguments]    ${swconfig_modify}=${None}     ${is_called_in_test_case_level}=${False}      ${gnb_index}=${0}    ${du_index}=${0}
    ...       ${connection}=GNB_OAM    ${alias}=ASIK Master    ${swconfig_template_path}=${SWCONFIG_DEFAULT_FILE_PATH}
    COAM Create log directory    is_set_to_test_case_level=${is_called_in_test_case_level}
    ${has_cbts}    testline_info.has_cloudBts    ${tl}
    Run keyword if    ${has_cbts}     Cloud DU connect to gnb coam via ssl
    ...    gnb_index=${gnb_index}    du_index=${du_index}    connection=${connection}
    ...    ELSE    Connect to gnb coam via ssl   gnb_index=${gnb_index}    connection=${connection}
    Connect to Common Unit Master    gnb_index=${gnb_index}    du_index=${du_index}    alias=${alias}
    ${local_log_file_folder}    set variable if  ${is_called_in_test_case_level}==${True}    ${TS_CASE_LOG_PATH}    ${SUITE_LOG_PATH}
    ${default_swconfig_file_path}    Copy file    source=${swconfig_template_path}    destination=${local_log_file_folder}/swconfig.txt
    Run keyword if    ${swconfig_modify}!=${None}
    ...    swconf.Modify swConfig file    parametersList=${swconfig_modify}    filePath=${default_swconfig_file_path}
    swconf.Upload swConfig file to asik and crasign    localFilePath=${default_swconfig_file_path}    asik_alias=${alias}
    csn.disconnect    connection=${alias}
    [Teardown]    Run keyword and ignore error    Run keywords    csn.disconnect    connection=${alias}    AND
    ...    COAM Teardown gnb connections    connection=${connection}

Get wireshark log data
    [Arguments]     ${file_path}   ${command}    ${connection}=ute
    5GC000573_common_keyword.Connect to ENB with ssh    hostname=${TEST_PC_IP}
    ...    username=${TEST_PC_USERNAME}     password=${TEST_PC_PASSWORD}    alias=${connection}
    csn.Send Command  command=cat ${file_path} |${command}    connection=${connection}
    ${data}    csn.Read Output    connection=${connection}
    ${data}    strip_string    ${data}
    [Return]   ${data}
    [Teardown]    run keyword and ignore error    csn.Disconnect  	connection=${connection}

BIP Log Convert Pcap To Text
    [Arguments]  ${source}   ${target}   ${filter}   ${connection}=ute
    Log To Console    Convert pcap to text
    5GC000573_common_keyword.Connect to ENB with ssh    hostname=${TEST_PC_IP}
    ...    username=${TEST_PC_USERNAME}     password=${TEST_PC_PASSWORD}    alias=${connection}
    csn.execute
    ...    command=tshark -V -r ${source} -T text -Y '${filter}' > ${OUTPUT_DIR}/${target}
    ...    connection=${connection}
    csn.await execution end    connection=${connection}    timeout=30min
    [Teardown]    run keyword and ignore error    csn.Disconnect  	connection=${connection}

Check wireshark log data not empty for 8423
    [Arguments]    ${filename}    ${command}   ${connection}=ute
    ${data}    Get wireshark log data     file_path=${filename}    command=${command}    connection=${connection}
    should not be empty    ${data}
    log to console    data:${data}
    [Teardown]    run keyword and ignore error    csn.Disconnect	connection=${connection}

Get parameter from BTS WEBUI
    [Arguments]     ${dist_name}=${MR_NR_BTS_NRCELL}    ${filter_param}=P0 nominal PUSCH    ${abbr}=p0NominalPusch
    selenium_coam.Enable Virtual Display
    selenium_coam.login    url=https://${gNB_ip}     username=${gNB_username}   password=${gNB_password}
    ${p0NominalPusch_value}    selenium_coam.get_parameter_value    dist_name=${dist_name}
    ...    filter_param=${filter_param}   abbr=${abbr}
    [Return]    ${p0NominalPusch_value}
    [Teardown]    Run keyword and ignore error    selenium_coam.logout

Block Cell
    [Arguments]    ${connection}=GNB_OAM    ${dist_name}=${gnb7372_cell_dist_name}
    Connect to gnb coam via ssl     bts_host=${gNB_ip}
    ${info}      coam.get_parameters    dist_name=${dist_name}    connection=${connection}
    ${blockingState}    set variable      ${info['stateInfo']['blockingState']}
    run keyword if    '${blockingState}'=="Unblocked"
    ...    coam.block_cell     dist_name=${MR_NR_BTS_NRCELL}    connection=${connection}
    sleep     5s
    ${info1}      coam.get_parameters    dist_name=${dist_name}    connection=${connection}
    ${blockingState1}    set variable      ${info1['stateInfo']['blockingState']}
    should be true    '${blockingState1}'=="Blocked"
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections

UnBlock Cell
    [Arguments]    ${connection}=GNB_OAM    ${dist_name}=${gnb7372_cell_dist_name}
    Connect to gnb coam via ssl     bts_host=${gNB_ip}
    ${info}      coam.get_parameters    dist_name=${dist_name}    connection=${connection}
    ${blockingState}    set variable      ${info['stateInfo']['blockingState']}
    run keyword if    '${blockingState}'=="Blocked"
    ...    coam.unblock_cell     dist_name=${MR_NR_BTS_NRCELL}    connection=${connection}
    sleep     5s
    ${info1}      coam.get_parameters    dist_name=${dist_name}    connection=${connection}
    ${blockingState1}    set variable      ${info1['stateInfo']['blockingState']}
    should be true    '${blockingState1}'=="Unblocked"
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections

Block other Cell
    [Arguments]      ${connection}=GNB_OAM    ${dist_name}=${gnb737_cell_dist_name}
    Connect to gnb coam via ssl     bts_host=${other_bts_ip}
    ${info}      coam.get_parameters    dist_name=${dist_name}    connection=${connection}
    ${blockingState}    set variable      ${info['stateInfo']['blockingState']}
    run keyword if    '${blockingState}'=="Unblocked"
    ...    coam.block_cell     dist_name=${MR_NR_BTS1_NRCELL}        connection=${connection}
    sleep     5s
    ${info1}      coam.get_parameters    dist_name=${dist_name}    connection=${connection}
    ${blockingState1}    set variable      ${info1['stateInfo']['blockingState']}
    should be true    '${blockingState1}'=="Blocked"
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections

Check BTS Cell On Air
    [Arguments]  ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    connection=${connection}
    ${status}            coam.get_bts_statuses       connection=${connection}
    ${bts_status}        get from dictionary     ${status}     proceduralState
    should be equal      ${bts_status}      OnAir
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections   connection=${connection}

Reset Site with admin
    [Arguments]   ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    connection=${connection}
    coam.reset_site   connection=${connection}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Start Capture BIP log
    [Arguments]       ${connection}=DU    ${if_replace}=${True}
#    csn.Connect to    hostname=${gNB_ip}    username=${DU_OAM_SSH_USERNAME}
#    ...    password=${DU_OAM_SSH_PASSWORD}    alias=${connection}
#    ${PID}    Get PID    connection=${connection}
#    ...    command=ps -ef | grep tcpdump | grep -v grep | grep tcpdump_L2L1 | tail -n 1 |awk '{print $2}'
#    csn.send_command    command=kill -9 ${PID}    connection=${connection}
#    run keyword and continue on failure    csn.send_command    command=cd /tmp && rm -rf tcpdump_L2L1_bip*    connection=${connection}
#    Precondition for bip capture with gnbMirroring scripts     connection=${connection}
#    Run keyword if    ${if_replace}==${True}     _replace_gnbMirroringConfig    connection=${connection}
    Log To Console    Capture BIP Logs
    Collect Interface Mirroring Bip Collector
#    csn.send_command   command=sh /ffs/run/config/scripts/gnbMirroring.sh > /dev/null    connection=${connection}
#    [Return]   ${connection}

Stop Capture BIP log and download file
    [Arguments]    ${connection}=UTE
    ${full_log_path}    Get Bip Log Via Interface Mirroring Collector
    ${num}    get length    ${full_log_path}
    csn.Connect to    hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}
    ...    password=${TEST_PC_PASSWORD}    alias=${connection}
    Log To Console    Copy BIP Logs To Test PC
    ${biplog_list}    create list
    FOR    ${item}    IN RANGE    int(${num})
       csn.download_file    remote_path=${full_log_path}[${item}]
       ...    local_path=${LOG_PATH}/${bip_log_file}_${item}.pcap    connection=${connection}
       append to list    ${biplog_list}    ${bip_log_file}_${item}.pcap
    END
    set suite variable    ${biplog_list}    ${biplog_list}
    [Return]    ${biplog_list}
    [Teardown]    csn.Disconnect    connection=${connection}

_replace_gnbMirroringConfig
    [Arguments]    ${connection}
    csn.upload_file     local_path=${CURDIR}/gnbMirroringConfig.sh
    ...    remote_path=/ffs/run/config/scripts/gnbMirroringConfig.sh    connection=${connection}

Get PID
    [Arguments]    ${connection}    ${command}
    Log To Console    Get PID
    csn.send_command    command=${command}   connection=${connection}
    ${PID}    csn.read output    connection=${connection}
    ${PID}    strip_string    ${PID}
    [Return]    ${PID}

Switch UE to NSA model
    [Arguments]     ${mode_name}=5G/LTE/3G/2G (auto connect)    ${apn_NSA}=dxdata1
    Android Mobile Setup
    android_mobile.switch_network_mode    mode_name=${mode_name}    mobile=test
    android_mobile.switch_apn    apn_name=${apn_NSA}      mobile=test
    ${access_name}   android_mobile.get_access_point_name         mobile=test
    log to console    ${access_name}
    android_mobile.disable_volte_calls      mobile=test
    [Teardown]    android_mobile.teardown    mobile=test

Switch UE to SA model
   [Arguments]      ${mode_name}=5G/LTE/3G/2G (auto connect)    ${apn_SA}=SA
   Android Mobile Setup
   android_mobile.switch_network_mode       mode_name=${mode_name}      mobile=test
   android_mobile.switch_apn    apn_name=${apn_SA}      mobile=test
   ${access_name}   android_mobile.get_access_point_name         mobile=test
   log to console    ${access_name}
   android_mobile.enable_volte_calls    mobile=test
   [Teardown]    android_mobile.teardown    mobile=test

Android Mobile Setup
    [Arguments]     ${ui_version}=one ui 3.1      ${serial_number}=${UE_Serial_Number}     ${port}=22    ${alias}=test
    ...     ${host}=${Control_PC_IP}      ${username}=${Control_PC_USERNAME}     ${password}=${Control_PC_PASSWORD}
    android_mobile.setup
    ...   ui_version=${ui_version}
    ...   host=${host}
    ...   username=${username}
    ...   password=${password}
    ...   port=${port}
    ...   serial_number=${serial_number}
    ...   alias=${alias}

Stop Wireshark PID
    [Arguments]   ${filename}    ${index}=${0}    ${alias}=ASIK Master
    5GC000573_common_keyword.Connect to GNB with ssh       gnb_index=${index}    alias=${alias}
    Stop trace capturing    log_prefix=${filename}    connection_alias=${alias}
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${alias}
