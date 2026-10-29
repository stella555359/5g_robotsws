*** Settings ***
Documentation     author: yifan hu
...                 contact: yifan.hu@nokia-sbell.com
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
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Atten.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/UE.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Collect_logs.robot

*** Variables ***
${ue_type}    ${tl.ues[0].capabilities[0]}
${gnb_instance}    ${tl.gnbs[0].instance_id}
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
${command_template_Y}       {tshark_path} -r {pcap_file} -Y  \"(ngap or f1ap)\"  -T pdml
${command_template_S1}       {tshark_path} -r {pcap_file} -Y  \"s1ap\"  -T pdml
${command_template_Y_xnap}       {tshark_path} -r {pcap_file} -Y  \"ngap or xnap\"  -T pdml
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

${att_port_1_gnb1_cell1_37611}                ${tl.attenuator[0].attenuator_ports[9]}
${att_port_2_gnb1_cell1_37611}                ${tl.attenuator[0].attenuator_ports[10]}
${att_port_3_gnb1_cell1_37611}                ${tl.attenuator[0].attenuator_ports[11]}
${att_port_4_gnb1_cell1_37611}                ${tl.attenuator[0].attenuator_ports[12]}
${att_port_1_gnb1_cell2_37611}                ${tl.attenuator[1].attenuator_ports[9]}
${att_port_2_gnb1_cell2_37611}                ${tl.attenuator[1].attenuator_ports[10]}
${att_port_3_gnb1_cell2_37611}                ${tl.attenuator[1].attenuator_ports[11]}
${att_port_4_gnb1_cell2_37611}                ${tl.attenuator[1].attenuator_ports[12]}
${att_port_1_gnb2_cell1_37611}                ${tl.attenuator[0].attenuator_ports[13]}
${att_port_2_gnb2_cell1_37611}                ${tl.attenuator[0].attenuator_ports[14]}
${att_port_3_gnb2_cell1_37611}                ${tl.attenuator[0].attenuator_ports[15]}
${att_port_4_gnb2_cell1_37611}                ${tl.attenuator[0].attenuator_ports[16]}
${att_port_1_gnb2_cell2_37611}                ${tl.attenuator[1].attenuator_ports[13]}
${att_port_2_gnb2_cell2_37611}                ${tl.attenuator[1].attenuator_ports[14]}
${att_port_3_gnb2_cell2_37611}                ${tl.attenuator[1].attenuator_ports[15]}
${att_port_4_gnb2_cell2_37611}                ${tl.attenuator[1].attenuator_ports[16]}
${att_ipaddr_gnb1_cell1_37611}                ${tl.attenuator[0].ip_addr}
${att_ipaddr_gnb1_cell2_37611}                ${tl.attenuator[1].ip_addr}
${att_ipaddr_gnb2_cell1_37611}                ${tl.attenuator[0].ip_addr}
${att_ipaddr_gnb2_cell2_37611}                ${tl.attenuator[1].ip_addr}

${att_port_1_gnb1_cell1_37711}                ${tl.attenuator[0].attenuator_ports[1]}
${att_port_2_gnb1_cell1_37711}                ${tl.attenuator[0].attenuator_ports[2]}
${att_port_3_gnb1_cell1_37711}                ${tl.attenuator[0].attenuator_ports[3]}
${att_port_4_gnb1_cell1_37711}                ${tl.attenuator[0].attenuator_ports[4]}
${att_port_1_gnb1_cell2_37711}                ${tl.attenuator[1].attenuator_ports[5]}
${att_port_2_gnb1_cell2_37711}                ${tl.attenuator[1].attenuator_ports[6]}
${att_port_3_gnb1_cell2_37711}                ${tl.attenuator[1].attenuator_ports[7]}
${att_port_4_gnb1_cell2_37711}                ${tl.attenuator[1].attenuator_ports[8]}
${att_port_1_gnb2_cell1_37711}                ${tl.attenuator[0].attenuator_ports[5]}
${att_port_2_gnb2_cell1_37711}                ${tl.attenuator[0].attenuator_ports[6]}
${att_port_3_gnb2_cell1_37711}                ${tl.attenuator[0].attenuator_ports[7]}
${att_port_4_gnb2_cell1_37711}                ${tl.attenuator[0].attenuator_ports[8]}
${att_ipaddr_gnb1_cell1_37711}                ${tl.attenuator[0].ip_addr}
${att_ipaddr_gnb1_cell2_37711}                ${tl.attenuator[1].ip_addr}
${att_ipaddr_gnb2_cell1_37711}                ${tl.attenuator[0].ip_addr}

${att_port_1_gnb1_cell1_38811}                ${tl.attenuator[0].attenuator_ports[1]}
${att_port_2_gnb1_cell1_38811}                ${tl.attenuator[0].attenuator_ports[2]}
${att_port_3_gnb1_cell1_38811}                ${tl.attenuator[0].attenuator_ports[3]}
${att_port_4_gnb1_cell1_38811}                ${tl.attenuator[0].attenuator_ports[4]}
${att_port_1_gnb1_cell2_38811}                ${tl.attenuator[1].attenuator_ports[1]}
${att_port_2_gnb1_cell2_38811}                ${tl.attenuator[1].attenuator_ports[2]}
${att_port_3_gnb1_cell2_38811}                ${tl.attenuator[1].attenuator_ports[3]}
${att_port_4_gnb1_cell2_38811}                ${tl.attenuator[1].attenuator_ports[4]}
${att_port_1_gnb2_cell1_38811}                ${tl.attenuator[0].attenuator_ports[5]}
${att_port_2_gnb2_cell1_38811}                ${tl.attenuator[0].attenuator_ports[6]}
${att_port_3_gnb2_cell1_38811}                ${tl.attenuator[0].attenuator_ports[7]}
${att_port_4_gnb2_cell1_38811}                ${tl.attenuator[0].attenuator_ports[8]}
${att_ipaddr_gnb1_cell1_38811}                ${tl.attenuator[0].ip_addr}
${att_ipaddr_gnb1_cell2_38811}                ${tl.attenuator[1].ip_addr}
${att_ipaddr_gnb2_cell1_38811}                ${tl.attenuator[0].ip_addr}
${att_port_1_enb_cell_37611}                ${tl.attenuator[2].attenuator_ports[9]}
${att_ipaddr_enb_cell_37611}                ${tl.attenuator[2].ip_addr}
${att_port_1_enb_cell_38811}                ${tl.attenuator[0].attenuator_ports[11]}
${att_ipaddr_enb_cell_38811}                ${tl.attenuator[0].ip_addr}
@{gnb_id}    37611    37711    38811
${att_good}    ${0}
${att_bad}    ${127}
${ui_version}=    petrus
${SIM1}    SIM 1 - MAIN
${SIM2}    SIM 2 - SUB
${ics_fail_EC_SEM55125C05503}    M55125C05503
${ics_fail_EC_RAC_M55125C05504}    M55125C05504
${ics_fail_EC_SENT_M55125C02503}    M55125C02503
${AT_script_path}    C:tool
${at_com_21B}    4
${at_com_21A}    35
${at_com_trunk}    6
${DL_TIME}                  600
${DL_LENGTH}                1024B
${UL_TIME}                  600
${UL_LENGTH}                1024B
${PROGRAM}                  20A
${UL_PORT}                  ${tl.ues[0].iperf_details.ssh_connection_details.port}
${DL_PORT}                  ${tl.ues[0].iperf_details.port}
${dial_911}    ATD911;
@{gnb_ips}    ${LOCAL_MASTER_IP}
@{branch}    SBTS24R2_ENB_9999
${tl_scf_filename1}    7326_784_SCF
${tl_scf_filename2}    7326_784_SCF_gnb2
${tl_scf_filename1_xml}    7326_784_SCF.xml
${tl_scf_filename2_xml}    7326_784_SCF_gnb2.xml
@{allow_fault_list}    7311    7107
${sys_logs_path}    /tmp/btslog2/
${UTE_logs_path}    /home/ute/ERR_WRN_logs/

*** Keywords ***
Common Suite Setup for COAM 784
    COAM Create log directory    is_set_to_test_case_level=${False}
    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
    Set Suite Variable    ${epc_log_path}    ${LOG_PATH}/${time_stamp}/
    Create directory    ${epc_log_path}
    ${release_info}    Get sagnb release
    Set Suite Variable    ${release}    ${release_info}
    Set Suite Variable    ${TS_CASE_LOG_PATH}    ${epc_log_path}

Load SCF with different release
    ${release}=    Get sagnb release title
    Prepare with COAM classical two BTS cell onair    scf_filename1=${tl_scf_filename1}_${release}.xml
    ...    scf_filename2=${tl_scf_filename2}_${release}.xml

Load SCF with different release and TL
    Run keyword If    ${gnb_instance}=='37611'    Prepare with COAM classical two BTS cell onair
    ...    ELSE    Load SCF with different release

Prepare with COAM classical two BTS cell onair
    [Arguments]    ${scf_filename1}=${tl_scf_filename1_xml}    ${scf_filename2}=${tl_scf_filename2_xml}
    Prepare with COAM classical BTS2 cell onair     scf_filename=${scf_filename1}    gnb_index=${0}
    Prepare with COAM classical BTS2 cell onair     scf_filename=${scf_filename2}    gnb_index=${1}

Prepare with COAM classical BTS cell onair
    Prepare with COAM classical BTS2 cell onair     scf_filename=${tl_scf_filename_784B}    gnb_index=${0}

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
    ...    is_pdl_checking_needed=${is_pdl_checking_needed}    timeout=600
    [Teardown]    COAM Teardown gnb connections

Perform full commission for COAM enb BTS
    [Arguments]    ${enb_BTS}=${enb_BTS}    ${scf_file_path_enb}=${tl_scf_dir_path}${tl_scf_filename_enb}
    Connect to gnb coam via ssl    connection=enblte    bts_host=${enb_BTS}
    COAM Commission with scf file    scf_file_path=${scf_file_path_enb}    timeout=600    connection=enblte
    [Teardown]    COAM Teardown gnb connections    connection=enblte

Check the gnb2 RU status ready
    [Arguments]    ${gnb_index}=${0}
    Connect to gnb coam via ssl   connection=GNB_OAM    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    wait until keyword succeeds    10min   30s    COAM Check GNB RU status
    [Teardown]    COAM Teardown gnb connections

Check the gnb2 cell status onair
    [Arguments]    ${gnb_index}=${0}
    Connect to gnb coam via ssl   connection=GNB_OAM    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    wait until keyword succeeds    5min   30s    COAM Check GNB cell on air
    [Teardown]    COAM Teardown gnb connections

Check the enb cell status onair
    [Arguments]    ${enb_BTS}=${enb_BTS}
    Connect to gnb coam via ssl    connection=enblte    bts_host=${enb_BTS}
    wait until keyword succeeds    5min   30s    COAM Check GNB cell on air    connection=enblte
    [Teardown]    COAM Teardown gnb connections    connection=enblte

Modify NIDD parameter on gnb
    [Arguments]    ${parameters_to_update}    ${gnb_index}=${0}    ${timeout}=${60}
    Connect to gnb coam via ssl   connection=GNB_OAM    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters_to_update}    timeout=${timeout}
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

Add parmeters on gnb
    [Arguments]    ${parameters_to_update}
    Connect to gnb coam via ssl    connection=GNB_OAM   bts_host=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    COAM add several MOs via rest api    objects_to_add_via_api=${parameters_to_update}
    sleep    2
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

#UE##
Get all xiaomi11 pointer variable for 376
    Set Suite Variable    ${home}    3
    Set Suite Variable    ${airplane}    1265 2095
    Set Suite Variable    ${close_task}    710 2766
    Set Suite Variable    ${Home_button}    3
    Set Suite Variable    ${swipe}    1300 2700 1300 2700
    Set Suite Variable    ${open_iperf_location}    500 2050
    Set Suite Variable    ${iperf_button}    1131 411
    Set Suite Variable    ${iperf_space}    800 550
    Set Suite Variable    ${5G}    900 960
    Set Suite Variable    ${start_call}    730 2990
    Set Suite Variable    ${stop_call}    712 2970
    Set Suite Variable    ${apn_muiltdrb}    86 872
    Set Suite Variable    ${apn_dxdata}    86 598

Get all xiaomi11 pointer variable for 377
    Set Suite Variable    ${home}    3
    Set Suite Variable    ${airplane}    940 1640
    Set Suite Variable    ${close_task}    540 2175
    Set Suite Variable    ${Home_button}    3
    Set Suite Variable    ${swipe}    550 1700 550 1200
    Set Suite Variable    ${open_iperf_location}    500 2050
    Set Suite Variable    ${iperf_button}    817 290
    Set Suite Variable    ${iperf_space}    800 550
    Set Suite Variable    ${5G}    900 960
    Set Suite Variable    ${start_call}    530 2260
    Set Suite Variable    ${stop_call}    540 2140
    Set Suite Variable    ${apn_muiltdrb}    36 850
    Set Suite Variable    ${apn_dxdata}    36 634

Get all xiaomi11 pointer variable for 388
    Set Suite Variable    ${home}    3
    Set Suite Variable    ${airplane}    1251 2208
    Set Suite Variable    ${close_task}    710 2766
    Set Suite Variable    ${Home_button}    3
    Set Suite Variable    ${swipe}    1300 2700 1300 2700
    Set Suite Variable    ${open_iperf_location}    500 2050
    Set Suite Variable    ${iperf_button}    1131 411
    Set Suite Variable    ${iperf_space}    800 550
    Set Suite Variable    ${5G}    900 960
    Set Suite Variable    ${start_call}    730 2990
    Set Suite Variable    ${stop_call}    712 2970
    Set Suite Variable    ${apn_muiltdrb}    142 1196
    Set Suite Variable    ${apn_dxdata}    142 886

Set APN point for sanmsung
    [Arguments]    ${apn_name}    ${ui_version}    ${ue_index}=${0}    ${ue_type}=${ue_type}
    unlock the screen and close all task    ue_index=${0}
    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}
    Android UE SwitchApn    ue_index=${ue_index}    apn_name=${apn_name}    ui_version=${ui_version}
    run keyword and ignore error    power_ue.UE Detach    ue_type=${ue_type}

Set APN point for sanmsungS22
#    Set Suite Variable    ${apn_muiltdrb}    95 593  #samsung S22
#    Set Suite Variable    ${apn_dxdata}    95 397    #samsung S22
    Set Suite Variable    ${apn_muiltdrb}    101 626
    Set Suite Variable    ${apn_mdrb3}    101 826
    Set Suite Variable    ${apn_dxdata2}    101 426
    Set Suite Variable    ${location_apn}    155 1049

Power UE Precondition
#    ADB Reboot Xiaomi UE
#    sleep    30s
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    capatibility_index=${0}    reset_sol=none    detach_request=${true}
    run keyword if    '${gnb_instance}'=='${gnb_id[0]}'    Get all xiaomi11 pointer variable for 377
    ...    ELSE    Get all xiaomi11 pointer variable for 388

ADB Reboot Xiaomi UE
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    [Documentation]    This KW is used for ADB Reboot UE
    Connect to control pc enhanced    ue_index=${ue_index}
    csn.execute    command=adb -s ${serial_number} reboot    connection=cpc_${ue_index}
    csn.disconnect    connection=cpc_${ue_index}

#Connect to control pc enhanced
#    [Arguments]    ${ue_index}=${0}    ${telnet}=${true}
#    [Documentation]    This kw is used to Connect to control pc enhanced
#    ${cpc_ip} =    set variable    ${tl.ues[${ue_index}].ssh_connection_details.addr}
#    ${cpc_usrname} =    set variable    ${tl.ues[${ue_index}].ssh_connection_details.username}
#    ${cpc_passwd} =    set variable    ${tl.ues[${ue_index}].ssh_connection_details.password}
#    ${cpc_status}    run keyword and return status
#    ...              Connect to control pc    cpc_ip=${cpc_ip}    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}
#    ...              alias=cpc_${ue_index}
#    run keyword if    '${cpc_status}'=='False' and ${telnet}
#    ...               reset cpc sshd services    cpc_ip=${cpc_ip}    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}
#    run keyword if    '${cpc_status}'=='False' and ${telnet}
#    ...               Connect to control pc    cpc_ip=${cpc_ip}    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}
#    ...               alias=cpc_${ue_index}

#reset cpc sshd services
#    [Arguments]    ${cpc_ip}    ${cpc_usrname}    ${cpc_passwd}
#    [Documentation]    This kw is used to reset cpc sshd services
#    Telnet.Open connection    ${cpc_ip}
#    Telnet.set timeout    20 s
#    Telnet.Login    ${cpc_usrname}    ${cpc_passwd}    login_timeout=10 s    password_prompt=password:
#    Telnet.Write    sc stop cygsshd
#    sleep    5s
#    Telnet.Write    sc config cygsshd start= Auto
#    sleep    5s
#    Telnet.Write    sc start cygsshd
#    sleep    5s
#    Telnet.close connection
#    sleep    5s
#
#Connect to control pc
#    [Arguments]    ${cpc_ip}    ${cpc_usrname}    ${cpc_passwd}    ${alias}=cpc
#    [Documentation]    This kw is used to Connect to control pc
#    Wait Until Keyword Succeeds    5min    20s
#    ...    Csn.Connect to    ${cpc_ip}    ${cpc_usrname}    ${cpc_passwd}    alias=${alias}

power off or on SIM
     [Arguments]    ${command}    ${ue_index}=${0}
    ${release_info}    Get sagnb release
    run keyword if    '${release_info}'=='SBTS22R2_ENB_0000'    AT cammand    command=${command}    COM_port=${at_com_21B}
    ...    ue_index=${ue_index}    ELSE IF    '${release_info}'=='SBTS22R1_ENB_0000'
    ...    AT cammand    command=${command}    COM_port=${at_com_21A}    ue_index=${ue_index}
    ...    ELSE    AT cammand    command=${command}    COM_port=${at_com_trunk}    ue_index=${ue_index}

AT cammand
    [Arguments]    ${command}    ${COM_port}    ${ue_index}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    csn.send_command
    ...    command=adb -s ${serial_number} shell "su -c 'setprop sys.usb.config diag,adb,serial_cdev'"
    ...    connection=cygwin${ue_index}
    sleep   10s
    csn.send_command
    ...    command=cd ${AT_script_path} && python ATcommand.py -p com${COM_port} -c "${command}"
    ...    connection=cygwin${ue_index}
    ${output}    csn.Read Output    connection=cygwin${ue_index}
    sleep    3s
    should contain    ${output}    ${command}\\r\\r\\nOK\\r\\n
#    csn.execute    command=cd    connection=cygwin${ue_index}


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

hold on an VONR
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
#    ...    ${connection}=cygwin${ue_index}
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:+6688
    ...    connection=cygwin${ue_index}
    sleep    2s
        csn.send_command    command=adb -s ${serial_number} shell input tap 711 2435
    ...    connection=cygwin${ue_index}
    sleep    5s

Make a VoNR call(+6688) samsung
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=6688
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
    #####Samsung S21 WA to click time cancel
    csn.send_command    command=adb -s ${serial_number} shell input tap 302 2108    connection=cygwin${ue_index}
    sleep    2s
    #####make VoNR call#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:+${phone_number}
    ...    connection=cygwin${ue_index}
    sleep   1s
    csn.disconnect      connection=cygwin${ue_index}

Start a emergency call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=911
#    ...    ${connection}=cygwin${ue_index}
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.DIAL -d tel:${phone_number}
    ...    connection=cygwin${ue_index}
    sleep    10s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${start_call}
    ...    connection=cygwin${ue_index}
    sleep    5s

Stop the emergency call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    #${phone_number}=911
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    csn.send_command    command=adb -s ${serial_number} shell input tap ${stop_call}
    ...    connection=cygwin${ue_index}
    sleep    10s

Stop the VONR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    #${phone_number}=911
#    ...    ${connection}=cygwin${ue_index}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    csn.send_command    command=adb -s ${serial_number} shell input tap ${stop_call}
    ...    connection=cygwin${ue_index}
    sleep    3s

hang up VoNR call samsung
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}    look_for_keys=False
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 6    connection=cygwin${ue_index}
    sleep   1s
    csn.disconnect      connection=cygwin${ue_index}

Make EMC call on samsung UE
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=911
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}
    sleep   3s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 3
    ...    connection=cpc_${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=cpc_${ue_index}
    sleep   2s
    #####make VoNR call#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:${phone_number}
    ...    connection=cpc_${ue_index}
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input tap 538 1959
    ...    connection=cpc_${ue_index}
    csn.disconnect      connection=cpc_${ue_index}

hang up EMC call on samsung UE
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}
    sleep   3s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent 3
    ...    connection=cpc_${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800
    ...    connection=cpc_${ue_index}
    sleep   2s
    #####Samsung S21 WA to click time cancel
    csn.send_command    command=adb -s ${serial_number} shell input tap 285 37    connection=cpc_${ue_index}
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input tap 538 1959
    ...    connection=cpc_${ue_index}
    sleep    5s
    csn.disconnect      connection=cpc_${ue_index}

check voice call status
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${status}=${2}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cpc_${ue_index}    look_for_keys=False
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

Check timer differ
    [Arguments]    ${logname}    ${message_filter}    ${message_filter1}    ${value}    ${index00}=${0}    ${index01}=${0}
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
#    [Arguments]    ${alias}=enb
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

Check wireshark log for successful EC procedure
    [Arguments]    ${logname}
    Check wireshark log for EC setup    logname=${logname}
    Check wireshark log for EC 5QI 5    logname=${logname}
    Check wireshark log for EC 5QI 1    logname=${logname}
    Check wireshark log for EC release    logname=${logname}

Check wireshark log for successful EC procedure without sim
    [Arguments]    ${logname}
    Check wireshark log for EC registration    logname=${logname}
    Check wireshark log for EC setup    logname=${logname}
    Check wireshark log for EC 5QI 5 by ICRS    logname=${logname}
    Check wireshark log for EC 5QI 1    logname=${logname}
    Check wireshark log for EC release    logname=${logname}

Check wireshark log for EC registration
    [Arguments]    ${logname}
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=ngap.procedureCode == 15 and ngap.RRCEstablishmentCause == 0
    ...    xpath_filter=ngap.RRCEstablishmentCause    expect_value=0

Check wireshark log for inter gnb HO
    [Arguments]    ${logname1}    ${logname2}    #${attribute_name}=show
    ...    ${command_template}=${command_template_Y_xnap}
    ...    ${message_filter1}=ngap.fiveQI == 7 and ngap.priorityLevelARP == 7
    ...    ${message_filter2}=ngap.fiveQI == 5 and ngap.priorityLevelARP == 5
    ...    ${message_filter3}=ngap.procedureCode == 29 and ngap.fiveQI == 5 and ngap.priorityLevelARP ==1
    ...    ${message_filter4}=ngap.procedureCode == 29 and ngap.fiveQI == 5 and ngap.priorityLevelARP ==1
    ...    ${message_filter_service}=xnap.procedureCode == 0 and xnap.XnAP_PDU == 1
    ...    ${message_filter_target}=ngap.procedureCode == 25 and ngap.NGAP_PDU == 1
    log to console    check service gnb HO procedure
    ${all_packets1}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname1}
    ...    command_template=${command_template}
    ${filter_expression1}=    Catenate    ${message_filter1}
    ${filter_expression2}=    Catenate    ${message_filter2}
    ${filter_expression3}=    Catenate    ${message_filter3}
    ${filter_expression4}=    Catenate    ${message_filter4}
    ${filter_expression_service}=    Catenate    ${message_filter_service}
    ${filtered_packets1}=    parser.filter_packets_by_expression
    ...    filter_expression=${filter_expression1}
    ${filtered_packets2}=    parser.filter_packets_by_expression
    ...    filter_expression=${filter_expression2}
    ${filtered_packets3}=    parser.filter_packets_by_expression
    ...    filter_expression=${filter_expression3}
    ${filtered_packets4}=    parser.filter_packets_by_expression
    ...    filter_expression=${filter_expression4}
    ${filtered_packets_service}=    parser.filter_packets_by_expression
    ...    filter_expression=${filter_expression_service}
    ${filtered_value_pdu}    Create List
    FOR    ${index}    IN    1    2    3    4
        ${filtered_value}=    parser.get_field_value_by_xpath    pdml_list=${filtered_packets${index}}
        ...    xpath=.//ngap.pDUSessionID
        append to list    ${filtered_value_pdu}    ${filtered_value[0]}
    END
    ${filtered_value_qosflow}    Create List
    FOR    ${index}    IN    1    2    3    4
        ${filtered_value}=    parser.get_field_value_by_xpath    pdml_list=${filtered_packets${index}}
        ...    xpath=.//ngap.qosFlowIdentifier
        append to list    ${filtered_value_qosflow}    ${filtered_value[0]}
    END
    ${filtered_value_qosflow_service}=    parser.get_field_value_by_xpath    pdml_list=${filtered_packets_service}
    ...    xpath=.//xnap.qosFlowIdentifier
    ${filtered_value_pdu_service}=    parser.get_field_value_by_xpath    pdml_list=${filtered_packets_service}
    ...    xpath=.//xnap.pduSessionId
    FOR    ${index}    IN RANGE    ${3}
        should contain    ${filtered_value_pdu_service}    ${filtered_value_pdu[${index}]}
        should contain    ${filtered_value_qosflow_service}    ${filtered_value_qosflow[${index}]}
    END
    log to console    check target gnb HO procedure
    ${all_packets2}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname2}
    ...    command_template=${command_template}
    ${filter_expression_target}=    Catenate    ${message_filter_target}
    ${filtered_packets_target}=    parser.filter_packets_by_expression
    ...    filter_expression=${filter_expression_target}
    ${filtered_value_pdu_target}=    parser.get_field_value_by_xpath    pdml_list=${filtered_packets_target}
    ...    xpath=.//ngap.pDUSessionID
    FOR    ${index}    IN RANGE    ${3}
        should contain    ${filtered_value_pdu_service}    ${filtered_value_pdu_target[${index}]}
    END


Check wireshark log for EC release on source
    [Arguments]    ${logname}
    Check wireshark log for EC setup    logname=${logname}
    Check wireshark log for EC 5QI 5    logname=${logname}
    Check wireshark log for EC 5QI 1    logname=${logname}
    Check wireshark log for EC UEContextreleasecomplete    logname=${logname}

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

Check wireshark log for RRE success
    [Arguments]    ${logname}
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=f1ap.procedureCode == 11 and nr-rrc.c1 == 2
    ...    xpath_filter=nr-rrc.c1   expect_value=2

Check wireshark log for EC and VONR unrelease
    [Arguments]    ${logname}
#    ${nomal_call_pdu_id}    Get filtered value    logname=${logname}    command_template=${command_template_Y}
#    ...    message_filter=ngap.fiveQI == 1 and ngap.priorityLevelARP == 3
#    ...    xpath_filter=ngap.pDUSessionID
    Check wireshark log for unrelease    logname=${logname}    command_template=${command_template_Y}
    ...    message_filter=ngap.nas == 0
    ...    xpath_filter=ngap.nas == 0
#    ${EC_call_pdu_id}    Get filtered value    logname=${logname}    command_template=${command_template_Y}
#    ...    message_filter=ngap.fiveQI == 1 and ngap.priorityLevelARP == 1
#    ...    xpath_filter=ngap.pDUSessionID
#    Check wireshark log for unrelease    logname=${logname}    command_template=${command_template_Y}
#    ...    message_filter=ngap.nas == 0
#    ...    xpath_filter=ngap.pDUSessionID == ${EC_call_pdu_id[0]}

Check wireshark log for unrelease
    [Arguments]    ${logname}    ${message_filter}    ${xpath_filter}    ${attribute_name}=show
    ...    ${command_template}=${command_template_Y}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ...    command_template=${command_template}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    parser.filter_packets_by_expression
    ...    filter_expression=${filter_expression}
    ${filtered_value}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//${xpath_filter}
    ...    attribute_name=${attribute_name}
    should be empty    ${filtered_value}

Check wireshark log for successful EC procedure_idle
    [Arguments]    ${logname}
    Check wireshark log for EC initial UE massage    logname=${logname}
    Check wireshark log for EC setup    logname=${logname}
    Check wireshark log for EC 5QI 5_idle    logname=${logname}
    Check wireshark log for EC 5QI 1    logname=${logname}
    Check wireshark log for EC release    logname=${logname}

Check wireshark log for EC setup
    [Arguments]    ${logname}
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=(ngap.procedureCode == 46 and nas-5gs.mm.req_type == 3)
    ...    xpath_filter=nas-5gs.mm.req_type    expect_value=3

Check wireshark log for EC 5QI 1
    [Arguments]    ${logname}
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=(ngap.procedureCode == 26 and ngap.fiveQI == 1)
    ...    xpath_filter=ngap.fiveQI    expect_value=1
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=(ngap.procedureCode == 26 and ngap.priorityLevelARP == 1)
    ...    xpath_filter=ngap.priorityLevelARP    expect_value=1

Check wireshark log for EC 5QI 5
    [Arguments]    ${logname}
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=(ngap.procedureCode == 29 and ngap.fiveQI == 5)
    ...    xpath_filter=ngap.fiveQI    expect_value=5
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=(ngap.procedureCode == 29 and ngap.priorityLevelARP == 1)
    ...    xpath_filter=ngap.priorityLevelARP    expect_value=1

Check wireshark log for EC 5QI 5 by ICRS
    [Arguments]    ${logname}
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=ngap.procedureCode == 14 and ngap.fiveQI == 5
    ...    xpath_filter=ngap.fiveQI    expect_value=5
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=ngap.procedureCode == 14 and ngap.priorityLevelARP == 1
    ...    xpath_filter=ngap.priorityLevelARP    expect_value=1

Check wireshark log for EC 5QI 5_idle
    [Arguments]    ${logname}
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=ngap.procedureCode == 14 and ngap.fiveQI == 5
    ...    xpath_filter=ngap.fiveQI    expect_value=5
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=ngap.procedureCode == 14 and ngap.priorityLevelARP == 1
    ...    xpath_filter=ngap.priorityLevelARP    expect_value=1

Check wireshark log for EC release
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
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ...    command_template=${command_template_Y}
    ${filter_expression}=     Catenate    ngap.procedureCode == 28 and ngap.nas == 0
    ${filtered_packets}=    parser.filter_packets_by_expression
    ...    filter_expression=${filter_expression}
    ${filtered_value}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//ngap.nas
    ...    attribute_name=${attribute_name}
    should be empty    ${filtered_value}

Check wireshark log that emergency call setup failed
    [Arguments]    ${logname}   ${attribute_name}=show
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ...    command_template=${command_template_Y}
    ${filter_expression}=     Catenate    ngap.procedureCode == 26 and ngap.priorityLevelARP == 1
    ${filtered_packets}=    parser.filter_packets_by_expression
    ...    filter_expression=${filter_expression}
    ${filtered_value}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//ngap.priorityLevelARP
    ...    attribute_name=${attribute_name}
    should be empty    ${filtered_value}

Check wireshark log for EC 5QI 1 failed for redirection
    [Arguments]    ${logname}
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=ngap.procedureCode == 26 and ngap.radioNetwork == 41
    ...    xpath_filter=ngap.radioNetwork    expect_value=41

Check wireshark log for EC 5QI 5 failed for redirection
    [Arguments]    ${logname}
    Check wireshark log for VoNR    logname=${logname}
    ...    message_filter=ngap.procedureCode == 14 and ngap.radioNetwork == 41
    ...    xpath_filter=ngap.radioNetwork    expect_value=41

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

Check wireshark log for VoNR
    [Arguments]    ${logname}    ${message_filter}    ${xpath_filter}    ${expect_value}    ${attribute_name}=show
    ...    ${command_template}=${command_template_Y}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}
    ...    command_template=${command_template}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    parser.filter_packets_by_expression
    ...    filter_expression=${filter_expression}
    ${filtered_value}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}
    ...    xpath=.//${xpath_filter}
    ...    attribute_name=${attribute_name}
    should be equal    ${filtered_value[0]}    ${expect_value}

Get filtered value
    [Arguments]    ${logname}    ${message_filter}    ${xpath_filter}    ${attribute_name}=show
    ...    ${command_template}=${command_template_Y}
    ${all_packets}=    parser.load_pcap_file    pcap_file=${epc_log_path}${logname}
#    ${all_packets}=    parser.load_pcap_file    pcap_file=/opt/workspace/CIT/Master/Case_Logs/${logname}
    ...    command_template=${command_template}
    ${filter_expression}=     Catenate    ${message_filter}
    ${filtered_packets}=    parser.filter_packets_by_expression
    ...    filter_expression=${filter_expression}
    ${filtered_value}=     parser.get_field_value_by_xpath    pdml_list=${filtered_packets}    xpath=.//${xpath_filter}
    ...    attribute_name=${attribute_name}
    [Return]    ${filtered_value}

##bip log##
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
   [Arguments]    ${biplog}    #${bip_time}=${1}
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
    [Arguments]    ${biplog}    #${bip_time}
    bip capture on ABIO and download to UTE    biplog=${biplog}    interface=eth1    bip_time=${3}    connection=Local_gnb2
    Check SIB1 not contain emergency from BIP log        biplog=${biplog}

Tests Recover
    Tear down wireshark log and detach
#    eNB stop wireshark log_teardown
    Tear down the connections
#    Adjust eNB_RU Attenuation    value_1=${120}    value_2=${120}

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

##PA##
Adjust gNB_RU Attenuation
    [Arguments]     ${tl}=${gnb_instance}
    ...    ${gnb1_cell1_value}=${127}    ${gnb1_cell2_value}=${127}
    ...    ${gnb2_cell1_value}=${127}    ${gnb2_cell2_value}=${127}
    ####create cell list#####
    @{att_ports_gnb1_cell1}    Create List    ${att_port_1_gnb1_cell1_${tl}}    ${att_port_2_gnb1_cell1_${tl}}
    ...    ${att_port_3_gnb1_cell1_${tl}}    ${att_port_4_gnb1_cell1_${tl}}
    @{att_ports_gnb1_cell2}    Create List    ${att_port_1_gnb1_cell2_${tl}}    ${att_port_2_gnb1_cell2_${tl}}
    ...    ${att_port_3_gnb1_cell2_${tl}}    ${att_port_4_gnb1_cell2_${tl}}
    @{att_ports_gnb2_cell1}    Create List    ${att_port_1_gnb2_cell1_${tl}}    ${att_port_2_gnb2_cell1_${tl}}
    ...    ${att_port_3_gnb2_cell1_${tl}}    ${att_port_4_gnb2_cell1_${tl}}
    @{att_ports_gnb2_cell2}    Run Keyword If    '${gnb_instance}'=='${gnb_id[0]}'
    ...    Create List    ${att_port_1_gnb2_cell2_${tl}}    ${att_port_2_gnb2_cell2_${tl}}
    ...    ${att_port_3_gnb2_cell2_${tl}}    ${att_port_4_gnb2_cell2_${tl}}

    ###create value list####
    @{values_gnb1_cell1}    Create List    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}
    @{values_gnb1_cell2}    Create List    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}
    @{values_gnb2_cell1}    Create List    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}
    @{values_gnb2_cell2}    Run Keyword If    '${gnb_instance}'=='${gnb_id[0]}'
    ...    Create List    ${gnb2_cell2_value}    ${gnb2_cell2_value}    ${gnb2_cell2_value}    ${gnb2_cell2_value}

    ###Adjust the HBTE attenuation value###
    Set the attenuation value    att_ports=${att_ports_gnb1_cell1}    values=${values_gnb1_cell1}
    ...    att_connection_port=${att_port_1_gnb1_cell1_${tl}}    att_ipaddr=${att_ipaddr_gnb1_cell1_${tl}}
    Set the attenuation value    att_ports=${att_ports_gnb1_cell2}    values=${values_gnb1_cell2}
    ...    att_connection_port=${att_port_1_gnb1_cell2_${tl}}    att_ipaddr=${att_ipaddr_gnb1_cell2_${tl}}
    Set the attenuation value    att_ports=${att_ports_gnb2_cell1}    values=${values_gnb2_cell1}
    ...    att_connection_port=${att_port_1_gnb2_cell1_${tl}}    att_ipaddr=${att_ipaddr_gnb2_cell1_${tl}}
    Run Keyword If    '${gnb_instance}'=='${gnb_id[0]}'
    ...    Set the attenuation value    att_ports=${att_ports_gnb2_cell2}    values=${values_gnb2_cell2}
    ...    att_connection_port=${att_port_1_gnb2_cell2_${tl}}    att_ipaddr=${att_ipaddr_gnb2_cell2_${tl}}

Adjust enb attenuation
    [Arguments]     ${tl}=${gnb_instance}    ${enb_cell_value}=${127}
    ####create cell list#####
    @{att_ports_enb_cell}    Create List    ${att_port_1_enb_cell_${tl}}

    ###create value list####
    @{values_enb_cell}    Create List    ${enb_cell_value}

    ###Adjust the HBTE attenuation value###
    Set the attenuation value    att_ports=${att_ports_enb_cell}    values=${values_enb_cell}
    ...    att_connection_port=${att_port_1_enb_cell_${tl}}    att_ipaddr=${att_ipaddr_enb_cell_${tl}}

Adjust one port attenuation
    [Arguments]     ${tl}=${gnb_instance}    ${gnb1_cell1_value}='NULL'    ${gnb2_cell1_value}='NULL'
    ####create cell list#####
    @{att_ports_gnb1_cell1}    Create List    ${att_port_1_gnb1_cell1_${tl}}    ${att_port_2_gnb1_cell1_${tl}}
    ...    ${att_port_3_gnb1_cell1_${tl}}    ${att_port_4_gnb1_cell1_${tl}}
    @{att_ports_gnb2_cell1}    Create List    ${att_port_1_gnb2_cell1_${tl}}    ${att_port_2_gnb2_cell1_${tl}}
    ...    ${att_port_3_gnb2_cell1_${tl}}    ${att_port_4_gnb2_cell1_${tl}}

    ###create value list####
    @{values_gnb1_cell1}    Create List    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}
    @{values_gnb2_cell1}    Create List    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}

    ###Adjust the HBTE attenuation value###
    run keyword if  not ${gnb1_cell1_value}=='NULL'
    ...    Set the attenuation value    att_ports=${att_ports_gnb1_cell1}    values=${values_gnb1_cell1}
    ...    att_connection_port=${att_port_1_gnb1_cell1_${tl}}    att_ipaddr=${att_ipaddr_gnb1_cell1_${tl}}
    run keyword if  not ${gnb2_cell1_value}=='NULL'
    ...    Set the attenuation value    att_ports=${att_ports_gnb2_cell1}    values=${values_gnb2_cell1}
    ...    att_connection_port=${att_port_1_gnb2_cell1_${tl}}    att_ipaddr=${att_ipaddr_gnb2_cell1_${tl}}

### check counter ###
check the counter M55125C05503 M55125C05504 and M55125C02503
    ${PM_counter_5503}    Get PM counter Result for case    counter_id=${ics_fail_EC_SEM55125C05503}
    Should contain    ${PM_counter_5503}    ${1}
    ${PM_counter_5504}    Get PM counter Result for case    counter_id=${ics_fail_EC_RAC_M55125C05504}
    Should contain    ${PM_counter_5504}    ${1}
    ${PM_counter_2503}    Get PM counter Result for case    counter_id=${ics_fail_EC_SENT_M55125C02503}
    Should contain    ${PM_counter_2503}    ${1}

Get PM counter Result for case
    [Arguments]    ${counter_id}
    ${PM_counter}    Check PM counter with sort list    counter_id=${counter_id}
    ...    full_path=BTS/CELLS/NRCELL-1/NNGCC
    [Return]      ${PM_counter}

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

Power UE Start dl traffic and check throughput
    [Arguments]    ${dl_throughput}    ${Expect_DOWNLINK}    ${duration}=${DL_TIME}    ${dl_length}=${DL_LENGTH}    ${dl_port}=${DL_PORT}
    ...    ${ue_index}=${0}    ${gnb_index}=${0}    ${cellid}=1
    ${nrcellid}    COAM Get nrcellid with lcrid    lcrid=${cellid}    gnb_index=${gnb_index}
    power_ue.Start traffic    ue_type=xiaomi    direction=dl    throughput=${dl_throughput}    duration=${duration}
    ...                       iperf_port=${dl_port}    ue_index=${0}    cap_index=${0}    buffer_size=${dl_length}
    sleep    15s
    wait until keyword succeeds    2min    10s    power_ue.Check throughput    ue_type=xiaomi    direction=dl    throughput=${Expect_DOWNLINK}
    ...    ue_index=${ue_index}    hw_slot=1    sample=${10}    start_offset=${3}    sleep_time=${5}    cellid=${nrcellid}    gnb_index=${gnb_index}

Check the cell DL throughput and stop traffic
    [Arguments]    ${cellid}=1    ${gnb_index}=${0}    ${Expect_DOWNLINK}=10
#    ...    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ${nrcellid}    COAM Get nrcellid with lcrid    lcrid=${cellid}    gnb_index=${gnb_index}
    Wait Until Keyword Succeeds   3x    10s    power_ue.Check Throughput    sample=${6}    gnb_index=${gnb_index}
    ...    ue_type=${ue_type}    direction=dl    throughput=${Expect_DOWNLINK}    cellid=${nrcellid}    sleep_time=${20}
    power_ue.Stop traffic    ue_type=${ue_type}     direction=dl    iperf_port=${dl_port}
    sleep    3s
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}

Online modify parmeters
    [Arguments]    ${parameters_to_update}    ${gnb_index}=${0}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters_to_update}
    sleep    5
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

Lock LTE
    Locked LTE cell tl388

Locked LTE cell
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-0
    ...    parameter=administrativeState
    ...    value=locked
    sleep    10s

Locked LTE cell tl388
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-1
    ...    parameter=administrativeState
    ...    value=locked
    sleep    10s

UnLock LTE
    Unlocked LTE cell 388

Unlocked LTE cell
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-0
    ...    parameter=administrativeState
    ...    value=unlocked
    sleep    10s

Unlocked LTE cell 388
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}/LNCEL-1
    ...    parameter=administrativeState
    ...    value=unlocked
    sleep    10s

Lock 5G other cell
    Modify NIDD parameter on gnb    parameters_to_update=${PARAMETERS_TO_UPDATE_B20}    gnb_index=${0}
    Modify NIDD parameter on gnb    parameters_to_update=${PARAMETERS_TO_UPDATE_B20_GNB2}    gnb_index=${1}

UnLock 5G other cell
    Modify NIDD parameter on gnb    parameters_to_update=${PARAMETERS_TO_UPDATE_B20_UNLOCK}    gnb_index=${0}
    Modify NIDD parameter on gnb    parameters_to_update=${PARAMETERS_TO_UPDATE_B20_GNB2_UNLOCK}    gnb_index=${1}

UE.Check Both ULDL throughput for 40s
    [Arguments]    ${ue_type}    ${theory_dl_peak}    ${theory_ul_peak}    #${deviation}=10
    ...            ${total_time}=40    ${duration_time_for_once}=15s    #${interval}=5s
    ...            ${acceptable_tput_percentage}=0.90    ${nr_cell_index}=1    ${du_index}=0
#    ...            ${gnb_ssl_connection}=GNB_OAM    ${is_need_to_capture_log}=${False}
#    ...            ${gnb_index}=${0}
    [Documentation]    Check Both ULDL throughputt from started traffic.
    [Timeout]      30min
    Log to console    \nINFO:power_ue.Check Both ULDL throughput for 40s
    Connect to gnb coam via ssl
    power_ue.Check peak throughput     ue_type=${ue_type}
    ...     theory_dl_peak=${theory_dl_peak}     theory_ul_peak=${theory_ul_peak}     nr_cell_index=${nr_cell_index}
    ...     total_time=${total_time}     duration_time_for_once=${duration_time_for_once}
    ...     acceptable_tput_percentage=${acceptable_tput_percentage}
    ...     du_index=${du_index}

Common UE teardown
    Run Keyword And Ignore Error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul
    Run Keyword And Ignore Error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}

Reset the gnb1 and gnb2 and wait them on air
    COAM gNB Reset site via api    gnb_index=${0}    is_need_check_cell_onair=False    wait_for_reconnection=False
    COAM gNB Reset site via api    gnb_index=${1}    is_need_check_cell_onair=False    wait_for_reconnection=False
    wait until keyword succeeds    10 min    20s   Check the gnb2 cell status onair    gnb_index=${0}
    wait until keyword succeeds    10 min    20s   Check the gnb2 cell status onair    gnb_index=${1}

COAM gNB Reset site via api
    [Arguments]   ${gnb_index}=${0}    ${wait_for_reconnection}=True    #${is_need_check_cell_onair}=True
    Connect to gnb coam via ssl    connection=coam_admin    gnb_index=${gnb_index}
    coam.reset_site    wait_for_reconnection=${wait_for_reconnection}    connection=coam_admin
    COAM Teardown gnb connections    connection=coam_admin
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections

Check the PM counter shuould be value
    [Arguments]    ${counter_id}    ${dic_path}    ${value}    ${gnb_index}=${0}
    ...    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ${counter_lenth}    Get Length    ${counter_id}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
    FOR    ${index}    IN RANGE    ${counter_lenth}
        ${counter_value} =    get_pm_counter_values    counter_id=${counter_id[${index}]}    connection=GNB_OAM
         ...    dic_path=${dic_path[${index}]}    timeout=120
        Should contain    ${counter_value}    ${value[${index}]}
    END
    [Teardown]    COAM Teardown gnb connections

get and analysis syslog
    Check ERR Or WRN From Syslog
    ...    sys_logs_path=${sys_logs_path}      Expected_ERR_WRN_deviation=0.2
    ...    Expected_ERR_WRN_diff_number=0
    ...    UTE_logs_path=${UTE_logs_path}      testline=${testline_name}
    ...    base_file=None     Fail_Case=False       Clear_log=True     remove_ERR_WRN_excel=True
    ...    filter_list=None      ignore_list=None      Delete_old_ERR_WRN=1
    ...    FilesSystem=/dev/vda2      Max_used_space_ratio=0.75      check_diff=True
    ...    timeout=30 minutes      Expected_ERR_WRN_number=0

Start capture syslog via btslog on ute
    Start BTSlogs Collection In Log Server
    ...    Test_PC_IP=${Test_PC_IP}    Test_PC_username=${Test_PC_username}
    ...    Test_PC_password=${Test_PC_password}
    ...    btslog_path=/tmp/btslog2    btslog_launcher=/opt/btslog/btslog_launcher
    ...    btslog_launcher_path=/opt/btslog/btslog
    ...    Login_UTE=False

Stop capture syslog via btslog on ute
    Stop BTSlogs Collection And Download Logs To Log Server
    ...    UTE_syslogs_path=/home/ute/BTS_logs    btslog_path=/tmp/btslog2
    ...    btslog_launcher=/opt/btslog/btslog_launcher    btslog_launcher_path=/opt/btslog/btslog
    ...    Login_UTE=${False}