*** Settings ***
Documentation    author：Hongyu Jiang
...              contact: hongyu.jiang@nokia-sbell.com
...              squad group: mmw_SG_04

Library     BuiltIn
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Commercial_mobile_phone_adb_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/aasyslog.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/sigspark_yiyuan_multiUE.py
Library     sigspark_yiyuan_multiUE.SigSparkMutiUE    WITH NAME    sparkMultiUE_yiyuan
Library     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001937_OTA/resources/5GC001937_mmw4_common_keywords.py
Library     taf.transport.ssh      WITH NAME    ssh
Library     taf.sbts.oam.coam.admin       WITH NAME    coam






*** Variables ***
${appserver_addr}             ${tl.ues[0].iperf_details.ssh_connection_details.addr}
${gNB_ip}                     ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${gNB_username}               ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gNB_password}               ${tl.gnbs[0].cu.oam_http_connection_details.password}
${gnb_ssh_username}           ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${gnb_ssh_password}           ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${UTE_ADDRESS}                ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}               ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}               ${tl.test_pc.default_ssh_connection_details.password}
${Control_PC_addr}            ${tl.ues[0].ssh_connection_details.addr}
${Control_PC_user}            ${tl.ues[0].ssh_connection_details.username}
${Control_PC_pass}            ${tl.ues[0].ssh_connection_details.password}
${BTS_ID}                     ${tl.gnbs[0].instance_id}
${NRBTS_ID}                   ${tl.gnbs[0].global_bts_id}
@{Cell_unblock_status}        Unlocked    enabled    Active    configured    Unblocked
@{Cell_block_status}          Unlocked    disabled    Idle    configured    Blocked
@{allowed_list}               ${4655}    ${61524}    ${4654}    ${4681}    ${61652}
${total_count}                ${180}
@{case_row_list}              NR PDCP Thr. DL [Mbps]    NR PDCP Thr. UL [Mbps]    NR PDSCH iBLER[%]    NR PUSCH iBLER[%]
@{Romd_list}                  RMOD-1    RMOD-4
@{Romd_list2}                 RMOD-2
${LOG_PATH}                   ${OUTPUT DIR}
@{cell_list}                  592564
@{empty_list}





*** Keywords ***
########### setup and teardown KW #################
CB010600 Suite Setup
    robot_common_operations.Common Suite Setup
    Adapt to ute cloud commission scf
    Setup Commission SCF
    Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}

Case Teardown
    [Arguments]  ${input_list}    ${cell_id}    ${block_flag}
    Modify Common parameter via Coam    input_list=${input_list}    time=1min
    Block Cell And Check Status    cell_id=${cell_id}    block_flag=${block_flag}


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

########### common operate #################
Block or UnBlock Mulite Cell
    [Arguments]  ${cell_id_list}    ${block_flag}=${True}    ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM    ${timeout}=60
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    FOR  ${cell_id}  IN  @{cell_id_list}
        ${dist_name}    Set Variable    MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        Run keyword if    ${block_flag}==${True}    Log To Console    Block Cell-${cell_id}
        ...    ELSE    Log To Console    UnBlock Cell-${cell_id}
        Run keyword if    ${block_flag}==${True}    coam.block_cell    dist_name=${dist_name}    timeout=${timeout}    connection=${connection}
        ...    ELSE    coam.unblock_cell    dist_name=${dist_name}    timeout=${timeout}    connection=${connection}
        sleep    5s
    END
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Get All RU or Cell Status
    [Arguments]  ${if_ru}=${False}    ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM
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

Check All RU or Cell Status
    [Documentation]  expect_item_status_dict eg:
    ...              1) ${cell_status_dict}    Create Dictionary     NRCELL-1=${Cell_unblock_status}    NRCELL-2=${Cell_block_status}
    ...              2) ${ru_status_dict}    Create Dictionary     RMOD-1=${RU_unlock_status}    RMOD-2=${RU_lock_status}
    [Arguments]  ${expect_item_status_dict}    ${if_ru}=${False}   ${bts_host}=${gnb_ip}
    Log To Console    Check All RU or Cell Status
    ${item_status_dic}    Get All RU or Cell Status    if_ru=${if_ru}    bts_host=${bts_host}    connection=GNB_OAM
    @{item_id_list}    get dictionary keys    ${expect_item_status_dict}
    FOR  ${item_id}  IN  @{item_id_list}
        ${expect_status_list}     get from dictionary    ${expect_item_status_dict}    ${item_id}
        ${item_status}    set variable    ${item_status_dic['${item_id}']}
        Run Keyword If    ${if_ru}    Check Single RU Status    item_status=${item_status}    expect_status_list=${expect_status_list}
        ...    ELSE    Check Single Cell Status    item_status=${item_status}    expect_status_list=${expect_status_list}
    END

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

Block Cell And Check Status
    [Arguments]  ${cell_id}    ${block_flag}=${True}
    @{all_cell_list}    create list    1    3    4
    ${cell_id_list}    ${expect_item_status_dic}    Define_Cell_Status    cell_id=${cell_id}    all_cell_list=${all_cell_list}
    ...    unblock_status=${Cell_unblock_status}    block_status=${Cell_block_status}    flag=${block_flag}
    Block or UnBlock Mulite Cell    cell_id_list=${cell_id_list}    block_flag=${block_flag}
    Wait Until Keyword Succeeds    10min    2min    Check All RU or Cell Status    expect_item_status_dict=${expect_item_status_dic}
    [Return]  ${expect_item_status_dic}

Reset Station And Check Status
    [Arguments]  ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM    ${timeout}=1800
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${reset_status}    coam.reset_site       timeout=${timeout}      connection=${connection}
    sleep    3min
    Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}

########### about Spark Muliti UE ################
Prepare MultiUE And Attach
    [Arguments]    ${multiue_config_direction}    ${ue_alias}=spark_UE    ${restart_ue}=${False}    ${restart_network}=${False}
    ...    ${get_spark_license}=${False}
    log to console      "Prepare UE"
    Run Keyword And Ignore Error    sparkMultiUE_yiyuan.require_ue    ue_alias=${ue_alias}    multiue_traffic_config=${multiue_config_direction}
    ...    restart_ue=${restart_ue}    restart_network=${restart_network}    get_spark_license=${get_spark_license}
    log to console      "UE Attach"
    sparkMultiUE_yiyuan.attach_ue    ue_alias=${ue_alias}

MultiUE Start Traffic
    [Arguments]    ${UL_Enable}=${True}    ${DL_Enable}=${True}    ${ue_alias}=spark_UE
    ${ue_ip1}    sparkMultiUE_yiyuan.get_ue_ip    ue_alias=${ue_alias}
    ${UE_IP_SA}    get from dictionary    ${ue_ip1}     0
    log to console    ${UE_IP_SA}
    ${command_str}    Catenate    cmd /C "iperf.exe -c ${appserver_addr} -u -p 5001 -l 1350B -f k -b 600M -t 9999 -i 1 -P 1 -B ${UE_IP_SA}"
    sleep   2s
    run keyword if    ${UL_Enable}==${True}    log to console      "UE Start UL Traffic"
    run keyword if    ${UL_Enable}==${True}    csn.send command     command=${command_str}    connection=sigspark
    sleep   2s
#    ${command}    csn.send command     command=tasklist /fi "imagename eq iperf.exe"     connection=sigspark
#    log to console    ${command}
#    run keyword if    ${UL_Enable}==${True}    log to console      "UE Start UL Traffic"
#    run keyword if    ${UL_Enable}==${True}    sparkMultiUE_yiyuan.start_data_transfer    ue_alias=${ue_alias}    direction=ul
    run keyword if    ${DL_Enable}==${True}    log to console      "UE Start DL Traffic"
    run keyword if    ${DL_Enable}==${True}    sparkMultiUE_yiyuan.TL750_start_data_transfer    ue_alias=${ue_alias}    direction=dl
    [Return]    ${UE_IP_SA}

MultiUE Stop Traffic
    [Arguments]    ${UL_Enable}=${False}    ${DL_Enable}=${True}    ${ue_alias}=spark_UE
    log to console      "UE Stop UL Traffic"
    run keyword if    ${UL_Enable}==${True}    sparkMultiUE_yiyuan.stop_data_transfer    ue_alias=${ue_alias}    direction=ul
    log to console      "UE Stop DL Traffic"
    run keyword if    ${DL_Enable}==${True}    sparkMultiUE_yiyuan.stop_data_transfer    ue_alias=${ue_alias}    direction=dl

MultiUE Detach
    [Arguments]  ${ue_alias}=spark_UE
    log to console      "UE Detach"
    sparkMultiUE_yiyuan.detach_ue    ue_alias=${ue_alias}

Capture Spark TP Log
    [Arguments]  ${log_time}=1min    ${logpath}=${OUTPUT_DIR}/${TEST NAME}    ${filter}=test    ${ue_alias}=spark_UE
    ...    ${UL_Enable}=${True}    ${DL_Enable}=${True}
    sparkMultiUE_yiyuan.start_log    ue_alias=${ue_alias}
    sleep   ${log_time}
    sparkMultiUE_yiyuan.stop_log    ue_alias=${ue_alias}
    Run keyword and ignore error    MultiUE Stop Traffic    UL_Enable=${UL_Enable}    DL_Enable=${DL_Enable}
    sparkMultiUE_yiyuan.export_log_file    ue_alias=${ue_alias}     logpath=${logpath}    filter=${filter}

Get Each UE TP From Spark
    [Arguments]  ${ue_num}    ${list_length}=${total_count}    ${row_list}=${case_row_list}
    @{dl_tput_info}    Create list
    @{ul_tput_info}    Create list
    @{dl_bler_info}    Create list
    @{ul_bler_info}    Create list
    @{total_result_list}    Create List
    FOR    ${ue_index}    IN RANGE  ${ue_num}
        ${id}    Evaluate    ${ue_index}+1
        ${result_dic}    Get_UE_TP_Bler_From_spark_log    file_path=${OUTPUT_DIR}/${TEST NAME}/UE-${id}.csv
        ...    list_length=${list_length}    row_list=${row_list}
        ${DL_bler}    get from dictionary  ${result_dic}    DL_bler
        ${UL_bler}    get from dictionary  ${result_dic}    UL_bler
        ${DL_tp}    get from dictionary  ${result_dic}    DL_tp
        ${UL_tp}    get from dictionary  ${result_dic}    UL_tp
        APPEND TO LIST   ${dl_tput_info}    ${DL_tp}[0]
        APPEND TO LIST   ${ul_tput_info}    ${UL_tp}[0]
        APPEND TO LIST   ${dl_bler_info}    ${DL_bler}[0]
        APPEND TO LIST   ${ul_bler_info}    ${UL_bler}[0]
        append to list   ${total_result_list}   ${result_dic}
    END
    [Return]    ${ul_tput_info}    ${dl_tput_info}   ${ul_bler_info}    ${dl_bler_info}    ${total_result_list}

Start Traffic And Check TP
    [Arguments]    ${UL_Enable}=${True}    ${DL_Enable}=${True}    ${ul_bler}=${1}    ${dl_bler}=${1}    ${ul_tp}=${10}    ${dl_tp}=${50}
    ...    ${multiue_config_direction}=${TLCommonConfig["MultiUECFG"]}    ${restart_ue}=${True}    ${restart_network}=${False}
    ...    ${get_spark_license}=${False}
    Create Directory    ${OUTPUT_DIR}/${TEST NAME}
    Prepare MultiUE And Attach    multiue_config_direction=${multiue_config_direction}    restart_ue=${restart_ue}
    ...    restart_network=${restart_network}    get_spark_license=${get_spark_license}
    ${UE_IP_SA}   MultiUE Start Traffic    UL_Enable=${UL_Enable}    DL_Enable=${DL_Enable}
    sleep  30s
    Capture Spark TP Log    UL_Enable=${UL_Enable}    DL_Enable=${DL_Enable}
    ${ue_num}    get length    ${multiue_config_direction['ue_index_for_call']}
    ${spark_result}    CB010600_common_keyword.Get Each UE TP From Spark    ue_num=${ue_num}
    ${status}    Check_Mulite_UE_TP_And_Bler    if_ul=${UL_Enable}    if_dl=${DL_Enable}
    ...    actual_value=@{spark_result[-1]}    expect_ul_bler=${ul_bler}    expect_dl_bler=${dl_bler}
    ...    expect_ul_tp=${ul_tp}    expect_dl_tp=${dl_tp}
    Run Keyword And Continue On Failure    should be equal    ${status}    ${True}
    [Return]  ${spark_result}
    [Teardown]    Run keyword and continue on failure    sigspark teardown for TL750

sigspark teardown for TL750
    [Arguments]    ${UL_Enable}=${True}     ${DL_Enable}=${True}
#    ${command}    csn.send command     command=tasklist /fi "imagename eq iperf.exe"     connection=sigspark
    csn.send command    command=taskkill /fi "imagename eq iperf.exe" /F    connection=sigspark
    Run keyword and ignore error    Stop Traffic And Detach UE    UL_Enable=${UL_Enable}    DL_Enable=${DL_Enable}

Stop Traffic And Detach UE
    [Arguments]  ${UL_Enable}=${False}    ${DL_Enable}=${True}
    MultiUE Stop Traffic    UL_Enable=${UL_Enable}    DL_Enable=${DL_Enable}
    MultiUE Detach

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

########### modify parameter ###################
Modify Parameters with json
    [Arguments]    ${input_list}    ${delta_id}=update_parameter    ${connection}=GNB_OAM    ${time}=10min
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
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
    sleep    ${time}
    [Teardown]    run keyword and ignore error    coam.teardown      connection=${connection}

Modify Common parameter via Coam
    [Arguments]  ${input_list}    ${time}=2min    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    FOR    ${item}  IN    @{input_list}
        ${dist_name}    get from dictionary     ${item}    dist_name
        ${parammeter}    get from dictionary    ${item}    parameter
        ${new_value}     get from dictionary    ${item}    value
        coam.Perform Parameter Recommissioning    dist_name=${dist_name}   parameter=${parammeter}   value=${new_value}
        ...    operation=update    skip_parameter_relation_errors=${True}    should_activate=${True}    connection=${connection}
        sleep  30s
    END
    sleep    ${time}
    [Teardown]  Run keyword and ignore error    coam.teardown      connection=${connection}

########### Check parameter Value ###################
Get RMOD SN Mumber And Match RU
    [Arguments]    ${bts_host}=${gNB_ip}    ${connection}=COAM_GNB
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${ru_info_list}    coam.get_frm    connection=${connection}
    ${ru_object_info_list}=    coam.get_managed_objects    class_name=RMOD_L    connection=${connection}
    ${match_ru_dict}    match_rmod_sn_number    ru_info_list=${ru_info_list}    ru_object_info_list=${ru_object_info_list}
    [Return]  ${match_ru_dict}
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Get RU ENDPOINT CAPACITY Info
    [Arguments]  ${bts_host}=${gNB_ip}    ${connection}=COAM_GNB
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${endpoint_capacity_info}    coam.get_managed_objects    class_name=ENDPOINT_CAPACITY_SHARING_GROUP    connection=${connection}
    ${endpoint_capacity_idct}    Get_RU_DL_And_UL_info    endpoint_capacity_info=${endpoint_capacity_info}
    Should Not Be Empty    ${endpoint_capacity_idct}
    [Return]  ${endpoint_capacity_idct}
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Get LOW LEVEL ENDPOINT Info
    [Arguments]  ${bts_host}=${gNB_ip}    ${connection}=COAM_GNB
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${endpoint_capacity_info}    coam.get_managed_objects    class_name=LOW_LEVEL_ENDPOINT    connection=${connection}
    ${all_ru_Endpoint_dict}    Get_All_Low_Level_Endpoint_info    Low_Level_Endpoint_info=${endpoint_capacity_info}
    ...    parameter=userPlaneFragmentationRequested
    [Return]  ${all_ru_Endpoint_dict}
    [Teardown]  Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Check ENDPOINT Parameter Value
    [Arguments]  ${Romd_list}    ${trans}=RX    ${exp_value}=${True}    ${bts_host}=${gNB_ip}    ${connection}=COAM_GNB
    ${match_ru_dict}    Get RMOD SN Mumber And Match RU    bts_host=${bts_host}
    ${Romd_L_list}    Cover_Romd_To_Rmod_L    match_ru_dict=${match_ru_dict}    rmod_list=${Romd_list}
    ${endpoint_capacity_idct}    Get RU ENDPOINT CAPACITY Info    bts_host=${bts_host}
    ${all_ru_Endpoint_dict}    Get LOW LEVEL ENDPOINT Info    bts_host=${bts_host}
    ${result}    Check_RMOD_Endpoint_info    all_ru_Endpoint_dict=${all_ru_Endpoint_dict}    Rmod_list=${Romd_L_list}
    ...    endpoint_capacity_idct=${endpoint_capacity_idct}    trans=${trans}    exp_value=${exp_value}
    should be equal   ${result}   ${True}

########### about swconfig ###################
Check flag in swconfig
    [Arguments]  ${para}    ${bts_host}=${gNB_ip}    ${connection}=GNB_SSH
    Create Directory    ${OUTPUT_DIR}/${TEST NAME}
    ssh.connect_to    hostname=${bts_host}    username=${gnb_ssh_username}     password=${gnb_ssh_password}    alias=${connection}
    sleep    1s
    ssh.Send Command  command=cat /ffs/run/swconfig.txt    connection=${connection}
    ${data}    ssh.Read Output    connection=${connection}
    ${data}    split_string    ${data}    separator=\n
    log to console    ${data}
    ${result}    Check_Parameter_In_Swconfig    data_list=${data}    para=${para}
    run keyword if    '${result}'=='False'    Modify swconfig And Reset BTS    bts_host=${bts_host}    para=#0x600012=0    connection=${connection}
    [Return]   ${data}
    [Teardown]  Run keyword and ignore error    ssh.disconnect    connection=${connection}


Backup and Modify swconfig file
    [Arguments]    ${bts_host}=${gNB_ip}    ${para}=0x600012=0    ${connection}=GNB_SSH
    ssh.connect_to    hostname=${gNB_ip}    username=${gnb_ssh_username}     password=${gnb_ssh_password}    alias=${connection}
    ${local_log_file_folder}    set variable    ${OUTPUT_DIR}/${TEST NAME}
    Run keyword and ignore error    ssh.Download File   /ffs/run/swconfig.txt    ${local_log_file_folder}/swconfig_bak.txt
    ...    connection=${connection}
    ssh.Send Command  command=cat /ffs/run/swconfig.txt    connection=${connection}
    ${data}    ssh.Read Output    connection=${connection}
    ${data}    split_string    ${data}    separator=\n
    Modify_Swconfig_Files    data_list=${data}    para=${para}    file_path=${local_log_file_folder}/swconfig.txt
    ssh.Upload File  local_path=${local_log_file_folder}/swconfig.txt    remote_path=/ffs/run/swconfig.txt    connection=${connection}
    [Teardown]  Run keyword and ignore error    ssh.disconnect    connection=${connection}

Modify swconfig And Reset BTS
    [Arguments]  ${bts_host}=${gNB_ip}    ${para}=0x600012=0    ${connection}=GNB_SSH
    Backup and Modify swconfig file    bts_host=${bts_host}    para=${para}    connection=${connection}
    Reset Station And Check Status    bts_host=${bts_host}    connection=${connection}

Capture Snapshot Multi Time
    [Arguments]   ${num}    ${sleep_time}=15min
    FOR  ${item}  IN RANGE  ${num}
        ${tmp}    Evaluate    ${item}+${1}
        Save Snapshot
        Run Keyword If    ${tmp}!=${num}    sleep    ${sleep_time}
    END

Delete Snapshot And Aasyslog From UTE
    [Arguments]    ${connection}=Test_PC
    ssh.connect_to    hostname=${UTE_ADDRESS}    username=${UTE_USERNAME}     password=${UTE_PASSWORD}    alias=${connection}
    sleep    1s
    ssh.Send Command  command=rm -rf ${OUTPUT DIR}/Snapshot*  connection=${connection}
    ssh.Send Command  command=rm -rf ${OUTPUT_DIR}/${TEST NAME}/*.txt  connection=${connection}
    [Teardown]  Run keyword and ignore error    ssh.disconnect    connection=${connection}

Delete Spark Log From Control Pc
    [Arguments]  ${connection}=Cygwin
    @{path_string}    split string    ${tl.ues[0].server_dir}    /
    ${spark_version}    set variable    ${path_string}[${2}]
    ssh.connect_to    hostname=${Control_PC_addr}    username=${Control_PC_user}     password=${control_PC_pass}    alias=${connection}
    ssh.send_command    command=cd '/cygdrive/c/tmp/uelog/AUTO';rm -rf *    connection=${connection}
    ssh.send_command    command=cd '/cygdrive/c/Program Files (x86)/${spark_version}/Data/Tmp';rm -rf *    connection=${connection}
    [Teardown]  Run keyword and ignore error    ssh.disconnect    connection=${connection}

Start Traffic And Capture Snapshot
    [Arguments]    ${expect_item_status_dic}    ${UL_Enable}=${True}    ${DL_Enable}=${True}    ${ul_bler}=${0}    ${dl_bler}=${1}
    ...    ${ul_tp}=${160}    ${dl_tp}=${1400}    ${multiue_config_direction}=${TLCommonConfig["MultiUECFG"]}    ${sleep_time}=15min
    Wait Until Keyword Succeeds    2min    20s    Check All RU or Cell Status    expect_item_status_dict=${expect_item_status_dic}
    ${ue_num}    get length    ${multiue_config_direction['ue_index_for_call']}
    ${attach_status}  run keyword and return status    Prepare MultiUE And Attach    multiue_config_direction=${multiue_config_direction}
    run keyword if  ${attach_status}==${True}    Delete Snapshot And Aasyslog From UTE
    MultiUE Start Traffic    UL_Enable=${UL_Enable}    DL_Enable=${DL_Enable}
    sleep  20s
    Start Capture Aasyslog
    Capture Spark TP Log And Snpshot
    ${log_path}    Stop Capture Aasyslog
    run keyword and continue on failure    run keyword if    ${UL_Enable}==${True}    power_ue.Check Tput    ue_type=samsung
    ...    direction=UL    log=${log_path}    cells=${cell_list}    target_throughput=${ul_tp}    target_avg_percent=${1}
    ...    actCarrierAggregation=${True}    min_percent=0
    run keyword and continue on failure    run keyword if    ${DL_Enable}==${True}    power_ue.Check Tput    ue_type=samsung
    ...    direction=DL    log=${log_path}    cells=${cell_list}    target_throughput=${dl_tp}    target_avg_percent=${1}
    ...    actCarrierAggregation=${True}    min_percent=0
#    ${spark_result}    Get Each UE TP From Spark    ue_num=${ue_num}    list_length=${1800}    row_list=${case_row_list}
#    ${single_ue_status}    Check_Mulite_UE_TP_And_Bler    if_ul=${UL_Enable}    if_dl=${DL_Enable}
#    ...    actual_value=@{spark_result[-1]}    expect_ul_bler=${ul_bler}    expect_dl_bler=${dl_bler}
#    ...    expect_ul_tp=${ul_tp}    expect_dl_tp=${dl_tp}
#    ${result}    ${total_ul_tp}    ${total_dl_tp}    Total_TP_From_Spark_Log    spark_list=${spark_result}    exp_ul=${160}    exp_dl=${1400}
#    Run Keyword And Continue On Failure    should be equal    ${single_ue_status}    ${True}
#    Run Keyword And Continue On Failure    should be equal    ${result}    ${True}
#    [Return]  ${spark_result}    ${attach_status}
    [Teardown]  Stop Traffic And Detach UE    UL_Enable=${UL_Enable}    DL_Enable=${DL_Enable}

Capture Spark TP Log And Snpshot
    [Arguments]  ${sleep_time}=15min    ${logpath}=${OUTPUT_DIR}/${TEST NAME}    ${filter}=test    ${ue_alias}=spark_UE    ${num}=${2}
    sparkMultiUE_yiyuan.start_log    ue_alias=${ue_alias}
    Capture Snapshot Multi Time    sleep_time=${sleep_time}    num=${num}
    sparkMultiUE_yiyuan.stop_log    ue_alias=${ue_alias}
    sparkMultiUE_yiyuan.export_log_file    ue_alias=${ue_alias}     logpath=${logpath}    filter=${filter}

Start Capture Aasyslog
    [Arguments]  ${log_name}=Aasys_Tput.txt    ${gnb_path}=/tmp/
    Teardown the Aasyslog save progress
    Aasyslog precondition
    Start the Aasyslog save progress    gnb_path=${gnb_path}    log_name=${log_name}

Stop Capture Aasyslog
    [Arguments]  ${log_name}=Aasys_Tput.txt    ${gnb_path}=/tmp/
    ${local_path}    set variable    ${OUTPUT_DIR}/${TEST NAME}/${log_name}
    Download Aasyslog File From GNB    log_path=${gnb_path}${log_name}    local_path=${local_path}
    Teardown the Aasyslog save progress
    [Return]    ${local_path}
