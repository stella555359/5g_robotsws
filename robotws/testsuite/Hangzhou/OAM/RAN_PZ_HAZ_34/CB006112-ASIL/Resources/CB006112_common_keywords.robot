*** Settings ***
Documentation     author: yayun.zhang && Xing Jing
...                 contact: yayun.zhang@nokia-sbell.com && jing.1.xing@nokia-sbell.com
...                 squad group: SG_03
...                 feature : CB006112
Library     DateTime
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/Attenuation.py
Library    Attenuation.Attenuation    WITH NAME    atten
Library    taf.analyzer.pcap   WITH NAME    parser
Library     taf.hw.rf_attenuator    WITH NAME    att
Library     taf.config.testline    WITH NAME    testline
Library     taf.transport.ssh    WITH NAME    csn
Library     taf.sbts.oam.coam.admin   WITH NAME    coam
Variables   ../Resources/variables.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource     ./../../common/taf_coam.robot
Library     taf.rfrl.common_resources.python.SWConfig    WITH NAME    SWConfig
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    taf/rfrl/common_resources/robot/stream_manager.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    taf/rfrl/common_resources/robot/TTI_Trace.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot

*** Variables ***
${gnb_path}    /tmp
${connection}    gnb
${tshark_path}      /usr/bin/tshark
${distname_id_1}      MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}
${distname_id_2}      MRBTS-${tl.gnbs[1].instance_id}/NRBTS-${tl.gnbs[1].instance_id}
${LOCAL_MASTER_IP}    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${PEER_MASTER_IP}     ${tl.gnbs[1].cu.oam_http_connection_details.addr}
${WEBUI_COAM}    https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_NAME}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
${WEBUI2_COAM}    https://${tl.gnbs[1].cu.oam_http_connection_details.addr}
${WEBUI2_NAME}    ${tl.gnbs[1].cu.oam_http_connection_details.username}
${WEBUI2_PWD}     ${tl.gnbs[1].cu.oam_http_connection_details.password}
${asik_addr}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${asik_username}    ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${asik_password}     ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${asik2_addr}    ${tl.gnbs[1].cu.oam_ssh_connection_details.addr}
${asik2_username}    ${tl.gnbs[1].cu.oam_ssh_connection_details.username}
${asik2_password}     ${tl.gnbs[1].cu.oam_ssh_connection_details.password}
${enb_address}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${enb_username}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.username}
${enb_password}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.password}
${enb_instance}     ${tl.enbs[0].instance_id}
${vendor}                    HBTE
${max_attenuation_value}     ${127}
${att_ipaddr}                ${tl.attenuator[0].ip_addr}
${att_connection_port}       ${tl.attenuator[0].attenuator_ports[5]}
${att_api_port}              ${tl.attenuator[0].port}
${att_port_5}                ${tl.attenuator[0].attenuator_ports[5]}
${att_port_6}                ${tl.attenuator[0].attenuator_ports[6]}
${att_port_7}                ${tl.attenuator[0].attenuator_ports[7]}
${att_port_8}                ${tl.attenuator[0].attenuator_ports[8]}
${att_port_15}                ${tl.attenuator[0].attenuator_ports[15]}
${att_port_16}                ${tl.attenuator[0].attenuator_ports[16]}

###UE ###
${ue_type}    huawei

*** Keywords ***
###attenuator###
Adjust ${RU} Attenuation to ${value}
    Adjust the Attenuation Value    ports=${5G${RU}_ANT7}    value=${value}
    Adjust the Attenuation Value    ports=${5G${RU}_ANT8}    value=${value}

Adjust the Attenuation Value
    [Arguments]    ${ports}    ${value}
    atten.connect to    ip=${att_ipaddr_1}
    atten.get_value    channel=${ports}
    atten.set_value    channel=${ports}    value=${value}
    atten.disconnect

Adjust the HBTE attenuation value
    [Arguments]      ${value_1}    ${value_2}    ${value_3}    ${value_4}    ${att_port1}=${att_port_5}
    ...    ${att_port2}=${att_port_6}    ${att_port3}=${att_port_7}    ${att_port4}=${att_port_8}
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

##BTS keyword##
Setup for SA Env cell on-air
    Prepare SA classical COAM BTS cell onair
    RUN KEYWORD IF    '${cell_status}'=='FAIL'    Prepare SA classical COAM BTS cell onair
    should be equal    ${cell_status}    PASS

Prepare SA classical COAM BTS cell onair
    ${cell_status}    ${cell_value} =    Run Keyword And Ignore Error    Prepare SA COMA classical BTS cell onair
    set global variable    ${cell_status}

Prepare SA COMA classical BTS cell onair
    Perform full commission for COAM SA gnb    scf=${SCF_path}${SCF_file_name}
    Check gnb COAM classical normally
    Check the gnb cell status onair    cell_no=1

Perform full commission for COAM SA gnb
    [Arguments]    ${scf}=${epc_log_path}${tl_scf_filename}
    ...            ${gnb_ip}=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    Connect to gnb coam via ssl   bts_host=${gnb_ip}
    COAM Commission with scf file    scf_file_path=${scf}    timeout=500    is_pdl_checking_needed=${False}
    COAM Teardown gnb connections

Check gnb COAM classical normally
    ${res} =    Feature 1514 Enabled
    sleep    30s
    Run Keyword And Ignore Error    Check the gnb RU ready

Check the gnb RU ready
    selenium_coam.enable_virtual_display
    wait until keyword succeeds    5min    10s
    ...    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    wait until keyword succeeds    10min    20s    get RU status
    [Teardown]    Run Keywords
    ...    Run keyword and ignore error    selenium_coam.logout                                  AND
    ...    Run keyword and ignore error    selenium_coam.disable_virtual_display

get RU status
    ${ru1_status} =    selenium_coam.get_ru_info    ru_index=1
    sleep    10s
    Get info status check    info_status=${ru1_status}

Check the gnb cell status onair
    [Arguments]    ${gnb_ip}=${WEBUI_COAM}    ${cell_no}=1
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${gnb_ip}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    wait until keyword succeeds    1min    30s    Get all cell info    cell_no=${cell_no}
    [Teardown]    Run Keywords
    ...    Run keyword and ignore error    selenium_coam.logout                                  AND
    ...    Run keyword and ignore error    selenium_coam.disable_virtual_display

Check gnb2 COAM classical normally
    sleep    3s
    wait until keyword succeeds    20min    20s    Check the gnb2 RU ready
#    wait until keyword succeeds    5min   30s    Check the sctp UP on gnb2    port_num=${x2_sctp_port}

Lock The Second gNB
    Connect to gnb coam via ssl    bts_host=${PEER_MASTER_IP}    connection=gnb2
#    coam.lock_cell    dist_name=${distname_id_2}/NRCELL-1    connection=gnb2
    coam.lock   dist_name=${distname_id_2}/NRCELL-2    connection=gnb2    timeout=180s
    coam.teardown    connection=gnb2

Unlock The Second gNB
    Connect to gnb coam via ssl    bts_host=${PEER_MASTER_IP}    connection=gnb2
#    coam.unlock_cell    dist_name=${distname_id_2}/NRCELL-1    connection=gnb2
    coam.unlock    dist_name=${distname_id_2}/NRCELL-2    connection=gnb2    timeout=180s
    coam.teardown    connection=gnb2

Lock The First gNB
    Connect to gnb coam via ssl    bts_host=${LOCAL_MASTER_IP}    connection=gnb1
    coam.lock    dist_name=${distname_id_1}/NRCELL-1    connection=gnb1    timeout=180s
#    coam.lock_cell    dist_name=${distname_id_1}/NRCELL-2    connection=gnb1
    coam.teardown    connection=gnb1

Unlock The First gNB
    Connect to gnb coam via ssl    bts_host=${LOCAL_MASTER_IP}    connection=gnb1
    coam.unlock    dist_name=${distname_id_1}/NRCELL-1    connection=gnb1    timeout=180s
#    coam.unlock_cell    dist_name=${distname_id_1}/NRCELL-2    connection=gnb1
    coam.teardown    connection=gnb1

Lock_gnb2_Cell
    [Arguments]         ${url}=${WEBUI2_COAM}    ${cell_id}=1    ${bts_host}=${asik2_addr}    ${port}=443      ${alias}=OAM_admin
    ...    ${username}=${WEBUI_NAME}    ${password}=${WEBUI_PWD}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${url}    username=${username}    password=${password}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${administrativeState_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${cell_id}
    selenium_coam.logout
    selenium_coam.disable_virtual_display
    coam.connect to   bts_host=${bts_host}
    ...               bts_port=${port}    name=${alias}
    coam.lock_cell    dist_name=/${administrativeState_distname}
    ...               connection=${alias}
    coam.teardown          connection=${alias}

unLock_gnb2_Cell
    [Arguments]         ${url}=${WEBUI2_COAM}    ${cell_id}=1    ${bts_host}=${asik2_addr}    ${port}=443      ${alias}=OAM_admin
    ...    ${username}=${WEBUI_NAME}    ${password}=${WEBUI_PWD}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${url}    username=${username}    password=${password}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${administrativeState_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${cell_id}
    selenium_coam.logout
    selenium_coam.disable_virtual_display
    coam.connect to   bts_host=${bts_host}
    ...               bts_port=${port}    name=${alias}
    coam.unlock_cell    dist_name=${administrativeState_distname}
    ...               connection=${alias}
    coam.teardown          connection=${alias}

Setup for SA Env cell on-air on gnb2
    Prepare SA classical COAM BTS cell onair on gnb2
    RUN KEYWORD IF    '${cell_status}'=='FAIL'    Prepare SA classical COAM BTS cell onair on gnb2
    should be equal    ${cell_status}    PASS

Prepare SA classical COAM BTS cell onair on gnb2
    ${cell_status}    ${cell_value} =    Run Keyword And Ignore Error    Prepare SA COMA classical BTS cell onair on gnb2
    set global variable    ${cell_status}

Prepare SA COMA classical BTS cell onair on gnb2
#    Perform full commission for COAM SA gnb2    scf=${SCF_path}${SCF_file_name_2}    gnb_ip=${asik2_addr}
    ${scfname}    Return scf name for release
    Perform full commission for COAM SA gnb2
    ...    scf=${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/TL830_6112_${scfname}.xml    gnb_ip=${asik2_addr}
    Check gnb2 COAM classical normally
    Check the gnb2 cell status onair    cell_no=1

Perform full commission for COAM SA gnb2
    [Arguments]    ${scf}=${epc_log_path}${tl_scf_filename}
    ...            ${gnb_ip}=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    Connect to gnb coam via ssl   connection=GNB2_OAM    bts_host=${gnb_ip}
    COAM Commission with scf file    scf_file_path=${scf}    connection=GNB2_OAM    timeout=500    is_pdl_checking_needed=${False}
    COAM Teardown gnb connections    connection=GNB2_OAM

Check the gnb2 RU ready
    selenium_coam.enable_virtual_display
    wait until keyword succeeds    5min    10s
    ...    selenium_coam.login    url=${WEBUI2_COAM}    username=${WEBUI2_NAME}    password=${WEBUI2_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    wait until keyword succeeds    15min    20s    get gnb2 RU status
    [Teardown]    Run Keywords
    ...    Run keyword and ignore error    selenium_coam.logout                                  AND
    ...    Run keyword and ignore error    selenium_coam.disable_virtual_display

Compare Lists
    [Arguments]    ${listA}    ${listB}
    ${length}   Get Length   ${listA}
    FOR   ${index}    IN RANGE    ${length}
       Should Be Equal As Strings   ${listA[${index}]}   ${listB[${index}]}
    END

get gnb2 RU status
    ${ru1_status} =    selenium_coam.get_ru_info    ru_index=1
    sleep    10s
    Get info status check    info_status=${ru1_status}

Get info status check
    [Arguments]    ${info_status}
    ${Status} =   get from dictionary    ${info_status}    Status
    ${opr_state} =   get from dictionary    ${Status}    Operational state
    should be equal    ${opr_state.lower()}    enabled
#    ${avi_state} =   get from dictionary    ${Status}   Availability status
#    should be equal    ${avi_state}    Online
    ${adm_state} =   get from dictionary    ${Status}    Administrative state
    should be equal    ${adm_state}    Unlocked

Check the gnb2 cell status onair
    [Arguments]    ${gnb_ip}=${WEBUI_COAM}    ${cell_no}=1
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI2_COAM}    username=${WEBUI2_NAME}    password=${WEBUI2_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    wait until keyword succeeds    5min    30s    Get all cell info    cell_no=${cell_no}
    [Teardown]    Run Keywords
    ...    Run keyword and ignore error    selenium_coam.logout                                  AND
    ...    Run keyword and ignore error    selenium_coam.disable_virtual_display

Get all cell info
    [Arguments]    ${cell_no}
    FOR    ${cell_idx}    IN    1    ${cell_no}
        Get cell info    cell_idx=${cell_idx}
    END

Get cell info
    [Arguments]    ${cell_idx}=1
    ${cell_status} =    selenium_coam.get_cell_info    cell_idx=${cell_idx}
    Get info status check    info_status=${cell_status}

gnb2 connection
    ssh.Connect to    hostname=${asik2_addr}    username=${asik2_username}    password=${asik2_password}    alias=gnb2

gnb2 disconnection
    csn.disconnect      connection=gnb2

Start Capture Wireshark Logs on gNB
    [Arguments]     ${nglogname}    ${interface}
    RUN KEYWORD AND IGNORE ERROR    gNB connections
    csn.send command    command=tcpdump -i ${interface} sctp -w ${gnb_path}/${nglogname}   connection=${connection}
    sleep    3s

gNB connections
    csn.Connect To    hostname=${asik_addr}
    ...               username=${asik_username}
    ...               password=${asik_password}
    ...               alias=gnb

Stop Capture Wireshark Logs on gNB
    [Arguments]    ${nglogname}
    gNB connections
    sleep    5
    csn.send command    command=killall tcpdump     connection=${connection}
    sleep    3
    csn.download_file   remote_path=${gnb_path}/${nglogname}   local_path=${epc_log_path}${nglogname}   connection=${connection}
    sleep    3

Start Capture Wireshark Logs on gNB2
    [Arguments]     ${nglogname}    ${interface}
    RUN KEYWORD AND IGNORE ERROR    gnb2 connection
    csn.send command    command=tcpdump -i ${interface} sctp -w ${gnb_path}/${nglogname}   connection=gnb2
    sleep    3s

Stop Capture Wireshark Logs on gNB2
    [Arguments]    ${nglogname}
    gnb2 connection
    sleep    5
    csn.send command    command=killall tcpdump     connection=gnb2
    sleep    3
    csn.download_file   remote_path=${gnb_path}/${nglogname}   local_path=${epc_log_path}${nglogname}   connection=gnb2
    sleep    3
    gnb2 disconnection

Only Stop Capture Wireshark Logs on gNB2
    gnb2 connection
    sleep    5
    csn.send command    command=killall tcpdump     connection=gnb2
    gnb2 disconnection

Modify the COAM parameter with admin API
    [Arguments]    ${parameters}    ${coam_addr}    ${coam_username}    ${coam_password}
    Connect to gnb coam via ssl    bts_host=${coam_addr}    username=${coam_username}    password=${coam_password}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters}
    COAM Teardown gnb connections

check value of parameter administrativeState on MO SNSSAI
    [Arguments]    ${value}=Unlocked
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${administrativeState_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/SNSSAI-1
    ${administrativeState_value}=    selenium_coam.get_parameter_value    dist_name=${administrativeState_distname}
    ...    filter_param=Administrative state    abbr=administrativeState
    Should Be Equal    ${administrativeState_value}    ${value}
    selenium_coam.logout
    selenium_coam.disable_virtual_display

set value of parameter administrativeState on MO SNSSAI
    [Arguments]    ${new_value}=Unlocked    ${despite_errors}=True
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${administrativeState_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/SNSSAI-1
    selenium_coam.set_parameter_value  dist_name=${administrativeState_distname}
    ...    filter_param=Administrative state
    ...    abbr=administrativeState    new_value=${new_value}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${despite_errors}
    sleep    8s
    selenium_coam.logout
    selenium_coam.disable_virtual_display

set and check value of parameter administrativeState on MO SNSSAI
    [Arguments]    ${value}=Unlocked    ${new_value}=Unlocked    ${despite_errors}=True
    set value of parameter administrativeState on MO SNSSAI    new_value=${new_value}    despite_errors=${despite_errors}
#    check value of parameter administrativeState on MO SNSSAI    value=${value}

set value of parameter administrativeState of gnb2 on MO SNSSAI
    [Arguments]    ${new_value}=Unlocked    ${despite_errors}=True
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI2_COAM}    username=${WEBUI2_NAME}    password=${WEBUI2_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${administrativeState_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/SNSSAI-1
    selenium_coam.set_parameter_value  dist_name=${administrativeState_distname}
    ...    filter_param=Administrative state
    ...    abbr=administrativeState    new_value=${new_value}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${despite_errors}
    sleep    8s
    selenium_coam.logout
    selenium_coam.disable_virtual_display

set and check value of parameter administrativeState of gnb2 on MO SNSSAI
    [Arguments]    ${value}=Unlocked    ${new_value}=Unlocked    ${despite_errors}=True
    set value of parameter administrativeState of gnb2 on MO SNSSAI    new_value=${new_value}    despite_errors=${despite_errors}
#    check value of parameter administrativeState of gnb2 on MO SNSSAI    value=${value}

Modify parameters online for cases
    [Arguments]    ${parameters_to_update}    ${download_dir}=${epc_log_path}    ${WEBUI_COAM}=${WEBUI_COAM}
    COAM modify several parameters via webUI   parameters_to_update_via_webui=${parameters_to_update}
    ...    download_dir=${download_dir}    WEBUI_COAM=${WEBUI_COAM}

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

Get the gNB Cell Id
    [Arguments]    ${WEBUI_COAM}=${WEBUI_COAM}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${info_cell1}    selenium_coam.get_cell_info    cell_idx=${1}
    set suite variable    ${cell1_id}    ${info_cell1['NR cell ID']}
    selenium_coam.logout
    selenium_coam.disable_virtual_display

#Get gnb release
#    [Arguments]   ${host}=${asik_addr}   ${username}=${asik_username}   ${password}=${asik_password}
#    csn.Connect To   hostname=${host}   username=${username}   password=${password}   alias=release_info
#    ${info}   csn.Execute    command=ls /ffs/run/TargetBD*xml   connection=release_info
#    ${release_info}     set variable    ${info.split('_')[3]}_${info.split('_')[4]}
#    [Return]    ${release_info}
#    [Teardown]   csn.Disconnect   connection=release_info

checking type of system board on gnb1
    gNB connections
    ${output}=    csn.execute    command=ifconfig |grep fp0    connection=${connection}
    ${status}=    Run Keyword And Return Status    Should Be Empty    ${output}
    Run Keyword If    '${status}' == 'True'    Setting variable br1 for interface name on gnb1
    Run Keyword If    '${status}' == 'False'    Setting variable fp0 for interface name on gnb1
    csn.disconnect      connection=${connection}

checking type of system board on gnb2
    gnb2 connection
    ${output}=    csn.execute    command=ifconfig |grep fp0    connection=gnb2
    ${status}=    Run Keyword And Return Status    Should Be Empty    ${output}
    Run Keyword If    '${status}' == 'True'    Setting variable br1 for interface name on gnb2
    Run Keyword If    '${status}' == 'False'    Setting variable fp0 for interface name on gnb2
    csn.disconnect      connection=gnb2

Setting variable br1 for interface name on gnb1
    Set Suite Variable    ${gnb1_interface_name}    br1
    Log    The system board of gnb1 is ASIB
    Log To Console    The system board of gnb1 is ASIB

Setting variable fp0 for interface name on gnb1
    Set Suite Variable    ${gnb1_interface_name}    fp0
    Log    The system board of gnb1 is ASIK
    Log To Console    The system board of gnb1 is ASIK

Setting variable br1 for interface name on gnb2
    Set Suite Variable    ${gnb2_interface_name}    br1
    Log    The system board of gnb2 is ASIB
    Log To Console    The system board of gnb2 is ASIB

Setting variable fp0 for interface name on gnb2
    Set Suite Variable    ${gnb2_interface_name}    fp0
    Log    The system board of gnb2 is ASIK
    Log To Console    The system board of gnb2 is ASIK

Teardown for disconnect all connections
    Run Keyword And Ignore Error    csn.Disconnect    connection=gnb
    Run Keyword And Ignore Error    csn.Disconnect    connection=cygwin
    Run Keyword And Ignore Error    csn.Disconnect    connection=EPCAPP
    Run Keyword And Ignore Error    csn.Disconnect    connection=enb
    Run Keyword And Ignore Error    enblte.teardown    connection=enblte
    Run Keyword And Ignore Error    selenium_coam.logout
    Run Keyword And Ignore Error    selenium_coam.disable_virtual_display

Save snapshot Teardown for COAM
    Connect to gnb coam via ssl
    COAM Download scf from cluster    scf_dir_path=${epc_log_path}
    COAM Save snapshot via rest api    log_path=${epc_log_path}
    COAM Teardown gnb connections

Check counter ${counter_id} as ${expected_value}
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id}    full_path=${ct_path['${counter_id}']}
#    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id}
    ${value}=    Get From Dictionary    ${counters}    ${countertime}
    should be true   ${value}>=${expected_value}
#    ${values}    get dictionary values   ${counters}
#    log  The latest one is: ${values[-1]}
#    should be true   ${values[-1]}>=${expected_value}

Check counter ${counter_id} equal ${expected_value}
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id}    full_path=${ct_path['${counter_id}']}
#    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id}
    ${value}=    Get From Dictionary    ${counters}    ${countertime}
    should be true   ${value}==${expected_value}
#    ${values}    get dictionary values   ${counters}
#    log  The latest one is: ${values[-1]}
#    should be true   ${values[-1]}==${expected_value}

###UE keywordWords###
Set UE to Offair
    [Arguments]    ${ue_index}=${0}
    ${mode_status}   Get UE Airmode status   ue_index=${ue_index}
    run keyword if  not '${mode_status}'=='1'   power_ue.UE Detach   ue_type=huawei    ue_index=${ue_index}
    ${mode_status2}   Get UE Airmode status   ue_index=${ue_index}
    run keyword if  not '${mode_status2}'=='1'   Reboot UE to Normal   ue_index=${ue_index}
    run keyword if  not '${mode_status2}'=='1'   Check UE device exist      ue_index=${ue_index}
    run keyword if  not '${mode_status2}'=='1'   power_ue.UE Detach   ue_type=huawei    ue_index=${ue_index}

Reboot UE to Normal
    [Arguments]  ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Restart adb server and wait until status ready    ue_index=${ue_index}   serial_number=${serial_number}
    ADB reboot ue    ue_index=${ue_index}   serial_number=${serial_number}
    Log to console    wait for adb startup
    BuiltIn.sleep    30s

Check phone attach successfully on SA env two times
    [Arguments]    ${gnb_index}=${0}    ${ue_index}=${0}
    ${UE_status}    run keyword and return status     Check phone attach successfully on SA env    gnb_index=${gnb_index}    ue_index=${ue_index}
    run keyword if     '${UE_status}'=='False'    Check phone attach successfully on SA env    gnb_index=${gnb_index}    ue_index=${ue_index}

Check phone attach successfully on SA env
    [Arguments]    ${5Gstatus}=PASS    ${abil}=asp1a    ${gnb_index}=${0}    ${ue_index}=${0}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=huawei    gnb_index=${gnb_index}    ue_index=${ue_index}

TL UE detach
    [Arguments]    ${ue_index}=${0}
    power_ue.UE Detach    ue_type=huawei    ue_index=${ue_index}

Make a VoNR call(+6688)
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    wait until keyword succeeds   5m   30s
    ...    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 82
    ...    connection=cygwin${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=cygwin${ue_index}
    sleep   2s
    #####make VoNR call#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:+6688
    ...    connection=cygwin${ue_index}
    sleep    30s
    csn.disconnect      connection=cygwin${ue_index}

hang up VoNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    wait until keyword succeeds   5m   30s
    ...    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 6    connection=cygwin${ue_index}
    sleep   5s
    csn.disconnect      connection=cygwin${ue_index}

Set automatic rotation on UEs
    Set automatic rotation    ue_index=${0}
    Set automatic rotation    ue_index=${1}

Set automatic rotation
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...    ${commond}=shell content insert --uri content://settings/system --bind name:s:accelerometer_rotation --bind value:i:
    ...    ${rotation_value}=0
    wait until keyword succeeds   5m   30s
    ...    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} ${commond}${rotation_value}
    ...    connection=cygwin${ue_index}
    sleep    5s
    csn.disconnect      connection=cygwin${ue_index}

Prepare env with UE
    [Arguments]    ${ue_index}=${0}
    power_ue.Prepare UE    ue_type=huawei    ue_index=${ue_index}

UE attach successfully
    [Arguments]    ${5Gstatus}=PASS    ${abil}=asp1a    ${ue_index}=${0}    ${gnb_index}=${0}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=huawei    ue_index=${ue_index}    gnb_index=${gnb_index}
    power_ue.Verify attach    ue_type=huawei    ue_index=${ue_index}    gnb_index=${gnb_index}
    ...    5Grach_ed=${5Grach_ed}    4G_check=False

Make a voice call on UE
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Make a call on UE(dial +6688 on UE)    ue_index=${ue_index}    serial_number=${serial_number}
    End a call on UE    ue_index=${ue_index}    serial_number=${serial_number}

Make a call on UE(dial +6688 on UE)
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    wait until keyword succeeds   5m   30s
    ...    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 82
    ...    connection=cygwin${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=cygwin${ue_index}
    sleep   2s
    #####make a call on UE with +6688#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:+6688
    ...    connection=cygwin${ue_index}
    sleep   15s

End a call on UE
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    #####hang up with +6688#####
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 6    connection=cygwin${ue_index}
    sleep   2s
    csn.disconnect      connection=cygwin${ue_index}

Prepare env with UEs
    power_ue.Prepare UE    ue_type=huawei
    power_ue.Prepare UE    ue_type=huawei    ue_index=${1}

Check UE exist
    Check UE device exist
    Check UE device exist    ue_index=${1}

Start UL data transfer
    [Arguments]    ${ul_throughput}    ${ue_index}=${0}    ${iperf_port}=default
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul   throughput=${ul_throughput}
    ...    duration=${duration}    ue_index=${ue_index}    iperf_port=${iperf_port}

Start DL date transfer
    [Arguments]    ${dl_throughput}    ${ue_index}=${0}    ${iperf_port}=default
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl   throughput=${dl_throughput}
    ...    duration=${duration}    ue_index=${ue_index}    iperf_port=${iperf_port}

Check the UL throughput
    [Arguments]    ${ul_expected_throughput}    ${cell_id}=${cell1_id}
    power_ue.Check throughput    ue_type=${ue_type}    direction=ul    throughput=${ul_expected_throughput}
    ...    deviation=${deviation}    cellid=${cell_id}    gnb_index=${1}

Check the DL throughput
    [Arguments]    ${dl_expected_throughput}        ${cell_id}=${cell1_id}
    power_ue.Check throughput    ue_type=${ue_type}    direction=dl    throughput=${dl_expected_throughput}
    ...    deviation=${deviation}    cellid=${cell_id}    gnb_index=${1}

Start DL and UL data transfer
    [Arguments]    ${dl_throughput}    ${ul_throughput}    ${ue_index}=${0}
    log to console    \n *** Start DL & UL transmission
    Start DL date transfer    dl_throughput=${dl_throughput}    ue_index=${ue_index}
    Start UL data transfer    ul_throughput=${ul_throughput}    ue_index=${ue_index}

Check the DL and UL throughput
    [Arguments]    ${dl_expected_throughput}    ${ul_expected_throughput}
    Check the DL throughput    dl_expected_throughput=${dl_expected_throughput}
    Check the UL throughput    ul_expected_throughput=${ul_expected_throughput}

check voiceOverNR support
    [Arguments]    ${logname}
    ${all_packets}=    parser.Load Pcap File    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}

    ${UERadioCapabilityInfoIndication} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 44
    Log To Console    check voiceOverNR value on UERadioCapabilityInfoIndication message
    ${UERadioCapabilityInfoIndication_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${UERadioCapabilityInfoIndication}
    should be equal    ${UERadioCapabilityInfoIndication_status}    ${True}
    ${filtered_packets}=    parser.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${UERadioCapabilityInfoIndication}
    ${nr_rrc_voiceOverNR}=    parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//nr-rrc.voiceOverNR
    Should Be Equal    ${nr_rrc_voiceOverNR[0]}    0

Make a VoNR and ViNR call together
    [Arguments]    ${phone_number}=18001006306
    Get VoNR and ViNR pointer variable
    Make a VoNR and ViNR call    phone_number=${phone_number}
    answer ViNR call    ue_index=${1}

Make a VoNR and ViNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=18001006149
    wait until keyword succeeds   5m   30s
    ...    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error
    ...    csn.send_command    command=adb -s ${serial_number} shell input keyevent 82    connection=cygwin${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=cygwin${ue_index}
    sleep   2s
    #####make VoNR and ViNR call together#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.DIAL tel:+86${phone_number}
    ...    connection=cygwin${ue_index}
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${Enter_Make_ViNR_button_T}    connection=cygwin${ue_index}
    sleep    5s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${Make_ViNR_button_T}    connection=cygwin${ue_index}
    sleep    5s

Make a VoNR call separately
    [Arguments]    ${phone_number}=18001006306
    Get VoNR and ViNR pointer variable
    Make a VoNR call    phone_number=${phone_number}
    answer VoNR call    ue_index=${1}

Make a ViNR call separately
    Make a ViNR call
    answer ViNR call    ue_index=${1}

Make a VoNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=18001006149
    wait until keyword succeeds   5m   30s
    ...    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 82
    ...    connection=cygwin${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=cygwin${ue_index}
    sleep   2s
    #####make VoNR call#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:+86${phone_number}
    ...    connection=cygwin${ue_index}
    sleep    20s

answer VoNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    wait until keyword succeeds   5m   30s
    ...    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 5    connection=cygwin${ue_index}
    sleep    5s

Make a ViNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    wait until keyword succeeds   5m   30s
    ...    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${Make_ViNR_button_S}    connection=cygwin${ue_index}
    sleep    5s

answer ViNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    wait until keyword succeeds   5m   30s
    ...    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${answer_ViNR_button}    connection=cygwin${ue_index}
    sleep    5s

switch ViNR to VoNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    wait until keyword succeeds   5m   30s
    ...    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${trigger_button}    connection=cygwin${ue_index}
    sleep    1s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${switch_to_VoNR}    connection=cygwin${ue_index}

hang up VoNR and ViNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    wait until keyword succeeds   5m   30s
    ...    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 6    connection=cygwin${ue_index}
    sleep    5s

Get VoNR and ViNR pointer variable
    run keyword if    '${brand}'=='HUAWEI'
    ...    Get VoNR and ViNR pointer variable with mate30 pro

Get VoNR and ViNR pointer variable with mate30 pro
    Set Suite Variable    ${Enter_Make_ViNR_button_T}    1040 552
    Set Suite Variable    ${Make_ViNR_button_T}    875 1219
    Set Suite Variable    ${answer_ViNR_button}    836 2149
    Set Suite Variable    ${switch_to_VoNR}    914 1746
    Set Suite Variable    ${trigger_button}    735 1805
    Set Suite Variable    ${hang_up_VoNR_and_ViNR}    588 1982
    Set Suite Variable    ${Make_ViNR_button_S}    254 1728

check points with VoNR and ViNR call together
    [Arguments]    ${logname}
    ${all_packets}=    parser.Load Pcap File    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}

    ${PDUSessionResourceModifyRequest} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 26
    Log To Console    check fiveQI value on PDUSessionResourceModifyRequest message
    ${PDUSessionResourceModifyRequest_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${PDUSessionResourceModifyRequest}
    should be equal    ${PDUSessionResourceModifyRequest_status}    ${True}
    ${filtered_packets}=    parser.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${PDUSessionResourceModifyRequest}
    ${ngap_fiveQI}=    parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//ngap.fiveQI
    Should Contain    ${ngap_fiveQI}    1
    Should Contain    ${ngap_fiveQI}    2

    ${BearerContextModificationRequest} =    Catenate    e1ap.E1AP_PDU == 0 and e1ap.procedureCode == 9
    Log To Console    check BearerContextModificationRequest message
    ${BearerContextModificationRequest_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${BearerContextModificationRequest}
    should be equal    ${BearerContextModificationRequest_status}    ${True}

    ${BearerContextModificationResponse} =    Catenate    e1ap.E1AP_PDU == 1 and e1ap.procedureCode == 9
    Log To Console    check BearerContextModificationResponse message
    ${BearerContextModificationResponse_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${BearerContextModificationResponse}
    should be equal    ${BearerContextModificationResponse_status}    ${True}

    ${UEContextModificationRequest} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 7
    Log To Console    check value on UEContextModificationRequest message
    ${UEContextModificationRequest_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${UEContextModificationRequest}
    should be equal    ${UEContextModificationRequest_status}    ${True}
    ${filtered_packets}=    parser.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${UEContextModificationRequest}
    ${f1ap_fiveQI}=    parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.fiveQI
    Should Contain    ${f1ap_fiveQI}    1
    Should Contain    ${f1ap_fiveQI}    2
    ${f1ap_PDCPSNLength}=    parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.PDCPSNLength
    Should Contain    ${f1ap_PDCPSNLength}    0
    ${f1ap_DRXConfigurationIndicator}=    parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.DRXConfigurationIndicator
    Should Contain    ${f1ap_DRXConfigurationIndicator}    0

    ${UEContextModificationResponse} =    Catenate    f1ap.F1AP_PDU == 1 and f1ap.procedureCode == 7
    Log To Console    check value on UEContextModificationResponse message
    ${UEContextModificationResponse_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${UEContextModificationResponse}
    should be equal    ${UEContextModificationResponse_status}    ${True}
    ${filtered_packets}=    parser.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${UEContextModificationResponse}
    ${f1ap_id}=    parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.id
    Should Contain    ${f1ap_id}    39

    ${DLRRCMessageTransfer} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 12
    Log To Console    check DLRRCMessageTransfer message
    ${DLRRCMessageTransfer_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${DLRRCMessageTransfer}
    should be equal    ${DLRRCMessageTransfer_status}    ${True}

    ${ULRRCMessageTransfer} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 13
    Log To Console    check ULRRCMessageTransfer message
    ${ULRRCMessageTransfer_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${ULRRCMessageTransfer}
    should be equal    ${ULRRCMessageTransfer_status}    ${True}

    ${PDUSessionResourceModifyResponse} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 26
    Log To Console    check PDUSessionResourceModifyResponse
    ${PDUSessionResourceModifyResponse_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${PDUSessionResourceModifyResponse}
    should be equal    ${PDUSessionResourceModifyResponse_status}    ${True}
    ${filtered_packets}=    parser.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${PDUSessionResourceModifyResponse}
    ${ngap_qosFlowAddOrModifyResponseList} =    parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//ngap.qosFlowAddOrModifyResponseList
    Should be equal    ${ngap_qosFlowAddOrModifyResponseList[0]}    2
    Should be equal    ${ngap_qosFlowAddOrModifyResponseList[1]}    2

check points with VoNR and ViNR call release together
    [Arguments]    ${logname}
    ${all_packets}=    parser.Load Pcap File    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}

    ${PDUSessionResourceModifyRequest} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 26
    Log To Console    check release value on PDUSessionResourceModifyRequest message
    ${PDUSessionResourceModifyRequest_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${PDUSessionResourceModifyRequest}
    should be equal    ${PDUSessionResourceModifyRequest_status}    ${True}
    ${filtered_packets}=    parser.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${PDUSessionResourceModifyRequest}
    ${ngap_nas}=    parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//ngap.nas
    Should Contain    ${ngap_nas}    0

    ${BearerContextModificationRequest} =    Catenate    e1ap.E1AP_PDU == 0 and e1ap.procedureCode == 9
    Log To Console    check release BearerContextModificationRequest message
    ${BearerContextModificationRequest_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${BearerContextModificationRequest}
    should be equal    ${BearerContextModificationRequest_status}    ${True}
    ${filtered_packets}=    parser.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${BearerContextModificationRequest}
    ${e1ap_dRB_To_Remove_List_NG_RAN}=    parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//e1ap.dRB_To_Remove_List_NG_RAN
    Should Contain    ${e1ap_dRB_To_Remove_List_NG_RAN}    2
    ${e1ap_dRB_ID}=    parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//e1ap.dRB_ID
    Should Contain    ${e1ap_dRB_ID}    6
    Should Contain    ${e1ap_dRB_ID}    7

    ${BearerContextModificationResponse} =    Catenate    e1ap.E1AP_PDU == 1 and e1ap.procedureCode == 9
    Log To Console    check release BearerContextModificationResponse message
    ${BearerContextModificationResponse_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${BearerContextModificationResponse}
    should be equal    ${BearerContextModificationResponse_status}    ${True}

    ${UEContextModificationRequest} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 7
    Log To Console    check value on release UEContextModificationRequest message
    ${UEContextModificationRequest_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${UEContextModificationRequest}
    should be equal    ${UEContextModificationRequest_status}    ${True}
    ${filtered_packets}=    parser.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${UEContextModificationRequest}
    ${f1ap_DRBs_ToBeReleased_List}=    parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.DRBs_ToBeReleased_List
    Should Contain    ${f1ap_DRBs_ToBeReleased_List}    2

    ${UEContextModificationResponse} =    Catenate    f1ap.F1AP_PDU == 1 and f1ap.procedureCode == 7
    Log To Console    check value on release UEContextModificationResponse message
    ${UEContextModificationResponse_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${UEContextModificationResponse}
    should be equal    ${UEContextModificationResponse_status}    ${True}
    ${filtered_packets}=    parser.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${UEContextModificationResponse}
    ${nr_rrc_drx_Config}=    parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//nr-rrc.drx_Config
#    Should Contain    ${nr_rrc_drx_Config}    1

    ${DLRRCMessageTransfer} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 12
    Log To Console    check release DLRRCMessageTransfer message
    ${DLRRCMessageTransfer_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${DLRRCMessageTransfer}
    should be equal    ${DLRRCMessageTransfer_status}    ${True}

    ${ULRRCMessageTransfer} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 13
    Log To Console    check release ULRRCMessageTransfer message
    ${ULRRCMessageTransfer_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${ULRRCMessageTransfer}
    should be equal    ${ULRRCMessageTransfer_status}    ${True}

    ${PDUSessionResourceModifyResponse} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 26
    Log To Console    check release value on PDUSessionResourceModifyResponse
    ${PDUSessionResourceModifyResponse_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${PDUSessionResourceModifyResponse}
    should be equal    ${PDUSessionResourceModifyResponse_status}    ${True}
    ${filtered_packets}=    parser.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${PDUSessionResourceModifyResponse}
    ${ngap_pDUSessionResourceModifyResponseTransfer} =    parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//ngap.pDUSessionResourceModifyResponseTransfer
    Should Contain    ${ngap_pDUSessionResourceModifyResponseTransfer}    00

check points with ViNR call release
    [Arguments]    ${logname}
    ${all_packets}=    parser.Load Pcap File    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}

    ${PDUSessionResourceModifyRequest} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 26
    Log To Console    check release value on PDUSessionResourceModifyRequest message
    ${PDUSessionResourceModifyRequest_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${PDUSessionResourceModifyRequest}
    should be equal    ${PDUSessionResourceModifyRequest_status}    ${True}
    ${filtered_packets}=    parser.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${PDUSessionResourceModifyRequest}
    ${ngap_nas}=    parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//ngap.nas
    Should Contain    ${ngap_nas}    0

    ${BearerContextModificationRequest} =    Catenate    e1ap.E1AP_PDU == 0 and e1ap.procedureCode == 9
    Log To Console    check release BearerContextModificationRequest message
    ${BearerContextModificationRequest_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${BearerContextModificationRequest}
    should be equal    ${BearerContextModificationRequest_status}    ${True}
    ${filtered_packets}=    parser.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${BearerContextModificationRequest}
    ${e1ap_dRB_To_Remove_List_NG_RAN}=    parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//e1ap.dRB_To_Remove_List_NG_RAN
    Should Contain    ${e1ap_dRB_To_Remove_List_NG_RAN}    1
    ${e1ap_dRB_ID}=    parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//e1ap.dRB_ID
#    Should Not Contain    ${e1ap_dRB_ID}    6
#    Should Contain    ${e1ap_dRB_ID}    7

    ${BearerContextModificationResponse} =    Catenate    e1ap.E1AP_PDU == 1 and e1ap.procedureCode == 9
    Log To Console    check release BearerContextModificationResponse message
    ${BearerContextModificationResponse_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${BearerContextModificationResponse}
    should be equal    ${BearerContextModificationResponse_status}    ${True}

    ${UEContextModificationRequest} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 7
    Log To Console    check value on release UEContextModificationRequest message
    ${UEContextModificationRequest_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${UEContextModificationRequest}
    should be equal    ${UEContextModificationRequest_status}    ${True}
    ${filtered_packets}=    parser.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${UEContextModificationRequest}
    ${f1ap_DRBs_ToBeReleased_List}=    parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.DRBs_ToBeReleased_List
    Should Contain    ${f1ap_DRBs_ToBeReleased_List}    1

    ${UEContextModificationResponse} =    Catenate    f1ap.F1AP_PDU == 1 and f1ap.procedureCode == 7
    Log To Console    check value on release UEContextModificationResponse message
    ${UEContextModificationResponse_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${UEContextModificationResponse}
    should be equal    ${UEContextModificationResponse_status}    ${True}

    ${DLRRCMessageTransfer} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 12
    Log To Console    check release DLRRCMessageTransfer message
    ${DLRRCMessageTransfer_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${DLRRCMessageTransfer}
    should be equal    ${DLRRCMessageTransfer_status}    ${True}

    ${ULRRCMessageTransfer} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 13
    Log To Console    check release ULRRCMessageTransfer message
    ${ULRRCMessageTransfer_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${ULRRCMessageTransfer}
    should be equal    ${ULRRCMessageTransfer_status}    ${True}

    ${PDUSessionResourceModifyResponse} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 26
    Log To Console    check release value on PDUSessionResourceModifyResponse
    ${PDUSessionResourceModifyResponse_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${PDUSessionResourceModifyResponse}
    should be equal    ${PDUSessionResourceModifyResponse_status}    ${True}
    ${filtered_packets}=    parser.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${PDUSessionResourceModifyResponse}
    ${ngap_pDUSessionResourceModifyResponseTransfer} =    parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//ngap.pDUSessionResourceModifyResponseTransfer
    Should Contain    ${ngap_pDUSessionResourceModifyResponseTransfer}    00

check points with VoNR call separately
    [Arguments]    ${logname}
    ${all_packets}=    parser.Load Pcap File    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}

    ${PDUSessionResourceModifyRequest} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 26
    Log To Console    check fiveQI value on PDUSessionResourceModifyRequest message
    ${PDUSessionResourceModifyRequest_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${PDUSessionResourceModifyRequest}
    should be equal    ${PDUSessionResourceModifyRequest_status}    ${True}
    ${filtered_packets}=    parser.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${PDUSessionResourceModifyRequest}
    ${ngap_fiveQI}=    parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//ngap.fiveQI
    Should Contain    ${ngap_fiveQI}    1
    Should Not Contain    ${ngap_fiveQI}    2

    ${BearerContextModificationRequest} =    Catenate    e1ap.E1AP_PDU == 0 and e1ap.procedureCode == 9
    Log To Console    check BearerContextModificationRequest message
    ${BearerContextModificationRequest_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${BearerContextModificationRequest}
    should be equal    ${BearerContextModificationRequest_status}    ${True}

    ${BearerContextModificationResponse} =    Catenate    e1ap.E1AP_PDU == 1 and e1ap.procedureCode == 9
    Log To Console    check BearerContextModificationResponse message
    ${BearerContextModificationResponse_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${BearerContextModificationResponse}
    should be equal    ${BearerContextModificationResponse_status}    ${True}

    ${UEContextModificationRequest} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 7
    Log To Console    check value on UEContextModificationRequest message
    ${UEContextModificationRequest_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${UEContextModificationRequest}
    should be equal    ${UEContextModificationRequest_status}    ${True}
    ${filtered_packets}=    parser.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${UEContextModificationRequest}
    ${f1ap_fiveQI}=    parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.fiveQI
    Should Contain    ${f1ap_fiveQI}    1
    Should Not Contain    ${f1ap_fiveQI}    2
    ${f1ap_PDCPSNLength}=    parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.PDCPSNLength
    Should Contain    ${f1ap_PDCPSNLength}    0
    ${f1ap_DRXConfigurationIndicator}=    parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.DRXConfigurationIndicator
#    Should Contain    ${f1ap_DRXConfigurationIndicator}    0

    ${UEContextModificationResponse} =    Catenate    f1ap.F1AP_PDU == 1 and f1ap.procedureCode == 7
    Log To Console    check value on UEContextModificationResponse message
    ${UEContextModificationResponse_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${UEContextModificationResponse}
    should be equal    ${UEContextModificationResponse_status}    ${True}
    ${filtered_packets}=    parser.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${UEContextModificationResponse}
    ${f1ap_id}=    parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.id
    Should Contain    ${f1ap_id}    39

    ${DLRRCMessageTransfer} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 12
    Log To Console    check DLRRCMessageTransfer message
    ${DLRRCMessageTransfer_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${DLRRCMessageTransfer}
    should be equal    ${DLRRCMessageTransfer_status}    ${True}

    ${ULRRCMessageTransfer} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 13
    Log To Console    check ULRRCMessageTransfer message
    ${ULRRCMessageTransfer_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${ULRRCMessageTransfer}
    should be equal    ${ULRRCMessageTransfer_status}    ${True}

    ${PDUSessionResourceModifyResponse} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 26
    Log To Console    check PDUSessionResourceModifyResponse
    ${PDUSessionResourceModifyResponse_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${PDUSessionResourceModifyResponse}
    should be equal    ${PDUSessionResourceModifyResponse_status}    ${True}
    ${filtered_packets}=    parser.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${PDUSessionResourceModifyResponse}
    ${ngap_qosFlowAddOrModifyResponseList} =    parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//ngap.qosFlowAddOrModifyResponseList
    Should be equal    ${ngap_qosFlowAddOrModifyResponseList[0]}    1
    Should be equal    ${ngap_qosFlowAddOrModifyResponseList[1]}    1

check points with ViNR call separately
    [Arguments]    ${logname}
    ${all_packets}=    parser.Load Pcap File    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}

    ${PDUSessionResourceModifyRequest} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 26
    Log To Console    check fiveQI value on PDUSessionResourceModifyRequest message
    ${PDUSessionResourceModifyRequest_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${PDUSessionResourceModifyRequest}
    should be equal    ${PDUSessionResourceModifyRequest_status}    ${True}
    ${filtered_packets}=    parser.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${PDUSessionResourceModifyRequest}
    ${ngap_fiveQI}=    parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//ngap.fiveQI
    Should Contain    ${ngap_fiveQI}    2
    Should Not Contain    ${ngap_fiveQI}    1

    ${BearerContextModificationRequest} =    Catenate    e1ap.E1AP_PDU == 0 and e1ap.procedureCode == 9
    Log To Console    check BearerContextModificationRequest message
    ${BearerContextModificationRequest_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${BearerContextModificationRequest}
    should be equal    ${BearerContextModificationRequest_status}    ${True}

    ${BearerContextModificationResponse} =    Catenate    e1ap.E1AP_PDU == 1 and e1ap.procedureCode == 9
    Log To Console    check BearerContextModificationResponse message
    ${BearerContextModificationResponse_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${BearerContextModificationResponse}
    should be equal    ${BearerContextModificationResponse_status}    ${True}

    ${UEContextModificationRequest} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 7
    Log To Console    check value on UEContextModificationRequest message
    ${UEContextModificationRequest_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${UEContextModificationRequest}
    should be equal    ${UEContextModificationRequest_status}    ${True}
    ${filtered_packets}=    parser.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${UEContextModificationRequest}
    ${f1ap_fiveQI}=    parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.fiveQI
    Should Contain    ${f1ap_fiveQI}    2
    Should Not Contain    ${f1ap_fiveQI}    1
    ${f1ap_PDCPSNLength}=    parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.PDCPSNLength
    Should Contain    ${f1ap_PDCPSNLength}    0

    ${UEContextModificationResponse} =    Catenate    f1ap.F1AP_PDU == 1 and f1ap.procedureCode == 7
    Log To Console    check value on UEContextModificationResponse message
    ${UEContextModificationResponse_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${UEContextModificationResponse}
    should be equal    ${UEContextModificationResponse_status}    ${True}
    ${filtered_packets}=    parser.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${UEContextModificationResponse}
    ${f1ap_id}=    parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.id
    Should Contain    ${f1ap_id}    39

    ${DLRRCMessageTransfer} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 12
    Log To Console    check DLRRCMessageTransfer message
    ${DLRRCMessageTransfer_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${DLRRCMessageTransfer}
    should be equal    ${DLRRCMessageTransfer_status}    ${True}

    ${ULRRCMessageTransfer} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 13
    Log To Console    check ULRRCMessageTransfer message
    ${ULRRCMessageTransfer_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${ULRRCMessageTransfer}
    should be equal    ${ULRRCMessageTransfer_status}    ${True}

    ${PDUSessionResourceModifyResponse} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 26
    Log To Console    check PDUSessionResourceModifyResponse
    ${PDUSessionResourceModifyResponse_status} =    run_keyword_and_return_status
    ...    parser.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${PDUSessionResourceModifyResponse}
    should be equal    ${PDUSessionResourceModifyResponse_status}    ${True}
    ${filtered_packets}=    parser.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${PDUSessionResourceModifyResponse}
    ${ngap_qosFlowAddOrModifyResponseList} =    parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//ngap.qosFlowAddOrModifyResponseList
    Should be equal    ${ngap_qosFlowAddOrModifyResponseList[0]}    1
    Should be equal    ${ngap_qosFlowAddOrModifyResponseList[1]}    1

UEs attach
    [Arguments]    ${5Gstatus}=PASS    ${abil}=asp1a    ${gnb_index}=${0}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=huawei    gnb_index=${gnb_index}
    power_ue.Verify attach    ue_type=huawei    gnb_index=${gnb_index}    5Grach_ed=${5Grach_ed}    4G_check=False
    ${5Grach_ed}    power_ue.UE Attach    ue_type=huawei    ue_index=${1}    gnb_index=${gnb_index}
    power_ue.Verify attach    ue_type=huawei    ue_index=${1}    gnb_index=${gnb_index}    5Grach_ed=${5Grach_ed}    4G_check=False

UEs detach
    power_ue.UE Detach    ue_type=huawei
    power_ue.UE Detach    ue_type=huawei    ue_index=${1}

###check the 6112 wireshark log###
Check IE wireshark log for attach
    [Arguments]    ${logname}    ${message_filter1}    ${message_filter2}    ${message_filter3}
             ...    ${value1}    ${value2}    ${value3}
    Check IE wireshark log for drx_onDurationTimer     logname=${logname}    message_filter=${message_filter1}     value=${value1}
    Check IE wireshark log for drx_InactivityTimer     logname=${logname}    message_filter=${message_filter2}    value=${value2}
    Check IE wireshark log for longDRXCycleLength     logname=${logname}    message_filter=${message_filter3}    value=${value3}

Check IE wireshark log for VONR CDRX config
    [Arguments]    ${logname}    ${message_filter1}    ${message_filter2}    ${message_filter3}
             ...    ${value1}    ${value2}    ${value3}
    Check IE wireshark log for drx_onDurationTimer     logname=${logname}    message_filter=${message_filter1}     value=${value1}
    Check IE wireshark log for drx_InactivityTimer     logname=${logname}    message_filter=${message_filter2}    value=${value2}
    Check IE wireshark log for longDRXCycleLength     logname=${logname}    message_filter=${message_filter3}    value=${value3}

Check IE wireshark log for VONR_Release CDRX config
    [Arguments]    ${logname}    ${message_filter1}    ${message_filter2}    ${message_filter3}
             ...    ${value1}    ${value2}    ${value3}
    Check IE wireshark log for drx_onDurationTimer     logname=${logname}    message_filter=${message_filter1}     value=${value1}
    Check IE wireshark log for drx_InactivityTimer     logname=${logname}    message_filter=${message_filter2}    value=${value2}
    Check IE wireshark log for longDRXCycleLength     logname=${logname}    message_filter=${message_filter3}    value=${value3}

Check IE wireshark log for drx_onDurationTimer
    [Arguments]    ${logname}    ${message_filter}    ${value}
    ${all_packets}=    parser.Load Pcap File    pcap_file=${epc_log_path}${logname}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    parser.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${filter_expression}
    ${drx_onDurationTimer}=     parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//nr-rrc.milliSeconds
    should be equal    ${drx_onDurationTimer[0]}    ${value}

Check IE wireshark log for drx_InactivityTimer
    [Arguments]    ${logname}    ${message_filter}    ${value}
    ${all_packets}=    parser.Load Pcap File    pcap_file=${epc_log_path}${logname}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    parser.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${filter_expression}
    ${drx_InactivityTimer}=     parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//nr-rrc.drx_InactivityTimer
    should be equal    ${drx_InactivityTimer[0]}    ${value}

Check IE wireshark log for longDRXCycleLength
    [Arguments]    ${logname}    ${message_filter}    ${value}
    ${all_packets}=    parser.Load Pcap File    pcap_file=${epc_log_path}${logname}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    parser.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${filter_expression}
    ${longDRXCycleLength}=     parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//f1ap.longDRXCycleLength
    should be equal    ${drx_LongCycleStartOffset[0]}    ${value}

locked LTE cell
    run keyword if    '${enb_instance}'=='911'      locked LTE cell on TL343
    run keyword if    '${enb_instance}'=='5302'     locked LTE cell on TL42
    run keyword if    '${enb_instance}'=='910'     locked LTE cell on TL830

locked LTE cell on TL343
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-0
    ...    parameter=administrativeState
    ...    value=locked
    sleep    10s

locked LTE cell on TL42
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-1
    ...    parameter=administrativeState
    ...    value=locked
    sleep    10s

locked LTE cell on TL830
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-1
    ...    parameter=administrativeState
    ...    value=locked
    sleep    10s

unlocked LTE cell
    run keyword if    '${enb_instance}'=='911'    unlocked LTE cell on TL343
    run keyword if    '${enb_instance}'=='5302'    unlocked LTE cell on TL42
    run keyword if    '${enb_instance}'=='910'    unlocked LTE cell on TL830

unlocked LTE cell on TL343
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-0
    ...    parameter=administrativeState
    ...    value=unlocked
    sleep    10s

unlocked LTE cell on TL42
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-1
    ...    parameter=administrativeState
    ...    value=unlocked
    sleep    10s

unlocked LTE cell on TL830
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-1
    ...    parameter=administrativeState
    ...    value=unlocked
    sleep    10s

Kill firefox process
    ssh.Connect to    ${tl.test_pc.default_ssh_connection_details.addr}
    ...               ${tl.test_pc.default_ssh_connection_details.username}
    ...               ${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=ute
    csn.send_command    command=ps -ef | grep firefox | awk '{print $2}' | xargs kill -9    connection=ute
    sleep   2s
    csn.disconnect      connection=ute

enb connection
    csn.Connect To    hostname=${enb_address}    username=${enb_username}    password=${enb_password}    alias=enb

Enb start capture wireshark log
    [Arguments]    ${filename}     ${interface}=br1    ${connection}=enb
    RUN KEYWORD AND IGNORE ERROR    enb connection
    csn.send command    command=tcpdump -i ${interface} sctp -w ${enb_path}${filename}   connection=${connection}
    sleep    3s

Enb stop and Save classical Logs
    [Arguments]    ${filename}    ${connection}=enb
    enb connection
    csn.send command    command=killall tcpdump     connection=${connection}
    sleep    3
    csn.download_file   remote_path=${enb_path}${filename}   local_path=${epc_log_path}${filename}   connection=${connection}
    sleep    3
    csn.disconnect      connection=${connection}

Capture TTITrace and download to test pc ASIB
    [Arguments]    ${gnb_index}=${0}    ${hw_slot}=${1}
    Start TTI trace log capturing ASIB    gnb_index=${gnb_index}    hw_slot=${hw_slot}
    sleep    2s
    Stop TTI trace log capturing
    sleep     10s
    &{dict_csv_file_path}    Convert TTI trace log and download combined csv logs to test pc    local_path=${epc_log_path}
    Set suite variable    ${ttitrace_localpath}    ${dict_csv_file_path['DL']}

Start TTI trace log capturing ASIB
    [Arguments]    ${gnb_index}=${0}    ${hw_slot}=${1}    ${connection_for_abil}=${None}    ${du_index}=${0}
    Run keyword if    '${connection_for_abil}'=='${None}'
    ...    Create default connection ASIB    gnb_index=${gnb_index}    hw_slot=${hw_slot}    du_index=${du_index}
    ${connection_for_abil}    Set variable if    '${connection_for_abil}'=='${None}'    ${ABIL_ALIAS}    ${connection_for_abil}
    tti.prepare_for_tti_trace_log_capturing    connection=${connection_for_abil}
    tti.start_tti_trace    connection=${connection_for_abil}

Create default connection ASIB
    [Arguments]    ${gnb_index}=${0}    ${hw_slot}=${1}    ${du_index}=${0}
    ${is_feature_1514_enabled}    stream_manager.Feature 1514 Enabled
    ${ABIL_ALIAS}    Set variable if     ${is_feature_1514_enabled}    ${ABIL_SLAVE_ALIAS}    ${ABIL_MASTER_ALIAS}
    Set suite variable    ${ABIL_ALIAS}
    Run keyword if    ${is_feature_1514_enabled}
    ...    Connect to Capacity Unit Slave with hostname    gnb_index=${gnb_index}    hw_slot=${hw_slot}
    ...                                                      alias=${ABIL_ALIAS}    du_index=${du_index}
    ...    ELSE    Connect to Capacity Unit Master with hostname    gnb_index=${gnb_index}
    ...    alias=${ABIL_ALIAS}    hw_slot=${hw_slot}    du_index=${du_index}

Check IE wireshark log for VONR Release
    [Arguments]    ${logname}    ${message_filter}
    ${all_packets}=    parser.Load Pcap File    pcap_file=${epc_log_path}${logname}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    parser.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${filter_expression}
    ${ngap_nas}=     parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//ngap.nas
    should be equal    ${ngap_nas[0]}    0

Check IE wireshark log for VONR setup
    [Arguments]    ${logname}    ${message_filter}
    parser.Load Pcap File    pcap_file=${epc_log_path}${logname}   alias=VONR
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    parser.Filter Packets By Expression    pcap_parser=VONR   filter_expression=${filter_expression}
    ${ngap_fiveQI}=     parser.Get Field Value By Xpath    pcap_parser=VONR
    ...                                                xpath=.//ngap.fiveQI
    should be equal    ${ngap_fiveQI[0]}    1

Check IE wireshark log for RLF
    [Arguments]    ${logname}    ${message_filter}
    ${all_packets}=    parser.Load Pcap File    pcap_file=${epc_log_path}${logname}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    parser.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${filter_expression}
    ${f1ap_cause}=     parser.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//f1ap.radioNetwork
    should be equal    ${f1ap_cause[0]}    12

Check IE wireshark log for VONR attach
    [Arguments]    ${logname}    ${message_filter}    ${message_filter1}    ${value}   ${value1}
    Run Keyword And Ignore Error    Check IE wireshark log for VONR attach_5QI5    logname=${logname}
    ...    message_filter=${message_filter}     value=${value}
    Run Keyword And Ignore Error    Check IE wireshark log for VONR attach_5QI7    logname=${logname}
    ...    message_filter=${message_filter1}    value=${value1}

Check IE wireshark log for VONR attach_5QI5
    [Arguments]     ${logname}    ${message_filter}    ${value}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
    ${ngap_fiveQI}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//ngap.fiveQI
    should be equal    ${ngap_fiveQI[0]}    ${value}

Check IE wireshark log for VONR attach_5QI7
    [Arguments]     ${logname}    ${message_filter}    ${value}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
    ${ngap_fiveQI}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//ngap.fiveQI
    should be equal    ${ngap_fiveQI[0]}    ${value}

Enable RD flag of rdUeContextRequest
    [Arguments]    ${ip_addr}=${asik_addr}    ${gnb}=${ALIAS_ASIK}
    wait until keyword succeeds    1min   10s    gNB2 connections    ip_addr=${ip_addr}    gnb=${gnb}
    Modify RD flag of rdUeContextRequest    before_value=rdUeContextRequest=False    after_value=rdUeContextRequest=True
    ...    file=cp_ue.enb_conf.ini    ALIAS_ASIK=${gnb}

Disable RD flag of rdUeContextRequest
    [Arguments]    ${ip_addr}=${asik_addr}    ${gnb}=${ALIAS_ASIK}
    wait until keyword succeeds    1min   10s    gNB2 connections    ip_addr=${ip_addr}    gnb=${gnb}
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

gNB2 connections
    [Arguments]    ${ip_addr}=${asik2_addr}    ${gnb}=ASIK
    csn.connect To    hostname=${ip_addr}
    ...               username=${asik2_username}
    ...               password=${asik2_password}
    ...               alias=${gnb}

Check timer differ
    [Arguments]    ${logname}    ${message_filter}    ${message_filter1}    ${index00}    ${index01}    ${value}
    ${time1} =    Get message time    logname=${logname}    message_filter=${message_filter}    index=${index00}
    ${time2} =    Get message time    logname=${logname}    message_filter=${message_filter1}    index=${index01}
    ${time_dif1} =    evaluate  float(${time2})-float(${time1})
    ${time_differ1} =    convert_to_number    ${time_dif1}	0
    should be true    ${time_differ1}>=${value}
    [Return]    ${time_differ1}

Get message time
    [Arguments]    ${logname}    ${message_filter}    ${index}=${index0}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
    @{frame_time}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//frame.time_epoch
    #    ${timelist} =   Evaluate    ${frame_time}[${index}].split('|')
    ${timestamp}=    convert_to_number    ${frame_time}[${index}]
#    ${timestamp} =     Caculate the wireshark timevalue to seconds    input_value=${timelist}   index=${index0}
    [Return]    ${timestamp}

Update the swconfig file
    [Arguments]    ${localFilePath}
    wait until keyword succeeds    1min    10s    Connect to Common Unit Master   alias=ASIK    du_index=${0}    gnb_index=${1}
    SWConfig.Upload SwConfig File To Asik And Crasign     localFilePath=${localFilePath}    asik_alias=ASIK
    csn.Disconnect    connection=ASIK

Delete all NRADJGNB object
    Delete NRADJGNB object on gnb    url=${WEBUI2_COAM}    distname_ID=${distname_id_2}
    Delete NRADJGNB object on gnb    url=${WEBUI_COAM}    distname_ID=${distname_id_1}

Delete NRADJGNB object on gnb
    [Arguments]    ${url}    ${distname_ID}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${url}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    selenium_coam.disable_message_box
    Run Keyword And Ignore Error    selenium_coam.remove_object    object_name=${distname_ID}/NRADJGNB-0
    sleep    3s
    Run Keyword And Ignore Error    selenium_coam.remove_object    object_name=${distname_ID}/NRADJGNB-1
    sleep    3s
    Run Keyword And Ignore Error    selenium_coam.remove_object    object_name=${distname_ID}/NRADJGNB-2
    sleep    3s
    Run Keyword And Ignore Error    selenium_coam.remove_object    object_name=${distname_ID}/XNLINK-0
    sleep    3s
    Run Keyword And Ignore Error    selenium_coam.remove_object    object_name=${distname_ID}/XNLINK-1
    sleep    3s
    Run Keyword And Ignore Error    selenium_coam.remove_object    object_name=${distname_ID}/XNLINK-2
    sleep    3s
    selenium_coam.validate_plan
    sleep    5s
    selenium_coam.activate_plan    activate_plan_despite_errors=True    timeout=120
    sleep    5s
    selenium_coam.logout
    selenium_coam.disable_virtual_display


############################## Wanglei Add ##############################

Adjust the HBTE attenuation value for lte
    [Arguments]      ${value_1}    ${value_2}
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    att.set_attenuation     port=${att_port_15}    value=${value_1}
    att.set_attenuation     port=${att_port_16}    value=${value_2}
    ${value_port1}    att.read_attenuation    port=${att_port_15}
    should be equal    ${value_port1}    ${value_1}
    ${value_port2}    att.read_attenuation    port=${att_port_16}
    should be equal    ${value_port2}    ${value_2}

Start Dl Ul Tput
    [Arguments]    ${dl_throughput}=${dl_throughput}    ${ul_throughput}=${ul_throughput}    ${ue_index}=${ue_index}
    ...    ${duration}=${duration}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl   throughput=${dl_throughput}
    ...    duration=${duration}    ue_index=${ue_index}    iperf_port=${iperf_port}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul   throughput=${ul_throughput}
    ...    duration=${duration}    ue_index=${ue_index}    iperf_port=${iperf_port}

Check Dl Ul Tput
    [Arguments]    ${dl_expected_throughput}=${dl_expected_throughput}    ${ul_expected_throughput}=${ul_expected_throughput}
    ...    ${cellid}=${cellid}    ${gnb_index}=${gnb_index}
    power_ue.Check throughput    ue_type=${ue_type}    direction=ul    throughput=${ul_expected_throughput}
    ...    deviation=${deviation}    cellid=${cellid}    gnb_index=${gnb_index}
    power_ue.Check throughput    ue_type=${ue_type}    direction=dl    throughput=${dl_expected_throughput}
    ...    deviation=${deviation}    cellid=${cellid}    gnb_index=${gnb_index}

Get Current Time for counter
    @{current_time} =	Get Time	year month day hour min sec
    ${min_1}=    convert to integer    ${current_time}[4]
    ${min_2}=    convert to integer    ${min_1/5}
    ${min_3}=    convert to string    ${min_2*5}
    ${min_3}     set variable if    '${min_3}'=='0'    00      ${min_3}
    ${min_3}     set variable if    '${min_3}'=='5'    05      ${min_3}
    ${countertime}=    Catenate    SEPARATOR=    ${current_time}[0]    -    ${current_time}[1]    -    ${current_time}[2]
    ...    ${space}    ${current_time}[3]    :    ${min_3}    :00
    [Return]    ${countertime}

Get Current Time for counter at int time
    ${current_time}    Wait Until Keyword Succeeds    6min    20s    Get int time
    ${countertime}=    Catenate    SEPARATOR=    ${current_time}[0]    -    ${current_time}[1]    -    ${current_time}[2]
    ...    ${space}    ${current_time}[3]    :    ${current_time}[4]    :00
    [Return]    ${countertime}

Get int time
    @{current_time} =	Get Time	year month day hour min sec
    Should Contain    ${int_time_list}    ${current_time}[4]    not right time
    [Return]    ${current_time}

Get 5qi1 grant counters
    [Arguments]    ${WEBUI_COAM}=${WEBUI2_COAM}    ${WEBUI_NAME}=${WEBUI2_NAME}    ${WEBUI_PWD}=${WEBUI2_PWD}
    ...    ${countertime}=${countertime}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${M5530824001_value}=    Get counter    counter_id=M55308C24001    countertime=${countertime}
    ${M5530824002_value}=    Get counter    counter_id=M55308C24002    countertime=${countertime}
    sleep    5s
    [Return]    ${M5530824001_value}    ${M5530824002_value}
    [Teardown]    Run Keywords
    ...    Run keyword and ignore error    selenium_coam.logout                                  AND
    ...    Run keyword and ignore error    selenium_coam.disable_virtual_display

Get counter
    [Arguments]    ${counter_id}=${counter_id}    ${countertime}=${countertime}
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id}    full_path=${ct_path['${counter_id}']}
    ${value}=    Get From Dictionary    ${counters}    ${countertime}
    [Return]    ${value}

Check the bts counters are triggered
    [Arguments]    ${WEBUI_COAM}=${WEBUI2_COAM}    ${WEBUI_NAME}=${WEBUI2_NAME}    ${WEBUI_PWD}=${WEBUI2_PWD}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    Check counter M55308C23001 as 1
    Check counter M55308C23002 as 1
    Check counter M55308C24001 as 1
    Check counter M55308C24002 as 1
#    Check counter M55308C25001 as 1
#    Check counter M55308C25002 as 1
    sleep    5s
    [Teardown]    Run Keywords
    ...    Run keyword and ignore error    selenium_coam.logout                                  AND
    ...    Run keyword and ignore error    selenium_coam.disable_virtual_display

Check the bts discard counters are triggered
    [Arguments]    ${WEBUI_COAM}=${WEBUI2_COAM}    ${WEBUI_NAME}=${WEBUI2_NAME}    ${WEBUI_PWD}=${WEBUI2_PWD}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    Check counter M55308C24001 as 10
    Check counter M55310C19001 as 5
    sleep    5s
    [Teardown]    Run Keywords
    ...    Run keyword and ignore error    selenium_coam.logout                                  AND
    ...    Run keyword and ignore error    selenium_coam.disable_virtual_display

Check the bts discard counters are not be triggered
    [Arguments]    ${WEBUI_COAM}=${WEBUI_COAM}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    Check counter M55308C24001 as 20
    Check counter M55310C19001 equal 0
    sleep    5s
    [Teardown]    Run Keywords
    ...    Run keyword and ignore error    selenium_coam.logout                                  AND
    ...    Run keyword and ignore error    selenium_coam.disable_virtual_display

Check the bts padding counters are triggered
    [Arguments]    ${WEBUI_COAM}=${WEBUI2_COAM}    ${WEBUI_NAME}=${WEBUI2_NAME}    ${WEBUI_PWD}=${WEBUI2_PWD}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    Check counter M55308C24002 as 10
    Check counter M55309C11001 as 0
    sleep    5s
    [Teardown]    Run Keywords
    ...    Run keyword and ignore error    selenium_coam.logout                                  AND
    ...    Run keyword and ignore error    selenium_coam.disable_virtual_display

Get ul mcs counters
    [Arguments]    ${WEBUI_COAM}=${WEBUI2_COAM}    ${WEBUI_NAME}=${WEBUI2_NAME}    ${WEBUI_PWD}=${WEBUI2_PWD}
    ...    ${countertime}=${countertime}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${M55302C00000}=    Get counter    counter_id=M55302C00000    countertime=${countertime}
    ${M55302C00001}=    Get counter    counter_id=M55302C00001    countertime=${countertime}
    ${M55302C00002}=    Get counter    counter_id=M55302C00002    countertime=${countertime}
    ${M55302C00003}=    Get counter    counter_id=M55302C00003    countertime=${countertime}
    ${M55302C00004}=    Get counter    counter_id=M55302C00004    countertime=${countertime}
    ${M55302C00005}=    Get counter    counter_id=M55302C00005    countertime=${countertime}
    ${M55302C00006}=    Get counter    counter_id=M55302C00006    countertime=${countertime}
    ${M55302C00007}=    Get counter    counter_id=M55302C00007    countertime=${countertime}
    ${M55302C00008}=    Get counter    counter_id=M55302C00008    countertime=${countertime}
    ${M55302C00009}=    Get counter    counter_id=M55302C00009    countertime=${countertime}
    ${M55302C00010}=    Get counter    counter_id=M55302C00010    countertime=${countertime}
    ${M55302C00011}=    Get counter    counter_id=M55302C00011    countertime=${countertime}
    ${M55302C00012}=    Get counter    counter_id=M55302C00012    countertime=${countertime}
    ${M55302C00013}=    Get counter    counter_id=M55302C00013    countertime=${countertime}
    ${M55302C00014}=    Get counter    counter_id=M55302C00014    countertime=${countertime}
    ${M55302C00015}=    Get counter    counter_id=M55302C00015    countertime=${countertime}
    ${M55302C00016}=    Get counter    counter_id=M55302C00016    countertime=${countertime}
    ${M55302C00017}=    Get counter    counter_id=M55302C00017    countertime=${countertime}
    ${M55302C00018}=    Get counter    counter_id=M55302C00018    countertime=${countertime}
    ${M55302C00019}=    Get counter    counter_id=M55302C00019    countertime=${countertime}
    ${M55302C00020}=    Get counter    counter_id=M55302C00020    countertime=${countertime}
    ${M55302C00021}=    Get counter    counter_id=M55302C00021    countertime=${countertime}
    ${M55302C00022}=    Get counter    counter_id=M55302C00022    countertime=${countertime}
    ${M55302C00023}=    Get counter    counter_id=M55302C00023    countertime=${countertime}
    ${M55302C00024}=    Get counter    counter_id=M55302C00024    countertime=${countertime}
    ${M55302C00025}=    Get counter    counter_id=M55302C00025    countertime=${countertime}
    ${M55302C00026}=    Get counter    counter_id=M55302C00026    countertime=${countertime}
    ${M55302C00027}=    Get counter    counter_id=M55302C00027    countertime=${countertime}
    ${M55302C00028}=    Get counter    counter_id=M55302C00028    countertime=${countertime}
    @{ulmcs_list}    create list    ${M55302C00000}    ${M55302C00001}    ${M55302C00002}    ${M55302C00003}    ${M55302C00004}
    ...    ${M55302C00005}    ${M55302C00006}    ${M55302C00007}    ${M55302C00008}    ${M55302C00009}    ${M55302C00010}
    ...    ${M55302C00011}    ${M55302C00012}    ${M55302C00013}    ${M55302C00014}    ${M55302C00015}    ${M55302C00016}
    ...    ${M55302C00017}    ${M55302C00018}    ${M55302C00019}    ${M55302C00020}    ${M55302C00021}    ${M55302C00022}
    ...    ${M55302C00023}    ${M55302C00024}    ${M55302C00025}    ${M55302C00026}    ${M55302C00027}    ${M55302C00028}
    sleep    5s
    [Return]    ${ulmcs_list}
    [Teardown]    Run Keywords
    ...    Run keyword and ignore error    selenium_coam.logout                                  AND
    ...    Run keyword and ignore error    selenium_coam.disable_virtual_display

Check the bts setup and release counters are triggered
    [Arguments]    ${WEBUI_COAM}=${WEBUI2_COAM}    ${WEBUI_NAME}=${WEBUI2_NAME}    ${WEBUI_PWD}=${WEBUI2_PWD}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    Check counter M55138C01001 as 0
    Check counter M55138C01002 as 0
    Check counter M55138C01004 as 0
    Check counter M55139C00501 as 0
    Check counter M55139C00502 as 0
    Check counter M55139C00509 as 0
    sleep    5s
    [Teardown]    Run Keywords
    ...    Run keyword and ignore error    selenium_coam.logout                                  AND
    ...    Run keyword and ignore error    selenium_coam.disable_virtual_display

Check IE wireshark log for VONR discardtimer
    [Arguments]    ${logname}    ${message_filter}    ${xpath}    ${value}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
    ${discardtimer}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//${xpath}
    should be equal    ${discardtimer[0]}    ${value}

Check IE wireshark log for BearerGroupID
    [Arguments]    ${logname}    ${message_filter1}    ${xpath1}    ${message_filter2}    ${xpath2}
    ...    ${message_filter3}    ${xpath3}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ${filter_expression1}=     Catenate    ${message_filter1}
    ${filtered_packets1}=    parser.filter_packets_by_expression    filter_expression=${filter_expression1}
    ${filtered_out1}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets1}
    ...                                                xpath=.//${xpath1}
    ${Caculate1}=     set variable    ${filtered_out1[0]}
    ${Caculate2}=    convert to integer    ${Caculate1.split(":")[0]}
    ${Caculate3}=    convert to integer    ${Caculate2/100}
    ${filter_expression2}=     Catenate    ${message_filter2}
    ${filtered_packets2}=    parser.filter_packets_by_expression    filter_expression=${filter_expression2}
    ${filtered_out2}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets2}
    ...                                                xpath=.//${xpath2}
    ${Caculate4}=     set variable    ${filtered_out2[0]}
    ${Caculate5}=    convert to integer    ${Caculate4.split(":")[0]}
    ${Caculate6}=    convert to integer    ${Caculate5/100}
    ${filter_expression3}=     Catenate    ${message_filter3}
    ${filtered_packets3}=    parser.filter_packets_by_expression    filter_expression=${filter_expression3}
    ${filtered_out3}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets3}
    ...                                                xpath=.//${xpath3}
    ${Caculate7}=     set variable    ${filtered_out3[1]}
    ${Caculate8}=    convert to integer    ${Caculate7.split(":")[0]}
    ${Caculate9}=    convert to integer    ${Caculate8/100}
    @{BearerGroupID_list}    create list   ${Caculate3}    ${Caculate6}   ${Caculate9}
    [Return]     ${BearerGroupID_list}

Check IE wireshark log for VONR PHY
    [Arguments]    ${logname}    ${message_filter}    ${message_filter1}    ${message_filter2}    ${message_filter3}
    ...             ${value}   ${value1}    ${value2}   ${value3}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
    ${nr_rrc_t310}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//nr-rrc.t310
    should be equal    ${nr_rrc_t310[0]}    ${value}
    ${filter_expression}=     Catenate    ${message_filter1}
    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
    ${nr_rrc_n310}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//nr-rrc.n310
    should be equal    ${nr_rrc_n310[0]}    ${value1}
    ${filter_expression}=     Catenate    ${message_filter2}
    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
    ${nr_rrc_n311}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//nr-rrc.n311
    should be equal    ${nr_rrc_n311[0]}    ${value2}
    ${filter_expression}=     Catenate    ${message_filter3}
    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
    ${nr_rrc_t311_v1530}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//nr-rrc.t311_v1530
    Run Keyword And Ignore Error    should be equal    ${nr_rrc_t311_v1530[0]}    ${value3}

Check IE wireshark log for VONR PDCP
    [Arguments]    ${logname}    ${message_filter}    ${message_filter1}    ${message_filter2}    ${message_filter3}
    ...             ${value}   ${value1}    ${value2}   ${value3}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
    ${e1ap_pDCP_SN_Size_UL}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//e1ap.pDCP_SN_Size_UL
    should be equal    ${e1ap_pDCP_SN_Size_UL[0]}    ${value}
    ${filter_expression}=     Catenate    ${message_filter1}
    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
    ${e1ap_pDCP_SN_Size_DL}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//e1ap.pDCP_SN_Size_DL
    should be equal    ${e1ap_pDCP_SN_Size_DL[0]}    ${value1}
    ${filter_expression}=     Catenate    ${message_filter2}
    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
    ${e1ap_dRB_Inactivity_Timer}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//e1ap.dRB_Inactivity_Timer
    should be equal    ${e1ap_dRB_Inactivity_Timer[0]}    ${value2}
    ${filter_expression}=     Catenate    ${message_filter3}
    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
    ${e1ap_discardTimer}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//e1ap.discardTimer
    should be equal    ${e1ap_discardTimer[0]}    ${value3}

Check IE wireshark log for VONR RLC
    [Arguments]    ${logname}    ${message_filter}    ${value}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
    ${nr_rrc_sn_FieldLength}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//nr-rrc.sn_FieldLength
    should be equal    ${nr_rrc_sn_FieldLength[0]}    ${value}

Check IE wireshark log for VONR 5QI5 timer
    [Arguments]    ${logname}    ${message_filter}    ${value}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
    ${e1ap_dRB_Inactivity_Timer}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//e1ap.dRB_Inactivity_Timer
    should be equal    ${e1ap_dRB_Inactivity_Timer[0]}    ${value}

Check IE wireshark log for VONR DRX
    [Arguments]    ${logname}    ${message_filter}    ${xpath}    ${value}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ${filter_length}=    Get Length    ${message_filter}
    FOR    ${x}    IN RANGE    ${filter_length}
        ${filter_expression}=     Catenate    ${message_filter}[${x}]
        ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
        ${filtered_out}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//${xpath}[${x}]
        should be equal    ${filtered_out[0]}    ${value}[${x}]
    END

Check IE wireshark log for VONR noDRX
    [Arguments]    ${logname}    ${message_filter}    ${xpath}    ${value}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
    ${drx_LongCycle}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//${xpath}
    Should Be Empty    ${drx_LongCycle}

Check IE wireshark log for VONR CALLSUC
    [Arguments]    ${logname}    ${message_filter}    ${value}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
    ${ngap_radioNetwork}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//ngap.radioNetwork
    Should Be Empty    ${ngap_radioNetwork}

Check IE wireshark log for VONR CALLFAIL
    [Arguments]    ${logname}    ${message_filter}    ${value}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
    ${ngap_radioNetwork}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//ngap.radioNetwork
    should be equal    ${ngap_radioNetwork[0]}    ${value}

Check IE wireshark log for VONR MeasConf A2
    [Arguments]    ${logname}    ${message_filter}    ${xpath}    ${value}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
    ${A2_Config}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//${xpath}
    should be equal    ${A2_Config[0]}    ${value}

Check IE wireshark log for VONR MeasConf A1A3A5
    [Arguments]    ${logname}    ${message_filter}    ${xpath}    ${value}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ${filter_expression}=     Catenate    ${message_filter}[0]
    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
    ${filtered_out}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//${xpath}[0]
    should be equal    ${filtered_out[0]}    ${value}[0]
    ${filter_expression}=     Catenate    ${message_filter}[1]
    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
    ${filtered_out}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//${xpath}[1]
    should be equal    ${filtered_out[3]}    ${value}[1]
    ${filter_expression}=     Catenate    ${message_filter}[2]
    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
    ${filtered_out}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//${xpath}[2]
    should be equal    ${filtered_out[4]}    ${value}[2]
    ${filter_expression}=     Catenate    ${message_filter}[3]
    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
    ${filtered_out}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//${xpath}[3]
    should be equal    ${filtered_out[5]}    ${value}[3]

Check IE wireshark log for VONR IntraNR HO
    [Arguments]    ${logname}    ${message_filter}    ${xpath}    ${value}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
    ${HO_CMD}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//${xpath}
    Should Not Be Empty    ${HO_CMD}

Check IE wireshark log for VONR MeasConf B2A1
    [Arguments]    ${logname}    ${message_filter}    ${xpath}    ${value}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ${filter_expression}=     Catenate    ${message_filter}[0]
    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
    ${filtered_out}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//${xpath}[0]
    Should Contain    ${filtered_out}    ${value}[0]
    ${filter_expression}=     Catenate    ${message_filter}[1]
    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
    ${filtered_out}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//${xpath}[1]
    Should Contain    ${filtered_out}    ${value}[1]
    ${filter_expression}=     Catenate    ${message_filter}[2]
    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
    ${filtered_out}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//${xpath}[2]
    Should Contain    ${filtered_out}    ${value}[2]

Check IE wireshark log for VONR InterSystem HO
    [Arguments]    ${logname}    ${message_filter}    ${xpath}    ${value}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    parser.filter_packets_by_expression    filter_expression=${filter_expression}
    ${HO_CMD}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//${xpath}
    should be equal    ${HO_CMD[0]}    ${value}
    should be equal    ${HO_CMD[1]}    ${value}

Prepare UE gNB and ENB on Suite Setup
    Set automatic rotation on UEs
    Prepare env with UE      ue_index=${0}
    Prepare env with UE      ue_index=${1}

attach with capture wireshark
    [Arguments]    ${nglogname}    ${interface}    ${ue_index}
    Start Capture Wireshark Logs on gNB2    nglogname=${nglogname}    interface=${interface}
    sleep    2s
    Check phone attach successfully on SA env    gnb_index=1    ue_index=${ue_index}
    sleep    5s
    Stop Capture Wireshark Logs on gNB2    nglogname=${nglogname}
    sleep    2s

make call to 6688 with capture wireshark
    [Arguments]    ${nglogname}    ${interface}    ${ue_index}
    Start Capture Wireshark Logs on gNB2    nglogname=${nglogname}    interface=${interface}
    sleep    2s
    Make a VoNR call(+6688)    ue_index=${ue_index}
    sleep    20s
    Stop Capture Wireshark Logs on gNB2    nglogname=${nglogname}
    sleep    2s

make longcall to 6688 with capture wireshark
    [Arguments]    ${nglogname}    ${interface}    ${ue_index}
    Start Capture Wireshark Logs on gNB2    nglogname=${nglogname}    interface=${interface}
    sleep    2s
    Make a VoNR call(+6688)    ue_index=${ue_index}
    sleep    20s
    Stop Capture Wireshark Logs on gNB2    nglogname=${nglogname}
    sleep    30s

make multi call to 6688 with capture wireshark
    [Arguments]    ${nglogname}    ${interface}    ${ue_index}
    Start Capture Wireshark Logs on gNB2    nglogname=${nglogname}    interface=${interface}
    sleep    2s
    Make a VoNR call(+6688)    ue_index=${1}
    sleep    60s
    hang up VoNR call    ue_index=${1}
    sleep    2s
    Make a VoNR call(+6688)    ue_index=${1}
    sleep    60s
    hang up VoNR call    ue_index=${1}
    ${countertime}=    Get Current Time for counter
    set test variable    ${countertime}
    log    ${countertime}
    sleep    60s
    Make a VoNR call(+6688)    ue_index=${1}
    sleep    60s
    hang up VoNR call    ue_index=${1}
    sleep    2s
    Make a VoNR call(+6688)    ue_index=${1}
    sleep    60s
    hang up VoNR call    ue_index=${1}
    sleep    2s
    Stop Capture Wireshark Logs on gNB2    nglogname=${nglogname}

attach and make call to 6688 with capture wireshark
    [Arguments]    ${nglogname}    ${interface}    ${ue_index}
    Start Capture Wireshark Logs on gNB2    nglogname=${nglogname}    interface=${interface}
    sleep    2s
    Check phone attach successfully on SA env    gnb_index=1    ue_index=${ue_index}
    sleep    5s
    Make a VoNR call(+6688)    ue_index=${ue_index}
    sleep    5s
    Stop Capture Wireshark Logs on gNB2    nglogname=${nglogname}
    sleep    15s

hangup and detach
    [Arguments]    ${ue_index}
    hang up VoNR call    ue_index=${ue_index}
    sleep    10s
    TL UE detach    ue_index=${ue_index}
    sleep    5s

attach and detach two times when ue camp on 4G
    [Arguments]    ${ue_index}
    Run Keyword And Ignore Error    Check phone attach successfully on SA env    gnb_index=1    ue_index=${ue_index}
    Run Keyword And Ignore Error    TL UE detach    ue_index=${ue_index}
    Run Keyword And Ignore Error    Check phone attach successfully on SA env    gnb_index=1    ue_index=${ue_index}
    Run Keyword And Ignore Error    TL UE detach    ue_index=${ue_index}

Prepare UE gNB and ENB
    [Arguments]    ${importscf}=${true}    ${lock5g}=${true}    ${lock4g}=${true}
    Set UE to Offair      ue_index=${0}
    Set UE to Offair      ue_index=${1}
    Run Keyword If    ${importscf}    Setup for SA Env cell on-air on gnb2
    Run Keyword If    ${lock5g}    Lock The First gNB
    Run Keyword If    ${lock4g}    locked LTE cell
    selenium_coam.enable_virtual_display

Recover UE gNB and ENB
    [Arguments]    ${importscf}=${false}    ${unlock5g}=${true}    ${unlock4g}=${true}
    Run Keyword And Ignore Error    Adjust the HBTE attenuation value
    ...    value_1=${0}    value_2=${0}    value_3=${0}    value_4=${0}
    Run Keyword And Ignore Error    Adjust the HBTE attenuation value for lte    value_1=${0}    value_2=${0}
    Run Keyword If    ${importscf}    Run Keyword And Ignore Error   Setup for SA Env cell on-air on gnb2
    Run Keyword If    ${unlock5g}    Run Keyword And Ignore Error   Unlock The First gNB
    Run Keyword If    ${unlock4g}    Run Keyword And Ignore Error   unlocked LTE cell
    Run Keyword And Ignore Error    selenium_coam.disable_virtual_display
    Run Keyword And Ignore Error    CI_interface.Common Case Teardown

attach make call to 6688 hangup and detach at int time with capture wireshark
    [Arguments]    ${nglogname1}    ${nglogname2}    ${interface}    ${ue_index}
    ${current_time}    Wait Until Keyword Succeeds    6min    20s    Get int time
    ${countertime}=    Catenate    SEPARATOR=    ${current_time}[0]    -    ${current_time}[1]    -    ${current_time}[2]
    ...    ${space}    ${current_time}[3]    :    ${current_time}[4]    :00
    attach with capture wireshark    nglogname=${nglogname1}    interface=${interface}    ue_index=${ue_index}
    make longcall to 6688 with capture wireshark    nglogname=${nglogname2}    interface=${interface}    ue_index=${ue_index}
    hang up VoNR call    ue_index=${ue_index}
    TL UE detach    ue_index=${ue_index}
    [Return]    ${countertime}

check vonr attach and setup with capture wireshark
    [Arguments]    ${nglogname1}    ${nglogname2}    ${gnb_filter1}    ${gnb_filter2}    ${value1}
    Run Keyword And Continue On Failure    Check IE wireshark log for VONR attach       logname=${nglogname1}
    ...    message_filter=${gnb_filter1}[0]    message_filter1=${gnb_filter1}[1]    value=${value1}[0]    value1=${value1}[1]
    Run Keyword And Continue On Failure    Check IE wireshark log for VONR setup   logname=${nglogname2}
    ...    message_filter=${gnb_filter2}[0]

Return scf name for release
       ${gnb_release}   Get gnb release    host=${LMP_ADDR}
       ${scfname}    Run keyword if   '${gnb_release}'=='TRUNK'     set variable   TRUNK
       ...   ELSE IF    '${gnb_release}'!='TRUNK'    String.Fetch From Right    string=${gnb_release}    marker=SBTS
       [Return]     ${scfname}
