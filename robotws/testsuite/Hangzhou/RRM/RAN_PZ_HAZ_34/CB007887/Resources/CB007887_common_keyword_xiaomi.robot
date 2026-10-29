*** Settings ***
Documentation     author: qingqing,zhang
...                 contact: qingqing.zhang@nokia-sbell.com
...                 squad group: SG_03
...                 feature : 5GC000784

Library           OperatingSystem
Library           Collections
Library           taf.transport.ssh    WITH NAME    csn
Library           taf.config.scf    WITH NAME    scf
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Library           taf.ul.oam.selenium_coam    WITH NAME    selenium_coam
Library           taf.ul.oam.selenium_megazone    WITH NAME    selenium_megazone
Resource          taf/rfrl/common_resources/robot/connections.robot
Resource          taf/rfrl/common_resources/robot/gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Library           taf.sbts.oam.coam.admin   WITH NAME    coam
Library    taf.analyzer.pcap   WITH NAME    parser
Library           taf.hw.rf_attenuator    WITH NAME    attenuator
#Library           sigspark.SigSpark    WITH NAME    spark
Library           taf.ue.plugin.mtk
Library           taf.ul.messaging.mtk      WITH NAME    mtk
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot

*** Variables ***
${ue_type}    xiaomi
${gnb_instance}    ${tl.gnbs[0].instance_id}
${imsi_mcc}    ${tl.core.mcc}
${imsi_mnc}    ${tl.core.mnc}
${LOCAL_MASTER_IP}    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${PEER_MASTER_IP}     ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_NAME}         ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}          ${tl.gnbs[0].cu.oam_http_connection_details.password}
${WEBUI_COAM}     https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_COAM2}    https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_COAM_LOCAL}    https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${distname_id_1}      MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}
${distname_id_2}      MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}
${LOG_PATH}    /opt/workspace/CIT/Master/Case_Logs/
${TS_LOG_PATH_BASE}    /opt/workspace/CIT/Master/Case_Logs/
${tshark_path}      /usr/bin/tshark
${LUA_SCRIPT_PATH}          /opt/workspace/CIT/Master/luashark/generated_luashark/luashark.lua
${command_template_Y}       {tshark_path} -r {pcap_file} -Y  \"ngap or f1ap\"  -T pdml
${command_template_S1}       {tshark_path} -r {pcap_file} -Y  \"s1ap\"  -T pdml
${command_template_Y_xnap}       {tshark_path} -r {pcap_file} -Y  \"ngap or f1ap or xnap\"  -T pdml
${gnb_path}                 /tmp/
${enb_path}                 /tmp/
${tl_scf_dir_path}    /opt/workspace/CRT/Master/SCF_file/
${enb_BTS}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${enb_instance}    ${tl.enbs[0].instance_id}
${enbx2_dist0}               MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNADJGNB-0
${enbx2_dist1}               MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNADJGNB-1
${enbx2_dist2}               MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNADJGNB-2
${enbx2_dist3}               MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNADJGNB-3
${enbx2_para}               administrativeState
#${asp_1a_addr}      fd5f:4268:2387:a881:40:43ff:fe80:101
${asp_1a_addr}          ${tl.gnbs[0].cu.f1m.v6}
${asp_1a_username}    ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${asp_1a_password}    ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${att_atten_port}              ${tl.attenuator[0].port}
${vendor}                    ${tl.attenuator[0].vendor}
${att_atten_ip_attenuator1}    ${tl.attenuator[1].ip_addr}
${max_attenuation_value}     ${127}
${max_attenuation_value_topyoung}     ${120}
${att_atten_ip}    ${tl.attenuator[0].ip_addr}
${att_port_1_376}                ${tl.attenuator[0].attenuator_ports[9]}
${att_port_2_376}                ${tl.attenuator[0].attenuator_ports[10]}
${att_port_3_376}                ${tl.attenuator[0].attenuator_ports[11]}
${att_port_4_376}                ${tl.attenuator[0].attenuator_ports[12]}
${att_port_5_376}                ${tl.attenuator[0].attenuator_ports[13]}
${att_port_6_376}                ${tl.attenuator[0].attenuator_ports[14]}
${att_port_7_376}                ${tl.attenuator[0].attenuator_ports[15]}
${att_port_8_376}                ${tl.attenuator[0].attenuator_ports[16]}
${att_port_1_388}                ${tl.attenuator[0].attenuator_ports[1]}
${att_port_2_388}                ${tl.attenuator[0].attenuator_ports[2]}
${att_port_3_388}                ${tl.attenuator[0].attenuator_ports[3]}
${att_port_4_388}                ${tl.attenuator[0].attenuator_ports[4]}
${att_port_5_388}                ${tl.attenuator[0].attenuator_ports[5]}
${att_port_6_388}                ${tl.attenuator[0].attenuator_ports[6]}
${att_port_7_388}                ${tl.attenuator[0].attenuator_ports[7]}
${att_port_8_388}                ${tl.attenuator[0].attenuator_ports[8]}
${att_port_ru2_1_388}                ${tl.attenuator[1].attenuator_ports[1]}
${att_port_ru2_2_388}                ${tl.attenuator[1].attenuator_ports[2]}
${att_port_ru2_3_388}                ${tl.attenuator[1].attenuator_ports[3]}
${att_port_ru2_4_388}                ${tl.attenuator[1].attenuator_ports[4]}
${att_port_1_377}                ${tl.attenuator[0].attenuator_ports[1]}
${att_port_2_377}                ${tl.attenuator[0].attenuator_ports[2]}
${att_port_3_377}                ${tl.attenuator[0].attenuator_ports[3]}
${att_port_4_377}                ${tl.attenuator[0].attenuator_ports[4]}
${att_port_5_377}                ${tl.attenuator[0].attenuator_ports[5]}
${att_port_6_377}                ${tl.attenuator[0].attenuator_ports[6]}
${att_port_7_377}                ${tl.attenuator[0].attenuator_ports[7]}
${att_port_8_377}                ${tl.attenuator[0].attenuator_ports[8]}
${att_port_ru2_1_377}                ${tl.attenuator[1].attenuator_ports[5]}
${att_port_ru2_2_377}                ${tl.attenuator[1].attenuator_ports[6]}
${att_port_ru2_3_377}                ${tl.attenuator[1].attenuator_ports[7]}
${att_port_ru2_4_377}                ${tl.attenuator[1].attenuator_ports[8]}
@{gnb_id}    376    37711    38811
${att_good}    ${0}
${att_bad}    ${127}
${target_cellID_344}    378
${target_cellID_341}    61
${target_cellID_242}    322
${ui_version}=    petrus
${SIM1}    SIM 1 - MAIN
${SIM2}    SIM 2 - SUB
${DL_TIME}                  600
${DL_LENGTH}                1024B
${UL_TIME}                  600
${UL_LENGTH}                1024B
${PROGRAM}                  20A
${UL_PORT}                  ${tl.ues[0].iperf_details.ssh_connection_details.port}
${DL_PORT}                  ${tl.ues[0].iperf_details.port}
@{counter_dic_path_A07}    BTS/BTS/NRBTS-${gnb_instance}/MCC-${imsi_mcc}_MNC-${imsi_mnc}/SST-1_SD-13714341/NSL
...    BTS/BTS/NRBTS-${gnb_instance}/MCC-${imsi_mcc}_MNC-${imsi_mnc}/SST-128_SD-1/NSL
...    BTS/BTS/NRBTS-${gnb_instance}/MCC-${imsi_mcc}_MNC-${imsi_mnc}/SST-255_SD-1/NSL

*** Keywords ***
Common Suite Setup for COAM
    COAM Create log directory    is_set_to_test_case_level=${False}
    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
    Set Suite Variable    ${epc_log_path}    ${LOG_PATH}/${time_stamp}/
    Create directory    ${epc_log_path}

Prepare with COAM classical two BTS cell onair
    Prepare with COAM classical BTS2 cell onair     scf_filename=${tl_scf_filename2}    gnb_index=${1}
    Prepare with COAM classical BTS2 cell onair     scf_filename=${tl_scf_filename}    gnb_index=${0}

Prepare with COAM classical BTS2 cell onair
    [Arguments]    ${scf_filename}=${tl_scf_filename}    ${gnb_index}=${0}
    Perform full commission for COAM gnb2    scf_filename=${scf_filename}    gnb_index=${gnb_index}
    Check the gnb2 RU status ready    gnb_index=${gnb_index}
    Check the gnb2 cell status onair    gnb_index=${gnb_index}

Perform full commission for COAM gnb2
    [Arguments]    ${scf_filename}    ${is_pdl_checking_needed}=${False}    ${gnb_index}=${0}
    Connect to gnb coam via ssl   connection=GNB_OAM    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
#    COAM Update several parameters via rest api    parameters_to_update_via_api=${PARAMETERS_TO_administrativeState}
#    Reboot gNB locally    gnb_index=${0}
#    sleep    360s
    COAM Commission with scf file    scf_file_path=${tl_scf_dir_path}${scf_filename}
    ...    is_pdl_checking_needed=${is_pdl_checking_needed}
    [Teardown]    COAM Teardown gnb connections

Perform full commission for COAM enb BTS
    [Arguments]    ${enb_BTS}=${enb_BTS}    ${scf_file_path_enb}=${tl_scf_dir_path}${tl_scf_filename_enb}
    Connect to gnb coam via ssl    connection=enblte    bts_host=${enb_BTS}
    COAM Commission with scf file    scf_file_path=${scf_file_path_enb}    timeout=600    connection=enblte
    [Teardown]    COAM Teardown gnb connections    connection=enblte

Check the enb cell status onair
    [Arguments]    ${enb_BTS}=${enb_BTS}
    Connect to gnb coam via ssl    connection=enblte    bts_host=${enb_BTS}
    wait until keyword succeeds    5min   30s    COAM Check GNB cell on air    connection=enblte
    [Teardown]    COAM Teardown gnb connections    connection=enblte

### PA adjust ###
Adjust gNB_RU Attenuation
    [Arguments]    ${value1}=${att_good}    ${value2}=${att_bad}    ${value3}=${att_bad}
    Run Keyword If    '${gnb_instance}'=='${gnb_id[0]}'
    ...    Adjust the tl HBTE1 attenuation value    tl=${376}    value1=${value1}    value2=${value2}
    ...    ELSE IF    '${gnb_instance}'=='${gnb_id[2]}'    Run keywords
    ...    Adjust the tl HBTE1 attenuation value    tl=${388}    value1=${value1}    value2=${value2}    AND
    ...    Adjust the tl HBTE2 attenuation value    tl=${388}    value3=${value3}
    ...    ELSE    Run keywords
    ...    Adjust the tl HBTE1 attenuation value    tl=${377}    value1=${value1}    value2=${value2}    AND
    ...    Adjust the tl HBTE2 attenuation value    tl=${377}    value3=${value3}

Adjust the tl HBTE1 attenuation value
    [Arguments]     ${tl}=${tl}    ${value1}=${0}    ${value2}=${127}
    @{att_ports_gnb1_cell1}    Create List    ${att_port_1_${tl}}    ${att_port_2_${tl}}
    ...    ${att_port_3_${tl}}    ${att_port_4_${tl}}
    @{values_gnb1_cell1}    Create List    ${value1}    ${value1}    ${value1}    ${value1}
    Adjust the HBTE attenuation value    att_ports=${att_ports_gnb1_cell1}    values=${values_gnb1_cell1}
    ...    att_connection_port=${att_port_1_${tl}}

    @{att_ports_gnb2_cell1}    Create List    ${att_port_5_${tl}}    ${att_port_6_${tl}}
    ...    ${att_port_7_${tl}}    ${att_port_8_${tl}}
    @{values_gnb2_cell1}    Create List    ${value2}    ${value2}    ${value2}    ${value2}
    Adjust the HBTE attenuation value    att_ports=${att_ports_gnb2_cell1}    values=${values_gnb2_cell1}
    ...    att_connection_port=${att_port_5_${tl}}

Adjust the tl HBTE2 attenuation value
    [Arguments]     ${tl}=${tl}    ${value3}=${127}
    @{att_ports_gnb1_cell2}    Create List    ${att_port_ru2_1_${tl}}    ${att_port_ru2_2_${tl}}
    ...    ${att_port_ru2_3_${tl}}    ${att_port_ru2_4_${tl}}
    @{values_gnb1_cell2}    Create List    ${value3}    ${value3}    ${value3}    ${value3}
    Adjust the HBTE attenuation value    att_ports=${att_ports_gnb1_cell2}    values=${values_gnb1_cell2}
    ...    att_connection_port=${att_port_ru2_1_${tl}}    att_atten_ip=${att_atten_ip_attenuator1}

Adjust the HBTE attenuation value
    [Arguments]    ${att_ports}    ${values}    ${att_connection_port}=${att_connection_port}
    ...    ${att_atten_ip}=${att_atten_ip}
    [Documentation]    This keyword is to set the test environment PA values.
    ...    ${att_port}:List all the attenuator ports as int list
    ...    ${value}:List the value of attenuator ports  int list
    attenuator.setup_attenuator    ip_addr=${att_atten_ip}    port=${att_atten_port}
    ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    ${Num_att_port}=    get length    ${att_ports}
    FOR    ${Num}    IN RANGE    ${0}    ${Num_att_port}
        attenuator.set_attenuation     port=${att_ports[${Num}]}    value=${values[${Num}]}
        sleep    1s
        ${value_port}    attenuator.read_attenuation    port=${att_ports[${Num}]}
        ${value_port}=    Convert To Integer    ${value_port}
        should be equal    ${value_port}    ${values[${Num}]}
    END

Check the gnb2 RU status ready
    [Arguments]    ${gnb_index}=${0}
    Connect to gnb coam via ssl   connection=GNB_OAM    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    wait until keyword succeeds    10min   30s    COAM Check GNB RU status
    [Teardown]    COAM Teardown gnb connections

Check the gnb2 cell status onair
    [Arguments]    ${gnb_index}=${0}
    Connect to gnb coam via ssl   connection=GNB_OAM    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    wait until keyword succeeds    10min   30s    COAM Check GNB cell on air
    [Teardown]    COAM Teardown gnb connections

Modify NIDD parameter on gnb
    [Arguments]    ${parameters_to_update}    ${gnb_index}=${0}
    Connect to gnb coam via ssl   connection=GNB_OAM    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters_to_update}    timeout=${600}
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

Online add parmeters
    [Arguments]    ${parameters_to_update}    ${gnb_index}=${0}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    COAM add several parameters via rest api    parameters_to_update_via_api=${parameters_to_update}
    sleep    5
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

Online delete parmeters
    [Arguments]    ${parameters_to_update}    ${gnb_index}=${0}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    COAM delete parameters via rest api    parameters_to_delete_via_api=${parameters_to_update}
    sleep    5
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

check value of parameter algorithm
    [Arguments]    ${value1}=9    ${value2}=0    ${value3}=0
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM_LOCAL}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error
    ...    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${algorithm_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}
    ${nea1_128_value}=    selenium_coam.get_parameter_value    dist_name=${algorithm_distname}
    ...    filter_param=SNOW 3G-based algorithm    abbr=nea1_128
    ${return1}=    Run Keyword And Return Status    Should Be Equal    ${nea1_128_value}    ${value1}
    Run Keyword If    '${return1}' == 'True'    sleep    0.5s
    Run Keyword If    '${return1}' == 'False'    set value of parameter algorithm
    ...    filter_param=SNOW 3G-based algorithm
    ...    abbr=nea1_128    new_value=${value1}
    ${nea2_128_value}=    selenium_coam.get_parameter_value    dist_name=${algorithm_distname}
    ...    filter_param=AES-based algorithm    abbr=nea2_128
    ${return2}=    Run Keyword And Return Status    Should Be Equal    ${nea2_128_value}    ${value2}
    Run Keyword If    '${return2}' == 'True'    sleep    0.5s
    Run Keyword If    '${return2}' == 'False'    set value of parameter algorithm    filter_param=AES-based algorithm
    ...    abbr=nea2_128    new_value=${value2}
    ${nea3_128_value}=    selenium_coam.get_parameter_value    dist_name=${algorithm_distname}
    ...    filter_param=ZUC-based algorithm    abbr=nea3_128
    ${return3}=    Run Keyword And Return Status    Should Be Equal    ${nea3_128_value}    ${value3}
    Run Keyword If    '${return3}' == 'True'    sleep    0.5s
    Run Keyword If    '${return3}' == 'False'    set value of parameter algorithm    filter_param=ZUC-based algorithm
    ...    abbr=nea3_128    new_value=${value3}
    selenium_coam.logout
    selenium_coam.disable_virtual_display

set value of parameter algorithm
    [Arguments]    ${filter_param}    ${abbr}    ${new_value}
    selenium_coam.set_parameter_value  dist_name=${algorithm_distname}
    ...    filter_param=${filter_param}
    ...    abbr=${abbr}    new_value=${new_value}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    8s

Tests Recover
    Tear down wireshark log and detach
    eNB stop wireshark log_teardown
    Online add parmeters    parameters_to_update=${PARAMETERS_TO_UPDATE_slice_SNSSAI3}    gnb_index=${1}
    power_ue.Stop traffic    ue_type=xiaomi     direction=dl    iperf_port=${dl_port}
    Tear down the connections

Tear down wireshark log and detach
    run keywords
    ...    run keyword and ignore error    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname1}
    ...    gnb_index=${0}    AND    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${0}

Tear down the connections
    Run keyword and ignore error    coam_gnb_classical.COAM Teardown gnb connections
    Run keyword and ignore error    csn.Disconnect    connection=enb
    Run keyword and ignore error    csn.Disconnect    connection=gnb
    Run keyword and ignore error    csn.Disconnect    connection=ASIK Master
    Run keyword and ignore error    csn.Disconnect    connection=BB1

Common Suite Teardown for COAM
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...    username=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    COAM Download scf from cluster    scf_dir_path=${epc_log_path}
#    COAM Save snapshot via rest api    log_path=${epc_log_path}
    [Teardown]    COAM Teardown gnb connections

remove object NRADJGNB and XNLINK
    [Arguments]    ${index}=1    ${WEBUI_COAM}=${WEBUI_COAM}    ${index2}=1
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    ${bts_id}   selenium_coam.get_bts_id
    Set Suite Variable    ${NRADJGNB_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/NRADJGNB-${index}
    Set Suite Variable    ${XNLINK_distname}    MRBTS-${bts_id}/NRBTS-${bts_id}/XNLINK-${index2}
    selenium_coam.remove_object  object_name=${NRADJGNB_distname}
    selenium_coam.remove_object  object_name=${XNLINK_distname}
    sleep    3s
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    sleep    8s
    selenium_coam.logout
    selenium_coam.disable_virtual_display

##BIPlog##
Check SIB1 contain emergency from BIP log
    [Arguments]    ${biplog}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${biplog}   tshark_path=${tshark_path}
    ...    luashark_path=${LUA_SCRIPT_PATH}    command_template=${None}
    ${filter_expression}=    Catenate    nr-rrc
    ${filtered_packets}=    parser.filter_packets_by_expression
    ...    filter_expression=${filter_expression}
    ${ims-emergencysupport}=    parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//nr-rrc.ims_EmergencySupport
    should contain    ${ims-emergencysupport}    0

Check SIB1 not contain emergency from BIP log
    [Arguments]    ${biplog}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${biplog}   tshark_path=${tshark_path}
    ...    luashark_path=${LUA_SCRIPT_PATH}    command_template=${None}
    ${filter_expression}=    Catenate    nr-rrc
    ${filtered_packets}=    parser.filter_packets_by_expression
    ...    filter_expression=${filter_expression}
    ${ims-emergencysupport}=    parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//nr-rrc.ims_EmergencySupport
    should be empty    ${ims-emergencysupport}

bip capture and check SIB1 contain emergency from BIP log
   [Arguments]    ${biplog}    ${bip_time}=${1}
    bip capture on ABIO and download to UTE    biplog=${biplog}    interface=eth1    bip_time=${3}    connection=Local_gnb2
    Check SIB1 contain emergency from BIP log    biplog=${biplog}

bip capture on ABIO and download to UTE
    [Arguments]     ${biplog}    ${interface}    ${connection}    ${bip_time}=${1}
    gNB connections to ssh    connection=${connection}    gnb_index=${0}
    Connect to ABIO    proxy=${connection}    asik_slave=ABIO
    csn.send command    command=dbgnac set port 1 loop e t    connection=ABIO
    csn.send command    command=dbgnac mirror sport 12 dport 1 e b    connection=ABIO
    csn.send command    command=dbgnac mirror sport 16 dport 1 e b    connection=ABIO
    csn.send command    command=dbgnac mirror sport 1 dport 20 e b    connection=ABIO
    csn.send command    command=ifconfig ${interface} up    connection=ABIO
    csn.send command    command=tcpdump -i ${interface} -w ${gnb_path}${biplog} -vv    connection=ABIO
    sleep    ${bip_time}s
    csn.send command    command=killall tcpdump     connection=ABIO
    sleep    5s
    csn.send command    command=mv ${gnb_path}${biplog} /ffs/run/config/toor4nsn/     connection=ABIO
    csn.download_file   remote_path=/ffs/run/config/toor4nsn/${biplog}   local_path=${epc_log_path}${biplog}   connection=ABIO
    [Teardown]    csn.disconnect    connection=${connection}


Connect to ABIO
    [Arguments]    ${asik_slave}=${asik_slave}    ${proxy}=ASIK
    csn.Connect to    hostname=${asp_1a_addr}    username=${asp_1a_username}
    ...    password=${asp_1a_password}    alias=${asik_slave}    proxy=${proxy}

bip capture and check SIB1 not contain emergency from BIP log
    [Arguments]    ${biplog}    ${bip_time}
    bip capture on ABIO and download to UTE    biplog=${biplog}    interface=eth1    bip_time=${3}    connection=Local_gnb2
    Check SIB1 not contain emergency from BIP log        biplog=${biplog}

### UE ###
Get all xiaomi11 pointer variable for 376
    Set Suite Variable    ${home}    3
    Set Suite Variable    ${airplane}    1265 2095
    Set Suite Variable    ${close_task}    710 2766
    Set Suite Variable    ${Home_button}    3
    Set Suite Variable    ${swipe}    1300 2700 1300 2700
    Set Suite Variable    ${open_iperf_location}    500 2050
    Set Suite Variable    ${iperf_button}    730 300
    Set Suite Variable    ${iperf_space}    800 550
    Set Suite Variable    ${5G}    900 960

Get all xiaomi11 pointer variable for 377
    Set Suite Variable    ${home}    3
    Set Suite Variable    ${airplane}    1245 1878
    Set Suite Variable    ${close_task}    717 2920
    Set Suite Variable    ${Home_button}    3
    Set Suite Variable    ${swipe}    1300 2700 1300 2700
    Set Suite Variable    ${open_iperf_location}    500 2050
    Set Suite Variable    ${iperf_button}    730 300
    Set Suite Variable    ${iperf_space}    800 550
    Set Suite Variable    ${5G}    900 960

Get all xiaomi11 pointer variable for 388
    Set Suite Variable    ${home}    3
    Set Suite Variable    ${airplane}    1251 2208
    Set Suite Variable    ${close_task}    710 2766
    Set Suite Variable    ${Home_button}    3
    Set Suite Variable    ${swipe}    1300 2700 1300 2700
    Set Suite Variable    ${open_iperf_location}    500 2050
    Set Suite Variable    ${iperf_button}    730 300
    Set Suite Variable    ${iperf_space}    800 550
    Set Suite Variable    ${5G}    900 960

Power UE Precondition
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    capatibility_index=${0}    reset_sol=none    detach_request=${true}
    run keyword if    '${gnb_instance}'=='${gnb_id[0]}'    Get all xiaomi11 pointer variable for 376
    ...    ELSE IF    '${gnb_instance}'=='${gnb_id[1]}'    Get all xiaomi11 pointer variable for 377
    ...    ELSE    Get all xiaomi11 pointer variable for 388

Power UE Attach and Verify attach
    [Arguments]    ${4g_check}=False    ${gnb_index}=${0}
    unlock the screen and close all task    ue_index=${0}
     ${5Grach_ed}    power_ue.UE Attach    ue_type=xiaomi    ue_index=${0}    gnb_index=${gnb_index}
#    sleep    30s
    power_ue.Verify attach    ue_type=xiaomi    5Grach_ed=${5Grach_ed}    ue_index=${0}    gnb_index=${gnb_index}
    ...                       4G_check=${4g_check}    5Gstatus=PASS

unlock the screen and close all task
    [Documentation]   Check UE if need awake
    [Arguments]   ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}   ${connection}=cpc_${ue_index}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}
    csn.send_command   connection=${connection}
    ...   command=adb -s ${serial_number} shell dumpsys window | grep -E \"mAwake|isStatusBarKeyguard|mShowingLockscreen\"
    sleep   2s
    ${output}   csn.read_output   connection=${connection}
    Run Keyword If   ${output.lower().count('mawake=false')}>0
    ...   csn.send_command   command=adb -s ${serial_number} shell input keyevent 26   connection=${connection}
    sleep    1s
    csn.send_command   command=adb -s ${serial_number} shell input swipe 347 2514 715 400    connection=${connection}
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 3    connection=${connection}
    sleep   2s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 187    connection=${connection}
    sleep   4s
    #####Turn off all running tasks on the phone#####
    csn.send_command    command=adb -s ${serial_number} shell input tap ${close_task}    connection=${connection}

Start a emergency call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=911
    ...    ${connection}=cygwin${ue_index}
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.DIAL -d tel:${phone_number}
    ...    connection=cygwin${ue_index}
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input tap 720 2897
    ...    connection=cygwin${ue_index}

Stop the emergency call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=911
    ...    ${connection}=cygwin${ue_index}
    csn.send_command    command=adb -s ${serial_number} shell input tap 724 2783
    ...    connection=cygwin${ue_index}
    sleep    10s

Stop the VONR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=911
    ...    ${connection}=cygwin${ue_index}
    csn.send_command    command=adb -s ${serial_number} shell input tap 724 2783
    ...    connection=cygwin${ue_index}
    sleep    3s

Expect MTK Attach Messages
    ${Attach Expected Messages} =    Create List     5GMM_REGISTRATION_ACCEPT
    mtk.Expect Messages in Flow    awaited_messages=${Attach Expected Messages}    flow_alias=MTK_OTA_MESSAGE

Modify UE mobile data
    [Arguments]    ${ue_index}=${0}    ${action}=disable    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=adb${ue_index}
    csn.send_command    command=adb -s ${serial_number} shell svc data ${action}    connection=adb${ue_index}
    sleep    2s
    [Teardown]    csn.disconnect      connection=adb${ue_index}

Make a emergency call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=911
    android.setup    ui_version=${ui_version}    host=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}
    ...    serial_number=${serial_number}   alias=cygwin${ue_index}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=adb${ue_index}
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 82
    ...    connection=adb${ue_index}
    sleep   2s
    android.start_emergency_call    number=${phone_number}    mobile=cygwin${ue_index}
    sleep    45s
    android.stop_emergency_call    mobile=cygwin${ue_index}
    sleep    30s
    [Teardown]    run keywords
    ...    run keyword and ignore error    android.teardown    mobile=cygwin${ue_index}    AND
    ...    run keyword and ignore error    csn.disconnect      connection=adb${ue_index}

Start a VoNR call
    [Arguments]    ${to}=911    ${ue_index}=${0}    ${vc_alias}=test_voice_call
    start_voice_call    vc_alias=${vc_alias}    ue_alias=UE_${ue_index}    to=${to}
    Sleep    10s

make another emergency call and check it success
    [Arguments]     ${nglogname}    ${interface}    ${gnb_index}    ${ue_index}
    Start Capture Wireshark Logs on gNB    nglogname=${nglogname}    interface=${interface}    gnb_index=${gnb_index}
    Make a emergency call    ue_index=${ue_index}
    Stop Capture Wireshark Logs on gNB    nglogname=${nglogname}    gnb_index=${gnb_index}
    Check wireshark log for successful EC procedure    logname=${nglogname}


### log analyze ###
Start Capture Wireshark Logs on gNB
    [Arguments]     ${nglogname}    ${interface}    ${gnb_index}=${0}
    gNB connections to ssh    connection=gnb${gnb_index}    gnb_index=${gnb_index}
    csn.send command    command=tcpdump -i ${interface} sctp -w ${gnb_path}/${nglogname}   connection=gnb${gnb_index}
    sleep    3s
    [Teardown]    csn.disconnect    connection=gnb${gnb_index}

Stop Capture Wireshark Logs on gNB
    [Arguments]    ${nglogname}    ${gnb_index}=${0}
    gNB connections to ssh    connection=gnb${gnb_index}    gnb_index=${gnb_index}
    sleep    5s
    csn.send command    command=killall tcpdump     connection=gnb${gnb_index}
    sleep    3s
    csn.download_file   remote_path=${gnb_path}/${nglogname}   local_path=${epc_log_path}${nglogname}
    ...    connection=gnb${gnb_index}
    sleep    3s
    [Teardown]    csn.disconnect    connection=gnb${gnb_index}

gNB connections to ssh
    [Arguments]    ${connection}    ${gnb_index}=${0}
    csn.Connect To    hostname=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...               username=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}
    ...               password=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.password}
    ...               alias=${connection}

enb connection
    [Arguments]    ${alias}=enb
    csn.Connect To    hostname=${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
    ...               username=${tl.enbs[0].airscale.common_units[0].lmp_connection.username}
    ...               password=${tl.enbs[0].airscale.common_units[0].lmp_connection.password}
    ...               alias=enb

eNB start capture wireshark log
    [Arguments]    ${filename}     ${interface}=any    ${connection}=enb
    RUN KEYWORD AND IGNORE ERROR    enb connection
    csn.send command    command=tcpdump -i ${interface} -w ${enb_path}${filename}   connection=${connection}
    sleep    3s

eNB stop and Save classical Logs
    [Arguments]    ${filename}    ${connection}=enb
    enb connection
    csn.send command    command=killall tcpdump     connection=${connection}
    sleep    3s
    csn.download_file   remote_path=${enb_path}${filename}   local_path=${epc_log_path}${filename}
    ...    connection=${connection}
    sleep    3s
    csn.disconnect      connection=${connection}

eNB stop wireshark log_teardown
    [Arguments]    ${connection}=enb
    enb connection
    csn.send command    command=killall tcpdump     connection=${connection}
    sleep    3s
    csn.disconnect      connection=${connection}


### check wireshark log ###
Check wireshark log for VoNR
    [Arguments]    ${logname}    ${message_filter}    ${xpath_filter}    ${expect_value}    ${attribute_name}=show
    ...    ${command_template}=${command_template_Y}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ...    command_template=${command_template}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    parser.filter_packets_by_expression
    ...    filter_expression=${filter_expression}
    ${filtered_value}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//${xpath_filter}
    ...    attribute_name=${attribute_name}
    should be equal    ${filtered_value[0]}    ${expect_value}

Get filtered value
    [Arguments]    ${logname}    ${message_filter}    ${xpath_filter}    ${attribute_name}=show
    ...    ${command_template}=${command_template_Y}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ...    command_template=${command_template}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    parser.filter_packets_by_expression
    ...    filter_expression=${filter_expression}
    ${filtered_value}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//${xpath_filter}
    ...    attribute_name=${attribute_name}
    [Return]    ${filtered_value}

Check wireshark log for intra-F intra-gNB HO
    [Arguments]    ${logname}    ${target_cellID}
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=f1ap.procedureCode == 7 and nr-rrc.measResultNeighCellListNR == 1
    ...    xpath_filter=.//nr-rrc.MeasResultNR_element/nr-rrc.physCellId    expect_value=${target_cellID}

Check wireshark log for data service
    [Arguments]    ${logname}
    ${pduseeion_id_normal}    Get filtered value    logname=${logname}
    ...    message_filter=ngap.fiveQI == 5 and ngap.priorityLevelARP == 5    xpath_filter=ngap.pDUSessionID
    ${pduseeion_id_date}    Get filtered value    logname=${logname}
    ...    message_filter=ngap.fiveQI == 7 and ngap.priorityLevelARP == 7
    ...    xpath_filter=ngap.pDUSessionID
    ${pduseeion_id_release_verify}    Get filtered value    logname=${logname}
    ...    message_filter=ngap.procedureCode == 30    xpath_filter=ngap.pDUSessionID
    ${pduseeion_id_release_cause}    Get filtered value    logname=${logname}
    ...    message_filter=ngap.procedureCode == 30    xpath_filter=ngap.radioNetwork
    Should contain    ${pduseeion_id_release_verify}    ${pduseeion_id_normal[0]}
    Should contain    ${pduseeion_id_release_verify}    ${pduseeion_id_date[0]}
    FOR    ${index}    IN RANGE    ${2}
        Should be equal    ${pduseeion_id_release_cause[${index}]}    39
    END

Check wireshark log for support slice by registration
    [Arguments]    ${logname}
    ${slice_SST}    Get filtered value    logname=${logname}
    ...    message_filter=ngap.procedureCode == 15
    ...    xpath_filter=nas_5gs.mm.sst
    ${slice_SD}    Get filtered value    logname=${logname}
    ...    message_filter=ngap.procedureCode == 15
    ...    xpath_filter=nas_5gs.mm.mm_sd
    ${slice_SST_1}    Get Slice From List    ${slice_SST}    0    3
    ${slice_SD_1}    Get Slice From List    ${slice_SD}    0    3
    Sort List    ${slice_SST_1}
    Should be equal    ${slice_SST_1[0]}    1
    Should be equal    ${slice_SST_1[1]}    128
    Should be equal    ${slice_SST_1[2]}    255
    Should be equal    ${slice_SD_1[0]}    13714341
    Should be equal    ${slice_SD_1[1]}    1
    Should be equal    ${slice_SD_1[2]}    1

Check wireshark log for 5QI5 slice by attach
    [Arguments]    ${logname}
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=ngap.fiveQI == 5 and ngap.priorityLevelARP == 5
    ...    xpath_filter=ngap.fiveQI    expect_value=5
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=ngap.fiveQI == 5 and ngap.priorityLevelARP == 5
    ...    xpath_filter=ngap.priorityLevelARP    expect_value=5
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=ngap.fiveQI == 5 and ngap.priorityLevelARP == 5
    ...    xpath_filter=ngap.sST    expect_value=ff
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=ngap.fiveQI == 5 and ngap.priorityLevelARP == 5
    ...    xpath_filter=ngap.sD    expect_value=00:00:01

Check wireshark log for 5QI7 slice by attach for trunk
    [Arguments]    ${logname}
#    Check wireshark log for VoNR    logname=${logname}
#    ...    message_filter=ngap.fiveQI == 7 and ngap.priorityLevelARP == 7 and nas_5gs.cmn.dnn == wap1.nokia.com
#    ...    xpath_filter=ngap.sST    expect_value=80
#    Check wireshark log for VoNR    logname=${logname}
#    ...    message_filter=ngap.fiveQI == 7 and ngap.priorityLevelARP == 7 and nas_5gs.cmn.dnn == wap1.nokia.com
#    ...    xpath_filter=ngap.sD    expect_value=00:00:01
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=ngap.fiveQI == 7 and ngap.priorityLevelARP == 7 and ngap.procedureCode == 14
    ...    xpath_filter=ngap.sST    expect_value=80
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=ngap.fiveQI == 7 and ngap.priorityLevelARP == 7 and ngap.procedureCode == 14
    ...    xpath_filter=ngap.sD    expect_value=00:00:01

Check wireshark log for 5QI7 slice by attach
    [Arguments]    ${logname}
#    Check wireshark log for VoNR    logname=${logname}
#    ...    message_filter=ngap.fiveQI == 7 and ngap.priorityLevelARP == 7 and nas_5gs.cmn.dnn == wap1.nokia.com
#    ...    xpath_filter=ngap.sST    expect_value=80
#    Check wireshark log for VoNR    logname=${logname}
#    ...    message_filter=ngap.fiveQI == 7 and ngap.priorityLevelARP == 7 and nas_5gs.cmn.dnn == wap1.nokia.com
#    ...    xpath_filter=ngap.sD    expect_value=00:00:01
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=ngap.fiveQI == 7 and ngap.priorityLevelARP == 7 and ngap.sST
    ...    xpath_filter=ngap.sST    expect_value=80
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=ngap.fiveQI == 7 and ngap.priorityLevelARP == 7 and ngap.sD
    ...    xpath_filter=ngap.sD    expect_value=00:00:01

Check wireshark log for VONR 5QI 1
    [Arguments]    ${logname}
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=ngap.procedureCode == 26 and ngap.fiveQI == 1
    ...    xpath_filter=ngap.fiveQI    expect_value=1
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=ngap.procedureCode == 26 and ngap.priorityLevelARP == 3
    ...    xpath_filter=ngap.priorityLevelARP    expect_value=3

Check wireshark log for EC 5QI 1
    [Arguments]    ${logname}
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=ngap.procedureCode == 26 and ngap.fiveQI == 1
    ...    xpath_filter=ngap.fiveQI    expect_value=1
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=ngap.procedureCode == 26 and ngap.priorityLevelARP == 1
    ...    xpath_filter=ngap.priorityLevelARP    expect_value=1

Check wireshark log for EC 5QI 5
    [Arguments]    ${logname}
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=ngap.procedureCode == 29 and ngap.fiveQI == 5
    ...    xpath_filter=ngap.fiveQI    expect_value=5
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=ngap.procedureCode == 29 and ngap.priorityLevelARP == 1
    ...    xpath_filter=ngap.priorityLevelARP    expect_value=1

Check wireshark log for EC setup
    [Arguments]    ${logname}
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=ngap.procedureCode == 46 and nas_5gs.mm.req_typ == 3
    ...    xpath_filter=nas_5gs.mm.req_typ    expect_value=3

Check wireshark log for 5QI5 slice by EC
    [Arguments]    ${logname}
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=ngap.procedureCode == 29 and ngap.fiveQI == 5
    ...    xpath_filter=ngap.fiveQI    expect_value=5
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=ngap.procedureCode == 29 and ngap.priorityLevelARP == 1
    ...    xpath_filter=ngap.priorityLevelARP    expect_value=1
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=ngap.procedureCode == 29 and ngap.priorityLevelARP == 1
    ...    xpath_filter=ngap.sST    expect_value=01
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=ngap.procedureCode == 29 and ngap.priorityLevelARP == 1
    ...    xpath_filter=ngap.sD    expect_value=d1:43:a5

Check wireshark log for EC release
    [Arguments]    ${logname}
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=ngap.procedureCode == 26 and ngap.nas == 0
    ...    xpath_filter=ngap.nas    expect_value=0

Check wireshark log for nomal EC release
    [Arguments]    ${logname}
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=ngap.procedureCode == 28 and ngap.nas == 0
    ...    xpath_filter=ngap.nas    expect_value=0
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=ngap.procedureCode == 28
    ...    xpath_filter=ngap.PDUSessionResourceReleaseResponse_element
    ...    expect_value=PDUSessionResourceReleaseResponse
    ...    attribute_name=showname

Check wireshark log for EC unrelease
    [Arguments]    ${logname}   ${attribute_name}=show
    ${pdu_release_pdu_id}    Get filtered value    logname=${logname}    command_template=${command_template_Y_xnap}
    ...    message_filter=ngap.procedureCode == 28 and ngap.nas == 0
    ...    xpath_filter=ngap.pDUSessionID
    Should Not Contain    ${pdu_release_pdu_id}    3

Check wireshark log for EC UEContextreleasecommand
    [Arguments]    ${logname}
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=ngap.procedureCode == 41 and ngap.radioNetwork == 41
    ...    xpath_filter=ngap.radioNetwork    expect_value=41

Check wireshark log for EC UEContextreleasecomplete
    [Arguments]    ${logname}
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=f1ap.procedureCode == 6
    ...    xpath_filter=f1ap.UEContextReleaseComplete_element
    ...    expect_value=UEContextReleaseComplete
    ...    attribute_name=showname

#Check inter-F inter-gNB intra-PLMN HO with EC and data service
#    run keyword if    '${release_info}'=='SBTS22R2_ENB_9999'
#    ...    Check inter-F inter-gNB intra-PLMN HO with EC and data service for trunk    ELSE
#    ...    Check inter-F inter-gNB intra-PLMN HO with EC and data service for other

Check inter-F inter-gNB intra-PLMN HO with EC and data service
    [Arguments]    ${logname_source}    ${logname_target}
    Check wireshark log for support slice by registration    logname=${logname_source}
    Check wireshark log for 5QI5 slice by attach    logname=${logname_source}
    Check wireshark log for 5QI7 slice by attach    logname=${logname_source}
    Check wireshark log for 5QI5 slice by EC    logname=${logname_source}
    Check wireshark log for EC 5QI 1    logname=${logname_source}
    log to console    check inter gnb HO procedure
    Check wireshark log for inter gnb HO with EC    logname1=${logname_source}    logname2=${logname_target}
    log to console    check EC ongoing
    Check wireshark log for EC UEContextreleasecomplete    logname=${logname_source}
    Check wireshark log for EC unrelease   logname=${logname_target}

Check intra-F intra-gNB intra-PLMN HO with EC and data service
    [Arguments]    ${logname_source}
    Check wireshark log for support slice by registration    logname=${logname_source}
    Check wireshark log for 5QI5 slice by attach    logname=${logname_source}
    Check wireshark log for 5QI7 slice by attach    logname=${logname_source}
    Check wireshark log for 5QI5 slice by EC    logname=${logname_source}
    Check wireshark log for EC 5QI 1    logname=${logname_source}
    log to console    check intra-gNB procedure
    Check wireshark log for intra gnb HO with EC    logname1=${logname_source}
    log to console    check EC ongoing
    Check wireshark log for EC not release unusual    logname=${logname_source}
    Check wireshark log for EC unrelease   logname=${logname_source}

Check HO with EC and data service with pduHoSliceRelease false
    [Arguments]    ${logname_source}    ${logname_target}
    Check wireshark log for support slice by registration    logname=${logname_source}
    Check wireshark log for 5QI5 slice by attach    logname=${logname_source}
    Check wireshark log for 5QI7 slice by attach    logname=${logname_source}
    Check wireshark log for 5QI5 slice by EC    logname=${logname_source}
    Check wireshark log for EC 5QI 1    logname=${logname_source}
    Check wireshark log for HO failure   logname=${logname_target}
    Check wireshark log for EC unrelease   logname=${logname_source}

Check wireshark log for HO failure
    [Arguments]    ${logname}
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=xnap.procedureCode == 0
    ...    xpath_filter=xnap.HandoverPreparationFailure_element
    ...    expect_value=HandoverPreparationFailure
    ...    attribute_name=showname
    ...    command_template=${command_template_Y_xnap}
    Check wireshark log for HO failure cause    logname=${logname}
    ...    message_filter=xnap.procedureCode == 0
    ...    xpath_filter=xnap.radioNetwork    expect_value=45
    ...    command_template=${command_template_Y_xnap}

Check wireshark log for HO failure cause
    [Arguments]    ${logname}    ${message_filter}    ${xpath_filter}    ${expect_value}    ${attribute_name}=show
    ...    ${command_template}=${command_template_Y}
#    ${all_packets}=    parser.load_pcap_file    pcap_file=/opt/workspace/CIT/Master/Case_Logs/${logname}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ...    command_template=${command_template}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    parser.filter_packets_by_expression
    ...    filter_expression=${filter_expression}
    ${filtered_value}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//${xpath_filter}
    ...    attribute_name=${attribute_name}
    should contain    ${filtered_value}    ${expect_value}

Check wireshark log for VONR unrelease
    [Arguments]    ${logname}   ${attribute_name}=show
    ${pdu_release_pdu_id}    Get filtered value    logname=${logname}    command_template=${command_template_Y_xnap}
    ...    message_filter=ngap.procedureCode == 28 and ngap.nas == 0
    ...    xpath_filter=ngap.pDUSessionID
    run keyword if    '${release}'=='SBTS22R3_ENB_9999'    Should Not Contain    ${pdu_release_pdu_id}   2
    ...    ELSE    Should Not Contain    ${pdu_release_pdu_id}   1

Check inter-F inter-gNB intra-PLMN HO with VONR and data service
    [Arguments]    ${logname_source}    ${logname_target}
    Check wireshark log for support slice by registration    logname=${logname_source}
    Check wireshark log for 5QI5 slice by attach    logname=${logname_source}
    Check wireshark log for 5QI7 slice by attach    logname=${logname_source}
    Check wireshark log for VONR 5QI 1    logname=${logname_source}
    log to console    check inter gnb HO procedure
    Check wireshark log for inter gnb HO with VONR    logname1=${logname_source}    logname2=${logname_target}
    log to console    check VONR ongoing
    Check wireshark log for VONR unrelease    logname=${logname_target}

Check wireshark log for inter gnb HO with VONR
    [Arguments]    ${logname1}    ${logname2}
    run keyword if    '${release}'=='SBTS22R3_ENB_9999'
    ...    Check wireshark log for inter gnb HO with VONR for trunk    logname1=${logname1}    logname2=${logname2}
    ...    ELSE    Check wireshark log for inter gnb HO with VONR for other    logname1=${logname1}    logname2=${logname2}

Check wireshark log for inter gnb HO with VONR for other
    [Arguments]    ${logname1}    ${logname2}    ${attribute_name}=show
    ...    ${command_template}=${command_template_Y_xnap}
    ...    ${message_filter1}=ngap.fiveQI == 5 and ngap.priorityLevelARP == 5
    ...    ${message_filter2}=ngap.fiveQI == 7 and ngap.priorityLevelARP == 7 and ngap.procedureCode == 29
    ...    ${message_filter3}=ngap.procedureCode == 26 and ngap.fiveQI == 1 and ngap.priorityLevelARP ==3
    ...    ${message_filter_service}=xnap.procedureCode == 0 and xnap.XnAP_PDU == 1
    ...    ${message_filter_target}=xnap.procedureCode == 0 and xnap.XnAP_PDU == 1
    log to console    check service gnb HO procedure
    ${all_packets1}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname1}
#    ${all_packets1}=    parser.load_pcap_file    pcap_file=/opt/workspace/CIT/Master/Case_Logs/${logname1}
    ...    command_template=${command_template}
    ${filter_expression1}=    Catenate    ${message_filter1}
    ${filter_expression2}=    Catenate    ${message_filter2}
    ${filter_expression3}=    Catenate    ${message_filter3}
    ${filter_expression_service}=    Catenate    ${message_filter_service}
    ${filtered_packets1}=    parser.filter_packets_by_expression
    ...    filter_expression=${filter_expression1}
    ${filtered_packets2}=    parser.filter_packets_by_expression
    ...    filter_expression=${filter_expression2}
    ${filtered_packets3}=    parser.filter_packets_by_expression
    ...    filter_expression=${filter_expression3}
    ${filtered_packets_service}=    parser.filter_packets_by_expression
    ...    filter_expression=${filter_expression_service}
    ${filtered_value_pdu}    Create List
    FOR    ${index}    IN    1    2
        ${filtered_value}=    parser.get_field_value_by_xpath    pdml_list=${filtered_packets${index}}
        ...    xpath=.//ngap.pDUSessionID
        append to list    ${filtered_value_pdu}    ${filtered_value[0]}
    END
    ${filtered_value_pdu_service}=    parser.get_field_value_by_xpath    pdml_list=${filtered_packets_service}
    ...    xpath=.//xnap.pduSessionId
    FOR    ${index}    IN RANGE    ${2}
        Should be equal    ${filtered_value_pdu_service[${index}]}    ${filtered_value_pdu[${index}]}
    END
    log to console    check target gnb HO for slice
    ${pduseeion_id_admin}    Get filtered value    logname=${logname2}    command_template=${command_template_Y_xnap}
    ...    message_filter=xnap.procedureCode == 0 and xnap.XnAP_PDU == 1
    ...    xpath_filter=xnap.PDUSessionResourcesAdmitted_Item_element/xnap.pduSessionId
    Should be equal    ${filtered_value_pdu[0]}    ${pduseeion_id_admin[0]}
    ${pduseeion_id_not_admin_target}    Get filtered value    logname=${logname2}    command_template=${command_template_Y_xnap}
    ...    message_filter=xnap.procedureCode == 0 and xnap.XnAP_PDU == 1
    ...    xpath_filter=xnap.PDUSessionResourcesNotAdmitted_Item_element/xnap.pduSessionId
    ${pduseeion_id_not_admin_cause}    Get filtered value    logname=${logname2}    command_template=${command_template_Y_xnap}
    ...    message_filter=xnap.procedureCode == 0
    ...    xpath_filter=xnap.PDUSessionResourcesNotAdmitted_Item_element/xnap.cause/xnap.radioNetwork
    Should be equal    ${filtered_value_pdu[1]}    ${pduseeion_id_not_admin_target[0]}
    Should be equal    ${pduseeion_id_not_admin_cause[0]}    45

Check wireshark log for inter gnb HO with VONR for trunk
    [Arguments]    ${logname1}    ${logname2}    ${attribute_name}=show
    ...    ${command_template}=${command_template_Y_xnap}
    ...    ${message_filter1}=ngap.fiveQI == 5 and ngap.priorityLevelARP == 5
    ...    ${message_filter2}=ngap.fiveQI == 7 and ngap.priorityLevelARP == 7 and ngap.procedureCode == 14
    ...    ${message_filter3}=ngap.procedureCode == 26 and ngap.fiveQI == 1 and ngap.priorityLevelARP ==3
    ...    ${message_filter_service}=xnap.procedureCode == 0 and xnap.XnAP_PDU == 1
    ...    ${message_filter_target}=xnap.procedureCode == 0 and xnap.XnAP_PDU == 1
    log to console    check service gnb HO procedure
    ${all_packets1}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname1}
#    ${all_packets1}=    parser.load_pcap_file    pcap_file=/opt/workspace/CIT/Master/Case_Logs/${logname1}
    ...    command_template=${command_template}
    ${filter_expression1}=    Catenate    ${message_filter1}
    ${filter_expression2}=    Catenate    ${message_filter2}
    ${filter_expression3}=    Catenate    ${message_filter3}
    ${filter_expression_service}=    Catenate    ${message_filter_service}
    ${filtered_packets1}=    parser.filter_packets_by_expression
    ...    filter_expression=${filter_expression1}
    ${filtered_packets2}=    parser.filter_packets_by_expression
    ...    filter_expression=${filter_expression2}
    ${filtered_packets3}=    parser.filter_packets_by_expression
    ...    filter_expression=${filter_expression3}
    ${filtered_packets_service}=    parser.filter_packets_by_expression
    ...    filter_expression=${filter_expression_service}
    ${filtered_value_pdu}    Create List
    FOR    ${index}    IN    1    2
        ${filtered_value}=    parser.get_field_value_by_xpath    pdml_list=${filtered_packets${index}}
        ...    xpath=.//ngap.pDUSessionID
        append to list    ${filtered_value_pdu}    ${filtered_value[0]}
    END
    ${filtered_value_pdu_service}=    parser.get_field_value_by_xpath    pdml_list=${filtered_packets_service}
    ...    xpath=.//xnap.pduSessionId
    FOR    ${index}    IN RANGE    ${2}
        Should be equal    ${filtered_value_pdu_service[${index}]}    ${filtered_value_pdu[${index}]}
    END
    log to console    check target gnb HO for slice
    ${pduseeion_id_admin}    Get filtered value    logname=${logname2}    command_template=${command_template_Y_xnap}
    ...    message_filter=xnap.procedureCode == 0 and xnap.XnAP_PDU == 1
    ...    xpath_filter=xnap.PDUSessionResourcesAdmitted_Item_element/xnap.pduSessionId
    Should be equal    ${filtered_value_pdu[0]}    ${pduseeion_id_admin[0]}
    ${pduseeion_id_not_admin_target}    Get filtered value    logname=${logname2}    command_template=${command_template_Y_xnap}
    ...    message_filter=xnap.procedureCode == 0 and xnap.XnAP_PDU == 1
    ...    xpath_filter=xnap.PDUSessionResourcesNotAdmitted_Item_element/xnap.pduSessionId
    ${pduseeion_id_not_admin_cause}    Get filtered value    logname=${logname2}    command_template=${command_template_Y_xnap}
    ...    message_filter=xnap.procedureCode == 0
    ...    xpath_filter=xnap.PDUSessionResourcesNotAdmitted_Item_element/xnap.cause/xnap.radioNetwork
    Should be equal    ${filtered_value_pdu[1]}    ${pduseeion_id_not_admin_target[0]}
    Should be equal    ${pduseeion_id_not_admin_cause[0]}    45

Check wireshark log for inter gnb HO with EC
    [Arguments]    ${logname1}    ${logname2}    ${attribute_name}=show
    ...    ${command_template}=${command_template_Y_xnap}
    ${5QI5_nomal_pdu_id}    Get filtered value    logname=${logname1}    command_template=${command_template_Y_xnap}
    ...    message_filter=ngap.fiveQI == 5 and ngap.priorityLevelARP == 5
    ...    xpath_filter=ngap.pDUSessionID
    ${5QI7_date_pdu_id}    Get filtered value    logname=${logname1}    command_template=${command_template_Y_xnap}
    ...    message_filter=ngap.fiveQI == 7 and ngap.priorityLevelARP == 7
    ...    xpath_filter=ngap.pDUSessionID
    ${5QI5_EC_pdu_id}    Get filtered value    logname=${logname1}    command_template=${command_template_Y_xnap}
    ...    message_filter=ngap.procedureCode == 29 and ngap.fiveQI == 5 and ngap.priorityLevelARP ==1
    ...    xpath_filter=ngap.pDUSessionID
    log to console    check target gnb HO for slice
    ${pduseeion_id_admit}    Get filtered value    logname=${logname2}    command_template=${command_template_Y_xnap}
    ...    message_filter=xnap.procedureCode == 0 and xnap.XnAP_PDU == 1
    ...    xpath_filter=xnap.PDUSessionResourcesAdmitted_Item_element/xnap.pduSessionId
    Should be equal    ${5QI5_EC_pdu_id[0]}    ${pduseeion_id_admit[0]}
    ${pduseeion_id_not_admit_target}    Get filtered value    logname=${logname2}    command_template=${command_template_Y_xnap}
    ...    message_filter=xnap.procedureCode == 0 and xnap.XnAP_PDU == 1
    ...    xpath_filter=xnap.PDUSessionResourcesNotAdmitted_Item_element/xnap.pduSessionId
    ${pduseeion_id_not_admit_cause}    Get filtered value    logname=${logname2}    command_template=${command_template_Y_xnap}
    ...    message_filter=xnap.procedureCode == 0
    ...    xpath_filter=xnap.PDUSessionResourcesNotAdmitted_Item_element/xnap.cause/xnap.radioNetwork
     Should contain    ${pduseeion_id_not_admit_target}    ${5QI5_nomal_pdu_id[0]}
     Should contain    ${pduseeion_id_not_admit_target}    ${5QI7_date_pdu_id[0]}
     Should be equal    ${pduseeion_id_not_admit_cause[0]}    45
     Should be equal    ${pduseeion_id_not_admit_cause[1]}    45

Check wireshark log for intra gnb HO with EC
    [Arguments]    ${logname1}    ${attribute_name}=show
    ...    ${command_template}=${command_template_Y_xnap}
    @{5QI7_nomal_drb_id}    Get filtered value    logname=${logname1}    command_template=${command_template_Y_xnap}
    ...    message_filter=(f1ap.fiveQI == 7 || f1ap.fiveQI == 5) and f1ap.procedureCode == 5
    ...    xpath_filter=f1ap.dRBID
    @{5QI5_nomal_and_EC_drb_id}    Get filtered value    logname=${logname1}    command_template=${command_template_Y_xnap}
    ...    message_filter=(f1ap.fiveQI == 7 || f1ap.fiveQI == 5) and f1ap.procedureCode == 7
    ...    xpath_filter=f1ap.dRBID
    @{5QI1_EC_drb_id}    Get filtered value    logname=${logname1}    command_template=${command_template_Y_xnap}
    ...    message_filter=f1ap.fiveQI == 1 and f1ap.procedureCode == 7
    ...    xpath_filter=f1ap.dRBID
    ${drb_get_all}    Create List    ${5QI7_nomal_drb_id[0]}    ${5QI5_nomal_and_EC_drb_id[0]}
    ...    ${5QI5_nomal_and_EC_drb_id[1]}    ${5QI1_EC_drb_id[0]}
    Sort list     ${drb_get_all}
    ${drb}    Create List    4    5    6    7
    Should be equal    ${drb_get_all}    ${drb}
    log to console    check target cell for slice
    @{drb_id_target_cell}    Get filtered value    logname=${logname1}    command_template=${command_template_Y_xnap}
    ...    message_filter=f1ap.procedureCode == 7 and f1ap.id == 21
    ...    xpath_filter=f1ap.dRBID
    Should be equal    ${drb_id_target_cell}    ${drb_get_all[2:]}
    @{drb_id_target_cell_release}    Get filtered value    logname=${logname1}    command_template=${command_template_Y_xnap}
    ...    message_filter=f1ap.procedureCode == 7 and f1ap.id == 33
    ...    xpath_filter=f1ap.dRBID
    Should be equal    ${drb_id_target_cell_release[2:]}    ${drb_get_all[:2]}
    ${pduseeion_id_not_admin_cause}    Get filtered value    logname=${logname1}    command_template=${command_template_Y_xnap}
    ...    message_filter=ngap.procedureCode == 30
    ...    xpath_filter=ngap.radioNetwork
     Should be equal    ${pduseeion_id_not_admin_cause[0]}    39
     Should be equal    ${pduseeion_id_not_admin_cause[1]}    39

Check wireshark log for EC release on source
    [Arguments]    ${logname}
    Check wireshark log for EC setup    logname=${logname}
    Check wireshark log for EC 5QI 5    logname=${logname}
    Check wireshark log for EC 5QI 1    logname=${logname}
    Check wireshark log for EC UEContextreleasecomplete    logname=${logname}

Check wireshark log for EC not release unusual
    [Arguments]    ${logname}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ...    command_template=${command_template_Y}
    ${filter_expression}=     Catenate    ngap.procedureCode == 42
    ${filtered_packets}=    parser.filter_packets_by_expression
    ...    filter_expression=${filter_expression}
    ${filtered_value}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//ngap.UEContextReleaseRequest_element    attribute_name=showname
    should be empty    ${filtered_value}

Check PM counter for per slice
    [Arguments]    ${counter_id_send}    ${counter_id_NOTI}    ${full_path}
    ${PM_counter_send_slice1}    Get PM counter Result for case    counter_id=${counter_id_send}
    ...    full_path=${full_path[0]}
    should be equal      ${PM_counter_send_slice1[-1]}    ${1}
    ${PM_counter_NOTI_slice1}    Get PM counter Result for case    counter_id=${counter_id_NOTI}
    ...    full_path=${full_path[0]}
    should be equal       ${PM_counter_NOTI_slice1[-1]}    ${0}
    ${PM_counter_send_slice2}    Get PM counter Result for case    counter_id=${counter_id_send}
    ...    full_path=${full_path[1]}
    should be equal       ${PM_counter_send_slice2[-1]}    ${1}
    ${PM_counter_NOTI_slice2}    Get PM counter Result for case    counter_id=${counter_id_NOTI}
    ...    full_path=${full_path[1]}
    should be equal       ${PM_counter_NOTI_slice2[-1]}    ${1}
    ${PM_counter_send_slice3}    Get PM counter Result for case    counter_id=${counter_id_send}
    ...    full_path=${full_path[2]}
    should be equal       ${PM_counter_send_slice3[-1]}    ${1}
    ${PM_counter_NOTI_slice3}    Get PM counter Result for case    counter_id=${counter_id_NOTI}
    ...    full_path=${full_path[2]}
    should be equal      ${PM_counter_NOTI_slice3[-1]}    ${1}

Get PM counter Result for case
    [Arguments]    ${counter_id}    ${full_path}
    ${PM_counter}    Check PM counter with sort list    counter_id=${counter_id}
    ...    full_path=${full_path}
    [Return]    ${PM_counter}

Check PM counter with sort list
    [Arguments]    ${counter_id}    ${full_path}    ${date}=all
    Connect to gnb coam via ssl   connection=GNB_OAM    bts_host=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ${result} =    get_pm_counter_values    counter_id=${counter_id}    connection=GNB_OAM
    ...    dic_path=${full_path}    date=${date}
    Sort list    ${result}
    [Return]    ${result}
    [Teardown]    COAM Teardown gnb connections

Record the counter action timer
    @{utc0} =    Get Time    hour min sec    UTC
    ${utc0_min} =    convert to integer  ${utc0}[1]
    ${utc_min} =    Evaluate    ${utc0_min}%5
    Run Keyword If    ${utc_min}>3.5    Record time again
    ${utc_left} =    Evaluate    5-${utc_min}+1
    set test variable    ${utc_left}

Record time again
    sleep    1min
    @{utc0} =    Get Time    hour min sec    UTC
    ${utc0_min} =    convert to integer  ${utc0}[1]
    ${utc_min} =    Evaluate    ${utc0_min}%5
    Set Suite Variable    ${utc_min}

Get sagnb release
    [Arguments]   ${host}=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...    ${username}=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...    ${password}=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    csn.Connect To   hostname=${host}   username=${username}   password=${password}   alias=release_info
    ${info}   csn.Execute    command=ls /ffs/run/TargetBD*xml   connection=release_info
#    ${release_info}     set variable    ${info.split('_')[1]}
    ${release_info}    set variable    ${info.split('_')[1]}_${info.split('_')[2]}_${info.split('_')[3]}
    [Return]    ${release_info}
    [Teardown]   csn.Disconnect   connection=release_info

Get release info
    ${release_info}    Get sagnb release
    Set Suite Variable    ${release}    ${release_info}
### data service ###

Power UE Start dl traffic and check throughput
    [Arguments]    ${dl_throughput}    ${Expect_DOWNLINK}    ${duration}=${DL_TIME}    ${dl_length}=${DL_LENGTH}    ${dl_port}=${DL_PORT}
    ...    ${ue_index}=${0}    ${gnb_index}=${0}    ${cellid}=1
    ${nrcellid}    COAM Get nrcellid with lcrid    lcrid=${cellid}    gnb_index=${gnb_index}
    power_ue.Start traffic    ue_type=xiaomi    direction=dl    throughput=${dl_throughput}    duration=${duration}
    ...                       iperf_port=${dl_port}    ue_index=${0}    cap_index=${0}    buffer_size=${dl_length}
    sleep    15s
    wait until keyword succeeds    2min    10s    power_ue.Check throughput    ue_type=xiaomi    direction=dl    throughput=${Expect_DOWNLINK}
    ...    ue_index=${ue_index}    hw_slot=1    sample=${10}    start_offset=${3}    sleep_time=${5}    cellid=${nrcellid}    gnb_index=${gnb_index}

Power UE Start ul traffic and check throughput
        [Arguments]    ${ul_throughput}    ${Expect_DOWNLINK}    ${duration}=${UL_TIME}    ${ul_length}=${UL_LENGTH}    ${ul_port}=${UL_PORT}
    ...    ${ue_index}=${0}    ${gnb_index}=${0}    ${cellid}=1
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_throughput}    duration=${duration}
    ...                       iperf_port=${ul_port}    ue_index=${0}    cap_index=${0}    buffer_size=${ul_length}
    sleep    5s
    ${nrcellid}    COAM Get nrcellid with lcrid    lcrid=${cellid}    gnb_index=${gnb_index}
    wait until keyword succeeds    2min    10s    power_ue.Check throughput    ue_type=${ue_type}    direction=ul    throughput=${Expect_DOWNLINK}
    ...    ue_index=${ue_index}    hw_slot=1    sample=${10}    start_offset=${3}    sleep_time=${5}    cellid=${nrcellid}    gnb_index=${gnb_index}

Check the cell DL throughput and stop traffic
    [Arguments]    ${cellid}=1    ${gnb_index}=${0}    ${Expect_DOWNLINK}=-1
    ...    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ${nrcellid}    COAM Get nrcellid with lcrid    lcrid=${cellid}    gnb_index=${gnb_index}
    Wait Until Keyword Succeeds   3x    10s    power_ue.Check Throughput    sample=${6}    gnb_index=${gnb_index}
    ...    ue_type=${ue_type}    direction=dl    throughput=${Expect_DOWNLINK}    cellid=${nrcellid}    sleep_time=${20}
    power_ue.Stop traffic    ue_type=${ue_type}     direction=dl    iperf_port=${dl_port}
    sleep    3s
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}


COAM Get nrcellid with lcrid
    [Arguments]   ${lcrid}    ${gnb_index}=${0}    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    Connect to gnb coam via ssl   bts_host=${bts_host}
    ${cell_info}   coam.get_subcells_info   timeout=20    connection=GNB_OAM
    ${number_of_cell_group_info}    get length    ${cell_info}
    FOR  ${index}  IN RANGE   ${number_of_cell_group_info}
        ${cell_from_cellgrp}    Get from Dictionary    ${cell_info}    NRCELLGRP-${index}
        ${nrCellId}    Get nrcellid in all cellgroup with lcrid    cell_from_cellgrp=${cell_from_cellgrp}    lcrid=${lcrid}
        exit for loop if    '${nrCellId}'!='None'
    END
    [Return]    ${nrCellId}
    [Teardown]    COAM Teardown gnb connections

Get nrcellid in all cellgroup with lcrid
    [Arguments]   ${cell_from_cellgrp}    ${lcrid}
    ${cell_list}    Get Dictionary Keys    ${cell_from_cellgrp}
    FOR  ${cell}  IN   @{cell_list}
        ${eachcell}    Get from Dictionary    ${cell_from_cellgrp}    ${cell}
        ${lcrid_get} =    set variable    ${eachcell['NRCELL_L']['parameters']['lcrId']}
        ${nrCellIdentity}     run keyword if     '${lcrid_get}'=='${lcrid}'
    ...    set variable    ${eachcell['NRCELL_L']['parameters']['nrCellIdentity']}
    END
    [Return]    ${nrCellIdentity}
