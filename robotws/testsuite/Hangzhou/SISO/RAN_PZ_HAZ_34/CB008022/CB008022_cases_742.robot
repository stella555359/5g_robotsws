*** Settings ***
Documentation
...   author: chun.tian@nokia-sbell.com
...   contact: chun.tian@nokia-sbell.com
...   SISO
Suite Setup    Case Suite Setup
Suite Teardown       robot_common_operations.Common Suite Teardown

Resource    ./resource/CB008022_common_keywords.robot
Resource      ../../../resources/RAN_PZ_HAZ_34/robot/Commercial_mobile_phone_adb_common_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF_NEW/Resource/UUF_LogCollection.robot
Variables     testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/UUF_NEW/Config/UUF_Vars.py


*** Variables ***
${cell_info_1}    ${1}
${connection}    du_conn
${parameter}     administrativeState
${value}      Shutting Down
${dist_name}       MRBTS-${btsname_id}/NRBTS-${btsname_id}/NRCELL-10

${Operational_status1}       enabled
${Administrative_status1}     Shutting Down
${procedural_status1}       configured

${Operational_status2}       disabled
${Administrative_status2}     Locked
${procedural_status2}     initialization required
${cellid}       178315
${ru_742}      [TL742_TMO] MRBTS-${btsname_id}/EQM-1/APEQM-1/RMOD-11
${ue_type_742}    xiaomi
${dl_data_xiaomi}      200M
${dltarget_tp}     60
${server_port_ul_hon}       ${tl.ues[1].iperf_details.ports[0]}
${server_port_dl_hon}       ${tl.ues[1].iperf_details.ports[1]}
${RU_SN}       	K9195201558
${brand}     lge
@{ru_serial_list}    K9195201558


*** Test Cases ***
[1]CB008022-5G_01_RMOD_reduction_with_disconnecting_first
    [Tags]    CRT_22R3    CRT_742
    Xiaomi12 Attach and Verify attach
    ${conn}    Modify parameter administrativeState      dist_name=${dist_name}       parameter=${parameter}
    ...       value=${value}    connection=${connection}
    wait until keyword succeeds    2min    1s    Check Cells Status       procedural_status=${procedural_status2}
    ...    operational_status=${Operational_status2}
    ...     administrative_status=${Administrative_status2}     cell_index=${10}
    Lock Ru and check ru and cell Status    ru_idx=${11}    cell_index=${10}
    Power Off RU       expected_RU=${RU_SN}      RU_PDU_IP=${RU_PDU_IP}     RU_PDU_PORT=${RU_PDU_PORT}
    check fault 10 with alarm 7116      ru_index=${ru_742}
    ${all_ru_list[0]}     COAM get ru index    SN=${RU_SN}
    Delete RMOD-1 Relevant Object and get cell number
    Run Keyword And Expect Error    *ErrorCode: 7*       Check Web RMOD Detail    j=${all_ru_list[0]}
    ${i}    Get TL742 BBMOD distname
    ${ii}    Get TL742 BBMOD RF1 SFP_R     i=${i}
    ${RF_port_SFP_Astatus}    ${RF_port_SFP_Ostatus}
    ...     Get Availability status and operational State for SFP in TL742      i=${i}     ii=${ii}
    Check SFP availability status and operational State    RF_port_SFP_Astatus=${RF_port_SFP_Astatus}
       ...       RF_port_SFP_Ostatus=${RF_port_SFP_Ostatus}
   Check Throughput Only    dltarget_tp=${dltarget_tp}     cell_id=${cellid}
   [Teardown]   Case Teardown

[1]CB008022-5G_02_RMOD_reduction_with_de-commissioning_first
    [Tags]    CRT_22R3      CIT_TRUNK
    [Setup]  robot_common_operations.Common Case Setup
    Xiaomi12 Attach and Verify attach
    ${conn}    Modify parameter administrativeState      dist_name=${dist_name}       parameter=${parameter}
    ...       value=${value}    connection=${connection}
    wait until keyword succeeds    2min    1s    Check Cells Status       procedural_status=${procedural_status2}
    ...    operational_status=${Operational_status2}
    ...     administrative_status=${Administrative_status2}     cell_index=${10}
   Lock Ru and check ru and cell Status    ru_idx=${11}    cell_index=${10}
   ${all_ru_list[0]}     COAM get ru index    SN=${RU_SN}
   Delete RMOD-1 Relevant Object and get cell number
   Power Off RU       expected_RU=${RU_SN}      RU_PDU_IP=${RU_PDU_IP}     RU_PDU_PORT=${RU_PDU_PORT}
   Run Keyword And Expect Error    *ErrorCode: 7*       Check Web RMOD Detail    j=${all_ru_list[0]}
   ${i}    Get TL742 BBMOD distname
   ${ii}    Get TL742 BBMOD RF1 SFP_R     i=${i}
   ${RF_port_SFP_Astatus}    ${RF_port_SFP_Ostatus}
   ...     Get Availability status and operational State for SFP in TL742      i=${i}     ii=${ii}
   Check SFP availability status and operational State    RF_port_SFP_Astatus=${RF_port_SFP_Astatus}
       ...       RF_port_SFP_Ostatus=${RF_port_SFP_Ostatus}
   Check Throughput Only    dltarget_tp=${dltarget_tp}     cell_id=${cellid}
   [Teardown]   Case Teardown

[1]CB008022-5G_07_RMOD_reduction_with_disconnecting_first_in_exceptional_scenarios
   [Tags]    CRT_22R3
   Xiaomi12 Attach and Verify attach
   Lock Ru and check ru and cell Status    ru_idx=${1}    cell_index=${0}
   ${all_ru_list[0]}     COAM get ru index    SN=${RU_SN}
   Delete RMOD-1 Relevant Object and get cell number
   Power Off RU       expected_RU=${RU_SN}      RU_PDU_IP=${RU_PDU_IP}     RU_PDU_PORT=${RU_PDU_PORT}
   Run Keyword And Expect Error    *ErrorCode: 7*       Check Web RMOD Detail    j=${all_ru_list[0]}
   ${i}    Get TL742 BBMOD distname
   ${ii}    Get TL742 BBMOD RF1 SFP_R     i=${i}
   ${RF_port_SFP_Astatus}    ${RF_port_SFP_Ostatus}
   ...     Get Availability status and operational State for SFP in TL742      i=${i}     ii=${ii}
   Check SFP availability status and operational State    RF_port_SFP_Astatus=${RF_port_SFP_Astatus}
   ...       RF_port_SFP_Ostatus=${RF_port_SFP_Ostatus}
   Check Throughput Only    dltarget_tp=${dltarget_tp}     cell_id=${cellid}
   [Teardown]   Case Teardown

*** Keywords ***
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

Logout DU via admin
    [Documentation]    logout DU via admin
    ...                Author: Shenrao
    [Arguments]  ${alias}=default
    coam.Teardown  connection=${alias}

Get TL742 BBMOD distname
     ${conn}    Rest Login DU
     FOR     ${i}    IN RANGE    ${1}    ${20}
        ${Connector_status}    coam.get_parameters    dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-${i}
        ...              connection=${conn}
        ${label}    get from dictionary    ${Connector_status}     serialNumber
        ${if_BBMOD}     run keyword and return status    should be equal     ${label}    L1213615776
        Exit For Loop If    '${if_BBMOD}'=='${True}'
    END
    [Return]    ${i}
    [Teardown]     CB008022_common_keywords.Disconnect from DU

Get TL742 BBMOD RF1 SFP_R
    [Arguments]    ${i}
     ${conn}    Rest Login DU
     FOR     ${ii}    IN RANGE    ${1}    ${20}
        ${physicalPort}    coam.get_parameters
        ...              dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-${i}/SFP_R-${ii}
        ...              connection=${conn}
        ${label}    get from dictionary    ${physicalPort}     physicalPort
        ${if_RF_port}     run keyword and return status    should be equal     ${label}    RF1
        Exit For Loop If    '${if_RF_port}'=='${True}'
    END
    [Return]    ${ii}
    [Teardown]     CB008022_common_keywords.Disconnect from DU

Get Availability status and operational State for SFP in TL742
    [Arguments]    ${i}    ${ii}
    ${conn}    Rest Login DU
    ${RF_port_status}    coam.get_parameters
    ...       dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-${i}/SFP_R-${ii}
    ...       pattern=availabilityStatus    connection=${conn}
    ${RF_port_SFP_Astatus}         get from dictionary    ${RF_port_status}    availabilityStatus
    ${RF_port_status}    coam.get_parameters
    ...       dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-${i}/SFP_R-${ii}
    ...       pattern=operationalState    connection=${conn}
    ${RF_port_SFP_Ostatus}         get from dictionary    ${RF_port_status}     operationalState
    [Return]    ${RF_port_SFP_Astatus}    ${RF_port_SFP_Ostatus}
    [Teardown]    CB008022_common_keywords.Disconnect from DU

Check SFP availability status and operational State
    [Arguments]      ${RF_port_SFP_Astatus}    ${RF_port_SFP_Ostatus}
    Run keyword and continue on failure    should be equal    ${RF_port_SFP_Astatus}     dependency
    Run keyword and continue on failure    should be equal    ${RF_port_SFP_Ostatus}     disabled

Connect to PC
    [Arguments]    ${ue_index}=${0}
    ...    ${hostname}=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    ${username}=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    ${password}=${tl.ues[${ue_index}].ssh_connection_details.password}
    csn.Connect to    hostname=${hostname}
    ...    username=${username}
    ...    password=${password}    alias=cygwin    timeout=120

check fault 10 with alarm 7116
   [Arguments]      ${ru_index}
   Rest Login DU
   ${alarmId_id_list}    ${fault_id_list}       ${object_list}    CB008022_common_keywords.Get Alarm and fault Info     timeout=5
   list should contain value     ${fault_id_list}     ${10}
   list should contain value     ${alarmId_id_list}     ${7116}
   list should contain value        ${object_list}     ${ru_index}
   [Teardown]  CB008022_common_keywords.Disconnect from DU

Check Web RMOD Detail
    [Arguments]    ${j}
    Log To Console    Check Web RMOD Detail
    Rest Login DU
    ${RMONDlistinfo}   coam.get_parameters    dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-${j}
    [Return]     ${RMONDlistinfo}
    [Teardown]    Run Keyword And Ignore Error    WEBUI Logout

Get all xiaomi12 pointer variable
    Set Suite Variable    ${home}    3
    Set Suite Variable    ${airplane}    932 1633
    Set Suite Variable    ${close_task}   717 2920
    Set Suite Variable    ${Home_button}    3
    Set Suite Variable    ${swipe}    1300 2700 1300 2700
    Set Suite Variable    ${open_iperf_location}    500 2050
    Set Suite Variable    ${iperf_button}    730 300
    Set Suite Variable    ${iperf_space}    800 550
    Set Suite Variable    ${5G}    900 960
    Set Suite Variable    ${ue_type}    xiaomi

Xiaomi12 Attach and Verify attach
   [Arguments]    ${ue_index}=${0}
   unlock the screen and click airplane    ue_index=${ue_index}
   Start DL date      dl_throughput=${dl_data_xiaomi}    ue_index=${ue_index}
   ${log_path}    power_ue.Collect Tput    ue_type=${ue_type}    duration=60s    ignore_time=5s
   ${cell_list}    create list    ${cell_id}
   power_ue.Check Tput    ue_type=${ue_type}    direction=dl    log=${log_path}
   ...    cells=${cell_list}    target_throughput=${dltarget_tp}    min_percent=0

unlock the screen and click airplane
    [Documentation]   Check UE if need awake
    [Arguments]   ${ue_index}=${0}   ${serial_number}=${tl.ues[${ue_index}].serial_number}   ${connection}=cygwin
    Get all xiaomi12 pointer variable
    wait until keyword succeeds    3x   1min
    ...    csn.Connect to    hostname=${tl.ues[${ue_index}].ssh_connection_details.addr}
    ...    username=${tl.ues[${ue_index}].ssh_connection_details.username}
    ...    password=${tl.ues[${ue_index}].ssh_connection_details.password}    alias=cygwin    timeout=120
    csn.send_command   connection=${connection}
    ...   command=adb -s ${serial_number} shell dumpsys window | grep -E \"mAwake|isStatusBarKeyguard|mShowingLockscreen\"
    sleep   2s
    ${output}   csn.read_output   connection=${connection}
    Run Keyword If   ${output.lower().count('mawake=false')}>0
    ...   csn.send_command   command=adb -s ${serial_number} shell input keyevent 26   connection=${connection}
    csn.send_command   command=adb -s ${serial_number} shell input swipe 347 2514 715 400    connection=${connection}
    sleep    2s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 3    connection=${connection}
    sleep   2s
    csn.send_command    command=adb -s ${serial_number} shell input keyevent 187    connection=${connection}
    sleep   4s
    csn.send_command    command=adb -s ${serial_number} shell input tap ${close_task}    connection=${connection}
    Commercial_mobile_phone_adb_common_keywords.Commercial UE click AIRPLANE once      serial_number=${serial_number}    Home_button=${Home_button}
    ...    swipe=${swipe}    airplane=${airplane}       close_task=${close_task}
    [Teardown]

Start DL date
     [Arguments]    ${dl_throughput}    ${ue_index}=${0}      ${iperf_port}=default
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl   throughput=${dl_throughput}
    ...    duration=${duration}    ue_index=${ue_index}    iperf_port=${iperf_port}     iperf_type=via_command

Power On RU_2_HBTE
    [Arguments]     ${RU_PDU_IP}     ${RU_PDU_PORT}
    Power On RU    model=TOPYOUNG    RU_PDU_IP=${RU_PDU_IP}    RU_PDU_PORT=${RU_PDU_PORT}

Power On RU
    [Arguments]    ${RU_PDU_IP}    ${RU_PDU_PORT}    ${model}=TOPYOUNG
    Log To Console    Power On RU
    pdu.Setup Pdu    model=${model}    host=${RU_PDU_IP}    alias=pdu_alias
    pdu.Power On    port=${RU_PDU_PORT}    pdu_device=pdu_alias
    pdu.Get Port Status    port=${RU_PDU_PORT}    pdu_device=pdu_alias
    sleep    3s

Check Throughput Only
    [Arguments]    ${dltarget_tp}     ${cell_id}
    Log To Console    Check Throughput
    ${log_path}    power_ue.Collect Tput    ue_type=${ue_type}    duration=60s    ignore_time=5s
    ${cell_list}    create list    ${cell_id}
    power_ue.Check Tput    ue_type=${ue_type}    direction=dl    log=${log_path}
    ...    cells=${cell_list}    target_throughput=${dltarget_tp}    min_percent=0
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    iperf_type=via_command


Case Teardown
    robot_common_operations.Common Case Teardown
    Run Keyword if    "${TEST_STATUS}"=="FAIL"    Save Snapshot
    Run Keyword if    "${TEST_STATUS}"=="FAIL"    Capture LMI Log    gnb_index=${0}    ru_serial_list=${ru_serial_list}
    Power On RU_2_HBTE      RU_PDU_IP=${RU_PDU_IP}     RU_PDU_PORT=${RU_PDU_PORT}
    Input default SCF
    CI_interface.Common Case Teardown
    FOR    ${i}    IN RANGE    3
        run keyword and ignore error    power_ue.UE Detach    ue_type=${ue_type}
    END

Get RF1 distname
    ${conn}    Rest Login DU
    FOR     ${i}    IN RANGE    ${1}    ${20}
        ${Connector_status}    coam.get_parameters    dist_name=/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/BBMOD_L-2/CONNECTOR_L-{i}
        ...              connection=${connection}
        ${label}    get from dictionary    ${Connector_status}     connectorLabel
        ${if_RF1}     run keyword and return status    should be equal     ${label}    RF1
        Exit For Loop If    '${if_RF1}'=='${True}'
     END
    [Return]    ${i}
    [Teardown]    CB008022_common_keywords.Disconnect from DU

Case Suite Setup
    Adapt to ute cloud commission scf
    Input default SCF
    robot_common_operations.Common Suite Setup

############# Capture LMI Log ###############
Capture LMI Log
    [Arguments]    ${gnb_index}    ${ru_serial_list}    ${log_dir}=${OUTPUT_DIR}/${TEST_NAME}
    Log To Console   //TODO: UUF Catch RU Log
    Log To Console   ${RU_LOG_FLAG}
    ${log_dir_not_exist}   Run Keyword And Return Status   OperatingSystem.Directory Should Not Exist   ${log_dir}
    Run Keyword If   ${log_dir_not_exist}   OperatingSystem.Create Directory   ${log_dir}
    ${RU_serial_pc_info}    UUF Get RU PC Info Accordind To Serial    ru_serial_list=${ru_serial_list}
    UUF Catch RU Log From LMI    testline=gnb_${gnb_index}    ru_list=${RU_serial_pc_info}
