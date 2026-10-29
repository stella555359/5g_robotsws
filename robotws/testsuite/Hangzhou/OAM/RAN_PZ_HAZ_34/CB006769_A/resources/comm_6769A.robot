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
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot

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
${ue_type}    ${tl.ues[0].capabilities[1]}
${IPERF_ADDR}    ${tl.appserver.iperf_details.network_interface_address}
${IPERF_portlist}    ${tl.appserver.iperf_details.ports}
${appserver_addr}    ${tl.ues[0].iperf_details.ssh_connection_details.addr}
${LOG_PATH}    ${output_dir}
${luashark_path}    /opt/ute/luashark/luashark_script/generated_luashark
@{all_cell_info}    ${0}    ${1}    ${2}    ${3}    ${4}    ${5}
@{PCI_list}    ${37}    ${72}    ${225}
${GNB_PDU_IP}    ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${GNB_PDU_PORT}    ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}
@{ignore_history_fault}    ${7319}    ${7300}    ${9000}    ${61524}    ${61652}    ${61649}
...    ${61074}    ${61618}    ${4592}    ${1932}    ${4420}    ${4340}    ${4655}
${default_scf_path}     ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/
@{AWEUA_cells}    ${11780097}    ${11780098}    ${11780099}    ${11780100}
@{AHLOA_cells}    ${11780101}
@{AEHC_cells}    ${11780103}

*** Keywords ***
Rest Login DU
    [Arguments]    ${ip_address}=${DU_OAM_IP}    ${username}=${DU_OAM_WEBUI_USER}
    ...    ${password}=${DU_OAM_WEBUI_PASSWORD}    ${alias}=default
    [Documentation]   Rest Login DU
    Connect to gnb coam via ssl    bts_host=${ip_address}    username=${username}    password=${password}    connection=${alias}
    ${connection}    set variable    ${alias}
    [Return]    ${connection}

Rest Logout DU
    [Arguments]    ${alias}=default
    [Documentation]   Rest Logout DU
    coam.Teardown    connection=${alias}

Check BTS Should Be Normal
    [Arguments]    ${all_cell_info}=${all_cell_info}
    Log To Console  Check BTS Should Be Normal
    Rest Login DU
    Wait Until BTS Should Be Normal    all_cell_info=${all_cell_info}
    [Teardown]   Run Keyword And Ignore Error   Rest Logout DU

Wait Until BTS Should Be Normal
    [Arguments]   ${all_cell_info}=${all_cell_info}    ${retry}=1200s    ${retry_interval}=10s
    [Documentation]   Wait Until CBTS Status Should Be Normal, if CBTS status is abnormal during retry time,
    Wait Until Keyword Succeeds   ${retry}     ${retry_interval}    Verify all cells should be onair    connection=default

Gnb Cell Should Be Onair
    [Arguments]    ${all_cell_info}=${all_cell_info}    ${alias}=default    ${cell_type }=nr
    [Documentation]  Gnb Cell Should Be Onair, check method is via REST
    ${status}      coam.Get_Bts_Statuses   connection=${alias}
    ${operationalState}    Get From Dictionary    ${status}    operationalState
    Should Be true    '${operationalState}'=='Enabled' or '${operationalState}'=='enabled'
    ${blockingState}   Get From Dictionary    ${status}    blockingState
    Should Be Equal    ${blockingState}    Unblocked
    ${proceduralState}   Get From Dictionary    ${status}   proceduralState
    Should Be Equal    ${proceduralState}    OnAir
    #cell info
    ${cell_status}     coam.Get_Cells_Info   cell_type=${cell_type}
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
    [Arguments]    ${DU_OAM_IP}
    Log To Console    Set Default Scf
    ${connection}    Rest Login DU     ip_address=${DU_OAM_IP}
    ${version}    coam.get_sw_version    connection=${connection}
    ${version_list}    split string    ${version}    _
    ${if_common_load}     run keyword and return status    should contain    ${version_list[2]}    9999
    ${default_scf}    set variable if    ${if_common_load}    ${default_scf_path}SCF_SBTS00_ipv4.xml
    ...    ${default_scf_path}SCF_${version_list[0]}_ipv4.xml
#    set suite variable    ${default_scf}
    log to console   ${default_scf}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}
    [Return]    ${default_scf}

Commission Default SCF
    [Arguments]    ${ip_address}    ${default_scf}
    Log To Console    Commission Default SCF
    ${connection}    Rest Login DU    ip_address=${ip_address}
    COAM Commission with scf file    scf_file_path=${default_scf}    connection=${connection}
    [Teardown]    Rest Logout DU


UEs Attach And Check Attach Request
    Log To Console    UEs Attach And Check Attach Request
    FOR    ${i}    IN RANGE    ${3}
        power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${i}
        Log To Console    UE Attach
        ${5Grach_ed_0}    power_ue.UE Attach    ue_type=${ue_type}    attach_mode=5G_NSA    ue_index=${i}
        Log To Console    Verify attach
        power_ue.Verify attach    ue_type=${ue_type}    ue_index=${i}
        ...    5Grach_ed=${5Grach_ed_0}    4G_check=False
    END

UEs Attach Start Traffic And Check Throughput
    [Arguments]    ${cellid_list}=${PCI_list}
    Log To Console    UEs Attach Start Traffic And Check Throughput
    FOR    ${i}    IN RANGE    ${3}
        power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${i}
        Log To Console    UE Attach
        ${5Grach_ed_0}    power_ue.UE Attach    ue_type=${ue_type}    attach_mode=5G_NSA    ue_index=${i}
        Log To Console    Verify attach
        power_ue.Verify attach    ue_type=${ue_type}    ue_index=${i}
        ...    5Grach_ed=${5Grach_ed_0}    4G_check=False
        Log To Console    Start traffic
        power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=100MKbits/sec    ue_index=${i}
        ...    duration=300    ue_mode=NSA    iperf_port=${IPERF_portlist}[${i}]    iperf_type=via_command    process_num=${1}
        sleep    1s
        power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=100MKbits/sec    ue_index=${i}
        ...    duration=300    ue_mode=NSA    iperf_port=${IPERF_portlist}[${i}]    iperf_type=via_command    process_num=${1}
        Log To Console    Check throughput
        ${nrcell_dict}    create dictionary    ${37}=@{AHLOA_cells}    ${72}=@{AEHC_cells}    ${225}=@{AWEUA_cells}
        ${nrcell_id}    get from dictionary    ${nrcell_dict}    ${cellid_list[${i}]}
        ${log_path}    power_ue.Collect Tput     ue_type=samsung    duration=1m    log_dir=${OUTPUT_DIR}/
        run keyword and continue on failure    power_ue.Check Tput    ue_type=${ue_type}    direction=ul    target_throughput=10
        ...     min_percent=0    cells=${nrcell_id}    log=${log_path}
        ...     actCarrierAggregation=${True}
        run keyword and continue on failure    power_ue.Check Tput    ue_type=${ue_type}    direction=dl    target_throughput=30
        ...     min_percent=0    cells=${nrcell_id}    log=${log_path}
        ...     actCarrierAggregation=${True}
        Log To Console    Stop traffic
        run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${i}
        ...    iperf_port=${IPERF_portlist}[${i}]    ue_mode=NSA
        run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${i}
        ...    iperf_port=${IPERF_portlist}[${i}]    ue_mode=NSA
        Log To Console    UE Detach
        run keyword and ignore error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${i}
    END

Single UE Attach Start Traffic And Check Throughput
    [Arguments]    ${cellid_list}=${PCI_list}    ${ue_index}=${0}
    Log To Console    Single UE Attach Start Traffic And Check Throughput
    ${i}    set variable    ${ue_index}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${i}
    Log To Console    UE Attach
    ${5Grach_ed_0}    power_ue.UE Attach    ue_type=${ue_type}    attach_mode=5G_NSA    ue_index=${i}
    Log To Console    Verify attach
    power_ue.Verify attach    ue_type=${ue_type}    ue_index=${i}
    ...    5Grach_ed=${5Grach_ed_0}    4G_check=False
    Log To Console    Start traffic
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=100MKbits/sec    ue_index=${i}
    ...    duration=300    ue_mode=NSA    iperf_port=${IPERF_portlist}[${i}]    iperf_type=via_command    process_num=${1}
    sleep    1s
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=100MKbits/sec    ue_index=${i}
    ...    duration=300    ue_mode=NSA    iperf_port=${IPERF_portlist}[${i}]    iperf_type=via_command    process_num=${1}
    Log To Console    Check throughput
    ${nrcell_dict}    create dictionary    ${37}=@{AHLOA_cells}    ${72}=@{AEHC_cells}    ${225}=@{AWEUA_cells}
    ${nrcell_id}    get from dictionary    ${nrcell_dict}    ${cellid_list[${i}]}
    ${log_path}    power_ue.Collect Tput     ue_type=samsung    duration=1m    log_dir=${OUTPUT_DIR}/
    run keyword and continue on failure    power_ue.Check Tput    ue_type=${ue_type}    direction=ul    target_throughput=10
    ...     min_percent=0    cells=${nrcell_id}    log=${log_path}
    ...     actCarrierAggregation=${True}
    run keyword and continue on failure    power_ue.Check Tput    ue_type=${ue_type}    direction=dl    target_throughput=30
    ...     min_percent=0    cells=${nrcell_id}    log=${log_path}
    ...     actCarrierAggregation=${True}
    Log To Console    Stop traffic
    run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${i}
    ...    iperf_port=${IPERF_portlist}[${i}]    ue_mode=NSA
    run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${i}
    ...    iperf_port=${IPERF_portlist}[${i}]    ue_mode=NSA
    Log To Console    UE Detach
    run keyword and ignore error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${i}

Reset BTS And Wait Until On Air
    Log To Console    Reset BTS And Wait Until On Air
    Rest Login DU
    sleep    2s
    coam.reset_site
    wait until bts should be normal
    [Teardown]    Rest Logout DU

Power Off BTS And Wait Until On Air
    [Arguments]   ${retry}=1000s    ${retry_interval}=10s
    Log To Console    Power Off BTS And Wait Until On Air
    pdu.Setup Pdu    model=TOPYOUNG    host=${GNB_PDU_IP}    alias=pdu_alias
    pdu.Power Off    port=${GNB_PDU_PORT}    pdu_device=pdu_alias
    pdu.Get Port Status    port=${GNB_PDU_PORT}    pdu_device=pdu_alias
    Sleep    3s
    pdu.Power On    port=${GNB_PDU_PORT}    pdu_device=pdu_alias
    pdu.Get Port Status    port=${GNB_PDU_PORT}    pdu_device=pdu_alias
    Log To Console    Try to login...
    wait until keyword succeeds    ${retry}     ${retry_interval}    Rest Login DU
    Log To Console    wait until bts should be normal
    wait until bts should be normal
    [Teardown]    Rest Logout DU

Single UE Attach And Check Attach Request
    [Arguments]    ${ue_type}=${ue_type}    ${ue_index}=${0}    ${cell_list}=${cell_list0}
    Log To Console    Single UE Attach And Check Attach Request
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    Log To Console    UE Attach
    ${5Grach_ed_0}    power_ue.UE Attach    ue_type=${ue_type}    attach_mode=5G_NSA    ue_index=${ue_index}
    Log To Console    Verify attach
    power_ue.Verify attach    ue_type=${ue_type}    ue_index=${ue_index}
    ...    5Grach_ed=${5Grach_ed_0}    4G_check=False

Single UE Attach Failed
    [Arguments]    ${ue_index}=${0}
    Log To Console    Single UE Attach Failed
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    Log To Console    UE Attach
    ${5Grach_ed_0}   power_ue.UE Attach    ue_type=${ue_type}    attach_mode=5G_NSA    ue_index=${ue_index}
    Log To Console    Verify attach Failed
    run keyword and expect error    *5G RACH still not success after retry*    power_ue.Verify attach    ue_type=${ue_type}
    ...    ue_index=${ue_index}    5Grach_ed=${5Grach_ed_0}    4G_check=False

UEs Attach Failed
    Log To Console    UEs Attach Failed
    FOR    ${i}    IN RANGE    ${3}
        power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${i}
        Log To Console    UE Attach
        ${5Grach_ed_0}   power_ue.UE Attach    ue_type=${ue_type}    attach_mode=5G_NSA    ue_index=${i}
        Log To Console    Verify UEs attach Failed
        run keyword and expect error    *5G RACH still not success after retry*    power_ue.Verify attach    ue_type=${ue_type}
        ...    ue_index=${i}    5Grach_ed=${5Grach_ed_0}    4G_check=False
    END

Single UE Start Traffic And Check Throughput
    [Arguments]    ${physcell_ID}     ${ue_index}=${0}    ${port}=${0}
    Log To Console    Single UE Start Traffic And Check Throughput
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=100MKbits/sec    ue_index=${ue_index}
    ...    duration=200    ue_mode=NSA    iperf_port=${IPERF_portlist}[${port}]    iperf_type=via_command    process_num=${1}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=100MKbits/sec    ue_index=${ue_index}
    ...    duration=200    ue_mode=NSA    iperf_port=${IPERF_portlist}[${port}]    iperf_type=via_command    process_num=${1}
    sleep    30s
    Log To Console    Check Throughput
    ${nrcell_dict}    create dictionary    ${37}=${11780101}    ${72}=${11780103}    ${225}=${11780097}
    ...    ${226}=${11780098}    ${227}=${11780099}    ${228}=${11780100}
    ${nrcell_id}    get from dictionary    ${nrcell_dict}    ${physcell_ID}
    run keyword and continue on failure    power_ue.Check throughput    ue_type=${ue_type}    direction=ul
    ...    throughput=30    ue_index=${ue_index}    cellid=${nrcell_id}
    run keyword and continue on failure    power_ue.Check throughput    ue_type=${ue_type}    direction=dl
    ...    throughput=30    ue_index=${ue_index}    cellid=${nrcell_id}
    Log To Console    Stop traffic
    run keyword and ignore error   power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}
    ...    iperf_port=${IPERF_portlist}[${port}]    ue_mode=NSA
    run keyword and ignore error    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
    ...    iperf_port=${IPERF_portlist}[${port}]    ue_mode=NSA
    [Teardown]    run keyword and ignore error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${2}

Lock BBMOD
    [Arguments]    ${BBMOD_idx}=${1}    ${alias}=default
    Log To Console    Lock BBMOD
    Rest Login DU
    coam.lock    dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-${BBMOD_idx}    connection=${alias}
    sleep    5s
    [Teardown]    Rest Logout DU

Unlock BBMOD
    [Arguments]    ${BBMOD_idx}=${1}    ${alias}=default
    Log To Console    Unlock BBMOD
    Rest Login DU
    coam.unlock    dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-${BBMOD_idx}    connection=${alias}
    wait until bts should be normal
    [Teardown]    Rest Logout DU

Restart BBMOD
    [Arguments]    ${BBMOD_idx}=${1}    ${alias}=default
    Log To Console    Restart BBMOD
    Rest Login DU
    coam.reset_unit    dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-${BBMOD_idx}    reset_type=Warm    force_radio_reset=${True}
    ...    timeout=600s    connection=${alias}
    Log To Console    wait until bts should be normal
    wait until bts should be normal
    [Teardown]    Rest Logout DU

Lock Cell
    [Arguments]    ${cell_idx}=${1}    ${alias}=default
    Log To Console    Lock cell
    Rest Login DU
    coam.lock    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_idx}    connection=${alias}    timeout=60s
    sleep    5s
    [Teardown]    Rest Logout DU

Unlock Cell
    [Arguments]    ${cell_idx}=${1}    ${alias}=default
    Log To Console    Unlock cell
    Rest Login DU
    coam.unlock    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_idx}    connection=${alias}    timeout=60s
    Log To Console    wait until bts should be normal
    wait until bts should be normal
    [Teardown]    Rest Logout DU

Lock Cellgroup
    [Arguments]    ${cellgrp_idx}=${1}    ${alias}=default
    Log To Console    Lock Cellgroup
    Rest Login DU
    coam.lock    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-${cellgrp_idx}    connection=${alias}
    sleep    35s
    [Teardown]    Rest Logout DU

Unlock Cellgroup
    [Arguments]    ${cellgrp_idx}=${1}    ${alias}=default
    Log To Console    Unlock Cellgroup
    Rest Login DU
    coam.unlock    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-${cellgrp_idx}    connection=${alias}
    Log To Console    wait until bts should be normal
    wait until bts should be normal
    [Teardown]    Rest Logout DU

Lock BTS
    [Arguments]    ${NRDU_idx}=${1}    ${alias}=default
    Log To Console    Lock BTS
    Rest Login DU
    coam.lock    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRDU-${NRDU_idx}    connection=${alias}
    sleep    5s
    [Teardown]    Rest Logout DU

Unlock BTS
    [Arguments]    ${NRDU_idx}=${1}    ${alias}=default
    Log To Console    Unlock BTS
    Rest Login DU
    coam.unlock    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRDU-${NRDU_idx}    connection=${alias}
    Log To Console    wait until bts should be normal
    wait until bts should be normal
    [Teardown]    Rest Logout DU

Check if Unexpected History Alarm Exist
    ${fault_id_list}    Get BTS History Alarm FaultID
    return from keyword if    '${fault_id_list}' == '[]'
    ${ignore_fault}    set variable    ${ignore_history_fault}
    FOR    ${item}    IN    @{fault_id_list}
        run keyword and continue on failure    list should contain value    ${ignore_fault}    ${item}
    END

Get BTS History Alarm FaultID
    ${connection}    Rest Login DU
    Log To Console    get history alarm faultid
    ${alarm_info}    coam.get_historic_alarms    timeout=60    connection=${connection}
    ${fault_id_list}    create list
    FOR    ${item}    IN    @{alarm_info}
        ${fault_id_dic}    get from dictionary    ${item}    additionalFaultID
        append to list    ${fault_id_list}    ${fault_id_dic}
    END
    sort list    ${fault_id_list}
    [Return]    ${fault_id_list}
    [Teardown]    Rest Logout DU

Start Catch BTS Log
    [Arguments]   ${name}=btslog    ${bts_logs_dir}=/tmp/btslog2
    Log To Console    Start Catch BTS Log
    __Make empty BTS logs dir      bts_logs_dir=${bts_logs_dir}
    btslog.create_btslog_collector    name=${name}    log_dir=${bts_logs_dir}
    core.setup_collectors        names=${name}
    core.start_collectors        names=${name}
    btslog.set_suite_alias       ${name}

__Make empty BTS logs dir
    [Arguments]     ${bts_logs_dir}
    Run  if [ ! -d ${bts_logs_dir} ]; then mkdir ${bts_logs_dir}; else rm ${bts_logs_dir}/*; fi

Stop and collect btslog on local machine
    [Arguments]   ${name}=btslog
    Log To Console    Stop and collect btslog on local machine
    core.stop_collectors         names=${name}
    core.collect_collectors      names=${name}
    core.teardown_collectors     names=${name}

Check CA Point
    [Arguments]    ${bts_logs_dir}=/tmp/btslog2
    Log To Console    Check CA Point
    ssh.Connect to    hostname=${UTE_ADDRESS}    username=${UTE_USERNAME}    password=${UTE_PASSWORD}    alias=VM
    sleep    2s
    ssh.send_command    cat ${bts_logs_dir}/SYSLOG_*.LOG | grep 'CellSetupReq'| grep 'maxNbOfCRNTIPools'
    ...    connection=VM
    sleep    2s
    ${output}    ssh.read output    connection=VM
    run keyword and continue on failure    should not be empty    ${output}
    [Teardown]    ssh.disconnect    connection=VM

Save Snapshot Log
    [Arguments]    ${alias}=default    ${timeout}=600s
    Log To Console    Save Snapshot Log
    Rest Login DU
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    ${snapshot_file_path}    set variable    ${CURDIR}/../snapshot/${timestamp}_snapshot.zip
    coam.get_snapshot    target_file_name=${snapshot_file_path}    connection=${alias}    timeout=${timeout}
    sleep    10s
    [Return]    ${snapshot_file_path}
    [Teardown]    Rest Logout DU
