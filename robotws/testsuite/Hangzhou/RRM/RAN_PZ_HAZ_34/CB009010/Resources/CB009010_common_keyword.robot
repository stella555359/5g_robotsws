*** Settings ***
Documentation    author：Hongyu Jiang
...              contact: hongyu.jiang@nokia-sbell.com
...              squad group: mmw_SG_04

Library     BuiltIn
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Library     taf.transport.ssh      WITH NAME    ssh
Library     taf.sbts.oam.coam.admin       WITH NAME    coam
Library     taf.hw.rf_attenuator    WITH NAME    att
Library     ./hbtePositioner/positionerDemo.py






*** Variables ***
${gNB_ip1}                    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${gNB_ip2}                    ${tl.gnbs[1].dus[0].airscale.common_units[0].lmp_connection.addr}
${eNB_ip}                     ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${gNB_username}               ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gNB_password}               ${tl.gnbs[0].cu.oam_http_connection_details.password}
${gnb_ssh_username}           ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${gnb_ssh_password}           ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${TEST_PC_IP}                 ${tl.test_pc.default_ssh_connection_details.addr}
${TEST_PC_USERNAME}           ${tl.test_pc.default_ssh_connection_details.username}
${TEST_PC_PASSWORD}           ${tl.test_pc.default_ssh_connection_details.password}
${att_ipaddr}                  ${tl.attenuator.ip_addr}
${att_api_port}                ${tl.attenuator.port}
${att_connection_port}         ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${BTS_ID1}                     ${tl.gnbs[0].instance_id}
${NRBTS_ID1}                   ${tl.gnbs[0].global_bts_id}
${BTS_ID2}                     ${tl.gnbs[1].instance_id}
${NRBTS_ID2}                   ${tl.gnbs[1].global_bts_id}
@{allowed_list}                ${4655}    ${61524}    ${4654}    ${61652}
@{PA_port_list}                ${0}    ${1}    ${2}    ${3}    ${4}    ${5}    ${6}    ${7}
@{PA_value_list}               ${0}    ${0}    ${127}    ${127}    ${127}    ${127}    ${127}    ${127}
${Turntable_PB_ip1}            10.71.216.6
${Turntable_PB_ip2}            10.71.216.4
${luashark_path}               /opt/ute/luashark/luashark_script/generated_luashark/luashark.lua
${case_log_name}               CB009010_X2
@{Cell_unblock_status}         Unlocked    enabled    Active    configured    Unblocked
@{Cell_block_status}           Unlocked    disabled    Idle    configured    Blocked
${model}                     ${tl.attenuator.model}




*** Keywords ***
########### setup and teardown KW #################
CB009010 Suite Setup
    robot_common_operations.Common Suite Setup
    Adapt to ute cloud commission scf
    Setup Commission SCF    flag=GNB1    bts_host=${gNB_ip1}
    Setup Commission SCF    flag=GNB2    bts_host=${gNB_ip2}
    Check GNB on air    bts_host=${gNB_ip1}
    Check GNB on air    bts_host=${gNB_ip2}
    Check Alarm List on BTS    bts_host=${gNB_ip1}    allowed_list=${allowed_list}
    Check Alarm List on BTS    bts_host=${gNB_ip2}    allowed_list=${allowed_list}
    Block or UnBlock Single Cell    cell_id=2    block_flag=${True}    bts_host=${gnb_ip1}
    ${cell_status_dict}    Create Dictionary     NRCELL-1=${Cell_unblock_status}    NRCELL-2=${Cell_block_status}
    Check All RU or Cell Status    expect_item_status_dict=${cell_status_dict}    if_ru=${False}   bts_host=${gnb_ip1}
    Adjust the HBTE attenuation value    value_list=${PA_value_list}    port_list=${PA_port_list}
    Set X and Y PositionMotion    ip=${Turntable_PB_ip1}     if_X=${False}    start_Y=${275}     end_Y=${275}    exceed=${360}
    Set X and Y PositionMotion    ip=${Turntable_PB_ip2}     if_X=${False}    start_Y=${0}     end_Y=${0}    exceed=${360}

CB009010 Suite Teardown
    robot_common_operations.Common Suite Teardown

Case Setup
    robot_common_operations.Common case Setup

Case Teardown
    Run keyword and ignore error   MTK UE detach
    Block or UnBlock Single Cell    cell_id=2    block_flag=${False}    bts_host=${gnb_ip1}
    Check GNB on air    bts_host=${gNB_ip1}
    robot_common_operations.Common case Teardown
    CI_interface.Common Case Teardown

########### check bts on air #################
Adapt to ute cloud commission scf
    ${TL_NAME}   set variable if      '${testline_name}' == '${EMPTY}'    ${CONFIGURATION}    ${testline_name}
    ${pattern}   Set Variable    7_5(.*)
    ${TLNAME}    Get Regexp Matches     ${TL_NAME}    ${pattern}    1
    ${TLNAME}   Set Variable    7_5${TLNAME}[0]
    Set Suite Variable    ${CURDIR_path}    ${CURDIR}/../../../../../../commissionings/HGZ/${TLNAME}/

Set default SCF
    [Arguments]    ${flag}    ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${version}    coam.get_sw_version    connection=${connection}
    ${version_list}    split string    ${version}    separator=_
    ${version_scf}    run keyword if    '${version_list[2]}'=='9999'    Set Variable    SBTS00
    ...    ELSE    Set Variable    ${version_list[0]}
    ${default_scf_path}    set variable    ${CURDIR_path}/SCF_${version_scf}_9010_${flag}.xml
    set suite variable    ${default_scf_path}
    log to console   ${default_scf_path}
    [Teardown]     Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Setup Commission SCF
    [Arguments]  ${flag}    ${bts_host}=${gNB_ip1}    ${connection}=GNB_OAM
    Set default SCF    bts_host=${bts_host}    flag=${flag}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    COAM Commission with scf file    scf_file_path=${default_scf_path}    connection=${connection}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Check GNB on air
    [Timeout]    20 min
    [Arguments]  ${bts_host}=${gnb_ip1}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    Wait Until Keyword Succeeds    20min    20s    COAM Check GNB cell on air    connection=${connection}
    Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair    connection=${connection}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Get Alarm on BTS
    [Arguments]  ${bts_host}=${gnb_ip1}    ${connection}=GNB_OAM
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
    [Arguments]  ${allowed_list}=None    ${not_allowed_list}=None    ${bts_host}=${gnb_ip1}    ${connection}=GNB_OAM
    ${actual_fault_id_list}    ${history_id_list}    Get Alarm on BTS    bts_host=${bts_host}    connection=${connection}
    ${history_id_len}    Get Length    ${history_id_list}
    Run Keyword if    ${allowed_list} != None        Check List1 content in List2    list1=${actual_fault_id_list}    list2=${allowed_list}
    Run Keyword if    ${not_allowed_list} != None     Check List1 content not in List2    list1=${not_allowed_list}    list2=${actual_fault_id_list}
    Run Keyword if    ${history_id_len} != ${0}    Save Snapshot    bts_host=${bts_host}
    Should be equal    ${history_id_len}    ${0}

Check Alarm List on BTS
    [Arguments]  ${allowed_list}=None    ${not_allowed_list}=None    ${bts_host}=${gnb_ip1}    ${connection}=GNB_OAM
    ${status}    Run Keyword And Return Status    Check Alarm List on BTS Temp    allowed_list=${allowed_list}
    ...    not_allowed_list=${not_allowed_list}    bts_host=${bts_host}    connection=${connection}
    Run Keyword if    ${status} == ${False}    Save Snapshot    bts_host=${bts_host}
    Should be equal    ${status}    ${True}

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

Check All RU or Cell Status
    [Documentation]  expect_item_status_dict eg:
    ...              1) ${cell_status_dict}    Create Dictionary     NRCELL-1=${Cell_unblock_status}    NRCELL-2=${Cell_block_status}
    ...              2) ${ru_status_dict}    Create Dictionary     RMOD-1=${RU_unlock_status}    RMOD-2=${RU_lock_status}
    [Arguments]  ${expect_item_status_dict}    ${if_ru}=${True}   ${bts_host}=${gnb_ip}
    Log To Console    Check All RU or Cell Status
    ${item_status_dic}    Get All RU or Cell Status    if_ru=${if_ru}    bts_host=${bts_host}    connection=GNB_OAM
    @{item_id_list}    get dictionary keys    ${expect_item_status_dict}
    FOR  ${item_id}  IN  @{item_id_list}
        ${expect_status_list}     get from dictionary    ${expect_item_status_dict}    ${item_id}
        ${item_status}    set variable    ${item_status_dic['${item_id}']}
        Run Keyword If    ${if_ru}    Check Single RU Status    item_status=${item_status}    expect_status_list=${expect_status_list}
        ...    ELSE    Check Single Cell Status    item_status=${item_status}    expect_status_list=${expect_status_list}
    END

Block or UnBlock Single Cell
    [Arguments]  ${cell_id}    ${block_flag}=${True}    ${bts_host}=${gnb_ip1}    ${connection}=GNB_OAM    ${timeout}=60
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${dist_name}    Set Variable    ${GNB1_NRBTS}/NRCELL-${cell_id}
    Run keyword if    ${block_flag}==${True}    Log To Console    Block Cell-${cell_id}
    ...    ELSE    Log To Console    UnBlock Cell-${cell_id}
    Run keyword if    ${block_flag}==${True}    coam.block_cell    dist_name=${dist_name}    timeout=${timeout}    connection=${connection}
    ...    ELSE    coam.unblock_cell    dist_name=${dist_name}    timeout=${timeout}    connection=${connection}
    sleep    5s
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

########### Logic Code #################
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

########### about MTK UE #################
Prepare UE and Attach UE
    [Arguments]  ${ue_index}=${1}    ${ue_type}=mtk
    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=${ue_type}
    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${ue_type}
    power_ue.Verify attach    ue_type=${ue_type}    ue_index=${ue_index}    4G_check=${True}

MTK UE detach
    [Arguments]  ${ue_index}=${1}    ${ue_type}=mtk
    Power_ue.UE Detach    ue_index=${ue_index}    ue_type=${ue_type}

################## Collect Logs ###########################
Start Collect Tcpdump
    [Arguments]  ${host_ip}    ${host_name}=${gnb_ssh_username}    ${host_pass}=${gnb_ssh_password}    ${log_name}=X2.pcap
    ...    ${interface}=any    ${conn}=Tcpdump
    ssh.Connect to    hostname=${host_ip}     username=${host_name}    password=${host_pass}    alias=${conn}
    ssh.send_command    command=ps -ef | grep tcpdump | awk '{print $2}' | xargs kill -9    connection=${conn}
    sleep    2s
    ssh.send command    command=nohup tcpdump sctp -i ${interface} -w /tmp/${log_name} &>/dev/null &   connection=${conn}
    sleep    30s
    [Teardown]    run keyword and ignore error    ssh.Disconnect    connection=${conn}

Stop Collect Tcpdump
    [Arguments]  ${host_ip}    ${time}    ${host_name}=${gnb_ssh_username}    ${host_pass}=${gnb_ssh_password}
    ...    ${log_name}=X2.pcap    ${conn}=Tcpdump
    sleep    ${time}
    ssh.Connect to    hostname=${host_ip}     username=${host_name}    password=${host_pass}    alias=${conn}
    ssh.send_command    command=ps -ef | grep tcpdump | awk '{print $2}' | xargs kill -9    connection=${conn}
    ssh.download_file   remote_path=/tmp/${log_name}   local_path=${OUTPUT_DIR}/${log_name}   connection=${conn}
    Sleep    60s
    ssh.execute    command=rm /tmp/${log_name}    connection=${conn}
    [Teardown]    run keyword and ignore error    ssh.Disconnect    connection=${conn}

Save Snapshot
    [Arguments]    ${bts_host}=${gNB_ip1}    ${connection}=cOAM    ${timeout}=10min
    log to console    Save Snapshot...
    run keyword and ignore error     coam.teardown    connection=${connection}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}
    ...    connection=${connection}
    ${snapshot_path}    coam.Get Snapshot From BTS    alias=${connection}    timeout=${timeout}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}
    [Return]    ${snapshot_path}

Convert pcap to text
    [Arguments]    ${pcap_filename}   ${txt_filename}    ${filter}    ${connection}=ute
    ${source}      set variable     ${OUTPUT_DIR}/${pcap_filename}
    ${target}      set variable     ${OUTPUT_DIR}/${txt_filename}
    ssh.Connect to    hostname=${TEST_PC_IP}     username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}    alias=${connection}
    sleep    1s
    ssh.send_command
    ...  command=nice tshark -X lua_script:${luashark_path} -V -r ${source} -T text > ${target} -Y '${filter}'   connection=${connection}
    ssh.await execution end  connection=${connection}  timeout=30min
    [Teardown]       ssh.Disconnect  	connection=${connection}

Check wireshark log Parameter
    [Arguments]     ${sgnb_chg_ho_message}     ${message_dict}    ${file_name}=${case_log_name}
    Convert pcap to text    pcap_filename=${file_name}.pcap    txt_filename=${file_name}.txt    filter=x2ap
    ${val_result}    Check_Wireshark_Parameter_From_Txt    txt_file_path=${OUTPUT_DIR}/${file_name}.txt
    ...    parameters=${sgnb_chg_ho_message}
    ${val_list}     set variable    ${val_result}[resultList]
    FOR    ${val1}    IN    @{val_list}
        Run Keyword And Continue On Failure    should be equal    ${val1}    ${True}
    END
    ${flow_result}    Check_Wireshark_Message_Flow_From_Txt    txt_file_path=${OUTPUT_DIR}/${file_name}.txt    message_dict=${message_dict}
    ${CGIrepor_result}    checkCGIreport    txt_file_path=${OUTPUT_DIR}/${file_name}.txt
    Run Keyword And Continue On Failure    should be equal    ${flow_result}    ${True}
    Run Keyword And Continue On Failure    should be equal    ${CGIrepor_result}    ${True}

########### modify parameter ###################
Modify Parameters with json
    [Timeout]  10min
    [Arguments]    ${input_list}    ${bts_host}=${gnb_ip1}    ${delta_id}=update_parameter    ${connection}=GNB_OAM
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


############ Adjust PA #################
Adjust the HBTE attenuation value
    [Arguments]      ${value_list}    ${port_list}
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${127}    vendor=HBTE
    ...    model=${model}
    ${port_num}    Get Length   ${port_list}
    @{port_list1}    Create List
    FOR    ${port}    IN    @{port_list}
        ${tmp}    Evaluate    ${port}+1
        Append to list  ${port_list1}  ${tmp}
    END
    FOR    ${i}    IN RANGE    ${port_num}
        att.set_attenuation     port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[${port_list[${i}]}].port_no}    value=${value_list}[${i}]
        ${value_port}    att.read_attenuation    port=${port_list1}[${i}]
        should be equal    ${value_port}    ${value_list}[${i}]
    END
    sleep  10s

############ Adjust Turntable #################
Set X and Y PositionMotion
    [Arguments]   ${ip}     ${if_X}=${True}    ${if_Y}=${True}      ${exceed}=${180}
    ...    ${start_X}=${0}     ${end_X}=${0}     ${speed_X}=${5}    ${loopCount_X}=${1}
    ...    ${start_Y}=${0}     ${end_Y}=${0}     ${speed_Y}=${5}    ${loopCount_Y}=${1}
    Run keyword if     ${if_X}     positionerDemo.setXPositionMotion     ip=${ip}      start=${start_X}
    ...     end=${end_X}    speed=${speed_X}    loopCount=${loopCount_X}    exceed=${exceed}
    Run keyword if     ${if_Y}     positionerDemo.setYPositionMotion     ip=${ip}      start=${start_Y}
    ...     end=${end_Y}    speed=${speed_Y}    loopCount=${loopCount_Y}    exceed=${exceed}

############ Check Parameter Value #################
Check Node Parameter
    [Arguments]    ${bts_host}=${gNB_ip1}    ${connection}=COAM_GNB
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${NRADJNRCELL_dict}    coam.get_managed_objects    class_name=NRADJNRCELL_A    connection=${connection}
    ${NRADJNRCELL_para}    get from dictionary    ${NRADJNRCELL_dict}[${0}]    parameters
    ${cellDepType}    get from dictionary    ${NRADJNRCELL_para}    cellDepType
    Run Keyword And Continue On Failure    should be equal as strings   ${cellDepType}    NSA
    ${cellReservedForOperatorUse}    get from dictionary    ${NRADJNRCELL_para}    cellReservedForOperatorUse
    Run Keyword And Continue On Failure    should be equal as strings    ${cellReservedForOperatorUse}    reserved
    ${gNbId}    get from dictionary    ${NRADJNRCELL_para}    gNbId
    Run Keyword And Continue On Failure    should be equal as strings    ${gNbId}    ${BTS_ID2}

    ${ADJ_dict}    coam.get_managed_objects    class_name=ADJ_NRPLMNSET_NSA_A    connection=${connection}
    ${ADJ_para}    get from dictionary    ${ADJ_dict}[${0}]    parameters
    ${cellReservedForOperatorUse}    get from dictionary    ${ADJ_para}    cellReservedForOperatorUse
    Run Keyword And Continue On Failure    should be equal as strings    ${cellReservedForOperatorUse}    reserved

    ${NRREL_dict}    coam.get_managed_objects    class_name=NRREL_A    connection=${connection}
    ${NRREL_para}    get from dictionary    ${NRREL_dict}[${0}]    parameters
    ${gNbId}    get from dictionary    ${NRREL_para}    gNbId
    Run Keyword And Continue On Failure    should be equal as strings    ${gNbId}    ${BTS_ID2}
    ${lcrId}    get from dictionary    ${NRREL_para}    lcrId
    Run Keyword And Continue On Failure    should be equal as strings    ${lcrId}    1
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
