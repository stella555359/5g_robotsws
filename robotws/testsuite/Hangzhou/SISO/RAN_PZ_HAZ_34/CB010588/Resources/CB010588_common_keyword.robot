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
...    ${7313}    ${4476}
${gNB_ip}                     ${tl.gnbs[0].dus[0].f1_m_ip_addr}
${gNB_username}               ${tl.gnbs[0].cu.oam_http_connection_details.username}
${gNB_password}               ${tl.gnbs[0].cu.oam_http_connection_details.password}
${BTS_ID}                     ${tl.gnbs[0].instance_id}
${NRBTS_ID}                   ${tl.gnbs[0].global_bts_id}
${ul_port_list}               ${tl.ues[0].iperf_details.ports[0:2]}
${dl_port_list}               ${tl.ues[0].iperf_details.ports[2:4]}
${gnb_ssh_username}           ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${gnb_ssh_password}           ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${control_pc}                 ${tl.ues[0].ssh_connection_details.addr}
${control_pc_name}            ${tl.ues[0].ssh_connection_details.username}
${control_pc_pass}            ${tl.ues[0].ssh_connection_details.password}
@{cell_list_8CC}              596629    596630    596631    596632    596633    596634    596635    596636
@{RU_Id_list}                 ${2}    ${4}
@{RU_unlock_status}           Unlocked    enabled    Active    configured
@{RU_lock_status}             Locked    enabled    Idle    configured
@{Cell_unblock_status}        Unlocked    enabled    Active    configured    Unblocked
@{Cell_block_status}          Unlocked    disabled    Idle    configured    Blocked
@{empty_list}
@{physCellId_list}           ${85}    ${86}    ${87}    ${88}    ${89}    ${90}    ${91}    ${92}
@{nrarfcn}                   ${710000}    ${716666}
${serial_number}   ${tl.ues[0].serial_number}
@{cell_id_list_4CC}                5    7    9    11
@{cell_id_list_8cc}                5    6    7    8    9    10    11    12

*** Keywords ***
########### setup and teardown KW #################
CB0010588 Suite Setup
    CI_interface.Common Suite Setup
    Adapt to ute cloud commission scf
    Get all xiaomi12 pointer variable
    Set CONF-1 Version

Case Teardown
    Run Keyword if    "${TEST_STATUS}"=="FAIL"    Save Snapshot
    robot_common_operations.Common case Teardown
    Setup Commission SCF
    Check GNB on air
    CI_interface.Common Case Teardown

Case setup
    robot_common_operations.Common case Setup
    AlarmWatchdog.add_allow_alarms    fault_id=49
    AlarmWatchdog.add_allow_alarms    fault_id=4476
    Check Alarm List on BTS    allowed_list=${allowed_list}

CB0010588 Suite Teardown
    robot_common_operations.Common Suite Teardown
    Setup Commission SCF
    Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}

Set CONF-1 Version
    [Arguments]    ${bts_host}=${gNB_ip}   ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${version}    coam.get_sw_version    connection=${connection}
    ${version_list}    split string    ${version}    separator=_
    ${CONF-1_SCF_Version}    run keyword if    '${version_list[0]}'=='SBTS25R1' or '${version_list[0]}'=='SBTS24R3'
    ...    Set Variable    CONF-1
    ...    ELSE IF    '${version_list[2]}'=='9999'    Set Variable    CONF-1_SCF_SBTS00
	...    ELSE    Set Variable    CONF-1_SCF_${version_list[0]}
    set suite variable    ${CONF-1_SCF_Version}
    [Teardown]     Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

########### check bts on air #################
Adapt to ute cloud commission scf
    ${TL_NAME}   set variable if      '${testline_name}' == '${EMPTY}'    ${CONFIGURATION}    ${testline_name}
    ${pattern}   Set Variable    7_5(.*)
    ${TL_NAME}    Get Regexp Matches     ${TL_NAME}    ${pattern}    1
    ${TL_NAME}   Set Variable    7_5${TL_NAME}[0]
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
attach single power ue
    [Arguments]    ${ue_index}    ${attach_mode}=5G_NSA
    log to console       Prepare UE
    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=samsung    ui_version=S22UI4.1
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=samsung    log_type=Aasyslog    attach_mode=${attach_mode}
    power_ue.Verify attach    ue_type=samsung   5Grach_ed=${5Grach_ed_0}    4G_check=False

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

detach multi power ue
    [Arguments]    ${ue_index}
    log to console      UE-${ue_index} Detach    console=yes
    power_ue.UE Detach    ue_index=${ue_index}    ue_type=samsung

Check Throught From Asslog
    [Arguments]  ${ul_list}    ${dl_list}      ${ul_tp}=${500}    ${dl_tp}=${500}    ${if_ul}=${True}    ${if_dl}=${True}
    ...    ${target_avg_percent_UL}=0.90    ${ue_type}=samsung   ${log_time}=60s    ${target_avg_percent_DL}=0.90
    ${log_path}    power_ue.Collect Tput   ue_type=${ue_type}    duration=${log_time}    ignore_time=10s
    run keyword and continue on failure    run keyword if    ${if_ul}==${True}    power_ue.Check Tput    ue_type=${ue_type}
    ...    direction=UL    log=${log_path}    cells=${ul_list}    target_throughput=${ul_tp}    target_avg_percent=${target_avg_percent_UL}
    ...    actCarrierAggregation=${True}    min_percent=0
    run keyword and continue on failure    run keyword if    ${if_dl}==${True}    power_ue.Check Tput    ue_type=${ue_type}
    ...    direction=DL    log=${log_path}    cells=${dl_list}    target_throughput=${dl_tp}    target_avg_percent=${target_avg_percent_DL}
    ...    actCarrierAggregation=${True}    min_percent=0

172 IP UE Start DL traffic TCP
    [Arguments]    ${DL_port}    ${ue_index}=${2}    ${time}=6000    ${process_num}=${1}
    ...    ${connection}=cygwin
    #get ue ip
    ssh.connect to    hostname=${control_pc}    username=${control_pc_name}    password=${control_pc_pass}    alias=${connection}
    ${serial_number}    set variable    ${tl.ues[${ue_index}].serial_number}
    ssh.send_command    command=adb -s ${serial_number} shell ip -f inet addr |grep inet |grep -v ims00 | cut -d '/' -f 1 |awk '{print $2}'
    ...    connection=${connection}
    ${UE_IP_info}    ssh.read_output    connection=${connection}
    ${UE_IP}    Get_UE_Right_IP    cmd_info=${UE_IP_info}
    log to console    ue_ip_info:${UE_IP_info}
    log to console    ue_ip_info:${UE_IP}
    #ue iperf
    ssh.send_command    command=adb -s ${serial_number} root &
    ...    connection=${connection}
    ssh.send_command    command=adb -s ${serial_number} shell ps -ef |grep iperf |grep ${DL_port} |grep -v grep |awk '{print $2}'
    ...    connection=${connection}
    ssh.send_command    command=adb -s ${serial_number} shell ps -ef |grep iperf |grep ${DL_port} |grep -v grep |awk '{print $2}'
    ...    connection=${connection}
    ${pid}    wait until keyword succeeds    1 min    10 sec    ssh.read_output    connection=${connection}
    ssh.send_command    command=adb -s ${serial_number} shell kill -9 ${pid} &
    ...    connection=${connection}
    sleep  2s
    ssh.send_command    command=adb -s ${serial_number} shell ps -ef |grep iperf |grep ${DL_port} |grep -v grep |awk '{print $2}'
    ...    connection=${connection}
    ${pid}    wait until keyword succeeds    1 min    10 sec    ssh.read_output    connection=${connection}
    ssh.send_command    command=adb -s ${serial_number} shell /data/local/tmp/iperf3 -s -p ${DL_port} -i 1 &
    ...    connection=${connection}
    sleep  3s
    #send DL command
    wait until keyword succeeds    1 min    10 sec    Connect to EPC APP    ue_index=${ue_index}
    sleep  3s
    ssh.send_command   command=ps -ef|grep iperf3|grep -v grep|grep ${DL_port}| awk '{print $2}' |xargs kill -9 &    connection=EPCAPP
    sleep    3s
    ssh.send_command
    ...    command=iperf3 -c ${UE_IP} -p ${DL_port} -t ${time} -P ${process_num} -w 2M -M 1180 >/dev/null 2>/dev/null &
    ...    connection=EPCAPP
    sleep  2s
    ssh.send_command   command=ps -ef|grep iperf3    connection=EPCAPP
    ${iperf_process}    ssh.read_output    connection=EPCAPP
    log to console    iperf process: ${iperf_process}
    ssh.disconnect    connection=EPCAPP
    [Teardown]  ssh.disconnect    connection=${connection}


172 IP UE Start UL traffic TCP
    [Arguments]    ${UL_port}    ${ue_index}=${2}    ${time}=6000    ${process_num}=${1}
    ...    ${connection}=cygwin
    #get ue ip
    ssh.connect to    hostname=${control_pc}    username=${control_pc_name}    password=${control_pc_pass}    alias=${connection}
    ${serial_number}    set variable    ${tl.ues[${ue_index}].serial_number}
    ssh.send_command    command=adb -s ${serial_number} shell ip -f inet addr |grep inet |grep -v ims00 | cut -d '/' -f 1 |awk '{print $2}'
    ...    connection=${connection}
    ${UE_IP_info}    ssh.read_output    connection=${connection}
    ${UE_IP}    Get_UE_Right_IP    cmd_info=${UE_IP_info}
    log to console    ue_ip_info:${UE_IP_info}
    log to console    ue_ip_info:${UE_IP}
    #ue iperf
    ssh.send_command    command=adb -s ${serial_number} root &
    ...    connection=${connection}
    ssh.send_command    command=adb -s ${serial_number} shell ps -ef |grep iperf |grep ${UL_port} |grep -v grep |awk '{print $2}'
    ...    connection=${connection}
    ssh.send_command    command=adb -s ${serial_number} shell ps -ef |grep iperf |grep ${UL_port} |grep -v grep |awk '{print $2}'
    ...    connection=${connection}
    ${pid}    wait until keyword succeeds    1 min    10 sec    ssh.read_output    connection=${connection}
    ssh.send_command    command=adb -s ${serial_number} shell kill -9 ${pid} &
    ...    connection=${connection}
    sleep  2s
    ssh.send_command    command=adb -s ${serial_number} shell ps -ef |grep iperf |grep ${UL_port} |grep -v grep |awk '{print $2}'
    ...    connection=${connection}
    ${pid}    wait until keyword succeeds    1 min    10 sec    ssh.read_output    connection=${connection}
    ssh.send_command    command=adb -s ${serial_number} shell /data/local/tmp/iperf3 -s -p ${UL_port} -i 1 &
    ...    connection=${connection}
    sleep  3s
    #send DL command
    wait until keyword succeeds    1 min    10 sec    Connect to EPC APP    ue_index=${ue_index}
    sleep  3s
    ssh.send_command   command=ps -ef|grep iperf3|grep -v grep|grep ${UL_port}| awk '{print $2}' |xargs kill -9 &    connection=EPCAPP
    sleep    3s
    ssh.send_command
    ...    command=iperf3 -c ${UE_IP} -p ${UL_port} -t ${time} -R -w 2M -M 1280 -P ${process_num} >/dev/null 2>/dev/null &
    ...    connection=EPCAPP
    sleep    2s
    ssh.send_command   command=ps -ef|grep iperf3    connection=EPCAPP
    ${iperf_process}    ssh.read_output    connection=EPCAPP
    log to console    iperf process: ${iperf_process}
    ssh.disconnect    connection=EPCAPP
    [Teardown]  ssh.disconnect    connection=${connection}

start multi power ue traffic ul and dl
    [Arguments]    ${ue_index_list}    ${ul_duration}=6000    ${dl_duration}=6000
    ...    ${if_ul}=${True}    ${if_dl}=${True}    ${process_num}=${2}
    log to console      Start traffic    console=yes
    FOR    ${item}    IN    @{ue_index_list}
#        run keyword and continue on failure    run keyword if    ${if_ul}    power_ue.Start traffic    ue_index=${item}    direction=ul
#        ...    duration=${ul_duration}
#        ...    iperf_port=@{ul_power_port_list}[${item}]    process_num=${process_num}    iperf_type=via_command
        run keyword and continue on failure    run keyword if    ${if_Ul}    172 IP UE Start UL traffic TCP    ue_index=${item}
        ...    time=${Ul_duration}
        ...    UL_port=${Ul_power_port_list}[${item}]    process_num=${process_num}
        sleep    1s
#        run keyword and continue on failure    run keyword if    ${if_dl}    power_ue.Start traffic    ue_index=${item}    direction=dl
#        ...    duration=${dl_duration}
#        ...    iperf_port=@{dl_power_port_list}[${item}]    process_num=${process_num}
        run keyword and continue on failure    run keyword if    ${if_dl}    172 IP UE Start DL traffic TCP    ue_index=${item}
        ...    time=${dl_duration}
        ...    DL_port=${dl_power_port_list}[${item}]    process_num=${process_num}
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

#MTK90_attach_detach
Get all UE pointer variable
    [Documentation]    Pixel range of X80 mobile phones
    ...                MTK：（1110~1280）：1200
    Set Suite Variable    ${home}    3
    Set Suite Variable    ${Home_button}    3
    Set Suite Variable    ${swipe}    500 2050 500 800
    Set Suite Variable    ${iperf_button}    720 312
    Set Suite Variable    ${brand}    mtk

MTK UE Click on airplane mode
    [Documentation]   click AIRPLANE
    ...    :param  ue_mode: Attach  or  Dettach
    [Arguments]   ${ue_mode}    ${ue_index}
    Get all UE pointer variable
    Connect to control pc via cygwin    ue_index=${ue_index}
    Run Keyword If    '${ue_mode}'=='Dettach'    Dettach UE By Adb Command    ue_index=${ue_index}
    Run Keyword If    '${ue_mode}'=='Attach'    Run Keywords    Dettach UE By Adb Command    ue_index=${ue_index}    AND
    ...    Attach UE By Adb Command    ue_index=${ue_index}
    [Teardown]    Run Keyword And Ignore Error    csn.disconnect      connection=cygwin

Dettach UE By Adb Command
    [Arguments]    ${ue_index}=${0}
    ${serial_number}    Set Variable    ${tl.ues[${ue_index}].serial_number}
    Run Keyword and Ignore Error   csn.send_command    command=adb -s ${serial_number} root    connection=cygwin
    sleep   4s
    Run Keyword and Ignore Error   csn.send_command    command=adb -s ${serial_number} shell settings put global airplane_mode_on 1
    ...    connection=cygwin
    sleep   4s
    Run Keyword and Ignore Error   csn.send_command
    ...    command=adb -s ${serial_number} shell am broadcast -a android.intent.action.AIRPLANE_MODE --ez state true    connection=cygwin
    sleep   4s

Attach UE By Adb Command
    [Arguments]    ${ue_index}=${0}
    ${serial_number}    Set Variable    ${tl.ues[${ue_index}].serial_number}
    Run Keyword and Ignore Error   csn.send_command    command=adb -s ${serial_number} root    connection=cygwin
    sleep   4s
    Run Keyword and Ignore Error   csn.send_command    command=adb -s ${serial_number} shell settings put global airplane_mode_on 0
    ...    connection=cygwin
    sleep   4s
    Run Keyword and Ignore Error   csn.send_command
    ...    command=adb -s ${serial_number} shell am broadcast -a android.intent.action.AIRPLANE_MODE --ez state false    connection=cygwin
    sleep   4s

UE Start Traffic
    [Arguments]    ${ue_index}    ${ue_type}=samsung_ue    ${ul_throughput}=${None}    ${dl_throughput}=${None}
    ...    ${ul_duration}=6000    ${dl_duration}=6000    ${protocol}=udp    ${if_ul}=${True}    ${if_dl}=${True}
    Run Keyword And Ignore Error    run keyword if     ${if_ul}    power_ue.Start traffic    direction=ul    duration=${ul_duration}
    ...    protocol=${protocol}    ue_index=${ue_index}    iperf_port=${ul_port_list[${ue_index}]}    throughput=${ul_throughput}
    ...    ue_type=${ue_type}    apn_address=dxdata1    iperf_type=via_command
    run keyword and continue on failure    run keyword if     ${if_dl}    power_ue.Start traffic    direction=dl    duration=${dl_duration}
    ...    protocol=${protocol}    ue_index=${ue_index}    iperf_port=${dl_port_list[${ue_index}]}    throughput=${dl_throughput}
    ...    ue_type=${ue_type}

UE Stop Traffic
    [Arguments]    ${ue_index}    ${ue_type}=samsung_ue    ${protocol}=udp    ${if_ul}=${True}    ${if_dl}=${True}
    Run Keyword And Ignore Error    run keyword if    ${if_ul}    power_ue.Stop traffic    direction=ul    ue_index=${ue_index}
    ...    ue_type=${ue_type}    protocol=${protocol}    iperf_port=${ul_port_list[${ue_index}]}    iperf_type=via_command
    run keyword and continue on failure    run keyword if    ${if_dl}    power_ue.Stop traffic    direction=dl    ue_index=${ue_index}
    ...    ue_type=${ue_type}    protocol=${protocol}    iperf_port=${dl_port_list[${ue_index}]}

#xiaomi_attach_power_UE#
Xiaomi_UE_Attach
    [Arguments]    ${ue_sn}=${UE0_SN}    ${ue_index}=${0}
    Log To Console    Single UE Attach
    run keyword and ignore error    ssh.disconnect    connection=cygwin
    sleep    5s
    wait until keyword succeeds    3min    30s    ssh.Connect to    hostname=${control_pc_addr}    username=${control_pc_username}
    ...    password=${control_pc_password}    alias=cygwin
    ssh.send_command   connection=cygwin
    ...   command=adb -s ${ue_sn} shell dumpsys window | grep -E \"mAwake|isStatusBarKeyguard|mShowingLockscreen\"
    sleep   2s
    ${output}   ssh.read_output   connection=cygwin
    Run Keyword If   ${output.lower().count('mawake=false')}>0
    ...   ssh.send_command   command=adb -s ${ue_sn} shell input keyevent 26   connection=cygwin
    ssh.send_command   command=adb -s ${ue_sn} shell input swipe 347 2514 715 400    connection=cygwin
    sleep    2s
    ssh.send_command    command=adb -s ${ue_sn} shell input keyevent 3    connection=cygwin
    sleep   2s
    ssh.send_command    command=adb -s ${ue_sn} shell input keyevent 187    connection=cygwin
    sleep   4s
    ssh.send_command    command=adb -s ${ue_sn} shell input tap ${close_task}    connection=cygwin
    Commercial_mobile_phone_adb_common_keywords.Commercial UE click AIRPLANE once    serial_number=${ue_sn}
    ...    Home_button=${Home_button}     swipe=${swipe}    airplane=${airplane}    close_task=${close_task}    ue_index=${ue_index}


Xiaomi Attach By Power UE And Check TP
    [Arguments]    ${ul_throughput}    ${dl_throughput}    ${ul_list}    ${dl_list}    ${protocol}    ${ue_index}
    ...    ${if_ul}=${True}    ${if_dl}=${True}    ${target_avg_percent}=0.9    ${min_percent}=0    ${log_time}=60s
    @{ue_index_list}    create list    ${ue_index}
    Xiaomi12 Attach And Verify attach    ue_index=${ue_index}
    start multi power ue traffic ul and dl    ue_index_list=${ue_index_list}
    ...    if_ul=${if_ul}    if_dl=${if_dl}    process_num=${3}
    Check Throught From Asslog   ul_list=${ul_list}    dl_list=${dl_list}     ul_tp=${ul_throughput}    dl_tp=${dl_throughput}    if_ul=${if_ul}
    ...   if_dl=${if_dl}   target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    log_time=${log_time}
    stop multi power ue traffic ul and dl    ue_index_list=${ue_index_list}    if_ul=${if_ul}    if_dl=${if_dl}    protocol=${protocol}
    [Teardown]  Xiaomi12 UE Detach    ue_index=${ue_index}


########### modify parameter ###################
Get BTS release
    [Arguments]      ${connection}=gnb_oam_login    ${bts_host}=${gNB_ip}
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    ${version}    coam.get_sw_version    connection=${connection}
    ${version_list}    split string    ${version}    separator=_
    ${bts_release}    set variable    ${version_list[0]}
    [Return]    ${bts_release}
    [Teardown]    Run keyword and ignore error    COAM Teardown gnb connections    connection=${connection}

WEBUI Login
    [Arguments]
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
    [Arguments]  ${cell_id_list}    ${node_index}
    Log To Console    delete nrcell
    FOR   ${cell_id}    IN    @{cell_id_list}
        selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-${cell_id}
        selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}
        selenium_coam.remove_element   dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
        ...    filter_param=Reference to cell group    node_index=${node_index}    abbr=refNrCellGroup
        ${node_index}    Evaluate    ${node_index} - 1
    END

Add Channelgroup Object
    [Arguments]   ${start_id}    ${LCELNR__COPY_ID}    ${LCELNR_ID}    ${copy_from}=CURRENT_BTS_CONF-1
    Log To Console    add channelgroup
    FOR    ${item}    IN     @{LCELNR__COPY_ID}
        selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${LCELNR_ID}   object_class_name=CHANNELGROUP
        ...    plan_to_copy_from=${copy_from}    copy_from=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${item}/CHANNELGROUP-1
        ...    include_subobject=${TRUE}    id_value=${start_id}
        ${start_id}    Evaluate    ${start_id} + 1
    END

Add Cell Object
    [Arguments]    ${cell_id_list}    ${node_index}=${5}
    ...     ${nrarfcn}=${nrarfcn[${1}]}    ${physCellId_list}=${physCellId_list}
    Log To Console    add  cell
    FOR    ${cell_id}    IN    @{cell_id_list}
        ${PCI}    Evaluate    ${cell_id} - 5
        ${copy_cell_id}   Evaluate    ${cell_id} - 1
        selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1   object_class_name=LCELNR
        ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${copy_cell_id}
        ...    include_subobject=${TRUE}    id_value=${cell_id}
        selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}   object_class_name=NRCELL
        ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${copy_cell_id}
        ...    include_subobject=${TRUE}    id_value=${cell_id}
        selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ...    filter_param=Local cell resource ID   new_value=${cell_id}    abbr=lcrId
        selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ...    filter_param=Physical cell identifier   new_value=${physCellId_list[${PCI}]}    abbr=physCellId
        selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
        ...    filter_param=NR Absolute radio frequency channel number   new_value=${nrarfcn}    abbr=nrarfcn
        selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}   object_class_name=NRCELLGRP
        ...    plan_to_copy_from=CURRENT_BTS_CONF-1    copy_from=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-${copy_cell_id}
        ...    include_subobject=${TRUE}    id_value=${cell_id}
       selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-${cell_id}
       ...    filter_param=List of NR cells assigned to cell group   node_index=${0}    new_value=${cell_id}    abbr=nrCellList
       selenium_coam.add_element    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
       ...    filter_param=Reference to cell group    abbr=refNrCellGroup
       selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
       ...    filter_param=Reference to cell group    new_value=${cell_id}    node_index=${node_index}    abbr=refNrCellGroup
       ${node_index}   Evaluate    ${node_index} + 1
    END


Add super Cell Object
    [Arguments]    ${cell_id}    ${node_index}=${2}    ${copy_from}=CURRENT_BTS_CONF-1
    Log To Console    add  cell
    selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1   object_class_name=LCELNR
    ...    plan_to_copy_from=${copy_from}    copy_from=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id}
    ...    include_subobject=${TRUE}    id_value=${cell_id}
    selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}   object_class_name=NRCELL
    ...    plan_to_copy_from=${copy_from}    copy_from=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    include_subobject=${TRUE}    id_value=${cell_id}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id}
    ...    filter_param=Local cell resource ID   new_value=${cell_id}    abbr=lcrId
    selenium_coam.add_object    object_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}   object_class_name=NRCELLGRP
    ...    plan_to_copy_from=${copy_from}    copy_from=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-${cell_id}
     ...    include_subobject=${TRUE}    id_value=${cell_id}
       selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELLGRP-${cell_id}
       ...    filter_param=List of NR cells assigned to cell group   node_index=${0}    new_value=${cell_id}    abbr=nrCellList
       selenium_coam.add_element    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
       ...    filter_param=Reference to cell group    abbr=refNrCellGroup
       selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRDU-1
       ...    filter_param=Reference to cell group    new_value=${cell_id}    node_index=${node_index}    abbr=refNrCellGroup



########### Case Step #################
Attach And Check Throughput
    [Arguments]    ${block_cell_list}    ${unblock_cell_id}=${5}
    ...    ${cells}=${cell_list_8CC[0:1]}
    FOR  ${item}  IN    @{block_cell_list}
        BLock or UnBlock Cell And Check Status    block_cell_id=${item}    unblock_cell_id=${unblock_cell_id}    block_flag=${True}
    END
    Attach MTK90 power UE and check throughput    ue_index=${0}    ul_throughput=${200}
    ...    dl_throughput=${1500}    cells=${cells}    target_avg_percent_UL=0.75   target_avg_percent_DL=0.6

UnBlock mutil Cell
    [Arguments]    ${unblock_cell_list}    ${block_flag}    ${block_cell_id}=None    ${bts_host}=${gnb_ip}
    @{allowed_cell_block_list}    create list    @{allowed_list}    ${49}
    @{not_allowed_list}    create list   ${49}
    FOR  ${item}  IN    @{unblock_cell_list}
        ${operate_cell_id}    Set Variable If    ${block_flag}    ${block_cell_id}    ${item}
        Block or UnBlock Single Cell    cell_id=${operate_cell_id}    block_flag=${block_flag}    bts_host=${bts_host}
        ${expect_item_status_dict}    create dictionary
        Set to dictionary    ${expect_item_status_dict}
        ...    NRCELL-${item}=${Cell_unblock_status}
        Wait Until Keyword Succeeds    15min    1min
        ...    Check All RU or Cell Status     expect_item_status_dict=${expect_item_status_dict}    if_ru=${False}   bts_host=${bts_host}
    END
        run keyword if  ${block_flag}    Check Alarm List on BTS    allowed_list=${allowed_cell_block_list}    bts_host=${bts_host}
        ...    ELSE    Check Alarm List on BTS    allowed_list=${allowed_list}    not_allowed_list=${not_allowed_list}    bts_host=${bts_host}

Attach xiaomi power UE and check throughput
    [Arguments]    ${ue_index}    ${ul_throughput}    ${dl_throughput}    ${cells}    ${target_avg_percent_UL}=0.5   ${target_avg_percent_DL}=0.6
    @{ue_index_list}    create list    ${ue_index}
    Xiaomi12 Attach And Verify attach     ue_index=${ue_index}
    Sleep    15s
    start multi power ue traffic ul and dl     ue_index_list=${ue_index_list}
    ...    if_ul=${True}     if_dl=${True}     process_num=${3}
    Check Throught From Asslog    ul_list=${cells}    dl_list=${cells}     ul_tp=${ul_throughput}    dl_tp=${dl_throughput}
    ...    target_avg_percent_UL=${target_avg_percent_UL}   target_avg_percent_DL=${target_avg_percent_DL}
    stop multi power ue traffic ul and dl    ue_index_list=${ue_index_list}    if_ul=${True}     if_dl=${True}    protocol=tcp
    [Teardown]    Xiaomi12 UE Detach    ue_index=${ue_index}

Attach MTK90 power UE and check throughput
    [Arguments]    ${ue_index}    ${ul_throughput}    ${dl_throughput}    ${cells}    ${target_avg_percent_UL}=0.5   ${target_avg_percent_DL}=0.6
    @{ue_index_list}    create list    ${ue_index}
    MTK UE Click on airplane mode    ue_mode=Attach   ue_index=${ue_index}
    UE Start Traffic    ue_index=${ue_index}    ue_type=samsung    ul_throughput=150M    dl_throughput=1000M
#    ...    if_ul=${True}     if_dl=${True}     process_num=${3}
    Check Throught From Asslog    ul_list=${cells}    dl_list=${cells}     ul_tp=${ul_throughput}    dl_tp=${dl_throughput}
    ...    target_avg_percent_UL=${target_avg_percent_UL}   target_avg_percent_DL=${target_avg_percent_DL}
    UE Stop Traffic    ue_index=${ue_index}    ue_type=samsung
    [Teardown]  MTK UE Click on airplane mode    ue_mode=Dettach    ue_index=${ue_index}

MTK90 Attach By Power UE And Check TP
    [Arguments]    ${ul_throughput}    ${dl_throughput}    ${ul_list}    ${dl_list}    ${protocol}    ${ue_index}
    ...    ${if_ul}=${True}    ${if_dl}=${True}    ${target_avg_percent}=0.9    ${min_percent}=0    ${log_time}=60s
    @{ue_index_list}    create list    ${ue_index}
    MTK UE Click on airplane mode    ue_mode=Attach    ue_index=${ue_index}
    UE Start Traffic    ue_index=${ue_index}    ue_type=samsung    ul_throughput=150M    dl_throughput=1000M
#    start multi power ue traffic ul and dl    ue_index_list=${ue_index_list}    ul_throughput=${ul_throughput}M    dl_throughput=${dl_throughput}M
#    ...    if_ul=${if_ul}    if_dl=${if_dl}    process_num=${3}    protocol=${protocol}    ue_type=${ue_type}
    Check Throught From Asslog   ul_list=${ul_list}    dl_list=${dl_list}     ul_tp=${ul_throughput}    dl_tp=${dl_throughput}    if_ul=${if_ul}
    ...   if_dl=${if_dl}   target_avg_percent=${target_avg_percent}    min_percent=${min_percent}    log_time=${log_time}
    UE Stop Traffic    ue_index=${ue_index}    ue_type=samsung    if_ul=${if_ul}    if_dl=${if_dl}    protocol=${protocol}
    [Teardown]  MTK UE Click on airplane mode    ue_mode=Dettach    ue_index=${ue_index}

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

configuration 4nom to 8nom
    WEBUI Login
    ${cell_id_list}    Create List    6    8    10    12
    Add Cell Object    cell_id_list=${cell_id_list}
    ${error}    selenium_coam.validate_plan    timeout=${180}
    Log To Console    ${error}
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${180}
    Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}
    [Teardown]    WEBUI Logout

configuration 4nom to 1super2sub
    WEBUI Login
    Add Channelgroup Object    start_id=${2}    LCELNR_ID=${cell_id_list_4CC}[0]   LCELNR__COPY_ID=${cell_id_list_4CC[1:2]}
    Delete Nrcells Data    cell_id_list=${cell_id_list_4CC[1:4]}    node_index=${3}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id_list_4CC}[0]
    ...    filter_param=Activate super cell   new_value=true    abbr=actSuperCell
    ${error}    selenium_coam.validate_plan    timeout=${180}
    Log To Console    ${error}
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${180}
    Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}
    [Teardown]    WEBUI Logout

configuration 1super2sub to 2super2sub
    [Arguments]   ${bts_host}=${gNB_ip}
    Set default SCF    bts_host=${bts_host}
    WEBUI Login
    selenium_coam.load_commissioning_file_and_check_load_status      file_path=${default_scf_path}
    Add super Cell Object    cell_id=${cell_id_list_4CC}[2]    copy_from=${CONF-1_SCF_Version}
    Add Channelgroup Object    start_id=${2}    LCELNR_ID=${cell_id_list_4CC}[2]    LCELNR__COPY_ID=${cell_id_list_4CC[3:4]}
    ...    copy_from=${CONF-1_SCF_Version}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id_list_4CC}[2]
    ...    filter_param=Activate super cell   new_value=true    abbr=actSuperCell
    ${error}    selenium_coam.validate_plan
    Log To Console    ${error}
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${180}
    Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}
    [Teardown]    WEBUI Logout

configuration 4nom to 1super4sub
    WEBUI Login
    Add Channelgroup Object    start_id=${2}    LCELNR_ID=${cell_id_list_4CC}[0]   LCELNR__COPY_ID=${cell_id_list_4CC[1:4]}
    Delete Nrcells Data    cell_id_list=${cell_id_list_4CC[1:4]}    node_index=${3}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id_list_4CC}[0]
    ...    filter_param=Activate super cell   new_value=true    abbr=actSuperCell
    ${error}    selenium_coam.validate_plan
    Log To Console    ${error}
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${180}
    Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}
    [Teardown]    WEBUI Logout

configuration 1super4sub to 1super2sub
    WEBUI Login
    ${CHANNELGROUP_list}    Create List    3    4
    FOR   ${item}    IN    @{CHANNELGROUP_list}
        selenium_coam.remove_object    object_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${cell_id_list_4CC}[0]/CHANNELGROUP-${item}
    END
    ${error}    selenium_coam.validate_plan
    Log To Console    ${error}
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${180}
    Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}
    [Teardown]    WEBUI Logout


configuration 4nom to 2super2sub
    WEBUI Login
    Add Channelgroup Object    start_id=${2}    LCELNR_ID=${cell_id_list_4CC}[0]     LCELNR__COPY_ID=${cell_id_list_4CC[1:2]}
    Add Channelgroup Object    start_id=${2}    LCELNR_ID=${cell_id_list_4CC}[2]     LCELNR__COPY_ID=${cell_id_list_4CC[3:4]}
    Delete Nrcells Data    cell_id_list=${cell_id_list_4CC[3:4]}    node_index=${3}
    Delete Nrcells Data    cell_id_list=${cell_id_list_4CC[1:2]}    node_index=${1}
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id_list_4CC}[0]
    ...    filter_param=Activate super cell   new_value=true    abbr=actSuperCell
    selenium_coam.set_parameter_value    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_id_list_4CC}[2]
    ...    filter_param=Activate super cell   new_value=true    abbr=actSuperCell
    ${error}    selenium_coam.validate_plan
    Log To Console    ${error}
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}    timeout=${180}
    Check GNB on air
    Check Alarm List on BTS    allowed_list=${allowed_list}
    [Teardown]    WEBUI Logout


Reset MUtiRF
    [Arguments]    ${bts_host}=${gnb_ip}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    bts_host=${bts_host}    username=${gNB_username}    password=${gNB_password}    connection=${connection}
    FOR    ${ru_index }  IN    @{RU_Id_list}
        coam.reset_unit    dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${ru_index}   force_radio_reset=${True}
        ...    timeout=${300}    connection=${connection}
    END
    COAM Teardown gnb connections    connection=${connection}
