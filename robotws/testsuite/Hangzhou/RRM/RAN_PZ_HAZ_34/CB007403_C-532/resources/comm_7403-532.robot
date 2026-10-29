*** Settings ***
Documentation
...   author: zheyuan.chen@nokia-sbell.com
...   contact: zheyuan.chen@nokia-sbell.com

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
${BTS_ID}    ${tl.gnbs[0].instance_id}
${NRBTS_ID}    ${tl.gnbs[0].global_bts_id}
${ENB_OAM_IP}    ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${ENB_BTS_ID}    ${tl.enbs[0].global_bts_id}
${ue_type}    ${tl.ues[0].capabilities[1]}
${IPERF_ADDR}    ${tl.appserver.iperf_details.network_interface_address}
${IPERF_portlist}    ${tl.appserver.iperf_details.ports}
${appserver_addr}    ${tl.ues[0].iperf_details.ssh_connection_details.addr}
${LOG_PATH}    ${output_dir}
${luashark_path}    /opt/ute/luashark/luashark_script/generated_luashark
@{all_cell_info}    ${0}
${default_scf_path}     ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/
@{rdflags_rank1_TPMI0}    0x580019=1    0x58010d=0
@{rdflags_rank1_TPMI1}    0x580019=1    0x58010d=1
@{rdflags_rank2_TPMI0}    0x580019=2    0x58010e=0
${bip_log_file}    biplog.pcap
${TS_LOG_PATH_BASE}    ${output_dir}
${TS_CASE_LOG_PATH}    ${output_dir}

*** Keywords ***
Rest Login DU
    [Arguments]    ${ip_address}=${DU_OAM_IP}    ${username}=${DU_OAM_WEBUI_USER}
    ...    ${password}=${DU_OAM_WEBUI_PASSWORD}    ${alias}=default
    [Documentation]   Rest Login DU
    Connect to gnb coam via ssl    bts_host=${ip_address}    username=${username}    password=${password}    connection=${alias}
    ${connection}    set variable    ${alias}
    [Return]    ${connection}

Rest Logout DU
    [Arguments]  ${alias}=default
    [Documentation]   Rest Logout DU
    coam.Teardown  connection=${alias}

Check BTS Should Be Normal
    Log To Console  Check BTS Should Be Normal
    Rest Login DU
    Wait Until BTS Should Be Normal
    [Teardown]   Run Keyword And Ignore Error   Rest Logout DU

Wait Until BTS Should Be Normal
    [Arguments]   ${retry}=1200s    ${retry_interval}=10s
    [Documentation]   Wait Until CBTS Status Should Be Normal, if CBTS status is abnormal during retry time,
    Wait Until Keyword Succeeds   ${retry}     ${retry_interval}    Verify all cells should be onair    connection=default

Gnb Cell Should Be Onair
    [Arguments]    ${alias}=default   ${cell_type }=nr
    [Documentation]  Gnb Cell Should Be Onair, check method is via REST
    ${status}      coam.Get_Bts_Statuses   connection=${alias}
    ${operationalState}    Get From Dictionary    ${status}    operationalState
    should be equal as strings    ${operationalState}    Enabled    ignore_case=${True}
    ${blockingState}   Get From Dictionary    ${status}    blockingState
    should be equal as strings    ${blockingState}    Unblocked    ignore_case=${True}
    ${proceduralState}   Get From Dictionary    ${status}   proceduralState
    should be equal as strings    ${proceduralState}    OnAir    ignore_case=${True}
    #cell info
    ${cell_status}     coam.Get_Cells_Info   cell_type=${cell_type}    connection=${alias}
    FOR    ${item}    IN    @{all_cell_info}
        ${Status}    Get From Dictionary    ${cell_status[${item}]}    status
        ${tmp}   Get From Dictionary    ${status}    operationalState
        should be equal as strings    ${tmp}    Enabled    ignore_case=${True}
        ${tmp}   Get From Dictionary    ${status}  administrativeState
        should be equal as strings    ${tmp}    Unlocked    ignore_case=${True}
        ${tmp}   Get From Dictionary    ${status}  blockingState
        should be equal as strings    ${tmp}    Unblocked    ignore_case=${True}
        ${tmp}   Get From Dictionary    ${status}  usageState
        should be equal as strings    ${tmp}    Active    ignore_case=${True}
    END

suite setup to prepare default scf
    [Arguments]    ${SBTS_scf_name}    ${Branch_scf_name}
    Log To Console    Set Default Scf
    ${connection}    Rest Login DU    alias=GNB_OAM
    ${version}    coam.get_sw_version    connection=${connection}
    ${version_list}    split string    ${version}    _
    ${if_common_load}     run keyword and return status    should contain    ${version_list[2]}    9999
    ${default_scf}    set variable if    ${if_common_load}    ${default_scf_path}${SBTS_scf_name}
    ...    ${default_scf_path}${Branch_scf_name}
    log to console   ${default_scf}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}
    [Return]    ${default_scf}

Commission Default SCF
    [Arguments]    ${default_scf}
    Log To Console    Commission Default SCF
    ${connection}    Rest Login DU    ip_address=${DU_OAM_IP}
    COAM Commission with scf file    scf_file_path=${default_scf}    connection=${connection}
    Wait Until BTS Should Be Normal
    [Teardown]    Rest Logout DU

Judge Version
    ${connection}    Rest Login DU    alias=GNB_OAM
    ${version}    coam.get_sw_version    connection=${connection}
    ${version_list}    split string    ${version}    _
    ${if_22R1_version}     run keyword and return status    should contain    ${version_list[0]}    SBTS22R1
    [Return]    ${if_22R1_version}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}

Modify rdflag Swconfig File
    [Arguments]    ${params}
    Log To Console    Modify rdflag Swconfig File
    ssh.Connect to    hostname=${DU_OAM_IP}    username=${DU_OAM_SSH_USERNAME}    password=${DU_OAM_SSH_PASSWORD}    alias=DU
    swconf.Download_swConfig_file_from_asik_to_test_pc    localFilePath=${output_dir}/swconfig.txt    asik_alias=DU
    sleep   5s
    swconf.Modify_swConfig_file    parametersList=${params}    filePath=${output_dir}/swconfig.txt
    swconf.Upload_swConfig_file_to_asik_and_crasign    localFilePath=${output_dir}/swconfig.txt    asik_alias=DU
    sleep    5s
    ssh.send_command    command=reboot    connection=DU
    sleep    5s
    [Teardown]   run keyword and ignore error    ssh.Disconnect    connection=DU

Modify ullaIniMcs Parameter
    [Arguments]    ${Actual_value}
    Log To Console    Modify ullaIniMcs Parameter
    wait until keyword succeeds    10min    10s    Rest Login DU
    Wait Until BTS Should Be Normal
    ${dict}    create dictionary    parameterName=ullaIniMcs    operation=update    value=${Actual_value}
    ${list}    create list    ${dict}
    coam.perform_object_recommissioning    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-5
    ...    parameter=${list}    operation=update     skip_parameter_relation_errors=${True}    should_activate=${True}
    sleep    10s
    [Teardown]    Rest Logout DU

Single UE Attach
    [Arguments]    ${ue_type}=${ue_type}    ${ue_index}=${1}
    Log To Console    Single UE Attach
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    Log To Console    UE Attach
    ${5Grach_ed_0}    power_ue.UE Attach    ue_type=${ue_type}    attach_mode=5G_NSA    ue_index=${ue_index}
    Log To Console    Verify attach
    power_ue.Verify attach    ue_type=${ue_type}    ue_index=${ue_index}
    ...    5Grach_ed=${5Grach_ed_0}    4G_check=False

Single UE Start Traffic And Check Throughput
    [Arguments]    ${ue_index}=${1}    ${port}=${0}
    Log To Console    Single UE Start Traffic And Check Throughput
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=50MKbits/sec    ue_index=${ue_index}
    ...    duration=600    ue_mode=NSA    iperf_port=${IPERF_portlist}[${port}]    iperf_type=via_command    process_num=${1}
    sleep    30s
    Log To Console    Check Throughput
    run keyword and continue on failure    power_ue.Check throughput    ue_type=${ue_type}    direction=ul
    ...    throughput=10    ue_index=${ue_index}

Single UE Stop Traffic And Detach
    [Arguments]    ${ue_index}=${1}    ${port}=${0}
    Log To Console    stop traffic
    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}
    ...    iperf_port=${IPERF_portlist}[${port}]    ue_mode=NSA
    Log To Console    UE detach
    [Teardown]    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

Capture BIP Logs
    ${connection}    ssh.Connect to    hostname=${DU_OAM_IP}    username=${DU_OAM_SSH_USERNAME}
    ...    password=${DU_OAM_SSH_PASSWORD}    alias=DU
    Log To Console    prepare for capture bip
    run keyword and continue on failure    ssh.send_command    command=cd /tmp && rm -rf tcpdump_L2L1_bip*    connection=${connection}
    Precondition for bip capture with gnbMirroring scripts    connection=${connection}
    _replace_gnbMirroringConfig    connection=${connection}
    Log To Console    Capture BIP Logs
    ssh.send_command   command=sh /ffs/run/config/scripts/gnbMirroring.sh > /dev/null    connection=${connection}
    sleep    7s
    ${PID}    wait until keyword succeeds    1min    2s    Get PID    connection=${connection}
    ...    command=ps -ef | grep tcpdump | grep -v grep | grep tcpdump_L2L1 | tail -n 1 |awk '{print $2}'
    ssh.send_command    command=kill -9 ${PID}    connection=${connection}
    ${output}    ssh.read_output    connection=${connection}
    should be empty    ${output}
    sleep    10s
    Log To Console    Copy BIP Logs To Test PC
    ssh.download_file    remote_path=/tmp/tcpdump_L2L1_bip_filtering_off.pcap0
    ...    local_path=${LOG_PATH}/${bip_log_file}    connection=${connection}
    [Teardown]    ssh.Disconnect    connection=${connection}

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
    ssh.execute
    ...    command=tshark -V -r ${source} -T text -Y ${filter} > ${target}
    ...    connection=${connection}
    ssh.await execution end    connection=${connection}    timeout=30min

Grep Text Content
    [Arguments]    ${txt_filename}    ${item}    ${connection}
    ssh.send_command    command=cat ${LOG_PATH}/${txt_filename} | grep '${item}'    connection=${connection}
    sleep    2s
    ${output}    ssh.read output    connection=${connection}
    [Return]    ${output}

Grep Message From TXT For List
    [Arguments]    ${filter1}    ${txt_filename}    ${item}
    Log To Console    Grep Message From TXT
    ${connection}    ssh.Connect to    hostname=${UTE_ADDRESS}    username=${UTE_USERNAME}
    ...    password=${UTE_PASSWORD}    alias=UTE
    ${filter1}=    CATENATE    ${filter1}
    Convert Pcap To Text    source=${LOG_PATH}/${bip_log_file}    target=${LOG_PATH}/${txt_filename}
    ...    filter="${filter1}"    connection=${connection}
    ${output}    Grep Text Content    txt_filename=${txt_filename}    item=${item}    connection=${connection}
    ${output_list}    set variable    ${output.split('\n')}
    should not be empty    ${output}
    ${value_list}    create list
    FOR    ${item}    IN    @{output_list}
        ${item}    strip string    ${item}    left
        continue for loop if    '${item}'=='${EMPTY}'
        ${result}    replace string    ${item}    ${SPACE}    ${EMPTY}
        ${result_list}    split string    ${result}    :
        append to list    ${value_list}    ${result_list[1]}
    END
    log    ${value_list}
    [Teardown]    ssh.Disconnect    connection=${connection}
    [Return]    ${value_list}

Get NR_CELL PUSCH Counter
    [Arguments]    ${counter_id}    ${alias}=default
    Log To Console    Get NR_CELL PUSCH Counter
    Rest Login DU
    ${result}    coam.get_PM_counters    couter_ids=${counter_id}    connection=${alias}
    ${counter_list}    get dictionary values    ${result['BTS']['CELLS']['NRCELL-5']['NULSQ']['${counter_id}']}
    [Return]    ${counter_list}
    [Teardown]    Rest Logout DU

Check UE Peak Throughput
    [Arguments]    ${ue_index}=${1}    ${port}=${0}    ${direction}=ul
    Log To Console    Check Peak Throughput
    Single UE Attach
    Log To Console    start traffic
    power_ue.Start traffic    ue_type=${ue_type}    direction=${direction}    throughput=300MKbits/sec    ue_index=${ue_index}
    ...    duration=60    ue_mode=NSA    iperf_port=${IPERF_portlist}[${port}]    iperf_type=via_command    process_num=${1}
    sleep    5s
    Log To Console    check throughput
    ${log_path}    power_ue.Collect Tput    ue_type=${ue_type}    duration=30s    ignore_time=5s
    ${cell_list}    create list    32773
    run keyword and continue on failure    power_ue.Check Tput    ue_type=${ue_type}    direction=${direction}    log=${log_path}     
    ...    cells=${cell_list}    target_throughput=40
    Log To Console    stop traffic
    power_ue.Stop traffic    ue_type=${ue_type}    direction=${direction}    ue_index=${ue_index}
    ...    iperf_port=${IPERF_portlist}[${port}]    ue_mode=NSA
    [Teardown]   run keyword and ignore error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

