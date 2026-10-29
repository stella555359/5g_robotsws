*** Settings ***
Documentation
...   author: chun.tian@nokia-sbell.com
...   contact: chun.tian@nokia-sbell.com
...   SISO

Force Tags     STATE_SW_UPLOADED
Suite Setup    T733 Input default SCF
Suite Teardown    Case Suite Teardown

Resource    ./resource/CB008022_common_keywords.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot

*** Variables ***
${cell_info_1}    ${1}
${connection}    du_conn
${parameter}     administrativeState
${value}      Shutting Down
${dist_name}       MRBTS-${btsname_id}/NRBTS-${btsname_id}/NRCELL-411

${Operational_status1}       enabled
${Administrative_status1}     Shutting Down
${procedural_status1}       configured

${Operational_status2}       disabled
${Administrative_status2}     Locked
${procedural_status2}     initialization required

${RU_SN}         1M204902597
${cellid_733}      12009473
${ru_733}      [HZ_TL733_ASOE_AEQE] MRBTS-${btsname_id}/EQM-1/APEQM-1/RMOD-2
${ue_type_733}    huawei
${dl_data_hon}      200M
${dltarget_tp}     50

${server_port_ul_hon}       ${tl.ues[1].iperf_details.ports[0]}
${server_port_dl_hon}       ${tl.ues[1].iperf_details.ports[1]}

@{ue_index_list}           ${0}
${exp_dl}                  ${25}
${dl_throughput}           100M
${duration}                6000
${nr_cell_list1}          12009473
${733_scf_path}           ${CURDIR}/../../../../../commissionings/HGZ/7_5_UTE5G402T733/
${cell_index}            ${411}

*** Test Cases ***
[1][1.0] CB008022-5G_01_RMOD_reduction_with_disconnecting_first
   [Tags]    CRT_22R3
   [Setup]    Case Setup
#  Start Traffic And Check Throughput        if_dl=${True}    dl_list=${nr_cell_list1}    dl_list=${nr_cell_list1}
   ${conn}    Modify parameter administrativeState      dist_name=${dist_name}       parameter=${parameter}
   ...       value=${value}    connection=${connection}
   wait until keyword succeeds    2min    1s    Check Cells Status       procedural_status=${procedural_status2}
    ...    operational_status=${Operational_status2}
    ...     administrative_status=${Administrative_status2}     cell_index=${cell_index}
   Lock Ru and check ru and cell Status    ru_idx=${2}     cell_index=${cell_index}
   AlarmWatchdog.add_allow_alarms    fault_id=10
   Power Off RU_2_HBTE       expected_RU=${RU_SN}      RU_PDU_IP=${RU_PDU_IP}     RU_PDU_PORT=${RU_PDU_PORT}
   check fault 10 with alarm 7116      ru_index=${ru_733}
   ${all_ru_list[0]}     COAM get ru index    SN=${RU_SN}
   Delete 733-RMOD-2 Relevant Object and get cell number
   Run Keyword And Expect Error    **ErrorCode: 7*       Check Web RMOD Detail     j=${all_ru_list[0]}
   ${distName_SFB_R}    Get TL733 BBMOD RF2 SFP_R
   ${RF_port_SFP_Astatus}    ${RF_port_SFP_Ostatus}
   ...    Get Availability status and operational State for SFP in TL733     distName_SFB_R=${distName_SFB_R}
   Check SFP availability status and operational State    RF_port_SFP_Astatus=${RF_port_SFP_Astatus}
       ...       RF_port_SFP_Ostatus=${RF_port_SFP_Ostatus}
#    Start Traffic And Check Throughput        if_dl=${True}    dl_list=${nr_cell_list1}    dl_list=${nr_cell_list1}
    [Teardown]    Case Teardown

[2]CB008022-5G_02_RMOD_reduction_with_de-commissioning_first
   [Tags]    CRT_22R3    CRT_733
   [Setup]    Case Setup
   Start Traffic And Check Throughput        if_dl=${True}    dl_list=${nr_cell_list1}    dl_list=${nr_cell_list1}
   ${conn}    Modify parameter administrativeState      dist_name=${dist_name}       parameter=${parameter}
   ...       value=${value}    connection=${connection}
   wait until keyword succeeds    2min    1s    Check Cells Status       procedural_status=${procedural_status2}
    ...    operational_status=${Operational_status2}
    ...     administrative_status=${Administrative_status2}     cell_index=${1}
   Lock Ru and check ru and cell Status    ru_idx=${2}     cell_index=${1}
   ${all_ru_list[0]}     COAM get ru index    SN=${RU_SN}
   Delete 733-RMOD-2 Relevant Object and get cell number
   Power Off RU_2_HBTE       expected_RU=${RU_SN}      RU_PDU_IP=${RU_PDU_IP}     RU_PDU_PORT=${RU_PDU_PORT}
   Run Keyword And Expect Error    *ErrorCode: 7*       Check Web RMOD Detail     j=${all_ru_list[0]}
   ${ii}    Get TL733 BBMOD RF1 SFP_R
   ${RF_port_SFP_Astatus}    ${RF_port_SFP_Ostatus}
   ...    Get Availability status and operational State for SFP in TL733     ii=${ii}
   Check SFP availability status and operational State    RF_port_SFP_Astatus=${RF_port_SFP_Astatus}
       ...       RF_port_SFP_Ostatus=${RF_port_SFP_Ostatus}
   Start Traffic And Check Throughput        if_dl=${True}    dl_list=${nr_cell_list1}    dl_list=${nr_cell_list1}
   [Teardown]   Case Teardown

#[2]CB008022-5G_07_RMOD_reduction_with_disconnecting_first_in_exceptional_scenarios
#   [Tags]    CRT_22R3    CRT_733
#   UE Attach And Start Traffic And Check Throughput      dl_throughput=${dl_data_hon}
#    ...      dltarget_tp=${dltarget_tp}     cell_id=${cellid_733}     ul_duration=1200
#   Lock Ru and check ru and cell Status    ru_idx=${2}     cell_index=${1}
#   Power Off RU_2_HBTE       expected_RU=${RU_SN}      RU_PDU_IP=${RU_PDU_IP}     RU_PDU_PORT=${RU_PDU_PORT}
#   check fault 10 with alarm 7116      ru_index=${ru_733}
#   ${all_ru_list[0]}     COAM get ru index    SN=${RU_SN}
#   Delete 733-RMOD-2 Relevant Object and get cell number
#   Run Keyword And Expect Error    *No such a distName*       Check Web RMOD Detail     j=${all_ru_list[0]}
#   ${ii}    Get TL733 BBMOD RF1 SFP_R
#   ${RF_port_SFP_Astatus}    ${RF_port_SFP_Ostatus}
#   ...    Get Availability status and operational State for SFP in TL733     ii=${ii}
#   Check SFP availability status and operational State    RF_port_SFP_Astatus=${RF_port_SFP_Astatus}
#       ...       RF_port_SFP_Ostatus=${RF_port_SFP_Ostatus}
#   Check Throughput Only     dltarget_tp=${dltarget_tp}     cell_id=${cellid_733}
#   [Teardown]    Case Teardown
   

*** Keywords ***
Case Setup
    robot_common_operations.Common case Setup

Case Teardown
   robot_common_operations.Common case Teardown
   Run Keyword if    "${TEST_STATUS}"=="FAIL"    Save Snapshot
   Power On RU_2_HBTE       expected_RU=${RU_SN}      RU_PDU_IP=${RU_PDU_IP}     RU_PDU_PORT=${RU_PDU_PORT}
   T733 Input default SCF
   CI_interface.Common Case Teardown
   

check fault 10 with alarm 7116
   [Arguments]      ${ru_index}
   Rest Login DU
   sleep  2min
   ${alarmId_id_list}    ${fault_id_list}       ${object_list}    CB008022_common_keywords.Get Alarm and fault Info     timeout=5
   list should contain value     ${fault_id_list}     ${10}
   list should contain value     ${alarmId_id_list}     ${7116}
   list should contain value        ${object_list}     ${ru_index}
   [Teardown]   CB008022_common_keywords.Disconnect from DU

Delete 733-RMOD-2 Relevant Object and get cell number
    Log To Console    Delete RMOD And Relevant Object
    WEBUI Login
    selenium_coam.remove_object    object_name=MRBTS-${btsname_id}/NRBTS-${btsname_id}/NRCELL-411
    selenium_coam.remove_object    object_name=MRBTS-${btsname_id}/NRBTS-${btsname_id}/NRCELLGRP-411
    selenium_coam.remove_element   dist_name=MRBTS-${btsname_id}/NRBTS-${btsname_id}/NRDU-1
    ...    filter_param=Reference to cell group    node_index=${1}    abbr=refNrCellGroup
    selenium_coam.remove_object    object_name=MRBTS-${btsname_id}/EQM-1/APEQM-1/RMOD-2
    selenium_coam.remove_object    object_name=MRBTS-${btsname_id}/EQM-1/HWTOP-1/CABLINK-1
    selenium_coam.remove_element   dist_name=MRBTS-${btsname_id}/MNL-1/MNLENT-1/SYNC-2
    ...    filter_param=List of Distinguished Names     node_index=${0}    abbr=targetDNList
    selenium_coam.remove_object    object_name=MRBTS-${btsname_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-411
    selenium_coam.remove_object    object_name=MRBTS-${btsname_id}/TNLSVC-1/TNL-2/ETHSVC-1/ETHLK-3
    selenium_coam.remove_object    object_name=MRBTS-${btsname_id}/TNLSVC-1/TNL-2/ETHSVC-1/ETHIF-3
    ${error}    selenium_coam.validate_plan
    sleep    5s
    Log To Console    ${error}
    Log To Console    Activate plan
    selenium_coam.activate_plan    download_plan_without_activation=${False}    activate_plan_despite_errors=${True}
    log to console      get current cell number
    sleep    30s
    ${total_cell_number}    selenium_coam.get_number_of_cells
    should be equal      ${total_cell_number}     ${1}
    [Teardown]    Run Keyword And Ignore Error    WEBUI Logout

Power Off RU_2_HBTE
    [Arguments]    ${expected_RU}     ${RU_PDU_IP}     ${RU_PDU_PORT}
    Power Off    model=HBTE    RU_PDU_IP=${RU_PDU_IP}    RU_PDU_PORT=${RU_PDU_PORT}

Power On RU_2_HBTE
    [Arguments]    ${expected_RU}     ${RU_PDU_IP}     ${RU_PDU_PORT}
    Power On RU    model=HBTE    RU_PDU_IP=${RU_PDU_IP}    RU_PDU_PORT=${RU_PDU_PORT}

Power On RU
    [Arguments]    ${model}    ${RU_PDU_IP}    ${RU_PDU_PORT}
    Log To Console    Power On RU
    pdu.Setup Pdu    model=${model}    host=${RU_PDU_IP}    alias=pdu_alias
    pdu.Power On    port=${RU_PDU_PORT}    pdu_device=pdu_alias
    pdu.Get Port Status    port=${RU_PDU_PORT}    pdu_device=pdu_alias
    sleep    3s

Start Traffic And Check Throughput
    [Arguments]     ${if_dl}    ${dl_list}    ${ue_index_list}=${ue_index_list}
    ...    ${exp_dl_tp}=${exp_dl}    ${log_time}=3m    ${ue_type}=huawei
    attach multi power ue    ue_index_list=${ue_index_list}
    start multi power ue traffic ul and dl    ue_index_list=${ue_index_list}     dl_throughput=${dl_throughput}
    ...         dl_duration=${duration}    protocol=udp      if_dl=${if_dl}
    run keyword and continue on failure    power_ue.Check throughput
    ...    ue_type=${ue_type}    direction=dl    throughput=${exp_dl_tp}     cellid=${dl_list}
    stop multi power ue traffic dl    ue_index_list=${ue_index_list}    protocol=udp       if_dl=${if_dl}
    [Teardown]  Run keyword and ignore error    detach multi power ue    ue_index_list=${ue_index_list}

attach multi power ue
    [Arguments]    ${ue_index_list}
    log to console       Prepare UE
    FOR    ${item}    IN    @{ue_index_list}
        power_ue.Prepare UE    ue_index=${item}    ue_type=huawei
        ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${item}    ue_type=huawei    log_type=Aasyslog
        power_ue.Verify attach    ue_type=huawei   5Grach_ed=${5Grach_ed_0}    4G_check=False
    END

start multi power ue traffic ul and dl
    [Arguments]    ${ue_index_list}       ${dl_throughput}=${None}       ${dl_duration}=6000
    ...    ${protocol}=udp       ${if_dl}=${True}
    log to console      Start traffic    console=yes
    FOR    ${item}    IN    @{ue_index_list}
        run keyword and continue on failure    run keyword if    ${if_dl}    power_ue.Start traffic    ue_index=${item}    direction=dl
        ...    throughput=${dl_throughput}    duration=${dl_duration}    ue_type=huawei    protocol=${protocol}
        ...    iperf_port=${dl_power_port_list}[${item}]
    END

stop multi power ue traffic dl
    [Arguments]    ${ue_index_list}    ${protocol}=udp      ${if_dl}=${True}
    log to console     Stop traffic    console=yes
    FOR    ${item}    IN    @{ue_index_list}
        run keyword if    ${if_dl}    power_ue.Stop traffic    direction=dl    ue_index=${item}    ue_type=huawei    protocol=${protocol}
        ...    iperf_port=${dl_power_port_list}[${item}]
    END

detach multi power ue
    [Arguments]    ${ue_index_list}
    log to console      UE Detach    console=yes
    FOR    ${item}    IN    @{ue_index_list}
         power_ue.UE Detach    ue_index=${item}    ue_type=huawei
    END

Check Web RMOD Detail
    [Arguments]    ${j}
    Log To Console    Check Web RMOD Detail
    Rest Login DU
    ${RMONDlistinfo}   coam.get_parameters    dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-${j}
    [Return]     ${RMONDlistinfo}
    [Teardown]    Run Keyword And Ignore Error    WEBUI Logout

check rf2 disabled and depedency status
   Rest Login DU
   ${Connector_status}    coam.get_parameters    dist_name=/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/SMOD_L-1/CONNECTOR_L-2
   [Return]      ${Connector_status}
   [Teardown]    Run Keyword And Ignore Error    WEBUI Logout

Check SFP status
    [Arguments]   ${EIF1_SFP_status}    ${RF1_SFP_status}    ${RMOD_SFP_status}    ${expected_status}
    Run keyword and continue on failure    should be equal    ${EIF1_SFP_status}    ${expected_status}
    Run keyword and continue on failure    should be equal    ${RMOD_SFP_status}    ${expected_status}
    should be equal    ${RF1_SFP_status}    ${expected_status}

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

Get TL733 BBMOD RF1 SFP_R
     ${conn}    Rest Login DU
     FOR     ${ii}    IN RANGE    ${1}    ${20}
        ${physicalPort}    Run Keyword And Ignore Error    coam.get_parameters
        ...              dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1/SFP_R-${ii}
        ...              connection=${conn}
        ${label}    get from dictionary    ${physicalPort}     physicalPort
        ${if_RF_port}     run keyword and return status    should be equal     ${label}    RF7
        Exit For Loop If    '${if_RF_port}'=='${True}'
    END
    [Return]    ${ii}
    [Teardown]     CB008022_common_keywords.Disconnect from DU

Get Availability status and operational State for SFP in TL733
    [Arguments]     ${distName_SFB_R}
    ${conn}    Rest Login DU
    ${RF_port_status}    coam.get_parameters
    ...       dist_name=${distName_SFB_R}
    ...       pattern=availabilityStatus    connection=${conn}
    ${RF_port_SFP_Astatus}         get from dictionary    ${RF_port_status}    availabilityStatus
    ${RF_port_status}    coam.get_parameters
    ...       dist_name=${distName_SFB_R}
    ...       pattern=operationalState    connection=${conn}
    ${RF_port_SFP_Ostatus}         get from dictionary    ${RF_port_status}     operationalState
    [Return]    ${RF_port_SFP_Astatus}    ${RF_port_SFP_Ostatus}
    [Teardown]    CB008022_common_keywords.Disconnect from DU

Check SFP availability status and operational State
    [Arguments]      ${RF_port_SFP_Astatus}    ${RF_port_SFP_Ostatus}
    Run keyword and continue on failure    should be equal    ${RF_port_SFP_Astatus}     dependency
    Run keyword and continue on failure    should be equal    ${RF_port_SFP_Ostatus}     disabled

T733 Input default SCF
    [Timeout]  30 min
    [Arguments]      ${timeout}=15 min
    CI_interface.Common Suite Setup
    robot_common_operations.Common Suite Setup
    ${conn}    Rest Login DU
    ${version}    coam.get_sw_version    connection=${conn}
    ${version_list}    split string    ${version}
    ${if_common_load}     run keyword and return status    should contain    ${version_list[0]}    SBTS22R3
    ${default_scf}    set variable if    ${if_common_load}   ${733_scf_path}SCF_SBTS22R3_8022.xml
    ...    ${733_scf_path}SCF_Trunk_8022.xml
    set suite variable    ${default_scf}
    BuiltIn.Log    \n Input default SCF \n    console=yes
    run keyword and ignore error    COAM Commission with scf file    scf_file_path=${default_scf}    connection=${conn}
    BuiltIn.Log    \n wait until gnb cell on air \n    console=yes
    wait until keyword succeeds    ${timeout}    30sec   Cloud DU connect to gnb coam via ssl    connection=${conn}
    wait until keyword succeeds    ${timeout}    30sec   COAM Check GNB cell on air    connection=${conn}
    [Teardown]    CB008022_common_keywords.Disconnect from DU

Case Suite Teardown
    CI_interface.Common Case Teardown
    robot_common_operations.Common Suite Teardown

Get TL733 BBMOD RF2 SFP_R
     ${conn}    Rest Login DU
    ${physicalPort_list}     coam.get_managed_objects
    ...              class_name=SFP_R
    ...              connection=${conn}
    ${physicalPort_list_len}    Get Length    ${physicalPort_list}
    FOR     ${item}    IN RANGE    ${physicalPort_list_len}
        ${label_parameters}    get from dictionary    ${physicalPort_list[${item}]}    parameters
        ${distName_SFB_R}    get from dictionary     ${physicalPort_list[${item}]}    distName
        ${label}    get from dictionary    ${label_parameters}    physicalPort
        Exit For Loop If    '${label}'=='RF7'
    END
    [Return]    ${distName_SFB_R}
    [Teardown]     CB008022_common_keywords.Disconnect from DU
