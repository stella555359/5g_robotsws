*** Settings ***
Documentation
...               author: Steven Liu
...               contact: steven.liu@nokia-sbell.com
...               squad group: MMW_SG_04
Library           taf.sbts.oam.coam.admin    WITH NAME    coam
Library           taf.hw.optical_switch    WITH NAME    fiberswitch
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Commercial_mobile_phone_adb_common_keywords.robot
#Resource          ../../../../../resources/sites/Ulm/Common/connect.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/aasyslog.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Throughput_checking_from_GNB.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/rrm_log_check.robot

*** Variables ***
${MRBTS_ID}            ${tl.gnbs[0].instance_id}
${DU_IP}               ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${WEBEM_USERNAME}      ${tl.gnbs[0].cu.oam_http_connection_details.username}
${WEBEM_PASSWORD}      ${tl.gnbs[0].cu.oam_http_connection_details.password}


*** Keywords ***
Connect to DU
    [Arguments]    ${alias}=cOAM_admin
    ${conn}=    coam.connect_to
    ...    bts_host=${DU_IP}
    ...    username=${WEBEM_USERNAME}
    ...    password=${WEBEM_PASSWORD}
    ...    name=${alias}
    [Return]    ${conn}

Disconnect from DU
    [Arguments]    ${alias}=cOAM_admin
    coam.teardown     connection=${alias}

Modify SCFfile and Commissioning
    [Documentation]    used for update scf or modify parameter with scf commission.
    [Arguments]    ${PARAMS_TO_MODIFY_SCF}    ${default_scf}=${MIMO_default_scf}
    ${new_scf_file}    COAM Modify scf file    scf_file_path=${default_scf}    scf_parameters_list=${PARAMS_TO_MODIFY_SCF}
    Connect to gnb coam via ssl
    COAM Commission with scf file    scf_file_path=${new_scf_file}    timeout=600    is_pdl_checking_needed=${False}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections

Delete object
    [Arguments]    ${objName}
    Connect to gnb coam via ssl
    @{emptyList}     create list
    ${status}=       coam.perform_object_recommissioning    dist_name=${objName}
    ...                                                          parameter=@{emptyList}
    ...                                                          operation=delete
    ...                                                          skip_parameter_relation_errors=${True}
    ...                                                          connection=GNB_OAM
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections

honor attach
    [Arguments]    ${ue_index}=${0}    ${ue_type}=huawei
    Log To Console    honor attach
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    ${5Grach_ed0}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
    Log To Console    Verify attach
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed0}    4G_check=False    ue_index=${ue_index}

samsung attach
    [Arguments]    ${ue_index}=${2}    ${ue_type}=samsung
    Log To Console    samsung attach
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    ${5Grach_ed1}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
    Log To Console    Verify attach
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed1}    4G_check=False    ue_index=${ue_index}

UE check throughput
    [Arguments]    ${tp_direction}    ${exp_ul}=50    ${exp_dl}=220    ${cell_id}=${1}    ${gnb_index}=0    ${du_index}=0
    log to console    Check throughput
    AAsys log captrue    gnb_index=${gnb_index}    du_index=${du_index}
    ...    sleep_time=120s
    ${all_tp}    Get ul and dl peak and ave and min throughput and return result    cell_id=${cell_id}
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'    Run keyword and continue on failure
    ...      should be true    ${all_tp[0]}>${exp_dl}
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'    Run keyword and continue on failure
    ...      should not be equal as strings    ${all_tp[2]}    0.0
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    Run keyword and continue on failure
    ...      should be true    ${all_tp[3]}>${exp_ul}
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    Run keyword and continue on failure
    ...      should not be equal as strings    ${all_tp[5]}    0.0

UE start traffic
    [Documentation]    used for UE start traffic, ul/dl/both.
    [Arguments]    ${ue_index}=${0}    ${protocol}=udp    ${tp_direction}=both    ${duration}=2000    ${iperf_type}=via_command
    ...    ${ul_throughput}=100M    ${dl_throughput}=2048M    ${time}=2s    ${ue_type}=huawei
    ...    ${iperf_port_ul}=default    ${iperf_port_dl}=default
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    power_ue.Start traffic    ue_index=${ue_index}
    ...    direction=ul    throughput=${ul_throughput}    duration=${duration}    ue_type=${ue_type}    iperf_type=${iperf_type}
    ...    protocol=${protocol}    iperf_port=${iperf_port_ul}
    sleep    1s
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'   power_ue.Start traffic    ue_index=${ue_index}
    ...     direction=dl    throughput=${dl_throughput}    duration=${duration}    ue_type=${ue_type}    protocol=${protocol}
    ...    iperf_port=${iperf_port_dl}
    sleep    ${time}

UE start traffic sam
    [Documentation]    used for UE start traffic, ul/dl/both.
    [Arguments]    ${ue_index}=${0}    ${protocol}=udp    ${tp_direction}=both    ${duration}=2000    ${iperf_type}=via_command
    ...    ${ul_throughput}=100M    ${dl_throughput}=2048M    ${time}=2s    ${ue_type}=huawei
    ...    ${iperf_port_ul}=default    ${iperf_port_dl}=default
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    Start traffic sam    ue_index=${ue_index}
    ...    direction=ul    throughput=${ul_throughput}    duration=${duration}    ue_type=${ue_type}    iperf_type=${iperf_type}
    ...    protocol=${protocol}    iperf_port=${iperf_port_ul}
    sleep    1s
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'   Start traffic sam    ue_index=${ue_index}
    ...     direction=dl    throughput=${dl_throughput}    duration=${duration}    ue_type=${ue_type}    protocol=${protocol}
    ...    iperf_port=${iperf_port_dl}
    sleep    ${time}

Get ul and dl peak and ave and min throughput and return result
    [Documentation]    Get ul and dl peak and ave throughput and return result.
    ...    :param aasys_start_flag: for short time captrue use default, for long time call use ${False}, EG:${true}/${False}
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${cell_id}=${EMPTY}    ${cell_number}=1
#    ${cell_number}    Get cell numbers in gnb    gnb_index=${gnb_index}    du_index=${du_index}
#    ${cell_id}    Get nrcellid from aasys log    gnb_index=${gnb_index}    du_index=${du_index}
    ${dl_traffic_data}    ${ul_traffic_data}    Get traffic data from aasys log    gnb_index=${gnb_index}    du_index=${du_index}
    ...    cell_id=${cell_id}
    ${dl_peak_tp}    ${dl_average_tp}    ${dl_minimum_tp}    Calculate Throughput and retrun result in gnb    data=${dl_traffic_data}
    ...    cell_numbers=${cell_number}
    ${ul_peak_tp}    ${ul_average_tp}    ${ul_minimum_tp}    Calculate Throughput and retrun result in gnb    data=${ul_traffic_data}
    ...    cell_numbers=${cell_number}
    [Return]    ${dl_peak_tp}    ${dl_average_tp}    ${dl_minimum_tp}    ${ul_peak_tp}    ${ul_average_tp}    ${ul_minimum_tp}

Switch fiber channels and verify fiber channels status
    [Arguments]  ${cross_connection_setting}
    ...    ${vendor}=${tl.optical_switches[0].__class__.__name__}
    ...    ${model}=${tl.optical_switches[0].model}
    ...    ${addr}=${tl.optical_switches[0].addr}
    ...    ${port}=4001
    fiberswitch.setup_optical_switch    optical_switch=${vendor}    alias=switch1    model=${model}    addr=${addr}   port=${port}
    fiberswitch.get_optical_switch_channels    optical_switch_device=switch1
    fiberswitch.set_optical_switch_channels    settings=${cross_connection_setting}    optical_switch_device=switch1
    sleep      2s
    fiberswitch.get_optical_switch_channels    optical_switch_device=switch1
    [Teardown]    fiberswitch.teardown     optical_switch_device=switch1

UE Teardown
    run keyword and ignore error    Disconnect from DU
    run keyword and ignore error    power_ue.UE Detach    ue_type=huawei
    run keyword and ignore error    power_ue.UE Detach    ue_type=samsung
    CI_interface.Common Case Teardown

case teardown
    run keyword and continue on failure    UE Teardown

###########
UE start traffic hon
    [Documentation]    used for UE start traffic, ul/dl/both.
    [Arguments]    ${ue_index}=${0}    ${protocol}=udp    ${tp_direction}=both    ${duration}=2000    ${iperf_type}=via_command
    ...    ${ul_throughput}=100M    ${dl_throughput}=2048M    ${time}=2s    ${ue_type}=huawei
    ...    ${iperf_port_ul}=default    ${iperf_port_dl}=default
    Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    Start traffic hon    ue_index=${ue_index}
    ...    direction=ul    throughput=${ul_throughput}    duration=${duration}    ue_type=${ue_type}    iperf_type=${iperf_type}
    ...    protocol=${protocol}    iperf_port=${iperf_port_ul}
    sleep    1s
    Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'   Start traffic hon    ue_index=${ue_index}
    ...     direction=dl    throughput=${dl_throughput}    duration=${duration}    ue_type=${ue_type}    protocol=${protocol}
    ...    iperf_port=${iperf_port_dl}
    sleep    ${time}

Start traffic hon
    [Arguments]    ${direction}    ${duration}   ${throughput}    ${iperf_port}=default
    ...            ${ue_index}=${0}    ${interval}=1    ${buffer_size}=1024B    ${protocol}=udp
    ...            &{kwargs}
    [Documentation]    Start data transfer for L3 call test.
    ...  :param  direction: The traffic direction, ul or dl.
    ...  :param  duration: Duration of traffic
    ...  :param  throughput: Throughput of new data transfer
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for traffic
    ${default_port}    set variable if    '${direction}'=='ul'    ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
    ...                                                           ${tl.ues[${ue_index}].iperf_details.port}
    ${port}    set variable if   '${iperf_port}' == 'default'    ${default_port}    ${iperf_port}
    run keyword if    '${direction}' == 'dl'    Start DL traffic and check the TP on EPC hon    ue_index=${ue_index}
    ...                                                                                     time=${duration}
    ...                                                                                     interval=${interval}
    ...                                                                                     traffic=${throughput}
    ...                                                                                     buffer_size=${buffer_size}
    ...                                                                                     iperf_port=${port}
    ...                                                                                     protocol=${protocol}
    ...    ELSE IF    '${direction}' == 'ul'    Start UL traffic and check the TP on Commercial hon    time=${duration}
    ...                                                                                            traffic=${throughput}
    ...                                                                                            ue_index=${ue_index}
    ...                                                                                            iperf_port=${port}
    ...                                                                                            protocol=${protocol}

Start DL traffic and check the TP on EPC hon
    [Documentation]    stat DL traffic
    ...    :param  ue_index: The list index from tl.ues[]
    ...    :param  time: Duration of traffic
    ...    :param  interval: common which to get UE IP
    ...    :param  traffic: Throughput of new data transfer
    ...    :param  buffer_size: buffer size of new data transfer
    ...    :param  protocal: Traffic protocal type. E.G udp/tcp
    [Arguments]    ${ue_index}=${0}    ${time}=10    ${iperf_port}=${tl.ues[${ue_index}].iperf_details.port}
    ...            ${interval}=1    ${traffic}=10.00M    ${buffer_size}=1024B    ${protocol}=udp
    run keyword if    '${protocol}'=='udp'        Start DL traffic and check the TP on EPC with hon    ue_index=${ue_index}
    ...                                                       time=${time}
    ...                                                       interval=${interval}
    ...                                                       traffic=${traffic}
    ...                                                       buffer_size=${buffer_size}
    ...                                                       DL_port=${iperf_port}

Start DL traffic and check the TP on EPC with hon
    [Arguments]    ${Home_button}=${Home_button}    ${swipe}=${swipe}
    ...            ${open_iperf_location}=${open_iperf_location}
    ...            ${ue_index}=${0}    ${DL_port}=${tl.ues[${ue_index}].iperf_details.port}    ${time}=10
    ...            ${interval}=1    ${traffic}=10.00M    ${buffer_size}=1024B    ${iperf_button}=${iperf_button}
    Get Commercial UE IP    ue_index=${ue_index}
    wait until keyword succeeds    1 min    10 sec    Connect to EPC APP    ue_index=${ue_index}
    sleep   2s
    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${DL_port}| awk '{print $2}' |xargs kill -9    connection=EPCAPP
    csn.send_command
    ...    command=iperf -c ${UE_IP} -u -t ${time} -i ${interval} -p ${DL_port} -P 3 -b ${traffic}
    ...    connection=EPCAPP

Start UL traffic and check the TP on Commercial hon
    [Arguments]    ${time}=10    ${traffic}=10.00M    ${ue_index}=${0}    ${iperf_port}=${tl.appserver.iperf_details.port}    ${retry}=${3}
    ...    ${iperf_type}=via_app    ${protocol}=udp    ${data_amount}=data_amount    ${buffer_size}=1024B
    run keyword if    '${iperf_type}'=='via_app'    Start UL UDP traffic via iperf app     time=${time}    traffic=${traffic}
    ...    iperf_port=${iperf_port}    ue_index=${ue_index}
    ...    ELSE    Start UL traffic via iperf command hon    time=${time}    traffic=${traffic}
    ...    UL_port=${iperf_port}    ue_index=${ue_index}    protocol=${protocol}     data_amount=${data_amount}    buffer_size=${buffer_size}

Start UL traffic via iperf command hon
    [Arguments]    ${time}=10    ${traffic}=10.00M    ${ue_index}=${0}    ${UL_port}=${tl.appserver.iperf_details.port}
    ...    ${protocol}=udp      ${data_amount}=data_amount    ${buffer_size}=1024B
    run keyword if    '${protocol}'=='udp'    Start UL UDP traffic via iperf command hon    time=${time}    traffic=${traffic}
    ...    UL_port=${UL_port}    ue_index=${ue_index}    buffer_size=${buffer_size}
    ...    ELSE    Start UL TCP traffic via iperf command    time=${time}    traffic=${traffic}
    ...    UL_port=${UL_port}    ue_index=${ue_index}     data_amount=${data_amount}    buffer_size=${buffer_size}

Start UL UDP traffic via iperf command hon
    [Arguments]    ${EPC_IP}=${tl.appserver.iperf_details.network_interface_address}
    ...    ${UL_port}=${tl.appserver.iperf_details.port}    ${buffer_size}=1024B    ${interval}=1    ${ue_index}=${0}
    ...    ${time}=10    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...    ${traffic}=10.00M    ${window_size}=2M
    sleep   2s
    Connect to control pc via cygwin    ue_index=${ue_index}
    csn.send_command    command=adb -s ${serial_number} root &
    ...    connection=cygwin
    csn.send_command    command=adb -s ${serial_number} shell ps -ef | grep iperf |grep ${UL_port} |grep -v grep |awk '{print $2}'
    ...    connection=cygwin
    ${pid}    wait until keyword succeeds    10s    1s    csn.Read Output    connection=cygwin
    csn.send_command    command=adb -s ${serial_number} shell kill -9 ${pid} &
    ...    connection=cygwin
    sleep    2s
    ${cmd}=    catenate    adb -s ${serial_number} shell /data/local/tmp/iperf -c ${EPC_IP} -u -p ${UL_port}
    ...    -t ${time} -P 1 -i 1 -b ${traffic}
    csn.send_command    command=${cmd}
    ...    connection=cygwin
    csn.send_command    command=adb -s ${serial_number} shell ps -ef |grep iperf |grep ${UL_port} |grep -v grep |awk '{print $2}'
    ...    connection=cygwin
    ${pid}    wait until keyword succeeds    10s    1s    csn.Read Output    connection=cygwin
    log to console    .....UE_${ue_index} udp ul iperf start....
    [Teardown]    csn.disconnect      connection=cygwin

###########

Start traffic sam
    [Arguments]    ${direction}    ${duration}   ${throughput}    ${iperf_port}=default
    ...            ${ue_index}=${0}    ${interval}=1    ${buffer_size}=1024B    ${iperf_type}=via_app
    ...            ${protocol}=udp    ${data_amount}=1M    &{kwargs}
    [Documentation]    Start data transfer for L3 call test.
    ...  :param  direction: The traffic direction, ul or dl.
    ...  :param  duration: Duration of traffic
    ...  :param  throughput: Throughput of new data transfer
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for traffic
    ...  :param  protocal: Traffic protocal type. E.G udp/tcp
    ...  :param  iperf_type: Traffic use iperf command or iperf app type. E.G via_app/via_command
    ${default_port}    set variable if    '${direction}'=='ul'    ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
    ...                                                           ${tl.ues[${ue_index}].iperf_details.port}
    ${port}    set variable if   '${iperf_port}' == 'default'    ${default_port}    ${iperf_port}
    run keyword if    '${direction}' == 'dl'    Start DL traffic and check the TP on EPC sam    ue_index=${ue_index}
    ...                                                                                     time=${duration}
    ...                                                                                     interval=${interval}
    ...                                                                                     traffic=${throughput}
    ...                                                                                     buffer_size=${buffer_size}
    ...                                                                                     iperf_port=${port}
    ...                                                                                     protocol=${protocol}
    ...    ELSE IF    '${direction}' == 'ul'    Start UL traffic and check the TP on Commercial sam    time=${duration}
    ...                                                                                            traffic=${throughput}
    ...                                                                                            ue_index=${ue_index}
    ...                                                                                            iperf_port=${port}
    ...                                                                                            iperf_type=${iperf_type}
    ...                                                                                             protocol=${protocol}
    ...                                                                                             data_amount=${data_amount}
    ...                                                                                             buffer_size=${buffer_size}

Start DL traffic and check the TP on EPC sam
    [Documentation]    stat DL traffic
    ...    :param  ue_index: The list index from tl.ues[]
    ...    :param  time: Duration of traffic
    ...    :param  interval: common which to get UE IP
    ...    :param  traffic: Throughput of new data transfer
    ...    :param  buffer_size: buffer size of new data transfer
    ...    :param  protocal: Traffic protocal type. E.G udp/tcp
    [Arguments]    ${ue_index}=${0}    ${time}=10    ${iperf_port}=${tl.ues[${ue_index}].iperf_details.port}
    ...            ${interval}=1    ${traffic}=10.00M    ${buffer_size}=1024B    ${protocol}=udp
    run keyword if    '${protocol}'=='udp'        Start DL traffic and check the TP on EPC with sam    ue_index=${ue_index}
    ...                                                       time=${time}
    ...                                                       interval=${interval}
    ...                                                       traffic=${traffic}
    ...                                                       buffer_size=${buffer_size}
    ...                                                       DL_port=${iperf_port}

Start UL traffic and check the TP on Commercial sam
    [Arguments]    ${time}=10    ${traffic}=10.00M    ${ue_index}=${0}    ${iperf_port}=${tl.appserver.iperf_details.port}    ${retry}=${3}
    ...    ${iperf_type}=via_app    ${protocol}=udp    ${data_amount}=data_amount    ${buffer_size}=1024B
    run keyword if    '${iperf_type}'=='via_app'    Start UL UDP traffic via iperf app sam     time=${time}    traffic=${traffic}
    ...    iperf_port=${iperf_port}    ue_index=${ue_index}
    ...    ELSE    Start UL traffic via iperf command sam    time=${time}    traffic=${traffic}
    ...    UL_port=${iperf_port}    ue_index=${ue_index}    protocol=${protocol}     data_amount=${data_amount}    buffer_size=${buffer_size}

Start UL UDP traffic via iperf app sam
    [Arguments]    ${time}=10    ${traffic}=10.00M    ${ue_index}=${0}    ${iperf_port}=${tl.appserver.iperf_details.port}    ${retry}=${3}
    Connect to control pc via cygwin    ue_index=${ue_index}
    FOR   ${index}    IN RANGE    ${retry}
        ${iperf_status}    run keyword and return status    Start UL traffic and check the TP on Commercial with sam
    ...    time=${time}    traffic=${traffic}    UL_port=${iperf_port}    ue_index=${ue_index}
        exit for loop if   ${iperf_status}
    END
    should be true   ${iperf_status}   msg=Failed to start UL traffic after ${retry} retries.

Start UL traffic via iperf command sam
    [Arguments]    ${time}=10    ${traffic}=10.00M    ${ue_index}=${0}    ${UL_port}=${tl.appserver.iperf_details.port}
    ...    ${protocol}=udp      ${data_amount}=data_amount    ${buffer_size}=1024B
    run keyword if    '${protocol}'=='udp'    Start UL UDP traffic via iperf command sam     time=${time}    traffic=${traffic}
    ...    UL_port=${UL_port}    ue_index=${ue_index}    buffer_size=${buffer_size}
    ...    ELSE    Start UL TCP traffic via iperf command    time=${time}    traffic=${traffic}
    ...    UL_port=${UL_port}    ue_index=${ue_index}     data_amount=${data_amount}    buffer_size=${buffer_size}

Start UL UDP traffic via iperf command sam
    [Arguments]    ${EPC_IP}=${tl.appserver.iperf_details.network_interface_address}
    ...    ${UL_port}=${tl.appserver.iperf_details.port}    ${buffer_size}=1024B    ${interval}=1    ${ue_index}=${0}
    ...    ${time}=10    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...    ${traffic}=10.00M    ${window_size}=2M
    sleep   2s
    Connect to control pc via cygwin    ue_index=${ue_index}
    csn.send_command    command=adb -s ${serial_number} root &
    ...    connection=cygwin
    csn.send_command    command=adb -s ${serial_number} shell ps -ef | grep iperf |grep ${UL_port} |grep -v grep |awk '{print $2}'
    ...    connection=cygwin
    ${pid}    wait until keyword succeeds    10s    1s    csn.Read Output    connection=cygwin
    csn.send_command    command=adb -s ${serial_number} shell kill -9 ${pid} &
    ...    connection=cygwin
    sleep    2s
    ${cmd}=    catenate    adb -s ${serial_number} shell /data/local/tmp/iperf -c ${EPC_IP} -u -p ${UL_port}
    ...    -t ${time} -P 1 -i 1 -b ${traffic}
    csn.send_command    command=${cmd}
    ...    connection=cygwin
    csn.send_command    command=adb -s ${serial_number} shell ps -ef |grep iperf |grep ${UL_port} |grep -v grep |awk '{print $2}'
    ...    connection=cygwin
    ${pid}    wait until keyword succeeds    10s    1s    csn.Read Output    connection=cygwin
    log to console    .....UE_${ue_index} udp ul iperf start....
    [Teardown]    csn.disconnect      connection=cygwin

Start DL traffic and check the TP on EPC with sam
    [Arguments]    ${Home_button}=${Home_button}    ${swipe}=${swipe}
    ...            ${open_iperf_location}=${open_iperf_location}
    ...            ${ue_index}=${0}    ${DL_port}=${tl.ues[${ue_index}].iperf_details.port}    ${time}=10
    ...            ${interval}=1    ${traffic}=10.00M    ${buffer_size}=1024B    ${iperf_button}=${iperf_button}
    Get Commercial UE IP    ue_index=${ue_index}
    wait until keyword succeeds    1 min    10 sec    Connect to EPC APP    ue_index=${ue_index}
    sleep   2s
    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${DL_port}| awk '{print $2}' |xargs kill -9    connection=EPCAPP
    csn.send_command
    ...    command=iperf -c ${UE_IP} -u -t ${time} -i ${interval} -p ${DL_port} -P 3 -b ${traffic}
    ...    connection=EPCAPP

Start UL traffic and check the TP on Commercial with sam
    [Arguments]    ${Home_button}=${Home_button}    ${swipe}=${swipe}    ${open_iperf_location}=${open_iperf_location}
    ...    ${EPC_IP}=${tl.appserver.iperf_details.network_interface_address}
    ...    ${UL_port}=${tl.appserver.iperf_details.port}    ${buffer_size}=1024B    ${interval}=1    ${ue_index}=${0}
    ...    ${time}=10
    ...    ${traffic}=10.00M    ${iperf_button}=${iperf_button}   ${serial_number}=${tl.ues[${ue_index}].serial_number}
    sleep   2s
    #####Press the Home button to open the screen#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input keyevent ${Home_button}    connection=cygwin
    sleep   3s
    #####Swipe up to unlock the phone#####
    Run Keyword And Ignore Error    csn.send_command    command=adb -s ${serial_number} shell input swipe ${swipe}    connection=cygwin
    sleep   3s
    csn.send_command    command=adb -s ${serial_number} shell pm clear com.nextdoordeveloper.miperf.miperf    connection=cygwin
    sleep   3s
    csn.send_command
    ...    command=adb -s ${serial_number} shell am start -n com.nextdoordeveloper.miperf.miperf/com.nextdoordeveloper.miperf.miperf.MainActivity
    ...    connection=cygwin
    sleep    2s
    #####tap the spare space of magic iperf to focus on input line#####
    csn.send_command    command=adb -s ${serial_number} shell input tap ${iperf_space}    connection=cygwin
    sleep   2s
    FOR	 ${i}	IN RANGE	10
        csn.send_command    adb -s ${serial_number} shell input keyevent 67    connection=cygwin
        sleep    0.5
    END
    ${ul_cmd}    set variable
    ...  iperf\%s-c\%s${EPC_IP}\%s-u\%s-p\%s${UL_port}\%s-t\%s${time}\%s-i\%s1\%s-P\%s1\%s-b\%s${traffic}\%s
    csn.send_command    command=adb -s ${serial_number} shell input text ${ul_cmd}    connection=cygwin
    sleep   3s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${iperf_button}    connection=cygwin
    sleep   3s
    csn.send_command    command=adb -s ${serial_number} shell ps -ef | grep -w iperf| grep -v grep|awk '{print $2}'    connection=cygwin
    ${output}    csn.read_output    size=1000    connection=cygwin
    ${iperf_pid}    evaluate    ${output.strip()}
    should be true    ${iperf_pid} > ${0}
