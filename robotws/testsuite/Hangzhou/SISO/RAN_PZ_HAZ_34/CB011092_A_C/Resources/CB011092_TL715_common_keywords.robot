*** Settings ***
Documentation
...    author: xiaofeng zhu
...    contact: xiaofeng.1.zhu@nokia-sbell.com
...    squad group: MMW_SG_04
...    feature : CB011092


Library     taf.sbts.oam.coam.admin       WITH NAME    coam
Library     taf.transport.ssh            WITH NAME    ssh
Library     taf.selenium.sbts            WITH NAME    selenium_sbts
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/modify_scf.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Commercial_mobile_phone_adb_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB007306_OTA/Resources/CB007306_common_keyword.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB009102/Resources/CB009102_common_keyword_2.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB007835_B_NEW/resources/common_keywords.robot
Variables    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB007835_B_NEW/resources/modify_para.py

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
${ul_power_port_list}         ${tl.ues[0].iperf_details.ports[0:2]}
${dl_power_port_list}         ${tl.ues[0].iperf_details.ports[2:4]}
@{allowed_list}               ${4655}    ${61524}    ${4654}    ${61652}    ${4592}    ${49}    ${61649}
${att_connection_port}        ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${gNB_ssh_name}               ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${gNB_ssh_pass}               ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${BTS_ID}                 ${tl.gnbs[0].global_bts_id}

${PB_IP_GNB}        ${tl.attenuator[6].addr}
${PB_PORT_GNB}        ${tl.attenuator[6].port_numbers[0]}
${PB_IP_RMOD1}        ${tl.attenuator[0].addr}
${PB_PORT_RMOD1}        ${tl.attenuator[0].port_numbers[4]}
${PB_IP_RMOD2}        ${tl.attenuator[1].addr}
${PB_PORT_RMOD2}        ${tl.attenuator[1].port_numbers[5]}
${PB_IP_RMOD3}        ${tl.attenuator[2].addr}
${PB_PORT_RMOD3}        ${tl.attenuator[2].port_numbers[6]}
${PB_IP_RMOD4}        ${tl.attenuator[3].addr}
${PB_PORT_RMOD4}        ${tl.attenuator[3].port_numbers[0]}
${PB_IP_RMOD5}        ${tl.attenuator[4].addr}
${PB_PORT_RMOD5}        ${tl.attenuator[4].port_numbers[1]}
${PB_IP_RMOD6}        ${tl.attenuator[5].addr}
${PB_PORT_RMOD6}        ${tl.attenuator[5].port_numbers[5]}

#@{RU_unlock_status}           Unlocked    enabled    Active    configured
#@{RU_lock_status}             Locked    enabled    Idle    configured
@{Cell_unblock_status}        unlocked    enabled    unblocked
@{Cell_block_status}          unlocked    disabled    blocked

@{NR_cell_id_nrtdd_0}      599760
@{NR_cell_id_nrtdd_1}      599761
@{NR_cell_id_nrtdd_2}      599762
@{NR_cell_id_nrtdd_3}      599763
@{NR_cell_id_nrtdd_4}      599764
@{NR_cell_id_nrtdd_5}      599765

@{NR_cell_id_list_CA_NRTDD}      599761    	599764

@{LTE_cell_list_block}        ${1}    ${5}    ${9}
@{NR_cell_list_block}         ${1}    ${2}
${NRBTS_ID}                   ${tl.gnbs[0].instance_id}
${LNBTS}                      ${tl.enbs[0].global_bts_id}
${NRBTS}                      ${tl.gnbs[0].global_bts_id}
@{PA_port_list}               ${0}    ${1}    ${2}    ${3}    ${4}
@{LTE_row_list}               LTE PDCP Thr. DL [Mbps]    LTE PDCP Thr. UL [Mbps]
@{empty_list}
@{RU_unlock_status}           Unlocked    enabled    Active    configured
@{RU_lock_status}             Locked    enabled    Idle    configured
@{cell_id_list_6CC}           1    2    3    4    0    5
@{physCellId_list}            90    92    93    94    91    95
@{cell_id_list_8CC}           1    2    4    5    6    7    8    9
@{physCellId_list_8CC}        90    92    94    95    96    97    98    99    100    101    102
@{block_cell_list_1}          1    2    4    5    6    7    8    9
@{block_cell_list_2}          1    3    6    7    8    9    10    11
@{cell_id_list_2T2R_8CC}          1    3    6    7    8    9    10    11
${test_iteration}       ${1}

*** Keywords ***
########### setup and teardown KW #################
CB011092 Suite Setup
    CI_interface.Common Suite Setup
    robot_common_operations.Common Suite Setup

Check GNB on air and Check Alarm List on BTS
    [Arguments]       ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    Check the GNB on air_debug
    Check Alarm List on BTS    allowed_list=${allowed_list}    bts_host=${bts_host}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Case Teardown1
    [Arguments]    ${bts_host}=${gnb_ip}    ${if_activate_scf}=${False}
    log to console    ${TEST_STATUS} recover action...
    Run Keyword if    "${TEST_STATUS}"=="FAIL"    Save the Snapshot
    run keyword if    ${if_activate_scf}    Setup the Commission SCF    bts_host=${bts_host}
    AlarmWatchdog.remove_allow_alarms    fault_id=49
    AlarmWatchdog.remove_allow_alarms    fault_id=1815
    AlarmWatchdog.remove_allow_alarms    fault_id=4589
    Check GNB on air and Check Alarm List on BTS
    robot_common_operations.Common case Teardown
    CI_interface.Common Case Teardown

Case Setup
    robot_common_operations.Common case Setup
    Wait Until Keyword Succeeds    1min    5s    Kill firefox
    AlarmWatchdog.add_allow_alarms    fault_id=49
    AlarmWatchdog.add_allow_alarms    fault_id=1815
    AlarmWatchdog.add_allow_alarms    fault_id=4589
    Adapt to ute cloud commission scf1
    Check GNB on air and Check Alarm List on BTS

########### check bts on air #################
Adapt to ute cloud commission scf1
    ${TL_NAME}   set variable if      '${testline_name}' == 'null' or '${testline_name}' == '${EMPTY}'    ${CONFIGURATION}    ${testline_name}
    #${ute_env}    Run Keyword And Return Status    Variable Should Exist    ${CONFIGURATION}
    #${TL_NAME}   set variable if      ${ute_env}    ${CONFIGURATION}    ${testline_name}
    ${pattern}   Set Variable    7_5(.*)
    ${TLNAME_1}    Get Regexp Matches     ${TL_NAME}    ${pattern}    1
    ${TLNAME_final}   Set Variable    7_5${TLNAME_1}[0]
    Set Suite Variable    ${CURDIR_path}    ${CURDIR}/../../../../../../commissionings/HGZ/${TLNAME_final}

Set default SCF
    [Arguments]    ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${version}    coam.get_sw_version    connection=${connection}
    ${version_list}    split string    ${version}    separator=_
    ${version_scf}    run keyword if    '${version_list[2]}'=='9999'    Set Variable    SBTS00
    ...    ELSE   Set Variable    ${version_list[0]}
    ${default_scf}    set variable    ${CURDIR_path}/SCF_${version_scf}.xml
    Set Suite variable   ${default_scf}
    log to console   ${default_scf}
    [Teardown]     Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
    [Return]    ${default_scf}

Setup the Commission SCF
    [Arguments]    ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM
    ${default_scf}    Set default SCF    bts_host=${bts_host}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    COAM Commission with scf file    scf_file_path=${default_scf}    timeout=600    connection=${connection}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Check the GNB on air
    [Timeout]    30 min
    [Arguments]  ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM
    Wait Until Keyword Succeeds    20min    20s
    ...    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    Wait Until Keyword Succeeds    30min    20s    COAM Check GNB cell on air    connection=${connection}
    Wait Until Keyword Succeeds    30min    20s    Verify all cells should be onair    connection=${connection}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Check the GNB on air_debug
    [Timeout]    20 min
    [Arguments]   ${connection}=GNB_OAM
    Wait Until Keyword Succeeds    20min    20s    COAM Check GNB cell on air    connection=${connection}
    Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair    connection=${connection}

Get Alarm on BTS
    [Arguments]  ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    @{active_alarms}    coam.get_active_alarms    connection=${connection}
    @{history_alarms}    coam.get_historic_alarms    connection=${connection}
    ${active_id_list}    Get Alarm ID From BTS    output_alarms=${active_alarms}
    ${history_id_list}    Get Alarm ID From BTS    output_alarms=${history_alarms}
    [Return]  ${active_id_list}    ${history_id_list}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Get Alarm on BTS_debug
    [Arguments]  ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    connection=${connection}
    @{active_alarms}    coam.get_active_alarms    connection=${connection}
    @{history_alarms}    coam.get_historic_alarms    connection=${connection}
    ${active_id_list}    Get Alarm ID From BTS    output_alarms=${active_alarms}
    ${history_id_list}    Get Alarm ID From BTS    output_alarms=${history_alarms}
    [Return]  ${active_id_list}    ${history_id_list}

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
    ${actual_fault_id_list}    ${history_id_list}    Get Alarm on BTS_debug    bts_host=${bts_host}    connection=${connection}
    ${history_id_len}    Get Length    ${history_id_list}
    Run Keyword if    ${allowed_list} != None        Check List1 content in List2    list1=${actual_fault_id_list}    list2=${allowed_list}
    Run Keyword if    ${allowed_list} != None        Check List1 content in List2    list1=${history_id_list}    list2=${allowed_list}
    Run Keyword if    ${not_allowed_list} != None     Check List1 content not in List2    list1=${not_allowed_list}    list2=${actual_fault_id_list}
#    Run Keyword if    ${history_id_len} != ${0}    Save the Snapshot
#    Should be equal    ${history_id_len}    ${0}

Check Alarm List on BTS
    [Arguments]  ${allowed_list}=None    ${not_allowed_list}=None    ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM
    ${status}    Run Keyword And Return Status    Check Alarm List on BTS Temp    allowed_list=${allowed_list}
    ...    not_allowed_list=${not_allowed_list}    bts_host=${bts_host}    connection=${connection}
    Run Keyword if    ${status} == ${False}    Save the Snapshot
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

########### Cell operation #################
Block or UnBlock Multiple Cell
    [Arguments]     ${nr_cell_id}    ${block_flag}=${True}    ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM    ${timeout}=60
    Run keyword if    ${block_flag}==${True}    Log To Console    Block Cell Start
    ...    ELSE    Log To Console    UnBlock Cell Start
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${dist_name}    Set Variable    MRBTS-${BTS_ID}/NRBTS-${NRBTS}/NRCELL-${nr_cell_id}
    Run keyword if    ${block_flag}==${True}    coam.block_cell    dist_name=${dist_name}    timeout=${timeout}    connection=${connection}
    ...    ELSE    coam.unblock_cell    dist_name=${dist_name}    timeout=${timeout}    connection=${connection}
    sleep    30s
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Check All RU or Cell Status
    [Documentation]  expect_item_status_dict eg:
    ...              1) ${cell_status_dict}    Create Dictionary     NRCELL-1=${Cell_unblock_status}    NRCELL-2=${Cell_block_status}
    ...              2) ${ru_status_dict}    Create Dictionary     RMOD-1=${RU_unlock_status}    RMOD-2=${RU_lock_status}
    [Arguments]  ${expect_item_status_dict}    ${actual_item_status_dict}    ${if_ru}=${True}
    Log To Console    Check All RU or Cell Status
    @{item_id_list}    get dictionary keys    ${expect_item_status_dict}
    @{status_list}    create list
    FOR  ${item_id}  IN  @{item_id_list}
        ${expect_status_list}     get from dictionary    ${expect_item_status_dict}    ${item_id}
        ${item_status}    set variable    ${actual_item_status_dict['${item_id}']}
        ${status}    run keyword and return status
        ...    Run Keyword If    ${if_ru}    Check Single RU Status    item_status=${item_status}    expect_status_list=${expect_status_list}
        ...    ELSE    Check Single Cell Status    item_status=${item_status}    expect_status_list=${expect_status_list}
        append to list    ${status_list}    ${status}
    END
    [Return]  ${status_list}

Get All RU or Cell Status
    [Arguments]   ${cell_type}=nr    ${if_ru}=${True}    ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM
    Log to console    Get All RU or Cell Status
    ${item_status_dic}    Create Dictionary
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${ru_info_list}    coam.get_frm    connection=${connection}
    ${cell_info_list}     coam.Get_Cells_Info   cell_type=${cell_type}    connection=${connection}
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
    ${admin_status}    get from dictionary    ${item_status}    administrativeState
    ${admin_status}    Evaluate    '${admin_status}'.lower()
    Run Keyword And Continue On Failure    should be equal as strings   ${admin_status}    ${expect_status_list[${0}]}
    ${operate_status}    get from dictionary    ${item_status}    operationalState
    ${operate_status}    Evaluate    '${operate_status}'.lower()
    Run Keyword And Continue On Failure    should be equal as strings    ${operate_status}    ${expect_status_list[${1}]}
    ${block_status}    get from dictionary    ${item_status}    blockingState
    ${block_status}    Evaluate    '${block_status}'.lower()
    Run Keyword And Continue On Failure    should be equal as strings   ${block_status}    ${expect_status_list[${2}]}

Get LTE And NR cell Status
    [Arguments]  ${bts_host}=${gnb_ip}
    ${nr_cell_status_dic}    Get All RU or Cell Status    cell_type=nr    if_ru=${False}    bts_host=${bts_host}    connection=GNB_OAM
    ${lte_cell_status_dic}   Get All RU or Cell Status    cell_type=lte    if_ru=${False}    bts_host=${bts_host}    connection=GNB_OAM
    ${nr_cells_ID}    Get Dictionary Keys    ${nr_cell_status_dic}
    FOR    ${ID}    IN    @{nr_cells_ID}
        ${cell_info}    Get From Dictionary    ${nr_cell_status_dic}    ${ID}
        Set To Dictionary   ${lte_cell_status_dic}  ${ID}=${cell_info}
    END
    [Return]  ${lte_cell_status_dic}

Check All LTE And NR cell Status
    [Arguments]  ${expect_cell_status}    ${bts_host}=${gnb_ip}
    ${all_cell_status_dict}   Get LTE And NR cell Status    bts_host=${bts_host}
    ${expect_cell_status_dict}    Create Dictionary
    @{cell_id_list}    get dictionary keys  ${all_cell_status_dict}
    FOR  ${cell_id}  IN  @{cell_id_list}
        Set To Dictionary    ${expect_cell_status_dict}    ${cell_id}=${expect_cell_status}
    END
    ${status_list}    Check All RU or Cell Status    expect_item_status_dict=${expect_cell_status_dict}
    ...    actual_item_status_dict=${all_cell_status_dict}    if_ru=${False}
    Should Not Contain    ${status_list}    ${False}

################## Snopshot ###########################
Save the Snapshot
    [Arguments]    ${connection}=cOAM
    log to console    Save Snapshot...
    run keyword and ignore error     coam.teardown    connection=${connection}
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
    ...    connection=${connection}
    coam.collect_snapshot    target_file_name=${output_dir}/snapshot/snapshot.zip   connection=${connection}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}

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

################ About PA #######################

################ Relate To UE ###################
attach the power ue
    [Arguments]    ${ue_index_list}   ${gnb_index}=${0}
    log to console       Prepare UE
    FOR    ${ue_index}   IN    @{ue_index_list}
        power_ue.Prepare UE    ue_index=${ue_index}    ue_type=samsung    ui_version=S10UI2.1
        ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    attach_mode=5G_SA   ue_type=samsung
        power_ue.Verify attach    ue_type=samsung   5Grach_ed=${5Grach_ed_0}    4G_check=False    gnb_index=${gnb_index}
    END

start the power ue traffic ul and dl
    [Arguments]    ${ue_index_list}    ${ul_duration}=6000    ${dl_duration}=6000
    ...    ${if_ul}=${True}    ${if_dl}=${True}    ${process_num}=${2}
    log to console      Start traffic    console=yes
    FOR    ${item}    IN    @{ue_index_list}
        run keyword and continue on failure    run keyword if    ${if_Ul}    172 IP UE Start UL traffic TCP    ue_index=${item}
        ...    time=${Ul_duration}
        ...    UL_port=${Ul_power_port_list}[${item}]    process_num=${process_num}
        sleep    1s
        run keyword and continue on failure    run keyword if    ${if_dl}    172 IP UE Start DL traffic TCP    ue_index=${item}
        ...    time=${dl_duration}
        ...    DL_port=${dl_power_port_list}[${item}]    process_num=${process_num}
    END

stop the power ue traffic ul and dl
    [Arguments]    ${ue_index_list}    ${protocol}=udp    ${if_ul}=${True}    ${if_dl}=${True}    ${ue_type}=samsung
    log to console     Stop traffic    console=yes
    FOR    ${item}    IN    @{ue_index_list}
        run keyword if    ${if_ul}    power_ue.Stop traffic    direction=ul    ue_index=${item}    ue_type=${ue_type}    iperf_type=via_command
        ...    protocol=${protocol}    iperf_port=${ul_power_port_list}[${item}]
        run keyword if    ${if_dl}    power_ue.Stop traffic    direction=dl    ue_index=${item}    ue_type=${ue_type}    protocol=${protocol}
        ...    iperf_port=${dl_power_port_list}[${item}]
    END

detach the power ue
    [Arguments]    ${ue_index_list}
    log to console      UE Detach    console=yes
    FOR    ${item}    IN    @{ue_index_list}
         power_ue.UE Detach    ue_index=${item}    ue_type=samsung
    END

##################### Delete Or Add Cell########################
Rest Login DU
    [Arguments]    ${ip_address}=${gnb_ip}    ${username}=${gNB_username}
    ...    ${password}=${gNB_password}    ${alias}=default
    [Documentation]   Rest Login DU
    Connect to gnb coam via ssl    bts_host=${ip_address}    username=${username}    password=${password}    connection=${alias}
    ${conn}     set variable    ${alias}
    [Return]    ${conn}

Get BTS release
    ${conn}    Rest Login DU
    ${version}    coam.get_sw_version    connection=${conn}
    ${version_list}    split string    ${version}    separator=_
    ${bts_release}    set variable    ${version_list[0]}
    [Return]    ${bts_release}
    [Teardown]    COAM Teardown gnb connections    connection=${conn}

WEB Login
    [Documentation]   WEBUI Login
    Log To Console  START:WEBUI Login
    Log To Console  Try to login...
    ${version}    Get BTS release
    selenium_sbts.Enable_Virtual_Display
    selenium_sbts.Login    url=https://${gNB_ip}    username=${gNB_username}   password=${gNB_password}
    ...     version=${version}
    Log To Console  Login successfully...
    Run Keyword And Ignore Error      selenium_sbts.Disable_Message_Box
    Sleep    15s
    selenium_sbts.disable_screen_lock
    Log To Console  END:WEBUI Login!

WEB Logout
    [Arguments]     ${virtual_disable}=${True}
    [Documentation]    WEBUI Logout
    Log To Console    Try to logout...
    Run Keyword If      ${virtual_disable}    Run Keyword And Ignore Error    selenium_sbts.Enable_Virtual_Display
    Run Keyword And Ignore Error    selenium_sbts.Logout
    Log To Console    Logout successfully...
    Run Keyword If      ${virtual_disable}    Run Keyword And Ignore Error    selenium_sbts.Disable_Virtual_Display
    Sleep    3s
    Log To Console    END:WEBUI Logout!

Delete Nrcells Data
    [Arguments]    ${cell_id_list}    ${node_index}
    Log To Console    delete nrcell
    FOR   ${cell_id}    IN    @{cell_id_list}
        selenium_sbts.remove_object
        ...    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        selenium_sbts.remove_object
        ...    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-${cell_id}
        selenium_sbts.remove_object
        ...    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}
        selenium_sbts.remove_element
        ...    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
        ...    filter_param=Reference to cell group    node_index=${node_index}    abbr=refNrCellGroup
        ${node_index}    Evaluate    ${node_index} - 1
    END

Delete NrcellGrp Data
    [Arguments]    ${cell_id_list}    ${nrcellgrp_id}    ${node_index}
    Log To Console    delete nrcell group
    ${length}    Get Length    ${cell_id_list}
    FOR   ${item}    IN RANGE   ${length}
        Wait Until Keyword Succeeds    3x    2min    selenium_sbts.remove_object
        ...    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS}/NRCELL-${cell_id_list}[${item}]
        Wait Until Keyword Succeeds    3x    2min    selenium_sbts.remove_object
        ...    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id_list}[${item}]
    END
    Wait Until Keyword Succeeds    3x    2min    selenium_sbts.remove_object
    ...    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS}/NRCELLGRP-${nrcellgrp_id}
    Wait Until Keyword Succeeds    3x    2min    selenium_sbts.remove_element
    ...    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS}/NRDU-1
    ...    filter_param=Reference to cell group    node_index=${node_index}    abbr=refNrCellGroup

Copy Cell info From SCF
    [Arguments]    ${copy_cell_id_list}    ${keep_cell_id}
    Adapt to ute cloud commission scf1
    ${default_scf_path}    Set default SCF
    Log To Console    Add nrcell
    ${id_value}    set variable    ${1}
    ${LCELNR_name}    set variable    MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR
    selenium_sbts.load_commissioning_file_and_check_load_status    file_path=${default_scf_path}
    FOR  ${cell_id}  IN  @{copy_cell_id_list}
        ${id_value}=    Evaluate    ${id_value} + ${1}
        Wait Until Keyword Succeeds    3x    2min    selenium_sbts.add_object
        ...    object_name=${LCELNR_name}-${keep_cell_id}   object_class_name=CHANNELGROUP
        ...    plan_to_copy_from=CONF-1    copy_from=${LCELNR_name}-${cell_id}/CHANNELGROUP-1
        ...    include_subobject=${TRUE}    id_value=${id_value}
    END

#################### Case Setup########################
Check Throught From Asslog
    [Arguments]    ${ul_list}    ${dl_list}      ${ul_tp}=${100}    ${dl_tp}=${1500}    ${if_ul}=${True}    ${if_dl}=${True}
    ...    ${target_avg_percent}=0.95    ${min_percent}=0    ${ue_type}=samsung   ${log_time}=60s    ${ignore_time}=10s
    ${log_path}    power_ue.Collect Tput   ue_type=${ue_type}    duration=${log_time}    ignore_time=${ignore_time}
    run keyword and continue on failure    run keyword if    ${if_ul}==${True}    power_ue.Check Tput    ue_type=${ue_type}
    ...    direction=UL    log=${log_path}    cells=${ul_list}    target_throughput=${ul_tp}    target_avg_percent=${target_avg_percent}
    ...    actCarrierAggregation=${True}    min_percent=${min_percent}
    run keyword and continue on failure    run keyword if    ${if_dl}==${True}    power_ue.Check Tput    ue_type=${ue_type}
    ...    direction=DL    log=${log_path}    cells=${dl_list}    target_throughput=${dl_tp}    target_avg_percent=${target_avg_percent}
    ...    actCarrierAggregation=${True}    min_percent=${min_percent}

UE Start Traffic And Check Tp
    [Arguments]    ${ul_throughput}    ${dl_throughput}    ${ul_list}    ${dl_list}    ${ue_index}=${0}
    ...    ${if_ul}=${True}    ${if_dl}=${True}    ${target_avg_percent}=0.2    ${min_percent}=0    ${log_time}=60s
    ...    ${target_avg_percent_peak}=0.98    ${min_percent_peak}=0.85    ${if_peak}=${False}
    ...    ${expect_ul_tp}=0    ${expect_dl_tp}=0    ${ignore_time}=20s    ${process_num}=3
    @{ue_index_list}    create list    ${ue_index}
    attach the power ue    ue_index_list=${ue_index_list}
    sleep    5s
    start the power ue traffic ul and dl    ue_index_list=${ue_index_list}
    ...    if_ul=${if_ul}    if_dl=${if_dl}    process_num=${process_num}

    run keyword if    ${if_peak}==${False}    Check Throught From Asslog   ul_list=${ul_list}    dl_list=${dl_list}     ul_tp=${ul_throughput}
    ...    dl_tp=${dl_throughput}    if_ul=${if_ul}    if_dl=${if_dl}   target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    log_time=${log_time}

    run keyword if    ${if_peak}==${True}    Check Throught From Asslog   ul_list=${ul_list}    dl_list=${dl_list}     ul_tp=${expect_ul_tp}
    ...    dl_tp=${expect_dl_tp}    if_ul=${if_ul}    if_dl=${if_dl}   target_avg_percent=${target_avg_percent_peak}
    ...    min_percent=${min_percent_peak}    log_time=${log_time}    ignore_time=${ignore_time}

    stop the power ue traffic ul and dl    ue_index_list=${ue_index_list}    if_ul=${if_ul}    if_dl=${if_dl}
    [Teardown]    detach the power ue    ue_index_list=${ue_index_list}

Block And Unblock All Cell
    Block or UnBlock Multiple Cell    lte_cell_id_list=${LTE_cell_list_block}    nr_cell_list=${NR_cell_list_block}    block_flag=${True}
    Check All LTE And NR cell Status    expect_cell_status=${Cell_block_status}
    Block or UnBlock Multiple Cell    lte_cell_id_list=${LTE_cell_list_block}    nr_cell_list=${NR_cell_list_block}    block_flag=${False}
    Check All LTE And NR cell Status    expect_cell_status=${Cell_unblock_status}
    Check GNB on air and Check Alarm List on BTS

Modify Parameter And Check BTS Status
    [Arguments]    ${input_list}
    Modify Parameters with json    input_list=${input_list}

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
        Run keyword if    ${lock_flag}==${True}    Log To Console    Lock RMOD-${RMOD_id}
        ...    ELSE    Log To Console    UnLock RMOD-${RMOD_id}
        Run keyword if    ${lock_flag}==${True}    coam.lock    dist_name=${dist_name}    timeout=${timeout}    connection=${connection}
        ...    ELSE    coam.unlock    dist_name=${dist_name}    timeout=${timeout}    connection=${connection}
        sleep    8s
    END
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

configuration nomalcell to supercell
    [Arguments]   ${LCELNR_ID_1}=${cell_id_list_6CC}[0]    ${LCELNR__COPY_ID_1}=${cell_id_list_6CC[1:2]}
    ...    ${LCELNR_ID_2}=${cell_id_list_6CC}[2]    ${LCELNR__COPY_ID_2}=${cell_id_list_6CC[3:4]}
    ...    ${LCELNR_ID_3}=${cell_id_list_6CC}[4]    ${LCELNR__COPY_ID_3}=${cell_id_list_6CC[5:6]}    ${if_supercell_2}=${False}
    ...    ${if_supercell_3}=${False}   ${node_index_1}=${5}    ${node_index_2}=${3}    ${node_index_3}=${1}
    ...    ${start_id_1}=${2}    ${start_id_2}=${2}    ${start_id_3}=${2}    ${expect_cell_info}=none

    Run keyword if    ${if_supercell_3}==${True}    config supercell    LCELNR_ID=${LCELNR_ID_3}
    ...    LCELNR__COPY_ID=${LCELNR__COPY_ID_3}    node_index=${node_index_3}    start_id=${start_id_3}

    Run keyword if    ${if_supercell_2}==${True}    config supercell    LCELNR_ID=${LCELNR_ID_2}
    ...    LCELNR__COPY_ID=${LCELNR__COPY_ID_2}    node_index=${node_index_2}    start_id=${start_id_2}

    config supercell    LCELNR_ID=${LCELNR_ID_1}    LCELNR__COPY_ID=${LCELNR__COPY_ID_1}    node_index=${node_index_1}    start_id=${start_id_1}


    ${error}    selenium_sbts.validate_plan    timeout=120
    Log To Console    ${error}
    selenium_sbts.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${180}
    Check the GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}
    Check Cells info    expect_cell_info=${expect_cell_info}

config supercell
    [Arguments]   ${LCELNR_ID}    ${LCELNR__COPY_ID}    ${node_index}=${1}    ${start_id}=${2}
    Add Channelgroup Object    start_id=${start_id}    LCELNR_ID=${LCELNR_ID}   LCELNR__COPY_ID=${LCELNR__COPY_ID}
    Delete Nrcells Data    cell_id_list=${LCELNR__COPY_ID}    node_index=${node_index}
    selenium_sbts.set_parameter_value
    ...    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${LCELNR_ID}
    ...    filter_param=Activate super cell   new_value=true    abbr=actSuperCell

Add Channelgroup Object
    [Arguments]   ${start_id}    ${LCELNR__COPY_ID}    ${LCELNR_ID}    ${copy_from}=CURRENT_BTS_CONF-1
    Log To Console    add channelgroup
    FOR    ${item}    IN     @{LCELNR__COPY_ID}
        selenium_sbts.add_object
        ...    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${LCELNR_ID}   object_class_name=CHANNELGROUP
        ...    plan_to_copy_from=${copy_from}    copy_from=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${item}/CHANNELGROUP-1
        ...    include_subobject=${TRUE}    id_value=${start_id}
        ${start_id}    Evaluate    ${start_id} + 1
    END

172 IP UE Start DL traffic TCP
    [Arguments]    ${DL_port}    ${ue_index}=${2}    ${time}=6000    ${process_num}=${1}
    ...    ${connection}=cygwin
    #get ue ip
    ssh.connect to    hostname=${control_pc}    username=${control_pc_name}    password=${control_pc_pass}    alias=${connection}
    ${serial_number}    set variable    ${tl.ues[${ue_index}].serial_number}
    ssh.send_command    command=adb -s ${serial_number} shell ip -f inet addr |grep inet |grep -v ims00 | cut -d '/' -f 1 |awk '{print $2}'
    ...    connection=${connection}
    ${UE_IP_info}    ssh.read_output    connection=${connection}
    ${UE_IP}    Get_UE_Right_IP    cmd_info=${UE_IP_info}
    log to console    UE IP :${UE_IP}
    #ue iperf
    ssh.send_command    command=adb -s ${serial_number} root &
    ...    connection=${connection}
    ssh.send_command    command=adb -s ${serial_number} shell ps -ef |grep iperf |grep ${DL_port} |grep -v grep |awk '{print $2}'
    ...    connection=${connection}
    ssh.send_command    command=adb -s ${serial_number} shell ps -ef |grep iperf |grep ${DL_port} |grep -v grep |awk '{print $2}'
    ...    connection=${connection}
    ${pid}    wait until keyword succeeds    1 min    10 sec    ssh.read_output    connection=${connection}
    ssh.send_command    command=adb -s ${serial_number} shell kill -9 ${pid} &
    ...    connection=${connection}
    sleep  2s
    ssh.send_command    command=adb -s ${serial_number} shell ps -ef |grep iperf |grep ${DL_port} |grep -v grep |awk '{print $2}'
    ...    connection=${connection}
    ${pid}    wait until keyword succeeds    1 min    10 sec    ssh.read_output    connection=${connection}
    ssh.send_command    command=adb -s ${serial_number} shell /data/local/tmp/iperf3 -s -p ${DL_port} -i 1 &
    ...    connection=${connection}
    sleep  3s
    #send DL command
    wait until keyword succeeds    1 min    10 sec    Connect to EPC APP    ue_index=${ue_index}
    sleep  3s
    ssh.send_command   command=ps -ef|grep iperf3|grep -v grep|grep ${DL_port}| awk '{print $2}' |xargs kill -9 &    connection=EPCAPP
    sleep  3s
    ssh.send_command
    ...    command=iperf3 -t ${time} -P 11 -w 2M -M 1200 -p ${DL_port} -c ${UE_IP} ${process_num} -w 2M -M 1180 >/dev/null 2>/dev/null &
    ...    connection=EPCAPP
    sleep  3s
    ssh.disconnect    connection=EPCAPP
    [Teardown]  ssh.disconnect    connection=${connection}

172 IP UE Start UL traffic TCP
    [Arguments]    ${UL_port}    ${ue_index}=${2}    ${time}=6000    ${process_num}=${1}
    ...    ${connection}=cygwin
    #get ue ip
    ssh.connect to    hostname=${control_pc}    username=${control_pc_name}    password=${control_pc_pass}    alias=${connection}
    ${serial_number}    set variable    ${tl.ues[${ue_index}].serial_number}
    ssh.send_command    command=adb -s ${serial_number} shell ip -f inet addr |grep inet |grep -v ims00 | cut -d '/' -f 1 |awk '{print $2}'
    ...    connection=${connection}
    ${UE_IP_info}    ssh.read_output    connection=${connection}
    ${UE_IP}    Get_UE_Right_IP    cmd_info=${UE_IP_info}
    log to console    UE IP :${UE_IP}
    #ue iperf
    ssh.send_command    command=adb -s ${serial_number} root &
    ...    connection=${connection}
    ssh.send_command    command=adb -s ${serial_number} shell ps -ef |grep iperf |grep ${UL_port} |grep -v grep |awk '{print $2}'
    ...    connection=${connection}
    ${pid}    wait until keyword succeeds    1 min    10 sec    ssh.read_output    connection=${connection}
    ssh.send_command    command=adb -s ${serial_number} shell kill -9 ${pid} &
    ...    connection=${connection}
    sleep  2s
    ssh.send_command    command=adb -s ${serial_number} shell ps -ef |grep iperf |grep ${UL_port} |grep -v grep |awk '{print $2}'
    ...    connection=${connection}
    ${pid}    wait until keyword succeeds    1 min    10 sec    ssh.read_output    connection=${connection}
    ssh.send_command    command=adb -s ${serial_number} shell /data/local/tmp/iperf3 -s -p ${UL_port} -i 1 &
    ...    connection=${connection}
    sleep  3s
    #send DL command
    wait until keyword succeeds    1 min    10 sec    Connect to EPC APP    ue_index=${ue_index}
    sleep  3s
    ssh.send_command   command=ps -ef|grep iperf3|grep -v grep|grep ${UL_port}| awk '{print $2}' |xargs kill -9 &    connection=EPCAPP
    sleep  3s
    ssh.send_command
    ...    command=iperf3 -t ${time} -P 10 -w 2M -M 1200 -p ${UL_port} -c ${UE_IP} -R ${process_num} >/dev/null 2>/dev/null &
    ...    connection=EPCAPP
    sleep  3s
    ssh.disconnect    connection=EPCAPP
    [Teardown]  ssh.disconnect    connection=${connection}

Get Theoretical TP From NRDIM_1
    [Arguments]    ${dl_cell_list}=${empty_list}
    ${scf_name}    set variable    715_peak_scf.xml
    Download Current BTS SCF To UTE    scf_name=${scf_name}
    ${default_scf}    Set Variable    ${OUTPUT_DIR}/${scf_name}
    ${total_ul_tp}    ${total_dl_tp}    Calculate Theoretical TP    scf_path=${default_scf}    dl_cell_list=${dl_cell_list}
    ...    ul_cell_list=${dl_cell_list}
    Log to console    [Origion]Tput calculated by NRDIM: DL:${total_dl_tp}, UL:${total_ul_tp}
    ${total_dl_tp}    Evaluate    ${total_dl_tp}-${26}
    ${total_ul_tp}    Evaluate    ${total_ul_tp}*0.5    #UL RANK1
    Log to console    Tput calculated by NRDIM: DL:${total_dl_tp}, UL:${total_ul_tp}
    [Return]    ${total_ul_tp}    ${total_dl_tp}

Download Current BTS SCF To UTE
    [Arguments]    ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM_1    ${scf_name}=${Empty}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}
    ...    connection=${connection}
    coam.get_current_scf_file    local_dir_path=${OUTPUT_DIR}    file_name=${scf_name}    connection=${connection}
    ...    timeout=${120}    with_auto_configured_parameters=${True}
    [Teardown]     Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

unlock RU and cell
    [Arguments]    ${lock_ru_id_list}    ${block_cellid_1}    ${block_cellid_2}
    Lock or Unlock RU And Check Status    unlock_RU_id_list=${lock_ru_id_list}    lock_flag=${False}    bts_host=${gnb_ip}   BTS_ID=37485
    Block or UnBlock Multiple Cell    nr_cell_id=${block_cellid_1}    block_flag=${False}    bts_host=${gnb_ip}
    Block or UnBlock Multiple Cell    nr_cell_id=${block_cellid_2}    block_flag=${False}    bts_host=${gnb_ip}

check active alarm
     [Arguments]    ${BTS_IP}    ${test_alarm_ID}    ${test_fault_ID}    ${check}    ${ru_index}
     ...    ${connection}=GNB_OAM
     log to console    start check RU${ru_index} alarm
     coam.connect_to    bts_host=${BTS_IP}   name=${connection}
     ${alarms}    coam.get_active_alarms    connection=${connection}
     FOR    ${item}    IN    @{alarms}
          ${ObjectName}    get from dictionary    ${item}    configObjectName
          ${alarm_id}    get from dictionary    ${item}    alarmId
          ${fault_id}    get from dictionary    ${item}    faultId
          ${status}    Run Keyword If
          ...    '${ALARM_RU_NAME}${ru_index}'=='${ObjectName}' and '${alarm_id}'=='${test_alarm_ID}'    Compare alarm detail
          ...    alarm_id=${alarm_id}    fault_id=${fault_id}
          ...    test_alarm_ID=${test_alarm_ID}    test_fault_ID=${test_fault_ID}
           Exit For Loop If    '${status}'=='${True}'
     END
     Run Keyword If    '${status}'=='None'    Set Suite Variable    ${status}    ${False}
     Should Be Equal as strings    ${status}    ${check}
     log to console    check RU alarm successful
     [Teardown]    coam.teardown    connection=${connection}

Compare alarm detail
    [Arguments]    ${alarm_id}    ${fault_id}
    ...    ${test_alarm_ID}    ${test_fault_ID}
    should be equal    ${alarm_id}            ${test_alarm_ID}
    should be equal    ${fault_id}            ${test_fault_ID}
    ${status}    Set Variable    ${True}
    [Return]    ${status}

lock RU and attach to supercell
     [Arguments]    ${RU_index1}    ${RU_index2}    ${block_cellid}    ${NR_cell_id_list}
    @{lock_ru_id_list}    create list    ${RU_index1}    ${RU_index2}
    Lock or Unlock RU And Check Status    lock_RU_id_list=${lock_ru_id_list}    lock_flag=${True}    bts_host=${gnb_ip}   BTS_ID=37485
    Block or UnBlock Multiple Cell    nr_cell_id=${block_cellid}    block_flag=${True}    bts_host=${gnb_ip}
    UE Start Traffic And Check Tp    ul_throughput=160    dl_throughput=300    ul_list=${NR_cell_id_list}
    ...    dl_list=${NR_cell_id_list}    ue_index=${0}    target_avg_percent=0.2    log_time=60s
    [Teardown]    unlock RU and unblock cell    lock_ru_id_list=${lock_ru_id_list}    block_cellid=${block_cellid}

unlock RU and unblock cell
    [Arguments]    ${lock_ru_id_list}    ${block_cellid}
    Lock or Unlock RU And Check Status    unlock_RU_id_list=${lock_ru_id_list}    lock_flag=${False}    bts_host=${gnb_ip}   BTS_ID=37485
    Block or UnBlock Multiple Cell    nr_cell_id=${block_cellid}    block_flag=${False}    bts_host=${gnb_ip}

Stability Reset with HWF test
    ${swconfig_list}=   Create List   0x190030=0    0x4F0214=0
    Modify Swconfig File   para_update=${swconfig_list}
    run keyword and ignore error    COAM Teardown gnb connections
    Wait Until Keyword Succeeds    1 min    5 sec    Connect to gnb coam via ssl
    ...    bts_host=${DU_OAM_IP}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    Run Keyword And Continue On Failure    start btslog capture  name=btslog
    Reset BTS And Wait Until On Air
    Run Keyword And Continue On Failure    stop btslog and collect logs   status=FAIL
    ${bts_log_path}=   set variable   ${OUTPUT_DIR}/btslog/syslog_files.tgz
    Run Keyword And Continue On Failure    Check_btslog_After_Reset   log_path=${bts_log_path}
    Wait Until Keyword Succeeds    3 min    5 sec    Check_gNB_Startup_log
    Wait Until Keyword Succeeds    1 min    5 sec  Connect to gnb coam via ssl
    ...    bts_host=${DU_OAM_IP}    username=${DU_OAM_WEBUI_USER}    password=${DU_OAM_WEBUI_PASSWORD}
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    Run Keyword And Continue On Failure    Unexpect History Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    [Teardown]   run keyword and ignore error    COAM Teardown gnb connections

Power Off or on
    [Arguments]    ${PB_IP}    ${RU_PORT}    ${if_power_on}=${False}
    log to console    start power reset
    pdu.Setup Pdu    model=HBTE    host=${PB_IP}    alias=pdu_alias
    Run keyword if    ${if_power_on}==${True}    pdu.Power On    port=${RU_PORT}   pdu_device=pdu_alias
    Run keyword if    ${if_power_on}==${False}    pdu.Power Off    port=${RU_PORT}   pdu_device=pdu_alias

    ${status}=    Run keyword if    ${if_power_on}==${True}    pdu.Get Port Status    port=${RU_PORT}    pdu_device=pdu_alias
    Run keyword if    ${if_power_on}==${True}    Should Be Equal    ${status}    on

    ${status}=    Run keyword if    ${if_power_on}==${False}    pdu.Get Port Status    port=${RU_PORT}    pdu_device=pdu_alias
    Run keyword if    ${if_power_on}==${False}    Should Be Equal    ${status}    off

config 6normal cell to 3supercell
    WEB Login
    selenium_sbts.remove_object
    ...    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1/NRREL-1

    configuration nomalcell to supercell    LCELNR_ID_1=${cell_id_list_6CC}[0]     LCELNR__COPY_ID_1=${cell_id_list_6CC[1:2]}
    ...    LCELNR_ID_2=${cell_id_list_6CC}[2]    LCELNR__COPY_ID_2=${cell_id_list_6CC[3:4]}    if_supercell_2=${True}
    ...    LCELNR_ID_3=${cell_id_list_6CC}[4]    LCELNR__COPY_ID_3=${cell_id_list_6CC[5:6]}    if_supercell_3=${True}
    ...    node_index_1=${1}    node_index_2=${3}    node_index_3=${5}    expect_cell_info=${supercell_for_3super2sub}
    [Teardown]    WEB Logout

power off RMOD and attach supercell
    Power Off or on    PB_IP=${PB_IP_RMOD1}    RU_PORT=${PB_PORT_RMOD1}    if_power_on=${False}
    wait until keyword succeeds    300s    10 s    check active alarm    check=${True}
    ...    test_alarm_ID=${7116}    test_fault_ID=${10}    ru_index=${1}    BTS_IP=${gnb_ip}
    Block or UnBlock Multiple Cell    nr_cell_id=${3}    block_flag=${True}    bts_host=${gnb_ip}
    Block or UnBlock Multiple Cell    nr_cell_id=${0}    block_flag=${True}    bts_host=${gnb_ip}
    UE Start Traffic And Check Tp    ul_throughput=100    dl_throughput=300   ul_list=${NR_cell_id_nrtdd_1}
    ...    dl_list=${NR_cell_id_nrtdd_1}    ue_index=${0}    target_avg_percent=0.2    log_time=60s

    Power Off or on    PB_IP=${PB_IP_RMOD1}    RU_PORT=${PB_PORT_RMOD1}    if_power_on=${True}
    wait until keyword succeeds    300s    10 s    check active alarm    check=${False}
    ...    test_alarm_ID=${7116}    test_fault_ID=${10}    ru_index=${1}    BTS_IP=${gnb_ip}

    Block or UnBlock Multiple Cell    nr_cell_id=${3}    block_flag=${False}    bts_host=${gnb_ip}

    Block or UnBlock Multiple Cell    nr_cell_id=${1}    block_flag=${True}    bts_host=${gnb_ip}
    Power Off or on    PB_IP=${PB_IP_RMOD3}    RU_PORT=${PB_PORT_RMOD3}    if_power_on=${False}
    wait until keyword succeeds    300s    10 s    check active alarm    check=${True}
    ...    test_alarm_ID=${7116}    test_fault_ID=${10}    ru_index=${3}    BTS_IP=${gnb_ip}

     Power Off or on    PB_IP=${PB_IP_RMOD3}    RU_PORT=${PB_PORT_RMOD3}    if_power_on=${True}
     wait until keyword succeeds    300s    10 s    check active alarm    check=${False}
    ...    test_alarm_ID=${7116}    test_fault_ID=${10}    ru_index=${3}    BTS_IP=${gnb_ip}

    UE Start Traffic And Check Tp    ul_throughput=100    dl_throughput=300   ul_list=${NR_cell_id_nrtdd_3}
    ...    dl_list=${NR_cell_id_nrtdd_3}    ue_index=${0}    target_avg_percent=0.2    log_time=60s

    Block or UnBlock Multiple Cell    nr_cell_id=${0}    block_flag=${False}    bts_host=${gnb_ip}
    Block or UnBlock Multiple Cell    nr_cell_id=${1}    block_flag=${False}    bts_host=${gnb_ip}
    power off other RMOD and recover
     [Teardown]   run keyword and ignore error    power on all RMOD

power off other RMOD and recover
    Power Off or on    PB_IP=${PB_IP_RMOD2}    RU_PORT=${PB_PORT_RMOD2}    if_power_on=${False}
    wait until keyword succeeds    300s    10 s    check active alarm    check=${True}
    ...    test_alarm_ID=${7116}    test_fault_ID=${10}    ru_index=${2}    BTS_IP=${gnb_ip}
    Power Off or on    PB_IP=${PB_IP_RMOD2}    RU_PORT=${PB_PORT_RMOD2}    if_power_on=${True}
    wait until keyword succeeds    300s    10 s    check active alarm    check=${False}
    ...    test_alarm_ID=${7116}    test_fault_ID=${10}    ru_index=${2}    BTS_IP=${gnb_ip}

    Power Off or on    PB_IP=${PB_IP_RMOD4}    RU_PORT=${PB_PORT_RMOD4}    if_power_on=${False}
    wait until keyword succeeds    300s    10 s    check active alarm    check=${True}
    ...    test_alarm_ID=${7116}    test_fault_ID=${10}    ru_index=${4}    BTS_IP=${gnb_ip}
    Power Off or on    PB_IP=${PB_IP_RMOD4}    RU_PORT=${PB_PORT_RMOD4}    if_power_on=${True}
    wait until keyword succeeds    300s    10 s    check active alarm    check=${False}
    ...    test_alarm_ID=${7116}    test_fault_ID=${10}    ru_index=${4}    BTS_IP=${gnb_ip}

    Power Off or on    PB_IP=${PB_IP_RMOD5}    RU_PORT=${PB_PORT_RMOD5}    if_power_on=${False}
    wait until keyword succeeds    300s    10 s    check active alarm    check=${True}
    ...    test_alarm_ID=${7116}    test_fault_ID=${10}    ru_index=${5}    BTS_IP=${gnb_ip}
    Power Off or on    PB_IP=${PB_IP_RMOD5}    RU_PORT=${PB_PORT_RMOD5}    if_power_on=${True}
    wait until keyword succeeds    300s    10 s    check active alarm    check=${False}
    ...    test_alarm_ID=${7116}    test_fault_ID=${10}    ru_index=${5}    BTS_IP=${gnb_ip}

    Power Off or on    PB_IP=${PB_IP_RMOD6}    RU_PORT=${PB_PORT_RMOD6}    if_power_on=${False}
    wait until keyword succeeds    300s    10 s    check active alarm    check=${True}
    ...    test_alarm_ID=${7116}    test_fault_ID=${10}    ru_index=${6}    BTS_IP=${gnb_ip}
    Power Off or on    PB_IP=${PB_IP_RMOD6}    RU_PORT=${PB_PORT_RMOD6}    if_power_on=${True}
    wait until keyword succeeds    300s    10 s    check active alarm    check=${False}
    ...    test_alarm_ID=${7116}    test_fault_ID=${10}    ru_index=${6}    BTS_IP=${gnb_ip}

    Check the GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}

power on all RMOD
    Power Off or on    PB_IP=${PB_IP_RMOD1}    RU_PORT=${PB_PORT_RMOD1}    if_power_on=${True}
    Power Off or on    PB_IP=${PB_IP_RMOD2}    RU_PORT=${PB_PORT_RMOD2}    if_power_on=${True}
    Power Off or on    PB_IP=${PB_IP_RMOD3}    RU_PORT=${PB_PORT_RMOD3}    if_power_on=${True}
    Power Off or on    PB_IP=${PB_IP_RMOD4}    RU_PORT=${PB_PORT_RMOD4}    if_power_on=${True}
    Power Off or on    PB_IP=${PB_IP_RMOD5}    RU_PORT=${PB_PORT_RMOD5}    if_power_on=${True}
    Power Off or on    PB_IP=${PB_IP_RMOD6}    RU_PORT=${PB_PORT_RMOD6}    if_power_on=${True}

config 5normal cell to 2supercell
    WEB Login
    selenium_sbts.remove_object
    ...    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1/NRREL-1
    Remove single NRCELL    cell_id=${cell_id_list_6CC}[5]    node_index=5

    configuration nomalcell to supercell    LCELNR_ID_1=${cell_id_list_6CC}[0]     LCELNR__COPY_ID_1=${cell_id_list_6CC[1:3]}
    ...    LCELNR_ID_2=${cell_id_list_6CC}[3]    LCELNR__COPY_ID_2=${cell_id_list_6CC[4:5]}    if_supercell_2=${True}
    ...    node_index_1=${1}    node_index_2=${2}    expect_cell_info=${supercell_for_2super5sub}
    [Teardown]    WEB Logout

Check Cells info
    [Arguments]    ${expect_cell_info}     ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${cells_info_list}    coam.get_cells_info    connection=${connection}
    ${result}    Check_Cell_Id_Info    cells_info_list=${cells_info_list}    expect_cell_info=${expect_cell_info}
    Should be equal   ${result}    ${True}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Remove single NRCELL
    [Arguments]    ${cell_id}    ${node_index}
    log to console    remove nrcell-${cell_id}
    selenium_sbts.remove_object
    ...    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    selenium_sbts.remove_object
    ...    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-${cell_id}
    selenium_sbts.remove_object
    ...    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}
    selenium_sbts.remove_element
    ...    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
    ...    filter_param=Reference to cell group    node_index=${node_index}    abbr=refNrCellGroup

attach to subcell in two supercells
    @{lock_ru_id_list1}    create list    ${2}    ${3}
    lock RU and attach cell    lock_RMOD_list=${lock_ru_id_list1}    block_cell_id=${4}    attach_cell_id=${NR_cell_id_nrtdd_1}
#    Lock or Unlock RU And Check Status    lock_RU_id_list=${lock_ru_id_list1}   lock_flag=${True}    bts_host=${gnb_ip}   BTS_ID=37485
#    Block or UnBlock Multiple Cell    nr_cell_id=${4}    block_flag=${True}    bts_host=${gnb_ip}
#    UE Start Traffic And Check Tp    ul_throughput=100    dl_throughput=300   ul_list=${NR_cell_id_nrtdd_1}
#    ...    dl_list=${NR_cell_id_nrtdd_1}    ue_index=${0}    target_avg_percent=0.2    log_time=60s
#    Lock or Unlock RU And Check Status    unlock_RU_id_list=${lock_ru_id_list1}   lock_flag=${False}    bts_host=${gnb_ip}   BTS_ID=37485
#    Block or UnBlock Multiple Cell    nr_cell_id=${4}    block_flag=${False}    bts_host=${gnb_ip}

    @{lock_ru_id_list2}    create list    ${4}
    lock RU and attach cell    lock_RMOD_list=${lock_ru_id_list2}    block_cell_id=${1}    attach_cell_id=${NR_cell_id_nrtdd_4}
#    Lock or Unlock RU And Check Status    lock_RU_id_list=${lock_ru_id_list2}   lock_flag=${True}    bts_host=${gnb_ip}   BTS_ID=37485
#    Block or UnBlock Multiple Cell    nr_cell_id=${1}    block_flag=${True}    bts_host=${gnb_ip}
#    UE Start Traffic And Check Tp    ul_throughput=100    dl_throughput=300   ul_list=${NR_cell_id_nrtdd_4}
#    ...    dl_list=${NR_cell_id_nrtdd_4}    ue_index=${0}    target_avg_percent=0.2    log_time=60s
#
#    Lock or Unlock RU And Check Status    unlock_RU_id_list=${lock_ru_id_list2}   lock_flag=${False}    bts_host=${gnb_ip}   BTS_ID=37485
#    Block or UnBlock Multiple Cell    nr_cell_id=${1}    block_flag=${False}    bts_host=${gnb_ip}

lock RU and attach cell
    [Arguments]    ${lock_RMOD_list}    ${block_cell_id}    ${attach_cell_id}
    Lock or Unlock RU And Check Status    lock_RU_id_list=${lock_RMOD_list}   lock_flag=${True}    bts_host=${gnb_ip}   BTS_ID=37485
    Block or UnBlock Multiple Cell    nr_cell_id=${block_cell_id}    block_flag=${True}    bts_host=${gnb_ip}
    UE Start Traffic And Check Tp    ul_throughput=100    dl_throughput=300   ul_list=${attach_cell_id}
    ...    dl_list=${attach_cell_id}    ue_index=${0}    target_avg_percent=0.2    log_time=60s

    Lock or Unlock RU And Check Status    unlock_RU_id_list=${lock_RMOD_list}   lock_flag=${False}    bts_host=${gnb_ip}   BTS_ID=37485
    Block or UnBlock Multiple Cell    nr_cell_id=${block_cell_id}    block_flag=${False}    bts_host=${gnb_ip}

attach to two subcells on RMOD1 and RMOD5
    @{lock_ru_id_list1}    create list    ${2}    ${3}    ${4}    ${5}    ${6}
    Lock or Unlock RU And Check Status    lock_RU_id_list=${lock_ru_id_list1}   lock_flag=${True}    bts_host=${gnb_ip}   BTS_ID=37485

    UE Start Traffic And Check Tp    ul_throughput=100    dl_throughput=300   ul_list=${NR_cell_id_nrtdd_1}
    ...    dl_list=${NR_cell_id_nrtdd_1}    ue_index=${0}    target_avg_percent=0.2    log_time=60s

config 2supercell to 6subcell in 1supercell
    [Arguments]    ${copy_from}=CURRENT_BTS_CONF-1
    WEB Login
    Wait Until Keyword Succeeds    3x    2min    selenium_sbts.add_object
        ...    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1   object_class_name=CHANNELGROUP
        ...    plan_to_copy_from=${copy_from}    copy_from=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-1
        ...    include_subobject=${TRUE}    id_value=${4}
    Wait Until Keyword Succeeds    3x    2min    selenium_sbts.add_object
        ...    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1   object_class_name=CHANNELGROUP
        ...    plan_to_copy_from=${copy_from}    copy_from=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-2
        ...    include_subobject=${TRUE}    id_value=${5}
    Wait Until Keyword Succeeds    3x    2min    selenium_sbts.add_object
        ...    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1   object_class_name=CHANNELGROUP
        ...    plan_to_copy_from=${copy_from}    copy_from=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-4/CHANNELGROUP-2
        ...    include_subobject=${TRUE}    id_value=${6}
    SET RMOD CHANNEL 4T4R
    Remove single NRCELL    cell_id=${cell_id_list_6CC}[3]    node_index=1
    ${error}    selenium_sbts.validate_plan    timeout=120
    Log To Console    ${error}
    selenium_sbts.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${180}
    Check the GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}
    Check Cells info    expect_cell_info=${supercell_for_1super6sub}
    [Teardown]    WEB Logout

SET RMOD CHANNEL 4T4R
    [Arguments]    ${GROUP_id}=6    ${RMOD_id}=6    ${LCELNR_id}=1
    Log To Console    SET RMOD CHANNEL
    selenium_sbts.set_parameter_value
    ...    dist_name=MRBTS-37485/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${LCELNR_id}/CHANNELGROUP-${GROUP_id}/CHANNEL-1
    ...    filter_param=Distinguished Name of antenna line    new_value=MRBTS-37485/EQM-1/APEQM-1/RMOD-${RMOD_id}/ANTL-1    abbr=antlDN
    selenium_sbts.set_parameter_value
    ...    dist_name=MRBTS-37485/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${LCELNR_id}/CHANNELGROUP-${GROUP_id}/CHANNEL-2
    ...    filter_param=Distinguished Name of antenna line    new_value=MRBTS-37485/EQM-1/APEQM-1/RMOD-${RMOD_id}/ANTL-1    abbr=antlDN
    selenium_sbts.set_parameter_value
    ...    dist_name=MRBTS-37485/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${LCELNR_id}/CHANNELGROUP-${GROUP_id}/CHANNEL-3
    ...    filter_param=Distinguished Name of antenna line    new_value=MRBTS-37485/EQM-1/APEQM-1/RMOD-${RMOD_id}/ANTL-2    abbr=antlDN
    selenium_sbts.set_parameter_value
    ...    dist_name=MRBTS-37485/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${LCELNR_id}/CHANNELGROUP-${GROUP_id}/CHANNEL-4
    ...    filter_param=Distinguished Name of antenna line    new_value=MRBTS-37485/EQM-1/APEQM-1/RMOD-${RMOD_id}/ANTL-2    abbr=antlDN
    selenium_sbts.set_parameter_value
    ...    dist_name=MRBTS-37485/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${LCELNR_id}/CHANNELGROUP-${GROUP_id}/CHANNEL-5
    ...    filter_param=Distinguished Name of antenna line    new_value=MRBTS-37485/EQM-1/APEQM-1/RMOD-${RMOD_id}/ANTL-3    abbr=antlDN
    selenium_sbts.set_parameter_value
    ...    dist_name=MRBTS-37485/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${LCELNR_id}/CHANNELGROUP-${GROUP_id}/CHANNEL-6
    ...    filter_param=Distinguished Name of antenna line    new_value=MRBTS-37485/EQM-1/APEQM-1/RMOD-${RMOD_id}/ANTL-3    abbr=antlDN
    selenium_sbts.set_parameter_value
    ...    dist_name=MRBTS-37485/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${LCELNR_id}/CHANNELGROUP-${GROUP_id}/CHANNEL-7
    ...    filter_param=Distinguished Name of antenna line    new_value=MRBTS-37485/EQM-1/APEQM-1/RMOD-${RMOD_id}/ANTL-4    abbr=antlDN
    selenium_sbts.set_parameter_value
    ...    dist_name=MRBTS-37485/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${LCELNR_id}/CHANNELGROUP-${GROUP_id}/CHANNEL-8
    ...    filter_param=Distinguished Name of antenna line    new_value=MRBTS-37485/EQM-1/APEQM-1/RMOD-${RMOD_id}/ANTL-4    abbr=antlDN
    Log To Console    SET RMOD CHANNEL successful

config 3supercell to 2supercell
    [Arguments]    ${copy_from}=CURRENT_BTS_CONF-1
    WEB Login
    log to console    config 3supercell to 2supercell
    selenium_sbts.add_object
    ...    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1   object_class_name=CHANNELGROUP
    ...    plan_to_copy_from=${copy_from}    copy_from=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-1
    ...    include_subobject=${TRUE}    id_value=${3}
    selenium_sbts.add_object
    ...    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-0   object_class_name=CHANNELGROUP
    ...    plan_to_copy_from=${copy_from}    copy_from=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-3/CHANNELGROUP-2
    ...    include_subobject=${TRUE}    id_value=${3}
    Remove single NRCELL    cell_id=${cell_id_list_6CC}[2]    node_index=1

    ${error}    selenium_sbts.validate_plan    timeout=120
    log to console    ${error}
    selenium_sbts.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${180}
    Check the GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}
    Check Cells info    expect_cell_info=${supercell_for_2super3sub}
    [Teardown]    WEB Logout

lock RMOD and attach to supercell
    [Arguments]    ${RMOD_ID1}    ${RMOD_ID2}    ${Block_CELL_ID}    ${ul_list}    ${dl_list}
    @{lock_ru_id_list1}    create list    ${RMOD_ID1}    ${RMOD_ID2}
    Lock or Unlock RU And Check Status    lock_RU_id_list=${lock_ru_id_list1}   lock_flag=${True}    bts_host=${gnb_ip}   BTS_ID=37485
    Block or UnBlock Multiple Cell    nr_cell_id=${Block_CELL_ID}    block_flag=${True}    bts_host=${gnb_ip}

    UE Start Traffic And Check Tp    ul_throughput=100    dl_throughput=300   ul_list=${ul_list}
    ...    dl_list=${dl_list}    ue_index=${0}    target_avg_percent=0.2    log_time=60s

    Lock or Unlock RU And Check Status    unlock_RU_id_list=${lock_ru_id_list1}   lock_flag=${False}    bts_host=${gnb_ip}   BTS_ID=37485
    Block or UnBlock Multiple Cell    nr_cell_id=${Block_CELL_ID}    block_flag=${False}    bts_host=${gnb_ip}

block normal cell and attach
    [Arguments]    ${ul_list}    ${dl_list}
    @{cell_id_list}    create list    ${0}    ${1}    ${3}    ${4}    ${5}
    block or Unblock the Multiple cell    cell_id_list=${cell_id_list}    block_flag=${True}    bts_host=${gnb_ip}
    UE Start Traffic And Check Tp    ul_throughput=100    dl_throughput=300   ul_list=${ul_list}
    ...    dl_list=${dl_list}    ue_index=${0}    target_avg_percent=0.2    log_time=60s
    block or Unblock the Multiple cell    cell_id_list=${cell_id_list}    block_flag=${False}    bts_host=${gnb_ip}

block or Unblock the Multiple cell
    [Arguments]    ${cell_id_list}   ${block_flag}   ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM    ${timeout}=60
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    FOR  ${cell_id}  IN  @{cell_id_list}
        Run keyword if    ${block_flag}==${True}    Log To Console    Block Cell Start
        ...    ELSE    Log To Console    UnBlock Cell Start
        ${dist_name}    Set Variable    MRBTS-${BTS_ID}/NRBTS-${NRBTS}/NRCELL-${cell_id}
        Run keyword if    ${block_flag}==${True}    coam.block_cell    dist_name=${dist_name}    timeout=${timeout}    connection=${connection}
        ...    ELSE    coam.unblock_cell    dist_name=${dist_name}    timeout=${timeout}    connection=${connection}
    END
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

config 3 normalcell to 1supercell and attach to subcell1
    [Arguments]     ${ul_list}    ${dl_list}
    WEB Login
    Remove single NRCELL    cell_id=${cell_id_list_6CC}[5]    node_index=5
    Remove single NRCELL    cell_id=${cell_id_list_6CC}[4]    node_index=4
    Remove single NRCELL    cell_id=${cell_id_list_6CC}[3]    node_index=3
    selenium_sbts.set_parameter_value    dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/SMOD-1/BBCAP-1
    ...    filter_param=SMOD board configuration type   new_value=NRFDD_NRTDD   abbr=smodBoardConfigType
    selenium_sbts.remove_object
    ...    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1/NRREL-1
    configuration nomalcell to supercell    LCELNR_ID_1=${cell_id_list_6CC}[0]     LCELNR__COPY_ID_1=${cell_id_list_6CC[1:3]}
    ...    node_index_1=${2}    expect_cell_info=${supercell_for_1super3sub}

    @{lock_ru_id_list}    create list    ${2}    ${3}
    Lock or Unlock RU And Check Status    lock_RU_id_list=${lock_ru_id_list}   lock_flag=${True}    bts_host=${gnb_ip}   BTS_ID=37485
    UE Start Traffic And Check Tp    ul_throughput=100    dl_throughput=300   ul_list=${ul_list}
    ...    dl_list=${dl_list}    ue_index=${0}    target_avg_percent=0.2    log_time=60s
    Lock or Unlock RU And Check Status    unlock_RU_id_list=${lock_ru_id_list}   lock_flag=${False}    bts_host=${gnb_ip}   BTS_ID=37485

    [Teardown]    WEB Logout

config 1 supercell to 3 normalcell and attach to cell3
    [Arguments]    ${ul_list}    ${dl_list}    ${start_cell_id}=${2}    ${NRCELLGRP_id}=${1}    ${cell_id}=1
    WEB Login
    selenium_sbts.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=Activate super cell   new_value=false   abbr=actSuperCell
    selenium_sbts.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-${NRCELLGRP_id}
    ...    filter_param=Number of transmitted Synchronization Signal Blocks  new_value=1 beam   abbr=numberOfTransmittedSsBlocks
    Add and Copy nomcell    physCellId_list=${physCellId_list[1:3]}    add_object_cell_num=${2}    start_cell_id=${start_cell_id}
    ...    copy_cell_id=${1}    node_index_Diff=${1}
    Delete CHANNELGROUP    cell_id=${cell_id_list_6CC}[1]    CHANNELGROUP_id=1
    Delete CHANNELGROUP    cell_id=${cell_id_list_6CC}[1]    CHANNELGROUP_id=3
    Delete CHANNELGROUP    cell_id=${cell_id_list_6CC}[2]    CHANNELGROUP_id=1
    Delete CHANNELGROUP    cell_id=${cell_id_list_6CC}[2]    CHANNELGROUP_id=2
    Delete CHANNELGROUP    cell_id=${cell_id_list_6CC}[0]    CHANNELGROUP_id=2
    Delete CHANNELGROUP    cell_id=${cell_id_list_6CC}[0]    CHANNELGROUP_id=3
    ${error}    selenium_sbts.validate_plan    timeout=120
    Log To Console    ${error}
    selenium_sbts.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${180}
    Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}

    @{lock_ru_id_list}    create list    ${1}    ${2}
    Lock or Unlock RU And Check Status    lock_RU_id_list=${lock_ru_id_list}   lock_flag=${True}    bts_host=${gnb_ip}   BTS_ID=37485
    UE Start Traffic And Check Tp    ul_throughput=100    dl_throughput=300   ul_list=${ul_list}
    ...    dl_list=${dl_list}    ue_index=${0}    target_avg_percent=0.2    log_time=60s
    Lock or Unlock RU And Check Status    unlock_RU_id_list=${lock_ru_id_list}   lock_flag=${False}    bts_host=${gnb_ip}   BTS_ID=37485

    [Teardown]    WEB Logout

Add and Copy nomcell
    [Arguments]    ${physCellId_list}    ${add_object_cell_num}    ${start_cell_id}    ${node_index_Diff}=1    ${copy_cell_id}=1
    FOR    ${item}    IN RANGE    ${add_object_cell_num}
        ${cell_id}    Evaluate    ${item} + ${start_cell_id}
        ${node_index}     Evaluate    ${item}+${node_index_Diff}
        ${physCellId}    Evaluate    ${item}+1
        Wait Until Keyword Succeeds    3x    2min    selenium_sbts.add_object
        ...    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}   object_class_name=NRCELL
        ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${copy_cell_id}
        ...    include_subobject=${TRUE}    id_value=${cell_id}
        selenium_sbts.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ...    filter_param=Local cell resource ID   new_value=${cell_id}    abbr=lcrId
        selenium_sbts.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ...    filter_param=Physical cell identifier   new_value=${physCellId_list[${item}]}   abbr=physCellId
        Wait Until Keyword Succeeds    3x    2min    selenium_sbts.add_object
        ...    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}   object_class_name=NRCELLGRP
        ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-${copy_cell_id}
        ...    include_subobject=${TRUE}    id_value=${cell_id}
       selenium_sbts.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-${cell_id}
       ...    filter_param=List of NR cells assigned to cell group   node_index=${0}    new_value=${cell_id}    abbr=nrCellList
       selenium_sbts.add_element    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
       ...    filter_param=Reference to cell group    abbr=refNrCellGroup
       Wait Until Keyword Succeeds    3x    2min    selenium_sbts.set_parameter_value
       ...    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
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

remove 3 normalcell and attach to other cell
    WEB Login
    Remove single NRCELL    cell_id=${cell_id_list_6CC}[5]    node_index=5
    Remove single NRCELL    cell_id=${cell_id_list_6CC}[3]    node_index=3
    Remove single NRCELL    cell_id=${cell_id_list_6CC}[0]    node_index=0

    ${error}    selenium_sbts.validate_plan    timeout=120
    Log To Console    ${error}
    selenium_sbts.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${180}
    Check the GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}

    block cell and attach to single cell
    [Teardown]    WEB Logout

block cell and attach to single cell
#    @{cell_id_list1}    create list    ${0}    ${3}
#    block or Unblock the Multiple cell    cell_id_list=${cell_id_list1}    block_flag=${True}    bts_host=${gnb_ip}
#    UE Start Traffic And Check Tp    ul_throughput=100    dl_throughput=300   ul_list=${NR_cell_id_nrtdd_2}
#    ...    dl_list=${NR_cell_id_nrtdd_2}    ue_index=${0}    target_avg_percent=0.2    log_time=60s
#    block or Unblock the Multiple cell    cell_id_list=${cell_id_list1}    block_flag=${False}    bts_host=${gnb_ip}
#
#    @{cell_id_list2}    create list    ${0}    ${2}
#    block or Unblock the Multiple cell    cell_id_list=${cell_id_list2}    block_flag=${True}    bts_host=${gnb_ip}
#    UE Start Traffic And Check Tp    ul_throughput=100    dl_throughput=300   ul_list=${NR_cell_id_nrtdd_3}
#    ...    dl_list=${NR_cell_id_nrtdd_3}    ue_index=${0}    target_avg_percent=0.2    log_time=60s
#    block or Unblock the Multiple cell    cell_id_list=${cell_id_list2}    block_flag=${False}    bts_host=${gnb_ip}

    @{cell_id_list3}    create list    ${2}    ${3}
    block or Unblock the Multiple cell    cell_id_list=${cell_id_list3}    block_flag=${True}    bts_host=${gnb_ip}
    UE Start Traffic And Check Tp    ul_throughput=100    dl_throughput=300   ul_list=${NR_cell_id_nrtdd_0}
    ...    dl_list=${NR_cell_id_nrtdd_0}    ue_index=${0}    target_avg_percent=0.2    log_time=60s
    block or Unblock the Multiple cell    cell_id_list=${cell_id_list3}    block_flag=${False}    bts_host=${gnb_ip}

Add 3 normalcell and attach cell one by one
    [Arguments]    ${if_peak}=${False}
    WEB Login
    Add and Copy nomcell    physCellId_list=${physCellId_list[0:1]}    add_object_cell_num=${1}    start_cell_id=${1}
    ...    copy_cell_id=${2}    node_index_Diff=${3}
    Add and Copy nomcell    physCellId_list=${physCellId_list[3:4]}    add_object_cell_num=${1}    start_cell_id=${4}
    ...    copy_cell_id=${2}    node_index_Diff=${4}
    Add and Copy nomcell    physCellId_list=${physCellId_list[5:6]}    add_object_cell_num=${1}    start_cell_id=${5}
    ...    copy_cell_id=${2}    node_index_Diff=${5}
    SET RMOD CHANNEL 4T4R    GROUP_id=1    RMOD_id=1    LCELNR_id=1
    SET RMOD CHANNEL 4T4R    GROUP_id=1    RMOD_id=4    LCELNR_id=4
    SET RMOD CHANNEL 4T4R    GROUP_id=1    RMOD_id=6    LCELNR_id=5
    ${error}    selenium_sbts.validate_plan    timeout=120
    Log To Console    ${error}
    selenium_sbts.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${180}
    Check the GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}

    attach cell one by one    if_peak=${if_peak}

    [Teardown]    WEB Logout

attach cell one by one
    [Arguments]    ${if_peak}=${False}
    attach to cell4    if_peak=${if_peak}

#    @{cell_id_list2}    create list    ${1}    ${2}    ${3}    ${4}    ${5}
#    block or Unblock the Multiple cell    cell_id_list=${cell_id_list2}    block_flag=${True}    bts_host=${gnb_ip}
#    UE Start Traffic And Check Tp    ul_throughput=100    dl_throughput=300   ul_list=${NR_cell_id_nrtdd_0}
#    ...    dl_list=${NR_cell_id_nrtdd_0}    ue_index=${0}    target_avg_percent=0.2    log_time=60s
#    block or Unblock the Multiple cell    cell_id_list=${cell_id_list2}    block_flag=${False}    bts_host=${gnb_ip}
#
#    @{cell_id_list3}    create list    ${0}    ${2}    ${3}    ${4}    ${5}
#    block or Unblock the Multiple cell    cell_id_list=${cell_id_list3}    block_flag=${True}    bts_host=${gnb_ip}
#    UE Start Traffic And Check Tp    ul_throughput=100    dl_throughput=300   ul_list=${NR_cell_id_nrtdd_1}
#    ...    dl_list=${NR_cell_id_nrtdd_1}    ue_index=${0}    target_avg_percent=0.2    log_time=60s
#    block or Unblock the Multiple cell    cell_id_list=${cell_id_list3}    block_flag=${False}    bts_host=${gnb_ip}
#
#    @{cell_id_list4}    create list    ${0}    ${1}    ${3}    ${4}    ${5}
#    block or Unblock the Multiple cell    cell_id_list=${cell_id_list4}    block_flag=${True}    bts_host=${gnb_ip}
#    UE Start Traffic And Check Tp    ul_throughput=100    dl_throughput=300   ul_list=${NR_cell_id_nrtdd_2}
#    ...    dl_list=${NR_cell_id_nrtdd_2}    ue_index=${0}    target_avg_percent=0.2    log_time=60s
#    block or Unblock the Multiple cell    cell_id_list=${cell_id_list4}    block_flag=${False}    bts_host=${gnb_ip}
#
#    @{cell_id_list5}    create list    ${0}    ${1}    ${2}    ${4}    ${5}
#    block or Unblock the Multiple cell    cell_id_list=${cell_id_list5}    block_flag=${True}    bts_host=${gnb_ip}
#    UE Start Traffic And Check Tp    ul_throughput=100    dl_throughput=300   ul_list=${NR_cell_id_nrtdd_3}
#    ...    dl_list=${NR_cell_id_nrtdd_3}    ue_index=${0}    target_avg_percent=0.2    log_time=60s
#    block or Unblock the Multiple cell    cell_id_list=${cell_id_list5}    block_flag=${False}    bts_host=${gnb_ip}

    @{cell_id_list6}    create list    ${0}    ${1}    ${2}    ${3}    ${4}
    block or Unblock the Multiple cell    cell_id_list=${cell_id_list6}    block_flag=${True}    bts_host=${gnb_ip}
    UE Start Traffic And Check Tp    ul_throughput=100    dl_throughput=300   ul_list=${NR_cell_id_nrtdd_5}
    ...    dl_list=${NR_cell_id_nrtdd_5}    ue_index=${0}    target_avg_percent=0.2    log_time=60s
    block or Unblock the Multiple cell    cell_id_list=${cell_id_list6}    block_flag=${False}    bts_host=${gnb_ip}

All normal cell config to 60m and power reset site
    Modify Parameter And Check BTS Status    input_list=${para_chBw_1}
    Power Off or on    PB_IP=${PB_IP_GNB}    RU_PORT=${PB_PORT_GNB}    if_power_on=${False}
    sleep    10s
    Power Off or on    PB_IP=${PB_IP_GNB}    RU_PORT=${PB_PORT_GNB}    if_power_on=${True}
    Check the GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}

attach to cell4
    [Arguments]    ${if_peak}=${False}
    @{cell_id_list1}    create list    ${0}    ${1}    ${2}    ${3}    ${5}
    block or Unblock the Multiple cell    cell_id_list=${cell_id_list1}    block_flag=${True}    bts_host=${gnb_ip}
    ${dl_cell_list}    create list    4
    ${expect_ul_tp}    ${expect_dl_tp}    Get Theoretical TP From NRDIM_1    dl_cell_list=${dl_cell_list}
    UE Start Traffic And Check Tp    ul_throughput=100    dl_throughput=1500    ul_list=${NR_cell_id_nrtdd_4}
    ...    dl_list=${NR_cell_id_nrtdd_4}    ue_index=${0}    log_time=300s    if_peak=${if_peak}    expect_ul_tp=${expect_ul_tp}
    ...    expect_dl_tp=${expect_dl_tp}    ignore_time=60s    process_num=${10}
    block or Unblock the Multiple cell    cell_id_list=${cell_id_list1}    block_flag=${False}    bts_host=${gnb_ip}

config full 8 cell
    Modify Parameter And Check BTS Status    input_list=${para_chBw_2}
    Check the GNB on air
    WEB Login
    Wait Until Keyword Succeeds    3x    2min    selenium_sbts.remove_object
    ...    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1/NRREL-1
    Remove single NRCELL    cell_id=${cell_id_list_6CC}[4]    node_index=4
    Remove single NRCELL    cell_id=${cell_id_list_6CC}[2]    node_index=2
    SET NRCELL TO 2T2R    LCELNR_id=1    NRCELL_id=${cell_id_list_6CC}[0]
    SET NRCELL TO 2T2R    LCELNR_id=2    NRCELL_id=${cell_id_list_6CC}[1]
    SET NRCELL TO 2T2R    LCELNR_id=4    NRCELL_id=${cell_id_list_6CC}[3]
    SET NRCELL TO 2T2R    LCELNR_id=5    NRCELL_id=${cell_id_list_6CC}[5]

    Add and Copy nomcell    physCellId_list=${physCellId_list_8CC[4:8]}    add_object_cell_num=${4}    start_cell_id=${6}
    ...    copy_cell_id=${1}    node_index_Diff=${6}
    SET RMOD CHANNEL 2T2R    RMOD_id=1    LCELNR_id=6
    SET RMOD CHANNEL 2T2R    RMOD_id=2    LCELNR_id=7
    SET RMOD CHANNEL 2T2R    RMOD_id=4    LCELNR_id=8
    SET RMOD CHANNEL 2T2R    RMOD_id=6    LCELNR_id=9
    SET CELL NRARFCN    NRCELL_id=${cell_id_list_2T2R_8CC}[2]
    SET CELL NRARFCN    NRCELL_id=${cell_id_list_2T2R_8CC}[3]
    SET CELL NRARFCN    NRCELL_id=${cell_id_list_2T2R_8CC}[4]
    SET CELL NRARFCN    NRCELL_id=${cell_id_list_2T2R_8CC}[5]
    ${error}    selenium_sbts.validate_plan    timeout=120
    Log To Console    ${error}
    selenium_sbts.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${180}
    Check the GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}
    [Teardown]    WEB Logout

remove NRCELL channel
    [Arguments]    ${LCELNR_id}=1
    log to console    remove channel
    Wait Until Keyword Succeeds    3x    2min    selenium_sbts.remove_object
    ...    object_name=MRBTS-37485/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${LCELNR_id}/CHANNELGROUP-1/CHANNEL-5
    Wait Until Keyword Succeeds    3x    2min    selenium_sbts.remove_object
    ...    object_name=MRBTS-37485/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${LCELNR_id}/CHANNELGROUP-1/CHANNEL-6
    Wait Until Keyword Succeeds    3x    2min    selenium_sbts.remove_object
    ...    object_name=MRBTS-37485/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${LCELNR_id}/CHANNELGROUP-1/CHANNEL-7
    Wait Until Keyword Succeeds    3x    2min    selenium_sbts.remove_object
    ...    object_name=MRBTS-37485/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${LCELNR_id}/CHANNELGROUP-1/CHANNEL-8

SET RMOD CHANNEL 2T2R
    [Arguments]    ${channelGROUP_id}=1    ${RMOD_id}=6    ${LCELNR_id}=1    ${ANTL1}=1    ${ANTL2}=2
    Log To Console    SET RMOD CHANNEL 2T2R
    selenium_sbts.set_parameter_value
    ...    dist_name=MRBTS-37485/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${LCELNR_id}/CHANNELGROUP-${channelGROUP_id}/CHANNEL-1
    ...    filter_param=Distinguished Name of antenna line    new_value=MRBTS-37485/EQM-1/APEQM-1/RMOD-${RMOD_id}/ANTL-${ANTL1}    abbr=antlDN
    selenium_sbts.set_parameter_value
    ...    dist_name=MRBTS-37485/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${LCELNR_id}/CHANNELGROUP-${channelGROUP_id}/CHANNEL-2
    ...    filter_param=Distinguished Name of antenna line    new_value=MRBTS-37485/EQM-1/APEQM-1/RMOD-${RMOD_id}/ANTL-${ANTL1}    abbr=antlDN
    selenium_sbts.set_parameter_value
    ...    dist_name=MRBTS-37485/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${LCELNR_id}/CHANNELGROUP-${channelGROUP_id}/CHANNEL-3
    ...    filter_param=Distinguished Name of antenna line    new_value=MRBTS-37485/EQM-1/APEQM-1/RMOD-${RMOD_id}/ANTL-${ANTL2}    abbr=antlDN
    selenium_sbts.set_parameter_value
    ...    dist_name=MRBTS-37485/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${LCELNR_id}/CHANNELGROUP-${channelGROUP_id}/CHANNEL-4
    ...    filter_param=Distinguished Name of antenna line    new_value=MRBTS-37485/EQM-1/APEQM-1/RMOD-${RMOD_id}/ANTL-${ANTL2}    abbr=antlDN
    Log To Console    SET RMOD CHANNEL successful

SET NRCELL TO 2T2R
    [Arguments]    ${LCELNR_id}=1    ${NRCELL_id}=1
    log to console    SET NRCELL TO 2T2R
    remove NRCELL channel    LCELNR_id=${LCELNR_id}
    Wait Until Keyword Succeeds    3x    2min    selenium_sbts.set_parameter_value
    ...    dist_name=MRBTS-37485/NRBTS-37485/NRCELL-${NRCELL_id}    filter_param=NR Cell type    new_value=2DL2UL    abbr=nrCellType
    selenium_sbts.set_parameter_value
    ...    dist_name=MRBTS-37485/NRBTS-37485/NRCELL-${NRCELL_id}    filter_param=Downlink MIMO Mode
    ...    new_value=2x2 Closed Loop Spatial Multiplexing    abbr=dlMimoMode
    selenium_sbts.set_parameter_value
    ...    dist_name=MRBTS-37485/NRBTS-37485/NRCELL-${NRCELL_id}
    ...    filter_param=Activate multiple CSI-RS resources multiplexing in slot    new_value=false    abbr=actCsirsMultiplexing
    selenium_sbts.set_parameter_value
    ...    dist_name=MRBTS-37485/NRBTS-37485/NRCELL-${NRCELL_id}
    ...    filter_param=Activate downlink low PAPR optimized precoding    new_value=false    abbr=actDlLowPAPRoptimizedPrecoding

SET CELL NRARFCN
    [Arguments]    ${NRCELL_id}=1    ${new_value}=524820
    log to console    set nrarfcn
    selenium_sbts.set_parameter_value
    ...    dist_name=MRBTS-37485/NRBTS-37485/NRCELL-${NRCELL_id}    filter_param=NR Absolute radio frequency channel number
    ...    new_value=${new_value}    abbr=nrarfcn

block cell and attach
    [Arguments]    ${attach_cell_id}    ${attach_list}    ${block_cell_list}
    block or Unblock the Multiple cell    cell_id_list=${block_cell_list}    block_flag=${True}    bts_host=${gnb_ip}
    @{cell_id_list}    create list    ${attach_cell_id}
    block or Unblock the Multiple cell    cell_id_list=${cell_id_list}    block_flag=${False}    bts_host=${gnb_ip}
    UE Start Traffic And Check Tp    ul_throughput=40    dl_throughput=40  ul_list=${attach_list}
    ...    dl_list=${attach_list}    ue_index=${0}    target_avg_percent=0.2    log_time=60s
    block or Unblock the Multiple cell    cell_id_list=${cell_id_list}    block_flag=${True}    bts_host=${gnb_ip}
    block or Unblock the Multiple cell    cell_id_list=${block_cell_list}    block_flag=${False}    bts_host=${gnb_ip}

A_05_config full 8 cell
    Modify Parameter And Check BTS Status    input_list=${para_chBw_2}
    Check the GNB on air
    WEB Login
    Wait Until Keyword Succeeds    3x    2min    selenium_sbts.remove_object
    ...    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1/NRREL-1
    Remove single NRCELL    cell_id=${cell_id_list_6CC}[5]    node_index=5
    Remove single NRCELL    cell_id=${cell_id_list_6CC}[4]    node_index=4
    Remove single NRCELL    cell_id=${cell_id_list_6CC}[3]    node_index=3
    Remove single NRCELL    cell_id=${cell_id_list_6CC}[1]    node_index=1
    SET NRCELL TO 2T2R    LCELNR_id=1    NRCELL_id=${cell_id_list_6CC}[0]
    SET NRCELL TO 2T2R    LCELNR_id=3    NRCELL_id=${cell_id_list_6CC}[2]

    Add and Copy nomcell    physCellId_list=${physCellId_list_8CC[4:10]}    add_object_cell_num=${6}    start_cell_id=${6}
    ...    copy_cell_id=${1}    node_index_Diff=${6}
    SET RMOD CHANNEL 2T2R    RMOD_id=1    LCELNR_id=6    ANTL1=1    ANTL2=2
    SET RMOD CHANNEL 2T2R    RMOD_id=1    LCELNR_id=7    ANTL1=3    ANTL2=4
    SET RMOD CHANNEL 2T2R    RMOD_id=1    LCELNR_id=8    ANTL1=3    ANTL2=4
    SET RMOD CHANNEL 2T2R    RMOD_id=3    LCELNR_id=9    ANTL1=1    ANTL2=2
    SET RMOD CHANNEL 2T2R    RMOD_id=3    LCELNR_id=10    ANTL1=3    ANTL2=4
    SET RMOD CHANNEL 2T2R    RMOD_id=3    LCELNR_id=11    ANTL1=3    ANTL2=4

    SET CELL NRARFCN    NRCELL_id=${cell_id_list_2T2R_8CC}[2]    new_value=524820
    SET CELL NRARFCN    NRCELL_id=${cell_id_list_2T2R_8CC}[3]    new_value=510000
    SET CELL NRARFCN    NRCELL_id=${cell_id_list_2T2R_8CC}[4]    new_value=524820
    SET CELL NRARFCN    NRCELL_id=${cell_id_list_2T2R_8CC}[5]    new_value=524820
    SET CELL NRARFCN    NRCELL_id=${cell_id_list_2T2R_8CC}[6]    new_value=510000
    SET CELL NRARFCN    NRCELL_id=${cell_id_list_2T2R_8CC}[7]    new_value=524820
    ${error}    selenium_sbts.validate_plan    timeout=120
    Log To Console    ${error}
    selenium_sbts.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${180}
    Check the GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}
    [Teardown]    WEB Logout

block all cell and unblock
    @{cell_id_list}    create list    ${1}    ${2}    ${3}    ${4}
    block or Unblock the Multiple cell    cell_id_list=${cell_id_list}    block_flag=${True}    bts_host=${gnb_ip}
    sleep    5s
    block or Unblock the Multiple cell    cell_id_list=${cell_id_list}    block_flag=${False}    bts_host=${gnb_ip}
    sleep    5s
    block or Unblock the Multiple cell    cell_id_list=${cell_id_list}    block_flag=${True}    bts_host=${gnb_ip}
    sleep    5s
    block or Unblock the Multiple cell    cell_id_list=${cell_id_list}    block_flag=${False}    bts_host=${gnb_ip}

Config 6subcell to 2supercell
    WEB Login
    selenium_sbts.remove_object
    ...    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1/NRREL-1
#    @{cell_id_list_6CC}           1    2    3    4    0    5
    @{LCELNR__COPY_ID_1}    create list    ${3}    ${2}
    @{LCELNR__COPY_ID_2}    create list    ${5}    ${0}
    configuration nomalcell to supercell    LCELNR_ID_1=${cell_id_list_6CC}[0]     LCELNR__COPY_ID_1=${LCELNR__COPY_ID_1}
    ...    LCELNR_ID_2=${cell_id_list_6CC}[3]    LCELNR__COPY_ID_2=${LCELNR__COPY_ID_2}    if_supercell_2=${True}
    ...    node_index_1=${2}    node_index_2=${5}    expect_cell_info=${supercell_for_E2E_2super3sub}
    [Teardown]    WEB Logout

Remove 2NRCELL and config 4NRCELL to 2T2R
    WEB Login
    selenium_sbts.remove_object
    ...    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1/NRREL-1
    Remove single NRCELL    cell_id=${cell_id_list_6CC}[5]    node_index=5
    Remove single NRCELL    cell_id=${cell_id_list_6CC}[4]    node_index=4
    SET NRCELL TO 2T2R    LCELNR_id=1    NRCELL_id=${cell_id_list_6CC}[0]
    SET NRCELL TO 2T2R    LCELNR_id=2    NRCELL_id=${cell_id_list_6CC}[1]
    SET NRCELL TO 2T2R    LCELNR_id=3    NRCELL_id=${cell_id_list_6CC}[2]
    SET NRCELL TO 2T2R    LCELNR_id=4    NRCELL_id=${cell_id_list_6CC}[3]
    ${error}    selenium_sbts.validate_plan    timeout=120
    Log To Console    ${error}
    selenium_sbts.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${180}
    Check the GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}
    [Teardown]    WEB Logout

Kill firefox
    [Arguments]    ${connection}=ute
    csn.connect_to   hostname=${TEST_PC_IP}
    ...        username=${TEST_PC_USERNAME}    password=${TEST_PC_PASSWORD}    alias=${connection}
    sleep    1s
    csn.send_command
    ...    command=ps -ef |grep -v grep|grep firefox|grep socket|head -1|tail -n 1|awk '{print $3}'    connection=${connection}
    ${process}    csn.Read Output    connection=${connection}
    ${process}    strip_string    ${process}
    csn.send_command    command=kill ${process}    connection=${connection}
    Should Be Empty    ${process}

    [Teardown]       csn.Disconnect  	connection=${connection}
