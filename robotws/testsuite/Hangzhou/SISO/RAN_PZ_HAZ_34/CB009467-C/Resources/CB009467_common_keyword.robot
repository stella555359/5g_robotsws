*** Settings ***
Documentation    author：Na Li
...              contact: Na.Li@nokia-sbell.com
...              squad group: mmw_SG_04


Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/Commercial_mobile_phone_adb_common_keywords.robot
Resource    taf/rfrl/common_resources/robot/TTI_Trace.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/TTI_Trace_Analysis_MMW4.py
Library     TTI_Trace_Analysis_MMW4.TTI_Trace_analysis    WITH NAME    TTI_Trace
Library     taf.transport.ssh      WITH NAME    ssh
Library     taf.sbts.oam.coam.admin       WITH NAME    coam
Library     taf.hw.rf_attenuator    WITH NAME    att


*** Variables ***
@{allowed_list}               ${4655}    ${61524}    ${4654}    ${61649}    ${4681}    ${61652}     ${7300}    ${7319}    ${4592}    ${6327}
${gNB_ip}                     ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${gNB_username}               ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gNB_password}               ${tl.gnbs[0].cu.oam_http_connection_details.password}
${BTS_ID}                     ${tl.gnbs[0].instance_id}
${ul_power_port_list}         ${tl.ues[0].iperf_details.ports[0:3]}
${dl_power_port_list}         ${tl.ues[0].iperf_details.ports[3:6]}
${gnb_ssh_username}           ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${gnb_ssh_password}           ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
@{cell_list_8CC}              122912789    122912790    122912791    122912792    122912793    122912794    122912795    122912796
@{cell_list_UE0}              122912809    122912810    122912811    122912812    122912813    122912814    122912815    122912816
@{RU_Id_list}                 ${3}    ${4}    ${5}
${ENB_0_ip}                   ${tl.ues[2].airscale.common_units[0].lmp_connection.addr}
${ENB_1_ip}                   ${tl.ues[3].airscale.common_units[0].lmp_connection.addr}
${ENB_2_ip}                   ${tl.ues[4].airscale.common_units[0].lmp_connection.addr}
@{RU_unlock_status}           Unlocked    enabled    Active    configured
@{RU_lock_status}             Locked    enabled    Idle    configured
@{empty_list}
${153_GNB_1P}                 10.71.215.230
@{RU_Id_list_153}             ${1}    ${2}
${BTS_ID_153}                 153




*** Keywords ***
########### setup and teardown KW #################
CB009467 Suite Setup
    CI_interface.Common Suite Setup
    robot_common_operations.Common Suite Setup
    Adapt to ute cloud commission scf
    Setup Commission SCF
    Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}
#    Lock or Unlock RU And Check Status    lock_RU_id_list=${RU_Id_list_153[0:2]}    lock_flag=${True}
#    ...    bts_host=${153_GNB_1P}    BTS_ID=${BTS_ID_153}


Case Teardown
    robot_common_operations.Common case Teardown
    CI_interface.Common Case Teardown
    Run keyword and ignore error    Lock or Unlock RU And Check Status
    ...    lock_RU_id_list=${RU_Id_list[0:3]}    lock_flag=${false}

Case setup
    Set default SCF
    Setup Commission SCF
    Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}

CB009467 Suite Teardown
    robot_common_operations.Common Suite Teardown
    Setup Commission SCF
    Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}
#    Run keyword and ignore error    Lock or Unlock RU And Check Status
#    ...    unlock_RU_id_list=${RU_Id_list_153[0:2]}    lock_flag=${false}
#    ...    bts_host=${153_GNB_1P}    BTS_ID=${BTS_ID_153}

########### check bts on air #################
Adapt to ute cloud commission scf
    ${TL_NAME}   set variable if      '${testline_name}' == '${EMPTY}'    ${CONFIGURATION}    ${testline_name}
    ${pattern}   Set Variable    7_5(.*)
    ${TLNAME}    Get Regexp Matches     ${TL_NAME}    ${pattern}    1
    ${TLNAME}   Set Variable    7_5${TLNAME}[0]
    Set Suite Variable    ${CURDIR_path}    ${CURDIR}/../../../../../../commissionings/HGZ/${TLNAME}/

Set default SCF
    [Arguments]    ${bts_host}=${gNB_ip}   ${connection}=GNB_OAM
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
    COAM Commission with scf file    scf_file_path=${default_scf_path}     timeout=10min    connection=${connection}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Check GNB on air
    [Timeout]    30 min
    [Arguments]  ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM
    Wait Until Keyword Succeeds    20min    20s
    ...    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    Wait Until Keyword Succeeds    30min    20s    COAM Check GNB cell on air    connection=${connection}
    Wait Until Keyword Succeeds    30min    20s    Verify all cells should be onair    connection=${connection}
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

Save Snapshot
    [Arguments]    ${connection}=cOAM    ${timeout}=10min
    log to console    Save Snapshot...
    run keyword and ignore error     coam.teardown    connection=${connection}
    Connect to gnb coam via ssl    bts_host=${gNB_ip}    username=${gNB_username}    password=${gNB_password}
    ...    connection=${connection}
    ${snapshot_path}    coam.Get Snapshot From BTS    alias=${connection}    timeout=${timeout}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}
    [Return]    ${snapshot_path}


Lock or UnLock Multiple RU
    [Arguments]    ${RMOD_id_list}   ${lock_flag}=${True}    ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM    ${timeout}=60    ${BTS_ID}=${BTS_ID}
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

########### about Samsung UE #################
attach single power ue
    [Arguments]    ${ue_index}    ${attach_mode}=5G_NSA    ${ui_version}=S22UI4.1
    log to console       Prepare UE
    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=samsung    ui_version=S22UI4.1
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=samsung    log_type=Aasyslog    attach_mode=${attach_mode}
    power_ue.Verify attach    ue_type=samsung   5Grach_ed=${5Grach_ed_0}    4G_check=False


Single UE start traffic ul and dl
    [Arguments]    ${ue_index}    ${ul_throughput}=${None}    ${dl_throughput}=${None}    ${ul_duration}=6000    ${dl_duration}=6000
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
    [Arguments]    ${ue_index}
    log to console      UE-${ue_index} Detach    console=yes
    power_ue.UE Detach    ue_index=${ue_index}    ue_type=samsung

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
    [Arguments]    ${DL_port}    ${traffic}    ${ue_index}=${2}    ${time}=6000   ${interval}=${1}    ${process_num}=${1}    ${buffer_size}=1400B
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

stop multi power ue traffic ul and dl
    [Arguments]    ${ue_index}    ${protocol}=udp    ${if_ul}=${True}    ${if_dl}=${True}
    log to console     Stop traffic    console=yes
        run keyword if    ${if_ul}    power_ue.Stop traffic    direction=ul    ue_index=${ue_index}
        ...    ue_type=samsung
        ...    protocol=${protocol}    iperf_port=${ul_power_port_list}[${ue_index}]
        run keyword if    ${if_dl}    power_ue.Stop traffic    direction=dl    ue_index=${ue_index}
        ...    ue_type=samsung
        ...   protocol=${protocol}    iperf_port=${dl_power_port_list}[${ue_index}]



########### Case Step #################
ATTACH SAM 2UE3RU AND CHECK THROUGHT
    ATTACH SAM 1UE1RU AND CHECK THROUGHT     ue_index=${1}    ul_throughput=150    dl_throughput=500
    ...    cells=${cell_list_8CC[0:8]}     value=${3}    ENB_index=3    bts_host=${ENB_1_ip}
    Lock or Unlock RU And Check Status    lock_RU_id_list=${RU_Id_list[2:3]}    lock_flag=${True}
    ATTACH SAM 1UE1RU AND CHECK THROUGHT    ue_index=${0}    ul_throughput=${150}
    ...    dl_throughput=${500}    cells=${cell_list_UE0[0:4]}      value=${1}    ENB_index=2
    ...    bts_host=${ENB_0_ip}    LNCEL_id=${1}    ui_version=S21UI3.1
    Lock or Unlock RU And Check Status    unlock_RU_id_list=${RU_Id_list[2:3]}    lock_flag=${false}
    Lock or Unlock RU And Check Status    lock_RU_id_list=${RU_Id_list[1:2]}    lock_flag=${True}
    Sleep    200
    ATTACH SAM 1UE1RU AND CHECK THROUGHT    ue_index=${0}    ul_throughput=${150}
    ...    dl_throughput=${500}    cells=${cell_list_UE0[4:8]}      value=${2}    ENB_index=2
    ...   bts_host=${ENB_0_ip}    LNCEL_id=${1}    ui_version=S21UI3.1
    Lock or Unlock RU And Check Status    unlock_RU_id_list=${RU_Id_list[1:2]}    lock_flag=${false}

ATTACH SAM 1UE1RU AND CHECK THROUGHT
    [Arguments]    ${ue_index}    ${ul_throughput}    ${dl_throughput}    ${cells}    ${target_avg_percent}=0.30
    ...    ${ENB_index}=${2}    ${value}=${2}   ${bts_host}=${ENB_0_ip}    ${ui_version}=S22UI4.1    ${LNCEL_id}=${2}
    Adjust Enb    ENB_index=${ENB_index}   bts_host=${bts_host}    value=${value}    LNCEL_id=${LNCEL_id}
    attach single power ue     ue_index=${ue_index}    ui_version=${ui_version}
    Single UE start traffic ul and dl    ue_index=${ue_index}     ul_throughput=${ul_throughput}M     dl_throughput=${dl_throughput}M
    Check Throught From Asslog    ul_list=${cells}    dl_list=${cells}     ul_tp=${ul_throughput}    dl_tp=${dl_throughput}
    ...    target_avg_percent=${target_avg_percent}
    stop multi power ue traffic ul and dl    ue_index=${ue_index}
    [Teardown]    detach multi power ue    ue_index=${ue_index}

Adjust Enb
    [Arguments]    ${ENB_index}=${2}    ${ENB_id}=0     ${value}=${2}
    ...    ${parameter}=defaultLnRelGnbCellId    ${bts_host}=${ENB_0_ip}    ${LNCEL_id}=${1}
    CB009467_common_keyword.Connect to eNB    bts_host=${bts_host}
    ${dist_name}    Set variable    MRBTS-${tl.ues[${ENB_index}].global_bts_id}/LNBTS-${tl.ues[${ENB_index}].global_bts_id}/LNCEL-${LNCEL_id}
    Modify the parameter on enblte    dist_name=${dist_name}     parameter_name=${parameter}    value=${value}
    [Teardown]    Run keyword and ignore error    enblte.teardown    connection=enblte


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
