*** Settings ***
Documentation
...    author: xiaodan.li
...    contact: xiaodan.li@nokia-sbell.com
...    squad group: SG_03

Library    OperatingSystem
Library    Collections
Library    String
Library    BuiltIn
Library    taf.gnb.oam.commissioning   WITH NAME    commissioning
Library    taf.gnb.oam.megazone_client    WITH NAME    megazone_client
Library    taf.ul.oam.selenium_megazone    WITH NAME    selenium_megazone
Library    taf.config.testline    WITH NAME    testline
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/UE.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Atten.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/eNB.robot
Library    taf.analyzer.pcap    WITH NAME    cap
Library    taf.ul.messaging.mtk    WITH NAME    message
Library    taf.pdu       WITH NAME    pdu
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/nrdim_throughput/interface.py    WITH NAME    nrdim_get_tput

*** Variables ***
${WEBUI_COAM}    https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_NAME}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
${distname_id_1}       MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}
${TS_LOG_PATH_BASE_classical}    /opt/workspace/CRT/Master/Case_Logs/
${TS_CASE_LOG_PATH_classical}    /opt/workspace/CRT/Master/Case_Logs/
${tl_scf_dir_path_classical}    /opt/workspace/CIT/Master/SCF_file/1881/
${TS_LOG_PATH_BASE_cloud}    /home/ute/workspace/CRT/Master/Case_Logs/
${TS_CASE_LOG_PATH_cloud}    /home/ute/test_results/Logs/
${TS_CASE_SWCONFIG_PATH_cloud}    /home/ute/test_results/swconfig/
${ute_log_path_cloud}    /home/ute/test_results/
${tl_scf_dir_path_cloud}    /home/ute/Auto5G/commissionings/HGZ/
${asik_addr}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${asik_username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${asik_password}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${gnb_path}    /tmp/
${iperf_path}    ${tl.ues[0].iperf_details.iperf_path}
${gnb_instance}     ${tl.gnbs[0].instance_id}
${cell1_distname}    MRBTS-${gnb_instance}/NRBTS-${gnb_instance}/NRCELL-1
${bts_distname}    MRBTS-${gnb_instance}/NRBTS-${gnb_instance}
${ALIAS_ASIK}    ASIK
${enb_bts}    MRBTS-${tl.enbs[0].instance_id}/LNBTS-${tl.enbs[0].instance_id}
${enbx2_dist}    ${enb_bts}/LNADJGNB-1
${enb_cell}    ${enb_bts}/LNCEL-1
${enbx2_dist_21B}    ${enb_bts}/LNADJGNB-0
${enb_cell_21B}    ${enb_bts}/LNCEL-11
${actDynTrig}    actDynTrigLteNrDualConnectivity
${default_rel}    defaultLnRelGnbCellId
${enbx2_para}    administrativeState
${epc_log_path}    /opt/workspace/CRT/Master/Case_Logs/
${ue_dl_port}    ${tl.ues[0].iperf_details.ssh_connection_details.port}
${dl_direction}    dl
${duration}    300
${dl_throughput}    800M
${dl_expect_throughput_false}    537    ###600*0.95=475
${dl_expect_throughput_true}    575     ###570*0.95=546
${dl_expect_throughput_false_22R1}    515     ###515*0.95=489
${dl_expect_throughput_true_22R1}    540     ###540*0.95=513
${dl_expect_throughput1}    105.3   ###105.3*0.95=100
## Attenuator parameter ##
${gNB_cell_dist}    MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}
${ue_type}    ${tl.ues[0].capabilities[0]}
${SN}    ${tl.ues[0].serial_number}

## Attenuator parameter ##
${atten_ip}    ${tl.attenuator[0].ip_addr}
#${5GRU1_ANT1}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}

${att_api_port}         ${tl.attenuator[0].port}
${max_attenuation_value}     ${127}
${vendor}                    ${tl.attenuator[0].vendor}
##cloud ute default para##
${testline_name}      null
${CONFIGURATION}      null
${bts_host}    ${tl.gnbs[0].cu.oam_http_connection_details.addr}
@{gnb_ips}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}

*** Keywords ***
lock or unlock enb for sa set
    [Arguments]    ${cell_status}=locked    ${enb_cell_id}=${12}    ${enb_index}=${0}
    Connect and Modify the parameter on enblte
    ...    dist_name=MRBTS-${tl.enbs[${enb_index}].instance_id}/LNBTS-${tl.enbs[${enb_index}].instance_id}/LNCEL-${enb_cell_id}
    ...    parameter=administrativeState
    ...    value=${cell_status}
    sleep    10s

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

Unlock amf for NSA attach
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


Pre Condition
    [Documentation]    Author: Ren Biyao
    ...    This keyword will set the default path for scf which will be used for ute cloud or lightweight CI.
    [Timeout]    20 min
    [Arguments]
    ${SCF_PATH}     Get Substring    ${CURDIR}  0  24
    ${TL_NAME}   set variable if      '${testline_name}' == 'null'    ${CONFIGURATION}    ${testline_name}
    ${pattern}   Set Variable    7_5(.*)
    ${TLNAME_match}    Get Regexp Matches     ${TL_NAME}    ${pattern}    1
    ${testlinename}   Set Variable    7_5${TLNAME_match}[0]
    ${CONFIGURATION}    Get Variable Value    ${CONFIGURATION}
    set suite variable     ${CONFIGURATION}
    set suite variable     ${SCF_PATH}
    set suite variable     ${testlinename}
    Connect to Common Unit Master    alias=ASIK Master
    run keyword if    '${CONFIGURATION}' != '${None}' and '${CONFIGURATION}' != 'null'
    ...    Default directory for ute cloud
    ...    ELSE    Default directory for lightweight ci

Default directory for ute cloud
    [Documentation]    Author: Ren Biyao
    ...     Description: default dir scf and swconfig and log dir for ute cloud.
    ${cur_dir}    run    pwd
    set suite variable     ${TS_LOG_PATH_BASE}       ${cur_dir}/../test_results
    set suite variable     ${SWCONFIG_DEFAULT_FILE_PATH}    ${SCF_PATH}/commissionings/HGZ/${testlinename}/swconfig.txt
    set suite variable     ${luashark_path}        /opt/luashark/luashark.lua
    Set Suite Variable    ${TS_CASE_LOG_PATH}    ${TS_CASE_LOG_PATH_cloud}
    Set Suite Variable    ${TS_CASE_SWCONFIG_PATH}    ${TS_CASE_SWCONFIG_PATH_cloud}/swconfig.txt
    Set Suite Variable    ${ute_log_path}    ${ute_log_path_cloud}
    Set Suite Variable    ${tl_scf_dir_path}     ${SCF_PATH}/commissionings/HGZ/${testlinename}/
    Common Suite Setup for COAM

Default directory for lightweight ci
    Set Suite Variable    ${TS_LOG_PATH_BASE}    ${TS_LOG_PATH_BASE_classical}
    Set Suite Variable    ${TS_CASE_LOG_PATH}    ${TS_CASE_LOG_PATH_classical}
    Set Suite Variable    ${tl_scf_dir_path}     ${tl_scf_dir_path_classical}
    Set Suite Variable    ${ute_log_path}    ${TS_CASE_LOG_PATH_classical}
    Common Suite Setup for COAM

Prepare the enb dyntrig
    run keyword if   '${gnb_id}'=='${gnb_instance[1]}'     run keywords    Modify the enblte parameter
    ...    dist_name=${enb_bts}    parameter=${actDynTrig}    value=false    AND
    ...    Modify the enblte parameter    dist_name=${enb_cell_21B}    parameter=${default_rel}    value=0
    ...    ELSE    run keywords    Modify the enblte parameter    dist_name=${enb_bts}
    ...    parameter=${actDynTrig}    value=false    AND
    ...    Modify the enblte parameter    dist_name=${enb_cell}    parameter=${default_rel}    value=0

## GNB BTS Precondition ##
Prepare with COAM classical BTS cell onair
    [Arguments]
    Common Case TestLine Setup    Is_Swconfig=True
    ...    swconfig_file=${SWCONFIG_DEFAULT_FILE_PATH}    swconfig_target_path=${TS_CASE_SWCONFIG_PATH}
    run keyword if   '${gnb_id}'=='${gnb_instance[1]}'
    ...    Modify the enblte parameter    dist_name=${enbx2_dist_21B}    parameter=${enbx2_para}    value=locked
    ...    ELSE    Modify the enblte parameter    dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=locked
    Wait until keyword succeeds    15min   30s    Check the COAM gnb RU status ready
    sleep    30s
    run keyword if   '${gnb_id}'=='${gnb_instance[1]}'
    ...    Modify the enblte parameter    dist_name=${enbx2_dist_21B}    parameter=${enbx2_para}    value=unlocked
    ...    ELSE    Modify the enblte parameter    dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=unlocked
    sleep    60s
    Wait Until Keyword Succeeds    5 min    30 sec     Check the cells status on air    bts_host=${bts_host}
    ...    connection=gnb
    Online modify parmeters    parameters_to_update=${Lock_gnb1_AMF1}

Common Suite Teardown for COAM
    connect to gnb coam via ssl
    COAM Download scf from cluster    scf_dir_path=${epc_log_path}
    #COAM Save snapshot via rest api    log_path=${epc_log_path}
    COAM Teardown gnb connections

Get gnb release info
    ${release_info}    Get sagnb release
    set suite variable    ${release}    ${release_info}

get peak value
    [Arguments]    ${peak_list}
    ${Peak_list_value}=    get from list    ${peak_list}    0
    ${Peak_value}=    get from dictionary   ${Peak_list_value}    average
    ${Peak_value}=    convert to integer    ${Peak_value}
    [Return]    ${Peak_value}

Modify gnb parameter and gnb on air
    [Arguments]    ${parameters}=${parameters}
    Online modify parmeters    parameters_to_update=${parameters}
    Wait Until Keyword Succeeds    5 min    30 sec     Check the cells status on air    bts_host=${bts_host}
    ...    connection=gnb

disconect all connections
    run keyword and ignore error    csn.disconnect    connection=TestPC
    run keyword and ignore error     coam.teardown    connection=GNB_OAM
    run keyword and ignore error     csn.disconnect    connection=ASIK


Get Cell id list
    ${cell1_id}=    run keyword if   '${gnb_id}'=='${gnb_instance[0]}'    COAM Get nrcellid with lcrid    lcrid=${16383}
    ...    ELSE    COAM Get nrcellid with lcrid    lcrid=${1}
    ${list_of_cell_ids}    Create list    ${cell1_id}
    [Return]    ${list_of_cell_ids}

Get the all PM counter value
    [Arguments]    ${counter_id}    ${dic_path}    ${gnb_index}=${0}
    ...    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ${counter_lenth}    Get Length    ${counter_id}
    ${counter_value_list}    create list
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
    FOR    ${index}    IN RANGE    ${counter_lenth}
        ${counter_value} =    get_pm_counter_values    counter_id=${counter_id[${index}]}    connection=GNB_OAM
         ...    dic_path=${dic_path[${index}]}
        append to list    ${counter_value_list}    ${counter_value[0]}
    END
    [Return]    ${counter_value_list}

Prepare with PM counter time to caculate
    [Arguments]    ${period}=start
    ${utc0} =    Get Time    epoch
    ${utc} =    Evaluate    ${utc0}-${utc0}%300
    ${utc} =    set variable if    '${period}'=='start'     ${utc+300}    ${utc}
    set suite variable    ${${period}_date}    ${utc}
    ${left_timer} =    Evaluate    300-${utc0}%300
    sleep    ${left_timer}

Snapshot Save
    [Arguments]    ${gnb_index}=${0}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    username=${WEBUI_NAME}
    ...    password=${WEBUI_PWD}
    COAM Save snapshot via rest api    log_path=${epc_log_path}
    [Teardown]    COAM Teardown gnb connections

Kill firefox process
    ssh.Connect to    ${tl.test_pc.default_ssh_connection_details.addr}
    ...               ${tl.test_pc.default_ssh_connection_details.username}
    ...               ${tl.test_pc.default_ssh_connection_details.password}
    ...               alias=ute
    csn.send_command    command=ps -ef | grep firefox | awk '{print $2}' | xargs kill -9    connection=ute
    sleep   2s
    csn.disconnect      connection=ute
