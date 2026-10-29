*** Settings ***
Documentation    Suite description

Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/viavi_common_keyword.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/container_log_capturing.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/Analysis_Viavi_Log.py
Library           Analysis_Viavi_Log.Viavi_Log_analysis     WITH NAME    Viavi_Log_analysis
Library           taf.config.scf.interface.scf     WITH NAME   scf
Library           ./5GC001094_comm_keyword.py
Variables         ./5GC001094_modify_para.py
Library           ute_syslog

*** Variables ***

${CURDIR_path}            ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}
${LOG_PATH}               ${OUTPUT_DIR}
${gNB_ip}                 ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${gNB_BTS_ID}             ${tl.gnbs[0].global_bts_id}
${gNB_oam_username}       ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gNB_oam_password}       ${tl.gnbs[0].cu.oam_http_connection_details.password}
${gNB_ssh_username}       ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${gNB_ssh_password}       ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${eNB_ip}                 ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${eNB_username}           ${tl.enbs[0].airscale.common_units[0].lmp_connection.username}
${eNB_password}           ${tl.enbs[0].airscale.common_units[0].lmp_connection.password}
${TEST_PC_IP}             ${tl.test_pc.default_ssh_connection_details.addr}
${TEST_PC_USERNAME}       ${tl.test_pc.default_ssh_connection_details.username}
${TEST_PC_PASSWORD}       ${tl.test_pc.default_ssh_connection_details.password}
${luashark_path}          /opt/ute/luashark/luashark_script/generated_luashark/luashark.lua
${Server_ip}              ${tl.ues[0].iperf_details.ssh_connection_details.addr}
${new_scf_path}           ${LOG_PATH}/scf_base_default.xml
${ul_ports}               ${tl.ues[0].iperf_details.ports[0]}
${dl_ports}               ${tl.ues[0].iperf_details.ports[1]}
${TMA_SSH_ALIAS}          e500
${E500_IP}                ${tl.ues[0].tma_host.addr}
${E500_USER}              ${tl.ues[0].tma_host.username}
${E500_PW}                ${tl.ues[0].tma_host.password}
${btslog_port}            ${51000}


*** Keywords ***
env parpare
    log to console      case preparation
    Delete old logs
    Modify SCF file and create new
    Setup Commission SCF

Case1 Teardown
    Delete blacklist
    Case Teardown

Case Teardown
    log to console      case teardown
    Cobham UE detach    e500_script_path=${E500_SCRIPTS_BASE}
    Run Keyword And Continue On Failure     stop syslog     alias=ute
    CI_interface.Common Case Teardown

#***********BTSLOG***********
Start BTSlog
    [Arguments]           ${log_name}=btslog.log
    log to console    start capture btslog.
    ${ports}    create list    ${btslog_port}
    start syslog    log_dir=${OUTPUT_DIR}    log_name=${log_name}    ports=${ports}    host_ip=${TEST_PC_IP}    alias=ute
    ...         ssh_username=${TEST_PC_USERNAME}    ssh_password=${TEST_PC_PASSWORD}

Stop BTSlog and check Message
    [Arguments]           ${regexp}
    log to console    stop btslog and check message.
    Wait until keyword succeeds    2x    5s
    ...         wait_for_message_in_syslog_file    alias=ute
    ...         regexp=${regexp}
    ...         timeout=3s
    stop syslog     alias=ute

#***********OAM operation*****************
Connect to DU
    [Arguments]           ${BTS_Host}=${gNB_ip}    ${username}=${gNB_oam_username}    ${password}=${gNB_oam_password}
    ...         ${name}=GNB_OAM
    log to console    connect to BTS, ip=${gNB_ip}
    ${connection}     coam.connect_to    bts_host=${BTS_Host}    bts_port=${443}    username=${username}
    ...         password=${password}    name=${name}
    [return]    ${connection}

Setup Commission SCF
    [Arguments]      ${gnbnumber}=${gNB_BTS_ID}     ${BTS_Host}=${gNB_ip}    ${username}=${gNB_oam_username}
    ...         ${password}=${gNB_oam_password}
     ${connection}     Connect to DU
     log to console    start commission SCF:${new_scf_path}
     COAM Commission with scf file    scf_file_path=${new_scf_path}  #Commission new SCF
     Wait Until Keyword Succeeds   16min   2min     Check cell on air
    [Teardown]    Run keyword and ignore error     coam.teardown      connection=${connection}

Get BTS Version And SCF Path
    [Arguments]    ${gnbnumber}=${gNB_BTS_ID}    ${gNB_ip}=${gNB_ip}   ${CURDIR_path}=${CURDIR_path}
    ${connection}    Connect to DU
    ${version}    coam.get_sw_version    connection=${connection}
    log to console    bts version=${version}
    ${scf_name}    Covert_BTS_Version    version=${version}    gnbnumber=${gnbnumber}
    ${default_scf}    set variable    ${CURDIR_path}/${scf_name}
    [Return]    ${default_scf}
    [Teardown]    Run keyword and ignore error     coam.teardown      connection=${connection}

Check cell on air
    log_to_console    Check cell on air
    ${connection}     Connect to DU
    ${status}            coam.get_bts_statuses       connection=GNB_OAM
    ${bts_status}        get from dictionary     ${status}     proceduralState
    should be equal      ${bts_status}      OnAir
    [Teardown]    Run keyword and ignore error     coam.teardown    connection=GNB_OAM

#***********Parameters modify**************
Modify SCF file and create new
    log to console      start modify scf offline...
    ${default_scf}      Get BTS Version And SCF Path
    scf.load_scf       file_path=${default_scf}
    sleep   3s
    ${gscnOrSsPbchArfcn}    get_value_from_scf      dist_name=${NRCELL_1}    p_name=gscnOrSsPbchArfcn
    ${nrarfcn}    get_value_from_scf      dist_name=${NRCELL_1}    p_name=nrarfcn
    modify_scf_element     dist_name=${NRCELL_2}    p_name=gscnOrSsPbchArfcn     value=${gscnOrSsPbchArfcn}
    modify_scf_element     dist_name=${NRCELL_2}    p_name=nrarfcn     value=${nrarfcn}
    scf.save_scf        file_path=${new_scf_path}
    log to console      modify successful,${default_scf} will be commissioned.
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}

Modify Parameters for 001
    Modify Common parameter via Coam    input_list=${ENB_MODIFY_Parameter_001}    bts_ip=${eNB_ip}
    Modify Common parameter via Coam    input_list=${GNB_MODIFY_Parameter_001}    bts_ip=${gNB_ip}

Modify Parameters for 002
    Modify Common parameter via Coam    input_list=${ENB_MODIFY_Parameter_001}    bts_ip=${eNB_ip}
    Modify Common parameter via Coam    input_list=${GNB_MODIFY_Parameter_002}    bts_ip=${gNB_ip}

Modify Parameters for 003
    Modify Common parameter via Coam    input_list=${ENB_MODIFY_Parameter_001}    bts_ip=${eNB_ip}
    Modify Common parameter via Coam    input_list=${GNB_MODIFY_Parameter_003}    bts_ip=${gNB_ip}

Delete blacklist
    log to console    delete black list configuration...
    Modify Common parameter via Coam    input_list=${Black_List_Parameter}    bts_ip=${gNB_ip}  operation=delete

Modify Common parameter via Coam
    [Arguments]  ${input_list}    ${bts_ip}    ${operation}=update  ${connection}=GNB_connection
    log to console    Modify parameter for BTS ip:${bts_ip}
    ${connection}    Connect to DU      BTS_Host=${bts_ip}   name=${connection}
    FOR    ${item}   IN    @{input_list}
        coam.Perform Parameter Recommissioning    dist_name=${item}[dist_name]   parameter=${item}[parameter]
        ...    value=${item}[value]
        ...    operation=${operation}    skip_parameter_relation_errors=${True}    should_activate=${True}
        ...    connection=${connection}
    END
    log to console  change parameter successful,sleep 5s
    sleep    5s
    [Teardown]    run keyword and ignore error    coam.teardown    connection=${connection}

#*****************Viavi*********************
Trigger NR measurement report
    [Arguments]    ${meas_id}=1    ${report_interval}=4    ${serving_cell_pci}=50    ${serving_cell_rsrp}=50
    ...    ${serving_cell_rsrq}=53    ${serving_cell_sinr}=35    ${neigh_cell_pci}=52    ${neigh_cell_rsrp}=71
    ...    ${neigh_cell_rsrq}=57    ${neigh_cell_sinr}=44    ${tm500_alias}=${TMA_SSH_ALIAS}     ${ssb_index}=${0}
    ...    ${handover_type}=A3rsrp    ${isHandoverOK}=ok
    log to console  Start to trigger NR measurement report
    ${MR_REPORT}    catenate
    ...    forw mte NrRrcAptTriggerMeasReport ${meas_id} 0 0 ${report_interval} 1
    ...    {0 [${serving_cell_pci}] [[${serving_cell_rsrp}] [${serving_cell_rsrq}] [${serving_cell_sinr}]] []
    ...    [[1{${ssb_index} [[${serving_cell_rsrp}] [${serving_cell_rsrq}] [${serving_cell_sinr}]]}] []] [] []}
    ...    [0(1{[${neigh_cell_pci}] [[${neigh_cell_rsrp}] [${neigh_cell_rsrq}] [${neigh_cell_sinr}]] []
    ...    [ [1{${ssb_index} [[${neigh_cell_rsrp}] [${neigh_cell_rsrq}] [${neigh_cell_sinr}]]}] [] ] })]
    log to console      MeasurementReport: ${MR_REPORT}
    ${response}    tm500_remote.send_command    command=${MR_REPORT}    alias=${tm500_alias}
    ${response}    tm500_remote.send_command    command=forw mte Activate -1    alias=${tm500_alias}
    sleep    5s
    run keyword if    '${isHandoverOK}'=='ok'
    ...     Wait until keyword succeeds    10s    200ms    match pattern in response    response=${response}
    ...    e500_alias=${tm500_alias}    pattern=Random Access Complete

match pattern in response
    [Arguments]    ${pattern}    ${response}    ${e500_alias}=${TMA_SSH_ALIAS}
    ${response_extra}    tm500_remote.read_responses    alias=${e500_alias}
    ${response}    Catenate    ${response}    ${response_extra}
    Should contain    ${response}    ${pattern}    msg=String "${pattern}" is not found
    log to console    Response: ${response}

Start logging on cobham and Return Folder
    [Documentation]  Author: Jiang Hongyu
    ...              Description: Start logging on cobham TMA so that the protocol logs can be captured
    ...                           And Return Log path
    [Arguments]    ${connection}=${TMA_SSH_ALIAS}
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
    csn.Connect to    hostname=${E500_IP}    username=${E500_USER}    password=${E500_PW}    alias=${connect}
    ${new_path}    set variable    /cygdrive/c/Users/nokia5G/Documents/CSV/${logs_path}[1]
    csn.send command    command=mkdir ${new_path}    connection=${connect}
    Wait Until Keyword Succeeds   ${retry}    10s    Check CSV file is exsit    csv_path='${logs_path}[0]'
    ...     connection=${connect}
    csn.send command    command=cd '${logs_path}[0]';scp *.csv ${new_path}     connection=${connect}
    sleep    ${time}
    Copy Viavi Log    logs_path=${new_path}
    csn.send command    command=rm -rf ${logs_path}    connection=${connect}
    ${ute_path}    set variable    ${output_dir}/${logs_path}[1]
    [Return]  ${ute_path}
    [Teardown]    Run Keyword And Ignore error    csn.disconnect    connection=${connect}
Check CSV file is exsit
    [Arguments]  ${csv_path}    ${connection}
    ${file_list}   csn.execute   ls ${csv_path}   connection=${connection}
    ${file_list}    Split String    ${file_list}    \r\n
    ${csv_list}    Get_csv_is_exsit    input_list=${file_list}
    ${csv_list_len}    Get Length    ${csv_list}
    should be equal as integers    ${csv_list_len}    ${2}    msg=Don't have all csv file
    [Return]   ${csv_list}

Copy Viavi Log
    [Documentation]
    [Arguments]  ${logs_path}    ${ute_path}=${output_dir}    ${time}=40s    ${connect}=ute
    csn.Connect to    hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}
    ...     alias=${connect}
    csn.send command    command=sshpass -p ${E500_PW} scp -r ${E500_USER}@${E500_IP}:${logs_path} ${ute_path}
    ...     connection=${connect}
    sleep    ${time}
    [Teardown]  Run Keyword And Ignore error    csn.disconnect    connection=${connect}

Check_TP_And_Bler
    [Arguments]  ${dir_path}    ${ul_min_tp}    ${ul_max_tp}    ${dl_min_tp}    ${dl_max_tp}    ${bler_value}
    ...     ${row}=${10}
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
Start traffic
    [Documentation]  start ul and dl traffic
    [Arguments]  ${ul_throughput}    ${dl_throughput}    ${traffic_time}    ${appserver_ip}=${Server_ip}
    ...    ${ul_port}=${ul_ports}    ${dl_port}=${dl_ports}    ${if_ul}=${True}    ${if_dl}=${True}
    run keyword if    ${if_ul}    Start UDP UL traffic    host_ip=${appserver_ip}    throughput=${ul_throughput}    traffic_time=${traffic_time}
    ...    port=${ul_port}
    run keyword if    ${if_dl}    DL traffic start iperf client from app server with real epc    throughput=${dl_throughput}
    ...    traffic_time=${traffic_time}    port=${dl_port}    dl_host_ip=${UE_IP}    length=${1024}
Start UDP UL traffic
    [Documentation]  Start udp ul traffic
    [Arguments]    ${host_ip}    ${throughput}    ${traffic_time}    ${port}    ${thread}=1    ${connection}=${TMA_SSH_ALIAS}
    csn.connect to    hostname=${E500_IP}    username=${E500_USER}    password=${E500_PW}    alias=${connection}
    wait until keyword succeeds    3min    20s    enable PPPoE connection    TMA_SSH_ALIAS=${connection}
    ${cmd_start_iperf_client}    Catenate    iperf -u -c ${host_ip} -b ${throughput}M -t ${traffic_time} -i 1 -p ${port} -P ${thread}
    csn.send command     command=${cmd_start_iperf_client}    connection=${connection}
    Log to console    Start UL traffic
    [Teardown]  Run keyword and ignore error    csn.disconnect    connection=${connection}

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
    csn.send command   rasdial TM500    connection=${TMA_SSH_ALIAS}
    ${output}    csn.read output    connection=${TMA_SSH_ALIAS}
    Log to console    ${output}
    should contain    ${output}    Command completed successfully

#*************Capture Log****************
Start wireshark capture from gNB or Enb
    [Documentation]    Description: Start X2 log capture on gNB or Enb
    [Arguments]     ${filename}=enb_tcpdump.pcap   ${interface}=any    ${index}=${0}    ${alias}=ASIK Master    ${gnb}=${False}
    log to console    start capture wireshark log...
    run keyword if    '${gnb}'=='True'    Connect to with ssh    hostname=${gNB_ip}    username=${gNB_ssh_username}
    ...     password=${gNB_ssh_password}    alias=${alias}
    run keyword if    '${gnb}'!='True'    Connect to with ssh    alias=${alias}
    ${log_full_path_gnb}     set variable if    '${gnb}'=='True'    /ram/${filename}    /tmp/${filename}
    csn.send command    command=ps -ef |grep tcpdump |grep -v grep |grep ${interface} |awk '{print $2}' |xargs kill -2    connection=${alias}
    sleep    2s
    run keyword if    '${gnb}'=='True'    SSH to CPRT for gNB    filename=${log_full_path_gnb}    alias=${alias}
    run keyword if    '${gnb}'!='True'    csn.send command    command=nohup tcpdump -i ${interface} -s 0 -w ${log_full_path_gnb}
    ...     connection=${alias}
    sleep    2s
    Trace capturing process should be triggered    log_prefix=${filename}    connection_alias=${alias}
    [Return]    ${alias}
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${alias}

SSH to CPRT for gNB
    [Arguments]    ${filename}    ${alias}=ASIK Master
    csn.send command    command=cd /ram && ls -l | grep CPRT | cut -d "_" -f 2|cut -d " " -f 1|head -1      connection=${alias}
    ${readOutput}=     csn.readOutput    connection=${alias}
    csn.send command
    ...        command=cd /ram && lxc-attach -n ${readOutput.split("\n")[0]} && nohup tcpdump -i any -w ${filename} &>/dev/null &
    ...        connection=${alias}

Stop wireshark capture from gNB or Enb
    [Documentation]    Description: Stop X2 log capture on gNB or Enb, and download x2 log to testpc
    [Arguments]     ${filename}=enb_tcpdump.pcap    ${log_path}=${LOG_PATH}    ${index}=${0}    ${alias}=ASIK Master    ${gnb}=${False}
    log to console    stop capture wireshark log.
    run keyword if    '${gnb}'=='True'    Connect to with ssh    hostname=${gNB_ip}    username=${gNB_ssh_username}
    ...     password=${gNB_ssh_password}    alias=${alias}
    run keyword if    '${gnb}'!='True'    Connect to with ssh    alias=${alias}
    Stop trace capturing    log_prefix=${filename}    connection_alias=${alias}
    ${log_full_path_ute}    set variable     ${LOG_PATH}/${filename}
    ${log_full_path_gnb}     set variable if    '${gnb}'=='True'    /ram/${filename}    /tmp/${filename}
    log to console     pcap log saved path:${log_full_path_ute}
    csn.download_file   remote_path=${log_full_path_gnb}   local_path=${log_full_path_ute}   connection=${alias}
    csn.execute    command=rm ${log_full_path_gnb}    connection=${alias}
    log to console    removed log in BTS: ${log_full_path_gnb}
    [Return]    ${log_full_path_ute}
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${alias}

#*******************check point****************
check measid
    [Arguments]     ${txt_filename}    ${expect}    ${measConfigDic}    ${para1}=report    ${para2}=eventId    ${mr_n}=1    ${mc_n}=1
    # if n=2, measid in the 2 times measurement report will be checked.
    log to console      find measID form the ${mr_n} time meassurement report...
    ${expected_dic}     create Dictionary       measId=${Empty}
    ${measid_dic_1}    create Dictionary    xpath=measurementReport/measResults     expected_value=${expected_dic}      n=${mr_n}
    ${measid_list}     create List    ${measid_dic_1}
    ${val}     Check Wireshark Parameter From Txt        txt_file_path=${LOG_PATH}/${txt_filename}    parameters=${measid_list}

    ${val_list}     set variable    ${val}[resultSearch]
    ${val_dic}      set variable    ${val_list}[0]
    ${actual_value}    set variable     ${val_dic}[actual_value]
    log to console
    ...    find measID: ${actual_value}[measId] from the ${mr_n} time meassurement report, will check the ${mc_n} time measConfig.
    ${event}    Get MeasConfig Value From Dictionary     n=${mc_n}     measid=${actual_value}[measId]      para1=${para1}
    ...         para2=${para2}   measConfigDic=${measConfigDic}
    should be equal     ${expect}      ${event}


#******************other common keyword****************
Convert pcap to text
    [Arguments]    ${source}    ${target}    ${filter}   ${connection}=ute
    log to console      'convert pcap->txt: '${source}
    Connect to with ssh    hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}     password=${TEST_PC_PASSWORD}    alias=${connection}
    sleep    1s
    csn.send_command
    ...  command=nice tshark -X lua_script:${luashark_path} -V -r ${source} -T text > ${target} -Y '${filter}'   connection=${connection}
    csn.await execution end  connection=${connection}  timeout=30min
    sleep    5s
    [Teardown]      run keyword and ignore error    csn.Disconnect    connection=${connection}

Connect to with ssh
    [Arguments]    ${hostname}=${enb_ip}    ${username}=${eNB_username}      ${password}=${eNB_password}   ${alias}=enb
    log to console    ssh to ${hostname}
    csn.connect_to   hostname=${hostname}    username=${username}    password=${password}    alias=${alias}

Delete old logs
    log to console      start delete old logs...
    Connect to with ssh    hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}     password=${TEST_PC_PASSWORD}    alias=ute
    csn.send command    command=rm -f ${new_scf_path}      connection=ute  #remove scf which changed freq
    csn.send command    command=rm -f ${LOG_PATH}/wireshark_pcap_case*      connection=ute
    csn.send command    command=rm -f ${LOG_PATH}/btslog*.log      connection=ute
    [Teardown]      run keyword and ignore error    csn.Disconnect    connection=ute

kill IPSL process
    [Arguments]    ${alias}=tma_ssh
    log to console      kill IPSL process......
    Connect to with ssh    hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}     password=${TEST_PC_PASSWORD}    alias=${alias}
    csn.send command    command=taskkill /f /im "ips32.exe"       connection=${alias}
    [Teardown]      run keyword and ignore error    csn.Disconnect    connection=${alias}
