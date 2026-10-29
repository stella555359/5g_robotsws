*** Settings ***
Documentation
...    author: Jiang Hongyu
...    contact: hongyu.jiang@nokia-sbell.com
...    squad group: MMW_SG_04
...    feature : CB009469-SR


Library     taf.sbts.oam.coam.admin       WITH NAME    coam
Library     taf.transport.ssh            WITH NAME    ssh
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Commercial_mobile_phone_adb_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Variables ***
${gnb_ip}                     ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${gNB_username}               ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gNB_password}               ${tl.gnbs[0].cu.oam_http_connection_details.password}
${TEST_PC_IP}                 ${tl.test_pc.default_ssh_connection_details.addr}
${TEST_PC_USERNAME}           ${tl.test_pc.default_ssh_connection_details.username}
${TEST_PC_PASSWORD}           ${tl.test_pc.default_ssh_connection_details.password}
${control_pc}                 ${tl.ues[0].ssh_connection_details.addr}
${control_pc_name}            ${tl.ues[0].ssh_connection_details.username}
${control_pc_pass}            ${tl.ues[0].ssh_connection_details.password}
${enb_ip}                     ${tl.ues[3].airscale.common_units[0].lmp_connection.addr}
${TS_CASE_LOG_PATH}           ${output_dir}
${ul_power_port_list}         ${tl.ues[0].iperf_details.ports[0:3]}
${dl_power_port_list}         ${tl.ues[0].iperf_details.ports[3:6]}
@{allowed_list}               ${4655}    ${61524}    ${4654}    ${61652}    ${8150}    ${4681}
@{ue_index_list}              ${1}
${gNB_ssh_name}               ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${gNB_ssh_pass}               ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${cell_id}                    122912789
${gNB_ip_153}                 10.71.215.230
@{RU_id_list_153}             ${1}    ${2}
${BTS_ID_153}                 153
@{RU_unlock_status}           Unlocked    enabled    Active    configured
@{RU_lock_status}             Locked    enabled    Idle    configured
@{cell_id_list}               24    25    26
@{cell_id_list1}              24    25    26    27    28
@{cell_id_index}              ${3}    ${4}    ${5}
${BTS_ID}                     ${tl.gnbs[0].instance_id}
@{all_cell_id_list}           122912789    122912790    122912791    122912792    122912793    122912794    122912795    122912796
@{all_cell_id_list1}          122912789    122912790    122912791    122912795    122912796
@{empty_list}


*** Keywords ***
########### setup and teardown KW #################
CB009469 Suite Setup
    [Arguments]     ${bts_host}=${gNB_ip}    ${id_index}=${0}
    CI_interface.Common Suite Setup
    robot_common_operations.Common Suite Setup
    Adapt to ute cloud commission scf
    Setup Commission SCF       bts_host=${bts_host}
    Check GNB on air    bts_host=${bts_host}
#    Check Alarm List on BTS    allowed_list=${allowed_list}    bts_host=${bts_host}
#    Setup 4G Commission SCF
#    Check GNB on air    bts_host=${enb_ip}
#    Determine whether to lock based on RU status
    Modify Parameters with json    input_list=${enb_para}    bts_host=${enb_ip}

CB009469 Suite Teardown
#    Lock or Unlock RU And Check Status    unlock_RU_id_list=${RU_id_list_153}    lock_flag=${False}    bts_host=${gNB_ip_153}
#     ...   BTS_ID=${BTS_ID_153}
    robot_common_operations.Common Suite Teardown

Case Teardown
    robot_common_operations.Common case Teardown
    CI_interface.Common Case Teardown


########### check bts on air #################
Adapt to ute cloud commission scf
    ${TL_NAME}   set variable if      '${testline_name}' == '${EMPTY}'    ${CONFIGURATION}    ${testline_name}
    ${pattern}   Set Variable    7_5(.*)
    ${TLNAME}    Get Regexp Matches     ${TL_NAME}    ${pattern}    1
    ${TLNAME}   Set Variable    7_5${TLNAME}[0]
    Set Suite Variable    ${CURDIR_path}    ${CURDIR}/../../../../../../commissionings/HGZ/${TLNAME}

Set default SCF
    [Arguments]    ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${version}    coam.get_sw_version    connection=${connection}
    ${version_list}    split string    ${version}    separator=_
    ${version_scf}    run keyword if    '${version_list[2]}'=='9999'    Set Variable    SBTS00
    ...    ELSE   Set Variable    ${version_list[0]}
    ${default_scf_path}    set variable    ${CURDIR_path}/SCF_${version_scf}.xml
    set suite variable    ${default_scf_path}
    log to console   ${default_scf_path}
    [Teardown]     Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Setup Commission SCF
    [Arguments]   ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM
    Set default SCF    bts_host=${bts_host}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    COAM Commission with scf file    scf_file_path=${default_scf_path}    connection=${connection}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Setup 4G Commission SCF
    [Arguments]   ${bts_host}=${enb_ip}    ${connection}=GNB_OAM
    ${default_4G_scf_path}    set variable    ${CURDIR_path}/SCF_SBTS00_4G.xml
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    COAM Commission with scf file    scf_file_path=${default_4G_scf_path}    connection=${connection}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Check GNB on air
    [Timeout]    20 min
    [Arguments]  ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    Wait Until Keyword Succeeds    20min    20s    COAM Check GNB cell on air    connection=${connection}
    Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair    connection=${connection}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Get Alarm on BTS
    [Arguments]  ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    @{active_alarms}    coam.get_active_alarms    connection=${connection}
    @{history_alarms}    coam.get_historic_alarms    connection=${connection}
    ${active_id_list}    Get Alarm ID From BTS    output_alarms=${active_alarms}
    ${history_id_list}    Get Alarm ID From BTS    output_alarms=${history_alarms}
    [Return]  ${active_id_list}    ${history_id_list}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Get Alarm ID From BTS
    [Arguments]  ${output_alarms}
    ${len}    Get Length    ${output_alarms}
    @{fault_id_list}    create list
    FOR    ${i}    IN RANGE    ${len}
        ${fault_id}     get from dictionary  ${output_alarms[${i}]}    additionalFaultID
        APPEND TO LIST  ${fault_id_list}    ${fault_id}
    END
    [Return]  ${fault_id_list}

Check Alarm List on BTS Temp
    [Arguments]  ${allowed_list}=None    ${not_allowed_list}=None    ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM
    ${actual_fault_id_list}    ${history_id_list}    Get Alarm on BTS    bts_host=${bts_host}    connection=${connection}
    ${history_id_len}    Get Length    ${history_id_list}
    Run Keyword if    ${allowed_list} != None        Check List1 content in List2    list1=${actual_fault_id_list}    list2=${allowed_list}
    Run Keyword if    ${not_allowed_list} != None     Check List1 content not in List2    list1=${not_allowed_list}    list2=${actual_fault_id_list}
    Run Keyword if    ${history_id_len} != ${0}    Save Snapshot
    Should be equal    ${history_id_len}    ${0}

Check Alarm List on BTS
    [Arguments]  ${allowed_list}=None    ${not_allowed_list}=None    ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM
    ${status}    Run Keyword And Return Status    Check Alarm List on BTS Temp    allowed_list=${allowed_list}
    ...    not_allowed_list=${not_allowed_list}    bts_host=${bts_host}    connection=${connection}
    Run Keyword if    ${status} == ${False}    Save Snapshot
    Should be equal    ${status}    ${True}

Check List1 content in List2
    [Arguments]  ${list1}    ${list2}
    ${len1}    Get Length    ${list1}
    ${len2}    Get Length    ${list2}
    Run Keyword And Continue On Failure    Should be true    ${len1}<=${len2}
    FOR  ${i}  IN  @{list1}
        Run Keyword And Continue On Failure    Should contain    ${list2}    ${i}
    END

Check List1 content not in List2
   [Arguments]  ${list1}    ${list2}
    FOR  ${i}  IN  @{list1}
        Run Keyword And Continue On Failure    Should not contain    ${list2}    ${i}
    END

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

Determine whether to lock based on RU status
    [Arguments]    ${lock_ru_list}=${RU_id_list_153}    ${ru_expect_status}=${RU_lock_status}    ${bts_host}=${gNB_ip_153}   ${BTS_ID}=${BTS_ID_153}
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

################## Snopshot ###########################
Save Snapshot
    [Arguments]    ${connection}=cOAM    ${timeout}=10min
    log to console    Save Snapshot...
    run keyword and ignore error     coam.teardown    connection=${connection}
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
    ...    connection=${connection}
    ${snapshot_path}    coam.Get Snapshot From BTS    alias=${connection}    timeout=${timeout}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}
    [Return]    ${snapshot_path}

########## modify parameter ###################
Modify Parameters with json
    [Timeout]  10min
    [Arguments]    ${input_list}    ${bts_host}=${gnb_ip}    ${delta_id}=update_parameter    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    coam.create_delta    delta_id=${delta_id}
    FOR    ${item}  IN    @{input_list}
        ${operation}    get from dictionary    ${item}    operation
        Run keyword if    '${operation}'=='update'
        ...    coam.append_parameter_update_to_delta    dist_name=${item['dist_name']}    parameter=${item['parameter']}
        ...    value=${item['value']}    delta_id=${delta_id}
        Run keyword if    '${operation}'=='delete'
        ...    coam.append_parameter_delete_to_delta    dist_name=${item['dist_name']}    parameter=${item['parameter']}
        ...    delta_id=${delta_id}
        Log to console    Add task - ${operation}: ${item['dist_name']}.${item['parameter']}
    END
    ${delta_file}    coam.get_delta    delta_id=${delta_id}
    ${timeout}    set variable    480
    Log to console    Perform parameters via delta_id:${delta_id} is ongoing, timeout ${timeout}s.
    coam.perform_delta_recommissioning
    ...    delta_file=${delta_file}
    ...    skip_parameter_relation_errors=${False}
    ...    should_activate=${True}
    ...    timeout=${timeout}
    ...    connection=${connection}
    Log to console    Perform parameters done.
    run keyword and ignore error    coam.remove_delta    delta_id=${delta_id}
    [Teardown]    run keyword and ignore error    coam.teardown      connection=${connection}

################ Relate To UE ###################
attach multi power ue
    [Arguments]    ${ue_index_list}   ${gnb_index}=${0}
    log to console       Prepare UE
    FOR    ${ue_index}   IN    @{ue_index_list}
        power_ue.Prepare UE    ue_index=${ue_index}    ue_type=samsung
        ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    attach_mode=5G_NSA   ue_type=samsung
        power_ue.Verify attach    ue_type=samsung    ue_index=${ue_index}   5Grach_ed=${5Grach_ed_0}    4G_check=False
    END
    ${5Grach_ing}    ${5Grach_time_ing}    Get 5Grach attach time    hwcheck_index=${5Grach_ed_0[2]}     log_type=${5Grach_ed_0[3]}
    ${local_path}    Copy Aasys log From Du    file_name=5Grach.txt
    [Return]   ${5Grach_time_ing}

start multi power ue traffic ul and dl
    [Arguments]    ${ue_index_list}    ${ul_throughput}=${None}    ${dl_throughput}=${None}    ${ul_duration}=6000    ${dl_duration}=6000
    ...    ${protocol}=udp    ${if_ul}=${True}    ${if_dl}=${True}    ${process_num}=${2}
    log to console      Start traffic    console=yes
    FOR    ${item}    IN    @{ue_index_list}
        run keyword and continue on failure    run keyword if    ${if_ul}    CB009469_common_keywords.Start UL UDP traffic via iperf command
        ...    UL_port=${ul_power_port_list}[${item}]    ue_index=${item}    time=${ul_duration}    traffic=${ul_throughput}
        ...    process_num=${process_num}
        sleep    1s
        run keyword and continue on failure    run keyword if    ${if_dl}    power_ue.Start traffic    ue_index=${item}    direction=dl
        ...    throughput=${dl_throughput}    duration=${dl_duration}    ue_type=samsung    protocol=${protocol}
        ...    iperf_port=${dl_power_port_list}[${item}]    process_num=${process_num}
    END

stop multi power ue traffic ul and dl
    [Arguments]    ${ue_index_list}    ${protocol}=udp    ${if_ul}=${True}    ${if_dl}=${True}
    log to console     Stop traffic    console=yes
    FOR    ${item}    IN    @{ue_index_list}
        run keyword if    ${if_ul}    power_ue.Stop traffic    direction=ul    ue_index=${item}    ue_type=samsung    iperf_type=via_command
        ...    protocol=${protocol}    iperf_port=${ul_power_port_list}[${item}]
        run keyword if    ${if_dl}    power_ue.Stop traffic    direction=dl    ue_index=${item}    ue_type=samsung    protocol=${protocol}
        ...    iperf_port=${dl_power_port_list}[${item}]
    END

detach multi power ue
    [Arguments]    ${ue_index_list}
    log to console      UE Detach    console=yes
    FOR    ${item}    IN    @{ue_index_list}
         power_ue.UE Detach    ue_index=${item}    ue_type=samsung
    END

Start UL UDP traffic via iperf command
    [Arguments]    ${EPC_IP}=${tl.appserver.iperf_details.network_interface_address}
    ...    ${UL_port}=${tl.appserver.iperf_details.port}    ${buffer_size}=1024B    ${interval}=1    ${ue_index}=${0}
    ...    ${time}=10    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    ...    ${traffic}=10.00M    ${window_size}=2M    ${process_num}=${1}
    sleep   2s
    Connect to control pc via cygwin    ue_index=${ue_index}
    csn.send_command    command=adb -s ${serial_number} root &
    ...    connection=cygwin
    csn.send_command    command=adb -s ${serial_number} shell ps -ef | grep iperf |grep ${UL_port} |grep -v grep |awk '{print $2}'
    ...    connection=cygwin
    ${pid}    wait until keyword succeeds    10s    1s    csn.Read Output    connection=cygwin
    csn.send_command    command=adb -s ${serial_number} shell kill -9 ${pid} &
    ...    connection=cygwin
    sleep    2s
    ${cmd}=    catenate    adb -s ${serial_number} shell /data/local/tmp/iperf -c ${EPC_IP} -u -p ${UL_port}
    ...    -t ${time} -P ${process_num} -i 1 -f m -b ${traffic} -l ${buffer_size} -T 64 -w ${window_size} &
    csn.send_command    command=${cmd}
    ...    connection=cygwin
    csn.send_command    command=adb -s ${serial_number} shell ps -ef |grep iperf |grep ${UL_port} |grep -v grep |awk '{print $2}'
    ...    connection=cygwin
    ${pid}    wait until keyword succeeds    10s    1s    csn.Read Output    connection=cygwin
    log to console    .....UE_${ue_index} udp ul iperf start....
    [Teardown]    csn.disconnect      connection=cygwin


##################### Check Counter ######################
Check Release Larged Than Given
    [Arguments]    ${release}=24R1    ${gnb_index}=${0}    ${connection}=GNB_OAM
    ${Y_given_string}=    Get SubString    ${release}    0    2
    ${R_given_string}=    Get SubString    ${release}    3    4
    ${Y_given}    Evaluate    int(${Y_given_string})
    ${R_given}    Evaluate    int(${R_given_string})
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${software}    coam.get_software_info    connection=${connection}
    ${activate_version}    Set Variable    ${software}[Active SW version]
    ${Y_active_string}=    Get SubString    ${activate_version}    4    6
    ${R_active_string}=    Get SubString    ${activate_version}    7    8
    ${Y_active}    Evaluate    int(${Y_active_string})
    ${R_active}    Evaluate    int(${R_active_string})
    ${Is_large}    Set variable if    ${Y_active}>${Y_given}    ${True}
    ...    ${Y_active}==${Y_given} and ${R_active}>${R_given}    ${True}    ${False}
    [Return]    ${Is_large}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections  connection=${connection}

Get Multiple counter result
    [Arguments]    ${counter_id_dict}    ${host_ip}=${gNB_ip}    ${connection}=GNB_COM
    Connect to gnb coam via ssl    bts_host=${host_ip}    username=${gNB_username}    password=${gNB_password}
    ...    connection=${connection}
    ${counter_result_dict}   create dictionary
    ${counter_id_list}    Get Dictionary Keys    ${counter_id_dict}
    FOR    ${counter_id}    IN    @{counter_id_list}
        ${counter_list}    Get From Dictionary    ${counter_id_dict}    ${counter_id}
        ${counter_values}    coam.get pm counters   counter_ids=${counter_id}    timeout=120    connection=${connection}
        ${result_list}   Get Multiple Cell counter result    counter_list=${counter_list}    counter_id=${counter_id}
        ...    counter_values=${counter_values}
        Set To Dictionary    ${counter_result_dict}    ${counter_id}     ${result_list}
    END
    [Return]  ${counter_result_dict}
    [Teardown]    Run Keyword And Ignore Error   coam.teardown      connection=${connection}

Get Multiple Cell counter result
    [Arguments]  ${counter_list}    ${counter_id}    ${counter_values}    ${index}=${0}
    ${result_list}    create list
    FOR    ${counter}    IN    @{counter_list}
        ${BTS}    set variable    ${counter}[0]
        ${CELLS}    set variable    ${counter}[1]
        ${NRCELL}    set variable    ${counter}[2]
        ${counter_object}    set variable    ${counter}[3]
        ${MR_BTS}    set variable    MRBTS-${tl.gnbs[${index}].instance_id}
        ${NR_BTS}    set variable    NRBTS-${tl.gnbs[${index}].global_bts_id}
        ${is_large_24R1_release}    Check Release Larged Than Given    release=24R1    gnb_index=${index}
        ${result}    run keyword if    ${is_large_24R1_release}
        ...    Get Dictionary Values   ${counter_values['${BTS}']['${MR_BTS}']['${NR_BTS}']['${NRCELL}']['${counter_object}']['${counter_id}']}
        ...    ELSE    Get Dictionary Values   ${counter_values['${BTS}']['${CELLS}']['${NRCELL}']['${counter_object}']['${counter_id}']}
        Append To List    ${result_list}    ${result}
    END
    [Return]  ${result_list}

Check Multiple counter result
    [Arguments]    ${befor_counter_dict}    ${after_counter_dict}    ${check_counter_dict}    ${Toler}    ${file_name}
    ...    ${if_ul}    ${if_dl}    ${cell_id}    ${attach_rach_time}    ${counter_id}=${EMPTY}
    ${counter_diff_dict}    Calculate_diff_between_the_sum_two_counters    counter_input_dict1=${befor_counter_dict}
    ...    counter_input_dict2=${after_counter_dict}
    ${act_time_list}    Get Attach Time And Tp time From Aasyslog    file_name=${file_name}    if_ul=${if_ul}    if_dl=${if_dl}
    ...    cell_id=${cell_id}    bts_host=${gNB_ip}    attach_rach_time=${attach_rach_time}
    ${attach_counter_dict}    ${ul_time_counter_dict}    ${dl_time_counter_dict}    Generate_Corresponding_expected_counter
    ...    check_counter_dict=${check_counter_dict}    actual_value_list=${act_time_list}
    ${ul_check_result}    run keyword if    ${if_ul}    Check_counter_value_as_expect    actual_value_dict=${counter_diff_dict}
    ...    attach_counter_dict=${attach_counter_dict}    tp_time_counter_dict=${ul_time_counter_dict}    Toler=${Toler}
    ${dl_check_result}    run keyword if    ${if_dl}    Check_counter_value_as_expect    actual_value_dict=${counter_diff_dict}
    ...    attach_counter_dict=${attach_counter_dict}    tp_time_counter_dict=${dl_time_counter_dict}    Toler=${Toler}
    ${after_counter1}    run keyword if    '${counter_id}'!='${EMPTY}'    Get From Dictionary    ${after_counter_dict}    ${counter_id}
    ${befor_counter1}    run keyword if    '${counter_id}'!='${EMPTY}'    Get From Dictionary    ${befor_counter_dict}    ${counter_id}
    ${befor_counter_len}    run keyword if    '${counter_id}'!='${EMPTY}'    Get Length    ${befor_counter1[${0}]}
    ${after_counter_len}    run keyword if    '${counter_id}'!='${EMPTY}'    Get Length    ${after_counter1[${0}]}
#    ${counter_tmp_list}    run keyword if    '${counter_id}'!='${EMPTY}'    create list   ${counter_value[${0}][${-2}]}
#    ...    ${counter_value[${0}][${-1}]}
    run keyword and continue on failure    run keyword if    ${if_ul}    should be equal    ${ul_check_result}    ${True}
    run keyword and continue on failure    run keyword if    ${if_dl}    should be equal    ${dl_check_result}    ${True}
    run keyword and continue on failure    run keyword if    '${counter_id}'!='${EMPTY}'    List Should Contain Value
    ...   ${after_counter1[${0}][${befor_counter_len}:${after_counter_len}]}   ${1}

Wait for counter to be gathered after guard peroid
   [Arguments]  ${Time_M}=0    ${if_current_time}=${False}    ${interval}=5
   ${list1}=    Create List         00  15  30  45
   ${list2}=    Create List         00  05  10  15  20  25  30  35  40  45  50  55
   ${list}=    Set Variable IF     '${interval}' == '5'    ${list2}    ${list1}
   ${actualTime}=     DateTime.Get Current Date    result_format=%M    time_zone=UTC
   ${actualTime_M}    Set Variable IF    ${if_current_time}    ${actualTime}    ${Time_M}
   ${time_check}    run keyword and return status   List Should Contain Value    ${list}    '${actualTime_M}'
   run keyword if    ${time_check}   Sleep   ${interval} minutes
   PM Wait To Nearest Measurement Period    interval=${interval}

PM Wait To Nearest Measurement Period
   [Arguments]  ${interval}
   Log    PM Wait To Nearest Measurement Period    console=yes
   Wait Until Keyword Succeeds    16 min    1 min    Wait For Right Period    interval=${interval}

Wait For Right Period
   [Arguments]  ${interval}
   ${list1}=           Create List         00  15  30  45
   ${list2}=           Create List         00  05  10  15  20  25  30  35  40  45  50  55
   ${list}=            Set Variable IF     '${interval}' == '5'    ${list2}    ${list1}
   ${actualTime}=     DateTime.Get Current Date    result_format=%M    time_zone=UTC    increment=8 hours
   ${actualHour}=     DateTime.Get Current Date    result_format=%H    time_zone=UTC    increment=8 hours
   ${date}=     DateTime.Get Current Date    result_format=%Y-%m-%d    time_zone=UTC    increment=8 hours
   ${date_nodash}=    DateTime.Get Current Date    result_format=%Y%m%d    time_zone=UTC
   ${actualEpoch}=    DateTime.Convert Date	       ${date} ${actualHour}:${actualTime}:00.000	epoch
   List Should Contain Value	           ${list}  ${actualTime}
   Log                                    ${actualTime}
   ${string_epoch}=   Convert To String   ${actualEpoch}
   ${nopoint_epoch}=   fetch from left   ${string_epoch}   .
   ${integer_epoch}=   convert to integer  ${nopoint_epoch}
   ${epoch_minus_interval}=   Evaluate   ${integer_epoch}-15*60
   ${epoch_minus_interval_string}=   Convert To String   ${epoch_minus_interval}
   set test variable    ${epoch_minus_interval_string}

################## About Aasyslog ###########################
Capture Aasyslog
    [Arguments]    ${gnb_index}=0    ${du_index}=0    ${log_name}=data_dl.txt
    Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
    Aasyslog precondition    gnb_index=${gnb_index}    du_index=${du_index}
    Start the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}    filter=L2   log_name=${log_name}

Get 5Grach attach time
    [Arguments]  ${gnb_index}=${0}    ${hwcheck_index}=${1}    ${log_type}=Aasyslog   ${log_loca}=l2lo
    ${5Grach_ing}    ${5Grach_time_ing}    Get 5GRACH success times on gnb side    gnb_index=${gnb_index}
    ...                                                                            hwcheck_index=${hwcheck_index}
    ...                                                                            log_type=${log_type}
    ...                                                                            log_loca=${log_loca}
    [Return]  ${5Grach_ing}    ${5Grach_time_ing}

Copy Aasys log From Du
    [Arguments]  ${file_name}    ${bts_host}=${gNB_ip}    ${connection}=ASIK_Master
    ${current_time}    DateTime.Get Current Date    result_format=%Y-%m-%d_%H:%M:%S
    ${local_path}    set variable    ${output_dir}/${current_time}_${file_name}
    csn.Connect to    hostname=${bts_host}    username=${gNB_ssh_name}    password=${gNB_ssh_pass}    alias=${connection}
    csn.download_file    remote_path=/tmp/${file_name}    local_path=${local_path}    connection=${connection}
    sleep    2s
    [Return]  ${local_path}
    [Teardown]  Csn.Disconnect	connection=${connection}

Get Attach Time And Tp time From Aasyslog
    [Arguments]  ${file_name}    ${cell_id}    ${attach_rach_time}    ${if_ul}=${True}    ${if_dl}=${True}    ${bts_host}=${gNB_ip}
    ...    ${connection}=UTE_CON
    ${ul_tp_time}    set variable    ${0}
    ${dl_tp_time}    set variable    ${0}
    ${local_path}    Copy Aasys log From Du    file_name=${file_name}    bts_host=${bts_host}
    ${detach_rach_time}    Obtain a timestamp for a row    local_path=${local_path}    line_index=${0}    filter=cause:RELEASE
    ...    cell_id=${cell_id}
    ${ul_tp_start_time}    Run keyword if   ${if_ul}    Obtain a timestamp for a row    local_path=${local_path}    line_index=${0}
    ...    filter=L2Lo, UlCounterUpdate    dl_tp_time=${False}    ul_tp_time=${True}    cell_id=${cell_id}
    ${dl_tp_start_time}    Run keyword if   ${if_dl}    Obtain a timestamp for a row    local_path=${local_path}    line_index=${0}
    ...    filter=TBS|MacCe|StatusPdu|DataPdu    dl_tp_time=${True}    ul_tp_time=${False}    cell_id=${cell_id}
    ${attach_time}    Get_time_Diff_second    start_time_list=${attach_rach_time}    end_time_list=${detach_rach_time}
    ${ul_tp_time}    Run keyword if   ${if_ul}    Get_time_Diff_second    start_time_list=${ul_tp_start_time}    end_time_list=${detach_rach_time}
    ${dl_tp_time}    Run keyword if   ${if_dl}    Get_time_Diff_second    start_time_list=${dl_tp_start_time}    end_time_list=${detach_rach_time}
    @{time_list}=    Create List    ${attach_time}    ${ul_tp_time}     ${dl_tp_time}
    [Return]    ${time_list}

Obtain a timestamp for a row
    [Arguments]  ${local_path}    ${line_index}    ${filter}    ${cell_id}    ${dl_tp_time}=${False}    ${ul_tp_time}=${False}
    ...    ${connection}=UTE_CON
    ${list}    Obtain Content By Filter    local_path=${local_path}    filter=${filter}
    ${len}    Get Length    ${list}
    ${act_line_index}    run keyword if    ${dl_tp_time}    Get_DL_TP_Start_line    dl_tp_list=${list}   cell_id=${cell_id}
    ...    ELSE IF    ${ul_tp_time}    Get_UL_TP_Start_line    ul_tp_list=${list}   cell_id=${cell_id}
    ...    ELSE IF    ${dl_tp_time}==${False} and ${ul_tp_time}==${False}    set variable    ${line_index}
    ${last_line}    Run keyword if    ${len}>0    Get From List    ${list}    ${act_line_index}
    ${rach_time}    Run keyword if    ${len}>0    Get Regexp Matches    ${last_line}    \\d{2}\\:\\d{2}\\:\\d{2}\\.[\\d|\\w]*
    [Return]  ${rach_time}

Obtain Content By Filter
    [Arguments]    ${local_path}    ${filter}    ${bts_host}=${TEST_PC_IP}    ${username}=${TEST_PC_USERNAME}    ${password}=${TEST_PC_PASSWORD}
    ...    ${connection}=UTE_CON
    csn.Connect to    hostname=${bts_host}    username=${username}    password=${password}    alias=${connection}
    ${input_cmd}=    catenate    cat ${local_path} | grep -a "${filter}" | grep -av grep
    ${cmd_output}    csn.execute    command=${input_cmd}    connection=${connection}
    @{list}    split string    ${cmd_output}    \n
    Remove Values From List    ${list}   ${empty}
    [Teardown]   run keyword and ignore error    csn.disconnect    connection=${connection}
    [Return]  ${list}

#################### Delete Or Add Cell########################
WEBUI Login
    [Arguments]      ${virtual_enable}=${True}
    [Documentation]   WEBUI Login
    Log To Console  START:WEBUI Login
    Log To Console  Try to login...
    selenium_coam.Enable_Virtual_Display
    selenium_coam.Login    url=https://${gNB_ip}    username=${gNB_username}   password=${gNB_password}
    Log To Console  Login successfully...
    Run Keyword And Ignore Error      selenium_coam.Disable_Message_Box
    Sleep    15s
    selenium_coam.disable_screen_lock
    Log To Console  END:WEBUI Login!

WEBUI Logout
    [Arguments]     ${virtual_disable}=${True}
    [Documentation]   WEBUI Logout
    Log To Console  Try to logout...
    Run Keyword If      ${virtual_disable}    Run Keyword And Ignore Error    selenium_coam.Enable_Virtual_Display
    Run Keyword And Ignore Error  selenium_coam.Logout
    Log To Console  Logout successfully...
    Run Keyword If      ${virtual_disable}    Run Keyword And Ignore Error    selenium_coam.Disable_Virtual_Display
    Sleep    3s
    Log To Console  END:WEBUI Logout!

Delete Nrcells Data
    [Arguments]  ${cell_id_list}    ${cell_id_list_index}
    Log To Console    delete nrcell
    ${length}    Get Length    ${cell_id_list}
    FOR   ${item}    IN RANGE   ${length}
        selenium_coam.remove_object    object_name=${NRBTS_ID}/NRCELL-${cell_id_list}[${item}]
        selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id_list}[${item}]
        selenium_coam.remove_element   dist_name=${NRBTS_ID}/NRCELLGRP-2
        ...    filter_param=List of NR cells assigned to cell group    node_index=${cell_id_list_index}[${item}]    abbr=nrCellList
    END

Add Nrcells Data
    [Arguments]  ${cell_id_list}    ${cell_id_list_index}
    Adapt to ute cloud commission scf
    Set default SCF
    Log To Console    Add nrcell
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${default_scf_path}
    ${length}    Get Length    ${cell_id_list}
    FOR   ${item}    IN RANGE   ${length}
        ${cell_id}    set variable    ${cell_id_list}[${item}]
        ${new_cell_id_index}    evaluate    ${cell_id_list_index}[${item}]+${2}
        selenium_coam.add_object    object_name=${NRBTS_ID}   object_class_name=NRCELL    plan_to_copy_from=CONF-1
        ...    copy_from=${NRBTS_ID}/NRCELL-${cell_id}    include_subobject=${TRUE}    id_value=${cell_id}
        selenium_coam.set_parameter_value    dist_name=${NRBTS_ID}/NRCELL-${cell_id}
        ...    filter_param=Local cell resource ID   new_value=${cell_id}    abbr=lcrId
        selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1   object_class_name=LCELNR
        ...    plan_to_copy_from=CONF-1    copy_from=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}
        ...    include_subobject=${TRUE}    id_value=${cell_id}
        selenium_coam.add_element    dist_name=${NRBTS_ID}/NRCELLGRP-2
        ...    filter_param=List of NR cells assigned to cell group    abbr=nrCellList
        selenium_coam.set_parameter_value    dist_name=${NRBTS_ID}/NRCELLGRP-2
        ...    filter_param=List of NR cells assigned to cell group    new_value=${cell_id}
        ...    node_index=${new_cell_id_index}    abbr=nrCellList
    END
    Adjust Nrcelllist Data    adjust_cell_id_list=${cell_id_list1}

Adjust Nrcelllist Data
    [Arguments]  ${adjust_cell_id_list}
    ${length}    Get Length    ${adjust_cell_id_list}
    FOR    ${item}    IN RANGE    ${length}
        ${cell_id}    set variable    ${adjust_cell_id_list}[${item}]
        ${new_cell_id_index}    evaluate    ${item}+${3}
        selenium_coam.set_parameter_value    dist_name=${NRBTS_ID}/NRCELLGRP-2
        ...    filter_param=List of NR cells assigned to cell group    new_value=${cell_id}
        ...    node_index=${new_cell_id_index}    abbr=nrCellList
    END

Add Or Delete Cell By WebUI
    [Arguments]  ${if_add}    ${cell_id_list}=${cell_id_list}    ${cell_id_list_index}=${cell_id_index}
    WEBUI Login
    run keyword if    ${if_add}    Add Nrcells Data    cell_id_list=${cell_id_list}    cell_id_list_index=${cell_id_list_index}
    ...    ELSE    Delete Nrcells Data    cell_id_list=${cell_id_list}    cell_id_list_index=${cell_id_list_index}
    ${error}    selenium_coam.validate_plan
    Log To Console    ${error}
    Log To Console    Activate plan
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${False}    timeout=${180}
    Check GNB on air
#    Check Alarm List on BTS    allowed_list=${allowed_list}
    [Teardown]    WEBUI Logout


#################### Case Setup and Teardown ########################
Capture Syslog And Start Traffic
    [Arguments]  ${file_name}    ${if_ul}    ${if_dl}    ${time}=1min    ${ul_throughput}=${None}    ${dl_throughput}=${None}
    ...    ${ul_duration}=6000    ${dl_duration}=6000    ${protocol}=udp    ${ue_index_list}=${ue_index_list}
    ${5Grach_time_ing}    attach multi power ue    ue_index_list=${ue_index_list}
    Capture Aasyslog    log_name=${file_name}
    start multi power ue traffic ul and dl    ue_index_list=${ue_index_list}    ul_throughput=${ul_throughput}    dl_throughput=${dl_throughput}
    ...    ul_duration=${ul_duration}    dl_duration=${dl_duration}    protocol=${protocol}    if_ul=${if_ul}    if_dl=${if_dl}
    sleep    ${time}
    detach multi power ue    ue_index_list=${ue_index_list}
    stop multi power ue traffic ul and dl    ue_index_list=${ue_index_list}    protocol=${protocol}    if_ul=${if_ul}    if_dl=${if_dl}
    Teardown the Aasyslog save progress
    [Return]  ${5Grach_time_ing}

Capture Syslog And Attach UE
    [Arguments]  ${file_name}    ${time}=1min    ${ue_index_list}=${ue_index_list}
    ${5Grach_time_ing}    attach multi power ue    ue_index_list=${ue_index_list}
    Capture Aasyslog    log_name=${file_name}
    sleep    ${time}
    detach multi power ue    ue_index_list=${ue_index_list}
    Teardown the Aasyslog save progress
    [Return]  ${5Grach_time_ing}

Check Throught From Asslog
    [Arguments]  ${ul_list}    ${dl_list}      ${ul_tp}=${100}    ${dl_tp}=${1500}    ${if_ul}=${True}    ${if_dl}=${True}
    ...    ${target_avg_percent}=0.95    ${min_percent}=0    ${ue_type}=samsung   ${log_time}=60s
    ${log_path}    power_ue.Collect Tput   ue_type=${ue_type}    duration=${log_time}    ignore_time=10s
    run keyword and continue on failure    run keyword if    ${if_ul}==${True}    power_ue.Check Tput    ue_type=${ue_type}
    ...    direction=UL    log=${log_path}    cells=${ul_list}    target_throughput=${ul_tp}    target_avg_percent=${target_avg_percent}
    ...    actCarrierAggregation=${True}    min_percent=${min_percent}
    run keyword and continue on failure    run keyword if    ${if_dl}==${True}    power_ue.Check Tput    ue_type=${ue_type}
    ...    direction=DL    log=${log_path}    cells=${dl_list}    target_throughput=${dl_tp}    target_avg_percent=${target_avg_percent}
    ...    actCarrierAggregation=${True}    min_percent=${min_percent}

Start Traffic And Check Tp
    [Arguments]    ${ul_throughput}    ${dl_throughput}    ${ul_list}    ${dl_list}    ${ue_index_list}=${ue_index_list}
    ...    ${if_ul}=${True}    ${if_dl}=${True}    ${target_avg_percent}=0.9    ${min_percent}=0    ${log_time}=30s
    attach multi power ue    ue_index_list=${ue_index_list}
    start multi power ue traffic ul and dl    ue_index_list=${ue_index_list}    ul_throughput=${ul_throughput}M    dl_throughput=${dl_throughput}M
    ...    if_ul=${if_ul}    if_dl=${if_dl}    process_num=${1}
    Check Throught From Asslog   ul_list=${ul_list}    dl_list=${dl_list}     ul_tp=${ul_throughput}    dl_tp=${dl_throughput}    if_ul=${if_ul}
    ...   if_dl=${if_dl}   target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    log_time=${log_time}
    stop multi power ue traffic ul and dl    ue_index_list=${ue_index_list}    if_ul=${if_ul}    if_dl=${if_dl}
    [Teardown]  detach multi power ue    ue_index_list=${ue_index_list}
