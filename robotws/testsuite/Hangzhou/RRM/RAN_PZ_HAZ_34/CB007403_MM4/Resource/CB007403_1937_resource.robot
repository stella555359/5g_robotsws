*** Settings ***
Documentation
...    author: Wang Debbie
...    contact: debbie.wang@nokia-sbell.com
...    squad group: 5G_PZ_MMW_HZ_4_SG
...    Feature 5GC001937_OTA program

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/rrm_log_check.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_cu.robot
Library    ute_reporting_portal
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/kpi_reporter.py
Library    kpi_reporter.KpiReporter    WITH NAME    KpiReporter

*** Variables ***
${tmp_lua_dir}    /home/ute/wireshark/plugins/luashark.lua
${SCF_PATH}   ${commissionings_path}/HGZ/${testline_name}/
${ue_type}    ${tl.ues[0].capabilities[1]}
${CU_addr}                    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}            
${CU_username}                ${tl.gnbs[0].cu.oam_ssh_connection_details.username}         
${CU_password}                ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${gNB_username}            ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gNB_password}            ${tl.gnbs[0].cu.oam_http_connection_details.password}
${UL_PORT}      ${tl.ues[0].iperf_details.ports[0]}
${DL_PORT}      ${tl.ues[0].iperf_details.ports[1]}
${4G_IP}        ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${BTS_ID}       ${tl.gnbs[0].instance_id}
@{5G_RU_id_list_749}        ${3}
@{4G_RU_id_list_749}        ${1}
${5G_BTS_ID_749}            7502
${4G_BTS_ID_749}            10725
@{RU_lock_status}           Locked    enabled    Idle    configured
@{empty_list}

*** Keywords ***
All Case Suite Setup
    [Arguments]
    robot_common_operations.Common Suite Setup
    Determine whether to lock based on RU status    lock_ru_list=${5G_RU_id_list_749}    bts_host=10.71.215.244    BTS_ID=${5G_BTS_ID_749}
    Determine whether to lock based on RU status    lock_ru_list=${4G_RU_id_list_749}    bts_host=10.71.215.243    BTS_ID=${4G_BTS_ID_749}

COAM Check GNB_DU cell on air
    [Documentation]  Author:
    ...              Description: Check if GNB is in cell on air status
    Cloud DU connect to gnb coam via ssl
    Verify all cells should be onair
    [Teardown]   COAM Teardown gnb connections

Get cell numbers
    Cloud DU connect to gnb coam via ssl
    ${bts_info}   coam.get_bts_info   connection=GNB_OAM   timeout=10
    ${cell_list}   Run Keyword If   ${bts_info.has_key('requestMessage')}
    ...   Set Variable   ${bts_info['requestMessage']['cells']['nr']}
    ...   ELSE   Set Variable   ${bts_info['cells']['nr']}   
    ${cell_numbers}    get length    ${cell_list}
    ${sample_times}=    Evaluate    ${cell_numbers}*10
    Log To Console    current env cell number is ${cell_numbers}
    Log To Console    current env sample times is ${sample_times}
    set suite variable       ${cell_numbers}
    set suite variable       ${sample_times}

Common Setup
    Run keyword and continue on failure    Wait Until Keyword Succeeds    15min    20s    step1: Check all cells status
    step2: Scf commission and wait for on-air

Restart CU
    csn.connect_to    hostname=${CU_addr}    username=${CU_username}    password=${CU_password}    alias=cu_oam
    csn.SendCommand    command=sudo reboot    connection=cu_oam
    csn.Disconnect    connection=cu_oam

change 4G configuration
    Cloud DU connect to gnb coam via ssl    bts_host=${4G_IP}    connection=4G_admin
    coam.Perform Parameter Recommissioning
    ...    dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-1
    ...    parameter=defaultLnRelGnbCellId
    ...    value=1
    ...    operation=update
    ...    skip_parameter_relation_errors=${True}
    ...    should_activate=${True}
    ...    connection=4G_admin
    [Teardown]  coam.teardown     connection=4G_admin
        
step1: Check all cells status
    log to console      step1: Check all cells status
#    change 4G configuration
    COAM Check GNB_DU cell on air

step2: Scf commission and wait for on-air
    log to console      Scf commission and wait for on-air
    Set default SCF
    Du scf commission and wait for on-air     scf_name=${default_scf_name}

Set default SCF
    [Arguments]    ${bts_host}=${CU_addr}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${CU_username}    password=${CU_password}    connection=${connection}
    ${version}    coam.get_sw_version    connection=${connection}
    ${version_list}    split string    ${version}    separator=_
    ${version_scf}    run keyword if    '${version_list[2]}'=='9999'    Set Variable    SBTS00
    ...    ELSE   Set Variable    ${version_list[0]}
    ${default_scf_name}    set variable    SCF_${version_scf}.xml
    set suite variable    ${default_scf_name}
    log to console   ${default_scf_name}
    [Teardown]     Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Du scf commission and wait for on-air
    [Arguments]   ${scf_name}   ${connection}=GNB_OAM
    Cloud DU connect to gnb coam via ssl    connection=${connection}
    COAM Commission with scf file    scf_file_path=${SCF_PATH}/${scf_name}    timeout=${600}    is_pdl_checking_needed=${False}
    COAM Teardown gnb connections
    #sleep    1s
    #Restart CU
    sleep    3min
    Wait Until Keyword Succeeds    15min    20s    COAM Check GNB_DU cell on air
    Get cell numbers
    [Teardown]    COAM Teardown gnb connections

step3: Prepare UE
    [Arguments]     ${ue_index}=${0}
    log to console      step3: Prepare UE
#    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=${ue_type}    ui_version=S20PlusUI2.1
    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=${ue_type}    ui_version=S21UI3.1

Step4: UE Attach
    [Arguments]     ${ue_index}=${0}
    log to console      Step4: UE Attach
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${ue_type}    log_type=Aasyslog
    ...    attach_mode=5G_NSA
    power_ue.Verify attach    ue_type=${ue_type}   5Grach_ed=${5Grach_ed_0}    4G_check=False


Step5: Start traffic
    [Arguments]   ${ul_throughput}=240M    ${dl_throughput}=2400M    ${protocol}=udp    ${ue_index}=${0}
    log to console      Step5: Start traffic
    power_ue.Start traffic    ue_index=${ue_index}    direction=ul    throughput=${ul_throughput}    duration=1200    ue_type=${ue_type}
    ...    iperf_type=via_command
    ...    protocol=${protocol}    iperf_port=${UL_PORT}
    sleep    1s
    ${process_num}    set variable if     '${protocol}'=='udp'    ${2}    ${8}
    power_ue.Start traffic    ue_index=${ue_index}    direction=dl    throughput=${dl_throughput}    duration=1200    ue_type=${ue_type}
    ...    protocol=${protocol}    buffer_size=1280B    process_num=${process_num}    seg_size=1350    window=16M    iperf_port=${DL_PORT}
    sleep    2s

Step5: Start traffic UL
    [Arguments]   ${ul_throughput}=240M    ${protocol}=tcp    ${ue_index}=${0}
    log to console      Step5: Start traffic
    power_ue.Start traffic    ue_index=${ue_index}    direction=ul    throughput=${ul_throughput}    duration=1200    ue_type=${ue_type}
    ...    iperf_type=via_command    process_num=${8}    seg_size=1350    window=16M    buffer_size=1400B
    ...    protocol=${protocol}
    sleep    5s

Step5: Start traffic DL
    [Arguments]   ${dl_throughput}=2400M    ${protocol}=tcp    ${ue_index}=${0}
    log to console      Step5: Start traffic
    power_ue.Start traffic    ue_index=${ue_index}    direction=dl    throughput=${dl_throughput}    duration=1200    ue_type=${ue_type}
    ...    protocol=${protocol}    buffer_size=1400B        process_num=${8}    seg_size=1350    window=16M
    sleep    5s


Step7: Stop traffic
    [Arguments]     ${ue_index}=0
    log to console      Step7: Stop traffic
    power_ue.Stop traffic    direction=ul    ue_index=${ue_index}    ue_type=${ue_type}    iperf_type=via_command     iperf_port=${UL_PORT}
    power_ue.Stop traffic    direction=dl    ue_index=${ue_index}    ue_type=${ue_type}    iperf_port=${DL_PORT}

Step8: UE Detach
    [Arguments]     ${ue_index}=${0}
    log to console      Step8: UE Detach
    power_ue.UE Detach    ue_index=${ue_index}    ue_type=${ue_type}


Determine whether to lock based on RU status
    [Arguments]    ${lock_ru_list}    ${bts_host}    ${BTS_ID}    ${ru_expect_status}=${RU_lock_status}
    ${lock_ru_status}    Create Dictionary
    @{tmp_ru_list}    create list
    FOR    ${ru_id}    IN    @{lock_ru_list}
        APPEND TO LIST    ${tmp_ru_list}    ${ru_id}
        Set To Dictionary    ${lock_ru_status}    RMOD-${ru_id}    ${ru_expect_status}
    END
    ${status_list}    Check All RU or Cell Status    expect_item_status_dict=${lock_ru_status}    if_ru=${True}    bts_host=${bts_host}
    ${length}    Get length    ${lock_ru_list}
    FOR    ${item}   IN RANGE    ${length}
        Run Keyword If    ${status_list}[${item}] == ${True}    Remove Values From List     ${lock_ru_list}    ${tmp_ru_list}[${item}]
        log to console    ${tmp_ru_list}
    END
    Lock or Unlock RU And Check Status    lock_RU_id_list=${lock_ru_list}     lock_flag=${True}    bts_host=${bts_host}    BTS_ID=${BTS_ID}

Check All RU or Cell Status
    [Documentation]  expect_item_status_dict eg:
    ...              1) ${cell_status_dict}    Create Dictionary     NRCELL-1=${Cell_unblock_status}    NRCELL-2=${Cell_block_status}
    ...              2) ${ru_status_dict}    Create Dictionary     RMOD-1=${RU_unlock_status}    RMOD-2=${RU_lock_status}
    [Arguments]  ${expect_item_status_dict}    ${if_ru}=${True}   ${bts_host}=${gnb_ip}
    Log To Console    Check All RU or Cell Status
    ${item_status_dic}    Get All RU or Cell Status    if_ru=${if_ru}    bts_host=${bts_host}    connection=GNB_OAM
    @{item_id_list}    get dictionary keys    ${expect_item_status_dict}
    @{status_list}    create list
    FOR  ${item_id}  IN  @{item_id_list}
        ${expect_status_list}     get from dictionary    ${expect_item_status_dict}    ${item_id}
        ${item_status}    set variable    ${item_status_dic['${item_id}']}
        ${status}    run keyword and return status
        ...    Run Keyword If    ${if_ru}    Check Single RU Status    item_status=${item_status}    expect_status_list=${expect_status_list}
        ...    ELSE    Check Single Cell Status    item_status=${item_status}    expect_status_list=${expect_status_list}
        append to list    ${status_list}    ${status}
    END
    [Return]  ${status_list}

Get All RU or Cell Status
    [Arguments]  ${if_ru}=${True}    ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM
    Log to console    Get All RU or Cell Status
    ${item_status_dic}    Create Dictionary
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${ru_info_list}    coam.get_frm    connection=${connection}
    ${cell_info_list}     coam.Get_Cells_Info   cell_type=nr    connection=${connection}
    ${item_info_list}    set variable if    ${if_ru}    ${ru_info_list}    ${cell_info_list}
    ${count_item}    Get Length    ${item_info_list}
    FOR  ${item}  IN RANGE   ${count_item}
        ${item_id_info}  Split String  ${item_info_list[${item}]['id']['configuration']}  separator=/
        ${item_id}    set variable    ${item_id_info[-1]}
        ${item_status}    set variable    ${item_info_list[${item}]['status']}
        set to dictionary    ${item_status_dic}    ${item_id}=${item_status}
    END
    [Return]  ${item_status_dic}
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Check Single RU Status
    [Arguments]  ${item_status}    ${expect_status_list}
    ${admin_status}    get from dictionary    ${item_status}    administrativeState
    Run Keyword And Continue On Failure    should be equal as strings   ${admin_status}    ${expect_status_list[${0}]}
    ${operate_status}    get from dictionary    ${item_status}    operationalState
    Run Keyword And Continue On Failure    should be equal as strings    ${operate_status}    ${expect_status_list[${1}]}
    ${usage_status}    get from dictionary    ${item_status}    usageState
    Run Keyword And Continue On Failure    should be equal as strings    ${usage_status}    ${expect_status_list[${2}]}
    ${procedure_status}    get from dictionary    ${item_status}    proceduralStatus
    Run Keyword And Continue On Failure    should be equal as strings    ${procedure_status}    ${expect_status_list[${3}]}

Check Single Cell Status
    [Arguments]  ${item_status}    ${expect_status_list}
    Check Single RU Status    item_status=${item_status}    expect_status_list=${expect_status_list}
    ${block_status}    get from dictionary    ${item_status}    blockingState
    Run Keyword And Continue On Failure    should be equal as strings   ${block_status}    ${expect_status_list[${-1}]}

Lock or Unlock RU And Check Status
    [Arguments]  ${BTS_ID}   ${lock_RU_id_list}=${empty_list}     ${unlock_RU_id_list}=${empty_list}    ${lock_flag}=${True}   ${bts_host}=${gnb_ip}
    ${operate_ru_id_list}    Set Variable If    ${lock_flag}    ${lock_RU_id_list}    ${unlock_RU_id_list}
    Lock or UnLock Multiple RU    RMOD_id_list=${operate_ru_id_list}    lock_flag=${lock_flag}    bts_host=${bts_host}    BTS_ID=${BTS_ID}
    ${expect_item_status_dict}    create dictionary
    FOR  ${item}  IN    @{lock_RU_id_list}
        Set to dictionary    ${expect_item_status_dict}    RMOD-${item}=${RU_lock_status}
    END
    FOR  ${item1}  IN   @{unlock_RU_id_list}
        Set to dictionary    ${expect_item_status_dict}    RMOD-${item1}=${RU_unlock_status}
    END
    Check All RU or Cell Status    expect_item_status_dict=${expect_item_status_dict}    if_ru=${True}    bts_host=${bts_host}

Lock or UnLock Multiple RU
    [Arguments]    ${RMOD_id_list}   ${BTS_ID}    ${lock_flag}=${True}    ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM    ${timeout}=60
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    FOR  ${RMOD_id}  IN  @{RMOD_id_list}
        ${dist_name}    Set Variable    MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${RMOD_id}
        Run keyword if    ${lock_flag}==${True}    Log To Console    Lock RMOD-${RMOD_id}
        ...    ELSE    Log To Console    UnLock RMOD-${RMOD_id}
        Run keyword if    ${lock_flag}==${True}    coam.lock    dist_name=${dist_name}    timeout=${timeout}    connection=${connection}
        ...    ELSE    coam.unlock    dist_name=${dist_name}    timeout=${timeout}    connection=${connection}
        sleep    8s
    END
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
