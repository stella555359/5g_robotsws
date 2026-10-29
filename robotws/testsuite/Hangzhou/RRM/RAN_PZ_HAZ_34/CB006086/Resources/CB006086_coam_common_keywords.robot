*** Settings ***
Documentation
...    author: Rebecca.Liu
...    contact:jia-rebecca.liu@nokia-sbell.com
...    squad group: SG_03
...    feature : CB006086

Library     OperatingSystem
Library     Collections
Library     String
Library     BuiltIn
Library     DateTime
Library     taf.transport.ssh    WITH NAME    csn
Library     taf.sbts.oam.coam.admin   WITH NAME    wmplte
Library     taf.config.scf    WITH NAME    scf
Library    taf.analyzer.pcap      WITH NAME      cap
Library     taf.hw.rf_attenuator    WITH NAME    att
Library     taf.config.testline    WITH NAME    testline
Library     taf.rfrl.common_resources.python.SWConfig    WITH NAME    SWConfig
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    taf/rfrl/common_resources/robot/gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot   #必用#
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
#Library     ../../../../../../../resources/python_libs/check_csv_log.py
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/check_csv_log.py
#Library    ../../../../../resources/python_libs/Attenuation.py
#Library    Attenuation.Attenuation    WITH NAME    atten
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    ../../libraries/biplog_capture/biplog_capture.robot
Resource    ../../libraries/connection_with_hostname.robot
Resource    ../../5GC001856/Resources/5GC001856_coam_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    ../../../../resources/RAN_PZ_HAZ_34/robot/BIP_trace/BIP_trace_collector.robot

*** Variables ***
##BTS##
${MAX_WAIT_TIME_COAM_CONFIGURED}     10 min
${Retry_interval_COAM_CONFIGURED}     30 s
${WEBUI_COAM}                https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_COAM_1}              https://${tl.gnbs[1].cu.oam_http_connection_details.addr}
${gnb0_BTS_host}             ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${gnb1_BTS_host}             ${tl.gnbs[1].cu.oam_ssh_connection_details.addr}
${gnb_BTS_username}          ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gnb_BTS_password}          ${tl.gnbs[0].cu.oam_http_connection_details.password}
${asib_addr_0}                 ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${asib_addr_1}               ${tl.gnbs[1].dus[0].airscale.common_units[0].lmp_connection.addr}
${asib_username}             ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${asib_password}             ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${gnb_instance_0}              ${tl.gnbs[0].instance_id}
${gnb_instance_1}            ${tl.gnbs[1].instance_id}
${ENB_ADDRESS}               ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${enb_instance}              ${tl.enbs[0].instance_id}
${enbcell_dist}              MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-1
${enbcell_dist_TL343}        MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-0
##TEST PC##
${TestPC_addr}               ${tl.test_pc.default_ssh_connection_details.addr}
${TestPC_username}           ${tl.test_pc.default_ssh_connection_details.username}
${TestPC_password}           ${tl.test_pc.default_ssh_connection_details.password}
##PATH##
${TS_LOG_PATH_BASE}          /opt/workspace/CIT/Master/Case_Logs
${gnb_path}                  /tmp/
${localFilePath_default}     opt/workspace/swconfig/sw_default/swconfig.txt
${tshark_path}               /usr/bin/tshark
${LUA_SCRIPT_PATH}           /home/nokia/luashark/generated_luashark/luashark.lua
${enb_path}                  /user/toor4nsn
${scf_log_path}              /opt/workspace/SCF/6086/
##UE##
${ue_type}                   ${tl.ues[0].capabilities[1]}
${appserver_addr}            ${tl.ues[0].iperf_details.ssh_connection_details.addr}
${appserver_username}        ${tl.ues[0].iperf_details.ssh_connection_details.username}
${appserver_password}        ${tl.ues[0].iperf_details.ssh_connection_details.password}
${UE_pc_ip}                  ${tl.ues[0].ssh_connection_details.addr}
${UE_pc_user}                ${tl.ues[0].ssh_connection_details.username}
${UE_pc_password}            ${tl.ues[0].ssh_connection_details.password}
${SN}                        ${tl.ues[0].serial_number}
${DL_PORT}                   ${tl.ues[0].iperf_details.ssh_connection_details.port}
${UL_PORT}                   ${tl.ues[0].iperf_details.port}
${UL_TIME}                   1400
${DL_TIME}                   1400
${DL_LENGTH}                 1024B
${UL_LENGTH}                 1024B
##PA##
${att_ipaddr}                ${tl.attenuator[0].ip_addr}
${att2_ipaddr}               ${tl.attenuator[1].ip_addr}
${att_port_1}                ${tl.attenuator[0].attenuator_ports[5]}
${att_port_2}                ${tl.attenuator[0].attenuator_ports[6]}
${att_port_3}                ${tl.attenuator[0].attenuator_ports[7]}
${att_port_4}                ${tl.attenuator[0].attenuator_ports[8]}
${att_api_port}              ${tl.attenuator[0].port}
${vendor}                    HBTE
${max_attenuation_value}     ${127}
${att_connection_port}       ${tl.attenuator[0].attenuator_ports[5]}
${TOPYONG_ANT1}              ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[0].port_no}
${TOPYONG_ANT2}              ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[1].port_no}
${TOPYONG_ANT3}              ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[2].port_no}
${TOPYONG_ANT4}              ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[3].port_no}
${GNB2_ANT1}                 ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${GNB2_ANT2}                 ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}

*** Keywords ***
##PA##
Common Suite Setup for COAM 6086
    [Arguments]    ${log_level}=${False}
    COAM Create log directory    is_set_to_test_case_level=${log_level}
    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
    Set Suite Variable    ${epc_log_path}    ${LOG_PATH}/${time_stamp}/
    Create directory    ${epc_log_path}

Common Suite Teardown for COAM 6086
    [Arguments]    ${localFilePath_default}=${localFilePath_default}    ${bts_host}=${gnb0_BTS_host}
    ...    ${username}=${gnb_BTS_username}
    ...    ${password}=${gnb_BTS_password}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
    COAM Download scf from cluster    scf_dir_path=${epc_log_path}
    COAM Save snapshot via rest api    log_path=${epc_log_path}
    restore swConfig to default    localFilePath=${localFilePath_default}
    COAM Teardown gnb connections
    CI_interface.Common Case Teardown

Lock gnb cell
    [Arguments]    ${parameters}    ${bts_host}=${gnb1_BTS_host}
    ...    ${username}=${gnb_BTS_username}    ${password}=${gnb_BTS_password}
    Connect to gnb coam via ssl     bts_host=${bts_host}    username=${username}    password=${password}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters}
    COAM Teardown gnb connections

Modify GNB2 SIB5 parameter
    [Arguments]    ${parameters}    ${bts_host}=${gnb1_BTS_host}
    ...    ${username}=${gnb_BTS_username}    ${password}=${gnb_BTS_password}
    Connect to gnb coam via ssl     bts_host=${bts_host}    username=${username}    password=${password}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters}
    COAM Teardown gnb connections

Prepare SA GNB onair with scf and swconfig
    [Arguments]     ${localFilePath}    ${tl_scf_dir_path}    ${tl_scf_filename}      ${gnb_index}=${0}
    ...          ${bts_host}=${gnb0_BTS_host}    ${username}=${gnb_BTS_username}    ${password}=${gnb_BTS_password}
    Update the swconfig file to SA gnb    gnb_index=${gnb_index}    localFilePath=${localFilePath}
    Prepare with COAM classical BTS cell onair SA    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_filename=${tl_scf_filename}
    ...    bts_host=${bts_host}    username=${username}    password=${password}

Update the swconfig file to SA gnb
    [Arguments]      ${localFilePath}    ${gnb_index}=${0}
    wait until keyword succeeds    5min    10s    Connect to Classical Common Unit Master gnb    gnb_index=${gnb_index}
    SWConfig.Upload SwConfig File To Asik And Crasign     localFilePath=${localFilePath}    asik_alias=ASIK Master
    [Teardown]      run keyword and ignore error      Csn.disconnect      connection=ASIK Master


##wireshark log##
Stop wireshark Logs teardown
    [Arguments]    ${connection}    ${asik_addr}=${asik_addr}    ${asik_username}=${asik_username}    ${asik_password}=${asik_password}
    gNB connections    asik_addr=${asik_addr}    asik_username=${asik_username}    asik_password=${asik_password}
    csn.send command    command=killall tcpdump     connection=${connection}

##UE##
Start power UE dlul traffic and check throughput
    [Arguments]    ${dl_throughput}    ${ul_throughput}    ${Expect_DOWNLINK}    ${Expect_UPLINK}    ${dl_duration}=${dl_time}
    ...    ${ul_duration}=${ul_time}    ${dl_length}=${DL_LENGTH}    ${ul_length}=${UL_LENGTH}    ${dl_port}=${DL_PORT}    ${ul_port}=${UL_PORT}
    ...          ${ue_type}=huawei    ${ue_index}=${0}    ${gnb_index}=${0}
#    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_throughput}    duration=${dl_duration}
#    ...                       iperf_port=${dl_port}    ue_index=${0}    cap_index=${0}    buffer_size=${dl_length}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_throughput}    duration=${ul_duration}
    ...                       iperf_port=${ul_port}    ue_index=${0}    cap_index=${0}    buffer_size=${ul_length}    iperf_type=via_command
    sleep    5s
#    wait until keyword succeeds    2min    10s    power_ue.Check throughput    ue_type=${ue_type}    direction=dl    throughput=${Expect_DOWNLINK}
#    ...    ue_index=${ue_index}    hw_slot=1    sample=${10}    start_offset=${3}    sleep_time=${5}    cellid=${EMPTY}    gnb_index=${gnb_index}
    wait until keyword succeeds    2min    10s    power_ue.Check throughput    ue_type=${ue_type}    direction=ul    throughput=${Expect_UPLINK}
    ...    ue_index=${ue_index}    hw_slot=1    sample=${10}    start_offset=${3}    sleep_time=${5}    cellid=${EMPTY}    gnb_index=${gnb_index}

Check ul and dl throughput
    [Arguments]    ${Expect_DOWNLINK}    ${Expect_UPLINK}    ${ue_type}=huawei     ${ue_index}=${0}    ${gnb_index}=${0}
#    wait until keyword succeeds    2min    10s    power_ue.Check throughput    ue_type=${ue_type}    direction=dl    throughput=${Expect_DOWNLINK}
#    ...    ue_index=${ue_index}    hw_slot=1    sample=${10}    start_offset=${3}    sleep_time=${5}    cellid=${EMPTY}    gnb_index=${gnb_index}
    wait until keyword succeeds    2min    10s    power_ue.Check throughput    ue_type=${ue_type}    direction=ul    throughput=${Expect_UPLINK}
    ...    ue_index=${ue_index}    hw_slot=1    sample=${10}    start_offset=${3}    sleep_time=${5}    cellid=${EMPTY}    gnb_index=${gnb_index}

Stop power UE uldl traffic and detach
    [Arguments]     ${dl_port}    ${ul_port}     ${ue_type}=huawei
#    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    iperf_port=${dl_port}
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
    set suite variable    ${gnb_index}    ${para_store['${case_key}']['${release_info}']['gnb_index']}
    set suite variable    ${att_value}    ${para_store['${case_key}']['${release_info}']['att_value']}
    set suite variable    ${PARAMS_TO_MODIFY_UNLOCKG}    ${para_store['${case_key}']['${release_info}']['PARAMS_TO_MODIFY_UNLOCKG']}
    set suite variable    ${PARAMS_TO_MODIFY_LOCKG}    ${para_store['${case_key}']['${release_info}']['PARAMS_TO_MODIFY_LOCKG']}
    set suite variable    ${gnb_BTS_host}    ${para_store['${case_key}']['${release_info}']['gnb_BTS_host']}
    set suite variable    ${block_BTS_host}    ${para_store['${case_key}']['${release_info}']['block_BTS_host']}
    set suite variable    ${asib_addr}    ${para_store['${case_key}']['${release_info}']['asib_addr']}
    set suite variable    ${gnb_index_gnb2}    ${para_store['${case_key}']['${release_info}']['gnb_index_gnb2']}
    set suite variable    ${gnb_BTS_host_gnb2}    ${para_store['${case_key}']['${release_info}']['gnb_BTS_host_gnb2']}
    set suite variable    ${gnb_BTS_host_gnb1}    ${para_store['${case_key}']['${release_info}']['gnb_BTS_host_gnb1']}
    set suite variable    ${PARAMS_TO_MODIFY_UNLOCKG_gnb2}    ${para_store['${case_key}']['${release_info}']['PARAMS_TO_MODIFY_UNLOCKG_gnb2']}
    set suite variable    ${PARAMS_TO_MODIFY_LOCKG_gnb2}    ${para_store['${case_key}']['${release_info}']['PARAMS_TO_MODIFY_LOCKG_gnb2']}
    set suite variable    ${PARAMS_TO_MODIFY_UNLOCKG_gnb1}    ${para_store['${case_key}']['${release_info}']['PARAMS_TO_MODIFY_UNLOCKG_gnb1']}
    set suite variable    ${PARAMS_TO_MODIFY_LOCKG_gnb1}    ${para_store['${case_key}']['${release_info}']['PARAMS_TO_MODIFY_LOCKG_gnb1']}
    set suite variable    ${gnb_index_gnb1}    ${para_store['${case_key}']['${release_info}']['gnb_index_gnb1']}
    set suite variable    ${block_BTS_host_gnb2}    ${para_store['${case_key}']['${release_info}']['block_BTS_host_gnb2']}
    set suite variable    ${block_BTS_host_gnb1}    ${para_store['${case_key}']['${release_info}']['block_BTS_host_gnb1']}
    set suite variable    ${asib_addr_gnb2}    ${para_store['${case_key}']['${release_info}']['asib_addr_gnb2']}
    set suite variable    ${hwslot}    ${para_store['${case_key}']['${release_info}']['hwslot']}
    set suite variable    ${asib_addr_gnb1}    ${para_store['${case_key}']['${release_info}']['asib_addr_gnb1']}


Get sagnb release
    [Arguments]   ${host}=${asib_addr_0}   ${username}=${asib_username}   ${password}=${asib_password}
    csn.Connect To   hostname=${host}   username=${username}   password=${password}   alias=release_info
    ${info}   csn.Execute    command=ls /ffs/run/TargetBD*xml   connection=release_info
#    ${release_info}     set variable    ${info.split('_')[4]}
#    ${release_info}     set variable    ${info.split('_')[1]}
    ${release_info}     set variable    ${info.split('_')[1]}_${info.split('_')[2]}_${info.split('_')[3]}
    [Return]    ${release_info}
    [Teardown]   csn.Disconnect   connection=release_info

Tests Recover fit trunk
    [Arguments]
#    run keyword if    '${release_info}' == '5G20A'    Adjust the HBTE attenuation value with attport    value_1=${@{${att_value}}[0]}
#    ...    value_2=${@{${att_value}}[0]}    value_3=${@{${att_value}}[0]}    value_4=${@{${att_value}}[0]}
#    ...    ELSE    TopYong 2ports Attenuation Value set    value1=@{${att_value}}[0]    value2=@{${att_value}}[0]
    Adjust the attenuation value    value_1=${${att_value}}[0]    value_2=${${att_value}}[0]
    Lock gnb cell     parameters=${${PARAMS_TO_MODIFY_UNLOCKG}}    bts_host=${${block_BTS_host}}
    ...    username=${gnb_BTS_username}    password=${gnb_BTS_password}
    Stop wireshark Logs teardown     connection=gnb    asik_addr=${${asib_addr}}    asik_username=${asib_username}    asik_password=${asib_password}
#    Connect and Modify the parameter on enblte    dist_name=${enbcell_dist}    parameter=administrativeState     value=unlocked
    run keyword if    '${release_info}' == 'SBTS22R1_ENB_0000'    Connect and Modify the parameter on enblte     dist_name=${enbcell_dist_TL343}
    ...    parameter=administrativeState     value=unlocked
    ...    ELSE    Connect and Modify the parameter on enblte     dist_name=${enbcell_dist}    parameter=administrativeState     value=unlocked
    sleep     5s
    Connect to EPC APP
    Stop power UE uldl traffic and detach    ue_type=huawei    dl_port=${DL_PORT}    ul_port=${UL_PORT}
    sleep     3s
    Get product brand
    disconect all connections
