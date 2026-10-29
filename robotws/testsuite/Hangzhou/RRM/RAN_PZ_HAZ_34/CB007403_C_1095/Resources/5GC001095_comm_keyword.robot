*** Settings ***
Documentation
...   author: Hongyu.Jiang@nokia-sbell.com
...   contact: Jiang Hongyu

Library     taf.sbts.oam.coam.admin       WITH NAME    coam
Library     taf.transport.ssh      WITH NAME    ssh
Library           taf.config.scf.interface.scf     WITH NAME   scf
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/Analysis_Viavi_Log.py
Library     Analysis_Viavi_Log.Viavi_Log_analysis     WITH NAME    Viavi_Log_analysis
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/viavi_common_keyword.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/container_log_capturing.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot



*** Variables ***
${gnb_ip1}                ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${gnb_ip2}                ${tl.gnbs[1].dus[0].f1_m_ip_addr}
${eNB_ip}                 ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${gNB_username}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gNB_password}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${gNB_ssh_username}       ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${gNB_ssh_password}       ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${eNB_ssh_user}           ${tl.enbs[0].airscale.common_units[0].lmp_connection.username}
${eNB_ssh_pass}           ${tl.enbs[0].airscale.common_units[0].lmp_connection.password}
${luashark_path}          /opt/ute/luashark/luashark_script/generated_luashark/luashark.lua
${TEST_PC_IP}             ${tl.test_pc.default_ssh_connection_details.addr}
${TEST_PC_USERNAME}       ${tl.test_pc.default_ssh_connection_details.username}
${TEST_PC_PASSWORD}       ${tl.test_pc.default_ssh_connection_details.password}
${LOG_PATH}               ${output_dir}
${CURDIR_path}            ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}
${E500_SCRIPTS_BASE}      ${CURDIR}/E500_scripts
${E500_IP}                ${tl.ues[0].tma_host.addr}
${E500_USER}              ${tl.ues[0].tma_host.username}
${E500_PW}                ${tl.ues[0].tma_host.password}
${TMA_SSH_ALIAS}          TEST_PC
${Server_ip}              ${tl.ues[0].iperf_details.ssh_connection_details.addr}
${ul_ports}               ${tl.ues[0].iperf_details.ports[0]}
${dl_ports}               ${tl.ues[0].iperf_details.ports[1]}
#${gnb_default_scf1}       ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/SCF_Trunk_gNB1.xml
#${gnb_default_scf2}       ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/SCF_Trunk_gNB2.xml
${gNB_BTS_ID1}             ${tl.gnbs[0].global_bts_id}
${gNB_BTS_ID2}             ${tl.gnbs[1].global_bts_id}


*** Keywords ***
########### Commission SCF #################
Set Default scf name
    [Arguments]  ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${gNB_ip1}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${version}    coam.get_sw_version    connection=${connection}
    ${version_list}    split string    ${version}    _
    ${if_common_load}     run keyword and return status    should contain    ${version_list[0]}    SBTS22R1
    ${default_scf}    set variable if    ${if_common_load}    ${CURDIR_path}SCF_SBTS00.xml
    ...    ${CURDIR_path}SCF_0_800_DU.xml
    set suite variable    ${default_scf}
    log to console   ${default_scf}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}

Setup Commission SCF
    [Arguments]  ${host_ip}    ${scf_path}    ${connection}
    Connect to gnb coam via ssl    bts_host=${host_ip}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    COAM Commission with scf file    scf_file_path=${scf_path}    connection=${connection}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Get BTS Version And SCF Path
    [Arguments]    ${gNB_ip}    ${gnbnumber}   ${CURDIR_path}=${CURDIR_path}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${version}    coam.get_sw_version    connection=${connection}
    log to console    bts version=${version}
    ${scf_name}    Covert_BTS_Version    version=${version}    gnbnumber=${gnbnumber}
    ${default_scf}    set variable    ${CURDIR_path}/${scf_name}
    [Return]    ${default_scf}
    [Teardown]    Run keyword and ignore error     coam.teardown      connection=${connection}

Reset Station
    [Arguments]  ${host_ip}=${gNB_ip1}    ${connection}=GNB_OAM    ${timeout}=20min
    Connect to gnb coam via ssl    bts_host=${host_ip}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    Log to console    Restart Station
    coam.reset_site   timeout=${timeout}  connection=${connection}

Check BTS Should Be Normal
    [Timeout]  15min
    [Arguments]    ${host_ip}    ${connection}=GNB_OAM
    Log To Console  Check BTS Should Be Normal
    Connect to gnb coam via ssl    bts_host=${host_ip}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    Wait Until BTS Should Be Normal    connection=${connection}
    [Teardown]   Run Keyword And Ignore Error   coam.teardown    connection=${connection}

Wait Until BTS Should Be Normal
    [Arguments]   ${retry}=800s    ${retry_interval}=10s    ${connection}=default
    [Documentation]   Wait Until CBTS Status Should Be Normal, if CBTS status is abnormal during retry time,
    Wait Until Keyword Succeeds   ${retry}     ${retry_interval}    Check cell on air    alias=${connection}
    log to console    BTS status is normal

Gnb Cell Should Be Onair
    [Arguments]  ${alias}=default  ${cell_type }=nr
    [Documentation]  Gnb Cell Should Be Onair, check method is via REST
    ${bts_info}   coam.get_bts_info   connection=${alias}   timeout=10
    ${cell_list}    Set Variable   ${bts_info['cells']['nr']}
    FOR    ${cell}    IN    @{cell_list}
        ${status}   Set Variable   ${cell['status']}
        Should Contain   ${status['proceduralStatus']}   configured
        Should Contain   ${status['availabilityStatus']}   Online
        Should Contain   ${status['operationalState']}   Enabled
        Should Contain   ${status['usageState']}   Active
    END

Check cell on air
    [Arguments]  ${alias}
    log_to_console    Check cell on air
    ${status}            coam.get_bts_statuses       connection=${alias}
    ${bts_status}        get from dictionary     ${status}     proceduralState
    should be equal      ${bts_status}      OnAir

########## modify parameter ###################
Modify Value On DU
    [Timeout]  20min
    [Arguments]    ${host_ip}    ${structure_modify_list}=None    ${common_modify_list}=None    ${keywords_list}=None    ${connection}=coam_admin
    ...    ${class_name}=None   ${is_structure}=${True}    ${is_common}=${True}    ${structure_index}=0
    Connect to gnb coam via ssl    bts_host=${host_ip}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    run keyword if  ${is_structure}    Modify Structure parameter via Coam    class_name=${class_name}   connection=${connection}
    ...    modify_list=${structure_modify_list}    keywords_list=${keywords_list}    index=${structure_index}
    run keyword if  ${is_common}    Modify Common parameter via Coam    input_list=${common_modify_list}    connection=${connection}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}

Modify Structure parameter via Coam
    [Arguments]   ${class_name}   ${connection}   ${modify_list}   ${keywords_list}    ${index}=0
    ${get_managed_objects}     coam.get_managed_objects     class_name=${class_name}    connection=${connection}
    ${output_dict_list}    Return_Structure_Mofify_Value    input_list=${get_managed_objects}    modify_list=${modify_list}
    ...    keywords_list=${keywords_list}    index=${index}
    FOR    ${item}  IN  @{output_dict_list}
        ${dict_value}    Get Content From Input Dict    input_dict=${item}
        coam.Perform Parameter Recommissioning    dist_name=${dict_value}[0]   parameter=${dict_value}[1]   value=${dict_value}[2]
        ...    operation=update    skip_parameter_relation_errors=${True}    should_activate=${True}    connection=${connection}
        sleep  2min
    END

Modify Common parameter via Coam
    [Arguments]  ${input_list}    ${connection}
    FOR    ${item}  IN    @{input_list}
        ${dict_value}    Get Content From Input Dict    input_dict=${item}
        coam.Perform Parameter Recommissioning    dist_name=${dict_value}[0]   parameter=${dict_value}[1]   value=${dict_value}[2]
        ...    operation=update    skip_parameter_relation_errors=${True}    should_activate=${True}    connection=${connection}
        sleep  2min
    END

Get Content From Input Dict
    [Arguments]  ${input_dict}
    ${dist_name}    get from dictionary     ${input_dict}    dist_name
    ${parammeter}    get from dictionary    ${input_dict}    parameter
    ${new_value}     get from dictionary    ${input_dict}    value
    ${value_list}    create list    ${dist_name}    ${parammeter}    ${new_value}
    [Return]  ${value_list}

ENB_and_GNB_Modify_Para
    [Documentation]  Modify eNB and gNB parameter
    [Arguments]    ${enb_para}    ${gnb_para}    ${gnb_host_ip}    ${connection}
    Kill IPSL process
    Check BTS Should Be Normal    host_ip=${gnb_host_ip}    connection=${connection}
    log to console    Modify parameter on ENB
    run keyword if     ${enb_para}!=None   Modify Value On DU    host_ip=${eNB_ip}    common_modify_list=${enb_para}
    ...    is_structure=${False}
    log to console    Modify parameter on GNB
    run keyword if     ${gnb_para}!=None    Modify Value On DU    host_ip=${gnb_host_ip}    common_modify_list=${gnb_para}
    ...    is_structure=${False}
    Check BTS Should Be Normal    host_ip=${gnb_host_ip}    connection=${connection}

Modify SCF file and create new
    [Arguments]  ${default_scf}    ${para_list}    ${new_scf_name}
    log to console      start modify scf offline...
    scf.load_scf       file_path=${default_scf}
    sleep   3s
    FOR     ${item}    IN    @{para_list}
        ${dist_name}    Get From Dictionary    ${item}    dist_name
        ${p_name}    Get From Dictionary    ${item}    p_name
        ${value}    Get From Dictionary    ${item}    value
        modify_scf_element     dist_name=${dist_name}    p_name=${p_name}     value=${value}
    END
    ${new_scf}    set variable    ${output_dir}/${new_scf_name}
    scf.save_scf        file_path=${new_scf}
    log to console      modify successful,${default_scf} will be commissioned.
    [Return]  ${new_scf}

######################## Log Collection  ###################################
Start wireshark capture from gNB or Enb
    [Documentation]    Description: Start X2 log capture on gNB or Enb
    [Arguments]     ${host_ip}    ${filename}=enb_tcpdump.pcap   ${interface}=any    ${alias}=ASIK Master    ${gnb}=${False}
    log to console    start capture wireshark log...
    ssh.Connect to    hostname=${host_ip}    username=${gNB_ssh_username}    password=${gNB_ssh_password}    alias=${alias}
    ${log_full_path_gnb}     set variable if    '${gnb}'=='True'    /ram/${filename}    /tmp/${filename}
    ssh.send command    command=ps -ef |grep tcpdump |grep -v grep |grep ${interface} |awk '{print $2}' |xargs kill -2    connection=${alias}
    sleep    2s
    run keyword if    '${gnb}'=='True'    SSH to CPRT for gNB    filename=${log_full_path_gnb}    alias=${alias}
    run keyword if    '${gnb}'!='True'    ssh.send command    command=nohup tcpdump -i ${interface} -s 0 -w ${log_full_path_gnb}
    ...     connection=${alias}
    sleep    2s
    Trace capturing process should be triggered    log_prefix=${filename}    connection_alias=${alias}
    [Return]    ${alias}
    [Teardown]    run keyword and ignore error    ssh.Disconnect    connection=${alias}

SSH to CPRT for gNB
    [Arguments]    ${filename}    ${alias}=ASIK Master
    ssh.send command    command=cd /ram && ls -l | grep CPRT | cut -d "_" -f 2|cut -d " " -f 1|head -1      connection=${alias}
    ${readOutput}=     ssh.readOutput    connection=${alias}
    ssh.send command
    ...        command=cd /ram && lxc-attach -n ${readOutput.split("\n")[0]} && nohup tcpdump -i any -w ${filename} &>/dev/null &
    ...        connection=${alias}

Stop wireshark capture from gNB or Enb
    [Documentation]    Description: Stop X2 log capture on gNB or Enb, and download x2 log to testpc
    [Arguments]     ${host_ip}    ${filename}=enb_tcpdump.pcap    ${log_path}=${LOG_PATH}    ${index}=${0}   ${alias}=ASIK Master   ${gnb}=${False}
    log to console    stop capture wireshark log.
    ssh.Connect to    hostname=${host_ip}    username=${gNB_ssh_username}    password=${gNB_ssh_password}    alias=${alias}
    Stop trace capturing    log_prefix=${filename}    connection_alias=${alias}
    ${log_full_path_ute}    set variable     ${LOG_PATH}/${filename}
    log to console     pcap log saved path:${log_full_path_ute}
    ssh.download_file   remote_path=/tmp/${filename}   local_path=${log_full_path_ute}   connection=${alias}
    ssh.execute    command=rm /tmp/${filename}    connection=${alias}
    [Return]    ${log_full_path_ute}
    [Teardown]    run keyword and ignore error    ssh.Disconnect    connection=${alias}


Start Collect Tcpdump
    [Arguments]  ${host_ip}    ${host_name}=${eNB_ssh_user}    ${host_pass}=${eNB_ssh_pass}    ${log_name}=X2.pcap    ${interface}=any
    ...    ${conn}=Tcpdump
    ssh.Connect to    hostname=${host_ip}     username=${host_name}    password=${host_pass}    alias=${conn}
    ssh.send_command    command=ps -ef | grep tcpdump | awk '{print $2}' | xargs kill -9    connection=${conn}
    sleep    2s
    ssh.send command    command=nohup tcpdump -i ${interface} -w /tmp/${log_name} &>/dev/null &   connection=${conn}
    sleep    30s
    [Teardown]    run keyword and ignore error    ssh.Disconnect    connection=${conn}

Stop Collect Tcpdump
    [Arguments]  ${host_ip}    ${host_name}=${eNB_ssh_user}    ${host_pass}=${eNB_ssh_pass}    ${log_name}=X2.pcap    ${conn}=Tcpdump
    ssh.Connect to    hostname=${host_ip}     username=${host_name}    password=${host_pass}    alias=${conn}
    ssh.send_command    command=ps -ef | grep tcpdump | awk '{print $2}' | xargs kill -9    connection=${conn}
    ssh.download_file   remote_path=/tmp/${log_name}   local_path=${LOG_PATH}/${log_name}   connection=${conn}
    Sleep    60s
    ssh.execute    command=rm /tmp/${log_name}    connection=${conn}
    [Teardown]    run keyword and ignore error    ssh.Disconnect    connection=${conn}

Save Snapshot
    [Arguments]    ${host_ip}    ${connection}=cOAM    ${timeout}=10min
    run keyword and ignore error     coam.teardown    connection=${connection}
    Connect to gnb coam via ssl    bts_host=${host_ip}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${snapshot_path}    Get Snapshot From BTS    alias=${connection}    timeout=${timeout}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}
    [Return]    ${snapshot_path}

Trigger measurement
    [Arguments]    ${message}    ${tm500_alias}=e500
    log to console  Start to trigger A3 measurement report
    ${cmd_a3_mr}    catenate    forw mte NrRrcAptTriggerMeasReport ${message}
    log to console    ${cmd_a3_mr}
    ${response}    tm500_remote.send_command    command=${cmd_a3_mr}    alias=${tm500_alias}
    ${response1}    tm500_remote.send_command    command=forw mte Activate -1    alias=${tm500_alias}
    sleep    15s


match pattern in response
    [Arguments]    ${pattern}    ${response}    ${e500_alias}=e500
    ${response_extra}    tm500_remote.read_responses    alias=${e500_alias}
    ${response}    Catenate    ${response}    ${response_extra}
    Should contain    ${response}    ${pattern}    msg=String "${pattern}" is not found

Kill IPSL process
    [Arguments]  ${connect}=TEST_PC
    ssh.Connect to    hostname=${E500_IP}    username=${E500_USER}    password=${E500_PW}    alias=${connect}
    ssh.send command    command=taskkill /f /im "ips32.exe"       connection=${connect}
    [Teardown]    Run Keyword And Ignore error    ssh.disconnect    connection=${connect}

Start logging on cobham and Return Folder
    [Documentation]  Author: Jiang Hongyu
    ...              Description: Start logging on cobham TMA so that the protocol logs can be captured
    ...                           And Return Log path
    [Arguments]    ${connection}=${TMA_APP_ALIAS}
    ${output_start_logging}    tm500_remote.send_command    command=#$$START_LOGGING    alias=${connection}
    should contain    ${output_start_logging}      START_LOGGING 0x00 OK    msg=Start logging on cobham failed
    ${logs_path}    Get_Viavi_CSV_Log_Path    log_str=${output_start_logging}
    log to console    ${output_start_logging}
    log to console    ${logs_path}
    [Return]  ${logs_path}

Download Viavi Log
    [Documentation]
    [Arguments]  ${logs_path}    ${retry}=2min    ${time}=40s    ${connect}=Control_PC
    log to console    ${logs_path}
    ssh.Connect to    hostname=${E500_IP}    username=${E500_USER}    password=${E500_PW}    alias=${connect}
    ${new_path}    set variable    /cygdrive/c/Users/nokia5G/Documents/CSV/${logs_path}[1]
    ssh.send command    command=mkdir ${new_path}    connection=${connect}
    Wait Until Keyword Succeeds   ${retry}    10s    Check CSV file is exsit    csv_path='${logs_path}[0]'    connection=${connect}
    sleep    10s
    ssh.send command    command=cd '${logs_path}[0]';scp *.csv ${new_path}     connection=${connect}
    sleep    ${time}
    Copy Viavi Log    logs_path=${new_path}
    ssh.send command    command=rm -rf ${new_path}    connection=${connect}
    ${ute_path}    set variable    ${output_dir}/${logs_path}[1]
    [Return]  ${ute_path}
    [Teardown]    Run Keyword And Ignore error    ssh.disconnect    connection=${connect}

Check CSV file is exsit
    [Arguments]  ${csv_path}    ${connection}
    ${file_list}   ssh.execute   ls ${csv_path}   connection=${connection}
    ${file_list}    Split String    ${file_list}    \r\n
    ${csv_list}    Get_csv_is_exsit    input_list=${file_list}
    ${csv_list_len}    Get Length    ${csv_list}
    should be equal as integers    ${csv_list_len}    ${2}    msg=Don't have all csv file
    [Return]   ${csv_list}

Copy Viavi Log
    [Documentation]
    [Arguments]  ${logs_path}    ${ute_path}=${output_dir}    ${time}=120s    ${connect}=Test_PC
    ssh.Connect to    hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}    alias=${connect}
    ssh.send command    command=sshpass -p ${E500_PW} scp -r ${E500_USER}@${E500_IP}:${logs_path} ${ute_path}    connection=${connect}
    sleep    ${time}
    [Teardown]  Run Keyword And Ignore error    ssh.disconnect    connection=${connect}

Check_TP_And_Bler
    [Arguments]  ${dir_path}    ${ul_min_tp}    ${ul_max_tp}    ${dl_min_tp}    ${dl_max_tp}    ${bler_value}    ${row}=${10}
    ${ul_tp_result}   Viavi_Log_analysis.Check_One_UE_TP_Stable    dir_path=${dir_path}    direction=ul    check_value=${ul_max_tp}
    ...    expect_num=${5}    UE_ID=0
    ${dl_tp_result}   Viavi_Log_analysis.Check_One_UE_TP_Stable    dir_path=${dir_path}    direction=dl    check_value=${dl_max_tp}
    ...    expect_num=${5}    UE_ID=0
    ${ul_bler_result}    Viavi_Log_analysis.Check_One_UE_Bler_Stable    dir_path=${dir_path}    direction=ul    check_value=${bler_value}
    ...    expect_num=${5}    UE_ID=0
    ${dl_bler_result}    Viavi_Log_analysis.Check_One_UE_Bler_Stable    dir_path=${dir_path}    direction=dl    check_value=${bler_value}
    ...    expect_num=${5}    UE_ID=0
    ${ul_start_time}    Viavi_Log_analysis.Check_One_UE_Start_TP_Time    dir_path=${dir_path}    direction=ul    row=${row}
    ...    min=${ul_min_tp}    max=${ul_max_tp}
    ${dl_start_time}    Viavi_Log_analysis.Check_One_UE_Start_TP_Time    dir_path=${dir_path}    direction=dl    row=${row}
    ...    min=${dl_min_tp}    max=${dl_max_tp}
    Run Keyword And Continue On Failure    Should Be Equal    ${ul_tp_result}    ${True}
    Run Keyword And Continue On Failure    Should Be Equal    ${dl_tp_result}    ${True}
    Run Keyword And Continue On Failure    Should Be Equal    ${ul_bler_result}    ${True}
    Run Keyword And Continue On Failure    Should Be Equal    ${dl_bler_result}    ${True}
    Run Keyword And Continue On Failure    Should Be Equal    ${ul_start_time}    ${True}
    Run Keyword And Continue On Failure    Should Be Equal    ${dl_start_time}    ${True}


########################### About traffic ########################################
Start UDP UL traffic
    [Documentation]  Start udp ul traffic
    [Arguments]    ${host_ip}    ${throughput}    ${traffic_time}    ${port}    ${thread}=1    ${connection}=${TMA_SSH_ALIAS}
    ssh.connect to    hostname=${E500_IP}    username=${E500_USER}    password=${E500_PW}    alias=${connection}
    enable PPPoE connection    TMA_SSH_ALIAS=${connection}
    ${cmd_start_iperf_client}    Catenate    iperf -u -c ${host_ip} -b ${throughput}M -t ${traffic_time} -i 1 -p ${port} -P ${thread}
    ssh.send command     command=${cmd_start_iperf_client}    connection=${connection}
    Log to console    Start UL traffic
    [Teardown]  Run keyword and ignore error    ssh.disconnect    connection=${connection}

DL traffic start iperf client from app server with real epc
    [Documentation]    Author: Ding Binmei
    ...                ${UE_IP} is returned from UE attach
    ...                Need to configure iperf path to cygwin
    ...                DL port value range: 54000~55000
    [Arguments]    ${throughput}    ${traffic_time}    ${port}=${tl.ues[0].iperf_details.port}    ${dl_host_ip}=${UE_IP}    ${length}=${1024}
    wait until keyword succeeds    2 min    10 s    traffic_via_iperf.Connect to APPserver
    Start iperf client    throughput=${throughput}    traffic_time=${traffic_time}
    ...                   host_ip=${dl_host_ip}    length=${length}    port=${port}    connection=APPserver
    log to console    Start DL traffic
    ${is_iperf_process_started}    Is iperf process exists on app server    port=${port}
    Should be true  ${is_iperf_process_started}    msg=Iperf client process is not started on app server side for port ${port}
    [Teardown]    Run keyword and ignore error    traffic_via_iperf.Disconnect from app server

enable PPPoE connection
    [Documentation]    activates the PPPoE tunnel with E500 thanks to ssh opened connection.
    ...                PPPoE tunnel is required to be able to launch DL iperf in reception on the Viavi PC
    ...                the PPPoE configured name under the PC shall be TM500
    ...                the alias of the ssh connection used is ViaviSshConnection from above Viavi PC connect keyword
    ...                PPPoE set up action in script must be performed in background as the UE attach under TMA should
    ...                be launch in // of the PPPoE set up
    [Arguments]    ${TMA_SSH_ALIAS}
    ssh.send command   rasdial TM500    connection=${TMA_SSH_ALIAS}
    ${output}    ssh.read output    connection=${TMA_SSH_ALIAS}
    Log to console    ${output}
    should contain    ${output}    Command completed successfully

Start traffic
    [Documentation]  start ul and dl traffic
    [Arguments]  ${ul_throughput}    ${dl_throughput}    ${traffic_time}    ${appserver_ip}=${Server_ip}
    ...    ${ul_port}=${ul_ports}    ${dl_port}=${dl_ports}    ${if_ul}=${True}    ${if_dl}=${True}
    run keyword if    ${if_ul}    Start UDP UL traffic    host_ip=${appserver_ip}    throughput=${ul_throughput}    traffic_time=${traffic_time}
    ...    port=${ul_port}
    run keyword if    ${if_dl}    DL traffic start iperf client from app server with real epc    throughput=${dl_throughput}
    ...    traffic_time=${traffic_time}    port=${dl_port}    dl_host_ip=${UE_IP}    length=${1024}


######################## Check Point  ##############################################
Convert pcap to text
    [Arguments]  ${source}   ${target}   ${filter}    ${connection}
    ssh.send_command
    ...  command=nice tshark -X lua_script:${luashark_path} -V -r ${source} -T text > ${target} -Y '${filter}'   connection=${connection}
    ssh.await execution end  connection=${connection}  timeout=30min

Convert pcap file to txt
    [Arguments]    ${source}   ${target}   ${filter}    ${connection}=TEST_PC
    ssh.Connect to     hostname=${TEST_PC_IP}   username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}  alias=${connection}
    Convert pcap to text    source=${source}    target=${target}    connection=${connection}    filter=${filter}
    [Teardown]  run keyword and ignore error  ssh.Disconnect	connection=${connection}

Get PM counter result
    [Arguments]    ${counter_id}    ${BTS}=BTS    ${CELLS}=CELLS    ${NRCELL}=NRCELL-1    ${counter_object}=NX2CC
    ...    ${host_ip}=${gNB_ip1}    ${connection}=GNB_COM
    Connect to gnb coam via ssl    bts_host=${host_ip}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${counter_values}    coam.get pm counters   couter_ids=${counter_id}    connection=${connection}
    ${result}    Get Dictionary Values   ${counter_values['${BTS}']['${CELLS}']['${NRCELL}']['${counter_object}']['${counter_id}']}
    [Return]    ${result}
    [Teardown]    Run Keyword And Ignore Error   coam.teardown      connection=${connection}


####################### Case Keyword  #######################################
Commission 2GNB SCF
    [Arguments]
    ${gnb_default_scf1}    Get BTS Version And SCF Path    gNB_ip=${gnb_ip1}    gnbnumber=${gNB_BTS_ID1}
    ${gnb_default_scf2}    Get BTS Version And SCF Path    gNB_ip=${gnb_ip2}    gnbnumber=${gNB_BTS_ID2}
    ${gnb1_new_scf}    Modify SCF file and create new    default_scf=${gnb_default_scf1}    para_list=${gnb1_modify_para}   new_scf_name=gnb1.xml
    ${gnb2_new_scf}    Modify SCF file and create new    default_scf=${gnb_default_scf2}    para_list=${gnb2_modify_para}   new_scf_name=gnb2.xml
    ENB_and_GNB_Modify_Para    enb_para=${enb1_para1}    gnb_para=None    gnb_host_ip=${gnb_ip1}    connection=GNB1
    Setup Commission SCF    host_ip=${gnb_ip1}    scf_path=${gnb1_new_scf}    connection=GNB1
    Setup Commission SCF    host_ip=${gnb_ip2}    scf_path=${gnb2_new_scf}    connection=GNB2
    Wait Until Keyword Succeeds   20min     1min    Check BTS Should Be Normal    host_ip=${gNB_ip1}    connection=GNB1
    Wait Until Keyword Succeeds   20min     1min    Check BTS Should Be Normal    host_ip=${gNB_ip2}    connection=GNB1


5GC001095_A2A3_measurement_Trigger
    [Arguments]    ${message_list}
    FOR    ${item}    IN    @{message_list}
        Trigger measurement    message=${item}
    END
    Sleep    60s

5GC001095_TCPdump_Check_Point
    [Arguments]    ${source}    ${txt_name}    ${except_signal_list}    ${except_measId_list}
    Convert pcap file to txt    source=${LOG_PATH}/${source}   target=${LOG_PATH}/${txt_name}   filter=x2ap||s1ap||f1ap||e1ap||nr-rrc
    ${order_result}    Check_tcpdump_signal_order    log_path=${LOG_PATH}/${txt_name}    except_value_list=${except_signal_list}
    ${measId_result}    Get_measId_value    log_path=${LOG_PATH}/${txt_name}    except_measId_list=${except_measId_list}
    Run Keyword And Continue On Failure    Should Be Equal    ${order_result}    ${True}
    Run Keyword And Continue On Failure    Should Be Equal    ${measId_result}    ${True}

case5_TCPdump_Check_Point
    [Arguments]    ${source}    ${txt_name}    ${except_signal_list}    ${check_message_list}    ${except_measId_Id}    ${index}
    Convert pcap file to txt    source=${LOG_PATH}/${source}   target=${LOG_PATH}/${txt_name}   filter=x2ap||s1ap||f1ap||e1ap||nr-rrc
    ${order_result}    Check_tcpdump_signal_order    log_path=${LOG_PATH}/${txt_name}    except_value_list=${except_signal_list}
    Check_TCPdump_MeasId    txt_name=${txt_name}   check_message_list=${check_message_list}    except_measId_Id=${except_measId_Id}   index=${index}
    Run Keyword And Continue On Failure    Should Be Equal    ${order_result}    ${True}

Check_TCPdump_MeasId
    [Arguments]  ${txt_name}    ${check_message_list}    ${except_measId_Id}    ${index}    ${check_message}=rrcReconfiguration
    ${message_dict}    Check_measId_Info    log_path=${LOG_PATH}/${txt_name}    check_message_list=${check_message_list}    index=${index}
    ...    check_message=${check_message}
    ${measidtoremovelist}    Get From Dictionary     ${message_dict}     measidtoremovelist
    ${measidtoaddmodlist}    Get From Dictionary     ${message_dict}     measidtoaddmodlist
    Run Keyword And Continue On Failure    Lists Should Be Equal    ${measidtoremovelist}    ${except_measId_Id}[0]
    Run Keyword And Continue On Failure    Lists Should Be Equal    ${measidtoaddmodlist}    ${except_measId_Id}[1]

Check Counter List Sum
    [Arguments]    ${counter_id1}    ${counter_id2}    ${exp_sum}   ${BTS}=BTS    ${CELLS}=CELLS    ${NRCELL}=NRCELL-1
    ...    ${counter_object}=NX2CC    ${host_ip}=${gNB_ip1}    ${connection}=GNB_COM
    ${counter_list1}    Get PM counter result    counter_id=${counter_id1}    BTS=${BTS}    CELLS=${CELLS}    NRCELL=${NRCELL}
    ...    counter_object=${counter_object}    host_ip=${host_ip}    connection=${connection}
    ${counter_list2}    Get PM counter result    counter_id=${counter_id1}    BTS=${BTS}    CELLS=${CELLS}    NRCELL=${NRCELL}
    ...    counter_object=${counter_object}    host_ip=${host_ip}    connection=${connection}
    ${result}    Sum_list_value    input_list1=${counter_list1}    input_list2=${counter_list2}    exp_sum=${exp_sum}
    should be equal    ${result}    ${True}
    [Return]  ${result}

case7_TCPdump_Check_Point
    [Arguments]  ${source}    ${txt_name}    ${except_signal_list}    ${check_message_list}
    Convert pcap file to txt    source=${LOG_PATH}/${source}   target=${LOG_PATH}/${txt_name}   filter=x2ap||s1ap||f1ap||e1ap||nr-rrc
    ${order_result}    Check_tcpdump_signal_order    log_path=${LOG_PATH}/${txt_name}    except_value_list=${except_signal_list}
    Check_TCPdump_MeasId    txt_name=${txt_name}    check_message_list=${check_message_list}    except_measId_Id=${case7_measId_Id1}
    ...    index=${0}    check_message=SgNBModificationRequired
    Check_TCPdump_MeasId    txt_name=${txt_name}    check_message_list=${check_message_list}    except_measId_Id=${case7_measId_Id2}
    ...    index=${0}    check_message=SgNBAdditionRequestAcknowledge
    Check_TCPdump_MeasId    txt_name=${txt_name}    check_message_list=${check_message_list}    except_measId_Id=${case7_measId_Id3}
    ...    index=${2}    check_message=SgNBModificationRequired
    Check_TCPdump_MeasId    txt_name=${txt_name}    check_message_list=${check_message_list}    except_measId_Id=${case7_measId_Id4}
    ...    index=${1}    check_message=SgNBAdditionRequestAcknowledge
