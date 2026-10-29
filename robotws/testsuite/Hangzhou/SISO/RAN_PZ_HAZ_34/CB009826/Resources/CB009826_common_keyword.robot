*** Settings ***
Documentation    author：Hongyu Jiang
...              contact: hongyu.jiang@nokia-sbell.com
...              squad group: mmw_SG_04

Library     BuiltIn
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Library     taf.sbts.oam.coam.admin       WITH NAME    coam
Library     taf.hw.pdu       WITH NAME    pdu



*** Variables ***
${gNB_ip}                     ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${gNB_username}               ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gNB_password}               ${tl.gnbs[0].cu.oam_http_connection_details.password}
${ul_power_port_list}         ${tl.ues[0].iperf_details.ports[0:3]}
${dl_power_port_list}         ${tl.ues[0].iperf_details.ports[3:6]}
${BTS_ID}                     ${tl.gnbs[0].instance_id}
${NRBTS_ID}                   ${tl.gnbs[0].global_bts_id}
${LNBTS_ID}                   ${tl.enbs[0].global_bts_id}
${Secondary_PDU_ip}           ${tl.gnbs[0].dus[0].airscale.common_units[1].pdu_port.pdu.addr}
${Secondary_PDU_port}         ${tl.gnbs[0].dus[0].airscale.common_units[1].pdu_port.port_no}
@{RU_id_list}                 ${1}    ${2}   ${3}   ${5}   ${6}   ${7}   #{8}    ${9}
@{RU_lock_status}             Locked    enabled    Idle    configured
@{RU_unlock_status}           Unlocked    enabled    Active    configured
@{Cell_unlock_status}         Unlocked    enabled    Active    configured    Unblocked
@{Cell_lock_status}           Locked    disabled    Idle    initialization required    Unblocked
@{LTE_Cell_unlock_status}     unlocked    Unblocked    enabled    Idle
@{LTE_Cell_lock_status}       locked      Unblocked     disabled    Idle
@{cellgrp_list1}              ${1}    ${18}    ${19}    ${21}    ${22}    ${23}    #${24}    ${25}
@{allowed_list1}              ${4655}    ${61524}    ${4654}    ${61652}
@{AWEUA_cell_list}            612958249    612958250    612958251    612958252
@{AWHQX_cell_list}            612958230
@{ul_throughput_list1}        70    100
@{dl_throughput_list1}        100    500
@{ue_index_list1}             ${0}    ${1}
@{secondary_BBMOD}            ${4}    ${5}    ${6}
@{all_BBMOD}                  ${1}    ${2}    ${3}    ${4}    ${5}    ${6}
@{LTE_cell_list}              LNCEL-1
@{NR_cell_list1}              ${21}    ${18}   ${19}    ${23}



*** Keywords ***
########### setup KW #################
CB009826 Suit Setup
    CI_interface.Common Suite Setup
    robot_common_operations.Common Suite Setup

Case Teardown
    [Arguments]
    robot_common_operations.Common case Teardown
    CI_interface.Common Case Teardown
    Operate LTE Cell And Check status    operation=${True}    if_lock=${False}
    Operate NR Cell And Check status    if_lock=${False}    cell_id_list=${NR_cell_list1}

Case1 Teardown
    robot_common_operations.Common case Teardown
    CI_interface.Common Case Teardown

########### check bts on air #################
Save Snapshot
    [Arguments]    ${connection}=cOAM    ${timeout}=10min
    log to console    Save Snapshot...
    run keyword and ignore error     coam.teardown    connection=${connection}
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
    ...    connection=${connection}
    ${snapshot_path}    coam.Get Snapshot From BTS    alias=${connection}    timeout=${timeout}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}
    [Return]    ${snapshot_path}

Adapt to ute cloud commission scf
    ${TL_NAME}   set variable if      '${testline_name}' == '${EMPTY}'    ${CONFIGURATION}    ${testline_name}
    ${pattern}   Set Variable    7_5(.*)
    ${TLNAME}    Get Regexp Matches     ${TL_NAME}    ${pattern}    1
    ${TLNAME}   Set Variable    7_5${TLNAME}[0]
    Set Suite Variable    ${CURDIR_path}    ${CURDIR}/../../../../../../commissionings/HGZ/${TLNAME}

Set default SCF
    [Arguments]      ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM
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
    [Arguments]  ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM
    Adapt to ute cloud commission scf
    Set default SCF    bts_host=${bts_host}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    COAM Commission with scf file    scf_file_path=${default_scf_path}    connection=${connection}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Check GNB on air
    [Timeout]    20 min
    [Arguments]  ${BBMOD_list}    ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM    ${check_BBMOD_status}=${True}
    ${BBOMD_Procedura_status_dict}    Set initial state     bts_host=${bts_host}    connection=${connection}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    Wait Until Keyword Succeeds    20min    20s    COAM Check GNB cell on air    connection=${connection}
    Wait Until Keyword Succeeds    20min    20s    Check GNB cell on air Procedura    connection=${connection}
    Run Keyword If    ${check_BBMOD_status}    Check Mutil BBMOD Status
    ...    BBOMD_Procedura_status_dict=${BBOMD_Procedura_status_dict}   BBMOD_list=${BBMOD_list}
    [Return]    ${BBOMD_Procedura_status_dict}
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
        ${fault_id}     get from dictionary  ${output_alarms}[${i}]   additionalFaultID
        APPEND TO LIST  ${fault_id_list}    ${fault_id}
    END
    [Return]  ${fault_id_list}

Check Alarm List on BTS Temp
    [Arguments]  ${allowed_list}=None    ${not_allowed_list}=None    ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM
    ${actual_fault_id_list}    ${history_id_list}    Get Alarm on BTS    bts_host=${bts_host}    connection=${connection}
    ${history_id_len}    Get Length    ${history_id_list}
    Run Keyword if    ${allowed_list} != None        Check List1 content in List2    list1=${actual_fault_id_list}    list2=${allowed_list}
    Run Keyword if    ${not_allowed_list} != None    Check List1 content not in List2    list1=${not_allowed_list}    list2=${actual_fault_id_list}
    Run Keyword if    ${history_id_len} != ${0}    Save Snapshot
    Should be equal    ${history_id_len}    ${0}

Check Alarm List on BTS
    [Arguments]  ${allowed_list}=${allowed_list1}    ${not_allowed_list}=None    ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM
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
    
Get Station Procedura State
    [Arguments]    ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM
    ${BBOMD_status_dict}    Create Dictionary
    ${bts_status}    coam.get_bts_info    connection=${connection}
    ${ALL_BBMOD_status}    Get From Dictionary    ${bts_status}    basebandModules
    FOR    ${BBMOD}    IN    @{ALL_BBMOD_status}
        ${BBMOD_id_tmp}    Set Variable    ${BBMOD['id']['configuration']}
        ${BBMOD_id_info}    Split String    ${BBMOD_id_tmp}    separator=/
        ${BBMOD_id}    Set Variable    ${BBMOD_id_info[-1]}
        ${BBMOD_status}    Set Variable    ${BBMOD['status']['operationalState']}
        Set To Dictionary    ${BBOMD_status_dict}    ${BBMOD_id}    ${BBMOD_status}
    END
    [Return]    ${BBOMD_status_dict}
    
Check GNB cell on air Procedura
    [Arguments]    ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM
    ${BBOMD_status_dict}    Get Station Procedura State    bts_host=${bts_host}    connection=${connection}
    ${BBMOD_id_list}    Get Dictionary Keys    ${BBOMD_status_dict}
    FOR  ${BBMOD_id}  IN  @{BBMOD_id_list}
        ${BBMOD_status}    Get From Dictionary    ${BBOMD_status_dict}    ${BBMOD_id}
        ${BBMOD_status_procedura}    Get From Dictionary    ${BBOMD_Procedura_status_dict}    ${BBMOD_id}
        Append To List    ${BBMOD_status_procedura}    ${BBMOD_status}
        Set To Dictionary    ${BBOMD_Procedura_status_dict}    ${BBMOD_id}    ${BBMOD_status_procedura}
    END
    Verify all cells should be onair    connection=${connection}
    [Return]    ${BBOMD_Procedura_status_dict}

Set initial state
    [Arguments]    ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM
    ${BBOMD_Procedura_status_dict}    Create Dictionary
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${BBOMD_status_dict}    Get Station Procedura State    bts_host=${bts_host}    connection=${connection}
    ${BBMOD_id_list}    Get Dictionary Keys    ${BBOMD_status_dict}
    FOR  ${BBMOD_ID}  IN  @{BBMOD_id_list}
        ${BBMOD_status}    Get From Dictionary    ${BBOMD_status_dict}    ${BBMOD_ID}
        @{empty_list}    Create list
        Set To Dictionary    ${BBOMD_Procedura_status_dict}    ${BBMOD_ID}    ${empty_list}
    END
    Set Suite Variable    ${BBOMD_Procedura_status_dict}
    [Return]    ${BBOMD_Procedura_status_dict}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Judging The Median Change In The List
    [Arguments]    ${input_list}
    @{expect_value_list}    Create List    ${0}    ${1}
    ${change_time}    Set Variable    ${0}
    ${len}    Get Length    ${input_list}
    FOR  ${i}  IN RANGE  0   ${len}-1
        ${change_time}    Run Keyword If    '${input_list[${i}]}' != '${input_list[${i+1}]}'    Evaluate   ${change_time}+${1}
        ...    ELSE    Set Variable    ${change_time}
    END
    Log To Console    ${change_time}
    ${status}    Run Keyword And Return Status    List Should Contain Value    ${expect_value_list}    ${change_time}
    Run Keyword If    ${status}==${False}    Save Snapshot
    [Return]    ${status}

Check Mutil BBMOD Status
    [Arguments]    ${BBOMD_Procedura_status_dict}   ${BBMOD_list}
    FOR  ${id}  IN  @{BBMOD_list}
        ${BBMOD_id}    Set Variable    BBMOD-${id}
        ${status_list}    Get From Dictionary    ${BBOMD_Procedura_status_dict}    ${BBMOD_id}
        ${status}    Judging The Median Change In The List    input_list=${status_list}
        Should Be True    ${status}
    END

########### station operation ###################
Lock or Unlock LTE Cell
    [Arguments]    ${bts_host}    ${cell_id}    ${if_lock}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    run keyword if    ${if_lock}
    ...    coam.lock    dist_name=MRBTS-${BTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-${cell_id}    connection=${connection}    timeout=120
    ...    ELSE    coam.unlock    dist_name=MRBTS-${BTS_ID}/LNBTS-${LNBTS_ID}/LNCEL-${cell_id}    connection=${connection}    timeout=120
    sleep    10s
    [Teardown]     Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Lock Multiple NR Cell
    [Arguments]    ${bts_host}    ${cell_id_list}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    FOR  ${cell_id}  IN  @{cell_id_list}
        coam.lock    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}    connection=${connection}    timeout=120
    END
    [Teardown]     Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
    
UnLock Multiple NR Cell
    [Arguments]    ${bts_host}    ${cell_id_list}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    FOR  ${cell_id}  IN  @{cell_id_list}
        coam.unlock    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}    connection=${connection}    timeout=120
    END
    [Teardown]     Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}  
    
Get LTE Cell Status
    [Arguments]    ${bts_host}    ${connection}=GNB_OAM
    ${LTE_cell_status}    create dictionary
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=GNB_OAM
    ${cell_info_list}     coam.Get_Cells_Info   cell_type=lte    connection=${connection}
    FOR  ${cell_info}  IN  @{cell_info_list}
        ${cell_id_string}    Split String  ${cell_info['id']['configuration']}  separator=/
        ${cell_id}    set variable    ${cell_id_string}[-1]
        ${cell_status}    get from dictionary    ${cell_info}    status
        set to dictionary    ${LTE_cell_status}    ${cell_id}=${cell_status}
    END
    [Return]    ${LTE_cell_status}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Power Off Hardware
    [Arguments]    ${model}    ${PDU_IP}    ${PDU_PORT}    ${connection}=pdu_alias
    Log To Console    Power Off Start
    pdu.Setup Pdu    model=${model}    host=${PDU_IP}    alias=${connection}
    pdu.Power Off    port=${PDU_PORT}    pdu_device=${connection}
    ${port_status}    pdu.Get Port Status    port=${PDU_PORT}    pdu_device=${connection}
    Sleep    5s
    should be equal    ${port_status}    off

Power On Hardware
    [Arguments]    ${model}    ${PDU_IP}    ${PDU_PORT}    ${connection}=pdu_alias
    Log To Console    Power On Start
    pdu.Setup Pdu    model=${model}    host=${PDU_IP}    alias=${connection}
    pdu.Power On    port=${PDU_PORT}    pdu_device=${connection}
    ${port_status}    pdu.Get Port Status    port=${PDU_PORT}    pdu_device=${connection}
    sleep    5s
    should be equal    ${port_status}    on

Reset Site And Waite Until on Air
    [Arguments]    ${allowed_list}=${allowed_list1}    ${not_allowed_list}=None    ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    Log To Console    Start Reset Site
    coam.reset_site    connection=${connection}
    Check GNB on air    BBMOD_list=${all_BBMOD}    bts_host=${bts_host}    connection=${connection}    check_BBMOD_status=${True}
    Check Alarm List on BTS    allowed_list=${allowed_list}    not_allowed_list=${not_allowed_list}    bts_host=${bts_host}
    ...    connection=${connection}
    [Teardown]     Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Lock Cellgroup
    [Arguments]    ${cellgrp_idx}    ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM
    Log To Console    Lock Cellgroup ${cellgrp_idx}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    coam.lock_cell_group    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP_A-${cellgrp_idx}    connection=${connection}
    sleep    25s
    [Teardown]     Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Unlock Cellgroup
    [Arguments]    ${cellgrp_idx}    ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM
    Log To Console    Unlock Cellgroup ${cellgrp_idx}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    coam.unlock_cell_group    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP_A-${cellgrp_idx}    connection=${connection}
    sleep    3s
    [Teardown]     Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Lock RU
    [Arguments]  ${RMOD_id}    ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM    ${timeout}=60
    Log To Console    Lock RU ${RMOD_id}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${dist_name}    Set Variable    MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${RMOD_id}
    coam.lock    dist_name=${dist_name}    timeout=${timeout}    connection=${connection}
    sleep    10s
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

UnLock RU
    [Arguments]  ${RMOD_id}    ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM    ${timeout}=60
    Log To Console    Unlock RU ${RMOD_id}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${dist_name}    Set Variable    MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${RMOD_id}
    coam.unlock    dist_name=${dist_name}    timeout=${timeout}    connection=${connection}
    sleep    10s
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Check All RU or Cell Status
    [Documentation]  expect_item_status_dict eg:
    ...              1) ${cell_status_dict}    Create Dictionary     NRCELL-1=${Cell_unlock_status}    NRCELL-2=${Cell_lock_status}
    ...              2) ${ru_status_dict}    Create Dictionary     RMOD-1=${RU_unlock_status}    RMOD-2=${RU_lock_status}
    [Arguments]  ${expect_item_status_dict}    ${cell_type}=nr    ${if_ru}=${True}   ${bts_host}=${gnb_ip}
    Log To Console    Check All RU or Cell Status
    ${nr_item_status_dic}    run keyword if    '${cell_type}'=='nr'    Get All RU or Cell Status    if_ru=${if_ru}    bts_host=${bts_host}
    ...    connection=GNB_OAM
    ${lte_item_status_dic}    run keyword if    '${cell_type}'=='lte'    Get LTE Cell Status    bts_host=${bts_host}
    ...    connection=GNB_OAM
    ${item_status_dic}    run keyword if    '${cell_type}'=='nr'    set variable    ${nr_item_status_dic}
    ...    ELSE IF    '${cell_type}'=='lte'    set variable    ${lte_item_status_dic}
    @{item_id_list}    get dictionary keys    ${expect_item_status_dict}
    @{status_list}    create list
    FOR  ${item_id}  IN  @{item_id_list}
        ${expect_status_list}     get from dictionary    ${expect_item_status_dict}    ${item_id}
        ${item_status}    set variable    ${item_status_dic['${item_id}']}
        ${status}    run keyword and return status
        ...    Run Keyword If    ${if_ru}    Check Single RU Status    item_status=${item_status}    expect_status_list=${expect_status_list}
        ...    ELSE IF    '${cell_type}'=='lte'    Check LTE Cell Status    item_status=${item_status}    expect_status_list=${expect_status_list}
        ...    ELSE    Check Single Cell Status    item_status=${item_status}    expect_status_list=${expect_status_list}
        append to list    ${status_list}    ${status}
    END
    Should not Contain    ${status_list}    ${False}
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

Check LTE Cell Status
    [Arguments]    ${item_status}    ${expect_status_list}
    ${admin_status}    get from dictionary    ${item_status}    administrativeState
    Run Keyword And Continue On Failure    should be equal as strings   ${admin_status}    ${expect_status_list[${0}]}
    ${block_status}    get from dictionary    ${item_status}    blockingState
    Run Keyword And Continue On Failure    should be equal as strings   ${block_status}    ${expect_status_list[${1}]}
    ${operate_status}    get from dictionary    ${item_status}    operationalState
    Run Keyword And Continue On Failure    should be equal as strings    ${operate_status}    ${expect_status_list[${2}]}
    ${usage_status}    get from dictionary    ${item_status}    usageState
    Run Keyword And Continue On Failure    should be equal as strings    ${usage_status}    ${expect_status_list[${3}]}


############# UE attach relevant ###################
attach multi power ue
    [Arguments]    ${ue_index_list}    ${gnb_index}=${0}
    log to console       Prepare UE
    FOR    ${ue_index}  IN  @{ue_index_list}
        power_ue.Prepare UE    ue_index=${ue_index}    ue_type=samsung    ui_version=S20UI2.1
        ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    attach_mode=5G_NSA    ue_type=samsung    log_type=Aasyslog
        power_ue.Verify attach    ue_type=samsung   5Grach_ed=${5Grach_ed_0}    4G_check=False    gnb_index=${gnb_index}
    END

start multi power ue traffic ul and dl
    [Arguments]    ${ue_index_list}    ${ul_throughput_list}=${None}    ${dl_throughput_list}=${None}    ${ul_duration}=6000    ${dl_duration}=6000
    ...    ${protocol}=udp    ${if_ul}=${True}    ${if_dl}=${True}    ${process_num}=${2}    ${ue_type}=samsung
    log to console      Start traffic    console=yes
    FOR    ${item}    IN    @{ue_index_list}
        run keyword and continue on failure    run keyword if    ${if_ul}    power_ue.Start traffic    ue_index=${item}    direction=ul
        ...    throughput=${ul_throughput_list}[${item}]M    duration=${ul_duration}    ue_type=${ue_type}    protocol=${protocol}
        ...    iperf_port=${ul_power_port_list}[${item}]    process_num=${process_num}    iperf_type=via_command
        sleep    1s
        run keyword and continue on failure    run keyword if    ${if_dl}    power_ue.Start traffic    ue_index=${item}    direction=dl
        ...    throughput=${dl_throughput_list}[${item}]M    duration=${dl_duration}    ue_type=${ue_type}    protocol=${protocol}
        ...    iperf_port=${dl_power_port_list}[${item}]    process_num=${process_num}
    END

UE Check Throughput
    [Arguments]   ${exp_ul_tp}    ${exp_dl_tp}    ${ul_list}    ${dl_list}    ${log_path}    ${if_ul}=${True}    ${if_dl}=${True}
    ...    ${ue_type}=samsung    ${avg_percent}=0.95    ${min_percent}=0
    run keyword and continue on failure    run keyword if    ${if_ul}==${True}    power_ue.Check Tput    ue_type=${ue_type}
    ...    direction=UL    log=${log_path}    cells=${ul_list}    target_throughput=${exp_ul_tp}    target_avg_percent=${avg_percent}
    ...    min_percent=${min_percent}    actCarrierAggregation=${True}
    run keyword and continue on failure    run keyword if    ${if_dl}==${True}    power_ue.Check Tput    ue_type=${ue_type}
    ...    direction=DL    log=${log_path}    cells=${dl_list}    target_throughput=${exp_dl_tp}    target_avg_percent=${avg_percent}
    ...    min_percent=${min_percent}    actCarrierAggregation=${True}

stop multi power ue traffic ul and dl
    [Arguments]    ${ue_index_list}    ${protocol}=udp    ${if_ul}=${True}    ${if_dl}=${True}    ${ue_type}=samsung
    log to console     Stop traffic    console=yes
    FOR    ${item}    IN    @{ue_index_list}
        run keyword if    ${if_ul}    power_ue.Stop traffic    direction=ul    ue_index=${item}    ue_type=${ue_type}    iperf_type=via_command
        ...    protocol=${protocol}    iperf_port=${ul_power_port_list}[${item}]
        run keyword if    ${if_dl}    power_ue.Stop traffic    direction=dl    ue_index=${item}    ue_type=${ue_type}   protocol=${protocol}
        ...    iperf_port=${dl_power_port_list}[${item}]
    END

detach multi power ue
    [Arguments]    ${ue_index_list}=${1}
    log to console      UE Detach    console=yes
    FOR  ${ue_index}  IN   @{ue_index_list}
        power_ue.UE Detach    ue_index=${ue_index}    ue_type=samsung
    END

############# Case Step ###################
Get NRcellgroup Mapping Relationship
    [Arguments]  ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${NRcellgrp_cell_mapping}=    Create Dictionary
    ${output}    coam.get_bts_info    connection=${connection}
    ${cellgroup_info}    get from dictionary    ${output}    cellsGroup
    FOR  ${item}  IN  @{cellgroup_info}
        ${cellgroup}    get from dictionary    ${item}    name
        ${celllist}    get from dictionary    ${item}    nrCellList
        Set to dictionary   ${NRcellgrp_cell_mapping}      ${cellgroup}=${celllist}
    END
    [Return]  ${NRcellgrp_cell_mapping}
    [Teardown]     Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Lock And Unlock cellgroup multiple times
    [Arguments]  ${cellgroup_list}    ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM
    ${NRcellgrp_cell_mapping}    Get NRcellgroup Mapping Relationship    bts_host=${bts_host}    connection=${connection}
    FOR   ${cellgrp_idx}   IN   @{cellgroup_list}
        ${cell_list}    get from dictionary    ${NRcellgrp_cell_mapping}    NRCELLGRP-${cellgrp_idx}
        Log To Console    Lock Cellgroup-${cellgrp_idx}
        Lock Cellgroup    cellgrp_idx=${cellgrp_idx}    bts_host=${bts_host}    connection=${connection}
        ${lock_status_dict}    Set Cell List Status    cell_list=${cell_list}    cell_status=${Cell_lock_status}
        wait until keyword succeeds    10min    30s    Check All RU or Cell Status
        ...    expect_item_status_dict=${lock_status_dict}    if_ru=${False}   bts_host=${bts_host}
        Unlock Cellgroup    cellgrp_idx=${cellgrp_idx}    bts_host=${bts_host}    connection=${connection}
        ${unlock_status_dict}    Set Cell List Status    cell_list=${cell_list}    cell_status=${Cell_unlock_status}
        wait until keyword succeeds    10min    30s    Check All RU or Cell Status
        ...    expect_item_status_dict=${unlock_status_dict}    if_ru=${False}   bts_host=${bts_host}
        Check Alarm List on BTS    allowed_list=${allowed_list1}
    END

Set Cell List Status
    [Arguments]  ${cell_list}    ${cell_status}
    ${cell_status_dict}    Create Dictionary
    FOR  ${cell}  IN  @{cell_list}
        Set to dictionary   ${cell_status_dict}      ${cell}=${cell_status}
    END
    [Return]  ${cell_status_dict}

Lock And Unlock RU multiple times
    [Arguments]  ${RU_id_list}    ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM
    FOR  ${RU_id}  IN  @{RU_id_list}
        Lock RU    RMOD_id=${RU_id}    bts_host=${bts_host}    connection=${connection}
        ${expect_lock_dict}  Create Dictionary    RMOD-${RU_id}=${RU_lock_status}
        wait until keyword succeeds    10min    30s    Check All RU or Cell Status
        ...    expect_item_status_dict=${expect_lock_dict}    if_ru=${True}   bts_host=${bts_host}
        UnLock RU    RMOD_id=${RU_id}    bts_host=${bts_host}    connection=${connection}
        ${expect_unlock_dict}  Create Dictionary    RMOD-${RU_id}=${RU_unlock_status}
        wait until keyword succeeds    10min    30s    Check All RU or Cell Status
        ...    expect_item_status_dict=${expect_unlock_dict}    if_ru=${True}   bts_host=${bts_host}
        Check Alarm List on BTS    allowed_list=${allowed_list1}
    END

UE Start Traffic And Check TP
    [Arguments]    ${ue_index_list}=${ue_index_list1}    ${ul_throughput_list}=${ul_throughput_list1}
    ...    ${dl_throughput_list}=${dl_throughput_list1}    ${log_time}=1m
    attach multi power ue    ue_index_list=${ue_index_list}
    start multi power ue traffic ul and dl    ue_index_list=${ue_index_list}    ul_throughput_list=${ul_throughput_list}
    ...    dl_throughput_list=${dl_throughput_list}    process_num=${1}
    ${log_path}    power_ue.Collect Tput   ue_type=samsung    duration=${log_time}    ignore_time=10s
    stop multi power ue traffic ul and dl    ue_index_list=${ue_index_list}
    UE Check Throughput    exp_ul_tp=${ul_throughput_list}[${0}]    exp_dl_tp=${dl_throughput_list}[${0}]    ul_list=${AWHQX_cell_list}
    ...    dl_list=${AWHQX_cell_list}    log_path=${log_path}    avg_percent=0.95    min_percent=0
    UE Check Throughput    exp_ul_tp=${ul_throughput_list}[${1}]    exp_dl_tp=${dl_throughput_list}[${1}]    ul_list=${AWEUA_cell_list}
    ...    dl_list=${AWEUA_cell_list}    log_path=${log_path}    avg_percent=0.95    min_percent=0
    [Teardown]    detach multi power ue    ue_index_list=${ue_index_list}
    
Operate LTE Cell And Check status
    [Arguments]    ${operation}    ${if_lock}    ${bts_host}=${gNB_ip}
    run keyword if    ${operation}    Lock or Unlock LTE Cell    bts_host=${bts_host}    cell_id=${1}    if_lock=${if_lock}
    ${cell_status}    set variable if    ${if_lock}    ${LTE_Cell_lock_status}    ${LTE_Cell_unlock_status}
    ${expect_cell_status_dict}    Set Cell List Status    cell_list=${LTE_cell_list}    cell_status=${cell_status}
    wait until keyword succeeds    2min    10s    Check All RU or Cell Status    expect_item_status_dict=${expect_cell_status_dict}
    ...    cell_type=lte    if_ru=${False}   bts_host=${bts_host}

Operate NR Cell And Check status
    [Arguments]    ${if_lock}    ${cell_id_list}    ${bts_host}=${gNB_ip}
    run keyword if    ${if_lock}    Lock Multiple NR Cell    bts_host=${bts_host}    cell_id_list=${cell_id_list}
    ...    ELSE    UnLock Multiple NR Cell    bts_host=${bts_host}    cell_id_list=${cell_id_list}
    ${cell_status}    set variable if    ${if_lock}    ${Cell_lock_status}    ${Cell_unlock_status}
    @{NR_cell_list}    Create list
    FOR    ${cell_id}  IN  @{cell_id_list}
        Append To List    ${NR_cell_list}    NRCELL-${cell_id}
    END
    ${expect_cell_status_dict}    Set Cell List Status    cell_list=${NR_cell_list}    cell_status=${cell_status}
    wait until keyword succeeds    2min    10s    Check All RU or Cell Status    expect_item_status_dict=${expect_cell_status_dict}
    ...    cell_type=nr    if_ru=${False}   bts_host=${bts_host}
