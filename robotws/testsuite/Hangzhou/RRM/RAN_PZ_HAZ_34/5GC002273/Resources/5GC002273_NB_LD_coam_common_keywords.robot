*** Settings ***
Documentation
...    author: zhangqingqing
...    contact:qingqing.zhang@nokia-sbell.com
...    squad group: SG_03
...    feature : 5GC002273-EL & C5GC002273-EM & C5GC002273-EN & C5GC002273-ES

Library     OperatingSystem
Library     Collections
Library     String
Library     BuiltIn
Library     DateTime
Library     taf.transport.ssh    WITH NAME    csn
Library     taf.pdu  WITH NAME   pdu
Library     taf.sbts.oam.coam.admin   WITH NAME    wmplte
Library     taf.config.scf    WITH NAME    scf
Library    taf.analyzer.pcap   WITH NAME    cap
Library     taf.hw.rf_attenuator    WITH NAME    att
Library     taf.config.testline    WITH NAME    testline
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py
Library     taf.rfrl.common_resources.python.SWConfig    WITH NAME    SWConfig
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    taf/rfrl/common_resources/robot/gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Library     ../../libraries/L3Call.py
Library     Attenuation.Attenuation    WITH NAME    atten
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    ../../libraries/biplog_capture/biplog_capture.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BIP_trace/BIP_trace_collector.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Library           taf.gnb.oam.megazone_client     WITH NAME    megazone_client


*** Variables ***
##PATH##
${TS_LOG_PATH_BASE}         /opt/workspace/CRT/Master/Case_Logs
${tl_scf_dir_path}          /opt/workspace/SCF/
${gnb_path}                 /tmp/
${enb_path}                 /user/toor4nsn
${ttitrace_path}            /ffs/run/config/toor4nsn/eventTrace_log/
${swconfig_default}         /opt/workspace/swconfig/1856_M_19/swconfig.txt
${tshark_path}              /usr/bin/tshark
${LUA_SCRIPT_PATH}          /opt/workspace/CIT/Master/luashark/generated_luashark/luashark.lua
##GNB##
${WEBUI_COAM}             https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_URL}                ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_NAME}             ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}              ${tl.gnbs[0].cu.oam_http_connection_details.password}
${gnb0_BTS_host}             ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${gnb_BTS_username}          ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gnb_BTS_password}          ${tl.gnbs[0].cu.oam_http_connection_details.password}
${asik_addr_0}              ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${asik_username}            ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${asik_password}            ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${TestPC_addr}              ${tl.test_pc.default_ssh_connection_details.addr}
${TestPC_username}          ${tl.test_pc.default_ssh_connection_details.username}
${TestPC_password}          ${tl.test_pc.default_ssh_connection_details.password}
${gnb_instance_0}           ${tl.gnbs[0].instance_id}
##ENB##
${ENB_ADDRESS_0}            ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${enbx2_para}               administrativeState
${enb_instance}             ${tl.enbs[0].instance_id}
${enbx2_dist}               MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNADJGNB-1
##Iperf##
${appserver_addr}           ${tl.ues[0].iperf_details.ssh_connection_details.addr}
${appserver_username}       ${tl.ues[0].iperf_details.ssh_connection_details.username}
${appserver_password}       ${tl.ues[0].iperf_details.ssh_connection_details.password}
##UE pc##
${UE_pc_ip}                 ${tl.ues[0].ssh_connection_details.addr}
${UE_pc_user}               ${tl.ues[0].ssh_connection_details.username}
${UE_pc_password}           ${tl.ues[0].ssh_connection_details.password}
##PA##
${att_ipaddr}               ${tl.attenuator[0].ip_addr}
${att_port_1}               ${tl.attenuator[0].attenuator_ports[13]}
${att_port_2}               ${tl.attenuator[0].attenuator_ports[14]}
${att_port_3}               ${tl.attenuator[0].attenuator_ports[15]}
${att_port_4}               ${tl.attenuator[0].attenuator_ports[16]}
${att_connection_port}      ${tl.attenuator[0].attenuator_ports[13]}
${att_api_port}             ${tl.attenuator[0].port}
${vendor}                   HBTE
${HBTE_max_value}           ${127}
${TOPYONG_ANT1}             ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${TOPYONG_ANT2}             ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${TOPYONG_ANT3}             ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
${TOPYONG_ANT4}             ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
${RU_1_SN}                  ${tl.gnbs[0].dus[0].rus[0].serial_number}
${calibration_filename}    disabelcalibration.sh
${disable_calibration}      ${tl_scf_dir_path}${calibration_filename}
##UE##
${SN}                       ${tl.ues[0].serial_number}
${ue_type}                  ${tl.ues[0].capabilities[1]}
${UL_PORT}                  ${tl.ues[0].iperf_details.ssh_connection_details.port}
${DL_PORT}                  ${tl.ues[0].iperf_details.port}
${aeqn_pb_ip}               ${tl.gnbs[0].dus[0].rus[0].pdu_port.pdu.addr}
${aeqn_pb_port}             ${tl.gnbs[0].dus[0].rus[0].pdu_port.port_no}
${web_ui}=                  https://[${tl.gnbs[0].cu.oam_ssh_connection_details.addr}]
#${ul_throughput}            30M
#${dl_throughput}            1000M
${DL_TIME}                  1200
${DL_LENGTH}                1024B
${UL_TIME}                  600
${UL_LENGTH}                1024B
${PROGRAM}                  20A
${command_template_with_Y}    {tshark_path} -r {pcap_file} -X lua_script:{luashark_path} -T pdml
${distname_id_1}       MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}

*** Keywords ***
##setup and teardown and recovery##
lock amf for NSA attach
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    selenium_coam.disable_message_box
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    selenium_coam.set_parameter_value    dist_name=${distname_id_1}/SERVEDAMF-1
    ...    filter_param=Administrative state
    ...    new_value=Locked
    selenium_coam.validate_plan
    sleep    3s
    selenium_coam.activate_plan    activate_plan_despite_errors=True    timeout=120
    selenium_coam.logout
    selenium_coam.disable_virtual_display

unlock amf for NSA attach
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    selenium_coam.disable_message_box
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    selenium_coam.set_parameter_value    dist_name=${distname_id_1}/SERVEDAMF-1
    ...    filter_param=Administrative state
    ...    new_value=Unlocked
    selenium_coam.validate_plan
    sleep    3s
    selenium_coam.activate_plan    activate_plan_despite_errors=True    timeout=120
    selenium_coam.logout
    selenium_coam.disable_virtual_display

Set suite variables by program
    [Documentation]      This keyword is to set several variables by program.
    ${release_info}    Get sagnb release
    set variable    ${release_info}
    run keyword if    '${release_info}' == '001800'    set suite variable    ${PROGRAM}   20A
    ...    ELSE         set suite variable    ${PROGRAM}     Trunk
    import library    TTI_Trace_analysis_dl.TTI_Trace_analysis_dl    program=${PROGRAM}    WITH NAME    event_trace

Common Suite Setup for COAM
    [Arguments]    ${log_level}=${False}
    COAM Create log directory    is_set_to_test_case_level=${log_level}
    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
    Set Suite Variable    ${epc_log_path}    ${LOG_PATH}/${time_stamp}/
    Create directory    ${epc_log_path}

Common Suite Teardown for COAM
    [Arguments]    ${localFilePath_default}=${swconfig_default}
    Connect to gnb coam via ssl
#    COAM Download scf from cluster    scf_dir_path=${epc_log_path}
#    COAM Save snapshot via rest api    log_path=${epc_log_path}

restore swConfig to default
    [Arguments]     ${localFilePath}
    Update the swconfig file    localFilePath=${localFilePath}

Tests Recover SA
    [Arguments]
    run keyword if    '${release_info}' == 'SBTS21B'    Adjust the attenuation value for HBTE    value_1=${${${att_value}}[0]}
    ...    value_2=${${${att_value}}[0]}    value_3=${${${att_value}}[0]}    value_4=${${${att_value}}[0]}
    ...    ELSE    Adjust the attenuation value for HBTE    value_1=${${${att_value}}[0]}
    ...    value_2=${${${att_value}}[0]}    value_3=${${${att_value}}[0]}    value_4=${${${att_value}}[0]}
    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist}    parameter=administrativeState     value=unlocked
    lock or unlock enb for sa set    cell_status=unlocked    enb_cell_id=${11}
    sleep     5s
    Connect to EPC APP
    Power UE stop dl traffic
    sleep     3s
    Get product brand
    Power UE Detach
    disconect all connections

Tests Recover NSA
    Power UE stop traffic and detach
    sleep     3s
    Get product brand
    Update the swconfig file  gnb_index=${0}    localFilePath=${swconfig_default}
    disconect all connections

disconect all connections
    run keyword and ignore error    csn.disconnect    connection=TestPC
    run keyword and ignore error     coam.teardown    connection=GNB_OAM
    run keyword and ignore error     csn.disconnect    connection=ASIK

##prepare BTS##
Lock the eNB cell
    Connect and Modify the parameter on enblte    dist_name=${eNB_cell1_distname}   parameter=${eNB_parameter}     value=locked

lock or unlock enb for sa set
    [Arguments]    ${cell_status}=locked    ${enb_cell_id}=${1}    ${enb_index}=${0}
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${tl.enbs[${enb_index}].instance_id}/LNBTS-${tl.enbs[${enb_index}].instance_id}/LNCEL-${enb_cell_id}
    ...    parameter=administrativeState
    ...    value=${cell_status}
    sleep    10s

Prepare testline to cell onair for NSA
    [Arguments]      ${localFilePath}    ${tl_scf_filename}    ${tl_scf_dir_path}=${tl_scf_dir_path}    ${gnb_index}=${0}
    Update the swconfig file  gnb_index=${gnb_index}    localFilePath=${localFilePath}
    Prepare with COAM classical BTS cell onair for NSA    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_filename=${tl_scf_filename}

Prepare testline to cell onair for SA
    [Arguments]     ${localFilePath}    ${tl_scf_filename}    ${tl_scf_dir_path}=${tl_scf_dir_path}      ${gnb_index}=${0}
    ...          ${bts_host}=${gnb0_BTS_host}    ${username}=${gnb_BTS_username}    ${password}=${gnb_BTS_password}
    Update the swconfig file    gnb_index=${gnb_index}    localFilePath=${localFilePath}
    Prepare with COAM classical BTS cell onair for SA    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_filename=${tl_scf_filename}
    ...    bts_host=${bts_host}    username=${username}    password=${password}

Update the swconfig file
    [Arguments]    ${localFilePath}    ${gnb_index}=${0}
    wait until keyword succeeds    5min    10s    Connect to Classical Common Unit Master gnb   gnb_index=${gnb_index}
    SWConfig.Upload SwConfig File To Asik And Crasign     localFilePath=${localFilePath}    asik_alias=ASIK Master
    [Teardown]      run keyword and ignore error      Csn.disconnect      connection=ASIK Master

Prepare with COAM classical BTS cell onair for NSA
    [Arguments]    ${tl_scf_dir_path}    ${tl_scf_filename}    ${bts_host}=${gnb0_BTS_host}    ${username}=${gnb_BTS_username}
    ...    ${password}=${gnb_BTS_password}
    Perform full commission for COAM gnb     scf=${tl_scf_dir_path}${tl_scf_filename}
      ...    gnb_ip=${bts_host}    username=${username}    password=${password}
    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=locked
    COAM Wait for gnb ready    bts_host=${bts_host}    username=${username}    password=${password}
    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=unlocked
    wait until keyword succeeds    10min    30s    COAM Check GNB cell on air
    [Teardown]    COAM Teardown gnb connections

Prepare with COAM classical BTS cell onair for SA
      [Arguments]    ${tl_scf_dir_path}    ${tl_scf_filename}    ${bts_host}=${gnb0_BTS_host}    ${username}=${gnb_BTS_username}
    ...    ${password}=${gnb_BTS_password}
      Perform full commission for COAM gnb     scf=${tl_scf_dir_path}${tl_scf_filename}
      ...    gnb_ip=${bts_host}    username=${username}    password=${password}
      COAM Wait for gnb ready    bts_host=${bts_host}    username=${username}    password=${password}
      Wait Until Keyword Succeeds     10min     30s     COAM Check GNB cell on air
      [Teardown]    COAM Teardown gnb connections

Perform full commission for COAM gnb
    [Arguments]    ${scf}    ${gnb_ip}    ${username}    ${password}
    Connect to gnb coam via ssl   bts_host=${gnb_ip}    username=${username}      password=${password}
    COAM Commission with scf file    scf_file_path=${scf}    timeout=500    is_pdl_checking_needed=${False}
    [Teardown]    COAM Teardown gnb connections

COAM Wait for gnb ready
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

Connect to Classical Common Unit Master gnb
    [Arguments]    ${gnb_index}=${0}    ${du_index}=${0}    ${alias}=ASIK Master
    ${gnbs}    testline_info.get_classicalbts_gnbs    tl=${tl}
    ssh.Connect to    hostname=${gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...               username=${gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...               password=${gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...               alias=${alias}
Adjust the attenuation value for HBTE
    [Arguments]      ${value_1}    ${value_2}    ${value_3}    ${value_4}
    [Documentation]    Auther:cris.cai@nokia-sbell.com
    ...                modify HBTE PA 4 port value default value[0-63db] if not set the max_attenuation value below
    ...                for value and not default port 1234, plz set in your case level. setup connection only port1
    ...                if connect on local plz disconnect firstly
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${HBTE_max_value}    vendor=${vendor}
    att.set_attenuation     port=${att_port_1}    value=${value_1}
    att.set_attenuation     port=${att_port_2}    value=${value_2}
    att.set_attenuation     port=${att_port_3}    value=${value_3}
    att.set_attenuation     port=${att_port_4}    value=${value_4}
    ${value_port1}    att.read_attenuation    port=${att_port_1}
    should be equal    ${value_port1}    ${value_1}
    ${value_port2}    att.read_attenuation    port=${att_port_2}
    should be equal    ${value_port2}    ${value_2}
    ${value_port3}    att.read_attenuation    port=${att_port_3}
    should be equal    ${value_port3}    ${value_3}
    ${value_port4}    att.read_attenuation    port=${att_port_4}
    should be equal    ${value_port4}    ${value_4}

Adjust the TopYong Attenuation Value
    [Arguments]    ${ports}    ${value}
    atten.connect to    ip=${att_ipaddr}
    atten.get_value    channel=${ports}
    atten.set_value    channel=${ports}    value=${value}
    atten.disconnect

Record the counter action timer
    @{utc0} =    Get Time    hour min sec    UTC
    ${utc0_min} =    convert to integer  ${utc0}[1]
    ${utc_min} =    Evaluate    ${utc0_min}%5
    Run Keyword If    ${utc_min}>3.5    Record time again
    ${utc_left} =    Evaluate    5-${utc_min}+1
    set suite variable    ${utc_left}

Record time again
    sleep    1min
    @{utc0} =    Get Time    hour min sec    UTC
    ${utc0_min} =    convert to integer  ${utc0}[1]
    ${utc_min} =    Evaluate    ${utc0_min}%5
    Set Suite Variable    ${utc_min}

Check PM counter with sort list
    [Arguments]    ${counter_id}    ${full_path}    ${date}=all
    Connect to gnb coam via ssl
    ${result} =    get_pm_counter_values    counter_id=${counter_id}    connection=GNB_OAM
    ...    dic_path=${full_path}    date=${date}
    Sort list    ${result}
    [Return]    ${result}
    [Teardown]    COAM Teardown gnb connections

###log capture###
##BIPlog##
Catch Bip log on 20B
    [Arguments]    ${script_path}    ${capturing_time_seconds}=3    ${gnb_index}=${0}
    Connect to Classical Common Unit Master gnb    gnb_index=${gnb_index}
    Precondition for bip capture with gnbMirroring scripts    script_path=${script_path}
    Bip Capture with gnbMirroring scripts 1856    gnb_index=${gnb_index}    capturing_time_seconds=${capturing_time_seconds}

Bip Capture with gnbMirroring scripts 1856
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

Preconfdition for Bip Capture trunk
    [Arguments]     ${mirror_mode}     ${hw_slot}=${1}    ${HW_TYPE}=ASIB
    Connect to Capacity Unit Loner with hostname    alias=ABIL Loner    hw_slot=${hw_slot}
    ${hwindex_asib}=    HW slot for asib capture    hw_slot=${hw_slot}
    detectHwAndStartMirroring    asik_alias=Common Master    loner_alias=ABIL Loner   mirror_mode=${mirror_mode}
    ...    sw_release=${HW_TYPE}    hw_index=${hwindex_asib}

BIP logs download from ASIB to UTE
    [Arguments]    ${logname}     ${gnb_index}=${0}    ${connection}=ABIL Master    ${hw_slot}=${1}
    Connect to Capacity Unit Master with hostname    gnb_index=${gnb_index}    hw_slot=${hw_slot}
    sleep    5s
    csn.download_file   remote_path=${gnb_path}${logname}   local_path=${epc_log_path}${logname}   connection=${connection}

#TTItraces#
Start To Capture Wireshark Logs
    [Arguments]     ${filename}    ${connection}    ${interface}
    ...    ${asik_addr}=${asik_addr_0}    ${asik_username}=${asik_username}    ${asik_password}=${asik_password}
    gNB connections    asik_addr=${asik_addr}    asik_username=${asik_username}    asik_password=${asik_password}
    csn.send command    command=tcpdump sctp -i ${interface} -w ${gnb_path}${filename}   connection=${connection}

Stop and download wireshark Logs
    [Arguments]    ${logname}    ${connection}
    ...        ${asik_addr}=${asik_addr_0}    ${asik_username}=${asik_username}    ${asik_password}=${asik_password}
    gNB connections    asik_addr=${asik_addr}    asik_username=${asik_username}    asik_password=${asik_password}
    csn.send command    command=killall tcpdump     connection=${connection}
    sleep    3
    csn.download_file   remote_path=${gnb_path}${logname}   local_path=${epc_log_path}${logname}   connection=${connection}
    sleep    3

gNB connections
    [Arguments]    ${asik_addr}=${asik_addr}    ${asik_username}=${asik_username}    ${asik_password}=${asik_password}
    csn.Connect To    hostname=${asik_addr}
    ...               username=${asik_username}
    ...               password=${asik_password}
    ...               alias=gnb

##UE##
Power UE Precondition
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    capatibility_index=${0}    reset_sol=pc_reset    detach_request=${true}

Power UE Attach and Verify attach
    [Arguments]    ${4g_check}    ${gnb_index}=${0}
     ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${0}    gnb_index=${gnb_index}
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    ue_index=${0}    gnb_index=${gnb_index}
    ...                       4G_check=${4g_check}    5Gstatus=PASS

Power UE Start traffic and check throughput
    [Arguments]    ${dl_throughput}    ${Expect_DOWNLINK}    ${duration}=${DL_TIME}    ${dl_length}=${DL_LENGTH}    ${dl_port}=${DL_PORT}
    ...    ${ue_index}=${0}    ${gnb_index}=${0}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_throughput}    duration=${duration}
    ...                       iperf_port=${dl_port}    ue_index=${0}    cap_index=${0}    buffer_size=${dl_length}
    sleep    5s
    wait until keyword succeeds    2min    10s    power_ue.Check throughput    ue_type=${ue_type}    direction=dl    throughput=${Expect_DOWNLINK}
    ...    ue_index=${ue_index}    hw_slot=1    sample=${10}    start_offset=${3}    sleep_time=${5}    cellid=${EMPTY}    gnb_index=${gnb_index}

Power UE stop dl traffic and detach
    [Arguments]    ${dl_port}=${DL_PORT}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    iperf_port=${dl_port}
    sleep    3s
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}

Power UE check throughput
    [Arguments]    ${Expect_DOWNLINK}    ${ue_index}=${0}    ${gnb_index}=${0}
#    wait until keyword succeeds    2min    10s    power_ue.Check throughput    ue_type=${ue_type}    direction=dl    throughput=${Expect_DOWNLINK}
#    ...    ue_index=${ue_index}    hw_slot=1    sample=${10}    start_offset=${3}    sleep_time=${5}    cellid=${EMPTY}    gnb_index=${gnb_index}
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=5m
    ${list_of_cell_ids}    Create list    5816321
    Power_ue.Check Tput    ue_type=${ue_type}    direction=DL    log=${tput_log}    cells=${list_of_cell_ids}
    ...    target_throughput=${Expect_DOWNLINK}


Power UE stop dl traffic
    [Arguments]    ${dl_port}=${DL_PORT}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    iperf_port=${dl_port}

Power UE Start ul traffic and check throughput
        [Arguments]    ${ul_throughput}    ${Expect_DOWNLINK}    ${duration}=${UL_TIME}    ${ul_length}=${UL_LENGTH}    ${ul_port}=${UL_PORT}
    ...    ${ue_index}=${0}    ${gnb_index}=${0}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_throughput}    duration=${duration}
    ...                       iperf_port=${ul_port}    ue_index=${0}    cap_index=${0}    buffer_size=${ul_length}
    sleep    5s
    wait until keyword succeeds    2min    10s    power_ue.Check throughput    ue_type=${ue_type}    direction=ul    throughput=${Expect_DOWNLINK}
    ...    ue_index=${ue_index}    hw_slot=1    sample=${10}    start_offset=${3}    sleep_time=${5}    cellid=${EMPTY}    gnb_index=${gnb_index}

Power UE Detach
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}

Power UE stop traffic and detach
    [Arguments]    ${dl_port}=${DL_PORT}    ${ul_port}=${UL_PORT}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    iperf_port=${dl_port}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    iperf_port=${ul_port}
    sleep    3s
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}

##stream parameter##
Case variable set for ${case_key}
    test suite variable set for ${case_key}
#    Set Test Tag

test suite variable set for ${case_key}
    ${release_info}    Get sagnb release
    set suite variable    ${release_info}
    set suite variable    ${qc_id}    ${para_store['${case_key}']['${release_info}']['qc_id']}
    set suite variable    ${att_value}    ${para_store['${case_key}']['${release_info}']['att_value']}
    set suite variable    ${Expect_DOWNLINK}    ${para_store['${case_key}']['${release_info}']['Expect_DOWNLINK']}
    set suite variable    ${scf_file}    ${para_store['${case_key}']['${release_info}']['scf_file']}


Get sagnb release
    [Arguments]   ${host}=${asik_addr_0}   ${username}=${asik_username}   ${password}=${asik_password}
    csn.Connect To   hostname=${host}   username=${username}   password=${password}   alias=release_info
    ${info}   csn.Execute    command=ls /ffs/run/TargetBD*xml   connection=release_info
    ${release_info}     set variable    ${info.split('_')[1]}
    [Return]    ${release_info}
    [Teardown]   csn.Disconnect   connection=release_info

Restart gNB on webUI
    selenium_coam.enable_virtual_display
    selenium_coam.login    ${WEBUI_COAM}    ${WEBUI_NAME}    ${WEBUI_PWD}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    selenium_coam.reset_site
    sleep    8s
    [Teardown]      run keyword and ignore error    selenium_coam.logout

Modify NIDD parameter for 2273
    [Arguments]    ${parameters_to_update}
    Connect to gnb coam via ssl
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters_to_update}
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections
