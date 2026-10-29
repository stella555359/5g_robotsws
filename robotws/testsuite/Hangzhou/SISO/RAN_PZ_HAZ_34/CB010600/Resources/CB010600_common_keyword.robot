*** Settings ***
Documentation    author：Hongyu Jiang
...              contact: hongyu.jiang@nokia-sbell.com
...              squad group: mmw_SG_04

Library     BuiltIn
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/aasyslog.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/sigspark_yiyuan_multiUE.py
Library     sigspark_yiyuan_multiUE.SigSparkMutiUE    WITH NAME    sparkMultiUE_yiyuan
Library     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001937_OTA/resources/5GC001937_mmw4_common_keywords.py
Library     taf.transport.ssh      WITH NAME    ssh
Library     taf.sbts.oam.coam.admin       WITH NAME    coam
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF_NEW/Resource/UUF_LogCollection.robot
Variables     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF_NEW/Config/UUF_Vars.py
Library     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB010636_Cloud/Resources/CB010636_counter_in_logs.py
Library     taf.hw.rf_attenuator    WITH NAME    att






*** Variables ***
${gNB_ip}                     ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${gNB_ip1}                    ${tl.gnbs[1].dus[0].airscale.common_units[0].lmp_connection.addr}
${gNB_username}               ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gNB_password}               ${tl.gnbs[0].cu.oam_http_connection_details.password}
${gnb_ssh_username}           ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${gnb_ssh_password}           ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${UTE_ADDRESS}                ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}               ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}               ${tl.test_pc.default_ssh_connection_details.password}
${att_ipaddr}                  ${tl.attenuator.ip_addr}
${att_api_port}                ${tl.attenuator.port}
${att_connection_port}         ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${Control_PC_addr}            ${tl.ues[0].ssh_connection_details.addr}
${Control_PC_user}            ${tl.ues[0].ssh_connection_details.username}
${Control_PC_pass}            ${tl.ues[0].ssh_connection_details.password}
${BTS_ID0}                     ${tl.gnbs[0].instance_id}
${NRBTS_ID0}                   ${tl.gnbs[0].global_bts_id}
${BTS_ID1}                     ${tl.gnbs[1].instance_id}
${NRBTS_ID1}                   ${tl.gnbs[1].global_bts_id}
@{Cell_unblock_status}        Unlocked    enabled    Active    configured    Unblocked
@{Cell_block_status}          Unlocked    disabled    Idle    configured    Blocked
@{allowed_list}               ${4655}    ${61524}    ${4654}    ${4681}    ${6327}
${total_count}                ${180}
@{case_row_list}              NR PDCP Thr. DL [Mbps]    NR PDCP Thr. UL [Mbps]    NR PDSCH iBLER[%]    NR PUSCH iBLER[%]
@{Romd_list}                  RMOD-1
@{Romd_list2}                 RMOD-2
${LOG_PATH}                   ${OUTPUT DIR}
@{cell_list}                  592563
@{empty_list}
@{ru_serial_list}             EB2202R0016


&{C_DL_Counters}    DL_RLC_PDU_VOL_UE_TPUT=M55349C03002
...                 DL_RLC_PDU_TIME_UE_TPUT=M55349C04002
...                 DL_RLC_VOL_UE_TPUT_FR1_SA_1CC=M55349C00026
...                 DL_RLC_VOL_UE_TPUT_FR1_SA_2CC=M55349C00027
...                 DL_RLC_VOL_UE_TPUT_FR1_SA_3CC=M55349C00028
...                 DL_RLC_VOL_UE_TPUT_FR1_SA_4CC=M55349C00029
...                 DL_RLC_VOL_UE_TPUT_FR1_SA_5CC=M55349C00030
...                 DL_RLC_TIM_UE_TPUT_FR1_SA_1CC=M55349C00032
...                 DL_RLC_TIM_UE_TPUT_FR1_SA_2CC=M55349C00033
...                 DL_RLC_TIM_UE_TPUT_FR1_SA_3CC=M55349C00034
...                 DL_RLC_TIM_UE_TPUT_FR1_SA_4CC=M55349C00035
...                 DL_RLC_TIM_UE_TPUT_FR1_SA_5CC=M55349C00036
...                 DL_RLC_VOL_UE_TPUT_FR1_NSA_1CC=M55349C00038
...                 DL_RLC_VOL_UE_TPUT_FR1_NSA_2CC=M55349C00039
...                 DL_RLC_TIM_UE_TPUT_FR1_NSA_1CC=M55349C00040
...                 DL_RLC_TIM_UE_TPUT_FR1_NSA_2CC=M55349C00041

&{C_UL_Counters}    UL_RLC_VOL_UE_TPUT_FR1_SA_1CC=M55349C00042
...                 UL_RLC_VOL_UE_TPUT_FR1_SA_2CC=M55349C00043
...                 UL_RLC_TIME_UE_TPUT_FR1_SA_1CC=M55349C00044
...                 UL_RLC_TIME_UE_TPUT_FR1_SA_2CC=M55349C00045
...                 UL_RLC_TIME_UE_TPUT=M55349C04001
...                 UL_RLC_VOL_UE_TPUT_TOT=M55349C03001

&{Counter_obj}      DL_RLC_PDU_VOL_UE_TPUT=NHRRC
...                 DL_RLC_PDU_TIME_UE_TPUT=NHRRC
...                 DL_RLC_VOL_UE_TPUT_FR1_SA_1CC=NHRRC
...                 DL_RLC_VOL_UE_TPUT_FR1_SA_2CC=NHRRC
...                 DL_RLC_VOL_UE_TPUT_FR1_SA_3CC=NHRRC
...                 DL_RLC_VOL_UE_TPUT_FR1_SA_4CC=NHRRC
...                 DL_RLC_VOL_UE_TPUT_FR1_SA_5CC=NHRRC
...                 DL_RLC_TIM_UE_TPUT_FR1_SA_1CC=NHRRC
...                 DL_RLC_TIM_UE_TPUT_FR1_SA_2CC=NHRRC
...                 DL_RLC_TIM_UE_TPUT_FR1_SA_3CC=NHRRC
...                 DL_RLC_TIM_UE_TPUT_FR1_SA_4CC=NHRRC
...                 DL_RLC_TIM_UE_TPUT_FR1_SA_5CC=NHRRC
...                 UL_RLC_VOL_UE_TPUT_FR1_SA_1CC=NHRRC
...                 UL_RLC_VOL_UE_TPUT_FR1_SA_2CC=NHRRC
...                 UL_RLC_TIME_UE_TPUT_FR1_SA_1CC=NHRRC
...                 UL_RLC_TIME_UE_TPUT_FR1_SA_2CC=NHRRC
...                 UL_RLC_TIME_UE_TPUT=NHRRC
...                 UL_RLC_VOL_UE_TPUT_TOT=NHRRC
...                 DL_RLC_VOL_UE_TPUT_FR1_NSA_1CC=NHRRC
...                 DL_RLC_VOL_UE_TPUT_FR1_NSA_2CC=NHRRC
...                 DL_RLC_TIM_UE_TPUT_FR1_NSA_1CC=NHRRC
...                 DL_RLC_TIM_UE_TPUT_FR1_NSA_2CC=NHRRC

*** Keywords ***
########### add 10636 counter check ##########
Get PM Counters Latest period time
    [Arguments]    ${counter_id_dict}=${C_DL_Counters}    ${NRCELL_id}=NRCELL-2    ${connection}=du_pm
    ${counter_last_period_time_dict}    Create dictionary
    ${counter_id_list}    get dictionary keys    ${counter_id_dict}
    ${first_counter_name}    set variable    ${counter_id_list}[${0}]
    ${counter_id}    set variable    ${counter_id_dict}[${first_counter_name}]
    Log to console    sleep 10min Wait counters data can be seen...
    sleep    10min
    Connect to gnb coam via ssl    bts_host=${gNB_ip1}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${counter_result}    coam.get_PM_counters    counter_ids=${counter_id}    connection=${connection}
    ${counter_obj_name}    set variable    ${Counter_obj}[${first_counter_name}]
    ${result}    Set Variable
    ...    ${counter_result['BTS']['MRBTS-${BTS_ID1}']['NRBTS-${NRBTS_ID1}']['${NRCELL_id}']['${counter_obj_name}']['${counter_id}']}
    ${counter_data_time_list}    get dictionary keys    ${result}
    ${counter_length}    Get Length    ${counter_data_time_list}
    ${counter_start_time}    set variable if    ${counter_length}>${0}    ${counter_data_time_list}[${-1}]    now
    Set to dictionary    ${counter_last_period_time_dict}    start_time=${counter_start_time}
    Log to console    ${counter_last_period_time_dict}
    [Return]    ${counter_last_period_time_dict}
    [Teardown]    run keyword and ignore error    coam.teardown      connection=${connection}

Get All Counter from DU
    [Arguments]    ${before_counter_time}    ${counter_id_dict}=${C_DL_Counters}    ${connection}=gnb_oam
    Log to console    get bts counters...
    Connect to gnb coam via ssl    bts_host=${gNB_ip1}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${counter_id_list}    get dictionary keys    ${counter_id_dict}
    ${after_counter_dict}    Create Dictionary
    ${result_list}    Create List
    FOR    ${counter_id_name}    IN    @{counter_id_list}
        Log to console    Get Counter ${counter_id_name}...
        ${counter_id}    set variable    ${counter_id_dict['${counter_id_name}']}
        ${counter_data}    coam.get_PM_counters    counter_ids=${counter_id}    connection=${connection}
        ${tmp_dict}    Change Counter Dict Fromat    counter_data=${counter_data}    counter_id_name=${counter_id_name}
        ...    counter_id_dict=${counter_id_dict}
        Append to list    ${result_list}    ${tmp_dict}
    END
    ${after_counter_dict}    merge_to_one_dictionary    ${result_list}
    ${all_cell_counter_dict}    get_counter_sum_value_after_dedicate_time
    ...    before_counter_time=${before_counter_time}
    ...    after_counter_dict=${after_counter_dict}
    [Return]    ${all_cell_counter_dict}
    [Teardown]    run keyword and ignore error    coam.teardown      connection=${connection}

_get_pm_counter
    [Arguments]    ${counter_id}    ${connection}=pm_wait
    Log to console    Wait counters data can be seen...
    Connect to gnb coam via ssl    bts_host=${gNB_ip1}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${counter_data}    coam.get_PM_counters    counter_ids=${counter_id}    connection=${connection}
    [Teardown]    run keyword and ignore error    coam.teardown      connection=${connection}

Change Counter Dict Fromat
    [Arguments]    ${counter_data}    ${counter_id_name}    ${counter_id_dict}
    ${counter_result}    Create Dictionary
    ${counter_id}    set variable    ${counter_id_dict['${counter_id_name}']}
    ${counter_obj_name}    set variable    ${Counter_obj}[${counter_id_name}]
    ${NRCELL_dict}    set variable    ${counter_data['BTS']['MRBTS-${BTS_ID1}']['NRBTS-${NRBTS_ID1}']}
    ${NRCELL_list}    get dictionary keys    ${NRCELL_dict}
    FOR    ${NRCELL}    IN    @{NRCELL_list}
        ${data}    set variable
        ...    ${counter_data['BTS']['MRBTS-${BTS_ID1}']['NRBTS-${NRBTS_ID1}']['${NRCELL}']['${counter_obj_name}']['${counter_id}']}
        ${tmp_dict}    _counter_value_to_new_dict    data=${data}    counter_name=${counter_id_name}
        Set to dictionary    ${counter_result}    ${NRCELL}=${tmp_dict}
    END
    [Return]    ${counter_result}

_counter_value_to_new_dict
    [Arguments]    ${data}    ${counter_name}
    ${new_dict}    Create Dictionary
    ${new_list}    Create List
    ${time}    Get dictionary keys    ${data}
    FOR    ${item}    IN    @{time}
        ${value}    set variable    ${data['${item}']}
        ${row_dict}    Create Dictionary    start_time=${item}    value=${value}
        Append to list    ${new_list}    ${row_dict}
    END
    set to dictionary    ${new_dict}    ${counter_name}=${new_list}
    [Return]    ${new_dict}

########### setup and teardown KW #################
Common setup
    [Arguments]     ${bts_host}=${gNB_ip}    ${id_index}=${0}
    robot_common_operations.Common Suite Setup
#    CI_interface.Common Suite Setup
    Adapt to ute cloud commission scf
    Setup Commission SCF       bts_host=${bts_host}    id_index=${id_index}
    Check GNB on air    bts_host=${bts_host}
    #Check Alarm List on BTS    allowed_list=${allowed_list}    bts_host=${bts_host}

CB010600 Suite Setup
    Common setup    bts_host=${gNB_ip}    id_index=${0}
    @{block_cell_id}    create list    2
    Determine whether to lock based on Cell status    lock_cell_list=${block_cell_id}    bts_host=${gNB_ip1}    BTS_ID=${BTS_ID1}
    ...    NRBTS_ID=${NRBTS_ID1}


CB010600 Suite Teardown
    @{block_cell_id}    create list    2
    Block or UnBlock Mulite Cell    cell_id_list=${block_cell_id}    block_flag=${False}    bts_host=${gnb_ip1}
    ...    BTS_ID=${BTS_ID1}    NRBTS_ID=${NRBTS_ID1}
    robot_common_operations.Common Suite Teardown

CB010776 Suite Setup
    Common setup    bts_host=${gNB_ip1}    id_index=${1}
    @{block_cell_id}    create list    1    3
    Determine whether to lock based on Cell status    lock_cell_list=${block_cell_id}    bts_host=${gNB_ip}    BTS_ID=${BTS_ID0}
    ...    NRBTS_ID=${NRBTS_ID0}
    Adjust the HBTE attenuation value    value_list=${AWHQN_PA_SET}    port_list=${PA_port_list}

Init_CI_Watchdog
    [Arguments]    ${gnb_index}=0    ${fail_with_alarms}=${True}
    run keyword and ignore error    AlarmWatchdog.init_watchdog
    ...    interval=5 sec
    ...    bts_config=${tl.gnbs[${gnb_index}]}
    ...    fail_with_alarms=${fail_with_alarms}


CB010776 Suite Teardown
    @{block_cell_id}    create list    1    3
    Block or UnBlock Mulite Cell    cell_id_list=${block_cell_id}    block_flag=${False}    bts_host=${gnb_ip}
    ...    BTS_ID=${BTS_ID0}    NRBTS_ID=${NRBTS_ID0}
    robot_common_operations.Common Suite Teardown

Case Teardown
    [Arguments]  ${input_list}    ${cell_id}    ${block_flag}    ${bts_host}=${gNB_ip}    ${if_cell_opt}=${True}
    Modify Common parameter via Coam    input_list=${input_list}    bts_host=${bts_host}    time=1min
    run keyword if    ${if_cell_opt}    Block Cell And Check Status    cell_id=${cell_id}    block_flag=${block_flag}
    robot_common_operations.Common Case Teardown

CB010600 Case Teardown
    [Arguments]    ${bts_host}=${gNB_ip}
    CI_interface.Common Case Teardown
    robot_common_operations.Common Case Teardown
    Run Keyword if    "${TEST_STATUS}"=="FAIL"    Save Snapshot    bts_host=${bts_host}
    Run Keyword if    "${TEST_STATUS}"=="FAIL"    Capture LMI Log    gnb_index=${0}    ru_serial_list=${ru_serial_list}
#    Modify swconfig And Reset BTS    para=#0x600012=0    bts_host=${bts_host}


########### check bts on air #################
Adapt to ute cloud commission scf
    ${TL_NAME1}   set variable if      '${testline_name}' == '${EMPTY}'    ${CONFIGURATION}    ${testline_name}
    ${pattern}   Set Variable    7_5(.*)
    ${TLNAME2}    Get Regexp Matches     ${TL_NAME1}    ${pattern}    1
    ${TLNAME}   Set Variable    7_5${TLNAME2}[0]
    Set Suite Variable    ${CURDIR_path}    ${CURDIR}/../../../../../../commissionings/HGZ/${TLNAME}

Set default SCF
    [Arguments]    ${bts_host}=${gNB_ip}    ${id_index}=${0}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${version}    coam.get_sw_version    connection=${connection}
    ${version_list}    split string    ${version}    separator=_
    ${version_scf}    run keyword if    '${version_list[2]}'=='9999'    Set Variable    SBTS00
    ...    ELSE   Set Variable    ${version_list[0]}
    ${default_scf_path}    set variable    ${CURDIR_path}/SCF_${version_scf}_GNB${id_index}.xml
    set suite variable    ${version_scf}
    set suite variable    ${default_scf_path}
    log to console   ${default_scf_path}
    [Teardown]     Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Setup Commission SCF
    [Arguments]   ${bts_host}=${gNB_ip}    ${id_index}=${0}    ${connection}=GNB_OAM
    Set default SCF    bts_host=${bts_host}    id_index=${id_index}
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
#    ${history_id_len}    Get Length    ${history_id_list}
    Run Keyword if    ${allowed_list} != None        Check List1 content in List2    list1=${actual_fault_id_list}    list2=${allowed_list}
    Run Keyword if    ${not_allowed_list} != None     Check List1 content not in List2    list1=${not_allowed_list}    list2=${actual_fault_id_list}
#    Run Keyword if    ${history_id_len} != ${0}    Save Snapshot
#    Should be equal    ${history_id_len}    ${0}

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
Determine whether to lock based on Cell status
    [Arguments]    ${lock_cell_list}    ${bts_host}    ${BTS_ID}    ${NRBTS_ID}    ${cell_expect_status}=${Cell_block_status}
    ${lock_cell_status}    Create Dictionary
    @{tmp_cell_list}    create list
    FOR    ${cell_id}    IN    @{lock_cell_list}
        APPEND TO LIST    ${tmp_cell_list}    ${cell_id}
        Set To Dictionary    ${lock_cell_status}    NRCELL-${cell_id}    ${cell_expect_status}
    END
    ${status_list}    Check All RU or Cell Status    expect_item_status_dict=${lock_cell_status}    if_ru=${False}    bts_host=${bts_host}
    ${length}    Get length    ${lock_cell_list}
    FOR    ${item}   IN RANGE    ${length}
        Run Keyword If    ${status_list}[${item}] == ${True}    Remove Values From List     ${lock_cell_list}    ${tmp_cell_list}[${item}]
        log to console    ${tmp_cell_list}
    END
    BLock or UnBlock Cell And Check Status    BTS_ID=${BTS_ID}    NRBTS_ID=${NRBTS_ID}    lock_cell_id_list=${lock_cell_list}    block_flag=${True}
    ...    bts_host=${bts_host}


BLock or UnBlock Cell And Check Status
    [Arguments]  ${BTS_ID}   ${NRBTS_ID}    ${lock_cell_id_list}=${empty_list}     ${unlock_cell_id_list}=${empty_list}    ${block_flag}=${True}
    ...    ${bts_host}=${gnb_ip}
    ${operate_cell_id_list}    Set Variable If    ${block_flag}    ${lock_cell_id_list}    ${unlock_cell_id_list}
    Block or UnBlock Mulite Cell    cell_id_list=${operate_cell_id_list}    block_flag=${block_flag}    bts_host=${bts_host}    BTS_ID=${BTS_ID}
    ...    NRBTS_ID=${NRBTS_ID}
    ${expect_item_status_dict}    create dictionary
    FOR  ${cell_id}  IN    @{lock_cell_id_list}
        Set to dictionary    ${expect_item_status_dict}    NRCELL-${cell_id}=${Cell_block_status}
    END
    FOR  ${cell_id}  IN   @{unlock_cell_id_list}
        Set to dictionary    ${expect_item_status_dict}    NRCELL-${cell_id}=${Cell_unblock_status}
    END
    Check All RU or Cell Status    expect_item_status_dict=${expect_item_status_dict}    if_ru=${False}    bts_host=${bts_host}

Block or UnBlock Mulite Cell
    [Arguments]  ${cell_id_list}    ${block_flag}=${True}    ${bts_host}=${gnb_ip}    ${BTS_ID}=${BTS_ID0}    ${NRBTS_ID}=${NRBTS_ID0}
    ...    ${connection}=GNB_OAM    ${timeout}=60
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
    @{all_cell_list}    create list    1    3
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
    Check GNB on air    bts_host=${bts_host}
    #Check Alarm List on BTS    allowed_list=${allowed_list}    bts_host=${bts_host}

########### about Spark Muliti UE ################
Prepare MultiUE And Attach
    [Arguments]    ${multiue_config_direction}    ${ue_alias}=spark_UE    ${restart_ue}=${False}    ${restart_network}=${False}
    ...    ${get_spark_license}=${False}    ${max_ue_num}=${8}
    log to console      "Prepare UE"
    Run Keyword And Ignore Error    sparkMultiUE_yiyuan.require_ue    ue_alias=${ue_alias}    multiue_traffic_config=${multiue_config_direction}
    ...    restart_ue=${restart_ue}    restart_network=${restart_network}    get_spark_license=${get_spark_license}
    ...    max_ue_num=${max_ue_num}
    log to console      "UE Attach"
    sparkMultiUE_yiyuan.attach_ue    ue_alias=${ue_alias}

MultiUE Start Traffic
    [Arguments]    ${UL_Enable}=${True}    ${DL_Enable}=${True}    ${ue_alias}=spark_UE
    run keyword if    ${UL_Enable}==${True}    log to console      "UE Start UL Traffic"
    run keyword if    ${UL_Enable}==${True}    sparkMultiUE_yiyuan.start_data_transfer    ue_alias=${ue_alias}    direction=ul
    run keyword if    ${DL_Enable}==${True}    log to console      "UE Start DL Traffic"
    run keyword if    ${DL_Enable}==${True}    sparkMultiUE_yiyuan.start_data_transfer    ue_alias=${ue_alias}    direction=dl

MultiUE Stop Traffic
    [Arguments]    ${UL_Enable}=${True}    ${DL_Enable}=${True}    ${ue_alias}=spark_UE
    log to console      "UE Stop UL Traffic"
    run keyword if    ${UL_Enable}==${True}    sparkMultiUE_yiyuan.stop_data_transfer    ue_alias=${ue_alias}    direction=ul
    log to console      "UE Stop DL Traffic"
    run keyword if    ${DL_Enable}==${True}    sparkMultiUE_yiyuan.stop_data_transfer    ue_alias=${ue_alias}    direction=dl

MultiUE Detach
    [Arguments]  ${ue_alias}=spark_UE
    log to console      "UE Detach"
    sparkMultiUE_yiyuan.detach_ue    ue_alias=${ue_alias}

#Change MultiUE Model To SA or NSA
#    [Arguments]  ${ue_alias}=spark_UE    ${if_SA}=${False}
#    log to console      "UE mode to NSA"
#    sparkMultiUE_yiyuan.require_ue    ue_alias=${ue_alias}    multiue_traffic_config=${TLCommonConfig["MultiUECFG"]}
#    ...    restart_ue=${False}    restart_network=${False}
#    sparkMultiUE_yiyuan.reboot_UE_by_outage   ue_alias=${ue_alias}
#    MultiUE Detach
#    sparkMultiUE_yiyuan.require_ue    ue_alias=${ue_alias}    multiue_traffic_config=${TLCommonConfig["MultiUECFG"]}
#    ...    restart_ue=${False}    restart_network=${False}
#    sparkMultiUE_yiyuan.Change_network_mode    ue_alias=${ue_alias}    if_SA=${if_SA}
#    MultiUE Detach


Capture Spark TP Log
    [Arguments]  ${log_time}=3min    ${logpath}=${OUTPUT_DIR}/${TEST NAME}    ${filter}=test    ${ue_alias}=spark_UE
    sparkMultiUE_yiyuan.start_log    ue_alias=${ue_alias}
    sleep   ${log_time}
    sparkMultiUE_yiyuan.stop_log    ue_alias=${ue_alias}
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
    Prepare MultiUE And Attach    multiue_config_direction=${multiue_config_direction}    restart_ue=${restart_ue}
    ...    restart_network=${restart_network}    get_spark_license=${get_spark_license}
    MultiUE Start Traffic    UL_Enable=${UL_Enable}    DL_Enable=${DL_Enable}
    log to console    expected bler:DL:${dl_bler} UL:${ul_bler}, dl_tp:${dl_tp}, ul_tp:${ul_tp}
    sleep  60s
#    Capture Spark TP Log
#    ${ue_num}    get length    ${multiue_config_direction['ue_index_for_call']}
#    ${spark_result}    Get Each UE TP From Spark    ue_num=${ue_num}
#    ${status}    Check_Mulite_UE_TP_And_Bler    if_ul=${UL_Enable}    if_dl=${DL_Enable}
#    ...    actual_value=@{spark_result[-1]}    expect_ul_bler=${ul_bler}    expect_dl_bler=${dl_bler}
#    ...    expect_ul_tp=${ul_tp}    expect_dl_tp=${dl_tp}
#    Run Keyword And Continue On Failure    should be equal    ${status}    ${True}
#    [Return]  ${spark_result}
    [Teardown]  Stop Traffic And Detach UE    UL_Enable=${UL_Enable}    DL_Enable=${DL_Enable}

Stop Traffic And Detach UE
    [Arguments]  ${UL_Enable}=${True}    ${DL_Enable}=${True}
    MultiUE Stop Traffic    UL_Enable=${UL_Enable}    DL_Enable=${DL_Enable}
    MultiUE Detach

################## Snopshot ###########################
Save Snapshot
    [Arguments]    ${connection}=cOAM    ${timeout}=10min    ${bts_host}=${gNB_ip}
    log to console    Save Snapshot...
    run keyword and ignore error     coam.teardown    connection=${connection}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}
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
    [Arguments]  ${input_list}    ${bts_host}=${gNB_ip}    ${time}=2min    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
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
    [Arguments]  ${Romd_list}    ${trans}=RX    ${exp_value}=${True}    ${bts_host}=${gNB_ip}
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
    ssh.connect_to    hostname=${bts_host}    username=${gnb_ssh_username}     password=${gnb_ssh_password}    alias=${connection}
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
    [Arguments]    ${expect_item_status_dic}    ${UL_Enable}=${True}    ${DL_Enable}=${True}
    ...    ${ul_tp}=${160}    ${dl_tp}=${1400}    ${multiue_config_direction}=${TLCommonConfig["MultiUECFG"]}
    Wait Until Keyword Succeeds    2min    20s    Check All RU or Cell Status    expect_item_status_dict=${expect_item_status_dic}
    ${ue_num}    get length    ${multiue_config_direction['ue_index_for_call']}
    ${attach_status}  run keyword and return status    Prepare MultiUE And Attach    multiue_config_direction=${multiue_config_direction}
    run keyword if  ${attach_status}==${True}    Delete Snapshot And Aasyslog From UTE
    MultiUE Start Traffic    UL_Enable=${UL_Enable}    DL_Enable=${DL_Enable}
    sleep  20s
    Start Capture Aasyslog
    Capture Spark TP Log And Snpshot
    ${log_path}    Stop Capture Aasyslog
    Run keyword and ignore error    run keyword if    ${UL_Enable}==${True}    power_ue.Check Tput    ue_type=samsung
    ...    direction=UL    log=${log_path}    cells=${cell_list}    target_throughput=${ul_tp}    target_avg_percent=${1}
    ...    actCarrierAggregation=${True}    min_percent=0
    Run keyword and ignore error    run keyword if    ${DL_Enable}==${True}    power_ue.Check Tput    ue_type=samsung
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

Capture LMI Log
    [Arguments]    ${gnb_index}    ${ru_serial_list}    ${log_dir}=${OUTPUT_DIR}/${TEST_NAME}
    Log To Console   //TODO: UUF Catch RU Log
    Log To Console   ${RU_LOG_FLAG}
    ${log_dir_not_exist}   Run Keyword And Return Status   OperatingSystem.Directory Should Not Exist   ${log_dir}
    Run Keyword If   ${log_dir_not_exist}   OperatingSystem.Create Directory   ${log_dir}
    ${RU_serial_pc_info}    UUF Get RU PC Info Accordind To Serial    ru_serial_list=${ru_serial_list}
    UUF Catch RU Log From LMI    testline=gnb_${gnb_index}    ru_list=${RU_serial_pc_info}

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
