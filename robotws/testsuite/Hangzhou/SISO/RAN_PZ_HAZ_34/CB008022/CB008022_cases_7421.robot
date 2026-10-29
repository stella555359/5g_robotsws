*** Settings ***
Documentation
...   author: chun.tian@nokia-sbell.com
...   contact: chun.tian@nokia-sbell.com
...   SISO

Suite Setup    Case Suite Setup
Suite Teardown    Case Suite Teardown

Resource    ./resource/CB008022_common_keywords.robot
Resource      ../../../resources/RAN_PZ_HAZ_34/robot/Commercial_mobile_phone_adb_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Variables ***
${connection}    du_conn
${parameter}     administrativeState
${value}      Shutting Down
${dist_name}       MRBTS-${btsname_id}/NRBTS-${btsname_id}/NRCELL-0

${Operational_status1}       enabled
${Administrative_status1}     Shutting Down
${procedural_status1}       configured

${Operational_status2}       disabled
${Administrative_status2}     Locked
${procedural_status2}     initialization required
${cellid}      181665793

${ru_7421}      [TL7421_CB008022_gNB] MRBTS-${btsname_id}/EQM-1/APEQM-1/RMOD-1
${ue_type_7421}    xiaomi

${dl_data_xiaomi}      500M
${dltarget_tp}     120
${server_port_ul_hon}       ${tl.ues[1].iperf_details.ports[0]}
${server_port_dl_hon}       ${tl.ues[1].iperf_details.ports[1]}
${RU_SN}      K9195201558
${brand}     lge

*** Test Cases ***
[1][1.0] CB008022-5G_01_RMOD_reduction_with_disconnecting_first
    [Tags]    CRT_22R3    CRT_7421
    [Setup]   Case Setup
#   Xiaomi12 Attach and Verify attach
#   ${conn}    Modify parameter administrativeState      dist_name=${dist_name}       parameter=${parameter}
#   ...       value=${value}    connection=${connection}
#   #Check administrative status         administrative_status=${Administrative_status1}     cell_index=${0}
#   #...    operational_status=${Operational_status1}    usage_status=${Usage_status1}    procedural_status=${procedural_status1}
#   wait until keyword succeeds    2min    1s    Check Cells Status       procedural_status=${procedural_status2}
#    ...    operational_status=${Operational_status2}
#    ...     administrative_status=${Administrative_status2}     cell_index=${0}
#   Lock Ru and check ru and cell Status    ru_idx=${1}    cell_index=${0}
#   Power Off RU       expected_RU=${RU_SN}      RU_PDU_IP=${RU_PDU_IP}     RU_PDU_PORT=${RU_PDU_PORT}
   sleep    30s
#   check fault 10 with alarm 7116      ru_index=${ru_7421}
#   ${all_ru_list[0]}     COAM get ru index    SN=${RU_SN}
  # Delete RMOD-1 Relevant Object and get cell number
#   Run Keyword And Expect Error    *ErrorCode: 7*       Check Web RMOD Detail      j=${all_ru_list[0]}
#   ${i}    Get TL7421 BBMOD distname
  # ${ii}    Get TL7421 BBMOD RF1 distname     i=${i}
  # ${RF_port_SFP_Astatus}    ${RF_port_SFP_Ostatus}
  # ...     Get Availability status and operational State for SFP in TL7421      i=${i}     ii=${ii}
  # Check SFP availability status and operational State    RF_port_SFP_Astatus=${RF_port_SFP_Astatus}
  # ...       RF_port_SFP_Ostatus=${RF_port_SFP_Ostatus}
  # Check Throughput Only    dltarget_tp=${dltarget_tp}     cell_id=${cellid}

   [Teardown]    Case Teardown
   
[2]CB008022-5G_02_RMOD_reduction_with_de-commissioning_first
    [Tags]    CRT_22R3
    [Setup]   Case Setup
   Xiaomi12 Attach and Verify attach
   ${conn}    Modify parameter administrativeState      dist_name=${dist_name}       parameter=${parameter}
   ...       value=${value}    connection=${connection}
   #Check administrative status         administrative_status=${Administrative_status1}     cell_index=${0}
   #...    operational_status=${Operational_status1}    usage_status=${Usage_status1}    procedural_status=${procedural_status1}
   wait until keyword succeeds    2min    1s    Check Cells Status       procedural_status=${procedural_status2}
    ...    operational_status=${Operational_status2}
    ...     administrative_status=${Administrative_status2}     cell_index=${0}
   Lock Ru and check ru and cell Status    ru_idx=${1}    cell_index=${0}
   ${all_ru_list[0]}     COAM get ru index    SN=${RU_SN}
   Delete RMOD-1 Relevant Object and get cell number
   Power Off RU       expected_RU=${RU_SN}      RU_PDU_IP=${RU_PDU_IP}     RU_PDU_PORT=${RU_PDU_PORT}
   Run Keyword And Expect Error    *ErrorCode: 7*       Check Web RMOD Detail      j=${all_ru_list[0]}
   ${i}    Get TL7421 BBMOD distname
   ${ii}    Get TL7421 BBMOD RF1 distname     i=${i}
   ${RF_port_SFP_Astatus}    ${RF_port_SFP_Ostatus}
   ...     Get Availability status and operational State for SFP in TL7421      i=${i}     ii=${ii}
   Check SFP availability status and operational State    RF_port_SFP_Astatus=${RF_port_SFP_Astatus}
   ...       RF_port_SFP_Ostatus=${RF_port_SFP_Ostatus}
   Check Throughput Only    dltarget_tp=${dltarget_tp}     cell_id=${cellid}
   [Teardown]    Case Teardown

[3]CB008022-5G_07_RMOD_reduction_with_disconnecting_first_in_exceptional_scenarios
       [Tags]    CRT_22R3    CRT_7421
   Xiaomi12 Attach and Verify attach
   Lock Ru and check ru and cell Status    ru_idx=${1}    cell_index=${0}
   Power Off RU       expected_RU=${RU_SN}      RU_PDU_IP=${RU_PDU_IP}     RU_PDU_PORT=${RU_PDU_PORT}
   check fault 10 with alarm 7116      ru_index=${ru_7421}
   ${all_ru_list[0]}     COAM get ru index    SN=${RU_SN}
   Delete RMOD-1 Relevant Object and get cell number
   Run Keyword And Expect Error    *ErrorCode: 7*       Check Web RMOD Detail      j=${all_ru_list[0]}
   ${i}    Get TL7421 BBMOD distname
   ${ii}    Get TL7421 BBMOD RF1 distname     i=${i}
   ${RF_port_SFP_Astatus}    ${RF_port_SFP_Ostatus}
   ...     Get Availability status and operational State for SFP in TL7421      i=${i}     ii=${ii}
   Check SFP availability status and operational State    RF_port_SFP_Astatus=${RF_port_SFP_Astatus}
   ...       RF_port_SFP_Ostatus=${RF_port_SFP_Ostatus}
   Check Throughput Only    dltarget_tp=${dltarget_tp}     cell_id=${cellid}
   [Teardown]    Case Teardown

*** Keywords ***
check fault 10 with alarm 7116
   [Arguments]      ${ru_index}
   Rest Login DU
   ${alarmId_id_list}    ${fault_id_list}       ${object_list}    CB008022_common_keywords.Get Alarm and fault Info     timeout=5
   list should contain value     ${fault_id_list}     ${10}
   list should contain value     ${alarmId_id_list}     ${7116}
   list should contain value        ${object_list}     ${ru_index}
   [Teardown]  CB008022_common_keywords.Disconnect from DU

Get TL7421 RMOD distname
     ${conn}    Rest Login DU
     FOR     ${j}    IN RANGE    ${1}    ${20}
        ${RMOD_status}    coam.get_parameters    dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/RMOD_R-${j}
        ...              connection=${conn}
        ${SN}    get from dictionary    ${RMOD_status}     chassisSerialNumber
        ${if_RMOD}     run keyword and return status    should be equal     ${SN}    K9195201558
        Exit For Loop If    '${if_RMOD}'=='${True}'
    END
    [Return]    ${j}
    [Teardown]     CB008022_common_keywords.Disconnect from DU

Check Web RMOD Detail
    [Arguments]    ${j}
    Log To Console    Check Web RMOD Detail
    Rest Login DU
    ${RMONDlistinfo}   coam.get_parameters    dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/RMOD_R-${j}
    [Return]     ${RMONDlistinfo}
    [Teardown]    Run Keyword And Ignore Error    WEBUI Logout

Connect to PC
    [Arguments]    ${ue_index}=${0}
    ...    ${hostname}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    ${username}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    ${password}=${tl.ues[${ue_index}].ssh_connection_details.password}
    csn.Connect to    hostname=${hostname}
    ...    username=${username}
    ...    password=${password}    alias=cygwin

Get all xiaomi12 pointer variable
    Set Suite Variable    ${home}    3
    Set Suite Variable    ${airplane}    932 1633
    Set Suite Variable    ${close_task}    717 2920
    Set Suite Variable    ${Home_button}    3
    Set Suite Variable    ${swipe}    1300 2700 1300 2700
    Set Suite Variable    ${open_iperf_location}    500 2050
    Set Suite Variable    ${iperf_button}    730 300
    Set Suite Variable    ${iperf_space}    800 550
    Set Suite Variable    ${5G}    900 960
    Set Suite Variable    ${ue_type}    xiaomi

Xiaomi12 Attach and Verify attach
   [Arguments]    ${ue_index}=${0}
   unlock the screen and click airplane    ue_index=${0}
   Start DL date      dl_throughput=${dl_data_xiaomi}    ue_index=${0}
   ${log_path}    power_ue.Collect Tput    ue_type=${ue_type}    duration=60s    ignore_time=5s
   ${cell_list}    create list    ${cell_id}
   power_ue.Check Tput    ue_type=${ue_type}    direction=dl    log=${log_path}
   ...    cells=${cell_list}    target_throughput=${dltarget_tp}

Start DL date
     [Arguments]    ${dl_throughput}    ${ue_index}=${0}      ${iperf_port}=default
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl   throughput=${dl_throughput}
    ...    duration=${duration}    ue_index=${ue_index}    iperf_port=${iperf_port}     iperf_type=via_command

Power On RU_2_HBTE
    [Arguments]    ${expected_RU}     ${RU_PDU_IP}     ${RU_PDU_PORT}
    Power On RU    model=TOPYOUNG    RU_PDU_IP=${RU_PDU_IP}    RU_PDU_PORT=${RU_PDU_PORT}

Power On RU
    [Arguments]    ${model}    ${RU_PDU_IP}    ${RU_PDU_PORT}
    Log To Console    Power On RU
    pdu.Setup Pdu    model=TOPYOUNG    host=${RU_PDU_IP}    alias=pdu_alias
    pdu.Power On    port=${RU_PDU_PORT}    pdu_device=pdu_alias
    pdu.Get Port Status    port=${RU_PDU_PORT}    pdu_device=pdu_alias
    sleep    3s

Check Throughput Only
    [Arguments]    ${dltarget_tp}     ${cell_id}
   ${log_path}    power_ue.Collect Tput    ue_type=${ue_type}    duration=60s    ignore_time=5s
   ${cell_list}    create list    ${cell_id}
   power_ue.Check Tput    ue_type=${ue_type}    direction=dl    log=${log_path}
   ...    cells=${cell_list}    target_throughput=${dltarget_tp}
   power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    iperf_type=via_command
#   [Teardown]    run keyword and ignore error    power_ue.UE Detach    ue_type=${ue_type}

Case Teardown
    Power On RU_2_HBTE       expected_RU=${RU_SN}      RU_PDU_IP=${RU_PDU_IP}     RU_PDU_PORT=${RU_PDU_PORT}
    Input default SCF
    unlock the screen and click airplane    ue_index=${0}
    CI_interface.Common Case Teardown
    robot_common_operations.Common Case Teardown

Check SFP availability status and operational State
    [Arguments]      ${RF_port_SFP_Astatus}    ${RF_port_SFP_Ostatus}
    Run keyword and continue on failure    should be equal    ${RF_port_SFP_Astatus}     ${None}
    Run keyword and continue on failure    should be equal    ${RF_port_SFP_Ostatus}     enabled

Get TL7421 BBMOD distname
     ${conn}    Rest Login DU
     FOR     ${i}    IN RANGE    ${1}    ${20}
        ${Connector_status}    coam.get_parameters    dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/CABINET_R-1/BBMOD_R-${i}
        ...              connection=${conn}
        ${label}    get from dictionary    ${Connector_status}     serialNumber
        ${if_BBMOD}     run keyword and return status    should be equal     ${label}    L1214610634
        Exit For Loop If    '${if_BBMOD}'=='${True}'
    END
    [Return]    ${i}
    [Teardown]     CB008022_common_keywords.Disconnect from DU

Get TL7421 BBMOD RF1 distname
    [Arguments]    ${i}
     ${conn}    Rest Login DU
     FOR     ${ii}    IN RANGE    ${1}    ${20}
        ${Connector_status}    coam.get_parameters
        ...    dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/CABINET_R-1/BBMOD_R-${i}/SFP_R-${ii}
        ...              connection=${conn}
        ${label}    get from dictionary    ${Connector_status}     physicalPort
        ${if_RF_port}     run keyword and return status    should be equal     ${label}     RF1
        Exit For Loop If    '${if_RF_port}'=='${True}'
    END
    [Return]    ${ii}
    [Teardown]     CB008022_common_keywords.Disconnect from DU

Get Availability status and operational State for SFP in TL7421
    [Arguments]    ${i}    ${ii}
    ${conn}    Rest Login DU
    ${RF_port_status}    coam.get_parameters
    ...       dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/CABINET_R-1/BBMOD_R-${i}/SFP_R-${ii}
    ...       pattern=availabilityStatus    connection=${conn}
    ${RF_port_SFP_Astatus}         get from dictionary    ${RF_port_status}    availabilityStatus
    ${RF_port_status}    coam.get_parameters
    ...       dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/CABINET_R-1/BBMOD_R-${i}/SFP_R-${ii}
    ...       pattern=operationalState    connection=${conn}
    ${RF_port_SFP_Ostatus}         get from dictionary    ${RF_port_status}     operationalState
    [Return]    ${RF_port_SFP_Astatus}    ${RF_port_SFP_Ostatus}
    [Teardown]   CB008022_common_keywords.Disconnect from DU

unlock the screen and click airplane
    [Documentation]   Check UE if need awake
    [Arguments]   ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}   ${connection}=cygwin
    Get all xiaomi12 pointer variable
    ssh.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin    timeout=300s
    log to console    start attach/detach UE
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
    log to console    attach/detach success
    [Teardown]  ssh.Disconnect   connection=cygwin


COAM get ru index
    [Documentation]  Author: shenrao
    ...              Description: Get RU detail info by ru index
    ...              ${ru_index} Should be start from 1, should match the value with RMOD-*
    [Arguments]    ${SN}    ${ru_index}=1    ${connection}=GNB_OAM
    Rest Login DU    alias=${connection}
    &{hw_info}    coam.get_detected_hw_info    connection=${connection}
    @{list_RUs}    Set variable    ${hw_info['radioModules']['rmod']}
    ${count_RUs}    Get length    ${list_RUs}
    ${all_ru_list}      Create List
    Run Keyword And Ignore Error    Should be true    ${count_RUs}>=1    msg=No RU found
    FOR    ${RMOD}    IN    @{list_RUs}
        run keyword if    '${RMOD['serialNumber']}'=='${SN}'    Append To List    ${all_ru_list}    ${RMOD['id']['internal'].split('RMOD_R-')[1]}
    END
    [Teardown]   Run Keyword And Ignore Error   Logout DU via admin    alias=${connection}
    [Return]  ${all_ru_list[0]}

Case Suite Setup
    CI_interface.Common Suite Setup
    robot_common_operations.Common Suite Setup
    Adapt to ute cloud commission scf

Case Suite Teardown
    CI_interface.Common Case Teardown
    robot_common_operations.Common Suite Teardown

Case Setup
    CI_interface.Common Case Setup
    robot_common_operations.Common case Setup
    Input default SCF
