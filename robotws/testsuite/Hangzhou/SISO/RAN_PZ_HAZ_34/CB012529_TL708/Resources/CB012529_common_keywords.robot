*** Settings ***
Documentation
...    author: Zhu Xiaofeng
...    contact: hongyu.jiang@nokia-sbell.com
...    squad group: MMW_SG_04
...    feature : CB012529


Library     taf.sbts.oam.coam.admin       WITH NAME    coam
Library     taf.transport.ssh            WITH NAME    ssh
Library     taf.selenium.sbts            WITH NAME    selenium_sbts

Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB012510_TL708/Resources/CB012510_common_keywords.robot
Library     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB012510_TL708/Resources/CB012510_common_keywords.py
Variables   testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB012510_TL708/Resources/CB012510_modify_para.py
Library     testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.gnb_alarm.AlarmWatchdog    WITH NAME    AlarmWatchdog

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Commercial_mobile_phone_adb_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/SISO_common_operation.robot
Library     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001937_OTA/resources/samsung_sigspark.py
Library     samsung_sigspark.SigSpark    WITH NAME    samsung_spark
Library     taf.selenium.sbts  WITH NAME  selenium_OAM
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/nrdim_throughput/interface.py    WITH NAME
...    throughput_computation


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
${ul_power_port_list}         ${tl.ues[0].iperf_details.ports[0:3]}
${dl_power_port_list}         ${tl.ues[0].iperf_details.ports[3:6]}
@{allowed_list}               ${4655}    ${61524}    ${4654}    ${61652}    ${4592}    ${7312}    ${7313}    ${49}    ${6351}    ${4298}
@{allowed_list_RU_poweroff}   ${4655}    ${61524}    ${4654}    ${61652}    ${4592}    ${7312}    ${7313}    ${6351}    ${10}    ${4589}    ${1815}
${att_ipaddr}                 ${tl.attenuator.ip_addr}
${att_api_port}               ${tl.attenuator.port}
${att_connection_port}        ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
@{RU_unlock_status}        Unlocked    enabled    Active    configured
@{RU_lock_status}          Locked    enabled    Idle    configured
@{Cell_unblock_status}        unlocked    enabled    unblocked
@{Cell_block_status}          unlocked    disabled    blocked
@{physCellId_list}            240    241    242
@{cell_id_list_3CC}           17    19    20
@{NR_cell_id_list}            1    182779908      182779921    2
@{NR_cell_id_list_1}        182779908      182779921
@{cell_list_1}              182779908
@{cell_list_2}              182779921
@{NR_cell_list}               ${0}    ${1}    ${2}    ${3}    ${4}    ${5}    ${6}    ${7}    ${8}    ${9}    ${10}    ${11}    ${12}
...                           ${13}    ${14}    ${15}    ${16}    ${17}    ${18}
@{NR_cell_list_2}             ${9}    ${15}
@{Rmod_id_list}               ${1}    ${11}    ${12}    ${13}    ${14}    ${15}    ${16}    ${17}    ${18}     ${19}
${BTS_ID}                     ${tl.gnbs[0].instance_id}
${LNBTS}                      ${tl.enbs[0].global_bts_id}
${NRBTS}                      ${tl.gnbs[0].global_bts_id}
@{empty_list}
@{LTE_row_list}               LTE PDCP Thr. DL [Mbps]    LTE PDCP Thr. UL [Mbps]
${AWHHI_PDU_IP}                ${tl.gnbs[0].dus[0].rus[8].pdu_port.pdu.addr}
${AWHHI_PDU_PORT}              ${tl.gnbs[0].dus[0].rus[8].pdu_port.port_no}
${AHEGBNR_PDU_IP}                ${tl.gnbs[0].dus[0].rus[1].pdu_port.pdu.addr}
${AHEGBNR_PDU_PORT}              ${tl.gnbs[0].dus[0].rus[1].pdu_port.port_no}
${AHEGBLTE_PDU_IP}               ${tl.gnbs[0].dus[0].rus[7].pdu_port.pdu.addr}
${AHEGBLTE_PDU_PORT}             ${tl.gnbs[0].dus[0].rus[7].pdu_port.port_no}
${CURDIR_path}             ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}/
${LOG_PATH}                     ${output_dir}
${DU_OAM_SSH_USERNAME}         ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${DU_OAM_SSH_PASSWORD}         ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${DU_OAM_IP}                   ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${testline_name}        7_5_UTE5G402T708

*** Keywords ***
########### setup and teardown KW #################
CB012529 Suite Setup
    CI_interface.Common Suite Setup
    robot_common_operations.Common Suite Setup
    Adapt to ute cloud commission scf

CB012529 Case Teardown
    AlarmWatchdog.remove_allow_alarms    fault_id=49
    robot_common_operations.Common case Teardown
    CI_interface.Common Case Teardown
    Run Keyword if    "${TEST_STATUS}"=="FAIL"    Save Snapshot

CB012529 Case Setup
    [Arguments]    ${scf_name}=None    ${if_activate_scf}=${False}
    robot_common_operations.Common case Setup
    run keyword if    ${if_activate_scf}    Setup the Commission SCF    scf_name=${scf_name}
    Check BTS onair without unexpected alarm
    AlarmWatchdog.add_allow_alarms    fault_id=49

Setup the Commission SCF
    [Arguments]   ${scf_name}    ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM
    ${default_scf_path}    Set default SCF    scf_name=${scf_name}    bts_host=${bts_host}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    COAM Commission with scf file    timeout=600    scf_file_path=${default_scf_path}    connection=${connection}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Lock or Unlock RU And Check Status
    [Arguments]    ${BTS_ID}    ${lock_RU_id_list}=${empty_list}     ${unlock_RU_id_list}=${empty_list}
    ...    ${lock_flag}=${True}   ${bts_host}=${gnb_ip}
    ${operate_ru_id_list}    Set Variable If    ${lock_flag}    ${lock_RU_id_list}    ${unlock_RU_id_list}
    Lock or UnLock Multiple RU    RMOD_id_list=${operate_ru_id_list}    lock_flag=${lock_flag}    bts_host=${bts_host}    BTS_ID=${BTS_ID}

Lock or UnLock Multiple RU
    [Arguments]    ${RMOD_id_list}   ${BTS_ID}    ${lock_flag}=${True}    ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM    ${timeout}=60
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    FOR  ${RMOD_id}  IN  @{RMOD_id_list}
        ${dist_name}    Set Variable    MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${RMOD_id}
        Run keyword if    ${lock_flag}==${True}    coam.lock    dist_name=${dist_name}    timeout=${timeout}    connection=${connection}
        ...    ELSE    coam.unlock    dist_name=${dist_name}    timeout=${timeout}    connection=${connection}
        sleep    8s
    END
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Reset RAT
    [Arguments]    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${gnb_ip}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    coam.rat_reset    rat_type=NR    timeout=${300}    connection=${connection}
    log to console    reset RAT successful
    Check GNB on air and Check Alarm List on BTS
    [Teardown]    run keyword and ignore error    coam.teardown     connection=${connection}

Reset BBMOD
    [Arguments]    ${BBmod_ID}=2    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${gnb_ip}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    coam.reset_unit    dist_name=/MRBTS-${NRBTS}/EQM-1/APEQM-1/CABINET-1/BBMOD-${BBmod_ID}   reset_type=Hard
    ...    timeout=${240}
    ...    connection=${connection}
    log to console    reset BBMOD successful
    Check GNB on air and Check Alarm List on BTS
    [Teardown]    run keyword and ignore error    coam.teardown     connection=${connection}

Lock and Unlock TL708 ALL RU
    [Arguments]    ${Rmod_id_list}=${Rmod_id_list}
    Lock or Unlock RU And Check Status    BTS_ID=${BTS_ID}    lock_RU_id_list=${Rmod_id_list}    lock_flag=${True}
    Wait Until Keyword Succeeds    2min    5s    check all cell and RU status    expect_status=${RU_lock_status}
    Lock or Unlock RU And Check Status    BTS_ID=${BTS_ID}    unlock_RU_id_list=${Rmod_id_list}    lock_flag=${False}
    Wait Until Keyword Succeeds    2min    5s    check all cell and RU status    expect_status=${RU_unlock_status}
    Check GNB on air and Check Alarm List on BTS

check all cell and RU status
    [Arguments]    ${expect_status}    ${bts_host}=${gnb_ip}    ${if_ru}=${True}
    ${status_dic}    Get All RU or Cell Status    cell_type=nr    if_ru=${if_ru}    bts_host=${bts_host}    connection=GNB_OAM
    ${ID_list}    Get Dictionary Keys    ${status_dic}
    ${expect_status_dict}    Create Dictionary
    FOR  ${ID}  IN  @{ID_list}
        Set To Dictionary    ${expect_status_dict}    ${ID}=${expect_status}
    END
    ${status_list}    Check All RU or Cell Status    expect_item_status_dict=${expect_status_dict}
    ...    actual_item_status_dict=${status_dic}    if_ru=${if_ru}
    Should Not Contain    ${status_list}    ${False}

block or Unblock the Multiple cell
    [Arguments]    ${cell_id_list}   ${block_flag}   ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM    ${timeout}=60
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    FOR  ${cell_id}  IN  @{cell_id_list}
        Run keyword if    ${block_flag}==${True}    Log To Console    Block Cell${cell_id} Start
        ...    ELSE    Log To Console    UnBlock Cell${cell_id} Start
        ${dist_name}    Set Variable    MRBTS-${BTS_ID}/NRBTS-${NRBTS}/NRCELL-${cell_id}
        Run keyword if    ${block_flag}==${True}    coam.block_cell    dist_name=${dist_name}    timeout=${timeout}    connection=${connection}
        ...    ELSE    coam.unblock_cell    dist_name=${dist_name}    timeout=${timeout}    connection=${connection}
    END
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

bLock and Unblock TL708 ALL cell
    [Arguments]    ${cell_id_list}=${NR_cell_list}    ${if_ru}=${False}
    block or Unblock the Multiple cell    cell_id_list=${cell_id_list}    block_flag=${True}    bts_host=${gnb_ip}
    Wait Until Keyword Succeeds    2min    5s    check all cell and RU status    expect_status=${Cell_block_status}    if_ru=${if_ru}
    block or Unblock the Multiple cell    cell_id_list=${cell_id_list}    block_flag=${False}    bts_host=${gnb_ip}
    Wait Until Keyword Succeeds    2min    5s    check all cell and RU status    expect_status=${Cell_unblock_status}    if_ru=${if_ru}
    Check GNB on air and Check Alarm List on BTS

block cell and start traffic
    [Arguments]    ${cell_list_1}    ${cell_list_2}    ${ue1_ul_tp}=70    ${ue1_dl_tp}=380    ${ue2_ul_tp}=70    ${ue2_dl_tp}=1500
    ...    ${target_avg_percent}=0.98    ${min_percent}=0.85    ${log_time}=300s
    @{block_cell_id_list}    create list    ${9}    ${15}
    block or Unblock the Multiple cell    cell_id_list=${block_cell_id_list}    block_flag=${True}    bts_host=${gnb_ip}
    UE Attach GET 172 IP And Check TP    ul_throughput=${ue1_ul_tp}    dl_throughput=${ue1_dl_tp}
    ...    ul_list=${cell_list_1}    dl_list=${cell_list_1}    ignore_time=60s
    ...    protocol=tcp    ue_index=${1}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    log_time=${log_time}
    UE Attach GET 172 IP And Check TP    ul_throughput=${ue2_ul_tp}    dl_throughput=${ue2_dl_tp}
    ...    ul_list=${cell_list_2}    dl_list=${cell_list_2}    ignore_time=60s
    ...    protocol=tcp    ue_index=${2}    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    log_time=${log_time}
    [Teardown]    block or Unblock the Multiple cell    cell_id_list=${block_cell_id_list}    block_flag=${False}    bts_host=${gnb_ip}

Config supercell to normal cell
    [Arguments]    ${add_object_cell_num}=${1}     ${start_cell_id}=${2}    ${NRCELLGRP_id}=${17}    ${cell_id}=17    ${copy_cell_id}=${1}
    ...    ${node_index_Diff}=1
    webui Login
    selenium_sbts.remove_element
    ...    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS}/NRCELL-${copy_cell_id}
    ...    filter_param=NG RAN access point position    node_index=${2}    abbr=nGRanAccessPointPosition
    selenium_sbts.remove_element
    ...    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS}/NRCELL-${copy_cell_id}
    ...    filter_param=NG RAN access point position    node_index=${1}    abbr=nGRanAccessPointPosition
    selenium_sbts.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS}/NRCELL-${cell_id}
    ...    filter_param=Activate super cell   new_value=false   abbr=actSuperCell
    selenium_sbts.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS}/NRCELLGRP-${NRCELLGRP_id}
    ...    filter_param=Number of transmitted Synchronization Signal Blocks  new_value=1 beam   abbr=numberOfTransmittedSsBlocks
    Add and Copy nomcell    physCellId_list=${physCellId_list[1:3]}    add_object_cell_num=${add_object_cell_num}    start_cell_id=${start_cell_id}
    ...    copy_cell_id=${copy_cell_id}    node_index_Diff=${node_index_Diff}
    Delete CHANNELGROUP    cell_id=${cell_id_list_3CC}[2]    CHANNELGROUP_id=1
    sleep    1s
    Delete CHANNELGROUP    cell_id=${cell_id_list_3CC}[2]    CHANNELGROUP_id=3
    sleep    1s
    Delete CHANNELGROUP    cell_id=${cell_id_list_3CC}[0]    CHANNELGROUP_id=1
    sleep    1s
    Delete CHANNELGROUP    cell_id=${cell_id_list_3CC}[0]    CHANNELGROUP_id=2
    sleep    1s
    Delete CHANNELGROUP    cell_id=${cell_id_list_3CC}[1]    CHANNELGROUP_id=2
    sleep    1s
    Delete CHANNELGROUP    cell_id=${cell_id_list_3CC}[1]    CHANNELGROUP_id=3
    sleep    1s
    ${error}    selenium_sbts.validate_plan
    Log To Console    ${error}
    selenium_sbts.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${180}
    Check GNB on air
    Check BTS onair without unexpected alarm
    [Teardown]    webui Logout

Add and Copy nomcell
    [Arguments]    ${physCellId_list}    ${add_object_cell_num}    ${start_cell_id}    ${node_index_Diff}=1    ${copy_cell_id}=1
    FOR    ${item}    IN RANGE    ${add_object_cell_num}
       ${cell_id}    Evaluate    ${item} + ${start_cell_id}
       ${node_index}     Evaluate    ${item}+${node_index_Diff}
       ${physCellId}    Evaluate    ${item}+1
       Wait Until Keyword Succeeds    3x    2min    selenium_sbts.add_object
       ...    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS}   object_class_name=NRCELL
       ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${BTS_ID}/NRBTS-${NRBTS}/NRCELL-${copy_cell_id}
       ...    include_subobject=${TRUE}    id_value=${cell_id}
       selenium_sbts.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS}/NRCELL-${cell_id}
       ...    filter_param=Local cell resource ID   new_value=${cell_id}    abbr=lcrId
       selenium_sbts.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS}/NRCELL-${cell_id}
       ...    filter_param=Physical cell identifier   new_value=${physCellId_list[${item}]}   abbr=physCellId
       sleep    1s
       Wait Until Keyword Succeeds    3x    2min    selenium_sbts.add_object
       ...    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS}   object_class_name=NRCELLGRP
       ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${BTS_ID}/NRBTS-${NRBTS}/NRCELLGRP-${copy_cell_id}
       ...    include_subobject=${TRUE}    id_value=${cell_id}
       sleep    1s
       selenium_sbts.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS}/NRCELLGRP-${cell_id}
       ...    filter_param=List of NR cells assigned to cell group   node_index=${0}    new_value=${cell_id}    abbr=nrCellList
       selenium_sbts.add_element    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS}/NRDU-1
       ...    filter_param=Reference to cell group    abbr=refNrCellGroup
       selenium_sbts.set_parameter_value
       ...    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS}/NRDU-1
       ...    filter_param=Reference to cell group    new_value=${cell_id}   node_index=${node_index}  abbr=refNrCellGroup
       Wait Until Keyword Succeeds    3x    2min    selenium_sbts.add_object
       ...    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1   object_class_name=LCELNR
       ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${copy_cell_id}
       ...    include_subobject=${TRUE}    id_value=${cell_id}
       log to console    add NRCELL-${cell_id} successful
    END

Delete CHANNELGROUP
    [Arguments]    ${CHANNELGROUP_id}    ${cell_id}
    Wait Until Keyword Succeeds    3x    2min    selenium_sbts.remove_object
    ...    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-${CHANNELGROUP_id}
