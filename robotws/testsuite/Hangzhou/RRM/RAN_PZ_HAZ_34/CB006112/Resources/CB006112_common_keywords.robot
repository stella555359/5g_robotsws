*** Settings ***
Documentation     author: yayun.zhang && Xing Jing
...                 contact: yayun.zhang@nokia-sbell.com && jing.1.xing@nokia-sbell.com
...                 squad group: SG_03
...                 feature : CB006112
Library     DateTime
#Library     L3Call.py
Library    taf.analyzer.pcap    WITH NAME    cap
#Library    ./../../../../../resources/python_libs/Attenuation.py
#Library     ../../5GC000738/Resources/get_pm_counter.py
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py
#Library    Attenuation.Attenuation    WITH NAME    atten
#Library    taf.analyzer.pcap   WITH NAME    cap
Library     taf.hw.rf_attenuator    WITH NAME    att
Library     taf.config.testline    WITH NAME    testline
Library     ./../../common/delete_ue_and_sip_context.py
Library     taf.transport.ssh    WITH NAME    csn
Library     taf.sbts.oam.coam.admin   WITH NAME    coam
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/sigspark.py
Variables   ../Resources/variables.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Library     taf.rfrl.common_resources.python.SWConfig    WITH NAME    SWConfig
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    taf/rfrl/common_resources/robot/stream_manager.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    taf/rfrl/common_resources/robot/TTI_Trace.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/UE.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot

*** Variables ***
${scf_path}    /opt/workspace/CRT/Master/SCF_file/golden SCF/
${tl_scf_SBTS25R3_ENB_9999}    Trunk_Configuration_scf_GNB1_CB008698.xml
${tl_scf_SBTS25R2_ENB_9999}    Trunk_Configuration_scf_GNB1_CB008698.xml
${tl_scf_SBTS25R2_ENB_0000}    Trunk_Configuration_scf_GNB1_CB008698.xml
${tl_scf_SBTS24R2_ENB_0000}    24R1_Configuration_scf_GNB1_CB008698.xml
${tl_scf_SBTS24R2_ENB_9999}    24R1_Configuration_scf_GNB1_CB008698.xml
${tl_scf_SBTS24R1_ENB_0000}    24R1_Configuration_scf_GNB1_CB008698.xml
${tl_scf_SBTS23R4_ENB_0000}    Configuration_scf_GNB1_CB008698.xml
${tl_scf_SBTS23R3_ENB_0000}    Configuration_scf_GNB1_CB008698.xml

${tl_scf2_SBTS25R3_ENB_9999}    Trunk_Configuration_scf_GNB2_CB008698.xml
${tl_scf2_SBTS25R2_ENB_9999}    Trunk_Configuration_scf_GNB2_CB008698.xml
${tl_scf2_SBTS25R2_ENB_0000}    Trunk_Configuration_scf_GNB2_CB008698.xml
${tl_scf2_SBTS24R2_ENB_0000}    24R1_Configuration_scf_GNB2_CB008698.xml
${tl_scf2_SBTS24R2_ENB_9999}    24R1_Configuration_scf_GNB2_CB008698.xml
${tl_scf2_SBTS24R1_ENB_0000}    24R1_Configuration_scf_GNB2_CB008698.xml
${tl_scf2_SBTS23R4_ENB_0000}    Configuration_scf_GNB2_CB008698.xml
${tl_scf2_SBTS23R3_ENB_0000}    Configuration_scf_GNB2_CB008698.xml

${gnb_path}    /tmp
${connection}    gnb
${epc_log_path}    /tmp
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
${asik_addr}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${asik2_addr}    ${tl.gnbs[1].cu.oam_ssh_connection_details.addr}
${asik2_username}    ${tl.gnbs[1].cu.oam_ssh_connection_details.username}
${asik2_password}     ${tl.gnbs[1].cu.oam_ssh_connection_details.password}
${enb_address}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${enb_username}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.username}
${enb_password}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.password}
${enb_instance}     ${tl.enbs[0].instance_id}
${TOPYONG_ANT1}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[0].port_no}
${TOPYONG_ANT2}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[1].port_no}
${TOPYONG_ANT3}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[2].port_no}
${TOPYONG_ANT4}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[3].port_no}
${att_ipaddr}      ${tl.attenuator[0].ip_addr}
${att_ipaddr_1}    ${tl.attenuator[1].ip_addr}
${att_connection_port}       ${tl.attenuator[0].attenuator_ports[5]}
${att_api_port}              ${tl.attenuator[0].port}
${vendor}                    ${tl.attenuators[0].vendor}
${model}                     ${tl.attenuator[0].model}
${max_attenuation_value}     ${127}
#${att_port_1}                ${tl.attenuator[0].attenuator_ports[5]}
#${att_port_2}                ${tl.attenuator[0].attenuator_ports[6]}
#${att_port_3}                ${tl.attenuator[0].attenuator_ports[7]}
#${att_port_4}                ${tl.attenuator[0].attenuator_ports[8]}
@{diffTL_enb_ID}    36721    38221    911    5395    342

###UE ###
${ue_type}    huawei
${duration}    1200
${deviation}    15

${command_template_with_Y}    {tshark_path} -r {pcap_file} -Y  \"ngap or e1ap or f1ap or xnap\"  -T pdml
@{gnb_ips}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}    ${tl.gnbs[1].cu.oam_ssh_connection_details.addr}
#@{gnb_list}    ${0}    ${1}
@{gnb_list}    ${0}
@{branch}    SBTS23R3_ENB_0000    SBTS23R4_ENB_0000    SBTS24R1_ENB_0000

*** Keywords ***
###attenuator###
Adjust ${RU} Attenuation to ${value}
    Adjust the Attenuation Value    ports=${5G${RU}_ANT9}    value=${value}
    Adjust the Attenuation Value    ports=${5G${RU}_ANT10}    value=${value}

Adjust the Attenuation Value
    [Arguments]    ${ports}    ${value}
    atten.connect to    ip=${att_ipaddr}
    atten.get_value    channel=${ports}
    atten.set_value    channel=${ports}    value=${value}
    atten.disconnect

adjust HBTE attenuation
    [Arguments]      ${value_1}    ${value_2}    ${value_3}    ${value_4}    ${att_port1}=${att_port_1}
    ...    ${att_port2}=${att_port_2}    ${att_port3}=${att_port_3}    ${att_port4}=${att_port_4}
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    ...    model=${model}
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
#    ${res} =    Feature 1514 Enabled
    sleep    3s
    Run Keyword And Ignore Error    Check the gnb RU ready

Check the gnb RU ready
    selenium_coam.enable_virtual_display
    wait until keyword succeeds    5min    10s
    ...    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    wait until keyword succeeds    10min    20s    get RU status
    selenium_coam.logout
    selenium_coam.disable_virtual_display

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
    wait until keyword succeeds    5min    30s    Get all cell info    cell_no=${cell_no}
    [Teardown]    selenium_coam.logout

Check gnb2 COAM classical normally
    sleep    3s
    wait until keyword succeeds    10min    20s    Check the gnb2 RU ready
#    wait until keyword succeeds    5min   30s    Check the sctp UP on gnb2    port_num=${x2_sctp_port}

Lock The Second gNB
    [Arguments]     ${timeout}=60
    Connect to gnb coam via ssl    bts_host=${PEER_MASTER_IP}    connection=gnb2
#    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    coam.lock_cell
#    ...    dist_name=${distname_id_2}/NRCELL-1    connection=gnb2    #TL367
#    ...    ELSE    coam.lock    dist_name=${distname_id_2}/NRCELL-1    connection=gnb2
    coam.lock    dist_name=${distname_id_2}/NRCELL-1    connection=gnb2    timeout=${timeout}
    coam.teardown    connection=gnb2

Unlock The Second gNB
    [Arguments]     ${timeout}=60
    Connect to gnb coam via ssl    bts_host=${PEER_MASTER_IP}    connection=gnb2
#    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    coam.unlock_cell
#    ...    dist_name=${distname_id_2}/NRCELL-1    connection=gnb2    #TL367
#    ...    ELSE    coam.unlock    dist_name=${distname_id_2}/NRCELL-1    connection=gnb2
    coam.unlock    dist_name=${distname_id_2}/NRCELL-1    connection=gnb2    timeout=${timeout}
    coam.teardown    connection=gnb2

Lock The First gNB
    [Arguments]     ${timeout}=60
    Connect to gnb coam via ssl    bts_host=${LOCAL_MASTER_IP}    connection=gnb1
    coam.lock    dist_name=${distname_id_1}/NRCELL-1    connection=gnb1    timeout=${timeout}
    coam.lock    dist_name=${distname_id_1}/NRCELL-2    connection=gnb1    timeout=${timeout}
#    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    coam.lock_cell    dist_name=${distname_id_1}/NRCELL-1    connection=gnb1  #TL367
#    ...    ELSE    coam.lock    dist_name=${distname_id_1}/NRCELL-1    connection=gnb1
#    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    coam.lock_cell    dist_name=${distname_id_1}/NRCELL-2    connection=gnb1  #TL367
#    ...    ELSE    coam.lock    dist_name=${distname_id_1}/NRCELL-2    connection=gnb1
#    coam.lock_cell    dist_name=${distname_id_1}/NRCELL-1    connection=gnb1
#    coam.lock_cell    dist_name=${distname_id_1}/NRCELL-2    connection=gnb1
    coam.teardown    connection=gnb1

Unlock The First gNB
    [Arguments]     ${timeout}=60
    Connect to gnb coam via ssl    bts_host=${LOCAL_MASTER_IP}    connection=gnb1
    coam.unlock   dist_name=${distname_id_1}/NRCELL-1     connection=gnb1    timeout=${timeout}
    coam.unlock    dist_name=${distname_id_1}/NRCELL-2    connection=gnb1    timeout=${timeout}
#    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    coam.unlock_cell    dist_name=${distname_id_1}/NRCELL-1    connection=gnb1  #TL367
#    ...    ELSE    coam.unlock   dist_name=${distname_id_1}/NRCELL-1    connection=gnb1
#    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    coam.unlock_cell    dist_name=${distname_id_1}/NRCELL-2    connection=gnb1  #TL367
#    ...    ELSE    coam.unlock    dist_name=${distname_id_1}/NRCELL-2    connection=gnb1
#    coam.unlock_cell    dist_name=${distname_id_1}/NRCELL-1    connection=gnb1
#    coam.unlock_cell    dist_name=${distname_id_1}/NRCELL-2    connection=gnb1
    coam.teardown    connection=gnb1

#Lock_gnb2_Cell
#    [Arguments]         ${url}=${WEBUI2_COAM}    ${cell_id}=1    ${bts_host}=${asik2_addr}    ${port}=443      ${alias}=OAM_admin
#    ...    ${username}=${WEBUI_NAME}    ${password}=${WEBUI_PWD}
#    selenium_coam.enable_virtual_display
#    selenium_coam.login    url=${url}    username=${username}    password=${password}
#    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
#    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
#    ${bts_id}   selenium_coam.get_bts_id
#    Set Suite Variable    ${administrativeState_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${cell_id}
#    selenium_coam.logout
#    selenium_coam.disable_virtual_display
#    coam.connect to   bts_host=${bts_host}
#    ...               bts_port=${port}    name=${alias}
#    coam.lock_cell    dist_name=/${administrativeState_distname}
#    ...               connection=${alias}
#    coam.teardown          connection=${alias}
#
#unLock_gnb2_Cell
#    [Arguments]         ${url}=${WEBUI2_COAM}    ${cell_id}=1    ${bts_host}=${asik2_addr}    ${port}=443      ${alias}=OAM_admin
#    ...    ${username}=${WEBUI_NAME}    ${password}=${WEBUI_PWD}
#    selenium_coam.enable_virtual_display
#    selenium_coam.login    url=${url}    username=${username}    password=${password}
#    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
#    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
#    ${bts_id}   selenium_coam.get_bts_id
#    Set Suite Variable    ${administrativeState_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${cell_id}
#    selenium_coam.logout
#    selenium_coam.disable_virtual_display
#    coam.connect to   bts_host=${bts_host}
#    ...               bts_port=${port}    name=${alias}
#    coam.unlock_cell    dist_name=${administrativeState_distname}
#    ...               connection=${alias}
#    coam.teardown          connection=${alias}

Lock_gnb2_Cell
    [Arguments]         ${url}=${WEBUI2_COAM}    ${cell_id}=1    ${bts_host}=${asik2_addr}    ${alias}=GNB_OAM    #${port}=443
    ...    ${username}=${WEBUI_NAME}    ${password}=${WEBUI_PWD}    ${timeout}=60
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${url}    username=${username}    password=${password}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${administrativeState_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${cell_id}
    selenium_coam.logout
    selenium_coam.disable_virtual_display
#    Lock_gnb2_Cell    url=${WEBUI_COAM}    cell_id=2    bts_host=${asik_addr}
    coam_gnb_classical.Connect to gnb coam via ssl    bts_host=${bts_host}
#    coam.connect to   bts_host=${bts_host}
#    ...               bts_port=${port}    name=${alias}
#    coam.lock_cell    dist_name=/${administrativeState_distname}
#    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    coam.lock_cell    dist_name=/${administrativeState_distname}
#    ...    connection=${alias}                     #TL367
#    ...    ELSE    coam.lock    dist_name=/${administrativeState_distname}    connection=${alias}
    coam.lock    dist_name=${administrativeState_distname}    timeout=${timeout}    connection=${alias}
    coam.teardown          connection=${alias}

unLock_gnb2_Cell
    [Arguments]         ${url}=${WEBUI2_COAM}    ${cell_id}=1    ${bts_host}=${asik2_addr}    ${alias}=GNB_OAM    #${port}=443
    ...    ${username}=${WEBUI_NAME}    ${password}=${WEBUI_PWD}    #${timeout}=60
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${url}    username=${username}    password=${password}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${administrativeState_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/NRCELL-${cell_id}
    selenium_coam.logout
    selenium_coam.disable_virtual_display
#    coam.connect to   bts_host=${bts_host}    bts_port=${port}    name=${alias}
    coam_gnb_classical.Connect to gnb coam via ssl    bts_host=${bts_host}
#    coam.unlock_cell    dist_name=${administrativeState_distname}
#    Run Keyword If    '${enb_instance}'=='@{diffTL_enb_ID}[0]'    coam.unlock_cell    dist_name=${administrativeState_distname}
#    ...    connection=${alias}    #TL367
#    ...    ELSE    coam.unlock    dist_name=/${administrativeState_distname}    connection=${alias}
    coam.unlock    dist_name=/${administrativeState_distname}    connection=${alias}
    coam.teardown          connection=${alias}

Setup for SA Env cell on-air on gnb2
    Prepare SA classical COAM BTS cell onair on gnb2
    RUN KEYWORD IF    '${cell_status}'=='FAIL'    Prepare SA classical COAM BTS cell onair on gnb2
    should be equal    ${cell_status}    PASS

Prepare SA classical COAM BTS cell onair on gnb2
    ${cell_status}    ${cell_value} =    Run Keyword And Ignore Error    Prepare SA COMA classical BTS cell onair on gnb2
    set global variable    ${cell_status}

Prepare SA COMA classical BTS cell onair on gnb2
    Perform full commission for COAM SA gnb2    scf=${SCF_path}${SCF_file_name_2}    gnb_ip=${asik2_addr}
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
    wait until keyword succeeds    10min    20s    get gnb2 RU status
    selenium_coam.logout
    selenium_coam.disable_virtual_display

get gnb2 RU status
    ${ru1_status} =    selenium_coam.get_ru_info    ru_index=1
    sleep    10s
    Get info status check    info_status=${ru1_status}

Get info status check
    [Arguments]    ${info_status}
    ${Status} =   get from dictionary    ${info_status}    Status
    ${opr_state} =   get from dictionary    ${Status}    Operational state
    should be equal    ${opr_state}    Enabled    ignore_case=${True}
#    ${avi_state} =   get from dictionary    ${Status}   Availability status
#    should be equal    ${avi_state}    Online
    ${adm_state} =   get from dictionary    ${Status}    Administrative state
    should be equal    ${adm_state}    Unlocked

Check the gnb2 cell status onair
    [Arguments]    ${cell_no}=1    #${gnb_ip}=${WEBUI_COAM}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI2_COAM}    username=${WEBUI2_NAME}    password=${WEBUI2_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    wait until keyword succeeds    5min    30s    Get all cell info    cell_no=${cell_no}
    [Teardown]    selenium_coam.logout

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
    csn.send command    command=killall tcpdump     connection=gnb2
    sleep    3
    csn.download_file   remote_path=${gnb_path}/${nglogname}   local_path=${epc_log_path}${nglogname}   connection=gnb2
    sleep    5
    gnb2 disconnection

Modify the COAM parameter with admin API
    [Arguments]    ${parameters}
    Connect to gnb coam via ssl    bts_host=${asik2_addr}    username=${WEBUI2_NAME}    password=${WEBUI2_PWD}
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
    [Arguments]    ${new_value}=Unlocked    ${despite_errors}=True    #${value}=Unlocked
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
    [Arguments]    ${new_value}=Unlocked    ${despite_errors}=True    #${value}=Unlocked
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
    [teardown]    Run Keyword And Ignore Error    selenium_coam.logout

Get gnb release
    [Arguments]   ${host}=${asik_addr}   ${username}=${asik_username}   ${password}=${asik_password}
    csn.Connect To   hostname=${host}   username=${username}   password=${password}   alias=release_info
    ${info}   csn.Execute    command=ls /ffs/run/TargetBD*xml   connection=release_info
#    ${release_info}     set variable    ${info.split('_')[1]}
    ${release_info}     set variable    ${info.split('_')[1]}_${info.split('_')[2]}_${info.split('_')[3]}
    [Return]    ${release_info}
    [Teardown]   csn.Disconnect   connection=release_info

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
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id}
    ${values}    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
    should be true   ${values[-1]}>=${expected_value}

Check counter ${counter_id} equal ${expected_value}
    ${counters}=    selenium_coam.get_bts_counters_info     counter_id=${counter_id}
    ${values}    get dictionary values   ${counters}
    log  The latest one is: ${values[-1]}
    should be true   ${values[-1]}==${expected_value}

Check the bts counters are triggered
    [Arguments]    ${WEBUI_COAM}=${WEBUI_COAM}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    Check counter M55308C23002 as 100
    Check counter M55308C24001 as 100
    Check counter M55308C24002 as 100
    Check counter M55308C25001 as 100
    Check counter M55308C25002 as 100
    sleep    5s
    [Teardown]    Run keyword and ignore error   selenium_coam.logout

Check the bts discard counters are triggered
    [Arguments]    ${WEBUI_COAM}=${WEBUI_COAM}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    Check counter M55308C23002 as 100
    Check counter M55310C19001 as 1
    sleep    5s
    [Teardown]    Run keyword and ignore error   selenium_coam.logout

Check the bts discard counters are not be triggered
    [Arguments]    ${WEBUI_COAM}=${WEBUI_COAM}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    Check counter M55308C23002 as 100
    Check counter M55310C19001 equal 0
    sleep    5s
    [Teardown]    Run keyword and ignore error   selenium_coam.logout

###UE keywordWords###
Prepare env with UE
    [Arguments]    ${ue_index}=${0}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}

Check phone attach successfully on SA env two times
    [Arguments]    ${gnb_index}    ${ue_index}=${0}
    ${UE_status}    run keyword and return status     Check phone attach successfully on SA env    gnb_index=${gnb_index}    ue_index=${ue_index}
    run keyword if     '${UE_status}'=='False'    Check phone attach successfully on SA env    gnb_index=${gnb_index}    ue_index=${ue_index}

Check phone attach successfully on SA env
    [Arguments]    ${gnb_index}=${0}    ${ue_index}=${0}    #${5Gstatus}=PASS    ${abil}=asp1a
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    gnb_index=${gnb_index}    ue_index=${ue_index}
    power_ue.Verify attach    ue_type=${ue_type}    gnb_index=${gnb_index}    5Grach_ed=${5Grach_ed}    4G_check=False    ue_index=${ue_index}

Make a VoNR call(+6688)
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=6688    ${sleep_time}=30s
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
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
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:+${phone_number}
    ...    connection=cygwin${ue_index}
    sleep    ${sleep_time}
    check voice call status    ue_index=${ue_index}
    [Teardown]    csn.disconnect      connection=cygwin${ue_index}

check voice call status
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${status}=${2}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}
    sleep   3s
    ##### check voice call enable  #####
    ##### 0: the phone is in standby state. 1: the call is not answered. 2: the phone is busy  #####
    csn.send_command    command=adb -s ${serial_number} shell dumpsys telephony.registry |grep mCallState
    ...    connection=cpc_${ue_index}
    sleep   2s
    ${result} =    csn.read output    connection=cpc_${ue_index}
    sleep    1s
    csn.disconnect      connection=cpc_${ue_index}
    should contain    ${result}    mCallState=${status}

hang up VoNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 6    connection=cygwin${ue_index}

Set automatic rotation on UEs
    Set automatic rotation
    Set automatic rotation    ue_index=${1}

Set automatic rotation
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...    ${commond}=shell content insert --uri content://settings/system --bind name:s:accelerometer_rotation --bind value:i:
    ...    ${rotation_value}=0
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} ${commond}${rotation_value}
    ...    connection=cygwin${ue_index}
    sleep    5s

UE attach successfully
    [Arguments]    ${ue_index}=${0}    ${gnb_index}=${0}    #${5Gstatus}=PASS    ${abil}=asp1a
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    gnb_index=${gnb_index}
    power_ue.Verify attach    ue_type=${ue_type}    ue_index=${ue_index}    gnb_index=${gnb_index}
    ...    5Grach_ed=${5Grach_ed}    4G_check=False

Make a voice call on UE
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Make a call on UE(dial +6688 on UE)    ue_index=${ue_index}    serial_number=${serial_number}
    End a call on UE    ue_index=${ue_index}    serial_number=${serial_number}

Make a call on UE(dial +6688 on UE)
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
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
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 82
    ...    connection=cygwin${ue_index}
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 6    connection=cygwin${ue_index}
    sleep   2s
    csn.disconnect      connection=cygwin${ue_index}

Prepare env with UEs
    power_ue.Prepare UE    ue_type=${ue_type}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}

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
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}

    ${UERadioCapabilityInfoIndication} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 44
    Log To Console    check voiceOverNR value on UERadioCapabilityInfoIndication message
    ${UERadioCapabilityInfoIndication_status} =    run_keyword_and_return_status
    ...    cap.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${UERadioCapabilityInfoIndication}
    should be equal    ${UERadioCapabilityInfoIndication_status}    ${True}
    ${filtered_packets}=    cap.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${UERadioCapabilityInfoIndication}
    ${nr_rrc_voiceOverNR}=    cap.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//nr-rrc.voiceOverNR
    Should Be Equal    ${nr_rrc_voiceOverNR[0]}    0

Make a VoNR and ViNR call together
    [Arguments]    ${phone_number}=18001006306    ${ue_index}=${0}
    power_ue.Prepare UE    ue_type=${ue_type}
    Get VoNR and ViNR pointer variable
    Make a VoNR and ViNR call    ue_index=${ue_index}    phone_number=${phone_number}
    answer ViNR call    ue_index=${1}

Make a VoNR and ViNR call
    [Arguments]    ${ue_index}=${0}   ${phone_number}=18001006149
    ${serial_number}	set variable   ${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
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
    power_ue.Prepare UE    ue_type=${ue_type}
    Get VoNR and ViNR pointer variable
    Make a VoNR call    phone_number=${phone_number}
    answer VoNR call    ue_index=${1}

Make a ViNR call separately
    Make a ViNR call
    answer ViNR call    ue_index=${1}

Make a VoNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=18001006149
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
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
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 5    connection=cygwin${ue_index}
    sleep    5s

Make a ViNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${Make_ViNR_button_S}    connection=cygwin${ue_index}
    sleep    5s

answer ViNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${answer_ViNR_button}    connection=cygwin${ue_index}
    sleep    5s

switch ViNR to VoNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${trigger_button}    connection=cygwin${ue_index}
    sleep    1s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${switch_to_VoNR}    connection=cygwin${ue_index}

hang up VoNR and ViNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
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
    Set Suite Variable    ${answer_ViNR_button}    762 1999
    Set Suite Variable    ${switch_to_VoNR}    914 1746
    Set Suite Variable    ${trigger_button}    735 1805
    Set Suite Variable    ${hang_up_VoNR_and_ViNR}    588 1982
    Set Suite Variable    ${Make_ViNR_button_S}    254 1728

check points with VoNR and ViNR call together
    [Arguments]    ${logname}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}

    ${PDUSessionResourceModifyRequest} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 26
    Log To Console    check fiveQI value on PDUSessionResourceModifyRequest message
    ${PDUSessionResourceModifyRequest_status} =    run_keyword_and_return_status
    ...    cap.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${PDUSessionResourceModifyRequest}
    should be equal    ${PDUSessionResourceModifyRequest_status}    ${True}
    ${filtered_packets}=    cap.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${PDUSessionResourceModifyRequest}
    ${ngap_fiveQI}=    cap.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//ngap.fiveQI
    Should Contain    ${ngap_fiveQI}    1
    Should Contain    ${ngap_fiveQI}    2

    ${BearerContextModificationRequest} =    Catenate    e1ap.E1AP_PDU == 0 and e1ap.procedureCode == 9
    Log To Console    check BearerContextModificationRequest message
    ${BearerContextModificationRequest_status} =    run_keyword_and_return_status
    ...    cap.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${BearerContextModificationRequest}
    should be equal    ${BearerContextModificationRequest_status}    ${True}

    ${BearerContextModificationResponse} =    Catenate    e1ap.E1AP_PDU == 1 and e1ap.procedureCode == 9
    Log To Console    check BearerContextModificationResponse message
    ${BearerContextModificationResponse_status} =    run_keyword_and_return_status
    ...    cap.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${BearerContextModificationResponse}
    should be equal    ${BearerContextModificationResponse_status}    ${True}

    ${UEContextModificationRequest} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 7
    Log To Console    check value on UEContextModificationRequest message
    ${UEContextModificationRequest_status} =    run_keyword_and_return_status
    ...    cap.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${UEContextModificationRequest}
    should be equal    ${UEContextModificationRequest_status}    ${True}
    ${filtered_packets}=    cap.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${UEContextModificationRequest}
    ${f1ap_fiveQI}=    cap.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.fiveQI
    Should Contain    ${f1ap_fiveQI}    1
    Should Contain    ${f1ap_fiveQI}    2
    ${f1ap_PDCPSNLength}=    cap.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.PDCPSNLength
    Should Contain    ${f1ap_PDCPSNLength}    0
    ${f1ap_DRXConfigurationIndicator}=    cap.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.DRXConfigurationIndicator
    Should Contain    ${f1ap_DRXConfigurationIndicator}    0

    ${UEContextModificationResponse} =    Catenate    f1ap.F1AP_PDU == 1 and f1ap.procedureCode == 7
    Log To Console    check value on UEContextModificationResponse message
    ${UEContextModificationResponse_status} =    run_keyword_and_return_status
    ...    cap.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${UEContextModificationResponse}
    should be equal    ${UEContextModificationResponse_status}    ${True}
    ${filtered_packets}=    cap.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${UEContextModificationResponse}
    ${f1ap_id}=    cap.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.id
    Should Contain    ${f1ap_id}    39

    ${DLRRCMessageTransfer} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 12
    Log To Console    check DLRRCMessageTransfer message
    ${DLRRCMessageTransfer_status} =    run_keyword_and_return_status
    ...    cap.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${DLRRCMessageTransfer}
    should be equal    ${DLRRCMessageTransfer_status}    ${True}

    ${ULRRCMessageTransfer} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 13
    Log To Console    check ULRRCMessageTransfer message
    ${ULRRCMessageTransfer_status} =    run_keyword_and_return_status
    ...    cap.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${ULRRCMessageTransfer}
    should be equal    ${ULRRCMessageTransfer_status}    ${True}

    ${PDUSessionResourceModifyResponse} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 26
    Log To Console    check PDUSessionResourceModifyResponse
    ${PDUSessionResourceModifyResponse_status} =    run_keyword_and_return_status
    ...    cap.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${PDUSessionResourceModifyResponse}
    should be equal    ${PDUSessionResourceModifyResponse_status}    ${True}
    ${filtered_packets}=    cap.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${PDUSessionResourceModifyResponse}
    ${ngap_qosFlowAddOrModifyResponseList} =    cap.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//ngap.qosFlowAddOrModifyResponseList
    Should be equal    ${ngap_qosFlowAddOrModifyResponseList[0]}    2
    Should be equal    ${ngap_qosFlowAddOrModifyResponseList[1]}    2

check points with VoNR and ViNR call release together
    [Arguments]    ${logname}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}

    ${PDUSessionResourceModifyRequest} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 26
    Log To Console    check release value on PDUSessionResourceModifyRequest message
    ${PDUSessionResourceModifyRequest_status} =    run_keyword_and_return_status
    ...    cap.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${PDUSessionResourceModifyRequest}
    should be equal    ${PDUSessionResourceModifyRequest_status}    ${True}
    ${filtered_packets}=    cap.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${PDUSessionResourceModifyRequest}
    ${ngap_nas}=    cap.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//ngap.nas
    Should Contain    ${ngap_nas}    0

    ${BearerContextModificationRequest} =    Catenate    e1ap.E1AP_PDU == 0 and e1ap.procedureCode == 9
    Log To Console    check release BearerContextModificationRequest message
    ${BearerContextModificationRequest_status} =    run_keyword_and_return_status
    ...    cap.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${BearerContextModificationRequest}
    should be equal    ${BearerContextModificationRequest_status}    ${True}
    ${filtered_packets}=    cap.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${BearerContextModificationRequest}
    ${e1ap_dRB_To_Remove_List_NG_RAN}=    cap.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//e1ap.dRB_To_Remove_List_NG_RAN
    Should Contain    ${e1ap_dRB_To_Remove_List_NG_RAN}    2
    ${e1ap_dRB_ID}=    cap.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//e1ap.dRB_ID
    Should Contain    ${e1ap_dRB_ID}    6
    Should Contain    ${e1ap_dRB_ID}    7

    ${BearerContextModificationResponse} =    Catenate    e1ap.E1AP_PDU == 1 and e1ap.procedureCode == 9
    Log To Console    check release BearerContextModificationResponse message
    ${BearerContextModificationResponse_status} =    run_keyword_and_return_status
    ...    cap.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${BearerContextModificationResponse}
    should be equal    ${BearerContextModificationResponse_status}    ${True}

    ${UEContextModificationRequest} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 7
    Log To Console    check value on release UEContextModificationRequest message
    ${UEContextModificationRequest_status} =    run_keyword_and_return_status
    ...    cap.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${UEContextModificationRequest}
    should be equal    ${UEContextModificationRequest_status}    ${True}
    ${filtered_packets}=    cap.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${UEContextModificationRequest}
    ${f1ap_DRBs_ToBeReleased_List}=    cap.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.DRBs_ToBeReleased_List
    Should Contain    ${f1ap_DRBs_ToBeReleased_List}    2

    ${UEContextModificationResponse} =    Catenate    f1ap.F1AP_PDU == 1 and f1ap.procedureCode == 7
    Log To Console    check value on release UEContextModificationResponse message
    ${UEContextModificationResponse_status} =    run_keyword_and_return_status
    ...    cap.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${UEContextModificationResponse}
    should be equal    ${UEContextModificationResponse_status}    ${True}
    ${filtered_packets}=    cap.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${UEContextModificationResponse}
    ${nr_rrc_drx_Config}=    cap.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//nr-rrc.drx_Config
#    Should Contain    ${nr_rrc_drx_Config}    1

    ${DLRRCMessageTransfer} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 12
    Log To Console    check release DLRRCMessageTransfer message
    ${DLRRCMessageTransfer_status} =    run_keyword_and_return_status
    ...    cap.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${DLRRCMessageTransfer}
    should be equal    ${DLRRCMessageTransfer_status}    ${True}

    ${ULRRCMessageTransfer} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 13
    Log To Console    check release ULRRCMessageTransfer message
    ${ULRRCMessageTransfer_status} =    run_keyword_and_return_status
    ...    cap.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${ULRRCMessageTransfer}
    should be equal    ${ULRRCMessageTransfer_status}    ${True}

    ${PDUSessionResourceModifyResponse} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 26
    Log To Console    check release value on PDUSessionResourceModifyResponse
    ${PDUSessionResourceModifyResponse_status} =    run_keyword_and_return_status
    ...    cap.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${PDUSessionResourceModifyResponse}
    should be equal    ${PDUSessionResourceModifyResponse_status}    ${True}
    ${filtered_packets}=    cap.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${PDUSessionResourceModifyResponse}
    ${ngap_pDUSessionResourceModifyResponseTransfer} =    cap.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//ngap.pDUSessionResourceModifyResponseTransfer
    Should Contain    ${ngap_pDUSessionResourceModifyResponseTransfer}    00

check points with ViNR call release
    [Arguments]    ${logname}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}

    ${PDUSessionResourceModifyRequest} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 26
    Log To Console    check release value on PDUSessionResourceModifyRequest message
    ${PDUSessionResourceModifyRequest_status} =    run_keyword_and_return_status
    ...    cap.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${PDUSessionResourceModifyRequest}
    should be equal    ${PDUSessionResourceModifyRequest_status}    ${True}
    ${filtered_packets}=    cap.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${PDUSessionResourceModifyRequest}
    ${ngap_nas}=    cap.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//ngap.nas
    Should Contain    ${ngap_nas}    0

    ${BearerContextModificationRequest} =    Catenate    e1ap.E1AP_PDU == 0 and e1ap.procedureCode == 9
    Log To Console    check release BearerContextModificationRequest message
    ${BearerContextModificationRequest_status} =    run_keyword_and_return_status
    ...    cap.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${BearerContextModificationRequest}
    should be equal    ${BearerContextModificationRequest_status}    ${True}
    ${filtered_packets}=    cap.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${BearerContextModificationRequest}
    ${e1ap_dRB_To_Remove_List_NG_RAN}=    cap.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//e1ap.dRB_To_Remove_List_NG_RAN
    Should Contain    ${e1ap_dRB_To_Remove_List_NG_RAN}    1
    ${e1ap_dRB_ID}=    cap.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//e1ap.dRB_ID
#    Should Not Contain    ${e1ap_dRB_ID}    6
#    Should Contain    ${e1ap_dRB_ID}    7

    ${BearerContextModificationResponse} =    Catenate    e1ap.E1AP_PDU == 1 and e1ap.procedureCode == 9
    Log To Console    check release BearerContextModificationResponse message
    ${BearerContextModificationResponse_status} =    run_keyword_and_return_status
    ...    cap.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${BearerContextModificationResponse}
    should be equal    ${BearerContextModificationResponse_status}    ${True}

    ${UEContextModificationRequest} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 7
    Log To Console    check value on release UEContextModificationRequest message
    ${UEContextModificationRequest_status} =    run_keyword_and_return_status
    ...    cap.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${UEContextModificationRequest}
    should be equal    ${UEContextModificationRequest_status}    ${True}
    ${filtered_packets}=    cap.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${UEContextModificationRequest}
    ${f1ap_DRBs_ToBeReleased_List}=    cap.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.DRBs_ToBeReleased_List
    Should Contain    ${f1ap_DRBs_ToBeReleased_List}    1

    ${UEContextModificationResponse} =    Catenate    f1ap.F1AP_PDU == 1 and f1ap.procedureCode == 7
    Log To Console    check value on release UEContextModificationResponse message
    ${UEContextModificationResponse_status} =    run_keyword_and_return_status
    ...    cap.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${UEContextModificationResponse}
    should be equal    ${UEContextModificationResponse_status}    ${True}

    ${DLRRCMessageTransfer} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 12
    Log To Console    check release DLRRCMessageTransfer message
    ${DLRRCMessageTransfer_status} =    run_keyword_and_return_status
    ...    cap.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${DLRRCMessageTransfer}
    should be equal    ${DLRRCMessageTransfer_status}    ${True}

    ${ULRRCMessageTransfer} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 13
    Log To Console    check release ULRRCMessageTransfer message
    ${ULRRCMessageTransfer_status} =    run_keyword_and_return_status
    ...    cap.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${ULRRCMessageTransfer}
    should be equal    ${ULRRCMessageTransfer_status}    ${True}

    ${PDUSessionResourceModifyResponse} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 26
    Log To Console    check release value on PDUSessionResourceModifyResponse
    ${PDUSessionResourceModifyResponse_status} =    run_keyword_and_return_status
    ...    cap.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${PDUSessionResourceModifyResponse}
    should be equal    ${PDUSessionResourceModifyResponse_status}    ${True}
    ${filtered_packets}=    cap.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${PDUSessionResourceModifyResponse}
    ${ngap_pDUSessionResourceModifyResponseTransfer} =    cap.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//ngap.pDUSessionResourceModifyResponseTransfer
    Should Contain    ${ngap_pDUSessionResourceModifyResponseTransfer}    00

check points with VoNR call separately
    [Arguments]    ${logname}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}

    ${PDUSessionResourceModifyRequest} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 26
    Log To Console    check fiveQI value on PDUSessionResourceModifyRequest message
    ${PDUSessionResourceModifyRequest_status} =    run_keyword_and_return_status
    ...    cap.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${PDUSessionResourceModifyRequest}
    should be equal    ${PDUSessionResourceModifyRequest_status}    ${True}
    ${filtered_packets}=    cap.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${PDUSessionResourceModifyRequest}
    ${ngap_fiveQI}=    cap.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//ngap.fiveQI
    Should Contain    ${ngap_fiveQI}    1
    Should Not Contain    ${ngap_fiveQI}    2

    ${BearerContextModificationRequest} =    Catenate    e1ap.E1AP_PDU == 0 and e1ap.procedureCode == 9
    Log To Console    check BearerContextModificationRequest message
    ${BearerContextModificationRequest_status} =    run_keyword_and_return_status
    ...    cap.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${BearerContextModificationRequest}
    should be equal    ${BearerContextModificationRequest_status}    ${True}

    ${BearerContextModificationResponse} =    Catenate    e1ap.E1AP_PDU == 1 and e1ap.procedureCode == 9
    Log To Console    check BearerContextModificationResponse message
    ${BearerContextModificationResponse_status} =    run_keyword_and_return_status
    ...    cap.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${BearerContextModificationResponse}
    should be equal    ${BearerContextModificationResponse_status}    ${True}

    ${UEContextModificationRequest} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 7
    Log To Console    check value on UEContextModificationRequest message
    ${UEContextModificationRequest_status} =    run_keyword_and_return_status
    ...    cap.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${UEContextModificationRequest}
    should be equal    ${UEContextModificationRequest_status}    ${True}
    ${filtered_packets}=    cap.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${UEContextModificationRequest}
    ${f1ap_fiveQI}=    cap.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.fiveQI
    Should Contain    ${f1ap_fiveQI}    1
    Should Not Contain    ${f1ap_fiveQI}    2
    ${f1ap_PDCPSNLength}=    cap.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.PDCPSNLength
    Should Contain    ${f1ap_PDCPSNLength}    0
    ${f1ap_DRXConfigurationIndicator}=    cap.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.DRXConfigurationIndicator
#    Should Contain    ${f1ap_DRXConfigurationIndicator}    0

    ${UEContextModificationResponse} =    Catenate    f1ap.F1AP_PDU == 1 and f1ap.procedureCode == 7
    Log To Console    check value on UEContextModificationResponse message
    ${UEContextModificationResponse_status} =    run_keyword_and_return_status
    ...    cap.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${UEContextModificationResponse}
    should be equal    ${UEContextModificationResponse_status}    ${True}
    ${filtered_packets}=    cap.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${UEContextModificationResponse}
    ${f1ap_id}=    cap.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.id
    Should Contain    ${f1ap_id}    39

    ${DLRRCMessageTransfer} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 12
    Log To Console    check DLRRCMessageTransfer message
    ${DLRRCMessageTransfer_status} =    run_keyword_and_return_status
    ...    cap.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${DLRRCMessageTransfer}
    should be equal    ${DLRRCMessageTransfer_status}    ${True}

    ${ULRRCMessageTransfer} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 13
    Log To Console    check ULRRCMessageTransfer message
    ${ULRRCMessageTransfer_status} =    run_keyword_and_return_status
    ...    cap.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${ULRRCMessageTransfer}
    should be equal    ${ULRRCMessageTransfer_status}    ${True}

    ${PDUSessionResourceModifyResponse} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 26
    Log To Console    check PDUSessionResourceModifyResponse
    ${PDUSessionResourceModifyResponse_status} =    run_keyword_and_return_status
    ...    cap.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${PDUSessionResourceModifyResponse}
    should be equal    ${PDUSessionResourceModifyResponse_status}    ${True}
    ${filtered_packets}=    cap.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${PDUSessionResourceModifyResponse}
    ${ngap_qosFlowAddOrModifyResponseList} =    cap.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//ngap.qosFlowAddOrModifyResponseList
    Should be equal    ${ngap_qosFlowAddOrModifyResponseList[0]}    1
    Should be equal    ${ngap_qosFlowAddOrModifyResponseList[1]}    1

check points with ViNR call separately
    [Arguments]    ${logname}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    tshark_path=${tshark_path}

    ${PDUSessionResourceModifyRequest} =    Catenate    ngap.NGAP_PDU == 0 and ngap.procedureCode == 26
    Log To Console    check fiveQI value on PDUSessionResourceModifyRequest message
    ${PDUSessionResourceModifyRequest_status} =    run_keyword_and_return_status
    ...    cap.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${PDUSessionResourceModifyRequest}
    should be equal    ${PDUSessionResourceModifyRequest_status}    ${True}
    ${filtered_packets}=    cap.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${PDUSessionResourceModifyRequest}
    ${ngap_fiveQI}=    cap.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//ngap.fiveQI
    Should Contain    ${ngap_fiveQI}    2
    Should Not Contain    ${ngap_fiveQI}    1

    ${BearerContextModificationRequest} =    Catenate    e1ap.E1AP_PDU == 0 and e1ap.procedureCode == 9
    Log To Console    check BearerContextModificationRequest message
    ${BearerContextModificationRequest_status} =    run_keyword_and_return_status
    ...    cap.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${BearerContextModificationRequest}
    should be equal    ${BearerContextModificationRequest_status}    ${True}

    ${BearerContextModificationResponse} =    Catenate    e1ap.E1AP_PDU == 1 and e1ap.procedureCode == 9
    Log To Console    check BearerContextModificationResponse message
    ${BearerContextModificationResponse_status} =    run_keyword_and_return_status
    ...    cap.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${BearerContextModificationResponse}
    should be equal    ${BearerContextModificationResponse_status}    ${True}

    ${UEContextModificationRequest} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 7
    Log To Console    check value on UEContextModificationRequest message
    ${UEContextModificationRequest_status} =    run_keyword_and_return_status
    ...    cap.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${UEContextModificationRequest}
    should be equal    ${UEContextModificationRequest_status}    ${True}
    ${filtered_packets}=    cap.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${UEContextModificationRequest}
    ${f1ap_fiveQI}=    cap.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.fiveQI
    Should Contain    ${f1ap_fiveQI}    2
    Should Not Contain    ${f1ap_fiveQI}    1
    ${f1ap_PDCPSNLength}=    cap.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.PDCPSNLength
    Should Contain    ${f1ap_PDCPSNLength}    0

    ${UEContextModificationResponse} =    Catenate    f1ap.F1AP_PDU == 1 and f1ap.procedureCode == 7
    Log To Console    check value on UEContextModificationResponse message
    ${UEContextModificationResponse_status} =    run_keyword_and_return_status
    ...    cap.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${UEContextModificationResponse}
    should be equal    ${UEContextModificationResponse_status}    ${True}
    ${filtered_packets}=    cap.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${UEContextModificationResponse}
    ${f1ap_id}=    cap.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//f1ap.id
    Should Contain    ${f1ap_id}    39

    ${DLRRCMessageTransfer} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 12
    Log To Console    check DLRRCMessageTransfer message
    ${DLRRCMessageTransfer_status} =    run_keyword_and_return_status
    ...    cap.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${DLRRCMessageTransfer}
    should be equal    ${DLRRCMessageTransfer_status}    ${True}

    ${ULRRCMessageTransfer} =    Catenate    f1ap.F1AP_PDU == 0 and f1ap.procedureCode == 13
    Log To Console    check ULRRCMessageTransfer message
    ${ULRRCMessageTransfer_status} =    run_keyword_and_return_status
    ...    cap.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${ULRRCMessageTransfer}
    should be equal    ${ULRRCMessageTransfer_status}    ${True}

    ${PDUSessionResourceModifyResponse} =    Catenate    ngap.NGAP_PDU == 1 and ngap.procedureCode == 26
    Log To Console    check PDUSessionResourceModifyResponse
    ${PDUSessionResourceModifyResponse_status} =    run_keyword_and_return_status
    ...    cap.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${PDUSessionResourceModifyResponse}
    should be equal    ${PDUSessionResourceModifyResponse_status}    ${True}
    ${filtered_packets}=    cap.Filter Packets By Expression    pdml_list=${all_packets}
    ...    filter_expression=${PDUSessionResourceModifyResponse}
    ${ngap_qosFlowAddOrModifyResponseList} =    cap.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...    xpath=.//ngap.qosFlowAddOrModifyResponseList
    Should be equal    ${ngap_qosFlowAddOrModifyResponseList[0]}    1
    Should be equal    ${ngap_qosFlowAddOrModifyResponseList[1]}    1

UEs attach
    [Arguments]    ${gnb_index}=${0}    #${5Gstatus}=PASS    ${abil}=asp1a
    power_ue.Prepare UE    ue_type=${ue_type}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    gnb_index=${gnb_index}
    power_ue.Verify attach    ue_type=${ue_type}    gnb_index=${gnb_index}    5Grach_ed=${5Grach_ed}    4G_check=False
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${1}    gnb_index=${gnb_index}
    power_ue.Verify attach    ue_type=${ue_type}    ue_index=${1}    gnb_index=${gnb_index}    5Grach_ed=${5Grach_ed}    4G_check=False

UEs detach
    power_ue.Prepare UE    ue_type=${ue_type}
    power_ue.UE Detach    ue_type=${ue_type}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${1}
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${1}

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
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    cap.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${filter_expression}
    ${drx_onDurationTimer}=     cap.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//nr-rrc.milliSeconds
    should be equal    ${drx_onDurationTimer[0]}    ${value}

Check IE wireshark log for drx_InactivityTimer
    [Arguments]    ${logname}    ${message_filter}    ${value}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    cap.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${filter_expression}
    ${drx_InactivityTimer}=     cap.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//nr-rrc.drx_InactivityTimer
    should be equal    ${drx_InactivityTimer[0]}    ${value}

Check IE wireshark log for longDRXCycleLength
    [Arguments]    ${logname}    ${message_filter}    ${value}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    cap.Filter Packets By Expression    pdml_list=${all_packets}    filter_expression=${filter_expression}
    ${longDRXCycleLength}=     cap.Get Field Value By Xpath    pdml_list=${filtered_packets}
    ...                                                xpath=.//f1ap.longDRXCycleLength
    should be equal    ${drx_LongCycleStartOffset[0]}    ${value}

locked LTE cell
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[1]'      locked LTE cell on TL42       #38221
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[2]'      locked LTE cell on TL343      #911
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[0]'      locked LTE cell on TL367       #36721

locked LTE cell on TL343
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-1
    ...    parameter=administrativeState
    ...    value=locked
    sleep    10s

locked LTE cell on TL42
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-1
    ...    parameter=administrativeState
    ...    value=locked
    sleep    10s

locked LTE cell on TL367
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-1
    ...    parameter=administrativeState
    ...    value=locked
    sleep    10s

unlocked LTE cell
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[2]'    unlocked LTE cell on TL343    #911
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[1]'    unlocked LTE cell on TL42    #38221
    run keyword if    '${enb_instance}'=='${diffTL_enb_ID}[0]'    unlocked LTE cell on TL367    #36721

unlocked LTE cell on TL343
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-1
    ...    parameter=administrativeState
    ...    value=unlocked
    sleep    10s

unlocked LTE cell on TL42
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-1
    ...    parameter=administrativeState
    ...    value=unlocked
    sleep    10s

unlocked LTE cell on TL367
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
    [Arguments]    ${filename}     ${interface}=br1    ${connection}=enb    ${protcol}=sctp
    RUN KEYWORD AND IGNORE ERROR    enb connection
    csn.send command    command=tcpdump -i ${interface} ${protcol} -w ${enb_path}${filename}   connection=${connection}
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
    [Arguments]    ${gnb_index}=${0}    ${hw_slot}=${1}    ${connection_for_abil}=ABIL Slave
    Start TTI trace log capturing ASIB    gnb_index=${gnb_index}    hw_slot=${hw_slot}
    Stop TTI trace log capturing ASIB
    sleep     5s
    &{dict_csv_file_path}    Convert TTI trace log and download combined csv logs to test pc    local_path=${epc_log_path}
    ...    connection_for_abil=${connection_for_abil}
    Set suite variable    ${ttitrace_localpath}    ${dict_csv_file_path['DL']}

Start TTI trace log capturing ASIB
    [Arguments]    ${gnb_index}=${0}    ${hw_slot}=${1}    ${connection_for_abil}=ABIL Slave
    #Run keyword if    '${connection_for_abil}'=='${None}'
    #...    Create default connection ASIB    gnb_index=${gnb_index}    hw_slot=${hw_slot}
    #${connection_for_abil}    Set variable if    '${connection_for_abil}'=='${None}'    ${ABIL_ALIAS}    ${connection_for_abil}
    #tti.prepare_for_tti_trace_log_capturing    connection=${connection_for_abil}
    Create default connection ASIB    gnb_index=${gnb_index}    hw_slot=${hw_slot}
    tti.prepare_for_tti_trace_log_capturing    connection=${connection_for_abil}
    tti.start_tti_trace    connection=${connection_for_abil}

Stop TTI trace log capturing ASIB
    [Arguments]        ${connection_for_abil}=ABIL Slave
    tti.stop_tti_trace    connection=${connection_for_abil}

Create default connection ASIB
    [Arguments]    ${gnb_index}=${0}    ${hw_slot}=${1}    ${du_index}=${0}    ${ABIL_ALIAS}=ABIL Slave
    #${is_feature_1514_enabled}    stream_manager.Feature 1514 Enabled
    #${ABIL_ALIAS}    Set variable if     ${is_feature_1514_enabled}    ${ABIL_SLAVE_ALIAS}    ${ABIL_MASTER_ALIAS}
    #Set suite variable    ${ABIL_ALIAS}
    #Run keyword if    ${is_feature_1514_enabled}
    #...    Connect to Capacity Unit Slave with hostname    gnb_index=${gnb_index}    hw_slot=${hw_slot}
    #...                                                      alias=${ABIL_ALIAS}    du_index=${du_index}
    #...    ELSE    Connect to Capacity Unit Master with hostname    gnb_index=${gnb_index}
    #...    alias=${ABIL_ALIAS}    hw_slot=${hw_slot}    du_index=${du_index}
    Connect to Capacity Unit Slave with hostname    gnb_index=${gnb_index}    hw_slot=${hw_slot}
    ...                                                      alias=${ABIL_ALIAS}    du_index=${du_index}
TL UE detach
    [Arguments]    ${ue_index}=${0}
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

Check IE wireshark log for VONR Release
    [Arguments]    ${logname}    ${message_filter}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_nas}=     cap.Get Field Value By Xpath    xpath=.//ngap.nas    pcap_parser=test6
    should be equal    ${ngap_nas[0]}    0

Check IE wireshark log for VONR setup
    [Arguments]    ${logname}    ${message_filter}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_fiveQI}=     cap.Get Field Value By Xpath    xpath=.//ngap.fiveQI    pcap_parser=test6
    should be equal    ${ngap_fiveQI[0]}    1

Check IE wireshark log for RLF
    [Arguments]    ${logname}    ${message_filter}
    ${all_packets}=    cap.Load Pcap File    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}     alias=test6
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    cap.Filter Packets By Expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${f1ap_cause}=     cap.Get Field Value By Xpath    xpath=.//f1ap.radioNetwork    pcap_parser=test6
    should be equal    ${f1ap_cause[0]}    12

Check IE wireshark log for VONR attach
    [Arguments]    ${logname}    ${message_filter}    ${message_filter1}    ${value}   ${value1}
    Check IE wireshark log for VONR attach_5QI5    logname=${logname}    message_filter=${message_filter}     value=${value}
    Check IE wireshark log for VONR attach_5QI7    logname=${logname}    message_filter=${message_filter1}    value=${value1}

Check IE wireshark log for VONR attach_5QI5
    [Arguments]     ${logname}    ${message_filter}    ${value}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_fiveQI}=     cap.get_field_value_by_xpath    xpath=.//ngap.fiveQI    pcap_parser=test6
    should be equal    ${ngap_fiveQI[0]}    ${value}

Check IE wireshark log for VONR attach_5QI7
    [Arguments]     ${logname}    ${message_filter}    ${value}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${ngap_fiveQI}=     cap.get_field_value_by_xpath    xpath=.//ngap.fiveQI    pcap_parser=test6
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
    [Arguments]    ${logname}    ${message_filter}    ${index}=${index}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}    pcap_parser=test6
    @{frame_time}=     cap.get_field_value_by_xpath    xpath=.//frame.time_epoch     pcap_parser=test6
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

lock gnb1 cell2
    Lock_gnb2_Cell    url=${WEBUI_COAM}    cell_id=2    bts_host=${asik_addr}

unlock gnb1 cell2
    unLock_gnb2_Cell    url=${WEBUI_COAM}    cell_id=2    bts_host=${asik_addr}

lock gnb1 cell1
    Lock_gnb2_Cell    url=${WEBUI_COAM}    cell_id=1    bts_host=${asik_addr}

Check IE wireshark log for CDRX config
    [Arguments]    ${logname}    ${message_filter}    ${value1}    ${value2}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}    pcap_parser=test6
    #${drx_onDurationTimer}=     cap.get_field_value_by_xpath   pdml_list=${filtered_packets}
    #...                                                xpath=.//nr-rrc.milliSeconds
    #should be equal    ${drx_onDurationTimer[0]}    ${value1}
    ${drx_InactivityTimer}=     cap.get_field_value_by_xpath   xpath=.//nr-rrc.drx_InactivityTimer    pcap_parser=test6
    should be equal    ${drx_InactivityTimer[0]}    ${value1}
    ${drx_LongCycleStartOffset}=     cap.get_field_value_by_xpath   xpath=.//nr-rrc.drx_LongCycleStartOffset   pcap_parser=test6
    should be equal    ${drx_LongCycleStartOffset[0]}    ${value2}

Check IE wireshark log for discardtimer config
    [Arguments]    ${logname}    ${message_filter}    ${value}
    ${all_packets}=    cap.load_pcap_file    pcap_file=${epc_log_path}${logname}    command_template=${command_template_with_Y}    alias=test6
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    cap.filter_packets_by_expression    filter_expression=${filter_expression}    pcap_parser=test6
    ${discard_Timer}=     cap.get_field_value_by_xpath   xpath=.//nr-rrc.discardTimer    pcap_parser=test6
    should be equal    ${discard_Timer[0]}    ${value}

add attenuation for 1db
    [Arguments]    ${port1}    ${port2}    ${origin_value}    ${target_value}
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    att.set_attenuation     port=${port1}    value=${origin_value}
    att.set_attenuation     port=${port2}    value=${origin_value}
    FOR    ${origin_value}    IN RANGE    ${target_value}
         ${origin_value}    evaluate     ${origin_value}+1
         att.set_attenuation     port=${port1}    value=${origin_value}
         att.set_attenuation     port=${port2}    value=${origin_value}
         sleep    1s
    END

Check PM counter Result
    [Arguments]    ${counter_id}    ${dic_path}    ${gnb_index}=${0}    ${counter_increase}=True    ${timeout}=${300}
    ${counter_value}    Check PM counter from webui    counter_id=${counter_id}    full_path=${dic_path}    gnb_index=${gnb_index}
    ...    timeout=${timeout}
    ${counter_sum}    Sum the list value    ${counter_value}
    Run keyword if    "${counter_increase}" == "True"    should be true    ${counter_sum} >= ${1}
    ...    ELSE    should be true     ${counter_sum} == ${0}
    [Return]    ${counter_sum}

Check PM counter from webui
    [Arguments]    ${counter_id}    ${full_path}    ${gnb_index}=${0}    ${date}=all    ${timeout}=${300}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ${counter_value} =    get_pm_counter_values    counter_id=${counter_id}    connection=GNB_OAM
    ...    dic_path=${full_path}    date=${date}    timeout=${timeout}
    [Return]    ${counter_value}
    [Teardown]    COAM Teardown gnb connections

Sum the list value
    [Arguments]    ${counter_result}
    ${length}    Get Length    ${counter_result}
    ${sum_result}    set variable    ${0}
    FOR    ${i}    IN RANGE    ${length}
        ${sum_result}    Evaluate    ${sum_result} + ${counter_result[${i}]}
    END
    [Return]      ${sum_result}

Record the counter action timer
    @{utc0} =    Get Time    hour min sec    UTC
    ${utc0_min} =    convert to integer  ${utc0}[1]
    ${utc_min} =    Evaluate    ${utc0_min}%15
    ${utc_left} =    Evaluate    15-${utc_min}+1
    set global variable    ${utc_left}
    sleep    ${utc_left} min

Get gnb release info
    ${release_info}    Get sagnb release
    set suite variable    ${release_info}
