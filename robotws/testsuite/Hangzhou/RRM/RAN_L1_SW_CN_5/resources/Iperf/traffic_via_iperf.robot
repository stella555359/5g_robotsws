*** Settings ***
Documentation    This iperf common keyword, contain the DL UL data start and data check in gnb L2L0 and end to end side online check.
...              support to Multi andriod UE data transfer also.
...              Please do not modify the file without notification to author
...              Author: Andy Cheng
...              Contact: huimin.1.cheng@nokia-sbell.com
...              Squard: HZ SG3
Resource         ../UE/android_common_keyword.robot
Resource         taf/rfrl/common_resources/robot/stream_manager.robot
Library          taf.rfrl.common_resources.python.gNB_l2_lo_throughput

*** Variables ***
${appserver}    1.1.1.1

*** Keywords ***
Caculate UL throughput on gnb L2Lo
    [Documentation]  This keyword check the UL throughput in gnb l2lo and compare with expect value.
    [Arguments]     ${ul_expect}    ${du_index}=${0}    ${hw_slot}=${1}
    ${res} =    Feature 1514 Enabled
    run keyword if    ${res}==${False}    Connect to Capacity Unit Master    du_index=${du_index}   hw_slot=${hw_slot}    alias=aspa
    ...    ELSE IF    ${res}==${True}    Connect to Capacity Unit Slave    du_index=${du_index}   hw_slot=${hw_slot}    alias=aspa
    ${ul_tp_l2lo} =    Calculate UL throughoutput    alias=aspa
    should be true    ${ul_tp_l2lo} > ${ul_expect}
    [Teardown]    RUN KEYWORDS    run keyword and ignore error  csn.disconnect    connection=aspa    AND
    ...                           run keyword and ignore error  csn.disconnect    connection=ASIK Master

Caculate UL throughput on gnb L2Lo with re
    [Documentation]  This keyword check the UL throughput in gnb l2lo and compare with expect value.
    ...  :param  ul_expect: the expect minimum throughput for ul caculate.
    ...  :param  du_index: this du index can distinguish left or right of AMIA, 0 meas left, 1 means right
    ...  :param  hw_slot: abil index, In left of AMIA support slot 1, 2, 3. In right of AMIA support slot 5, 6, 7.
    ...  :param  sample: how many sample cut in l2lo for average caculate.
    ...  :param  start_offset: start from which line to caculate the throughput.
    [Arguments]     ${ul_expect}=${0}    ${gnb_index}=${0}    ${du_index}=${0}    ${hw_slot}=${1}    ${sample}=${60}
    ...    ${start_offset}=${5}    ${sleep_time}=${15}    ${cellid}=${EMPTY}    ${log_type}=journallog
    ...    ${host}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    run keyword if    '${log_type}'=='journallog'    Connect to Capacity Unit Master
    ...               du_index=${du_index}    hw_slot=${hw_slot}    alias=aspa_l2lo
    ...    ELSE IF    '${log_type}'=='Aasyslog'    csn.connect_to
    ...               hostname=${host}   username=${username}    password=${password}    alias=aspa_l2lo
    ${ul_tp_l2lo} =    Calculate UL throughoutput re    alias=aspa_l2lo    sample=${sample}
    ...    start_offset=${start_offset}    sleep_time=${sleep_time}    cellid=${cellid}    log_type=${log_type}
    Should Be True    ${ul_tp_l2lo} > ${ul_expect}    [ERROR]UL TP is NOT on Target: | UL_TP_L2Lo: ${ul_tp_l2lo} | ULTP_Expected: ${ul_expect} |.
    Log To Console    \n[INFO]UL TP is on Target: | UL_TP_L2Lo: ${ul_tp_l2lo} | ULTP_Expected: ${ul_expect} |
    [Return]    ${ul_tp_l2lo}
    [Teardown]    RUN KEYWORDS    run keyword and ignore error  csn.disconnect    connection=aspa    AND
    ...                           run keyword and ignore error  csn.disconnect    connection=ASIK Master

Calculate the E2E Appserver side UL TP
    [Documentation]  This keyword check the throughput in end Appserver side and compare with expect value.
    [Arguments]    ${ul_expect}    ${ul_port}
    traffic_via_iperf.Connect to APPserver
    ${ul_tp} =    calculate_e2e_throughput    alias=APPserver    port=${ul_port}    iperf_path=iperf
    should be true    ${ul_tp} > ${ul_expect}
    [Teardown]    csn.disconnect    connection=APPserver

Start DL traffic via iperf on Appserver
    [Documentation]  This keyword connect to Appserver and start the iperf data.
    ...    2020-03-19 Liu Zheng: remove sudo, if appserver username is not root account, it will wait until input the password,
    ...    then kw execute for more than 5 minutes. so remove the sudo. it also suitable for root account.
    [Arguments]     ${ue_addr}    ${dl_time}    ${dl_port}    ${dl_throughput}    ${dl_length}
    ...    ${appserver}=APPserver    ${protocol}=udp    ${ue_index}=${0}    ${process_num}=${5}
    ...    ${seg_size}=${1180}    ${window}=2M
    run keyword if    '${appserver}'=='APPserver'
    ...    wait until keyword succeeds    1 min    10 sec    traffic_via_iperf.Connect to APPserver
    ...    ELSE IF    '${appserver}'=='APPserversim'
    ...    wait until keyword succeeds    1 min    10 sec    traffic_via_iperf.Connect to APPserversim
    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${dl_port}| awk '{print $2}' |xargs kill -9    connection=APPserver
    run keyword if    '${protocol}'=='udp'    csn.send command
    ...    command=iperf -c ${ue_addr} -u -t ${dl_time} -i 1 -p ${dl_port} -P 1 -f m -b ${dl_throughput} -l ${dl_length} -T 64 &
    ...    connection=APPserver
    ...    ELSE IF    '${protocol}'=='tcp'    Start the tcp DL data via iperf    ue_index=${ue_index}
    ...    dl_time=${dl_time}    ue_addr=${ue_addr}    dl_port=${dl_port}    process_num=${process_num}    seg_size=${seg_size}
    ...    window=${window}
    sleep    3s
    Check the iperf progress exist    connection=APPserver    port=${dl_port}
    [Teardown]    csn.disconnect    connection=APPserver

Start the tcp DL data via iperf
    [Documentation]    This keyword starts tcp dl data.
    ...    :param process_num: the number of process which are used for tcp data transfer, the more the better.
    [Arguments]     ${ue_index}    ${dl_time}    ${ue_addr}    ${dl_port}
    ...    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...    ${process_num}=${5}    ${seg_size}=${1180}    ${window}=2M
    Wait Until Keyword Succeeds    3x    5s    Close the iperf process on android ue    ue_index=${ue_index}    iperf_port=${dl_port}
    Connect to control pc enhanced    ue_index=${ue_index}
    ${cmd_dl_traffic}    Catenate    adb -s ${serial_number} shell iperf -s -i 1 -p ${dl_port} -w ${window}
    csn.send_command    command=${cmd_dl_traffic}    connection=cpc_${ue_index}
    sleep    10s
    csn.send command
    ...    command=iperf -c ${ue_addr} -t ${dl_time} -i 1 -p ${dl_port} -P ${process_num} -M ${seg_size} -w ${window} &
    ...    connection=APPserver
    [Teardown]    csn.disconnect    connection=cpc_${ue_index}

Check the iperf progress exist
    [Arguments]     ${connection}    ${port}    ${ue_sn}=${EMPTY}      ${iperf_index}=${2}
    run keyword if    '${ue_sn}'=='${EMPTY}'
    ...    csn.send_command    command=ps -ef | grep iperf |grep ${port} |grep -v grep |awk '{print $${iperf_index}}'
    ...    connection=${connection}    timeout=120
    ...    ELSE
    ...    csn.send_command    command=adb -s ${ue_sn} shell ps -ef | grep iperf |grep ${port} |grep -v grep |awk '{print $${iperf_index}}'
    ...    connection=${connection}    timeout=120
    ${output}    csn.read_output    size=1000    connection=${connection}
    ${iperf_pid}    evaluate    ${output.strip()}
    should be true    ${iperf_pid} > ${0}


Caculate DL throughput on gnb L2Lo
    [Documentation]  This keyword check the DL throughput in gnb l2lo and compare with expect value.
    [Arguments]     ${dl_expect}    ${sw_branch}=master    ${du_index}=${0}    ${hw_slot}=${1}
    ${res} =    Feature 1514 Enabled
    run keyword if    ${res}==${False}    Connect to Capacity Unit Master    du_index=${du_index}   hw_slot=${hw_slot}    alias=aspa
    ...    ELSE IF    ${res}==${True}    Connect to Capacity Unit Slave    du_index=${du_index}   hw_slot=${hw_slot}    alias=aspa
    ${dl_tp_l2lo}=    run keyword if    '${sw_branch}'=='master'    Calculate DL throughoutput    alias=aspa
    ...               ELSE IF           '${sw_branch}'=='trunk'     Calculate DL throughoutput trunk    alias=aspa
    should be true    ${dl_tp_l2lo} > ${dl_expect}
    [Teardown]    RUN KEYWORDS    run keyword and ignore error  csn.disconnect    connection=asppa    AND
    ...                           run keyword and ignore error  csn.disconnect    connection=ASIK Master

Caculate DL throughput on gnb L2Lo with re
    [Documentation]  This keyword check the DL throughput in gnb l2lo and compare with expect value.
    ...  :param  dl_expect: the expect minimum throughput for dl caculate.
    ...  :param  du_index: this du index can distinguish left or right of AMIA, 0 meas left, 1 means right
    ...  :param  hw_slot: abil index, In left of AMIA support slot 1, 2, 3. In right of AMIA support slot 5, 6, 7.
    ...  :param  sample: how many sample cut in l2lo for average caculate.
    ...  :param  start_offset: start from which line to caculate the throughput.
    [Arguments]     ${dl_expect}=${0}    ${gnb_index}=${0}    ${du_index}=${0}    ${hw_slot}=${1}    ${sample}=${60}
    ...    ${start_offset}=${5}    ${sleep_time}=${15}    ${cellid}=${EMPTY}    ${log_type}=journallog
    ...    ${host}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    run keyword if    '${log_type}'=='journallog'    Connect to Capacity Unit Master
    ...               du_index=${du_index}    hw_slot=${hw_slot}    alias=aspa_l2lo
    ...    ELSE IF    '${log_type}'=='Aasyslog'    csn.connect_to
    ...               hostname=${host}   username=${username}    password=${password}    alias=aspa_l2lo
    ${dl_tp_l2lo} =    Calculate DL throughoutput re    alias=aspa_l2lo    sample=${sample}
    ...    start_offset=${start_offset}    sleep_time=${sleep_time}    cellid=${cellid}    log_type=${log_type}
    should be true    ${dl_tp_l2lo} > ${dl_expect}    [ERROR]DL TP is NOT on Target: | DL_TP_L2Lo: ${dl_tp_l2lo} | DLTP_Expected: ${dl_expect} |.
    Log To Console    \n[INFO]DL TP is on Target: | DL_TP_L2Lo: ${dl_tp_l2lo} | DLTP_Expected: ${dl_expect} |
    [Return]    ${dl_tp_l2lo}
    [Teardown]    RUN KEYWORDS    run keyword and ignore error  csn.disconnect    connection=aspa_l2lo    AND
    ...                           run keyword and ignore error  csn.disconnect    connection=ASIK Master

Calculate the E2E UE side DL TP
    [Documentation]  This keyword check the DL throughput in gnb l2lo and compare with expect value.
    [Arguments]    ${ue_index}    ${dl_expect}    ${dl_port}
    Connect to control pc enhanced    ${ue_index}
    ${dl_tp} =    calculate_e2e_throughput    alias=cpc_${ue_index}    port=${dl_port}    iperf_path=adb shell iperf
    should be true    ${dl_tp} > ${dl_expect}
    [Teardown]    Csn.disconnect      connection=cpc_${ue_index}


Stop tcp data via iperf
    [Arguments]    ${iperf_port}    ${ue_index}=${0}    ${appserver}=APPserver
    traffic_via_iperf.Connect to APPserver    alias=${appserver}
    Connect to control pc enhanced    ue_index=${ue_index}    cpc_ip=${cpc_ip}    cpc_usrname=${cpc_username}    cpc_passwd=${cpc_password}
    ${remote_pc_shell_channel}    Connect to ue manage ip    ue_index=${ue_index}
    ...    ue_manage_ip=${ue_manage_ip}    ue_manage_username=${ue_manage_username}    ue_manage_password=${ue_manage_password}
    run keywords    Call Method    ${remote_pc_shell_channel}
    ...    send    ps -ef|grep iperf|grep -v grep|grep ${iperf_port}| awk '{print $2}' |xargs kill -9\n    AND
    ...    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${iperf_port}| awk '{print $2}' |xargs kill -9    connection=${appserver}
    [Teardown]    run keywords    Call Method    ${remote_pc_shell_channel}    close   AND
    ...    csn.disconnect    connection=cpc_${ue_index}    AND    csn.disconnect    connection=${appserver}


Iperf3 Start UDP DownLink data traffic
    [Arguments]    ${ue_index}    ${dl_throughput_Mbps}    ${dl_port}=5001    ${dl_time}=600
    [Documentation]    Need to install iperf3 both on ue side and iperf server side.
    ...    Descrition：start UDP downlink traffic via iperf3
    ${serial_number}    Set Variable    ${tl.ues[${ue_index}].serial_number}
    ${ue_addr} =    Get the UE Ip address    ue_index=${ue_index}
    Set Test Variable    ${ue_addr}
    Log to console    INFO:The iperf3 server is starting on UE with port ${dl_port}...
    ${cmd_dl_traffic}=    catenate    adb -s ${serial_number} shell
    ...    iperf3 -s -p ${dl_port} -i 1 -J --logfile /data/local/tmp/DL_${serial_number}.json
    Connect to control pc enhanced    ${ue_index}
    csn.send command    command=${cmd_dl_traffic}     connection=cpc_${ue_index}
    ${resp2}    csn.execute    command=adb shell ps -ef|grep iperf3    connection=cpc_${ue_index}
    Should Contain    ${resp2}    iperf3 -s -p ${dl_port}    The iperf server is failed to start on UE.
    Log to console    INFO:The iperf3 server is started on UE with port ${dl_port}.
    Log to console    INFO:The iperf3 client is starting on iperf APPserver...
    wait until keyword succeeds    1 min    10 sec    Connect to APPserver
    csn.execute    command=ps -ef|grep iperf3|grep -v grep|grep ${dl_port}| awk '{print $2}' |xargs kill -9    connection=APPserver
    csn.send command    command=iperf3 -u -c ${ue_addr} -p ${dl_port} -t ${dl_time} -P 1 -i 1 -l 1400 -b ${dl_throughput_Mbps}
    ...    connection=APPserver
    ${resp4}    csn.execute    command=ps -ef|grep iperf3    connection=APPserver
    Should Contain    ${resp4}    iperf3 -u -c ${ue_addr}    The DL data traffic is failed.
    Log to console    INFO:The iperf3 client is started on iperf APPserver with port ${dl_port}.

Iperf3 Start UDP UpLink data traffic
    [Arguments]    ${ue_index}    ${ul_throughput_Mbps}    ${ul_port}=10010    ${ul_time}=600
    [Documentation]    Need to install iperf3 both on ue side and iperf server side.
    ...    Descrition：start UDP uplink traffic via iperf3
    ${serial_number}    Set Variable    ${tl.ues[${ue_index}].serial_number}
    Log to console    INFO:The iperf3 server is starting on iperf APPserver with port ${ul_port}...
    wait until keyword succeeds    1 min    10 sec    Connect to APPserver
    csn.execute    command=ps -ef|grep iperf3|grep -v grep|grep ${ul_port}| awk '{print $2}' |xargs kill -9    connection=APPserver
    csn.send command    command=iperf3 -s -p ${ul_port} -i 1 -J --logfile /home/ute/Public/UL_${serial_number}.json    connection=APPserver
    ${resp5}    csn.execute    command=ps -ef|grep iperf3    connection=APPserver
    Should Contain    ${resp5}    iperf3 -s -p ${ul_port}    The iperf server is failed to start on APPserver.
    Log to console    INFO:The iperf3 server is started on iperf APPserver with port ${ul_port}.
    Log to console    INFO:The iperf3 client is starting on UE with port ${ul_port}...
    ${cmd_ul_traffic}=    catenate    adb -s ${serial_number} shell
    ...    iperf3 -c ${appserver_addr} -t ${ul_time} -p ${ul_port} -b ${ul_throughput_Mbps} -i 1 -l 1400
    Connect to control pc enhanced    ${ue_index}
    csn.send command    command=${cmd_ul_traffic}    connection=cpc_${ue_index}
    ${resp6}    csn.execute    command=adb -s ${serial_number} shell ps -ef|grep iperf3    connection=cpc_${ue_index}
    Should Contain    ${resp6}    iperf3 -c ${appserver_addr}    The UL data traffic is failed.
    Log to console    INFO:The iperf3 client is started on UE with port ${ul_port}.

Iperf3 Stop UDP data
    [Arguments]    ${ue_index}    ${ul_port}=10010
    Connect to control pc enhanced    ue_index=${ue_index}
    csn.execute    command=adb shell pkill iperf3    connection=cpc_${ue_index}
    wait until keyword succeeds    1 min    10 sec    Connect to APPserver
    csn.execute    command=ps -ef|grep iperf3|grep -v grep|grep ${ul_port}| awk '{print $2}' |xargs kill -9    connection=APPserver
    csn.execute    command=ps -ef|grep iperf3|grep -v grep|grep ${ue_addr}| awk '{print $2}' |xargs kill -9    connection=APPserver
    [Teardown]    run keywords    csn.disconnect    connection=cpc_${ue_index}
    ...    AND    csn.disconnect    connection=APPserver

Iperf3 Get Results From UE And APPserver
    [Arguments]    ${ue_index}
    wait until keyword succeeds    1 min    10 sec    Connect to APPserver
    ${serial_number}    Set Variable    ${tl.ues[${ue_index}].serial_number}
    csn.download_file    remote_path=/home/ute/Public/UL_${serial_number}.json
    ...                  local_path=${TEST_LOG_DIR}/UL_${serial_number}.json
    ...                  connection=APPserver
    Connect to control pc enhanced    ue_index=${ue_index}
    ${get_json_ue_to_pc}    catenate    adb -s ${serial_number} shell
    ...    cat /data/local/tmp/DL_${serial_number}.json > /home/root/DL_${serial_number}.json
    csn.execute    command=${get_json_ue_to_pc}     connection=cpc_${ue_index}
    csn.execute    command=ls -l | grep *.json     connection=cpc_${ue_index}
    csn.download_file    remote_path=/home/root/DL_${serial_number}.json
    ...                  local_path=${TEST_LOG_DIR}/DL_${serial_number}.json
    ...                  connection=cpc_${ue_index}
    [Teardown]    Run Keywords    csn.execute    command=adb shell rm /data/local/tmp/*.json    connection=cpc_${ue_index}
    ...    AND    csn.execute    command=rm /home/root/DL_${serial_number}.json    connection=cpc_${ue_index}
    ...    AND    csn.disconnect    connection=cpc_${ue_index}
    ...    AND    csn.execute    command=rm /home/ute/Public/UL_${serial_number}.json    connection=APPserver
    ...    AND    csn.disconnect    connection=APPserver

Calculate Iperf3 bd Average From Json File
    [Arguments]    ${json_file}
    ${json_output}    get_json_content    ${json_file}
    ${average_tp}    calculate_iperf_bd_average    ${json_output}
    [Return]    ${average_tp}
