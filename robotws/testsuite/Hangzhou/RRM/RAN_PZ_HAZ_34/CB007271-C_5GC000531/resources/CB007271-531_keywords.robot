*** Settings ***
Library    taf.transport.ssh            WITH NAME    ssh
Library    taf.collectors.core          WITH NAME    core
Library    taf.collectors.tcpdump       WITH NAME    tcpdump
Library    taf.analyzer.pdml            WITH NAME    cpdml
Library    taf.sbts.oam.coam.admin       WITH NAME    coam
Library    taf.pdu                      WITH NAME    pdu
Library    String
Library    Collections
Library    OperatingSystem
Library    Process
Library    XML
Library    DateTime
Library    Telnet
Library     taf.rfrl.common_resources.python.SWConfig.SWConfig    WITH NAME    swconf
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/BIP_trace/BIP_trace_collector.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/log/l1l2bip_collect.robot

*** Variables ***
${DU_OAM_IP}    ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${DU_OAM_SSH_USERNAME}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${DU_OAM_SSH_PASSWORD}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${DU_OAM_WEBUI_URL}    https://${tl.gnbs[0].dus[0].f1_m_ip_addr}/
${DU_OAM_WEBUI_USER}    ${tl.gnbs[0].cu.oam_http_connection_details.username}
${DU_OAM_WEBUI_PASSWORD}    ${tl.gnbs[0].cu.oam_http_connection_details.password}
${UTE_ADDRESS}    ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}    ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}    ${tl.test_pc.default_ssh_connection_details.password}
${ue_type}    ${tl.ues[0].capabilities[1]}
${IPERF_portlist}    ${tl.appserver.iperf_details.ports}
${LOG_PATH}    ${output_dir}
${bip_log_file}    biplog
${flag}     ${0}

*** Keywords ***
################  SCF  #############
Suite Setup
    Power Off pDU    model=${model}    pdu_ip=${7432_eNB_PB_ASIK_IP}    pdu_port=${7432_eNB_PB_ASIK_PORT}
    Commission GNB SCF
    back_up swconfig file

Power Off pDU
    [Arguments]    ${model}    ${pdu_ip}    ${pdu_port}
    Log To Console    Power Off pDU
    pdu.Setup Pdu    model=${model}    host=${pdu_ip}    alias=pdu_alias
    pdu.Power Off    port=${pdu_port}    pdu_device=pdu_alias
    pdu.Get Port Status    port=${pdu_port}    pdu_device=pdu_alias
    Sleep    15s

Power On pDU
    [Arguments]    ${model}    ${pdu_ip}    ${pdu_port}
    Log To Console    Power On pDU
    pdu.Setup Pdu    model=${model}    host=${pdu_ip}    alias=pdu_alias
    pdu.Power On    port=${pdu_port}    pdu_device=pdu_alias
    pdu.Get Port Status    port=${pdu_port}    pdu_device=pdu_alias

Commission GNB SCF
    [Arguments]
    Log To Console  Commission GNB SCF
    Set Default scf name    SBTS_scf_name=SCF_SBTS00_531    Branch_scf_name=SCF_SBTS22R3_531
    Setup Commission SCF    gNB_ip=${gNB_ip}    default_scf=${default_scf}
    Wait Until Keyword Succeeds   20min     1min    Check BTS Should Be Normal    bts_host=${gNB_ip}    connection=GNB
    log to console    Commission GNB scf successful

Set Default scf name
    [Arguments]    ${SBTS_scf_name}    ${Branch_scf_name}    ${connection}=GNB
    Log To Console  Set Default scf name
    Connect to gnb coam via ssl     connection=${connection}
    ${version}    coam.get_sw_version    connection=${connection}
    ${version_list}    split string    ${version}    _
    set suite variable    ${version_list}
    ${if_common_load}     run keyword and return status    should contain    ${version_list[2]}    9999
    ${default_scf}    set variable if    ${if_common_load}    ${CURDIR_path}${SBTS_scf_name}.xml
    ...    ${CURDIR_path}${Branch_scf_name}.xml
    set suite variable    ${default_scf}
    log to console   ${default_scf}
    log to console   Set Default scf name successful
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}

Setup Commission SCF
    [Arguments]  ${gNB_ip}    ${default_scf}     ${connection}=GNB
    Log To Console  Setup Commission SCF
    Connect to gnb coam via ssl     connection=${connection}    bts_host=${gNB_ip}
    COAM Commission with scf file    scf_file_path=${default_scf}    connection=${connection}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}

Check BTS Should Be Normal
    [Arguments]    ${bts_host}=${gNB_ip}     ${connection}=GNB
    log to console    Check BTS Should Be Normal
    Connect to gnb coam via ssl     connection=${connection}    bts_host=${bts_host}
    Wait Until BTS Should Be Normal    connection=${connection}
    [Teardown]   Run Keyword And Ignore Error   coam.teardown    connection=${connection}

Wait Until BTS Should Be Normal
    [Arguments]   ${retry}=800s    ${retry_interval}=10s    ${connection}=default
    Wait Until Keyword Succeeds   ${retry}     ${retry_interval}    Check BTS Cell On Air    alias=${connection}

#Gnb Cell Should Be Onair
#    [Arguments]  ${alias}=default  ${cell_type }=nr   ${connection}=GNB
#    [Documentation]  Gnb Cell Should Be Onair, check method is via REST
#    ${bts_info}   coam.get_bts_info   connection=${alias}   timeout=10
#    ${cell_list}    Set Variable   ${bts_info['cells']['nr']}
#    FOR    ${cell}    IN    @{cell_list}
#        ${status}   Set Variable   ${cell['status']}
#        check cell onair    ${status}
#    END
#    log to console    Gnb Cell is Onair

Check BTS Cell On Air
    [Arguments]  ${connection}=GNB
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    connection=${connection}
    ${status}            coam.get_bts_statuses       connection=${connection}
    ${bts_status}        get from dictionary     ${status}     proceduralState
    should be equal      ${bts_status}      OnAir
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections   connection=${connection}

#check cell onair
#    [Arguments]  ${status}
#    Should Contain   ${status['proceduralStatus']}   configured
#    Should Contain   ${status['operationalState']}   enabled
#    Should Contain   ${status['usageState']}   Active

Rest Login DU
    [Arguments]  ${ip_address}=${DU_OAM_IP}        ${alias}=default
    ...          ${username}=${DU_OAM_WEBUI_USER}  ${password}=${DU_OAM_WEBUI_PASSWORD}
    [Documentation]   Rest Login DU
    Run Keyword And Ignore Error    Rest Logout DU   alias=${alias}
    Sleep  2
    ${connection}   coam.Connect To  bts_host=${ip_address}  bts_port=443
    ...                                    name=${alias}
    ...                                    username=${username}  password=${password}
    [Return]  ${connection}

Rest Logout DU
    [Arguments]  ${alias}=default
    [Documentation]   Rest Logout DU
    coam.Teardown  connection=${alias}

############# common keywords ##############
back_up swconfig file
    Log To Console    back_up swconfig file
    ssh.Connect to    hostname=${DU_OAM_IP}    username=${DU_OAM_SSH_USERNAME}    password=${DU_OAM_SSH_PASSWORD}
    ...    alias=DU
    swconf.Download_swConfig_file_from_asik_to_test_pc    localFilePath=${output_dir}/swconfig.txt    asik_alias=DU
    sleep    5s
    ssh.Disconnect    connection=DU
    ssh.Connect to    hostname=${UTE_ADDRESS}    username=${UTE_USERNAME}
    ...    password=${UTE_PASSWORD}    alias=UTE
    ssh.send_command    command=cp ${output_dir}/swconfig.txt ${output_dir}/swconfig_backup.txt    connection=UTE
    sleep    3s
    ssh.Disconnect    connection=UTE

Modify rdflag Swconfig File
    [Arguments]    ${params}
    Log To Console    Modify rdflag Swconfig File
    ssh.Connect to    hostname=${DU_OAM_IP}    username=${DU_OAM_SSH_USERNAME}    password=${DU_OAM_SSH_PASSWORD}
    ...    alias=DU
    swconf.Download_swConfig_file_from_asik_to_test_pc    localFilePath=${output_dir}/swconfig.txt    asik_alias=DU
    sleep   5s
    swconf.Modify_swConfig_file    parametersList=${params}    filePath=${output_dir}/swconfig.txt
    swconf.Upload_swConfig_file_to_asik_and_crasign    localFilePath=${output_dir}/swconfig.txt    asik_alias=DU
    sleep    5s
    ssh.send_command    command=reboot    connection=DU
    sleep    5s
    [Teardown]   run keyword and ignore error    ssh.Disconnect    connection=DU

replace rdflag Swconfig File
    Log To Console    replace rdflag Swconfig File
    ssh.Connect to    hostname=${DU_OAM_IP}    username=${DU_OAM_SSH_USERNAME}    password=${DU_OAM_SSH_PASSWORD}
    ...    alias=DU
    swconf.Upload_swConfig_file_to_asik_and_crasign    localFilePath=${swconfig_path}/swconfig.txt    asik_alias=DU
    sleep    5s
    ssh.send_command    command=reboot    connection=DU
    sleep    5s
    Wait Until Keyword Succeeds   20min     1min    Check BTS Should Be Normal    bts_host=${gNB_ip}    connection=GNB
    log to console    Modify rdflag Swconfig File successful
    [Teardown]   run keyword and ignore error    ssh.Disconnect    connection=DU

Single UE Attach
    [Arguments]    ${ue_type}=${ue_type}    ${ue_index}=${0}
    Log To Console    Single UE Attach
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    Log To Console    UE Attach
    ${5Grach_ed_0}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}
    Log To Console    Verify attach
    power_ue.Verify attach    ue_type=${ue_type}    ue_index=${ue_index}
    ...    5Grach_ed=${5Grach_ed_0}    4G_check=False

Start Traffic and Get Tput
    [Arguments]    ${cell_id}    ${ue_index}=${0}    ${port}=${0}    ${direction}=dl
    Log To Console    Start Traffic and Get Tput
    Log To Console    Start traffic
    power_ue.Start traffic    ue_type=${ue_type}    direction=${direction}    throughput=200MKbits/sec
    ...    ue_index=${ue_index}    duration=60    ue_mode=SA    iperf_port=${IPERF_portlist}[${port}]
    ...    iperf_type=via_command    process_num=${1}
    sleep    3s
    ${log_path}    power_ue.Collect Tput    ue_type=${ue_type}    duration=100s    ignore_time=10s
    Log To Console    stop traffic
    power_ue.Stop traffic    ue_type=${ue_type}    direction=${direction}    ue_index=${ue_index}
    ...    iperf_port=${IPERF_portlist}[${port}]    ue_mode=SA
    Log To Console    get throughput
    ${tput_result}    aastp.get_aasyslog_throughput    direction=dl    log=${log_path}
    ...    cells=${cell_id}    actCarrierAggregation=${False}
    [Return]    ${tput_result}

Start Traffic And Capture BIP Log
    [Arguments]    ${ue_index}=${0}    ${port}=${0}    ${direction}=dl    
    ...    ${target_file_name}=l1l2bip_log    ${interface}=L1-L2    ${host_ip}=${DU_OAM_IP}    
    ...    ${username}=${DU_OAM_WEBUI_USER}    
    ...    ${password}=${DU_OAM_WEBUI_PASSWORD}    ${target_dir}=${OUTPUT DIR}
    Log To Console    Start Traffic and Capture BIP Log
    ${connection}    ssh.Connect to    hostname=${DU_OAM_IP}    username=${DU_OAM_SSH_USERNAME}
    ...    password=${DU_OAM_SSH_PASSWORD}    alias=DU
#    Log To Console    prepare for capture bip
#    run keyword and continue on failure    ssh.send_command    command=cd /tmp && rm -rf tcpdump_L2L1_bip*
#    ...    connection=${connection}
#    Precondition for bip capture with gnbMirroring scripts    connection=${connection}
#    _replace_gnbMirroringConfig    connection=${connection}
#    Log To Console    Capture BIP Logs
#    ssh.send_command   command=sh /ffs/run/config/scripts/gnbMirroring.sh > /dev/null    connection=${connection}
    Collect Interface Mirroring Bip Collector    target_file_name=${target_file_name}    interface=${interface}    host_ip=${host_ip}
    ...    username=${username}    password=${password}
    Log To Console    Start traffic
    power_ue.Start traffic    ue_type=${ue_type}    direction=${direction}    throughput=50MKbits/sec
    ...    ue_index=${ue_index}    duration=60    ue_mode=SA    iperf_port=${IPERF_portlist}[${port}]
    ...    iperf_type=via_command    process_num=${1}
    sleep    5s
    Log To Console    stop traffic
    power_ue.Stop traffic    ue_type=${ue_type}    direction=${direction}    ue_index=${ue_index}
    ...    iperf_port=${IPERF_portlist}[${port}]    ue_mode=SA
    ${full_log_path}    Get Bip Log Via Interface Mirroring Collector    target_file_name=${target_file_name}    target_dir=${target_dir}
#    ${PID}    wait until keyword succeeds    1min    2s    Get PID    connection=${connection}
#    ...    command=ps -ef | grep tcpdump | grep -v grep | grep tcpdump_L2L1 | tail -n 1 |awk '{print $2}'
#    ssh.send_command    command=kill -9 ${PID}    connection=${connection}
#    ${output}    ssh.read_output    connection=${connection}
#    run keyword and continue on failure    should be empty    ${output}
#    sleep    5s
#    ssh.send_command    command=ls /tmp/*tcpdump_L2L1_bip* | wc -l    connection=${connection}
#    ${num}    ssh.read_output    connection=${connection}
    Log To Console    Copy BIP Logs To Test PC
    Copy BIP Logs To Test PC    target_file_name=${full_log_path}[${0}]
#    ${biplog_list}    create list
#    FOR    ${item}    IN RANGE    int(${num})
#       ssh.download_file    remote_path=/tmp/tcpdump_L2L1_bip_filtering_off.pcap${item}
#       ...    local_path=${LOG_PATH}/${bip_log_file}_${item}.pcap    connection=${connection}
#       append to list    ${biplog_list}    ${bip_log_file}_${item}.pcap
#    END
    Log To Console    UE detach
#    set suite variable    ${biplog_list}    ${biplog_list}
    Run keyword and ignore error    Stop Bip Log Via Interface Mirroring Collector    target_file_name=${target_file_name}
    [Teardown]   run keywords    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}     AND
    ...    ssh.Disconnect    connection=${connection}

Copy BIP Logs To Test PC
    [Arguments]  ${target_file_name}
    ${connection}    ssh.Connect to    hostname=${UTE_ADDRESS}    username=${UTE_USERNAME}    password=${UTE_PASSWORD}    alias=UTE
    ssh.send_command    command=mv ${target_file_name} ${OUTPUT DIR}/${bip_log_file}
    ...    connection=${connection}
    [Teardown]  ssh.Disconnect    connection=${connection}


################# case keywords #################
recover_swconfig
    Log To Console    recover_swconfig
    ssh.Connect to    hostname=${UTE_ADDRESS}    username=${UTE_USERNAME}
    ...    password=${UTE_PASSWORD}    alias=UTE
    ssh.send_command    command=cp ${output_dir}/swconfig_backup.txt ${output_dir}/swconfig.txt    connection=UTE
    sleep    3s
    ssh.Disconnect    connection=UTE
    ssh.Connect to    hostname=${DU_OAM_IP}    username=${DU_OAM_SSH_USERNAME}    password=${DU_OAM_SSH_PASSWORD}
    ...    alias=DU
    swconf.Upload_swConfig_file_to_asik_and_crasign    localFilePath=${output_dir}/swconfig.txt    asik_alias=DU
    sleep    5s
    ssh.send_command    command=reboot    connection=DU
    sleep    5s
    ssh.Disconnect    connection=DU
    wait until keyword succeeds    10min    10s    Rest Login DU
    Wait Until BTS Should Be Normal
    [Teardown]    Rest Logout DU

_replace_gnbMirroringConfig
    [Arguments]    ${connection}
    ssh.upload_file     local_path=${CURDIR}/gnbMirroringConfig.sh
    ...    remote_path=/ffs/run/config/scripts/gnbMirroringConfig.sh    connection=${connection}

Get PID
    [Arguments]    ${connection}    ${command}
    Log To Console    Get PID
    ssh.send_command    command=${command}   connection=${connection}
    ${PID}    ssh.read output    connection=${connection}
    ${PID}    strip_string    ${PID}
    should not be empty    ${PID}
    [Return]    ${PID}

Convert Pcap To Text
    [Arguments]  ${source}   ${target}   ${filter}   ${connection}
    Log To Console    Convert pcap to text
    ssh.execute    command=tshark -V -r ${source} -T text -Y ${filter} > ${target}
    ...    connection=${connection}
    ssh.await execution end    connection=${connection}    timeout=30min

Grep Text Content
    [Arguments]    ${txt_filename}    ${item}    ${connection}
    ssh.send_command    command=cat ${LOG_PATH}/${txt_filename} | grep '${item}'    connection=${connection}
    sleep    2s
    ${output}    ssh.read output    connection=${connection}
    [Return]    ${output}

Grep Message From TXT
    [Arguments]    ${filter1}    ${txt_filename}    ${item}
    Log To Console    Grep Message From TXT To List
    ${connection}    ssh.Connect to    hostname=${UTE_ADDRESS}    username=${UTE_USERNAME}
    ...    password=${UTE_PASSWORD}    alias=UTE
    ${filter1}=    CATENATE    ${filter1}
    Convert Pcap To Text    source=${LOG_PATH}/${bip_log_file}_0.pcap    target=${LOG_PATH}/${txt_filename}
    ...    filter="${filter1}"    connection=${connection}
    ${output}    Grep Text Content    txt_filename=${txt_filename}    item=${item}    connection=${connection}
    ${output_list}    set variable    ${output.split('\n')}
    log    ${output_list}
    [Teardown]    ssh.Disconnect    connection=${connection}
    [Return]    ${output_list}

Grep Message From TXT To List
    [Arguments]    ${filter1}    ${txt_filename}    ${item}
    Log To Console    Grep Message From TXT To List
    ${connection}    ssh.Connect to    hostname=${UTE_ADDRESS}    username=${UTE_USERNAME}
    ...    password=${UTE_PASSWORD}    alias=UTE
    ${filter1}=    CATENATE    ${filter1}
    Convert Pcap To Text    source=${LOG_PATH}/${bip_log_file}_0.pcap    target=${LOG_PATH}/${txt_filename}
    ...    filter="${filter1}"    connection=${connection}
    ${output}    Grep Text Content    txt_filename=${txt_filename}    item=${item}    connection=${connection}
    ${output_list}    set variable    ${output.split('\n')}
    should not be empty    ${output_list}
    ${output_list[0]}    strip string    ${output_list[0]}    left
    run keyword if    '${output_list[0]}' != 'numOfLayers (Uint8): 1'    reverse list   ${output_list}
    ${value_list}    create list
    FOR    ${item}    IN    @{output_list}
        ${item}    strip string    ${item}    left
        ${flag}    evaluate    ${flag}+${1}
        continue for loop if    '${item}'=='${EMPTY}' or float(${flag})>${10}
        ${result}    replace string    ${item}    ${SPACE}    ${EMPTY}
        ${result_list}    split string    ${result}    :
        run keyword if    '${result_list[1]}' != '2'    append to list    ${value_list}    ${result_list[1]}
    END
    log    ${value_list}
    [Teardown]    ssh.Disconnect    connection=${connection}
    [Return]    ${value_list}

Get NR_CELL PUSCH Counter
    [Arguments]    ${counter_id}    ${alias}=default
    Log To Console    Get NR_CELL PUSCH Counter
    Rest Login DU
    ${result}    coam.get_PM_counters    couter_ids=${counter_id}    connection=${alias}
    ${counter_list}    get dictionary values    ${result['BTS']['CELLS']['NRCELL-1']['NDLSQ']['${counter_id}']}
    [Return]    ${counter_list}
    [Teardown]    Rest Logout DU

########################  suite setup/teardown ######################
case_setup
    [Arguments]    ${params}
    Modify rdflag Swconfig File    params=${params}
    Wait Until Keyword Succeeds   20min     1min    Check BTS Should Be Normal    bts_host=${gNB_ip}    connection=GNB
    log to console    Modify rdflag Swconfig File successful
    robot_common_operations.Common case Setup

case_teardown
    Log To Console    case teardown
    ssh.Connect to    hostname=${UTE_ADDRESS}    username=${UTE_USERNAME}
    ...    password=${UTE_PASSWORD}    alias=UTE
    ssh.send_command    command=cp ${output_dir}/swconfig_backup.txt ${output_dir}/swconfig.txt    connection=UTE
    sleep    3s
    ssh.Disconnect    connection=UTE
    ssh.Connect to    hostname=${DU_OAM_IP}    username=${DU_OAM_SSH_USERNAME}    password=${DU_OAM_SSH_PASSWORD}
    ...    alias=DU
    swconf.Upload_swConfig_file_to_asik_and_crasign    localFilePath=${output_dir}/swconfig.txt    asik_alias=DU
    sleep    5s
    CI_interface.Common Case Teardown
    robot_common_operations.Common Case Teardown
    [Teardown]    ssh.Disconnect    connection=DU

Suite Teardown
    recover_swconfig
    remove files    ${LOG_PATH}/*.txt

################### check keywords####################
Check MCS Counter
    [Arguments]    ${counter_result_list}
    Log To Console    Check MCS Counter
    ${counter_log_26}    Count Signalling In BIP Log    filter1=dldata_pdschsendreq    item=mcs (Uint8): 26
    ${status_26}    run keyword and return status    should be true    ${counter_log_26}>0
    ${counter_log_27}    Count Signalling In BIP Log    filter1=dldata_pdschsendreq    item=mcs (Uint8): 27
    ${status_27}    run keyword and return status    should be true    ${counter_log_27}>0
    should be true    ${status_26} or ${status_27}
    should be true    abs(${counter_log_26}-${counter_result_list[0]}) < ${10}
    should be true    abs(${counter_log_27}-${counter_result_list[1]}) < ${10}

Check PMI Counter
    [Arguments]    ${counter_result_list}
    Log To Console    Check PMI Counter
    ${counter_PMI3}    Count Signalling In BIP Log    filter1=DlData_PdschGrant.codebookIndex == 3    item=codebookIndex
    should be true    abs(${counter_PMI3}-${counter_result_list[2]}) < ${300}

Count Signalling In BIP Log
    [Arguments]    ${filter1}    ${item}
    ${connection}    ssh.Connect to    hostname=${UTE_ADDRESS}    username=${UTE_USERNAME}
    ...    password=${UTE_PASSWORD}    alias=UTE
    ${final_list}    create list
    FOR    ${biplog}    IN    @{biplog_list}
        ${filter1}=    CATENATE    ${filter1}
        Convert Pcap To Text    source=${LOG_PATH}/${biplog}    target=${LOG_PATH}/PdschSendReq.txt
        ...    filter="${filter1}"    connection=${connection}
        ${result}    Grep Text Content    txt_filename=PdschSendReq.txt     item=${item}    connection=${connection}
        ${result_list}    set variable    ${result.split('\n')}
        ${not_empty}   run keyword and return status    should not be empty    ${result_list}
        ${final_list}     run keyword if    ${not_empty}    evaluate    ${final_list}+${result_list}
    END
    ${counter_log}    get length    ${final_list}
    [Teardown]    ssh.Disconnect    connection=${connection}
    [Return]    ${counter_log}

Check PMI1&2&3
    Log To Console    Check TPMI
    ${value_list1}    Grep Message From TXT To List    filter1=DlData_PdschGrant.codebookIndex == 1
    ...    txt_filename=PdschSendReq2.txt     item=codebookIndex
    ${stauts1}    run keyword and return status    should not be empty    ${value_list1}
    ${value_list2}    Grep Message From TXT To List    filter1=DlData_PdschGrant.codebookIndex == 2
    ...    txt_filename=PdschSendReq2.txt     item=codebookIndex
    ${stauts2}    run keyword and return status    should not be empty    ${value_list2}
    ${value_list3}    Grep Message From TXT To List    filter1=DlData_PdschGrant.codebookIndex == 3
    ...    txt_filename=PdschSendReq2.txt     item=codebookIndex
    ${stauts3}    run keyword and return status    should not be empty    ${value_list3}
    [Return]    ${stauts1}    ${stauts2}    ${stauts3}

Check PUSCH Counter
    [Arguments]    ${counter_rank}
    Log To Console    Check PUSCH Counter
    Log To Console    sleep 5min
    sleep    5min
    ${counter_list1}    create list
    FOR    ${item}    IN    @{counter_rank}
        ${counter_list2}    Get NR_CELL PUSCH Counter    counter_id=${item}
        append to list    ${counter_list1}    ${counter_list2[-1]}
    END
    ${status}    run keyword and return status    list should contain value    ${counter_list1}    0
    run keyword if    ${status}   sleep   5min
    ${counter_result_list}    create list
    FOR    ${item}    IN    @{counter_rank}
        ${counter_list}    Get NR_CELL PUSCH Counter    counter_id=${item}
        ${counter_list_length}    get length    ${counter_list}
        ${counter}    run keyword if    ${counter_list_length}>=2   evaluate   ${counter_list[-1]} + ${counter_list[-2]}
        ...    ELSE     evaluate    ${counter_list[-1]} + ${0}
        append to list    ${counter_result_list}    ${counter}
    END
    [Return]    ${counter_result_list}

Check CSI And RANK Message
    [Arguments]    ${item1}=DlData_CsiRsSendReq_t     ${item2}=numOfLayers (l1_common_numOfPucchLayers_t)
    ...    ${item2_layer}=NUM_OF_PUCCH_LAYERS_VAL_1(1)    ${item3}=numOfLayers (Uint8)    ${item3_layer}=${2}
    Log To Console    Check CSI from UE
    ${value_list1}   Grep Message From TXT   filter1=dldata_csirssendreq   txt_filename=csirssendreq.txt   item=${item1}
    should not be empty    ${value_list1}
    Log To Console    Check Rank from Pucch
    ${value_list2}    Grep Message From TXT To List    filter1=uldata_pucchreceivereq   txt_filename=PucchReceiveReq.txt
    ...     item=${item2}
    FOR    ${item_value}    IN    @{value_list2}
        should be equal    ${item_value}    ${item2_layer}
    END
    Log To Console    Check Rank from Pdsch
    ${value_list3}    Grep Message From TXT To List    filter1=dldata_pdschsendreq    txt_filename=PdschSendReq.txt
    ...    item=${item3}
    FOR    ${item_value}    IN    @{value_list3}
        should be equal as numbers    ${item_value}    ${item3_layer}
    END

get and check total tput
    [Arguments]    ${tput_result}
    log to console    get and check total tput
    ${sum_TP}    set variable    ${0}
    FOR    ${item}    IN    @{tput_result}
        ${TP}    get from dictionary    ${item}    peak
        ${sum_TP}     evaluate    ${sum_TP}+${TP}
    END
    should be true    float(${sum_TP}) > ${125}

Check RANK And TPMI Message
    [Arguments]    ${item1}=numOfLayers (Uint8)    ${item2}=codebookIndex    ${item3}=NUM_OF_PUCCH_LAYERS_VAL_1
    ...    ${flayer_num}=${1}    ${layer_num}=NUM_OF_PUCCH_LAYERS_VAL_1(1)
    Log To Console    Check Rank In Pdsch
    ${value_list1}    Grep Message From TXT To List    filter1=DlData_PdschGrant.numOfLayers
    ...    txt_filename=PdschSendReq.txt     item=${item1}
    FOR    ${item_value}    IN    @{value_list1}
        should be equal as numbers    ${item_value}    ${flayer_num}
    END
    Log To Console    Check TPMI
    ${value_list2}    Grep Message From TXT To List    filter1=DlData_PdschGrant.codebookIndex
    ...    txt_filename=PdschSendReq2.txt    item=${item2}
    should not be empty    ${value_list2}
    ${stauts1}    ${stauts2}    ${stauts3}    Check PMI1&2&3
    should be true    ${stauts1} or ${stauts2} or ${stauts3}
    Log To Console    Check Rank In Pucch
    ${value_list3}    Grep Message From TXT To List    filter1=UlData_pucchReceiveReqPucchResource_t.numOfLayers
    ...    txt_filename=PucchReceiveReq.txt     item=${item3}
    FOR    ${item_value}    IN    @{value_list3}
        should be equal as strings    ${item_value}    ${layer_num}    ignore_case=${True}
    END
