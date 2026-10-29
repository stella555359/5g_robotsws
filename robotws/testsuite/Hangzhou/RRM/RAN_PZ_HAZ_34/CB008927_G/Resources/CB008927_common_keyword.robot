*** Settings ***
Documentation    author：Hongyu Jiang
...              contact: hongyu.jiang@nokia-sbell.com
...              squad group: mmw_SG_04

Library     BuiltIn
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Commercial_mobile_phone_adb_common_keywords.robot
Resource    taf/rfrl/common_resources/robot/TTI_Trace.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/TTI_Trace_Analysis_MMW4.py
Library     TTI_Trace_Analysis_MMW4.TTI_Trace_analysis    WITH NAME    TTI_Trace
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/TTI_stream_Analysis_MMW4.py
Library     TTI_stream_Analysis_MMW4.TTI_Stream_analysis    WITH NAME    TTI_Stream
Library     taf.transport.ssh      WITH NAME    ssh
Library     taf.sbts.oam.coam.admin       WITH NAME    coam
Library     taf.hw.rf_attenuator    WITH NAME    att
Library     ../../CB007306_OTA/Resources/CB007306_common.py
Library     ../../CB009102/Resources/CB009102_common_keywords.py
Library             taf.ul.mobile.ui.android     WITH NAME   android_mobile
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/TTI_logs_Capture.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/SISO_common_operation.robot




*** Variables ***
@{allowed_list}               ${4655}    ${61524}    ${4654}    ${61649}    ${4681}    ${61652}     ${7300}    ${7319}    ${4592}    ${6327}
...    ${7313}    ${4476}    ${7311}
${CURDIR_path}            ${CURDIR}/../../../../../../commissionings/HGZ/${testline_name}
${gNB_ip0}                 ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${gNB_ip1}                ${tl.gnbs[1].dus[0].airscale.common_units[0].lmp_connection.addr}
${gNB_username}           ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gNB_password}           ${tl.gnbs[0].cu.oam_http_connection_details.password}
${gnb_ssh_username}       ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${gnb_ssh_password}       ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${ul_power_port_list}     ${tl.ues[0].iperf_details.ports[0:4]}
${dl_power_port_list}     ${tl.ues[0].iperf_details.ports[3:8]}
${ul_power_port_list_1}     ${tl.ues[2].iperf_details.ports[0:4]}
${dl_power_port_list_1}     ${tl.ues[2].iperf_details.ports[4:8]}
${control_pc}             ${tl.ues[0].ssh_connection_details.addr}
${control_pc_name}        ${tl.ues[0].ssh_connection_details.username}
${control_pc_pass}        ${tl.ues[0].ssh_connection_details.password}
${control_pc1}            ${tl.ues[2].ssh_connection_details.addr}
${control_pc1_name}       ${tl.ues[2].ssh_connection_details.username}
${control_pc1_pass}       ${tl.ues[2].ssh_connection_details.password}
${ue_type}                samsung
${iperf_addr}             ${tl.ues[0].iperf_details.ssh_connection_details.addr}
${TS_CASE_LOG_PATH}       ${output_dir}
${att_ipaddr}             ${tl.attenuator.ip_addr}
${att_api_port}           ${tl.attenuator.port}
${att_connection_port}    ${tl.gnbs[1].dus[0].rus[0].attenuation_ports[0].port_no}
${UTE_ADDRESS}            ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}           ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}           ${tl.test_pc.default_ssh_connection_details.password}
${luashark_path}          /opt/ute/luashark/generated_luashark
@{port_list}             0    1    2    3    4    5    6     7
@{value_list}            0   15    127   44    60    68
@{ue_index_list}         0    1    2    3
@{cell_list_gnb2}        612663297    612663298
@{cell_list_gnb1}        182747153    182747154    182747156    182747159
@{cell_ID_list_gnb1}     23    17    18    20
@{cell_LN_ID_list_gnb1}    5    6    7
@{ue_index_list_all}           0    1    2    3
${BTS_ID_0}                 ${tl.gnbs[0].global_bts_id}
${BTS_ID_1}                  ${tl.gnbs[1].global_bts_id}
@{RU_Id_list}                  ${2}   ${4}    ${5}    ${6}
@{RU_unlock_status}           Unlocked    enabled    Active    configured
@{RU_lock_status}             Locked    enabled    Idle    configured
@{Cell_unblock_status}        Unlocked    enabled    Active    configured    Unblocked
@{Cell_block_status}          Unlocked    disabled    Idle    configured    Blocked
@{Cell_LTE_block_status}          unlocked    disabled    Idle    off line    Blocked
${appserver_24}              10.71.219.24
${model}                     ${tl.attenuator.model}
@{Empty_list_value}



*** Keywords ***
########### setup KW #################
Suite Setup 8927
    robot_common_operations.Common Suite Setup
    Setup Commission SCF    bts_host=${gNB_ip0}
    Setup Commission SCF    bts_host=${gNB_ip1}    gnb_index=1
    CB008927_common_keyword.Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}
    CB008927_common_keyword.Check GNB on air    bts_host=${gNB_ip1}
    Check Alarm List on BTS    allowed_list=${allowed_list}    bts_host=${gnb_ip1}

Suite Teardown 8927
    robot_common_operations.Common Suite Teardown

Case Teardown
    Run Keyword if    "${TEST_STATUS}"=="FAIL"    Save Snapshot
    robot_common_operations.Common case Teardown
    ${result1}    Run Keyword And Return Status   CB008927_common_keyword.Check GNB on air    bts_host=${gnb_ip0}    time_str=2min
    ${result2}    Run Keyword And Return Status   CB008927_common_keyword.Check GNB on air    bts_host=${gNB_ip1}    time_str=2min
    Run keyword if    '${result1}'=='False'    Setup Commission SCF    bts_host=${gNB_ip0}
    Run keyword if    '${result2}'=='False'    Setup Commission SCF    bts_host=${gNB_ip1}    gnb_index=1
    Run keyword if    '${result1}'=='False'    CB008927_common_keyword.Check GNB on air    bts_host=${gnb_ip0}
    Run keyword if    '${result2}'=='False'    CB008927_common_keyword.Check GNB on air    bts_host=${gNB_ip1}
    sleep    20s
    CI_interface.Common Case Teardown

G_B2_Case_Teardown
    Unblock cells    unblock_cell_list=${cell_ID_list_gnb1[1:3]}
    modify the parameter case B2_recovery
    Case Teardown

IWK12_Case_Teardown
    ${gnb2_unlock_cell_list}    Create list    ${1}
    Unblock cells    unblock_cell_list=${cell_ID_list_gnb1[1:4]}
    Unblock cells    unblock_cell_list=${gnb2_unlock_cell_list}    gnb_index=${1}
    modify the parameter case IWK12_recovery
    Case Teardown

IWK15_Case_Teardown
    ${gnb2_unlock_cell_list}    Create list    ${2}
    Unblock cells    unblock_cell_list=${cell_ID_list_gnb1[1:4]}
    Unblock cells    unblock_cell_list=${gnb2_unlock_cell_list}    gnb_index=${1}
    modify the parameter case IWK15_recovery
    Case Teardown

IWK17_Case_Teardown
    Unblock cells    unblock_cell_list=${cell_ID_list_gnb1[0:3]}
    modify the parameter case IWK17    new_value=false
    Case Teardown

HR1_Case_Teardown
    ${gnb2_unlock_cell_list}    Create list    ${1}    ${2}
    Unblock cells    unblock_cell_list=${cell_ID_list_gnb1[1:4]}
    Unblock cells    unblock_cell_list=${gnb2_unlock_cell_list}    gnb_index=${1}
    modify the parameter case HR1_recovery
    Case Teardown

IWK9_Case_Teardown
    robot_common_operations.Common case Teardown
    CI_interface.Common Case Teardown

########### check bts on air #################
Adapt to ute cloud commission scf
    ${TL_NAME}   set variable if      '${testline_name}' == '${EMPTY}'    ${CONFIGURATION}    ${testline_name}
    ${pattern}   Set Variable    7_5(.*)
    ${TL_NAME_1}    Get Regexp Matches     ${TL_NAME}    ${pattern}    1
    ${TL_NAME_1}   Set Variable    7_5${TL_NAME_1}[0]
    Set Suite Variable    ${CURDIR_path}    ${CURDIR}/../../../../../../commissionings/HGZ/${TL_NAME_1}/

Set default SCF
    [Arguments]    ${bts_host}=${gNB_ip0}   ${connection}=GNB_OAM    ${gnb_index}=0
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${version}    coam.get_sw_version    connection=${connection}
    ${version_list}    split string    ${version}    separator=_
    ${version_scf}    run keyword if    '${version_list[2]}'=='9999' or '${version_list[2]}'=='9990'
    ...    Set Variable    SBTS00
    ...    ELSE   Set Variable    ${version_list[0]}
    ${default_scf_path}    set variable    ${CURDIR_path}/SCF_${version_scf}_gnb${gnb_index}.xml
    set suite variable    ${default_scf_path}
    log to console   ${default_scf_path}
    [Teardown]     Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Setup Commission SCF
    [Arguments]   ${bts_host}=${gNB_ip0}    ${connection}=GNB_OAM    ${gnb_index}=0
    Set default SCF    bts_host=${bts_host}    gnb_index=${gnb_index}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    COAM Commission with scf file    scf_file_path=${default_scf_path}     timeout=10min    connection=${connection}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Check GNB on air
    [Timeout]    30 min
    [Arguments]  ${bts_host}=${gnb_ip0}    ${connection}=GNB_OAM    ${time_str}=30min
    Wait Until Keyword Succeeds    20min    20s
    ...    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}
    ...    connection=${connection}
    Wait Until Keyword Succeeds    ${time_str}    20s    COAM Check GNB cell on air    connection=${connection}
    Wait Until Keyword Succeeds    ${time_str}    20s    Verify all cells should be onair    connection=${connection}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Get Alarm on BTS
    [Arguments]  ${bts_host}=${gnb_ip0}    ${connection}=GNB_OAM
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

Connect to eNB
    [Arguments]    ${BTS_PORT}= 443     ${USE_SSL}= True    ${connection}=enblte    ${bts_host}=${ENB_0_ip}
    enblte.connect_to    bts_host=${bts_host}
    ...    bts_port=${BTS_PORT}  use_ssl=${USE_SSL}    name=${connection}

Check Alarm List on BTS Temp
    [Arguments]  ${allowed_list}=None    ${not_allowed_list}=None    ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM
    ${actual_fault_id_list}    ${history_id_list}    Get Alarm on BTS    bts_host=${bts_host}    connection=${connection}
    ${history_id_len}    Get Length    ${history_id_list}
    Run Keyword if    ${allowed_list} != None        Check List1 content in List2    list1=${actual_fault_id_list}    list2=${allowed_list}
    Run Keyword if    ${not_allowed_list} != None     Check List1 content not in List2    list1=${not_allowed_list}    list2=${actual_fault_id_list}
    Run Keyword if    ${history_id_len} != ${0}    Save Snapshot
    Should be equal    ${history_id_len}    ${0}

Check Alarm List on BTS
    [Arguments]  ${allowed_list}=None    ${not_allowed_list}=None    ${bts_host}=${gnb_ip0}    ${connection}=GNB_OAM
    ${status}    Run Keyword And Return Status    Check Alarm List on BTS Temp    allowed_list=${allowed_list}
    ...    not_allowed_list=${not_allowed_list}    bts_host=${bts_host}    connection=${connection}
    Run Keyword if    ${status} == ${False}    Save Snapshot    bts_host=${bts_host}
    Should be equal    ${status}    ${True}

Check Cells info
    [Arguments]    ${expect_cell_info}     ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${cells_info_list}    coam.get_cells_info    connection=${connection}
    ${result}    Check_Cell_Id_Info    cells_info_list=${cells_info_list}    expect_cell_info=${expect_cell_info}
    Should be equal   ${result}    ${True}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

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

Save Snapshot
    [Arguments]    ${connection}=cOAM    ${timeout}=10min    ${bts_host}=${gNB_ip0}
    log to console    Save Snapshot...
    run keyword and ignore error     coam.teardown    connection=${connection}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}
    ...    connection=${connection}
    ${snapshot_path}    coam.Get Snapshot From BTS    alias=${connection}    timeout=${timeout}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}
    [Return]    ${snapshot_path}

Block or UnBlock Single Cell
    [Arguments]  ${cell_id}    ${block_flag}=${True}    ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM    ${timeout}=60
    ...    ${cell_type}=NR     ${BTS_ID}=${BTS_ID_0}    ${NRBTS_ID}=${BTS_ID_0}    ${CELL}=CELL
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${dist_name}    Set Variable    MRBTS-${BTS_ID}/${cell_type}BTS-${NRBTS_ID}/${cell_type}${CELL}-${cell_id}
    Run keyword if    ${block_flag}==${True}    Log To Console    Block Cell-${cell_id}
    ...    ELSE    Log To Console    UnBlock Cell-${cell_id}
    Run keyword if    ${block_flag}==${True}    coam.block_cell    dist_name=${dist_name}    timeout=${timeout}    connection=${connection}
    ...    ELSE    coam.unblock_cell    dist_name=${dist_name}    timeout=${timeout}    connection=${connection}
    sleep    5s
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}


Get All RU or Cell Status
    [Arguments]  ${if_ru}=${True}    ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM
    ...    ${cell_type}=NR
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

Check LTE Single RU Status
    [Arguments]  ${item_status}    ${expect_status_list}
    ${admin_status}    get from dictionary    ${item_status}    administrativeState
    Run Keyword And Continue On Failure    should be equal as strings   ${admin_status}    ${expect_status_list[${0}]}
    ${operate_status}    get from dictionary    ${item_status}    operationalState
    Run Keyword And Continue On Failure    should be equal as strings    ${operate_status}    ${expect_status_list[${1}]}
    ${usage_status}    get from dictionary    ${item_status}    usageState
    Run Keyword And Continue On Failure    should be equal as strings    ${usage_status}    ${expect_status_list[${2}]}
    ${availabilityStatus_status}    get from dictionary    ${item_status}    availabilityStatus
    Run Keyword And Continue On Failure    should be equal as strings    ${availabilityStatus_status}    ${expect_status_list[${3}]}

Check Single Cell Status
    [Arguments]  ${item_status}    ${expect_status_list}    ${cell_type}
    run keyword if    '${cell_type}' == 'nr'    Check Single RU Status    item_status=${item_status}    expect_status_list=${expect_status_list}
    run keyword if    '${cell_type}' != 'nr'    Check LTE Single RU Status    item_status=${item_status}    expect_status_list=${expect_status_list}
    ${block_status}    get from dictionary    ${item_status}    blockingState
    Run Keyword And Continue On Failure    should be equal as strings   ${block_status}    ${expect_status_list[${-1}]}

Check All RU or Cell Status
    [Documentation]  expect_item_status_dict eg:
    ...              1) ${cell_status_dict}    Create Dictionary     NRCELL-1=${Cell_unblock_status}    NRCELL-2=${Cell_block_status}
    ...              2) ${ru_status_dict}    Create Dictionary     RMOD-1=${RU_unlock_status}    RMOD-2=${RU_lock_status}
    [Arguments]  ${expect_item_status_dict}    ${if_ru}=${True}   ${bts_host}=${gnb_ip}    ${cell_type}=NR
    Log To Console    Check All RU or Cell Status
    ${item_status_dic}    Get All RU or Cell Status    if_ru=${if_ru}    bts_host=${bts_host}
    ...    cell_type=${cell_type}   connection=GNB_OAM
    @{item_id_list}    get dictionary keys    ${expect_item_status_dict}
    FOR  ${item_id}  IN  @{item_id_list}
        ${expect_status_list}     get from dictionary    ${expect_item_status_dict}    ${item_id}
        ${item_status}    set variable    ${item_status_dic['${item_id}']}
        Run Keyword If    ${if_ru}    Check Single RU Status    item_status=${item_status}    expect_status_list=${expect_status_list}
        ...    ELSE    Check Single Cell Status    item_status=${item_status}    expect_status_list=${expect_status_list}    cell_type=${cell_type}
    END

Lock or Unlock RU And Check Status
    [Arguments]  ${lock_RU_id_list}=${empty_list}     ${unlock_RU_id_list}=${empty_list}    ${lock_flag}=${True}
    ...    ${bts_host}=${gnb_ip}    ${BTS_ID}=${BTS_ID}
    ${operate_ru_id_list}    Set Variable If    ${lock_flag}    ${lock_RU_id_list}    ${unlock_RU_id_list}
    Lock or UnLock Multiple RU    RMOD_id_list=${operate_ru_id_list}    lock_flag=${lock_flag}    bts_host=${bts_host}    BTS_ID=${BTS_ID}
#    Check Alarm List on BTS    allowed_list=${allowed_list}    bts_host=${bts_host}
    Sleep    121
    ${expect_item_status_dict}    create dictionary
    FOR  ${item}  IN    @{lock_RU_id_list}
        Set to dictionary    ${expect_item_status_dict}    RMOD-${item}=${RU_lock_status}
    END
    FOR  ${item1}  IN   @{unlock_RU_id_list}
        Set to dictionary    ${expect_item_status_dict}    RMOD-${item1}=${RU_unlock_status}
    END
    Wait Until Keyword Succeeds    15min    1min    Check All RU or Cell Status    expect_item_status_dict=${expect_item_status_dict}
    ...    if_ru=${True}    bts_host=${bts_host}



########### about Samsung UE #################
attach single power ue
    log to console       Prepare UE
    [Arguments]    ${ue_type}=samsung   ${ue_index}=${0}    ${4G_check}=False    ${UE}=X70    ${gnb_index}=${0}
    Get Single all pointer variable    UE=${UE}
    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=${ue_type}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    gnb_index=${gnb_index}
    Verify attach1    5Grach_ed=${5Grach_ed}    ue_index=${ue_index}    4G_check=${4G_check}    gnb_index=${gnb_index}
    #power_ue.Verify attach    ue_type=${ue_type}   5Grach_ed=${5Grach_ed}    ue_index=${ue_index}    4G_check=${4G_check}    gnb_index=${gnb_index}

Get Single all pointer variable
    [Arguments]    ${UE}=X70
    Run Keyword If    '${UE}' == 'X70'    Get all X70 pointer variable
    Run Keyword If    '${UE}' == 'X55'    Get all X55 pointer variable
    Run Keyword If    '${UE}' == 'X551'    Get all X551 pointer variable

Single UE start traffic ul and dl
    [Arguments]    ${ue_index}    ${ul_throughput}=${None}    ${dl_throughput}=${None}    ${ul_duration}=20000    ${dl_duration}=20000
    ...    ${protocol}=udp    ${if_ul}=${True}    ${if_dl}=${True}
    log to console      UE-${ue_index} Start traffic    console=yes
    run keyword and continue on failure    run keyword if     ${if_ul}    power_ue.Start traffic    ue_index=${ue_index}    direction=ul
    ...    throughput=${ul_throughput}    duration=${ul_duration}    ue_type=samsung    iperf_type=via_command    protocol=${protocol}
    ...    iperf_port=${ul_power_port_list}[${ue_index}]
    sleep    1s
    run keyword and continue on failure    run keyword if    ${if_dl}    power_ue.Start traffic    ue_index=${ue_index}     direction=dl
    ...    throughput=${dl_throughput}    duration=${dl_duration}    ue_type=samsung    protocol=${protocol}
    ...    iperf_port=${dl_power_port_list}[${ue_index} ]

detach multi power ue
    [Arguments]    ${ue_index}    ${ue_type}=samsung    ${UE}=X70
    log to console      UE-${ue_index} Detach    console=yes
    Get Single all pointer variable    UE=${UE}
    power_ue.UE Detach    ue_index=${ue_index}    ue_type=${ue_type}

Check Throught From Asslog
    [Arguments]  ${ul_list}    ${dl_list}      ${ul_tp}=${500}    ${dl_tp}=${500}    ${if_ul}=${True}    ${if_dl}=${True}
    ...    ${target_avg_percent}=0.90    ${ue_type}=samsung   ${log_time}=60s
    ${log_path}    power_ue.Collect Tput   ue_type=${ue_type}    duration=${log_time}    ignore_time=10s
    run keyword and continue on failure    run keyword if    ${if_ul}==${True}    power_ue.Check Tput    ue_type=${ue_type}
    ...    direction=UL    log=${log_path}    cells=${ul_list}    target_throughput=${ul_tp}    target_avg_percent=${target_avg_percent}
    ...    actCarrierAggregation=${True}    min_percent=0
    run keyword and continue on failure    run keyword if    ${if_dl}==${True}    power_ue.Check Tput    ue_type=${ue_type}
    ...    direction=DL    log=${log_path}    cells=${dl_list}    target_throughput=${dl_tp}    target_avg_percent=${target_avg_percent}
    ...    actCarrierAggregation=${True}    min_percent=0

Samsung UE Start DL traffic
    [Arguments]    ${DL_port}    ${traffic}    ${ue_index}=${2}    ${time}=20000   ${interval}=${1}    ${process_num}=${1}    ${buffer_size}=1400B
    ...    ${connection}=cygwin
    ssh.connect to    hostname=${control_pc}    username=${control_pc_name}    password=${control_pc_pass}    alias=${connection}
    ${serial_number}    set variable    ${tl.ues[${ue_index}].serial_number}
    ssh.send_command    command=adb -s ${serial_number} shell ip -f inet addr |grep inet |grep -v ims00 | cut -d '/' -f 1 |awk '{print $2}'
    ...    connection=${connection}
    ${UE_IP_info}    ssh.read_output    connection=${connection}
    ${UE_IP}    Get_UE_Right_IP    cmd_info=${UE_IP_info}
    wait until keyword succeeds    1 min    10 sec    Connect to EPC APP    ue_index=${ue_index}
    sleep  2s
    ssh.execute    command=ps -ef|grep iperf|grep -v grep|grep ${DL_port}| awk '{print $2}' |xargs kill -9    connection=EPCAPP
    ssh.send_command
    ...    command=iperf -c ${UE_IP} -u -t ${time} -i ${interval} -p ${DL_port} -P ${process_num} -f m -b ${traffic} -l ${buffer_size} -T 64&
    ...    connection=EPCAPP
    ssh.disconnect    connection=EPCAPP
    [Teardown]  ssh.disconnect    connection=${connection}


Get all X70 pointer variable
    Set Suite Variable    ${home}    3
    Set Suite Variable    ${airplane}    953 1385
    Set Suite Variable    ${close_task}    523 272
    Set Suite Variable    ${Home_button}    3
    Set Suite Variable    ${swipe}    500 2050 500 800
    Set Suite Variable    ${open_iperf_location}    480 860
    Set Suite Variable    ${iperf_button}    720 312
    Set Suite Variable    ${iperf_space}    800 550
    Set Suite Variable    ${brand}    qti

Get all X55 pointer variable
    Set Suite Variable    ${home}    3
    Set Suite Variable    ${airplane}    953 880
    Set Suite Variable    ${close_task}    523 272
    Set Suite Variable    ${Home_button}    3
    Set Suite Variable    ${swipe}    500 2050 500 800
    Set Suite Variable    ${open_iperf_location}    480 860
    Set Suite Variable    ${iperf_button}    720 312
    Set Suite Variable    ${iperf_space}    800 550
    Set Suite Variable    ${brand}    qti

Get all X551 pointer variable
    Set Suite Variable    ${home}    3
    Set Suite Variable    ${airplane}    953 1650
    Set Suite Variable    ${close_task}    523 272
    Set Suite Variable    ${Home_button}    3
    Set Suite Variable    ${swipe}    500 2050 500 800
    Set Suite Variable    ${open_iperf_location}    480 860
    Set Suite Variable    ${iperf_button}    720 312
    Set Suite Variable    ${iperf_space}    800 550
    Set Suite Variable    ${brand}    qti

Get gnb release info
    ${release_info}    Get sagnb release
    set suite variable    ${release_info}


start multi power ue traffic ul and dl
    [Arguments]    ${ue_index_list}    ${ul_throughput}=${None}    ${dl_throughput}=${None}    ${ul_duration}=20000    ${dl_duration}=20000
    ...    ${protocol}=udp    ${if_ul}=${True}    ${if_dl}=${True}    ${process_num}=${2}    ${ue_type}=samsung
    ...    ${iperf_port_UL}=@{ul_power_port_list}   ${iperf_port_DL}=@{dl_power_port_list}
    log to console      Start traffic    console=yes
    FOR    ${item}    IN    @{ue_index_list}
        Get Single all pointer variable    UE=${tl.ues[${item}].capabilities[1]}
        run keyword and continue on failure    run keyword if    ${if_ul}    power_ue.Start traffic    ue_index=${item}    direction=ul
        ...    throughput=${ul_throughput}    duration=${ul_duration}    ue_type=${ue_type}    protocol=${protocol}
        ...    iperf_port=${iperf_port_UL}[${item}]     process_num=${process_num}    iperf_type=via_command
        sleep    1s
        run keyword and continue on failure    run keyword if    ${if_dl}    power_ue.Start traffic    ue_index=${item}    direction=dl
        ...    throughput=${dl_throughput}    duration=${dl_duration}    ue_type=${ue_type}    protocol=${protocol}
        ...    iperf_port=${iperf_port_DL}[${item}]    process_num=${process_num}
    END

UE Check Throughput
    [Arguments]   ${exp_ul_tp}    ${exp_dl_tp}    ${ul_list}    ${dl_list}    ${target_avg_percent_UL}    ${target_avg_percent_DL}
    ...    ${actCarrierAggregation}
    ...    ${if_ul}=${True}    ${if_dl}=${True}    ${gnb_index}=0    ${log_time}=10s
    ${log_path}    power_ue.Collect Tput   ue_type=${ue_type}    duration=${log_time}    gnb_index=${gnb_index}    ignore_time=10s
    run keyword and continue on failure    run keyword if    ${if_ul}==${True}    power_ue.Check Tput    ue_type=${ue_type}
    ...    actCarrierAggregation=${actCarrierAggregation}
    ...    direction=UL    log=${log_path}    cells=${ul_list}    target_throughput=${exp_ul_tp}    target_avg_percent=${target_avg_percent_UL}
    ...    actCarrierAggregation=${True}
    run keyword and continue on failure    run keyword if    ${if_dl}==${True}    power_ue.Check Tput    ue_type=${ue_type}
    ...    actCarrierAggregation=${actCarrierAggregation}
    ...    direction=DL    log=${log_path}    cells=${dl_list}    target_throughput=${exp_dl_tp}    target_avg_percent=${target_avg_percent_DL}
    ...    actCarrierAggregation=${True}

stop multi power ue traffic ul and dl
    [Arguments]    ${ue_index_list}    ${protocol}=udp    ${if_ul}=${True}    ${if_dl}=${True}
    log to console     Stop traffic    console=yes
    FOR    ${item}    IN    @{ue_index_list}
        run keyword if    ${if_ul}    power_ue.Stop traffic    direction=ul    ue_index=${item}    ue_type=${ue_type}    iperf_type=via_command
        ...    protocol=${protocol}    iperf_port=${ul_power_port_list}[${item}]
        run keyword if    ${if_dl}    power_ue.Stop traffic    direction=dl    ue_index=${item}    ue_type=${ue_type}   protocol=${protocol}
        ...    iperf_port=${dl_power_port_list}[${item}]
    END

############# TTI log ###################
Check Same Sfn Slot Rnti Number
    [Documentation]  Check the number of UEs scheduled for the same slot, return True or False
    [Arguments]   ${file_path}    ${expect_rnti_num}=${4}
    ${result}    TTI_Stream.get_rnti_value_of_same_sfn_slot    file_path=${file_path}    direction=dl    expect_rnti_num=${expect_rnti_num}
    Should Be True    ${result} == ${True}

Check mcsTable Value
    [Documentation]  Get the value of the FdSchedData.mcsTable column, and check the value list should be include expect value
    [Arguments]  ${file_path}    ${expect_mcsTable_value}=QAM64LOWSE
    ${total_list}    TTI_Stream.get_sfn_slot_rnti_mscTable_prb    file_path=${file_path}    direction=dl
    ${msc_list}    set variable    ${total_list[${3}]}
    Should Contain  ${msc_list}  ${expect_mcsTable_value}

Check numOfLayers corresponding rrmDlProposedMcs value
    [Documentation]  The rrmDlProposedMcs value corresponding to a specific numOfLayers.
    ...    Check that the requirements are met and return a ture
    [Arguments]  ${file_path}
    ${result_1}    TTI_Stream.get_numOfLayers_rrmDlProposedMcs_value    file_path=${file_path}    numOfLayers_value=RANK2
    ...    rrmDlProposedMcs_value=${25}
    ${result_2}    TTI_Stream.get_numOfLayers_rrmDlProposedMcs_value    file_path=${file_path}    numOfLayers_value=RANK4
    ...    rrmDlProposedMcs_value=${20}
    ${result}    evaluate    ${result_1}+${result_2}
    Should Be True    ${result} >= ${0}

Check ul And dl Bler
    [Documentation]  Calculate the bler of ul and dl
    [Arguments]  ${ul_file_path}=${EMPTY}    ${dl_file_path}=${EMPTY}    ${EXP_UL}=${1}    ${EXP_DL}=${1}
    ${ul_bler}    run keyword if    '${ul_file_path}'!='${EMPTY}'    TTI_Stream.get_HarqRxDataArray_ackNack_number
    ...    file_path=${ul_file_path}    direction=ul
    ${dl_bler}    run keyword if    '${dl_file_path}'!='${EMPTY}'    TTI_Stream.get_HarqRxDataArray_ackNack_number
    ...    file_path=${dl_file_path}    direction=dl
    run keyword if    '${ul_file_path}'!='${EMPTY}'    Should Be True    ${ul_bler} <= ${EXP_UL}
    run keyword if    '${dl_file_path}'!='${EMPTY}'    Should Be True    ${dl_bler} <= ${EXP_DL}

############# tcpdump log ###################
Start Catch Trace Log
    [Arguments]    ${DU_OAM_IP}    ${connection}    ${filename}   ${time}=3s
    Log To Console    Start Catch Trace Log
    ssh.Connect to    hostname=${DU_OAM_IP}    username=${gnb_ssh_username}  password=${gnb_ssh_password}     alias=${connection}
    csn.send command    command=ps -ef |grep tcpdump |grep -v grep |grep any |awk '{print $2}' |xargs kill -2    connection=${connection}
    sleep    2s
    ssh.send_command    command=nohup tcpdump sctp -i any -w /tmp/${filename}.pcap &   connection=${connection}
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

Stop And Copy Log To UTE
    [Arguments]    ${DU_OAM_IP}    ${connection}    ${filename}    ${time}=10s
    Log To Console    Stop And Copy Log To UTE
    ssh.Connect to    hostname=${DU_OAM_IP}    username=${gnb_ssh_username}  password=${gnb_ssh_password}     alias=${connection}
    sleep    2s
    ${PID}    wait until keyword succeeds    1min    2s    _get_PID    connection=${connection}
    ...    command=ps -ef | grep tcpdump | grep -v grep | tail -n 1 |awk '{print $2}'
    Log To Console    kill PID
    ssh.send_command    command=kill -9 ${PID}    connection=${connection}
    Log To Console    download file to local
    ssh.download_file    remote_path=/tmp/${filename}   local_path=${LOG_PATH}/${filename}    connection=${connection}
    sleep    ${time}
    [Teardown]    ssh.disconnect    connection=${connection}

Convert pcap to text
    [Arguments]    ${source}    ${target}    ${filter}=ngap || xnap || f1ap
    ssh.Connect to    hostname=${UTE_ADDRESS}    username=${UTE_USERNAME}    password=${UTE_PASSWORD}    alias=UTE
    Log To Console    Convert pcap to text
    ssh.send_command
    ...    command=nice tshark -V -r ${source} -T text > ${target} -Y '${filter}'
    ...    connection=UTE
    sleep    10s
    ssh.await execution end    connection=UTE    timeout=10min
    [Teardown]    ssh.disconnect    connection=UTE



########### PA Relevant #################
Adjust the HBTE attenuation value
    [Arguments]      ${value}    ${port_list}
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}
    ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${127}    vendor=HBTE
    ...    model=${model}
    ${port_num}    Get Length   ${port_list}
    FOR    ${i}    IN RANGE    ${port_num}
        att.set_attenuation     port=${tl.gnbs[1].dus[0].rus[0].attenuation_ports[${port_list[${i}]}].port_no}    value=${value}
        ${value_port}    att.read_attenuation    port=${tl.gnbs[1].dus[0].rus[0].attenuation_ports[${port_list[${i}]}].port_no}
        should be equal    ${value_port}    ${value}
    END
    sleep  3s



##############  Log #########################
Capture TTI log 8927
    [Arguments]    ${gnb_index}=0    ${bts_ip}=${gNB_ip0}    ${connection}=GNB_OAM    ${collector_names}=l2stream3_ttitrace
    Connect to gnb coam via ssl    bts_host=${bts_ip}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${csv_path}    Start Ttitrace With Streaming Mode    collector_names=${collector_names}    gnb_index=${gnb_index}
    [Teardown]    coam.teardown    connection=${connection}

Stop TTI log 8927
    [Arguments]    ${bts_ip}=${gNB_ip0}    ${connection}=GNB_OAM    ${collector_names}=l2stream3_ttitrace
    Connect to gnb coam via ssl    bts_host=${bts_ip}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    Stop Ttitrace    collector_names=${collector_names}
    ${csv_path}     Decode Ttitrace Log    collector_names=${collector_names}
    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
    ${UL_DL_csv_file_path_dict}=  Create Dictionary
    ...    DL=${csv_path}/tcpdump_ttitrace_dl.csv
    ...    UL=${csv_path}/tcpdump_ttitrace_ul.csv
    [Return]  ${UL_DL_csv_file_path_dict}

check TTI LOG
    [Arguments]    ${collector_names}=l2stream3_ttitrace    ${filter}=ulHarqRxData
    ${csv_path}     Decode Ttitrace Log 8927    collector_names=${collector_names}   filter=${filter}
    ${UL_DL_csv_file_path_dict}=  Create Dictionary
    ...    DL=${csv_path}/tcpdump_ttitrace_dl.csv
    ...    UL=${csv_path}/tcpdump_ttitrace_ul.csv
     [Return]    ${UL_DL_csv_file_path_dict}


Decode Ttitrace Log 8927
    [Documentation]    Author: Wang Yixiang   Migrate from ET
    [Arguments]    ${collector_names}=l2stream3_ttitrace    ${log_dir}=${TS_CASE_LOG_PATH}/ttitrace_streaming    ${format_tti_log}=${False}
    ...    ${filter}=dlFdSchedData    ${DL_name}=tcpdump_ttitrace_dl.csv    ${UL_name}=tcpdump_ttitrace_ul.csv
    log to console    Start to decode ttitrace...
    ${timestamp}    robot.libraries.DateTime.Get current date    result_format=%Y%m%d%H%M%S
    ${csv_file_path}   Convert Ttitrace From Pcap To Excelcsv by Filter      log_path=${log_dir}    collector_names=${collector_names}
    ...    filter=${filter}
    run keyword if   ${format_tti_log}   log to console    Start to format ttitrace...
    run keyword if   ${format_tti_log}   Format Tti In Stream Mode    ${csv_file_path}/${DL_name}
    ...    ${csv_file_path}/format_output_dl.csv
    run keyword if   ${format_tti_log}   Format Tti In Stream Mode    ${csv_file_path}/${UL_name}
    ...    ${csv_file_path}/format_output_ul.csv
    log to console    decode ttitrace finished.
    [Return]    ${csv_file_path}


Capture And Decode TTitrace
    [Arguments]    ${collector_names}=l2stream3_ttitrace    ${duration}=3
    Start Ttitrace With Streaming Mode    collector_names=${collector_names}
    Sleep    ${duration}s    reason=Wait for logs
    Stop Ttitrace    collector_names=${collector_names}
    ${csv_file_path}    Decode Ttitrace Log    collector_names=${collector_names}
    [Return]    ${csv_file_path}


Check TTI Log For Case04
    [Arguments]    ${UL_DL_csv_file_path_dict}    ${direction}
    ${csv_path}    Get From Dictionary    ${UL_DL_csv_file_path_dict}    ${direction}
    ${csv_path}    replace_csv_content    file_path=${csv_path}
    ${sfn_list}    ${slot_list}    TTI_Trace.get_sfn_slot_according_fdSchedData    file_path=${csv_path}    direction=${direction}
    ${result1}    Check_sfn_even_numbers_slot    sfn_list=${sfn_list}    slot_list=${slot_list}
    ${result2}    Check_sfn_Dividing_eight_slot    sfn_list=${sfn_list}    slot_list=${slot_list}
    Run Keyword And Continue On Failure    Should Be Equal    ${result1}     ${True}
    Run Keyword And Continue On Failure    Should Be Equal    ${result2}    ${True}

Check TTI Log For Case13
    [Arguments]    ${UL_DL_csv_file_path_dict}    ${direction}    ${msc_expect_value}    ${prb_sum_expect_value}
    ${csv_path}    Get From Dictionary    ${UL_DL_csv_file_path_dict}    ${direction}
    ${sfn_list}    ${slot_list}    ${rnti_list}    ${msc_list}    ${prb_list}     TTI_Stream.get_sfn_slot_rnti_mscTable_prb
    ...    file_path=${csv_path}    direction=${direction}
    ${msc_value}    Check_msc_list    msc_list=${msc_list}    expect_value=${msc_expect_value}
    ${prb_sum_value}    Check_Two_Rnti_Prb_Sum    sfn_list=${sfn_list}    slot_list=${slot_list}    rnti_list=${rnti_list}
    ...    prb_list=${prb_list}    expect_vaule=${prb_sum_expect_value}
    Run Keyword And Continue On Failure    Should Be Equal    ${msc_value}     ${True}
    Run Keyword And Continue On Failure    Should Be Equal    ${prb_sum_value}    ${True}

############### common Case Step ########################
Adjust PA
    [Arguments]      ${value_0}    ${value_1}    ${port_list_0}    ${port_list_1}
    Adjust the HBTE attenuation value    value=${value_0}    port_list=${port_list_0}
    Adjust the HBTE attenuation value    value=${value_1}     port_list=${port_list_1}



GNB2_TO_GNB1_PA_Adjust
    Adjust PA    value_0=${0}   value_1=${4}    port_list_0=${port_list[0:4]}    port_list_1=${port_list[4:8]}
    Adjust PA    value_0=${0}   value_1=${8}    port_list_0=${port_list[0:4]}    port_list_1=${port_list[4:8]}
    Adjust PA    value_0=${0}   value_1=${12}    port_list_0=${port_list[0:4]}    port_list_1=${port_list[4:8]}
    Adjust PA    value_0=${0}   value_1=${15}    port_list_0=${port_list[0:4]}    port_list_1=${port_list[4:8]}

GNB1_TO_GNB2_PA_Adjust
    Adjust PA    value_0=${0}   value_1=${4}    port_list_0=${port_list[4:8]}    port_list_1=${port_list[0:4]}
    Adjust PA    value_0=${0}   value_1=${8}    port_list_0=${port_list[4:8]}    port_list_1=${port_list[0:4]}
    Adjust PA    value_0=${0}   value_1=${12}    port_list_0=${port_list[4:8]}    port_list_1=${port_list[0:4]}
    Adjust PA    value_0=${0}   value_1=${15}    port_list_0=${port_list[4:8]}    port_list_1=${port_list[0:4]}




###############Case CB008927-G-IWK15-01 Step ########################
modify the parameter case IWK15_Old
    [Arguments]     ${cell_id}=${1}    ${new_value}=true    ${BTS_ID}=${BTS_ID_1}    ${NRBTS_ID}=${BTS_ID_1}
    ...    ${filter_param}=Activate FD resource allocation type1    ${abbr}=actRat1Alloc    ${gNB_ip}=${gNB_ip1}
    WEBUI Login    gNB_ip=${gNB_ip}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=${filter_param}    new_value=${new_value}    abbr=${abbr}
    ${error}    selenium_coam.validate_plan
    Log To Console    ${error}
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${false}    timeout=${180}
    CB008927_common_keyword.Check GNB on air    bts_host=${gNB_ip}
    Check Alarm List on BTS    allowed_list=${allowed_list}    bts_host=${gNB_ip}
    [Teardown]    WEBUI Logout

modify the parameter case IWK15
    [Arguments]     ${gnb_index}=${0}
    ${bts_ip}    set variable    ${tl.gnbs[${gnb_index}].dus[${0}].f1_m_ip_addr}
    Modify Parameters with json_702    bts_host=${bts_ip}    input_list=${IWK15_case_parameter_1}    connection=para_coam
    CB008927_common_keyword.Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}
    #modify bts2
    ${bts_ip_2}    set variable    ${tl.gnbs[${1}].dus[${0}].f1_m_ip_addr}
    Modify Parameters with json_702    bts_host=${bts_ip_2}    input_list=${IWK15_case_parameter_2}    connection=para_coam
    CB008927_common_keyword.Check GNB on air    bts_host=${bts_ip_2}
    Check Alarm List on BTS    allowed_list=${allowed_list}    bts_host=${bts_ip_2}

modify the parameter case IWK15_recovery
    [Arguments]     ${gnb_index}=${0}
    ${bts_ip}    set variable    ${tl.gnbs[${gnb_index}].dus[${0}].f1_m_ip_addr}
    Modify Parameters with json_702    bts_host=${bts_ip}    input_list=${IWK15_case_parameter_1_recovery}    connection=para_coam
    CB008927_common_keyword.Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}
    #modify bts2
    ${bts_ip_2}    set variable    ${tl.gnbs[${1}].dus[${0}].f1_m_ip_addr}
    Modify Parameters with json_702    bts_host=${bts_ip_2}    input_list=${IWK15_case_parameter_2_recovery}    connection=para_coam
    CB008927_common_keyword.Check GNB on air    bts_host=${bts_ip_2}
    Check Alarm List on BTS    allowed_list=${allowed_list}    bts_host=${bts_ip_2}

Adjust PA and Block cell IWK15
    [Arguments]    ${block_cell_list}=${cell_ID_list_gnb1[1:4]}    ${unblock_cell_id}=${23}
    Adjust PA    value_0=${0}   value_1=${15}
    ...    port_list_0=${port_list[0:4]}    port_list_1=${port_list[4:8]}
    FOR  ${item}  IN    @{block_cell_list}
        BLock or UnBlock Cell And Check Status    block_cell_id=${item}    unblock_cell_id=${unblock_cell_id}    block_flag=${True}
        ...    bts_host=${gNB_ip0}
    END
#    FOR  ${item}  IN    @{block_cell__LN_list}
#        BLock or UnBlock Cell And Check Status    block_cell_id=${item}    block_flag=${True}
#        ...    bts_host=${gNB_ip0}     cell_type=LN    cell_type_1=lte    CELL=CEL    Cell_block_status=${Cell_LTE_block_status}
#    END
    BLock or UnBlock Cell And Check Status    block_cell_id=${2}    unblock_cell_id=${1}    block_flag=${True}
    ...    bts_host=${gNB_ip1}    BTS_ID=${BTS_ID_1}   NRBTS_ID=${BTS_ID_1}

Unblock cells
    [Arguments]    ${unblock_cell_list}=${Empty_list_value}    ${gnb_index}=${0}
    ${bts_ip}    set variable    ${tl.gnbs[${gnb_index}].dus[${0}].f1_m_ip_addr}
    ${BTS_ID}    set variable    ${tl.gnbs[${gnb_index}].global_bts_id}
    FOR  ${item}  IN    @{unblock_cell_list}
        BLock or UnBlock Cell And Check Status    unblock_cell_id=${item}    block_flag=${False}    bts_host=${bts_ip}
        ...    BTS_ID=${BTS_ID}    NRBTS_ID=${BTS_ID}
    END

UE Attach and start traffic
    log to console    gnb1
    @{ue_index_list_attach}    create list    0    1    2
    FOR  ${item}  IN    @{ue_index_list_attach}
        attach single power ue     ue_index=${item}   UE=${tl.ues[${item}].capabilities[1]}   gnb_index=${0}
    END
    @{ue_index_list_2}    create list    0    1
    FOR    ${item}    IN    @{ue_index_list_2}
        Get Single all pointer variable    UE=${tl.ues[${item}].capabilities[1]}
        run keyword and continue on failure    run keyword if    ${True}    power_ue.Start traffic    ue_index=${item}    direction=ul
        ...    throughput=${1}M    duration=${20000}    ue_type=samsung    protocol=udp    appserver=${appserver_24}
        ...    iperf_port=${44900}    process_num=${1}    iperf_type=via_command
        sleep    1s
        run keyword and continue on failure    run keyword if    ${True}    power_ue.Start traffic    ue_index=${item}    direction=dl
        ...    throughput=${1}M    duration=${20000}    ue_type=samsung    protocol=udp    appserver=${appserver_24}
        ...    iperf_port=${44900}   process_num=${1}
    END
    UE Check Throughput    ul_list=${cell_list_gnb1[3:4]}    dl_list=${cell_list_gnb1[3:4]}     exp_ul_tp=${2}
    ...    exp_dl_tp=${1}    actCarrierAggregation=${false}
    ...    target_avg_percent_UL=${1}   target_avg_percent_DL=${1}    gnb_index=0     log_time=30s
        @{ue_index_list_1}    create list    2
        Start Multi Power Ue Traffic Ul And Dl      ue_index_list=${ue_index_list_1}   ul_throughput=${80}M    dl_throughput=${390}M
        ...    if_ul=${True}     if_dl=${True}     process_num=${1}    protocol=udp    ue_type=samsung
        UE Check Throughput    ul_list=${cell_list_gnb1[3:4]}    dl_list=${cell_list_gnb1[3:4]}     exp_ul_tp=${50}
        ...    exp_dl_tp=${200}    actCarrierAggregation=${false}
        ...    target_avg_percent_UL=${1}   target_avg_percent_DL=${1}    gnb_index=0     log_time=30s
        UE3 Make VoNR call


UE Attach Gnb1-Gnb2 and check log&throughput case iwk15
    [Arguments]    ${item}=1
#    FOR    ${item}   IN RANGE   ${2}
        log to console    gnb1-gnb2
         Start Catch Trace Log   DU_OAM_IP=${gNB_ip0}    connection=alias    filename=Tcpdump_Gnb0_IWK15_${item}0
         Start Catch Trace Log   DU_OAM_IP=${gNB_ip1}    connection=alias    filename=Tcpdump_Gnb1_IWK15_${item}0
         GNB1_TO_GNB2_PA_Adjust
         sleep    3s
         Adjust the HBTE attenuation value    value=${127}     port_list=${port_list[0:4]}
         sleep    1s
         Stop And Copy Log To UTE    DU_OAM_IP=${gNB_ip0}    connection=alias    filename=Tcpdump_Gnb0_IWK15_${item}0.pcap
         Stop And Copy Log To UTE    DU_OAM_IP=${gNB_ip1}    connection=alias    filename=Tcpdump_Gnb1_IWK15_${item}0.pcap
         Pcap chang to txt    pcap_name=Tcpdump_Gnb0_IWK15_${item}0.pcap     text_name=Tcpdump_Gnb0_IWK15_${item}0.txt
         Pcap chang to txt    pcap_name=Tcpdump_Gnb1_IWK15_${item}0.pcap     text_name=Tcpdump_Gnb1_IWK15_${item}0.txt
         Check wireshark log Parameter    txt_filename=Tcpdump_Gnb1_IWK15_${item}0.txt
         ...    sgnb_chg_ho_message=${attached_pci_11}  logpath=${LOG_PATH}
         Check Flow Message    text_name=Tcpdump_Gnb1_IWK15_${item}0.txt    message_dict=${gnb_target_message_flow}
         Check Flow Message    text_name=Tcpdump_Gnb0_IWK15_${item}0.txt    message_dict=${gnb_source_message_flow}
         UE Check Throughput    ul_list=${cell_list_gnb2[0:1]}    dl_list=${cell_list_gnb2[0:1]}     exp_ul_tp=${50}
        ...    exp_dl_tp=${200}    actCarrierAggregation=${false}
        ...    target_avg_percent_UL=${1}   target_avg_percent_DL=${1}    gnb_index=1     log_time=30s
        log to console    gnb2-gnb1
        Start Catch Trace Log   DU_OAM_IP=${gNB_ip0}    connection=alias    filename=Tcpdump_Gnb0_IWK15_${item}1
        Start Catch Trace Log   DU_OAM_IP=${gNB_ip1}    connection=alias    filename=Tcpdump_Gnb1_IWK15_${item}1
        GNB2_TO_GNB1_PA_Adjust
        sleep    3s
        Adjust the HBTE attenuation value    value=${127}     port_list=${port_list[4:8]}
        sleep    1s
        Stop And Copy Log To UTE    DU_OAM_IP=${gNB_ip0}    connection=alias    filename=Tcpdump_Gnb0_IWK15_${item}1.pcap
        Stop And Copy Log To UTE    DU_OAM_IP=${gNB_ip1}    connection=alias    filename=Tcpdump_Gnb1_IWK15_${item}1.pcap
        Pcap chang to txt    pcap_name=Tcpdump_Gnb0_IWK15_${item}1.pcap     text_name=Tcpdump_Gnb0_IWK15_${item}1.txt
        Pcap chang to txt    pcap_name=Tcpdump_Gnb1_IWK15_${item}1.pcap     text_name=Tcpdump_Gnb1_IWK15_${item}1.txt
        Check wireshark log Parameter    txt_filename=Tcpdump_Gnb0_IWK15_${item}1.txt
        ...    sgnb_chg_ho_message=${attached_pci_244}  logpath=${LOG_PATH}
        Check Flow Message    text_name=Tcpdump_Gnb0_IWK15_${item}1.txt    message_dict=${gnb_target_message_flow}
        Check Flow Message    text_name=Tcpdump_Gnb1_IWK15_${item}1.txt    message_dict=${gnb_source_message_flow}
        UE Check Throughput    ul_list=${cell_list_gnb1[3:4]}    dl_list=${cell_list_gnb1[3:4]}     exp_ul_tp=${50}
        ...    exp_dl_tp=${200}    actCarrierAggregation=${false}
        ...    target_avg_percent_UL=${1}   target_avg_percent_DL=${1}    gnb_index=0     log_time=30s
#    END
    [Teardown]    Stop traffic and detech UE iwk15

Stop traffic and detech UE iwk15
    @{ue_index_list_2}    create list    2
    stop multi power ue traffic ul and dl    ue_index_list=${ue_index_list_2}   if_ul=${True}     if_dl=${True}    protocol=udp
    @{ue_index_list_3}    create list    0    1
    FOR  ${item}  IN    @{ue_index_list_3}
        run keyword if    ${True}    power_ue.Stop traffic    direction=ul    ue_index=${item}    ue_type=samsung    iperf_type=via_command
        ...    protocol=udp    iperf_port=${44900}
        run keyword if    ${True}    power_ue.Stop traffic    direction=dl    ue_index=${item}    ue_type=samsung   protocol=udp
        ...    iperf_port=${44900}
    END
    UE hang up VoNR call
    DETACH UE IWK15

DETACH UE IWK15
    @{ue_index_list_1}    create list    0    1    2
    FOR  ${item}  IN    @{ue_index_list_1}
        detach multi power ue    ue_index=${item}    UE=${tl.ues[${item}].capabilities[1]}
    END


###############Case CB008927-G-HR1-01 Step ########################
Case Suit Setup HR1
    Log to console    case setup...
    robot_common_operations.Common Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=49
    AlarmWatchdog.add_allow_alarms    fault_id=7311
    AlarmWatchdog.add_allow_alarms    fault_id=6327
    Check Alarm List on BTS    allowed_list=${allowed_list}
    Check Alarm List on BTS    allowed_list=${allowed_list}    bts_host=${gnb_ip1}



modify the parameter case HR1_Old
    [Arguments]     ${cell_id}=${23}    ${new_value}=true    ${BTS_ID}=${BTS_ID_0}    ${NRBTS_ID}=${BTS_ID_0}
    WEBUI Login
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=Activate FD resource allocation type1   new_value=${new_value}    abbr=actRat1Alloc
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=Activate 256QAM in DL   new_value=false    abbr=actDl256Qa
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=Activate downlink dynamic BLER target   new_value=false    abbr=actDlLaDynBlerTarget
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=Activate adaptive retransmission based on reserved MCS   new_value=false    abbr=actAdaptiveReTxResMcs
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=Activate link adaptation for high reliability DRB   new_value=${new_value}    abbr=actLAForHiReliab
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=Maximum MCS of 64QAM low SE MCS table for DL of HR for RANK1   new_value=${25}    abbr=dllaMcsMax64qamLowSERANK1HR
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=Maximum MCS of 64QAM low SE MCS table for DL of HR for RANK2   new_value=${25}    abbr=dllaMcsMax64qamLowSERANK2HR
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=Maximum MCS of 64QAM low SE MCS table for DL of HR for RANK3   new_value=${20}    abbr=dllaMcsMax64qamLowSERANK3HR
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=Maximum MCS of 64QAM low SE MCS table for DL of HR for RANK4   new_value=${20}    abbr=dllaMcsMax64qamLowSERANK4HR
    ${error}    selenium_coam.validate_plan
    Log To Console    ${error}
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${false}    timeout=${180}
    CB008927_common_keyword.Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}
    [Teardown]    WEBUI Logout

modify the parameter case HR1
    [Arguments]     ${gnb_index}=${0}
    ${bts_ip}    set variable    ${tl.gnbs[${gnb_index}].dus[${0}].f1_m_ip_addr}
    Modify Parameters with json_702    bts_host=${bts_ip}    input_list=${HR1_case_parameters}    connection=para_coam
    CB008927_common_keyword.Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}

modify the parameter case HR1_recovery
    [Arguments]     ${gnb_index}=${0}
    ${bts_ip}    set variable    ${tl.gnbs[${gnb_index}].dus[${0}].f1_m_ip_addr}
    Modify Parameters with json_702    bts_host=${bts_ip}    input_list=${HR1_case_parameters_recovery}    connection=para_coam
    CB008927_common_keyword.Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}

Adjust PA and Block cell case HR1
    [Arguments]    ${block_cell_list}=${cell_ID_list_gnb1[1:4]}    ${unblock_cell_id}=${23}
    Adjust PA    value_0=${0}   value_1=${127}
    ...    port_list_0=${port_list[0:4]}    port_list_1=${port_list[4:8]}
    FOR  ${item}  IN    @{block_cell_list}
        BLock or UnBlock Cell And Check Status    block_cell_id=${item}    unblock_cell_id=${unblock_cell_id}    block_flag=${True}
        ...    bts_host=${gNB_ip0}
    END
#    FOR  ${item}  IN    @{block_cell__LN_list}
#        BLock or UnBlock Cell And Check Status    block_cell_id=${item}    block_flag=${True}
#        ...    bts_host=${gNB_ip0}     cell_type=LN    cell_type_1=lte    CELL=CEL    Cell_block_status=${Cell_LTE_block_status}
#    END
    @{block_cell_list_GNB1}    create list    1    2
    FOR  ${item}  IN    @{block_cell_list_GNB1}
        BLock or UnBlock Cell And Check Status    block_cell_id=${item}        block_flag=${True}
        ...    bts_host=${gNB_ip1}    BTS_ID=${BTS_ID_1}   NRBTS_ID=${BTS_ID_1}
    END


UE3 Attach Gnb1 and check log&throughput case HR1
    attach single power ue     ue_index=${2}   UE=${tl.ues[${2}].capabilities[1]}   gnb_index=${0}
    Get Single all pointer variable    UE=${tl.ues[${2}].capabilities[1]}
    @{iperf_port}    create list    44903    44904    44906    44907
    #44903/44904/44906/44907
    FOR  ${item}  IN    @{iperf_port}
        run keyword and continue on failure    run keyword if    ${True}    power_ue.Start traffic    ue_index=${2}    direction=ul
        ...    throughput=${15}M    duration=${200000}    ue_type=samsung    protocol=udp    appserver=${appserver_24}
        ...    iperf_port=${item}    process_num=${1}    iperf_type=via_command
        sleep    1s
        run keyword and continue on failure    run keyword if    ${True}    power_ue.Start traffic    ue_index=${2}    direction=dl
        ...    throughput=${30}M    duration=${200000}    ue_type=samsung    protocol=udp    appserver=${appserver_24}
        ...    iperf_port=${item}   process_num=${1}
    END
    UE Check Throughput    ul_list=${cell_list_gnb1[3:4]}    dl_list=${cell_list_gnb1[3:4]}     exp_ul_tp=${25}
    ...    exp_dl_tp=${85}    actCarrierAggregation=${false}
    ...    target_avg_percent_UL=${1}   target_avg_percent_DL=${1}    gnb_index=0     log_time=30s
#    log to console    PA0-48
#    FOR    ${item1}   IN RANGE   ${2}
        Start Catch Trace Log   DU_OAM_IP=${gNB_ip0}    connection=alias    filename=Tcpdump_Gnb0_HR1
#        Capture TTI log 8927    log_time=30    bts_ip=${gNB_ip0}
#        Adjust the HBTE HR1    range=${6}    item1=${item1}
#        Connect to gnb coam via ssl    bts_host=${gNB_ip0}     username=${gNB_username}    password=${gNB_password}    connection=GNB_OAM
#        Stop Ttitrace    collector_names=l2stream3_ttitrace
#        ${UL_DL_csv_file_path_dict}    check TTI LOG   filter=dlFdSchedData
#        ${file_path_DL}    Get from Dictionary    ${UL_DL_csv_file_path_dict}    DL
#        Check mcsTable Value    file_path=${file_path_DL}    expect_mcsTable_value=QAM64LOWSE
#        Check numOfLayers corresponding rrmDlProposedMcs value    file_path=${file_path_DL}
#        ${UL_DL_csv_file_path_dict}    check TTI LOG   filter=dlHarqRxDataArray
#        ${file_path_DL}    Get from Dictionary    ${UL_DL_csv_file_path_dict}    DL
#        Check ul And dl Bler       dl_file_path=${file_path_DL}
#        ${UL_DL_csv_file_path_dict}    check TTI LOG   filter=ulHarqRxData
#        ${file_path_UL}    Get from Dictionary    ${UL_DL_csv_file_path_dict}    UL
#        Check ul And dl Bler    ul_file_path=${file_path_UL}
#        Run keyword and ignore error    COAM Teardown gnb connections    connection=GNB_OAM
#    END
    log to console    PA0-68
    Capture TTI log 8927    bts_ip=${gNB_ip0}
    FOR    ${item}   IN RANGE   ${7}
        ${value}    evaluate   (${item}+1)*10
        Adjust the HBTE attenuation value    value=${value}     port_list=${port_list[0:4]}
    END
    Adjust the HBTE attenuation value    value=${68}     port_list=${port_list[0:4]}
    Connect to gnb coam via ssl    bts_host=${gNB_ip0}     username=${gNB_username}    password=${gNB_password}    connection=GNB_OAM
    Stop Ttitrace    collector_names=l2stream3_ttitrace
    ${UL_DL_csv_file_path_dict}    check TTI LOG   filter=dlFdSchedData
    ${file_path_DL}    Get from Dictionary    ${UL_DL_csv_file_path_dict}    DL
    Check mcsTable Value    file_path=${file_path_DL}    expect_mcsTable_value=QAM64LOWSE
    Check numOfLayers corresponding rrmDlProposedMcs value    file_path=${file_path_DL}
    ${UL_DL_csv_file_path_dict}    check TTI LOG   filter=dlHarqRxDataArray
    ${file_path_DL}    Get from Dictionary    ${UL_DL_csv_file_path_dict}    DL
    Check ul And dl Bler       dl_file_path=${file_path_DL}    EXP_UL=${2}    EXP_DL=${2}
    ${UL_DL_csv_file_path_dict}    check TTI LOG   filter=ulHarqRxData
    ${file_path_UL}    Get from Dictionary    ${UL_DL_csv_file_path_dict}    UL
    Check ul And dl Bler    ul_file_path=${file_path_UL}    EXP_UL=${2}    EXP_DL=${2}
    Run keyword and ignore error    COAM Teardown gnb connections    connection=GNB_OAM
    log to console    check tcpdump
    Stop And Copy Log To UTE    DU_OAM_IP=${gNB_ip0}    connection=alias    filename=Tcpdump_Gnb0_HR1.pcap
    Pcap chang to txt    pcap_name=Tcpdump_Gnb0_HR1.pcap     text_name=Tcpdump_Gnb0_HR1.txt
    Check wireshark log Parameter    txt_filename=Tcpdump_Gnb0_HR1.txt
    ...    sgnb_chg_ho_message=${resourceAllocation_1_gnb1}  logpath=${LOG_PATH}
#    log to console    PA68-48
#    Capture TTI log 8927    bts_ip=${gNB_ip0}
#    FOR    ${item}   IN RANGE   ${5}
#        ${value}    evaluate   68-(${item}+1)*4
#        Adjust the HBTE attenuation value    value=${value}     port_list=${port_list[0:4]}
#    END
#    Connect to gnb coam via ssl    bts_host=${gNB_ip0}     username=${gNB_username}    password=${gNB_password}    connection=GNB_OAM
#    Stop Ttitrace    collector_names=l2stream3_ttitrace
#    ${UL_DL_csv_file_path_dict}    check TTI LOG   filter=dlFdSchedData
#    ${file_path_DL}    Get from Dictionary    ${UL_DL_csv_file_path_dict}    DL
#    Check mcsTable Value    file_path=${file_path_DL}    expect_mcsTable_value=QAM64LOWSE
#    Check numOfLayers corresponding rrmDlProposedMcs value    file_path=${file_path_DL}
#    ${UL_DL_csv_file_path_dict}    check TTI LOG   filter=dlHarqRxDataArray
#    ${file_path_DL}    Get from Dictionary    ${UL_DL_csv_file_path_dict}    DL
#    Check ul And dl Bler       dl_file_path=${file_path_DL}
#    ${UL_DL_csv_file_path_dict}    check TTI LOG   filter=ulHarqRxData
#    ${file_path_UL}    Get from Dictionary    ${UL_DL_csv_file_path_dict}    UL
#    Check ul And dl Bler    ul_file_path=${file_path_UL}
#    Run keyword and ignore error    COAM Teardown gnb connections    connection=GNB_OAM
#    log to console    check tcpdump
#    Stop And Copy Log To UTE    DU_OAM_IP=${gNB_ip0}    connection=alias    filename=Tcpdump_Gnb0_HR1.pcap
#    Pcap chang to txt    pcap_name=Tcpdump_Gnb0_HR1.pcap     text_name=Tcpdump_Gnb0_HR1.txt
#    Check wireshark log Parameter    txt_filename=Tcpdump_Gnb0_HR1.txt
#    ...    sgnb_chg_ho_message=${resourceAllocation_1_gnb1}  logpath=${LOG_PATH}
#    log to console    PA48-0
#    FOR    ${item1}   IN RANGE   ${2}
#        Start Catch Trace Log   DU_OAM_IP=${gNB_ip0}    connection=alias    filename=Tcpdump_Gnb0_HR1
#        Capture TTI log 8927    bts_ip=${gNB_ip0}
#        Adjust the HBTE HR1 48-0    range=${6}    item1=${item1}
#        Connect to gnb coam via ssl    bts_host=${gNB_ip0}     username=${gNB_username}    password=${gNB_password}    connection=GNB_OAM
#        Stop Ttitrace    collector_names=l2stream3_ttitrace
#        ${UL_DL_csv_file_path_dict}    check TTI LOG   filter=dlFdSchedData
#        ${file_path_DL}    Get from Dictionary    ${UL_DL_csv_file_path_dict}    DL
#        Check mcsTable Value    file_path=${file_path_DL}    expect_mcsTable_value=QAM64LOWSE
#        Check numOfLayers corresponding rrmDlProposedMcs value    file_path=${file_path_DL}
#        ${UL_DL_csv_file_path_dict}    check TTI LOG   filter=dlHarqRxDataArray
#        ${file_path_DL}    Get from Dictionary    ${UL_DL_csv_file_path_dict}    DL
#        Check ul And dl Bler       dl_file_path=${file_path_DL}
#        ${UL_DL_csv_file_path_dict}    check TTI LOG   filter=ulHarqRxData
#        ${file_path_UL}    Get from Dictionary    ${UL_DL_csv_file_path_dict}    UL
#        Check ul And dl Bler    ul_file_path=${file_path_UL}
#        Run keyword and ignore error    COAM Teardown gnb connections    connection=GNB_OAM
#    END
    [Teardown]  stop traffic and detact UE

stop traffic and detact UE
    @{iperf_port}    create list    44903    44904    44906    44907
    FOR  ${item}  IN    @{iperf_port}
        run keyword if    ${True}    power_ue.Stop traffic    direction=ul    ue_index=${2}    ue_type=samsung    iperf_type=via_command
        ...    protocol=udp    iperf_port=${item}   appserver=${appserver_24}
        run keyword if    ${True}    power_ue.Stop traffic    direction=dl    ue_index=${2}    ue_type=samsung   protocol=udp
        ...    iperf_port=${item}    appserver=${appserver_24}
    END
    detach multi power ue    ue_index=${2}    UE=${tl.ues[${2}].capabilities[1]}

Adjust the HBTE HR1
    [Arguments]    ${range}    ${item1}
    FOR    ${item}   IN RANGE   ${range}
        ${value}    evaluate   (${item}+1+6*${item1})*4
        Adjust the HBTE attenuation value    value=${value}     port_list=${port_list[0:4]}
    END

Adjust the HBTE HR1 48-0
    [Arguments]    ${range}    ${item1}
    FOR    ${item}   IN RANGE   ${range}
        ${value}    evaluate   48-(${item}+1+6*${item1})*4
        Adjust the HBTE attenuation value    value=${value}     port_list=${port_list[0:4]}
    END


###############Case CB008927-G-IWK12-01 Step ########################
modify the parameter case IWK12_Old
    [Arguments]     ${cell_id}=${23}    ${BTS_ID}=${BTS_ID_0}    ${NRBTS_ID}=${BTS_ID_0}
    WEBUI Login
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=A3 offset SSB RSRP   new_value=3    abbr=a3OffsetSsbRsrp
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}/NRHOIF-1
    ...    filter_param=A3 offset SSB RSRP for VoNr UEs  new_value=3    abbr=a3OffsetSsbRsrpVoNr
    ${error}    selenium_coam.validate_plan
    Log To Console    ${error}
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${false}    timeout=${180}
    CB008927_common_keyword.Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}
    [Teardown]    WEBUI Logout

modify the parameter case IWK12
    [Arguments]     ${gnb_index}=${0}
    ${bts_ip}    set variable    ${tl.gnbs[${gnb_index}].dus[${0}].f1_m_ip_addr}
    Modify Parameters with json_702    bts_host=${bts_ip}    input_list=${IWK12_case_parameter}    connection=para_coam
    CB008927_common_keyword.Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}

modify the parameter case IWK12_recovery
    [Arguments]     ${gnb_index}=${0}
    ${bts_ip}    set variable    ${tl.gnbs[${gnb_index}].dus[${0}].f1_m_ip_addr}
    Modify Parameters with json_702    bts_host=${bts_ip}    input_list=${IWK12_case_parameter_recovery}    connection=para_coam
    CB008927_common_keyword.Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}

BLock or UnBlock Cell And Check Status
    [Arguments]    ${block_cell_id}=None    ${unblock_cell_id}=None    ${block_flag}=${True}    ${bts_host}=${gnb_ip}
    ...    ${cell_type_1}=nr    ${cell_type}=NR    ${BTS_ID}=${BTS_ID_0}   ${NRBTS_ID}=${BTS_ID_0}    ${CELL}=CELL
    ...    ${Cell_block_status}=${Cell_block_status}
    @{allowed_cell_block_list}    create list    @{allowed_list}    ${49}
    @{not_allowed_list}    create list   ${49}
    ${operate_cell_id}    Set Variable If    ${block_flag}    ${block_cell_id}    ${unblock_cell_id}
    Block or UnBlock Single Cell    cell_id=${operate_cell_id}    block_flag=${block_flag}    bts_host=${bts_host}
    ...    cell_type=${cell_type}    BTS_ID=${BTS_ID}   NRBTS_ID=${NRBTS_ID}    cell_type=${cell_type}    CELL=${CELL}
    run keyword if  ${block_flag}    Check Alarm List on BTS    allowed_list=${allowed_cell_block_list}    bts_host=${bts_host}
#    ...    ELSE    Check Alarm List on BTS    allowed_list=${allowed_list}    bts_host=${bts_host}
    ${expect_item_status_dict}    create dictionary
    run keyword if    ${block_cell_id} != None    Set to dictionary    ${expect_item_status_dict}
    ...    ${cell_type}${CELL}-${block_cell_id}=${Cell_block_status}
#    run keyword if    ${unblock_cell_id} != None    Set to dictionary    ${expect_item_status_dict}
#    ...    ${cell_type}${CELL}-${unblock_cell_id}=${Cell_unblock_status}
    Check All RU or Cell Status     expect_item_status_dict=${expect_item_status_dict}    if_ru=${False}   bts_host=${bts_host}
    ...    cell_type=${cell_type_1}

Block and unblock Gnb1&Gnb2 cell
    [Arguments]    ${block_cell_list}=${cell_ID_list_gnb1[1:4]}    ${unblock_cell_id}=${23}
    ...    ${block_cell_id_gnb1}=${1}    ${unblock_cell_id_gnb1}=${2}
    FOR  ${item}  IN    @{block_cell_list}
        BLock or UnBlock Cell And Check Status    block_cell_id=${item}    unblock_cell_id=${unblock_cell_id}    block_flag=${True}
        ...    bts_host=${gNB_ip0}
    END
    BLock or UnBlock Cell And Check Status    block_cell_id=${block_cell_id_gnb1}    unblock_cell_id=${unblock_cell_id_gnb1}    block_flag=${True}
    ...    bts_host=${gNB_ip1}    BTS_ID=${BTS_ID_1}   NRBTS_ID=${BTS_ID_1}

Adjust PA and 3UE attach Gnb2
    Adjust PA    value_0=${60}    value_1=${44}
    ...    port_list_0=${port_list[0:4]}    port_list_1=${port_list[4:8]}
    @{ue_index_list}    create list    0    1    2
    FOR  ${item}  IN    @{ue_index_list}
        Start Catch Trace Log   DU_OAM_IP=${gNB_ip1}    connection=alias    filename=Tcpdump_Gnb2_iwk12_${item}
        attach single power ue     ue_index=${item}   UE=${tl.ues[${item}].capabilities[1]}   gnb_index=${1}
        Stop And Copy Log To UTE    DU_OAM_IP=${gNB_ip1}    connection=alias    filename=Tcpdump_Gnb2_iwk12_${item}.pcap
        Pcap chang to txt    pcap_name=Tcpdump_Gnb2_iwk12_${item}.pcap     text_name=Tcpdump_Gnb2_iwk12_${item}.txt
        Check wireshark log Parameter    txt_filename=Tcpdump_Gnb2_iwk12_${item}.txt
        ...    sgnb_chg_ho_message=${attached_pci_12}  logpath=${LOG_PATH}
    END



UE3 Make VoNR call
    [Arguments]    ${ue_index}=${2}    ${phone_number}=6688
    Make a VoNR call(+6688) on X70    ue_index=${ue_index}    serial_number=${tl.ues[${ue_index}].serial_number}
    ...    phone_number=${phone_number}

UE hang up VoNR call
    [Arguments]    ${ue_index}=${2}
    hang up VoNR call    ue_index=${ue_index}

hang up VoNR call
    [Arguments]    ${ue_index}=${2}    ${serial_number}=${tl.ues[${ue_index}].serial_number}
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 6    connection=cygwin${ue_index}
    sleep   1s
    csn.disconnect      connection=cygwin${ue_index}

Make a VoNR call(+6688) on X70
    [Arguments]    ${ue_index}=${2}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${phone_number}=6688
    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin${ue_index}
    sleep   5s
    #####Press the Home button to open the screen#####
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 3    connection=cygwin${ue_index}
    sleep   2s
    #####Swipe up to unlock the phone#####
    csn.send_command    command=adb -s ${serial_number} shell input swipe 500 2050 500 800    connection=cygwin${ue_index}
    sleep    2s
    #####make VoNR call#####
    csn.send_command    command=adb -s ${serial_number} shell am start -a android.intent.action.CALL tel:+${phone_number}
    ...    connection=cygwin${ue_index}
    sleep   1s
    [Teardown]    csn.disconnect      connection=cygwin${ue_index}

UE123 Attach Gnb1-Gnb2 and check log&throughput
#    [Arguments]
#    [Arguments]
#    ...    ${port_list_0}=${port_list[0:4]}    ${port_list_1}=${port_list[4:8]}    ${port_list_2}=${port_list[0:4]}
#    ...    ${cell_check_list}=${cell_list_gnb2[1:2]}    ${target_avg_percent_UL}=1  ${target_avg_percent_DL}=1
#    ...    ${filename0}=Tcpdump_Gnb01    ${filename1}=Tcpdump_Gnb11    ${text_name_source}=Tcpdump_Gnb01
#    ...    ${text_name_target}=Tcpdump_Gnb11    ${attached_pci}=${attached_pci_11}    ${resourceAllocation_target}=${resourceAllocation_0}
    log to console    VoNR call
    UE3 Make VoNR call
    @{ue_index_list}    create list    0    1
    FOR    ${item}    IN    @{ue_index_list}
        Get Single all pointer variable    UE=${tl.ues[${item}].capabilities[1]}
        run keyword and continue on failure    run keyword if    ${True}    power_ue.Start traffic    ue_index=${item}    direction=ul
        ...    throughput=${1}M    duration=${20000}    ue_type=samsung    protocol=udp    appserver=${appserver_24}
        ...    iperf_port=${44900}    process_num=${1}    iperf_type=via_command
        sleep    1s
        run keyword and continue on failure    run keyword if    ${True}    power_ue.Start traffic    ue_index=${item}    direction=dl
        ...    throughput=${1}M    duration=${20000}    ue_type=samsung    protocol=udp    appserver=${appserver_24}
        ...    iperf_port=${44900}   process_num=${1}
    END
    UE Check Throughput    ul_list=${cell_list_gnb2[1:2]}    dl_list=${cell_list_gnb2[1:2]}     exp_ul_tp=${2}
    ...    exp_dl_tp=${1}    actCarrierAggregation=${false}
    ...    target_avg_percent_UL=${1}   target_avg_percent_DL=${1}    gnb_index=1     log_time=30s
#    FOR    ${item}   IN RANGE   ${2}
        log to console    gnb2-gnb1
        Start Catch Trace Log   DU_OAM_IP=${gNB_ip0}    connection=alias    filename=Tcpdump_Gnb1_iwk12_1
        Start Catch Trace Log   DU_OAM_IP=${gNB_ip1}    connection=alias    filename=Tcpdump_Gnb2_iwk12_2
        log to console    Check TTI Log For bler
        Capture TTI log 8927    bts_ip=${gNB_ip1}    gnb_index=1    collector_names=l2stream3_ttitrace
        sleep    2s
        Connect to gnb coam via ssl    bts_host=${gNB_ip1}     username=${gNB_username}    password=${gNB_password}    connection=GNB_OAM
        Stop Ttitrace    collector_names=l2stream3_ttitrace
        ${UL_DL_csv_file_path_dict}    check TTI LOG   filter=dlHarqRxDataArray
        ${file_path_DL}    Get from Dictionary    ${UL_DL_csv_file_path_dict}    DL
        Check ul And dl Bler       dl_file_path=${file_path_DL}    EXP_UL=${2}    EXP_DL=${2}
        ${UL_DL_csv_file_path_dict}    check TTI LOG   filter=ulHarqRxData
        ${file_path_UL}    Get from Dictionary    ${UL_DL_csv_file_path_dict}    UL
        Check ul And dl Bler    ul_file_path=${file_path_UL}    EXP_UL=${2}    EXP_DL=${2}
        Run keyword and ignore error    COAM Teardown gnb connections    connection=GNB_OAM
        Adjust the HBTE attenuation value    value=${68}     port_list=${port_list[4:8]}
        sleep    30s
        log to console    Check TTI Log For bler GNB0
        Check Log For GNB0
        log to console    gnb1-gnb2
        Start Catch Trace Log   DU_OAM_IP=${gNB_ip0}    connection=alias    filename=Tcpdump_Gnb1_iwk12_1
        Start Catch Trace Log   DU_OAM_IP=${gNB_ip1}    connection=alias    filename=Tcpdump_Gnb2_iwk12_2
        Adjust the HBTE attenuation value    value=${44}     port_list=${port_list[4:8]}
        sleep    30s
        log to console    Check TTI Log For bler GNB1
        Check Log For GNB1
#    END
    [Teardown]    Stop traffic and detech UE iwk12

Check Log For GNB1
        Capture TTI log 8927    bts_ip=${gNB_ip1}    gnb_index=1    collector_names=l2stream3_ttitrace
        sleep    2s
        Connect to gnb coam via ssl    bts_host=${gNB_ip1}     username=${gNB_username}    password=${gNB_password}    connection=GNB_OAM
        Stop Ttitrace    collector_names=l2stream3_ttitrace
        UE Check Throughput    ul_list=${cell_list_gnb2[1:2]}    dl_list=${cell_list_gnb2[1:2]}     exp_ul_tp=${1}
        ...    exp_dl_tp=${1}    actCarrierAggregation=${false}
        ...    target_avg_percent_UL=${1}   target_avg_percent_DL=${1}    gnb_index=1     log_time=30s
        ${UL_DL_csv_file_path_dict}    check TTI LOG   filter=dlHarqRxDataArray
        ${file_path_DL}    Get from Dictionary    ${UL_DL_csv_file_path_dict}    DL
        Check ul And dl Bler       dl_file_path=${file_path_DL}    EXP_UL=${2}    EXP_DL=${2}
        ${UL_DL_csv_file_path_dict}    check TTI LOG   filter=ulHarqRxData
        ${file_path_UL}    Get from Dictionary    ${UL_DL_csv_file_path_dict}    UL
        Check ul And dl Bler    ul_file_path=${file_path_UL}    EXP_UL=${2}    EXP_DL=${2}
        Run keyword and ignore error    COAM Teardown gnb connections    connection=GNB_OAM
        log to console    Check tcpdump
        Stop And Copy Log To UTE    DU_OAM_IP=${gNB_ip0}    connection=alias    filename=Tcpdump_Gnb1_iwk12_1.pcap
        Stop And Copy Log To UTE    DU_OAM_IP=${gNB_ip1}    connection=alias    filename=Tcpdump_Gnb2_iwk12_2.pcap
        Pcap chang to txt    pcap_name=Tcpdump_Gnb1_iwk12_1.pcap     text_name=Tcpdump_Gnb1_iwk12_1.txt
        Pcap chang to txt    pcap_name=Tcpdump_Gnb2_iwk12_2.pcap     text_name=Tcpdump_Gnb2_iwk12_2.txt
        Check wireshark log Parameter    txt_filename=Tcpdump_Gnb2_iwk12_2.txt
        ...    sgnb_chg_ho_message=${attached_pci_12}  logpath=${LOG_PATH}
        Check Flow Message    text_name=Tcpdump_Gnb2_iwk12_2.txt    message_dict=${gnb_target_message_flow}
        Check Flow Message    text_name=Tcpdump_Gnb1_iwk12_1.txt    message_dict=${gnb_source_message_flow}
#        UE Check Throughput    ul_list=${cell_list_gnb2[1:2]}    dl_list=${cell_list_gnb2[1:2]}     exp_ul_tp=${1}
#        ...    exp_dl_tp=${1}    actCarrierAggregation=${false}
#        ...    target_avg_percent_UL=${1}   target_avg_percent_DL=${1}    gnb_index=1     log_time=30s

Check Log For GNB0
        Capture TTI log 8927    bts_ip=${gNB_ip0}
        sleep    2s
        Connect to gnb coam via ssl    bts_host=${gNB_ip0}     username=${gNB_username}    password=${gNB_password}    connection=GNB_OAM
        Stop Ttitrace    collector_names=l2stream3_ttitrace
        ${UL_DL_csv_file_path_dict}    check TTI LOG   filter=dlHarqRxDataArray
        ${file_path_DL}    Get from Dictionary    ${UL_DL_csv_file_path_dict}    DL
        Check ul And dl Bler       dl_file_path=${file_path_DL}    EXP_UL=${2}    EXP_DL=${2}
        ${UL_DL_csv_file_path_dict}    check TTI LOG   filter=ulHarqRxData
        ${file_path_UL}    Get from Dictionary    ${UL_DL_csv_file_path_dict}    UL
        Check ul And dl Bler    ul_file_path=${file_path_UL}    EXP_UL=${2}    EXP_DL=${2}
        Run keyword and ignore error    COAM Teardown gnb connections    connection=GNB_OAM
        log to console    Check tcpdump
        Stop And Copy Log To UTE    DU_OAM_IP=${gNB_ip0}    connection=alias    filename=Tcpdump_Gnb1_iwk12_1.pcap
        Stop And Copy Log To UTE    DU_OAM_IP=${gNB_ip1}    connection=alias    filename=Tcpdump_Gnb2_iwk12_2.pcap
        Pcap chang to txt    pcap_name=Tcpdump_Gnb1_iwk12_1.pcap     text_name=Tcpdump_Gnb1_iwk12_1.txt
        Pcap chang to txt    pcap_name=Tcpdump_Gnb2_iwk12_2.pcap     text_name=Tcpdump_Gnb2_iwk12_2.txt
        Check wireshark log Parameter    txt_filename=Tcpdump_Gnb1_iwk12_1.txt
        ...    sgnb_chg_ho_message=${attached_pci_244}  logpath=${LOG_PATH}
        Check Flow Message    text_name=Tcpdump_Gnb1_iwk12_1.txt    message_dict=${gnb_target_message_flow}
        Check Flow Message    text_name=Tcpdump_Gnb2_iwk12_2.txt    message_dict=${gnb_source_message_flow}
        UE Check Throughput    ul_list=${cell_list_gnb1[3:4]}    dl_list=${cell_list_gnb1[3:4]}     exp_ul_tp=${1}
        ...    exp_dl_tp=${1}    actCarrierAggregation=${false}
        ...    target_avg_percent_UL=${1}   target_avg_percent_DL=${1}    gnb_index=0     log_time=30s

Stop traffic and detech UE iwk12
    @{ue_index_list_3}    create list    0    1
    FOR  ${item}  IN    @{ue_index_list_3}
        run keyword if    ${True}    power_ue.Stop traffic    direction=ul    ue_index=${item}    ue_type=samsung    iperf_type=via_command
        ...    protocol=udp    iperf_port=${44900}
        run keyword if    ${True}    power_ue.Stop traffic    direction=dl    ue_index=${item}    ue_type=samsung   protocol=udp
        ...    iperf_port=${44900}
    END
    UE hang up VoNR call
    DETACH UE IWK12

DETACH UE IWK12
    @{ue_index_list_1}    create list    0    1    2
    FOR  ${item}  IN    @{ue_index_list_1}
        detach multi power ue    ue_index=${item}    UE=${tl.ues[${item}].capabilities[1]}
    END


###############Case CB008927-G-B2-02 Step ########################
Attach xiaomi power UE and check throughput
    [Arguments]    ${ue_index}    ${ul_throughput}    ${dl_throughput}    ${cells}    ${target_avg_percent_UL}=0.96  ${target_avg_percent_DL}=0.99
    @{ue_index_list}    create list    ${ue_index}
    attach single power ue     ue_index=${ue_index}   UE=${tl.ues[${ue_index}].capabilities[1]}   gnb_index=${0}
    Sleep    3s
    Start Multi Power Ue Traffic Ul And Dl      ue_index_list=${ue_index_list}   ul_throughput=${ul_throughput}M    dl_throughput=${dl_throughput}M
    ...    if_ul=${True}     if_dl=${True}     process_num=${1}    protocol=udp    ue_type=${ue_type}
    UE Check Throughput    ul_list=${cells}    dl_list=${cells}
    ...    exp_ul_tp=${ul_throughput}   exp_dl_tp=${dl_throughput}
    ...    actCarrierAggregation=${True}    gnb_index=0
    ...    target_avg_percent_UL=${target_avg_percent_UL}   target_avg_percent_DL=${target_avg_percent_DL}



UE3 Attach Gnb1 and check throughput
    Adjust PA    value_0=${0}    value_1=${127}
    ...    port_list_0=${port_list[0:4]}    port_list_1=${port_list[4:8]}
    Attach xiaomi power UE and check throughput    ue_index=${2}    ul_throughput=${57}    dl_throughput=${680}    cells=${cell_list_gnb1[2:4]}


UE3 Attach Gnb1-Gnb2 and check log&throughput
    [Arguments]    ${ul_throughput}=57    ${dl_throughput}=680    ${ue_index}=${2}
    ...    ${gnb_index}=1
    ...    ${port_list_2}=${port_list[0:4]}
    ...    ${cell_check_list}=${cell_list_gnb2[0:2]}    ${target_avg_percent_UL}=0.96  ${target_avg_percent_DL}=0.95
    ...    ${filename0}=Tcpdump_Gnb01    ${filename1}=Tcpdump_Gnb11    ${text_name_source}=Tcpdump_Gnb01
    ...    ${text_name_target}=Tcpdump_Gnb11    ${attached_pci}=${attached_pci_11}    ${resourceAllocation_target}=${resourceAllocation_0}
    ...    ${ho_direction}=GNB1_TO_GNB2
    @{ue_index_list}    create list    ${ue_index}
    Start Catch Trace Log   DU_OAM_IP=${gNB_ip0}    connection=alias    filename=${filename0}
    Start Catch Trace Log   DU_OAM_IP=${gNB_ip1}    connection=alias    filename=${filename1}
    Run keyword if    '${ho_direction}'=='GNB1_TO_GNB2'    GNB1_TO_GNB2_PA_Adjust
    Run keyword if    '${ho_direction}'=='GNB2_TO_GNB1'    GNB2_TO_GNB1_PA_Adjust
    #     Adjust PA    value_0=${value_0}   value_1=${value_1}
    #     ...    port_list_0=${port_list_0}    port_list_1=${port_list_1}
    Sleep    3s
    Adjust the HBTE attenuation value    value=${127}     port_list=${port_list_2}
    Sleep    10s
    UE Check Throughput    ul_list=${cell_check_list}    dl_list=${cell_check_list}
    ...    exp_ul_tp=${ul_throughput}   exp_dl_tp=${dl_throughput}
    ...    actCarrierAggregation=${True}    gnb_index=${gnb_index}
    ...    target_avg_percent_UL=${target_avg_percent_UL}   target_avg_percent_DL=${target_avg_percent_DL}
    Stop And Copy Log To UTE    DU_OAM_IP=${gNB_ip0}    connection=alias    filename=${filename0}.pcap
    Stop And Copy Log To UTE    DU_OAM_IP=${gNB_ip1}    connection=alias    filename=${filename1}.pcap
    Pcap chang to txt    pcap_name=${filename0}.pcap    text_name=${filename0}.txt
    Pcap chang to txt    pcap_name=${filename1}.pcap    text_name=${filename1}.txt
    Check wireshark log Parameter    txt_filename=${text_name_target}.txt
    ...    sgnb_chg_ho_message=${attached_pci}  logpath=${LOG_PATH}
    Check Flow Message    text_name=${text_name_target}.txt    message_dict=${gnb_target_message_flow}
    Check Flow Message    text_name=${text_name_source}.txt    message_dict=${gnb_source_message_flow}
    Check wireshark log Parameter    txt_filename=${text_name_target}.txt
    ...    sgnb_chg_ho_message=${resourceAllocation_target}  logpath=${LOG_PATH}

Pcap chang to txt
    [Arguments]    ${pcap_name}=Tcpdump_Gnb01.pcap    ${text_name}=Tcpdump_Gnb01.txt
    CB008927_common_keyword.Convert pcap to text    source=${LOG_PATH}/${pcap_name}    target=${LOG_PATH}/${text_name}

Check wireshark log Parameter
    [Arguments]     ${txt_filename}     ${sgnb_chg_ho_message}      ${logpath}=${OUTPUT_DIR}/${TEST NAME}
    ${val_result}    Check_Wireshark_Parameter_From_Txt    txt_file_path=${logpath}/${txt_filename}
    ...    parameters=${sgnb_chg_ho_message}
    ${val_list}     set variable    ${val_result}[resultList]
    FOR    ${val1}    IN    @{val_list}
        Run Keyword And Continue On Failure    should be equal    ${val1}    ${True}
    END


Check Flow Message
    [Arguments]    ${text_name}    ${message_dict}
    Log To Console    Check Flow Message
    ${result}    Check Wireshark Message Flow From Txt    txt_file_path=${logpath}/${text_name}    message_dict=${message_dict}
    should be equal as strings    ${result}    True

#need to be ope
modify the parameter case B2_Old
    [Arguments]     ${cell_id}=${23}    ${BTS_ID}=${BTS_ID_0}    ${NRBTS_ID}=${BTS_ID_0}
    WEBUI Login
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=A3 offset SSB RSRP   new_value=3    abbr=a3OffsetSsbRsrp
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-20
    ...    filter_param=Minimum required RX level in the cell (dBm)  new_value=-22    abbr=qRxLevMin
    ${error}    selenium_coam.validate_plan
    Log To Console    ${error}
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${false}    timeout=${180}
    CB008927_common_keyword.Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}
    WEBUI Logout
    WEBUI Login    gNB_ip=${gNB_ip1}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID_1}/NRBTS-${BTS_ID_1}/NRCELL-1
    ...    filter_param=Activate FD resource allocation type1   new_value=false    abbr=actRat1Alloc
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID_1}/NRBTS-${BTS_ID_1}/NRCELL-2
    ...    filter_param=Minimum required RX level in the cell (dBm)  new_value=-22    abbr=qRxLevMin
    ${error}    selenium_coam.validate_plan
    Log To Console    ${error}
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${false}    timeout=${180}
    CB008927_common_keyword.Check GNB on air    bts_host=${gnb_ip1}
    Check Alarm List on BTS    allowed_list=${allowed_list}    bts_host=${gnb_ip1}
    [Teardown]    WEBUI Logout

modify the parameter case B2
    [Arguments]     ${gnb_index}=${0}
    ${bts_ip}    set variable    ${tl.gnbs[${gnb_index}].dus[${0}].f1_m_ip_addr}
    Modify Parameters with json_702    bts_host=${bts_ip}    input_list=${B2_case_parameter_1}    connection=para_coam
    CB008927_common_keyword.Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}
    #modify bts2
    ${bts_ip_2}    set variable    ${tl.gnbs[${1}].dus[${0}].f1_m_ip_addr}
    Modify Parameters with json_702    bts_host=${bts_ip_2}    input_list=${B2_case_parameter_2}    connection=para_coam
    CB008927_common_keyword.Check GNB on air    bts_host=${bts_ip_2}
    Check Alarm List on BTS    allowed_list=${allowed_list}    bts_host=${bts_ip_2}

modify the parameter case B2_recovery
    [Arguments]     ${gnb_index}=${0}
    ${bts_ip}    set variable    ${tl.gnbs[${gnb_index}].dus[${0}].f1_m_ip_addr}
    Modify Parameters with json_702    bts_host=${bts_ip}    input_list=${B2_case_parameter_1_recovery}    connection=para_coam
    CB008927_common_keyword.Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}
    #modify bts2
    ${bts_ip_2}    set variable    ${tl.gnbs[${1}].dus[${0}].f1_m_ip_addr}
    Modify Parameters with json_702    bts_host=${bts_ip_2}    input_list=${B2_case_parameter_2_recovery}    connection=para_coam
    CB008927_common_keyword.Check GNB on air    bts_host=${bts_ip_2}
    Check Alarm List on BTS    allowed_list=${allowed_list}    bts_host=${bts_ip_2}

Block and unblock Gnb1&Gnb2 cell B2
    [Arguments]    ${block_cell_list}=${cell_ID_list_gnb1[1:3]}    ${block_flag}=${True}
    FOR  ${item}  IN    @{block_cell_list}
        BLock or UnBlock Cell And Check Status    block_cell_id=${item}    unblock_cell_id=${item}    block_flag=${block_flag}
        ...    bts_host=${gNB_ip0}
    END

detach and stop tup B2
    [Arguments]    ${ue_index}=2
    @{ue_index_list}    create list    ${ue_index}
    detach multi power ue    ue_index=${ue_index}     UE=${tl.ues[${ue_index}].capabilities[1]}
    stop multi power ue traffic ul and dl    ue_index_list=${ue_index_list}    if_ul=${True}     if_dl=${True}    protocol=udp

###############Case CB008927-G-IWK17-01 Step ########################

Get BTS release
    [Arguments]      ${connection}=gnb_oam_login    ${bts_host}=${gnb_ip0}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${version}    coam.get_sw_version    connection=${connection}
    ${version_list}    split string    ${version}    separator=_
    ${bts_release}    set variable    ${version_list[0]}
    [Return]    ${bts_release}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

WEBUI Login
    [Arguments]    ${gNB_ip}=${gNB_ip0}
    [Documentation]   WEBUI Login
    Log To Console  START:WEBUI Login
    Log To Console  Try to login...
    ${version}    Get BTS release
    selenium_coam.Enable_Virtual_Display
    selenium_coam.Login    url=https://${gNB_ip}    username=${gNB_username}   password=${gNB_password}
    ...    version=${version}
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

Case Suit Setup IWK17
    robot_common_operations.Common Case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=49
    AlarmWatchdog.add_allow_alarms    fault_id=7311
    AlarmWatchdog.add_allow_alarms    fault_id=6327
    Check Alarm List on BTS    allowed_list=${allowed_list}


modify the parameter case IWK17_Old
    [Arguments]     ${cell_id}=${20}    ${new_value}=true    ${BTS_ID}=${BTS_ID_0}    ${NRBTS_ID}=${BTS_ID_0}
    WEBUI Login
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=Activate FD resource allocation type1    new_value=${new_value}    abbr=actRat1Alloc
    ${error}    selenium_coam.validate_plan
    Log To Console    ${error}
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${false}    timeout=${180}
    CB008927_common_keyword.Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}
    [Teardown]    WEBUI Logout

modify the parameter case IWK17
    [Arguments]     ${cell_id}=${20}    ${new_value}=true    ${BTS_ID}=${BTS_ID_0}    ${NRBTS_ID}=${BTS_ID_0}    ${gnb_index}=${0}
    ${bts_ip}    set variable    ${tl.gnbs[${gnb_index}].dus[${0}].f1_m_ip_addr}
    ${parameter_list}    Create List
    ${parameter_dict}    Create dictionary
    ...    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    parameter=actRat1Alloc
    ...    value=${new_value}
    ...    operation=update
    Append to list    ${parameter_list}    ${parameter_dict}
    Modify Parameters with json_702    bts_host=${bts_ip}    input_list=${parameter_list}    connection=para_coam
    CB008927_common_keyword.Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}


Adjust PA and Block cell case IWK17
    [Arguments]    ${block_cell_list}=${cell_ID_list_gnb1[0:3]}    ${unblock_cell_id}=${20}
#    ...    ${block_cell_id_gnb1}=${1}    ${unblock_cell_id_gnb1}=${2}
    Adjust PA    value_0=${0}   value_1=${127}
    ...    port_list_0=${port_list[0:4]}    port_list_1=${port_list[4:8]}
    FOR  ${item}  IN    @{block_cell_list}
        BLock or UnBlock Cell And Check Status    block_cell_id=${item}    unblock_cell_id=${unblock_cell_id}    block_flag=${True}
        ...    bts_host=${gNB_ip0}
    END
#    FOR  ${item}  IN    @{block_cell__LN_list}
#        BLock or UnBlock Cell And Check Status    block_cell_id=${item}    block_flag=${True}
#        ...    bts_host=${gNB_ip0}     cell_type=LN    cell_type_1=lte    CELL=CEL    Cell_block_status=${Cell_LTE_block_status}
#    END


UE1234 Attach Gnb1 and check log&throughput case iwk17
#    [Arguments]    ${ul_throughput}=1    ${dl_throughput}=1
#    ...    ${value_0}=${15}    ${value_1}=${0}    ${value_list_2}=${value_list[2:3]}
#    ...    ${port_list_0}=${port_list[0:4]}    ${port_list_1}=${port_list[4:8]}    ${port_list_2}=${port_list[0:4]}
    [Arguments]        ${target_avg_percent_UL}=1  ${target_avg_percent_DL}=1
    log to console    VoNR call
    @{ue_index_list_attach}    create list    0    1    2
    FOR  ${item}  IN    @{ue_index_list_attach}
        attach single power ue     ue_index=${item}   UE=${tl.ues[${item}].capabilities[1]}   gnb_index=${0}
    END
    @{ue_index_list_1}    create list    1    2
    Start Multi Power Ue Traffic Ul And Dl      ue_index_list=${ue_index_list_1}   ul_throughput=${40}M    dl_throughput=${185}M
    ...    if_ul=${True}     if_dl=${True}     process_num=${1}    protocol=udp    ue_type=samsung
    UE Check Throughput    ul_list=${cell_list_gnb1[2:3]}    dl_list=${cell_list_gnb1[2:3]}     exp_ul_tp=${20}
    ...    exp_dl_tp=${150}    actCarrierAggregation=${false}
    ...    target_avg_percent_UL=${target_avg_percent_UL}   target_avg_percent_DL=${target_avg_percent_DL}    gnb_index=0     log_time=10s
    UE3 Make VoNR call
    Get Single all pointer variable    UE=${tl.ues[0].capabilities[1]}
    run keyword and continue on failure    run keyword if    ${True}    power_ue.Start traffic    ue_index=${0}    direction=ul
    ...    throughput=${10}M    duration=${20000}    ue_type=samsung    protocol=udp    appserver=${appserver_24}
    ...    iperf_port=${44901}    process_num=${1}    iperf_type=via_command
    sleep    1s
    run keyword and continue on failure    run keyword if    ${True}    power_ue.Start traffic    ue_index=${0}    direction=dl
    ...    throughput=${10}M    duration=${20000}    ue_type=samsung    protocol=udp    appserver=${appserver_24}
    ...    iperf_port=${44901}   process_num=${1}
    Capture TTI log 8927    bts_ip=${gNB_ip0}
    sleep    1s
    Stop Ttitrace    collector_names=l2stream3_ttitrace
    ${UL_DL_csv_file_path_dict}    check TTI LOG   filter=dlFdSchedData
    ${file_path_DL}    Get from Dictionary    ${UL_DL_csv_file_path_dict}    DL
    Check Same Sfn Slot Rnti Number    file_path=${file_path_DL}    expect_rnti_num=${3}
    UE Check Throughput    ul_list=${cell_list_gnb1[2:3]}    dl_list=${cell_list_gnb1[2:3]}     exp_ul_tp=${5}
    ...    exp_dl_tp=${5}    actCarrierAggregation=${false}
    ...    target_avg_percent_UL=${target_avg_percent_UL}   target_avg_percent_DL=${target_avg_percent_DL}    gnb_index=0     log_time=10s
    stop multi power ue traffic ul and dl    ue_index_list=${ue_index_list_1}   if_ul=${True}     if_dl=${True}    protocol=udp
    run keyword if    ${True}    power_ue.Stop traffic    direction=ul    ue_index=${0}    ue_type=samsung    iperf_type=via_command
    ...    protocol=udp    iperf_port=${44901}    appserver=${appserver_24}
    run keyword if    ${True}    power_ue.Stop traffic    direction=dl    ue_index=${0}    ue_type=samsung   protocol=udp
    ...    iperf_port=${44901}    appserver=${appserver_24}
    UE hang up VoNR call
    [Teardown]    DETACH UE IWK17

DETACH UE IWK17
    @{ue_index_list_1}    create list    0    1    2
    FOR  ${item}  IN    @{ue_index_list_1}
        detach multi power ue    ue_index=${item}    UE=${tl.ues[${item}].capabilities[1]}
    END

Verify attach1
    [Arguments]    ${5Grach_ed}    ${ue_index}=${0}    ${gnb_index}=${0}    ${du_index}=${0}    ${4G_check}=True
    ...            ${5Gstatus}=PASS    &{kwargs}
    [Documentation]    Verify attach result when plugin self verify not suffient
    ...  :param  ue_index: The list index from tl.ues[], it will use the index UE for verify attach
    ...  :param  5Grach_ed: the return value from ue attach, contain the RACH count and time and check location
    ...  :param  gnb_index: The list index from tl.gnbs[], it will use the index gnb for attach check
    ...  :param  4G_check: 4G ue attach need check or not
    ...  :param  5Gstatus: The expected 5G attach result, contain special sce need attach fail check
    Log to console    ${5Grach_ed}
    run keyword if    '${4G_check}' == 'True'
    ...    wait until keyword succeeds    1 min    10s    Verify 4G Attach by ADB Command    ue_index=${ue_index}
    ${status}    run keyword and return status    wait until keyword succeeds    3 min    10s    Check 5G Rach Status
    ...    before=${5Grach_ed[0]}    before_time=${5Grach_ed[1]}    hwcheck_index=${5Grach_ed[2]}    log_type=${5Grach_ed[3]}
    ...    gnb_index=${gnb_index}    5Gstatus=${5Gstatus}    log_loca=l2lo
    Run keyword if    '${status}'=='False'    wait until keyword succeeds    3 min    10s    Check 5G Rach Status
    ...    before=${5Grach_ed[4]}    before_time=${5Grach_ed[5]}    hwcheck_index=${5Grach_ed[2]}    log_type=${5Grach_ed[3]}
    ...    gnb_index=${gnb_index}    5Gstatus=${5Gstatus}    log_loca=l2hidu
    [Teardown]    run keyword if  '${5Grach_ed[3]}'=='Aasyslog'    Teardown the Aasyslog save progress
    ...    gnb_index=${gnb_index}    du_index=${du_index}

Modify Parameters with json_702
    [Arguments]    ${input_list}    ${bts_host}=${gNB_ip}    ${delta_id}=update_parameter    ${connection}=GNB_OAM    ${time}=10s
    ...    ${password}=${gNB_password}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${password}    connection=${connection}
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
        Run keyword if    '${operation}'=='update_object'
        ...    coam.append_managed_object_to_delta    dist_name=${item['dist_name']}
        ...    operation=update    delta_id=${delta_id}
        Run keyword if    '${operation}'=='delete_object'
        ...    coam.append_managed_object_to_delta    dist_name=${item['dist_name']}
        ...    operation=delete    delta_id=${delta_id}
        Run keyword if    '${operation}'=='create_object'
        ...    coam.append_managed_object_to_delta    dist_name=${item['dist_name']}
        ...    operation=create    delta_id=${delta_id}
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
    sleep    ${time}
    [Teardown]    run keyword and ignore error    coam.teardown      connection=${connection}
