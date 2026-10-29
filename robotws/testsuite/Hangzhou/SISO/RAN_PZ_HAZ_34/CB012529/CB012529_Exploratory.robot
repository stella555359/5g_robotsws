*** Settings ***
Documentation
...    author: Jiang Hongyu
...    contact: hongyu.jiang@nokia-sbell.com
...    squad group: MMW_SG_04
...    feature : CB012529-B



Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Commercial_mobile_phone_adb_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/SISO_common_operation.robot
Library     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001937_OTA/resources/samsung_sigspark.py
Library     samsung_sigspark.SigSpark    WITH NAME    samsung_spark
Library     testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/CB010706/Resources/CB010706_common_keywords.py
Variables   ./Resources/CB012529_modify_para.py





Suite Setup       CB012529 Case Setup
Suite Teardown    robot_common_operations.Common Suite Teardown


*** Variables ***
@{BBMOD_list}               1
@{RMOD_list}                2    5    8
@{RMOD_id_list}             1    4    7
@{allowed_list1}            ${4655}    ${61524}    ${61652}    ${4654}
@{allowed_list2}            ${4655}    ${61524}    ${61652}    ${4654}    ${49}
@{ue_id_list}               ${0}    ${1}    ${2}
@{delete_cell_id}           41    42    43   44   45
@{delete_nrcellgrp_id}      41    42    43   44   45
@{all_RMOD_id_list}         0   1    2    3    4    5    6   7   8
@{all_RMOD_list}            1    2    3    4    5    6   7   8   9
@{all_BBMOD_list}           1   3
@{all_RF_link_list}         1   2   3   4   5   6   7   8   9   10   11   12





*** Test Cases ***
[1]Input SCF multi Time
    [Setup]    Common Case Setup
    FOR   ${i}   IN RANGE   ${30}
        Commission SCF And Check OnAir
    END
    [Teardown]    Common Case Teardown

[1]Rest RF And Power Reset RF
    [Setup]    Common Case Setup
    FOR   ${i}   IN RANGE   ${20}
        Reset RF Module And Check On Air    bts_host=${gNB_ip}    RMOD_index_list=${all_RMOD_id_list}    allowed_list=${allowed_list1}
        ...    timeout=120s    interval=120
    END
    @{allow_alarm}    Create List    10    1815    4589
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_alarm}
    FOR   ${i}  IN RANGE    ${20}
        RMOD Power Reset
    END
    AlarmWatchdog.remove_allow_alarms    fault_id=${allow_alarm}
    [Teardown]    Common Case Teardown

[1]Repeat Reset BBMOD
    [Setup]    Common Case Setup
    Reset BBMOD Multiple Times    BBMOD_list=${BBMOD_list}    reset_time=${100}    bts_host=${gNB_ip}    if_muti_rat=${True}
    ...    BTS_ID=${TL_BTS_ID}    allowed_fault_id=${allowed_list1}
    [Teardown]    Common Case Teardown

[1]Block All Cell And Unblock Cell
    [Setup]    Common Case Setup
    ${nr_cells_list}    ${lte_cells_list}    ${rmod_cell_dict}    Get RMOD And Cell Mapping Relationship    RMOD_list=${all_RMOD_list}
    AlarmWatchdog.add_allow_alarms    fault_id=49
    FOR   ${i}  IN RANGE    ${100}
        Block NR And LTE Cell    nr_cells_list=${nr_cells_list}    lte_cells_list=${lte_cells_list}
        Unblock NR And LET Cell     nr_cells_list=${nr_cells_list}    lte_cells_list=${lte_cells_list}
    END
    [Teardown]    Common Case Teardown

[1]RAT reset multi Time
    [Setup]    Common Case Setup
    Rat Reset Multiple Times    BBMOD_list=${BBMOD_list}    reset_time=${100}    allowed_fault_id=${allowed_list1}    if_muti_rat=${True}
    [Teardown]    Common Case Teardown

[1]RF Lock And Unlock
    [Setup]    Common Case Setup
    FOR  ${i}   IN RANGE   ${30}
        Lock or Unlock RUs And Check Status    lock_RU_id_list=${all_RMOD_list}    lock_flag=${True}    timeout=120
        Lock or Unlock RUs And Check Status    unlock_RU_id_list=${all_RMOD_list}    lock_flag=${False}    timeout=120
    END
    [Teardown]    Common Case Teardown

[1]Lock Baseband mutil Time
    [Setup]    Common Case Setup
    FOR  ${i}   IN RANGE   ${2}
        Lock BTS BaseBand    BBMOD_id_list=${all_BBMOD_list[0:2]}    timeout=120
        UnLock BTS BaseBand    BBMOD_id_list=${all_BBMOD_list[0:2]}
    END
    [Teardown]    Common Case Teardown

[1]RF Link Lock And Unlock
    [Setup]    Common Case Setup
    @{allow_alarm}    Create List    10    1868
    FOR  ${i}   IN RANGE   ${5}
        AlarmWatchdog.add_allow_alarms    fault_id=${allow_alarm}
        Lock or Unlock RF Link    RF_link_id_list=${all_RF_link_list}    BBMOD_id=1    lock_flag=${True}
        Lock or Unlock RF Link    RF_link_id_list=${all_RF_link_list}    BBMOD_id=1    lock_flag=${False}
        AlarmWatchdog.remove_allow_alarms    fault_id=${allow_alarm}
        AlarmWatchdog.add_allow_alarms    fault_id=${allow_alarm}
        Lock or Unlock RF Link    RF_link_id_list=${all_RF_link_list[0:7]}    BBMOD_id=3    lock_flag=${True}
        Lock or Unlock RF Link    RF_link_id_list=${all_RF_link_list[0:7]}    BBMOD_id=3    lock_flag=${False}
        AlarmWatchdog.remove_allow_alarms    fault_id=${allow_alarm}
    END
    [Teardown]    Common Case Teardown

#[1]CB012529-SR-B_006_FDD_L3_on_concurrent_mode_NRFDD_LTEFDD_and_NRFDD_M4_simultaneously
#    [Setup]    Common Case Setup
#    Change M3 To M4    cell_list=${delete_cell_id}    nrcellgrp_id_list=${delete_nrcellgrp_id}    rmod_id=2
#    Change M4 To M3    cell_list=${delete_cell_id}    nrcellgrp_id_list=${delete_nrcellgrp_id}
#    Modify Parameter And Wait On Air    input_list=${D_case1_para}
#    AlarmWatchdog.add_allow_alarms    fault_id=49
#    ${nr_cells_list}    ${lte_cells_list}    ${rmod_cell_dict}    Get RMOD And Cell Mapping Relationship    RMOD_list=${RMOD_list}
#    ${nr_output_list}    ${lte_output_list}    Block NR And LTE Cell    nr_cells_list=${nr_cells_list}
#     ...    lte_cells_list=${lte_cells_list}    excpet_nr_list=${call_nr_list}    excpet_lte_list=${call_lte_list}
#    [Teardown]     Common Case Teardown

*** Keywords ***
CB012529 Case Setup
    robot_common_operations.Common Suite Setup
    Commission SCF And Check OnAir

Case Teardown
    [Arguments]    ${nr_cells_list}    ${lte_cells_list}
    Unblock NR And LET Cell     nr_cells_list=${nr_cells_list}    lte_cells_list=${lte_cells_list}
    Common Case Teardown

Get RMOD And Cell Mapping Relationship
    [Arguments]    ${RMOD_list}     ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${rmod_cell_dict}    Create Dictionary
    ${nr_cells_list}    Create List
    ${lte_cells_list}    Create List
    ${cells_info_list}    coam.get_cell_list    connection=${connection}
    ${nr_cells_info}    Set Variable    ${cells_info_list['cells']['nr']}
    ${lte_cells_info}    Set Variable    ${cells_info_list['cells']['lte']}
    FOR   ${rmod_index}  IN  @{RMOD_list}
        ${nr_cell_list_tmp}    Get the cell ID By RMOD ID    cells_info=${nr_cells_info}    RMOD_index=${rmod_index}
        ${lte_cell_list_tmp}    Get the cell ID By RMOD ID    cells_info=${lte_cells_info}    RMOD_index=${rmod_index}
        ${nr_cells_list}    Evaluate    ${nr_cells_list} + ${nr_cell_list_tmp}
        ${lte_cells_list}    Evaluate    ${lte_cells_list} + ${lte_cell_list_tmp}
        Set To Dictionary    ${rmod_cell_dict}    ${rmod_index}    ${nr_cell_list_tmp}
    END
    [Return]    ${nr_cells_list}    ${lte_cells_list}    ${rmod_cell_dict}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Get the cell ID By RMOD ID
    [Arguments]     ${cells_info}    ${RMOD_index}
    @{cell_list}    Create List
    FOR  ${item}  IN  @{cells_info}
        ${rmod_config}    set variable    ${item['carrierList'][0]['antennaLineId']['configuration']}
        ${status}    Run Keyword And Return Status    Should Contain    ${rmod_config}    RMOD-${RMOD_index}
        ${cell_id}    Set Variable If    ${status}    ${item['id']['configuration']}
        ${cell_id}    Run Keyword If    ${status}    Split String    ${cell_id}    -
        Run Keyword If    ${status}    Append to list    ${cell_list}    ${cell_id[-1]}
    END
    [Return]    ${cell_list}

Add Element To List
    [Arguments]    ${input_list}    ${excpet_element_list}
    @{output_list}    Create List
    FOR    ${i}    IN   @{input_list}
        run keyword if    '${i}' not in @{excpet_element_list}    Append To List    ${output_list}    ${i}
    END
    [Return]    ${output_list}

Block NR And LTE Cell
    [Arguments]    ${nr_cells_list}    ${lte_cells_list}    ${excpet_nr_list}=${empty_list}    ${excpet_lte_list}=${empty_list}
    ...    ${allowed_list}=${allowed_list2}
    ${nr_output_list}    Block Cell And Check Status    cells_list=${nr_cells_list}    excpet_list=${excpet_nr_list}
    ...    cell_type=nr    allowed_list=${allowed_list}
    ${lte_output_list}    Block Cell And Check Status    cells_list=${lte_cells_list}    excpet_list=${excpet_lte_list}
    ...    cell_type=lte    allowed_list=${allowed_list}
    [Return]    ${nr_output_list}    ${lte_output_list}

Block Cell And Check Status
    [Arguments]    ${cells_list}    ${excpet_list}    ${cell_type}    ${allowed_list}
    ${excet_list_len}    Get Length    ${excpet_list}
    ${output_list}     Add Element To List    input_list=${cells_list}    excpet_element_list=${excpet_list}
    BLock or UnBlock Cell And Check Status    allowed_list=${allowed_list}    block_cell_id_list=${output_list}
    ...    block_flag=${True}     unblock_cell_id_list=${excpet_list}    cell_type=${cell_type}
    [Return]    ${output_list}

Unblock NR And LET Cell
    [Arguments]    ${nr_cells_list}    ${lte_cells_list}
    BLock or UnBlock Cell And Check Status    allowed_list=${allowed_list2}    block_flag=${False}
    ...     unblock_cell_id_list=${nr_cells_list}    cell_type=nr
    BLock or UnBlock Cell And Check Status    allowed_list=${allowed_list1}    block_flag=${False}
    ...     unblock_cell_id_list=${lte_cells_list}    cell_type=lte

################ Relate To UE ###################
Collect Aasyslog
    [Arguments]    ${log_time}    ${ignore_time}=10s
    ${log_path}    power_ue.Collect Tput   ue_type=samsung    duration=${log_time}    ignore_time=${ignore_time}
    [Return]    ${log_path}

Check UE TP From Spark Log
    [Arguments]  ${log_path}    ${expect_ul}    ${expect_dl}    ${row_list}    ${list_length}
    ${throughput_dict}    Get_UE_TP_From_spark_log    file_path=${log_path}    list_length=${list_length}    row_list=${row_list}
    log to console    ${throughput_dict}
    ${DL_tp_info}    get from dictionary   ${throughput_dict}    DL_tp
    ${UL_tp_info}    get from dictionary   ${throughput_dict}    UL_tp
    run keyword and continue on failure    Should Be True     ${DL_tp_info}[${0}] > ${expect_dl}
    run keyword and continue on failure    Should Be True     ${UL_tp_info}[${0}] > ${expect_ul}

Check TP From Aasyslog
    [Arguments]    ${ul_list}    ${dl_list}    ${exp_ul_tp}    ${exp_dl_tp}    ${log_path}    ${if_ul}=${True}    ${if_dl}=${True}
    run keyword and continue on failure    run keyword if    ${if_ul}==${True}    power_ue.Check Tput    ue_type=samsung
    ...    direction=UL    log=${log_path}    cells=${ul_list}    target_throughput=${exp_ul_tp}    target_avg_percent=1
    ...    actCarrierAggregation=${True}    min_percent=0
    run keyword and continue on failure    run keyword if    ${if_dl}==${True}    power_ue.Check Tput    ue_type=samsung
    ...    direction=DL    log=${log_path}    cells=${dl_list}    target_throughput=${exp_dl_tp}    target_avg_percent=1
    ...    actCarrierAggregation=${True}    min_percent=0

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
    [Arguments]    ${ue_index}    ${log_name}=sigspark_UE${ue_index}
    Create Directory     ${output_dir}/${TEST_NAME}
    ${log_path}    set variable    ${output_dir}/${TEST_NAME}/${log_name}
    ${ue_alias}    set variable    UE_${ue_index}
    samsung_spark.stop_log    ue_alias=${ue_alias}    logname=${log_path}.xml   filter=test
    [Return]  ${log_path}.csv

start multi power ue traffic ul and dl
    [Arguments]    ${ue_index_list}    ${ul_throughput_list}    ${dl_throughput_list}    ${ul_duration}=6000    ${dl_duration}=6000
    ...    ${protocol}=udp    ${if_ul}=${True}    ${if_dl}=${True}    ${process_num}=${2}    ${ue_type}=samsung
    log to console      Start traffic    console=yes
    ${ue_num}    Get Length    ${ue_index_list}
    FOR    ${item}    IN RANGE    ${ue_num}
        run keyword and continue on failure    run keyword if    ${if_ul}    power_ue.Start traffic    ue_index=${ue_index_list}[${item}]
        ...    throughput=${ul_throughput_list}[${item}]M    duration=${ul_duration}    ue_type=${ue_type}    protocol=${protocol}
        ...    iperf_port=${ul_power_port_list}[${item}]    process_num=${process_num}    iperf_type=via_command    direction=ul
        sleep    1s
        run keyword and continue on failure    run keyword if    ${if_dl}    172 UE IP Start DL traffic UDP
        ...    ue_index=${ue_index_list}[${item}]    DL_port=${dl_power_port_list}[${item}]    time=${dl_duration}
        ...    traffic=${dl_throughput_list}[${item}]M    process_num=${process_num}
    END

172 UE IP Start DL traffic UDP
    [Arguments]    ${ue_index}=${0}    ${DL_port}=${tl.ues[${ue_index}].iperf_details.port}    ${time}=10    ${traffic}=10    ${process_num}=${1}
    ${UE_IP}    Get Commercial UE Right IP    ue_index=${ue_index}    serial_number=${tl.ues[${ue_index}].serial_number}    connection=cygwin
    wait until keyword succeeds    1 min    10 sec    Connect to EPC APP    ue_index=${ue_index}
    sleep   2s
    csn.execute    command=ps -ef|grep iperf|grep -v grep|grep ${DL_port}| awk '{print $2}' |xargs kill -9    connection=EPCAPP
    csn.send_command
    ...    command=iperf -c ${UE_IP} -u -t ${time} -i 1 -p ${DL_port} -P ${process_num} -f m -b ${traffic} -l 1024B -T 64&
    ...    connection=EPCAPP
    log to console    .....UE_${ue_index} udp dl iperf start....

Get Commercial UE Right IP
    [Arguments]    ${ue_index}=${0}    ${serial_number}=${tl.ues[${ue_index}].serial_number}    ${connection}=cygwin
    Connect to control pc via cygwin    ue_index=${ue_index}    alias=${connection}
    csn.send_command    command=adb -s ${serial_number} shell ip -f inet addr |grep inet |grep -v ims00 | cut -d '/' -f 1 |awk '{print $2}'
    ...    connection=${connection}
    ${UE_IP_info}    csn.read_output    connection=${connection}
    ${UE_IP}    Get_UE_Right_IP    cmd_info=${UE_IP_info}
    log to console    UE IP :${UE_IP}
    [Return]    ${UE_IP}

stop multi power ue traffic ul and dl
    [Arguments]    ${ue_index_list}    ${protocol}=udp    ${if_ul}=${True}    ${if_dl}=${True}    ${ue_type}=samsung
    log to console     Stop traffic    console=yes
    ${ue_num}    Get Length    ${ue_index_list}
    FOR    ${item}    IN RANGE    ${ue_num}
        run keyword if    ${if_ul}    power_ue.Stop traffic    direction=ul    ue_index=${ue_index_list}[${item}]    ue_type=${ue_type}
        ...    iperf_type=via_command    protocol=${protocol}    iperf_port=${ul_power_port_list}[${item}]
        run keyword if    ${if_dl}    power_ue.Stop traffic    direction=dl    ue_index=${ue_index_list}[${item}]    ue_type=${ue_type}
        ...    protocol=${protocol}    iperf_port=${dl_power_port_list}[${item}]
    END

UE Start Traffic And Check Tp
    [Arguments]    ${ue_index_list}     ${ul_throughput_list}    ${dl_throughput_list}    ${expect_ul_list}
    ...    ${expect_dl_list}    ${list_length}=${60}    ${process_num}=${1}    ${log_time}=60s    ${protocol}=udp    ${ignore_time}=15s
    Get all Samsung pointer variable
    ${ue_num}    Get Length    ${ue_index_list}
    FOR    ${item}  IN RANGE    ${ue_num}
        ${attach_mode}    Set Variable If    '${ue_index_list}[${item}]' == '${0}'     LTE    5G_NSA
        UE attach by Spark    ue_index=${ue_index_list}[${item}]    ue_type=huawei_sigspark    attach_mode=${attach_mode}
    END
    Spark Start UE Log    ue_index=${0}
    start multi power ue traffic ul and dl    ue_index_list=${ue_index_list}    ul_throughput_list=${ul_throughput_list}
    ...    dl_throughput_list=${dl_throughput_list}    if_ul=${True}    if_dl=${True}    process_num=${process_num}   protocol=${protocol}
    ${aasyslog_path}    Collect Aasyslog    log_time=${log_time}    ignore_time=${ignore_time}
    FOR    ${item}  IN RANGE    ${ue_num}
        ${row_list}    Set Variable If    '${ue_index_list}[${item}]' == '${0}'     ${LTE_row_list}    ${NR_row_list}
        ${spark_log_path}    Spark Stop UE Log    ue_index=${ue_index_list}[${item}]
        Check UE TP From Spark Log    log_path=${spark_log_path}    expect_ul=${expect_ul_list}[${item}]    expect_dl=${expect_dl_list}[${item}]
        ...    row_list=${row_list}    list_length=${list_length}
    END
    stop multi power ue traffic ul and dl    ue_index_list=${ue_index_list}    protocol=${protocol}
    Run Keyword And Continue On Failure    Check TP From Aasyslog    ul_list=${phy_cell_list[0:1]}    dl_list=${phy_cell_list[0:1]}
    ...    exp_ul_tp=${expect_ul_list}[${0}]    exp_dl_tp=${expect_dl_list}[${0}]    log_path=${aasyslog_path}
    Run Keyword And Continue On Failure    Check TP From Aasyslog    ul_list=${phy_cell_list[1:2]}    dl_list=${phy_cell_list[1:2]}
    ...    exp_ul_tp=${expect_ul_list}[${1}]    exp_dl_tp=${expect_dl_list}[${1}]    log_path=${aasyslog_path}
    [Teardown]  UE detach by Spark    ue_index_list=${ue_index_list}

Add Or Delete Cell And Check On air
    [Arguments]    ${if_add}    ${bts_host}   ${BTS_ID}    ${NRBTS_ID}    ${cell_id_list}    ${nrcellgrp_id_list}    ${scf_name}=${EMPTY}
    ${add_scf_path}    set variable    /home/ute/SCF/SCF_SBTS00.xml
    set suite variable    ${add_scf_path}
    ${info}    Get Distname Parameters Vlaue     dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
    ${refNrCellGroup_list}    Set Variable        ${info[${0}]['parameters']['refNrCellGroup']}
    ${node_index_list}    run keyword if    ${if_add}    Add Node Index    org_node_list=${refNrCellGroup_list}   cell_id_list=${cell_id_list}
    ...    ELSE    Delete Node Index    org_node_list=${refNrCellGroup_list}    cell_id_list=${cell_id_list}
    Add Or Delete Cell By WebUI    if_add=${if_add}    bts_host=${bts_host}    scf_name=${scf_name}   BTS_ID=${BTS_ID}    NRBTS_ID=${NRBTS_ID}
    ...    cell_id_list=${cell_id_list}    nrcellgrp_id_list=${nrcellgrp_id_list}    node_index_list=${node_index_list}
    ...    scf_path=${add_scf_path}
    Check GNB on air

Delete Node Index
    [Arguments]    ${org_node_list}    ${cell_id_list}
    ${node_index_list}    Create List
    FOR  ${cell_id}  IN  @{cell_id_list}
        ${node_index}    Get Index From List    ${org_node_list}    ${cell_id}
        Append To List    ${node_index_list}    ${node_index}
    END
    ${node_index_list}    Evaluate    sorted(${node_index_list}, reverse=True)
    [Return]    ${node_index_list}

Add Node Index
    [Arguments]    ${org_node_list}   ${cell_id_list}
    ${node_length}    Get Length    ${org_node_list}
    ${add_cell_len}    Get Length    ${cell_id_list}
    ${node_index_list}    Create List
    FOR   ${id}  IN RANGE  ${add_cell_len}
        ${node_index}    Evaluate    ${node_length} + ${id}
        Append To List    ${node_index_list}    ${node_index}
    END
    [Return]    ${node_index_list}

Change M3 To M4
    [Arguments]   ${cell_list}    ${nrcellgrp_id_list}    ${rmod_id}=2    ${bts_host}=${gNB_ip}    ${if_add}=${False}
    ${nr_cells_list1}    ${lte_cells_list1}    ${rmod_cell_dict1}    Get RMOD And Cell Mapping Relationship    RMOD_list=${RMOD_list}
    ${Rmod2_cell_list1}    Get From Dictionary    ${rmod_cell_dict1}    ${rmod_id}
    ${output_list}    Add Element To List    input_list=${Rmod2_cell_list1}    excpet_element_list=${cell_list}
    Add Or Delete Cell And Check On air    if_add=${if_add}    bts_host=${bts_host}   BTS_ID=${TL_BTS_ID}
    ...     cell_id_list=${cell_list}    nrcellgrp_id_list=${nrcellgrp_id_list}     NRBTS_ID=${TL_NRBTS_ID}
    ${nr_cells_list}    ${lte_cells_list}    ${rmod_cell_dict}    Get RMOD And Cell Mapping Relationship    RMOD_list=${RMOD_list}
    ${Rmod2_cell_list}    Get From Dictionary    ${rmod_cell_dict}    ${rmod_id}
    Sort List    ${output_list}
    Sort List    ${Rmod2_cell_list}
    Lists Should Be Equal    ${output_list}    ${Rmod2_cell_list}

#Change M4 To M3
#    [Arguments]    ${cell_list}    ${nrcellgrp_id_list}    ${bts_host}=${gNB_ip}
#    Add Or Delete Cell And Check On air    if_add=${True}    bts_host=${bts_host}   BTS_ID=${TL_BTS_ID}
#    ...     cell_id_list=${cell_list}    nrcellgrp_id_list=${nrcellgrp_id_list}     NRBTS_ID=${TL_NRBTS_ID}


RMOD Power Reset
    [Arguments]
    FOR    ${i}    IN RANGE    ${7}
        Reset PDU And Check On Air    model=HBTE    bts_host=${gNB_ip}    allowed_list=${allowed_list1}    sleep_time=60s    interval=120
        ...    PDU_IP=${tl.gnbs[0].dus[0].rus[${i}].pdu_port.pdu.addr}    PDU_PORT=${tl.gnbs[0].dus[0].rus[${i}].pdu_port.port_no}
        ...    check_lte_cell=${True}
    END

Commission SCF And Check OnAir
    [Arguments]  ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM    ${timeout}=600
    ${default_scf_path}    Set Variable    /home/ute/SCF/SCF_SBTS00.xml
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    COAM Commission with scf file    scf_file_path=${default_scf_path}    connection=${connection}    timeout=${timeout}
    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}
    Check GNB on air