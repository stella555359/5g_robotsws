*** Settings ***
Documentation
...    author: Rebecca.Liu & criscai
...    contact:jia-rebecca.liu@nokia-sbell.com
...    squad group: SG_03
...    feature : 5GC001856-L & M

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
#Library     ../../5GC000738/Resources/get_pm_counter.py
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/licence_keeper.py
Library     licence_keeper.licence_keeper     WITH NAME    LK
Library     taf.rfrl.common_resources.python.SWConfig    WITH NAME    SWConfig
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    taf/rfrl/common_resources/robot/gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
#Library     ../../libraries/L3Call.py
Library     ../../libraries/TTI_Trace_Analysis_dl.py
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/check_csv_log.py
Resource    taf/rfrl/common_resources/robot/TTI_Trace.robot
#Library    ../../../../../resources/python_libs/Attenuation.py
#Library    Attenuation.Attenuation    WITH NAME    atten
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
#Variables     ../5GC001856_R/Resources/Parameters/__init__.py
Resource    ../../libraries/biplog_capture/biplog_capture.robot
Resource    ../../libraries/connection_with_hostname.robot

*** Variables ***
${TS_LOG_PATH_BASE}          /opt/workspace/CIT/Master/Case_Logs
${WEBUI_COAM}                https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_COAM_1}                https://${tl.gnbs[1].cu.oam_http_connection_details.addr}
${WEBUI_NAME}                ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_NAME_1}                ${tl.gnbs[1].cu.oam_http_connection_details.username}
${WEBUI_PWD}                 ${tl.gnbs[0].cu.oam_http_connection_details.password}
${WEBUI_PWD_1}                 ${tl.gnbs[1].cu.oam_http_connection_details.password}
${ENB_ADDRESS}               ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${ENB_ADDRESS_1}               ${tl.enbs[1].airscale.common_units[0].lmp_connection.addr}
${asik_addr}                 ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${asik_addr_1}                 ${tl.gnbs[1].dus[0].airscale.common_units[0].lmp_connection.addr}
${asik_username}             ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${asik_username_1}             ${tl.gnbs[1].dus[0].airscale.common_units[0].lmp_connection.username}
${asik_password}             ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${asik_password_1}             ${tl.gnbs[1].dus[0].airscale.common_units[0].lmp_connection.password}
${TestPC_addr}               ${tl.test_pc.default_ssh_connection_details.addr}
${TestPC_username}           ${tl.test_pc.default_ssh_connection_details.username}
${TestPC_password}           ${tl.test_pc.default_ssh_connection_details.password}
${gnb_path}                  /tmp/
${ttitrace_path}             /ffs/run/config/toor4nsn/eventTrace_log/
${localFilePath_default}     ${CURDIR}/sw_default/swconfig.txt
${localFilePath_default_trunk}    ${CURDIR}/../5GC001856_Trunk_regression/swconfig_trunk/sw_default/swconfig.txt
${f1_sctp_port}              38472
${x2_sctp_port}              36422
${appserver_addr}            ${tl.ues[0].iperf_details.ssh_connection_details.addr}
${appserver_username}        ${tl.ues[0].iperf_details.ssh_connection_details.username}
${appserver_password}        ${tl.ues[0].iperf_details.ssh_connection_details.password}
${enbx2_para}                administrativeState
${gnb_instance}              ${tl.gnbs[0].instance_id}
${gnb_instance_1}              ${tl.gnbs[1].instance_id}
${gnb_dist}                  MRBTS-${gnb_instance}/NRBTS-${gnb_instance}
${gnb_dist_1}                  MRBTS-${gnb_instance_1}/NRBTS-${gnb_instance_1}
${enb_instance}              ${tl.enbs[0].instance_id}
${enbx2_dist}                MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNADJGNB-1
${enbcell_dist}                MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-1
${QPSTexe}                   "/cygdrive/c/Program Files (x86)/Qualcomm/QPST/bin/QPSTConfig.exe"
${MAX_WAIT_TIME_COAM_CONFIGURED}     10 min
${Retry_interval_COAM_CONFIGURED}     30 s
${epc_qxdm_path}             /opt/workspace/CRT/Master/QXDMlog/
##Get QXDM log from QC
${LKC_LOGIN_USER}            hai.2.huang@nokia-sbell.com
${LKC_LOGIN_PWD}             Password@3
${LKC_CLIENT_PORT}           6006
${5G_QXDM_PATH}              C:/MyDrivers/software/QXDM88
${LKC_CLIENT_ALIAS}          lkc
${LKC_CLIENT_PATH}          /cygdrive/c/cygwin64/home/nokia5G
${QCAT_EXE_PATH}            "C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/qcat.exe"
${UE_pc_ip}                  ${tl.ues[0].ssh_connection_details.addr}
${UE_pc_user}                ${tl.ues[0].ssh_connection_details.username}
${UE_pc_password}            ${tl.ues[0].ssh_connection_details.password}
${att_ipaddr}                ${tl.attenuator[0].ip_addr}    #FOR TL234 PA ip other pa plz set in case level
${att_port_1}                ${tl.attenuator[0].attenuator_ports[1]}
${att_port_2}                ${tl.attenuator[0].attenuator_ports[2]}
${att_port_3}                ${tl.attenuator[0].attenuator_ports[3]}
${att_port_4}                ${tl.attenuator[0].attenuator_ports[4]}
${att_port_13}                ${tl.attenuator[0].attenuator_ports[13]}
${att_port_14}                ${tl.attenuator[0].attenuator_ports[14]}
${att_port_15}                ${tl.attenuator[0].attenuator_ports[15]}
${att_port_16}                ${tl.attenuator[0].attenuator_ports[16]}
${att_port_5}                ${tl.attenuator[0].attenuator_ports[5]}
${att_port_6}                ${tl.attenuator[0].attenuator_ports[6]}
${att_port_7}                ${tl.attenuator[0].attenuator_ports[7]}
${att_port_8}                ${tl.attenuator[0].attenuator_ports[8]}
${att_connection_port}       ${tl.attenuator[0].attenuator_ports[1]}
${att_api_port}              ${tl.attenuator[0].port}
${vendor}                    HBTE
${max_attenuation_value}     ${127}
${SN}                        ${tl.ues[0].serial_number}
${tl_scf_dir_path}           /opt/workspace/SCF/
${DL_PORT}                   ${tl.ues[0].iperf_details.port}
${ul_throughput}             40M
${UL_TIME}                   600
${UL_PORT}                   ${tl.ues[0].iperf_details.ssh_connection_details.port}
${DL_TIME}                   600
${DL_LENGTH}                 1024B
${UL_LENGTH}                 1024B
${tshark_path}               /usr/bin/tshark
${LUA_SCRIPT_PATH}           /home/nokia/luashark/generated_luashark/luashark.lua
${ttitrace_logname}          full_dl.csv
${enb_path}                  /user/toor4nsn
${TOPYONG_ANT1}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${TOPYONG_ANT2}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${TOPYONG_ANT3}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
${TOPYONG_ANT4}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
${TRUNK_ANT1}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[0].port_no}
${TRUNK_ANT2}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[1].port_no}
${TRUNK_ANT3}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[2].port_no}
${TRUNK_ANT4}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[3].port_no}
${enbx2_dist_2nd}        MRBTS-${enb_instance_id}/LNBTS-${enb_instance_id}/LNADJGNB-1
${enb_instance_id}          ${tl.enbs[1].instance_id}
${ue_type}                  ${tl.ues[0].capabilities[1]}

*** Keywords ***
#SA On TL342
Tests Recover for SA
    Run Keyword And Ignore Error    Connect and Modify the parameter on enblte
    ...    dist_name=${eNB_cell1_distname}   parameter=${eNB_parameter}     value=unlocked
    Run Keyword And Ignore Error    unlock Cell for gNB2    WEBUI_COAM=${WEBUI_COAM_1}    cell_id=1
    Close the iperf process on APPserver    port=${dl_port}
    Stop power UE dl traffic and detach     ue_type=huawei    dl_port=${dl_port}
    disconect all connections

unlock Cell for gNB2
    [Arguments]    ${WEBUI_COAM}    ${cell_id}
    Run Keyword And Ignore Error    selenium_coam.logout
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    selenium_coam.disable_message_box
    selenium_coam.unlock_cell    cell_idx=${cell_id}
    sleep    35s
    [teardown]  Run keywords    selenium_coam.logout    AND    selenium_coam.disable_virtual_display

Lock the eNB cell
    Connect and Modify the parameter on enblte    dist_name=${eNB_cell1_distname}   parameter=${eNB_parameter}     value=locked

Set test variables
    ${release_info} =    Get gnb release
    set suite variable    ${interface}    ${para_store['${release_info}']['interface']}
    set suite variable    ${tac_exp}    ${para_store['${release_info}']['tac']}
    set suite variable    ${plmn}    ${para_store['${release_info}']['plmn']}
    set suite variable    ${mcc}    ${para_store['${release_info}']['mcc']}
    set suite variable    ${mnc}    ${para_store['${release_info}']['mnc']}

##ENB
Start To Capture ENB Logs
    [Arguments]     ${filename}  ${connection}=ENB
    wait until keyword succeeds    5 min    10 sec    Connect to ENB    alias=${connection}
    csn.send command    command=tcpdump -i br1 -w ${enb_path}${filename}   connection=${connection}

Stop and download ENB Logs
    [Arguments]     ${filename}=s1x2log.pcap  ${connection}=ENB
    wait until keyword succeeds    5 min    10 sec    Connect to ENB    alias=${connection}
    csn.send command    command=killall tcpdump     connection=${connection}
    sleep    5
    csn.download_file   remote_path=${enb_path}${filename}   local_path=${epc_log_path}${filename}   connection=${connection}

Change the COAM parameter online
    [Arguments]    ${dist_name}    ${parameter_name}    ${new_value}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    selenium_coam.set_parameter_value    dist_name=${dist_name}
    ...                                  filter_param=${parameter_name}
    ...                                  new_value=${new_value}
    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=True
    selenium_coam.logout

###gnb status
## NSA
adjust the HBTE attenuation value
    [Arguments]      ${value_1}    ${value_2}    ${value_3}    ${value_4}    ${att_port1}=${att_port_1}
    ...    ${att_port2}=${att_port_2}    ${att_port3}=${att_port_3}    ${att_port4}=${att_port_4}
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

Adjust the TopYong Attenuation Value
    [Arguments]    ${ports}    ${value}
    atten.connect to    ip=${att_ipaddr}
    atten.get_value    channel=${ports}
    atten.set_value    channel=${ports}    value=${value}
    atten.disconnect

Adjust the TopYong 4ports Attenuation Value
      [Arguments]    ${value1}    ${value2}    ${value3}    ${value4}    ${TOPYONG_ANT1}=${TOPYONG_ANT1}
      ...       ${TOPYONG_ANT2}=${TOPYONG_ANT2}    ${TOPYONG_ANT3}=${TOPYONG_ANT3}    ${TOPYONG_ANT4}=${TOPYONG_ANT4}
      Adjust the TopYong Attenuation Value    ports=${TOPYONG_ANT1}    value=${value1}
      Adjust the TopYong Attenuation Value    ports=${TOPYONG_ANT2}    value=${value2}
      Adjust the TopYong Attenuation Value    ports=${TOPYONG_ANT3}    value=${value3}
      Adjust the TopYong Attenuation Value    ports=${TOPYONG_ANT4}    value=${value4}

Prepare testline to cell onair
      [Arguments]      ${localFilePath}    ${tl_scf_filename}
      Update the swconfig file   localFilePath=${localFilePath}
      Prepare with COAM classical BTS cell onair    tl_scf_filename=${tl_scf_filename}


Update the swconfig file
    [Arguments]    ${localFilePath}
    wait until keyword succeeds    5min    10s    Connect to Common Unit Master   alias=ASIK    du_index=${0}
    SWConfig.Upload SwConfig File To Asik And Crasign     localFilePath=${localFilePath}    asik_alias=ASIK
    csn.Disconnect    connection=ASIK

Prepare with COAM classical BTS cell onair
    [Arguments]    ${tl_scf_filename}
    Perform full commission for COAM gnb    tl_scf_filename=${tl_scf_filename}
    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=locked
#    Check gnb COAM classical start normally
    COAM Wait for gnb ready
    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=unlocked
    wait until keyword succeeds    10min    30s    COAM Check GNB cell on air
    [Teardown]    COAM Teardown gnb connections

COAM Wait for gnb ready
    [Documentation]  Author: Ding Binmei
    ...              Description: Wait until GNB status ready.
    [Timeout]  30 min
    [Arguments]  ${timeout}=10 min    ${connection}=GNB_OAM
    Wait until keyword succeeds    ${timeout}    20 sec    Connect to gnb coam via ssl    connection=${connection}
    Wait until keyword succeeds    ${timeout}    20 sec    COAM Check GNB ABIL status    connection=${connection}
    Wait until keyword succeeds    ${timeout}    20 sec    COAM Check GNB ASIK status    connection=${connection}
    Wait until keyword succeeds    ${timeout}    20 sec    COAM Check GNB RU status    connection=${connection}


Perform full commission for COAM gnb
    [Arguments]    ${tl_scf_filename}
    Connect to gnb coam via ssl   bts_host=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    COAM Commission with scf file    scf_file_path=${tl_scf_dir_path}${tl_scf_filename}    timeout=500    is_pdl_checking_needed=${False}
    [Teardown]    COAM Teardown gnb connections

Check gnb COAM classical start normally
    wait until keyword succeeds    5min   10s    Check Airscale HW module status
    wait until keyword succeeds    5min   30s    Check the sctp port UP    port_num=${f1_sctp_port}
    wait until keyword succeeds    5min   30s    Check the gnb RU status ready
    wait until keyword succeeds    10min   30s    Check the sctp port UP    port_num=${x2_sctp_port}

Get info status check
    [Arguments]    ${info_status}
    ${Status} =   get from dictionary    ${info_status}    Status
    ${opr_state} =   get from dictionary    ${Status}    Operational state
    should be equal    ${opr_state}    Enabled
    ${avi_state} =   get from dictionary    ${Status}   Availability status
    should be equal    ${avi_state}    Online
    ${adm_state} =   get from dictionary    ${Status}    Administrative state
    should be equal    ${adm_state}    Unlocked

Check the sctp port UP
    [Arguments]    ${port_num}
    Connect to BB1 master    alias=BB1
    ssh.sendCommand    command=netstat -anl |grep sctp    connection=BB1
    sleep    3s
    ${sctp_status} =    ssh.read_output    connection=BB1
    ssh.disconnect     connection=BB1
    should contain     ${sctp_status}     ${port_num}

Common Suite Setup for COAM
    [Arguments]    ${log_level}=${False}
    COAM Create log directory    is_set_to_test_case_level=${log_level}
    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
    Set Suite Variable    ${epc_log_path}    ${LOG_PATH}/${time_stamp}/
    Create directory    ${epc_log_path}

Get gnb release
    wait until keyword succeeds    1min    10s    Connect to Common Unit Master    alias=release_info
    ${info}   csn.Execute    ls /ffs/run/TargetBD*xml    connection=release_info
    ${release_info}     set variable    ${info.split('_')[1]}
    [Return]    ${release_info}
    [Teardown]   csn.Disconnect   connection=release_info

Common Suite Teardown for COAM
    [Arguments]    ${localFilePath_default}=${localFilePath_default}
    Connect to gnb coam via ssl
    COAM Download scf from cluster    scf_dir_path=${epc_log_path}
    COAM Save snapshot via rest api    log_path=${epc_log_path}
    restore swConfig to default    localFilePath=${localFilePath_default}
    COAM Teardown gnb connections

restore swConfig to default
    [Arguments]     ${localFilePath}
    Update the swconfig file    localFilePath=${localFilePath}

Read BIP pcap files
    [Arguments]    ${filter}    ${BIP_log_name}    ${lua_script_path}=${LUA_SCRIPT_PATH}
    Wait until keyword succeeds    3 min     7 s    cap.Read cap
    ...    cap_file=${epc_log_path}${BIP_log_name}
    ...    X=lua_script:${lua_script_path}
    ...    display_filter=${filter}

Lock gnb1 cell
    [Arguments]    ${parameters}
    Connect to gnb2 coam via ssl     bts_host=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...                              username=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...                              password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters}
    COAM Teardown gnb connections

Connect to gnb2 coam via ssl
    [Arguments]  ${connection}=GNB_OAM    ${bts_host}=${tl.gnbs[1].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[1].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[1].cu.oam_http_connection_details.password}
    coam.connect_to    bts_host=${bts_host}    bts_port=${443}    username=${username}    password=${password}
    ...   name=${connection}

##SA
Prepare with COAM classical BTS cell onair SA
      [Arguments]    ${tl_scf_dir_path}    ${tl_scf_filename}    ${bts_host}    ${username}    ${password}
      Perform full commission for COAM SA gnb     scf=${tl_scf_dir_path}${tl_scf_filename}
      ...    gnb_ip=${bts_host}    username=${username}    password=${password}
      COAM Wait for gnb ready SA    bts_host=${bts_host}    username=${username}    password=${password}
      Wait Until Keyword Succeeds     10min     30s     COAM Check GNB cell on air

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

##capture UE log
Get Qualcomm License
    [Arguments]    ${ue_index}
    Kill QXDM and QPSK exe    ue_index=${ue_index}
    Prepare LKC    ue_index=${ue_index}
    LK.create_ssh_runner    host=${UE_pc_ip}    username=${UE_pc_user}    password=${UE_pc_password}    alias=${LKC_CLIENT_ALIAS}
    Keep 5G Licence
    LK.licence_keeper_client_is_running    alias=${LKC_CLIENT_ALIAS}
    LK.disconnect_ssh_runner    alias=${LKC_CLIENT_ALIAS}

5G isf decoder to txt and save to local
    [Arguments]    ${ue_index}    ${QXDM_log_name}
    Connect to control pc enhanced    ue_index=${ue_index}
    wait until keyword succeeds    2min    2s    Csn.Assert file exists
    ...    remote_path=${5G_QXDM_PATH}/${QXDM_log_name}.isf    connection=cpc_${ue_index}
    Log to console   \nINFO:5G Qmdl decoder to txt
    ${result}   Csn.execute
    ...  command=cmd /c ${QCAT_EXE_PATH} -txt ${5G_QXDM_PATH}/${QXDM_log_name}.isf
    ...  connection=cpc_${ue_index}
    Log to console   \nINFO:${result}
    Csn.download file
    ...   remote_path=${5G_QXDM_PATH}/${QXDM_log_name}.txt
    ...   local_path=${epc_qxdm_path}${QXDM_log_name}.txt
    ...   connection=cpc_${ue_index}
    Csn.execute   command=rm -rf ${5G_QXDM_PATH}/*.isf   connection=cpc_${ue_index}
    Csn.execute   command=rm -rf ${5G_QXDM_PATH}/*.txt   connection=cpc_${ue_index}
    Csn.disconnect   connection=cpc_${ue_index}

Kill QXDM and QPSK exe
    [Arguments]    ${ue_index}
    Connect to control pc enhanced    ue_index=${ue_index}
    csn.send command    command=taskkill /F /IM QXDM.exe    connection=cpc_${ue_index}
    csn.send command    command=taskkill /F /IM QPSTServer.exe    connection=cpc_${ue_index}
    csn.send command    command=taskkill /F /IM QPSTConfig.exe    connection=cpc_${ue_index}
    Csn.disconnect      connection=cpc_${ue_index}

Prepare LKC
    [Arguments]    ${ue_index}
    LK.create_ssh_runner    host=${UE_pc_ip}    username=${UE_pc_user}    password=${UE_pc_password}    alias=${LKC_CLIENT_ALIAS}
    Sleep    10s
    ${res} =    LK.licence_keeper_client_is_running    alias=${LKC_CLIENT_ALIAS}
    Run Keyword If    ${res} == ${True}     Kill ClientMain exe    ue_index=${ue_index}
    Connect to control pc enhanced    ue_index=${ue_index}
    csn.send command
    ...    command=/cygdrive/c/cygwin64/home/nokia5G/ClientMain.exe
    ...    connection=cpc_${ue_index}    timeout=100
    Sleep    5s
    LK.connect    host=${UE_pc_ip}     port=${LKC_CLIENT_PORT}
    LK.login    username=${LKC_LOGIN_USER}     password=${LKC_LOGIN_PWD}     timeout=${30}

Kill ClientMain exe
    [Arguments]    ${ue_index}
    Connect to control pc enhanced    ue_index=${ue_index}
    csn.send command    command=taskkill /F /IM ClientMain.exe    connection=cpc_${ue_index}
    Csn.disconnect      connection=cpc_${ue_index}

Keep 5G Licence
    LK.get_licence_qxdm_5g
    LK.get_licence_qcat_5g

Drop License
    [Arguments]    ${ue_index}=${0}
    ${UE_pc_ip} =    set variable    ${tl.ues[${ue_index}].ssh_connection_details.addr}
    ${UE_pc_user} =    set variable    ${tl.ues[${ue_index}].ssh_connection_details.username}
    ${UE_pc_password} =    set variable    ${tl.ues[${ue_index}].ssh_connection_details.password}
    LK.create_ssh_runner    host=${UE_pc_ip}    username=${UE_pc_user}    password=${UE_pc_password}    alias=${LKC_CLIENT_ALIAS}
    LK.release_licence_qxdm_5g
    LK.release_licence_qcat_5g
    LK.disconnect
    LK.disconnect_ssh_runner    alias=${LKC_CLIENT_ALIAS}

##PM counter
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

Check PM counter
    [Arguments]    ${counter_id}    ${full_path}    ${date}=all
    Connect to gnb coam via ssl
    ${result} =    get_pm_counter_values    counter_id=${counter_id}    connection=GNB_OAM
    ...    dic_path=${full_path}    date=${date}
    [Return]    ${result}
    [Teardown]    COAM Teardown gnb connections

Sum the list value
    [Arguments]    ${counter_result}
    ${length}    Get Length    ${counter_result}
    ${sum_result}    set variable    ${0}
    FOR    ${i}    IN RANGE    ${length}
        ${sum_result}    Evaluate    ${sum_result} + ${counter_result[${i}]}
    END
    [Return]      ${sum_result}

##Iperf server
Start DL traffic and check Throughput
     Start DL traffic     dl_time=${dl_time}    dl_port=${dl_port}    dl_throughput=${dl_throughput}    dl_length=${dl_length}
     sleep    30s
     Caculate DL throughput on gnb L2Lo 19B     dl_expect=${Expect_DOWNLINK}

Caculate DL throughput on gnb L2Lo 19B
    [Documentation]  This keyword check the DL throughput in gnb l2lo and compare with expect value.
    [Arguments]     ${dl_expect}
    wait until keyword succeeds    1 min    10 sec    Connect to BB1 master    alias=ASIK
    wait until keyword succeeds    1 min    10 sec    Connect to asp1a    alias=asp1a
    sleep     10s
    ${dl_tp_l2lo_with_2s}=    Get_And_Calculate_DL_throughput    alias=asp1a    duration=${50}    location=${16}
    ${dl_tp_l2lo} =    Evaluate    float(${dl_tp_l2lo_with_2s}/${2.0})
    run keyword if    ${dl_tp_l2lo} == 0       Retry UE attach     dl_expect=${dl_expect}
    should be true    ${dl_tp_l2lo} > ${dl_expect}
    [Teardown]    RUN KEYWORDS    run keyword and ignore error  csn.disconnect    connection=asp1a    AND
    ...                           run keyword and ignore error  csn.disconnect    connection=ASIK

Retry UE attach
    [Arguments]     ${dl_expect}
    UE soft reboot
    Close the iperf process on APPserver    port=${dl_port}
    Precondition for Android UE retry
    Android UE l3 call
    Start DL traffic    dl_time=${dl_time}    dl_port=${dl_port}    dl_throughput=${dl_throughput}    dl_length=${dl_length}
    wait until keyword succeeds    1 min    10 sec    Connect to BB1 master    alias=ASIK
    wait until keyword succeeds    1 min    10 sec    Connect to asp1a    alias=asp1a
    sleep     10s
    ${dl_tp_l2lo}=    Get_And_Calculate_DL_throughput     alias=asp1a    duration=${30}    location=${16}
    should be true    ${dl_tp_l2lo} > ${dl_expect}
    [Teardown]    RUN KEYWORDS    run keyword and ignore error  csn.disconnect    connection=asp1a    AND
    ...                           run keyword and ignore error  csn.disconnect    connection=ASIK

Start DL traffic
    [Documentation]
    [Arguments]    ${dl_time}    ${dl_port}    ${dl_throughput}    ${dl_length}    ${ue_index}=0
    ${ue_addr}    Get the UE Ip address    ue_index=${ue_index}
    Close the iperf process on APPserver    port=${dl_port}
    Close the iperf process on Qualcomm    ue_index=${ue_index}
    Start DL traffic via iperf on Appserver    ue_addr=${ue_addr}    dl_time=${dl_time}    dl_port=${dl_port}
    ...    dl_throughput=${dl_throughput}    dl_length=${dl_length}

Precondition for UE control PC
    [Arguments]    ${ue_num}=1
    FOR    ${i}    IN RANGE    0    ${ue_num}
        Reset UE Control PC    ue_index=${i}
    END


Modify the COAM parameter with admin API
    [Arguments]    ${parameters}
    Connect to gnb coam via ssl
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters}
    COAM Teardown gnb connections

gNB connections
    [Arguments]    ${asik_addr}=${asik_addr}    ${asik_username}=${asik_username}    ${asik_password}=${asik_password}
    csn.Connect To    hostname=${asik_addr}
    ...               username=${asik_username}
    ...               password=${asik_password}
    ...               alias=gnb

Start To Capture Wireshark Logs
    [Arguments]     ${filename}    ${connection}    ${interface}
    ...    ${asik_addr}=${asik_addr}    ${asik_username}=${asik_username}    ${asik_password}=${asik_password}
    gNB connections    asik_addr=${asik_addr}    asik_username=${asik_username}    asik_password=${asik_password}
#    csn.send command    command=cd /tmp&&tcpdump -i ${interface} sctp -w ${gnb_path}${filename}   connection=${connection}
    csn.send command    command=tcpdump -i ${interface} sctp -w ${gnb_path}/${filename}   connection=${connection}

Download bip Logs
    [Arguments]    ${logname}    ${logpath}    ${connection}=ASIK Master
    Connect to Common Unit Master
    csn.download_file   remote_path=${gnb_path}${logname}   local_path=${epc_log_path}${logname}   connection=${connection}

Stop and download Logs
    [Arguments]    ${logname}    ${connection}
    ...        ${asik_addr}=${asik_addr}    ${asik_username}=${asik_username}    ${asik_password}=${asik_password}
    gNB connections    asik_addr=${asik_addr}    asik_username=${asik_username}    asik_password=${asik_password}
    csn.send command    command=killall tcpdump     connection=${connection}
    sleep    3
    csn.download_file   remote_path=${gnb_path}${logname}   local_path=${epc_log_path}${logname}   connection=${connection}
    sleep    15

Connect to local master
    [Arguments]    ${alias}=Local gNB
    csn.Connect to    hostname=${LOCAL_MASTER_IP}
    ...    username=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    ...    alias=${alias}

disconect all connections
    run keyword and ignore error    csn.disconnect    connection=TestPC
    run keyword and ignore error     coam.teardown    connection=GNB_OAM
    run keyword and ignore error     csn.disconnect    connection=ASIK

Remove ttitrace log on ASIK
    [Arguments]     ${connection}=ASIK
    wait until keyword succeeds    1 min    10 sec     Connect to Common Unit Master    alias=${connection}
    csn.Execute    command=rm -rf /ffs/fs1/config/toor4nsn/eventTrace_log/    connection=${connection}

Tests Recover
    Remove ttitrace log on ASIK
    Adjust the TopYong 4ports Attenuation Value    value1=${0}    value2=${0}    value3=${0}    value4=${0}
#    Drop License
    sleep     5s
#    Kill ClientMain exe    ue_index=${0}
#    Kill QXDM and QPSK exe    ue_index=${0}
    Close the iperf process on APPserver    port=${dl_port}
    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=unlocked
    disconect all connections

Precondition for Android UE retry
    [Documentation]  This keyword is the precondition for android ue attach,
    ...  action contain QPST start to avoid UE crash and airplane mode turn on
    ...              and ue reboot to clear last time test remained.
    [Arguments]  ${ue_index}=${0}    ${cap_index}=${0}
    Start the QPST progress     ue_index=${ue_index}
    Check UE device exist     ue_index=${ue_index}
    UE soft reboot     ue_index=${ue_index}

##Gnb2
Connect to Classical Common Unit Master gnb
    [Arguments]    ${gnb_index}=${0}    ${du_index}=${0}    ${alias}=ASIK Master
    ${gnbs}    testline_info.get_classicalbts_gnbs    tl=${tl}
    ssh.Connect to    hostname=${gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...               username=${gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...               password=${gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...               alias=${alias}

Capture TTITrace and download to test pc ASIB
    [Arguments]    ${gnb_index}=${0}
    Start TTI trace log capturing ASIB    gnb_index=${gnb_index}
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

Preconfdition for Bip Capture on ASIB
    [Arguments]     ${mirror_mode}    ${gnb_index}=${0}    ${hw_slot}=${1}    ${hw_slot_mirror}=${1}
    Connect to Capacity Unit Loner with hostname    gnb_index=${gnb_index}    alias=ABIL Loner    hw_slot=${hw_slot}
    detectHwAndStartMirroring    asik_alias=Common Master    loner_alias=ABIL Loner    mirror_mode=${mirror_mode}    hw_index=${hw_slot_mirror}
    ...    sw_release=ASIB

Catch Bip log on ASIB
    [Arguments]     ${biplog}    ${connection}=ABIL Master    ${gnb_index}=${0}    ${mirror_mode}=local
    ...            ${bip_interface}=ethbp1    ${bip_time}=${3}    ${hw_slot}=${1}
    Preconfdition for Bip Capture on ASIB   gnb_index=${gnb_index}    mirror_mode=${mirror_mode}    hw_slot=${hw_slot}
    sleep    3s
    Connect to Capacity Unit Master with hostname    gnb_index=${gnb_index}    hw_slot=${hw_slot}
    sleep    3s
    Run keyword if    '${bip_time}'=='infinity'
    ...    csn.Execute    command=tcpdump -i ${bip_interface} -w ${gnb_path}${biplog} -vv
    ...           connection=${connection}
    ...    ELSE    csn.Execute    command=timeout ${bip_time} tcpdump -i ${bip_interface} -C 50M -w ${gnb_path}${biplog} -vv
    ...         connection=${connection}

Download GNB port15 Logs ASIB
    [Arguments]    ${logname}     ${gnb_index}=${0}    ${connection}=ABIL Master    ${hw_slot}=${1}
    Connect to Capacity Unit Master with hostname    gnb_index=${gnb_index}    hw_slot=${hw_slot}
    sleep    5s
    csn.download_file   remote_path=${gnb_path}${logname}   local_path=${epc_log_path}${logname}   connection=${connection}

##SA
Tests Recover SA
    [Arguments]     ${PARAMS_TO_MODIFY_UNLOCKG}=${PARAMS_TO_MODIFY_UNLOCKG1}
    Adjust the TopYong 4ports Attenuation Value    TOPYONG_ANT1=${TRUNK_ANT1}    TOPYONG_ANT2=${TRUNK_ANT2}    TOPYONG_ANT3=${TRUNK_ANT3}
    ...    TOPYONG_ANT4=${TRUNK_ANT4}    value1=${0}    value2=${0}    value3=${0}    value4=${0}
    Lock gnb1 cell     parameters=${PARAMS_TO_MODIFY_UNLOCKG}
    Connect and Modify the parameter on enblte    dist_name=${enbcell_dist}    parameter=administrativeState     value=unlocked
    sleep     5s
    Connect to EPC APP
    Stop power UE dl traffic    ue_type=huawei    dl_port=${DL_PORT}
    sleep     3s
    Get product brand
    Detach Huawei UE SA
    disconect all connections


##Huawei UE
Detach Huawei UE SA
    power_ue.UE Detach    ue_type=huawei

Precondition for power UE
    [Arguments]    ${ue_type}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}    capatibility_index=${0}    reset_sol=pc_reset    detach_request=${true}

Attach and check power UE
    [Arguments]    ${ue_type}    ${4g_check}    ${gnb_index}=${0}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${0}    gnb_index=${gnb_index}
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    ue_index=${0}     gnb_index=${gnb_index}
    ...                      4G_check=${4g_check}    5Gstatus=PASS

Stop power UE dl traffic
    [Arguments]     ${ue_type}    ${dl_port}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    iperf_port=${dl_port}

Detach power UE
    [Arguments]    ${ue_type}
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}

Stop power UE dl traffic and detach
    [Arguments]     ${ue_type}    ${dl_port}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    iperf_port=${dl_port}
    sleep    3s
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}

Power UE Start traffic
    [Arguments]    ${dl_throughput}     ${duration}=${DL_TIME}    ${dl_length}=${DL_LENGTH}    ${dl_port}=${DL_PORT}
    ...    ${ue_index}=${0}    ${ue_type}=huawei
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_throughput}    duration=${duration}
    ...                       iperf_port=${dl_port}    ue_index=${0}    cap_index=${0}    buffer_size=${dl_length}

Power UE check throughput
    [Arguments]    ${Expect_DOWNLINK}    ${ue_index}=${0}    ${gnb_index}=${0}    ${ue_type}=huawei
    wait until keyword succeeds    2min    10s    power_ue.Check throughput    ue_type=${ue_type}    direction=dl    throughput=${Expect_DOWNLINK}
    ...    ue_index=${ue_index}    hw_slot=1    sample=${10}    start_offset=${3}    sleep_time=${5}    cellid=${EMPTY}    gnb_index=${gnb_index}
