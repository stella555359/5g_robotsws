*** Settings ***
Documentation
...    author: yuegong
...    contact: yue.1.gong@nokia-sbell.com
...    squad group: SG_03
...    feature : 5GC001700BA

Library      OperatingSystem
Library      Collections
Library      String
Library      BuiltIn
Library      Telnet

#Library    ../../../../../resources/python_libs/Attenuation.py

Library    taf.analyzer.pcap    WITH NAME    cap
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource     taf/rfrl/common_resources/robot/gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Variables      1700_cases_commission/__init__.py
Library      taf.transport.ssh    WITH NAME    csn
Library      taf.config.scf    WITH NAME    scf
Library      taf.transport.ssh                 WITH NAME       ssh
Library      taf.collectors.btslog
Library      taf.gnb.oam.commissioning    WITH NAME    commissioning
#Library    Attenuation.Attenuation    WITH NAME    atten
Library    taf.hw.rf_attenuator     WITH NAME     attenuator

*** Variables ***
${TS_LOG_PATH_BASE}      /home/ute/workspace/CIT/Master/Case_Logs
${WEBUI_COAM}    https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_NAME}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
${ENB_ADDRESS}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${asik_addr}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${asik_username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${asik_password}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${UE_pc_ip}    ${tl.ues[0].ssh_connection_details.addr}
${UE_pc_user}    ${tl.ues[0].ssh_connection_details.username}
${UE_pc_password}    ${tl.ues[0].ssh_connection_details.password}
${SN}    ${tl.ues[0].serial_number}
${enb_instance}     ${tl.enbs[0].instance_id}
${gnb_instance}     ${tl.gnbs[0].instance_id}
${gnbcell1_dist}    MRBTS-${gnb_instance}/NRBTS-${gnb_instance}/NRCELL-1
${gnbcell2_dist}    MRBTS-${gnb_instance}/NRBTS-${gnb_instance}/NRCELL-2
${enbx2_dist}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNADJGNB-1
${enbx2_para}    administrativeState
${enbmme_dist}    MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNMME-0
${enbmme_para}    ipAddrPrim
${enbmme_para2}    administrativeState
${realepc_ip}    10.57.164.140
${f1_sctp_port}    38472
${x2_sctp_port}    29211
${gnb_path}    /tmp/

${atten_ip}    ${tl.attenuator[0].ip_addr}
${atten2_ip}    ${tl.attenuator[1].ip_addr}
${5GRU1_ANT1}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${5GRU1_ANT2}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${5GRU1_ANT3}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
${5GRU1_ANT4}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
${5GRU2_ANT1}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[0].port_no}
${5GRU2_ANT2}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[1].port_no}
${5GRU3_ANT1}    ${tl.gnbs[0].dus[0].rus[2].attenuation_ports[0].port_no}
${fsp2a_addr}    ${tl.gnbs[0].dus[0].airscale.common_units[0].capacity_units[1].addr}
@{attenuation_port_numbers}    ${5GRU1_ANT1}    ${5GRU1_ANT2}    ${5GRU1_ANT3}    ${5GRU1_ANT4}
${max_attenuation_value}    ${120}
${ue_poweron}    AT+CFUN=1
${ue_poweroff}    AT+CFUN=0
${tl_scf_dir_path}    /home/ute/workspace/CIT/Master/SCF_file/
${tl_scf_filename}    Configuration_scf_MRBTS-tl234.xml
${att_api_port}    ${tl.attenuator[0].port}
${vendor}          ${tl.attenuator[0].vendor}

${ul_port}    53234
${dl_port}    54234
${ul_time}    600
${ul_length}    1024B
${ul_throughput}     5M
${dl_time}    600
${dl_length}    1024B
${dl_throughput}    10M
${ul_expect}    0
${dl_expect}    0

*** Keywords ***
Common Suite Setup for COAM
    COAM Create log directory    is_set_to_test_case_level=${False}
    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
    Set Suite Variable    ${epc_log_path}    ${LOG_PATH}/${time_stamp}/
    Create directory    ${epc_log_path}

Common Suite Teardown for COAM
    Connect to gnb coam via ssl
    COAM Download scf from cluster    scf_dir_path=${epc_log_path}
    COAM Save snapshot via rest api    log_path=${epc_log_path}
    COAM Teardown gnb connections


Precondition for UE control PC
    [Arguments]    ${ue_num}=1
    FOR    ${i}    IN RANGE    0    ${ue_num}
        Reset UE Control PC    ue_index=${i}
    END

Start Capture Classical x2_WS Logs
    [Arguments]    ${x2logname}
    RUN KEYWORD AND IGNORE ERROR    gNB connections
    Start To Capture Wireshark Logs    filename=${x2logname}    connection=gnb    interface=fp0


Stop and Save classical x2_WS Logs
    [Arguments]    ${x2logname}
    gNB connections
    Stop and download Logs    logname=${x2logname}    connection=gnb


Modify the COAM parameter with admin API
    [Arguments]    ${parameters}
    Connect to gnb coam via ssl
    COAM Update several parameters via rest api    parameters=${parameters}
    COAM Teardown gnb connections

Close iperf progress
    [Arguments]    ${ue_index}=${0}    ${dl_port}=${dl_port}    ${ul_port}=${ul_port}
    Close the iperf process on APPserver    dl_port=${dl_port}
    Close the iperf process on APPserver    ul_port=${ul_port}
    Close the iperf process on Qualcomm    ue_index=${ue_index}




##Qualcomm keyword
Verify 5GRACH success times on gnb side
    [Arguments]    ${abil}=asp1a    ${gnb_index}=1
    wait until keyword succeeds    1 min    10 sec    Connect to BB${gnb_index} master     alias=asik
    wait until keyword succeeds    1 min    10 sec    Connect to ${abil}    alias=${abil}    proxy=asik
    ${output} =    csn.execute    command=journalctl -b | grep "flow control starts" |grep -v grep
    ...                           connection=${abil}
    run keyword and ignore error    csn.disconnect    connection=${abil}
    run keyword and ignore error    csn.disconnect    connection=asik
    @{list}    split string    ${output}    \n
    ${len} =    Get Length    ${list}
    [return]    ${len}

gNB connections
    csn.Connect To    hostname=${asik_addr}
    ...               username=${asik_username}
    ...               password=${asik_password}
    ...               alias=gnb

enb connections
    csn.Connect To    hostname=${ENB_ADDRESS}
    ...               username=${asik_username}
    ...               password=${asik_password}
    ...               alias=enb

Prepare the classical COAM BTS cell onair
    ${cell_status}    ${cell_value} =    Run Keyword And Ignore Error    Prepare with COMA classical BTS cell onair
    set global variable    ${cell_status}

Prepare with COMA classical BTS cell onair
    Perform full commission for COAM gnb
    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=locked
    Check gnb COAM classical start normally
    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=unlocked
    Check the gnb cell status onair    cell_no=2

Check the COAM gnb cell status onair
    Connect to gnb coam via ssl
    wait until keyword succeeds    10min   30s    COAM Check GNB cell on air
    [Teardown]    COAM Teardown gnb connections

Check the gnb cell status onair
    [Arguments]    ${gnb_ip}=${WEBUI_COAM}    ${cell_no}=1
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}      username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${is_startup_window_exist} =      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window

    wait until keyword succeeds    5min    30s    Get all cell info    cell_no=${cell_no}
    [Teardown]    selenium_coam.logout

Get all cell info
    [Arguments]    ${cell_no}
    FOR   ${cell_idx}    IN     1    ${cell_no}
        Get cell info    cell_idx=${cell_idx}
    END


Get cell info
    [Arguments]    ${cell_idx}=1
    ${cell1_status} =    selenium_coam.get_cell_info    cell_idx=${cell_idx}
    Get info status check    info_status=${cell1_status}

Perform full commission for COAM gnb
    [Arguments]    ${scf}=${tl_scf_dir_path}${tl_scf_filename}
    ...            ${gnb_ip}=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    Connect to gnb coam via ssl   bts_host=${gnb_ip}
    COAM Commission with scf file    scf_file_path=${scf}    timeout=500    is_pdl_checking_needed=${False}
    COAM Teardown gnb connections

Start Capture Classical enb x2 Logs
    [Arguments]    ${x2logname}
    RUN KEYWORD AND IGNORE ERROR    enb connections
    Start To Capture Wireshark Logs    filename=${x2logname}    connection=enb    interface=br1
    sleep    3s

Start To Capture Wireshark Logs
    [Arguments]     ${filename}    ${connection}    ${interface}
    csn.send command    command=tcpdump sctp -i ${interface} -w ${gnb_path}${filename}   connection=${connection}
    sleep    3s

Stop and Save classical x2 Logs
    [Arguments]    ${x2logname}
    gNB connections
    Stop and download Logs    logname=${x2logname}    connection=gnb

Stop and Save classical enb x2 Logs
    [Arguments]    ${x2logname}
    enb connections
    Stop and download Logs    logname=${x2logname}    connection=enb

Stop and download Logs
    [Arguments]    ${logname}    ${connection}
    csn.send command    command=killall tcpdump     connection=${connection}
    sleep    3
    csn.download_file   remote_path=${gnb_path}${logname}   local_path=${epc_log_path}${logname}
    ...    connection=${connection}
    sleep    3

Check gnb COAM classical start normally
    sleep    1min
    Check the gnb RU status ready

Check the sctp port UP
    [Arguments]    ${port_num}
    Connect to BB1 master    alias=BB1
    csn.sendCommand    command=netstat -anl |grep sctp    connection=BB1
    sleep    3s
    ${sctp_status} =    ssh.read_output    connection=BB1
    csn.disconnect     connection=BB1
    should contain     ${sctp_status}     ${port_num}

#Check the gnb RU status ready
#    selenium_coam.enable_virtual_display
#    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
#    ${ru1_status} =    selenium_coam.get_ru_info    ru_index=1
#    ${ru2_status} =    selenium_coam.get_ru_info    ru_index=2
#    selenium_coam.logout
#    Get info status check    info_status=${ru1_status}
#    Get info status check    info_status=${ru2_status}

Check the gnb RU status ready
    Connect to gnb coam via ssl
    wait until keyword succeeds    15min   30s    COAM Check GNB RU status
    [Teardown]    COAM Teardown gnb connections

Get info status check
    [Arguments]    ${info_status}
    ${Status} =   get from dictionary    ${info_status}    Status
#    ${opr_state} =   get from dictionary    ${Status}    Operational state
#    should be equal    ${opr_state}    Enabled
#    ${avi_state} =   get from dictionary    ${Status}   Availability status
#    should be equal    ${avi_state}    Online
    ${adm_state} =   get from dictionary    ${Status}    Administrative state
    should be equal    ${adm_state}    Unlocked

Check the enb BTS cell onair
    Connect and Modify the parameter on enblte    dist_name=${enbmme_dist}    parameter=${enbmme_para2}
    ...    value=unlocked
    Wait the enb cell status onair

Wait the enb cell status onair
    Connect to eNB via ssl
    wait until keyword succeeds    3min    10s    COAM Check ENB cell on air
    [Teardown]    Enblte close down

COAM Check ENB cell on air
    [Arguments]    ${connection}=enblte
    ${bts_status}    coam.get_bts_statuses    connection=${connection}
    ${enb_cell_status}    Set variable  ${bts_status['proceduralState']}
    Should be equal as strings    ${enb_cell_status}    OnAir    msg=GNB is not on air, Current status is
    ...    ${enb_cell_status}    ignore_case=${True}

Adjust ${RU} Attenuation to ${value}
    Adjust the Attenuation Value    ports=${5G${RU}_ANT1}    value=${value}    attenuation_port_numbers_oneport=${5GRU1_ANT1}
    Adjust the Attenuation Value    ports=${5G${RU}_ANT2}    value=${value}    attenuation_port_numbers_oneport=${5GRU1_ANT2}

Adjust RU1 Attenuation
    [Arguments]    ${value}
    Adjust the Attenuation Value    ports=${5GRU1_ANT1}    value=${value}    attenuation_port_numbers_oneport=${5GRU1_ANT1}
    Adjust the Attenuation Value    ports=${5GRU1_ANT2}    value=${value}    attenuation_port_numbers_oneport=${5GRU1_ANT2}
    Adjust the Attenuation Value    ports=${5GRU1_ANT3}    value=${value}    attenuation_port_numbers_oneport=${5GRU1_ANT3}
    Adjust the Attenuation Value    ports=${5GRU1_ANT4}    value=${value}    attenuation_port_numbers_oneport=${5GRU1_ANT4}

Adjust the Attenuation Value
    [Arguments]     ${ports}    ${value}    ${attenuation_port_numbers_oneport}=${5GRU1_ANT1}
    ...     ${atten_ip}=${atten_ip}    ${att_api_port}=${att_api_port}    ${vendor}=${vendor}
    @{attenuation_port_numbers_oneport}    create list    ${attenuation_port_numbers_oneport}
    attenuator.setup_attenuator    ip_addr=${atten_ip}    port=${att_api_port}
    ...    attenuation_port_numbers=${attenuation_port_numbers_oneport}   max_attenuation=${max_attenuation_value}    vendor=${vendor}
    attenuator.set_attenuation     port=${ports}    value=${value}
    ${value_port_1}    attenuator.read_attenuation    port=${ports}
    should be equal    ${value_port_1}    ${value}
    sleep    5s

#Adjust the Attenuation Value by step
#    [Arguments]    ${port1}    ${port2}    ${port3}    ${port4}    ${start_value}    ${end_value}    ${atten_ip}=${atten_ip}
#    atten.connect to    ip=${atten_ip}
#    atten.get_value    channel=${port1}
#    FOR    ${value}    IN RANGE    ${start_value}    ${end_value}+2    2
#      atten.set_value    channel=${port1}    value=${value}
#      atten.set_value    channel=${port2}    value=${value}
#      atten.set_value    channel=${port3}    value=${value}
#      atten.set_value    channel=${port4}    value=${value}
#      sleep    5s
#    END
#    atten.disconnect

adjust the HBTE attenuation value for one ports
    [Arguments]     ${value_1}    ${att_port_1}    ${atten_ip}=${atten_ip}
    ...    ${att_api_port}=${att_api_port}    ${vendor}=${vendor}    ${attenuation_port_numbers_oneport}=${5GRU2_ANT1}
    @{attenuation_port_numbers_oneport}    create list    ${attenuation_port_numbers_oneport}
    attenuator.setup_attenuator    ip_addr=${atten_ip}    port=${att_api_port}
    ...    attenuation_port_numbers=${attenuation_port_numbers_oneport}   max_attenuation=${max_attenuation_value}    vendor=${vendor}
    attenuator.set_attenuation     port=${att_port_1}    value=${value_1}
    ${value_port_1}    attenuator.read_attenuation    port=${att_port_1}
    should be equal    ${value_port_1}    ${value_1}
    sleep    5s

Adjust the Attenuation Value by step for topyoung
    [Arguments]    ${port1}    ${port2}    ${port3}    ${port4}    ${start_value}    ${end_value}    ${atten_ip}=${atten_ip}
    attenuator.setup_attenuator    ip_addr=${atten_ip}    port=${att_api_port}
    ...    attenuation_port_numbers=${attenuation_port_numbers}   max_attenuation=${max_attenuation_value}    vendor=${vendor}
    FOR    ${value}    IN RANGE    ${start_value}    ${end_value}+2    2
      attenuator.set_attenuation     port=${port1}    value=${value}
      attenuator.set_attenuation     port=${port2}    value=${value}
      attenuator.set_attenuation     port=${port3}    value=${value}
      attenuator.set_attenuation     port=${port4}    value=${value}
      sleep    5s
    END

adjust the HBTE attenuation value for Topyoung
    [Arguments]     ${value_1}     ${value_2}     ${value_3}     ${value_4}
    ...    ${att_port_1}    ${att_port_2}    ${att_port_3}
    ...    ${att_port_4}     ${atten_ip}    ${att_api_port}    ${vendor}    ${attenuation_port_numbers}
    attenuator.setup_attenuator    ip_addr=${atten_ip}    port=${att_api_port}
    ...    attenuation_port_numbers=${attenuation_port_numbers}   max_attenuation=${max_attenuation_value}    vendor=${vendor}
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
    sleep    5s

Tests Recover
    [Arguments]    ${x2logname}
    run keyword and ignore error  Stop and Save classical x2 Logs    x2logname=${x2logname}
    csn.disconnect    connection=gnb

Suite Recovery
    Connect and Modify the parameter on enblte   dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=unlocked
    csn.disconnect    connection=gnb
