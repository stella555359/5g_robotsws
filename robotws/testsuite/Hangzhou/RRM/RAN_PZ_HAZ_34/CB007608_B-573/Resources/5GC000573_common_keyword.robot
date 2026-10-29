*** Settings ***
Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/viavi_common_keyword.robot
Resource            testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/container_log_capturing.robot
Resource            taf/rfrl/common_resources/robot/connection_alias_store.robot
Library             testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/Analysis_Viavi_Log.py
Library             Analysis_Viavi_Log.Viavi_Log_analysis     WITH NAME    Viavi_Log_analysis
Library             ./5GC000573_common.py
Library             ute_syslog

*** Variables ***
${CURDIR_path}            ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}
${E500_SCRIPTS_BASE}      ${CURDIR}/E500_scripts
${gNB_ip}                 ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${gNB_username}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gNB_password}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${enb_ip}                 ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${eNB_username}           ${tl.enbs[0].airscale.common_units[0].lmp_connection.username}
${eNB_password}           ${tl.enbs[0].airscale.common_units[0].lmp_connection.password}
${TEST_PC_IP}             ${tl.test_pc.default_ssh_connection_details.addr}
${TEST_PC_USERNAME}       ${tl.test_pc.default_ssh_connection_details.username}
${TEST_PC_PASSWORD}       ${tl.test_pc.default_ssh_connection_details.password}
${port1}                  51000
${port2}                  51003
${TMA_APP_ALIAS}          e500
${E500_IP}                ${tl.ues[0].tma_host.addr}
${E500_USER}              ${tl.ues[0].tma_host.username}
${E500_PW}                ${tl.ues[0].tma_host.password}



*** Keywords ***
Setup Commission SCF
    [Arguments]      ${gnbnumber}=1     ${BTS_Host}=${gNB_ip}
     ${default_scf}    Get BTS Version And Perare SCF   gNB_ip=${BTS_Host}   CURDIR_path=${CURDIR_path}    gnbnumber=${gnbnumber}
     Connect to gnb coam via ssl    bts_host=${BTS_Host}    username=${gNB_username}    password=${gNB_password}
     COAM Commission with scf file    scf_file_path=${default_scf}     is_pdl_checking_needed=${False}
     Wait Until Keyword Succeeds   16min   2min   Check cell on air
     [Teardown]    Run keyword and ignore error     coam.teardown    connection=GNB_OAM

Get BTS Version And Perare SCF
    [Arguments]    ${gnbnumber}    ${gNB_ip}=${gNB_ip}   ${CURDIR_path}=${CURDIR_path}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl     bts_host=${gNB_ip}
    ${version}    coam.get_sw_version    connection=${connection}
    ${scf_name}    5GC000573_common.Covert_BTS_Version    version=${version}    gnbnumber=${gnbnumber}
    ${default_scf}    set variable    ${CURDIR_path}/${scf_name}
    log to console   ${default_scf}
    [Return]    ${default_scf}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}

Check cell on air
    log_to_console    Check cell on air
    ${status}            coam.get_bts_statuses       connection=GNB_OAM
    ${bts_status}        get from dictionary     ${status}     proceduralState
    should be equal      ${bts_status}      OnAir

Only Setup Commission SCF
    [Arguments]      ${gnbnumber}=1     ${BTS_Host}=${gNB_ip}
     ${default_scf}    Get BTS Version And Perare SCF   gNB_ip=${BTS_Host}   CURDIR_path=${CURDIR_path}    gnbnumber=${gnbnumber}
     Connect to gnb coam via ssl    bts_host=${BTS_Host}    username=${gNB_username}    password=${gNB_password}
     COAM Commission with scf file    scf_file_path=${default_scf}     is_pdl_checking_needed=${False}
     [Teardown]    Run keyword and ignore error     coam.teardown    connection=GNB_OAM

Connect gnb and Check cell on air
    [Arguments]     ${BTS_Host}=${gNB_ip}
    Connect to gnb coam via ssl    bts_host=${BTS_Host}    username=${gNB_username}    password=${gNB_password}
    Wait Until Keyword Succeeds   16min   1min   Check cell on air
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=GNB_OAM

Modify Common parameter via Coam
    [Arguments]  ${input_list}    ${gNB_ip}    ${connection}=GNB_connection
    log to console    Modify parameter
    Connect to gnb coam via ssl     bts_host=${gNB_ip}      connection=${connection}
    FOR    ${item}  IN    @{input_list}
        ${dict_value}    5GC000573_common_keyword.Get Content From Input Dict    input_dict=${item}
        coam.Perform Parameter Recommissioning    dist_name=${dict_value}[0]   parameter=${dict_value}[1]   value=${dict_value}[2]
        ...    operation=update    skip_parameter_relation_errors=${True}    should_activate=${True}    connection=${connection}
    END
    log to console  change parameter successful,sleep 30s
    sleep  30s
    [Teardown]    run keyword and ignore error    coam.teardown    connection=${connection}

Modify Structure parameter via Coam
    [Arguments]   ${class_name}   ${connection}   ${modify_list}   ${keywords_list}    ${index}=0
    ${get_managed_objects}     coam.get_managed_objects     class_name=${class_name}    connection=${connection}
    ${output_dict_list}    return_structure_value    input_list=${get_managed_objects}    modify_list=${modify_list}
    ...    keywords_list=${keywords_list}
    FOR    ${item}  IN  @{output_dict_list}
         ${dict_value}    5GC000573_common_keyword.Get Content From Input Dict    input_dict=${item}
         coam.Perform Parameter Recommissioning    dist_name=${dict_value}[0]   parameter=${dict_value}[1]   value=${dict_value}[2]
         ...    operation=update    skip_parameter_relation_errors=${True}    should_activate=${True}    connection=${connection}
         sleep  30s
    END

Get Content From Input Dict
    [Arguments]  ${input_dict}
    ${dist_name}    get from dictionary     ${input_dict}    dist_name
    ${parammeter}    get from dictionary    ${input_dict}    parameter
    ${new_value}     get from dictionary    ${input_dict}    value
    ${value_list}    create list    ${dist_name}    ${parammeter}    ${new_value}
    [Return]  ${value_list}

Connect to ENB with ssh
    [Arguments]    ${hostname}=${enb_ip}    ${username}=${eNB_username}      ${password}=${eNB_password}   ${alias}=enb
    csn.connect_to   hostname=${hostname}
        ...    username=${username}    password=${password}    alias=${alias}


Start wireshark capture from gNB or Enb
    [Documentation]    Description: Start X2 log capture on gNB or Enb
    [Arguments]     ${filename}=enb_tcpdump   ${interface}=any    ${index}=${0}    ${alias}=ASIK Master    ${gnb}=${False}
    run keyword if    '${gnb}'=='True'    Connect to GNB with ssh   gnb_index=${index}    alias=${alias}
    run keyword if    '${gnb}'!='True'    Connect to ENB with ssh     alias=${alias}
    ${log_name}    Set variable    ${filename}.pcap
    ${log_full_path_gnb}    join path    /tmp    ${log_name}
    csn.send command    command=ps -ef |grep tcpdump |grep -v grep |grep ${interface} |awk '{print $2}' |xargs kill -2    connection=${alias}
    sleep    2s
    csn.send command    command=nohup tcpdump -i ${interface} -s 0 -w ${log_full_path_gnb}     connection=${alias}
    sleep    2s
    Trace capturing process should be triggered    log_prefix=${log_name}    connection_alias=${alias}
    [Return]    ${alias}
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${alias}

Connect to GNB with ssh
    [Arguments]    ${du_index}=${0}    ${alias}=ASIK Master    ${gnb_index}=${0}
    csn.Connect to    ${tl.gnbs[${gnb_index}].dus[${du_index}].f1_m_ip_addr}
    ...               ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.username}
    ...               ${tl.gnbs[${gnb_index}].dus[${du_index}].airscale.common_units[0].lmp_connection.password}
    ...               alias=${alias}

Stop wireshark capture from gNB or Enb
    [Documentation]    Description: Stop X2 log capture on gNB or Enb, and download x2 log to testpc
    [Arguments]     ${filename}=enbX2    ${log_path}=${OUTPUT_DIR}    ${index}=${0}    ${alias}=ASIK Master    ${gnb}=${False}
    run keyword if    '${gnb}'=='True'    Connect to GNB with ssh       gnb_index=${index}    alias=${alias}
    run keyword if    '${gnb}'!='True'    Connect to ENB with ssh       alias=${alias}
    Stop trace capturing    log_prefix=${filename}    connection_alias=${alias}
    ${log_full_path_ute}    set variable     ${log_path}/${filename}.pcap
    csn.download_file   remote_path=/tmp/${filename}.pcap   local_path=${log_full_path_ute}   connection=${alias}
    csn.execute    command=rm /tmp/${filename}.pcap    connection=${alias}
    [Return]    ${log_full_path_ute}
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${alias}

Iperf send UL traffic VIAVI
    [Documentation]    Author: zhu xiaofeng
    ...                Description: ul_host_ip will default to 192.168.10.70
    ...                port=5410 is related with it used on cobham. Now dedicated to this value
    [Arguments]    ${throughput}=100    ${traffic_time}=${240}    ${ul_host_ip}=10.57.178.18
    ...    ${port}=${tl.ues[0].iperf_details.ssh_connection_details.port}
    Log to console    Start UL traffic with real epc
    wait until keyword succeeds    2 min    10 s    traffic_via_iperf.Connect to cobham control pc via ssh
    5GC000573_common_keyword.enable PPPoE connection    TMA_SSH_ALIAS=${TMA_SSH_ALIAS}
    ${cmd_start_iperf_client}    Catenate    iperf -u -c ${ul_host_ip} -b ${throughput}M -t ${traffic_time} -i 1 -p ${port} -P 1
    csn.send command     command=${cmd_start_iperf_client}    connection=${TMA_SSH_ALIAS}
    sleep    5s
    Log to console    Start to send UL traffic with real epc on UE side, traffic time is ${traffic_time}
    [Teardown]  Run keyword and ignore error    Run keywords    traffic_via_iperf.Disconnect from app server    AND
    ...    traffic_via_iperf.Disconnect from cobham control pc via ssh

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

Trigger A3 measurement report for 002 case
    [Arguments]    ${a2_meas_id}=1    ${report_interval}=4    ${serving_cell_pci}=50    ${serving_cell_rsrp}=50
    ...    ${serving_cell_rsrq}=53    ${serving_cell_sinr}=35    ${neigh_cell_pci}=52    ${neigh_cell_rsrp}=71    ${neigh_cell_rsrq}=57
    ...    ${neigh_cell_sinr}=44    ${tm500_alias}=e500
    log to console  Start to trigger A3 measurement report
    ${cmd_a3_mr}    catenate
    ...    forw mte NrRrcAptTriggerMeasReport ${a2_meas_id} 0 0 ${report_interval} 1
    ...   {0 [${serving_cell_pci}] [[${serving_cell_rsrp}] [${serving_cell_rsrq}] [${serving_cell_sinr}]] [] [[1{0[[50] [] []]}] []] [] []}
    ...    [0(1{[${neigh_cell_pci}] [[${neigh_cell_rsrp}] [${neigh_cell_rsrq}] [${neigh_cell_sinr}]] [][ [1{0[[71] [] []]}] [] ] })]
    ${response}    tm500_remote.send_command    command=${cmd_a3_mr}    alias=${tm500_alias}
    ${response}    tm500_remote.send_command    command=forw mte Activate -1    alias=${tm500_alias}
    sleep    5s
    Wait until keyword succeeds    10s    200ms    match pattern in response    response=${response}
    ...    e500_alias=${tm500_alias}    pattern=Random Access Complete

Trigger A3 measurement report for 004 case
    [Arguments]    ${a2_meas_id}=1    ${report_interval}=4    ${serving_cell_pci}=50    ${serving_cell_rsrp}=50
    ...    ${serving_cell_rsrq}=53    ${serving_cell_sinr}=35    ${neigh_cell_pci}=52    ${neigh_cell_rsrp}=71    ${neigh_cell_rsrq}=57
    ...    ${neigh_cell_sinr}=44    ${tm500_alias}=e500
    log to console  Start to trigger A3 measurement report
    ${cmd_a3_mr}    catenate
    ...    forw mte NrRrcAptTriggerMeasReport ${a2_meas_id} 0 0 ${report_interval} 1
    ...    {0 [${serving_cell_pci}] [[${serving_cell_rsrp}] [${serving_cell_rsrq}] [${serving_cell_sinr}]] [] [[1{0[[50] [] []]}] []] [] []}
    ...    [0(1{[${neigh_cell_pci}] [[${neigh_cell_rsrp}] [${neigh_cell_rsrq}] [${neigh_cell_sinr}]] [][ [1{0[[71] [] []]}] [] ] })]
    ${response}    tm500_remote.send_command    command=${cmd_a3_mr}    alias=${tm500_alias}
    ${response}    tm500_remote.send_command    command=forw mte Activate -1    alias=${tm500_alias}
    sleep    5s
    Run Keyword And Expect Error    *String "Random Access Complete" is not found*       match pattern in response    response=${response}
    ...    e500_alias=${tm500_alias}    pattern=Random Access Complete

match pattern in response
    [Arguments]    ${pattern}    ${response}    ${e500_alias}=${TMA_APP_ALIAS}
    ${response_extra}    tm500_remote.read_responses    alias=${e500_alias}
    ${response}    Catenate    ${response}    ${response_extra}
    Should contain    ${response}    ${pattern}    msg=String "${pattern}" is not found

start btslog capture on ute
    [Arguments]      ${connection}=ute     ${btslog_name}=btslog.log
    csn.Connect to     hostname=${TEST_PC_IP}     username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}  alias=${connection}
    log to console    start syslog...
    ${list}    Create list     ${port1}    ${port2}
    ute_syslog.Start Syslog    log_dir=${OUTPUT_DIR}      log_name=${btslog_name}
    ...      host_ip=${TEST_PC_IP}    ssh_username=${TEST_PC_USERNAME}    ssh_password=${TEST_PC_PASSWORD}    ports=${list}    alias=${connection}

Check wireshark log data common
    [Arguments]    ${command}    ${pacp_filename}   ${txt_filename}    ${filter}    ${connection}=ute
    Connect to ENB with ssh    hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}     password=${TEST_PC_PASSWORD}    alias=${connection}
    sleep    1s
    log to console    ${LOG_PATH}
    log to console    ${pacp_filename}
    5GC000573_common_keyword.Convert pcap to text   source=${LOG_PATH}/${pacp_filename}
    ...  target=${LOG_PATH}/${txt_filename}   connection=${connection}    filter=${filter}
    csn.Send Command  command=cat ${LOG_PATH}/${txt_filename} |${command}    connection=${connection}
    ${data}    csn.Read Output    connection=${connection}
    ${data}    strip_string    ${data}
    [Return]   ${data}
    [Teardown]    run keyword and ignore error    csn.Disconnect  	connection=${connection}

Check wireshark log data equal value
    [Arguments]    ${command}    ${pacp_filename}   ${txt_filename}    ${filter}   ${check}    ${connection}=ute
    ${data}    Check wireshark log data common    command=${command}    pacp_filename=${pacp_filename}    connection=${connection}
    ...   txt_filename=${txt_filename}      filter=${filter}
    should be equal as strings    ${data}    ${check}
    log to console    data:${data}
    [Teardown]    run keyword and ignore error    csn.Disconnect	connection=${connection}

Check wireshark log data not empty
    [Arguments]    ${command}    ${pacp_filename}   ${txt_filename}    ${filter}    ${connection}=ute
    ${data}    Check wireshark log data common    command=${command}    pacp_filename=${pacp_filename}    connection=${connection}
    ...   txt_filename=${txt_filename}      filter=${filter}
    should not be empty    ${data}
    log to console    data:${data}
    [Teardown]    run keyword and ignore error    csn.Disconnect	connection=${connection}

Check wireshark log data contain message
    [Arguments]    ${message}     ${txt_filename}=attach_message.txt     ${connection}=ute
    csn.Send Command  command=cat ${LOG_PATH}/${txt_filename} | grep ${message}    connection=${connection}
    ${data}    csn.Read Output    connection=${connection}
    ${data}    strip_string    ${data}
    should not be empty    ${data}
    log to console    data:${data}

Get measId from wireshark log
    [Arguments]    ${command}    ${pacp_filename}   ${txt_filename}    ${filter}    ${connection}=ute
    Connect to ENB with ssh    hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}     password=${TEST_PC_PASSWORD}    alias=${connection}
    sleep    1s
    Convert pcap to text   source=${LOG_PATH}/${pacp_filename}
    ...  target=${LOG_PATH}/${txt_filename}   connection=${connection}    filter=${filter}
    csn.Send Command  command=cat ${LOG_PATH}/${txt_filename} |${command}    connection=${connection}
    ${data}    csn.Read Output    connection=${connection}
    ${data}    strip_string    ${data}
    [Return]   ${data}
    [Teardown]    csn.Disconnect	connection=${connection}

Convert pcap to text
    [Arguments]    ${source}    ${target}    ${filter}   ${connection}=ute
    csn.send_command
    ...  command=nice tshark -X lua_script:${luashark_path} -V -r ${source} -T text > ${target} -Y '${filter}'   connection=${connection}
    csn.await execution end  connection=${connection}  timeout=30min
    sleep    5s

check BTS DL throughput
    [Arguments]   ${flag1}=100    ${flag2}=100    ${CELL1}=16385    ${CELL2}=32769    ${btslog}=btslog.log    ${connection}=GNB_OAM
    log to console    Check DL throughput
    Connect to ENB with ssh    hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}     password=${TEST_PC_PASSWORD}    alias=${connection}
    FOR    ${NUM}    IN RANGE    ${1}    ${99}    1
        ${TP1}    Get DL throughput form btslog       CELL=${CELL1}    NUM=${NUM}      btslog=${btslog}
        Run keyword if    ${TP1}==${0}      Continue For Loop
        ${TP2}    Get DL throughput form btslog       CELL=${CELL2}    NUM=${NUM}      btslog=${btslog}
        log to console    ${CELL1}:${TP1}
        log to console    ${CELL2}:${TP2}
        run keyword if    ${TP2}==${0}     Set test variable    ${flag1}    ${NUM}
        run keyword if    ${TP2}==${0}     should be true    ${TP1}>${200}
        run keyword if    ${TP2}>${200}     Set test variable    ${flag2}    ${NUM}
        should be true    ${flag2}>${flag1}
    END
    should not be equal as numbers    ${flag1}    100
    should not be equal as numbers    ${flag2}    100
    log to console    Check DL throughput successful
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}

check BTS throughput fluctuation
    [Arguments]      ${btslog}  ${ULorDL}=DL    ${CELL1}=16385    ${CELL2}=32769   ${throughput}=100
    ...    ${tolerance}=5    ${flag}=0     ${connection}=GNB_OAM
    log to console     check BTS throughput fluctuation
    ${TP_list}     Create List
    Connect to ENB with ssh    hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}     password=${TEST_PC_PASSWORD}    alias=${connection}
    FOR    ${NUM}    IN RANGE    ${1}    ${99}    1
        ${TP1}     Run keyword if    '${ULorDL}'=='DL'    Get DL throughput form btslog       CELL=${CELL1}    NUM=${NUM}      btslog=${btslog}
        ...        ELSE    Get UL throughput form btslog    CELL=${CELL1}    NUM=${NUM}      btslog=${btslog}
        ${TP2_length}     Run keyword if    '${ULorDL}'=='DL'      Get DL throughput length form btslog     CELL=${CELL2}    btslog=${btslog}
        ...      ELSE     Get UL throughput length form btslog      CELL=${CELL2}    btslog=${btslog}
        should not be equal as numbers      ${TP2_length}   0
        Run keyword if     ${TP2_length}<${NUM}      Continue For Loop
        ${TP2}    Run keyword if    '${ULorDL}'=='DL'    Get DL throughput form btslog       CELL=${CELL2}    NUM=${NUM}      btslog=${btslog}
        ...        ELSE    Get UL throughput form btslog    CELL=${CELL2}    NUM=${NUM}      btslog=${btslog}
        ${TP}     Set Variable IF      ${TP1}>${TP2}     ${TP1}     ${TP2}
        Append to list      ${TP_list}    ${TP}
     END
    log to console    ${TP_list}
    ${TP_list_length}     Get length   ${TP_list}
    should not be equal as numbers     ${TP_list_length}    0
    ${Expect_TP_value}      Evaluate    int(${throughput})*1024*1024/8
    ${TP_Number}     Create List
    FOR     ${TP_Number}      IN     @{TP_list}
        ${flag}     Run keyword if      ${TP_Number}<${Expect_TP_value}    Evaluate  ${flag}+1     ELSE    set variable    ${flag}
        log to console     ${flag}
    END
    should be true     ${flag}<${tolerance}
    [Teardown]    run keyword and ignore error    csn.Disconnect    connection=${connection}

Get UL throughput form btslog
    [Arguments]      ${CELL}    ${NUM}   ${btslog}    ${connection}=GNB_OAM
    csn.Send Command
    ...    command=cat ${LOG_PATH}/${btslog} |grep UlCounterUp|grep ${CELL}|awk '{print $10}'|head -${NUM}|tail -n 1|tr -cd "[0-9]"
    ...    connection=${connection}
    ${TP}    csn.Read Output    connection=${connection}
    ${TP}    Evaluate    int(${TP})
    [Return]    ${TP}

Get DL throughput form btslog
    [Arguments]      ${CELL}    ${NUM}   ${btslog}   ${connection}=GNB_OAM
    csn.Send Command
    ...    command=cat ${LOG_PATH}/${btslog}|grep DataPdu|grep ${CELL}|cut -d ':' -f 8|cut -d '|' -f 3|head -${NUM}|tail -n 1|tr -cd "[0-9]"
    ...    connection=${connection}
    ${TP}    csn.Read Output    connection=${connection}
    ${TP}    Evaluate    int(${TP})
    [Return]    ${TP}

Get UL throughput length form btslog
    [Arguments]      ${CELL}    ${btslog}   ${connection}=GNB_OAM
    csn.Send Command
    ...    command=cat ${LOG_PATH}/${btslog} |grep UlCounterUp|grep ${CELL}|awk '{print $10}'
    ...    connection=${connection}
    ${TP_number}    csn.Read Output    connection=${connection}
    ${TP_number_list}     split string    ${TP_number}    \n
    Remove values from list    ${TP_number_list}     ${EMPTY}
    Reverse List      ${TP_number_list}
    FOR   ${TP_list}    IN     @{TP_number_list}
        Run keyword if    '${TP_list}'=='0'     Remove from list    ${TP_number_list}     ${TP_list}
        Exit For loop if    '${TP_list}'!='0'
    END
    ${TPlength}    Get length     ${TP_number_list}
    [Return]      ${TPlength}

Get DL throughput length form btslog
    [Arguments]      ${CELL}    ${btslog}   ${connection}=GNB_OAM
    csn.Send Command
    ...    command=cat ${LOG_PATH}/${btslog}|grep DataPdu|grep ${CELL}|cut -d ':' -f 8|cut -d '|' -f 3
    ...    connection=${connection}
    ${TP_number}    csn.Read Output    connection=${connection}
    ${TP_number_list}     split string    ${TP_number}    \n
    Remove values from list    ${TP_number_list}     ${EMPTY}
    ${TPlength}    Get length     ${TP_number_list}
    [Return]      ${TPlength}

Wait for counter to be gathered after guard peroid
   [Arguments]  ${interval}=5
   ${list1}=    Create List         00  15  30  45
   ${list2}=    Create List         00  05  10  15  20  25  30  35  40  45  50  55
   ${list}=    Set Variable IF     '${interval}' == '5'    ${list2}    ${list1}
   ${actualTime}=     DateTime.Get Current Date    result_format=%M
   ...                                    time_zone=UTC
   ${time_check}    run keyword and return status   List Should Contain Value    ${list}    ${actualTime}
   run keyword if    ${time_check}   Sleep   ${interval} minutes
   PM Wait To Nearest Measurement Period    interval=${interval}

PM Wait To Nearest Measurement Period
   Log    PM Wait To Nearest Measurement Period    console=yes
   [Arguments]  ${interval}
   Wait Until Keyword Succeeds                     16 min
   ...                                            1 min
   ...                                             Wait For Right Period    interval=${interval}
   Sleep                                           60

Wait For Right Period
   [Arguments]  ${interval}
   ${list1}=           Create List         00  15  30  45
   ${list2}=           Create List         00  05  10  15  20  25  30  35  40  45  50  55
   ${list}=            Set Variable IF     '${interval}' == '5'    ${list2}    ${list1}
   ${actualTime}=     DateTime.Get Current Date    result_format=%M
   ...                                    time_zone=UTC
   ...                                    increment=8 hours
   ${actualHour}=     DateTime.Get Current Date    result_format=%H
   ...                                    time_zone=UTC
    ...                                    increment=8 hours
   ${date}=     DateTime.Get Current Date    result_format=%Y-%m-%d
   ...                                    time_zone=UTC
   ...                                    increment=8 hours
    ${date_nodash}=    DateTime.Get Current Date    result_format=%Y%m%d
   ...                                    time_zone=UTC
   ${actualEpoch}=    DateTime.Convert Date	       ${date} ${actualHour}:${actualTime}:00.000	epoch
   List Should Contain Value	           ${list}  ${actualTime}
   Log                                    ${actualTime}
   ${string_epoch}=   Convert To String   ${actualEpoch}
   ${nopoint_epoch}=   fetch from left   ${string_epoch}   .
   ${integer_epoch}=   convert to integer  ${nopoint_epoch}
   ${epoch_minus_interval}=   Evaluate   ${integer_epoch}-15*60
   ${epoch_minus_interval_string}=   Convert To String   ${epoch_minus_interval}
   set test variable    ${epoch_minus_interval_string}

Check PM counter result
    [Arguments]    ${counter_id}    ${index}=${0}    ${enb}=${False}    ${BTS}=BTS    ${CELLS}=CELLS
    ...    ${NRCELL}=NRCELL-1    ${counter_object}=NX2CC    ${connection}=GNB_OAM
    ${btsip}=    Set Variable If    ${enb}==${False}
    ...  ${tl.gnbs[${index}].dus[0].f1_m_ip_addr}    ${tl.enbs[${index}].airscale.common_units[0].lmp_connection.addr}
    Connect to gnb coam via ssl    bts_host=${btsip}    connection=${connection}
    ${counter_values}=    coam.get pm counters    couter_ids=${counter_id}    connection=${connection}
    ${result}    Get Dictionary Values   ${counter_values['${BTS}']['${CELLS}']['${NRCELL}']['${counter_object}']['${counter_id}']}
    [Return]    ${result}
    [Teardown]      COAM Teardown gnb connections   connection=${connection}

Cobham UE detach TM500 detach
    [Documentation]  Author: Zhang shanshan
    ...              Description: ${is_protocal_log_needed} if True, then it means protocal log is captured, so need to stop logging
    [Arguments]  ${e500_script_path}=${E500_SCRIPTS_BASE}    ${is_protocal_log_needed}=${False}
    tm500_hangzhou.TM500 detach    tm500_alias=${TMA_APP_ALIAS}    detach_script_path=${e500_script_path}/NSA_5G_UEdetach.txt

Kill iperf process on ue side for UL
    [Documentation]    Author: Zhang shanshan
    ...                Description: Kill iperf process on cobham via ssh command
    ...                   Precondition: Cygwin is installed in cobham control pc, all iperf processes will be closed
    [Arguments]    ${tma_ssh_alias}=${TMA_SSH_ALIAS}    ${retry_time}=10
    wait until keyword succeeds    2 min    10 s    traffic_via_iperf.Connect to cobham control pc via ssh    tma_ssh_alias=${tma_ssh_alias}
    Wait until keyword succeeds    ${retry_time}X    1 s    Kill iperf on ue side and verfify iperf is killed Except gperf
    ...     tma_ssh_alias=${tma_ssh_alias}
    [Teardown]    Run keyword and ignore error    traffic_via_iperf.Disconnect from cobham control pc via ssh

Kill iperf on ue side and verfify iperf is killed Except gperf
    [Documentation]    Author: Zhang shanshan
    ...                Description: Kill iperf process on cobham via ssh command
    ...                   Precondition: Cygwin is installed in cobham control pc, all iperf processes will be closed
    [Arguments]    ${tma_ssh_alias}=${TMA_SSH_ALIAS}
    ${is_iperf_process_exist}    Is iperf process exist on ue side for ul   tma_ssh_alias=${tma_ssh_alias}
    Run keyword if    ${is_iperf_process_exist}==${True}
    ...    Run keywords    csn.Execute    command=ps -Wef|grep iperf|grep -v "grep"|grep -v "gperf.exe"|awk '{print $2}'| xargs kill -9    
    ...    connection=${tma_ssh_alias}
    ...    AND    csn.Execute    command=TASKKILL /F /IM iperf.exe /T    connection=${tma_ssh_alias}
    ...    AND    sleep    200ms
    ${is_iperf_process_exist}    Is iperf process exist on ue side for ul   tma_ssh_alias=${tma_ssh_alias}
    Should not be true    ${is_iperf_process_exist}    msg=Iperf process is not killed on ue side

Is iperf process exists for ul
    [Documentation]    Author: Zhang shanshan
    ...                Description: iperf process started from app server side will be able to filter out with port number
    ...                             iperf process started from ue control pc, we are not able to see the port number
    [Arguments]    ${port}    ${connection}
    ${cmd_check_iperf_process}    Set variable if    ${port}==${None}    ps -Wef|grep iperf|grep -v "grep"|grep -v "gperf.exe"
    ...    ps -ef|grep iperf|grep -v "grep"|grep ${port}
    ${result}    csn.execute    command=${cmd_check_iperf_process}    connection=${connection}
    ${is_iperf_process_started}    Run keyword and return status    should not be empty    ${result.strip()}
    [Return]    ${is_iperf_process_started}

Is iperf process exist on ue side for ul
    [Documentation]    Author: Zhang shanshan
    ...                Description: check if iperf process eixsts from ue control pc. will also check if any iperf process
    ...                             is started from windows
    [Arguments]    ${tma_ssh_alias}=${TMA_SSH_ALIAS}
    ${is_iperf_process_started}    Is iperf process exists for ul   port=${None}    connection=${tma_ssh_alias}
    [Return]    ${is_iperf_process_started}

kill IPSL process
    Connect to cobham control pc via ssh
    csn.send command    command=taskkill /f /im "ips32.exe"       connection=tma_ssh
    Disconnect from cobham control pc via ssh

Check_TP_And_Bler_stable
    [Arguments]  ${dir_path}    ${ul_max_tp}    ${dl_max_tp}    ${bler_value}
    ${ul_tp_result}     Run Keyword And Continue On Failure      Viavi_Log_analysis.Check_One_UE_TP_Stable
    ...    dir_path=${dir_path}    direction=ul    check_value=${ul_max_tp}     expect_num=${5}    UE_ID=0
    ${dl_tp_result}     Run Keyword And Continue On Failure      Viavi_Log_analysis.Check_One_UE_TP_Stable
    ...    dir_path=${dir_path}    direction=dl    check_value=${dl_max_tp}      expect_num=${5}    UE_ID=0
    ${ul_bler_result}   Run Keyword And Continue On Failure      Viavi_Log_analysis.Check_One_UE_Bler_Stable
    ...     dir_path=${dir_path}    direction=ul    check_value=${bler_value}    expect_num=${5}    UE_ID=0
    ${dl_bler_result}   Run Keyword And Continue On Failure      Viavi_Log_analysis.Check_One_UE_Bler_Stable
    ...    dir_path=${dir_path}    direction=dl    check_value=${bler_value}     expect_num=${5}    UE_ID=0
    Run Keyword And Continue On Failure    Should Be Equal    ${ul_tp_result}    ${True}
    Run Keyword And Continue On Failure    Should Be Equal    ${dl_tp_result}    ${True}
    Run Keyword And Continue On Failure    Should Be Equal    ${ul_bler_result}    ${True}
    Run Keyword And Continue On Failure    Should Be Equal    ${dl_bler_result}    ${True}

Check_DL_TP_And_Bler_stable
    [Arguments]  ${dir_path}   ${dl_max_tp}    ${bler_value}
    ${dl_tp_result}     Run Keyword And Continue On Failure      Viavi_Log_analysis.Check_One_UE_TP_Stable
    ...    dir_path=${dir_path}    direction=dl    check_value=${dl_max_tp}      expect_num=${5}    UE_ID=0
    ${dl_bler_result}   Run Keyword And Continue On Failure      Viavi_Log_analysis.Check_One_UE_Bler_Stable
    ...    dir_path=${dir_path}    direction=dl    check_value=${bler_value}     expect_num=${5}    UE_ID=0
    Run Keyword And Continue On Failure    Should Be Equal    ${dl_tp_result}    ${True}
    Run Keyword And Continue On Failure    Should Be Equal    ${dl_bler_result}    ${True}

Check_UL_TP_And_Bler_stable
    [Arguments]  ${dir_path}    ${ul_max_tp}    ${bler_value}
    ${ul_tp_result}     Run Keyword And Continue On Failure      Viavi_Log_analysis.Check_One_UE_TP_Stable
    ...    dir_path=${dir_path}    direction=ul    check_value=${ul_max_tp}     expect_num=${5}    UE_ID=0
    ${ul_bler_result}   Run Keyword And Continue On Failure      Viavi_Log_analysis.Check_One_UE_Bler_Stable
    ...     dir_path=${dir_path}    direction=ul    check_value=${bler_value}    expect_num=${5}    UE_ID=0
    Run Keyword And Continue On Failure    Should Be Equal    ${ul_tp_result}    ${True}
    Run Keyword And Continue On Failure    Should Be Equal    ${ul_bler_result}    ${True}

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
    [Arguments]  ${logs_path}    ${time}=40s    ${connect}=Control_PC
    log to console    ${logs_path}
    csn.Connect to    hostname=${E500_IP}    username=${E500_USER}    password=${E500_PW}    alias=${connect}
    ${new_path}    set variable    /cygdrive/c/Users/nokia5G/Documents/CSV/${logs_path}[1]
    csn.send command    command=mkdir -p ${new_path}    connection=${connect}
    csn.send command    command=cd '${logs_path}[0]';scp *.csv ${new_path}     connection=${connect}
    sleep    ${time}
    Copy Viavi Log    logs_path=${new_path}
    csn.send command    command=rm -rf ${new_path}    connection=${connect}
    ${ute_path}    set variable    ${output_dir}/${logs_path}[1]
    [Return]  ${ute_path}
    [Teardown]    Run Keyword And Ignore error    csn.disconnect    connection=${connect}

Copy Viavi Log
    [Documentation]
    [Arguments]  ${logs_path}    ${ute_path}=${output_dir}    ${time}=40s    ${connect}=Test_PC
    csn.Connect to    hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}    alias=${connect}
    csn.send command    command=sshpass -p ${E500_PW} scp -r ${E500_USER}@${E500_IP}:${logs_path} ${ute_path}    connection=${connect}
    sleep    ${time}
    [Teardown]  Run Keyword And Ignore error    csn.disconnect    connection=${connect}

Download Viavi Log for 008
    [Documentation]
    [Arguments]  ${logs_path1}   ${logs_path2}   ${time}=40s    ${connect}=Control_PC
    csn.Connect to    hostname=${E500_IP}    username=${E500_USER}    password=${E500_PW}    alias=${connect}
    ${new_path}    set variable    /cygdrive/c/Users/nokia5G/Documents/CSV/${logs_path2}
    csn.send command    command=mkdir -p ${new_path}    connection=${connect}
    csn.send command    command=cd '${logs_path1}';scp *.csv ${new_path}     connection=${connect}
    sleep    ${time}
    Copy Viavi Log    logs_path=${new_path}
    csn.send command    command=rm -rf ${new_path}    connection=${connect}
    ${ute_path}    set variable    ${output_dir}/${logs_path2}
    [Return]  ${ute_path}
    [Teardown]    Run Keyword And Ignore error    csn.disconnect    connection=${connect}
