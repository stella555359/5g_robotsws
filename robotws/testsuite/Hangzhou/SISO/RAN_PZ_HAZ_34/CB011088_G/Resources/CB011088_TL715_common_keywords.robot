*** Settings ***
Documentation
...    author: xiaofeng Zhu
...    contact: xiaofeng.1.zhu@nokia-sbell.com
...    squad group: MMW_SG_04
...    feature : CB011088


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
Library     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001937_OTA/resources/samsung_sigspark.py
Library     samsung_sigspark.SigSpark    WITH NAME    samsung_spark

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
${att_ipaddr}                 ${tl.attenuator.ip_addr}
${att_api_port}               ${tl.attenuator.port}
${att_connection_port}        ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${gNB_ssh_name}               ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${gNB_ssh_pass}               ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
#@{RU_unlock_status}           Unlocked    enabled    Active    configured
#@{RU_lock_status}             Locked    enabled    Idle    configured
@{Cell_unblock_status}        unlocked    enabled    unblocked
@{Cell_block_status}          unlocked    disabled    blocked

@{NR_cell_id_list_nrtdd_0}      599760
@{NR_cell_id_list_nrtdd_1}      599761
@{NR_cell_id_list_nrtdd_2}      599762
@{NR_cell_id_list_nrtdd_3}      599763
@{NR_cell_id_list_nrtdd_4}      599764
@{NR_cell_id_list_nrtdd_5}      599765

@{NR_cell_id_list_CA_NRTDD}      599761    	599764

@{LTE_cell_list_block}        ${1}    ${5}    ${9}
@{NR_cell_list_block}         ${1}    ${2}
${BTS_ID}                     ${tl.gnbs[0].instance_id}
${NRBTS_ID}                   ${tl.gnbs[0].instance_id}
${LNBTS}                      ${tl.enbs[0].global_bts_id}
${NRBTS}                      ${tl.gnbs[0].global_bts_id}
@{PA_port_list}               ${0}    ${1}    ${2}    ${3}    ${4}
@{LTE_row_list}               LTE PDCP Thr. DL [Mbps]    LTE PDCP Thr. UL [Mbps]
@{empty_list}
@{RU_unlock_status}           Unlocked    enabled    Active    configured
@{RU_lock_status}             Locked    enabled    Idle    configured
@{cell_id_list_6CC}           1    2    3    4    0    5


*** Keywords ***
########### setup and teardown KW #################
CB011088 Suite Setup
    CI_interface.Common Suite Setup
    robot_common_operations.Common Suite Setup
    Adapt to ute cloud commission scf
#    Check GNB on air and Check Alarm List on BTS

Check GNB on air and Check Alarm List on BTS
    [Arguments]       ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    Check the GNB on air_debug
    Check Alarm List on BTS    allowed_list=${allowed_list}    bts_host=${bts_host}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Case Teardown
    [Arguments]    ${bts_host}=${gnb_ip}    ${if_activate_scf}=${False}
    log to console    ${TEST_STATUS} recover action...
    Run Keyword if    "${TEST_STATUS}"=="FAIL"    Save the Snapshot
    run keyword if    ${if_activate_scf}    Setup the Commission SCF    bts_host=${bts_host}
    AlarmWatchdog.remove_allow_alarms    fault_id=49
    Check GNB on air and Check Alarm List on BTS
    robot_common_operations.Common case Teardown
    CI_interface.Common Case Teardown

Case Setup
    robot_common_operations.Common case Setup
    Adapt to ute cloud commission scf
    AlarmWatchdog.add_allow_alarms    fault_id=49
    Check GNB on air and Check Alarm List on BTS
    Wait Until Keyword Succeeds    1min    5s    Kill firefox

Case8 Teardown
    Modify Parameter And Check BTS Status    input_list=${gnb_para2}    bts_host=${gnb_ip}
    Case Teardown

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
Adjust the HBTE attenuation value
    [Arguments]      ${value_list}    ${port_list}
    attenuator.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${127}    vendor=HBTE
    ${port_num}    Get Length   ${port_list}
    @{port_list1}    Create List
    FOR    ${port}    IN    @{port_list}
        ${tmp}    Evaluate    ${port}+1
        Append to list  ${port_list1}  ${tmp}
    END
    FOR    ${i}    IN RANGE    ${port_num}
        attenuator.set_attenuation     port=${tl.gnbs[0].dus[0].rus[0].attenuation_ports[${port_list[${i}]}].port_no}    value=${value_list}[${i}]
        ${value_port}    attenuator.read_attenuation    port=${port_list1}[${i}]
        should be equal    ${value_port}    ${value_list}[${i}]
    END
    sleep  10s

#Adjust Single RU PA
#    [Arguments]    ${port}
#    ${port_list}    create list     ${0}    ${1}    ${2}    ${3}
#    ${value_list}    create list
#    FOR    ${item}    IN RANGE    ${4}
#        Run keyword if    ${item} != ${port}    APPEND TO LIST  ${value_list}    ${0}
#        ...    ELSE    APPEND TO LIST  ${value_list}    ${127}
#    END
#    Log To Console    ${port_list}
#    Log To Console    ${value_list}
#    Adjust the HBTE attenuation value    value_list=${value_list}    port_list=${port_list}
#    sleep  1min

################ Relate To UE ###################
Prepare UE and Attach UE by spark
    [Arguments]  ${ue_index}    ${attach_mode}=5G_NSA
    samsung_spark.require_ue    ue_alias=UE_${ue_index}    index=${ue_index}    reset_sol=${None}
    ${5Grach_ed}    samsung_spark.attach_ue    ue_alias=UE_${ue_index}   attach_mode=${attach_mode}     power_reset=False    timeout=90000
    log to console    UE_${ue_index}
    log to console    ${5Grach_ed}
    [Return]  ${5Grach_ed}

UE attach by Spark
    [Timeout]  6min
    [Arguments]  ${ue_index}    ${ue_type}=huawei_sigspark    ${attach_mode}=5G_NSA
    ${5Grach_ed}    wait until keyword succeeds    2X    2min    Prepare UE and Attach UE by spark    ue_index=${ue_index}
    ...    attach_mode=${attach_mode}
    Run keyword if    '${attach_mode}' == '5G_NSA'
    ...    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    ue_index=${ue_index}    4G_check=False
    ...    ELSE    Verify 4G Attach by ADB Command    ue_index=${ue_index}
    Log To Console    Attach UE_${ue_index} success

UE detach by Spark
    [Arguments]  ${ue_index_list}
    FOR    ${ue_index}    IN    @{ue_index_list}
        Run Keyword And Ignore error    samsung_spark.detach_ue    ue_alias=UE_${ue_index}
    END

Spark Start UE Log
    [Documentation]    Author:jiang.hongyu@nokia-sbell.com
    [Arguments]    ${ue_index}
    ${ue_alias}    set variable    UE_${ue_index}
    samsung_spark.start_log    ue_alias=${ue_alias}

Spark Stop UE Log
    [Documentation]    Author:jiang.hongyu@nokia-sbell.com
    [Arguments]    ${ue_index}    ${log_name}=uelog_sigspark_UE${ue_index}
    Create Directory     ${output_dir}/${TEST_NAME}
    ${log_path}    set variable    ${output_dir}/${TEST_NAME}/${log_name}
    ${ue_alias}    set variable    UE_${ue_index}
    samsung_spark.stop_log    ue_alias=${ue_alias}    logname=${log_path}.xml   filter=test
    [Return]  ${log_path}.csv

attach the power ue
    [Arguments]    ${ue_index_list}   ${gnb_index}=${0}
    log to console       Prepare UE
    FOR    ${ue_index}   IN    @{ue_index_list}
        power_ue.Prepare UE    ue_index=${ue_index}    ue_type=samsung    ui_version=S10UI2.1
        ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    attach_mode=5G_SA   ue_type=samsung
        power_ue.Verify attach    ue_type=samsung   5Grach_ed=${5Grach_ed_0}    4G_check=False    gnb_index=${gnb_index}
    END

Set UE related variable
    Set Suite Variable    ${home}    3
    Set Suite Variable    ${airplane}    970 380
    Set Suite Variable    ${close_task}    535 1755
    Set Suite Variable    ${Home_button}    3
    Set Suite Variable    ${swipe}    500 2050 500 800
    Set Suite Variable    ${open_iperf_location}    480 860
    Set Suite Variable    ${iperf_button}    720 312
    Set Suite Variable    ${iperf_space}    800 550

start the power ue traffic ul and dl
    [Arguments]    ${ue_index_list}    ${ul_duration}=6000    ${dl_duration}=6000
    ...    ${if_ul}=${True}    ${if_dl}=${True}    ${process_num}=${2}
    log to console      Start traffic    console=yes
    FOR    ${item}    IN    @{ue_index_list}
#        run keyword and continue on failure    run keyword if    ${if_ul}    power_ue.Start traffic    ue_index=${item}    direction=ul
#        ...    throughput=${ul_throughput}    duration=${ul_duration}
#        ...    iperf_port=@{ul_power_port_list}[${item}]    process_num=${process_num}    iperf_type=via_command
        run keyword and continue on failure    run keyword if    ${if_Ul}    172 IP UE Start UL traffic TCP    ue_index=${item}
        ...    time=${Ul_duration}
        ...    UL_port=${Ul_power_port_list}[${item}]    process_num=${process_num}
        sleep    1s
#        run keyword and continue on failure    run keyword if    ${if_dl}    power_ue.Start traffic    ue_index=${item}    direction=dl
#        ...    throughput=${dl_throughput}    duration=${dl_duration}
#        ...    iperf_port=@{dl_power_port_list}[${item}]    process_num=${process_num}
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

Xiaomi12 click airplane tiwce
    [Arguments]  ${ue_index}    ${serial_number}    ${connection}=cygwin
    FOR    ${item}   IN RANGE   ${2}
        unlock the screen and click airplane    ue_index=${ue_index}   serial_number=${serial_number}   connection=${connection}
    END

Xiaomi12 Verify Airplane Status
    [Arguments]    ${serial_number}    ${connection}=cygwin
    ssh.send_command    command=adb -s ${serial_number} shell settings get global airplane_mode_on   connection=${connection}
    sleep   2s
    ${airplane_status}    ssh.Read Output    connection=${connection}
    @{airmode_status}    Split String    ${airplane_status}    \r\n
    ${status}    Set Variable If    '${airmode_status[0]}'=='0'    ${False}    ${True}
    [Return]  ${status}

unlock the screen and click airplane
    [Documentation]   Check UE if need awake
    [Arguments]   ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}   ${connection}=cygwin
    Get all xiaomi12 pointer variable
    ssh.send_command   connection=${connection}
    ...   command=adb -s ${serial_number} shell dumpsys window | grep -E \"mAwake|isStatusBarKeyguard|mShowingLockscreen\"
    sleep   2s
    ${output}   ssh.read_output   connection=${connection}
    Run Keyword If   ${output.lower().count('mawake=false')}>0
    ...   ssh.send_command   command=adb -s ${serial_number} shell input keyevent 26   connection=${connection}
    ssh.send_command   command=adb -s ${serial_number} shell input swipe 347 2514 715 400    connection=${connection}
    sleep    2s
    ssh.send_command   command=adb -s ${serial_number} shell am start -a android.settings.AIRPLANE_MODE_SETTINGS    connection=${connection}
    sleep    2s
    ssh.send_command   command=adb -s ${serial_number} shell dumpsys window | grep FocusedWindow    connection=${connection}
    sleep    2s
    ssh.send_command   command=adb -s ${serial_number} shell input tap ${airplane}    connection=${connection}
    sleep    2s
    ssh.send_command    command=adb -s ${serial_number} shell input keyevent ${Home_button}    connection=${connection}
    sleep   2s
    ssh.send_command    command=adb -s ${serial_number} shell input keyevent 187    connection=${connection}
    sleep   4s
    ssh.send_command    command=adb -s ${serial_number} shell input tap ${close_task}    connection=${connection}

Get all xiaomi12 pointer variable
    Set Suite Variable    ${Home_button}    3
    Set Suite Variable    ${airplane}    932 1633
    Set Suite Variable    ${close_task}   717 2920
    Set Suite Variable    ${swipe}    1300 2700 1300 2700
    Set Suite Variable    ${open_iperf_location}    500 2050
    Set Suite Variable    ${iperf_button}    730 300
    Set Suite Variable    ${iperf_space}    800 550
    Set Suite Variable    ${5G}    900 960
    Set Suite Variable    ${ue_type}    xiaomi
    Set Suite Variable    ${brand}    Xiaomi

Xiaomi12 Attach UE
    [Arguments]  ${ue_index}     ${serial_number}    ${connection}=cygwin
    Get all xiaomi12 pointer variable
    ${status}    Xiaomi12 Verify Airplane Status    serial_number=${serial_number}    connection=${connection}
    Run Keyword If    ${status}    unlock the screen and click airplane    ue_index=${ue_index}   serial_number=${serial_number}
    ...    connection=${connection}
    Run Keyword If    ${status}==${False}    Xiaomi12 click airplane tiwce    ue_index=${ue_index}   serial_number=${serial_number}
    ...    connection=${connection}

Xiaomi12 Attach And Verify attach
    [Arguments]  ${ue_index}    ${connection}=cygwin
    ssh.Connect to    hostname=${control_pc}    username=${control_pc_name}    password=${control_pc_pass}    alias=${connection}
    Xiaomi12 Attach UE    ue_index=${ue_index}     serial_number=${tl.ues[${ue_index}].serial_number}    connection=${connection}
    [Teardown]  Run Keyword And Ignore Error    ssh.Disconnect    connection=${connection}

Xiaomi12 UE Detach
    [Arguments]  ${ue_index}    ${connection}=cygwin
    ssh.Connect to    hostname=${control_pc}    username=${control_pc_name}    password=${control_pc_pass}    alias=${connection}
    unlock the screen and click airplane    ue_index=${ue_index}   serial_number=${tl.ues[${ue_index}].serial_number}  connection=${connection}
    [Teardown]  Run Keyword And Ignore Error    ssh.Disconnect    connection=${connection}

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

WEBUI Login
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

WEBUI Logout
    [Arguments]     ${virtual_disable}=${True}
    [Documentation]   WEBUI Logout
    Log To Console  Try to logout...
    Run Keyword If      ${virtual_disable}    Run Keyword And Ignore Error    selenium_sbts.Enable_Virtual_Display
    Run Keyword And Ignore Error  selenium_sbts.Logout
    Log To Console  Logout successfully...
    Run Keyword If      ${virtual_disable}    Run Keyword And Ignore Error    selenium_sbts.Disable_Virtual_Display
    Sleep    3s
    Log To Console  END:WEBUI Logout!

Delete Nrcells Data
    [Arguments]  ${cell_id_list}    ${node_index}
    Log To Console    delete nrcell
    FOR   ${cell_id}    IN    @{cell_id_list}
        selenium_sbts.remove_object
        ...    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        selenium_sbts.remove_object
        ...    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-${cell_id}
        selenium_sbts.remove_object
        ...    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}
        selenium_sbts.remove_element
        ...   dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
        ...    filter_param=Reference to cell group    node_index=${node_index}    abbr=refNrCellGroup
        ${node_index}    Evaluate    ${node_index} - 1
    END

Delete NrcellGrp Data
    [Arguments]  ${cell_id_list}    ${nrcellgrp_id}    ${node_index}
    Log To Console    delete nrcell group
    ${length}    Get Length    ${cell_id_list}
    FOR   ${item}    IN RANGE   ${length}
        selenium_sbts.remove_object
        ...    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS}/NRCELL-${cell_id_list}[${item}]
        Wait Until Keyword Succeeds    3x    1min    selenium_sbts.remove_object
        ...    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id_list}[${item}]
    END
    selenium_sbts.remove_object
    ...    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS}/NRCELLGRP-${nrcellgrp_id}
    selenium_sbts.remove_element
    ...    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS}/NRDU-1
    ...    filter_param=Reference to cell group    node_index=${node_index}    abbr=refNrCellGroup

Copy Cell info From SCF
    [Arguments]  ${copy_cell_id_list}    ${keep_cell_id}
    Adapt to ute cloud commission scf
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
    [Arguments]  ${ul_list}    ${dl_list}      ${ul_tp}=${100}    ${dl_tp}=${1500}    ${if_ul}=${True}    ${if_dl}=${True}
    ...    ${target_avg_percent}=0.95    ${min_percent}=0    ${ue_type}=samsung   ${log_time}=60s    ${ignore_time}=10s
    ${log_path}    power_ue.Collect Tput   ue_type=${ue_type}    duration=${log_time}    ignore_time=${ignore_time}
    run keyword and continue on failure    run keyword if    ${if_ul}==${True}    power_ue.Check Tput    ue_type=${ue_type}
    ...    direction=UL    log=${log_path}    cells=${ul_list}    target_throughput=${ul_tp}    target_avg_percent=${target_avg_percent}
    ...    actCarrierAggregation=${True}    min_percent=${min_percent}
    run keyword and continue on failure    run keyword if    ${if_dl}==${True}    power_ue.Check Tput    ue_type=${ue_type}
    ...    direction=DL    log=${log_path}    cells=${dl_list}    target_throughput=${dl_tp}    target_avg_percent=${target_avg_percent}
    ...    actCarrierAggregation=${True}    min_percent=${min_percent}

UE Start Traffic And Check Tp
    [Arguments]    ${ul_throughput}    ${dl_throughput}    ${ul_list}    ${dl_list}    ${ue_index}    ${protocol}=tcp
    ...    ${if_ul}=${True}    ${if_dl}=${True}    ${target_avg_percent}=0.2    ${min_percent}=0    ${log_time}=60s
    ...    ${pcap_name}=gNB1_attach.pcap    ${VONR_CALL}=${False}
    ...    ${target_avg_percent_peak}=0.98    ${min_percent_peak}=0.85    ${if_peak}=${False}
    ...    ${expect_ul_tp}=0    ${expect_dl_tp}=0    ${ignore_time}=20s    ${process_num}=3
#    Start Catch Trace Log    DU_OAM_IP=${gnb_ip}    connection=gNB1    filename=${pcap_name}
    @{ue_index_list}    create list    ${ue_index}
    attach the power ue    ue_index_list=${ue_index_list}
    sleep    5s
#    Stop And Copy Log To UTE    DU_OAM_IP=${gnb_ip}    connection=gNB1    filename=${pcap_name}
#    ${filter}=    CATENATE    f1ap
#    Convert pcap to the text     source=${LOG_PATH}/${pcap_name}    target=${LOG_PATH}/${text_name}    filter=${filter}
#    Check Attach PCI    text_name=${text_name}
#    run keyword if    ${if_CA}==${True}    Check Attach PCI    text_name=${text_name}

#    sleep    5s
    start the power ue traffic ul and dl    ue_index_list=${ue_index_list}
    ...    if_ul=${if_ul}    if_dl=${if_dl}    process_num=${process_num}

    run keyword if    ${if_peak}==${False}    Check Throught From Asslog   ul_list=${ul_list}    dl_list=${dl_list}     ul_tp=${ul_throughput}
    ...    dl_tp=${dl_throughput}    if_ul=${if_ul}    if_dl=${if_dl}   target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    log_time=${log_time}

#    run keyword if    ${if_peak}==${True}     sleep    5min
    run keyword if    ${if_peak}==${True}    Check Throught From Asslog   ul_list=${ul_list}    dl_list=${dl_list}     ul_tp=${expect_ul_tp}
    ...    dl_tp=${expect_dl_tp}    if_ul=${if_ul}    if_dl=${if_dl}   target_avg_percent=${target_avg_percent_peak}
    ...    min_percent=${min_percent_peak}    log_time=${log_time}    ignore_time=${ignore_time}
    run keyword if    ${VONR_CALL}==${True}    VNOR call

    stop the power ue traffic ul and dl    ue_index_list=${ue_index_list}    if_ul=${if_ul}    if_dl=${if_dl}    protocol=${protocol}
    [Teardown]    Stop log and detach    ue_index_list=${ue_index_list}    gnb_ip=${gnb_ip}    pcap_name=${pcap_name}

Stop log and detach
    [Arguments]    ${ue_index_list}=${ue_index_list}    ${gnb_ip}=${gnb_ip}    ${pcap_name}=${pcap_name}
    Run keyword and ignore error    Stop And Copy Log To UTE    DU_OAM_IP=${gnb_ip}    connection=gNB1    filename=${pcap_name}
    detach the power ue    ue_index_list=${ue_index_list}

Block And Unblock All Cell
    Block or UnBlock Multiple Cell    lte_cell_id_list=${LTE_cell_list_block}    nr_cell_list=${NR_cell_list_block}    block_flag=${True}
    Check All LTE And NR cell Status    expect_cell_status=${Cell_block_status}
    Block or UnBlock Multiple Cell    lte_cell_id_list=${LTE_cell_list_block}    nr_cell_list=${NR_cell_list_block}    block_flag=${False}
    Check All LTE And NR cell Status    expect_cell_status=${Cell_unblock_status}
    Check GNB on air and Check Alarm List on BTS

Modify Parameter And Check BTS Status
    [Arguments]  ${input_list}
    Modify Parameters with json    input_list=${input_list}

Lock or Unlock RU And Check Status
    [Arguments]  ${BTS_ID}   ${lock_RU_id_list}=${empty_list}     ${unlock_RU_id_list}=${empty_list}    ${lock_flag}=${True}   ${bts_host}=${gnb_ip}
    ${operate_ru_id_list}    Set Variable If    ${lock_flag}    ${lock_RU_id_list}    ${unlock_RU_id_list}
    Lock or UnLock Multiple RU    RMOD_id_list=${operate_ru_id_list}    lock_flag=${lock_flag}    bts_host=${bts_host}    BTS_ID=${BTS_ID}
#    ${expect_item_status_dict}    create dictionary
#    FOR  ${item}  IN    @{lock_RU_id_list}
#        Set to dictionary    ${expect_item_status_dict}    RMOD-${item}=${RU_lock_status}
#    END
#    FOR  ${item1}  IN   @{unlock_RU_id_list}
#        Set to dictionary    ${expect_item_status_dict}    RMOD-${item1}=${RU_unlock_status}
#    END
#    Check All RU or Cell Status    expect_item_status_dict=${expect_item_status_dict}    if_ru=${True}    bts_host=${bts_host}

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
    ...    ${if_supercell_3}=${False}   ${node_index_1}=${1}    ${node_index_2}=${3}    ${node_index_3}=${5}
    ...    ${start_id_1}=${2}    ${start_id_2}=${2}    ${start_id_3}=${2}
    WEBUI Login
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
    [Teardown]    WEBUI Logout

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

configuration 2 supercell CA
    [Arguments]   ${gnb_para}
    Modify Parameter And Check BTS Status    input_list=${gnb_para}
    Check the GNB on air    bts_host=${gnb_ip}
    Check Alarm List on BTS    allowed_list=${allowed_list}    bts_host=${gnb_ip}

172 IP UE Start DL traffic TCP
    [Arguments]    ${DL_port}    ${ue_index}=${2}    ${time}=6000   ${process_num}=${1}
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
    ssh.send_command   command=ps -ef|grep iperf3    connection=EPCAPP
    ${iperf_process}    ssh.read_output    connection=EPCAPP
    log to console    iperf process: ${iperf_process}
    ssh.disconnect    connection=EPCAPP
    [Teardown]  ssh.disconnect    connection=${connection}

172 IP UE Start UL traffic TCP
    [Arguments]    ${UL_port}    ${ue_index}=${2}    ${time}=6000   ${process_num}=${1}
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
    ssh.send_command   command=ps -ef|grep iperf3    connection=EPCAPP
    ${iperf_process}    ssh.read_output    connection=EPCAPP
    log to console    iperf process: ${iperf_process}
    ssh.disconnect    connection=EPCAPP
    [Teardown]  ssh.disconnect    connection=${connection}

Start Catch Trace Log
    [Arguments]    ${DU_OAM_IP}    ${connection}    ${filename}   ${time}=3s
    ...    ${DU_OAM_SSH_USERNAME}=${gNB_ssh_name}    ${DU_OAM_SSH_PASSWORD}=${gNB_ssh_pass}
    Log To Console    Start Catch Trace Log
    ssh.Connect to    hostname=${DU_OAM_IP}    username=${DU_OAM_SSH_USERNAME}   password=${DU_OAM_SSH_PASSWORD}    alias=${connection}
    sleep    2s
    ssh.send_command    command=tcpdump sctp -i any -w /tmp/${filename} &   connection=${connection}
    sleep    ${time}

Stop And Copy Log To UTE
    [Arguments]    ${DU_OAM_IP}    ${connection}    ${filename}    ${time}=10s
    ...    ${DU_OAM_SSH_USERNAME}=${gNB_ssh_name}    ${DU_OAM_SSH_PASSWORD}=${gNB_ssh_pass}
    Log To Console    Stop And Copy Log To UTE
    ssh.Connect to    hostname=${DU_OAM_IP}    username=${DU_OAM_SSH_USERNAME}   password=${DU_OAM_SSH_PASSWORD}    alias=${connection}
    sleep    2s
    ${PID}    wait until keyword succeeds    1min    2s    _get_PID    connection=${connection}
    ...    command=ps -ef | grep tcpdump | grep -v grep | tail -n 1 |awk '{print $2}'
    Log To Console    kill PID
    ssh.send_command    command=kill -9 ${PID}    connection=${connection}
    Log To Console    download file to local
    ssh.download_file    remote_path=/tmp/${filename}    local_path=${LOG_PATH}/${filename}    connection=${connection}
    sleep    ${time}
    [Teardown]    ssh.disconnect    connection=${connection}

_get_PID
    [Arguments]    ${connection}    ${command}
    Log To Console    Get PID
    ssh.send_command    command=${command}   connection=${connection}
    ${PID}    ssh.read output    connection=${connection}
    ${PID}    strip_string    ${PID}
    should not be empty    ${PID}
    [Return]    ${PID}

Check Attach PCI
    [Arguments]    ${text_name}    ${attached_pci}
    Log To Console    Check Attach PCI
    ${result_dic}    Check_Wireshark_Parameter_From_Txt    txt_file_path=${LOG_PATH}/${text_name}
    ...    parameters=${attached_pci}
    ${result_list}    get from dictionary    ${result_dic}    resultList
    should be equal as strings    ${result_list}[0]    True

Convert pcap to the text
    [Arguments]    ${source}   ${target}    ${filter}    ${connection}=ute
    Connect to with ssh    hostname=${TEST_PC_IP}    username=${TEST_PC_USERNAME}     password=${TEST_PC_PASSWORD}    alias=${connection}
    sleep    1s
    csn.send_command
    ...  command=nice tshark -V -r ${source} -T text > ${target} -Y '${filter}'   connection=${connection}
#    ...  command=nice tshark -X lua_script:${luashark_path} -V -r ${source} -T text > ${target} -Y '${filter}'   connection=${connection}
    csn.await execution end  connection=${connection}  timeout=30min
    [Teardown]       csn.Disconnect  	connection=${connection}

VNOR call
    [Arguments]  ${bts_ip}=${gnb_ip}    ${filename}=vnor_att    ${attached_pci}=${vonr_fiveQI_1}    ${message_dict}=${vonr_setup_message_flow}
    Start Catch Trace Log    DU_OAM_IP=${bts_ip}    connection=gNB1    filename=${filename}.pcap
    Make a VoNR call(+6688)    during=10s
    Stop And Copy Log To UTE    DU_OAM_IP=${bts_ip}    connection=gNB1    filename=${filename}.pcap    time=30s
    Check Target PCI And Flow Message    pcap_name=${filename}.pcap    text_name=${filename}.txt    attached_pci=${attached_pci}
    ...    message_dict=${message_dict}
    [Teardown]  Run Keyword And Ignore Error    hang up VoNR call

Make a VoNR call(+6688)
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${during}=90s
    log to console    \n *** Make a VoNR call(+6688)
    ssh.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    #####Press the Home button to open the screen#####
    ssh.send_command   connection=cygwin${ue_index}
    ...   command=adb -s ${serial_number} shell dumpsys window | grep -E \"mAwake|isStatusBarKeyguard|mShowingLockscreen\"
    sleep   2s
    ${output}   ssh.read_output   connection=cygwin${ue_index}
    Run Keyword If   ${output.lower().count('mawake=false')}>0
    ...    ssh.send_command    command=adb -s ${serial_number} shell input keyevent 82    connection=cygwin${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    ssh.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800    connection=cygwin${ue_index}
    sleep   2s
    #####make VoNR call#####
    ssh.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:+6688
    ...    connection=cygwin${ue_index}
    sleep    ${during}

hang up VoNR call
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    log to console    \n *** hang up VoNR call
    ssh.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    ssh.send_command    command=adb -s ${serial_number} shell input keyevent 6    connection=cygwin${ue_index}

Check Target PCI And Flow Message
    [Arguments]    ${pcap_name}    ${text_name}    ${attached_pci}    ${message_dict}
    ${filter}=    CATENATE    f1ap || ngap
    Convert pcap to the text    source=${LOG_PATH}/${pcap_name}    target=${LOG_PATH}/${text_name}   filter=${filter}
    Check Attach PCI    text_name=${text_name}    attached_pci=${attached_pci}
    Check Flow Message    text_name=${text_name}    message_dict=${message_dict}

Check Flow Message
    [Arguments]    ${text_name}    ${message_dict}
    Log To Console    Check Flow Message
    ${result}    Check Wireshark Message Flow From Txt    txt_file_path=${LOG_PATH}/${text_name}    message_dict=${message_dict}
    should be equal as strings    ${result}    True

attach to supercell one by one
    Block or UnBlock Multiple Cell    nr_cell_id=${1}    block_flag=${True}    bts_host=${gnb_ip}
    Block or UnBlock Multiple Cell    nr_cell_id=${3}    block_flag=${True}    bts_host=${gnb_ip}
    UE Start Traffic And Check Tp    ul_throughput=160    dl_throughput=300    ul_list=${NR_cell_id_list_nrtdd_0}
    ...    dl_list=${NR_cell_id_list_nrtdd_0}    ue_index=${0}    target_avg_percent=0.2    log_time=60s
    Block or UnBlock Multiple Cell    nr_cell_id=${1}    block_flag=${False}    bts_host=${gnb_ip}
#    Block or UnBlock Multiple Cell    nr_cell_id=${3}    block_flag=${False}    bts_host=${gnb_ip}

    Block or UnBlock Multiple Cell    nr_cell_id=${0}    block_flag=${True}    bts_host=${gnb_ip}
#    Block or UnBlock Multiple Cell    nr_cell_id=${3}    block_flag=${True}    bts_host=${gnb_ip}
    UE Start Traffic And Check Tp    ul_throughput=160    dl_throughput=300    ul_list=${NR_cell_id_list_nrtdd_1}
    ...    dl_list=${NR_cell_id_list_nrtdd_1}    ue_index=${0}    target_avg_percent=0.2    log_time=60s
#    Block or UnBlock Multiple Cell    nr_cell_id=${0}    block_flag=${False}    bts_host=${gnb_ip}
    Block or UnBlock Multiple Cell    nr_cell_id=${3}    block_flag=${False}    bts_host=${gnb_ip}

#    Block or UnBlock Multiple Cell    nr_cell_id=${0}    block_flag=${True}    bts_host=${gnb_ip}
    Block or UnBlock Multiple Cell    nr_cell_id=${1}    block_flag=${True}    bts_host=${gnb_ip}
    UE Start Traffic And Check Tp    ul_throughput=160    dl_throughput=300    ul_list=${NR_cell_id_list_nrtdd_3}
    ...    dl_list=${NR_cell_id_list_nrtdd_3}    ue_index=${0}    target_avg_percent=0.2    log_time=60s
    Block or UnBlock Multiple Cell    nr_cell_id=${0}    block_flag=${False}    bts_host=${gnb_ip}
    Block or UnBlock Multiple Cell    nr_cell_id=${1}    block_flag=${False}    bts_host=${gnb_ip}

attach to supercell1 and supercell2
    Block or UnBlock Multiple Cell    nr_cell_id=${3}    block_flag=${True}    bts_host=${gnb_ip}
    UE Start Traffic And Check Tp    ul_throughput=160    dl_throughput=300    ul_list=${NR_cell_id_list_nrtdd_1}
    ...    dl_list=${NR_cell_id_list_nrtdd_1}    ue_index=${0}    target_avg_percent=0.2    log_time=60s
    Block or UnBlock Multiple Cell    nr_cell_id=${3}    block_flag=${False}    bts_host=${gnb_ip}

    Block or UnBlock Multiple Cell    nr_cell_id=${1}    block_flag=${True}    bts_host=${gnb_ip}
    UE Start Traffic And Check Tp    ul_throughput=160    dl_throughput=300    ul_list=${NR_cell_id_list_nrtdd_3}
    ...    dl_list=${NR_cell_id_list_nrtdd_3}    ue_index=${0}    target_avg_percent=0.2    log_time=60s
    Block or UnBlock Multiple Cell    nr_cell_id=${1}    block_flag=${False}    bts_host=${gnb_ip}

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

unlock RU and cell
    [Arguments]    ${lock_ru_id_list}    ${block_cellid_1}    ${block_cellid_2}
    Lock or Unlock RU And Check Status    unlock_RU_id_list=${lock_ru_id_list}    lock_flag=${False}    bts_host=${gnb_ip}   BTS_ID=37485
    Block or UnBlock Multiple Cell    nr_cell_id=${block_cellid_1}    block_flag=${False}    bts_host=${gnb_ip}
    Block or UnBlock Multiple Cell    nr_cell_id=${block_cellid_2}    block_flag=${False}    bts_host=${gnb_ip}

attach to supercell3
    Block or UnBlock Multiple Cell    nr_cell_id=${1}    block_flag=${True}    bts_host=${gnb_ip}
    Block or UnBlock Multiple Cell    nr_cell_id=${3}    block_flag=${True}    bts_host=${gnb_ip}
    UE Start Traffic And Check Tp    ul_throughput=160    dl_throughput=300    ul_list=${NR_cell_id_list_nrtdd_0}
    ...    dl_list=${NR_cell_id_list_nrtdd_0}    ue_index=${0}    target_avg_percent=0.2    log_time=60s
    Block or UnBlock Multiple Cell    nr_cell_id=${1}    block_flag=${False}    bts_host=${gnb_ip}
    Block or UnBlock Multiple Cell    nr_cell_id=${3}    block_flag=${False}    bts_host=${gnb_ip}

RU5 and RU6 plug out or plug in
    [Arguments]    ${port_list}    ${locked}=True    ${check}=True
    Run keyword if    ${locked}==${True}    Modify Parameter And Check BTS Status    input_list=${port_list}
    Run keyword if    ${locked}==${False}    Modify Parameter And Check BTS Status    input_list=${port_list}
    ${status}    Run Keyword And Return Status     wait until keyword succeeds    300s    10 s    check active alarm    check=${check}
    ...    test_alarm_ID=${7116}    test_fault_ID=${10}    ru_index=${5}    BTS_IP=${gnb_ip}
    Run Keyword if    ${status} == ${False}    Save the Snapshot
     Should Be Equal as strings    ${status}    ${True}

     ${status}    Run Keyword And Return Status     wait until keyword succeeds    300s    10 s    check active alarm    check=${check}
    ...    test_alarm_ID=${7116}    test_fault_ID=${10}    ru_index=${6}    BTS_IP=${gnb_ip}
    Run Keyword if    ${status} == ${False}    Save the Snapshot
     Should Be Equal as strings    ${status}    ${True}

     Run keyword if    ${locked}==${False}    Check the GNB on air

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

Download Current BTS SCF To UTE
    [Arguments]    ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM_1    ${scf_name}=${Empty}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}
    ...    connection=${connection}
    coam.get_current_scf_file    local_dir_path=${OUTPUT_DIR}    file_name=${scf_name}    connection=${connection}
    [Teardown]     Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

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
