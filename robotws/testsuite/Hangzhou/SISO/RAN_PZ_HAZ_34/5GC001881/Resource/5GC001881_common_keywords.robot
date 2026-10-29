*** Settings ***
Documentation
...    author: qionghua zhang
...    contact: qionghua.zhang@nokia-sbell.com
...    squad group: SG_03

Library    OperatingSystem
Library    Collections
Library    String
Library    BuiltIn
Library    taf.config.scf    WITH NAME    scf
Library    taf.transport.ssh    WITH NAME    csn
Library    taf.sbts.oam.coam.admin              WITH NAME    coam
Library    taf.gnb.oam.commissioning   WITH NAME    commissioning
Library    taf.gnb.oam.megazone_client    WITH NAME    megazone_client
Library    taf.ul.oam.selenium_megazone    WITH NAME    selenium_megazone
Library    taf.hw.rf_attenuator    WITH NAME    attenuator
Library    taf.config.testline    WITH NAME    testline
#Library    ./../../../../../resources/python_libs/Attenuation.py
#Library    ../../../../RRM/Hangzhou/libraries/L3Call.py
#Library    Attenuation.Attenuation    WITH NAME    atten
Library    taf.analyzer.pcap
#Library    taf.analyzer.pcap
Library    taf.ul.messaging.mtk    WITH NAME    message
Library    taf.pdu       WITH NAME    pdu
Resource    taf/rfrl/common_resources/robot/gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource    taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Common_setup_and_teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot
#Resource    ../../common/made_siso_common.robot

*** Variables ***
${TS_LOG_PATH_BASE_classical}    /opt/workspace/CIT/Master/Case_Logs/
${TS_CASE_LOG_PATH_classical}    /opt/workspace/CIT/Master/Case_Logs/
${tl_scf_dir_path_classical}    /opt/workspace/CRT/Master/SCF_file/
${TS_LOG_PATH_BASE_cloud}    /home/ute/workspace/CIT/Master/Case_Logs/
${TS_CASE_LOG_PATH_cloud}    /home/ute/test_results/Logs/
${TS_CASE_SWCONFIG_PATH_cloud}    /home/ute/test_results/swconfig/
${ute_log_path_cloud}    /home/ute/test_results/
${tl_scf_dir_path_cloud}    /home/ute/Auto5G/commissionings/HGZ/
#${tl_scf_dir_path}    /opt/workspace/CIT/Master/SCF_file/1881/
${WEBUI_COAM}    https://${tl.gnbs[0].cu.oam_http_connection_details.addr}
${WEBUI_NAME}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
${asik_addr}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${asik_username}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${asik_password}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${gnb_path}    /tmp/
${iperf_path}    ${tl.ues[0].iperf_details.iperf_path}
${gnb_instance}     ${tl.gnbs[0].instance_id}
${cell1_distname}    MRBTS-${gnb_instance}/NRBTS-${gnb_instance}/NRCELL-1
${cell2_distname}    MRBTS-${gnb_instance}/NRBTS-${gnb_instance}/NRCELL-2
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
${epc_log_path}    /opt/workspace/CIT/Master/Case_Logs/
${ue_ul_port}    ${tl.ues[0].iperf_details.port}
${ue_dl_port}    ${tl.ues[0].iperf_details.ssh_connection_details.port}
${ul_direction}    ul
${dl_direction}    dl
${duration}    600
${ul_throughput}    40M
${dl_throughput}    800M
${ul_expect_throughput}    29
${dl_expect_throughput}    580     ###552*0.95=525
${dl_expect_throughput_22R1}    600     ###530*0.95=503
${ul_expect_throughput1}    10.53   ###10.53*0.95=10
${dl_expect_throughput1}    105.3   ###105.3*0.95=100
## Attenuator parameter ##
${gNB_cell_dist}    MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].instance_id}
${ue_type}    ${tl.ues[0].capabilities[0]}
${SN}    ${tl.ues[0].serial_number}

## Attenuator parameter ##
${atten_ip}    ${tl.attenuator[0].ip_addr}
#${5GRU1_ANT1}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${5GRU1_ANT1}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${5GRU1_ANT2}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${5GRU1_ANT3}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[2].port_no}
${5GRU1_ANT4}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[3].port_no}
${4GRU1_ANT1}    ${tl.attenuator[0].attenuator_ports[5]}
${4GRU1_ANT2}    ${tl.attenuator[0].attenuator_ports[6]}
${att_api_port}         ${tl.attenuator[0].port}
${atten_ip_21B}    ${tl.attenuator[1].ip_addr}
${5GRU0_ANT1_21B}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${5GRU0_ANT2_21B}    ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[1].port_no}
${5GRU1_ANT1_21B}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[0].port_no}
${5GRU1_ANT2_21B}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[1].port_no}
${5GRU1_ANT3_21B}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[2].port_no}
${5GRU1_ANT4_21B}    ${tl.gnbs[0].dus[0].rus[1].attenuation_ports[3].port_no}
${att_api_port_21B}         ${tl.attenuator[1].port}
${max_attenuation_value}     ${127}
${vendor}                    ${tl.attenuator[0].vendor}
${vendor_21B}                    ${tl.attenuator[1].vendor}
${model}    ${tl.attenuator[0].model}
##cloud ute default para##
${testline_name}      null
${CONFIGURATION}      null
@{attenuation_port_numbers}    ${5GRU1_ANT1}    ${5GRU1_ANT2}    ${5GRU1_ANT3}    ${5GRU1_ANT4}
@{attenuation_port_numbers_21B}    ${5GRU1_ANT1_21B}    ${5GRU1_ANT2_21B}    ${5GRU1_ANT3_21B}    ${5GRU1_ANT4_21B}
@{attenuation_port_numbers_21BRU0}    ${5GRU0_ANT1_21B}    ${5GRU0_ANT2_21B}
@{bts_id}    356111    35911    36911
@{gnb_ips}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}

*** Keywords ***
Pre Condition
    [Documentation]    Author: Ren Biyao
    ...    This keyword will set the default path for scf which will be used for ute cloud or lightweight CI.
    [Timeout]    20 min
    [Arguments]
    ${SCF_PATH}     Get Substring    ${CURDIR}  0  24
    ${TL_NAME}   set variable if      '${testline_name}' == 'null'    ${CONFIGURATION}    ${testline_name}
    ${pattern}   Set Variable    7_5(.*)
    ${TLNAME}    Get Regexp Matches     ${TL_NAME}    ${pattern}    1
    ${testlinename}   Set Variable    7_5${TLNAME}[0]
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
    set suite variable     ${SWCONFIG_PEAK_FILE_PATH}    ${SCF_PATH}/commissionings/HGZ/${testlinename}/peak_swconfig/swconfig.txt
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
    run keyword if    '${gnb_id}'=='${btsid[1]}'     run keywords    Connect and Modify the parameter on enblte
    ...    dist_name=${enb_bts}    parameter=${actDynTrig}    value=false    AND
    ...    Connect and Modify the parameter on enblte    dist_name=${enb_cell_21B}    parameter=${default_rel}    value=0
    ...    ELSE    run keywords    Connect and Modify the parameter on enblte    dist_name=${enb_bts}
    ...    parameter=${actDynTrig}    value=false    AND
    ...    Connect and Modify the parameter on enblte    dist_name=${enb_cell}    parameter=${default_rel}    value=0

#Common Suite Setup for COAM
#    COAM Create log directory    is_set_to_test_case_level=${False}
#    ${time_stamp}    Get current date    result_format=%Y%m%d%H%M%S
#    Set Suite Variable    ${epc_log_path}    ${LOG_PATH}/${time_stamp}/
#    Create directory    ${epc_log_path}

#Common Suite Teardown for COAM
#    connect to gnb coam via ssl
#    COAM Download scf from cluster    scf_dir_path=${epc_log_path}
#    COAM Save snapshot via rest api    log_path=${epc_log_path}
#    COAM Teardown gnb connections

## GNB BTS Precondition ##
Prepare the classical COAM BTS cell onair
    ${cell_status}    ${cell_value} =    Run Keyword And Ignore Error    Prepare with COAM classical BTS cell onair
    set suite variable    ${cell_status}

Prepare with COAM classical BTS cell onair
    [Arguments]    ${tl_scf_filename}=${tl_scf_filename}
    Perform full commission for COAM gnb    tl_scf_filename=${tl_scf_filename}
    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=locked
    Check COAM gnb classical start normally
    sleep    30s
    Connect and Modify the parameter on enblte    dist_name=${enbx2_dist}    parameter=${enbx2_para}    value=unlocked
    sleep    60s
    Check the COAM gnb cell status onair

Check COAM gnb classical start normally
#    Check Airscale HW module status
#    ${res} =    Feature 1514 Enabled
    wait until keyword succeeds    15min   30s
    ...    Check the COAM gnb RU status ready

Perform full commission for COAM gnb
    [Arguments]    ${tl_scf_filename}=${tl_scf_filename}
    Connect to gnb coam via ssl
    COAM Commission with scf file    scf_file_path=${tl_scf_dir_path}${tl_scf_filename}    timeout=600
    ...    is_pdl_checking_needed=${False}
    [Teardown]    COAM Teardown gnb connections

#Check the COAM gnb RU status ready
#    Connect to gnb coam via ssl
#    wait until keyword succeeds    10min   30s    COAM Check GNB RU status
#    [Teardown]    COAM Teardown gnb connections

Case preparation
    COAM Create log directory
    Connect to gnb coam via ssl
    Connect to Common Unit Master    alias=ASIK Master
    Connect to Capacity Unit Loner    alias=ABIL Loner_1
    Connect to RU With Allocated IP    ru_index=${1}    ru_alias=RU_1    asik_alias=ASIK Master    connection=GNB_OAM

Case env recovery
    Cell Should Be Unlocked
    ...    cell_idx=${1}    cell_group_idx=${0}    timeout=10    connection=GNB_OAM
    Run keyword and ignore error    Teardown all connections
    run keyword and ignore error    COAM Teardown gnb connections
    Run Keyword And Ignore Error    run    command=ps -ef | grep firefox |awk '{print $2}' | xargs kill -9

enb env recovery
    run keyword if    '${gnb_id}'=='${btsid[1]}'     run keywords    Connect and Modify the parameter on enblte
    ...    dist_name=${enb_bts}    parameter=${actDynTrig}    value=false    AND
    ...    Connect and Modify the parameter on enblte    dist_name=${enb_cell_21B}    parameter=${default_rel}    value=0

Teardown all connections
    [Arguments]    #${log_path_alarm}=${TS_CASE_LOG_PATH}
    Run keyword and ignore error    coam_gnb_classical.COAM Teardown gnb connections
    Run keyword and ignore error    enb_lte.Enblte close down    connection=${ENB_ALIAS}
    Run keyword and ignore error    csn.Disconnect    connection=ABIL Loner_1
    Run keyword and ignore error    csn.Disconnect    connection=ASIK Master
    Run keyword and ignore error    csn.Disconnect    connection=RU_1
#    Run keyword and ignore error    csn.Disconnect    connection=RU_2

Case recovery
    Cell Should Be Unlocked    cell_idx=${1}    cell_group_idx=${0}    timeout=10    connection=GNB_OAM
    Run keyword and ignore error    5GC001881_common_keywords.Teardown all connections

env recovery
    Run Keyword And Ignore Error    Modify parameters online for cases     parameters_to_update=${PARAM_1881_014_arfcn}
    Run Keyword And Ignore Error     Check gnb COAM classical start normally

Check only default Fault Present
    Connect to gnb coam via ssl
    @{alarm_list}    COAM Get active alarms
    FOR     ${alarms}    IN    @{alarm_list}
        Should Contain Any    '${alarms}[additionalFaultID]'
    ...    ${ALLOWED_FAULT[0]}    ${ALLOWED_FAULT[1]}    ${ALLOWED_FAULT[2]}    ${ALLOWED_FAULT[3]}    ${ALLOWED_FAULT[4]}
    ...    ${ALLOWED_FAULT[5]}    ${ALLOWED_FAULT[6]}
    END
    [Teardown]  COAM Teardown gnb connections

Check webui shows ${Fault_id} alarm
    selenium_coam.enable_virtual_display
    wait until keyword succeeds    2min   20s    selenium_coam.login    url=${WEBUI_COAM}
    ...    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    @{result}    selenium_coam.get_active_alarm_info
    ${fault_dic}   set variable    ${result}[-1]
    ${alarm_id_0}    set variable    ${fault_dic}[Fault ID]    #filter
    should be equal     ${alarm_id_0}     ${Fault_id}
    [Teardown]  Run keyword and ignore error    selenium_coam.logout

Get parameter in SCF
    [Arguments]    ${para}    ${dist_value}    ${connection}=GNB_OAM
    ${parameter}    coam_parameter.get_single_value_from_scf_file    parameter=${para}    dist_name=${dist_value}    connection=${connection}
    [Return]    ${parameter}

Modify parameters online for cases
    [Arguments]    ${parameters_to_update}    ${download_dir}=${epc_log_path}
    COAM modify several parameters via webUI   parameters_to_update_via_webui=${parameters_to_update}
    ...    download_dir=${download_dir}

COAM modify several parameters via webUI
    [Arguments]      ${parameters_to_update_via_webui}    ${download_dir}
    ...       ${is_need_to_check_validation_errors}=${False}
    ...       ${is_gnb_restrat_after_online_modify}=${False}
    COAM Navigate to login page via webUI    download_dir=${download_dir}
    @{diff_para} =    create list
    FOR  ${cur_para_to_update}  IN  @{parameters_to_update_via_webui}
        ${cur_para_value}    selenium_coam.get_parameter_value
        ...    dist_name=${cur_para_to_update['dist_name']}
        ...    abbr=${cur_para_to_update['abbr']}
        ...    filter_param=${cur_para_to_update['filter_param']}
        Run keyword if    '${cur_para_value}'=='${cur_para_to_update['new_value']}'
        ...    Log to console    current value is ${cur_para_value}, no need to update
        ...    ELSE    run keywords
        ...    selenium_coam.set_parameter_value
        ...    dist_name=${cur_para_to_update['dist_name']}
        ...    abbr=${cur_para_to_update['abbr']}
        ...    filter_param=${cur_para_to_update['filter_param']}
        ...    new_value=${cur_para_to_update['new_value']}    AND
        ...    Append to list    ${diff_para}    ${cur_para_to_update}
    END
    Run keyword if    ${diff_para}    run keywords
    ...    selenium_coam.validate_plan    AND
    ...    COAM check validation errors from webui
    ...    is_need_to_check_validation_errors=${is_need_to_check_validation_errors}    AND
    ...    selenium_coam.activate_plan    activate_plan_despite_errors=${True}    AND
    ...    COAM Verify gnb on air after activate plan via webUI    download_dir=${download_dir}
    ...    is_gnb_restrat_after_online_modify=${is_gnb_restrat_after_online_modify}
    [Teardown]    selenium_coam.logout

Check gnb COAM classical start normally
    Check Airscale HW module status
    wait until keyword succeeds    15min   30s    Check the gnb RU status ready

Check the COAM gnb cell status onair
    Connect to gnb coam via ssl
    wait until keyword succeeds    15min   30s    COAM Check GNB cell on air
    [Teardown]    COAM Teardown gnb connections

Check the gnb RU status ready
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${ru_status} =    selenium_coam.get_ru_info
    sleep    8s
    selenium_coam.logout
    Get info status check    info_status=${ru_status}

Get info status check
    [Arguments]    ${info_status}
    ${status} =   get from dictionary    ${info_status}    Status
    ${opr_state} =   get from dictionary    ${status}    Operational state
    should be equal    ${opr_state}    Enabled
    ${avi_state} =   get from dictionary    ${status}   Availability status
    should be equal    ${avi_state}    Online
    ${adm_state} =   get from dictionary    ${status}    Administrative state
    should be equal    ${adm_state}    Unlocked

Power Off For All RU
    ${ru_num}    get length    ${tl.gnbs[0].dus[0].rus}
    FOR  ${index}    IN RANGE    ${ru_num}
       ${index}    Evaluate    ${index}+${1}
       ${status}    Run Keyword And Return Status     Perform RU Power Off    ru_index=${index}
    ...    model=${tl.gnbs[0].dus[0].rus[${index}-1].pdu_port.pdu.__class__.__name__}
       run keyword if  not ${status}    Log    Power Off RU_${index}  failed.
    END

Power On For All RU
    ${ru_num}    get length    ${tl.gnbs[0].dus[0].rus}
    FOR  ${index}    IN RANGE    ${ru_num}
       ${index}    Evaluate    ${index}+${1}
        ${status}    Run Keyword And Return Status     Perform RU Power On    ru_index=${index}
    ...    model=${tl.gnbs[0].dus[0].rus[${index}-1].pdu_port.pdu.__class__.__name__}
       run keyword if  not ${status}    Log    Power On RU_${index}  failed.
    END

Reconnection For gnb Alais
    [Arguments]    ${hw_slot}=${1}
    Connect to Common Unit Master
    Connect to Capacity Unit Master    hw_slot=${hw_slot}
    Connect to Capacity Unit Loner    hw_slot=${hw_slot}
    Connect to RU With Allocated IP

Precondition for Sansumg UE
    [Arguments]    ${ue_type}    ${ui_version}=S20UI2.5    ${ue_index}=${0}
    power_ue.Prepare UE    ue_type=${ue_type}    ui_version=${ui_version}    ue_index=${ue_index}    reset_sol=pc_reset

Common UE attach
    [Arguments]    ${gnb_index}=${0}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${0}    gnb_index=${gnb_index}
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}
    ...    ue_index=${0}    gnb_index=${gnb_index}    4G_check=True

Common UE teardown
    Run Keyword And Ignore Error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    iperf_port=${ue_ul_port}
    Run Keyword And Ignore Error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    iperf_port=${ue_dl_port}
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}

## Huawei ##
Huawei UE teardown
    Run Keyword And Ignore Error    power_ue.Stop traffic    ue_type=huawei    direction=ul
    Run Keyword And Ignore Error    power_ue.Stop traffic    ue_type=huawei    direction=dl
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=huawei

Huawei UE attach
    [Arguments]    ${gnb_index}=${0}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    gnb_index=${gnb_index}
    power_ue.Verify attach    ue_type=${ue_type}    gnb_index=${gnb_index}    4G_check=False    5Grach_ed=${5Grach_ed}

Case env recovery for RU lock
#    Run Keyword And Ignore Error    Perform RU Unlock    ru_index=${1}
    Perform RU Unlock    ru_index=${1}
    Case env recovery

Case env recovery for cell lock
#    Run Keyword And Ignore Error    Perform Cell Unlock    cell_idx=${1}
    Perform Cell Unlock    cell_idx=${1}
    Case env recovery

Get parameter value
    [Arguments]    ${dis_name}    ${filter_name}
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=${WEBUI_COAM}    username=${WEBUI_NAME}    password=${WEBUI_PWD}
    ${value}=    selenium_coam.get_parameter_value    dist_name=${dis_name}
    ...    filter_param=${filter_name}
    selenium_coam.logout
    [Return]    ${value}

Modify the parameter on gNB bts
    [Arguments]    ${parameters}
    Connect to gnb coam via ssl
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters}

Modify NIDD parameter
    [Arguments]    ${parameters_to_update}
    ...    ${bts_host}=${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[0].cu.oam_http_connection_details.password}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${parameters_to_update}    timeout=${600}
    sleep    5
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

Online delete object
    [Arguments]    ${parameters_to_delete}    ${gnb_index}=${0}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    COAM delete objects via rest api    objects_to_delete_via_api=${parameters_to_delete}    timeout=${600}
    sleep    5
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

Online delete NIDD parameter
    [Arguments]    ${parameters_to_delete}    ${gnb_index}=${0}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    COAM delete parameters via rest api    parameters_to_delete_via_api=${parameters_to_delete}    timeout=${600}
    sleep    5
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

Add NIDD parameter
    [Arguments]    ${parameters_to_add}    ${gnb_index}=${0}
    Connect to gnb coam via ssl    bts_host=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    COAM add several parameters via rest api    parameters_to_add_via_api=${parameters_to_add}    timeout=${600}
    sleep    5
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections

#COAM Get nrcellid with lcrid
#    [Arguments]   ${lcrid}
#    Connect to gnb coam via ssl
#    ${cell_info}   coam.get_subcells_info   timeout=20    connection=GNB_OAM
#    ${number_of_cell_group_info}    get length    ${cell_info}
#    FOR  ${index}    IN RANGE    ${number_of_cell_group_info}
#        ${cell_from_cellgrp}    Get from Dictionary    ${cell_info}    NRCELLGRP-${index}
#        ${nrCellId}    Get nrcellid in all cellgroup with lcrid    cell_from_cellgrp=${cell_from_cellgrp}    lcrid=${lcrid}
#        exit for loop if    '${nrCellId}'!='None'
#    END
#    [Return]    ${nrCellId}
##    [Teardown]    COAM Teardown gnb connections

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

#Adjust RU1 Attenuation
#    [Arguments]    ${value_1}    ${value_2}    ${value_3}    ${value_4}
#    run keyword if    '${gnb_id}'=='${btsid[1]}'
#    ...    run keywords    Adjust the Attenuation Value    ports=${5GRU1_ANT1_21B}    value=${value_1}    atten_ip=${atten_ip_21B}
#    ...    AND    Adjust the Attenuation Value    ports=${5GRU1_ANT2_21B}    value=${value_2}    atten_ip=${atten_ip_21B}
#    ...    AND    Adjust the Attenuation Value    ports=${5GRU1_ANT3_21B}    value=${value_3}    atten_ip=${atten_ip_21B}
#    ...    AND    Adjust the Attenuation Value    ports=${5GRU1_ANT4_21B}    value=${value_4}    atten_ip=${atten_ip_21B}
#    ...    ELSE    run keywords    Adjust the Attenuation Value    ports=${5GRU1_ANT1}    value=${value_1}
#    ...    AND    Adjust the Attenuation Value    ports=${5GRU1_ANT2}    value=${value_2}
#    ...    AND    Adjust the Attenuation Value    ports=${5GRU1_ANT3}    value=${value_3}
#    ...    AND    Adjust the Attenuation Value    ports=${5GRU1_ANT4}    value=${value_4}

Adjust RU1 Attenuation
    [Arguments]    ${value_1}    ${value_2}    ${value_3}    ${value_4}
    run keyword if    '${gnb_id}'=='${btsid[1]}'
    ...    run keywords    Adjust the Attenuation Value    ports=${5GRU1_ANT1_21B}    value=${value_1}    atten_ip=${atten_ip_21B}
    ...    AND    Adjust the Attenuation Value    ports=${5GRU1_ANT2_21B}    value=${value_2}    atten_ip=${atten_ip_21B}
    ...    AND    Adjust the Attenuation Value    ports=${5GRU1_ANT3_21B}    value=${value_3}    atten_ip=${atten_ip_21B}
    ...    AND    Adjust the Attenuation Value    ports=${5GRU1_ANT4_21B}    value=${value_4}    atten_ip=${atten_ip_21B}
    ...    ELSE    run keywords    Adjust the Attenuation Value    ports=${5GRU1_ANT1}    value=${value_1}
    ...    AND    Adjust the Attenuation Value    ports=${5GRU1_ANT2}    value=${value_2}
    ...    AND    Adjust the Attenuation Value    ports=${5GRU1_ANT3}    value=${value_3}
    ...    AND    Adjust the Attenuation Value    ports=${5GRU1_ANT4}    value=${value_4}

Tear down other cell
    run keyword if    '${gnb_id}'=='${btsid[1]}'    Modify Attenuation for TL359

Modify Attenuation for TL359
    adjust the HBTE attenuation value 21BRU0    ${120}    ${120}    ${5GRU0_ANT1_21B}    ${5GRU0_ANT2_21B}
    ...    ${atten_ip}    ${att_api_port}    ${vendor}    ${attenuation_port_numbers_21BRU0}

Modify ${ru_index} Attenuation to ${value}
    Adjust RU1 Attenuation new    ports=${5G${ru_index}_ANT1_21B}    value=${value}
    Adjust RU1 Attenuation new   ports=${5G${ru_index}_ANT2_21B}    value=${value}

#Adjust the Attenuation Value
#    [Arguments]    ${ports}    ${value}    ${atten_ip}=${atten_ip}
#    atten.connect to    ip=${atten_ip}
#    atten.get_value    channel=${ports}
#    atten.set_value    channel=${ports}    value=${value}
#    atten.disconnect

Adjust RU1 Attenuation new
    [Arguments]    ${value_1}    ${value_2}    ${value_3}    ${value_4}
    run keyword if    '${gnb_id}'=='${btsid[1]}'    Adjust the HBTE attenuation value    value_1=${value_1}    value_2=${value_2}
    ...    value_3=${value_3}    value_4=${value_4}    att_port_1=${5GRU1_ANT1_21B}    att_port_2=${5GRU1_ANT2_21B}
    ...    att_port_3=${5GRU1_ANT3_21B}    att_port_4=${5GRU1_ANT4_21B}     atten_ip=${atten_ip_21B}    att_api_port=${att_api_port_21B}
    ...    vendor=${vendor_21B}    attenuation_port_numbers=${attenuation_port_numbers_21B}
    ...    ELSE    Adjust the HBTE attenuation value    value_1=${value_1}    value_2=${value_2}    value_3=${value_3}
    ...    value_4=${value_4}    att_port_1=${5GRU1_ANT1}    att_port_2=${5GRU1_ANT2}    att_port_3=${5GRU1_ANT3}
    ...    att_port_4=${5GRU1_ANT4}     atten_ip=${atten_ip}    att_api_port=${att_api_port}    vendor=${vendor}
    ...    attenuation_port_numbers=${attenuation_port_numbers}


adjust the HBTE attenuation value 21BRU0
    [Arguments]     ${value_1}     ${value_2}
    ...    ${att_port_1}    ${att_port_2}    ${atten_ip}    ${att_api_port}    ${vendor}    ${attenuation_port_numbers}
    ...    ${model}=${model}
    attenuator.setup_attenuator    ip_addr=${atten_ip}    port=${att_api_port}
    ...    attenuation_port_numbers=${attenuation_port_numbers}   max_attenuation=${max_attenuation_value}    vendor=${vendor}
    ...    model=${model}
    attenuator.set_attenuation     port=${att_port_1}    value=${value_1}
    attenuator.set_attenuation     port=${att_port_2}    value=${value_2}
    ${value_port_1}    attenuator.read_attenuation    port=${att_port_1}
    should be equal    ${value_port_1}    ${value_1}
    ${value_port_2}    attenuator.read_attenuation    port=${att_port_2}
    should be equal    ${value_port_2}    ${value_2}
    sleep    5s


adjust the HBTE attenuation value
    [Arguments]     ${value_1}     ${value_2}     ${value_3}     ${value_4}
    ...    ${att_port_1}=${5GRU1_ANT1}    ${att_port_2}=${5GRU1_ANT2}    ${att_port_3}=${5GRU1_ANT3}
    ...    ${att_port_4}=${5GRU1_ANT4}     ${attenuation_port_numbers}=${5GRU1_ANT1}
    ...    ${model}=${model}
    attenuator.setup_attenuator    ip_addr=${atten_ip}    port=${att_api_port}
    ...    attenuation_port_numbers=${attenuation_port_numbers}   max_attenuation=${max_attenuation_value}    vendor=${vendor}
    ...    model=${model}
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

adjust the enb HBTE attenuation value
    [Arguments]     ${value_1}=${0}     ${value_2}=${0}
    attenuator.setup_attenuator    ip_addr=${atten_ip}    port=${att_api_port}
    ...    attenuation_port_numbers=${4GRU1_ANT1}    max_attenuation=${max_attenuation_value}    vendor=${vendor}
    ...    model=${model}
    attenuator.set_attenuation     port=${4GRU1_ANT1}    value=${value_1}
    attenuator.set_attenuation     port=${4GRU1_ANT2}    value=${value_2}
    ${value_port_1}    attenuator.read_attenuation    port=${4GRU1_ANT1}
    should be equal    ${value_port_1}    ${value_1}
    ${value_port_2}    attenuator.read_attenuation    port=${4GRU1_ANT2}
    should be equal    ${value_port_2}    ${value_2}
    sleep    5s

Get gnb release info
    ${release_info}    Get sagnb release
    set suite variable    ${release}    ${release_info}

Get sagnb release
    [Arguments]   ${host}=${asik_addr}   ${username}=${asik_username}   ${password}=${asik_password}
    csn.Connect To   hostname=${host}   username=${username}   password=${password}   alias=release_info
    ${info}   csn.Execute    command=ls /ffs/run/TargetBD*xml   connection=release_info
    ${release_info}     set variable    ${info.split('_')[1]}_${info.split('_')[2]}_${info.split('_')[3]}
    [Return]    ${release_info}
    [Teardown]   csn.Disconnect   connection=release_info
