*** Settings ***

Documentation     author: Na Li
...               contact: na.li@nokia-sbell.com
...               squad group: MMW_SG_04

Library           taf.sbts.oam.coam.admin  WITH NAME  coam
Library           Collections
#Resource          ../core_checker.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Library           ute_admin
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Commercial_mobile_phone_adb_common_keywords.robot
#Resource          ../../../../../resources/sites/Ulm/Common/connect.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/aasyslog.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Throughput_checking_from_GNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/rrm_log_check.robot
Resource          ../../../../RRM/RAN_PZ_HAZ_34/5GC001937_OTA/resources/5GC001937_keywords.robot

*** Variables ***
${global_bts_id}           ${tl.gnbs[0].global_bts_id}
${instance_id}              ${tl.gnbs[0].instance_id}
${WEBUI_HOST}              ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${WEBUI_USER}              ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBUI_PWD}               ${tl.gnbs[0].cu.oam_http_connection_details.password}
${DST_FOR_FRM}             MRBTS-${instance_id}/EQM_R-1/APEQM_R-1/RMOD_R-1
${DST_FOR_FRM_1}           MRBTS-${instance_id}/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1
${DST_FOR_FRM_2}           MRBTS-${instance_id}/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1/GNSSE_R-1
${DST_FOR_FRM_3}           MRBTS-${instance_id}/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1/POWERGROUP_R-1
${DST_FOR_FRM_4}           MRBTS-${instance_id}/EQM_R-1/APEQM_R-1/RMOD_R-1
${DST_FOR_FRM_5}           MRBTS-${instance_id}/EQM_R-1/HWTOP_R-1/CABLINK_R-1001
${ul_throughput1}          100M
${dl_throughput1}          2048M
${ul_peak_50M}             55
${dl_peak_50M}             1150
${DU_OAM_SSH_USERNAME}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${DU_OAM_SSH_PASSWORD}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${UTE_ADDRESS}    ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}    ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}    ${tl.test_pc.default_ssh_connection_details.password}

*** Keywords ***
Connect to DU
    [Arguments]    ${alias}=cOAM_admin
    ${conn}=    coam.connect_to
    ...    bts_host=${WEBUI_HOST}
    ...    username=${WEBUI_USER}
    ...    password=${WEBUI_PWD}
    ...    name=${alias}
    [Return]    ${conn}

Disconnect from DU
    [Arguments]    ${alias}=cOAM_admin
    coam.teardown     connection=${alias}

ADMIN Wait Until BTS OnAir
    [Arguments]    ${timeout}=15 min
    ...            ${interval}=30 sec
    ...            ${alias}=cOAM_admin
    Wait Until Keyword Succeeds    ${timeout}
    ...                            ${interval}
    ...                            ADMIN Check onair
    ...                            admin_alias=${alias}

ADMIN Check onair
    [Arguments]        ${admin_alias}=${LOGGING_ADMIN_ALIAS}
    ${dict_info}=    coam.Get Bts Info    connection=${admin_alias}
    ${state}=    Get From Dictionary    dictionary=${dict_info['status']}    key=proceduralState
    Should be equal    ${state}    OnAir

Login Page Via WebUI
    selenium_coam.enable_virtual_display
    selenium_coam.login    url=https://${WEBUI_HOST}    username=${WEBUI_USER}    password=${WEBUI_PWD}
    selenium_coam.disable_message_box
    selenium_coam.disable_screen_lock

Selenium Cell Lock From WebUI
    [Arguments]    ${cell_id}    ${timeout}=60s
    selenium_coam.lock_cell     cell_idx=${cell_id}
    wait until keyword succeeds    ${timeout}   5s    Selenium Check If Cell Is Locked    cell_id=${cell_id}
    Log    message=Cell ${cell_id} is locked         console=${True}

Selenium Cell Unlock From WebUI
    [Arguments]                 ${cell_id}=1
    ...                         ${timeout}=300s
    selenium_coam.unlock_cell   cell_idx=${cell_id}
    wait until keyword succeeds    ${timeout}  5s    Selenium Check If Cell Is Unlocked    cell_id=${cell_id}
    Log    message=Cell ${cell_id} is unlocked       console=${True}

Selenium Check If Cell Is Locked
    [Arguments]  ${cell_id}=1
    ${cell_status}  selenium_coam.get_cell_info   cell_idx=${cell_id}
    should be equal as strings  ${cell_status['Status']['Operational state']}     Disabled
    should be equal as strings  ${cell_status['Status']['Availability status']}   Offline
    should be equal as strings  ${cell_status['Status']['Administrative state']}  Locked
    should be equal as strings  ${cell_status['Status']['Procedural status']}    initialization required


Selenium Check If Cell Is Unlocked
    [Arguments]  ${cell_id}=1
    ${cell_status}  selenium_coam.get_cell_info   cell_idx=${cell_id}
    should be equal as strings  ${cell_status['Status']['Operational state']}    Enabled
    should be equal as strings  ${cell_status['Status']['Availability status']}    Online
    should be equal as strings  ${cell_status['Status']['Administrative state']}    Unlocked
    should be equal as strings  ${cell_status['Status']['Procedural status']}    configured

Perform cell-group lock via rest api
    [Arguments]    ${cellgrp_idx}=${0}    ${connection}=cOAM_admin    ${timeout}=60    ${gnb_id}=0
    coam.lock_cell_group    dist_name=MRBTS_A-${instance_id}/NRBTS_A-${global_bts_id}/NRCELLGRP_A-${cellgrp_idx}     timeout=${timeout}
    ...    connection=${connection}

Perform cell-group unlock via rest api
    [Arguments]    ${cellgrp_idx}=${0}    ${connection}=cOAM_admin    ${timeout}=60    ${gnb_id}=0
    coam.unlock_cell_group    dist_name=MRBTS_A-${instance_id}/NRBTS_A-${global_bts_id}/NRCELLGRP_A-${cellgrp_idx}     timeout=${timeout}
    ...    connection=${connection}

Get GNB Cell Status
    [Arguments]  ${cell_idx}   ${cell_group_idx}   ${timeout}=10   ${connection}=cOAM_admin
    ${subcells_status}    coam.get_subcells_status   timeout=${timeout}    connection=${connection}
    ${status_dict}   Catenate   'operationalState':
    ...                         '${subcells_status["NRCELLGRP-${cell_group_idx}"]["NRCELL-${cell_idx}"]["NRCELL_R"]["operationalState"]}',
    ...                         'availabilityStatus':
    ...                         '${subcells_status["NRCELLGRP-${cell_group_idx}"]["NRCELL-${cell_idx}"]["NRCELL_R"]["availabilityStatus"]}',
    ...                         'administrativeState':
    ...                         '${subcells_status["NRCELLGRP-${cell_group_idx}"]["NRCELL-${cell_idx}"]["NRCELL_R"]["administrativeState"]}'
    ${subcell_status}    Evaluate   {${status_dict}}
    [Return]   ${subcell_status}

check Cell after Locked
    [Arguments]  ${cell_idx}=${1}   ${cell_group_idx}=${0}   ${timeout}=10   ${connection}=cOAM_admin
    ...    ${operationalState}=Disabled    ${availabilityStatus}=Offline    ${administrativeState}=Locked
    ${subcell_status}=    Get GNB Cell Status      cell_idx=${cell_idx}
    ...                                      cell_group_idx=${cell_group_idx}
    ...                                      timeout=${timeout}
    ...                                      connection=${connection}
    Should Be Equal As Strings  ${subcell_status["operationalState"]}   ${operationalState}
    Should Be Equal As Strings  ${subcell_status["availabilityStatus"]}  ${availabilityStatus}
    Should Be Equal As Strings  ${subcell_status["administrativeState"]}  ${administrativeState}

login webui and get parameter and check
    [Arguments]      ${expect_usage_status}    ${expect_operational_state}
    log to console    login webui and get parameter and check
    Login Page Via WebUI
    ${usage_status}    selenium_coam.get parameter value    dist_name=${DST_FOR_FRM}    filter_param=Usage state    abbr=usageState
    ${operational_state1}    selenium_coam.get parameter value    dist_name=${DST_FOR_FRM_1}
    ...     filter_param=Operational state    abbr=operationalState

    ${operational_state4}    selenium_coam.get parameter value    dist_name=${DST_FOR_FRM_4}
    ...     filter_param=Operational state    abbr=operationalState
    ${operational_state5}    selenium_coam.get parameter value    dist_name=${DST_FOR_FRM_5}
    ...     filter_param=Operational state    abbr=operationalState
    should be equal as strings     ${usage_status}    ${expect_usage_status}
    should be equal as strings     ${operational_state1}    ${expect_operational_state}
    should be equal as strings     ${operational_state4}    ${expect_operational_state}
    should be equal as strings     ${operational_state5}    ${expect_operational_state}
    [Teardown]    selenium_coam.logout

Input default SCF
    [Timeout]  20 min
    [Arguments]    ${scf}    ${timeout}=10 min
    ${conn}    Connect to DU
    BuiltIn.Log    \n Input default SCF \n    console=yes
    run keyword and ignore error    COAM Commission with scf file    scf_file_path=${scf}    connection=${conn}
    BuiltIn.Log    \n wait until gnb cell on air \n    console=yes
    wait until keyword succeeds    ${timeout}    30sec   Cloud DU connect to gnb coam via ssl    connection=${conn}
    wait until keyword succeeds    ${timeout}    30sec   COAM Check GNB cell on air    connection=${conn}
    [Teardown]    Disconnect from DU

honor attach
    [Arguments]  ${ue_index}=${0}    ${ue_type}=huawei
    Log To Console    honor attach
    power_ue.Prepare UE    ue_type=${ue_type}
    ${5Grach_ed0}    power_ue.UE Attach    ue_type=${ue_type}
    Log To Console    Verify attach
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed0}    4G_check=False

UE check throughput
    [Arguments]    ${tp_direction}    ${exp_ul}=50    ${exp_dl}=220
    log to console    Check throughput
    ${all_tp}    Get ul and dl peak and ave throughput and return result
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'    Run keyword and continue on failure
    ...      should be true    ${all_tp[0]}>${exp_dl}
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    Run keyword and continue on failure
    ...     should be true    ${all_tp[3]}>${exp_ul}

UE start traffic
    [Documentation]    used for UE start traffic, ul/dl/both.
    [Arguments]    ${ue_index}=${0}    ${protocol}=udp    ${tp_direction}=both    ${duration}=600    ${iperf_type}=via_command
    ...    ${ul_throughput}=140M    ${dl_throughput}=600M    ${time}=20s    ${ue_type}=huawei
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    power_ue.Start traffic    ue_index=${ue_index}
    ...    direction=ul    throughput=${ul_throughput}    duration=${duration}    ue_type=${ue_type}    iperf_type=${iperf_type}
    ...    protocol=${protocol}
    sleep    1s
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'   power_ue.Start traffic    ue_index=${ue_index}
    ...     direction=dl    throughput=${dl_throughput}    duration=${duration}    ue_type=${ue_type}    protocol=${protocol}
    sleep    ${time}

Honor attach and start traffic
    [Arguments]    ${ul_peak}    ${dl_peak}    ${ul_throughput}    ${dl_throughput}
    honor attach
    UE start traffic       tp_direction=ul    time=15s    ul_throughput=${ul_throughput}
#    UE check throughput     tp_direction=ul    exp_ul=${ul_peak}    exp_dl=0
    run keyword and continue on failure    power_ue.Check throughput
    ...    ue_type=huawei    direction=ul    throughput=${ul_peak}     cellid=11468801
    power_ue.Stop traffic    ue_type=huawei    direction=ul    iperf_type=via_command
    UE start traffic       tp_direction=dl    time=15s    dl_throughput=${dl_throughput}
#    UE check throughput     tp_direction=dl    exp_ul=0    exp_dl=${dl_peak}
    run keyword and continue on failure    power_ue.Check throughput
    ...    ue_type=huawei    direction=dl    throughput=${dl_peak}     cellid=11468801
    power_ue.Stop traffic    ue_type=huawei    direction=dl    iperf_type=via_command
    [Teardown]    run keyword and ignore error    power_ue.UE Detach    ue_type=huawei

Get ul and dl peak and ave and min throughput and return result
    [Documentation]    Get ul and dl peak and ave throughput and return result.
    ...    :param aasys_start_flag: for short time captrue use default, for long time call use ${False}, EG:${true}/${False}
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${aasys_start_flag}=${true}    ${cell_id}=${EMPTY}
    ${cell_number}    Get cell numbers in gnb    gnb_index=${gnb_index}    du_index=${du_index}
    run keyword if    '${aasys_start_flag}'=='${true}'    AAsys log captrue    gnb_index=${gnb_index}    du_index=${du_index}
    ...    sleep_time=300s
    ${cell_id}    Get nrcellid from aasys log    gnb_index=${gnb_index}    du_index=${du_index}
    ${dl_traffic_data}    ${ul_traffic_data}    Get traffic data from aasys log    gnb_index=${gnb_index}    du_index=${du_index}
    ...    cell_id=${cell_id}
    ${dl_peak_tp}    ${dl_average_tp}    ${dl_minimum_tp}    Calculate Throughput and retrun result in gnb    data=${dl_traffic_data}
    ...    cell_numbers=${cell_number}
    ${ul_peak_tp}    ${ul_average_tp}    ${ul_minimum_tp}    Calculate Throughput and retrun result in gnb    data=${ul_traffic_data}
    ...    cell_numbers=${cell_number}
    [Return]    ${dl_peak_tp}    ${dl_average_tp}    ${dl_minimum_tp}    ${ul_peak_tp}    ${ul_average_tp}    ${ul_minimum_tp}

Get Alarm Info
    [Arguments]   ${timeout}    ${connection}=cOAM_admin
    sleep    10s
    @{alarms}    coam.get_active_alarms    timeout=${timeout}    connection=cOAM_admin
    sleep    1s
    log     ${alarms}
    ${fault_id_list}    create list
    ${fault_name_list}    create list
    FOR    ${item}    IN    @{alarms}
        ${fault_id}    get from dictionary    ${item}    faultId
        ${fault_name}    get from dictionary    ${item}    faultName
        append to list    ${fault_id_list}    ${fault_id}
        append to list    ${fault_name_list}    ${fault_name}
    END
    [Return]    ${fault_name_list}    ${fault_id_list}

Get RU Led State
    [Arguments]    ${ru}
    ${RU_state}         selenium_coam.get_led_status_of_an_unit     unit=RMOD-${ru}
    Log to console      RU state: ${RU_state}
    [Return]            ${RU_state}

RU Ping not ok
    [Documentation]    ping ip address from DU to RU
    ssh.Connect to    hostname=${WEBUI_HOST}    username=${DU_OAM_SSH_USERNAME}
    ...   password=${DU_OAM_SSH_PASSWORD}    alias=VM
    ${response}    csn.execute    command=ping 172.16.18.33 -s 40000 -c 1    connection=VM
    should contain    ${response}    100% packet loss
    [Teardown]    ssh.disconnect    connection=VM
    [Return]  ${response}

Start Catch BTS Log
    [Arguments]   ${name}=btslog    ${bts_logs_dir}=/tmp/btslog2
    Log To Console    Start Catch BTS Log
    __Make empty BTS logs dir      bts_logs_dir=${bts_logs_dir}
    btslog.create_btslog_collector    name=${name}    log_dir=${bts_logs_dir}
    core.setup_collectors        names=${name}
    core.start_collectors        names=${name}
    btslog.set_suite_alias       alias=${name}

__Make empty BTS logs dir
    [Arguments]     ${bts_logs_dir}
    Run  if [ ! -d ${bts_logs_dir} ]; then mkdir ${bts_logs_dir}; else rm ${bts_logs_dir}/*; fi

Stop BTS Log and Check OAMLOG
    Log To Console    Stop and collect btslog on local machine
    Stop and collect btslog on local machine
    Check OAMLOG

Stop and collect btslog on local machine
    [Arguments]   ${name}=btslog
    Log To Console    Stop and collect btslog on local machine
    core.stop_collectors         names=${name}
    core.collect_collectors      names=${name}
    core.teardown_collectors     names=${name}

Check OAMLOG
    [Arguments]    ${bts_logs_dir}=/tmp/btslog2
    Log To Console    Check OAMLOG
    ssh.Connect to    hostname=${UTE_ADDRESS}    username=${UTE_USERNAME}    password=${UTE_PASSWORD}    alias=VM
    sleep    2s
    ssh.send_command    cat ${bts_logs_dir}/SYSLOG_*.LOG | grep 'modifyStateReq'
    ...    connection=VM
    sleep    2s
    ${output}    ssh.read output    connection=VM
    should not be empty    ${output}
    ssh.send_command    cat ${bts_logs_dir}/SYSLOG_*.LOG | grep 'updateUnitStateInfoForRestart'
    ...    connection=VM
    sleep    2s
    ${output1}    ssh.read output    connection=VM
    should not be empty    ${output1}
    [Teardown]    ssh.disconnect    connection=VM









