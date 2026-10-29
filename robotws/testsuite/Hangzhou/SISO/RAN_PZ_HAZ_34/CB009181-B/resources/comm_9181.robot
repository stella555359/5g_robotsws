*** Settings ***
Documentation
...   author: zheyuan.chen@nokia-sbell.com
...   contact: zheyuan.chen@nokia-sbell.com

Library    taf.transport.ssh            WITH NAME    ssh
Library    taf.collectors.core          WITH NAME    core
Library    taf.collectors.tcpdump       WITH NAME    tcpdump
Library    taf.analyzer.pdml            WITH NAME    cpdml
Library    taf.sbts.oam.coam.admin      WITH NAME    coam
Library    taf.collectors.btslog        WITH NAME    btslog
Library    String
Library    Collections
Library    OperatingSystem
Library    Process
Library    XML
Library    DateTime
Library    Telnet
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    ../../../../resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    ../../../../resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    ./variables_9181.robot

*** Keywords ***
SBTS Login
    [Arguments]    ${ip_address}=${DU_OAM_IP}    ${username}=${DU_OAM_WEBUI_USER}
    ...    ${password}=${DU_OAM_WEBUI_PASSWORD}    ${alias}=default
    [Documentation]   SBTS Login
    Connect to gnb coam via ssl    bts_host=${ip_address}    username=${username}    password=${password}    connection=${alias}
    ${connection}    set variable    ${alias}
    [Return]    ${connection}

SBTS Logout
    [Arguments]   ${alias}=default
    [Documentation]   SBTS Logout
    coam.Teardown    connection=${alias}

WEBUI Login
    [Arguments]      ${virtual_enable}=${True}
    [Documentation]   WEBUI Login
    Log To Console  START:WEBUI Login
    Log To Console  Try to login...
    selenium_coam.Enable_Virtual_Display
    selenium_coam.Login    url=${DU_OAM_WEBUI_URL}    username=${DU_OAM_WEBUI_USER}   password=${DU_OAM_WEBUI_PASSWORD}
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

Check BTS Should Be Normal
    Log To Console  Check BTS Should Be Normal
    SBTS Login
    ${ret}=    Run Keyword And Return Status    Wait Until BTS Should Be Normal
    Run keyword If    "${ret}"=="${False}"    Save Snapshot
    [Teardown]   Run Keyword And Ignore Error   SBTS Logout

Save Snapshot
    [Arguments]    ${connection}=default    ${timeout}=10min    ${ip_address}=${DU_OAM_IP}    
    ...    ${username}=${DU_OAM_WEBUI_USER}    ${password}=${DU_OAM_WEBUI_PASSWORD}
    log to console    Save Snapshot...
    run keyword and ignore error     coam.teardown    connection=${connection}
    Connect to gnb coam via ssl    bts_host=${ip_address}    username=${username}    password=${password}
    ...    connection=${connection}
    ${snapshot_path}    coam.Get Snapshot From BTS    alias=${connection}    timeout=${timeout}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}
    [Return]    ${snapshot_path}

Wait Until BTS Should Be Normal
    [Arguments]    ${retry}=1000s    ${retry_interval}=10s    ${alias}=default
    [Documentation]   Wait Until CBTS Status Should Be Normal, if CBTS status is abnormal during retry time,
    Wait Until Keyword Succeeds   ${retry}     ${retry_interval}    Gnb Cell Should Be Onair    alias=${alias}

Gnb Cell Should Be Onair
    [Arguments]    ${alias}=default    ${cell_type }=nr
    [Documentation]  Gnb Cell Should Be Onair, check method is via REST
    ${status}      coam.Get_Bts_Statuses   connection=${alias}
    ${operationalState}    Get From Dictionary    ${status}    operationalState
    should be equal as strings    ${operationalState}    Enabled    ignore_case=${True}
    ${blockingState}   Get From Dictionary    ${status}    blockingState
    should be equal as strings    ${blockingState}    Unblocked    ignore_case=${True}
    ${proceduralState}   Get From Dictionary    ${status}   proceduralState
    should be equal as strings    ${proceduralState}    OnAir    ignore_case=${True}
    #cell info
    ${cell_status}     coam.Get_Cells_Info   cell_type=${cell_type}    connection=${alias}
    FOR    ${item}    IN    @{cell_status}
        ${Status}    Get From Dictionary    ${item}    status
        ${tmp}   Get From Dictionary    ${status}    operationalState
        should be equal as strings    ${tmp}    Enabled    ignore_case=${True}
        ${tmp}   Get From Dictionary    ${status}  administrativeState
        should be equal as strings    ${tmp}    Unlocked    ignore_case=${True}
        ${tmp}   Get From Dictionary    ${status}  blockingState
        should be equal as strings    ${tmp}    Unblocked    ignore_case=${True}
        ${tmp}   Get From Dictionary    ${status}  usageState
        should be equal as strings    ${tmp}    Active    ignore_case=${True}
    END

setup to prepare default scf
    [Arguments]    ${SBTS_scf_name}    ${Branch_scf_name}    ${branch_version}=SBTS24R1
    Log To Console    Set Default Scf
    ${connection}    SBTS Login
    ${version}    coam.get_sw_version    connection=${connection}
    ${version_list}    split string    ${version}    _
    ${if_branch_load}     run keyword and return status    should contain    ${version_list[0]}    ${branch_version}
    ${default_scf}    set variable if    ${if_branch_load}    ${default_scf_path}${Branch_scf_name}
    ...    ${default_scf_path}${SBTS_scf_name}
    log to console   ${default_scf}
    [Teardown]    Run keyword and ignore error    coam.teardown      connection=${connection}
    [Return]    ${default_scf}

Commission Default SCF
    [Arguments]    ${default_scf}
    Log To Console    Commission Default SCF
    ${connection}    SBTS Login
    COAM Commission with scf file    scf_file_path=${default_scf}    connection=${connection}    is_pdl_checking_needed=${False}
    [Teardown]    SBTS Logout

Check if Unexpected History Alarm Exist
    ${fault_id_list}    Get BTS History Alarm FaultID
    return from keyword if    '${fault_id_list}' == '[]'
    ${ignore_fault}    set variable    ${ignore_history_fault}
    FOR    ${item}    IN    @{fault_id_list}
        run keyword and continue on failure    list should contain value    ${ignore_fault}    ${item}
    END

Get BTS History Alarm FaultID
    [Arguments]    ${connection}=default
    Log To Console    get history alarm faultid
    ${alarm_info}    coam.get_historic_alarms    timeout=60    connection=${connection}
    ${fault_id_list}    create list
    FOR    ${item}    IN    @{alarm_info}
        ${fault_id_dic}    get from dictionary    ${item}    additionalFaultID
        append to list    ${fault_id_list}    ${fault_id_dic}
    END
    sort list    ${fault_id_list}
    [Return]    ${fault_id_list}

Check Unexpected Active Alarm
    [Arguments]     ${ignore_fault}=${ignore_active_fault}
    ${faultid_list}    Get Active Alarm List
    FOR    ${item}    IN    @{faultid_list}
        run keyword and continue on failure    list should contain value    ${ignore_fault}    ${item}
    END

Get Active Alarm List
    [Arguments]    ${connection}=default
    Log To Console    Get Active Alarm List
    ${alarm_info}    coam.get_active_alarms    timeout=60    connection=${connection}
    ${faultid_list}    create list
    FOR    ${item}    IN    @{alarm_info}
        ${fault_id_dic}    get from dictionary    ${item}    additionalFaultID
        append to list    ${faultid_list}    ${fault_id_dic}
    END
    sort list    ${faultid_list}
    [Return]    ${faultid_list}

Power Off RU
    [Arguments]    ${model}    ${RU_PDU_IP}    ${RU_PDU_PORT}
    Log To Console    Power Off RU
    pdu.Setup Pdu    model=${model}    host=${RU_PDU_IP}    alias=pdu_alias
    pdu.Power Off    port=${RU_PDU_PORT}    pdu_device=pdu_alias
    pdu.Get Port Status    port=${RU_PDU_PORT}    pdu_device=pdu_alias
    Sleep    15s

Power On RU
    [Arguments]    ${model}    ${RU_PDU_IP}    ${RU_PDU_PORT}
    Log To Console    Power On RU
    pdu.Setup Pdu    model=${model}    host=${RU_PDU_IP}    alias=pdu_alias
    pdu.Power On    port=${RU_PDU_PORT}    pdu_device=pdu_alias
    pdu.Get Port Status    port=${RU_PDU_PORT}    pdu_device=pdu_alias
    sleep    3s

Reset RMOD
    [Arguments]    ${RU_index}    ${connection}=default
    Log To Console    Reset RMOD
    sleep    2s
    coam.reset_unit    dist_name=MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${RU_index}    force_radio_reset=${True}
    ...    timeout=${300}    connection=${connection}

block_cell
    [Arguments]      ${cell_idx}      ${connection}=default
    Log To Console    block cell
    SBTS Login
    coam.block_cell    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_idx}    connection=${connection}
    SBTS Logout
    sleep    3s

unblock_cell
    [Arguments]      ${cell_idx}      ${connection}=default
    Log To Console    unblock cell
    SBTS Login
    coam.unblock_cell    dist_name=MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${cell_idx}    connection=${connection}
    SBTS Logout
    sleep    3s

Xiaomi_UE_Attach
    [Arguments]    ${ue_sn}    ${ue_index}=${0}
    Log To Console    UE Attach
    run keyword and ignore error    ssh.disconnect    connection=cygwin
    sleep    5s
    wait until keyword succeeds    3min    30s    ssh.Connect to    hostname=${control_pc_addr}    username=${control_pc_username}
    ...    password=${control_pc_password}    alias=cygwin
    ssh.send_command
    ...   command=adb -s ${ue_sn} shell dumpsys window | grep -E \"mAwake|isStatusBarKeyguard|mShowingLockscreen\"   connection=cygwin
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

Xiaomi_Start Traffic
    [Arguments]    ${ue_sn}    ${tp_ul}    ${tp_dl}    ${duration}=600    ${ue_mode}=SA
    ...    ${ue_index}=${0}    ${p1}=${0}    ${p2}=${1}    ${iperf_type_dl}=via_command
    Log To Console    Start Traffic
    ssh.Connect to    hostname=${control_pc_addr}    username=${control_pc_username}
    ...    password=${control_pc_password}    alias=cygwin
    ${ipf}    set variable    /data/local/tmp/iperf
    ${command}    set variable
    ...    adb -s ${ue_sn} shell ${ipf} -c ${appserver_addr} -u -t ${duration} -i 1 -p ${IPERF_plist}[${p1}] -P 1 -f m -b ${tp_ul} -l 1024B -T 64
    run keyword and continue on failure    ssh.send_command    command=${command}    connection=cygwin
    ssh.Disconnect    connection=cygwin
    Log To Console    UE udp ul iperf start
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl   throughput=${tp_dl}    ue_index=${ue_index}
    ...    duration=${duration}    ue_mode=${ue_mode}    iperf_port=${IPERF_plist}[${p2}]    iperf_type=${iperf_type_dl}    process_num=${3}

Check UE Throughput
    [Arguments]    ${target_tp_ul}    ${target_tp_dl}    ${nrcell_id}=${nrcell_id}    ${target_avg_percent}=${0.95}
    Log To Console    check throughput
    ${log_path}    power_ue.Collect Tput    ue_type=${ue_type}    duration=60s    ignore_time=5s
    ${cell_list}    create list    ${nrcell_id}
    run keyword and continue on failure    power_ue.Check Tput    ue_type=${ue_type}    direction=ul    log=${log_path}
    ...    cells=${cell_list}    target_avg_percent=${target_avg_percent}    target_throughput=${target_tp_ul}
    ...    min_percent=${0}
    run keyword and continue on failure    power_ue.Check Tput    ue_type=${ue_type}    direction=dl    log=${log_path}
    ...    cells=${cell_list}    target_throughput=${target_tp_dl}      min_percent=${0}

Stop Traffic And UE Detach
    [Arguments]    ${ue_index}=${0}    ${port1}=${0}    ${port2}=${1}    ${ue_mode}=SA
    Log To Console    stop traffic
    run keyword and continue on failure    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}
    ...    iperf_port=${IPERF_plist}[${port1}]    ue_mode=${ue_mode}
    run keyword and continue on failure    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
    ...    iperf_port=${IPERF_plist}[${port2}]    ue_mode=${ue_mode}
    Log To Console    UE Detach
    [Teardown]   run keyword and ignore error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${ue_index}

Modify SWConfig
     [Arguments]    ${swconfig}
     Log To Console     modify swconfig
     ${connection}    ssh.Connect to    hostname=${DU_OAM_IP}    username=${DU_OAM_SSH_USERNAME}    password=${DU_OAM_SSH_PASSWORD}
     ...    alias=gNB
     ssh.Upload File  local_path=${CURDIR}/${swconfig}   remote_path=/ffs/run/swconfig.txt    connection=${connection}
     ssh.send_command    command=crasign /ffs/run/swconfig.txt    connection=${connection}
     sleep    5s
     [Teardown]    ssh.Disconnect    connection=${connection}

Input SCF
    [Arguments]    ${SBTS_scf_name}    ${Branch_scf_name}
    ${default_scf}    setup to prepare default scf    SBTS_scf_name=${SBTS_scf_name}    Branch_scf_name=${Branch_scf_name}
    Commission Default SCF    default_scf=${default_scf}

Reset TDD/FDD RMOD
    [Arguments]    ${RU1_index}    ${RU2_index}
    SBTS Login
    Reset RMOD    RU_index=${RU1_index}
    sleep    3s
    Reset RMOD    RU_index=${RU2_index}
    sleep    3s
    SBTS Logout
    
Power OFF/ON TDD/FDD RMOD
    [Arguments]    ${model1}=FPFH    ${model2}=FPFH
    Power Off RU    model=${model1}    RU_PDU_IP=${AKQJ_PDU_IP}    RU_PDU_PORT=${AKQJ_PDU_PORT}
    Power Off RU    model=${model2}    RU_PDU_IP=${AHEGB_PDU_IP}    RU_PDU_PORT=${AHEGB_PDU_PORT}
    sleep    5s
    Power On RU    model=${model1}    RU_PDU_IP=${AKQJ_PDU_IP}    RU_PDU_PORT=${AKQJ_PDU_PORT}
    Power On RU    model=${model2}    RU_PDU_IP=${AHEGB_PDU_IP}    RU_PDU_PORT=${AHEGB_PDU_PORT}
    
UEs Start Traffic Together
    [Arguments]    ${tp_ul1}    ${tp_dl1}    ${tp_ul2}    ${tp_dl2}
    Xiaomi_Start Traffic    ue_sn=${UE0_SN}    tp_ul=${tp_ul1}    tp_dl=${tp_dl1}    ue_index=${0}    p1=${0}    p2=${1}
    Xiaomi_Start Traffic    ue_sn=${UE1_SN}    tp_ul=${tp_ul2}    tp_dl=${tp_dl2}    ue_index=${1}    p1=${2}    p2=${3}

UE Start Traffic And Check Throughput New
    Xiaomi_UE_Attach    ue_sn=${UE0_SN}    ue_index=${0}
    Xiaomi_UE_Attach    ue_sn=${UE1_SN}    ue_index=${1}
    UEs Start Traffic Together    tp_ul1=130M    tp_dl1=300M    tp_ul2=100M    tp_dl2=200M
    sleep    30s
    Check UE Throughput    target_tp_ul=10    target_tp_dl=10    nrcell_id=${593411}    target_avg_percent=${1}
    Check UE Throughput    target_tp_ul=10    target_tp_dl=10    nrcell_id=${593414}    target_avg_percent=${1}
    Stop Traffic And UE Detach    ue_index=${0}    port1=${0}    port2=${1}
    Stop Traffic And UE Detach    ue_index=${1}    port1=${2}    port2=${3}

Reset without HWF in loop
    FOR    ${item}    IN RANGE    ${3}
        Reset without HWF
    END

Reset without HWF
    Check BTS Should Be Normal
    check unexpected alarm
    Modify SWConfig    swconfig=swconfig_flag.txt
    Reset gnb
    Check BTS Should Be Normal
    check unexpected alarm
    UE Start Traffic And Check Throughput New
    Modify SWConfig    swconfig=swconfig.txt
    Reset gnb
    Check BTS Should Be Normal
    check unexpected alarm

Reset gnb
     [Arguments]    ${connection}=default
     Log To Console    Reset BTS
     SBTS Login
     coam.reset_site    connection=${connection}
     SBTS Logout

CB009181 Suite Setup
     robot_common_operations.Common Suite Setup
     Input SCF    SBTS_scf_name=SCF_SBTS00.xml    Branch_scf_name=SCF_SBTS24R1_case02.xml

check unexpected alarm
     SBTS Login
     ${ret1}=    Run Keyword And Return Status    Check if Unexpected History Alarm Exist
     Run keyword If    "${ret1}"=="${False}"    Save Snapshot
     ${ret2}=    Run Keyword And Return Status    Check Unexpected Active Alarm
     Run keyword If    "${ret2}"=="${False}"    Save Snapshot
     SBTS Logout
