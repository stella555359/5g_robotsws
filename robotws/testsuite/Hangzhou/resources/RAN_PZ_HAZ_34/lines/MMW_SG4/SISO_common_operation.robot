*** Settings ***
Documentation    author：Hongyu Jiang
...              contact: hongyu.jiang@nokia-sbell.com
...              squad group: mmw_SG_04

Library     OperatingSystem
Library     BuiltIn
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/rulog.py
Library     taf.hw.pdu       WITH NAME    pdu
Library     RequestsLibrary
Library     taf.hw.rf_attenuator    WITH NAME    att
Library     taf.rfrl.common_resources.python.SWConfig
Resource    ./common_variables.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF_NEW/Resource/UUF_LogCollection.robot
Variables     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF_NEW/Config/UUF_Vars.py

*** Keywords ***
############# Common Steup And Teardown ###############
Common Suit Setup
    CI_interface.Common Suite Setup
    robot_common_operations.Common Suite Setup

Common Case Setup
    [Arguments]    ${gnb_index}=0    ${fail_with_alarms}=${True}    ${allowed_faults_ids}=${None}
    robot_common_operations.Common Case Setup    gnb_index=${gnb_index}
    ...    fail_with_alarms=${fail_with_alarms}    allowed_faults_ids=${allowed_faults_ids}
    Check GNB on air    bts_host=${gNB_ip}   interval=180
    Check Alarm List on BTS    bts_host=${gNB_ip}    allowed_list=${allowed_alarm_list}

Common Case Teardown
    [Arguments]    ${bts_host}=${gNB_ip}
    robot_common_operations.Common case Teardown
    CI_interface.Common Case Teardown
    Run Keyword If    "${TEST_STATUS}"=="FAIL"    Save Snapshot    bts_host=${bts_host}

############# Station Operation ###############
BLock or UnBlock Cell And Check Status
    [Arguments]  ${allowed_list}    ${BTS_ID}=${TL_BTS_ID}   ${NRBTS_ID}=${TL_NRBTS_ID}    ${block_cell_id_list}=${empty_list}
    ...    ${block_flag}=${True}    ${bts_host}=${gnb_ip}     ${unblock_cell_id_list}=${empty_list}    ${cell_type}=nr
    ${operate_cell_id_list}    Set Variable If    ${block_flag}    ${block_cell_id_list}    ${unblock_cell_id_list}
    Block or UnBlock Mulite Cell    cell_id_list=${operate_cell_id_list}    block_flag=${block_flag}    bts_host=${bts_host}    BTS_ID=${BTS_ID}
    ...    NRBTS_ID=${NRBTS_ID}    cell_type=${cell_type}
    ${cell_name}    Set Variable If    '${cell_type}' == 'nr'    NRCELL    LNCEL
    ${expect_item_status_dict}    create dictionary
    FOR  ${cell_id}  IN    @{block_cell_id_list}
        Set to dictionary    ${expect_item_status_dict}    ${cell_name}-${cell_id}=${Cell_block_status}
    END
    FOR  ${cell_id}  IN   @{unblock_cell_id_list}
        Set to dictionary    ${expect_item_status_dict}    ${cell_name}-${cell_id}=${Cell_unblock_status}
    END
    Check All RU or Cell Status    expect_item_status_dict=${expect_item_status_dict}    if_ru=${False}    cell_type=${cell_type}
    ...    bts_host=${bts_host}
    Check Alarm List on BTS    bts_host=${bts_host}    allowed_list=${allowed_list}

Block or UnBlock Mulite Cell
    [Arguments]  ${cell_id_list}    ${BTS_ID}    ${NRBTS_ID}    ${bts_host}    ${block_flag}=${True}    ${connection}=GNB_OAM    ${timeout}=60
    ...    ${cell_type}=nr
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    FOR  ${cell_id}  IN  @{cell_id_list}
        ${dist_name}    Set Variable If    '${cell_type}' == 'nr'    MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ...    MRBTS-${BTS_ID}/LNBTS-${NRBTS_ID}/LNCEL-${cell_id}
        Run keyword if    ${block_flag}==${True}    Log To Console    Block Cell-${cell_id}
        ...    ELSE    Log To Console    UnBlock Cell-${cell_id}
        Run keyword if    ${block_flag}==${True}    coam.block_cell    dist_name=${dist_name}    timeout=${timeout}    connection=${connection}
        ...    ELSE    coam.unblock_cell    dist_name=${dist_name}    timeout=${timeout}    connection=${connection}
        sleep    5s
    END
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Check All RU or Cell Status
    [Documentation]  expect_item_status_dict eg:
    ...              1) ${cell_status_dict}    Create Dictionary     NRCELL-1=${Cell_unblock_status}    NRCELL-2=${Cell_block_status}
    ...              2) ${ru_status_dict}    Create Dictionary     RMOD-1=${RU_unlock_status}    RMOD-2=${RU_lock_status}
    [Arguments]  ${expect_item_status_dict}    ${bts_host}    ${if_ru}=${False}    ${cell_type}=nr
    Log To Console    Check All RU or Cell Status
    ${item_status_dic}    Get All RU or Cell Status    if_ru=${if_ru}    bts_host=${bts_host}    cell_type=${cell_type}    connection=GNB_OAM
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

Lock or UnLock Multiple RU
    [Arguments]    ${RMOD_id_list}   ${lock_flag}=${True}    ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM    ${timeout}=60
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    FOR  ${RMOD_id}  IN  @{RMOD_id_list}
        ${dist_name}    Set Variable    MRBTS-${TL_BTS_ID}/EQM-1/APEQM-1/RMOD-${RMOD_id}
        Run keyword if    ${lock_flag}==${True}    Log To Console    Lock RMOD-${RMOD_id}
        ...    ELSE    Log To Console    UnLock RMOD-${RMOD_id}
        Run keyword if    ${lock_flag}==${True}    coam.lock    dist_name=${dist_name}    timeout=${timeout}    connection=${connection}
        ...    ELSE    coam.unlock    dist_name=${dist_name}    timeout=${timeout}    connection=${connection}
        sleep    8s
    END
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Lock or Unlock RUs And Check Status
    [Arguments]  ${lock_RU_id_list}=${empty_list}     ${unlock_RU_id_list}=${empty_list}    ${lock_flag}=${True}    ${bts_host}=${gnb_ip}
    ...    ${timeout}=60
    ${operate_ru_id_list}    Set Variable If    ${lock_flag}    ${lock_RU_id_list}    ${unlock_RU_id_list}
    Lock or UnLock Multiple RU    RMOD_id_list=${operate_ru_id_list}    lock_flag=${lock_flag}    bts_host=${bts_host}    timeout=${timeout}
    Check Alarm List on BTS    allowed_list=${allowed_alarm_list}    bts_host=${bts_host}
    ${expect_item_status_dict}    create dictionary
    FOR  ${item}  IN    @{lock_RU_id_list}
        Set to dictionary    ${expect_item_status_dict}    RMOD-${item}=${RU_lock_status}
    END
    FOR  ${item1}  IN   @{unlock_RU_id_list}
        Set to dictionary    ${expect_item_status_dict}    RMOD-${item1}=${RU_unlock_status}
    END
    Check All RU or Cell Status    expect_item_status_dict=${expect_item_status_dict}    if_ru=${True}    bts_host=${bts_host}

Lock or Unlock RF Link
    [Arguments]    ${RF_link_id_list}    ${BBMOD_id}    ${lock_flag}=${True}    ${bts_host}=${gnb_ip}
    @{para_list}    Create list
    FOR   ${id}   IN  @{RF_link_id_list}
        ${actual_value}    Set Variable If    ${lock_flag}    Locked    Unlocked
        ${para_dict}    Create Dictionary    dist_name=MRBTS-${TL_BTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-${BBMOD_id}/SFP-${id}/LANE-1
        ...    parameter=administrativeState    value=${actual_value}    operation=update
        Append to list    ${para_list}    ${para_dict}
    END
    Modify Parameters with json    input_list=${para_list}    bts_host=${bts_host}
    Run Keyword If    ${lock_flag}==${False}    Check GNB on air    bts_host=${bts_host}

Get All RU or Cell Status
    [Arguments]  ${if_ru}=${False}    ${bts_host}=${gnb_ip}    ${cell_type}=nr    ${connection}=GNB_OAM
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
    Check Single RU Status    item_status=${item_status}    expect_status_list=${expect_status_list}
    ${block_status}    get from dictionary    ${item_status}    blockingState
    ${lock_status}    get from dictionary    ${item_status}    lockState
    Run Keyword And Continue On Failure    should be equal as strings   ${block_status}    ${expect_status_list[${-1}]}
    Run Keyword And Continue On Failure    should be equal as strings   ${lock_status}    ${expect_status_list[${-1}]}

Check Cells List
    [Arguments]     ${bts_host}    ${expect_cell_list}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    @{actual_cell_list}    Create List
    ${cells_info_list}    coam.get_cell_list    connection=${connection}
    ${cells_info}    Set Variable    ${cells_info_list['cells']['nr']}
    FOR  ${item}  IN  @{cells_info}
        ${cell_id}    set variable    ${item['id']['configuration']}
        ${cell_id}    Split String    ${cell_id}    -
        Append to list    ${actual_cell_list}    ${cell_id[-1]}
    END
    Sort List    ${expect_cell_list}
    Sort List    ${actual_cell_list}
    Lists Should Be Equal    ${expect_cell_list}    ${actual_cell_list}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Reset Station On WeUI
    [Arguments]    ${bts_host}    ${connection}=reset_caom    ${timeout}=480
    Log To Console    Start Reset Station......
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}
    ...    connection=${connection}
    coam.reset_site    connection=${connection}    timeout=${timeout}
    [Teardown]   run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Reset BBMOD
    [Arguments]     ${BBMOD_list}    ${BTS_ID}=${TL_BTS_ID}    ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${BBMOD_dist_name}    Set Variable    MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-
    FOR  ${i}   IN   @{BBMOD_list}
        ${dist_name}    Set Variable    ${BBMOD_dist_name}${i}
        Log To Console    Start reset BBMOD-${i}
        coam.reset_unit    dist_name=${dist_name}    timeout=240    reset_type=Warm    connection=${connection}
    END
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Rat Reset On NR And LTE
    [Arguments]    ${if_muti_rat}=${True}    ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    Run Keyword If    ${if_muti_rat}    Log To Console    Start reset LTE
    Run Keyword If    ${if_muti_rat}    coam.rat_reset    rat_type=LTE    timeout=180    connection=${connection}
    Log To Console    Start reset NR
    coam.rat_reset    rat_type=NR    timeout=240   connection=${connection}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Reset BBMOD Multiple Times
     [Arguments]    ${BBMOD_list}    ${reset_time}    ${allowed_fault_id}    ${if_muti_rat}=${True}    ${BTS_ID}=${TL_BTS_ID}
     ...    ${cell_on_air_time}=10min    ${station_on_air_time}=15min   ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM
     FOR   ${i}   IN RANGE    ${reset_time}
        Reset BBMOD    BBMOD_list=${BBMOD_list}    bts_host=${bts_host}    BTS_ID=${BTS_ID}    connection=${connection}
        Check GNB On Air With BBMOD Reset Procedura    BBMOD_list=${BBMOD_list}    cell_on_air_time=${cell_on_air_time}
        ...    station_on_air_time=${station_on_air_time}    bts_host=${bts_host}    if_muti_rat=${if_muti_rat}    connection=${connection}
        Check Alarm List on BTS    allowed_list=${allowed_fault_id}    bts_host=${bts_host}    connection=${connection}
     END

Rat Reset Multiple Times
     [Arguments]    ${BBMOD_list}    ${reset_time}    ${allowed_fault_id}    ${if_muti_rat}=${True}    ${cell_on_air_time}=10min
     ...    ${station_on_air_time}=15min   ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM
     FOR   ${i}    IN RANGE    ${reset_time}
        Rat Reset On NR And LTE    bts_host=${bts_host}   if_muti_rat=${if_muti_rat}    connection=${connection}
        Check GNB On Air With BBMOD Reset Procedura    BBMOD_list=${BBMOD_list}    cell_on_air_time=${cell_on_air_time}
        ...    station_on_air_time=${station_on_air_time}    bts_host=${bts_host}    if_muti_rat=${if_muti_rat}    connection=${connection}
        Check Alarm List on BTS    allowed_list=${allowed_fault_id}    bts_host=${bts_host}    connection=${connection}
     END

Check GNB on air And alarm
    [Arguments]    ${bts_host}    ${allowed_list}   ${time}=10min    ${interval}=20    ${check_lte_cell}=${False}
    Check GNB on air    bts_host=${bts_host}    time=${time}    interval=${interval}    check_lte_cell=${check_lte_cell}
    Check Alarm List on BTS    allowed_list=${allowed_list}    bts_host=${bts_host}

Reset Station And Check On Air
    [Arguments]    ${bts_host}    ${allowed_list}    ${interval}=20
    Reset Station On WeUI    bts_host=${bts_host}
    ${result}    Run Keyword And Return Status    Check GNB on air And alarm    bts_host=${bts_host}    allowed_list=${allowed_list}
    ...    interval=${interval}
    Run Keyword If    '${result}'=='${False}'    run keyword and continue on failure    Save Snapshot    bts_host=${bts_host}
    run keyword if    '${result}'=='${False}'    run keyword and continue on failure    Capture RU log    bts_host=${bts_host}
    Should Be True    '${result}'=='${True}'

Get All RMOD From BTS
    [Arguments]    ${connection}=rf_reset_caom    ${timeout}=10s
    ${btsinfo}    coam.get_bts_info    connection=${connection}    timeout=${timeout}
    ${rmodinfo_list}    set variable    ${btsinfo}[radioModules][rmod]
    ${RMOD_List}    create list
    FOR    ${rmod_item}    IN    @{rmodinfo_list}
        ${RMOD_distname}    set variable    ${rmod_item}[id][configuration]
        Append to list    ${RMOD_List}    ${RMOD_distname}
    END
    Log to console    RMOD_list: ${RMOD_List}
    [Return]    ${RMOD_List}

RF module reset
    [Arguments]    ${bts_host}    ${RMOD_index_list}    ${connection}=rf_reset_caom    ${timeout}=10s
    Log To Console    Reset RU And Wait Until On Air
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${RMOD_List}    Get All RMOD From BTS    connection=${connection}    timeout=${timeout}
    ${string1}    Split String    ${RMOD_List[${0}]}    RMOD-
    ${dist_name}    Set Variable    ${string1[${0}]}RMOD-
    @{RMOD_id_list}    Create List
    FOR    ${item}    IN   @{RMOD_List}
        ${string}    Split String    ${item}    RMOD-
        Append to list    ${RMOD_id_list}    ${string[${1}]}
    END
    Sort List    ${RMOD_id_list}
    FOR    ${index}    IN    @{RMOD_index_list}
        ${id}    Evaluate    ${index}+${1}
        Log to console    Start Reset ${dist_name}${id}
        coam.reset_unit    dist_name=${dist_name}${id}    force_radio_reset=${True}    timeout=${600}    connection=${connection}
    END
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Reset RF Module And Check On Air
    [Arguments]    ${bts_host}    ${RMOD_index_list}    ${allowed_list}    ${timeout}=10s    ${interval}=20
    RF module reset    bts_host=${bts_host}    RMOD_index_list=${RMOD_index_list}    timeout=${timeout}
    ${result}    Run Keyword And Return Status    Check GNB on air And alarm    bts_host=${bts_host}    allowed_list=${allowed_list}
    ...    interval=${interval}
    Run Keyword If    '${result}'=='${False}'    run keyword and continue on failure    Save Snapshot    bts_host=${bts_host}
    run keyword if    '${result}'=='${False}'    run keyword and continue on failure    Capture RU log    bts_host=${bts_host}
    Should Be True    '${result}'=='${True}'

Power Off Hardware
    [Arguments]    ${PDU_IP}    ${PDU_PORT}    ${model}=HBTE    ${connection}=pdu_alias
    Log To Console    Power Off Start
    pdu.Setup Pdu    model=${model}    host=${PDU_IP}    alias=${connection}
    pdu.Power Off    port=${PDU_PORT}    pdu_device=${connection}
    ${port_status}    pdu.Get Port Status    port=${PDU_PORT}    pdu_device=${connection}
    Sleep    5s
    should be equal    ${port_status}    off

Power On Hardware
    [Arguments]    ${PDU_IP}    ${PDU_PORT}    ${model}=HBTE    ${connection}=pdu_alias
    Log To Console    Power On Start
    pdu.Setup Pdu    model=${model}    host=${PDU_IP}    alias=${connection}
    pdu.Power On    port=${PDU_PORT}    pdu_device=${connection}
    ${port_status}    pdu.Get Port Status    port=${PDU_PORT}    pdu_device=${connection}
    sleep    5s
    should be equal    ${port_status}    on

Reset PDU And Check On Air
    [Arguments]    ${model}    ${PDU_IP}    ${PDU_PORT}    ${bts_host}    ${allowed_list}    ${sleep_time}    ${interval}=20
    ...    ${check_lte_cell}=${False}
    Power Off Hardware    model=${model}    PDU_IP=${PDU_IP}    PDU_PORT=${PDU_PORT}
    sleep    ${sleep_time}
    Power On Hardware    model=${model}    PDU_IP=${PDU_IP}    PDU_PORT=${PDU_PORT}
    ${result}    Run Keyword And Return Status    Check GNB on air And alarm    bts_host=${bts_host}    allowed_list=${allowed_list}
    ...    interval=${interval}    check_lte_cell=${check_lte_cell}
    Run Keyword If    '${result}'=='${False}'    run keyword and continue on failure    Save Snapshot    bts_host=${bts_host}
    run keyword if    '${result}'=='${False}'    run keyword and continue on failure    Capture RU log    bts_host=${bts_host}
    Should Be True    '${result}'=='${True}'

Get BTS Software Version
    [Arguments]    ${connection}=GNB_OAM_VERSION
    ${parameters}    coam.get_parameters_for_all    class_name=BTS    timeout=20s    connection=${connection}
    ${ActiveVersion}    set variable    ${parameters}[${0}][activeSoftwareVersion]
    ${PassiveVersion}    set variable    ${parameters}[${0}][passiveSoftwareVersion]
    [Return]    ${ActiveVersion}    ${PassiveVersion}

Get Version Digit
    [Arguments]    ${version}
    ${string}    Split String    ${version}    _
    ${string}    Set Variable    ${string[${0}]}
    ${numbers}    Evaluate   int(${string[${4}]}${string[${5}]}${string[${7}]})
    [Return]    ${numbers}

BTS whether need rollback before upgrade
    [Arguments]  ${bts_host}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${activate_version}    ${passive_version}    Get BTS Software Version    connection=${connection}
    ${activate_num}    Get Version Digit    version=${activate_version}
    ${passive_num}    Get Version Digit    version=${passive_version}
    ${Is_need_rollback}    Set variable if    ${activate_num}>${passive_num}    ${True}    ${False}
    Log to console    Is_need_rollback:${Is_need_rollback}
    [Return]    ${Is_need_rollback}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections  connection=${connection}

Classical gNB Software Rollback
    [Arguments]    ${bts_host}     ${connection}=GNB_OAM    ${gps_check}=${True}
    #pre-check GPS 4420
    Run keyword if    ${gps_check}    Wait until keyword succeeds     20min    1min    Verify GPS Fault Should not in BTS    bts_host=${bts_host}
    Run keyword if    ${gps_check}    Wait until keyword succeeds     20min    1min    Verify GPS status should be avaliable    bts_host=${bts_host}
    #step1 login
     Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    #step2 get bts version before rollback
    ${preActiveVersion}    ${prePassiveVersion}    Get BTS Software Version    connection=${connection}
    #step3 execute rollback_build
    Log to console    Strat rollback BTS...
    coam.rollback_software    timeout=2400    connection=${connection}
    Run Keyword And Ignore Error    COAM Teardown gnb connections  connection=${connection}
    #step4 check if rollback success
    Wait until keyword succeeds     40min    1min    Check upgrade and rollback SW version
    ...    preActiveVersion=${preActiveVersion}    prePassiveVersion=${prePassiveVersion}    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections  connection=${connection}

Verify GPS Fault Should not in BTS
    [Arguments]    ${bts_host}     ${connection}=GNB_OAM_4420
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${active_alarms_list}    coam.get_active_alarms    connection=${connection}    timeout=15
    ${result}    set variable    ${False}
    FOR  ${alarm}  IN  @{active_alarms_list}
        ${faultid}    set variable    ${alarm}[faultId]
        ${result}    set variable if    '${faultid}'=='4420' or '${faultid}'=='1898'    ${True}    ${False}
        Exit For Loop If    ${result}
    END
    log to console    GPS alarm exists:${result}
    Should not be true    ${result}
    [Teardown]    Run Keyword And Ignore Error   COAM Teardown gnb connections  connection=${connection}

Verify GPS status should be avaliable
    [Arguments]    ${bts_host}     ${connection}=GNB_OAM_GPS_STASTUS
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${Get_information_BTS}    coam.get_bts_info    connection=${connection}
    ${Get_All_GNSS}     Set Variable    ${Get_information_BTS['gnsse']}
    ${GNSS_1}    Set Variable    ${Get_All_GNSS}[0]
    ${Get_stateInfo_GNSS}    Set Variable    ${GNSS_1['stateInfo']}
    ${Operational_status}    get from dictionary    ${Get_stateInfo_GNSS}    operationalState
    ${Admin_status}    get from dictionary    ${Get_stateInfo_GNSS}    administrativeState
    log to console    GPS Status: {Operational state:${Operational_status}, Administrative state:${Admin_status}}
    Should be equal as strings    ${Operational_status}    enabled
    Should be equal as strings    ${Admin_status}    Unlocked
    [Teardown]    Run Keyword And Ignore Error   COAM Teardown gnb connections  connection=${connection}

Check upgrade and rollback SW version
    [Arguments]    ${preActiveVersion}    ${prePassiveVersion}     ${connection}=GNB_OAM    ${bts_host}=${gNB_ip}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${activeVersion}    ${passiveVersion}    Get BTS Software Version    connection=${connection}
    ${prePassiveVersion_str}=	    Remove String	    ${prePassiveVersion}    SBTS00
    ${result1}    Run Keyword And Return Status    Should contain     ${activeVersion}    ${prePassiveVersion_str}
    ${result2}    Run Keyword And Return Status    Should Be Equal    ${preActiveVersion}    ${passiveVersion}
    ${sw_check}    Set variable if    ${result1} and ${result2}    ${True}    ${False}
    Log to console    sw_check: ${sw_check}
    should be true    ${sw_check}
    [Teardown]    Run Keyword And Ignore Error   COAM Teardown gnb connections  connection=${connection}

Classical gNB Rollback And Check On Air
    [Arguments]    ${bts_host}    ${allowed_list}    ${connection}=GNB_OAM    ${interval}=20    ${gps_check}=${True}
    Classical gNB Software Rollback    bts_host=${bts_host}     connection=${connection}    gps_check=${gps_check}
    ${result}    Run Keyword And Return Status    Check GNB on air And alarm    bts_host=${bts_host}    allowed_list=${allowed_list}
    ...    interval=${interval}
    Run Keyword If    '${result}'=='${False}'    run keyword and continue on failure    Save Snapshot    bts_host=${bts_host}
    run keyword if    '${result}'=='${False}'    run keyword and continue on failure    Capture RU log    bts_host=${bts_host}
    Should Be True    '${result}'=='${True}'

Classical gNB Software upgraded
    [Arguments]    ${bts_host}     ${target_version}    ${SW_build_path}=/home/ute/Downloads    ${connection}=GNB_OAM
    ...    ${gps_check}=${True}
    #pre-check GPS 4420
    Run keyword if    ${gps_check}    Wait until keyword succeeds     20min    1min    Verify GPS Fault Should not in BTS    bts_host=${bts_host}
    Run keyword if    ${gps_check}    Wait until keyword succeeds     20min    1min    Verify GPS status should be avaliable    bts_host=${bts_host}
    #step1 login
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    #step2  get bts version before upgrade
    ${preActiveVersion}    ${prePassiveVersion}    Get BTS Software Version    connection=${connection}
    #step3 exec upgrade_buid
    ${SW_build_path}    Set Variable    ${SW_build_path}/${target_version}
    upgrade build    SW_build_path=${SW_build_path}    target_version=${target_version}    connection=${connection}
    Run Keyword And Ignore Error    COAM Teardown gnb connections  connection=${connection}
    #step4 check if upgrade success
    Wait until keyword succeeds     40min    1min    Check upgrade and rollback SW version
    ...    preActiveVersion=${preActiveVersion}    prePassiveVersion=${target_version}    connection=${connection}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections  connection=${connection}

upgrade build
    [Arguments]    ${SW_build_path}    ${target_version}    ${connection}=GNB_OAM
    ${upgrade_package_path}    Set variable    ${SW_build_path}/${target_version}_release_BTSSM_downloadable_A54.zip
    ${status}    run keyword and return status   OperatingSystem.File Should Exist    ${upgrade_package_path}
    Run Keyword if     '${status}'=='False'     download upgrade packet    package_link=${package_link}    target_version=${target_version}
    ...    SW_build_path=${SW_build_path}
    Log to console    Strat upgrade BTS...
    coam.update_software    sw_package=${upgrade_package_path}    timeout=7200    connection=${connection}

download upgrade packet
    [Arguments]    ${package_link}    ${target_version}    ${SW_build_path}
    Log to console    Tips: target packet is not existed in UTE, will download it automitically.
    ${package_full_link}    Get link For Download from external value     package_link=${package_link}    target_version=${target_version}
    Download SW Build to VM     package_full_link=${package_full_link}    SW_build_path=${SW_build_path}

Get link For Download from external value
    [Arguments]    ${package_link}    ${target_version}
    @{result}    string.split string    string=${target_version}    separator=_
    ${target_release}     convert to string    ${result}[0]
    ${package_full_link}    Set Variable
    ...    ${package_link}${target_release}/${target_version}/${target_version}_release_BTSSM_downloadable_A54.zip
    [Return]      ${package_full_link}

Download SW Build to VM
    [Arguments]    ${package_full_link}    ${SW_build_path}
    OperatingSystem.Create Directory    ${SW_build_path}
    OperatingSystem.Empty Directory    ${SW_build_path}
    Run And Return Rc And Output    wget --no-proxy ${package_full_link}.sha256 -P ${SW_build_path}
    ${output}    OperatingSystem.List Directory    ${SW_build_path}    absolute=${TRUE}
    ${md5_file}     set variable    ${output}[0]
    ${md5_value}      OperatingSystem.get file    ${md5_file}
    OperatingSystem.Empty Directory    ${SW_build_path}
    Run And Return Rc And Output    wget --no-proxy ${package_full_link} -P ${SW_build_path}
    ${output}    OperatingSystem.List Directory    ${SW_build_path}    absolute=${TRUE}
    ${upgrade_package_path}     set variable    ${output}[0]
    sleep    1min
    wait until keyword succeeds    10min    10s    check the download completed    ${upgrade_package_path}     ${md5_value}
    Log to console    Download completed: ${upgrade_package_path}.

check the download completed
    [Arguments]    ${upgrade_package_path}    ${md5_value}
    ${sum}=        Set Variable     sha256sum ${upgrade_package_path}
    ${res}    ${output}    Run And Return Rc And Output    ${sum}
    ${res}    string.split string    ${output}s
    should be equal    ${md5_value}    ${res}[0]

Classical gNB Upgraded And Check On Air
    [Arguments]    ${bts_host}    ${allowed_list}    ${target_version}    ${SW_build_path}=/home/ute/Downloads    ${connection}=GNB_OAM
    ...    ${interval}=20    ${gps_check}=${True}
    Classical gNB Software upgraded    bts_host=${bts_host}     target_version=${target_version}    SW_build_path=${SW_build_path}
    ...    connection=${connection}    gps_check=${gps_check}
    ${result}    Run Keyword And Return Status    Check GNB on air And alarm    bts_host=${bts_host}    allowed_list=${allowed_list}
    ...    interval=${interval}
    Run Keyword If    '${result}'=='${False}'    run keyword and continue on failure    Save Snapshot    bts_host=${bts_host}
    run keyword if    '${result}'=='${False}'    run keyword and continue on failure    Capture RU log    bts_host=${bts_host}
    Should Be True    '${result}'=='${True}'

Fetch Information From Webpage
    [Arguments]    ${url}
    Create Session    mysession    ${url}
    ${response}    Get Request    mysession    /
    ${content}    Set Variable    ${response.content}
    # Add parsing logic here to extract the desired information
    ${extracted_info}    Evaluate    parse_content(${content})
    [Return]    ${extracted_info}

Get Branch Version And Package Version
    [Arguments]    ${software_version}
    ${version_list}    Split String    ${software_version}    _
    ${branch_version}    Set Variable If    '${version_list}[2]'=='9999'    SBTS00    ${version_list}[0]
    Set List Value    ${version_list}    ${0}    ${branch_version}
    ${software}    Evaluate    '_'.join(${version_list})
    [Return]    ${branch_version}    ${software}

Get BTS ActiveVersion
    [Arguments]    ${bts_host}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${ActiveVersion}    ${PassiveVersion}    Get BTS Software Version    connection=${connection}
    ${branch_version}    ${software}    Get Branch Version And Package Version    software_version=${ActiveVersion}
    [Return]    ${branch_version}    ${software}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections  connection=${connection}

Lock BTS BaseBand
    [Arguments]    ${BBMOD_id_list}    ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM    ${timeout}=60
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    FOR   ${id}   IN  @{BBMOD_id_list}
        coam.lock    dist_name=MRBTS-${TL_BTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-${id}    connection=${connection}    timeout=${timeout}
    END
    [Teardown]    COAM Teardown gnb connections  connection=${connection}

UnLock BTS BaseBand
    [Arguments]    ${BBMOD_id_list}    ${bts_host}=${gNB_ip}
    FOR   ${id}   IN  @{BBMOD_id_list}
        @{unlock_para}    Create list
        ${para_dict}    Create Dictionary    dist_name=MRBTS-${TL_BTS_ID}/EQM-1/APEQM-1/CABINET-1/BBMOD-${id}
        ...    parameter=administrativeState    value=Unlocked    operation=update
        Append to list    ${unlock_para}    ${para_dict}
        Modify Parameters with json    input_list=${unlock_para}    bts_host=${bts_host}
    END
    Check GNB on air    bts_host=${bts_host}

############ check bts on air #################
Adapt to ute cloud commission scf
    ${TL_NAME}   set variable if      '${testline_name}' == '${EMPTY}'    ${CONFIGURATION}    ${testline_name}
    ${pattern}   Set Variable    7_5(.*)
    ${TLNAME_TMP}    Get Regexp Matches     ${TL_NAME}    ${pattern}    1
    ${TL_NAME}   Set Variable    7_5${TLNAME_TMP}[0]
    Set Suite Variable    ${CURDIR_path}    ${CURDIR}/../../../../../../commissionings/HGZ/${TL_NAME}

Set default SCF
    [Arguments]      ${scf_name}=${Empty}    ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${version}    coam.get_sw_version    connection=${connection}
    ${version_list}    split string    ${version}    separator=_
    ${version_scf}    run keyword if    '${version_list[2]}'=='9999'    Set Variable    SBTS00
    ...    ELSE   Set Variable    ${version_list[0]}
    ${default_scf_path}    set variable    ${CURDIR_path}/SCF_${version_scf}${scf_name}.xml
    set suite variable    ${default_scf_path}
    log to console   ${default_scf_path}
    [Teardown]     Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Setup Commission SCF
    [Arguments]  ${scf_name}=${Empty}    ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM    ${timeout}=600
    Adapt to ute cloud commission scf
    Set default SCF    scf_name=${scf_name}    bts_host=${bts_host}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    COAM Commission with scf file    scf_file_path=${default_scf_path}    connection=${connection}    timeout=${timeout}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Check GNB on air
    [Timeout]    20 min
    [Arguments]  ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM     ${time}=20min    ${interval}=20    ${check_lte_cell}=${False}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
#    Wait Until Keyword Succeeds    20min    20s    COAM Check GNB cell on air    connection=${connection}
    Wait Until Keyword Succeeds    ${time}    ${interval}s    Verify all cells should be onair1
    ...    cell_type=nr    connection=${connection}    timeout=${interval}
    Run Keyword If    ${check_lte_cell}    Wait Until Keyword Succeeds    ${time}    ${interval}s    Verify all cells should be onair1
    ...    cell_type=lte    connection=${connection}    timeout=${interval}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Verify all cells should be onair1
    [Documentation]    Description: verify all the cells status should be correct.
    [Arguments]    ${cell_type}=nr  ${connection}=GNB_OAM    ${timeout}=20
    Log to console    Verify all cells are on air
    ${administrative_expected}    Set Variable      Unlocked      # NR
    ${administrative_expected}    Set Variable If   '${cell_type}'=='lte'    unlocked    ${administrative_expected}
    ${cells_info}   coam.get_cells_info  cell_type=${cell_type}    timeout=${timeout}    connection=${connection}
    FOR    ${cell}    IN    @{cells_info}
        ${cell_type}    Is NRPOSCELL Or NRCELL    ${cell}
        #Log To Console    nr cell type: ${cell_type}
        Run keyword and continue on failure    Should Be Equal As Strings    ${cell['status']['administrativeState']}
        ...      ${administrative_expected}
        Run keyword and continue on failure    Should Be Equal As Strings    ${cell['status']['operationalState']}    enabled
        Run keyword and continue on failure    Dictionary Should Not Contain Key    ${cell['status']}     availabilityStatus
    END

Is NRPOSCELL Or NRCELL
    [Documentation]    Description: check if current cell is NRCELL or NRPOSCELL base cell info
    ...    {'antennaMode': '4RX',
    ...    'id': {'configuration': 'MRBTS-37600/NRBTS-37600/NRPOSCELL-10',
    ...    'internal': '/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-37600/NRPOSCELL_R-10'},
    ...    'nrCellIdentity': 4,
    ...    'nrPosCellId': 10,
    ...    'nrPosCellType': '0DL4UL',
    ...    'status': {'administrativeState': 'Unlocked',
    ...             'barringStatus': 'unbarred',
    ...             'blockingState': 'Unblocked',
    ...             'operationalState': 'enabled'},
    ...  'trpId': [15]}
    [Arguments]    ${cell}
    # if nrPosCellId exsited in key of cell, return NRPOSCELL else return NRCELL
    ${key_items}    Get Dictionary Keys    ${cell}
    ${is_nrposcell}    Set Variable If    'nrPosCellId' in ${key_items}    NRPOSCELL    NRCELL
    [Return]    ${is_nrposcell}

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
    Run Keyword if    ${allowed_list} != None        Check List1 content in List2    list1=${history_id_list}    list2=${allowed_list}
    Run Keyword if    ${not_allowed_list} != None    Check List1 content not in List2    list1=${not_allowed_list}    list2=${history_id_list}

Check Alarm List on BTS
    [Arguments]  ${allowed_list}    ${not_allowed_list}=None    ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM
    ${status}    Run Keyword And Return Status    Check Alarm List on BTS Temp    allowed_list=${allowed_list}
    ...    not_allowed_list=${not_allowed_list}    bts_host=${bts_host}    connection=${connection}
#    Run Keyword if    ${status} == ${False}    Save Snapshot
    Should be equal    ${status}    ${True}

Check List1 content in List2
    [Arguments]  ${list1}    ${list2}
    ${list1}    Evaluate    list(set(${list1}))
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

Get Station Procedura State
    [Arguments]    ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM
    Log To Console    Get Station Procedura State for ${bts_host}
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
    [Arguments]    ${if_muti_rat}=${False}    ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM
    ${BBOMD_status_dict}    Get Station Procedura State    bts_host=${bts_host}    connection=${connection}
    ${BBMOD_id_list}    Get Dictionary Keys    ${BBOMD_status_dict}
    FOR  ${BBMOD_id}  IN  @{BBMOD_id_list}
        ${BBMOD_status}    Get From Dictionary    ${BBOMD_status_dict}    ${BBMOD_id}
        ${BBMOD_status_procedura}    Get From Dictionary    ${BBOMD_Procedura_status_dict}    ${BBMOD_id}
        Append To List    ${BBMOD_status_procedura}    ${BBMOD_status}
        Set To Dictionary    ${BBOMD_Procedura_status_dict}    ${BBMOD_id}    ${BBMOD_status_procedura}
    END
    Run Keyword If    ${if_muti_rat}    Check all cells info should be onair    connection=${connection}
    ...    ELSE    Verify all cells should be onair    connection=${connection}
    [Return]    ${BBOMD_Procedura_status_dict}

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
    [Return]    ${status}

Check Mutil BBMOD Status
    [Arguments]    ${BBOMD_Procedura_status_dict}   ${BBMOD_list}
    FOR  ${id}  IN  @{BBMOD_list}
        ${BBMOD_id}    Set Variable    BBMOD-${id}
        ${status_list}    Get From Dictionary    ${BBOMD_Procedura_status_dict}    ${BBMOD_id}
        ${status}    Judging The Median Change In The List    input_list=${status_list}
        Should Be True    ${status}
    END

Check GNB On Air With BBMOD Reset Procedura
    [Timeout]    20 min
    [Arguments]  ${BBMOD_list}    ${cell_on_air_time}    ${station_on_air_time}    ${if_muti_rat}=${False}    ${bts_host}=${gnb_ip}
    ...    ${connection}=GNB_OAM
    ${BBOMD_Procedura_status_dict}    Set initial state     bts_host=${bts_host}    connection=${connection}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    Wait Until Keyword Succeeds    ${cell_on_air_time}    20s    COAM Check GNB cell on air    connection=${connection}
    Wait Until Keyword Succeeds    ${station_on_air_time}    20s    Check GNB cell on air Procedura    connection=${connection}
    ...    if_muti_rat=${if_muti_rat}
    Check Mutil BBMOD Status    BBOMD_Procedura_status_dict=${BBOMD_Procedura_status_dict}   BBMOD_list=${BBMOD_list}
    [Return]    ${BBOMD_Procedura_status_dict}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

############# Modify Parameter #################
Modify Parameters with json
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

Modify Parameter And Wait On Air
    [Timeout]    20min
    [Arguments]    ${input_list}    ${bts_host}=${gNB_ip}    ${delta_id}=update_parameter    ${connection}=GNB_OAM    ${interval}=20
    Modify Parameters with json    input_list=${input_list}    bts_host=${bts_host}    delta_id=${delta_id}
    ...    connection=${connection}    time=10s
    Check GNB on air    bts_host=${bts_host}    connection=${connection}    interval=${interval}

Get Distname Parameters Vlaue
    [Arguments]    ${dist_name}    ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${parameter_info}    coam.get_parameter_by_distname    dist_name=${dist_name}    connection=${connection}
    [Return]    ${parameter_info}
    [Teardown]    run keyword and ignore error    coam.teardown      connection=${connection}

############# Capture Logs #################
Save Snapshot
    [Arguments]    ${bts_host}=${gNB_ip}    ${connection}=cOAM    ${timeout}=10min
    log to console    Save Snapshot...
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    run keyword and ignore error     coam.teardown    connection=${connection}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}
    ...    connection=${connection}
    ${snapshot_path}    coam.get_snapshot    target_file_name=${output_dir}/${timestamp}_snapshot.zip    connection=${connection}
    ...    timeout=${timeout}
    Log to console    snapshot saved in: ${output_dir}/${timestamp}_snapshot.zip
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}
    [Return]    ${snapshot_path}

Capture RU log
    [Documentation]    currently only for AQQL/AQQY
    [Arguments]    ${bts_host}=${gNB_ip}    ${connection}=rf_log_caom
    [Timeout]    10m
    Log to console    Start to capture RU log.
    Create Directory     ${OUTPUT_DIR}/rulogs/
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    capture_ru_logs    host=${bts_host}    username=${gNB_ssh_username}    password=${gNB_ssh_password}    timestamp=${timestamp}
    csn.connect_to   hostname=${bts_host}    username=${gNB_ssh_username}    password=${gNB_ssh_password}    alias=${connection}
    ${remote_path}    set variable    /ffs/run/config/toor4nsn/
    csn.send_command    command=find ${remote_path} -maxdepth 1 -type f | grep rulog    connection=${connection}
    ${output}    csn.read_output    connection=${connection}
    ${list}    Split To Lines    ${output}
    FOR    ${file}    IN    @{List}
        log to console    download: ${file}
        ${file_name}    String.Fetch From Right    ${file}    marker=/
        csn.download_file   remote_path=${file}   local_path=${OUTPUT DIR}/rulogs/${file_name}   connection=${connection}
    END
    [Teardown]    Run Keyword And Ignore Error    csn.disconnect    connection=${connection}

###############  selenium_coam   ############################
WEBUI Login
    [Arguments]      ${bts_host}
    [Documentation]   WEBUI Login
    ${branch_version}    ${software}    Get BTS ActiveVersion    bts_host=${bts_host}
    Log To Console  START:WEBUI Login
    Log To Console  Try to login...
    selenium_coam.Enable_Virtual_Display
    selenium_coam.Login    url=https://${bts_host}    username=${gNB_username}   password=${gNB_password}    version=${branch_version}
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
    Run Keyword If      ${virtual_disable}    Run Keyword And Ignore Error    selenium_coam.Disable_Virtual_Display
    Run Keyword And Ignore Error  selenium_coam.Logout
    Log To Console  Logout successfully...
    Sleep    3s
    Log To Console  END:WEBUI Logout!

Delete Nrcells Data
    [Arguments]  ${BTS_ID}    ${NRBTS_ID}    ${cell_id_list}    ${nrcellgrp_id_list}    ${node_index_list}
    ${length}    Get Length    ${cell_id_list}
    FOR   ${item}    IN RANGE   ${length}
        selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id_list}[${item}]
        selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-${nrcellgrp_id_list}[${item}]
        selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id_list}[${item}]
        selenium_coam.remove_element   dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
        ...    filter_param=Reference to cell group    node_index=${node_index_list}[${item}]    abbr=refNrCellGroup
    END

Add Nrcells Data
    [Arguments]  ${scf_name}    ${bts_host}   ${BTS_ID}    ${NRBTS_ID}    ${cell_id_list}    ${nrcellgrp_id_list}    ${node_index_list}
    ...    ${scf_path}=None
    Adapt to ute cloud commission scf
    Set default SCF    scf_name=${scf_name}    bts_host=${bts_host}
    ${commisioning_file}    set variable if    '${scf_path}' != 'None'    ${scf_path}    ${default_scf_path}
    Log To Console    Add nrcell
    selenium_coam.load_commissioning_file_and_check_load_status    file_path=${commisioning_file}
    ${length}    Get Length    ${cell_id_list}
    FOR   ${item}    IN RANGE   ${length}
        ${cell_id}    set variable    ${cell_id_list}[${item}]
        selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}   object_class_name=NRCELL    plan_to_copy_from=${copy_from_plan}
        ...    copy_from=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}    include_subobject=${TRUE}    id_value=${cell_id}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ...    filter_param=Local cell resource ID   new_value=${cell_id}    abbr=lcrId
        selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1   object_class_name=LCELNR
        ...    plan_to_copy_from=${copy_from_plan}    copy_from=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}
        ...    include_subobject=${TRUE}    id_value=${cell_id}
        selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}   object_class_name=NRCELLGRP
        ...    plan_to_copy_from=${copy_from_plan}    copy_from=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-${nrcellgrp_id_list}[${item}]
        ...    include_subobject=${TRUE}    id_value=${nrcellgrp_id_list}[${item}]
        selenium_coam.add_element    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
        ...    filter_param=Reference to cell group    abbr=refNrCellGroup
        selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
        ...    filter_param=Reference to cell group    new_value=${nrcellgrp_id_list}[${item}]
        ...    node_index=${node_index_list}[${item}]    abbr=refNrCellGroup
    END

Add Or Delete Cell By WebUI
    [Arguments]  ${if_add}    ${bts_host}    ${scf_name}   ${BTS_ID}    ${NRBTS_ID}    ${cell_id_list}    ${nrcellgrp_id_list}
    ...    ${node_index_list}    ${scf_path}=None    ${copy_from_plan}=CONF-1
    set suite variable    ${copy_from_plan}
    WEBUI Login    bts_host=${bts_host}
    run keyword if    ${if_add}    Add Nrcells Data    scf_name=${scf_name}    bts_host=${bts_host}   BTS_ID=${BTS_ID}    NRBTS_ID=${NRBTS_ID}
    ...    cell_id_list=${cell_id_list}    nrcellgrp_id_list=${nrcellgrp_id_list}    node_index_list=${node_index_list}    scf_path=${scf_path}
    ...    ELSE    Delete Nrcells Data    BTS_ID=${BTS_ID}    node_index_list=${node_index_list}
    ...    NRBTS_ID=${NRBTS_ID}    cell_id_list=${cell_id_list}    nrcellgrp_id_list=${nrcellgrp_id_list}
    ${error}    selenium_coam.validate_plan
    Log To Console    ${error}
    Log To Console    Activate plan
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${False}    timeout=${180}
    [Teardown]    WEBUI Logout


Adjust the HBTE attenuation value
    [Arguments]      ${value_list}    ${port_list}
    att.setup_attenuator    ip_addr=${att_ipaddr}    port=${att_api_port}    model=${tl.attenuator.model}
    ...    attenuation_port_numbers=${att_connection_port}    max_attenuation=${127}    vendor=HBTE
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

Modify Swconfig File
    [Documentation]    Modify ffs/run/swoncifg.txt file
    [Arguments]    ${para_update}    ${bts_host}=${gNB_ip}    ${local_path}=${OUTPUT_DIR}
    Run    rm ${local_path}/swconfig*
    csn.Connect to     hostname=${bts_host}    username=${gNB_ssh_username}    password=${gNB_ssh_password}    alias=ASIK Master
    csn.send command    command=touch /ffs/run/swconfig.txt    connection=ASIK Master
    csn.send command    command=cp /ffs/run/swconfig.txt /ffs/run/swconfig.txt.bak   connection=ASIK Master
    swconf.Download swConfig file from asik to test pc    localFilePath=${local_path}/swconfig.txt
    ...                                                   asik_alias=ASIK Master
    ...                                                   remoteFilePath=/ffs/run/swconfig.txt
    FOR   ${swconfig}   IN   @{para_update}
        ${config_id}    should match regexp     ${swconfig}    .*?(?==)
        Run   sed -i -e '/${config_id}.*=.*/'d ${local_path}/swconfig.txt
    END
    swconf.Modify swConfig file    parametersList=${para_update}    filePath=${local_path}/swconfig.txt
    swconf.Upload swConfig file to asik and crasign    localFilePath=${local_path}/swconfig.txt
    ...                                                asik_alias=ASIK Master
    run keyword and ignore error  csn.disconnect    connection=ASIK Master

############# Capture LMI Log ###############
Capture LMI Log
    [Arguments]    ${gnb_index}    ${ru_serial_list}    ${log_dir}=${OUTPUT_DIR}/${TEST_NAME}
    Log To Console   //TODO: UUF Catch RU Log
    Log To Console   ${RU_LOG_FLAG}
    ${log_dir_not_exist}   Run Keyword And Return Status   OperatingSystem.Directory Should Not Exist   ${log_dir}
    Run Keyword If   ${log_dir_not_exist}   OperatingSystem.Create Directory   ${log_dir}
    ${RU_serial_pc_info}    UUF Get RU PC Info Accordind To Serial    ru_serial_list=${ru_serial_list}
    UUF Catch RU Log From LMI    testline=gnb_${gnb_index}    ru_list=${RU_serial_pc_info}

Capture LMI Log For Cloud
    [Arguments]    ${gnb_index}    ${ru_serial_list}    ${log_dir}=${OUTPUT_DIR}/${TEST_NAME}
    ${vdu_version}    vDu Get software version
    ${vdu_version_tmp}    replace string    ${vdu_version}    vDUCNF    SBTS
    ${bts_version}    String.fetch from left    ${vdu_version_tmp}    marker=_
    Log To Console   //TODO: UUF Catch gnb_${gnb_index} RU Log
    ${log_dir_not_exist}   Run Keyword And Return Status   OperatingSystem.Directory Should Not Exist   ${log_dir}
    Run Keyword If   ${log_dir_not_exist}   OperatingSystem.Create Directory   ${log_dir}
    ${RU_serial_pc_info}    UUF Get RU PC Info Accordind To Serial    ru_serial_list=${ru_serial_list}
    FOR    ${ru_detail}    IN    @{RU_serial_pc_info}
        ${pc_ip}    Get From Dictionary    ${ru_detail}    test_pc_addr
        ${pc_username}    Get From Dictionary    ${ru_detail}    test_pc_username
        ${pc_password}    Get From Dictionary    ${ru_detail}    test_pc_password
        csn.connect_to   hostname=${pc_ip}    username=${pc_username}    password=${pc_password}    alias=linux_pc
        csn.send_command    command=rm /home/ute/.ssh/known_hosts    connection=linux_pc
        Run Keyword And Ignore Error    csn.disconnect    connection=linux_pc
        ${timestamp}    DateTime.Get current date    result_format=%Y%m%d%H%M%S
        ${ru_log_path}   UUF Single RU Catch RU Log From LMI   ru_detail=${ru_detail}   active_release=${bts_version}
        ...   log_dir=${log_dir}    prefix=${timestamp}
        Log To Console    RU log Saved: ${ru_log_path}
    END

Online_Changing_cablink_linkspeed_in_loops
    [Arguments]    ${MAX_LOOP}=${1}    ${bts_host}=${gNB_ip}
    WEBUI Login    bts_host=${bts_host}
    FOR    ${TEST_LOOP}    IN RANGE    1    ${MAX_LOOP}+1
        Online_Changing_cablink_linkspeed
    END
    [Teardown]    WEBUI Logout

Online_Changing_cablink_linkspeed
    [Arguments]    ${bts_host}=${gNB_ip}    ${allowed_list}=${allowed_alarm_list}
    FOR    ${speed}    IN    @{speed_values_list}
        FOR    ${cablink_id}    IN    @{cablink_list}
            Log To Console    \nModify the cablink ${cablink_id} link speed to ${speed}
            selenium_coam.set_parameter_value
            ...    dist_name=MRBTS-${BTS_ID}/EQM-1/HWTOP-1/CABLINK-${cablink_id}
            ...    filter_param=Link speed    abbr=linkSpeed    new_value=${speed}
        END
        ${error}    selenium_coam.validate_plan
        Log To Console    ${error}
        selenium_coam.activate_plan    download_plan_without_activation=${False}
        ...    activate_plan_despite_errors=${True}    timeout=${180}
        Wait Until Keyword Succeeds    10min    50s    Check GNB on air And alarm    bts_host=${bts_host}
        ...    allowed_list=${allowed_list}
        Sleep    30s
    END

Lock and Unlock NRCELL Via administrativeState
    [Documentation]    (lock/unlock)_cell_list=[1,2,3,4]
    [Arguments]    ${connection}=lock_unlock_coam    ${gnb_index}=${0}
    ...    ${lock_cell_list}=${EMPTY_List}    ${unlock_cell_list}=${EMPTY_List}
    ...    ${allowed_list}=${allowed_alarm_list}
    ${lock_cell_list_distname}    Generate NRCELL distname by id    gnb_index=${gnb_index}    NRCELL_id_list=${lock_cell_list}
    ${unlock_cell_list_distname}    Generate NRCELL distname by id    gnb_index=${gnb_index}    NRCELL_id_list=${unlock_cell_list}
    Connect to gnb coam via ssl    gnb_index=${gnb_index}    connection=${connection}
    ${NRCELL_Op_list}    create List
    FOR  ${cell_distname}  IN  @{unlock_cell_list_distname}
        ${NRCELL_dict_item}    create dictionary
        Set to dictionary    ${NRCELL_dict_item}    dist_name=${cell_distname}
        Set to dictionary    ${NRCELL_dict_item}    parameter=administrativeState
        Set to dictionary    ${NRCELL_dict_item}    value=Unlocked
        Set to dictionary    ${NRCELL_dict_item}    operation=update
        Append to list    ${NRCELL_Op_list}    ${NRCELL_dict_item}
    END
    FOR  ${cell_distname}  IN  @{lock_cell_list_distname}
        ${NRCELL_dict_item}    create dictionary
        Set to dictionary    ${NRCELL_dict_item}    dist_name=${cell_distname}
        Set to dictionary    ${NRCELL_dict_item}    parameter=administrativeState
        Set to dictionary    ${NRCELL_dict_item}    value=Locked
        Set to dictionary    ${NRCELL_dict_item}    operation=update
        Append to list    ${NRCELL_Op_list}    ${NRCELL_dict_item}
    END
    ${bts_ip}    set variable    ${tl.gnbs[${gnb_index}].dus[${0}].f1_m_ip_addr}
    Log to console    BTS modify parameters: ${NRCELL_Op_list}
    Modify Parameters with json    bts_host=${bts_ip}    input_list=${NRCELL_Op_list}    connection=para_coam
    Wait Until Keyword Succeeds    60s    10s    Check nrcell lock unlock status    connection=${connection}
    ...    lock_cell_list=${lock_cell_list}    unlock_cell_list=${unlock_cell_list}
    Check Alarm List on BTS    allowed_list=${allowed_list}    bts_host=${bts_ip}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Generate NRCELL distname by id
    [Arguments]    ${gnb_index}=${0}    ${NRCELL_id_list}=${empty_list}
    ${NRCELL_distname_list}    Create List
    ${MRBTS_id}    set variable    ${tl.gnbs[${gnb_index}].instance_id}
    ${NRBTS_id}    set variable    ${tl.gnbs[${gnb_index}].global_bts_id}
    FOR    ${nrcell_id}    IN    @{NRCELL_id_list}
        ${distname}    set variable    MRBTS-${MRBTS_id}/NRBTS-${NRBTS_id}/NRCELL-${nrcell_id}
        Append to list    ${NRCELL_distname_list}    ${distname}
    END
    [Return]    ${NRCELL_distname_list}

Check nrcell lock unlock status
    [Arguments]    ${connection}    ${lock_cell_list}=${EMPTY_List}    ${unlock_cell_list}=${EMPTY_List}
    ${cellinfo_list}    coam.get_cells_info    cell_type=nr    connection=${connection}
    FOR  ${cell_id}  IN  @{cellinfo_list}
        ${cell_distname}    set variable    ${cell_id}[id][configuration]
        ${cell_status}    set variable    ${cell_id}[status]
        ${is_lock_cell}    Run Keyword And Return Status    List Should Contain Value    ${lock_cell_list}    ${cell_distname}
        ${is_unlock_cell}    Run Keyword And Return Status    List Should Contain Value    ${unlock_cell_list}    ${cell_distname}
        Run Keyword If    ${is_lock_cell}==${True} and ${is_unlock_cell}==${False}
        ...    Check nrcell status should as expected    lock    ${cell_status}
        Run Keyword If    ${is_unlock_cell}==${True} and ${is_lock_cell}==${False}
        ...    Check nrcell status should as expected    unlock    ${cell_status}
    END

Check nrcell status should as expected
    [Arguments]    ${status_expected}    ${cell_status}
    [Documentation]    ${status_expected} should be lock or unlock
    Log to console    Verify cells status after cell lock/unlock
    ${administrative_expected}    set variable if    '${status_expected}'=='lock'    Locked    Unlocked
    ${operationalState}    set variable if    '${status_expected}'=='lock'    disabled    enabled
    Should Be Equal As Strings    ${cell_status['administrativeState']}    ${administrative_expected}
    Should Be Equal As Strings    ${cell_status['operationalState']}    ${operationalState}
    Run keyword if    '${status_expected}'=='unlock'    Dictionary Should Not Contain Key    ${cell_status}     availabilityStatus
    Run keyword if    '${status_expected}'=='lock'    Dictionary Should Contain Key    ${cell_status}     availabilityStatus
