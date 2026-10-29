*** Settings ***
Documentation    Author: Cui Lingxue
...              Description: Common keyword for throughput checking from iperf server side
...              Mainly focus on checking for single DRB for single UE

Library    Collections
Library    BuiltIn
Library    String
Library    ./lib/check_throughput_iperf.py
Library    robot.libraries.DateTime
Library     taf.transport.ssh    WITH NAME    ssh
Resource   ./data_process.robot

*** Variables ***
${IPERF_UL_PORT}    ${tl.appserver.iperf_details.port}

*** Keywords ***
Start tput checking via iperf for multiple ports
    [Documentation]    Author: Cui Lingxue  5G_PZ_MMW_HZ_1_SG
    ...    Description: start iperf server process to check throughput status on AppServer or UE.
    ...                 Multiple ports for signal UE on one direction will be checked.
    ...                 result of each port will be redirect to one file like /tmp/TPUT_UE${ue_id}_UL_port${iperf_ul_port}_${timestamp}
    ...    :param ${iperf_port_list}: can be signal port or a list contain multiple ports.
    ...    :param ${direction}: can be 'ul' or 'dl', other value will fail.
    ...    :param ${ue_id}: indicate which UE to check, starting from 1, ue_id=ue_index+1.
    ...    :return ${tput_file_list}: a list contain throughput result files on AppServer or UE, eg
    ...           [ /tmp/Tput_ue1_ul_p46824_20200911112343 | /tmp/Tput_ue1_ul_p47824_20200911112344 | /tmp/Tput_ue1_ul_p41824_20200911112344 ]
    [Arguments]    ${iperf_port_list}    ${direction}    ${ue_id}=${1}
    ${iperf_port_list}    Convert variable to list type    input_var=${iperf_port_list}
    ${tput_file_list}    create list
    FOR    ${port}    IN    @{iperf_port_list}
        ${tput_file}    run keyword if    '${direction}'=='ul'
        ...      wait until keyword succeeds    1 m    3 s
        ...      Start ul tput checking via iperf    iperf_ul_port=${port}    ue_id=${ue_id}
        ...    ELSE IF    '${direction}'=='dl'
        ...      wait until keyword succeeds    1 m    3 s
        ...      Start dl tput checking via iperf    ue_id=${ue_id}    iperf_dl_port=${port}
        ...    ELSE    fail    msg='${direction}' should be ul or dl, please use correct value.
        append_to_list    ${tput_file_list}    ${tput_file}
    END
    [Return]    ${tput_file_list}

Stop tput checking via iperf for multiple ports
    [Documentation]    Author: Cui Lingxue  5G_PZ_MMW_HZ_1_SG
    ...    Description: Kill and verify iperf server process to check throughput status on AppServer or UE.
    ...    :param ${iperf_port_list}: can be signal port or a list contain multiple ports.
    ...    :param ${direction}: can be 'ul' or 'dl', other value will fail.
    ...    :param ${ue_id}: indicate which UE to check, starting from 1, ue_id=ue_index+1.
    [Arguments]    ${iperf_port_list}    ${direction}    ${ue_id}=${1}
    ${iperf_port_list}    Convert variable to list type    input_var=${iperf_port_list}
    FOR    ${port}    IN    @{iperf_port_list}
        run keyword if    '${direction}'=='ul'
        ...      wait until keyword succeeds    2 m    3 s
        ...      Stop ul tput checking via iperf    iperf_ul_port=${port}
        ...    ELSE IF    '${direction}'=='dl'
        ...      wait until keyword succeeds    2 m    3 s
        ...      Stop dl tput checking via iperf    ue_id=${ue_id}    iperf_dl_port=${port}
        ...    ELSE    fail    msg='${direction}' should be ul or dl, please use correct value.
    END

Start ul tput checking via iperf
    [Documentation]    Author: Cui Lingxue  5G_PZ_MMW_HZ_1_SG
    ...    Description: start iperf server process to check UL throughput status on AppServer.
    ...                 Before starting checking, will check if there exist process, if yes, will kill existing process firstly.
    ...                 After starting iperf, will verify process is started.
    ...    :param ${iperf_ul_port}: defaul value is ${tl.appserver.iperf_details.port}
    ...    :param ${ue_id}: indicate which UE to check, starting from 1, ue_id=ue_index+1.
    ...    :return ${tput_file}: throughput result file on AppServer, eg  /tmp/Tput_ue1_ul_p46824_20200911112343
    [Arguments]    ${iperf_ul_port}=${IPERF_UL_PORT}    ${ue_id}=${1}
    log to console    Start to check ul tput for ue${ue_id}_port${iperf_ul_port}
    @{filter_conditions}    create list    iperf    ${iperf_ul_port}
    ${pid}    Check process existence on APPServer    filter_conditions=${filter_conditions}
    run keyword if    '${pid}'!='${EMPTY}'    Kill process on APPServer    pid=${pid}
    ${timestamp}    robot.libraries.DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${tput_file}    set variable    /tmp/TPUT_UE${ue_id}_UL_port${iperf_ul_port}_${timestamp}
    ssh.send_command    command=iperf -s -u -i 1 -w 2M -p ${iperf_ul_port} > ${tput_file} &    connection=EPCAPP
    sleep    200ms
    ${pid}    Check process existence on APPServer    filter_conditions=${filter_conditions}
    should not be empty    ${pid}
    [Return]    ${tput_file}

Stop ul tput checking via iperf
    [Documentation]    Author: Cui Lingxue  5G_PZ_MMW_HZ_1_SG
    ...    Description: Kill iperf server process to stop throughput checking on AppServer.
    ...    :param ${iperf_ul_port}: defaul value is ${tl.appserver.iperf_details.port}
    [Arguments]    ${iperf_ul_port}=${IPERF_UL_PORT}
    @{filter_conditions}    create list    iperf    ${iperf_ul_port}
    ${pid}    Check process existence on APPServer    filter_conditions=${filter_conditions}
    wait until keyword succeeds    5x    200ms    Kill process on APPServer    pid=${pid}

Start dl tput checking via iperf
    [Documentation]    Author: Cui Lingxue  5G_PZ_MMW_HZ_1_SG
    ...    Description: start iperf server process to check DL throughput status on UE, only androind UE is supported for now.
    ...                 Before starting checking, will check if there exist process, if yes, will kill existing process firstly.
    ...                 After starting iperf, will verify process is started.
    ...    :param ${ue_id}: indicate which UE to check, starting from 1, ue_id=ue_index+1.
    ...    :param ${iperf_dl_port}: defaul value is ${tl.ues[${ue_id}-1].iperf_details.port}
    ...    :param ${iperf_path}: give iperf path on UE, if leave empty, default path will be used.
    ...                          For samsung, /data/local/tmp/iperf; for qualcomm, /system/bin/iperf.
    ...    :param ${ue_type}: indicate UE type, huawei, samsung, or qct_dx50
    ...    :return ${tput_file}: throughput result file on UE, eg /tmp/Tput_ue1_dl_p46825_20200911112728
    [Arguments]    ${ue_id}=${1}    ${iperf_dl_port}=${tl.ues[${ue_id}-1].iperf_details.port}    ${iperf_path}=${None}    ${ue_type}=${UE_TYPE}
    ${iperf_path}   run keyword if    ${iperf_path}!=${None}                set variable    ${iperf_path}
    ...    ELSE IF    ${iperf_path}==${None} and '${ue_type}'=='samsung'    set variable    /data/local/tmp/iperf
    ...    ELSE IF    ${iperf_path}==${None} and '${ue_type}'=='qct_dx50'     set variable    /system/bin/iperf
    ...    ELSE       ${iperf_path}==${None}    fail  msg=iperf path is unknown,please specify

    log to console    Start to check dl tput for ue${ue_id}_port${iperf_dl_port}
    @{filter_conditions}    create list    iperf    ${iperf_dl_port}
    ${pid}    Check process existence on adb device    ue_id=${ue_id}    filter_conditions=${filter_conditions}
    run keyword if    '${pid}'!='${EMPTY}'    Kill process on APPServer    pid=${pid}
    ${serial_number}    set variable    ${tl.ues[${ue_id}-1].serial_number}
    ${timestamp}    robot.libraries.DateTime.Get Current Date    result_format=%Y%m%d%H%M%S
    ${tput_file}    set variable    /tmp/TPUT_UE${ue_id}_DL_port${iperf_dl_port}_${timestamp}
    ${cmd_iperf_server}    set variable if    '${ue_type}'=='samsung' or '${ue_type}'=='qct_dx50'
    ...    adb -s ${serial_number} shell ${iperf_path} -s -u -i 1 -w 2M -p ${iperf_dl_port} > ${tput_file} &
    ...    ${iperf_path} -s -u -i 1 -w 2M -p ${iperf_dl_port} > ${tput_file} &
    ssh.send_command    command=${cmd_iperf_server}    connection=cygwin
    ${pid}    Check process existence on adb device    ue_id=${ue_id}    filter_conditions=${filter_conditions}
    should not be empty    ${pid}
    [Return]    ${tput_file}

Stop dl tput checking via iperf
    [Documentation]    Author: Cui Lingxue
    ...    Stop checking for dl throughput
    [Arguments]    ${ue_id}=${1}    ${iperf_dl_port}=${tl.ues[${ue_id}-1].iperf_details.port}
    ${serial_number}    set variable    ${tl.ues[${ue_id}-1].serial_number}
    @{filter_conditions}    create list    iperf    ${iperf_dl_port}
    ${pid}    Check process existence on adb device    ue_id=${ue_id}    filter_conditions=${filter_conditions}
    wait until keyword succeeds    5x    200ms    Kill process on adb device   ue_id=${ue_id}    pid=${pid}

Download tput files to test pc
    [Documentation]    Author: Cui Lingxue
    ...    Download a list of tput files from control PC or APP server.
    ...    :param  direction: ul or dl.
    ...    :param  tput_file_list: a list of tput files or singal tput file to be downloaded.
    ...    :param  ue_id: starting from 1, ue_id=ue_index+1
    ...    :param  local_tput_dir: directory path on testPC.
    ...    :return local_tput_file_list: path on testPC of downloaded files.
    [Arguments]    ${direction}    ${tput_file_list}    ${ue_id}=${1}    ${local_tput_dir}=${TS_CASE_LOG_PATH}
    ${tput_file_list}    Convert variable to list type    input_var=${tput_file_list}
    ${connection}    set_variable_if    '${direction}'=='ul'    EPCAPP    cygwin
    ${is_folder_exist}    run keyword and return status    directory_should_exist    path=${local_tput_dir}
    run keyword if    '${is_folder_exist}'=='False'    create_directory    path=${local_tput_dir}
    ssh.download_file    remote_path=${tput_file_list}    local_path=${local_tput_dir}    connection=${connection}

    @{local_tput_file_list}    create_list
    FOR    ${file}    IN    @{tput_file_list}
        ${file_name}    fetch_from_right    string=${file}    marker=/
        ${local_tput_file}    join_path    ${local_tput_dir}    ${file_name}
        append_to_list    ${local_tput_file_list}    ${local_tput_file}
    END

    FOR    ${file}    IN    @{tput_file_list}
        run keyword and continue on failure    ssh.send_command    command=rm -rf ${file}    connection=${connection}
    END
    [Return]    ${local_tput_file_list}

Check tput status and record to file
    [Documentation]    Author: Cui Lingxue
    ...    This keyword will collect tput info on ul or dl, save to file and download to test pc.
    ...    :param   iperf_port_list: a list contain iperf ul or dl ports for each DRB, eg,[5410 5411 5412]
    ...    :param   direction: ul or dl
    ...    :param   traffic_duration: how long will traffic last, unit second
    ...    :return: tput file path on test pc.
    [Arguments]    ${iperf_port_list}    ${direction}    ${ue_id}=${1}    ${traffic_duration}=${30}
    run keyword if    '${direction}'=='dl'    Connect to control pc via cygwin    ue_index=${${ue_id}-1}
    ...    ELSE    Connect to EPC APP
    @{tput_file_list}    Start tput checking via iperf for multiple ports
    ...    iperf_port_list=${iperf_port_list}    direction=${direction}    ue_id=${ue_id}
    sleep    ${traffic_duration}s
    Stop tput checking via iperf for multiple ports    iperf_port_list=${iperf_port_list}    direction=${direction}    ue_id=${ue_id}
    @{local_tput_file_list}    Download tput files to test pc    direction=${direction}    ue_id=${ue_id}    tput_file_list=${tput_file_list}
    [Return]    ${local_tput_file_list}

Check process existence on adb device
    [Documentation]    Author: Cui Lingxue
    ...    Check if process exist on adb device based on given conditions ${filter_conditions}.
    ...    :param ${filter_conditions}: one or several filters to find process id by command ps -ef. Eg ['iperf', '41412'].
    ...           The filters will be used in ps cmd as:
    ...           ps -ef | grep -v grep | grep ${filter_conditions[0]} | grep ${filter_conditions[1]} | grep ${filter_conditions[2]}
    ...    :return ${pid}: return pid of process, if process not exist, pid will be ${emtpy}.
    [Arguments]    ${filter_conditions}    ${ue_id}=${1}
    ${filter_conditions}    Convert variable to list type    input_var=${filter_conditions}
    ${filters}    set variable    ${EMPTY}
    FOR    ${condition}    IN    @{filter_conditions}
        ${filters}    set variable if    '${filters}'=='${EMPTY}'    ${condition}   ${filters}|grep ${condition}
    END
    ${serial_number}    set variable    ${tl.ues[${ue_id}-1].serial_number}
    ${cmd_check_process}    set variable    adb -s ${serial_number} shell ps -ef | grep -v gerp | grep ${filters} | awk '{print $2}'
    ssh.send_command    command=${cmd_check_process}    connection=cygwin
    ${pid}    ssh.read_output    connection=cygwin
    ${pid}    replace_string    string=${pid}   search_for=\n    replace_with=${SPACE}
    [Return]    ${pid}

Kill process on adb device
    [Documentation]    Author: Cui Lingxue
    ...    Kill process on adb device based on ${pid}.
    [Arguments]    ${pid}    ${ue_id}=${1}
    return from keyword if    '${pid}'=='${EMPTY}'
    ${serial_number}    set variable    ${tl.ues[${ue_id}-1].serial_number}
    ssh.send_command    command=adb -s ${serial_number} shell kill -9 ${pid}    connection=cygwin
    ssh.send_command    command=adb -s ${serial_number} shell ps ${pid} | grep -v -i pid | awk '{print $2}'    connection=cygwin
    ${pid}    ssh.read_output    connection=cygwin
    should be empty    ${pid}

Check process existence on APPServer
    [Documentation]    Author: Cui Lingxue
    ...    Check if process exist on APPServer based on given conditions ${filter_conditions}.
    ...    :param ${filter_conditions}: one or several filters to find process id by command ps -ef. Eg ['iperf', '41412'].
    ...           The filters will be used in ps cmd as:
    ...           ps -ef | grep -v grep | grep ${filter_conditions[0]} | grep ${filter_conditions[1]} | grep ${filter_conditions[2]}
    ...    :return ${pid}: return pid of process, if process not exist, pid will be ${emtpy}.
    [Arguments]    ${filter_conditions}
    ${filter_conditions}    Convert variable to list type    input_var=${filter_conditions}
    ${filters}    set variable    ${EMPTY}
    FOR    ${condition}    IN    @{filter_conditions}
        ${filters}    set variable if    '${filters}'=='${EMPTY}'    ${condition}   ${filters}|grep ${condition}
    END
    ${cmd_check_process}    set variable    ps -ef | grep -v gerp | grep ${filters} | awk '{print $2}'
    ssh.send_command    command=${cmd_check_process}    connection=EPCAPP
    ${pid}    ssh.read_output    connection=EPCAPP
    ${pid}    replace_string    string=${pid}   search_for=\n    replace_with=${SPACE}
    [Return]    ${pid}

Kill process on APPServer
    [Documentation]    Author: Cui Lingxue
    ...    Kill process on APPServer based on ${pid}.
    [Arguments]    ${pid}
    return from keyword if    '${pid}'=='${EMPTY}'
    ssh.send_command    command=kill -9 ${pid}    connection=EPCAPP
    ssh.send_command    command=ps ${pid} | grep -v -i pid | awk '{print $2}'    connection=EPCAPP
    ${pid}    ssh.read_output    connection=EPCAPP
    should be empty    ${pid}

Get tput info from file
    [Documentation]    Author: Cui Lingxue
    ...    :param ${tput_file_list}: a file or a list contain throughput result files on AppServer or UE, eg
    ...    [ /tmp/Tput_ue1_ul_p46824_20200911112343 | /tmp/Tput_ue1_ul_p47824_20200911112344 | /tmp/Tput_ue1_ul_p41824_20200911112344 ]
    ...    return: a dict contain ue tput info for each drb and total of all drbs on ul or dl direction.
    ...    example: {'UE1_UL': {'port71824': 23.6, 'total': 23.6}, 'UE1_DL': {'port71825': 129.93, 'total': 129.93}}
    [Arguments]    ${tput_file_list}
    ${tput_file_list}    Convert variable to list type    input_var=${tput_file_list}
    ${file_group_dict}    classify_tput_files_into_file_groups    tput_file_list=${tput_file_list}
    ${tput_group_dict}    calculate_tput_for_file_groups    file_group_dict=${file_group_dict}
    [Return]    ${tput_group_dict}

Check uplink and downlink tput status for specific UE
    [Documentation]    Author: Cui Lingxue
    ...    Check both uplink and downlink throughput for UE, write tput checking result to file, and get tput info from file.
    ...    :param ${dl_port_list}: can be signal port or a list contain multiple ports for downlink throughput.
    ...    :param ${ul_port_list}: can be signal port or a list contain multiple ports for uplink throughput.
    ...    :param ${traffic_duration}: check throughput for ${traffic_duration} seconds.
    ...    :param ${ue_id}: indicate which UE to check, starting from 1, ue_id=ue_index+1.
    ...    :return: a dict contain ue tput info for each drb and total of all drbs on ul or dl direction.
    ...           example: {'UE1_UL': {'port71824': 23.6, 'total': 23.6}, 'UE1_DL': {'port71825': 129.93, 'total': 129.93}}
    [Arguments]    ${dl_port_list}    ${ul_port_list}    ${traffic_duration}=${30}    ${ue_id}=${1}
    ${tput_file_dl}    Check tput status and record to file
    ...    iperf_port_list=${dl_port_list}    direction=dl    ue_id=${ue_id}    traffic_duration=${traffic_duration}
    ${tput_file_ul}    Check tput status and record to file
    ...    iperf_port_list=${ul_port_list}    direction=ul    ue_id=${ue_id}    traffic_duration=${traffic_duration}
    ${tput_file_list}    combine lists    ${tput_file_dl}    ${tput_file_ul}
    ${ue_tput_dict}    Get tput info from file    tput_file_list=${tput_file_list}
    [Return]    ${ue_tput_dict}

Check tput status via iperf
    [Documentation]    Author: Cui Lingxue
    ...    Will check throughput via iperf for specified ${direction} for ${traffic_duration} seconds.
    ...    :param ${iperf_port_list}: can be signal port or a list contain multiple ports.
    ...    :param ${ue_id}: indicate which UE to check, starting from 1, ue_id=ue_index+1.
    ...    :return: a dict contain ue tput info for each drb and total of all drbs on ul or dl direction.
    ...           example: {'UE1_UL': {'port71824': 23.6, 'total': 23.6}, 'UE1_DL': {'port71825': 129.93, 'total': 129.93}}
    [Arguments]    ${iperf_port_list}    ${direction}    ${traffic_duration}=${30}    ${ue_id}=${1}
    ${tput_files}    Check tput status and record to file
    ...    iperf_port_list=${iperf_port_list}    direction=${direction}    ue_id=${ue_id}    traffic_duration=${traffic_duration}
    ${ue_tput_dict}    Get tput info from file    tput_file_list=${tput_files}
    [Return]    ${ue_tput_dict}



