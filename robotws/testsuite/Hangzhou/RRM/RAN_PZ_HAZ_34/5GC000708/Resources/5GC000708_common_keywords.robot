*** Settings ***
Documentation
...    author: Xing Jing
...    contact: jing.1.xing@nokia-sbell.com
...    squad group: SG_03

Library    OperatingSystem
Library    Collections
Library    String
Library    BuiltIn
Library    taf.config.scf    WITH NAME    scf
Library    taf.transport.ssh    WITH NAME    csn
Library    taf.transport.ssh    WITH NAME       ssh
Library    taf.gnb.oam.commissioning   WITH NAME    commissioning
Library    taf.gnb.oam.megazone_client    WITH NAME    megazone_client
Library    taf.ul.oam.selenium_megazone    WITH NAME    selenium_megazone
Library    taf.hw.rf_attenuator    WITH NAME    attenuator
#Library    ./../../../../../resources/python_libs/Attenuation.py
#Library    Attenuation.Attenuation    WITH NAME    atten
Library     taf.hw.rf_attenuator    WITH NAME    att
Library     taf.config.testline    WITH NAME    testline
Library    taf.analyzer.pcap   WITH NAME    pcap
Library      taf.ul.messaging.mtk    WITH NAME    message
Resource    taf/rfrl/common_resources/robot/gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot


*** Variables ***
${WEBUI_COAM}    https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_NAME}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
${gnb2_WEBUI_COAM}    https://${tl.gnbs[1].cu.oam_http_connection_details.addr}
${asik_addr}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${asik2_addr}    ${tl.gnbs[1].dus[0].airscale.common_units[0].lmp_connection.addr}
${asik_username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${asik_password}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${gnb1_host}        ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${gnb2_host}        ${tl.gnbs[1].cu.oam_ssh_connection_details.addr}
${gnb_path}    /tmp/
${iperf_path}    ${tl.ues[0].iperf_details.iperf_path}
${tl_scf_dir_path}    /home/ute/SCF/
${gnb_instance}     ${tl.gnbs[0].instance_id}
${cell1_distname}    MRBTS-${gnb_instance}/NRBTS-${gnb_instance}/NRCELL-1
${bts_distname}    MRBTS-${gnb_instance}/NRBTS-${gnb_instance}
${ALIAS_ASIK}    ASIK
${ALIAS_ASIK2}    ASIK2
#${TS_CASE_LOG_PATH}    /tmp
${M55125C01001_path}    CELLS/NRCELL-1/NNGCC/NNGCC_UE_CTXT_REL_REQ_SENT
${M55125C00501_path}    CELLS/NRCELL-1/NNGCC/NNGCC_UE_CTXT_REL_CMD_RECD
${M55125C00502_path}    CELLS/NRCELL-1/NNGCC/NNGCC_UE_CTXT_REL_CMP_SENT
${M55124C01501_path}    CELLS/NRCELL-1/NRRCC/NRRCC_RRC_RELEASE_REDIR_NR
${gNB_CPUE}    /rom/cp_runtime.ini
${UTE_CPUE}    /home/ute/SCF/cp_runtime.ini
${gNB_CPUE_PATH}    /tmp/node_CPUE20/tmp
${CPUE_LOG}    startup_cp_ue.log
${gNB_CPUE_LOG_XZ_PATH}    /ffs/run/logs/CPUE20_aasyslog/
${gNB_CPUE_LOG_XZ}    startup_cp_ue.log.xz
${pdu_gnb2_addr}    ${tl.gnbs[1].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
@{pdu_gnb2_port}    ${tl.gnbs[1].dus[0].airscale.common_units[0].pdu_port.port_no}
######eNB parameter######
${eNB_cell1_distname}    MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-1
${enb_instance}              ${tl.enbs[0].instance_id}
${enbcell_dist_TL343}        MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-0
${eNB_parameter}    administrativeState
${eNB_asik_addr}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
######MTK parameter######
${IMSI}            ${tl.ues[0].imsi}
${MTK_CtrlPC_IP}            ${tl.ues[0].ssh_connection_details.addr}
${MTK_CtrlPC_USERNAME}      ${tl.ues[0].ssh_connection_details.username}
${MTK_CtrlPC_PASSWORD}      ${tl.ues[0].ssh_connection_details.password}
${mtk_pdu_ip}    ${tl.ues[0].pdu.pdu.addr}
${mtk_pdu_port}    ${tl.ues[0].pdu.port_no}
## Attenuator parameter ##
${atten_ip}    ${tl.attenuator[0].ip_addr}
${5GRU1_ANT1}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${5GRU1_ANT2}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}

### Trunk PA ###
${5GRU2_ANT1}       ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[0].port_no}
${5GRU2_ANT2}       ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[1].port_no}
${5GRU2_ANT3}       ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[2].port_no}
${5GRU2_ANT4}       ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[3].port_no}


### 20A PA ###
${vendor}                    HBTE
${max_attenuation_value}     ${127}
${att_ipaddr}                ${tl.attenuator[0].ip_addr}
${att_connection_port}       ${tl.attenuator[0].attenuator_ports[5]}
${att_api_port}              ${tl.attenuator[0].port}
${att_port_5}                ${tl.attenuator[0].attenuator_ports[5]}
${att_port_6}                ${tl.attenuator[0].attenuator_ports[6]}
${att_port_7}                ${tl.attenuator[0].attenuator_ports[7]}
${att_port_8}                ${tl.attenuator[0].attenuator_ports[8]}

*** Keywords ***
## GNB BTS Precondition ##
Prepare the classical COAM BTS cell onair
    ${cell_status}    ${cell_value} =    Run Keyword And Ignore Error    Prepare with COAM classical BTS cell onair
    set suite variable    ${cell_status}

Prepare with COAM classical BTS cell onair
    Enable RD flag of rdUeContextRequest
    Active CPUE log    ip_addr=${asik_addr}    gnb=${ALIAS_ASIK}
    Perform full commission for COAM gnb
    Check gnb COAM classical start normally
    Wait the gNB cell onair

Prepare with one BTS cell onair with disable RD flag
    [Arguments]    ${gnb_addr}=${gnb_addr}    ${ALIAS}=${ALIAS}     ${tl_scf_filename}=${tl_scf_filename}
    ...     ${bts_host}=${bts_host}     ${username}=${WEBUI_NAME}     ${password}=${WEBUI_PWD}
    Disable RD flag of rdUeContextRequest    ip_addr=${gnb_addr}    gnb=${ALIAS}
    Active CPUE log    ip_addr=${gnb_addr}    gnb=${ALIAS}
    Perform full commission for COAM SA gnb    scf=${tl_scf_dir_path}${tl_scf_filename}
      ...    gnb_ip=${bts_host}    username=${username}    password=${password}
    COAM Wait for gnb ready SA    bts_host=${bts_host}    username=${username}    password=${password}

#Check one BTS cell onair with disable RD flag
#    [Arguments]    ${gnb_addr}=${gnb_addr}    ${ALIAS}=${ALIAS}     ${tl_scf_filename}=${tl_scf_filename}
#    ...    ${bts_host}=${bts_host}
#    ${cell_status}    ${cell_value} =      Prepare with one BTS cell onair with disable RD flag
#    ...    gnb_addr=${gnb_addr}    ALIAS=${ALIAS}     tl_scf_filename=${tl_scf_filename}
#    ...    bts_host=${bts_host}
#    set suite variable    ${cell_status}

Check one BTS cell onair with disable RD flag
    [Arguments]    ${gnb_addr}=${gnb_addr}    ${ALIAS}=${ALIAS}     ${tl_scf_filename}=${tl_scf_filename}
    ...    ${bts_host}=${bts_host}
    Prepare with one BTS cell onair with disable RD flag
    ...    gnb_addr=${gnb_addr}    ALIAS=${ALIAS}     tl_scf_filename=${tl_scf_filename}
    ...    bts_host=${bts_host}

Perform full commission for COAM SA gnb
    [Arguments]    ${scf}    ${gnb_ip}    ${username}    ${password}
    Connect to gnb coam via ssl   bts_host=${gnb_ip}    username=${username}      password=${password}
    COAM Commission with scf file    scf_file_path=${scf}    timeout=500    is_pdl_checking_needed=${False}
    COAM Teardown gnb connections

COAM Wait for gnb ready SA
    [Documentation]  Author: Ding Binmei
    ...              Description: Wait until GNB status ready.
    [Timeout]  30 min
    [Arguments]  ${timeout}=10 min    ${connection}=GNB_OAM    ${bts_host}=${bts_host}    ${username}=${username}    ${password}=${password}
    Wait until keyword succeeds    ${timeout}    20 sec    Connect to gnb coam via ssl    connection=${connection}
    ...                    bts_host=${bts_host}
    ...                    username=${username}
    ...                    password=${password}
    Wait until keyword succeeds    ${timeout}    20 sec    COAM Check GNB ABIL status    connection=${connection}
    Wait until keyword succeeds    ${timeout}    20 sec    COAM Check GNB ASIK status    connection=${connection}
    Wait until keyword succeeds    ${timeout}    20 sec    COAM Check GNB RU status    connection=${connection}
    COAM Teardown gnb connections

Prepare the Trunk BTS cell onair
    [Arguments]    ${ip_addr}=${asik2_addr}    ${gnb}=${ALIAS_ASIK2}
    ${cell_status}    ${cell_value} =    Run Keyword And Ignore Error    Prepare with Trunk BTS cell onair    ip_addr=${ip_addr}    gnb=${gnb}
    set suite variable    ${cell_status}

Prepare with Trunk BTS cell onair
    [Arguments]     ${ip_addr}=${asik2_addr}    ${gnb}=${ALIAS_ASIK2}    ${tl_scf_filename}=${tl_scf_filename}
    ...     ${tl_scf_filename_gnb2}=${gNB2_tl_scf_filename}
    wait until keyword succeeds    3min   30s    Enable RD flag of rdUeContextRequest    ip_addr=${ip_addr}    gnb=${gnb}
    wait until keyword succeeds    3min   30s    Active CPUE log    ip_addr=${ip_addr}    gnb=${gnb}
    Perform full commission for COAM SA gnb    scf=${tl_scf_dir_path}${tl_scf_filename}
      ...    gnb_ip=${gnb1_host}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    Perform full commission for COAM SA gnb    scf=${tl_scf_dir_path}${tl_scf_filename_gnb2}
      ...    gnb_ip=${gnb2_host}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    COAM Wait for gnb ready SA    bts_host=${gnb1_host}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    COAM Wait for gnb ready SA    bts_host=${gnb2_host}    username=${WEBUI_NAME}    password=${WEBUI_PWD}

Perform full commission for COAM gnb
    [Arguments]    ${WEBUI_COAM}=${WEBUI_COAM}    ${tl_scf_filename}=${tl_scf_filename}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    selenium_coam.load_commissioning_file_and_check_load_status    ${tl_scf_dir_path}${tl_scf_filename}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    8s
    selenium_coam.logout
    sleep    1min

Modify parameters online for cases
    [Arguments]    ${parameters_to_update}    ${download_dir}=${epc_log_path}    ${WEBUI}=${WEBUI_COAM}
    COAM modify several parameters via webUI   parameters_to_update_via_webui=${parameters_to_update}
    ...    download_dir=${download_dir}    WEBUI_COAM=${WEBUI}

COAM modify several parameters via webUI
    [Arguments]      ${parameters_to_update_via_webui}    ${download_dir}
    ...       ${WEBUI_COAM}=${WEBUI_COAM}
    ...       ${is_need_to_check_validation_errors}=${False}
    ...       ${is_gnb_restrat_after_online_modify}=${False}
    COAM login page via webUI    download_dir=${download_dir}    WEBUI_COAM=${WEBUI_COAM}
    @{diff_para} =    create list
    FOR  ${cur_para_to_update}  IN  @{parameters_to_update_via_webui}
        ${cur_para_value}    selenium_coam.get_parameter_value
        ...    dist_name=${cur_para_to_update['dist_name']}
        ...    abbr=${cur_para_to_update['abbr']}
        ...    filter_param=${cur_para_to_update['filter_param']}
        Run keyword if    '${cur_para_value}'=='${cur_para_to_update['new_value']}'
        ...    Log to console    current value is ${cur_para_value}, no need to update
        ...    ELSE    run keywords
        ...    selenium_coam.set_parameter_value
        ...    dist_name=${cur_para_to_update['dist_name']}
        ...    abbr=${cur_para_to_update['abbr']}
        ...    filter_param=${cur_para_to_update['filter_param']}
        ...    new_value=${cur_para_to_update['new_value']}    AND
        ...    Append to list    ${diff_para}    ${cur_para_to_update}
    END
    Run keyword if    ${diff_para}    run keywords
    ...    selenium_coam.validate_plan    AND
    ...    COAM check validation errors from webui
    ...    is_need_to_check_validation_errors=${is_need_to_check_validation_errors}    AND
    ...    selenium_coam.activate_plan    activate_plan_despite_errors=${True}    AND
    ...    COAM Verify gnb on air after activate plan via webUI    download_dir=${download_dir}
    ...    is_gnb_restrat_after_online_modify=${is_gnb_restrat_after_online_modify}
    [Teardown]    selenium_coam.logout

COAM login page via webUI
    [Arguments]  ${download_dir}=${TS_CASE_LOG_PATH}    ${WEBUI_COAM}=${WEBUI_COAM}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}
    ...                    username=${WEBUI_NAME}
    ...                    password=${WEBUI_PWD}
    ...                    download_dir=${download_dir}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    selenium_coam.disable_message_box

Check gnb COAM classical start normally
#    Check Airscale HW module status
    #wait until keyword succeeds    8min   30s    Check the sctp port UP    port_num=${f1_sctp_port}
    wait until keyword succeeds    15min   60s    Check the gnb RU status ready
    #wait until keyword succeeds    8min   30s    Check the sctp port UP    port_num=${x2_sctp_port}

Check the sctp port UP
    [Arguments]    ${port_num}
    ssh.sendCommand    command=netstat -anl |grep sctp    connection=${asik}
    sleep    3s
    ${sctp_status} =    ssh.read_output    connection=${asik}
    should contain     ${sctp_status}     ${port_num}

Check the gnb RU status ready
    [Arguments]    ${WEBUI_COAM}=${WEBUI_COAM}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${ru_status} =    selenium_coam.get_ru_info
    sleep    8s
    selenium_coam.logout
    Get info status check    info_status=${ru_status}

Check the gnb cell status onair
    [Arguments]    ${WEBUI_COAM}=${WEBUI_COAM}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${cell_status} =    selenium_coam.get_cell_info
    sleep    8s
    selenium_coam.logout
    Get info status check    info_status=${cell_status}

Wait the gNB cell onair
    [Arguments]    ${WEBUI_COAM}=${WEBUI_COAM}
    wait until keyword succeeds    15min   1min    Check the gnb cell status onair    WEBUI_COAM=${WEBUI_COAM}

Get info status check
    [Arguments]    ${info_status}
    ${status} =   get from dictionary    ${info_status}    Status
    ${opr_state} =   get from dictionary    ${status}    Operational state
    should be equal    ${opr_state}    Enabled
    ${avi_state} =   get from dictionary    ${status}   Availability status
    should be equal    ${avi_state}    Online
    ${adm_state} =   get from dictionary    ${status}    Administrative state
    should be equal    ${adm_state}    Unlocked

Modify the COAM parameter with admin API
    [Arguments]    ${parameters}    ${bts_host}=${gnb1_host}
    Connect to gnb coam via ssl    bts_host=${bts_host}
    COAM WEBUI Login
    COAM WEBUI Whether Close Start Up View Window
    Wait Until Keyword Succeeds   7m   60s   COAM Check All Cells Onair
    COAM WEBUI Logout
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters}
    COAM Teardown gnb connections

Common Suite Setup for COAM
    COAM Create log directory    is_set_to_test_case_level=${False}
    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
    Set Suite Variable    ${epc_log_path}    ${LOG_PATH}/${time_stamp}/
    Create directory    ${epc_log_path}

Common Suite Teardown for COAM
    connect to gnb coam via ssl
    COAM Download scf from cluster    scf_dir_path=${epc_log_path}
    COAM Save snapshot via rest api    log_path=${epc_log_path}
    COAM Teardown gnb connections
    CI_interface.Common Case Teardown

gNB connections
    [Arguments]    ${ip_addr}=${asik_addr}    ${gnb}=ASIK
    csn.connect To    hostname=${ip_addr}
    ...               username=${asik_username}
    ...               password=${asik_password}
    ...               alias=${gnb}

gNB2 connections
    [Arguments]    ${ip_addr}=${asik2_addr}    ${gnb}=ASIK2
    csn.connect To    hostname=${ip_addr}
    ...               username=${asik_username}
    ...               password=${asik_password}
    ...               alias=${gnb}

Start To Capture Wireshark Logs
    [Arguments]    ${interface}    ${filename}
    wait until keyword succeeds    1min   10s    gNB connections
    csn.send command    command=tcpdump -i ${interface} sctp -w ${gnb_path}${filename}   connection=${ALIAS_ASIK}

Capture Wireshark Logs
    [Arguments]    ${interface}    ${filename}    ${gnb_addr}    ${ALIAS}
    wait until keyword succeeds    1min   10s    gNB connections    ip_addr=${gnb_addr}    gnb=${ALIAS}
    csn.send command    command=tcpdump -i ${interface} sctp -w ${gnb_path}${filename}   connection=${ALIAS}

start capture wireshark log
    [Arguments]    ${interface}    ${filename}    ${gnb_addr}    ${ALIAS}
    wait until keyword succeeds    2min   10s    Capture Wireshark Logs    interface=${interface}    filename=${filename}
    ...        gnb_addr=${gnb_addr}    ALIAS=${ALIAS}

Collect wireshark logs
    [Arguments]    ${filename}    ${gnb_addr}    ${ALIAS}
    wait until keyword succeeds    1min   10s    gNB connections    ip_addr=${gnb_addr}    gnb=${ALIAS}
    csn.send command    command=killall tcpdump     connection=${ALIAS}
    sleep    3
    csn.download_file   remote_path=${gnb_path}${filename}   local_path=${epc_log_path}${filename}   connection=${ALIAS}
    sleep    3

Start To Capture Wireshark Logs on gNB2
    [Arguments]    ${interface}    ${filename}
    wait until keyword succeeds    2min   10s    Start To Capture the Wireshark Logs on gNB2
    ...    interface=${interface}    filename=${filename}

Start To Capture the Wireshark Logs on gNB2
    [Arguments]    ${interface}    ${filename}
    wait until keyword succeeds    1min   10s    gNB connections    ip_addr=${asik2_addr}    gnb=${ALIAS_ASIK2}
    csn.send command    command=tcpdump -i ${interface} sctp -w ${gnb_path}${filename}   connection=${ALIAS_ASIK2}

Stop and download Logs
    [Arguments]    ${filename}
    wait until keyword succeeds    1min   10s    gNB connections
    csn.send command    command=killall tcpdump     connection=${ALIAS_ASIK}
    sleep    3
    csn.download_file   remote_path=${gnb_path}${filename}   local_path=${epc_log_path}${filename}   connection=${ALIAS_ASIK}
    sleep    3

Stop and download Logs on gNB2
    [Arguments]    ${filename}
    wait until keyword succeeds    2min   10s    Stop and download the Logs on gNB2    filename=${filename}

Stop and download the Logs on gNB2
    [Arguments]    ${filename}
    wait until keyword succeeds    1min   10s    gNB2 connections
    csn.send command    command=killall tcpdump     connection=${ALIAS_ASIK2}
    sleep    3
    csn.download_file   remote_path=${gnb_path}${filename}   local_path=${epc_log_path}${filename}   connection=${ALIAS_ASIK2}
    sleep    3

Enable RD flag of rdUeContextRequest
    [Arguments]    ${ip_addr}=${asik_addr}    ${gnb}=${ALIAS_ASIK}
    wait until keyword succeeds    1min   10s    gNB connections    ip_addr=${ip_addr}    gnb=${gnb}
    Modify RD flag of rdUeContextRequest    before_value=rdUeContextRequest=False    after_value=rdUeContextRequest=True
    ...    file=cp_ue.enb_conf.ini    ALIAS_ASIK=${gnb}

Disable RD flag of rdUeContextRequest
    [Arguments]    ${ip_addr}=${asik_addr}    ${gnb}=${ALIAS_ASIK}
    wait until keyword succeeds    1min   10s    gNB connections    ip_addr=${ip_addr}    gnb=${gnb}
    Modify RD flag of rdUeContextRequest    before_value=rdUeContextRequest=True    after_value=rdUeContextRequest=False
    ...    file=cp_ue.enb_conf.ini    ALIAS_ASIK=${gnb}

Modify RD flag of rdUeContextRequest
    [Arguments]    ${before_value}    ${after_value}    ${file}     ${ALIAS_ASIK}=${ALIAS_ASIK}
    csn.Execute    command=rm -rf /tmp/cpue && mkdir /tmp/cpue    connection=${ALIAS_ASIK}
    ${output}    csn.Execute    command=cd /ffs/run/swpool/5G/CPUENODE/addons/ && ls cp_ue_*.txz    connection=${ALIAS_ASIK}
    ${filename}=    Remove String    ${output}    \r\n
    csn.Execute    command=tar -xvf /ffs/run/swpool/5G/CPUENODE/addons/${filename} -C /tmp/cpue   connection=${ALIAS_ASIK}
    csn.Execute    command=sed -i "s/${before_value}/${after_value}/g" /tmp/cpue/opt/nokia/SS_CPLANE/etc/${file}  connection=${ALIAS_ASIK}
    csn.Execute    command=cd /tmp/cpue && tar -Jcvf ${filename} opt/ usr/    connection=${ALIAS_ASIK}
    csn.Execute    command=cd /tmp/cpue && cp ${filename} /ffs/run/swpool/5G/CPUENODE/addons/    connection=${ALIAS_ASIK}
    csn.Execute    command=cd /ffs/run/swpool/5G/CPUENODE/addons/ && crasign ${filename} && rm /ffs/run/HashContainer*    connection=${ALIAS_ASIK}
    #csn.Execute    command=reboot    connection=${ALIAS_ASIK}
    csn.Disconnect    connection=${ALIAS_ASIK}
    #Sleep    3min

Connect to Classical Common Unit Master gnb
    [Arguments]    ${gnb_index}=${0}    ${du_index}=${0}    ${alias}=ASIK Master
    ${gnbs}    testline_info.get_classicalbts_gnbs    tl=${tl}
    ssh.Connect to    hostname=${gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...               username=${gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...               password=${gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...               alias=${alias}

Active CPUE log
    [Arguments]    ${ip_addr}=${asik2_addr}    ${gnb}=${ALIAS_ASIK2}
    wait until keyword succeeds    1min   10s    gNB connections    ip_addr=${ip_addr}    gnb=${gnb}
    csn.upload_file   remote_path=${gNB_CPUE}   local_path=${UTE_CPUE}   connection=${gnb}
    csn.send command    command=sync    connection=${gnb}
    sleep    1s
    csn.send command    command=sync    connection=${gnb}

Get the bts counter ${counter_id} from ${counter_path} as ${expected_value}
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id}
    ...                 full_path=${counter_path}
    ${values}    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
    should be true   ${values[-1]}>=${expected_value}

Lock gnb cell
    [Arguments]    ${parameters}    ${bts_host}=${gnb1_BTS_host}
    ...    ${username}=${gnb_BTS_username}    ${password}=${gnb_BTS_password}
    Connect to gnb coam via ssl     bts_host=${bts_host}    username=${username}    password=${password}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters}
    COAM Teardown gnb connections

Unlock the gNB cell
    [Arguments]    ${url}=${WEBUI_COAM}    ${cell_idx}=${1}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${url}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${cell_idx}  Convert To Integer    ${cell_idx}
    selenium_coam.unlock_cell    cell_idx=${cell_idx}
    Sleep  30 sec
    [Teardown]  Run keyword and ignore error    selenium_coam.logout

Analysis wireshark log to check attach successfully
    [Arguments]     ${logname}    ${asik_addr}=${asik_addr}
    cap.read_cap      cap_file=${epc_log_path}/${logname}    display_filter=ngap
    ${req}     Catenate   ngap.procedureCode == 14 and  ip.dst == ${asik_addr}
    cap.Check Expression    condition_expression=${req}
    ${rsp}     Catenate   ngap.procedureCode == 14 and  ip.src == ${asik_addr}
    cap.Check Expression    condition_expression=${rsp}

Analysis wireshark log to check RRC_Release with redirection
    [Arguments]     ${logname}    ${asik_addr}=${asik_addr}
    cap.read_cap       cap_file=${epc_log_path}${logname}     display_filter=ngap
    ${releaserequest}     Catenate   ngap.procedureCode == 42 and ip.src == ${asik_addr} and ngap.radioNetwork == 41
    cap.Check Expression    condition_expression=${releaserequest}
    ${releasecommand}     Catenate   ngap.procedureCode == 41 and ip.dst == ${asik_addr} and ngap.radioNetwork == 41
    cap.Check Expression    condition_expression=${releasecommand}
    ${releasecomplete}     Catenate   ngap.procedureCode == 41 and ip.src == ${asik_addr}
    cap.Check Expression    condition_expression=${releasecomplete}

MTK Detach
    [Arguments]    ${UE_alias}=UE_1
    ute_ue.detach_ue    ue_alias=${UE_alias}

Huawei UE setup
    power_ue.Prepare UE    ue_type=huawei

Huawei UE teardown
    Run Keyword And Ignore Error    power_ue.Stop traffic    ue_type=huawei    direction=ul
    Run Keyword And Ignore Error    power_ue.Stop traffic    ue_type=huawei    direction=dl
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=huawei

Huawei UE attach
    [Arguments]    ${gnb_index}=${1}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=huawei    gnb_index=${gnb_index}
    power_ue.Verify attach    ue_type=huawei    gnb_index=${gnb_index}    4G_check=False    5Grach_ed=${5Grach_ed}

Start ul data transfer
    [Arguments]    ${throughput}=10M
    power_ue.Start traffic    ue_type=huawei    direction=ul    throughput=${throughput}   duration=90

## modify PA ##
Adjust ${RU} Attenuation to ${value}
    Adjust the Attenuation Value    ports=${5G${RU}_ANT1}    value=${value}
    Adjust the Attenuation Value    ports=${5G${RU}_ANT2}    value=${value}

Modify Trunk_RU2 Attenuation to ${value}
    Adjust the Attenuation Value    ports=${5GRU2_ANT1}    value=${value}
    Adjust the Attenuation Value    ports=${5GRU2_ANT2}    value=${value}
    Adjust the Attenuation Value    ports=${5GRU2_ANT3}    value=${value}
    Adjust the Attenuation Value    ports=${5GRU2_ANT4}    value=${value}

Modify Trunk Attenuation to ${value}
    Adjust the Attenuation Value    ports=${5GRU2_ANT1}    value=${value}
    Adjust the Attenuation Value    ports=${5GRU2_ANT2}    value=${value}

Adjust the Attenuation Value
    [Arguments]    ${ports}    ${value}
    atten.connect to    ip=${atten_ip}
    atten.get_value    channel=${ports}
    atten.set_value    channel=${ports}    value=${value}
    atten.disconnect

Adjust the HBTE attenuation value
    [Arguments]      ${value_1}    ${value_2}    ${value_3}    ${value_4}    ${att_port1}=${att_port_5}
    ...    ${att_port2}=${att_port_6}    ${att_port3}=${att_port_7}    ${att_port4}=${att_port_8}
    [Documentation]    Auther:cris.cai@nokia-sbell.com
    ...                modify HBTE PA 4 port value default value[0-63db] if not set the max_attenuation value below
    ...                for value and not default port 1234, plz set in your case level. setup connection only port1
    ...                if connect on local plz disconnect firstly
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    att.set_attenuation     port=${att_port1}    value=${value_1}
    att.set_attenuation     port=${att_port2}    value=${value_2}
    att.set_attenuation     port=${att_port3}    value=${value_3}
    att.set_attenuation     port=${att_port4}    value=${value_4}
    ${value_port1}    att.read_attenuation    port=${att_port1}
    should be equal    ${value_port1}    ${value_1}
    ${value_port2}    att.read_attenuation    port=${att_port2}
    should be equal    ${value_port2}    ${value_2}
    ${value_port3}    att.read_attenuation    port=${att_port3}
    should be equal    ${value_port3}    ${value_3}
    ${value_port4}    att.read_attenuation    port=${att_port4}
    should be equal    ${value_port4}    ${value_4}

## eNB BTS Precondition ##
Unlock eNB and wait cell onair
    [Arguments]    ${eNB_cell1_distname}=${eNB_cell1_distname}
    Unlock the eNB cell    eNB_cell1_distname=${eNB_cell1_distname}
    Wait until enb cell on air status

Lock the eNB cell
    [Arguments]    ${eNB_cell1_distname}=${eNB_cell1_distname}
    Connect and Modify the parameter on enblte    dist_name=${eNB_cell1_distname}   parameter=${eNB_parameter}     value=locked

Unlock the eNB cell
    [Arguments]    ${eNB_cell1_distname}=${eNB_cell1_distname}
    Connect and Modify the parameter on enblte    dist_name=${eNB_cell1_distname}   parameter=${eNB_parameter}     value=unlocked

Start to collect the S1 log on eNB
    [Arguments]     ${port}=br1     ${S1_log_name}=S1_log_eNB.pcap
    wait until keyword succeeds    10 min    10 sec    Connect to eNB   alias=ENB
    csn.send command    command=tcpdump -i ${port} -w /tmp/${S1_log_name}   connection=ENB

Stop and download S1 Logs on eNB
    [Arguments]     ${S1_log_name}=s1_log_eNB.pcap
    wait until keyword succeeds    10 min    10 sec    Connect to eNB   alias=ENB
    sleep    30
    csn.send command    command=killall tcpdump     connection=ENB
    sleep    5
    csn.download_file   remote_path=/tmp/${S1_log_name}   local_path=${epc_log_path}${S1_log_name}   connection=ENB

##stream parameter##
Case variable set for ${case_key}
    test suite variable set for ${case_key}
#    Set Test Tag

test suite variable set for ${case_key}
    ${release_info}    Get sagnb release
    set suite variable    ${release_info}
    set suite variable    ${qc_id}       ${para_store['${case_key}']['${release_info}']['qc_id']}
    set suite variable    ${gnb_addr}     ${para_store['${case_key}']['${release_info}']['gnb_addr']}
    set suite variable    ${ALIAS}     ${para_store['${case_key}']['${release_info}']['ALIAS']}
#    set suite variable    ${tl_scf_filename}    ${para_store['${case_key}']['${release_info}']['tl_scf_filename']}
    set suite variable    ${bts_host}    ${para_store['${case_key}']['${release_info}']['bts_host']}
    set suite variable    ${bts_host_u}    ${para_store['${case_key}']['${release_info}']['bts_host_u']}
    set suite variable    ${distname}           ${para_store['${case_key}']['${release_info}']['distname']}
    set suite variable    ${WEBUI}              ${para_store['${case_key}']['${release_info}']['WEBUI']}
    set suite variable    ${scf_filename}      ${para_store['${case_key}']['${release_info}']['scf_filename']}
    set suite variable    ${LOCKCELL}         ${para_store['${case_key}']['${release_info}']['LOCKCELL']}
    set suite variable    ${UNLOCKCELL}         ${para_store['${case_key}']['${release_info}']['UNLOCKCELL']}
    set suite variable    ${INDEX}         ${para_store['${case_key}']['${release_info}']['INDEX']}
    set suite variable    ${unlock_WEBUI}         ${para_store['${case_key}']['${release_info}']['unlock_WEBUI']}
    set suite variable    ${unlock_index}         ${para_store['${case_key}']['${release_info}']['unlock_index']}



Get sagnb release
    [Arguments]   ${host}=${asik2_addr}   ${username}=${asik_username}   ${password}=${asik_password}
    csn.Connect To   hostname=${host}   username=${username}   password=${password}   alias=release_info
    ${info}   csn.Execute    command=ls /ffs/run/TargetBD*xml   connection=release_info
#    ${release_info}     set variable    ${info.split('_')[4]}
#    ${release_info}     set variable    ${info.split('_')[1]}
    ${release_info}     set variable    ${info.split('_')[1]}_${info.split('_')[2]}_${info.split('_')[3]}
    [Return]    ${release_info}
    [Teardown]   csn.Disconnect   connection=release_info

