*** Settings ***
Documentation    This iperf common keyword, contain the DL UL data start and data check in gnb L2L0 and end to end side online check.
...              support to Multi andriod UE data transfer also.
...              Please do not modify the file without notification to author
...              Author: Andy Cheng
...              Contact: huimin.1.cheng@nokia-sbell.com
...              Squard: HZ SG3

Resource     android_common_keyword.robot
Resource     taf/rfrl/common_resources/robot/stream_manager.robot
Library      DateTime
Library      taf.rfrl.common_resources.python.gNB_l2_lo_throughput
Library      taf.analyzer.iperf_throughput    WITH NAME    iperf_tput
Library      ../python/utils.py

*** Variables ***
${appserver_addr}    ${tl.ues[0].iperf_details.ssh_connection_details.addr}
${appserver_username}    ${tl.ues[0].iperf_details.ssh_connection_details.username}
${appserver_password}    ${tl.ues[0].iperf_details.ssh_connection_details.password}
${appserversim_addr}    ${tl.core.default_ssh_connection_details.addr}
${appserversim_username}    ${tl.core.default_ssh_connection_details.username}
${appserversim_password}    ${tl.core.default_ssh_connection_details.password}

*** Keywords ***
Start UL traffic via iperf from andriod UE
    [Documentation]  This keyword connect to android control pc and start the iperf data.
    ...    2020-03-19 Cui Lingxue: use ${serial_number} to indicate specific UE; add verification for iperf process
    ...    2020-12-22 Jia Lei: abstract three arguments for cpc_ip, cpc_usrname and cpc_passwd
    [Arguments]    ${ue_index}    ${ul_time}    ${ul_port}    ${ul_throughput}    ${ul_length}    ${appserver}=APPserver
    ...    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${protocol}=udp     ${process_num}=${5}   ${iperf_index}=${2}
    ...    ${cpc_ip}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    ${cpc_usrname}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    ${cpc_passwd}=${tl.ues[${ue_index}].ssh_connection_details.password}
    ...    ${window}=2M
    ...    ${iperf_path}=iperf
    Close the iperf process on android ue    ue_index=${ue_index}    iperf_port=${ul_port}    serial_number=${serial_number}
    ...                                      iperf_index=${iperf_index}
    ...                                      cpc_ip=${cpc_ip}    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}
    Connect to control pc enhanced    ue_index=${ue_index}    cpc_ip=${cpc_ip}    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}
    ${cmd_ul_traffic}=    run keyword if    '${appserver}'=='APPserver'       catenate    adb -s ${serial_number} shell
    ...     ${iperf_path} -c ${appserver_addr} -u -t ${ul_time} -i 1 -p ${ul_port} -P 1 -f m -b ${ul_throughput} -l ${ul_length} -T 64 &
    ...    ELSE IF    '${appserver}'=='APPserversim'     catenate    adb -s ${serial_number} shell
    ...  ${iperf_path} -c ${appserversim_addr} -u -t ${ul_time} -i 1 -p ${ul_port} -P ${process_num} -f m -b ${ul_throughput} -l ${ul_length} -T 64 &
    run keyword if    '${protocol}'=='udp'    csn.send_command    command=${cmd_ul_traffic}    connection=cpc_${ue_index}
    ...    ELSE IF    '${protocol}'=='tcp'    Start the tcp UL data via iperf    appserver=${appserver}
    ...    serial_number=${serial_number}    ul_time=${ul_time}    ul_port=${ul_port}    ue_index=${ue_index}
    ...    process_num=${process_num}    window=${window}
    sleep    3s
    Check the iperf progress exist    connection=cpc_${ue_index}    port=${ul_port}    ue_sn=${serial_number}   iperf_index=${iperf_index}
    [Teardown]    csn.disconnect    connection=cpc_${ue_index}

Start the tcp UL data via iperf
    [Documentation]    This keyword starts tcp ul data.
    ...    :param process_num: the number of process which are used for tcp data transfer, the more the better.
    [Arguments]     ${appserver}    ${serial_number}    ${ul_time}    ${ul_port}    ${ue_index}
    ...   ${process_num}=${5}    ${window}=2M
    run keyword if    '${appserver}'=='APPserver'
    ...    wait until keyword succeeds    1 min    10 sec    traffic_via_iperf.Connect to APPserver
    ...    ELSE IF    '${appserver}'=='APPserversim'
    ...    wait until keyword succeeds    1 min    10 sec    traffic_via_iperf.Connect to APPserversim
    ${cmd_ul_traffic}    Catenate    iperf -s -i 1 -p ${ul_port} -w ${window}
    ${server_addr}    set variable if    '${appserver}'=='APPserver'    ${appserver_addr}     ${appserversim_addr}
    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${ul_port}| awk '{print $2}' |xargs kill -9    connection=APPserver
    sleep    10s
    csn.send_command    command=${cmd_ul_traffic}    connection=APPserver
    sleep    10s
    csn.send command
    ...    command=adb -s ${serial_number} shell iperf -c ${server_addr} -t ${ul_time} -i 1 -p ${ul_port} -P ${process_num} -M 1180 -w ${window} &
    ...    connection=cpc_${ue_index}
    [Teardown]    csn.disconnect    connection=APPserver

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
    [Arguments]     ${ul_expect}=${0}    ${gnb_index}=${0}    ${du_index}=${0}    ${hw_slot}=${1}    ${sample}=${10}
    ...    ${start_offset}=${3}    ${sleep_time}=${5}    ${cellid}=${EMPTY}    ${log_type}=journallog
    ...    ${host}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    run keyword if    '${log_type}'=='journallog'    Connect to Capacity Unit Master
    ...               du_index=${du_index}    hw_slot=${hw_slot}    alias=aspa_l2lo
    ...    ELSE IF    '${log_type}'=='Aasyslog'    csn.connect_to
    ...               hostname=${host}   username=${username}    password=${password}    alias=aspa_l2lo
    ${ul_tp_l2lo} =    Calculate UL throughoutput re    alias=aspa_l2lo    sample=${sample}
    ...    start_offset=${start_offset}    sleep_time=${sleep_time}    cellid=${cellid}    log_type=${log_type}
    should be true    ${ul_tp_l2lo} > ${ul_expect}
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
    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${dl_port}| awk '{print $2}'    connection=APPserver
    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${dl_port}| awk '{print $2}' |xargs kill -9    connection=APPserver
    run keyword if    '${protocol}'=='udp'    csn.send command
    ...    command=iperf -c ${ue_addr} -u -t ${dl_time} -i 1 -p ${dl_port} -P ${process_num} -f m -b ${dl_throughput} -l ${dl_length} -T 64 &
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
    [Arguments]     ${dl_expect}=${0}    ${gnb_index}=${0}    ${du_index}=${0}    ${hw_slot}=${1}    ${sample}=${10}
    ...    ${start_offset}=${3}    ${sleep_time}=${5}    ${cellid}=${EMPTY}    ${log_type}=journallog
    ...    ${host}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    run keyword if    '${log_type}'=='journallog'    Connect to Capacity Unit Master
    ...               du_index=${du_index}    hw_slot=${hw_slot}    alias=aspa_l2lo
    ...    ELSE IF    '${log_type}'=='Aasyslog'    csn.connect_to
    ...               hostname=${host}   username=${username}    password=${password}    alias=aspa_l2lo
    ${dl_tp_l2lo} =    Calculate DL throughoutput re    alias=aspa_l2lo    sample=${sample}
    ...    start_offset=${start_offset}    sleep_time=${sleep_time}    cellid=${cellid}    log_type=${log_type}
    should be true    ${dl_tp_l2lo} > ${dl_expect}
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

Connect to APPserver
    [Arguments]    ${alias}=APPserver
    csn.Connect to    hostname=${appserver_addr}
    ...               username=${appserver_username}
    ...               password=${appserver_password}
    ...               alias=${alias}

Connect to APPserver with items defined in taf
    [Documentation]    Author: Ding Binmei
    ...    app server related info are defined in testline config file rather then in yaml file
    [Arguments]    ${alias}=APPserver
    ${is_iperf_details_exist}    utils.is_attribute_exist    obj=${tl.ues[0]}   attr=iperf_details
    ${appserver_addr}    set variable if    ${is_iperf_details_exist}    ${appserver_addr}
    ...    ${tl.ues[0].data_transfer[0].app_server.address}
    ${appserver_username}    set variable if    ${is_iperf_details_exist}    ${appserver_username}
    ...    ${tl.ues[0].data_transfer[0].app_server.user}
    ${appserver_password}    set variable if    ${is_iperf_details_exist}    ${appserver_password}
    ...    ${tl.ues[0].data_transfer[0].app_server.password}
    csn.Connect to    hostname=${appserver_addr}
    ...               username=${appserver_username}
    ...               password=${appserver_password}
    ...               alias=${alias}

Connect to APPserversim
    [Arguments]    ${alias}=APPserver
    csn.Connect to    hostname=${appserversim_addr}
    ...               username=${appserversim_username}
    ...               password=${appserversim_password}
    ...               alias=${alias}

Disconnect from app server
    [Documentation]  Author: Ding Binmei
    [Arguments]    ${app_server_alias}=APPserver
    csn.disconnect    connection=${app_server_alias}

Close the iperf process on APPserver
    [Arguments]    ${port}    ${appserver}=APPserver
    run keyword if    '${appserver}'=='APPserver'
    ...    wait until keyword succeeds    1 min    10 sec    traffic_via_iperf.Connect to APPserver
    ...    ELSE IF    '${appserver}'=='APPserversim'
    ...    wait until keyword succeeds    1 min    10 sec    traffic_via_iperf.Connect to APPserversim
#     wait until keyword succeeds    1 min    10 sec    traffic_via_iperf.Connect to APPserver
    run keyword and ignore error    csn.execute    command=ps -ef|grep iperf|grep -v grep    connection=APPserver
    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${port}| awk '{print $2}' |xargs kill -9    connection=APPserver

Close the iperf process on android ue
    [Arguments]    ${ue_index}    ${iperf_port}    ${serial_number}=${tl.ues[${ue_index}].serial_number}     ${iperf_index}=${2}
    ...             ${cpc_ip}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...             ${cpc_usrname}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...             ${cpc_passwd}=${tl.ues[${ue_index}].ssh_connection_details.password}
    Connect to control pc enhanced    ue_index=${ue_index}    cpc_ip=${cpc_ip}    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}
    run keyword and ignore error    csn.send_command
    ...    command=adb -s ${serial_number} shell ps -ef | grep iperf |grep -v grep
    ...    connection=cpc_${ue_index}    timeout=120
    sleep   3s
    ${output_for_debug}    run keyword and ignore error    csn.read_output    size=1000    connection=cpc_${ue_index}
    ${filter_command}    Catenate    ps -ef | grep iperf |grep ${iperf_port} |grep -v grep |awk '{print $${iperf_index}}'
    csn.send_command
    ...    command=adb -s ${serial_number} shell ${filter_command} |xargs adb -s ${serial_number} shell kill -9
    ...    connection=cpc_${ue_index}    timeout=120
    sleep   3s
    FOR    ${i}    IN RANGE    ${3}
        csn.send_command    command=adb -s ${serial_number} shell ${filter_command}
        ...    connection=cpc_${ue_index}    timeout=60
        ${output}    csn.read_output    size=1000    connection=cpc_${ue_index}
        ${output}    replace_string    string=${output}   search_for=\n    replace_with=${SPACE}
        run keyword if    '${output}'!='${EMPTY}'    csn.send_command
        ...    command=adb -s ${serial_number} shell ${filter_command} |xargs adb -s ${serial_number} shell kill -9
        ...    connection=cpc_${ue_index}    timeout=120
        exit for loop if    '${output}'=='${EMPTY}'
    END

    should be empty      ${output}
    [Teardown]    Csn.disconnect      connection=cpc_${ue_index}

Close the iperf process on Qualcomm
    [Documentation]    2020-04-01 Liu Zheng: use ${serial_number} to indicate specific UE.
    ...                                      if there are two ue connected to control pc,
    ...                                      adb shell command execute failed due to 'error: more than one device/emulator'
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    Connect to control pc enhanced    ${ue_index}
    csn.send command    command=adb -s ${serial_number} shell killall iperf    connection=cpc_${ue_index}
    [Teardown]    Csn.disconnect      connection=cpc_${ue_index}

Start UL traffic via iperf on VIAVI
    [Documentation]  Author: Wang Yishuang
    ...              Contact: yishuang.wang@nokia-sbell.com
    ...              This keyword connect to cobham control pc and start the iperf data.
    [Arguments]     ${iperf_path}    ${ul_addr}    ${ul_time}    ${ul_port}    ${ul_throughput}    ${ul_length}    ${tma_ssh_alias}=${TMA_SSH_ALIAS}
    wait until keyword succeeds    1 min    10 sec    traffic_via_iperf.Connect to cobham control pc via ssh    ${tma_ssh_alias}
    ${cmd_start_iperf_client}    Catenate    ${iperf_path}/iperf -c ${ul_addr} -u -t ${ul_time}
    ...                             -i 1 -p ${ul_port} -P 1 -f m -b ${ul_throughput} -l ${ul_length} -T 64
    csn.send command     command=${cmd_start_iperf_client}    connection=${tma_ssh_alias}
    [Teardown]    csn.disconnect    connection=${tma_ssh_alias}

Close the iperf process on VIAVI
    [Documentation]  Author: Wang Yishuang
    ...              Contact: yishuang.wang@nokia-sbell.com
    ...              This keyword is to kill the iperf process on cobham.
    [Arguments]    ${tma_ssh_alias}=${TMA_SSH_ALIAS}
    wait until keyword succeeds    1 min    10 sec    traffic_via_iperf.Connect to cobham control pc via ssh    ${tma_ssh_alias}
    csn.execute    command=ps -ef |grep iperf|awk '{print $2}'|xargs kill -9    connection=${tma_ssh_alias}
    [Teardown]    csn.disconnect    connection=${tma_ssh_alias}

Connect to cobham control pc via ssh
    [Documentation]  Author: Wang Yishuang
    ...              Contact: yishuang.wang@nokia-sbell.com
    ...              This keyword is to connect to the cobham control PC.
    [Arguments]  ${tma_ssh_alias}=${TMA_SSH_ALIAS}
    csn.connect to    hostname=${E500_IP}    username=${E500_USER}    password=${E500_PW}    alias=${tma_ssh_alias}

Disconnect from cobham control pc via ssh
    [Documentation]  Author: Ding Binmei
    [Arguments]    ${tma_ssh_alias}=${TMA_SSH_ALIAS}
   csn.disconnect    connection=${tma_ssh_alias}

Iperf send DL traffic with real epc
    [Documentation]    Author: Ding Binmei
    ...                ${UE_IP} is returned from UE attach
    ...                Need to configure iperf path to cygwin
    ...                DL port value range: 54000~55000
    [Arguments]    ${throughput}    ${traffic_time}    ${port}=${tl.ues[0].iperf_details.port}    ${dl_host_ip}=${UE_IP}    ${length}=${1024}
    Iperf DL traffic precondition with real epc    port=${port}
    Iperf DL traffic start iperf client from app server with real epc    throughput=${throughput}    traffic_time=${traffic_time}
    ...    port=${port}    dl_host_ip=${dl_host_ip}    length=${length}

Iperf send UL traffic with real epc
    [Documentation]    Author: Ding Binmei
    ...                Description: ul_host_ip will default to 192.168.10.70
    ...                port=5410 is related with it used on cobham. Now dedicated to this value
    [Arguments]    ${throughput}    ${traffic_time}    ${ul_host_ip}=192.168.10.70
    ...    ${port}=${tl.ues[0].iperf_details.ssh_connection_details.port}    ${length}=${1024}
    Log to console    Start UL traffic with real epc
    wait until keyword succeeds    2 min    10 s    Connect to app server
    ${is_iperf_process_started}    run keyword and return status  Check if iperf server process is started on app server    port=${port}
    Run keyword if  ${is_iperf_process_started}==${False}
    ...    Run keywords    Log to console    Iperf server is not started on app server, now started.    AND
    ...                    Start iperf server    port=${port}    connection=APPserver    AND
    ...                    Check if iperf server process is started on app server    port=${port}

    wait until keyword succeeds    2 min    10 s    traffic_via_iperf.Connect to cobham control pc via ssh
    Start iperf client    throughput=${throughput}    traffic_time=${traffic_time}
    ...                   host_ip=${ul_host_ip}    length=${length}    port=${port}    connection=${TMA_SSH_ALIAS}
    Log to console    Start to send UL traffic with real epc on UE side, traffic time is ${traffic_time}
    [Teardown]  Run keyword and ignore error    Run keywords    traffic_via_iperf.Disconnect from app server    AND
    ...    traffic_via_iperf.Disconnect from cobham control pc via ssh

Iperf stop traffic from appserver and ue side
    [Documentation]  Port number is allocated on app server side
    ...              DL port value range: 54000~55000
    ...              2019-12-3: Ding Binmei: Port can be a port list for both UL and DL ports
    [Arguments]    ${port}
    Kill iperf process on app server    port=${port}
    Kill iperf process on ue side

Iperf DL traffic precondition with real epc
    [Documentation]  Author: Ding Binmei
    ...              DL port value range: 54000~55000(Should use team's own port range)
    [Arguments]  ${port}=${tl.ues[0].iperf_details.port}
    Log to console    Start DL traffic with real epc
    wait until keyword succeeds    2 min    10 s    traffic_via_iperf.Connect to cobham control pc via ssh
    Start iperf server    port=${port}    connection=${TMA_SSH_ALIAS}
    wait until keyword succeeds    2 min    10 s    traffic_via_iperf.Connect to APPserver
    [Teardown]    Run keyword and ignore error    traffic_via_iperf.Disconnect from cobham control pc via ssh

Iperf DL traffic start iperf client from app server with real epc
    [Documentation]    Author: Ding Binmei
    ...                ${UE_IP} is returned from UE attach
    ...                Need to configure iperf path to cygwin
    ...                DL port value range: 54000~55000
    [Arguments]    ${throughput}    ${traffic_time}    ${port}=${tl.ues[0].iperf_details.port}    ${dl_host_ip}=${UE_IP}    ${length}=${1024}
    Start iperf client    throughput=${throughput}    traffic_time=${traffic_time}
    ...                   host_ip=${dl_host_ip}    length=${length}    port=${port}    connection=APPserver
    ${is_iperf_process_started}    Is iperf process exists on app server    port=${port}
    Should be true  ${is_iperf_process_started}    msg=Iperf client process is not started on app server side for port ${port}
    [Teardown]    Run keyword and ignore error    traffic_via_iperf.Disconnect from app server

Start iperf client
    [Documentation]    Author: Ding Binmei
    ...                Description: Start Iperf client
    [Arguments]    ${throughput}    ${traffic_time}    ${host_ip}    ${length}    ${port}    ${connection}
    ${cmd_start_iperf_client}    Catenate    iperf -c ${host_ip} -u -b ${throughput}M
    ...                              -i 1 -l ${length} -t ${traffic_time} -p ${port}
    csn.send command     ${cmd_start_iperf_client}    connection=${connection}
    sleep    200ms

Start iperf server
    [Documentation]    Author: Ding Binmei
    ...                Description: Start Iperf server
    [Arguments]  ${port}    ${connection}
    ${cmd_start_iperf_server}    Catenate  iperf -s -u -i 1 -p    ${port}
    csn.send command    ${cmd_start_iperf_server}    connection=${connection}
    sleep    200ms

# Kill iperf process
Kill iperf process on ue side
    [Documentation]    Author: Ding Binmei
    ...                Description: Kill iperf process on cobham via ssh command
    ...                   Precondition: Cygwin is installed in cobham control pc, all iperf processes will be closed
    [Arguments]    ${tma_ssh_alias}=${TMA_SSH_ALIAS}    ${retry_time}=10
    wait until keyword succeeds    2 min    10 s    traffic_via_iperf.Connect to cobham control pc via ssh    tma_ssh_alias=${tma_ssh_alias}
    Wait until keyword succeeds    ${retry_time}X    1 s    Kill iperf on ue side and verfify iperf is killed    tma_ssh_alias=${tma_ssh_alias}
    [Teardown]    Run keyword and ignore error    traffic_via_iperf.Disconnect from cobham control pc via ssh

Kill iperf process on app server
    [Documentation]    Author: Ding Binmei
    ...                Description: 2019-12-2 Extend ${port} to support for port list to kill multiple ports
    ...    ${is_ue_proxy}: ${True}/${False}: if ue proxy then set as ${True}, since app server definition is different
    [Arguments]    ${port}    ${app_server_alias}=APPserver    ${retry_time}=5    ${is_ue_proxy}=${False}
    ${port_list}    Convert port data type to a list    port=${port}
    run keyword if    ${is_ue_proxy}    wait until keyword succeeds    2 min    10 s
    ...    Connect to APPserver with items defined in taf    alias=${app_server_alias}
    ...    ELSE    wait until keyword succeeds    2 min    10 s    traffic_via_iperf.Connect to APPserver    alias=${app_server_alias}
    FOR    ${port_num}    IN    @{port_list}
        Wait until keyword succeeds    ${retry_time}X    1 s    Kill iperf process based on port num on app server
        ...    port=${port_num}    app_server_alias=${app_server_alias}
    END
    [Teardown]    traffic_via_iperf.Disconnect from app server

Kill iperf process based on port num on app server
    [Documentation]    Author: Ding Binmei
    ...                Description: Kill iperf process based on port number and verify if process is killed
    [Arguments]    ${port}    ${app_server_alias}=APPserver
    Log to console    Starting to kill iperf process on app server for port ${port}
    ${is_iperf_process_exist}    Is iperf process exists on app server    port=${port}    app_server_alias=${app_server_alias}
    Run keyword if    ${is_iperf_process_exist}==${True}
    ...    csn.Execute    command=ps -ef|grep iperf|grep -v "grep"|grep ${port}|awk '{print $2}'| xargs kill -9    connection=${app_server_alias}
    Sleep    200ms
    ${is_iperf_process_exist}    Is iperf process exists on app server    port=${port}    app_server_alias=${app_server_alias}
    Should not be true    ${is_iperf_process_exist}    msg=Iperf process with port ${port} is not killed from app server

Kill iperf on ue side and verfify iperf is killed
    [Documentation]    Author: Ding Binmei    [PRIVATE]
    ...                Description: Kill iperf process on cobham via ssh command
    ...                   Precondition: Cygwin is installed in cobham control pc, all iperf processes will be closed
    [Arguments]    ${tma_ssh_alias}=${TMA_SSH_ALIAS}
    ${is_iperf_process_exist}    Is iperf process exist on ue side    tma_ssh_alias=${tma_ssh_alias}
    Run keyword if    ${is_iperf_process_exist}==${True}
    ...    Run keywords    csn.Execute    command=ps -Wef|grep iperf|grep -v "grep"|awk '{print $2}'| xargs kill -9    connection=${tma_ssh_alias}
    ...    AND    csn.Execute    command=TASKKILL /F /IM iperf.exe /T    connection=${tma_ssh_alias}
    ...    AND    sleep    200ms
    ${is_iperf_process_exist}    Is iperf process exist on ue side    tma_ssh_alias=${tma_ssh_alias}
    Should not be true    ${is_iperf_process_exist}    msg=Iperf process is not killed on ue side

Convert port data type to a list
    [Documentation]    Author: Ding Binmei
    ...                Description: Convert the port date type to a list
    ...                             Input port type can be a string or a list
    [Arguments]    ${port}
    ${is_port_a_list_type}    Evaluate    isinstance(${port}, list)
    Return from keyword if    ${is_port_a_list_type}    ${port}
    ${port_list}    Create list    ${port}
    [Return]    ${port_list}

# Check if iperf process is started
Is iperf process exists
    [Documentation]    Author: Ding Binmei    [PRIVATE]
    ...                Description: iperf process started from app server side will be able to filter out with port number
    ...                             iperf process started from ue control pc, we are not able to see the port number
    [Arguments]    ${port}    ${connection}
    ${cmd_check_iperf_process}    Set variable if    ${port}==${None}    ps -Wef|grep iperf|grep -v "grep"
    ...    ps -ef|grep iperf|grep -v "grep"|grep ${port}
    ${result}    csn.execute    command=${cmd_check_iperf_process}    connection=${connection}
    ${is_iperf_process_started}    Run keyword and return status    should not be empty    ${result.strip()}
    [Return]    ${is_iperf_process_started}

Is iperf process exist on ue side
    [Documentation]    Author: Ding Binmei
    ...                Description: check if iperf process eixsts from ue control pc. will also check if any iperf process
    ...                             is started from windows
    [Arguments]    ${tma_ssh_alias}=${TMA_SSH_ALIAS}
    ${is_iperf_process_started}    Is iperf process exists    port=${None}    connection=${tma_ssh_alias}
    [Return]    ${is_iperf_process_started}

Is iperf process exists on app server
    [Documentation]    Author: Ding Binmei
    ...                Description: Check if iperf process with specific port number exists on app server
    [Arguments]    ${port}    ${app_server_alias}=APPserver
    ${is_iperf_process_started}    Is iperf process exists    port=${port}    connection=${app_server_alias}
    [Return]    ${is_iperf_process_started}

Check if iperf server process is started on app server
    [Documentation]  Author: Ding Binmei
    [Arguments]  ${port}
    csn.send command    command=ps -ef|grep "iperf -s"|grep -v "grep"|grep ${port}|awk '{print $2}'    connection=APPserver
    ${output_iperf_process_id}    csn.read output     connection=APPserver
    ${is_iperf_process_started}    Get length  ${output_iperf_process_id.strip()}
    Should be true    ${is_iperf_process_started} != ${0}    msg=Iperf server process is not started on app server side for port ${port}

Start DL traffic via iperf on Appserver for Askey
    [Documentation]  This keyword connect to Appserver and start the iperf data.
    ...    2021-03-17 Lin Jiangjing: change the method of tcp dl call
    ...    then kw execute for more than 5 minutes. so remove the sudo. it also suitable for root account.
    [Arguments]     ${ue_addr}    ${dl_time}    ${dl_port}    ${dl_throughput}    ${dl_length}
    ...    ${appserver}=APPserver    ${protocol}=udp    ${ue_index}=${0}    ${process_num}=${5}
    ...    ${seg_size}=${1180}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...    ${cpc_ip}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    ${cpc_usrname}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    ${cpc_passwd}=${tl.ues[${ue_index}].ssh_connection_details.password}
    run keyword if    '${appserver}'=='APPserver'
    ...    wait until keyword succeeds    1 min    10 sec    traffic_via_iperf.Connect to APPserver
    ...    ELSE IF    '${appserver}'=='APPserversim'
    ...    wait until keyword succeeds    1 min    10 sec    traffic_via_iperf.Connect to APPserversim
    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${dl_port}| awk '{print $2}' |xargs kill -9    connection=APPserver
    run keyword if    '${protocol}'=='udp'    csn.send command
    ...    command=iperf -c ${ue_addr} -u -t ${dl_time} -i 1 -p ${dl_port} -P 1 -f m -b ${dl_throughput} -l ${dl_length} -T 64 &
    ...    connection=APPserver
    ...    ELSE IF    '${protocol}'=='tcp'    Start the tcp DL data via iperf for askey   ue_index=${ue_index}
    ...    dl_time=${dl_time}    ue_addr=${ue_addr}    dl_port=${dl_port}    process_num=${process_num}    seg_size=${seg_size}
    ...    serial_number=${serial_number}    cpc_ip=${cpc_ip}    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}
    sleep    3s
    Check the iperf progress exist    connection=APPserver    port=${dl_port}

Start the tcp DL data via iperf for askey
    [Documentation]    This keyword starts tcp dl data.
    ...    :param process_num: the number of process which are used for tcp data transfer, the more the better.
    [Arguments]     ${ue_index}    ${dl_time}    ${ue_addr}    ${dl_port}
    ...    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...    ${process_num}=${5}    ${seg_size}=${1180}
    ...    ${cpc_ip}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    ${cpc_usrname}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    ${cpc_passwd}=${tl.ues[${ue_index}].ssh_connection_details.password}
    Wait Until Keyword Succeeds    3x    5s    Close the iperf process on android ue    ue_index=${ue_index}    iperf_port=${dl_port}
    ...    serial_number=${serial_number}    cpc_ip=${cpc_ip}    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}
    csn.send command    command=iperf3 -s -p ${dl_port} -i 1 >/tmp/dl_tcp_tput.txt &   connection=APPserver
    sleep   3s
    Connect to control pc enhanced    ue_index=${ue_index}    cpc_ip=${cpc_ip}    cpc_usrname=${cpc_usrname}    cpc_passwd=${cpc_passwd}
    ${cmd_dl_traffic}    Catenate    adb -s ${serial_number} shell iperf3 -c ${appserver_addr} -p ${dl_port} -t ${dl_time} -R -w 1M -M ${seg_size} &
    csn.send_command    command=${cmd_dl_traffic}    connection=cpc_${ue_index}
    [Teardown]    csn.disconnect    connection=cpc_${ue_index}

Connect to ue manage ip
    [Arguments]    ${ue_index}=${0}
    ...    ${ue_manage_ip}=${ue_manage_ip}
    ...    ${ue_manage_username}=${ue_manage_username}
    ...    ${ue_manage_password}=${ue_manage_password}
    ...    ${ue_manage_root_password}=${ue_manage_root_password}
    ${remote_pc_connection}    csn.get_connection_by_alias    cpc_${ue_index}
    ${remote_pc_shell_channel}    Call Method    ${remote_pc_connection}    invoke_shell
    Call Method    ${remote_pc_shell_channel}    send    ssh -o StrictHostKeyChecking\=no ${ue_manage_username}@${ue_manage_ip}\n
    wait until keyword succeeds    30x    2sec    Output contain match    ${remote_pc_shell_channel}    password
    Call Method    ${remote_pc_shell_channel}    send    ${ue_manage_password}\n
    wait until keyword succeeds    30x    2sec    Output contain match    ${remote_pc_shell_channel}    \$
    Call Method    ${remote_pc_shell_channel}    send    su\n
    wait until keyword succeeds    30x    2sec    Output contain match    ${remote_pc_shell_channel}    Password
    Call Method    ${remote_pc_shell_channel}    send    ${ue_manage_root_password}\n
    wait until keyword succeeds    30x    2sec    Output contain match    ${remote_pc_shell_channel}    \#
    Add iptables on ue manage ip    ${remote_pc_shell_channel}
    [Return]  ${remote_pc_shell_channel}

Reboot on ue manage ip
    [Arguments]    ${ue_index}=${0}
    Connect to control pc enhanced    ue_index=${ue_index}    cpc_ip=${cpc_ip}    cpc_usrname=${cpc_username}    cpc_passwd=${cpc_password}
    ${remote_pc_shell_channel}    Connect to ue manage ip    ue_index=${ue_index}
    Call Method    ${remote_pc_shell_channel}    send    reboot\n
    wait until keyword succeeds    5x    1sec    Output contain match    ${remote_pc_shell_channel}    /
    Call Method    ${remote_pc_shell_channel}    close
    sleep    2min
    wait until keyword succeeds    3min    15sec     Connect to ue manage ip    ue_index=${ue_index}
    [Teardown]    run keywords    Call Method    ${remote_pc_shell_channel}    close    AND
    ...    csn.disconnect    connection=cpc_${ue_index}

Output contain match
    [Arguments]     ${invoke_object}    ${match}
    ${status}    Call Method    ${invoke_object}    recv_ready
    ${output}    run keyword if    ${status}    Call Method    ${invoke_object}    recv    ${65535}
    ${output}    convert to string    ${output}
    should contain    ${output}    ${match}    ignore_case=True

Add iptables on ue manage ip
    [Arguments]     ${invoke_object}
    Call Method    ${invoke_object}    send    iptables -P INPUT ACCEPT\n
    wait until keyword succeeds    5x    1sec    Output contain match    ${invoke_object}    /
    Call Method    ${invoke_object}    send    iptables -P OUTPUT ACCEPT\n
    wait until keyword succeeds    5x    1sec    Output contain match    ${invoke_object}    /
    Call Method    ${invoke_object}    send    iptables -P FORWARD ACCEPT\n
    wait until keyword succeeds    5x    1sec    Output contain match    ${invoke_object}    /
    Call Method    ${invoke_object}    send    iptables -F\n
    wait until keyword succeeds    5x    1sec    Output contain match    ${invoke_object}    /

Start udp data transfer on appserver
    [Arguments]    ${destination_address}    ${trans_time}    ${port}    ${trans_throughput}    ${trans_length}    ${connection}=APPserver
    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${port}| awk '{print $2}' |xargs kill -9\n   connection=${connection}
    csn.send command
    ...    command=iperf -c ${destination_address} -u -t ${trans_time} -i 1 -p ${port} -P 1 -f m -b ${trans_throughput} -l ${trans_length} -T 64 &
    ...    connection=${connection}

Start udp data transfer on ue manage ip
    [Arguments]    ${destination_address}    ${trans_time}    ${port}    ${trans_throughput}    ${trans_length}    ${invoke_object}
    Call Method    ${invoke_object}    send    ps -ef|grep iperf|grep -v grep|grep ${port}| awk '{print $2}' |xargs kill -9\n
    sleep    1s
    Call Method    ${invoke_object}    send
    ...    iperf -c ${destination_address} -u -t ${trans_time} -i 1 -p ${port} -P 1 -f m -b ${trans_throughput} -l ${trans_length} -T 64 &\n
    sleep    1s
    ${status}    Call Method    ${invoke_object}    recv_ready
    ${output}    run keyword if    ${status}    Call Method    ${invoke_object}    recv    ${65535}

Start udp data via iperf
    [Arguments]    ${direction}    ${throughput}    ${duration}    ${iperf_port}    ${ue_index}=${0}
    ...            ${buffer_size}=1024B    ${appserver}=APPserver
    traffic_via_iperf.Connect to APPserver    alias=${appserver}
    Connect to control pc enhanced    ue_index=${ue_index}    cpc_ip=${cpc_ip}    cpc_usrname=${cpc_username}    cpc_passwd=${cpc_password}
    ${remote_pc_shell_channel}    Connect to ue manage ip    ue_index=${ue_index}
    ...    ue_manage_ip=${ue_manage_ip}    ue_manage_username=${ue_manage_username}    ue_manage_password=${ue_manage_password}
    ${destination_address}    run keyword if    '${direction.lower()}'=='dl'    Get the UE Ip address    ue_index=${ue_index}
    ...    ELSE    set variable    ${appserver_addr}
    run keyword if   '${direction.lower()}'=='dl'    run keywords    start udp port listening on ue manage ip    port=${iperf_port}
    ...    log_name=data_${direction}.txt    invoke_object=${remote_pc_shell_channel}    AND
    ...    Start udp data transfer on appserver    destination_address=${destination_address}
    ...    trans_time=${duration}    port=${iperf_port}    trans_throughput=${throughput}
    ...    trans_length=${buffer_size}    connection=${appserver}
    ...    ELSE IF    '${direction.lower()}'=='ul'    run keywords    start udp port listening on appserver    port=${iperf_port}
    ...    log_name=data_${direction}.txt    connection=${appserver}    AND
    ...    Start udp data transfer on ue manage ip    destination_address=${destination_address}
    ...    trans_time=${duration}    port=${iperf_port}    trans_throughput=${throughput}
    ...    trans_length=${buffer_size}    invoke_object=${remote_pc_shell_channel}
    [Teardown]    run keywords    Call Method    ${remote_pc_shell_channel}    close   AND
    ...    csn.disconnect    connection=cpc_${ue_index}    AND    csn.disconnect    connection=${appserver}

Stop udp data via iperf
    [Arguments]    ${direction}    ${iperf_port}    ${ue_index}=${0}    ${appserver}=APPserver
    traffic_via_iperf.Connect to APPserver    alias=${appserver}
    Connect to control pc enhanced    ue_index=${ue_index}    cpc_ip=${cpc_ip}    cpc_usrname=${cpc_username}    cpc_passwd=${cpc_password}
    ${remote_pc_shell_channel}    Connect to ue manage ip    ue_index=${ue_index}
    ...    ue_manage_ip=${ue_manage_ip}    ue_manage_username=${ue_manage_username}    ue_manage_password=${ue_manage_password}
    run keyword if    '${direction.lower()}'=='dl'    run keywords    Call Method    ${remote_pc_shell_channel}
    ...    send    ps -ef|grep iperf|grep -v grep|grep ${iperf_port}| awk '{print $2}' |xargs kill -9\n        AND
    ...    Call Method    ${remote_pc_shell_channel}    send    chmod 777 /tmp/data_${direction}.txt\n        AND
    ...    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${iperf_port}| awk '{print $2}' |xargs kill -9\n    connection=${appserver}
    ...    ELSE IF    '${direction.lower()}'=='ul'    run keywords    csn.execute
    ...    command=ps -ef|grep iperf|grep -v grep|grep ${iperf_port}| awk '{print $2}' |xargs kill -9\n    connection=${appserver}    AND
    ...    Call Method    ${remote_pc_shell_channel}    send    ps -ef|grep iperf|grep -v grep|grep ${iperf_port}| awk '{print $2}' |xargs kill -9\n
    [Teardown]    run keywords    Call Method    ${remote_pc_shell_channel}    close   AND
    ...    csn.disconnect    connection=cpc_${ue_index}    AND    csn.disconnect    connection=${appserver}

Start tcp data transfer on appserver
    [Arguments]    ${destination_address}    ${trans_time}    ${port}    ${process_num}    ${seg_size}=${1180}    ${window}=2M
    ...    ${connection}=APPserver
    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${port}| awk '{print $2}' |xargs kill -9    connection=${connection}
    sleep    3s
    csn.send command
    ...    command=iperf -c ${destination_address} -t ${trans_time} -i 1 -p ${port} -P ${process_num} -M ${seg_size} -w ${window} &
    ...    connection=${connection}
    csn.read_output_until    match=Transfer    timeout=20    connection=${connection}

Start tcp data transfer on ue manage ip
    [Arguments]    ${destination_address}    ${trans_time}    ${port}    ${process_num}    ${invoke_object}    ${seg_size}=${1180}    ${window}=2M
    Call Method    ${invoke_object}    send    ps -ef|grep iperf|grep -v grep|grep ${port}| awk '{print $2}' |xargs kill -9\n
    sleep    3s
    Call Method    ${invoke_object}    send
    ...    iperf -c ${destination_address} -t ${trans_time} -i 1 -p ${port} -P ${process_num} -M ${seg_size} -w ${window} &\n
    sleep    3s
    ${status}    Call Method    ${invoke_object}    recv_ready
    ${output}    run keyword if    ${status}    Call Method    ${invoke_object}    recv    ${65535}

start tcp port listening on appserver
    [Arguments]    ${port}    ${connection}=APPserver
    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${port}| awk '{print $2}' |xargs kill -9    connection=${connection}
    sleep    3s
    csn.send command    command=iperf -s -i 1 -p ${port}    connection=${connection}

start tcp port listening on ue manage ip
    [Arguments]    ${port}    ${invoke_object}
    Call Method    ${invoke_object}    send    ps -ef|grep iperf|grep -v grep|grep ${port}| awk '{print $2}' |xargs kill -9\n
    sleep    3s
    Call Method    ${invoke_object}    send    iperf -s -i 1 -p ${port} &\n
    sleep    3s
    ${status}    Call Method    ${invoke_object}    recv_ready
    ${output}    run keyword if    ${status}    Call Method    ${invoke_object}    recv    ${65535}
    log    ${output}

Start tcp data via iperf
    [Arguments]    ${direction}    ${throughput}    ${duration}    ${iperf_port}    ${ue_index}=${0}
    ...            ${process_num}=${5}    ${seg_size}=${1180}    ${window}=2M    ${appserver}=APPserver
    traffic_via_iperf.Connect to APPserver    alias=${appserver}
    Connect to control pc enhanced    ue_index=${ue_index}    cpc_ip=${cpc_ip}    cpc_usrname=${cpc_username}    cpc_passwd=${cpc_password}
    ${remote_pc_shell_channel}    Connect to ue manage ip    ue_index=${ue_index}
    ...    ue_manage_ip=${ue_manage_ip}    ue_manage_username=${ue_manage_username}    ue_manage_password=${ue_manage_password}
    ${destination_address}    run keyword if    '${direction.lower()}'=='dl'    Get the UE Ip address    ue_index=${ue_index}
    ...    ELSE    set variable    ${appserver_addr}
    ${connection}    set variable if    '${direction.lower()}'=='dl'    ${appserver}    ue_manage_${ue_index}
    run keyword if   '${direction.lower()}'=='dl'    run keywords    start tcp port listening on ue manage ip    port=${iperf_port}
    ...    invoke_object=${remote_pc_shell_channel}    AND
    ...    Start tcp data transfer on appserver    destination_address=${destination_address}    trans_time=${duration}
    ...    port=${iperf_port}    process_num=${process_num}    seg_size=${seg_size}    window=${window}    connection=${appserver}
    ...    ELSE IF    '${direction.lower()}'=='ul'    run keywords    start tcp port listening on appserver    port=${iperf_port}
    ...    connection=${appserver}    AND
    ...    Start tcp data transfer on ue manage ip    destination_address=${destination_address}    trans_time=${duration}
    ...    port=${iperf_port}    process_num=${process_num}    invoke_object=${remote_pc_shell_channel}    seg_size=${seg_size}    window=${window}
    [Teardown]    run keywords    Call Method    ${remote_pc_shell_channel}    close   AND
    ...    csn.disconnect    connection=cpc_${ue_index}    AND    csn.disconnect    connection=${appserver}

Stop tcp data via iperf
    [Arguments]    ${direction}    ${iperf_port}    ${ue_index}=${0}    ${appserver}=APPserver
    traffic_via_iperf.Connect to APPserver    alias=${appserver}
    Connect to control pc enhanced    ue_index=${ue_index}    cpc_ip=${cpc_ip}    cpc_usrname=${cpc_username}    cpc_passwd=${cpc_password}
    ${remote_pc_shell_channel}    Connect to ue manage ip    ue_index=${ue_index}
    ...    ue_manage_ip=${ue_manage_ip}    ue_manage_username=${ue_manage_username}    ue_manage_password=${ue_manage_password}
    run keywords    Call Method    ${remote_pc_shell_channel}
    ...    send    ps -ef|grep iperf|grep -v grep|grep ${iperf_port}| awk '{print $2}' |xargs kill -9\n    AND
    ...    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${iperf_port}| awk '{print $2}' |xargs kill -9    connection=${appserver}
    [Teardown]    run keywords    Call Method    ${remote_pc_shell_channel}    close   AND
    ...    csn.disconnect    connection=cpc_${ue_index}    AND    csn.disconnect    connection=${appserver}

start udp port listening on appserver
    [Arguments]    ${port}    ${log_name}    ${connection}=APPserver
    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${port}| awk '{print $2}' |xargs kill -9\n    connection=${connection}
    sleep    3s
    csn.execute    command=rm -rf /tmp/${log_name}\n    connection=${connection}
    sleep    3s
    csn.send command    command=iperf -u -s -i 1 -p ${port} > /tmp/${log_name} &\n    connection=${connection}

start udp port listening on ue manage ip
    [Arguments]    ${port}    ${log_name}    ${invoke_object}
    Call Method    ${invoke_object}    send    ps -ef|grep iperf|grep -v grep|grep ${port}| awk '{print $2}' |xargs kill -9\n
    sleep    3s
    Call Method    ${invoke_object}    send    rm -rf /tmp/${log_name}\n
    sleep    3s
    Call Method    ${invoke_object}    send    iperf -u -s -i 1 -p ${port} > /tmp/${log_name} &\n
    sleep    3s
    ${status}    Call Method    ${invoke_object}    recv_ready
    ${output}    run keyword if    ${status}    Call Method    ${invoke_object}    recv    ${65535}
    log    ${output}

downlod iperf log on appserver
    [Arguments]    ${log_path}=${OUTPUT_DIR}    ${log_name}=data_ul.txt    ${connection}=APPserver
    ${time_stamp}    DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${full_ul_log_name}   Set Variable    ${log_path}/data_ul_${time_stamp}.txt
    traffic_via_iperf.Connect to APPserver    alias=${connection}
    sleep    3s
    ${connection}    csn.get_connection_by_alias    alias=${connection}
    sleep    3s
    ${channel}    Call Method    ${connection}    invoke_shell
    Call Method    ${channel}
    ...    send    scp -o StrictHostKeyChecking\=no /tmp/${log_name} ${vm_username}@${vm_addr}:${full_ul_log_name}\n
    Sleep  2
    Call Method    ${channel}    recv    ${65535}
    Sleep  2
    Call Method    ${channel}    send    ${vm_password}\n
    Sleep  2
    Call Method    ${channel}    recv    ${65535}
    [Teardown]    csn.disconnect    connection=${connection}
    [Return]    ${full_ul_log_name}

downlod iperf log on ue manage ip
    [Arguments]    ${log_path}=${OUTPUT_DIR}    ${log_name}=data_dl.txt    ${ue_index}=${0}
    ${time_stamp}    DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${full_dl_log_name}   Set Variable    ${log_path}/data_dl_${time_stamp}.txt
    Connect to control pc enhanced    ue_index=${ue_index}    cpc_ip=${cpc_ip}    cpc_usrname=${cpc_username}    cpc_passwd=${cpc_password}
    ${connection}    csn.get_connection_by_alias    alias=cpc_${ue_index}
    @{split_ue_ip}    string.split string    ${ue_manage_ip}    separator=.
    ${grep_ue_ip}    Set Variable    ${split_ue_ip}[0].${split_ue_ip}[1].${split_ue_ip}[2]
    ${output}    csn.execute    command=route PRINT -4 | grep ${grep_ue_ip} | tail -1 | awk '{print $4}'    connection=${connection}
    @{split_big_ue_ip}    string.split string    ${output}    separator=.
    ${ue_pc_private_ip}   Set Variable    ${grep_ue_ip}.${split_big_ue_ip}[3]
    ${ue_pc_private_ip}    Replace String    ${ue_pc_private_ip}    \r\n    ${EMPTY}
    ${remote_pc_shell_channel}    Call Method    ${connection}    invoke_shell
    Call Method    ${remote_pc_shell_channel}    send    ssh -o StrictHostKeyChecking\=no ${ue_manage_username}@${ue_manage_ip}\n
    wait until keyword succeeds    30x    2sec    Output contain match    ${remote_pc_shell_channel}    password
    Call Method    ${remote_pc_shell_channel}    send    ${ue_manage_password}\n
    wait until keyword succeeds    30x    2sec    Output contain match    ${remote_pc_shell_channel}    \$
    Call Method    ${remote_pc_shell_channel}    send    su\n
    wait until keyword succeeds    30x    2sec    Output contain match    ${remote_pc_shell_channel}    Password
    Call Method    ${remote_pc_shell_channel}    send    ${ue_manage_root_password}\n
    wait until keyword succeeds    30x    2sec    Output contain match    ${remote_pc_shell_channel}    \#
    Sleep  2
    Call Method    ${remote_pc_shell_channel}
    ...    send    scp -o StrictHostKeyChecking\=no /tmp/${log_name} ${cpc_username}@${ue_pc_private_ip}:/home/${cpc_username}\n
#    Sleep  2
#    Call Method    ${remote_pc_shell_channel}    recv    ${65535}
    wait until keyword succeeds    30x    2sec    Output contain match    ${remote_pc_shell_channel}    password
#    Sleep  2
    Call Method    ${remote_pc_shell_channel}    send    ${cpc_password}\n
    Sleep  2
    Call Method    ${remote_pc_shell_channel}    recv    ${65535}
    csn.connect to    hostname=${vm_addr}    username=${vm_username}    password=${vm_password}   alias=test_pc
    ${connection2}    csn.get_connection_by_alias    alias=cpc_${ue_index}
    ${channel}    Call Method    ${connection2}    invoke_shell
    Sleep  2
    Call Method    ${channel}
    ...    send    scp -o StrictHostKeyChecking\=no /home/${cpc_username}/${log_name} ${vm_username}@${vm_addr}:${full_dl_log_name}\n
#    Sleep  2
#    Call Method    ${channel}    recv    ${65535}
    wait until keyword succeeds    30x    2sec    Output contain match    ${channel}    password
#    Sleep  2
    Call Method    ${channel}    send    ${vm_password}\n
    Sleep  2
    Call Method    ${channel}    recv    ${65535}
    [Teardown]    csn.disconnect    cpc_${ue_index}
    [Return]    ${full_dl_log_name}

check DL throughput for CPE
    [Arguments]    ${full_log_path}    ${dl_expect}=${0}
    iperf_tput.create_iperf_client_udp_throughput    log=${full_log_path}    alias=iperf_client
    ${list_of_throughputs}    Create list  iperf_client
    iperf_tput.analyze    throughputs=${list_of_throughputs}
    ${client_output}    iperf_tput.get_throughput    throughput=iperf_client
    log to console    \n average dl throughput:${client_output[0]['average']['value']}
    should be true    ${client_output[0]['average']['value']} > ${dl_expect}

check UL throughput for CPE
    [Arguments]    ${full_log_path}    ${ul_expect}=${0}
    iperf_tput.create_iperf_server_udp_throughput    log=${full_log_path}    alias=iperf_server
    ${list_of_throughputs}    Create list  iperf_server
    iperf_tput.analyze    throughputs=${list_of_throughputs}
    ${server_output}    iperf_tput.get_throughput    throughput=iperf_server
    log to console    \n average ul throughput:${server_output[0]['average']['value']}
    should be true    ${server_output[0]['average']['value']} > ${ul_expect}

Get UE IP Successfully
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    [Arguments]  ${ue_index}=${0}
    ${ue_info}    ute_ue.get_ue_info    UE_${ue_index}
    ${ips}    get dictionary keys    ${ue_info['ips']}
    ${ue_ip}    set variable    127.0.0.1
    FOR    ${ip_info}    IN    @{ips}
        ${status}    run keyword and return status    Should Contain Any    ${ip_info}    data    ccmni    default
        ${ue_ip}    set variable if    ${status}    ${ue_info['ips']['${ip_info}'][0]}    ${ue_ip}
    END
    ${ue_ip}    set variable if    '${ue_ip}'=='None'    127.0.0.1    ${ue_ip}
    log to console    \nue_index ${ue_index} ip is ${ue_ip}
    Should Not Contain      ${ue_ip}      127.0.0.1
    [Return]  ${ue_ip}

Get UE PCI Successfully
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    [Arguments]  ${ue_index}=${0}    ${pci}=${0}
    ${ue_info}    ute_ue.get_ue_info    UE_${ue_index}
    ${result}    ${attach_pci}    run keyword and ignore error   get from dictionary    ${ue_info}    pci
    return from keyword if    '${result}'=='FAIL'
    log to console    \nue_index ${ue_index} attach pci is ${attach_pci}
    run keyword if    '${pci}'!='${0}'    should be equal as strings    ${attach_pci}    ${pci}

Check UE INFO Successfully
    [Documentation]  Auther: tingting.zhong@nokia-sbell.com
    [Arguments]  ${ue_index}=${0}    ${pci}=${0}
    Get UE PCI Successfully    ue_index=${ue_index}    pci=${pci}
    Get UE IP Successfully    ue_index=${ue_index}
