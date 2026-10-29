# *** Settings ***
# Documentation
# ...               author: Steven Liu
# ...               contact: steven.liu@nokia-sbell.com
# ...               squad group: MMW_SG_04
# 
# Force Tags    SBTS00    RAN_5G    RAN_5G_TDD    CRT_UTE    CLOUD_5G_CLASSICAL_ANDROID_SA_ASIBL_ABILB1_2xAWHHF    STATE_SW_UPLOADED
# ...    PY36
# 
# Suite Setup       CI_interface.Common Suite Setup
# Suite Teardown
# Resource          ./resource/FGCR_8000_common_keyword.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BW_common_case/lib/BW_step_keywords.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
# Resource          ../../../RRM/RAN_PZ_HAZ_34/5GC001937_OTA/resources/5GC001937_keywords.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# 
# *** Variables ***
# ${server_port_ul_hon}       ${tl.ues[1].iperf_details.ports[0]}
# ${server_port_dl_hon}       ${tl.ues[1].iperf_details.ports[1]}
# ${MRBTS_ID}           ${tl.gnbs[0].instance_id}
# ${GNSSmode}           MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/GNSSE-1
# ${server_port}        ${tl.ues[1].iperf_details.port}
# ${server_ip}          ${tl.ues[1].iperf_details.network_interface_address}
# ${ul_throughput1}     100M
# ${dl_throughput1}     2048M
# ${ul_peak_50M}        23
# ${dl_peak_50M}        465
# ${ul_peak_90M}        42
# ${dl_peak_90M}        855
# ${scf_800_50M}       SCF_0_800_DU_50M.xml
# ${scf_800_90M}       SCF_0_800_DU_90M.xml
# ${scf_9999_50M}      SCF_SBTS00_50M.xml
# ${scf_9999_90M}      SCF_SBTS00_90M.xml
# 
# *** Test Cases ***
# [1]FGCR8000_001_SA_L3call_with_AWHHF_bandwidth_50MHz
#     [Tags]    CRT_TRUNK    CRT_21A    CRT_22R1    CRT_22R2    CRT_21B
#     [Setup]
#     Input default SCF     scf_800=${scf_800_50M}     scf_999=${scf_9999_50M}
#     Make Up Peak and Down Peak    ul_peak=${ul_peak_50M}    dl_peak=${dl_peak_50M}
#     ...    ul_throughput=${ul_throughput1}    dl_throughput=${dl_throughput1}
#     [Teardown]    Case Teardown
# 
# [1]FGCR8000_002_SA_L3call_with_AWHHF_bandwidth_90MHz
#     [Tags]    CRT_TRUNK    CRT_21A    CRT_22R1    CRT_22R2    CRT_21B
#     [Setup]
#     Input default SCF     scf_800=${scf_800_90M}     scf_999=${scf_9999_90M}
#     Make Up Peak and Down Peak    ul_peak=${ul_peak_90M}    dl_peak=${dl_peak_90M}
#     ...    ul_throughput=${ul_throughput1}    dl_throughput=${dl_throughput1}
#     [Teardown]    Case Teardown
# 
# *** Keywords ***
# Case Teardown
#     run keyword and ignore error    power_ue.UE Detach    ue_type=huawei
#     CI_interface.Common Case Teardown
# 
# Make Up Peak and Down Peak
#     [Arguments]    ${ul_peak}    ${dl_peak}    ${ul_throughput}    ${dl_throughput}
#     honor attach
#     UE start traffic hon       ue_index=${0}    tp_direction=ul    time=100s
#     ...    ul_throughput=${ul_throughput}    dl_throughput=${dl_throughput1}    ue_type=huawei
#     ...    iperf_port_ul=${server_port_ul_hon}    iperf_port_dl=${server_port_dl_hon}
#     run keyword and continue on failure    power_ue.Check throughput
#     ...    ue_type=huawei    direction=ul    throughput=${ul_peak}     cellid=11468801
#     power_ue.Stop traffic    ue_type=huawei    direction=ul    iperf_type=via_command
#     UE start traffic hon       ue_index=${0}    tp_direction=dl    time=100s
#     ...    ul_throughput=${ul_throughput}    dl_throughput=${dl_throughput1}    ue_type=huawei
#     ...    iperf_port_ul=${server_port_ul_hon}    iperf_port_dl=${server_port_dl_hon}
#     run keyword and continue on failure    power_ue.Check throughput
#     ...    ue_type=huawei    direction=dl    throughput=${dl_peak}     cellid=11468801
#     power_ue.Stop traffic    ue_type=huawei    direction=dl    iperf_type=via_command
#     UE start traffic hon       ue_index=${0}    tp_direction=both    time=100s
#     ...    ul_throughput=${ul_throughput}    dl_throughput=${dl_throughput1}    ue_type=huawei
#     ...    iperf_port_ul=${server_port_ul_hon}    iperf_port_dl=${server_port_dl_hon}
#     run keyword and continue on failure    power_ue.Check throughput
#     ...    ue_type=huawei    direction=ul    throughput=${ul_peak}     cellid=11468801
#     run keyword and continue on failure    power_ue.Check throughput
#     ...    ue_type=huawei    direction=dl    throughput=${dl_peak}     cellid=11468801
#     power_ue.Stop traffic    ue_type=huawei    direction=both    iperf_type=via_command
# 
# UE start traffic hon
#     [Documentation]    used for UE start traffic, ul/dl/both.
#     [Arguments]    ${ue_index}=${0}    ${protocol}=udp    ${tp_direction}=both    ${duration}=2000    ${iperf_type}=via_command
#     ...    ${ul_throughput}=100M    ${dl_throughput}=2048M    ${time}=2s    ${ue_type}=huawei
#     ...    ${iperf_port_ul}=default    ${iperf_port_dl}=default
#     Run keyword if    '${tp_direction}'=='ul' or '${tp_direction}'=='both'    Start traffic hon    ue_index=${ue_index}
#     ...    direction=ul    throughput=${ul_throughput}    duration=${duration}    ue_type=${ue_type}    iperf_type=${iperf_type}
#     ...    protocol=${protocol}    iperf_port=${iperf_port_ul}
#     sleep    1s
#     Run keyword if    '${tp_direction}'=='dl' or '${tp_direction}'=='both'   Start traffic hon    ue_index=${ue_index}
#     ...     direction=dl    throughput=${dl_throughput}    duration=${duration}    ue_type=${ue_type}    protocol=${protocol}
#     ...    iperf_port=${iperf_port_dl}
#     sleep    ${time}
# 
# Start traffic hon
#     [Arguments]    ${direction}    ${duration}   ${throughput}    ${iperf_port}=default
#     ...            ${ue_index}=${0}    ${interval}=1    ${buffer_size}=1024B    ${protocol}=udp
#     ...            &{kwargs}
#     [Documentation]    Start data transfer for L3 call test.
#     ...  :param  direction: The traffic direction, ul or dl.
#     ...  :param  duration: Duration of traffic
#     ...  :param  throughput: Throughput of new data transfer
#     ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for traffic
#     ${default_port}    set variable if    '${direction}'=='ul'    ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
#     ...                                                           ${tl.ues[${ue_index}].iperf_details.port}
#     ${port}    set variable if   '${iperf_port}' == 'default'    ${default_port}    ${iperf_port}
#     run keyword if    '${direction}' == 'dl'    Start DL traffic and check the TP on EPC hon    ue_index=${ue_index}
#     ...                                                                                     time=${duration}
#     ...                                                                                     interval=${interval}
#     ...                                                                                     traffic=${throughput}
#     ...                                                                                     buffer_size=${buffer_size}
#     ...                                                                                     iperf_port=${port}
#     ...                                                                                     protocol=${protocol}
#     ...    ELSE IF    '${direction}' == 'ul'    Start UL traffic and check the TP on Commercial hon    time=${duration}
#     ...                                                                                            traffic=${throughput}
#     ...                                                                                            ue_index=${ue_index}
#     ...                                                                                            iperf_port=${port}
#     ...                                                                                            protocol=${protocol}
# 
# Start UL traffic and check the TP on Commercial hon
#     [Arguments]    ${time}=10    ${traffic}=10.00M    ${ue_index}=${0}    ${iperf_port}=${tl.appserver.iperf_details.port}    ${retry}=${3}
#     ...    ${iperf_type}=via_app    ${protocol}=udp    ${data_amount}=data_amount    ${buffer_size}=1024B
#     run keyword if    '${iperf_type}'=='via_app'    Start UL UDP traffic via iperf app     time=${time}    traffic=${traffic}
#     ...    iperf_port=${iperf_port}    ue_index=${ue_index}
#     ...    ELSE    Start UL traffic via iperf command hon    time=${time}    traffic=${traffic}
#     ...    UL_port=${iperf_port}    ue_index=${ue_index}    protocol=${protocol}     data_amount=${data_amount}    buffer_size=${buffer_size}
# 
# Start UL traffic via iperf command hon
#     [Arguments]    ${time}=10    ${traffic}=10.00M    ${ue_index}=${0}    ${UL_port}=${tl.appserver.iperf_details.port}
#     ...    ${protocol}=udp      ${data_amount}=data_amount    ${buffer_size}=1024B
#     run keyword if    '${protocol}'=='udp'    Start UL UDP traffic via iperf command hon    time=${time}    traffic=${traffic}
#     ...    UL_port=${UL_port}    ue_index=${ue_index}    buffer_size=${buffer_size}
#     ...    ELSE    Start UL TCP traffic via iperf command    time=${time}    traffic=${traffic}
#     ...    UL_port=${UL_port}    ue_index=${ue_index}     data_amount=${data_amount}    buffer_size=${buffer_size}
# 
# Start DL traffic and check the TP on EPC hon
#     [Documentation]    stat DL traffic
#     ...    :param  ue_index: The list index from tl.ues[]
#     ...    :param  time: Duration of traffic
#     ...    :param  interval: common which to get UE IP
#     ...    :param  traffic: Throughput of new data transfer
#     ...    :param  buffer_size: buffer size of new data transfer
#     ...    :param  protocal: Traffic protocal type. E.G udp/tcp
#     [Arguments]    ${ue_index}=${0}    ${time}=10    ${iperf_port}=${tl.ues[${ue_index}].iperf_details.port}
#     ...            ${interval}=1    ${traffic}=10.00M    ${buffer_size}=1024B    ${protocol}=udp
#     run keyword if    '${protocol}'=='udp'        Start DL traffic and check the TP on EPC with hon    ue_index=${ue_index}
#     ...                                                       time=${time}
#     ...                                                       interval=${interval}
#     ...                                                       traffic=${traffic}
#     ...                                                       buffer_size=${buffer_size}
#     ...                                                       DL_port=${iperf_port}
# 
# Start DL traffic and check the TP on EPC with hon
#     [Arguments]    ${Home_button}=${Home_button}    ${swipe}=${swipe}
#     ...            ${open_iperf_location}=${open_iperf_location}
#     ...            ${ue_index}=${0}    ${DL_port}=${tl.ues[${ue_index}].iperf_details.port}    ${time}=10
#     ...            ${interval}=1    ${traffic}=10.00M    ${buffer_size}=1024B    ${iperf_button}=${iperf_button}
#     Get Commercial UE IP    ue_index=${ue_index}
#     wait until keyword succeeds    1 min    10 sec    Connect to EPC APP    ue_index=${ue_index}
#     sleep   2s
#     csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${DL_port}| awk '{print $2}' |xargs kill -9    connection=EPCAPP
#     csn.send_command
#     ...    command=iperf -c ${UE_IP} -u -t ${time} -i ${interval} -p ${DL_port} -P 3 -b ${traffic}
#     ...    connection=EPCAPP
# 
# Start UL UDP traffic via iperf command hon
#     [Arguments]    ${EPC_IP}=${tl.appserver.iperf_details.network_interface_address}
#     ...    ${UL_port}=${tl.appserver.iperf_details.port}    ${buffer_size}=1024B    ${interval}=1    ${ue_index}=${0}
#     ...    ${time}=10    ${serial_number}=${tl.ues[${ue_index}].serial_number}
#     ...    ${traffic}=10.00M    ${window_size}=2M
#     sleep   2s
#     Connect to control pc via cygwin    ue_index=${ue_index}
#     csn.send_command    command=adb -s ${serial_number} root &
#     ...    connection=cygwin
#     csn.send_command    command=adb -s ${serial_number} shell ps -ef | grep iperf |grep ${UL_port} |grep -v grep |awk '{print $2}'
#     ...    connection=cygwin
#     ${pid}    wait until keyword succeeds    10s    1s    csn.Read Output    connection=cygwin
#     csn.send_command    command=adb -s ${serial_number} shell kill -9 ${pid} &
#     ...    connection=cygwin
#     sleep    2s
#     ${cmd}=    catenate    adb -s ${serial_number} shell /data/local/tmp/iperf -c ${EPC_IP} -u -p ${UL_port}
#     ...    -t ${time} -P 1 -i 1 -b ${traffic}
#     csn.send_command    command=${cmd}
#     ...    connection=cygwin
#     csn.send_command    command=adb -s ${serial_number} shell ps -ef |grep iperf |grep ${UL_port} |grep -v grep |awk '{print $2}'
#     ...    connection=cygwin
#     ${pid}    wait until keyword succeeds    10s    1s    csn.Read Output    connection=cygwin
#     log to console    .....UE_${ue_index} udp ul iperf start....
#     [Teardown]    csn.disconnect      connection=cygwin
