*** Settings ***
Documentation
...    author: Jiang Hongyu
...    contact: hongyu.jiang@nokia-sbell.com
...    squad group: MMW_SG_04
...    feature : CB010706


Library     taf.sbts.oam.coam.admin       WITH NAME    coam
Library     taf.transport.ssh            WITH NAME    ssh
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Commercial_mobile_phone_adb_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
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
@{allowed_list}               ${4655}    ${61524}    ${4654}    ${61652}    ${4592}    ${7312}    ${7313}    ${49}    ${6351}    ${4657}
${att_ipaddr}                 ${tl.attenuator.ip_addr}
${att_api_port}               ${tl.attenuator.port}
${att_connection_port}        ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
#${gNB_ssh_name}               ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
#${gNB_ssh_pass}               ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
#@{RU_unlock_status}           Unlocked    enabled    Active    configured
#@{RU_lock_status}             Locked    enabled    Idle    configured
@{Cell_unblock_status}        unlocked    enabled    unblocked
@{Cell_block_status}          unlocked    disabled    blocked
@{LTE_cell_id_list1}          2670337    2670338    2670339    2670340
@{NR_cell_id_list_nrtdd}      182796305
@{NR_cell_id_list_nrfdd}      182796292
@{LTE_cell_list_block}        ${1}    ${5}    ${9}
@{NR_cell_list_block}         ${1}    ${5}    ${6}    ${4}    ${2}    ${3}    ${17}
${BTS_ID}                     ${tl.gnbs[0].instance_id}
${LNBTS}                      ${tl.enbs[0].global_bts_id}
${NRBTS}                      ${tl.gnbs[0].global_bts_id}
@{PA_port_list}               ${0}    ${1}    ${2}    ${3}    ${4}
@{LTE_row_list}               LTE PDCP Thr. DL [Mbps]    LTE PDCP Thr. UL [Mbps]
@{empty_list}
@{RU_unlock_status}           Unlocked    enabled    Active    configured
@{RU_lock_status}             Locked    enabled    Idle    configured

*** Keywords ***
########### setup and teardown KW #################
Test1
    [Arguments]    ${RRU_IP}=172.22.10.162    ${DU_IP}=10.71.215.239
    SSHLibrary.Open Connection    ${DU_IP}    timeout=10    alias=rf_alarm
    ${output}    SSHLibrary.Login    toor4nsn    oZPS0POrRieRtu
    sleep    2
    ${output}    SSHLibrary.Write    rm -rf /user/toor4nsn/.ssh/known_hosts
    sleep    2
    ${output}    SSHLibrary.Write    lxc-attach -n 0x2018
    SSHLibrary.Read Until    >
    sleep    2
    ${out}    SSHLibrary.Write    ssh rfsw@${RRU_IP}
    sleep   2
    SSHLibrary.Write    yes
    sleep    2
    SSHLibrary.Read Until    rfsw@${RRU_IP}'s password:
    ${out}    SSHLibrary.Write    ckBW1r1CX7VUPHcoHd69to3UwvEVm+cGW1aXDlfr51Y=
    sleep  2
    ${out}    SSHLibrary.Write    rad -mw 0x110032 60000
    [Teardown]    Run Keyword And Ignore Error    SSHLibrary.Close Connection

CB009183 Suite Setup
    [Arguments]     ${bts_host}=${gNB_ip}    ${id_index}=${0}
    CI_interface.Common Suite Setup
    robot_common_operations.Common Suite Setup
    Adapt to ute cloud commission scf
#    Setup Commission SCF    scf_name=${EMPTY}    bts_host=${bts_host}
    Check GNB on air and Check Alarm List on BTS
    Set default SCF

Check GNB on air and Check Alarm List on BTS
    [Arguments]       ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    Check GNB on air_debug    bts_host=${bts_host}
    Check Alarm List on BTS    allowed_list=${allowed_list}    bts_host=${bts_host}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

NR RAT Reset
    [Arguments]       ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    coam.reset_rat    rat_type=NR     timeout=180    connection=${connection}
    Check GNB on air_debug    bts_host=${bts_host}
    Check Alarm List on BTS    allowed_list=${allowed_list}    bts_host=${bts_host}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

LTE RAT Reset
    [Arguments]       ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    coam.reset_rat    rat_type=LTE     timeout=180    connection=${connection}
    Check GNB on air_debug    bts_host=${bts_host}
    Check Alarm List on BTS    allowed_list=${allowed_list}    bts_host=${bts_host}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Case Teardown
    robot_common_operations.Common case Teardown
#    CI_interface.Common Case Teardown

Case Setup
    [Arguments]    ${scf_path}=None    ${bts_host}=${gnb_ip}    ${if_activate_scf}=${False}
    robot_common_operations.Common case Setup
    Adapt to ute cloud commission scf
    run keyword if    ${if_activate_scf}    Setup Commission SCF    scf_path=${scf_path}    bts_host=${bts_host}
    Check GNB on air and Check Alarm List on BTS

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
    [Return]  ${default_scf}

Setup Commission SCF
    [Arguments]   ${scf_path}    ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM
#    ${default_scf}    Set default SCF    scf_name=${scf_name}    bts_host=${bts_host}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    COAM Commission with scf file    scf_file_path=${scf_path}    connection=${connection}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Check GNB on air
    [Timeout]    20 min
    [Arguments]  ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    Wait Until Keyword Succeeds    20min    20s    COAM Check GNB cell on air    connection=${connection}
    Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair    connection=${connection}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Check GNB on air_debug
    [Timeout]    20 min
    [Arguments]  ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM
  #  Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    Wait Until Keyword Succeeds    20min    20s    COAM Check GNB cell on air    connection=${connection}
    Wait Until Keyword Succeeds    20min    20s    Verify all cells should be onair    connection=${connection}
#    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

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
#    Run Keyword if    ${history_id_len} != ${0}    Save Snapshot
#    Should be equal    ${history_id_len}    ${0}

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

########### Cell operation #################
Block or UnBlock Multiple Cell
    [Arguments]  ${lte_cell_id_list}    ${nr_cell_list}    ${block_flag}=${True}    ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM    ${timeout}=60
    Run keyword if    ${block_flag}==${True}    Log To Console    Block Cell Start
    ...    ELSE    Log To Console    UnBlock Cell Start
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    FOR   ${cell_id}   IN   @{lte_cell_id_list}
        ${dist_name}    Set Variable    MRBTS-${BTS_ID}/LNBTS-${LNBTS}/LNCEL-${cell_id}
        Run keyword if    ${block_flag}==${True}    coam.block_cell    dist_name=${dist_name}    timeout=${timeout}    connection=${connection}
        ...    ELSE    coam.unblock_cell    dist_name=${dist_name}    timeout=${timeout}    connection=${connection}
        sleep    5s
    END
    FOR   ${cell_id}   IN   @{nr_cell_list}
        ${dist_name}    Set Variable    MRBTS-${BTS_ID}/NRBTS-${NRBTS}/NRCELL-${cell_id}
        Run keyword if    ${block_flag}==${True}    coam.block_cell    dist_name=${dist_name}    timeout=${timeout}    connection=${connection}
        ...    ELSE    coam.unblock_cell    dist_name=${dist_name}    timeout=${timeout}    connection=${connection}
        sleep    5s
    END
    sleep    30s
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Check All RU or Cell Status
    [Documentation]  expect_item_status_dict eg:
    ...              1) ${cell_status_dict}    Create Dictionary     NRCELL-1=${Cell_unblock_status}    NRCELL-2=${Cell_block_status}
    ...              2) ${ru_status_dict}    Create Dictionary     RMOD-1=${RU_unlock_status}    RMOD-2=${RU_lock_status}
    [Arguments]  ${expect_item_status_dict}    ${actual_item_status_dict}    ${if_ru}=${True}   ${bts_host}=${gnb_ip}
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
    ...    actual_item_status_dict=${all_cell_status_dict}    if_ru=${False}   bts_host=${bts_host}
    Should Not Contain    ${status_list}    ${False}

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

attach multi power ue
    [Arguments]    ${ue_index_list}   ${gnb_index}=${0}
    log to console       Prepare UE
    FOR    ${ue_index}   IN    @{ue_index_list}
        power_ue.Prepare UE    ue_index=${ue_index}    ue_type=samsung
        power_ue.UE Attach    ue_index=${ue_index}    attach_mode=5G_NSA   ue_type=samsung
        wait until keyword succeeds    1 min    10s    Verify 4G Attach by ADB Command    ue_index=${ue_index}
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

start multi power ue traffic ul and dl
    [Arguments]    ${ue_index_list}    ${ul_throughput}=${None}    ${dl_throughput}=${None}    ${ul_duration}=6000    ${dl_duration}=6000
    ...    ${protocol}=udp    ${if_ul}=${True}    ${if_dl}=${True}    ${process_num}=${2}    ${ue_type}=samsung
    log to console      Start traffic    console=yes
    FOR    ${item}    IN    @{ue_index_list}
        run keyword and continue on failure    run keyword if    ${if_ul}    power_ue.Start traffic    ue_index=${item}    direction=ul
        ...    throughput=${ul_throughput}    duration=${ul_duration}    ue_type=${ue_type}    protocol=${protocol}
        ...    iperf_port=${ul_power_port_list}[${item}]    process_num=${process_num}    iperf_type=via_command
        sleep    1s
        run keyword and continue on failure    run keyword if    ${if_dl}    power_ue.Start traffic    ue_index=${item}    direction=dl
        ...    throughput=${dl_throughput}    duration=${dl_duration}    ue_type=${ue_type}    protocol=${protocol}
        ...    iperf_port=${dl_power_port_list}[${item}]    process_num=${process_num}
    END

stop multi power ue traffic ul and dl
    [Arguments]    ${ue_index_list}    ${protocol}=udp    ${if_ul}=${True}    ${if_dl}=${True}    ${ue_type}=samsung
    log to console     Stop traffic    console=yes
    FOR    ${item}    IN    @{ue_index_list}
        run keyword if    ${if_ul}    power_ue.Stop traffic    direction=ul    ue_index=${item}    ue_type=${ue_type}    iperf_type=via_command
        ...    protocol=${protocol}    iperf_port=${ul_power_port_list}[${item}]
        run keyword if    ${if_dl}    power_ue.Stop traffic    direction=dl    ue_index=${item}    ue_type=${ue_type}    protocol=${protocol}
        ...    iperf_port=${dl_power_port_list}[${item}]
    END

detach multi power ue
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
    [Arguments]  ${cell_id_list}    ${nrcellgrp_id_list}
    Log To Console    delete nrcell
    ${length}    Get Length    ${cell_id_list}
    FOR   ${item}    IN RANGE   ${length}
        selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS}/NRCELL-${cell_id_list}[${item}]
        selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id_list}[${item}]
        selenium_coam.remove_element   dist_name=${NRBTS_ID}/NRCELLGRP-${nrcellgrp_id_list}[${item}]
        ...    filter_param=List of NR cells assigned to cell group    node_index=${1}    abbr=nrCellList
    END

Delete NrcellGrp Data
    [Arguments]  ${cell_id_list}    ${nrcellgrp_id}    ${node_index}
    Log To Console    delete nrcell group
    ${length}    Get Length    ${cell_id_list}
    FOR   ${item}    IN RANGE   ${length}
        selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS}/NRCELL-${cell_id_list}[${item}]
        selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id_list}[${item}]
    END
    selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS}/NRCELLGRP-${nrcellgrp_id}
    selenium_coam.remove_element   dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS}/NRDU-1
    ...    filter_param=Reference to cell group    node_index=${node_index}    abbr=refNrCellGroup

Copy Cell info From SCF
    [Arguments]  ${copy_cell_id_list}    ${keep_cell_id}
    Adapt to ute cloud commission scf
    ${default_scf_path}    Set default SCF
    Log To Console    Add nrcell
    ${id_value}    set variable    ${1}
    ${LCELNR_name}    set variable    MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${default_scf_path}
    FOR  ${cell_id}  IN  @{copy_cell_id_list}
        ${id_value}=    Evaluate    ${id_value} + ${1}
        selenium_coam.add_object    object_name=${LCELNR_name}-${keep_cell_id}   object_class_name=CHANNELGROUP
        ...    plan_to_copy_from=CONF-1    copy_from=${LCELNR_name}-${cell_id}/CHANNELGROUP-1
        ...    include_subobject=${TRUE}    id_value=${id_value}
    END


Change 8normal to mix super normal cell
    [Arguments]  ${copy_cell_id_list}    ${keep_cell_id}
    WEBUI Login
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS}/NRCELL-${keep_cell_id}
    ...    filter_param=Activate super cell   new_value=true    abbr=actSuperCell
    Copy Cell info From SCF    copy_cell_id_list=${copy_cell_id_list}    keep_cell_id=${keep_cell_id}
    Delete NrcellGrp Data    cell_id_list=    nrcellgrp_id=${2}    node_index=${1}
    Delete NrcellGrp Data    cell_id_list=    nrcellgrp_id=${3}    node_index=${2}
    @{keep_nrcellgrp_id_list}    create list    ${1}    ${4}
    Delete Nrcells Data    cell_id_list=    nrcellgrp_id_list=${keep_nrcellgrp_id_list}
    Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}
    [Teardown]  WEBUI Logout


#################### Case Setup########################
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
    [Arguments]    ${ul_throughput}    ${dl_throughput}    ${ul_list}    ${dl_list}    ${protocol}    ${ue_index}
    ...    ${if_ul}=${True}    ${if_dl}=${True}    ${target_avg_percent}=0.9    ${min_percent}=0    ${log_time}=30s    ${ue_type}=samsung
    @{ue_index_list}    create list    ${ue_index}
    attach multi power ue    ue_index_list=${ue_index_list}
    start multi power ue traffic ul and dl    ue_index_list=${ue_index_list}    ul_throughput=${ul_throughput}M    dl_throughput=${dl_throughput}M
    ...    if_ul=${if_ul}    if_dl=${if_dl}    process_num=${3}    protocol=${protocol}    ue_type=${ue_type}
    Check Throught From Asslog   ul_list=${ul_list}    dl_list=${dl_list}     ul_tp=${ul_throughput}    dl_tp=${dl_throughput}    if_ul=${if_ul}
    ...   if_dl=${if_dl}   target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    log_time=${log_time}
    stop multi power ue traffic ul and dl    ue_index_list=${ue_index_list}    if_ul=${if_ul}    if_dl=${if_dl}    protocol=${protocol}
    [Teardown]  detach multi power ue    ue_index_list=${ue_index_list}

LTE UE Start Traffic And Check Tp
    [Arguments]    ${ul_throughput}    ${dl_throughput}    ${protocol}    ${list_length}    ${if_ul}=${True}    ${if_dl}=${True}    ${log_time}=30s
    @{ue_index_list}    create list    ${0}
    UE attach by Spark    ue_index=${0}    ue_type=huawei_sigspark    attach_mode=LTE
    Spark Start UE Log    ue_index=${0}
    start multi power ue traffic ul and dl    ue_index_list=${ue_index_list}    ul_throughput=${ul_throughput}M    dl_throughput=${dl_throughput}M
    ...    if_ul=${if_ul}    if_dl=${if_dl}    process_num=${3}    protocol=${protocol}    ue_type=samsung
    sleep    ${log_time}
    ${log_path}    Spark Stop UE Log    ue_index=${0}
    stop multi power ue traffic ul and dl    ue_index_list=${ue_index_list}    if_ul=${if_ul}    if_dl=${if_dl}    protocol=${protocol}
    Check UE TP From Spark Log    log_path=${log_path}    expect_ul=${ul_throughput}    expect_dl=${dl_throughput}    row_list=${LTE_row_list}
    ...    list_length=${list_length}
    [Teardown]  UE detach by Spark    ue_index_list=${ue_index_list}

Check UE TP From Spark Log
    [Arguments]  ${log_path}    ${expect_ul}    ${expect_dl}    ${row_list}    ${list_length}
    ${throughput_dict}    Get_UE_TP_From_spark_log    file_path=${log_path}    list_length=${list_length}    row_list=${row_list}
    log to console    ${throughput_dict}
    ${DL_tp_info}    get from dictionary  ${throughput_dict}    DL_tp
    ${UL_tp_info}    get from dictionary  ${throughput_dict}    UL_tp
    run keyword and continue on failure    Should Be True     ${DL_tp_info}[${0}] > ${expect_dl}
    run keyword and continue on failure    Should Be True     ${UL_tp_info}[${0}] > ${expect_ul}

UE Start Traffic And Check Tp
    [Arguments]    ${ul_throughput}    ${dl_throughput}    ${ul_list}    ${dl_list}    ${protocol}    ${ue_index}
    ...    ${if_ul}=${True}    ${if_dl}=${True}    ${target_avg_percent}=0.9    ${min_percent}=0    ${log_time}=60s    ${ue_type}=samsung
    @{ue_index_list}    create list    ${ue_index}
    UE attach by Spark    ue_index=${ue_index}    ue_type=huawei_sigspark    attach_mode=5G_NSA
    sleep    10s
    start multi power ue traffic ul and dl    ue_index_list=${ue_index_list}    ul_throughput=${ul_throughput}M    dl_throughput=${dl_throughput}M
    ...    if_ul=${if_ul}    if_dl=${if_dl}    process_num=${3}    protocol=${protocol}    ue_type=${ue_type}
    Check Throught From Asslog   ul_list=${ul_list}    dl_list=${dl_list}     ul_tp=${ul_throughput}    dl_tp=${dl_throughput}    if_ul=${if_ul}
    ...   if_dl=${if_dl}   target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    log_time=${log_time}
    stop multi power ue traffic ul and dl    ue_index_list=${ue_index_list}    if_ul=${if_ul}    if_dl=${if_dl}    protocol=${protocol}
    [Teardown]  UE detach by Spark    ue_index_list=${ue_index_list}

Block And Unblock All Cell
    Block or UnBlock Multiple Cell    lte_cell_id_list=${LTE_cell_list_block}    nr_cell_list=${NR_cell_list_block}    block_flag=${True}
    Check All LTE And NR cell Status    expect_cell_status=${Cell_block_status}
    Block or UnBlock Multiple Cell    lte_cell_id_list=${LTE_cell_list_block}    nr_cell_list=${NR_cell_list_block}    block_flag=${False}
    Check All LTE And NR cell Status    expect_cell_status=${Cell_unblock_status}
    Check GNB on air and Check Alarm List on BTS

Modify Parameter And Check BTS Status
    [Arguments]  ${input_list}    ${bts_host}
    Modify Parameters with json    input_list=${input_list}
    Check GNB on air    bts_host=${bts_host}
    Check Alarm List on BTS    allowed_list=${allowed_list}    bts_host=${bts_host}

LTE Block Cell And Check Status
    [Arguments]    ${operate_cell_id}    ${keep_cell_id}    ${block_flag}    ${bts_host}=${gnb_ip}
    @{cell_id_list}    create list    ${operate_cell_id}
    Block or UnBlock Multiple Cell    lte_cell_id_list=${cell_id_list}    nr_cell_list=${empty_list}    block_flag=${block_flag}
    ...    bts_host=${bts_host}
    ${all_cell_status}    Get All RU or Cell Status    cell_type=lte    if_ru=${False}    bts_host=${bts_host}
    ${expect_cell_status_dict}    run keyword if    ${block_flag}
    ...    Create Dictionary     LNCEL-${operate_cell_id}=${Cell_block_status}    LNCEL-${keep_cell_id}=${Cell_unblock_status}
    ...    ELSE    Create Dictionary     LNCEL-${operate_cell_id}=${Cell_unblock_status}    LNCEL-${keep_cell_id}=${Cell_unblock_status}
    ${status_list}    Check All RU or Cell Status    expect_item_status_dict=${expect_cell_status_dict}
    ...    actual_item_status_dict=${all_cell_status}    if_ru=${False}    bts_host=${bts_host}
    Should Not Contain    ${status_list}    ${False}

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
