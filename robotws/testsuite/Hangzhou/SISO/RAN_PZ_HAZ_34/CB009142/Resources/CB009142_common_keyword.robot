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
Library     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG4/TTI_Trace_Analysis_MMW4.py
Library     TTI_Trace_Analysis_MMW4.TTI_Trace_analysis    WITH NAME    TTI_Trace
Library     taf.transport.ssh      WITH NAME    ssh
Library     taf.sbts.oam.coam.admin       WITH NAME    coam
Library     taf.hw.rf_attenuator    WITH NAME    att
Library     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001937_OTA/resources/samsung_sigspark.py
Library     samsung_sigspark.SigSpark    WITH NAME    samsung_spark





*** Variables ***
${gNB_ip}                     ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${gNB_username}               ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gNB_password}               ${tl.gnbs[0].cu.oam_http_connection_details.password}
${gnb_ssh_username}           ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${gnb_ssh_password}           ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${ul_power_port_list}         ${tl.ues[3].iperf_details.ports[0:4]}
${dl_power_port_list}         ${tl.ues[3].iperf_details.ports[4:8]}
${control_pc}                 ${tl.ues[3].ssh_connection_details.addr}
${control_pc_name}            ${tl.ues[3].ssh_connection_details.username}
${control_pc_pass}            ${tl.ues[3].ssh_connection_details.password}
${UTE_ADDRESS}                ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}               ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}               ${tl.test_pc.default_ssh_connection_details.password}
${iperf_addr}                 ${tl.ues[3].iperf_details.ssh_connection_details.addr}
${GNB_PDU_IP}                 ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${GNB_PDU_PORT}               ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}
${att_ipaddr}                 ${tl.attenuator[1].ip_addr}
${att_api_port}               ${tl.attenuator[1].port}
${att_connection_port}        ${tl.gnbs[0].dus[0].rus[0].attenuation_ports[0].port_no}
${BTS_ID}                     ${tl.gnbs[0].instance_id}
${NRBTS_ID}                   ${tl.gnbs[0].global_bts_id}
@{RU_id_list}                 ${1}   ${2}   ${3}   ${4}   ${5}   ${6}
@{RU_unlock_status}           Unlocked    enabled    Active    configured
@{RU_lock_status}             Locked    enabled    Idle    configured
@{Cell_unblock_status}        Unlocked    enabled    Active    configured    Unblocked
@{Cell_block_status}          Unlocked    disabled    Idle    configured    Blocked
@{allowed_list}               ${4655}    ${61524}    ${4654}    ${61649}    ${4681}    ${61652}    ${61011}    ${61618}    ${7316}    ${4592}
@{super_cell_list}            187564043    187564044    187564045    187564046    187564047    187564048    187564049
@{all_ue_type_list}           xiaomi    xiaomi    samsung    xiaomi
@{all_ue_index_list}          ${3}    ${1}    ${2}
@{physCellId_list1}           ${169}    ${170}    ${171}    ${172}    ${173}    ${174}
@{empty_list}
@{physCellId_list_ALL}           ${169}    ${170}    ${161}    ${172}    ${173}
@{super_cell_list1}            184754    184755    184757    184758
${model}                     ${tl.attenuator[1].model}

*** Keywords ***
########### setup and teardown KW #################
CB009142 Suite Setup
    CI_interface.Common Suite Setup
    robot_common_operations.Common Suite Setup
    Adapt to ute cloud commission scf
    Get all xiaomi12 pointer variable
    Set default SCF SBTS00
    Setup Commission SCF SBTS00
    Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}

CB009142 Suite Teardown
    robot_common_operations.Common Suite Teardown
    Set default SCF SBTS00
    Setup Commission SCF SBTS00

Case Teardown1
#    UE detach by Spark    ue_index_list=${all_ue_index_list}
    Run Keyword if    "${TEST_STATUS}"=="FAIL"    Save Snapshot
    robot_common_operations.Common case Teardown
    CI_interface.Common Case Teardown


Case setup
    ${port_list}    create list     ${0}    ${1}    ${2}    ${3}
    ${value_list}    create list    ${0}    ${0}    ${0}    ${0}
    Adjust the HBTE attenuation value    value_list=${value_list}    port_list=${port_list}
    robot_common_operations.Common case Setup    allowed_faults_ids=7316
#    Set default SCF SBTS00
#    Setup Commission SCF SBTS00
#    Check GNB on air
#    Check Alarm List on BTS    allowed_list=${allowed_list}

########### check bts on air #################
Adapt to ute cloud commission scf
    ${TL_NAME}   set variable if      '${testline_name}' == '${EMPTY}'    ${CONFIGURATION}    ${testline_name}
    ${pattern}   Set Variable    7_5(.*)
    ${TLNAME_1}    Get Regexp Matches     ${TL_NAME}    ${pattern}    1
    ${TLNAME_FINAL}   Set Variable    7_5${TLNAME_1}[0]
    Set Suite Variable    ${CURDIR_path}    ${CURDIR}/../../../../../../commissionings/HGZ/${TLNAME_FINAL}/

Set default SCF
    [Arguments]    ${flag}    ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM    ${feature}=9142
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${version}    coam.get_sw_version    connection=${connection}
    ${version_list}    split string    ${version}    separator=_
#    ${version_scf}    run keyword if    '${version_list[2]}'=='9999'    Set Variable    SBTS00
#    ...    ELSE IF    '${version_list[0]}'=='SBTS23R4'    Set Variable    SBTS23R4
#    ...    ELSE   Set Variable    SBTS24R1
    ${version_scf}    run keyword if    '${version_list[2]}'=='9999'    Set Variable    SBTS00
    ...    ELSE   Set Variable    ${version_list[0]}
    ${default_scf_path}    set variable    ${CURDIR_path}/SCF_${version_scf}_${feature}_${flag}.xml
    set suite variable    ${default_scf_path}
    log to console   ${default_scf_path}
    [Teardown]     Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Setup Commission SCF
    [Arguments]  ${flag}    ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM    ${feature}=9142
    Set default SCF    bts_host=${bts_host}    flag=${flag}    feature=${feature}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    COAM Commission with scf file    scf_file_path=${default_scf_path}    connection=${connection}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Set default SCF SBTS00
    [Arguments]    ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${version}    coam.get_sw_version    connection=${connection}
    ${version_list}    split string    ${version}    separator=_
#    ${version_scf}    run keyword if    '${version_list[2]}'=='9999'    Set Variable    SBTS00
#    ...    ELSE IF    '${version_list[0]}'=='SBTS23R4'    Set Variable    SBTS23R4
#    ...    ELSE   Set Variable    SBTS24R1
    ${version_scf}    run keyword if    '${version_list[2]}'=='9999'    Set Variable    SBTS00
    ...    ELSE   Set Variable    ${version_list[0]}
    ${default_scf_path}    set variable    ${CURDIR_path}/SCF_${version_scf}.xml
    set suite variable    ${default_scf_path}
    log to console   ${default_scf_path}
    [Teardown]     Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

Setup Commission SCF SBTS00
    [Arguments]    ${bts_host}=${gNB_ip}    ${connection}=GNB_OAM
    Set default SCF SBTS00    bts_host=${bts_host}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    COAM Commission with scf file    scf_file_path=${default_scf_path}    connection=${connection}
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

########### Logic Code #################
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
Lock or UnLock Multiple RU
    [Arguments]    ${RMOD_id_list}   ${lock_flag}=${True}    ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM    ${timeout}=60
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

Block or UnBlock Single Cell
    [Arguments]  ${cell_id}    ${block_flag}=${True}    ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM    ${timeout}=60
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${dist_name}    Set Variable    MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    Run keyword if    ${block_flag}==${True}    Log To Console    Block Cell-${cell_id}
    ...    ELSE    Log To Console    UnBlock Cell-${cell_id}
    Run keyword if    ${block_flag}==${True}    coam.block_cell    dist_name=${dist_name}    timeout=${timeout}    connection=${connection}
    ...    ELSE    coam.unblock_cell    dist_name=${dist_name}    timeout=${timeout}    connection=${connection}
    sleep    5s
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
Prepare UE and Attach UE by spark
    [Arguments]  ${ue_index}
    samsung_spark.require_ue    ue_alias=UE_${ue_index}    index=${ue_index}    reset_sol=${None}
    ${5Grach_ed}    samsung_spark.attach_ue    ue_alias=UE_${ue_index}   attach_mode=5G_NSA     power_reset=False    timeout=90000
    log to console    UE_${ue_index}
    log to console    ${5Grach_ed}
    [Return]  ${5Grach_ed}

UE attach by Spark
    [Arguments]  ${ue_index_list}    ${ue_type}=huawei_sigspark
    FOR  ${ue_index}  IN  @{ue_index_list}
        ${5Grach_ed}    wait until keyword succeeds    4X    2min    Prepare UE and Attach UE by spark    ue_index=${ue_index}
        power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    ue_index=${ue_index}    4G_check=False
        Log To Console    Attach UE_${ue_index} success
    END

UE detach by Spark
    [Arguments]  ${ue_index_list}
    FOR    ${ue_index}    IN    @{ue_index_list}
        Run Keyword And Ignore error    samsung_spark.detach_ue    ue_alias=UE_${ue_index}
    END

attach single power ue
    [Arguments]    ${ue_index}
    log to console       Prepare UE
    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=samsung    ui_version=S21UI3.1
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=samsung    log_type=Aasyslog
    power_ue.Verify attach    ue_type=samsung   5Grach_ed=${5Grach_ed_0}    4G_check=False

Single UE start traffic ul and dl
    [Arguments]    ${ue_index}    ${ul_throughput}=${None}    ${dl_throughput}=${None}    ${ul_duration}=6000    ${dl_duration}=6000
    ...    ${protocol}=udp    ${if_ul}=${True}    ${if_dl}=${True}
    log to console      UE-${ue_index} Start traffic    console=yes
    run keyword and continue on failure    run keyword if     ${if_ul}    power_ue.Start traffic    ue_index=${ue_index}    direction=ul
    ...    throughput=${ul_throughput}    duration=${ul_duration}    ue_type=samsung    iperf_type=via_command    protocol=${protocol}
    ...    iperf_port=${ul_power_port_list}[${ue_index}]
    sleep    1s
    run keyword and continue on failure    run keyword if    ${if_dl}    Samsung UE Start DL traffic    DL_port=${dl_power_port_list}[${ue_index}]
    ...    traffic=${dl_throughput}    ue_index=${ue_index}    time=${dl_duration}

detach multi power ue
    [Arguments]    ${ue_index}
    log to console      UE-${ue_index} Detach    console=yes
    power_ue.UE Detach    ue_index=${ue_index}    ue_type=samsung

Check Throught From Asslog
    [Arguments]  ${ul_list}    ${dl_list}      ${ul_tp}=${100}    ${dl_tp}=${1500}    ${if_ul}=${True}    ${if_dl}=${True}
    ...    ${target_avg_percent}=0.95    ${ue_type}=samsung   ${log_time}=60s
    ${log_path}    power_ue.Collect Tput   ue_type=${ue_type}    duration=${log_time}    ignore_time=10s
    run keyword and continue on failure    run keyword if    ${if_ul}==${True}    power_ue.Check Tput    ue_type=${ue_type}
    ...    direction=UL    log=${log_path}    cells=${ul_list}    target_throughput=${ul_tp}    target_avg_percent=${0}
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

Single UE start traffic ul and dl 9487
    [Arguments]    ${ue_index}    ${ul_throughput}=${None}    ${dl_throughput}=${None}    ${ul_duration}=6000    ${dl_duration}=6000
    ...    ${protocol}=udp    ${if_ul}=${True}    ${if_dl}=${True}
    log to console      UE-${ue_index} Start traffic    console=yes
    run keyword and continue on failure    run keyword if     ${if_ul}    power_ue.Start traffic    ue_index=${ue_index}    direction=ul
    ...    throughput=${ul_throughput}    duration=${ul_duration}    ue_type=samsung    iperf_type=via_command    protocol=${protocol}
    ...    iperf_port=${ul_power_port_list}[${ue_index}]
    sleep    1s
    run keyword and continue on failure    run keyword if    ${if_dl}    Samsung UE Start DL traffic 9487
    ...    DL_port=${dl_power_port_list}[${ue_index}]
    ...    traffic=${dl_throughput}    ue_index=${ue_index}    time=${dl_duration}

Samsung UE Start DL traffic 9487
    [Arguments]    ${DL_port}    ${traffic}    ${ue_index}=${2}    ${time}=6000   ${interval}=${1}    ${process_num}=${1}    ${buffer_size}=1400B
    ...    ${connection}=cygwin
    ssh.connect to    hostname=${control_pc}    username=${control_pc_name}    password=${control_pc_pass}    alias=${connection}
    ${serial_number}    set variable    ${tl.ues[${ue_index}].serial_number}
    ssh.send_command    command=adb -s ${serial_number} shell ip -f inet addr |grep inet |grep -v ims00 | cut -d '/' -f 1 |awk '{print $2}'
    ...    connection=${connection}
    ${UE_IP_info}    ssh.read_output    connection=${connection}
    ${UE_IP}    Get_UE_Right_IP_9487_f    cmd_info=${UE_IP_info}
    wait until keyword succeeds    1 min    10 sec    Connect to EPC APP    ue_index=${ue_index}
    sleep  2s
    ssh.execute    command=ps -ef|grep iperf|grep -v grep|grep ${DL_port}| awk '{print $2}' |xargs kill -9    connection=EPCAPP
    ssh.send_command
    ...    command=iperf -c ${UE_IP} -u -t ${time} -i ${interval} -p ${DL_port} -P ${process_num} -f m -b ${traffic} -l ${buffer_size} -T 64&
    ...    connection=EPCAPP
    ssh.disconnect    connection=EPCAPP
    [Teardown]  ssh.disconnect    connection=${connection}

########### about Xiaomi UE #################
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

Xiaomi12 Attach UE
    [Arguments]  ${ue_index}     ${serial_number}    ${connection}=cygwin
    ${status}    Xiaomi12 Verify Airplane Status    serial_number=${serial_number}    connection=${connection}
    Run Keyword If    ${status}    unlock the screen and click airplane    ue_index=${ue_index}   serial_number=${serial_number}
    ...    connection=${connection}
    Run Keyword If    ${status}==${False}    Xiaomi12 click airplane tiwce    ue_index=${ue_index}   serial_number=${serial_number}
    ...    connection=${connection}

Xiaomi12 Attach And Verify attach
    [Arguments]  ${ue_index}     ${hostname}=${control_pc}    ${username}=${control_pc_name}    ${password}=${control_pc_pass}
    ...    ${connection}=cygwin
    ssh.Connect to    hostname=${hostname}    username=${username}    password=${password}    alias=${connection}
    Xiaomi12 Attach UE    ue_index=${ue_index}     serial_number=${tl.ues[${ue_index}].serial_number}    connection=${connection}
    [Teardown]  Run Keyword And Ignore Error    ssh.Disconnect    connection=${connection}

Xiaomi12 UE Detach
    [Arguments]  ${ue_index_list}    ${connection}=cygwin
    ssh.Connect to    hostname=${control_pc}    username=${control_pc_name}    password=${control_pc_pass}    alias=${connection}
    FOR    ${ue_index}    IN    @{ue_index_list}
        unlock the screen and click airplane    ue_index=${ue_index}   serial_number=${tl.ues[${ue_index}].serial_number}  connection=${connection}
    END
    [Teardown]  Run Keyword And Ignore Error    ssh.Disconnect    connection=${connection}

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

Xiaomi start power ue traffic ul and dl
    [Arguments]     ${ue_index}    ${hostname}=${control_pc}    ${username}=${control_pc_name}    ${password}=${control_pc_pass}
    ...    ${ul_throughput}=${None}    ${dl_throughput}=${None}    ${ul_duration}=6000    ${dl_duration}=6000    ${protocol}=udp
    ssh.Connect to    hostname=${hostname}    username=${username}    password=${password}    alias=cygwin
    Log To Console   \n
    log to console      .....UE_${ue_index} udp ul iperf start....
    ${serial_number}    Set Variable    ${tl.ues[${ue_index}].serial_number}
    ${ul_command}=    Catenate
    ...    adb -s ${serial_number} shell /data/local/tmp/iperf -c ${iperf_addr} -u -p ${ul_power_port_list}[${ue_index}]
    ...    -t ${ul_duration} -P 1 -i 1 -f m -b ${ul_throughput} -l 1024B -T 64 -w 2M
    run keyword and continue on failure    ssh.send_command    command=${ul_command}    connection=cygwin
    ssh.Disconnect    connection=cygwin
    sleep    1s
    run keyword and continue on failure     power_ue.Start traffic    ue_index=${ue_index}    direction=dl    throughput=${dl_throughput}
    ...    duration=${dl_duration}    ue_type=xiaomi    protocol=${protocol}    iperf_port=${dl_power_port_list}[${ue_index}]

stop multi power ue traffic ul and dl
    [Arguments]    ${ue_index_list}    ${ue_type_list}=${all_ue_type_list}    ${protocol}=udp    ${if_ul}=${True}    ${if_dl}=${True}
    log to console     Stop traffic    console=yes
    FOR    ${item}    IN    @{ue_index_list}
        run keyword if    ${if_ul}    power_ue.Stop traffic    direction=ul    ue_index=${item}    ue_type=${ue_type_list[${item}]}
        ...    protocol=${protocol}    iperf_port=${ul_power_port_list}[${item}]
        run keyword if    ${if_dl}    power_ue.Stop traffic    direction=dl    ue_index=${item}    ue_type=${ue_type_list[${item}]}
        ...   protocol=${protocol}    iperf_port=${dl_power_port_list}[${item}]
    END

Xiaomi Start Traffic and Check TP
    [Arguments]    ${ue_index}    ${ul_throughput}    ${dl_throughput}    ${cells}    ${target_avg_percent}=0.95
    @{ue_index_list}    create list    ${ue_index}
    UE attach by Spark    ue_index_list=${ue_index_list}
    Xiaomi start power ue traffic ul and dl    ue_index=${ue_index}    ul_throughput=${ul_throughput}M    dl_throughput=${dl_throughput}M
    sleep   10s
    Check Throught From Asslog    ul_list=${cells}    dl_list=${cells}     ul_tp=${ul_throughput}    dl_tp=${dl_throughput}
    ...    target_avg_percent=${target_avg_percent}
    stop multi power ue traffic ul and dl    ue_index_list=${ue_index_list}
    [Teardown]  UE detach by Spark    ue_index_list=${ue_index_list}


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
Rest Login DU
    [Arguments]    ${ip_address}=${gNB_ip}    ${username}=${gNB_username}
    ...    ${password}=${gNB_password}   ${alias}=default
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
    [Teardown]    coam.teardown     connection=${conn}


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

Delete Nrcells Data
    [Arguments]  ${object_num}    ${start_id}
    Log To Console    delete nrcell
    FOR   ${item}    IN RANGE    ${object_num}
        ${cell_id}    Evaluate    ${item} + ${start_id}
        ${node_index}    Evaluate    ${8} - ${item}
        selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-${cell_id}
        selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}
        selenium_coam.remove_element   dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
        ...    filter_param=Reference to cell group    node_index=${node_index}    abbr=refNrCellGroup
#        ${node_index}    Evaluate    ${node_index} - ${1}
    END

Set Channelgroup Parameter
    [Arguments]  ${group_id}    ${ru_id}    ${cell_id}=${1}
    Log To Console    set channelgrp parameter
    @{antl_value_list}    create list    ${1}    ${1}    ${2}    ${2}    ${3}    ${3}    ${4}    ${4}
    FOR    ${item}    IN RANGE    ${8}
        ${CHANNEL_id}    Evaluate    ${item} + 1
        ${antlDN_value}    set variable    MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${ru_id}/ANTL-${antl_value_list}[${item}]
        selenium_coam.set_parameter_value
        ...    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-${group_id}/CHANNEL-${CHANNEL_id}
        ...    filter_param=Distinguished Name of antenna line   new_value=${antlDN_value}    abbr=antlDN
    END

Add Channelgroup Object
    [Arguments]  ${object_num}    ${start_id}    ${LCELNR}=LCELNR-11    ${cell_id}=${1}
    Log To Console    add channelgroup
    FOR    ${item}    IN RANGE     ${object_num}
        ${id}    Evaluate    ${item} + ${start_id}
        selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/${LCELNR}    object_class_name=CHANNELGROUP
        ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/${LCELNR}/CHANNELGROUP-11
        ...    include_subobject=${TRUE}    id_value=${id}
        Set Channelgroup Parameter    group_id=${id}    ru_id=${id}    cell_id=${cell_id}
    END

Add Cell Object
    [Arguments]  ${physCellId_list}    ${add_object_cell_num}    ${start_cell_id}    ${LCELNR}=LCELNR-11
    Log To Console    add super cell
    ${end_cell_id}    evaluate    ${add_object_cell_num} + ${start_cell_id}
    ${total_cell_num}    evaluate    ${add_object_cell_num} + 1
    ${change_time}     evaluate    int(${6}/${total_cell_num})
    ${start_ru_id}    evaluate    ${change_time} + 11
    FOR    ${item}    IN RANGE    ${add_object_cell_num}
        ${cell_id}    Evaluate    ${item} + ${start_cell_id}
        ${NRCELLGRP_id}    Evaluate    ${cell_id} - 0
        ${node_index}    Evaluate    ${NRCELLGRP_id}-11+3
        selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}   object_class_name=NRCELL
        ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-11
        ...    include_subobject=${TRUE}    id_value=${cell_id}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ...    filter_param=Local cell resource ID   new_value=${cell_id}    abbr=lcrId
        selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ...    filter_param=Physical cell identifier   new_value=${physCellId_list[${item}]}    abbr=physCellId
        selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}   object_class_name=NRCELLGRP
        ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-11
        ...    include_subobject=${TRUE}    id_value=${NRCELLGRP_id}
       selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-${NRCELLGRP_id}
       ...    filter_param=List of NR cells assigned to cell group   node_index=${0}    new_value=${cell_id}    abbr=nrCellList
       selenium_coam.add_element    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
       ...    filter_param=Reference to cell group    abbr=refNrCellGroup
       selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
       ...    filter_param=Reference to cell group    new_value=${NRCELLGRP_id}    node_index=${node_index}    abbr=refNrCellGroup
    END
    #Delete Channelgroup
    FOR  ${item}  IN RANGE  ${start_ru_id}  ${17}
        selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/${LCELNR}/CHANNELGROUP-${item}
    END
    #Add Cellmapping Cell
    FOR  ${item}  IN RANGE  ${start_cell_id}  ${end_cell_id}
        selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1   object_class_name=LCELNR
        ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1
        ...    include_subobject=${TRUE}    id_value=${item}
        Set Channelgroup Parameter Mutil Times    times=${change_time}    ru_id=${start_ru_id}    cell_id=${item}
        ${start_ru_id}    evaluate    ${start_ru_id} + ${change_time}
    END

Set Channelgroup Parameter Mutil Times
    [Arguments]  ${times}    ${ru_id}    ${cell_id}
    ${group_id}    set variable    ${0}
    FOR    ${item}    IN RANGE    ${times}
        ${group_id}    Evaluate    ${group_id} + 1
        Set Channelgroup Parameter    group_id=${group_id}    ru_id=${ru_id}    cell_id=${cell_id}
        ${ru_id}    Evaluate    ${ru_id} + 1
    END

########### Case Step #################
Lock or Unlock RU And Check Status
    [Arguments]  ${lock_RU_id_list}=${empty_list}     ${unlock_RU_id_list}=${empty_list}    ${lock_flag}=${True}    ${bts_host}=${gnb_ip}
    ${operate_ru_id_list}    Set Variable If    ${lock_flag}    ${lock_RU_id_list}    ${unlock_RU_id_list}
    Lock or UnLock Multiple RU    RMOD_id_list=${operate_ru_id_list}    lock_flag=${lock_flag}    bts_host=${bts_host}
    Check Alarm List on BTS    allowed_list=${allowed_list}    bts_host=${bts_host}
    ${expect_item_status_dict}    create dictionary
    FOR  ${item}  IN    @{lock_RU_id_list}
        Set to dictionary    ${expect_item_status_dict}    RMOD-${item}=${RU_lock_status}
    END
    FOR  ${item1}  IN   @{unlock_RU_id_list}
        Set to dictionary    ${expect_item_status_dict}    RMOD-${item1}=${RU_unlock_status}
    END
    Check All RU or Cell Status    expect_item_status_dict=${expect_item_status_dict}    if_ru=${True}    bts_host=${bts_host}
#    Check GNB on air

BLock or UnBlock Cell And Check Status
    [Arguments]    ${block_cell_id}=None    ${unblock_cell_id}=None    ${block_flag}=${True}    ${bts_host}=${gnb_ip}
    @{allowed_cell_block_list}    create list    @{allowed_list}    ${49}
    @{not_allowed_list}    create list   ${49}
    ${operate_cell_id}    Set Variable If    ${block_flag}    ${block_cell_id}    ${unblock_cell_id}
    Block or UnBlock Single Cell    cell_id=${operate_cell_id}    block_flag=${block_flag}    bts_host=${bts_host}
    run keyword if  ${block_flag}    Check Alarm List on BTS    allowed_list=${allowed_cell_block_list}    bts_host=${bts_host}
    ...    ELSE    Check Alarm List on BTS    allowed_list=${allowed_list}    not_allowed_list=${not_allowed_list}    bts_host=${bts_host}
    ${expect_item_status_dict}    create dictionary
    run keyword if    ${block_cell_id} != None    Set to dictionary    ${expect_item_status_dict}    NRCELL-${block_cell_id}=${Cell_block_status}
    run keyword if    ${unblock_cell_id} != None    Set to dictionary    ${expect_item_status_dict}
    ...    NRCELL-${unblock_cell_id}=${Cell_unblock_status}
    Check All RU or Cell Status     expect_item_status_dict=${expect_item_status_dict}    if_ru=${False}   bts_host=${bts_host}

Configure 2+2+2 Three UE Start Traffic
    [Arguments]
    UE attach by Spark    ue_index_list=${all_ue_index_list[0:1]}
    Xiaomi start power ue traffic ul and dl    ue_index=${3}    ul_throughput=50M     dl_throughput=400M
#    Xiaomi start power ue traffic ul and dl    ue_index=${1}    ul_throughput=200M    dl_throughput=1500M
#    Single UE start traffic ul and dl    ue_index=${2}    ul_throughput=100M    dl_throughput=1500M
    Run Keyword And Continue On Failure    Check Throught From Asslog    ul_list=${super_cell_list[2:3]}   dl_list=${super_cell_list[2:3]}
    ...     ul_tp=${30}    dl_tp=${400}    target_avg_percent=0.2
#   Run Keyword And Continue On Failure    Check Throught From Asslog    ul_list=${super_cell_list[1:2]}    dl_list=${super_cell_list[1:2]}
#    ...     ul_tp=${200}    dl_tp=${1500}    target_avg_percent=0.9
#    Run Keyword And Continue On Failure    Check Throught From Asslog    ul_list=${super_cell_list[0:1]}    dl_list=${super_cell_list[0:1]}
#    ...     ul_tp=${100}    dl_tp=${1500}    target_avg_percent=0.9
    stop multi power ue traffic ul and dl    ue_index_list=${all_ue_index_list[0:1]}    ue_type_list=${all_ue_type_list[0:4]}
    [Teardown]    UE detach by Spark    ue_index_list=${all_ue_index_list}

Samsung UE Start Traffic and Check TP
    [Arguments]
    UE attach by Spark    ue_index_list=${all_ue_index_list[-1:-2:-1]}
    sleep   10s
    Single UE start traffic ul and dl     ue_index=${2}    ul_throughput=100M    dl_throughput=1500M
    Run Keyword And Continue On Failure    Check Throught From Asslog    ul_list=${super_cell_list[0:1]}    dl_list=${super_cell_list[0:1]}
    ...     ul_tp=${100}    dl_tp=${1500}    target_avg_percent=0.9
    stop multi power ue traffic ul and dl    ue_index_list=${all_ue_index_list[-1:-2:-1]}
    [Teardown]    UE detach by Spark    ue_index_list=${all_ue_index_list[-1:-2:-1]}

Power Off BTS And Wait Until On Air
#    [Arguments]   ${retry}=1000s    ${retry_interval}=10s
    Log To Console    Power Off BTS And Wait Until On Air
    pdu.Setup Pdu    model=HBTE    host=${GNB_PDU_IP}    alias=pdu_alias
    pdu.Power Off    port=${GNB_PDU_PORT}    pdu_device=pdu_alias
    ${status1}    pdu.Get Port Status    port=${GNB_PDU_PORT}    pdu_device=pdu_alias
    Should Be Equal    ${status1}    off
    Sleep    10s
    pdu.Power On    port=${GNB_PDU_PORT}    pdu_device=pdu_alias
    ${status2}    pdu.Get Port Status    port=${GNB_PDU_PORT}    pdu_device=pdu_alias
    Should Be Equal    ${status2}    on
    Log To Console    Wait BTS On Air ....
    Check GNB on air

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


configuration normal to 1super3sub
    Log To Console    setup supercell
    WEBUI Login
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...    filter_param=Activate super cell   new_value=true    abbr=actSuperCell
    Add Channelgroup Object    object_num=${2}    start_id=${2}
    Delete Nrcells Data    object_num=${2}    start_id=${2}
    ${error}    selenium_coam.validate_plan
    Log To Console    ${error}
    Log To Console    Activate plan
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${180}
    Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}
    [Teardown]    WEBUI Logout

configuration 1super3sub to 1super6sub
    WEBUI Login
    Add Channelgroup Object    object_num=${3}    start_id=${4}
    ${error}    selenium_coam.validate_plan
    Log To Console    ${error}
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${180}
    Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}
    [Teardown]    WEBUI Logout




configuration 1super6sub to 2super2+4sub
     [Arguments]  ${physCellId_list}=${physCellId_list1[0:1]}     ${add_object_cell_num}=${1}     ${start_cell_id}=${2}
    WEBUI Login
    Add Cell Object    physCellId_list=${physCellId_list}    add_object_cell_num=${add_object_cell_num}    start_cell_id=${start_cell_id}
    Add pre Channelgroup    ru_id=${3}     CHANNEL_id=${4}    LCELNR=LCELNR-2    cell_id=${2}
    Delete Channelgroup Object   object_num=${1}    start_id=${3}
    ${error}    selenium_coam.validate_plan
    Log To Console    ${error}
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${180}
    Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}
    [Teardown]    WEBUI Logout

configuration 2super2+4sub to 3super2+2+2sub
    [Arguments]  ${physCellId_list}=${physCellId_list1[2:3]}     ${add_object_cell_num}=${1}     ${start_cell_id}=${3}
    WEBUI Login
    Add Cell Object    physCellId_list=${physCellId_list}    add_object_cell_num=${add_object_cell_num}    start_cell_id=${start_cell_id}
    Delete Channelgroup Object   object_num=${2}    start_id=${2}    LCELNR=LCELNR-2
    Set Channelgroup Parameter Mutil Times    times=${2}   ru_id=${5}    cell_id=${3}
    ${error}    selenium_coam.validate_plan
    Log To Console    ${error}
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${180}
    Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}
    [Teardown]    WEBUI Logout

configuration 1super6sub to 2super3+3sub
    [Arguments]  ${physCellId_list}=${physCellId_list1[0:1]}     ${add_object_cell_num}=${1}     ${start_cell_id}=${2}
    WEBUI Login
    Add Cell Object    physCellId_list=${physCellId_list}    add_object_cell_num=${add_object_cell_num}    start_cell_id=${start_cell_id}
    ${error}    selenium_coam.validate_plan
    Log To Console    ${error}
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${180}
    Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}
    [Teardown]    WEBUI Logout

Delete Channelgroup Object
    [Arguments]  ${object_num}    ${start_id}    ${LCELNR}=LCELNR-1
    Log To Console    Delete channelgroup
    FOR    ${item}    IN RANGE     ${object_num}
        ${id}    Evaluate    ${item} + ${start_id}
        selenium_coam.remove_object     object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/${LCELNR}/CHANNELGROUP-${id}
    END

Add pre Channelgroup
    [Arguments]  ${ru_id}     ${CHANNEL_id}    ${LCELNR}=LCELNR-1    ${cell_id}=${1}
    Log To Console    add channelgroup
    selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/${LCELNR}    object_class_name=CHANNELGROUP
    ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/${LCELNR}/CHANNELGROUP-1
    ...    include_subobject=${TRUE}    id_value=${CHANNEL_id}
    Set Channelgroup Parameter    group_id=${CHANNEL_id}   ru_id=${ru_id}    cell_id=${cell_id}


attach for Ru2356
    [Arguments]    ${RU_Num}=${4}    ${cells1}=${super_cell_list[0:1]}    ${cells2}=${super_cell_list[1:2]}    ${cells3}=${super_cell_list[2:3]}
    ...    ${super_num}=${1}
    Run Keyword If    ${super_num}==${2}    attach 2super    cells2=${cells2}    RU_Num=${RU_Num}    cells1=${cells1}
    Run Keyword If    ${super_num}==${3}    attach 3super    cells2=${cells2}    cells3=${cells3}    cells1=${cells1}    RU_Num=${RU_Num}
    Run Keyword If    ${super_num}==${0}    attach 6nom
    Run Keyword If    ${super_num}==${1}    attach 1super    cells1=${cells1}

attach 1super
    [Arguments]    ${RU_Num}=${4}    ${cells1}=${cells1}
    FOR    ${i}     IN RANGE    ${RU_Num}
        Adjust Single RU PA    port=${i}    single_ru_PA=${0}    mutil_ru_PA=${127}
        Xiaomi Start Traffic and Check TP    ue_index=${0}    ul_throughput=30    dl_throughput=400    cells=${cells1}
        ...    target_avg_percent=0.2
    END

attach 2super
    [Arguments]    ${RU_Num}=${4}   ${cells2}=${super_cell_list[1:2]}    ${cells1}=${cells1}
    attach 1super    RU_Num=${RU_Num}   cells1=${cells1}
    ${range}     Evaluate    ${4}-${RU_NUM}
    FOR    ${i}     IN RANGE    ${range}
        ${port}     Evaluate    ${i} + ${RU_NUM}
        Adjust Single RU PA    port=${port}    single_ru_PA=${0}    mutil_ru_PA=${127}
        Xiaomi Start Traffic and Check TP    ue_index=${0}    ul_throughput=30    dl_throughput=400    cells=${cells2}
        ...    target_avg_percent=0.2
    END

attach 3super
    [Arguments]    ${cells2}=${super_cell_list[1:2]}    ${cells3}=${super_cell_list[2:3]}    ${cells1}=${cells1}    ${RU_Num}=${1}
    attach 1super    RU_Num=${RU_Num}   cells1=${cells1}
    FOR    ${i}     IN RANGE    ${2}
        ${port}     Evaluate    2+${i}
        Adjust Single RU PA    port=${port}    single_ru_PA=${0}    mutil_ru_PA=${127}
        Xiaomi Start Traffic and Check TP    ue_index=${0}    ul_throughput=30    dl_throughput=400    cells=${cells3}
        ...    target_avg_percent=0.2
    END
    Adjust Single RU PA     port=${1}    single_ru_PA=${0}    mutil_ru_PA=${127}
    Xiaomi Start Traffic and Check TP    ue_index=${0}    ul_throughput=30    dl_throughput=400    cells=${cells2}
    ...    target_avg_percent=0.2

attach 6nom
    [Arguments]    ${cell_id1}=${super_cell_list[1:3]}    ${Cell_id2}=${super_cell_list[3:5]}
    FOR    ${i}     IN     @{cell_id1}
        ${port}     Evaluate    ${i}-${cell_id1}[0]+${2}
        ${cell_id}     Create list    ${i}
        Adjust Single RU PA    port=${port}    single_ru_PA=${0}    mutil_ru_PA=${127}
        Xiaomi Start Traffic and Check TP    ue_index=${0}    ul_throughput=30    dl_throughput=400    cells=${cell_id[0:1]}
        ...    target_avg_percent=0.2
    END
    FOR    ${i}     IN     @{cell_id2}
        ${port}     Evaluate    ${i}-${cell_id2}[0]
        ${cell_id}     Create list    ${i}
        Adjust Single RU PA    port=${port}    single_ru_PA=${0}    mutil_ru_PA=${127}
        Xiaomi Start Traffic and Check TP    ue_index=${0}    ul_throughput=30    dl_throughput=400    cells=${cell_id[0:1]}
        ...    target_avg_percent=0.2
    END

configuration 3super2+2+2sub to 6nom
    [Arguments]  ${physCellId_list}=${physCellId_list1[3:6]}     ${add_object_cell_num}=${3}     ${start_cell_id}=${4}
    Log To Console    setup 6Nnomcell
    WEBUI Login
    Add Cell Object    physCellId_list=${physCellId_list}    add_object_cell_num=${add_object_cell_num}    start_cell_id=${start_cell_id}
    Set Channelgroup Parameter Mutil Times    times=${1}   ru_id=${5}    cell_id=${2}
    Delete Channelgroup Object    object_num=${1}    start_id=${4}    LCELNR=LCELNR-2
    Delete Channelgroup Object    object_num=${1}    start_id=${1}    LCELNR=LCELNR-3
    FOR    ${i}     IN RANGE    ${6}
        ${cell_id}     Evaluate    1+${i}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ...    filter_param=Activate super cell   new_value=false    abbr=actSuperCell
        selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-${i}
        ...    filter_param=Number of transmitted Synchronization Signal Blocks    new_value=1 beam    abbr=numberOfTransmittedSsBlock
    END
    ${error}    selenium_coam.validate_plan
    Log To Console    ${error}
    Log To Console    Activate plan
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${180}
    Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}
    [Teardown]    WEBUI Logout

Lock or Unlock RU
    [Arguments]  ${lock_RU_id_list}=${empty_list}     ${unlock_RU_id_list}=${empty_list}    ${lock_flag}=${True}    ${bts_host}=${gnb_ip}
    ${operate_ru_id_list}    Set Variable If    ${lock_flag}    ${lock_RU_id_list}    ${unlock_RU_id_list}
    Lock or UnLock Multiple RU    RMOD_id_list=${operate_ru_id_list}    lock_flag=${lock_flag}    bts_host=${bts_host}
    Check Alarm List on BTS    allowed_list=${allowed_list}    bts_host=${bts_host}
    ${expect_item_status_dict}    create dictionary
    FOR  ${item}  IN    @{lock_RU_id_list}
        Set to dictionary    ${expect_item_status_dict}    RMOD-${item}=${RU_lock_status}
    END
    FOR  ${item1}  IN   @{unlock_RU_id_list}
        Set to dictionary    ${expect_item_status_dict}    RMOD-${item1}=${RU_unlock_status}
    END


configuration 1super6sub to 6nom
    [Arguments]  ${physCellId_list}=${physCellId_list1[1:6]}    ${add_object_cell_num}=${5}    ${start_cell_id}=${12}
    WEBUI Login
    ${CHANNELGROUP_ID_11}    Create list    12    13    14    15    16
    ${CHANNELGROUP_ID_12}    Create list    11    13    14    15    16
    ${CHANNELGROUP_ID_13}    Create list    12    11    14    15    16
    ${CHANNELGROUP_ID_14}    Create list    12    13    11    15    16
    ${CHANNELGROUP_ID_15}    Create list    12    13    14    11    16
    ${CHANNELGROUP_ID_16}    Create list    12    13    14    15    11
    FOR    ${item}    IN RANGE    ${add_object_cell_num}
        ${cell_id}    Evaluate    ${item} + ${start_cell_id}
        ${NRCELLGRP_id}    Evaluate    ${cell_id} - 0
        ${node_index}    Evaluate    ${NRCELLGRP_id}-11+3
        selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}   object_class_name=NRCELL
        ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-11
        ...    include_subobject=${TRUE}    id_value=${cell_id}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ...    filter_param=Local cell resource ID   new_value=${cell_id}    abbr=lcrId
        selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ...    filter_param=Physical cell identifier   new_value=${physCellId_list[${item}]}    abbr=physCellId
        selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}   object_class_name=NRCELLGRP
        ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-11
        ...    include_subobject=${TRUE}    id_value=${NRCELLGRP_id}
       selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-${NRCELLGRP_id}
       ...    filter_param=List of NR cells assigned to cell group   node_index=${0}    new_value=${cell_id}    abbr=nrCellList
       selenium_coam.add_element    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
       ...    filter_param=Reference to cell group    abbr=refNrCellGroup
       selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
       ...    filter_param=Reference to cell group    new_value=${NRCELLGRP_id}    node_index=${node_index}    abbr=refNrCellGroup
       selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1  object_class_name=LCELNR
       ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11
       ...    include_subobject=${TRUE}    id_value=${cell_id}
       selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
       ...    filter_param=Activate super cell   new_value=false    abbr=actSuperCell
       selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-${cell_id}
       ...    filter_param=Number of transmitted Synchronization Signal Blocks    new_value=1 beam    abbr=numberOfTransmittedSsBlock
       FOR  ${item}  IN    @{CHANNELGROUP_ID_${cell_id}}
           selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-${item}
       END
    END
    FOR  ${item}  IN    @{CHANNELGROUP_ID_11}
           selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-${item}
    END
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-11
    ...    filter_param=Activate super cell   new_value=false    abbr=actSuperCell
    ${error}    selenium_coam.validate_plan
    Log To Console    ${error}
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${180}
    Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}
    [Teardown]    WEBUI Logout

configuration 6nom to 1super6sub
    Log To Console    setup supercell
    WEBUI Login
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-11
    ...    filter_param=Activate super cell   new_value=true    abbr=actSuperCell
    ${nom_cell_list}    Create list    12    13    14    15    16
    FOR  ${item}  IN    @{nom_cell_list}
        selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11  object_class_name=CHANNELGROUP
       ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${item}/CHANNELGROUP-${item}
       ...    include_subobject=${TRUE}    id_value=${item}
    END
    Delete Nrcells Data    object_num=${5}    start_id=${12}
    ${error}    selenium_coam.validate_plan
    Log To Console    ${error}
    Log To Console    Activate plan
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${180}
    Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}
    [Teardown]    WEBUI Logout


Reset site
    [Arguments]    ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}
    ...    connection=${connection}
    coam.Reset Site    connection=${connection}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

configuration 1super6sub to 3super6sub
    [Arguments]  ${physCellId_list}    ${add_object_cell_num}    ${start_cell_id}    ${LCELNR}=LCELNR-11
    WEBUI Login
    Log To Console    add super cell
    ${CHANNELGROUP_ID_11}    Create list    13    14    15    16
    ${CHANNELGROUP_ID_12}    Create list    11    12    15    16
    ${CHANNELGROUP_ID_13}    Create list    12    13    14    11
    ${end_cell_id}    evaluate    ${add_object_cell_num} + ${start_cell_id}
    ${total_cell_num}    evaluate    ${add_object_cell_num} + 1
    ${change_time}     evaluate    int(${6}/${total_cell_num})
    ${start_ru_id}    evaluate    ${change_time} + 11
    FOR    ${item}    IN RANGE    ${add_object_cell_num}
        ${cell_id}    Evaluate    ${item} + ${start_cell_id}
        ${NRCELLGRP_id}    Evaluate    ${cell_id} - 0
        ${node_index}    Evaluate    ${NRCELLGRP_id}-11+3
        selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}   object_class_name=NRCELL
        ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-11
        ...    include_subobject=${TRUE}    id_value=${cell_id}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ...    filter_param=Local cell resource ID   new_value=${cell_id}    abbr=lcrId
        selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ...    filter_param=Physical cell identifier   new_value=${physCellId_list[${item}]}    abbr=physCellId
        selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}   object_class_name=NRCELLGRP
        ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-11
        ...    include_subobject=${TRUE}    id_value=${NRCELLGRP_id}
       selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-${NRCELLGRP_id}
       ...    filter_param=List of NR cells assigned to cell group   node_index=${0}    new_value=${cell_id}    abbr=nrCellList
       selenium_coam.add_element    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
       ...    filter_param=Reference to cell group    abbr=refNrCellGroup
       selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
       ...    filter_param=Reference to cell group    new_value=${NRCELLGRP_id}    node_index=${node_index}    abbr=refNrCellGroup
       selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1  object_class_name=LCELNR
       ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11
       ...    include_subobject=${TRUE}    id_value=${cell_id}
       FOR  ${item}  IN    @{CHANNELGROUP_ID_${cell_id}}
           selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}/CHANNELGROUP-${item}
       END
    END
    #Delete Channelgroup
    FOR  ${item}  IN    @{CHANNELGROUP_ID_11}
        selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/${LCELNR}/CHANNELGROUP-${item}
    END
    ${error}    selenium_coam.validate_plan
    Log To Console    ${error}
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${180}
    Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}
    [Teardown]    WEBUI Logout

