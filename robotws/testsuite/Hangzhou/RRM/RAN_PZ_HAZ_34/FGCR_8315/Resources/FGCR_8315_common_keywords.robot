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
Library    taf.gnb.oam.commissioning   WITH NAME    commissioning
Library    taf.hw.rf_attenuator    WITH NAME    att
#Library    ./../../../../../resources/python_libs/Attenuation.py
#Library    Attenuation.Attenuation    WITH NAME    atten
Library     taf.hw.rf_attenuator    WITH NAME    attenuator
Resource    taf/rfrl/common_resources/robot/gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BIP_trace/BIP_trace_collector.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Collect_logs.robot

*** Variables ***
${WEBUI_COAM}    https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_NAME}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
${asik_addr}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${asik_username}    ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${asik_password}    ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${gnb_path}    /tmp/
${epc_log_path}    /opt/workspace/CIT/Master/Case_Logs/
${tl_scf_dir_path}    /opt/workspace/CRT/Master/SCF_file/
${TS_LOG_PATH_BASE}    /opt/workspace/CIT/Master/Case_Logs/
${gnb_instance}     ${tl.gnbs[0].instance_id}
${cell1_distname}    MRBTS-${gnb_instance}/NRBTS-${gnb_instance}/NRCELL-1
${bts_distname}    MRBTS-${gnb_instance}/NRBTS-${gnb_instance}
${asp_1a_addr}        ${tl.gnbs[0].cu.f1m.v6}
#${asp_1a_addr_1}        ${tl.gnbs[1].cu.f1m.v6}
${asp_1a_username}    ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${asp_1a_password}    ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${tshark_path}      /usr/bin/tshark
${LUA_SCRIPT_PATH}    /opt/workspace/CRT/Master/luashark/generated_luashark/luashark.lua
${ALIAS_ASIK}    ASIK

##eNB parameter##
${eNB_cell1_distname}    MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-1
${eNB_cell1_distname_1}    MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-0
${eNB_parameter}    administrativeState
${eNB_asik_addr}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}

###UE ###
${ue_type}    huawei

###PA parameter for 21A###
${att_ipaddr_1}    ${tl.attenuator[0].ip_addr}

${att_port1_341}    ${tl.attenuator[0].attenuator_ports[1]}
${att_port2_341}    ${tl.attenuator[0].attenuator_ports[2]}
${att_port3_341}    ${tl.attenuator[0].attenuator_ports[3]}
${att_port4_341}    ${tl.attenuator[0].attenuator_ports[4]}
${att_port5_341}    ${tl.attenuator[0].attenuator_ports[5]}
${att_port6_341}    ${tl.attenuator[0].attenuator_ports[6]}
${att_port7_341}    ${tl.attenuator[0].attenuator_ports[7]}
${att_port8_341}    ${tl.attenuator[0].attenuator_ports[8]}
${att_port9_341}    ${tl.attenuator[0].attenuator_ports[9]}
${att_port10_341}    ${tl.attenuator[0].attenuator_ports[10]}
${att_port11_341}    ${tl.attenuator[0].attenuator_ports[11]}
${att_port12_341}    ${tl.attenuator[0].attenuator_ports[12]}

###PA parameter for master###
${att_api_port}    ${tl.attenuator[0].port}
${atten_ports}    ${tl.attenuator[0].attenuator_ports[0]}
${max_attenuation_value}     ${127}
${vendor}    ${tl.attenuator[0].vendor}

${att_api_port_topyoung}              ${tl.attenuator[1].port}
${vendor_topyoung}          ${tl.attenuator[1].vendor}
${max_attenuation_value_topyoung}     ${120}

${HBTE_att_port_9}                 ${tl.attenuator[0].attenuator_ports[5]}
${HBTE_att_port_10}                ${tl.attenuator[0].attenuator_ports[6]}
${HBTE_att_port_11}                ${tl.attenuator[0].attenuator_ports[7]}
${HBTE_att_port_12}                ${tl.attenuator[0].attenuator_ports[8]}
${HBTE_att_port_13}                ${tl.attenuator[0].attenuator_ports[9]}
${HBTE_att_port_14}                ${tl.attenuator[0].attenuator_ports[10]}
${HBTE_att_port_15}                ${tl.attenuator[0].attenuator_ports[11]}
${HBTE_att_port_16}                ${tl.attenuator[0].attenuator_ports[12]}

${HBTE_gNB1_att_port1}                ${tl.attenuator[0].attenuator_ports[1]}
${HBTE_gNB1_att_port2}                ${tl.attenuator[0].attenuator_ports[2]}
${HBTE_gNB1_att_port9}                ${tl.attenuator[0].attenuator_ports[3]}
${HBTE_gNB1_att_port10}               ${tl.attenuator[0].attenuator_ports[4]}

${4GRU_ANT11}    ${tl.attenuator[0].attenuator_ports[11].port_no}
${HBTE_eNB_att_port16}    ${tl.attenuator[0].attenuator_ports[13]}
${HBTE_eNB_att_port14}    ${tl.attenuator[0].attenuator_ports[14]}
${HBTE_eNB_att_port15}    ${tl.attenuator[0].attenuator_ports[15]}

###PA parameter for 21B###
${21B_att_port_5}                ${tl.attenuator[0].attenuator_ports[5]}
${21B_att_port_6}                ${tl.attenuator[0].attenuator_ports[7]}
${21B_att_port_7}                ${tl.attenuator[0].attenuator_ports[1]}
${21B_att_port_8}                ${tl.attenuator[0].attenuator_ports[2]}
${21B_att_port_13}                ${tl.attenuator[0].attenuator_ports[6]}
${21B_att_port_14}                ${tl.attenuator[0].attenuator_ports[6]}
${21B_att2_port_5}                ${tl.attenuator[0].attenuator_ports[4]}
${21B_att2_port_6}                ${tl.attenuator[0].attenuator_ports[3]}
*** Keywords ***
## GNB BTS Precondition ##
Prepare the classical COAM BTS cell onair
    ${cell_status}    ${cell_value} =    Run Keyword And Ignore Error    Prepare with COAM classical BTS cell onair
    set suite variable    ${cell_status}

Prepare with COAM classical BTS cell onair
    Perform full commission for COAM gnb
    Check gnb COAM classical start normally
    Wait the gNB cell onair

Perform full commission for COAM gnb
    [Arguments]    ${WEBUI_COAM}=${WEBUI_COAM}    ${tl_scf_filename}=${tl_scf_filename}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    selenium_coam.load_commissioning_file_and_check_load_status    ${tl_scf_dir_path}${tl_scf_filename}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    10s
    Run Keyword And Ignore Error    selenium_coam.logout
    sleep    1min
    [teardown]    Run Keyword And Ignore Error    selenium_coam.logout

Check gnb COAM classical start normally
    wait until keyword succeeds    15min   60s    Check the gnb RU status ready

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

Connect to Classical Common Unit Master gnb
    [Arguments]    ${gnb_index}=${0}    ${du_index}=${0}    ${alias}=ASIK Master
    ${gnbs}    testline_info.get_classicalbts_gnbs    tl=${tl}
    ssh.Connect to    hostname=${gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...               username=${gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...               password=${gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...               alias=${alias}

gNB connections
    [Arguments]    ${ip_addr}=${asik_addr}    ${gnb}=ASIK
    csn.connect To    hostname=${ip_addr}
    ...               username=${asik_username}
    ...               password=${asik_password}
    ...               alias=${gnb}

Connect to ASIK slave
    [Arguments]    ${asik_slave}=${asik_slave}    ${proxy}=ASIK
    csn.Connect to    hostname=${fct_addr}    username=${asik_username}
    ...    password=${asik_password}    alias=${asik_slave}    proxy=${proxy}

Start capture gNB log on master
    [Arguments]    ${filename}
    wait until keyword succeeds    1min   10s    gNB connections
    csn.send command    command=tcpdump -i any sctp -w ${gnb_path}${filename}   connection=${ALIAS_ASIK}

Start capture gNB log on slave
    [Arguments]    ${filename}
    gNB connections
    Connect to ASIK slave
    csn.send command    command=tcpdump -i any sctp -w ./${filename}   connection=${asik_slave}

Stop and download the Logs on slave
    [Arguments]    ${filename}
    gNB connections
    Connect to ASIK slave
    csn.send command    command=killall tcpdump     connection=${asik_slave}
    sleep    3
    csn.send command    command=cp ./${filename} ${gNB_master_log}/${filename}    connection=${asik_slave}
    csn.download_file   remote_path=${gNB_master_log}/${filename}   local_path=${epc_log_path}${filename}   connection=${ALIAS_ASIK}
    sleep    3

Stop and download the Logs
    [Arguments]    ${filename}
    wait until keyword succeeds    1min   10s    gNB connections
    csn.send command    command=killall tcpdump     connection=${ALIAS_ASIK}
    sleep    3
    csn.download_file   remote_path=${gnb_path}${filename}   local_path=${epc_log_path}${filename}   connection=${ALIAS_ASIK}
    sleep    3

Stop and download Logs on gNB on master
    [Arguments]    ${filename}
    wait until keyword succeeds    1min   10s    FGCR_8315_common_keywords.Stop and download the Logs    filename=${filename}

Unlock the gNB cell
    [Arguments]    ${cell_idx}=${1}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${cell_idx}  Convert To Integer    ${cell_idx}
    selenium_coam.unlock_cell    cell_idx=${cell_idx}
    Sleep  30 sec
    [Teardown]  Run keyword and ignore error    selenium_coam.logout

Get gnb release
    [Arguments]   ${host}=${asik_addr}   ${username}=${asik_username}   ${password}=${asik_password}
    csn.Connect To   hostname=${host}   username=${username}   password=${password}   alias=release_info
    ${info}   csn.Execute    command=ls /ffs/run/TargetBD*xml   connection=release_info
#    ${release_info}     set variable    ${info.split('_')[3]}
    ${release_info}    set variable    ${info.split('_')[1]}_${info.split('_')[2]}_${info.split('_')[3]}
    [Return]    ${release_info}
    [Teardown]   csn.Disconnect   connection=release_info

bip capture on ABIO and download to UTE
    [Arguments]    ${script_path}    ${capturing_time_seconds}=3    ${gnb_index}=${0}
    Connect to Classical Common Unit Master gnb    gnb_index=${gnb_index}
#    gNB connections
    Precondition for bip capture with gnbMirroring scripts    script_path=${script_path}
    Bip Capture with gnbMirroring scripts 8315    gnb_index=${gnb_index}    capturing_time_seconds=${capturing_time_seconds}


Bip Capture with gnbMirroring scripts 8315
    [Arguments]    ${gnb_index}=${0}    ${connection}=ASIK Master    ${gnb_mirroring}=gnbMirroring.sh
    ...            ${capturing_time_seconds}=infinite
    Connect to Classical Common Unit Master gnb    gnb_index=${gnb_index}
    ${cmd_local}    catenate    sh /ffs/run/config/scripts/${gnb_mirroring} --capturing_time_seconds=${capturing_time_seconds}
    csn.send_command    command=${cmd_local}    connection=${connection}
#    csn.send_command
#    ...    command=cd ${AT_script_path} && python ATcommand.py -p com${COM_port} -c "${command}"
#    ...    connection=cygwin${ue_index}
    ${output}    csn.Read Output    connection=${connection}
    sleep    3s
    should contain    ${output}    Dump files in /tmp/ folder

Connect to ABIO
    [Arguments]    ${asik_slave}=${asik_slave}    ${proxy}=ASIK
    csn.Connect to    hostname=${asp_1a_addr}    username=${asp_1a_username}
    ...    password=${asp_1a_password}    alias=${asik_slave}    proxy=${proxy}



## huawei ##
huawei UE setup
    power_ue.Prepare UE    ue_type=${ue_type}

huawei UE teardown
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}

huawei UE attach
    [Arguments]    ${gnb_index}=${0}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}  gnb_index=${gnb_index}
    power_ue.Verify attach    ue_type=${ue_type}   gnb_index=${gnb_index}    4G_check=False    5Grach_ed=${5Grach_ed}

## eNB BTS Precondition ##
Unlock eNB and wait cell onair
    Unlock the eNB cell
    Wait until enb cell on air status

Commit SCF to eNB
    [Arguments]    ${eNB_asik_addr}    ${scf_file}    ${connection}=eNB
    enblte.connect_to    bts_host=${eNB_asik_addr}
    ...    bts_port=443  use_ssl=True    name=${connection}
    enblte.perform_commissioning    scf_file=${tl_scf_dir_path}${scf_file}    skip_parameter_relation_errors=${True}
    ...     should_activate=${True}    connection=${connection}    timeout=300

Start to collect the log on eNB
    [Arguments]    ${log_name}
    wait until keyword succeeds    1 min    10 sec    Connect to eNB   enb_index=${0}    alias=ENB
    csn.send command    command=tcpdump -i any sctp -w /tmp/${log_name}   connection=ENB

Stop and download Logs on eNB
    [Arguments]     ${log_name}
    wait until keyword succeeds    1 min    10 sec    Connect to eNB    enb_index=${0}   alias=ENB
    sleep    10
    csn.send command    command=killall tcpdump     connection=ENB
    sleep    5
    csn.download_file   remote_path=/tmp/${log_name}   local_path=${epc_log_path}${log_name}   connection=ENB

Case recover
    Run Keyword And Ignore Error    huawei UE teardown
    FGCR_8315_common_keywords.Stop and download Logs on gNB on master     filename=${gNB_log_A4}
    FGCR_8315_common_keywords.Stop and download Logs on eNB    log_name=${eNB_log_A4}
    Run Keyword And Ignore Error    Set the env PA as default
    Run keyword and ignore error    CI_interface.Common Case Teardown
    Modify NIDD parameter for 8315   parameters_to_update=${PARAMETERS_TO_UPDATE_recover}

###check BIP log ###
Check the SIB5 contain eutra multiBandInfoList
    [Arguments]    ${biplog}    ${band_1}    ${band_2}    ${cellid_1}    ${cellid_2}    ${Priority_1}    ${Priority_2}
    ${all_packets}=    load_pcap_file    pcap_file=${biplog}
    ${filter_expression}=    Catenate    nr-rrc.EUTRA_MultiBandInfo_element and dldata_pdschpayloadtbsendreq
    ${filtered_packets}=    filter_packets_by_expression    filter_expression=${filter_expression}
    ${multiBandInfoList}=    get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//nr-rrc.eutra_FreqBandIndicator
    should be equal    '${multiBandInfoList[-1]}'    '${band_1}'
    should be equal    '${multiBandInfoList[-2]}'    '${band_2}'
    ${physCellId}=   get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//nr-rrc.physCellId
    should be equal    '${physCellId[-1]}'    '${cellid_1}'
    should be equal    '${physCellId[-2]}'    '${cellid_2}'
    ${cellReselectionPriority}=   get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//nr-rrc.cellReselectionPriority
    should be equal    '${cellReselectionPriority[-1]}'    '${Priority_1}'
    should be equal    '${cellReselectionPriority[-2]}'    '${Priority_2}'


Adjust the HBTE attenuation value
    [Arguments]     ${value_1}     ${value_2}     ${value_3}     ${value_4}
    ...             ${att_port_1}    ${att_port_2}     ${att_port_3}
    ...             ${att_port_4}     ${atten_ip}    ${att_api_port}=${att_api_port}
    ...             ${vendor}=${vendor}
    attenuator.setup_attenuator    ip_addr=${atten_ip}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_port_1}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    attenuator.set_attenuation     port=${att_port_1}    value=${value_1}
    attenuator.set_attenuation     port=${att_port_2}    value=${value_2}
    attenuator.set_attenuation     port=${att_port_3}    value=${value_3}
    attenuator.set_attenuation     port=${att_port_4}    value=${value_4}
    ${value_port_1}    attenuator.read_attenuation    port=${att_port_1}
    should be equal    ${value_port_1}    ${value_1}
    ${value_port_2}    attenuator.read_attenuation    port=${att_port_2}
    should be equal    ${value_port_2}    ${value_2}
    ${value_port_3}    attenuator.read_attenuation    port=${att_port_3}
    should be equal    ${value_port_3}    ${value_3}
    ${value_port_4}    attenuator.read_attenuation    port=${att_port_4}
    should be equal    ${value_port_4}    ${value_4}


Adjust the Attenuation Value
    [Arguments]    ${atten_ip}    ${value_1}    ${value_2}    ${port_1}    ${port_2}
    @{att_connection_port}   Create list    ${port_1}    ${port_2}
    att.setup_attenuator    ip_addr=${atten_ip}   port=${att_api_port_topyoung}
    ...    attenuation_port_numbers=${att_connection_port}      max_attenuation=${max_attenuation_value_topyoung}
    ...    vendor=${vendor_topyoung}
    att.set_attenuation     port=${port_1}   value=${value_1}
    ${value_port_1}    att.read_attenuation    port=${port_1}
    should be equal    ${value_port_1}    ${value_1}
    att.set_attenuation     port=${port_2}    value=${value_2}
    ${value_port_2}    att.read_attenuation    port=${port_2}
    should be equal    ${value_port_2}    ${value_2}

Modify NIDD parameter for 8315
    [Arguments]    ${parameters_to_update}
    ...    ${bts_host}=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[0].cu.oam_http_connection_details.password}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters_to_update}
    sleep    5
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

Reset UE Control PC
    [Documentation]  To reset te UE control pc which is windows system.
    [Arguments]    ${ue_index}=${0}
    Connect to control pc enhanced    ${ue_index}
    csn.Send Command    command=shutdown -r -t 3     connection=cpc_${ue_index}    timeout=5
    csn.disconnect      connection=cpc_${ue_index}
    sleep    180s
