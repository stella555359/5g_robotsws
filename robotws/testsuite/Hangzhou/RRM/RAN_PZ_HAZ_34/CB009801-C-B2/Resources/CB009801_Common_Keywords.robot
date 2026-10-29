*** Settings ***
Documentation
...         author: Lixia.tang
...         contact: lixia.tang@nokia-sbell.com
...         squad group: 5G_PZ_MMW_HZ_3_SG
...         CB009801 parity feature CB009169 T+F 2CC DL 2CC UL CA test

Library     taf.sbts.oam.coam.admin   WITH NAME    admin_cli
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/coam_resource.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/rrm_log_check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/Classical_gNB.robot

*** Variables ***
${LOG_PATH}              /home/ute/Case_Logs/CB009801
${SCF_TEMPLATE_PATH}     ${commissionings_path}/HGZ/7_5_UTE5G402T2069
${elt_temp_fold}         C:/UEPC/MTK/ELT_exe_v3.2340.0_customer_x64/ELT_v3.2340.0/Temp/

*** Keywords ***
Scf commission and wait for on-air
    [Arguments]   ${scf_name}   ${connection}=COAM
    admin_cli.perform_commissioning
    ...   scf_file=${SCF_TEMPLATE_PATH}/${scf_name}
    ...   skip_parameter_relation_errors=${true}
    ...   should_activate=${true}
    ...   timeout=${600}
    ...   connection=${connection}
    Wait Until Keyword Succeeds    20min    20s    COAM Check All Cells Onair

Get gNB Release Version
    [Arguments]   ${host}=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...    ${username}=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
    ...    ${password}=${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
    csn.Connect To   hostname=${host}   username=${username}   password=${password}   alias=release_info
    ${info}   csn.Execute    command=ls /ffs/run/TargetBD*xml   connection=release_info
    ${release_info_temp}     set variable    ${info.split('_')[1]}
    ${release_info}     set variable    ${release_info_temp.split('SBTS')[1]}
    [Return]    ${release_info}
    [Teardown]   csn.Disconnect   connection=release_info

Suite setup
    Connect to gnb coam via ssl    connection=COAM
    ...    gnb_index=${0}
    ...    bts_host=${tl.gnbs[0].dus[0].f1_m_ip_addr}
    ...    username=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...    password=${tl.gnbs[0].cu.oam_http_connection_details.password}

Suite teardown
    Run Keyword And Ignore Error    admin_cli.teardown    connection=COAM

CaseTeardown
    Log To Console    \n *** Case teardown
    Run keyword and continue on failure   Check unexpected alarm and fail case
    Save Snapshot If Case Failed
    Run Keyword And Ignore Error    Teardown the Aasyslog save progress
	Run Keyword And Ignore Error    CI_interface.Common Case Teardown

Connect to UE PC
    [Arguments]    ${ue_id}=${0}    ${alias}=cpc
    csn.Connect to    hostname=${tl.ues[${ue_id}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_id}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_id}].ssh_connection_details.password}
    ...    alias=${alias}

Check UE Status after Reboot
    [Arguments]    ${alias}=cpc    ${sleep_time}=5s    ${serial_number}=0123456789ABCDEF
    csn.send_command    command=adb devices    connection=${alias}    timeout=5
    Sleep    ${sleep_time}
    ${result}    csn.read output    connection=${alias}
    Should contain    ${result}    ${serial_number}

ADB Reboot UE and Clean ELT Temp Path
    [Arguments]      ${serial_number}=0123456789ABCDEF    ${ue_id}=${0}    ${clean_path}=${elt_temp_fold}
    Connect to UE PC
    csn.execute    command=adb -s ${serial_number} reboot    connection=cpc
    wait until keyword succeeds    2 min    10s    Check UE Status after Reboot
    csn.execute    command=rm -rf ${clean_path}*    connection=cpc
    [Teardown]  csn.disconnect    connection=cpc

Save Snapshot If Case Failed
    Run keyword And Ignore Error    Empty Directory    path=${LOG_PATH}
	Run keyword And Ignore Error    Run Keyword If Test Failed    COAM Save snapshot via rest api
	...    connection=COAM    log_path=${LOG_PATH}

Start 2CC ULDL traffic
    [Arguments]  ${tp_direction}=both
    log to console      \n Start 2CC ULDL traffic
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    power_ue.Start traffic    ue_index=${0}
    ...    direction=ul    throughput=200M    duration=1400    ue_type=${ue_type}    protocol=udp
    sleep    2s
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'   power_ue.Start traffic    ue_index=${0}
    ...     direction=dl    throughput=1500M    duration=1400    ue_type=${ue_type}     protocol=udp
    sleep    10s

Check 2CC ULDL throughput
    [Arguments]    ${PCell}=${173326337}    ${SCell}=${173326338}
    log to console      \n Check 2CC ULDL throughput
    ${tput_log}    Run keyword and continue on failure    power_ue.Collect Tput
	...    ue_type=${ue_type}    duration=${2cc_duration}    filter=L2Lo
	${PCell}    create list    ${PCell}
	${SCell}    create list    ${SCell}
	${PCell_Tput}    Run keyword and continue on failure    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${tput_log}
	...    cells=${PCell}  ultarget_throughput=${ul_exp_PCell}    dltarget_throughput=${dl_exp_PCell}
	${SCell_Tput}    Run keyword and continue on failure    power_ue.Check Bi Tput    ue_type=${ue_type}    log=${tput_log}
	...    cells=${SCell}  ultarget_throughput=${ul_exp_SCell}    dltarget_throughput=${dl_exp_SCell}

Check 2CC UL throughput
    [Arguments]    ${PCell}=${173326337}    ${SCell}=${173326338}
    log to console      \n Check 2CC UL throughput
    ${tput_log}    Run keyword and continue on failure    power_ue.Collect Tput
	...    ue_type=${ue_type}    duration=${2cc_duration}    filter=L2Lo
	${PCell}    create list    ${PCell}
	${SCell}    create list    ${SCell}
	${PCell_Tput}    Run keyword and continue on failure    power_ue.Check Tput    ue_type=${ue_type}    direction=ul
    ...     target_throughput=${ul_exp_PCell}    cells=${PCell}    log=${tput_log}
	${SCell_Tput}    Run keyword and continue on failure    power_ue.Check Tput    ue_type=${ue_type}    direction=ul
    ...     target_throughput=${ul_exp_SCell}    cells=${SCell}    log=${tput_log}

Stop 2CC traffic
    [Arguments]  ${tp_direction}=both
    log to console      \n Stop 2CC traffic
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    power_ue.Stop traffic    direction=ul
    ...    ue_index=${0}    ue_type=${ue_type}    protocol=udp
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'      power_ue.Stop traffic    direction=dl
    ...     ue_index=${0}    ue_type=${ue_type}    protocol=udp

Check the PM counters should be greater than 1
    [Arguments]    ${counter_id}    ${dic_path}    ${gnb_index}=${0}
    ...    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ${counter_lenth}    Get Length    ${counter_id}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
    FOR    ${index}    IN RANGE    ${counter_lenth}
        ${counter_value} =    get_pm_counter_values    counter_id=${counter_id[${index}]}    connection=GNB_OAM
         ...    dic_path=${dic_path[${index}]}
        Should Be True    ${counter_value[0]} > 1
    END
    [Teardown]    COAM Teardown gnb connections

Check the PM counters should be value
    [Arguments]    ${counter_id}    ${dic_path}    ${value}    ${gnb_index}=${0}
    ...    ${bts_host}=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].cu.oam_http_connection_details.password}
    ${counter_lenth}    Get Length    ${counter_id}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${username}    password=${password}
    FOR    ${index}    IN RANGE    ${counter_lenth}
        ${counter_value} =    get_pm_counter_values    counter_id=${counter_id[${index}]}    connection=GNB_OAM
         ...    dic_path=${dic_path[${index}]}
        Should Be True    "${counter_value[0]}" == "${value}"
    END
    [Teardown]    COAM Teardown gnb connections

Check unexpected alarm and fail case
    @{unexpected_fault}    Create List    ${10}    ${6450}    ${1806}    ${4341}    ${4352}    ${4383}
    ${active_alarms}    coam.get_active_alarms    connection=COAM
    FOR   ${active_alarm}    IN   @{active_alarms}
            ${roll}    run keyword and return status    Collections.List Should not Contain Value
            ...    ${unexpected_fault}    ${active_alarm['faultId']}
            run keyword if    not ${roll}
            ...    Fail    msg=Fault ${active_alarm['faultId']} is unexpected, case failed!!!!!
    END
	