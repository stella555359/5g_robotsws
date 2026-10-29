*** Settings ***
Documentation
...    author: Wu Xu
...    contact:xu.wu@nokia-sbell.com
...    squad group: SG_03
...    feature : CB005856

Library     OperatingSystem
Library     Collections
Library     String
Library     BuiltIn
Library     DateTime
Library     taf.transport.ssh    WITH NAME    csn
Library     taf.epcsim    WITH NAME    epc
Library     taf.sbts.oam.coam.admin   WITH NAME    wmplte
Library     taf.config.scf    WITH NAME    scf
Library     taf.selenium.gnb.oam.coam.classical   WITH NAME    selenium_coam
Library     taf.analyzer.pcap   WITH NAME    cap
Library     taf.hw.rf_attenuator    WITH NAME    att
Library     taf.config.testline    WITH NAME    testline
Library     ../../5GC000738/Resources/get_pm_counter.py
Library     taf.hw.mcs    WITH NAME    MCS
#Library     sigspark.SigSpark    WITH NAME    spark
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Library     ../../libraries/L3Call.py
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/check_csv_log.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    ../../libraries/biplog_capture/biplog_capture.robot
Resource    ../../libraries/connection_with_hostname.robot
#Resource      ./TOPYOUNG_MCS_common_keywords.robot
#Resource      ./HAOJIN_MCS_common_keywords.robot
#Resource      ./HBTE_MCS_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
#Variables    ./Stream_parameter.py


*** Variables ***
##PATH##
${TS_LOG_PATH_BASE}         /opt/workspace/CRT/Master/Case_Logs
${tl_scf_dir_path}          /opt/workspace/CIT/Master/SCF_file/
${gnb_path}                 /tmp/
${enb_path}                 /user/toor4nsn
${ttitrace_path}            /ffs/run/config/toor4nsn/eventTrace_log/
${swconfig_default}         /opt/workspace/SCF/swconfig/swconfig.txt
${tshark_path}              /usr/bin/tshark
${LUA_SCRIPT_PATH}          /opt/workspace/luashark/generated_luashark/luashark.lua
##GNB##
${WEBUI_COAM}             https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_NAME}             ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}              ${tl.gnbs[0].cu.oam_http_connection_details.password}
${gnb_BTS_host}           ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${gnb_BTS_username}       ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gnb_BTS_password}       ${tl.gnbs[0].cu.oam_http_connection_details.password}
${asik_addr}              ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${asik_username}          ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${asik_password}          ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${TestPC_addr}            ${tl.test_pc.default_ssh_connection_details.addr}
${TestPC_username}        ${tl.test_pc.default_ssh_connection_details.username}
${TestPC_password}        ${tl.test_pc.default_ssh_connection_details.password}
##5GC simulator##
#${sim5GC_addr}            10.57.150.153
#${sim5GC_username}        ute
#${sim5GC_password}        zxcvbnmP+12
##CentOS PC##
#${CentOSpc_addr}          10.57.150.168
#${CentOSpc_username}      ute
#${CentOSpc_password}      zxcvbnmP+12
#${CentOSpc_addr}          ${tl.ues[1].ssh_connection_details.addr}
#${CentOSpc_username}      ${tl.ues[1].ssh_connection_details.username}
#${CentOSpc_password}      ${tl.ues[1].ssh_connection_details.password}

${gnb_instance}           ${tl.gnbs[0].instance_id}
##ENB##
${ENB_ADDRESS}            ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${enbx2_para}             administrativeState
${enb_instance}           ${tl.enbs[0].instance_id}
${enbx2_dist_TL365}       MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNADJGNB-1
${enbx2_dist_TL362}       MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNADJGNB-0
${enbx2_dist_TL370}       MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNADJGNB-2
${TL365_enb_dist}         MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-1
${TL362_enb_dist}         MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-12
${TL370_enb_dist}         MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-1
${defaultgnbcell}         defaultLnRelGnbCellId
##UE##
${SN}                     ${tl.ues[0].serial_number}
${ue_type}                ${tl.ues[0].capabilities[1]}
${UL_PORT}                ${tl.ues[0].iperf_details.ssh_connection_details.port}
${DL_PORT}                ${tl.ues[0].iperf_details.port}
${ul_throughput}            100M
${dl_throughput}            1300M
${DL_TIME}                  9999
${DL_LENGTH}                1024B
${UL_TIME}                  600
${UL_LENGTH}                1024B
#${NSA_UE_MODE}    NSA
#${SA_UE_MODE}    SA
#${NSA_attach_mode}    5G_NSA
#${SA_attach_mode}    5G_SA
#${NSA_nettype}    NSA
#${SA_nettype}    AUTO
#${NSA_apn_addr}    dxdata2
#${SA_apn_addr}    wap2.nokia.com
# inseego
${CF}                     CONSTRUCTOR_PARAMETERS
${ue_name}                INSEEGO0
${ue_yaml}                ${tl.ues[0]}
${ue_ccc}                 ${ue_yaml['UE_POOLS']['AndroidUePool']['inline_config']['${ue_name}']['${CF}']}
${ue_param}               ${ue_ccc['configuration']}
${askey_SN}               ${ue_ccc['serial_number']}
${askey_hostname}         ${ue_param['ue_pc_ip']}
${askey_username}         ${ue_param['login']}
${askey_password}         ${ue_param['password']}
${iperf_hostname}         ${ue_param['data_transfer']['ssh']['host']}
${iperf_username}         ${ue_param['data_transfer']['ssh']['user']}
${iperf_password}         ${ue_param['data_transfer']['ssh']['password']}
##CentOS PC##
${CentOSpc_addr}          ${ue_param['centOSpc_pc_ip']}
${CentOSpc_username}      ${ue_param['centOSpc_login']}
${CentOSpc_password}      ${ue_param['centOSpc_password']}


*** Keywords ***
##setup and teardown and recovery##
Set suite variables by program
    [Documentation]      This keyword is to set several variables by program.
    ${release_info}    Get sagnb release
    set suite variable    ${release_info}

Common Suite Setup for COAM
    Set suite variables by program
    COAM Create log directory    is_set_to_test_case_level=${False}
    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
    Set Suite Variable    ${epc_log_path}    ${LOG_PATH}/${time_stamp}/
    Create directory    ${epc_log_path}
    set_suite_documentation    doc=||| All test suite log will save in this VM IP:${TestPC_addr} logPath:${epc_log_path}
    ...    append=True

ASKEY UE parameter setup
    [Arguments]  ${ue_index}=${0}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    set suite variable    ${ue_type}
    ${CF}    Set Variable    CONSTRUCTOR_PARAMETERS
    ${ue_name}    Set Variable    INSEEGO${ue_index}
    ${ue_yaml}    Set Variable    ${tl.ues[${ue_index}]}
    ${ue_ccc}     Set Variable    ${ue_yaml['UE_POOLS']['AndroidUePool']['inline_config']['${ue_name}']['${CF}']}
    ${ue_param}    Set Variable    ${ue_ccc['configuration']}
    set suite variable    ${ASKEY_DL_PORT}      ${ue_param['data_transfer']['iperf_options']['qci'][5]}
    set suite variable    ${ASKEY_UL_PORT}      ${ue_param['data_transfer']['iperf_options']['qci'][6]}
    set suite variable    ${askey_SN}           ${ue_ccc['serial_number']}
    set suite variable    ${askey_hostname}     ${ue_param['ue_pc_ip']}
    set suite variable    ${askey_username}     ${ue_param['login']}
    set suite variable    ${askey_password}     ${ue_param['password']}
    set suite variable    ${iperf_hostname}     ${ue_param['data_transfer']['ssh']['host']}
    set suite variable    ${iperf_username}     ${ue_param['data_transfer']['ssh']['user']}
    set suite variable    ${iperf_password}     ${ue_param['data_transfer']['ssh']['password']}
    set suite variable    ${appserver_addr}     ${iperf_hostname}
    set suite variable    ${CentOSpc_addr}      ${ue_param['centOSpc_pc_ip']}
    set suite variable    ${CentOSpc_username}     ${ue_param['centOSpc_login']}
    set suite variable    ${CentOSpc_password}     ${ue_param['centOSpc_password']}

Trigger ASKEY UE reboot
    [Arguments]    ${serial_number}=${askey_SN}
    csn.Connect to    hostname=${askey_hostname}    username=${askey_username}    password=${askey_password}    alias=cygwin
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} reboot    connection=cygwin
    sleep   2s
    csn.disconnect      connection=cygwin

clear cli process
    csn.Connect to    hostname=${askey_hostname}    username=${askey_username}    password=${askey_password}    alias=cygwin
    csn.send command    command=ps -ef | grep cli |grep ute_common_admin | grep -v grep |awk '{print $2}' |xargs kill -9

Common Suite Teardown for COAM
    [Arguments]    ${localFilePath_default}=${swconfig_default}
    disconect all connections
    Connect to gnb coam via ssl
    COAM Download scf from cluster    scf_dir_path=${epc_log_path}
#    COAM Save snapshot via rest api    log_path=${epc_log_path}
    COAM Teardown gnb connections
    CI_interface.Common Case Teardown

restore swConfig to default
    [Arguments]     ${localFilePath}
    Update the swconfig file    localFilePath=${localFilePath}

Tests Recover
    gNB connections    asik_addr=${asik_addr}    asik_username=${asik_username}    asik_password=${asik_password}
    csn.send command    command=killall tcpdump     connection=gnb
    Power UE stop dl traffic
    run keyword and ignore error     Power UE stop ul traffic
    clear cli process
    sleep     3s
    Get product brand
    Power UE Detach
    disconect all connections

disconect all connections
    run keyword and ignore error    csn.disconnect    connection=TestPC
    run keyword and ignore error     coam.teardown    connection=GNB_OAM
    run keyword and ignore error     csn.disconnect    connection=ASIK
    run keyword and ignore error     csn.disconnect    connection=gnb

##prepare BTS##
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

Prepare testline to cell onair for NSA
    [Arguments]      ${localFilePath}    ${tl_scf_filename}    ${tl_scf_dir_path}=${tl_scf_dir_path}    ${gnb_index}=${0}
    ...    ${enbx2_dist}=${enbx2_dist}
    Update the swconfig file  gnb_index=${gnb_index}    localFilePath=${localFilePath}
    Prepare with COAM classical BTS cell onair for NSA    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_filename=${tl_scf_filename}
    ...    enbx2_dist=${enbx2_dist}

Prepare testline to cell onair for SA
    [Arguments]      ${localFilePath}    ${tl_scf_filename}    ${tl_scf_dir_path}=${tl_scf_dir_path}    ${gnb_index}=${0}
    ...     ${bts_host}=${gnb_BTS_host}    ${username}=${gnb_BTS_username}    ${password}=${gnb_BTS_password}
    Update the swconfig file  gnb_index=${gnb_index}    localFilePath=${localFilePath}
    Prepare with COAM classical BTS cell onair for SA    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_filename=${tl_scf_filename}
    ...    bts_host=${bts_host}    username=${username}    password=${password}

Prepare with COAM classical BTS cell onair for SA
    [Arguments]    ${tl_scf_filename}=${tl_scf_filename}  ${bts_host}=${gnb_BTS_host}    ${username}=${gnb_BTS_username}
    ...    ${password}=${gnb_BTS_password}
    Perform full commission for COAM gnb     scf=${tl_scf_dir_path}${tl_scf_filename}
      ...    gnb_ip=${bts_host}    username=${username}    password=${password}
    COAM Wait for gnb ready    bts_host=${bts_host}    username=${username}    password=${password}
    wait until keyword succeeds    10min    30s    COAM Check GNB cell on air

Update the swconfig file
    [Arguments]    ${localFilePath}    ${gnb_index}=${0}
    wait until keyword succeeds    5min    10s    connection_alias_store.Connect to Common Unit Master with gnbindex    gnb_index=${gnb_index}
    ...    alias=ASIK Master
    SWConfig.Upload SwConfig File To Asik And Crasign     localFilePath=${localFilePath}    asik_alias=ASIK Master
    [Teardown]      run keyword and ignore error      Csn.disconnect      connection=ASIK Master

Prepare with COAM classical BTS cell onair for NSA
    [Arguments]    ${tl_scf_dir_path}    ${tl_scf_filename}    ${bts_host}=${gnb_BTS_host}    ${username}=${gnb_BTS_username}
    ...    ${password}=${gnb_BTS_password}
    Perform full commission for COAM gnb     scf=${tl_scf_dir_path}${tl_scf_filename}
      ...    gnb_ip=${bts_host}    username=${username}    password=${password}
    COAM Wait for gnb ready    bts_host=${bts_host}    username=${username}    password=${password}
    wait until keyword succeeds    10min    30s    COAM Check GNB cell on air

Perform full commission for COAM gnb
    [Arguments]    ${scf}    ${gnb_ip}    ${username}    ${password}
    Connect to gnb coam via ssl   bts_host=${gnb_ip}    username=${username}      password=${password}
    COAM Commission with scf file    scf_file_path=${scf}    timeout=500    is_pdl_checking_needed=${False}
    COAM Teardown gnb connections

COAM Wait for gnb ready
    [Timeout]  30 min
    [Arguments]  ${timeout}=10 min    ${connection}=GNB_OAM    ${bts_host}=${bts_host}    ${username}=${username}    ${password}=${password}
    Wait until keyword succeeds    ${timeout}    20 sec    Connect to gnb coam via ssl    connection=${connection}
    ...                    bts_host=${bts_host}
    ...                    username=${username}
    ...                    password=${password}
    Wait until keyword succeeds    ${timeout}    20 sec    COAM Check GNB ASIK status    connection=${connection}
    Wait until keyword succeeds    ${timeout}    20 sec    COAM Check GNB ABIL status    connection=${connection}
    Wait until keyword succeeds    ${timeout}    20 sec    COAM Check GNB RU status    connection=${connection}

Commission SCF to eNB
    [Arguments]    ${eNB_asik_addr}    ${connection}    ${scf_file}
    enblte.connect_to    bts_host=${eNB_asik_addr}
    ...    bts_port=443  use_ssl=True    name=${connection}
    enblte.perform_commissioning    scf_file=${tl_scf_dir_path}${scf_file}    skip_parameter_relation_errors=${True}
    ...     should_activate=${True}    connection=${connection}    timeout=300

Check BTS status
    [Arguments]    ${localFilePath}   ${tl_scf_filename}
    ${cell_status}=    COAM Check GNB cell on air
    RUN KEYWORD IF    '${cell_status}'=='FAIL'    Prepare with COAM classical BTS cell onair for SA
    ...    localFilePath=${localFilePath}   tl_scf_filename=${tl_scf_filename}
    Should be equal    ${cell_status}    PASS

Connect to Classical Common Unit Master gnb
    [Arguments]    ${gnb_index}=${0}    ${du_index}=${0}    ${alias}=ASIK Master
    ${gnbs}    testline_info.get_classicalbts_gnbs    tl=${tl}
    ssh.Connect to    hostname=${gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...               username=${gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...               password=${gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...               alias=${alias}

Connect to Classical Capacity Unit Loner gnb
    [Arguments]    ${gnb_index}=${0}    ${du_index}=${0}    ${hw_slot}=${1}    ${alias}=ABIL Loner    ${asik_alias}=ASIK Master
    Connect to Classical Common Unit Master gnb    gnb_index=${gnb_index}    du_index=${du_index}
    ${hoststr_rlan}    ssh.Execute    command=arp -a| grep 'fsp-.*${hw_slot}c[[:space:]].*rlan.*$'     connection=${asik_alias}
    ${is_hoststr_empty}    run keyword and return status    should be empty    ${hoststr_rlan}
    ${hoststr_eth}    Run Keyword If    ${is_hoststr_empty}
    ...    ssh.Execute    command=arp -a| grep 'fsp-.*${hw_slot}c[[:space:]].*eth.*$'     connection=${asik_alias}
    ${hoststr}    set variable if    ${is_hoststr_empty}    ${hoststr_eth}   ${hoststr_rlan}
    ${hostnames}    Get Hosts From String    ${hoststr}
    ${dus}    testline_info.get_du_list    ${tl}
    ssh.Connect to    hostname=${hostnames}[0]
    ...               username=${dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...               password=${dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...               proxy=${asik_alias}    alias=${alias}

Modify the COAM parameter with admin API
    [Arguments]    ${parameters}    ${bts_host}=${gnb_BTS_host}
    ...    ${username}=${gnb_BTS_username}    ${password}=${gnb_BTS_password}
    Connect to gnb coam via ssl     bts_host=${bts_host}    username=${username}    password=${password}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters}
    COAM Teardown gnb connections

###ENB LOCK UNLOCK###
Lock Unlock Enb Cell
    [Arguments]    ${dist_name}    ${parameter_name}    ${value}
    Connect to eNB via ssl
    Modify the parameter on enblte    dist_name=${dist_name}    parameter_name=${parameter_name}    value=${value}

###log capture###
##Wireshark log##
Start To Capture Wireshark Logs on ASIB
    [Arguments]     ${filename}    ${asik_addr}=${asik_addr}    ${asik_username}=${asik_username}    ${asik_password}=${asik_password}
    ...    ${connection}=gnb    ${interface}=any
    gNB connections    asik_addr=${asik_addr}    asik_username=${asik_username}    asik_password=${asik_password}
    csn.send command    command=tcpdump -i ${interface} sctp -C 30 -w ${gnb_path}${filename}    connection=${connection}

Stop and download wireshark Logs on ASIB
    [Arguments]    ${logname}    ${asik_addr}=${asik_addr}    ${asik_username}=${asik_username}    ${asik_password}=${asik_password}
    ...    ${connection}=gnb
    gNB connections    asik_addr=${asik_addr}    asik_username=${asik_username}    asik_password=${asik_password}
    csn.send command    command=killall tcpdump     connection=${connection}
    sleep    3
    csn.download_file    remote_path=${gnb_path}${logname}    local_path=${epc_log_path}${logname}    connection=${connection}
    sleep    3
    [Teardown]      run keyword and ignore error      Csn.disconnect      connection=${connection}

Start To Capture Wireshark Logs on ASIK
    [Arguments]     ${filename}     ${connection}=ASIK Slave    ${interface}=any
    Connect to Common Unit Slave
    csn.send command    command=tcpdump -i ${interface} sctp -w ${gnb_path}${filename}    connection=${connection}

Stop and download wireshark Logs on ASIK
    [Arguments]    ${logname}    ${connection}=ASIK Slave
    Connect to Common Unit Slave
    csn.send command    command=killall tcpdump     connection=${connection}
    sleep    3
    csn.download_file    remote_path=${gnb_path}${logname}    local_path=${epc_log_path}${logname}    connection=${connection}
    sleep    3
    [Teardown]      run keyword and ignore error      Csn.disconnect      connection=${connection}

gNB connections
    [Arguments]    ${asik_addr}=${asik_addr}    ${asik_username}=${asik_username}    ${asik_password}=${asik_password}
    csn.Connect To    hostname=${asik_addr}
    ...               username=${asik_username}
    ...               password=${asik_password}
    ...               alias=gnb

##BIP log##
Catch Bip log on ASIK
    [Arguments]     ${biplog}    ${connection}=ASIK Master    ${gnb_index}=${0}    ${mirror_mode}=local
    ...            ${bip_interface}=etha01    ${bip_time}=${3}    ${hw_slot}=${1}    ${HW_TYPE}=ASIK
    Preconfdition for Bip Capture ASIK    gnb_index=${gnb_index}    mirror_mode=${mirror_mode}    hw_slot=${hw_slot}    HW_TYPE=${HW_TYPE}
    sleep    3s
    Connect to Classical Common Unit Master gnb    gnb_index=${gnb_index}    alias=ASIK Master
    sleep    3s
    Run keyword if    '${bip_time}'=='infinity'
    ...    csn.Execute    command=tcpdump -i ${bip_interface} -w ${gnb_path}${biplog} -vv
    ...           connection=${connection}
    ...    ELSE    csn.Execute    command=timeout ${bip_time} tcpdump -i ${bip_interface} -C 5M -w ${gnb_path}${biplog} -vv
    ...         connection=${connection}

Catch Bip log on ABIO
    [Arguments]     ${biplog}    ${connection}=ABIL Master    ${gnb_index}=${0}    ${mirror_mode}=local
    ...            ${bip_interface}=eth1    ${bip_time}=${3}    ${HW_TYPE}=ASIB    ${hw_slot}=${1}
    Preconfdition for Bip Capture ABIO     mirror_mode=${mirror_mode}    HW_TYPE=${HW_TYPE}
    sleep    3s
    Connect to Capacity Unit Master with hostname     gnb_index=${gnb_index}     hw_slot=${hw_slot}
    sleep    3s
    Run keyword if    '${bip_time}'=='infinity'
    ...    csn.Execute    command=tcpdump -i ${bip_interface} -w ${gnb_path}${biplog} -vv
    ...           connection=${connection}
    ...    ELSE    csn.Execute    command=timeout ${bip_time} tcpdump -i ${bip_interface} -C 5M -w ${gnb_path}${biplog} -vv
    ...         connection=${connection}
    Run Keyword And Ignore Error    csn.disconnect    connection=Common Master

Preconfdition for Bip Capture ASIK
    [Arguments]     ${mirror_mode}    ${gnb_index}=${0}    ${hw_slot}=${1}    ${HW_TYPE}=ASIK
    Connect to Classical Capacity Unit Loner gnb    gnb_index=${gnb_index}    alias=ABIL Loner    hw_slot=${hw_slot}
    detectHwAndStartMirroring    asik_alias=ASIK Master    loner_alias=ABIL Loner    mirror_mode=${mirror_mode}    hw_index=${hw_slot}
    ...    sw_release=${HW_TYPE}

Preconfdition for Bip Capture ABIO
    [Arguments]     ${mirror_mode}     ${hw_slot}=${1}    ${HW_TYPE}=ASIB
    Connect to Capacity Unit Loner with hostname    alias=ABIL Loner    hw_slot=${hw_slot}
    ${hwindex_asib}=    HW slot for asib capture    hw_slot=${hw_slot}
    detectHwAndStartMirroring    asik_alias=Common Master    loner_alias=ABIL Loner   mirror_mode=${mirror_mode}
    ...    sw_release=${HW_TYPE}    hw_index=${hwindex_asib}
    Run Keyword And Ignore Error    csn.disconnect    connection=Common Master

BIP logs download from ASIK to UTE
    [Arguments]    ${logname}     ${gnb_index}=${0}    ${connection}=ASIK Master
    Connect to Classical Common Unit Master gnb    gnb_index=${gnb_index}
    sleep    5s
    csn.download_file   remote_path=${gnb_path}${logname}   local_path=${epc_log_path}${logname}   connection=${connection}

BIP logs download from ASIB to UTE
    [Arguments]    ${logname}     ${gnb_index}=${0}    ${connection}=ABIL Master    ${hw_slot}=${1}
    Connect to Capacity Unit Master with hostname    gnb_index=${gnb_index}    hw_slot=${hw_slot}
    sleep    5s
    csn.download_file   remote_path=${gnb_path}${logname}   local_path=${epc_log_path}${logname}   connection=${connection}

precondition and capture bip with scripts
    [Arguments]    ${script_path}    ${capturing_time_seconds}=3    ${gnb_index}=${0}
    Connect to Classical Common Unit Master gnb    gnb_index=${gnb_index}
    Precondition for bip capture with gnbMirroring scripts    script_path=${script_path}
    Bip Capture with gnbMirroring scripts 2200     gnb_index=${gnb_index}    capturing_time_seconds=${capturing_time_seconds}

Bip Capture with gnbMirroring scripts 2200
    [Arguments]    ${gnb_index}=${0}    ${connection}=ASIK Master    ${gnb_mirroring}=gnbMirroring.sh
    ...            ${capturing_time_seconds}=infinite
    Connect to Classical Common Unit Master gnb    gnb_index=${gnb_index}
    ${cmd_local}    catenate    sh /ffs/run/config/scripts/${gnb_mirroring} --capturing_time_seconds=${capturing_time_seconds}
    csn.send_command    command=${cmd_local}    connection=${connection}



##UE##
Power UE Precondition
    [Arguments]     ${ue_type}=${ue_type}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    reset_sol=${True}
    Log to console    \nPrepare UE is completed

Power UE Start DL traffic
    [Arguments]    ${dl_throughput}   ${duration}=${DL_TIME}    ${dl_length}=${DL_LENGTH}    ${dl_port}=${DL_PORT}
    ...    ${ue_index}=${0}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_throughput}    duration=${duration}
    ...                       iperf_port=${dl_port}    ue_index=${0}    cap_index=${0}    buffer_size=${dl_length}

Power UE Start UL traffic
    [Arguments]    ${ul_throughput}   ${duration}=${UL_TIME}    ${ul_length}=${UL_LENGTH}    ${ul_port}=${UL_PORT}
    ...    ${ue_index}=${0}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_throughput}    duration=${duration}
    ...                       iperf_port=${ul_port}    ue_index=${0}    cap_index=${0}    buffer_size=${ul_length}

Check the cell DLUL throughput
    [Arguments]      ${cellid}    ${dlexpect}    ${ulexpect}    ${gnb_index}=${0}    ${ue_type}=${ue_type}
    Wait Until Keyword Succeeds   5x    10s    power_ue.Check Throughput    sample=${6}
    ...    ue_type=${ue_type}    direction=dl    throughput=${dlexpect}    cellid=${nrcellid}    sleep_time=${20}
    Wait Until Keyword Succeeds   5x    10s    power_ue.Check Throughput    sample=${6}
    ...    ue_type=${ue_type}    direction=ul    throughput=${ulexpect}    cellid=${nrcellid}    sleep_time=${20}

Power UE check throughput with nrcellid
    [Arguments]    ${cellid}    ${dlexpect}    ${gnb_index}=${0}    ${ue_type}=${ue_type}
    ...    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ${dl_tp_l2l0}    Wait Until Keyword Succeeds   5x    10s    power_ue.Check Throughput    sample=${6}
    ...    ue_type=${ue_type}    direction=dl    throughput=${dlexpect}    cellid=${nrcellid}    sleep_time=${20}
    [Return]     ${dl_tp_l2l0}

Power UE check ul throughput with nrcellid
    [Arguments]    ${cellid}    ${ulexpect}    ${gnb_index}=${0}    ${ue_type}=${ue_type}
    ...    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ${dl_tp_l2l0}    Wait Until Keyword Succeeds   5x    10s    power_ue.Check Throughput    sample=${6}
    ...    ue_type=${ue_type}    direction=ul    throughput=${ulexpect}    cellid=${nrcellid}    sleep_time=${20}
    [Return]     ${dl_tp_l2l0}

Power UE stop dl traffic
    [Arguments]    ${dl_port}=${DL_PORT}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    iperf_port=${dl_port}

Power UE stop ul traffic
    [Arguments]    ${ul_port}=${UL_PORT}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    iperf_port=${ul_port}

Power UE Detach
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}

Power UE stop ul and dl traffic and detach
    [Arguments]    ${dl_port}=${DL_PORT}    ${ul_port}=${UL_PORT}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    iperf_port=${dl_port}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    iperf_port=${ul_port}
    sleep    3s
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}

Power UE stop dl traffic and detach
    [Arguments]    ${dl_port}=${DL_PORT}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    iperf_port=${dl_port}
    sleep    3s
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}

##Multi UE##
Multi UE Detach And Stop Traffic
    FOR    ${ue_no}    IN RANGE    ${ue_num}
        Run Keyword And Continue On Failure    Common UE Detach    ue_index=${ue_no}
        Run Keyword And Continue On Failure    Common Stop traffic    direction=dl    ue_index=${ue_no}    ue_mode=SA
#        Run Keyword And Continue On Failure    Common Stop traffic    direction=ul    ue_index=${ue_no}    ue_mode=SA
    END

Common UE Detach
    [Arguments]    ${ue_index}=${0}
    ${ue_type}    Get UE type    ue_index=${ue_index}
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

Get UE type
    [Arguments]    ${ue_index}=${0}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    [Return]    ${ue_type}

Common Stop traffic
    [Arguments]    ${direction}    ${ue_index}=${0}    ${ue_mode}=SA
    ${ue_type}    Get UE type    ue_index=${ue_index}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=${direction}    ue_index=${ue_index}    ue_mode=${ue_mode}

Multi-UEs attach and Data Transfer
    [Arguments]    ${ue_num}    ${attach_mode}    ${ue_mode}    ${nettpye}   ${apn_address}
    log to console       Attach Multi power ue
    FOR    ${i}    IN RANGE    ${ue_num}
       log to console       Prepare ue${i}
       power_ue.Prepare UE    ue_index=${i}    ue_type=${UE_TYPE}
       log to console       configure UE${i} mode
       spark.Config 5G Deployment    nettype=${nettpye}    ue_alias=UE_${i}
       log to console       UE${i} attach
       ${5Grach_ed}    power_ue.UE Attach    ue_index=${i}     ue_type=${UE_TYPE}   attach_mode=${attach_mode}
       sleep   5s
       power_ue.Verify attach    ue_type=${UE_TYPE}    5Grach_ed=${5Grach_ed}    4G_check=False
       sleep    3s
       log to console      Start traffic    console = yes
#       power_ue.Start traffic    ue_index=${i}    direction=ul    apn_address=${apn_address}
#        ...   throughput=${data_tranfer}    duration=1200    ue_type=${UE_TYPE}    ue_mode=${ue_mode}
#       sleep    3s
       power_ue.Start traffic    ue_index=${i}    direction=dl    apn_address=${apn_address}
        ...   throughput=${data_tranfer}    duration=1200    ue_type=${UE_TYPE}    ue_mode=${ue_mode}
       sleep    5s
       log to console      check throughput  console = yes
       power_ue.Check throughput    ue_type=${UE_TYPE}    direction=dl    throughput=${dltp}    ue_index=${i}
#       power_ue.Check throughput    ue_type=${UE_TYPE}    direction=ul    throughput=${ultp}    ue_index=${i}
    END

Multi-UEs attach
    [Arguments]    ${ue_num}    ${attach_mode}    ${ue_mode}    ${nettpye}   ${apn_address}
    log to console       Attach Multi power ue
    FOR    ${i}    IN RANGE    ${ue_num}
       log to console       Prepare ue${i}
       power_ue.Prepare UE    ue_index=${i}    ue_type=${UE_TYPE}
       log to console       configure UE${i} mode
       spark.Config 5G Deployment    nettype=${nettpye}    ue_alias=UE_${i}
       log to console       UE${i} attach
       ${5Grach_ed}    power_ue.UE Attach    ue_index=${i}     ue_type=${UE_TYPE}   attach_mode=${attach_mode}
       sleep   5s
       power_ue.Verify attach    ue_type=${UE_TYPE}    5Grach_ed=${5Grach_ed}    4G_check=False
    END

##ASKEY##
Power UE Attach and Verify attach for askey
    [Arguments]     ${ue_type}=${ue_type}    ${gnb_index}=${0}
    Log to console    \nStart ot Attach
    Wait until keyword succeeds    4X    5s    attach ue for askey one time    ue_type=${ue_type}    gnb_index=${gnb_index}
    Log to console    \nAttach is succeeded

attach ue for askey one time
    [Arguments]    ${ue_type}=${ue_type}    ${interval}=${1}    ${gnb_index}=${0}
    ${status}    ${5Grach_ed}    run keyword and ignore error    power_ue.UE Attach
    ...    ue_type=${ue_type}   ue_index=${0}    interval=${interval}     gnb_index=${gnb_index}
    At Cmd set IP type
    Wait for CentOSpc getting DL IP
#    ${5Grach_2ed}    run keyword if    '${status}'=='FAIL'    At Cmd UE reAttach    ue_index=${0}
#    ${5Grach_ed}    set variable if    '${status}'=='FAIL'    ${5Grach_2ed}    ${5Grach_ed}
#    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    ue_index=${0}    4G_check=False

Wait for CentOSpc getting DL IP
    Add IP route for CentOSpc
    Send DL packets with iPerf    Data_Size=${64B}    Iperf_Size=${Iperf_Size_64B}    Time=${Sending_Time}
    ...    Packets_Num=${Num_199pps}    Direction=${DL}
    wait until keyword succeeds    ${Waiting_IP}    ${Waiting_Interval}    Check CentOSpc has DL IP
    Add IP route for CentOSpc
    Kill Iperf process on sim5GC
    Kill Iperf process on CentOSpc

Receive DL data on CentOSpc
    [Arguments]     ${Data_Size}    ${connection}=CentOSpc
    CentOSpc connections
    Log to console    \nReceive DL data on CentOSpc
    csn.send command
    ...    command=iperf -s -e -u -p 58651 --udp-histogram=100u,100000,98,99.99 -B 192.168.61.1 -i 1 -o /home/ute/${Data_Size}_DL.txt
    ...    connection=${connection}

Send DL packets with iPerf
    [Arguments]    ${Data_Size}    ${Iperf_Size}     ${Direction}     ${Time}    ${Packets_Num}    ${connection}=UEC
    Connect to UEC    alias=UEC
    Log to console    \nSend ${Direction} packets of ${Data_Size} with iPerf on sim5GC
    csn.send command
    ...       command=iperf -c 192.168.61.1 -u -t ${Time} -e -p 58651 -b ${Packets_Num} -l ${Iperf_Size} --trip-times -B 192.168.61.5 -i 1
    ...       connection=${connection}

Receive UL data on sim5GC
    [Arguments]     ${Data_Size}    ${connection}=UEC
    Connect to UEC    alias=UEC
    Log to console    \nReceive UL data on sim5GC
    csn.send command
    ...    command=iperf -s -e -u -p 58751 --udp-histogram=100u,100000,98,99.99 -B 192.168.61.5 -i 1 -o /home/ute/${Data_Size}_UL.txt
    ...    connection=${connection}

Send UL packets with iPerf on CentOSpc
    [Arguments]    ${Data_Size}    ${Iperf_Size}     ${Direction}     ${Time}    ${Packets_Num}    ${connection}=CentOSpc
    CentOSpc connections
    Log to console    \nSend ${Direction} packets of ${Data_Size} with iPerf on CentOSpc
    csn.send command
    ...       command=iperf -c 192.168.61.5 -u -t ${Time} -e -p 58751 -b ${Packets_Num} -l ${Iperf_Size} --trip-times -B 192.168.61.1 -i 1
    ...       connection=${connection}

Get UE IP with first UE
    [Documentation]    get UE IP
    ...    get inseego/askey UE IP
    [Arguments]    ${ue_index}=${0}
    ${UE_IP}=    Get the UE Ip address    ${ue_index}
    Set Suite Variable    ${UE_IP}    ${UE_IP}

Start DL date transfer on appserver
    [Arguments]    ${ue_index}=${0}    ${DL_port}=${ASKEY_DL_PORT}    ${time}=${DL_TIME}    #${UE_IP}=172.252.65.7
    ...            ${interval}=1    ${traffic}=${dl_throughput}    ${buffer_size}=${DL_LENGTH}
    Get UE IP with first UE    ue_index=${ue_index}
    wait until keyword succeeds    1 min    10 sec    Connect to EPC APP    ue_index=${ue_index}    hostname=${iperf_hostname}
    ...    username=${iperf_username}    password=${iperf_password}
    sleep   2s
    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${DL_port}| awk '{print $2}' |xargs kill -9    connection=EPCAPP
    csn.send_command
    ...    command=iperf -c ${UE_IP} -u -t ${time} -i ${interval} -p ${DL_port} -P 1 -f m -b ${traffic} -l ${buffer_size} -T 64 &
    ...    connection=EPCAPP

Start DL TCP transfer on appserver
    [Arguments]    ${ue_index}=${0}    ${DL_port}=${ASKEY_DL_PORT}
    ...            ${process_num}=${20}    ${time}=${DL_TIME}    ${seg_size}=1400    ${window}=20M
    Get UE IP with first UE    ue_index=${ue_index}
    Connect to control pc via cygwin    ue_index=${ue_index}
    ...     hostname=${askey_hostname}    username=${askey_username}    password=${askey_password}
    csn.send_command    command=taskkill /F /IM iperf.exe &    connection=cygwin    connection=cygwin
    ${pid}    wait until keyword succeeds    10s    1s    csn.Read Output    connection=cygwin
    sleep    2s
    csn.send_command    command=cmd /c iperf.exe -s -i 1 -p ${DL_port} -w 20M &    connection=cygwin
    sleep    1s
    wait until keyword succeeds    1 min    10 sec    Connect to EPC APP    ue_index=${ue_index}    hostname=${iperf_hostname}
    ...    username=${iperf_username}    password=${iperf_password}
    sleep   2s
    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${DL_port}| awk '{print $2}' |xargs kill -9    connection=EPCAPP
    sleep    5s
    csn.send_command
    ...    command=iperf -c ${UE_IP} -P ${process_num} -i 1 -l ${seg_size} -t ${time} -p ${DL_port} -M ${seg_size} -w ${window} &
    ...    connection=EPCAPP
    log to console    .....UE_${ue_index} tcp dl iperf start....
    [Teardown]    csn.disconnect      connection=EPCAPP

Stop DL TCP traffic
    [Arguments]    ${port}=${ASKEY_DL_PORT}    ${ue_index}=${0}    ${serial_number}=${askey_SN}
    Connect to control pc via cygwin    ue_index=${ue_index}
    ...     hostname=${askey_hostname}    username=${askey_username}    password=${askey_password}
    csn.send_command    command=taskkill /F /IM iperf.exe &    connection=cygwin    connection=cygwin
    ${pid}    wait until keyword succeeds    10s    1s    csn.Read Output    connection=cygwin
    sleep    3s
    Stop TCP traffic on EPC    ue_index=${ue_index}    port=${port}    hostname=${askey_hostname}    username=${askey_username}
    ...    password=${askey_password}
    [Teardown]    csn.disconnect      connection=cygwin

Stop TCP traffc and detach UE
    [Arguments]    ${port}=${ASKEY_DL_PORT}    ${ue_index}=${0}    ${serial_number}=${askey_SN}    ${ue_type}=${ue_type}
    Stop DL TCP traffic    port=${port}    ue_index=${ue_index}    serial_number=${serial_number}
    sleep    3s
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

Askey UE start UL traffic
    [Arguments]    ${ul_throughput}    ${ue_index}=${0}   ${ul_port}=${ASKEY_UL_PORT}    ${ul_time}=${UL_TIME}
    ...    ${ul_length}=${UL_LENGTH}    ${appserver}=APPserver
    ...    ${serial_number}=${askey_SN}    ${protocol}=udp     ${process_num}=${5}   ${iperf_index}=${1}
    ...    ${cpc_ip}=${askey_hostname}    ${cpc_usrname}=${askey_username}    ${cpc_passwd}=${askey_password}
    Close the iperf process on android ue    ue_index=${ue_index}    iperf_port=${ul_port}    serial_number=${serial_number}
    ...                                      iperf_index=${iperf_index}
    ...                                      cpc_ip=${cpc_ip}    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}
    Connect to control pc enhanced    ue_index=${ue_index}    cpc_ip=${cpc_ip}    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}
    ${cmd_ul_traffic}=    run keyword if    '${appserver}'=='APPserver'       catenate    adb -s ${serial_number} shell
    ...     iperf -c ${appserver_addr} -u -t ${ul_time} -i 1 -p ${ul_port} -P 1 -f m -b ${ul_throughput} -l ${ul_length} -T 64 &
    ...    ELSE IF    '${appserver}'=='APPserversim'     catenate    adb -s ${serial_number} shell
    ...     iperf -c ${appserversim_addr} -u -t ${ul_time} -i 1 -p ${ul_port} -P 1 -f m -b ${ul_throughput} -l ${ul_length} -T 64 &
    run keyword if    '${protocol}'=='udp'    csn.send_command    command=${cmd_ul_traffic}    connection=cpc_${ue_index}
    ...    ELSE IF    '${protocol}'=='tcp'    Start the tcp UL data via iperf    appserver=${appserver}
    ...    serial_number=${serial_number}    ul_time=${ul_time}    ul_port=${ul_port}    ue_index=${ue_index}
    ...    process_num=${process_num}
    sleep    3s
    Check the iperf progress exist    connection=cpc_${ue_index}    port=${ul_port}    ue_sn=${serial_number}   iperf_index=${iperf_index}
    [Teardown]    csn.disconnect    connection=cpc_${ue_index}


Askey UE stop dl traffic on appserver and detach
    [Arguments]    ${ue_index}=${0}    ${DL_port}=${ASKEY_DL_PORT}    ${ue_type}=${ue_type}
    wait until keyword succeeds    1 min    10 sec    Connect to EPC APP    ue_index=${ue_index}    hostname=${iperf_hostname}
    ...    username=${iperf_username}    password=${iperf_password}
    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${DL_port}| awk '{print $2}' |xargs kill -9    connection=EPCAPP
    sleep    1s
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}
    sleep    2s
    [Teardown]    csn.disconnect      connection=EPCAPP

Stop Askey UE UL traffic
    [Arguments]    ${ue_index}=${0}    ${iperf_port}=${ASKEY_UL_PORT}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...        ${iperf_index}=${2}
    ...             ${cpc_ip}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...             ${cpc_usrname}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...             ${cpc_passwd}=${tl.ues[${ue_index}].ssh_connection_details.password}
    Connect to control pc enhanced    ue_index=${ue_index}    cpc_ip=${cpc_ip}    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}
    run keyword and ignore error    csn.send_command
    ...    command=adb -s ${serial_number} shell ps -ef | grep iperf |grep -v grep
    ...    connection=cpc_${ue_index}
    sleep   3s
    ${output_for_debug}    run keyword and ignore error    csn.read_output    size=1000    connection=cpc_${ue_index}
    ${filter_command}    Catenate    ps -ef | grep iperf |grep ${iperf_port} |grep -v grep |awk '{print $${iperf_index}}'
    csn.send_command
    ...    command=adb -s ${serial_number} shell ${filter_command} |xargs adb -s ${serial_number} shell kill -9
    ...    connection=cpc_${ue_index}
    sleep   3s
    csn.send_command    command=adb -s ${serial_number} shell ${filter_command}
    ...    connection=cpc_${ue_index}    timeout=60
    ${output}    csn.read_output    size=1000    connection=cpc_${ue_index}
    should be empty      ${output}
    [Teardown]    Csn.disconnect      connection=cpc_${ue_index}

At Cmd UE reAttach
    [Arguments]    ${ue_index}=${0}    ${gnb_index}=${0}    ${hwcheck_index}=${1}    ${du_index}=0
    ...    ${log_type}=Aasyslog    ${interval}=${1}    &{kwargs}
    [Documentation]    reAttach UE for L3 call test.
    Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
    Aasyslog precondition    gnb_index=${gnb_index}    du_index=${du_index}
    Start the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}    filter=L2   log_name=5Grach.txt
    ${5Gra_l2lo_counter}    ${5Gra_l2lo_timed}    Get 5GRACH success times on gnb side    gnb_index=${gnb_index}
    ...                                                                          hwcheck_index=${hwcheck_index}
    ...                                                                          log_type=${log_type}
    ...                                                                          log_loca=l2lo
    ${5Gra_l2hidu_counter}    ${5Gra_l2hidu_timed}    Get 5GRACH success times on gnb side    gnb_index=${gnb_index}
    ...                                                                          hwcheck_index=${hwcheck_index}
    ...                                                                          log_type=${log_type}
    ...                                                                          log_loca=l2hidu
#    ute_ue.send_at_cmd_to_ue    alias=UE_0    at_cmd=at+cops=1,2,${mcc}${mnc}
    ute_ue.Send At Cmd To Ue   UE_${ue_index}    at_cmd=AT+cgdcont=1,"IP",""
    [Return]    ${5Gra_l2lo_counter}    ${5Gra_l2lo_timed}    ${hwcheck_index}    ${log_type}
    ...    ${5Gra_l2hidu_counter}    ${5Gra_l2hidu_timed}

##QUALCOMM##
Power UE Attach and Verify attach for Qualcomm
    [Arguments]    ${4g_check}    ${ue_type}=${ue_type}    ${gnb_index}=${0}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${0}    gnb_index=${0}    hwcheck_index=${0}
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    ue_index=${0}    gnb_index=${0}
    ...     4G_check=${4g_check}    5Gstatus=PASS

Power UE Precondition for Qualcomm
    [Arguments]     ${ue_type}=${ue_type}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    capatibility_index=${0}    reset_sol=none    detach_request=${true}



##stream parameter##
Case variable set for ${case_key}
    test suite variable set for ${case_key}
#    Set Test Tag

test suite variable set for ${case_key}
    ${release_info}    Get sagnb release
    set suite variable    ${release_info}
    set suite variable    ${scf_disable2200}      ${para_store['${case_key}']['${release_info}']['scf_disable2200']}
    set suite variable    ${scf_enable2200}       ${para_store['${case_key}']['${release_info}']['scf_enable2200']}
    set suite variable    ${att_value}            ${para_store['${case_key}']['${release_info}']['att_value']}
    set suite variable    ${nrcellid}             ${para_store['${case_key}']['${release_info}']['nrcellid']}
    set suite variable    ${enb_dist}             ${para_store['${case_key}']['${release_info}']['enb_dist']}
    set suite variable    ${enbx2_dist}           ${para_store['${case_key}']['${release_info}']['enbx2_dist']}
    set suite variable    ${Expect_ul}            ${para_store['${case_key}']['${release_info}']['Expect_ul']}
    set suite variable    ${mcs_alias}            ${para_store['${case_key}']['${release_info}']['mcs_alias']}
    set suite variable    ${hw_slot}              ${para_store['${case_key}']['${release_info}']['hw_slot']}
    set suite variable    ${Expect_dl_enable}     ${para_store['${case_key}']['${release_info}']['Expect_dl_enable']}
    set suite variable    ${Expect_dl_disable}    ${para_store['${case_key}']['${release_info}']['Expect_dl_disable']}

Select branch and variable for ${case_key}            # 2200C&D
    ${release_info}    Get sagnb release
    set suite variable    ${release_info}
    set suite variable    ${qc_id}    ${para_store['${case_key}']['${release_info}']['qc_id']}
    set suite variable    ${mcs_alias}    ${para_store['${case_key}']['${release_info}']['mcs_alias']}

Get sagnb release
    [Arguments]   ${host}=${asik_addr}   ${username}=${asik_username}   ${password}=${asik_password}
    csn.Connect To   hostname=${host}   username=${username}   password=${password}   alias=release_info
    ${info}   csn.Execute    command=ls /ffs/run/TargetBD*xml   connection=release_info
#    ${release_info}     set variable    ${info.split('_')[4]}
    ${release_info}     set variable    ${info.split('_')[1]}
    [Return]    ${release_info}
    [Teardown]   csn.Disconnect   connection=release_info

Set Test Tag
    Set Tags   QC_${qc_id}

Set nrcellid suit varaible
    [Arguments]    ${cellid}    ${gnb_index}=${0}
    ${nrcellid}    COAM Get nrcellid with the lcrid    lcrid=${cellid}    gnb_index=${gnb_index}
    set suite variable    ${nrcellid}


EPCsim load cfg file
    [Arguments]  ${Edaemon}    ${Egate}
    Restart UEC Edaemon
    Start Edaemon    Edaemon=${Edaemon}
    Start Egate    Egate=${Egate}

Restart UEC Edaemon
     wait until keyword succeeds    10 min    5 sec    Connect to UEC    alias=UEC
     csn.execute    command=sudo killall edaemon    connection=UEC
     csn.execute    command=killall egate    connection=UEC
     csn.execute    command=sudo iptables -F    connection=UEC

Connect to UEC
    [Arguments]    ${alias}=UEC
    csn.Connect to    hostname=${tl.core.default_ssh_connection_details.addr}
    ...    username=${tl.core.default_ssh_connection_details.username}
    ...    password=${tl.core.default_ssh_connection_details.password}    alias=${alias}

Start Edaemon
    [Arguments]    ${edaemon_host}=${tl.core.default_ssh_connection_details.addr}
	...            ${edaemon_path}=${tl.core.dir_path}
	...            ${edaemon_port}=${tl.core.edaemon_port}
	...            ${Edaemon}=${Edaemon}
    epc.setup_edaemon    edaemon_port=${edaemon_port}    host_ip=${edaemon_host}    tool_dir=${edaemon_path}
    ...                  ssh_user=${tl.core.default_ssh_connection_details.username}
    ...                  ssh_pass=${tl.core.default_ssh_connection_details.password}
    ...                  alias=${Edaemon}
    epc.start_edaemon_process    alias=${Edaemon}

Start Egate
    [Arguments]    ${egate_host}=${tl.core.default_ssh_connection_details.addr}
	...            ${egate_path}=${tl.core.dir_path}
    ...	           ${cfg_file}=${tl.core.cfg_filename}
    ...	           ${egate_port}=${tl.core.egate_port}
    ...            ${Egate}=${Egate}
    epc.setup egate    egate_port=${egate_port}    host_ip=${egate_host}    tool_dir=${egate_path}
    ...                ssh_user=${tl.core.default_ssh_connection_details.username}
    ...                ssh_pass=${tl.core.default_ssh_connection_details.password}
    ...                alias=${Egate}
    epc.start egate process    cfg_file=${egate_path}${cfg_file}    timeout=10    alias=${Egate}
    sleep    5s
    Log to console    \nEdeamon and egate starting!\nWait for "S1 link is Up " \nWait for max 600
    epc.Execute egate command                cmd=start
    ...                                      timeout=30
    ...                                      alias=${Egate}

At Cmd set IP type
    [Arguments]  ${ue_index}=${0}
    Log to console    \nAT CMD set IP type
    ute_ue.Send At Cmd To Ue   UE_${ue_index}    at_cmd=AT+cgdcont=1,"IP",""

TestPC connections
    csn.Connect To    hostname=${TestPC_addr}
    ...               username=${TestPC_username}
    ...               password=${TestPC_password}
    ...               alias=TestPC

sim5GC connections
    csn.Connect To    hostname=${sim5GC_addr}
    ...               username=${sim5GC_username}
    ...               password=${sim5GC_password}
    ...               alias=sim5GC

CentOSpc connections
    csn.Connect To    hostname=${CentOSpc_addr}
    ...               username=${CentOSpc_username}
    ...               password=${CentOSpc_password}
    ...               alias=CentOSpc

#Verify STC sends data completely
#    [Arguments]     ${connection}=TestPC
#    TestPC connections
#    Log to console    \nWait for sending data
#    csn.send command    command=ps -ef | grep tclsh |grep -v grep    connection=${connection}
#    ${output}    Csn.read_output    connection=${connection}
#    Should be empty    ${output}

Check STC sends data completely
    Log to console    \nWait for sending data
    ${output} =   run    command=ps -ef | grep tclsh |grep -v grep
    Should be empty    ${output}

Check Iperf sends DL data completely on sim5GC
    [Arguments]     ${connection}=UEC
    Connect to UEC    alias=UEC
    Log to console    \nWait for sending DL data
    ${output}=    csn.execute   command=sudo ps -ef | grep iperf |grep -v grep    connection=${connection}
    Should be empty    ${output}

Check Iperf sends UL data completely on CentOSpc
    [Arguments]     ${connection}=CentOSpc
    CentOSpc connections
    Log to console    \nWait for sending UL data
    ${output}=    csn.execute   command=sudo ps -ef | grep iperf |grep -v grep    connection=${connection}
    Should be empty    ${output}

Set and Check IP on sim5GC
    ${result}=    Run Keyword And Return Status     Check IP is ready on sim5GC
    Run keyword if    '${result}'=='False'    Set IP on sim5GC
    Check IP is ready on sim5GC

Check IP is ready on sim5GC
    [Arguments]     ${connection}=UEC
    Connect to UEC    alias=UEC
    Log to console    \nCheck IP is ready on sim5GC
    ${output}=    csn.execute   command=sudo ip a |grep 192.168.100.32 |grep -v grep   connection=${connection}
    Should not be empty    ${output}

Set IP on sim5GC
    [Arguments]     ${connection}=UEC
    Connect to UEC    alias=UEC
    Log to console    \nSet IP on sim5GC
#    csn.execute   command=sudo ip addr add 192.168.100.32/24 dev ens10   connection=${connection}
    csn.execute   command=sudo ip addr add 192.168.100.32/24 dev enp0s20f0u4   connection=${connection}

Check CentOSpc has DL IP
    [Arguments]     ${connection}=CentOSpc
    CentOSpc connections
    Log to console    \nCheck CentOSpc has DL IP
#    ${output} =   csn.send command    command=sudo ip a |grep 192.168.60.1 |grep -v grep    connection=${connection}
    ${output}=    csn.execute   command=sudo ip a |grep 192.168.61.1 |grep -v grep   connection=${connection}
#    ${output}    Csn.read_output    connection=${connection}
    Should not be empty    ${output}

Add IP route for CentOSpc
    [Arguments]     ${connection}=CentOSpc
    CentOSpc connections
    Log to console    \nAdd IP route for CentOSpc
    #csn.send command    command=sudo ip route add 192.168.61.5 dev enp0s20f0u1    connection=${connection}
    csn.send command    command=sudo ip route add 192.168.61.5/32 via 192.168.61.2 me 10    connection=${connection}
    ${output}=    csn.execute   command=sudo ip route |grep 192.168.61.5 |grep -v grep   connection=${connection}

Adjust HBTE Attenuation to Good
    ${atten_ip} =    set variable     ${tl.attenuator[0].ip_addr}
    adjust the HBTE attenuation value    att_port_1=${att_port_1}    att_port_2=${att_port_2}    atten_ip=${atten_ip}
    ...        value_1=${30}    value_2=${30}

Adjust HBTE Attenuation to Bad
    ${atten_ip} =    set variable     ${tl.attenuator[0].ip_addr}
    adjust the HBTE attenuation value    att_port_1=${att_port_1}    att_port_2=${att_port_2}    atten_ip=${atten_ip}
    ...        value_1=${42}    value_2=${42}

Adjust HBTE Attenuation to Worse
    ${atten_ip} =    set variable     ${tl.attenuator[0].ip_addr}
    adjust the HBTE attenuation value    att_port_1=${att_port_1}    att_port_2=${att_port_2}    atten_ip=${atten_ip}
    ...        value_1=${50}    value_2=${50}

adjust the HBTE attenuation value
    [Arguments]     ${value_1}     ${value_2}
    ...             ${att_port_1}=${att_port_1}    ${att_port_2}=${att_port_2}     ${atten_ip}=${atten_ip}
    [Documentation]    Auther:cris.cai@nokia-sbell.com
    ...                modify HBTE PA value default value[0-63db] if not set the max_attenuation value below
    ...                for value plz set in your case level
    attenuator.setup_attenuator    ip_addr=${atten_ip}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_port_1}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    attenuator.set_attenuation     port=${att_port_1}    value=${value_1}
    attenuator.set_attenuation     port=${att_port_2}    value=${value_2}
    ${value_port_1}    attenuator.read_attenuation    port=${att_port_1}
    should be equal    ${value_port_1}    ${value_1}
    ${value_port_2}    attenuator.read_attenuation    port=${att_port_2}
    should be equal    ${value_port_2}    ${value_2}
    sleep    15s

Clear log path folder
    Log to console    \n Clear log path folder
    run    command=mv ${TS_LOG_PATH_BASE}/STC/* ${TS_LOG_PATH_BASE}/Backup
    sleep    3s

Copy Latency CSV file
    [Arguments]    ${Data_Size}
    Log to console    \nCopy Latency CSV file
    run    command=cp ${TS_LOG_PATH_BASE}/STC/*1_1*.csv ${epc_log_path}${Data_Size}_UL.csv
    run    command=cp ${TS_LOG_PATH_BASE}/STC/*1_2*.csv ${epc_log_path}${Data_Size}_DL.csv

Copy DL Iperf txt file
    [Arguments]    ${Data_Size}     ${connection}=CentOSpc
    CentOSpc connections
    Log to console    \nCopy DL Iperf txt file
    ssh.download_file    /home/ute/${Data_Size}_DL.txt
    ...                  ${epc_log_path}${Data_Size}_DL.txt
    ...                  connection=${connection}
    Log to console    \nKill Iperf process for receiving DL packets
    csn.execute    command=killall iperf   connection=${connection}

Copy UL Iperf txt file
    [Arguments]    ${Data_Size}     ${connection}=UEC
    Connect to UEC    alias=UEC
    Log to console    \nCopy UL Iperf txt file
    ssh.download_file    /home/ute/${Data_Size}_UL.txt
    ...                  ${epc_log_path}${Data_Size}_UL.txt
    ...                  connection=${connection}
    Log to console    \nKill Iperf process for receiving UL packets
    csn.execute    command=killall iperf   connection=${connection}

Kill Iperf process on CentOSpc
    [Arguments]    ${connection}=CentOSpc
    CentOSpc connections
    Log to console    \nKill Iperf process on CentOSpc
    csn.execute    command=killall iperf   connection=${connection}

Kill Iperf process on sim5GC
    [Arguments]    ${connection}=UEC
    Connect to UEC    alias=UEC
    Log to console    \nKill Iperf process on sim5GC
    csn.execute    command=killall iperf   connection=${connection}

Analysis latencylog
    [Arguments]    ${number_of_sending_data}    ${Latency_Criterion}    ${Data_Size}    ${Direction}
    Set Suite Variable    ${CSV_PATH}    ${epc_log_path}${Data_Size}_${Direction}.csv
    ${latency_list}    get_latency_list    file_path=${CSV_PATH}
    ${number_of_latency}    get length    ${latency_list}
    Log to console    \n ${Direction} Number of sending Data: ${number_of_sending_data}
    Log to console    \n ${Direction} Number of received Data: ${number_of_latency}
#    ${receiving_ratio}    Evaluate    float(${number_of_latency})/float(${number_of_sending_data})*100
    ${number_of_sending_data}    convert to number    ${number_of_sending_data}
    ${number_of_latency}    convert to number    ${number_of_latency}
    ${receiving_ratio}    Evaluate    float(${number_of_latency}*100/${number_of_sending_data})
    Log to console    \n ${Direction} Receiving_Ratio: ${receiving_ratio}%
    ${good_latency}    Set variable    ${0}
    FOR     ${lagency}    IN    @{latency_list}
        ${good_latency}    Run keyword if    ${lagency[0]}<${Latency_Criterion}    Evaluate    ${good_latency}+1
        ...   ELSE    set variable    ${good_latency}
    END
    Log to console    \n ${Direction} Number of good_latency: ${good_latency}
    ${good_latency}    convert to number    ${good_latency}
    ${good_latency_ratio}    Evaluate    float(${good_latency}*100/${number_of_sending_data})
    Log to console    \n ${Direction} Good latency Ratio: ${good_latency_ratio}%
    Should be true    ${receiving_ratio}>99
    Should be true    ${good_latency_ratio}>90

Send packets of 64B with STC
    [Arguments]     ${connection}=TestPC
    TestPC connections
    Log to console    \nSend packets of 64B
    csn.send command    command=tclsh ${5856_A01_64B}&    connection=${connection}
#    run    command==tclsh ${5856_A01_64B}&

Send packets of 255B with STC
    [Arguments]     ${connection}=TestPC
    TestPC connections
    Log to console    \nSend packets of 255B
    csn.send command    command=tclsh ${5856_A02_255B}&    connection=${connection}

Send packets of 1400B with STC
    [Arguments]     ${connection}=TestPC
    TestPC connections
    Log to console    \nSend packets of 1400B
    csn.send command    command=tclsh ${5856_A03_1400B}&    connection=${connection}
