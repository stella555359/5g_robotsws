*** Settings ***
Documentation    author：Hongyu Jiang
...              contact: hongyu.jiang@nokia-sbell.com
...              squad group: mmw_SG_04

Library     BuiltIn
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Commercial_mobile_phone_adb_common_keywords.robot
Resource    taf/rfrl/common_resources/robot/TTI_Trace.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF_NEW/Resource/UUF_LogCollection.robot
Variables   testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF_NEW/Config/UUF_Vars.py
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/TTI_Trace_Analysis_MMW4.py
Library     TTI_Trace_Analysis_MMW4.TTI_Trace_analysis    WITH NAME    TTI_Trace
Library     taf.transport.ssh      WITH NAME    ssh
Library     taf.sbts.oam.coam.admin       WITH NAME    coam
Library     taf.hw.rf_attenuator    WITH NAME    att
Library     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001937_OTA/resources/samsung_sigspark.py
Library     samsung_sigspark.SigSpark    WITH NAME    samsung_spark
Library    taf.selenium.sbts       WITH NAME    selenium_coam
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/throughput/nrdim_throughput/interface.py    WITH NAME
...    throughput_computation
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/UE_start_traffic.robot
Variables    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB012997/Resources/TLConfigration_12997.py
Variables    ./CB009102_modify_para.py



*** Variables ***
${gNB_ip}                     ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${gNB_username}               ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gNB_password}               ${tl.gnbs[0].cu.oam_http_connection_details.password}
${gnb_ssh_username}           ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${gnb_ssh_password}           ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${ul_power_port_list}         ${tl.ues[0].iperf_details.ports[0:3]}
${dl_power_port_list}         ${tl.ues[0].iperf_details.ports[3:6]}
${control_pc}                 ${tl.ues[0].ssh_connection_details.addr}
${control_pc_name}            ${tl.ues[0].ssh_connection_details.username}
${control_pc_pass}            ${tl.ues[0].ssh_connection_details.password}
${UTE_ADDRESS}                ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}               ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}               ${tl.test_pc.default_ssh_connection_details.password}
${iperf_addr}                 ${tl.ues[0].iperf_details.ssh_connection_details.addr}
${GNB_PDU_IP}                 ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${GNB_PDU_PORT}               ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}
${att_ipaddr}                 ${tl.attenuator.ip_addr}
${att_api_port}               ${tl.attenuator.port}
${att_connection_port}        ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${BTS_ID}                     ${tl.gnbs[0].instance_id}
${NRBTS_ID}                   ${tl.gnbs[0].global_bts_id}
${AQQQA_PDU_IP}                ${tl.pdus[1].addr}
${AQQQA_PDU_IP_Port}           ${tl.pdus[1].port_numbers[3]}
#${AQQQA_PDU_IP_Port_1}          ${tl.attenuator[1].attenuation_port_numbers[1]}
@{RU_id_list}                 ${1}   ${2}   ${3}   ${4}   ${5}   ${6}
@{RU_unlock_status}           Unlocked    enabled    Active    configured
@{RU_lock_status}             Locked    enabled    Idle    configured
@{Cell_unblock_status}        Unlocked    enabled    Active    configured    Unblocked
@{Cell_block_status}          Unlocked    disabled    Idle    configured    Blocked
@{allowed_list}    ${4592}    ${4655}    ${61524}    ${4654}    ${61649}    ${4681}    ${61652}    ${61011}    ${61618}
@{cell_list}            599744   599745    599746    599747    599754   599755    599756    599750
@{all_ue_type_list}           xiaomi    xiaomi    samsung
@{all_ue_index_list}          ${0}    ${1}    ${2}
@{physCellId_list1}           ${169}    ${170}    ${171}    ${172}    ${173}    ${174}
@{empty_list}
@{physCellId_list_ALL}           ${169}    ${170}    ${161}    ${172}    ${173}
@{super_cell_list1}            184754    184755    184757    184758
${model}                     ${tl.attenuator.model}
@{cell_id_list}             ${0}    ${1}    ${2}    ${3}    ${4}    ${5}
@{ul_tp_list}               ${70}   ${100}
@{ru_serial_list}           EB2210R0253    EB2125R0146    EB2126R0067    1M214010056


*** Keywords ***
########### setup and teardown KW #################
Suite Setup
#    CI_interface.Common Suite Setup
    robot_common_operations.Common Suite Setup
    Adapt to ute cloud commission scf
    Adjust AQQY PA
    Setup Commission SCF
    Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}

Suite Teardown
    robot_common_operations.Common Suite Teardown



Case Teardown
    Run Keyword if    "${TEST_STATUS}"=="FAIL"    Save Snapshot
    Run keyword if    "${TEST_STATUS}"=="FAIL"    Capture LMI Log    gnb_index=${0}    ru_serial_list=${ru_serial_list}
    Setup Commission SCF
    Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}
    robot_common_operations.Common case Teardown
    CI_interface.Common Case Teardown



Case setup
    robot_common_operations.Common case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=49


Adapt to ute cloud commission scf
    ${TL_NAME}   set variable if      '${testline_name}' == '${EMPTY}'    ${CONFIGURATION}    ${testline_name}
    ${pattern}   Set Variable    7_5(.*)
    ${TL_NAME_1}   Get Regexp Matches     ${TL_NAME}    ${pattern}    1
    ${TL_NAME_1}   Set Variable    7_5${TL_NAME_1}[0]
    Set Suite Variable    ${CURDIR_path}    ${CURDIR}/../../../../../../commissionings/HGZ/${TL_NAME_1}

########### download SCF and check bts on air #################
Set default SCF
    [Arguments]    ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}
    ...    connection=${connection}
    ${version}    coam.get_sw_version    connection=${connection}
    ${version_list}    split string    ${version}    separator=_
    ${version_scf}    run keyword if    '${version_list[2]}'=='9999'    Set Variable    SBTS00
    ...    ELSE   Set Variable    ${version_list[0]}
    ${default_scf_path}    set variable    ${CURDIR_path}/SCF_${version_scf}.xml
    set suite variable    ${default_scf_path}
    log to console   ${default_scf_path}
    [Teardown]     Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Setup Commission SCF
    [Arguments]    ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM
    Set default SCF   bts_host=${bts_host}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}
    ...    connection=${connection}
    COAM Commission with scf file    scf_file_path=${default_scf_path}    timeout=9min    connection=${connection}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Check GNB on air
    [Timeout]    30 min
    [Arguments]  ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM
    Wait Until Keyword Succeeds    20min    20s
    ...    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}
    ...    connection=${connection}
    Wait Until Keyword Succeeds    30min    20s    COAM Check GNB cell on air    connection=${connection}
    Wait Until Keyword Succeeds    30min    20s    Verify all cells should be onair    connection=${connection}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Get Alarm on BTS
    [Arguments]  ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}
    ...    connection=${connection}
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

check fault10 from BTS
    [Arguments]    ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM
    ${actual_fault_id_list}    ${history_id_list}    Get Alarm on BTS    bts_host=${bts_host}    connection=${connection}
#    FOR    ${item}    IN     @{fault_list}
    Should contain    ${actual_fault_id_list}    ${10}
#    END

Check Alarm List on BTS Temp
    [Arguments]  ${allowed_list}=None    ${not_allowed_list}=None    ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM
    ${actual_fault_id_list}    ${history_id_list}    Get Alarm on BTS    bts_host=${bts_host}    connection=${connection}
    ${history_id_len}    Get Length    ${history_id_list}
    Run Keyword if    ${allowed_list} != None        Check List1 content in List2    list1=${actual_fault_id_list}
    ...    list2=${allowed_list}
    Run Keyword if    ${not_allowed_list} != None     Check List1 content not in List2    list1=${not_allowed_list}
    ...    list2=${actual_fault_id_list}
    Run Keyword if    ${history_id_len} != ${0}    Save Snapshot
    Should be equal    ${history_id_len}    ${0}

Check Alarm List on BTS
    [Arguments]  ${allowed_list}=None    ${not_allowed_list}=None    ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM
    ${status}    Run Keyword And Return Status    Check Alarm List on BTS Temp    allowed_list=${allowed_list}
    ...    not_allowed_list=${not_allowed_list}    bts_host=${bts_host}    connection=${connection}
    Run Keyword if    ${status} == ${False}    Save Snapshot
    Should be equal    ${status}    ${True}

Check Cells info
    [Arguments]    ${expect_cell_info}     ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}
    ...    connection=${connection}
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
    [Arguments]    ${connection}=cOAM    ${timeout}=10min
    log to console    Save Snapshot...
    run keyword and ignore error     coam.teardown    connection=${connection}
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
    ...    connection=${connection}
    ${snapshot_path}    coam.Get Snapshot From BTS    alias=${connection}    timeout=${timeout}
    Log to console    snapshot saved in: ${snapshot_path}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}
    [Return]    ${snapshot_path}


########### modify parameter ###################
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
#    [Arguments]      ${virtual_enable}=${True}
    [Documentation]   WEBUI Login
    Log To Console  START:WEBUI Login
    Log To Console  Try to login...
    ${version}    Get BTS release
    selenium_coam.Enable_Virtual_Display
    selenium_coam.Login    url=https://${gNB_ip}    username=${gNB_username}   password=${gNB_password}
    ...     version=${version}
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


########### common operate #################
Lock or UnLock Multiple RU
    [Arguments]    ${RMOD_id_list}   ${lock_flag}=${True}    ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM    ${timeout}=60
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}
    ...    connection=${connection}
    FOR  ${RMOD_id}  IN  @{RMOD_id_list}
        ${dist_name}    Set Variable    MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${RMOD_id}
        Run keyword if    ${lock_flag}==${True}    Log To Console    Lock RMOD-${RMOD_id}
        ...    ELSE    Log To Console    UnLock RMOD-${RMOD_id}
        Run keyword if    ${lock_flag}==${True}    coam.lock    dist_name=${dist_name}    timeout=${timeout}
        ...    connection=${connection}
        ...    ELSE    coam.unlock    dist_name=${dist_name}    timeout=${timeout}    connection=${connection}
        sleep    8s
    END
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Block or UnBlock Single Cell
    [Arguments]  ${cell_id}    ${block_flag}=${True}    ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM    ${timeout}=60
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}
    ...    connection=${connection}
    ${dist_name}    Set Variable    MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    Run keyword if    ${block_flag}==${True}    Log To Console    Block Cell-${cell_id}
    ...    ELSE    Log To Console    UnBlock Cell-${cell_id}
    Run keyword if    ${block_flag}==${True}    coam.block_cell    dist_name=${dist_name}    timeout=${timeout}
    ...    connection=${connection}
    ...    ELSE    coam.unblock_cell    dist_name=${dist_name}    timeout=${timeout}    connection=${connection}
    sleep    5s
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Get All RU or Cell Status
    [Arguments]  ${if_ru}=${True}    ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM
    Log to console    Get All RU or Cell Status
    ${item_status_dic}    Create Dictionary
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}
    ...    connection=${connection}
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


Lock or Unlock RU And Check Status
    [Arguments]  ${lock_RU_id_list}=${empty_list}     ${unlock_RU_id_list}=${empty_list}    ${lock_flag}=${True}    ${bts_host}=${gnb_ip}
    ${operate_ru_id_list}    Set Variable If    ${lock_flag}    ${lock_RU_id_list}    ${unlock_RU_id_list}
    Lock or UnLock Multiple RU    RMOD_id_list=${operate_ru_id_list}    lock_flag=${lock_flag}    bts_host=${bts_host}
    Run keyword and ignore error    Check Alarm List on BTS    allowed_list=${allowed_list}    bts_host=${bts_host}
    ${expect_item_status_dict}    create dictionary
    FOR  ${item}  IN    @{lock_RU_id_list}
        Set to dictionary    ${expect_item_status_dict}    RMOD-${item}=${RU_lock_status}
    END
    FOR  ${item1}  IN   @{unlock_RU_id_list}
        Set to dictionary    ${expect_item_status_dict}    RMOD-${item1}=${RU_unlock_status}
    END
    sleep    60s
    Check All RU or Cell Status    expect_item_status_dict=${expect_item_status_dict}    if_ru=${True}    bts_host=${bts_host}



BLock or UnBlock Cell And Check Status
    [Arguments]    ${block_cell_id}=None    ${unblock_cell_id}=None    ${block_flag}=${True}    ${bts_host}=${gnb_ip}
    @{allowed_cell_block_list}    create list    @{allowed_list}    ${49}
    @{not_allowed_list}    create list   ${49}
    ${operate_cell_id}    Set Variable If    ${block_flag}    ${block_cell_id}    ${unblock_cell_id}
    Block or UnBlock Single Cell    cell_id=${operate_cell_id}    block_flag=${block_flag}    bts_host=${bts_host}
    run keyword if  ${block_flag}    Check Alarm List on BTS    allowed_list=${allowed_cell_block_list}    bts_host=${bts_host}
    ...    ELSE    Check Alarm List on BTS    allowed_list=${allowed_list}    not_allowed_list=${not_allowed_list}    bts_host=${bts_host}
    ${expect_item_status_dict}    create dictionary
    run keyword if    ${block_cell_id} != None    Set to dictionary    ${expect_item_status_dict}
    ...    NRCELL-${block_cell_id}=${Cell_block_status}
    run keyword if    ${unblock_cell_id} != None    Set to dictionary    ${expect_item_status_dict}
    ...    NRCELL-${unblock_cell_id}=${Cell_unblock_status}
    sleep    60s
    Check All RU or Cell Status     expect_item_status_dict=${expect_item_status_dict}    if_ru=${False}   bts_host=${bts_host}



########### about Xiaomi UE #################
#Xiaomi12 click airplane tiwce
#    [Arguments]  ${ue_index}    ${serial_number}    ${connection}=cygwin
#    FOR    ${item}   IN RANGE   ${2}
#        unlock the screen and click airplane    ue_index=${ue_index}   serial_number=${serial_number}   connection=${connection}
#    END
#
#Xiaomi12 Verify Airplane Status
#    [Arguments]    ${serial_number}    ${connection}=cygwin
#    ssh.send_command    command=adb -s ${serial_number} shell settings get global airplane_mode_on   connection=${connection}
#    sleep   2s
#    ${airplane_status}    ssh.Read Output    connection=${connection}
#    @{airmode_status}    Split String    ${airplane_status}    \r\n
#    ${status}    Set Variable If    '${airmode_status[0]}'=='0'    ${False}    ${True}
#    [Return]  ${status}
#
#Xiaomi12 Attach UE
#    [Arguments]  ${ue_index}     ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${connection}=cygwin
#    ${status}    Xiaomi12 Verify Airplane Status    serial_number=${serial_number}    connection=${connection}
#    Run Keyword If    ${status}    unlock the screen and click airplane    ue_index=${ue_index}   serial_number=${serial_number}
#    ...    connection=${connection}
#    Run Keyword If    ${status}==${False}    Xiaomi12 click airplane tiwce    ue_index=${ue_index}   serial_number=${serial_number}
#    ...    connection=${connection}
#
#Xiaomi12 Attach And Verify attach
#    [Arguments]  ${ue_index}     ${hostname}=${control_pc}    ${username}=${control_pc_name}    ${password}=${control_pc_pass}
#    ...    ${connection}=cygwin
#    ssh.Connect to    hostname=${hostname}    username=${username}    password=${password}    alias=${connection}
#    Xiaomi12 Attach UE    ue_index=${ue_index}     serial_number=${tl.ues[${ue_index}].serial_number}    connection=${connection}
#    [Teardown]  Run Keyword And Ignore Error    ssh.Disconnect    connection=${connection}
#
#Xiaomi12 UE Detach
#    [Arguments]  ${ue_index_list}    ${connection}=cygwin
#    ssh.Connect to    hostname=${control_pc}    username=${control_pc_name}    password=${control_pc_pass}    alias=${connection}
#    FOR    ${ue_index}    IN    @{ue_index_list}
#        unlock the screen and click airplane    ue_index=${ue_index}
#        ...   serial_number=${tl.ues[${ue_index}].serial_number}  connection=${connection}
#    END
#    [Teardown]  Run Keyword And Ignore Error    ssh.Disconnect    connection=${connection}

UE attach and check Traffic
    [Arguments]     ${ul_throughput}    ${dl_throughput}    ${cells}    ${ul_tp_list}=${ul_tp_list}
    ...     ${target_avg_percent}=0.95    ${min_percent}=0    ${if_ul}=${True}    ${if_dl}=${True}    ${ignore_time}=20s
    ...    ${log_time}=60s    ${multiue_config_direction}=${TLCommonConfig0["MultiUECFG"]}
    Start Traffic By Spark    multiue_config_direction=${multiue_config_direction}    ul_port_list=${ul_power_port_list}
    ...    get_spark_license=${True}    if_ul=${if_ul}    ul_tp_list=${ul_tp_list}
    ...    if_dl=${if_dl}    duration=3600
    Check Throught From Asslog    ul_list=${cells}    dl_list=${cells}     ul_tp=${ul_throughput}    dl_tp=${dl_throughput}
    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    log_time=${log_time}    if_ul=${if_ul}
    ...    ignore_time=${ignore_time}    if_dl=${if_dl}
    [Teardown]    Stop Traffic And Detach UE


#unlock the screen and click airplane
#    [Documentation]   Check UE if need awake
#    [Arguments]   ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}   ${connection}=cygwin
#    Get all xiaomi12 pointer variable
#    ssh.send_command   connection=${connection}
#    ...   command=adb -s ${serial_number} shell dumpsys window | grep -E \"mAwake|isStatusBarKeyguard|mShowingLockscreen\"
#    sleep   2s
#    ${output}   ssh.read_output   connection=${connection}
#    Run Keyword If   ${output.lower().count('mawake=false')}>0
#    ...   ssh.send_command   command=adb -s ${serial_number} shell input keyevent 26   connection=${connection}
#    ssh.send_command   command=adb -s ${serial_number} shell input swipe 347 2514 715 400    connection=${connection}
#    sleep    2s
#    ssh.send_command   command=adb -s ${serial_number} shell am start -a android.settings.AIRPLANE_MODE_SETTINGS
#    ...    connection=${connection}
#    sleep    2s
#    ssh.send_command   command=adb -s ${serial_number} shell dumpsys window | grep FocusedWindow    connection=${connection}
#    sleep    2s
#    ssh.send_command   command=adb -s ${serial_number} shell input tap ${airplane}    connection=${connection}
#    sleep    2s
#    ssh.send_command    command=adb -s ${serial_number} shell input keyevent ${Home_button}    connection=${connection}
#    sleep   2s
#    ssh.send_command    command=adb -s ${serial_number} shell input keyevent 187    connection=${connection}
#    sleep   4s
#    ssh.send_command    command=adb -s ${serial_number} shell input tap ${close_task}    connection=${connection}
#
#Get all xiaomi12 pointer variable
#    Set Suite Variable    ${Home_button}    3
#    Set Suite Variable    ${airplane}    932 1633
#    Set Suite Variable    ${close_task}   717 2920
#    Set Suite Variable    ${swipe}    1300 2700 1300 2700
#    Set Suite Variable    ${open_iperf_location}    500 2050
#    Set Suite Variable    ${iperf_button}    730 300
#    Set Suite Variable    ${iperf_space}    800 550
#    Set Suite Variable    ${5G}    900 960
#    Set Suite Variable    ${ue_type}    xiaomi
#    Set Suite Variable    ${brand}    Xiaomi
#
#Xiaomi start power ue traffic ul and dl
#    [Arguments]     ${ue_index}    ${hostname}=${control_pc}    ${username}=${control_pc_name}    ${password}=${control_pc_pass}
#    ...    ${ul_throughput}=${None}    ${dl_throughput}=${None}    ${ul_duration}=6000    ${dl_duration}=6000    ${protocol}=udp
#    run keyword and continue on failure    run keyword if    ${True}    power_ue.Start traffic    ue_index=${ue_index}   direction=ul
#    ...    throughput=${ul_throughput}   duration=${200000}    ue_type=xiaomi    protocol=${protocol}
#    ...    iperf_port=${dl_power_port_list}[${ue_index}]
#    sleep    1s
#    sleep    1s
#    run keyword and continue on failure     power_ue.Start traffic    ue_index=${ue_index}    direction=dl    throughput=${dl_throughput}
#    ...    duration=${dl_duration}    ue_type=xiaomi    protocol=${protocol}    iperf_port=${dl_power_port_list}[${ue_index}]
#
#stop multi power ue traffic ul and dl
#    [Arguments]    ${ue_index_list}    ${ue_type_list}=${all_ue_type_list}    ${protocol}=udp    ${if_ul}=${True}    ${if_dl}=${True}
#    log to console     Stop traffic    console=yes
#    FOR    ${item}    IN    @{ue_index_list}
#        run keyword if    ${if_ul}    power_ue.Stop traffic    direction=ul    ue_index=${item}    ue_type=${ue_type_list[${item}]}
#        ...    protocol=${protocol}    iperf_port=${ul_power_port_list}[${item}]
#        run keyword if    ${if_dl}    power_ue.Stop traffic    direction=dl    ue_index=${item}    ue_type=${ue_type_list[${item}]}
#        ...   protocol=${protocol}    iperf_port=${dl_power_port_list}[${item}]
#    END
#
Check Throught From Asslog
    [Arguments]  ${ul_list}    ${dl_list}      ${ul_tp}=${500}    ${dl_tp}=${500}    ${if_ul}=${True}    ${if_dl}=${True}
    ...    ${target_avg_percent}=0.90    ${ue_type}=samsung   ${log_time}=60s    ${min_percent}=0    ${ignore_time}=60s
    ${log_path}    power_ue.Collect Tput   ue_type=${ue_type}    duration=${log_time}    ignore_time=${ignore_time}
    ${ul_result}    run keyword and continue on failure    run keyword if    ${if_ul}==${True}    power_ue.Check Tput
    ...    ue_type=${ue_type}
    ...    direction=UL    log=${log_path}    cells=${ul_list}    target_throughput=${ul_tp}    target_avg_percent=${target_avg_percent}
    ...    actCarrierAggregation=${True}    min_percent=${min_percent}
    run keyword if    ${if_ul}    Log to console    ${ul_result}
    ${dl_result}    run keyword and continue on failure    run keyword if    ${if_dl}==${True}    power_ue.Check Tput
    ...    ue_type=${ue_type}
    ...    direction=DL    log=${log_path}    cells=${dl_list}    target_throughput=${dl_tp}    target_avg_percent=${target_avg_percent}
    ...    actCarrierAggregation=${True}    min_percent=${min_percent}
    run keyword if    ${if_dl}    Log to console    ${dl_result}
#
#Xiaomi Start Traffic and Check TP
#    [Arguments]    ${ue_index}    ${ul_throughput}    ${dl_throughput}    ${cells}    ${target_avg_percent}=0.95    ${min_percent}=0
#    ...    ${log_time}=60s
#    @{ue_index_list}    create list    ${ue_index}
##    UE attach by Spark    ue_index_list=${ue_index_list}
#    Xiaomi start power ue traffic ul and dl    ue_index=${ue_index}    ul_throughput=${ul_throughput}M    dl_throughput=${dl_throughput}M
#    sleep   10s
#    Check Throught From Asslog    ul_list=${cells}    dl_list=${cells}     ul_tp=${ul_throughput}    dl_tp=${dl_throughput}
#    ...    target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    log_time=${log_time}
#    stop multi power ue traffic ul and dl    ue_index_list=${ue_index_list}
#    [Teardown]    Xiaomi12 UE Detach    ue_index_list=${ue_index_list}

########### case common step#################
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

Adjust Single RU PA
    [Arguments]    ${port}    ${single_ru_PA}=${127}    ${mutil_ru_PA}=${0}
    ${port_list}    create list     ${0}    ${1}    ${2}    ${3}
    ${value_list}    create list
    FOR    ${item}    IN RANGE    ${4}
        Run keyword if    ${item} != ${port}    APPEND TO LIST  ${value_list}    ${mutil_ru_PA}
        ...    ELSE    APPEND TO LIST  ${value_list}    ${single_ru_PA}
    END
    Log To Console    ${port_list}
    Log To Console    ${value_list}
    Adjust the HBTE attenuation value    value_list=${value_list}    port_list=${port_list}
    sleep  1min




########### CB011088-D-siso-03 case step#################
unlock cell3 and attach cell3
    [Arguments]    ${exp_dl}=${400}    ${exp_ul}=${80}    ${if_dl}=${True}    ${if_ul}=${True}
    ...    ${target_avg_percent}=0.9    ${min_percent}=0    ${log_time}=60s    ${ue_info}=${TLCommonConfig["MultiUECFG"]}
    ${RMOD_id_list_1}    create list     ${1}    ${3}
    Lock or Unlock RU And Check Status  lock_RU_id_list=${RMOD_id_list_1}
    BLock or UnBlock Cell And Check Status    block_cell_id=${2}
    ${ul_tp_list}    Create List    ${50}
    UE attach and check Traffic    ul_throughput=${exp_ul}    dl_throughput=${exp_dl}    ul_tp_list=${ul_tp_list}
    ...    cells=${cell_list[3:4]}   target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    multiue_config_direction=${ue_info}
    ...    if_ul=${if_ul}    if_dl=${if_dl}    log_time=${log_time}

unlock cell23 and attach cell23
    [Arguments]    ${ul_tp_list}=${ul_tp_list}    ${exp_dl}=${400}    ${exp_ul}=${80}    ${if_dl}=${True}    ${if_ul}=${True}
    ...    ${target_avg_percent}=0.9    ${min_percent}=0    ${log_time}=60s    ${ue_info}=${TLCommonConfig["MultiUECFG"]}
    ${RMOD_id_list_1}    create list     ${1}    ${3}
    Lock or Unlock RU And Check Status  lock_RU_id_list=${RMOD_id_list_1}
    UE attach and check Traffic    ul_throughput=${exp_ul}    dl_throughput=${exp_dl}    ul_tp_list=${ul_tp_list}
    ...    cells=${cell_list[2:4]}   target_avg_percent=${target_avg_percent}    min_percent=${min_percent}
    ...    multiue_config_direction=${ue_info}    ignore_time=40s
    ...    if_ul=${if_ul}    if_dl=${if_dl}    log_time=${log_time}

lock cell3 unlock cell1 and attach cell1
    [Arguments]    ${block_cell_id}=${3}    ${unblock_cell_id}=${1}    ${attach_cells}=${cell_list[1:2]}
    ...    ${ul_tp_list}=${ul_tp_list}
    BLock or UnBlock Cell And Check Status    block_cell_id=${block_cell_id}
    Block or UnBlock Single Cell    cell_id=${unblock_cell_id}   block_flag=${false}    bts_host=${gnb_ip}
    @{allowed_cell_block_list}    create list    @{allowed_list}    ${49}
    Check Alarm List on BTS    allowed_list=${allowed_cell_block_list}    bts_host=${gnb_ip}
    UE attach and check Traffic    ul_throughput=${80}    dl_throughput=${400}    ul_tp_list=${ul_tp_list}
    ...    cells=${attach_cells}   target_avg_percent=0.1    multiue_config_direction=${TLCommonConfig["MultiUECFG"]}
    FOR    ${item}    IN RANGE     ${3}
        BLock or UnBlock Cell And Check Status    block_cell_id=${unblock_cell_id}
        Block or UnBlock Single Cell    cell_id=${unblock_cell_id}   block_flag=${false}    bts_host=${gnb_ip}
    END
    UE attach and check Traffic    ul_throughput=${80}    dl_throughput=${400}    ul_tp_list=${ul_tp_list}
    ...    cells=${attach_cells}   target_avg_percent=0.28    multiue_config_direction=${TLCommonConfig["MultiUECFG"]}


########### CB011088-G6-siso-01 case step#################
lock RU1&2
    ${RMOD_id_list_1}    create list     ${1}    ${2}
    Lock or Unlock RU And Check Status  lock_RU_id_list=${RMOD_id_list_1}

unlock AQQY cell12 and UE attach
    BLock or UnBlock Cell And Check Status    block_cell_id=${10}
    BLock or UnBlock Cell And Check Status    block_cell_id=${11}
    BLock or UnBlock Cell And Check Status    block_cell_id=${13}
    UE attach and check Traffic    ul_throughput=${80}    dl_throughput=${400}    ul_tp_list=${ul_tp_list}
    ...    cells=${cell_list[6:7]}   target_avg_percent=0.28   multiue_config_direction=${TLCommonConfig1["MultiUECFG"]}


########### CB011088-G2-siso-01 case step#################

modify the parameter case G2
    [Arguments]
    WEBUI Login
    Delete Nrcells Data    object_num=${1}    start_id=${13}    node_index_Start=${7}
    Delete Nrcells Data    object_num=${2}    start_id=${10}    node_index_Start=${5}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1/CABINET-1/SMOD-1/BBCAP-1
    ...    filter_param=SMOD board configuration type  new_value=Auto    abbr=smodBoardConfigType
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-12
    ...    filter_param=Number of Rx beamforming  new_value=4Rx   abbr=numberOfRxBeamforming
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-12
    ...    filter_param=NR Cell type    new_value=8DL8UL  abbr=nrCellType
    Add Channel Object    start_id=${5}    cell_id=${12}    CHANNEL_id=${2}
    ${error}    selenium_coam.validate_plan
    Log To Console    ${error}
    selenium_coam.activate_plan    download_plan_without_activation=${False}
    ...    activate_plan_despite_errors=${True}    timeout=${300}
    Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}
    [Teardown]    WEBUI Logout

Add Channel Object
    [Arguments]    ${start_id}    ${cell_id}    ${CHANNEL_id}    ${copy_from}=CURRENT_BTS_CONF-1
    Log To Console    add channelgroup
    FOR    ${item}    IN RANGE     4
        selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-2
        ...   object_class_name=CHANNEL
        ...    plan_to_copy_from=${copy_from}
        ...    copy_from=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-1/CHANNEL-${CHANNEL_id}
        ...    include_subobject=${TRUE}    id_value=${start_id}
        ${start_id}    Evaluate    ${start_id} + 1
    END


Delete Channel Object
    [Arguments]    ${item}
    Log To Console    delete Channel
    FOR    ${item1}    IN RANGE     4
        ${CHANNEL_id}    Evaluate    ${item1} + 9
        selenium_coam.remove_object
        ...    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${item}/CHANNELGROUP-1/CHANNEL-${CHANNEL_id}
    END


Power Off RU3 And check alarm
#    [Arguments]    ${retry_interval}=10s
    Log To Console    Power Off RU3 And check alarm
    @{allowed_list_1}    create list    @{allowed_list}    ${49}
    Check Alarm List on BTS    allowed_list=${allowed_list_1}
    pdu.Setup Pdu    model=HBTE    host=${AQQQA_PDU_IP}    alias=pdu_alias
    pdu.Power Off    port=${AQQQA_PDU_IP_Port}   pdu_device=pdu_alias
    ${status1}    pdu.Get Port Status    port=${AQQQA_PDU_IP_Port}   pdu_device=pdu_alias
    Should Be Equal    ${status1}    off
    sleep     30s
    check fault10 from BTS
    pdu.Power On    port=${AQQQA_PDU_IP_Port}   pdu_device=pdu_alias
    sleep     30s
    ${status2}    pdu.Get Port Status    port=${AQQQA_PDU_IP_Port}    pdu_device=pdu_alias
    Should Be Equal    ${status2}    on
    sleep    180s
    Check Alarm List on BTS    allowed_list=${allowed_list_1}


########### CB011088-G4-siso-02 case step#################

configuration AWHQE cell
    [Arguments]   ${cell_id}=${6}    ${physCellId_list}=${63}
    WEBUI Login
    Delete Nrcells Data    object_num=${4}    start_id=${10}    node_index_Start=${7}
    ${error}    selenium_coam.validate_plan
    Log To Console    ${error}
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${300}
    Check GNB on air
    Add Cell Object    physCellId_list=${physCellId_list}   add_object_cell_num=${1}    start_cell_id=${cell_id}    LCELNR=LCELNR-${cell_id}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=Activate super cell   new_value=true    abbr=actSuperCell
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate NR RTWP measurement   new_value=false   abbr=actRtwpMeasurement
    ${error}    selenium_coam.validate_plan
    Log To Console    ${error}
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${300}
    Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}
    [Teardown]    WEBUI Logout



Delete Nrcells Data
    [Arguments]  ${object_num}    ${start_id}    ${node_index_Start}
    Log To Console    delete nrcell
    FOR   ${item}    IN RANGE    ${object_num}
        ${cell_id}    Evaluate    ${item} + ${start_id}
#        ${NRCELLGRP_id}    Evaluate     ${cell_id} - 1
        ${node_index}    Evaluate    ${node_index_Start} - ${item}
        selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-${cell_id}
        selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}
        selenium_coam.remove_element   dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
        ...    filter_param=Reference to cell group    node_index=${node_index}    abbr=refNrCellGroup
    END


Add Cell Object
    [Arguments]  ${physCellId_list}    ${add_object_cell_num}    ${start_cell_id}    ${LCELNR}=LCELNR-6    ${NRCELLGRP_id}=${6}
    Log To Console    add super cell
    ${end_cell_id}    evaluate    ${add_object_cell_num} + ${start_cell_id}
    ${total_cell_num}    evaluate    ${add_object_cell_num} + 1
    ${change_time}     evaluate    int(${6}/${total_cell_num})
    ${start_ru_id}    evaluate    ${change_time} + 1
    FOR    ${item}    IN RANGE    ${add_object_cell_num}
        ${cell_id}    Evaluate    ${item} + ${start_cell_id}
        selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}   object_class_name=NRCELL
        ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-0
        ...    include_subobject=${TRUE}    id_value=${cell_id}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ...    filter_param=Local cell resource ID   new_value=${cell_id}    abbr=lcrId
        selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ...    filter_param=Physical cell identifier   new_value=${physCellId_list}   abbr=physCellId
        selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}   object_class_name=NRCELLGRP
        ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-0
        ...    include_subobject=${TRUE}    id_value=${NRCELLGRP_id}
       selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-${NRCELLGRP_id}
       ...    filter_param=List of NR cells assigned to cell group   node_index=${0}    new_value=${cell_id}    abbr=nrCellList
       selenium_coam.add_element    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
       ...    filter_param=Reference to cell group    abbr=refNrCellGroup
       selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
       ...    filter_param=Reference to cell group    new_value=${NRCELLGRP_id}    node_index=${4}    abbr=refNrCellGroup
    END

    selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1   object_class_name=LCELNR
    ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1
    ...    include_subobject=${TRUE}    id_value=6
    Set Channelgroup Parameter    group_id=${1}    ru_id=${4}
    selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-6   object_class_name=CHANNELGROUP
    ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/${LCELNR}/CHANNELGROUP-1
    ...    include_subobject=${TRUE}    id_value=2
    Set Channelgroup Parameter    group_id=${2}    ru_id=${5}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate load-based PS control logic enhancement   new_value=false   abbr=actLbpsCtrlLogicEnh
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate NR load-based power saving   new_value=false   abbr=actNrLBPowerSaving
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate NR load-based mMIMO TX power saving    new_value=false   abbr=actNrLBmMimoRTXPowerSaving
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}
    ...    filter_param=Activate mixed mode load-based power saving   new_value=false   abbr=actNrMixedSOMethod
    selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-1

Set Channelgroup Parameter Mutil Times
    [Arguments]    ${ru_id}    ${cell_id}    ${times}=${2}
    ${group_id}    set variable    ${0}
    FOR    ${item}    IN RANGE    ${times}
        ${group_id}    Evaluate    ${group_id} + 1
        Set Channelgroup Parameter    group_id=${group_id}    ru_id=${ru_id}    cell_id=${cell_id}
        ${ru_id}    Evaluate    ${ru_id} + 1
    END

Set Channelgroup Parameter
    [Arguments]  ${group_id}    ${ru_id}    ${cell_id}=${6}
    Log To Console    set channelgrp parameter
    @{antl_value_list}    create list    ${1}    ${1}    ${2}    ${2}    ${3}    ${3}    ${4}    ${4}
    FOR    ${item}    IN RANGE    ${8}
        ${CHANNEL_id}    Evaluate    ${item} + 1
        ${antlDN_value}    set variable    MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${ru_id}/ANTL-${antl_value_list}[${item}]
        selenium_coam.set_parameter_value
        ...    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-${group_id}/CHANNEL-${CHANNEL_id}
        ...    filter_param=Distinguished Name of antenna line   new_value=${antlDN_value}    abbr=antlDN
    END

Download Current BTS SCF To UTE
    [Arguments]    ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM    ${scf_name}=${Empty}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}
    ...    connection=${connection}
    coam.get_current_scf_file    local_dir_path=${OUTPUT_DIR}    file_name=${scf_name}    connection=${connection}
    ...    timeout=${120}
    [Teardown]     Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

# NRDIM keyword
Get Theoretical TP From NRDIM
    [Arguments]    ${dl_cell_list}=${empty_list}    ${ul_cell_list}=${empty_list}    ${UL_Rank}=${1}    ${scf_name}=${Empty}
    ...    ${dl_gap}=${-12}    ${ul_gap}=${0}
    Adapt to ute cloud commission scf
    ${total_ul_tp}    ${total_dl_tp}    Calculate Theoretical TP    scf_path=${OUTPUT_DIR}/${scf_name}
    ...    dl_cell_list=${dl_cell_list}    ul_cell_list=${ul_cell_list}    UL_Rank=${UL_Rank}
    # NRDIM not consider paging on pdsch
    ${total_dl_tp}    Evaluate    ${total_dl_tp}+${dl_gap}
    ${total_ul_tp}    Evaluate    ${total_ul_tp}+${ul_gap}
    Log to console    Theoretical Tput calculated via NRDIM DL-${dl_cell_list}:${total_dl_tp}Mbps, UL-${ul_cell_list}:${total_ul_tp}Mbps
    [Return]    ${total_ul_tp}    ${total_dl_tp}

Calculate Theoretical TP
    [Arguments]  ${scf_path}    ${dl_cell_list}=${empty_list}    ${ul_cell_list}=${empty_list}    ${UL_Rank}=${1}
    ${total_ul_tp}    set variable    ${0}
    ${total_dl_tp}    set variable    ${0}
    ${dl_cell_num}    get length    ${dl_cell_list}
    ${ul_cell_num}    get length    ${ul_cell_list}
    ${ul_divided_by}    set variable if    ${UL_Rank}==${1}    ${2}    ${1}
    FOR  ${i}  IN RANGE   ${dl_cell_num}
        ${cell_id}    Evaluate    ${dl_cell_list}[${i}]
        ${calculator_tp_dl}    ${calculator_tp_ul}    throughput_computation.get_theoretical_throughput    scf_path=${scf_path}    cell_id=${cell_id}
        ${total_dl_tp}    Evaluate    ${calculator_tp_dl}+${total_dl_tp}
    END
    FOR  ${i}  IN RANGE   ${ul_cell_num}
        ${cell_id}    Evaluate    ${ul_cell_list}[${i}]
        ${calculator_tp_dl}    ${calculator_tp_ul}    throughput_computation.get_theoretical_throughput    scf_path=${scf_path}    cell_id=${cell_id}
        ${total_ul_tp}    Evaluate    ${calculator_tp_ul}/${ul_divided_by}+${total_ul_tp}
    END
    [Return]  ${total_ul_tp}    ${total_dl_tp}

Change_NRCELL6_To_64QAM_And_DMRS
    [Arguments]    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
    ...    connection=${connection}
    ${dist_name}    set variable    MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-6
    ${dlDataDmrsFdm_struct_0_dict}    Create Dictionary
    ...    actDlDataDmrsFdm=false
    ...    dlDataDmrsFdmThres64QamMcs=5
    ...    dlDataDmrsFdmThres256QamMcs=5
    ...    redCap1RxUesEnabled=false
    ...    thres256QamMcsRedCap1Rx=20
    ${dlDataDmrsFdm_struct_list}    Create List    ${dlDataDmrsFdm_struct_0_dict}
    ${parameters_dict}    Create Dictionary
    ...    actDl256Qam=false
    ...    dlDataDmrsFdm=${dlDataDmrsFdm_struct_list}
    ...    actDlLaDynBlerTarget=false
    ...    dlDMRSAdditionalPosition=One additional DMRS
    ...    ulDMRSAdditionalPosition=One additional DMRS
    ${json_update}    Create List
    ${para_list}    Get Dictionary Keys    ${parameters_dict}
    FOR    ${para}    IN    @{para_list}
        ${value}    Get From Dictionary    ${parameters_dict}    ${para}
        ${item}    Create Dictionary    dist_name=${dist_name}    parameter=${para}    value=${value}    operation=update
        Append To List    ${json_update}    ${item}
    END
    Modify Parameters with coam     input_list=${json_update}    connection=${connection}
    Wait Until Keyword Succeeds    5min    10s
    ...    Check dedicated cell should be onair    NRCELL_id=${6}    connection=${connection}
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Change_NRCELL6_To_256QAM_And_DMRS
    [Arguments]    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
    ...    connection=${connection}
    ${dist_name}    set variable    MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-6
    ${dlDataDmrsFdm_struct_0_dict}    Create Dictionary
    ...    actDlDataDmrsFdm=true
    ...    dlDataDmrsFdmThres64QamMcs=5
    ...    dlDataDmrsFdmThres256QamMcs=5
    ...    redCap1RxUesEnabled=false
    ...    thres256QamMcsRedCap1Rx=20
    ${dlDataDmrsFdm_struct_list}    Create List    ${dlDataDmrsFdm_struct_0_dict}
    ${parameters_dict}    Create Dictionary
    ...    actDl256Qam=true
    ...    dlDataDmrsFdm=${dlDataDmrsFdm_struct_list}
    ...    actDlLaDynBlerTarget=true
    ...    dlDMRSAdditionalPosition=No additional DMRS
    ...    ulDMRSAdditionalPosition=No additional DMRS
    ${json_update}    Create List
    ${para_list}    Get Dictionary Keys    ${parameters_dict}
    FOR    ${para}    IN    @{para_list}
        ${value}    Get From Dictionary    ${parameters_dict}    ${para}
        ${item}    Create Dictionary    dist_name=${dist_name}    parameter=${para}    value=${value}    operation=update
        Append To List    ${json_update}    ${item}
    END
    Modify Parameters with coam     input_list=${json_update}    connection=${connection}
    Wait Until Keyword Succeeds    5min    10s
    ...    Check dedicated cell should be onair    NRCELL_id=${6}    connection=${connection}
    [Teardown]    run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}


set chBwUl/DL
    [Arguments]    ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM    ${input_list}=${json_update_50M}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    Modify Parameters with coam     input_list=${input_list}    connection=${connection}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}


Modify Parameters with coam
    [Arguments]    ${input_list}    ${delta_id}=update_parameter    ${connection}=GNB_connection
    coam.create_delta    delta_id=${delta_id}
    Log to console    start modify parameters:\n
    FOR    ${item}  IN    @{input_list}
        ${operation}    get from dictionary    ${item}    operation
        Run keyword if    '${operation}'=='update'
        ...    coam.append_parameter_update_to_delta    dist_name=${item['dist_name']}    parameter=${item['parameter']}
        ...    value=${item['value']}    delta_id=${delta_id}
        Run keyword if    '${operation}'=='delete'
        ...    coam.append_parameter_delete_to_delta    dist_name=${item['dist_name']}    parameter=${item['parameter']}
        ...    delta_id=${delta_id}
        Log to console    Add task - ${operation}: ${item['dist_name']}.${item['parameter']}=${item['value']}
    END
    ${delta_file}    coam.get_delta    delta_id=${delta_id}
    ${timeout}    set variable    300
    Log to console    Perform parameters via delta_id:${delta_id} is ongoing, timeout ${timeout}s.
    coam.perform_delta_recommissioning
    ...    delta_file=${delta_file}
    ...    skip_parameter_relation_errors=${False}
    ...    should_activate=${True}
    ...    timeout=${timeout}
    ...    connection=${connection}
    Log to console    Perform parameters done.
    [Teardown]    run keyword and ignore error    coam.remove_delta    delta_id=${delta_id}

Check dedicated cell should be onair
    [Arguments]    ${connection}=GNB_OAM    ${NRCELL_id}=${6}
    ${NRCELL_6}    set variable    MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NRCELL_id}
    ${cells_info}    coam.get_cells_info    cell_type=nr    timeout=20    connection=${connection}
    FOR    ${cell}    IN    @{cells_info}
        ${id}    get from dictionary    ${cell}    id
        ${NRCELL}    get from dictionary    ${id}    configuration
        Run keyword if    '${NRCELL}'=='${NRCELL_6}'    _verify_cell_status    cell=${cell}
    END

_verify_cell_status
    [Arguments]    ${cell}
    Run keyword and continue on failure    Should Be Equal As Strings    ${cell['status']['administrativeState']}
    ...      Unlocked
    Run keyword and continue on failure    Should Be Equal As Strings    ${cell['status']['operationalState']}    enabled
    Run keyword and continue on failure    Dictionary Should Not Contain Key    ${cell['status']}     availabilityStatus
    ...   msg=Cell-${cell['physicalCellId']}'s availabilityStatus present, means cell is disable or degraded, please check.

Xiaomi Start Traffic And Check Tp TCP
    [Arguments]    ${ul_throughput}    ${dl_throughput}    ${ul_list}    ${dl_list}    ${ue_index}    ${protocol}=tcp
    ...    ${if_ul}=${True}    ${if_dl}=${True}    ${target_avg_percent}=0.9    ${min_percent}=0    ${log_time}=60s    ${ue_type}=samsung
    @{ue_index_list}    create list    ${ue_index}
    start multi power ue traffic ul and dl    ue_index_list=${ue_index_list}    ul_throughput=${ul_throughput}M    dl_throughput=${dl_throughput}M
    ...    if_ul=${if_ul}    if_dl=${if_dl}    process_num=${16}    protocol=${protocol}    ue_type=${ue_type}
    Check Throught From Asslog   ul_list=${ul_list}    dl_list=${dl_list}     ul_tp=${ul_throughput}    dl_tp=${dl_throughput}    if_ul=${if_ul}
    ...   if_dl=${if_dl}   target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    log_time=${log_time}    ignore_time=60s
    stop multi power ue traffic ul and dl    ue_index_list=${ue_index_list}    if_ul=${if_ul}    if_dl=${if_dl}    protocol=${protocol}
    [Teardown]    Xiaomi12 UE Detach    ue_index_list=${ue_index_list}

start multi power ue traffic ul and dl
    [Arguments]    ${ue_index_list}    ${ul_throughput}=${None}    ${dl_throughput}=${None}    ${ul_duration}=6000    ${dl_duration}=6000
    ...    ${protocol}=udp    ${if_ul}=${True}    ${if_dl}=${True}    ${process_num}=${2}    ${ue_type}=samsung
    log to console      Start traffic    console=yes
    FOR    ${item}    IN    @{ue_index_list}
        run keyword and continue on failure    run keyword if    ${if_ul}    power_ue.Start traffic    ue_index=${item}    direction=ul
        ...    throughput=${ul_throughput}    duration=${ul_duration}    ue_type=${ue_type}    protocol=${protocol}
        ...    iperf_port=${ul_power_port_list}[${item}]    process_num=${5}    iperf_type=via_command    seg_size=1200
        sleep    1s
        run keyword and continue on failure    run keyword if    ${if_dl}    power_ue.Start traffic    ue_index=${item}    direction=dl
        ...    throughput=${dl_throughput}    duration=${dl_duration}    ue_type=${ue_type}    protocol=${protocol}
        ...    iperf_port=${dl_power_port_list}[${item}]    process_num=${process_num}    seg_size=1200
    END


Adjust AQQY PA
    ${port_list}    create list     ${12}    ${13}    ${14}    ${15}
    ${value_list}   create list     ${1}    ${0}    ${0}    ${0}
    Adjust the HBTE attenuation value    value_list=${value_list}     port_list=${port_list}


############# Capture LMI Log ###############
Capture LMI Log
    [Arguments]    ${gnb_index}    ${ru_serial_list}    ${log_dir}=${OUTPUT_DIR}/${TEST_NAME}
    Log To Console   //TODO: UUF Catch RU Log
    Log To Console   ${RU_LOG_FLAG}
    ${log_dir_not_exist}   Run Keyword And Return Status   OperatingSystem.Directory Should Not Exist   ${log_dir}
    Run Keyword If   ${log_dir_not_exist}   OperatingSystem.Create Directory   ${log_dir}
    ${RU_serial_pc_info}    UUF Get RU PC Info Accordind To Serial    ru_serial_list=${ru_serial_list}
    UUF Catch RU Log From LMI    testline=gnb_${gnb_index}    ru_list=${RU_serial_pc_info}

Modify Parameters for CB009102 30MHz
    [Arguments]    ${bts_host}=${gNB_ip}    ${input_list}=${CB009102_PARA}    ${connection}=para_9102
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    Modify Parameters with coam     input_list=${input_list}    connection=${connection}
    Check GNB on air
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Change The parameter of UE
    [Arguments]    ${new_ue_dict}    ${org_UE_dict}=${TLCommonConfig['MultiUECFG']}
    ${ue_index_list}    get dictionary keys    ${new_ue_dict}
    FOR  ${ue_index}  IN  @{ue_index_list}
        ${new_value_dict}    get from dictionary    ${new_ue_dict}    ${ue_index}
        ${org_dict}    Change Dictionary Value    new_value_dict=${new_value_dict}    org_dict=${org_UE_dict['${ue_index}']}
        set to dictionary    ${org_UE_dict}    ${ue_index}=${org_dict}
    END
    set to dictionary    ${org_UE_dict}    ue_index_for_call=${ue_index_list}
    [Return]    ${org_UE_dict}

Change Dictionary Value
    [Arguments]    ${new_value_dict}    ${org_dict}
    ${new_keys}    get dictionary keys    ${new_value_dict}
    FOR  ${key}  IN  @{new_keys}
        ${value}    get from dictionary    ${new_value_dict}    ${key}
        set to dictionary    ${org_dict}    ${key}=${value}
    END
    [Return]    ${org_dict}
