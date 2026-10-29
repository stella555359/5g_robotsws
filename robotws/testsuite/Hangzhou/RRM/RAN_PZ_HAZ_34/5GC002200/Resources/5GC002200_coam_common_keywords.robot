*** Settings ***
Documentation
...    author: liujia
...    contact: jia-rebecca.liu@nokia-sbell.com
...    squad group: SG_03
...    feature : 5GC002200

Library        OperatingSystem
Library        Collections
Library        String
Library        BuiltIn
Library        taf.transport.ssh    WITH NAME    csn
Library        taf.sbts.oam.coam.admin   WITH NAME    wmplte
Library        taf.config.scf    WITH NAME    scf
Library        taf.selenium.sbts    WITH NAME  selenium_coam
Library        taf.analyzer.pcap   WITH NAME    cap
Library        taf.hw.rf_attenuator    WITH NAME    att
Library        taf.config.testline    WITH NAME    testline
Library        ./get_pm_counter.py
Library        taf.rfrl.common_resources.python.SWConfig    WITH NAME    SWConfig
Library        taf.hw.mcs    WITH NAME    MCS
Library        ../../../../resources/RAN_PZ_HAZ_34/python/sigspark.py
Library        testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/get_coam_pmcounter.py
Resource       ../../../../resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource       taf/rfrl/common_resources/robot/gnb_classical.robot
Resource       ../../../../resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource       ../../../../resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource       ../../../../OAM/RAN_PZ_HAZ_34/common/coam_resource.robot
Resource       ../../../../resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource       taf/rfrl/common_resources/robot/connection_alias_store.robot
Library        ../../libraries/L3Call.py
Resource       btslog_collecting.robot
Library        ../../libraries/TTI_Trace_Analysis_dl.py
Library        ../../../../resources/RAN_PZ_HAZ_34/python/check_csv_log.py
Resource       taf/rfrl/common_resources/robot/TTI_Trace.robot
Resource       ../../../../resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource       ../../libraries/biplog_capture/biplog_capture.robot
Resource       ../../libraries/connection_with_hostname.robot
Library        ./tput_output.py
Resource       ../../../../resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Variables      ./Stream_parameter.py
Resource       ../../../../resources/RAN_PZ_HAZ_34/robot/BIP_trace/BIP_trace_collector.robot
Resource       ../../../../resources/RAN_PZ_HAZ_34/lines/SG3/robot/Collect_logs.robot
Resource       ../../../../resources/RAN_PZ_HAZ_34/lines/SG3/robot/Atten.robot
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/mcs/mcs_common.robot
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/UE.robot
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Variables      ./variables.py
Library        ./csv_analysis_mumimo.py
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/dingli_multiUE.robot



*** Variables ***
##SCF##
${golden_scf_24R1_365}          MRBTS-10175_TL365_golden_scf.xml
${golden_scf_23R4_374}          MRBTS-11006_TL374_golden_SCF.xml
${golden_scf_23R3_365}          MRBTS-10175_TL365_golden_scf_23R3.xml
${golden_scf_24R1_374}          MRBTS-11006_TL374_golden_SCF_24R1.xml
${golden_scf_23R3_374}          MRBTS-11006_TL374_golden_SCF_23R3.xml
${golden_scf_23R4_365}          MRBTS-10175_TL365_golden_scf_23R4.xml
${golden_scf_24R2_374}          MRBTS-11006_TL374_golden_SCF_24R2.xml
${golden_scf_24R3_365}          MRBTS-10175_TL365_golden_scf_24R3.xml
${golden_scf_24R3_374}          MRBTS-11006_TL374_golden_SCF_24R3.xml
${golden_scf_25R1_365}          MRBTS-10175_TL365_golden_scf_25R1.xml
${golden_scf_25R1_374}          MRBTS-11006_TL374_golden_SCF_25R1.xml
##PATH##
${TS_LOG_PATH_BASE}              /opt/workspace/CRT/Master/Case_Logs
${gnb_path}                      /tmp/
${enb_path}                      /user/toor4nsn/
${ttitrace_path}                 /ffs/run/config/toor4nsn/eventTrace_log/
${swconfig_default}              /opt/workspace/SCF/swconfig/swconfig.txt
${swconfig}                      /opt/workspace/SCF/swconfig.txt
${tshark_path}                   /usr/bin/tshark
${LUA_SCRIPT_PATH}               /opt/workspace/luashark/generated_luashark/luashark.lua
${bipscript_path}                   /opt/workspace/biplog_script/
${beamweight_path}               /ffs/run/config/
${beamweight_name_22R2}          CP_beamSet_6_10318_169050114.json
${beamweight_name_Trunk}         CP_beamSet_5_1_10175_166707201.json
${beamweight_name_22R3}          CP_beamSet_4_11006_180322305.json
${bpf_path}                      /tmp/bpf/
${bpf_name_22R2}                 475294A_AE_QV.gz
${ungzip_bpf_name_22R2}          475294A_AE_QV
${bpf_name_xml_22R2}             AE_QV.xml
${bpf_name_trunk}                475124A_475124B_091691A_475769A_AE_HC.gz
${ungzip_bpf_name_trunk}         475124A_475124B_091691A_475769A_AE_HC
${bpf_name_xml_trunk}            AE_HC.xml
${bpf_name_22R3}                 475294A_AE_QV.gz
${ungzip_bpf_name_22R3}          475294A_AE_QV
${bpf_name_xml_22R3}             AE_QV.xml

##GNB##
${MRBTS_ID}                     ${tl.gnbs[0].instance_id}
${WEBUI_COAM}                   https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_URL}                    https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_NAME}                   ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}                    ${tl.gnbs[0].cu.oam_http_connection_details.password}
${gnb_BTS_host}                 ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${gnb_BTS_username}             ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gnb_BTS_password}             ${tl.gnbs[0].cu.oam_http_connection_details.password}
${asik_addr}                    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${asik_username}                ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${asik_password}                ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${TestPC_addr}                  ${tl.test_pc.default_ssh_connection_details.addr}
${TestPC_username}              ${tl.test_pc.default_ssh_connection_details.username}
${TestPC_password}              ${tl.test_pc.default_ssh_connection_details.password}
${gnb_instance}                 ${tl.gnbs[0].instance_id}
${EPCAPP_addr}                  ${tl.appserver[1].ssh_connection_details.addr}
${EPCAPP_username}              ${tl.appserver[1].ssh_connection_details.username}
${EPCAPP_password}              ${tl.appserver[1].ssh_connection_details.password}
${golden_scf_name_Trunk}        MRBTS-10175_TL365_golden_scf.xml
${golden_scf_name_22R3}         MRBTS-11006_TL374_golden_SCF.xml
${golden_scf_name_22R2}         MRBTS-10318_TL362_golden_scf.xml
${golden_scf_name_23R1}         MRBTS-10175_TL365_golden_scf_23R1.xml
${golden_scf_name_23R2}         MRBTS-11006_TL374_golden_SCF.xml
${Empty_list}                   'NULL'

##ENB##
${ENB_ADDRESS}                   ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${enb_cell_admin}                administrativeState
${enb_instance}                  ${tl.enbs[0].instance_id}
${enbx2_dist_LNADJGNB_1}         MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNADJGNB-1
${enbx2_dist_LNADJGNB_0}         MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNADJGNB-0
${ENB_cell1_dist}                MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-1
${ENB_cell12_dist}               MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-12
${ENB_cell2_dist}                MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-2
${defaultgnbcell}                defaultLnRelGnbCellId
##UE##
${SN}                       ${tl.ues[0].serial_number}
${ue_type_1}                ${tl.ues[0].capabilities[1]}
${ue_type_0}                ${tl.ues[0].capabilities[0]}
${UL_PORT}                  ${tl.ues[0].iperf_details.ssh_connection_details.port}
${DL_PORT}                  ${tl.ues[0].iperf_details.port}
${ul_throughput}            100M
${dl_throughput}            1600M
${DL_TIME}                  9999
${DL_LENGTH}                1024B
${UL_TIME}                  600
${UL_LENGTH}                1024B
${NSA_UE_MODE}              NSA
${SA_UE_MODE}               SA
${NSA_attach_mode}          5G_NSA
${SA_attach_mode}           5G_SA
${NSA_nettype}              NSA
${SA_nettype}               AUTO
${NSA_apn_addr}             dxdata1
${SA_apn_addr}              wap2.nokia.com
${Multi_dl_throughput}      1000Mbits/sec



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

# 370 HBTE PA
${att_port_1}                 ${tl.attenuator[0].attenuator_ports[1]}
${att_port_2}                 ${tl.attenuator[0].attenuator_ports[2]}
${att_port_3}                 ${tl.attenuator[0].attenuator_ports[3]}
${att_port_4}                 ${tl.attenuator[0].attenuator_ports[4]}
${att_port_5}                 ${tl.attenuator[0].attenuator_ports[5]}
${att_port_6}                 ${tl.attenuator[0].attenuator_ports[6]}
${att_port_7}                 ${tl.attenuator[0].attenuator_ports[7]}
${att_port_8}                 ${tl.attenuator[0].attenuator_ports[8]}
${att_port_9}                 ${tl.attenuator[0].attenuator_ports[9]}
${att_port_10}                ${tl.attenuator[0].attenuator_ports[10]}
${att_port_11}                ${tl.attenuator[0].attenuator_ports[11]}
${att_port_12}                ${tl.attenuator[0].attenuator_ports[12]}
${att_port_13}                ${tl.attenuator[0].attenuator_ports[13]}
${att_port_14}                ${tl.attenuator[0].attenuator_ports[14]}
${att_port_15}                ${tl.attenuator[0].attenuator_ports[15]}
${att_port_16}                ${tl.attenuator[0].attenuator_ports[16]}
@{PA_port_list}      ${att_port_1}     ${att_port_2}     ${att_port_3}     ${att_port_4}     ${att_port_5}     ${att_port_6}
...                  ${att_port_7}     ${att_port_8}     ${att_port_9}     ${att_port_10}    ${att_port_11}    ${att_port_12}
...                  ${att_port_13}    ${att_port_14}    ${att_port_15}    ${att_port_16}
@{PA_values4}           ${40}    ${40}    ${40}    ${40}    ${40}    ${40}    ${40}    ${40}
...                     ${40}    ${40}    ${40}    ${40}    ${40}    ${40}    ${40}    ${40}
@{PA_valuesN1N2_4_1}           ${40}    ${40}    ${40}    ${40}    ${127}    ${127}    ${40}    ${40}
...                            ${127}    ${127}    ${40}    ${40}    ${127}    ${127}    ${127}    ${127}

*** Keywords ***
##setup and teardown and recovery##
Set suite variables by program
    [Documentation]      This keyword is to set several variables by program.
    ${release_info}    Get sagnb release
    set suite variable    ${release_info}

Common Suite Setup for COAM 2200
    Set suite variables by program
    Common Suite Setup for COAM
    Run Keyword If    '${MRBTS_ID}' == '11006' and '${release_info}' == 'SBTS24R1_ENB_0000'
    ...    Set Suite Variable    ${golden_scf_name_Trunk}     ${golden_scf_24R1_374}
    Run Keyword If    '${MRBTS_ID}' == '11006' and '${release_info}' == 'SBTS23R3_ENB_0000'
    ...    Set Suite Variable    ${golden_scf_name_Trunk}     ${golden_scf_23R3_374}
    Run Keyword If    '${MRBTS_ID}' == '10175' and '${release_info}' == 'SBTS23R4_ENB_0000'
    ...    Set Suite Variable    ${golden_scf_name_Trunk}     ${golden_scf_23R4_365}
    Run Keyword If    '${MRBTS_ID}' == '10175' and '${release_info}' == 'SBTS23R3_ENB_0000'
    ...    Set Suite Variable    ${golden_scf_name_Trunk}     ${golden_scf_23R3_365}
    Run Keyword If    '${MRBTS_ID}' == '10175' and '${release_info}' == 'SBTS24R3_ENB_0000'
    ...    Set Suite Variable    ${golden_scf_name_Trunk}     ${golden_scf_24R3_365}
    Run Keyword If    '${MRBTS_ID}' == '10175' and '${release_info}' == 'SBTS24R1_ENB_0000'
    ...    Set Suite Variable    ${golden_scf_name_Trunk}     ${golden_scf_24R1_365}
    Run Keyword If    '${MRBTS_ID}' == '11006' and '${release_info}' == 'SBTS23R4_ENB_0000'
    ...    Set Suite Variable    ${golden_scf_name_Trunk}     ${golden_scf_23R4_374}
    Run Keyword If    '${MRBTS_ID}' == '11006' and '${release_info}' == 'SBTS24R2_ENB_0000'
    ...    Set Suite Variable    ${golden_scf_name_Trunk}     ${golden_scf_24R2_374}
    Run Keyword If    '${MRBTS_ID}' == '11006' and '${release_info}' == 'SBTS24R3_ENB_0000'
    ...    Set Suite Variable    ${golden_scf_name_24R2}     ${golden_scf_24R3_374}
    Run Keyword If    '${MRBTS_ID}' == '10175' and '${release_info}' == 'SBTS25R1_ENB_0000'
    ...    Set Suite Variable    ${golden_scf_name_Trunk}     ${golden_scf_25R1_365}
    Run Keyword If    '${MRBTS_ID}' == '11006' and '${release_info}' == 'SBTS25R1_ENB_0000'
    ...    Set Suite Variable    ${golden_scf_name_24R2}     ${golden_scf_25R1_374}
    set suite variable    ${golden_scf_name_Trunk}


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
#    Run Keyword And Ignore Error       Clear pyro_server files

Trigger ASKEY UE reboot
    [Arguments]    ${serial_number}=${askey_SN}
    csn.Connect to     hostname=${askey_hostname}    username=${askey_username}    password=${askey_password}    alias=cygwin
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} reboot    connection=cygwin
    sleep   2s
    csn.disconnect      connection=cygwin

Clear pyro_server files
    csn.Connect to    hostname=${askey_hostname}    username=${askey_username}    password=${askey_password}    alias=cygwin
    sleep   2s
    csn.send_command    command=rm -rf c:/pyro_server/*    connection=cygwin

clear cli process
    csn.Connect to    hostname=${askey_hostname}    username=${askey_username}    password=${askey_password}    alias=cygwin
    csn.send command    command=ps -ef | grep cli |grep ute_common_admin | grep -v grep |awk '{print $2}' |xargs kill -9    connection=cygwin

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
#    run keyword if    '${release_info}' == 'SBTS22R2_ENB_0000'    power_ue.Prepare UE    ue_index=${0}    ue_type=${UE_TYPE}
    Update the swconfig file  gnb_index=${gnb_index}    localFilePath=${localFilePath}
    Prepare with COAM classical BTS cell onair for NSA    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_filename=${tl_scf_filename}
    ...    enbx2_dist=${enbx2_dist}

Prepare testline to cell onair for SA
    [Arguments]      ${tl_scf_filename}    ${localFilePath}=${localFilePath}      ${tl_scf_dir_path}=${tl_scf_dir_path}    ${gnb_index}=${0}
    ...     ${bts_host}=${gnb_BTS_host}    ${username}=${gnb_BTS_username}    ${password}=${gnb_BTS_password}
#    run keyword if    '${release_info}' == 'SBTS22R2_ENB_0000'    power_ue.Prepare UE    ue_index=${0}    ue_type=${UE_TYPE}
    Update the swconfig file  gnb_index=${gnb_index}    localFilePath=${localFilePath}
    Prepare with COAM classical BTS cell onair for SA    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_filename=${tl_scf_filename}
    ...    bts_host=${bts_host}    username=${username}    password=${password}

Prepare testline to cell onair for SA 70137
    [Arguments]      ${localFilePath}    ${tl_scf_filename}    ${tl_scf_dir_path}=${tl_scf_dir_path}    ${gnb_index}=${0}
    ...     ${bts_host}=${gnb_BTS_host}    ${username}=${gnb_BTS_username}    ${password}=${gnb_BTS_password}
    Update the swconfig file  gnb_index=${gnb_index}    localFilePath=${localFilePath}
    Prepare with COAM classical BTS cell onair for SA    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_filename=${tl_scf_filename}
    ...    bts_host=${bts_host}    username=${username}    password=${password}

Prepare with COAM classical BTS cell onair for SA
    [Arguments]    ${tl_scf_dir_path}    ${tl_scf_filename}    ${bts_host}=${gnb_BTS_host}    ${username}=${gnb_BTS_username}
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
    ...    ${password}=${gnb_BTS_password}    ${enbx2_dist}=${enbx2_dist}
    Perform full commission for COAM gnb     scf=${tl_scf_dir_path}${tl_scf_filename}
      ...    gnb_ip=${bts_host}    username=${username}    password=${password}
    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=locked
    COAM Wait for gnb ready    bts_host=${bts_host}    username=${username}    password=${password}
    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=unlocked
    wait until keyword succeeds    10min    30s    COAM Check GNB cell on air



Perform full commission for COAM gnb
    [Arguments]    ${scf}    ${gnb_ip}    ${username}    ${password}
    Connect to gnb coam via ssl   bts_host=${gnb_ip}    username=${username}      password=${password}
    COAM Commission with scf file    scf_file_path=${scf}    timeout=500    is_pdl_checking_needed=${True}
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



Modify the COAM parameter with admin API
    [Arguments]    ${parameters}    ${bts_host}=${gnb_BTS_host}
    ...    ${username}=${gnb_BTS_username}    ${password}=${gnb_BTS_password}    ${timeout}=${600}
    Connect to gnb coam via ssl     bts_host=${bts_host}    username=${username}    password=${password}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters}    timeout=${timeout}
    COAM Teardown gnb connections

Delete the COAM parameter with admin API
    [Arguments]    ${parameters}    ${bts_host}=${gnb_BTS_host}
    ...    ${username}=${gnb_BTS_username}    ${password}=${gnb_BTS_password}
    Connect to gnb coam via ssl     bts_host=${bts_host}    username=${username}    password=${password}
    COAM delete parameters via rest api    parameters_to_delete_via_api=${parameters}    timeout=${600}
    COAM Teardown gnb connections

Delete the COAM list with admin API
    [Arguments]    ${parameters_delete}    ${parameters_add}    ${bts_host}=${gnb_BTS_host}
    ...    ${username}=${gnb_BTS_username}    ${password}=${gnb_BTS_password}
    Connect to gnb coam via ssl     bts_host=${bts_host}    username=${username}    password=${password}
    COAM delete parameters via rest api    parameters_to_delete_via_api=${parameters_delete}   timeout=600
    COAM add several parameters via rest api    parameters_to_add_via_api=${parameters_add}   timeout=600
    COAM Teardown gnb connections

Modify temparameter9 and reset gnb
    [Arguments]    ${parameters}=${parameters}
    Modify the COAM parameter with admin API    parameters=${parameters}
    Reset gnb without modification
    COAM Wait for gnb ready    bts_host=${gnb_BTS_host}    username=${gnb_BTS_username}    password=${gnb_BTS_password}
    wait until keyword succeeds    10min    30s    COAM Check GNB cell on air

Lock unlock GNB AMF
    [Arguments]    ${parameters}    ${bts_host}=${gnb_BTS_host}
    ...    ${username}=${gnb_BTS_username}    ${password}=${gnb_BTS_password}
    Connect to gnb coam via ssl     bts_host=${bts_host}    username=${username}    password=${password}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters}
    COAM Teardown gnb connections

Unlock GNB AMF and check GNB onair
    [Arguments]
    Lock unlock GNB AMF    parameters=${UNLOCK_GNB_AMF}
    sleep    30s
    wait until keyword succeeds    10min    30s    Check Ng Link Status
#    COAM Teardown gnb connections

Check Ng Link Status
    WEBUI Login
    &{amf_status}    selenium_coam.get_amf_info
    should be equal    ${amf_status}[NG link status]    Active

Lock Unlock Enb Cell
    [Arguments]    ${dist_name}    ${parameter_name}    ${value}
    Connect to eNB via ssl
    Modify the parameter on enblte    dist_name=${dist_name}    parameter_name=${parameter_name}    value=${value}

Reset gnb without modification
    [Documentation]    This keyword is to reset GNB with admin
    coam.Setup Admin    bts_host=${gnb_BTS_host}    alias=reset
    coam.reset          connection=reset
    [Teardown]    Run Keyword And Ignore Error    coam.Teardown    connection=reset

Prepare gnb golden scf for test_case
    [Arguments]      ${scf_file_name_tmp}=${None}    ${ParamterToModify}='NULL'    ${ListParamterToModify}='NULL'
    ...    ${ParameterToDelete}='NULL'    ${empty_lists}='NULL'    ${TLS_golden}=${TL370_golden}
    csn.Connect to    hostname=${TestPC_addr}    username=${TestPC_username}    password=${TestPC_password}    alias=ute
    csn.send command    command=cp ${tl_scf_dir_path}${TLS_golden} ${tl_scf_dir_path}${scf_file_name_tmp}    connection=ute
    sleep    3s
    Modify golden SCF for specific cases    scf_file_name=${scf_file_name_tmp}    ParamterToModify=${ParamterToModify}
    ...    ListParamterToModify=${ListParamterToModify}    ParameterToDelete=${ParameterToDelete}
    ...    empty_lists=${empty_lists}

Add and Modify elements to scf
    [Arguments]   ${parameters_lists}
    FOR    ${item}    IN    @{parameters_lists}
        ${res}    scf.is_element_in_object    dist_name=${item}[dist_name]    p_name=${item}[p_name]
        Run Keyword If    '${res}'=='True'     scf.modify_scf_element    value=${item}[value]   ${item}
        ...      ELSE                          scf.add element to scf
        ...                                    value=${item}[value]   dist_name=${item}[dist_name]    p_name=${item}[p_name]
    END

Modify golden SCF for specific cases
    [Arguments]      ${scf_file_name}=${None}
    ...               ${scf_path}=${tl_scf_dir_path}
#    ...               ${scf_dir_path}=${SUITE_LOG_PATH}
    ...               ${ParameterToDelete}='NULL'
    ...               ${MOsToAdd}='NULL'
    ...               ${ParamterToModify}='NULL'
    ...               ${ListParamterToModify}='NULL'
    ...               ${ListToAdd}='NULL'
    ...               ${empty_lists}='NULL'
    wait until keyword succeeds    1min    15s    scf.Load scf    ${scf_path}${scf_file_name}
    run keyword if  not ${ParameterToDelete}=='NULL'     Delete Objects in SCF    parameters_lists=${ParameterToDelete}
    run keyword if  not ${empty_lists}=='NULL'     Add Empty lists in SCF    empty_lists=${empty_lists}
    run keyword if  not ${MOsToAdd}=='NULL'    Add MOs To SCF with Given version
    ...                                                   parameters_lists=${MOsToAdd}
    run keyword if  not ${ParamterToModify}=='NULL'     Add and Modify elements to scf
    ...                                                   parameters_lists=${ParamterToModify}
    run keyword if  not ${ListParamterToModify}=='NULL'     Modify ListElements to scf
    ...                                                       parameters_lists=${ListParamterToModify}
    run keyword if  not ${ListToAdd}=='NULL'     AddLists to SCF    parameters_lists=${ListToAdd}
    scf.Save scf    ${scf_path}${scf_file_name}

Add Empty lists in SCF
    [Arguments]     ${empty_lists}
    FOR    ${item}    IN    @{empty_lists}
        ${res_list_name}=    Run Keyword And Ignore error    set suite variable    ${list_name_to_add}   ${item}[list_name]
        ${elements_add}=    Run Keyword And Ignore error    set suite variable    ${elements_to_add}   ${item}[elements]
        Run Keyword If   ${res_list_name}== ('PASS', None)
        ...              Run Keyword And Ignore error    scf.add_list_to_scf    dist_name=${item}[dist_name]   list_name=${item}[list_name]
        Run Keyword If   ${elements_add}== ('PASS', None)
        ...              Run Keyword And Ignore error    Add default value to Empty lists in SCF    elements_lists=${item}[elements]
        ...    dist_name=${item}[dist_name]   list_name=${item}[list_name]
    END

Add default value to Empty lists in SCF
    [Arguments]     ${elements_lists}    ${dist_name}    ${list_name}
    FOR    ${item}    IN    @{elements_lists}
        scf.add_item_to_list    dist_name=${dist_name}  list_name=${list_name}    elements=${item}
    END

Delete Objects in SCF
    [Documentation]   Remove object , Mo, List, Element with p_name.
    [Arguments]     ${parameters_lists}
    FOR    ${item}    IN    @{parameters_lists}
        ${res_dist_name}=    Run Keyword And Ignore error    set suite variable    ${dist_name_to_delete}   ${item}[dist_name]
        ${res_list_name}=    Run Keyword And Ignore error    set suite variable    ${list_name_to_delete}   ${item}[list_name]
        ${res_p_name}=    Run Keyword And Ignore error    set suite variable    ${p_name_to_delete}   ${item}[p_name]
        Run Keyword If   ${res_p_name}== ('PASS', None)
        ...              Run Keyword And Ignore error    scf.Remove Element From Scf    &{item}
        Run Keyword If   ${res_list_name}== ('PASS', None) and ${res_p_name}!= ('PASS', None)
        ...              Run Keyword And Ignore error    scf.remove_list_from_scf    dist_name=${item}[dist_name]   list_name=${item}[list_name]
        Run Keyword If   ${res_list_name}!= ('PASS', None) and ${res_p_name}!= ('PASS', None)
        ...              Run Keyword And Ignore error    scf.remove_mo_with_descendant_mos    dist_name=${item}[dist_name]
    END

Modify ListElements to scf
    [Documentation]   Modify List element. report error If not present
    [Arguments]   ${parameters_lists}
    FOR    ${item}    IN    @{parameters_lists}
        ${res}    scf.is_list_in_object    dist_name=${item}[dist_name]    list_name=${item}[list_name]
        Run Keyword If    '${res}'=='True'  Modify SCF ListElements   dist_name=${item}[dist_name]  list_name=${item}[list_name]
        ...        elements=${item}[elements]
    END

Modify SCF ListElements
    [Arguments]   ${dist_name}    ${list_name}    ${elements}
    FOR    ${item}   IN    @{elements}
        scf.modify_scf_element    value=${item}[value]   dist_name=${dist_name}  list_name=${list_name}
        ...    p_name=${item}[p_name]    index=${item}[index]
    END

AddLists to SCF
    [Documentation]   add List items and elements, if the items are present, remove it first.
    [Arguments]    ${parameters_lists}
    FOR    ${item}    IN    @{parameters_lists}
        ${res}    scf.is_list_in_object    dist_name=${item}[dist_name]    list_name=${item}[list_name]
        Run Keyword If    '${res}'!='True'     scf.add_list_to_scf    dist_name=${item}[dist_name]    list_name=${item}[list_name]
        ${res}=    Run Keyword And Ignore error    scf.add item to list
        ...        dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
        Run keyword if    ${res} != ('PASS', None)    scf.add_elements_to_list
        ...        dist_name=${item}[dist_name]    list_name=${item}[list_name]    elements=${item}[elements]
    END

Add MOs To SCF with Given version
    [Documentation]   Add Mos for given version, used for add channels
    [Arguments]   ${parameters_lists}
    ${channel_version}=    scf.get_mo_attribute    MRBTS-${tl.gnbs[0].instance_id}/MNL-1/MNLENT-1/CELLMAPPING-1    version
    FOR    ${item}    IN    @{parameters_lists}
        scf.add object to scf  class_name=${item}[class_name]    dist_name=${item}[dist_name]   version=${channel_version}
    END

###log capture###
##Wireshark log##
Start To Capture Wireshark Logs on ASIB
    [Arguments]     ${filename}    ${asik_addr}=${asik_addr}    ${asik_username}=${asik_username}    ${asik_password}=${asik_password}
    ...    ${connection}=gnb    ${interface}=any
    gNB connections    asik_addr=${asik_addr}    asik_username=${asik_username}    asik_password=${asik_password}
    csn.send command    command=tcpdump -i ${interface} sctp -w ${gnb_path}${filename}    connection=${connection}

Stop and download wireshark Logs on ASIB
    [Arguments]    ${logname}    ${asik_addr}=${asik_addr}    ${asik_username}=${asik_username}    ${asik_password}=${asik_password}
    ...    ${connection}=gnb
    gNB connections    asik_addr=${asik_addr}    asik_username=${asik_username}    asik_password=${asik_password}
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
    [Arguments]     ${ue_type}=${ue_type}     ${reset_sol}=none
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${0}     reset_sol=${reset_sol}

Power UE Start UL traffic
    [Arguments]    ${ul_throughput}   ${duration}=${UL_TIME}    ${ul_length}=${UL_LENGTH}    ${ul_port}=${UL_PORT}
    ...    ${ue_index}=${0}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_throughput}    duration=${duration}
    ...                       iperf_port=${ul_port}    ue_index=${ue_index}    cap_index=${0}    buffer_size=${ul_length}

Check the cell DLUL throughput
    [Arguments]      ${nrcellid}    ${dlexpect}    ${ulexpect}    ${ue_type}=${ue_type}
    Wait Until Keyword Succeeds   5x    10s    power_ue.Check Throughput    sample=${6}
    ...    ue_type=${ue_type}    direction=dl    throughput=${dlexpect}    cellid=${nrcellid}    sleep_time=${20}
    Wait Until Keyword Succeeds   5x    10s    power_ue.Check Throughput    sample=${6}
    ...    ue_type=${ue_type}    direction=ul    throughput=${ulexpect}    cellid=${nrcellid}    sleep_time=${20}

Power UE check throughput with nrcellid
    [Arguments]    ${throughput}=${${${throughput}}[0]}
    ${dl_tp_l2l0}    Wait Until Keyword Succeeds   5x    10s
    ...    check tput with diff tl new way     throughput=${throughput}
    [Return]     ${dl_tp_l2l0}

DL Tput check with nrcellid
    [Arguments]    ${cellid}    ${dlexpect_tp}    ${ue_type}=${ue_type}    ${duration}=1m
    ${list_of_cell_ids}    Create list    ${cellid}
    ${log_path}     Power_ue.Collect Tput    ue_type=${ue_type}    duration=${duration}
    ${output}    Power_ue.Check Tput    ue_type=${ue_type}    direction=DL    log=${log_path}    cells=${list_of_cell_ids}
    ...    target_throughput=${dlexpect_tp}
    [Return]    ${output}

Power UE stop dl traffic
    [Arguments]    ${dl_port}=${DL_PORT}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    iperf_port=${dl_port}

Power UE stop ul traffic
    [Arguments]    ${ul_port}=${UL_PORT}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    iperf_port=${ul_port}

Power UE Detach
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}



##ASKEY##
Power UE Attach and Verify attach for askey
    [Arguments]    ${4g_check}    ${ue_type}=${ue_type}    ${gnb_index}=${0}
     Wait until keyword succeeds    4X    5s    attach ue for askey one time    4g_check=${4g_check}    ue_type=${ue_type}    gnb_index=${gnb_index}

attach ue for askey one time
    [Arguments]    ${4g_check}    ${ue_type}=${ue_type}    ${interval}=${1}    ${gnb_index}=${0}
    ${status}    ${5Grach_ed}    run keyword and ignore error  power_ue.UE Attach
    ...    ue_type=${ue_type}   ue_index=${0}    interval=${interval}     gnb_index=${gnb_index}
    ${5Grach_2ed}    run keyword if    '${status}'=='FAIL'    At Cmd UE reAttach    ue_index=${0}
    ${5Grach_ed}    set variable if    '${status}'=='FAIL'    ${5Grach_2ed}    ${5Grach_ed}
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    ue_index=${0}    4G_check=${4g_check}

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

Askey UE stop dl traffic on appserver and detach
    [Arguments]    ${ue_index}=${0}    ${DL_port}=${ASKEY_DL_PORT}    ${ue_type}=${ue_type}
    wait until keyword succeeds    1 min    10 sec    Connect to EPC APP    ue_index=${ue_index}    hostname=${iperf_hostname}
    ...    username=${iperf_username}    password=${iperf_password}
    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${DL_port}| awk '{print $2}' |xargs kill -9    connection=EPCAPP
    sleep    1s
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}
    sleep    2s
    [Teardown]    csn.disconnect      connection=EPCAPP

Askey UE stop DL traffic
    [Arguments]    ${ue_index}=${0}     ${DL_port}=${ASKEY_DL_PORT}
    wait until keyword succeeds    1 min    10 sec    Connect to EPC APP    ue_index=${ue_index}    hostname=${iperf_hostname}
    ...    username=${iperf_username}    password=${iperf_password}
    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${DL_port}| awk '{print $2}' |xargs kill -9    connection=EPCAPP
    sleep    1s

At Cmd UE reAttach
    [Arguments]     ${gnb_index}=${0}    ${hwcheck_index}=${1}    ${du_index}=0
    ...    ${log_type}=Aasyslog      &{kwargs}
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
    ute_ue.send_at_cmd_to_ue    alias=UE_0    at_cmd=at+cops=1,2,${mcc}${mnc}
    [Return]    ${5Gra_l2lo_counter}    ${5Gra_l2lo_timed}    ${hwcheck_index}    ${log_type}
    ...    ${5Gra_l2hidu_counter}    ${5Gra_l2hidu_timed}

##### UE #####
UE precondition with uetype
    [Arguments]     ${ue_type}=${ue_type_0}    ${ue_index}=${0}    ${reset_sol}=none
    Run Keyword If    '${MRBTS_ID}' == '11006' or '${MRBTS_ID}' == '10318'
    ...      power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}    reset_sol=${reset_sol}
    Run Keyword If    '${MRBTS_ID}' == '10175'     Prepare MultiUE with client


attach UE with uetype and capture wiresharklog
    [Arguments]    ${wiresharklog}    ${ue_num}    ${attach_mode}=${SA_attach_mode}    ${ue_mode}=${SA_UE_MODE}    ${nettpye}=${SA_nettype}
    ...     ${apn_address}=${SA_apn_addr}    ${4G_check}=False    ${options}=-i any sctp -s 0
    Start Capture CP-IF logs from Container     tcpdump_collector_name=${wiresharklog}    options=${options}
    Run Keyword And Continue On Failure
    ...     UE attach with Diff uetype    ue_num=${ue_num}    attach_mode=${attach_mode}    ue_mode=${ue_mode}    nettpye=${nettpye}
    ...                           apn_address=${apn_address}    4G_check=${4G_check}
    sleep    1s
    ${cpif_log_path}    Stop CP-IF log Collection    tcpdump_collector_name=${wiresharklog}    target_dir=${epc_log_path}
    [Return]     ${cpif_log_path}

UE attach with Diff uetype
    [Arguments]    ${ue_num}=${None}    ${attach_mode}=${SA_attach_mode}    ${ue_mode}=${SA_UE_MODE}   ${nettpye}=${SA_nettype}
    ...    ${apn_address}=${SA_apn_addr}    ${ue_index}=${0}    ${4G_check}=False
    Run Keyword If    '${MRBTS_ID}' == '10175'    Multi-UE attach and Verify    ue_num=${ue_num}    attach_mode=${attach_mode}
    ...                                           ue_mode=${ue_mode}    nettpye=${nettpye}    apn_address=${apn_address}    UE_TYPE=${ue_type_1}
    Run Keyword If    '${MRBTS_ID}' == '11006' or '${MRBTS_ID}' == '10318'
    ...    UE attach for QCOM and verify with retry    ue_type=${ue_type_0}    ue_index=${ue_index}    4G_check=${4G_check}


Start DL Traffic And Capture Biplog
    [Arguments]       ${apn_address}=${SA_apn_addr}    ${ue_mode}=${SA_UE_MODE}
    ...    ${dlexpect_tp}=${Expect_dl_enable}    ${ue_num}=1    ${duration}=1m    ${bbmod_slots}=1
    Start UE traffic and check tput    apn_address=${apn_address}     ue_mode=${ue_mode}
    ...                                cellid=${nrcellid}    dlexpect_tp=${dlexpect_tp}    ue_num=${ue_num}    duration=${duration}
    log to console    start to cpature biplog
    ${bip}=    Capture biplog and download    bbmod_slots=${bbmod_slots}
    [Return]     ${bip}

Start UE traffic and check tput
    [Arguments]     ${ue_num}=1     ${apn_address}=${SA_apn_addr}     ${ue_mode}=${SA_UE_MODE}
    ...    ${cellid}=${nrcellid}    ${dlexpect_tp}=@{Expect_dl_enable[0]}    ${duration}=1m
    UE start DLData Traffic with Diff uetype    ue_num=${ue_num}    ue_mode=${ue_mode}    apn_address=${apn_address}    dlexpect=${dlexpect_tp}
    sleep    30s
    log to console    check tput with nrcellid
    Check Dl traffic with nrcellid for uetype    cellid=${cellid}     dlexpect_tp=${dlexpect_tp}    duration=${duration}

Check tput and capture Biplog
    [Arguments]       ${dlexpect_tp}    ${cellid}=${nrcellid}    ${duration}=1m    ${bbmod_slots}=1
    Check Dl traffic with nrcellid for uetype    dlexpect_tp=${dlexpect_tp}    cellid=${cellid}    duration=${duration}
    log to console    start to cpature biplog
    ${bip}=    Capture biplog and download    bbmod_slots=${bbmod_slots}
    [Return]     ${bip}


UE start DLData Traffic with Diff uetype
    [Arguments]    ${ue_num}=${None}    ${ue_mode}=${SA_UE_MODE}    ${apn_address}=${SA_apn_addr}
    ...            ${ue_index}=${0}    ${dlexpect}=${dlexpect_tp}    ${dltput}=10
    Run Keyword If    '${MRBTS_ID}' == '10175'    Multi-UEs start Data Transfer    ue_num=${ue_num}    ue_mode=${ue_mode}    dlexpect=${dlexpect}
    ...    apn_address=${apn_address}    throughput=${Multi_dl_throughput}    ue_type=${ue_type_1}    duration=${DL_TIME}
    Run Keyword If    '${MRBTS_ID}' == '11006' or '${MRBTS_ID}' == '10318'
    ...    Power UE Start DL traffic    dl_throughput=${dltput}    duration=${DL_TIME}
    ...    dl_length=${DL_LENGTH}    dl_port=${DL_PORT}    ue_index=${ue_index}    process_num=${1}    ue_type=${ue_type_0}

Check Dl traffic with nrcellid for uetype
    [Arguments]     ${dlexpect_tp}    ${cellid}=${nrcellid}    ${duration}=1m
    Run Keyword If    '${MRBTS_ID}' == '11006' or '${MRBTS_ID}' == '10318'
    ...    DL Tput collect and check with nrcellid    cellid=${cellid}     dlexpect_tp=${dlexpect_tp}    duration=${duration}    ue_type=${ue_type_0}
    Run Keyword If    '${MRBTS_ID}' == '10175'
    ...    DL Tput collect and check with nrcellid    cellid=${cellid}     dlexpect_tp=${dlexpect_tp}    duration=${duration}    ue_type=${ue_type_1}

UE stop traffic and detach with uetype
    [Arguments]     ${ue_num}=1
    Run Keyword If    '${MRBTS_ID}' == '10175'
    ...                Multi UE Detach And Stop Traffic    ue_num=${ue_num}
    Run Keyword If    '${MRBTS_ID}' == '11006' or '${MRBTS_ID}' == '10318'
    ...                Power UE stop dl traffic and detach    dl_port=${DL_PORT}    ue_type=${ue_type_0}    ue_index=${0}


Capture biplog and download to UTE
    [Arguments]      ${script_path}    ${capturing_time_seconds}=5
    BIPlog Precondition And Capture With Scripts    script_path=${script_path}    capturing_time_seconds=${capturing_time_seconds}
    sleep     15s
    ${tmpbip}=    Download BIP Logs From ASIK To TestPC and rename it    log_path=${epc_log_path}
    [Return]     ${tmpbip[0]}

Capture biplog and download
    [Arguments]        ${bbmod_slots}=1
    Run Keyword If    '${MRBTS_ID}' == '10318' and '${release_info}' == 'SBTS23R2_ENB_9999'
    ...    Collect Interface Mirroring Bip Collector from WEBUI     target_dir=${epc_log_path}    times=5s
    sleep     15s
    ${tmpbip}=    Run Keyword If    '${MRBTS_ID}' == '10318' and '${release_info}' == 'SBTS23R2_ENB_9999'
    ...    Get Bip Log Via Interface Mirroring Collector to UTE    target_dir=${epc_log_path}
    ...    ELSE
    ...    Capture BIPlog with gnb_logs and Download    bbmod_slots=${bbmod_slots}
    Run Keyword If    '${MRBTS_ID}' == '10318' and '${release_info}' == 'SBTS23R2_ENB_9999'    Set Test Variable    ${tmpbip}    ${tmpbip[0]}
    [Return]     ${tmpbip}

Capture BIPlog with gnb_logs and Download
    [Arguments]    ${bbmod_slots}=1
    ...            ${duration}=2
    ...            ${gnb_logs_script_path}=/opt/workspace/gnb_logs
    ...            ${gnb_index}=0
    ...            ${du_index}=0
    ...            ${log_type}=BIP
    Capture Logs With gNB_logs_exe File    bbmod_slots=${bbmod_slots}      duration=${duration}
    ...            gnb_logs_script_path=${gnb_logs_script_path}
    ...            gnb_index=${gnb_index}       du_index=${du_index}      log_type=${log_type}
    ${biplogs}    Get Captured BIP File from UTE    gnb_logs_script_path=${gnb_logs_script_path}
    ...            target_dir=${epc_log_path}     gnb_index=${gnb_index}     du_index=${du_index}      log_type=${log_type}
    [Return]     ${biplogs[0]}

Stop Qualcomme Background Data
    [Arguments]      ${ue_index}=${0}
    Connect to control pc enhanced
    csn.Send Command     command=adb root     connection=cpc_${ue_index}
    sleep    5s
    csn.Send Command     command=adb shell iptables -A OUTPUT -p udp --dport 53 -j REJECT      connection=cpc_${ue_index}

Reset ASKEY ue Before Test
    [Arguments]      ${ue_index}=${0}
    Connect to control pc enhanced    cpc_ip=${askey_hostname}    cpc_usrname=${askey_username}    cpc_passwd=${askey_password}
    csn.Send Command     command=adb reboot     connection=cpc_${ue_index}
    sleep    10s


####
Case variable set for ${case_key}
    test suite variable set for ${case_key}
#    Set Test Tag

test suite variable set for ${case_key}
    ${release_info}    Get sagnb release
    set suite variable     ${TestLine_ID}     BTS_${MRBTS_ID}
    Run Keyword And Ignore Error    set suite variable    ${golden_scf_name}      ${para_store['${case_key}']['${release_info}']['golden_scf_name']}
    Run Keyword And Ignore Error    set suite variable    ${golden_scf_name}      ${para_store['${case_key}']['${TestLine_ID}']['golden_scf_name']}
    Run Keyword And Ignore Error    set suite variable    ${att_value}            ${para_store['${case_key}']['${TestLine_ID}']['att_value']}
    Run Keyword And Ignore Error    set suite variable    ${cellid}               ${para_store['${case_key}']['${TestLine_ID}']['cellid']}
    Run Keyword And Ignore Error    set suite variable    ${ENB_cell_dist}        ${para_store['${case_key}']['${TestLine_ID}']['ENB_cell_dist']}
    Run Keyword And Ignore Error    set suite variable    ${enbx2_dist}           ${para_store['${case_key}']['${TestLine_ID}']['enbx2_dist']}
    Run Keyword And Ignore Error    set suite variable    ${hw_slot}              ${para_store['${case_key}']['${TestLine_ID}']['hw_slot']}
    Run Keyword And Ignore Error    set suite variable    ${dlexpect_tp}     ${para_store['${case_key}']['${TestLine_ID}']['dlexpect_tp']}
    Run Keyword And Ignore Error    set suite variable    ${DRX_onduration}       ${para_store['${case_key}']['${TestLine_ID}']['DRX_onduration']}
    Run Keyword And Ignore Error    set suite variable
    ...                             ${beamweight_name}             ${para_store['${case_key}']['${TestLine_ID}']['beamweight_name']}
    Run Keyword And Ignore Error    set suite variable
    ...                             ${ParamterToModify}            ${para_store['${case_key}']['${TestLine_ID}']['ParamterToModify']}
    Run Keyword And Ignore Error    set suite variable
    ...                             ${ListParamterToModify}        ${para_store['${case_key}']['${TestLine_ID}']['ListParamterToModify']}
    Run Keyword And Ignore Error    set suite variable
    ...                             ${ParameterToDelete}            ${para_store['${case_key}']['${TestLine_ID}']['ParameterToDelete']}
    Run Keyword And Ignore Error    set suite variable
    ...                             ${ListToAdd}            ${para_store['${case_key}']['${TestLine_ID}']['ListToAdd']}
    Run Keyword And Ignore Error    set suite variable    ${bpf_name}             ${para_store['${case_key}']['${TestLine_ID}']['bpf_name']}
    Run Keyword And Ignore Error    set suite variable    ${ungzip_bpf_name}      ${para_store['${case_key}']['${TestLine_ID}']['ungzip_bpf_name']}
    Run Keyword And Ignore Error    set suite variable    ${bpf_name_xml}         ${para_store['${case_key}']['${TestLine_ID}']['bpf_name_xml']}
    Run Keyword And Ignore Error    set suite variable    ${mcs_alias}            ${para_store['${case_key}']['${TestLine_ID}']['mcs_alias']}
    Run Keyword And Ignore Error    set suite variable    ${BBMOD_ID}            ${para_store['${case_key}']['${TestLine_ID}']['BBMOD_ID']}
    Run Keyword And Ignore Error    set suite variable    ${first_horizontal}     ${para_store['${case_key}']['${TestLine_ID}']['first_horizontal']}
    Run Keyword And Ignore Error    set suite variable    ${second_horizontal}    ${para_store['${case_key}']['${TestLine_ID}']['second_horizontal']}
    Run Keyword And Ignore Error    set suite variable    ${dl_tput_multiue}    ${para_store['${case_key}']['${release_info}']['dl_tput_multiue']}




Prepare gnb parameters for test_case
    [Arguments]   ${parameters}=${parameters}
    Modify the COAM parameter with admin API    parameters=${parameters}    timeout=${timeout}
    COAM Wait for gnb ready    bts_host=${gnb_BTS_host}    username=${gnb_BTS_username}    password=${gnb_BTS_password}
    wait until keyword succeeds    10min    30s    COAM Check GNB cell on air

Select branch and variable for ${case_key}            # 2200C&D
    ${release_info}    Get sagnb release
    set suite variable    ${release_info}
    set suite variable    ${qc_id}    ${para_store['${case_key}']['${release_info}']['qc_id']}
    set suite variable    ${mcs_alias}    ${para_store['${case_key}']['${release_info}']['mcs_alias']}



Set nrcellid suit varaible
    [Arguments]    ${cellid}    ${gnb_index}=${0}
    ${nrcellid}    COAM Get nrcellid with the lcrid    lcrid=${cellid}    gnb_index=${gnb_index}
    set suite variable    ${nrcellid}
    [Return]    ${nrcellid}

##COMMON CHECK POINTS##
Check beamweight for CNI74278
    [Arguments]     ${beamweight_name}    ${connection}    ${beamset_num}
    gNB connections    asik_addr=${asik_addr}    asik_username=${asik_username}    asik_password=${asik_password}
    csn.download_file    remote_path=${beamweight_path}${beamweight_name}    local_path=/tmp/beamset.txt    connection=${connection}
    csn.Connect to    hostname=${TestPC_addr}    username=${TestPC_username}    password=${TestPC_password}    alias=ute
    csn.send command    cat /tmp/beamset.txt    connection=ute
    ${beamweight}=    ssh.read_output   connection=ute
    ${elem_lines}=    Get Lines Containing String    ${beamweight}    elements
    ${num}=    Get Line Count    ${elem_lines}
    Should Be Equal As Integers    ${num}    ${beamset_num}


Check beamweight size for CNI65655
    [Arguments]     ${beamweight_name}    ${connection}     ${bpf_name}     ${ungzip_bpf_name}    ${bpf_name_xml}
    gNB connections    asik_addr=${asik_addr}    asik_username=${asik_username}    asik_password=${asik_password}
    csn.download_file    remote_path=${beamweight_path}${beamweight_name}
    ...    local_path=${epc_log_path}${beamweight_name}    connection=${connection}
    csn.Connect to    hostname=${TestPC_addr}    username=${TestPC_username}    password=${TestPC_password}    alias=ute
    ${values}    read_beam_weight_size    ${epc_log_path}${beamweight_name}
    ${max_im}    Set Variable    ${values}[0]
    ${min_im}    Set Variable    ${values}[1]
    ${max_re}    Set Variable    ${values}[2]
    ${min_re}    Set Variable    ${values}[3]
    ${eCPRI_fomat_max}    ${eCPRI_fomat_min}    GET eCPRI fomat from bpf
    ...    bpf_name=${bpf_name}    ungzip_bpf_name=${ungzip_bpf_name}    bpf_name_xml=${bpf_name_xml}
    Should Be True    ${max_im} <= ${eCPRI_fomat_max}
    Should Be True    ${min_im} >= ${eCPRI_fomat_min}
    Should Be True    ${max_re} <= ${eCPRI_fomat_max}
    Should Be True    ${min_re} >= ${eCPRI_fomat_min}

GET eCPRI fomat from bpf
    [Arguments]      ${bpf_name}=*_AE_QV.gz     ${ungzip_bpf_name}=475294A_AE_QV     ${bpf_path}=/tmp/bpf/
    ...     ${connection}=GNB_OAM      ${bpf_name_xml}=AE_QV.xml
    Connect to gnb coam via ssl
    ${fsm_type}=    coam_gnb_classical.COAM Get FSM Type    connection=${connection}
    ${alias}    set variable if    '${fsm_type}'=='ASIB'    ASIK Slave    ASIK Master
    Run Keyword If    '${fsm_type}'=='ASIB'    Connect to Common Unit Master    alias=${alias}
    ...    ELSE    Connect to Common Unit Slave    alias=${alias}
    ${ungzip_bpf}     csn.execute    command=gzip -d ${bpf_path}${bpf_name}     connection=${alias}
    csn.download_file    remote_path=${bpf_path}${ungzip_bpf_name}
    ...    local_path=${epc_log_path}${bpf_name_xml}    connection=${alias}
    csn.Connect to    hostname=${TestPC_addr}    username=${TestPC_username}    password=${TestPC_password}    alias=ute
    ${eCPRI_format_exp}      set variable     (?<=>eCPRI<).*?(?=</p>)
    ${eCPRI_format_output}     csn.execute     command=cat ${epc_log_path}${bpf_name_xml}| grep -oP '${eCPRI_format_exp}'   connection=ute
    ${eCpri_format_1}=    String.Split String    ${eCPRI_format_output}    (
    ${eCpri_format_2}=    String.Split String    ${eCpri_format_1[1]}    )
    ${eCpri_format_3}=    String.Split String    ${eCpri_format_2[0]}    \.
    ${eCPRI_fomat}=     Evaluate     ${eCpri_format_3[2]}
    ${eCPRI_fomat_max}     Evaluate     2**${eCPRI_fomat}
    ${eCPRI_fomat_min}     Evaluate     -(2**${eCPRI_fomat})
    [Return]     ${eCPRI_fomat_max}    ${eCPRI_fomat_min}


##HBTE PA##
HBTE PA ON 22R3
    [Arguments]    ${att_ports}=${PA_port_list}    ${values}=${PA_values}    ${att_connection_port}=${att_connection_port}
    Set the attenuation value    ${att_ports}    ${values}    ${att_connection_port}

##Analysis pdml log##
Convert CPIF Pcap log To Pdml
    [Documentation]    Description: convert to cpif pcap to pdml format, pdml can be used for value check.
    [Arguments]    ${file_path}
    ...            ${tshark_path}=/usr/bin/tshark
    ...            ${filter}=nr-rrc
    ...            ${alias}=parser
    ${command_template}   Catenate    ${tshark_path} -r ${file_path} -Y \"${filter}\" -T pdml
    cap.load_pcap_file    pcap_file=${file_path}    command_template=${command_template}    alias=${alias}

Get Field Value From Pdml file
    [Documentation]    Description: get field value from pdml file.
    [Arguments]    ${filter_expression}    ${xpath}    ${attribute_name}=show    ${alias}=parser
    cap.filter_packets_by_expression    filter_expression=${filter_expression}    pcap_parser=${alias}
    ${field_value}=    cap.get_field_value_by_xpath    xpath=${xpath}    attribute_name=${attribute_name}    pcap_parser=${alias}
    [Return]    ${field_value}

Check Target Item Value on CPIF Tcpdump log
    [Documentation]       Description:check target item value on CPIF tcpdump log.
    [Arguments]    ${file_path}
    ...            ${filter_expression}
    ...            ${xpath}
    ...            ${tshark_path}=/usr/bin/tshark
    ...            ${filter}=f1ap||nr-rrc||ngap
#    ...            ${command_template}={tshark_path} -r {pcap_file} -Y \"${filter}\" -T pdml
    ...            ${attribute_name}=show
    Convert CPIF Pcap log To Pdml    file_path=${file_path}
    ...                          tshark_path=${tshark_path}
    ...                          filter=${filter}
#    ...                          command_template=${command_template}
    ${filter_output}    Get Field Value From Pdml file    filter_expression=${filter_expression}
    ...                                              xpath=${xpath}
    ...                                              attribute_name=${attribute_name}
    [Return]    ${filter_output}

Get DRX_LongCycle from CPIF
    [Arguments]    ${file_path}
    ${message_filter_expression}    Catenate    nr-rrc.rrcReconfiguration_element &&
    ...                                         nr-rrc.drx_Config == 1
    ${DRX_LongCycle_0}    Check Target Item Value on CPIF Tcpdump log
    ...            file_path=${file_path}
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//nr-rrc.setup_element/nr-rrc.drx_LongCycleStartOffset
    ...            attribute_name=showname
    ${DRX_LongCycle_1}=    String.Split String    ${DRX_LongCycle_0[0]}    :${SPACE}
    ${DRX_LongCycle_2}=    String.Split String    ${DRX_LongCycle_1[1]}    ${SPACE}(
    [Return]    ${DRX_LongCycle_2[0]}

Get DRX_Config from CPIF
    [Arguments]    ${file_path}
    ${message_filter_expression}    Catenate    nr-rrc.rrcReconfiguration_element
    ${DRX_Config}    Check Target Item Value on CPIF Tcpdump log
    ...            file_path=${file_path}
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//nr-rrc.drx_Config
    [Return]    ${DRX_Config}

Get DRX_StarOffset from CPIF
    [Arguments]    ${file_path}
    ${DRX_LongCycle}=    Get DRX_LongCycle from CPIF    file_path=${file_path}
    ${message_filter_expression}    Catenate    nr-rrc.rrcReconfiguration_element &&
    ...                                         nr-rrc.drx_Config == 1
    ${DRX_StarOffset_0}    Check Target Item Value on CPIF Tcpdump log
    ...            file_path=${file_path}
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//nr-rrc.setup_element/nr-rrc.drx_LongCycleStartOffset/nr-rrc.${DRX_LongCycle}
    [Return]    ${DRX_StarOffset_0[0]}

Get DRX_onduration timer from CPIF
    [Arguments]    ${file_path}
    ${message_filter_expression}    Catenate    nr-rrc.rrcReconfiguration_element &&
    ...                                         nr-rrc.drx_Config == 1
    ${milliSeconds_0}    Check Target Item Value on CPIF Tcpdump log
    ...            file_path=${file_path}
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//nr-rrc.setup_element/nr-rrc.drx_onDurationTimer/nr-rrc.milliSeconds
    ...            attribute_name=showname
    ${milliSeconds_1}=    String.Split String    ${milliSeconds_0[0]}    :${SPACE}
    ${milliSeconds_2}=    String.Split String    ${milliSeconds_1[1]}    (
    ${milliSeconds}=    String.Remove String    ${milliSeconds_2[0]}    ms
    [Return]    ${milliSeconds}

Get DRX_slotoffset from CPIF
    [Arguments]    ${file_path}
    ${message_filter_expression}    Catenate    nr-rrc.rrcReconfiguration_element &&
    ...                                         nr-rrc.drx_Config == 1
    ${drx_slotoffset_0}    Check Target Item Value on CPIF Tcpdump log
    ...            file_path=${file_path}
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//nr-rrc.setup_element/nr-rrc.drx_SlotOffset
    ...            attribute_name=showname
    ${drx_slotoffset_1}=    String.Split String    ${drx_slotoffset_0[0]}    :${SPACE}
    ${drx_slotoffset_2}=    String.Split String    ${drx_slotoffset_1[1]}    ${SPACE}(
    ${drx_slotoffset}=    String.Remove String    ${drx_slotoffset_2[0]}    ms
    [Return]    ${drx_slotoffset}

Get CQI_Reportslot from CPIF
    [Arguments]    ${file_path}
    ...    ${periodic_element}=_[1]/nr-rrc.CSI_ReportConfig_element/nr-rrc.reportConfigType/nr-rrc.periodic_element
    ${CQI_Reportperiodicity}=    Get CQI_Reportperiodicity from CPIF    file_path=${file_path}
    ${message_filter_expression}    Catenate    nr-rrc.rrcReconfiguration_element &&
    ...                                         nr-rrc.csi_MeasConfig == 1
    ${CQI_Reportslot_0}    Check Target Item Value on CPIF Tcpdump log
    ...            file_path=${file_path}
    ...            filter_expression=${message_filter_expression}
    ...    xpath=.//${periodic_element}/nr-rrc.reportSlotConfig/nr-rrc.${CQI_Reportperiodicity}
    [Return]    ${CQI_Reportslot_0[0]}

Get CQI_Reportperiodicity from CPIF
    [Arguments]    ${file_path}
    ...    ${periodic_element}=_[1]/nr-rrc.CSI_ReportConfig_element/nr-rrc.reportConfigType/nr-rrc.periodic_element
    ${message_filter_expression}    Catenate    nr-rrc.rrcReconfiguration_element &&
    ...                                         nr-rrc.csi_MeasConfig == 1
    ${CQI_Reportperiodicity_0}    Check Target Item Value on CPIF Tcpdump log
    ...            file_path=${file_path}
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//${periodic_element}/nr-rrc.reportSlotConfig
    ...            attribute_name=showname
    ${CQI_Reportperiodicity_1}=    String.Split String    ${CQI_Reportperiodicity_0[0]}    :${SPACE}
    ${CQI_Reportperiodicity_2}=    String.Split String    ${CQI_Reportperiodicity_1[1]}    ${SPACE}(
    [Return]    ${CQI_Reportperiodicity_2[0]}

Get CsiReport_Pucch_resource from CPIF
    [Arguments]    ${file_path}    ${report_index}=1
    ...    ${periodic_element}=_[${report_index}]/nr-rrc.CSI_ReportConfig_element/nr-rrc.reportConfigType/nr-rrc.periodic_element/
    ${message_filter_expression}    Catenate    nr-rrc.rrcReconfiguration_element &&
    ...                                         nr-rrc.csi_MeasConfig == 1
    ${CsiReport_Pucch_resource}    Check Target Item Value on CPIF Tcpdump log
    ...            file_path=${file_path}
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//${periodic_element}/nr-rrc.pucch_CSI_ResourceList/_/nr-rrc.PUCCH_CSI_Resource_element/nr-rrc.pucch_Resource
    ...            attribute_name=show
    [Return]    ${CsiReport_Pucch_resource[0]}

Get CsiReport_uplinkBandwidthPartId from CPIF
    [Arguments]    ${file_path}    ${report_index}=1
    ...    ${periodic_element}=_[${report_index}]/nr-rrc.CSI_ReportConfig_element/nr-rrc.reportConfigType/nr-rrc.periodic_element/
    ${message_filter_expression}    Catenate    nr-rrc.rrcReconfiguration_element &&
    ...                                         nr-rrc.csi_MeasConfig == 1
    ${uplinkBandwidthPartId}    Check Target Item Value on CPIF Tcpdump log
    ...            file_path=${file_path}
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//${periodic_element}/nr-rrc.pucch_CSI_ResourceList/_/nr-rrc.PUCCH_CSI_Resource_element/nr-rrc.uplinkBandwidthPartId
    ...            attribute_name=show
    [Return]    ${uplinkBandwidthPartId[0]}

Get SSB_Reportperiodicity from CPIF
    [Arguments]    ${file_path}
    ...    ${periodic_element}=_[2]/nr-rrc.CSI_ReportConfig_element/nr-rrc.reportConfigType/nr-rrc.periodic_element
    ${message_filter_expression}    Catenate    nr-rrc.rrcReconfiguration_element &&
    ...                                         nr-rrc.csi_MeasConfig == 1
    ${SSB_Reportperiodicity_0}    Check Target Item Value on CPIF Tcpdump log
    ...            file_path=${file_path}
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//${periodic_element}/nr-rrc.reportSlotConfig
    ...            attribute_name=showname
    ${SSB_Reportperiodicity_1}=    String.Split String    ${SSB_Reportperiodicity_0[0]}    :${SPACE}
    ${SSB_Reportperiodicity_2}=    String.Split String    ${SSB_Reportperiodicity_1[1]}    ${SPACE}(
    [Return]    ${SSB_Reportperiodicity_2[0]}

Get SSB_Reportslot from CPIF
    [Arguments]    ${file_path}
    ...    ${periodic_element}=_[2]/nr-rrc.CSI_ReportConfig_element/nr-rrc.reportConfigType/nr-rrc.periodic_element
    ${SSB_Reportperiodicity}=    Get CQI_Reportperiodicity from CPIF    file_path=${file_path}
    ${message_filter_expression}    Catenate    nr-rrc.rrcReconfiguration_element &&
    ...                                         nr-rrc.csi_MeasConfig == 1
    ${SSB_Reportslot_0}    Check Target Item Value on CPIF Tcpdump log
    ...            file_path=${file_path}
    ...            filter_expression=${message_filter_expression}
    ...    xpath=.//${periodic_element}/nr-rrc.reportSlotConfig/nr-rrc.${SSB_Reportperiodicity}
    [Return]    ${SSB_Reportslot_0[0]}

Get CSIRS_periodicity from CPIF
    [Arguments]    ${file_path}
    ${message_filter_expression}    Catenate    nr-rrc.rrcReconfiguration_element &&
    ...                                         nr-rrc.csi_MeasConfig == 1
    ${CSIRS_periodicity_0}    Check Target Item Value on CPIF Tcpdump log
    ...            file_path=${file_path}
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//_[1]/nr-rrc.NZP_CSI_RS_Resource_element/nr-rrc.periodicityAndOffset
    ...            attribute_name=showname
    ${CSIRS_periodicity_1}=    String.Split String    ${CSIRS_periodicity_0[0]}    :${SPACE}
    ${CSIRS_periodicity_2}=    String.Split String    ${CSIRS_periodicity_1[1]}    ${SPACE}(
    [Return]    ${CSIRS_periodicity_2[0]}

Get CSIRS_StartOffset from CPIF
    [Arguments]    ${file_path}
    ${CSIRS_periodicity}=    Get CSIRS_periodicity from CPIF    file_path=${file_path}
    ${message_filter_expression}    Catenate    nr-rrc.rrcReconfiguration_element &&
    ...                                         nr-rrc.csi_MeasConfig == 1
    ${CSIRS_Offset_0}    Check Target Item Value on CPIF Tcpdump log
    ...            file_path=${file_path}
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//_[1]/nr-rrc.NZP_CSI_RS_Resource_element/nr-rrc.periodicityAndOffset/nr-rrc.${CSIRS_periodicity}
    [Return]    ${CSIRS_Offset_0[0]}

Get CSIRS_nrofPorts from CPIF
    [Arguments]    ${file_path}
    ${message_filter_expression}    Catenate    nr-rrc.rrcReconfiguration_element &&
    ...                                         nr-rrc.csi_MeasConfig == 1
    ${CSIRS_nrofPorts_0}    Check Target Item Value on CPIF Tcpdump log
    ...            file_path=${file_path}
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//nr-rrc.NZP_CSI_RS_Resource_element/nr-rrc.resourceMapping_element/nr-rrc.nrofPorts
    ...            attribute_name=showname
    ...            filter=nr-rrc
    ${num}     get length    ${CSIRS_nrofPorts_0}
    ${CSIRS_nrofPorts}=    Create List
    FOR    ${i}    IN RANGE    ${num}
       ${CSIRS_nrofPorts_1}=    String.Split String    ${CSIRS_nrofPorts_0[${i}]}    :${SPACE}
       ${CSIRS_nrofPorts_2}=    String.Split String    ${CSIRS_nrofPorts_1[1]}    ${SPACE}(
       Append To List    ${CSIRS_nrofPorts}    ${CSIRS_nrofPorts_2[0]}
    END
    [Return]    ${CSIRS_nrofPorts}

Get CSIRS_cdm_Type from CPIF
    [Arguments]    ${file_path}
    ${message_filter_expression}    Catenate    nr-rrc.rrcReconfiguration_element &&
    ...                                         nr-rrc.csi_MeasConfig == 1
    ${CSIRS_cdm_Type}    Check Target Item Value on CPIF Tcpdump log
    ...            file_path=${file_path}
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//nr-rrc.NZP_CSI_RS_Resource_element/nr-rrc.resourceMapping_element/nr-rrc.cdm_Type
    [Return]    ${CSIRS_cdm_Type}

Get CSIRS_density from CPIF
    [Arguments]    ${file_path}
    ${message_filter_expression}    Catenate    nr-rrc.rrcReconfiguration_element &&
    ...                                         nr-rrc.csi_MeasConfig == 1
    ${CSIRS_density}    Check Target Item Value on CPIF Tcpdump log
    ...            file_path=${file_path}
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//_[1]/nr-rrc.NZP_CSI_RS_Resource_element/nr-rrc.resourceMapping_element/nr-rrc.density
    [Return]    ${CSIRS_density}

Get CSIRS_n1_n2 from CPIF
    [Arguments]    ${file_path}
    ${message_filter_expression}    Catenate    nr-rrc.rrcReconfiguration_element &&
    ...                                         nr-rrc.csi_MeasConfig == 1
    ${CSIRS_n1_n2}    Check Target Item Value on CPIF Tcpdump log
    ...            file_path=${file_path}
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//nr-rrc.n1_n2
    [Return]    ${CSIRS_n1_n2}

Get ri_Restriction from CPIF
    [Arguments]    ${file_path}
    ${message_filter_expression}    Catenate    nr-rrc.rrcReconfiguration_element
    ${ri_Restriction}    Check Target Item Value on CPIF Tcpdump log
    ...            file_path=${file_path}
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//nr-rrc.typeI_SinglePanel_ri_Restriction
    [Return]    ${ri_Restriction}

Get LongPucch_format from CPIF
    [Arguments]    ${file_path}
    ${message_filter_expression}    Catenate    nr-rrc.rrcReconfiguration_element &&
    ...                                         nr-rrc.pucch_Config == 1
    ${LongPucch_format}    Check Target Item Value on CPIF Tcpdump log
    ...            file_path=${file_path}
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//nr-rrc.format
    [Return]    ${LongPucch_format}

Get MeasGap_offset from CPIF
    [Arguments]    ${file_path}
    ${message_filter_expression}    Catenate    nr-rrc
    ${MeasGap_offset}    Check Target Item Value on CPIF Tcpdump log
    ...            file_path=${file_path}
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//nr-rrc.gapOffset
    [Return]    ${MeasGap_offset}

Get MeasGap_Config from CPIF
    [Arguments]    ${file_path}
    ${message_filter_expression}    Catenate    nr-rrc.measGapConfig == 1
    ${MeasGap_Config}    Check Target Item Value on CPIF Tcpdump log
    ...            file_path=${file_path}
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//nr-rrc.gapUE
    [Return]    ${MeasGap_Config}

Get MeasGap_Release from CPIF
    [Arguments]    ${file_path}    ${gap_release_name}=nr-rrc.measGapConfig     ## nsa:nr-rrc.measGapConfig sa:nr-rrc.gapUE
    ${message_filter_expression}    Catenate    nr-rrc.release_element
    ${MeasGap_Release}    Check Target Item Value on CPIF Tcpdump log
    ...            file_path=${file_path}
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//${gap_release_name}
    [Return]    ${MeasGap_Release}

Get Paging_TAC from CPIF
    [Arguments]    ${file_path}
    ${message_filter_expression}    Catenate    ngap.initiatingMessage_element
    ${Paging_TAC}    Check Target Item Value on CPIF Tcpdump log
    ...            file_path=${file_path}
    ...            filter_expression=${message_filter_expression}
    ...            xpath=.//ngap.tAC
    [Return]    ${Paging_TAC}

Convert BIP Pcap log To Pdml
    [Documentation]    Description: convert to bip file to pdml format, pdml can be used for value check.
    [Arguments]    ${file_path}
    ...            ${tshark_path}=/usr/bin/tshark
    ...            ${filter}=dldata_pdschsendreq
    ...            ${luashark_path}=/opt/workspace/luashark/generated_luashark/luashark.lua
    ...            ${command_template}={tshark_path} -r {pcap_file} -X lua_script:{luashark_path} -Y \"${filter}\" -T pdml
    ...            ${alias}=parser
    pcap.load_pcap_file    pcap_file=${file_path}
    ...                    tshark_path=${tshark_path}
    ...                    luashark_path=${luashark_path}
    ...                    command_template=${command_template}
    ...                    alias=${alias}

Get MaxCsirs_num From BIP Log
    [Documentation]          This keyword is used to get patternId from bip log, filter dldata_pdschsendreq
    [Arguments]    ${bip_log}    ${filter_expression}
    ...      ${xpath}=.//DlData_PdschGrant.patternId_item
    ...      ${alias}=parser
    ${all_packets}=    cap.load_pcap_file    pcap_file=${bip_log}    alias=${alias}
    ${bipPatternIdList}=    Get Field Value From Pdml file    filter_expression=${filter_expression}    xpath=${xpath}    attribute_name=show
    ${bipPatternIdList}    Remove Duplicates    ${bipPatternIdList}
    ${bipPatternIdList_length}    get length     ${bipPatternIdList}
    Should Be True    ${bipPatternIdList_length} > 0    msg="Get patternId From BIP Log Failed"
    [Return]    ${bipPatternIdList}

Get Maxnumber Of Layer for MCshark
    [Documentation]    This keyword is used to get numberoflayers from bip log, filter dldata_pdschsendreq
    [Arguments]    ${bip_log}    ${rank}
    ...      ${xpath}=.//DlData_PdschGrant.numOfLayers
    ...      ${alias}=parser
    ${all_packets}=    cap.load_pcap_file    pcap_file=${bip_log}    alias=${alias}
    ${filter_expression}    Catenate     (dldata_pdschsendreq) && !(3gpp.rnti == 65535)
    ${numOfLayers}=    Get Field Value From Pdml file    filter_expression=${filter_expression}    xpath=${xpath}
    should contain    ${numOfLayers}    ${rank}

########----------- new way for multiue ------------########

attach UE and capture wiresharklog with new way
    [Arguments]    ${wiresharklog}   ${UE_mode}=${SA_attach_mode}
    Start Capture CP-IF logs from Container     tcpdump_collector_name=${wiresharklog}
    MultiUE one Attach with client    UE_mode=${UE_mode}
    [Teardown]       Stop CP-IF log Collection    tcpdump_collector_name=${wiresharklog}    target_dir=${epc_log_path}
    [Return]     ${cpif_log_path}

UE attach with Diff TL with new way
    [Arguments]    ${UE_mode}=${SA_attach_mode}
    MultiUE one Attach with client    UE_mode=${UE_mode}


UE start DLData Traffic with Diff TL with new way
    [Arguments]     ${dl_tput_multiue}
    Start MUE dltraffic with appserver    ue_addr=${upd_info}[Param][IP]     dl_port=${DL_PORT}    dl_throughput=${dl_tput_multiue}


Start Traffic And Capture Biplog with new way
    [Arguments]     ${dlexpect_tp}=${Expect_dl_enable}     ${duration}=1m    ${bbmod_slots}=1
    Start UE traffic and check tput with new way    cellid=${nrcellid}    dlexpect_tp=${dlexpect_tp}    duration=${duration}
    log to console    start to cpature biplog
    ${bip}=    Capture biplog and download    bbmod_slots=${bbmod_slots}
    [Return]     ${bip}

Start UE traffic and check tput with new way
    [Arguments]     ${dl_tput_multiue}     ${cellid}=${nrcellid}    ${dlexpect_tp}=@{Expect_dl_enable[0]}
    UE start DLData Traffic with Diff TL with new way     dl_tput_multiue=${dl_tput_multiue}
    sleep    30s
    log to console    check tput with nrcellid
    ${tput_status}=    Run Keyword And Return Status
    ...    Check Dl traffic with nrcellid in Diff with new way    cellid=${cellid}     dlexpect_tp=${dlexpect_tp}
    Should Be True     '${tput_status}' == '${True}'

Check Dl traffic with nrcellid in Diff with new way
    [Arguments]     ${dlexpect_tp}    ${cellid}=${nrcellid}
    Check one multiUE traffic with aasyslog    target_throughput=${dlexpect_tp}    cellid=${cellid}

stop traffic and detach UE with new way
    [Arguments]    ${ue}=${uegroup}[0]
    Stop traffic with appserver    iperf_port=${DL_PORT}
    sleep    1s
    Detach MultiUE    ue=${ue}


Multi UE Detach And Stop Traffic with new way
    [Arguments]    ${ue}=${uegroup}[0]
    Stop traffic with appserver    iperf_port=${DL_PORT}
    sleep    1s
    Detach MultiUE and stoplog    ue=${ue}

stop traffic and MCS teardown with new way
    [Arguments]    ${mcs_type}=${mcs_type}
    Run Keyword And Ignore Error    Multi UE Detach And Stop Traffic with new way
    Run Keyword And Ignore Error    mcs_common.Teardown MCS    mcs_type=${mcs_type}

Detach UE without traffic with new way
    [Arguments]     ${ue}=${uegroup}[0]
    Detach MultiUE    ue=${ue}


attach multiUEs and capture wiresharklog
    [Arguments]    ${wiresharklog}    ${UE_mode}=${SA_attach_mode}    ${options}=-i any sctp -s 0
    Start Capture CP-IF logs from Container     tcpdump_collector_name=${wiresharklog}    options=${options}
    MultiUEs Attach with client    UE_mode=${UE_mode}
    sleep    5s
    [Teardown]       Stop CP-IF log Collection    tcpdump_collector_name=${wiresharklog}    target_dir=${epc_log_path}
    [Return]     ${cpif_log_path}

Start multiUEs Traffic And Capture Biplog
    [Arguments]     ${dl_tput_multiue}=${dl_tput_multiue}    ${UE_define}=NULL    ${bbmod_slots}=1
    Start multiUEs traffic with appserver    dl_tput_multiue=${dl_tput_multiue}    UE_define=${UE_define}
    log to console    start to cpature biplog
    ${bip}=    Capture biplog and download    bbmod_slots=${bbmod_slots}
    [Return]     ${bip}

check tput with diff tl new way
    [Arguments]    ${throughput}=${${${throughput}}[0]}
    ${tput}    Check one UE traffic with pioneer client    tput_target=${throughput}
    [Return]    ${tput}
