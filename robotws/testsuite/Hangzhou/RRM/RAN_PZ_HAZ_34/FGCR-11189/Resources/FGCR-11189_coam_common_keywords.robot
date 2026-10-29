*** Settings ***
Documentation
...    author: Rebecca.Liu
...    contact:jia-rebecca.liu@nokia-sbell.com
...    squad group: SG_03
...    feature : FGCR-11189

Library     OperatingSystem
Library     Collections
Library     String
Library     BuiltIn
Library     DateTime
Library     taf.transport.ssh    WITH NAME    csn
Library     taf.sbts.oam.coam.admin   WITH NAME    wmplte
Library     taf.config.scf    WITH NAME    scf
Library     taf.hw.rf_attenuator    WITH NAME    att
Library     taf.config.testline    WITH NAME    testline
Library     taf.rfrl.common_resources.python.SWConfig    WITH NAME    SWConfig
Library     taf.sw.qualcomm.license    WITH NAME   QLC
#Resource    ../../../../../resources/common/enb_lte.robot
Resource    ../../../../resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
#Resource    ../../../../../resources/common/gnb_classical.robot
Resource    taf/rfrl/common_resources/robot/gnb_classical.robot
#Resource    ../../../../resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Resource    ../../../../resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot   #must#
Resource    ../../../../resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
#Resource    ../../../../../resources/common/connection_alias_store.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Library     ../../../../resources/RAN_PZ_HAZ_34/python/check_csv_log.py
#Library     ../../../../../../../resources/python_libs/Attenuation.py
#Library     Attenuation.Attenuation    WITH NAME    atten
Resource    ../../../../resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    ../../libraries/biplog_capture/biplog_capture.robot
Resource    ../../libraries/connection_with_hostname.robot
Resource    ../../../../resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot

Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Collect_logs.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/UE.robot
Library       testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC002200/Resources/tput_output.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Atten.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/licence_keeper.py
Library    licence_keeper.licence_keeper     WITH NAME    LK
Library    taf.analyzer.pcap    WITH NAME    wireshark
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/ERR_WRN_Check.robot

*** Variables ***
##BTS##
${gnb_BTS_host}             ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
#${gnb_BTS_host_1}             ${tl.gnbs[1].cu.oam_ssh_connection_details.addr}
${gnb_BTS_username}       ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gnb_BTS_password}       ${tl.gnbs[0].cu.oam_http_connection_details.password}
${asik_addr}              ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
#${asik_addr_1}              ${tl.gnbs[1].dus[0].airscale.common_units[0].lmp_connection.addr}
${asik_username}          ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${asik_password}          ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}

## ENB ##
${enb_instance}                 ${tl.enbs[0].instance_id}
${TL372_enbx2_dist}            MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNADJGNB-1
${TL372_enbcell_dist}          MRBTS-${enb_instance}/LNBTS-${enb_instance}/LNCEL-1
${enbx2_para}                 administrativeState
##TEST PC##
${TestPC_addr}               ${tl.test_pc.default_ssh_connection_details.addr}
${TestPC_username}           ${tl.test_pc.default_ssh_connection_details.username}
${TestPC_password}           ${tl.test_pc.default_ssh_connection_details.password}
##PATH##
${TS_LOG_PATH_BASE}         /opt/workspace/CRT/Master/Case_Logs
${tshark_path}              /usr/bin/tshark
${localFilePath}            /opt/workspace/SCF/swconfig_11189/swconfig.txt
${scf_log_path}            /opt/workspace/SCF/SCF_11189/
${aasyslog_path}             /tmp/
##UE##
${ue_type}                ${tl.ues[1].capabilities[0]}
${UL_PORT}                ${tl.ues[0].iperf_details.ssh_connection_details.port}
${DL_PORT}                ${tl.ues[0].iperf_details.port}
${ul_throughput}            30M
${dl_throughput}            700M
${DL_TIME}                  9999
${DL_LENGTH}                1024B
${UL_TIME}                  9999
${UL_LENGTH}                1024B
${deviation}                15
##PA##
#${att_ipaddr}                 ${tl.attenuator[0].ip_addr}
#${att_ipaddr_1}               ${tl.attenuator[1].ip_addr}
#${att_port_7}               ${tl.attenuator[0].attenuator_ports[7]}
#${att_port_8}               ${tl.attenuator[0].attenuator_ports[8]}
#${att_port_1}               ${tl.attenuator[1].attenuator_ports[1]}
#${att_port_2}               ${tl.attenuator[1].attenuator_ports[2]}
#${att_port_3}               ${tl.attenuator[1].attenuator_ports[3]}
#${att_port_4}               ${tl.attenuator[1].attenuator_ports[4]}
${att_connection_port}      ${tl.attenuator[0].attenuator_ports[7]}
${att_api_port}             ${tl.attenuator[0].port}
${vendor}                   ${tl.attenuator[0].vendor}
${HBTE_max_value}           ${127}
${att_ipaddr}      ${tl.attenuator[0].ip_addr}
${att_port_1_}                ${tl.attenuator[0].attenuator_ports[1]}
${att_port_2_}                ${tl.attenuator[0].attenuator_ports[2]}
${att_port_3_}                ${tl.attenuator[0].attenuator_ports[3]}
${att_port_4_}                ${tl.attenuator[0].attenuator_ports[4]}
${att_port_5_}                ${tl.attenuator[0].attenuator_ports[5]}
${att_port_6_}                ${tl.attenuator[0].attenuator_ports[6]}
${att_port_7_}                ${tl.attenuator[0].attenuator_ports[7]}
${att_port_8_}                ${tl.attenuator[0].attenuator_ports[8]}
${att_port_9_}                ${tl.attenuator[0].attenuator_ports[9]}
${att_port_10_}                ${tl.attenuator[0].attenuator_ports[10]}
${att_port_11_}                ${tl.attenuator[0].attenuator_ports[11]}
${att_port_12_}                ${tl.attenuator[0].attenuator_ports[12]}
${att_port_13_}                ${tl.attenuator[0].attenuator_ports[13]}
${att_port_14_}                ${tl.attenuator[0].attenuator_ports[14]}
${att_port_15_}                ${tl.attenuator[0].attenuator_ports[15]}
${att_port_16_}                ${tl.attenuator[0].attenuator_ports[16]}



${gnb_instance}     ${tl.gnbs[0].instance_id}
${scf_path}    /opt/workspace/SCF/SCF_11189/
@{BTSID}    36011    34711    23311
#@{gnb_ips}    ${bts_host0}    ${bts_host1}
${bts_host0}    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
${bts_host1}    ${tl.gnbs[1].cu.oam_http_connection_details.addr}
@{gnb_ips}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}    ${tl.gnbs[1].cu.oam_ssh_connection_details.addr}
##Get QXDM log from QC
${LKC_LOGIN_USER}    hai.2.huang@nokia-sbell.com
${LKC_LOGIN_PWD}     Password@5
${LKC_CLIENT_PORT}    6006
${LKC_CLIENT_ALIAS}         lkc
${LKC_CLIENT_PATH}       /cygdrive/c/Tool/QPM_LK1.5.2/QPM_LK3.1.0/QPM_LK3.1.0/ClientMain.exe
${5G_QXDM_PATH}       C:/Tool/QXDM99
${QCAT_EXE_PATH}    "C:/Program Files/Qualcomm/QCAT7/Bin/QCAT.exe"
#${QCAT_EXE_PATH}    "C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe"
@{allow_fault_list}    7311    7107
${sys_logs_path}    /tmp/btslog2/
${UTE_logs_path}    /home/ute/ERR_WRN_logs/


*** Keywords ***
#Hanging resource test
#    [Arguments]    ${gnb_ips}=@{gnb_ips}    ${ue_index}=${0}
#    [Documentation]    hanging resource test
#    [Timeout]    1hour
#    Check hanging resource for gnb    gnb_ips=${gnb_ips}    ue_index=${ue_index}

##################### prepare BTS #################
Load SCF for each TL
    Run Keyword If    '${gnb_instance}' == '${BTSID}[0]'
    ...    Common Case TestLine Setup    is_commission=True    is_commission_for_second_gnb=False     Is_Swconfig=True
    ...     golden_scf_name=${tl_36011_scf_gnb1}    golden_scf_name_gnb2=${tl_36012_scf_gnb2}
    ...    swconfig_file=${swconfig_paths}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[1]'
    ...    Common Case TestLine Setup    is_commission=False    is_commission_for_second_gnb=True     Is_Swconfig=True
#    ...    Enb_commission=True   Enb_commission_For_ENB2=True    enb_scf=${T34721_SCF}    enb2_scf=${T34722_SCF}
    ...     golden_scf_name=${tl_34711_scf_gnb1}    golden_scf_name_gnb2=${tl_34712_scf_gnb2}
    ...    swconfig_file=${swconfig_paths}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[2]'
    ...    Common Case TestLine Setup    is_commission=False    is_commission_for_second_gnb=True     Is_Swconfig=True
#    ...    Enb_commission=True   Enb_commission_For_ENB2=True    enb_scf=${T34721_SCF}    enb2_scf=${T34722_SCF}
    ...     golden_scf_name=${tl_23311_scf_gnb1}    golden_scf_name_gnb2=${tl_23312_scf_gnb2}
    ...    swconfig_file=${swconfig_paths}


Prepare the atten for each TL
    Run Keyword If    '${gnb_instance}' == '${BTSID}[0]'
    ...    Adjust the TL HBTE attenuation value   gnb1_cell1_value=${0}    gnb1_cell2_value=${0}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[1]'
    ...    Adjust the TL HBTE attenuation value   gnb1_cell1_value=${0}    gnb1_cell2_value=${0}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[2]'
    ...    Adjust the TL HBTE attenuation value   gnb1_cell1_value=${0}    gnb1_cell2_value=${0}

Prepare the atten for each TL NSA
    Run Keyword If    '${gnb_instance}' == '${BTSID}[0]'
    ...    Adjust the TL HBTE attenuation value   gnb1_cell1_value=${0}    gnb1_cell2_value=${0}    enb2_cell1_value=${0}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[1]'
    ...    Adjust the TL HBTE attenuation value   gnb1_cell1_value=${0}    gnb1_cell2_value=${0}    enb2_cell1_value=${0}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[2]'
    ...    Adjust the TL HBTE attenuation value   gnb1_cell1_value=${0}    gnb1_cell2_value=${0}    enb2_cell1_value=${0}

Prepare the atten for each TL for mg NSA
    Run Keyword If    '${gnb_instance}' == '${BTSID}[0]'
    ...    Adjust the TL HBTE attenuation value   gnb1_cell1_value=${0}    gnb1_cell2_value=${20}    enb2_cell1_value=${0}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[1]'
    ...    Adjust the TL HBTE attenuation value   gnb1_cell1_value=${0}    gnb1_cell2_value=${20}    enb2_cell1_value=${0}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[2]'
    ...    Adjust the TL HBTE attenuation value   gnb1_cell1_value=${0}    gnb1_cell2_value=${20}    enb2_cell1_value=${0}

Prepare the atten for each TL for mg
    Run Keyword If    '${gnb_instance}' == '${BTSID}[0]'
    ...    Adjust the TL HBTE attenuation value   gnb1_cell1_value=${0}    gnb1_cell2_value=${28}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[1]'
    ...    Adjust the TL HBTE attenuation value   gnb1_cell1_value=${0}    gnb1_cell2_value=${28}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[2]'
    ...    Adjust the TL HBTE attenuation value   gnb1_cell1_value=${0}    gnb1_cell2_value=${28}

Adjust the TL HBTE attenuation value
    [Arguments]    ${enb1_cell1_value}=${127}    ${enb2_cell1_value}=${127}    ${gnb1_cell1_value}=${127}
    ...    ${gnb1_cell2_value}=${127}    ${gnb2_cell1_value}=${127}
    ####create cell list#####
    @{att_ports_enb1_cell1}    Create List    ${att_port_1_}    ${att_port_2_}
    @{att_ports_enb2_cell1}    Create List    ${att_port_3_}    ${att_port_4_}
    @{att_ports_gnb1_cell1}    Create List    ${att_port_13_}    ${att_port_14_}
    ...    ${att_port_15_}    ${att_port_16_}
    @{att_ports_gnb1_cell2}    Create List    ${att_port_5_}    ${att_port_6_}
    ...    ${att_port_7_}    ${att_port_8_}
    @{att_ports_gnb2_cell1}    Create List    ${att_port_9_}    ${att_port_10_}
    ...    ${att_port_11_}    ${att_port_12_}

    ###create value list####
    @{values_enb1_cell1}    Create List    ${enb1_cell1_value}    ${enb1_cell1_value}
    @{values_enb2_cell1}    Create List    ${enb2_cell1_value}    ${enb2_cell1_value}
    @{values_gnb1_cell1}    Create List    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}    ${gnb1_cell1_value}
    @{values_gnb1_cell2}    Create List    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}    ${gnb1_cell2_value}
    @{values_gnb2_cell1}    Create List    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}    ${gnb2_cell1_value}

    ###Adjust the HBTE attenuation value###
    Set the attenuation value    att_ports=${att_ports_enb1_cell1}    values=${values_enb1_cell1}
    ...    att_connection_port=${att_port_1_}    att_ipaddr=${att_ipaddr}
    Set the attenuation value    att_ports=${att_ports_enb2_cell1}    values=${values_enb2_cell1}
    ...    att_connection_port=${att_port_1_}    att_ipaddr=${att_ipaddr}
    Set the attenuation value    att_ports=${att_ports_gnb1_cell1}    values=${values_gnb1_cell1}
    ...    att_connection_port=${att_port_1_}    att_ipaddr=${att_ipaddr}
    Set the attenuation value    att_ports=${att_ports_gnb1_cell2}    values=${values_gnb1_cell2}
    ...    att_connection_port=${att_port_1_}    att_ipaddr=${att_ipaddr}
    Set the attenuation value    att_ports=${att_ports_gnb2_cell1}    values=${values_gnb2_cell1}
    ...    att_connection_port=${att_port_1_}    att_ipaddr=${att_ipaddr}





Common Suite Setup for 11189
#    [Arguments]    ${log_level}=${False}
    robot_common_operations.Common Suite Setup
    Set suite variables by program
    COAM Create log directory    is_set_to_test_case_level=${False}
    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
    Set Suite Variable    ${epc_log_path}    ${LOG_PATH}/${time_stamp}/
    Create directory    ${epc_log_path}
    set_suite_documentation    doc=||| All test suite log will save in this VM IP:${TestPC_addr} logPath:${epc_log_path}
    ...    append=True

Set suite variables by program
    [Documentation]      This keyword is to set several variables by program.
    ${release_info}    Get sagnb release
    set suite variable    ${release_info}

Common Suite Teardown for 11189
#    [Arguments]    ${bts_host}=${gnb_BTS_host}
#    ...    ${username}=${gnb_BTS_username}
#    ...    ${password}=${gnb_BTS_password}
#    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
#    COAM Download scf from cluster    scf_dir_path=${epc_log_path}
#    COAM Save snapshot via rest api    log_path=${epc_log_path}
    COAM Teardown gnb connections

Prepare TL for SA 11189 on suite setup
    [Arguments]      ${localFilePath}    ${tl_scf_trunk}    ${tl_scf_22R3}    ${tl_scf_22R2}    #${tl_scf_dir_path}=${scf_log_path}
    ${release_info}     Get sagnb release
    Set Suite Variable     ${release_info}
    run keyword if    '${release_info}' == 'SBTS23R1_ENB_9999'    Prepare testline to cell onair for SA 11189    localFilePath=${localFilePath}
    ...    tl_scf_dir_path=${scf_log_path}    tl_scf_filename=${tl_scf_trunk}    gnb_index=${0}    bts_host=${gnb_BTS_host}
    run keyword if    '${release_info}' == 'SBTS22R4_ENB_0000'    Prepare testline to cell onair for SA 11189    localFilePath=${localFilePath}
    ...    tl_scf_dir_path=${scf_log_path}    tl_scf_filename=${tl_scf_trunk}    gnb_index=${0}    bts_host=${gnb_BTS_host}
    run keyword if    '${release_info}' == 'SBTS22R3_ENB_0000'    Prepare testline to cell onair for SA 11189    localFilePath=${localFilePath}
    ...    tl_scf_dir_path=${scf_log_path}    tl_scf_filename=${tl_scf_22R3}    gnb_index=${0}    bts_host=${gnb_BTS_host}
    run keyword if    '${release_info}' == 'SBTS22R2_ENB_0000'    Prepare testline to cell onair for SA 11189    localFilePath=${localFilePath}
    ...    tl_scf_dir_path=${scf_log_path}    tl_scf_filename=${tl_scf_22R2}    gnb_index=${0}    bts_host=${gnb_BTS_host}


Prepare testline to cell onair for NSA 11189
    [Arguments]      ${localFilePath}    ${tl_scf_filename}    ${tl_scf_dir_path}=${tl_scf_dir_path}    ${gnb_index}=${0}
    ...    ${enbx2_dist}=${enbx2_dist}
    Update the swconfig file 11189    gnb_index=${gnb_index}    localFilePath=${localFilePath}
    Prepare with COAM classical BTS cell onair for NSA 11189    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_filename=${tl_scf_filename}
    ...    enbx2_dist=${enbx2_dist}

Prepare testline to cell onair for SA 11189
    [Arguments]      ${localFilePath}    ${tl_scf_filename}    ${tl_scf_dir_path}=${tl_scf_dir_path}    ${gnb_index}=${0}
    ...     ${bts_host}=${gnb_BTS_host}    ${username}=${gnb_BTS_username}    ${password}=${gnb_BTS_password}
    Update the swconfig file 11189    gnb_index=${gnb_index}    localFilePath=${localFilePath}
    Prepare with COAM classical BTS cell onair for SA 11189    tl_scf_dir_path=${tl_scf_dir_path}    tl_scf_filename=${tl_scf_filename}
    ...    bts_host=${bts_host}    username=${username}    password=${password}

Update the swconfig file 11189
    [Arguments]    ${localFilePath}    ${gnb_index}=${0}
    wait until keyword succeeds    5min    10s    Connect to Common Unit Master with gnbindex   gnb_index=${gnb_index}    alias=ASIK Master
    SWConfig.Upload SwConfig File To Asik And Crasign     localFilePath=${localFilePath}    asik_alias=ASIK Master
    [Teardown]      run keyword and ignore error      Csn.disconnect      connection=ASIK Master

Prepare with COAM classical BTS cell onair for SA 11189
    [Arguments]    ${tl_scf_dir_path}    ${tl_scf_filename}    ${bts_host}=${gnb_BTS_host}    ${username}=${gnb_BTS_username}
    ...    ${password}=${gnb_BTS_password}
    Perform full commission for COAM gnb 11189     scf=${tl_scf_dir_path}${tl_scf_filename}
      ...    gnb_ip=${bts_host}    username=${username}    password=${password}
    COAM Wait for gnb ready 11189    bts_host=${bts_host}    username=${username}    password=${password}
    Wait until keyword succeeds    10min    20 sec    Verify all cells should be onair    connection=GNB_OAM
    wait until keyword succeeds    10min    30s    COAM Check GNB cell on air

Prepare with COAM classical BTS cell onair for NSA 11189
    [Arguments]    ${tl_scf_dir_path}    ${tl_scf_filename}    ${bts_host}=${gnb_BTS_host}    ${username}=${gnb_BTS_username}
    ...    ${password}=${gnb_BTS_password}    ${enbx2_dist}=${enbx2_dist}
    Perform full commission for COAM gnb 11189     scf=${tl_scf_dir_path}${tl_scf_filename}
    ...    gnb_ip=${bts_host}    username=${username}    password=${password}
    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=locked
    COAM Wait for gnb ready 11189    bts_host=${bts_host}    username=${username}    password=${password}
    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=unlocked
    Wait until keyword succeeds    10min    20 sec    Verify all cells should be onair    connection=GNB_OAM
    wait until keyword succeeds    10min    30s    COAM Check GNB cell on air

Perform full commission for COAM gnb 11189
    [Arguments]    ${scf}    ${gnb_ip}    ${username}    ${password}
    Connect to gnb coam via ssl   bts_host=${gnb_ip}    username=${username}      password=${password}
    COAM Commission with scf file    scf_file_path=${scf}    timeout=500    is_pdl_checking_needed=${False}
    COAM Teardown gnb connections

COAM Wait for gnb ready 11189
    [Timeout]  30 min
    [Arguments]  ${timeout}=10 min    ${connection}=GNB_OAM    ${bts_host}=${bts_host}    ${username}=${username}    ${password}=${password}
    Wait until keyword succeeds    ${timeout}    20 sec    Connect to gnb coam via ssl    connection=${connection}
    ...                    bts_host=${bts_host}
    ...                    username=${username}
    ...                    password=${password}
    Wait until keyword succeeds    ${timeout}    20 sec    COAM Check GNB ASIK status    connection=${connection}
    Wait until keyword succeeds    ${timeout}    20 sec    COAM Check GNB ABIL status    connection=${connection}
    Wait until keyword succeeds    ${timeout}    20 sec    COAM Check GNB RU status    connection=${connection}

Modify the COAM parameter with admin API 11189
    [Arguments]    ${parameters}    ${bts_host}=${gnb_BTS_host}
    ...    ${username}=${gnb_BTS_username}    ${password}=${gnb_BTS_password}
    Connect to gnb coam via ssl     bts_host=${bts_host}    username=${username}    password=${password}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters}
    COAM Teardown gnb connections

gNB connections
    [Arguments]    ${asik_addr}=${asik_addr}    ${asik_username}=${asik_username}    ${asik_password}=${asik_password}
    csn.Connect To    hostname=${asik_addr}
    ...               username=${asik_username}
    ...               password=${asik_password}
    ...               alias=gnb

Set cell status barred 11189
    [Documentation]
    ...    Set cell status to 'barred' to forbid UE to attach.
    [Arguments]    ${set_cell_barred}    ${bts_host}=${gnb_BTS_host}    ${connection}=GNB_OAM    ${timeout}=5min
    ...    ${username}=${gnb_BTS_username}    ${password}=${gnb_BTS_password}
    Connect to gnb coam via ssl     bts_host=${bts_host}    username=${username}    password=${password}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${set_cell_barred}    connection=${connection}  timeout=${timeout}

Setup and set HBTE attenuation 2 ports 11189
    [Arguments]    ${value_1}    ${value_2}    ${att_port_1}=${att_port_7}    ${att_port_2}=${att_port_8}
    ...    ${att_ipaddr}=${att_ipaddr}    ${att_api_port}=${att_api_port}
    ...    ${att_connection_port}=${att_connection_port}    ${HBTE_max_value}=${HBTE_max_value}    ${vendor}=${vendor}
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${HBTE_max_value}    vendor=${vendor}
    att.set_attenuation     port=${att_port_1}    value=${value_1}
    att.set_attenuation     port=${att_port_2}    value=${value_2}
    ${value_port1}    att.read_attenuation    port=${att_port_1}
    should be equal    ${value_port1}    ${value_1}
    ${value_port2}    att.read_attenuation    port=${att_port_2}
    should be equal    ${value_port2}    ${value_2}

Prepare and Start Aasyslog capture 11189
    [Arguments]    ${log_name}    ${gnb_index}=${0}    ${du_index}=${0}    ${gnb_path}=${aasyslog_path}
#    ...            ${filter}=L2_PS_DL_SC    ${Teardown_after_finished}=${True}    ${type}=MCU    ${log_ip}=127.0.0.1
    ...            ${filter}=L2_PS_DL_SC    ${log_ip}=127.0.0.1
    ...            ${host}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    ...            ${username}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...            ${password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
    ...                                    host=${host}    username=${username}    password=${password}
    Aasyslog precondition    gnb_index=${gnb_index}    host=${host}    username=${username}    password=${password}
    Start the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}    filter=${filter}
    ...                                 gnb_path=${gnb_path}    log_name=${log_name}
    ...                                 host=${host}    username=${username}    password=${password}
    ...                                 log_ip=${log_ip}


Stop and download Aasyslog 11189
    [Arguments]    ${log_name}    ${gnb_index}=${0}    ${du_index}=${0}    ${gnb_path}=${epc_log_path}
    ...            ${host}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    ...            ${username}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...            ${password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
    ...                                    host=${host}    username=${username}    password=${password}
    sleep    3s
    Download Aasyslog File From GNB 11189    local_path=${gnb_path}${log_name}    remote_path=${aasyslog_path}${log_name}    gnb_index=${gnb_index}
    ...                 du_index=${du_index}    host=${host}    username=${username}    password=${password}

Download aasyslog file from gNB 11189
    [Arguments]    ${local_path}=${local_path}    ${remote_path}=${remote_path}    ${gnb_index}=0    ${du_index}=0
    ...    ${host}=${EMPTY}
    ...    ${username}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ${host}   Run Keyword If   '${host}'==''   Get Host IP from gNB   gnb_index=${gnb_index}   du_index=${du_index}
    ...    ELSE   Set Variable   ${host}
    csn.connect_to    hostname=${host}   username=${username}    password=${password}    alias=ASIK Master
    csn.download_file    remote_path=${remote_path}    local_path=${local_path}    connection=ASIK Master
    [Teardown]    csn.disconnect    connection=ASIK Master

################ wireshark log ########################
Start To Capture Wireshark Logs on ASIK 11189
    [Arguments]     ${logname}    ${gnb_index}=${0}    ${connection}=ASIK Slave    ${interface}=any
    Connect to Common Unit Slave    gnb_index=${gnb_index}
    csn.send command    command=cd /tmp&&tcpdump -i ${interface} sctp -w ${gnb_path}${logname}    connection=${connection}

Stop and download wireshark Logs on ASIK 11189
    [Arguments]    ${logname}    ${gnb_index}=${0}    ${connection}=ASIK Slave
    Connect to Common Unit Slave    gnb_index=${gnb_index}
    csn.send command    command=killall tcpdump     connection=${connection}
    sleep    3
    csn.download_file    remote_path=${gnb_path}${logname}    local_path=${epc_log_path}${logname}    connection=${connection}
    sleep    3
    [Teardown]      run keyword and ignore error      Csn.disconnect      connection=${connection}

Start To Capture Wireshark Logs NSA 11189
    [Arguments]     ${filename}    ${asik_addr}=${asik_addr}    ${asik_username}=${asik_username}    ${asik_password}=${asik_password}
    ...    ${connection}=gnb    ${interface}=any
    gNB connections    asik_addr=${asik_addr}    asik_username=${asik_username}    asik_password=${asik_password}
    csn.send command    command=tcpdump -i ${interface} sctp -w ${gnb_path}${filename}   connection=${connection}

Stop and download wireshark Logs NSA 11189
    [Arguments]    ${logname}    ${asik_addr}=${asik_addr}    ${asik_username}=${asik_username}    ${asik_password}=${asik_password}
    ...    ${connection}=gnb
    gNB connections    asik_addr=${asik_addr}    asik_username=${asik_username}    asik_password=${asik_password}
    csn.send command    command=killall tcpdump     connection=${connection}
    sleep    3
    csn.download_file   remote_path=${gnb_path}${logname}   local_path=${epc_log_path}${logname}   connection=${connection}
    sleep    3
    [Teardown]      run keyword and ignore error      Csn.disconnect      connection=${connection}

################ UE #################
Power UE Precondition 11189
    [Arguments]     ${ue_type}=${ue_type}    ${ue_index}=${0}    ${ui_version}=S20UI2.5
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}    ui_version=${ui_version}

Attach and check power UE 11189
    [Arguments]    ${4g_check}    ${ue_type}=${ue_type}    ${gnb_index}=${0}    ${ue_index}=${0}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    gnb_index=${gnb_index}
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    ue_index=${ue_index}     gnb_index=${gnb_index}
    ...                      4G_check=${4g_check}    5Gstatus=PASS

DL Tput check with nrcellid 11189
    [Arguments]    ${cellid}    ${dlexpect_tp}    ${ue_type}=${ue_type}    ${gnb_index}=${0}
    ${nrcellid}    COAM Get nrcellid with the lcrid    lcrid=${cellid}    gnb_index=${gnb_index}
    ${list_of_cell_ids}    Create list    ${nrcellid}
    ${log_path}     Power_ue.Collect Tput    ue_type=${ue_type}    duration=15s    ignore_time=2s
    Power_ue.Check Tput    ue_type=${ue_type}    direction=DL    log=${log_path}    cells=${list_of_cell_ids}
    ...    target_throughput=${dlexpect_tp}

Start DL tput and check dl throughput with nrcellid 11189
    [Arguments]    ${dlexpect_pcell}    ${dlexpect_scell}    ${pcellid}    ${scellid}
    ...    ${ue_type}=${ue_type}    ${dl_throughput}=${dl_throughput}    ${duration}=${DL_TIME}
    ...    ${dl_length}=${DL_LENGTH}    ${dl_port}=${DL_PORT}    ${ue_index}=${0}    #${gnb_index}=${0}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_throughput}    duration=${duration}
    ...                       iperf_port=${dl_port}    ue_index=${ue_index}    cap_index=${0}    buffer_size=${dl_length}
    sleep    55s
    DL Tput check with nrcellid 11189    dlexpect_tp=${dlexpect_pcell}    cellid=${pcellid}
    DL Tput check with nrcellid 11189    dlexpect_tp=${dlexpect_scell}    cellid=${scellid}

Start UL tput and check ul throughput with nrcellid 11189
    [Arguments]    ${ulexpect_pcell}    ${ulexpect_scell}    ${pcellid}    ${scellid}
    ...    ${ue_type}=${ue_type}    ${ul_throughput}=${ul_throughput}    ${duration}=${UL_TIME}
    ...    ${ul_length}=${UL_LENGTH}    ${ul_port}=${UL_PORT}    ${ue_index}=${0}    #${gnb_index}=${0}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_throughput}    duration=${duration}
    ...                       iperf_port=${ul_port}    ue_index=${ue_index}    cap_index=${0}    buffer_size=${ul_length}
    sleep    55s
    Power UE check UL throughput with nrcellid 11189    ulexpect=${ulexpect_pcell}    cellid=${pcellid}
    ${scell_ul_tput}    Run Keyword And Return Status    Power UE check UL throughput with nrcellid 11189    ulexpect=${ulexpect_scell}
    ...    cellid=${scellid}
    should be equal    '${scell_ul_tput}'    'False'

Power UE check DL throughput with nrcellid 11189
    [Arguments]     ${dlexpect}    ${cellid}    ${ue_type}=${ue_type}    ${gnb_index}=${0}
    ${nrcellid}    COAM Get nrcellid with the lcrid    lcrid=${cellid}    gnb_index=${gnb_index}
    set variable    ${nrcellid}
    ${dl_tp_l2l0}    Wait Until Keyword Succeeds    5x    10s    power_ue.Check Throughput    sample=${6}
    ...    ue_type=${ue_type}    direction=dl    throughput=${dlexpect}    gnb_index=${gnb_index}    cellid=${nrcellid}    sleep_time=${5}
    [Return]     ${dl_tp_l2l0}

Power UE check UL throughput with nrcellid 11189
    [Arguments]     ${ulexpect}    ${cellid}    ${ue_type}=${ue_type}    ${gnb_index}=${0}
    ${nrcellid}    COAM Get nrcellid with the lcrid    lcrid=${cellid}    gnb_index=${gnb_index}
    set variable    ${nrcellid}
    ${ul_tp_l2l0}    Wait Until Keyword Succeeds    5x    10s    power_ue.Check Throughput    sample=${6}
    ...    ue_type=${ue_type}    direction=ul    throughput=${ulexpect}    gnb_index=${gnb_index}    cellid=${nrcellid}    sleep_time=${5}
    [Return]     ${ul_tp_l2l0}

Power UE stop ul and dl traffic and detach 11189
    [Arguments]    ${dl_port}=${DL_PORT}    ${ul_port}=${UL_PORT}    ${ue_type}=${ue_type}    ${ue_index}=${0}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    iperf_port=${dl_port}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    iperf_port=${ul_port}
    sleep    3s
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

Power UE stop ul and dl traffic 11189
    [Arguments]    ${dl_port}=${DL_PORT}    ${ul_port}=${UL_PORT}    ${ue_type}=${ue_type}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    iperf_port=${dl_port}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    iperf_port=${ul_port}

Power UE stop dl traffic and detach 11189
    [Arguments]    ${ue_type}=${ue_type}    ${dl_port}=${DL_PORT}    ${ue_index}=${0}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    iperf_port=${dl_port}
    sleep    3s
    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

Make a VoNR call(+4488) 11189
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=4488    ${sleep_time}=30s
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
    csn.disconnect      connection=cygwin${ue_index}

hang up VoNR call 11189
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 6    connection=cygwin${ue_index}

################### stream parameter ############################
Case variable set for ${case_key}
    test suite variable set for ${case_key}

test suite variable set for ${case_key}
    ${release_info}    Get sagnb release
    set suite variable    ${release_info}
    Run Keyword And Ignore Error    set suite variable    ${SCF_B1_002}           ${para_store['${case_key}']['${release_info}']['SCF_B1_002']}
    Run Keyword And Ignore Error    set suite variable    ${SCF_B2_006}           ${para_store['${case_key}']['${release_info}']['SCF_B2_006']}



#Get sagnb release
#    [Arguments]   ${host}=${asik_addr}   ${username}=${asik_username}   ${password}=${asik_password}
#    csn.Connect To   hostname=${host}   username=${username}   password=${password}   alias=release_info
#    ${info}   csn.Execute    command=ls /ffs/run/TargetBD*xml   connection=release_info
#    ${release_info}     set variable    ${info.split('_')[1]}_${info.split('_')[2]}_${info.split('_')[3]}
#    [Return]    ${release_info}
#    [Teardown]   csn.Disconnect   connection=release_info


#################### Recovery #######################
Tests Recover 11189 SA
    Get product brand
    Run Keyword If    '${gnb_instance}' == '${BTSID}[0]'    Power UE stop ul and dl traffic and detach 11189
    ...    ue_index=${2}    ELSE    Power UE stop ul and dl traffic and detach 11189    ue_index=${0}
    check hanging resource for per UE on gnb    gnb_ips=@{gnb_ips}    UE_Type_Index=${0}
    Connect to Common Unit Slave
    CI_interface.Common Case Teardown

Tests Recover 11189 NSA
    Get product brand
    Power UE stop ul and dl traffic and detach 11189    ue_index=${1}
    Modify the COAM parameter with admin API 11189    parameters=${UNLOCK_GNB1_AMF}    bts_host=${gnb_BTS_host}
    Run Keyword And Ignore Error    check hanging resource for per UE on gnb    gnb_ips=@{gnb_ips}    UE_Type_Index=${0}
    CI_interface.Common Case Teardown

disconect all connections
    run keyword and ignore error    csn.disconnect    connection=TestPC
    run keyword and ignore error     coam.teardown    connection=GNB_OAM
    run keyword and ignore error     csn.disconnect    connection=ASIK
    run keyword and ignore error     csn.disconnect    connection=gnb

clear cli process
    csn.Connect to    hostname=${askey_hostname}    username=${askey_username}    password=${askey_password}    alias=cygwin
    csn.send command    command=ps -ef | grep cli |grep ute_common_admin | grep -v grep |awk '{print $2}' |xargs kill -9    connection=cygwin

################# EDA03266995 ##########################
Load SCF for each TL for EDA
    Common Suite Setup for COAM
    Run Keyword If    '${gnb_instance}' == '${BTSID}[0]'
    ...    Common Case TestLine Setup    ModifySCF_Beforecommission_GNB2=True
    ...                                  golden_scf_name_gnb2=${tl_36012_scf_gnb2}
    ...                                  ListParamterToModify_gnb2=${MODIFY_LIST_EDA}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[1]'
    ...    Common Case TestLine Setup    ModifySCF_Beforecommission_GNB2=True
    ...                                  golden_scf_name_gnb2=${tl_34712_scf_gnb2}
    ...                                  ListParamterToModify_gnb2=${MODIFY_LIST_EDA}
#    ...                                  ParameterToDelete_gnb2=${Delete_LIST_574_C001}
#    ...                                  ListToAdd_gnb2=${ADD_LIST_574_C001}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[2]'
    ...    Common Case TestLine Setup    ModifySCF_Beforecommission_GNB2=True
    ...                                  golden_scf_name_gnb2=${tl_23312_scf_gnb2}
    ...                                  ListParamterToModify_gnb2=${MODIFY_LIST_EDA}

Prepare the atten for each TL FOR EDA
    Run Keyword If    '${gnb_instance}' == '${BTSID}[0]'
    ...    Adjust the TL HBTE attenuation value    enb1_cell1_value=${0}   gnb2_cell1_value=${0}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[1]'
    ...    Adjust the TL HBTE attenuation value    enb1_cell1_value=${0}   gnb2_cell1_value=${0}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[2]'
    ...    Adjust the TL HBTE attenuation value    enb1_cell1_value=${0}   gnb2_cell1_value=${0}

Online modify NIDD on gnb1 and gnb2
    [Arguments]    ${Modify_Para_Online}='NULL'    ${Modify_Para_Online_GNB2}='NULL'
    ...    ${ModifySCF_Aftercommission}=False    ${ModifySCF_Aftercommission_for_GNB2}=False
    Common Case TestLine Setup    ModifySCF_Aftercommission=${ModifySCF_Aftercommission}
    ...    ModifySCF_Aftercommission_for_GNB2=${ModifySCF_Aftercommission_for_GNB2}
    ...    Modify_Para_Online=${Modify_Para_Online}    Modify_Para_Online_GNB2=${Modify_Para_Online_GNB2}
    sleep    5s

Check the UL throughput
    [Arguments]    ${ul_expected_throughput}    ${cell_id}=${cell1_id}    ${gnb_index}=${0}
    power_ue.Check throughput    ue_type=${ue_type}    direction=ul    throughput=${ul_expected_throughput}
    ...    deviation=${deviation}    cellid=${cell_id}    gnb_index=${gnb_index}

Change PA to Menb Handover
    Run Keyword If    '${gnb_instance}' == '${BTSID}[0]'
    ...    Adjust the TL HBTE attenuation value    enb1_cell1_value=${10}   enb2_cell1_value=${0}
    ...    gnb2_cell1_value=${0}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[1]'
    ...    Adjust the TL HBTE attenuation value    enb1_cell1_value=${5}   enb2_cell1_value=${0}
    ...    gnb2_cell1_value=${0}
    Run Keyword If    '${gnb_instance}' == '${BTSID}[2]'
    ...    Adjust the TL HBTE attenuation value    enb1_cell1_value=${10}   enb2_cell1_value=${0}
    ...    gnb2_cell1_value=${0}

Check the relocation counters C010
    Check the PM counter should be greater than 1
#    Check the PM counter should be value
    ...    gnb_index=${1}    counter_id=${counter_id_C01}
    ...    dic_path=${counter_dic_path_C01_trunk}    value=${value_counter_C01}

Check the relocation counters C011
    Check the PM counter should be greater than 1
#    Check the PM counter should be value
    ...    gnb_index=${1}    counter_id=${counter_id_C011}
    ...    dic_path=${counter_dic_path_C011_trunk}    value=${value_counter_C011}

Check the relocation counters C012
    Check the PM counter should be greater than 1
#    Check the PM counter should be value
    ...    gnb_index=${1}    counter_id=${counter_id_C012}
    ...    dic_path=${counter_dic_path_C012_trunk}    value=${value_counter_C012}

Check the logs when actInterMeNBMobility equal to true for 1200
    [Arguments]    ${eNB1_x2_log}    ${eNB2_x2_log}    ${gNB_x2_log}
    Check the X2log on Target eNB    input_file=${eNB2_x2_log}
    Check the X2log on source eNB    input_file=${eNB1_x2_log}
    Check the X2log on gNB for 1200    input_file=${gNB_x2_log}
    Check the e1ap log on gNB    input_file=${gNB_x2_log}
    Check the f1ap log on gNB    input_file=${gNB_x2_log}
    should be equal    ${Target_MME_SgNB_UE_X2AP_ID}    ${source_MME_SgNB_UE_X2AP_ID}
    should be equal    ${Target_MME_UL_GTP_TEID}    ${gNB_bear_setup_gTP_TEID}
    should be equal    ${Target_MME_UL_transportLayerAddress}    ${gNB_bear_setup_transportLayerAddress}


Check the X2log on source eNB
    [Arguments]    ${input_file}
    ${all_packets}    wireshark.load_pcap_file    pcap_file=${epc_log_path}${input_file}
    ...   tshark_path=${tshark_path}   command_template=${command_template_Y}
    ${RRC_Reconfig}    Catenate    x2ap.procedureCode == 27 && ip.dst == ${eNB1_asik_addr}
    ${RRC_Reconfig_packets}    wireshark.filter_packets_by_expression    filter_expression=${RRC_Reconfig}
    ${SgNB_UE_X2AP_ID_0}=    wireshark.get_field_value_by_xpath    pdml_list=${RRC_Reconfig_packets}   xpath=.//x2ap.SgNB_UE_X2AP_ID
    ${UE_release}    Catenate    x2ap.procedureCode == 5 && ip.src == ${eNB1_asik_addr}
    ${UE_release_packets}    wireshark.filter_packets_by_expression    filter_expression=${UE_release}
    ${UE_release_value}    wireshark.get_field_value_by_xpath    pdml_list=${UE_release_packets}   xpath=.//x2ap.UE_X2AP_ID
    Set Suite Variable    ${source_MME_SgNB_UE_X2AP_ID}    ${SgNB_UE_X2AP_ID_0[-1]}

Check the X2log on Target eNB
    [Arguments]    ${input_file}
    ${all_packets}    wireshark.load_pcap_file    pcap_file=${epc_log_path}${input_file}
    ...   tshark_path=${tshark_path}   command_template=${command_template_Y}
    ${handover_request}=     Catenate    x2ap.id == 254
    ${handover_packets}=    wireshark.filter_packets_by_expression    filter_expression=${handover_request}
    ${handover_value}=    wireshark.get_field_value_by_xpath    pdml_list=${handover_packets}
    ...    xpath=.//x2ap.id
    should contain     ${handover_value}    254
    ${SgNB_Addition_Request}=    Catenate    x2ap.SGNB_Addition_Trigger_Ind == 1 && x2ap.procedureCode == 27
    ${SgNB_Addition_packets}=    wireshark.filter_packets_by_expression    filter_expression=${SgNB_Addition_Request}
    ${SgNB_UE_X2AP_ID}=    wireshark.get_field_value_by_xpath    pdml_list=${SgNB_Addition_packets}   xpath=.//x2ap.SgNB_UE_X2AP_ID
    ${UL_GTP_TEID}    wireshark.get_field_value_by_xpath    pdml_list=${SgNB_Addition_packets}
    ...    xpath=.//x2ap.s1_UL_GTPtunnelEndpoint_element//x2ap.gTP_TEID
    ${UL_transportLayerAddressIPv4}    wireshark.get_field_value_by_xpath    pdml_list=${SgNB_Addition_packets}
    ...    xpath=.//x2ap.s1_UL_GTPtunnelEndpoint_element//x2ap.transportLayerAddressIPv4
    ###20250113:check 574_C_001_eNB2.pcap message:handoverRequest--QCI7
    ${UL_transportLayerAddress}    wireshark.get_field_value_by_xpath    pdml_list=${SgNB_Addition_packets}
    ...    xpath=.//x2ap.s1_UL_GTPtunnelEndpoint_element//x2ap.transportLayerAddress
    ${DL_GTP_TEID}    wireshark.get_field_value_by_xpath    pdml_list=${SgNB_Addition_packets}
    ...    xpath=.//x2ap.meNB_DL_GTP_TEIDatMCG_element//x2ap.gTP_TEID
    ${DL_transportLayerAddressIPv4}    wireshark.get_field_value_by_xpath    pdml_list=${SgNB_Addition_packets}
    ...    xpath=.//x2ap.meNB_DL_GTP_TEIDatMCG_element//x2ap.transportLayerAddressIPv4
    ${DL_transportLayerAddress}    wireshark.get_field_value_by_xpath    pdml_list=${SgNB_Addition_packets}
    ...    xpath=.//x2ap.meNB_DL_GTP_TEIDatMCG_element//x2ap.transportLayerAddress
    ${sg_add_req_val}=    wireshark.get_field_value_by_xpath    pdml_list=${SgNB_Addition_packets}   xpath=.//nr-rrc.allowedBC_ListMRDC
    should not be empty    ${sg_add_req_val}
    ${sg_add_req_Trig_val}=    wireshark.get_field_value_by_xpath    pdml_list=${SgNB_Addition_packets}   xpath=.//x2ap.SGNB_Addition_Trigger_Ind
    should contain    ${sg_add_req_Trig_val}    1
    ${handover_ack}=     Catenate    x2ap.E_RABs_Admitted_List
    ${handover_ack_packets}    wireshark.filter_packets_by_expression    filter_expression=${handover_ack}
    ${handover_ack_value}    wireshark.get_field_value_by_xpath    pdml_list=${handover_ack_packets}   xpath=.//x2ap.E_RABs_Admitted_List
    should not be empty    ${handover_ack_value}
    ${rrc_reconfig}    Catenate    nr-rrc.keyToUse == 1 && ip.dst == ${eNB2_asik_addr} && ip.src == ${gnb2_asik_addr}
    ${rrc_reconfig_packets}    wireshark.filter_packets_by_expression    filter_expression=${rrc_reconfig}
    ${rrc_reconfig_value}    wireshark.get_field_value_by_xpath    pdml_list=${rrc_reconfig_packets}   xpath=.//nr-rrc.keyToUse
    should contain    ${rrc_reconfig_value}    1
    ${rrc_reconfig_S}    Catenate    nr-rrc.keyToUse == 1 && ip.dst == ${eNB1_asik_addr} && ip.src == ${eNB2_asik_addr}
    ${rrc_reconfig_S_packets}    wireshark.filter_packets_by_expression    filter_expression=${rrc_reconfig_S}
    ${rrc_reconfig_S_value}    wireshark.get_field_value_by_xpath    pdml_list=${rrc_reconfig_S_packets}   xpath=.//nr-rrc.keyToUse
    should contain    ${rrc_reconfig_S_value}    1
    ${rrc_config_complete}    Catenate    x2ap.procedureCode == 28 && ip.src == ${eNB2_asik_addr}
    ${rrc_config_complete_packets}    wireshark.filter_packets_by_expression    filter_expression=${rrc_config_complete}
    ${rrc_config_complete_value}    wireshark.get_field_value_by_xpath    pdml_list=${rrc_config_complete_packets}   xpath=.//x2ap.procedureCode
    should contain    ${rrc_config_complete_value}    28
    ${UE_release}     Catenate    x2ap.procedureCode == 5 && ip.dst == ${eNB1_asik_addr}
    ${UE_release_packets}    wireshark.filter_packets_by_expression    filter_expression=${UE_release}
    ${UE_release_value}    wireshark.get_field_value_by_xpath    pdml_list=${UE_release_packets}   xpath=.//x2ap.procedureCode
    should contain    ${UE_release_value}    5
    Set Suite Variable    ${Target_MME_SgNB_UE_X2AP_ID}    ${SgNB_UE_X2AP_ID[-1]}
    Comment    20241204,check this case for TL233 ,TL233 UE2 NSA HO from enb1 to enb2,QCI5 not add success,Adaption TL360 QCI5 can add success,
    ...        result in case failed on TL360,Actually TL233 NSA register has a issue(not add QCI5),after modify this issue,need to modify case code
    ...        then this case can pass---change value {UL_GTP_TEID} from -1 to 0(get QCI 7 gTP-TEID from SgNBAdditionRequest)
#    Set Suite Variable    ${Target_MME_UL_GTP_TEID}    ${UL_GTP_TEID[-1]}
    Set Suite Variable    ${Target_MME_UL_GTP_TEID}    ${UL_GTP_TEID[0]}
    #TL347#Set Suite Variable    ${Target_MME_UL_transportLayerAddress}    ${UL_transportLayerAddress[-1]}
    Comment    20250109,check this case TL360 check QCI7 :"transportLayerAddress: 0a399a512a008a008000013f0000000000010069 [bit length 160]",
    ...        before,QCI7 and QCI5 transportLayerAddress are the same,but now they are not the same(SRN change UPF setting).so modify code
    ...        'UL_transportLayerAddress[-1]}' to '{UL_transportLayerAddress[0]}'(I think before check wrong QCI5 address)
#    Set Suite Variable    ${Target_MME_UL_transportLayerAddress}    ${UL_transportLayerAddress[-1]}
    Set Suite Variable    ${Target_MME_UL_transportLayerAddress}    ${UL_transportLayerAddress[0]}

Check the e1ap log on gNB
    [Arguments]    ${input_file}
    ${all_packets}    wireshark.load_pcap_file    pcap_file=${epc_log_path}${input_file}
    ...   tshark_path=${tshark_path}   command_template=${command_template_Z}
    ${bear_setup}    Catenate    e1ap.procedureCode == 8
    ${bear_setup_packets}    wireshark.filter_packets_by_expression    filter_expression=${bear_setup}
    ${bear_setup_gTP_TEID}    wireshark.get_field_value_by_xpath    pdml_list=${bear_setup_packets}
    ...    xpath=.//e1ap.s1_UL_UP_TNL_Information//e1ap.gTP_TEID
    ${bear_setup_transportLayerAddress}    wireshark.get_field_value_by_xpath    pdml_list=${bear_setup_packets}
    ...    xpath=.//e1ap.s1_UL_UP_TNL_Information//e1ap.transportLayerAddress
    ${Bear_modify_req}=     Catenate    e1ap.id == 18
    ${Bear_modify_req_packets}    wireshark.filter_packets_by_expression    filter_expression=${Bear_modify_req}
    ${Bear_modify_req_value}    wireshark.get_field_value_by_xpath    pdml_list=${Bear_modify_req_packets}   xpath=.//e1ap.gTP_TEID
    ${Bear_modify_req_dl_TX_value}    wireshark.get_field_value_by_xpath    pdml_list=${Bear_modify_req_packets}   xpath=.//e1ap.dL_TX_Stop
    ${Bear_modify_res}=     Catenate    e1ap.id == 19
    ${Bear_modify_res_packets}    wireshark.filter_packets_by_expression    filter_expression=${Bear_modify_req}
    ${Bear_modify_res_value}    wireshark.get_field_value_by_xpath    pdml_list=${Bear_modify_req_packets}   xpath=.//e1ap.gTP_TEID
    should not be empty    ${Bear_modify_req_value}
    should contain    ${Bear_modify_req_dl_TX_value}    1
    should not be empty    ${Bear_modify_res_value}
    Set Suite Variable    ${gNB_bear_setup_gTP_TEID}    ${bear_setup_gTP_TEID[0]}
    #Set Suite Variable    ${gNB_bear_setup_transportLayerAddress}    ${bear_setup_transportLayerAddress[-1]}
    Set Suite Variable    ${gNB_bear_setup_transportLayerAddress}    ${bear_setup_transportLayerAddress[0]}
    #347#Set Suite Variable    ${gNB_bear_setup_transportLayerAddress}    ${bear_setup_transportLayerAddress[0]}

Check the f1ap log on gNB
    [Arguments]    ${input_file}
    ${all_packets}    wireshark.load_pcap_file    pcap_file=${epc_log_path}${input_file}
    ...   tshark_path=${tshark_path}   command_template=${command_template_X}
    ${Bear_modify}=     Catenate    f1ap.procedureCode == 7 && f1ap.gTP_TEID
    ${Bear_modify_packets}    wireshark.filter_packets_by_expression    filter_expression=${Bear_modify}
    ${Bear_modify_value}    wireshark.get_field_value_by_xpath    pdml_list=${Bear_modify_packets}   xpath=.//f1ap.gTP_TEID
    should not be empty    ${Bear_modify_value}

Check the X2log on gNB
    [Arguments]    ${input_file}
    ${all_packets}    wireshark.load_pcap_file    pcap_file=${epc_log_path}${input_file}
    ...   tshark_path=${tshark_path}   command_template=${command_template_Y}
    ${Sgb_release_req}=    Catenate    x2ap.procedureCode == 31 && x2ap.radioNetwork == 46
    ${Sgb_release_req_packets}=    wireshark.filter_packets_by_expression    filter_expression=${Sgb_release_req}
    ${Sgb_release_req_value}=    wireshark.get_field_value_by_xpath    pdml_list=${Sgb_release_req_packets}    xpath=.//x2ap.radioNetwork
    should contain    ${Sgb_release_req_value}    46
    ${Sgb_release_req_UE}=    wireshark.get_field_value_by_xpath    pdml_list=${Sgb_release_req_packets}    xpath=.//x2ap.UE_ContextKeptIndicator
    should contain    ${Sgb_release_req_UE}    0
    ${CFRA_preamble_index}=    Catenate    nr-rrc.ra_PreambleIndex == 32 && x2ap.X2AP_PDU == 1
    ${CFRA_preamble_index_packets}=    wireshark.filter_packets_by_expression
    ...    filter_expression=${CFRA_preamble_index}
    ${CFRA_preamble_index_value}=    wireshark.get_field_value_by_xpath    pdml_list=${CFRA_preamble_index_packets}
    ...    xpath=.//nr-rrc.ra_PreambleIndex
    should contain    ${CFRA_preamble_index_value}    32
    ${Sgb_release_ack}=    Catenate    ip.src == ${asik_addr} && x2ap.procedureCode == 31
    ${Sgb_release_ack_packets}=    wireshark.filter_packets_by_expression    filter_expression=${Sgb_release_ack}
    ${Sgb_release_ack_value}=    wireshark.get_field_value_by_xpath    pdml_list=${Sgb_release_ack_packets}    xpath=.//x2ap.procedureCode
    should contain    ${Sgb_release_ack_value}    31

Check the X2log on gNB for 1200
    [Arguments]    ${input_file}
    ${all_packets}    wireshark.load_pcap_file    pcap_file=${epc_log_path}${input_file}
    ...   tshark_path=${tshark_path}   command_template=${command_template_Y}
    ${Sgb_release_req}=    Catenate    x2ap.procedureCode == 31 && x2ap.radioNetwork == 46
    ${Sgb_release_req_packets}=    wireshark.filter_packets_by_expression    filter_expression=${Sgb_release_req}
    ${Sgb_release_req_value}=    wireshark.get_field_value_by_xpath    pdml_list=${Sgb_release_req_packets}    xpath=.//x2ap.radioNetwork
    should contain    ${Sgb_release_req_value}    46
    ${Sgb_release_req_UE}=    wireshark.get_field_value_by_xpath    pdml_list=${Sgb_release_req_packets}    xpath=.//x2ap.UE_ContextKeptIndicator
    should contain    ${Sgb_release_req_UE}    0
    ${Sgb_release_ack}=    Catenate    ip.src == ${gnb2_asik_addr} && x2ap.procedureCode == 31
    ${Sgb_release_ack_packets}=    wireshark.filter_packets_by_expression    filter_expression=${Sgb_release_ack}
    ${Sgb_release_ack_value}=    wireshark.get_field_value_by_xpath    pdml_list=${Sgb_release_ack_packets}    xpath=.//x2ap.procedureCode
    should contain    ${Sgb_release_ack_value}    31

Hanging resource test
    [Arguments]    ${gnb_ips}=@{gnb_ips}    ${ue_index}=${ue_index}
    [Documentation]    hanging resource test
    [Timeout]    1hour
    Check hanging resource for gnb    gnb_ips=${gnb_ips}    ue_index=${ue_index}

Kill QXDM and QPSK exe
    [Arguments]    ${ue_index}
    Connect to control pc enhanced    ue_index=${ue_index}
    csn.send command    command=taskkill /F /IM QXDM.exe    connection=cpc_${ue_index}
    csn.send command    command=taskkill /F /IM QPSTServer.exe    connection=cpc_${ue_index}
    Csn.disconnect      connection=cpc_${ue_index}

Kill ClientMain exe
    [Arguments]    ${ue_index}
    Connect to control pc enhanced    ue_index=${ue_index}
    csn.send command    command=taskkill /F /IM ClientMain.exe    connection=cpc_${ue_index}
    Csn.disconnect      connection=cpc_${ue_index}

Prepare LKC and get license
    [Arguments]    ${ue_index}
    ${UE_pc_ip} =    set variable    ${tl.ues[${ue_index}].ssh_connection_details.addr}
    ${UE_pc_user} =    set variable    ${tl.ues[${ue_index}].ssh_connection_details.username}
    ${UE_pc_password} =    set variable    ${tl.ues[${ue_index}].ssh_connection_details.password}
    LK.create_ssh_runner    host=${UE_pc_ip}    username=${UE_pc_user}    password=${UE_pc_password}    alias=${LKC_CLIENT_ALIAS}
    Connect to control pc enhanced    ue_index=${ue_index}
    ${LKC_INFO}=    create dictionary
    ...    host=${UE_pc_ip}
    ...    path=${LKC_CLIENT_PATH}
    ...    user=${UE_pc_user}
    ...    password=${UE_pc_password}
    QLC.setup    launcher=${LKC_INFO}
    BuiltIn.Wait Until Keyword Succeeds    5min    30s    QLC.login    username=${LKC_LOGIN_USER}    password=${LKC_LOGIN_PWD}
    BuiltIn.Wait Until Keyword Succeeds    5min    30s    QLC.get_licence_qxdm_5g
    BuiltIn.Wait Until Keyword Succeeds    5min    30s    QLC.get_licence_qcat_5g

release lkc license
    QLC.release_licence_qxdm_5g
    QLC.release_licence_pcat_5g


Capture QXDM log by COMport
    [Arguments]    ${ue_index}    ${QXDM_log_name}    ${COMport}
    Connect to control pc enhanced    ue_index=${ue_index}
    ${hdf_file} =    set variable    ${5G_QXDM_PATH}/${QXDM_log_name}.hdf
    ${command_output}    csn.execute
    ...    command=cmd /c python ${5G_QXDM_PATH}/QXDM5Logcatch.py -t 20 -p ${COMport} -c ${5G_QXDM_PATH}/Tput_only.dmc -s ${hdf_file}
    ...    connection=cpc_${ue_index}    timeout=300
    sleep    15s
    ${capture_status}     Run Keyword And Return Status    Should Contain    ${command_output}    log save to path
    Run Keyword If     '${capture_status}' == 'False'    get licence again and capture log by comport
    ...       QXDM_log_name=${QXDM_log_name}     COMport=${COMport}    hdf_file=${hdf_file}    ue_index=${ue_index}
    sleep    5s
    ${capture_status}     Run Keyword And Return Status    Should Contain    ${command_output}    log save to path
    Csn.disconnect      connection=cpc_${ue_index}

get licence again and capture log by comport
    [Arguments]      ${QXDM_log_name}    ${COMport}    ${hdf_file}    ${ue_index}
    BuiltIn.Wait Until Keyword Succeeds    5min    30s    QLC.get_licence_qxdm_5g
    BuiltIn.Wait Until Keyword Succeeds    5min    30s    QLC.get_licence_qcat_5g
    Csn.disconnect      connection=cpc_${ue_index}
    sleep    1s
    Connect to control pc enhanced    ue_index=${ue_index}
    ${hdf_file} =    set variable    ${5G_QXDM_PATH}/${QXDM_log_name}.hdf
    ${command_output}    csn.execute
    ...    command=cmd /c python ${5G_QXDM_PATH}/QXDM5Logcatch.py -t 20 -p ${COMport} -c ${5G_QXDM_PATH}/Tput_only.dmc -s ${hdf_file}
    ...    connection=cpc_${ue_index}    timeout=300
    ${capture_status}     Run Keyword And Return Status    Should Contain    ${command_output}    log save to path


5G isf decoder to txt and save to local
    [Arguments]    ${ue_index}    ${QXDM_log_name}
    Connect to control pc enhanced    ue_index=${ue_index}
    wait until keyword succeeds    2min    2s    Csn.Assert file exists
    ...    remote_path=${5G_QXDM_PATH}/${QXDM_log_name}.hdf    connection=cpc_${ue_index}
    Log to console   \nINFO:5G Qmdl decoder to txt
    Csn.force_reconnect       connection=cpc_${ue_index}
    ${result}   Csn.execute
    ...  command=cmd /c ${QCAT_EXE_PATH} -txt ${5G_QXDM_PATH}/${QXDM_log_name}.hdf
    ...  connection=cpc_${ue_index}
    Log to console   \nINFO:${result}
    Csn.download file
    ...   remote_path=${5G_QXDM_PATH}/${QXDM_log_name}.txt
    ...   local_path=${epc_log_path}${QXDM_log_name}.txt
    ...   connection=cpc_${ue_index}
    Csn.execute   command=rm -rf ${5G_QXDM_PATH}/*.hdf   connection=cpc_${ue_index}
    Csn.execute   command=rm -rf ${5G_QXDM_PATH}/*.txt   connection=cpc_${ue_index}
    [Teardown]     Csn.disconnect   connection=cpc_${ue_index}


Deal uldata with hdf
    [Documentation]   Author: Liu Jia
    ...                Desription: deal with uelog captured by qxdm.
    ...                caculate lte ul tput only
    [Arguments]    ${QXDM_log_name}    ${lte_ul_expect}
    ...            ${ute_ip}=${tl.test_pc.default_ssh_connection_details.addr}
    ...            ${ute_name}=${tl.test_pc.default_ssh_connection_details.username}
    ...            ${ute_password}=${tl.test_pc.default_ssh_connection_details.password}
    ...            ${ute_alias}=ute
    Csn.Connect to   hostname=${ute_ip}   username=${ute_name}     password=${ute_password}    alias=${ute_alias}
    ${tput_qx}     Csn.execute
    ...    command=cat ${epc_log_path}${QXDM_log_name}.txt| grep 'ENL2UL.*LT.*tput.*'     connection=${ute_alias}
    ${exp_ul}    set variable
    ...    tput.*PHY.*(\\d\\d\\d\\d\\d).*L2buffDelay.*
    ${lte_ul} =    get regexp matches    ${tput_qx}    ${exp_ul}    1
    ${length}     get length    ${lte_ul}
    Set Test Variable    ${sum}    ${0}
    FOR    ${i}    IN RANGE     ${length}
      ${sum}   evaluate    ${sum} + ${lte_ul}[${i}]
    END
    ${lte_ul_tput}    evaluate    ${sum}/${length}
    should be true    ${lte_ul_tput} > ${lte_ul_expect}
    [Return]     ${lte_ul_tput}

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
