*** Settings ***
Documentation    This is for feature CB012591 related common keywords.
...              Please do not modify the file without notification to author
...              Author:jun.8.chen@nokia-sbell.com
...              Squard: HZ SG6

Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG6/Resources.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/variable/Variables_5G.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/5G_Setup_And_Teardown.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/Cell/General_SiSo_Cell_block_and_unblock.robot
Resource
...    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/5G/General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.robot
Library     taf.selenium.sbts   WITH NAME   selenium_sbts

*** Variables ***
${MRBTS_ID}    ${tl.gnbs[0].instance_id}


*** Keywords ***
CB012591-A_7_B3_General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot.General_SiSo_Collect_RFSW_logs_from_RU_into_BTS_Snapshot
    Start To Check L1L2 Error Info From Syslog

CB012591-A_9_B3_E2E_TL_SW_upgrade_rollback_with_OAM_KPI_and_L3_Call
    Procedures.UE Prepare    ue_type=${ue_type}
    Make L3 Call And Check Tupt    cell_index=1228801    RU_id=0    value=${ru0_pa_value}    whether_get_nrcellid=${False}
    Make L3 Call And Check Tupt    cell_index=1228805    RU_id=2    value=${ru2_pa_value}    whether_get_nrcellid=${False}
    Start To Check L1L2 Error Info From Syslog

CB012591-A_4_B3_Manual_SiSo_SM_Cell_Block_Unblock
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    General_SiSo_Cell_block_and_unblock.General_SiSo_Cell_block_and_unblock    with_call=${False}
    Start To Check L1L2 Error Info From Syslog

CB012591-A_6_Concurrent_mode_NR_TDD_eCPRI7-2e_and_7-2a_Baseband_resource_pooling
    ${stream_version}    Get Active SW Version Based On Stream Version
    Set Suite Variable    ${STREAM_VERSION}    ${stream_version}
    Procedures.UE Prepare    ue_type=${ue_type}
    Make L3 Call And Check Tupt    cell_index=1    RU_id=0    value=${ru0_pa_value}
    Make L3 Call And Check Tupt    cell_index=5    RU_id=1    value=${ru0_pa_value}
    ${cell_type}    Set Variable If    '${STREAM_VERSION}'=='25R3'    16DL4UL    16DL8UL
    Update Related Parameter Values    nrCellType=${cell_type}
    Make L3 Call And Check Tupt    cell_index=1    RU_id=0    value=${ru0_pa_value}
    Make L3 Call And Check Tupt    cell_index=5    RU_id=1    value=${ru0_pa_value}
    Online Cell Deletion And Update Parameter Value
    Make L3 Call And Check Tupt    cell_index=1    RU_id=0    value=${ru0_pa_value}
    Make L3 Call And Check Tupt    cell_index=5    RU_id=1    value=${ru0_pa_value}

Update Related Parameter Values
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${nrCellType}
    Log To Console    \n***start to Update Related Parameter Values***
    ${72e_cell_1}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1', 'parameter':'actEcpri72e', 'value':'false'}
    ${72e_cell_2}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2', 'parameter':'actEcpri72e', 'value':'false'}
    ${72e_cell_3}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3', 'parameter':'actEcpri72e', 'value':'false'}
    ${72e_cell_4}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-4', 'parameter':'actEcpri72e', 'value':'false'}
    ${nrCellType_1}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1', 'parameter':'nrCellType', 'value':'8DL8UL'}
    ${nrCellType_2}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2', 'parameter':'nrCellType', 'value':'8DL8UL'}
    ${nrCellType_3}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3', 'parameter':'nrCellType', 'value':'8DL8UL'}
    ${nrCellType_4}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-4', 'parameter':'nrCellType', 'value':'8DL8UL'}
    ${numOfRxBeamforming_1}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1',
    ...    'parameter':'numberOfRxBeamforming', 'value':'4Rx'}
    ${numOfRxBeamforming_2}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2',
    ...    'parameter':'numberOfRxBeamforming', 'value':'4Rx'}
    ${numOfRxBeamforming_3}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3',
    ...    'parameter':'numberOfRxBeamforming', 'value':'4Rx'}
    ${numOfRxBeamforming_4}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-4',
    ...    'parameter':'numberOfRxBeamforming', 'value':'4Rx'}

    ${72e_cell_5}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-5', 'parameter':'actEcpri72e', 'value':'true'}
    ${72e_cell_6}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-6', 'parameter':'actEcpri72e', 'value':'true'}
    ${72e_cell_7}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-7', 'parameter':'actEcpri72e', 'value':'true'}
    ${72e_cell_8}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-8', 'parameter':'actEcpri72e', 'value':'true'}
    ${nrCellType_5}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-5', 'parameter':'nrCellType', 'value':'${nrCellType}'}
    ${nrCellType_6}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-6', 'parameter':'nrCellType', 'value':'${nrCellType}'}
    ${nrCellType_7}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-7', 'parameter':'nrCellType', 'value':'${nrCellType}'}
    ${nrCellType_8}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-8', 'parameter':'nrCellType', 'value':'${nrCellType}'}
    ${numOfRxBeamforming_5}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-5',
    ...    'parameter':'numberOfRxBeamforming', 'value':'16Rx'}
    ${numOfRxBeamforming_6}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-6',
    ...    'parameter':'numberOfRxBeamforming', 'value':'16Rx'}
    ${numOfRxBeamforming_7}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-7',
    ...    'parameter':'numberOfRxBeamforming', 'value':'16Rx'}
    ${numOfRxBeamforming_8}    Catenate   {'dist_name':'MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-8',
    ...    'parameter':'numberOfRxBeamforming', 'value':'16Rx'}

    ${update_param_list}     Catenate    ${72e_cell_1},${72e_cell_2},${72e_cell_3},${72e_cell_4},${nrCellType_1},${nrCellType_2},
    ...                                  ${nrCellType_3},${nrCellType_4},${numOfRxBeamforming_1},${numOfRxBeamforming_2},
    ...                                  ${numOfRxBeamforming_3},${numOfRxBeamforming_4},${72e_cell_5},${72e_cell_6},
    ...                                  ${72e_cell_7},${72e_cell_8},${nrCellType_5},${nrCellType_6},${nrCellType_7},${nrCellType_8},
    ...                                  ${numOfRxBeamforming_5},${numOfRxBeamforming_6},${numOfRxBeamforming_7},${numOfRxBeamforming_8}
    ${update_param_list}     Evaluate    [${update_param_list}]
    Common_keywords.Update Params Via RestApi For ASOG    params_need_to_modify=${update_param_list}    gnb_index=0

Online Cell Deletion And Update Parameter Value
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]  ${deletion_cell}=4    ${connection}=GNB_OAM
    ${activate_plan_despite_errors}    set variable if    ${if_pdl_check}    ${False}    ${True}
    Connect to gnb coam via ssl    connection=${connection}
    ${addition_deletion_cellgrp}    Get Cell Group From Cell    cell_id=${deletion_cell}    connection=${connection}
    ${cell_grp}  Get All Cell Group Id    connection=${connection}
    ${scf_path}    Download SCF Download Via Rest Api    scf_dir_path=${SAVE LOG DIRECTORY}
    selenium login and disable screen lock
    ${lcrid}    Get lcrId via webem    cell_id=${deletion_cell}
    log to console  delete object
    wait until keyword succeeds    3x    30s    selenium_coam.remove_object
    ...    object_name=MRBTS-${mrbtsID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${deletion_cell}    timeout=15
    wait until keyword succeeds    3x    30s    selenium_coam.remove_object
    ...    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELL-${deletion_cell}    timeout=15
    wait until keyword succeeds    3x    30s    selenium_coam.remove_object
    ...    object_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRCELLGRP-${addition_deletion_cellgrp}    timeout=15
    log to console  modify the value of numberOfRxBeamforming
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-1
    ...                                  filter_param=Number of Rx beamforming
    ...                                  new_value=8Rx
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-2
    ...                                  filter_param=Number of Rx beamforming
    ...                                  new_value=8Rx
    selenium_coam.set_parameter_value    dist_name=MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-3
    ...                                  filter_param=Number of Rx beamforming
    ...                                  new_value=8Rx
    ${cell_grp_len}    get length    ${cell_grp}
    FOR    ${index}    IN RANGE    ${cell_grp_len}
        ${value}    wait until keyword succeeds    3x    30s    selenium_coam.get_parameter_value
        ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
        ...    abbr=refNrCellGroup    filter_param=Reference to cell group
        ...    node_index=${index}
        run keyword if    '${value}'=='${addition_deletion_cellgrp}'    wait until keyword succeeds    3x    30s
        ...    selenium_coam.remove_element
        ...    dist_name=MRBTS-${mrbtsID}/NRBTS-${nrbtsID}/NRDU-1
        ...    abbr=refNrCellGroup    filter_param=Reference to cell group
        ...    node_index=${index}
        Exit For Loop If    '${value}'=='${addition_deletion_cellgrp}'
    END
    wait until keyword succeeds    3x    30s    selenium_coam.validate_plan
    selenium_coam.activate_plan    activate_plan_despite_errors=${activate_plan_despite_errors}    timeout=${600}
    COAM Check GNB cell on air
    Wait Until Keyword Succeeds    5min   15s    verify all cells should be onair
    [Teardown]  selenium logout and close browser

Make L3 Call And Check Tupt
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${cell_index}=1    ${RU_id}=0    ${value}=${ru0_pa_value}    ${gnb_id}=0    ${whether_get_nrcellid}=${True}
    Initial PA Value Setting For All Attenuators
    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}
    Modify All Attenuation Ports Value For Specific RU    value=${value}    RU_id=${RU_id}    gnb_id=${gnb_id}
#    Change cellBarred Parameter Value On Gnb    pcell_index=${cell_index}   exp_status=notBarred
    ${attach_info}    Procedures.UE Attach    wireshark_log_prefix=ca_attach
    ...                                       ue_type=${ue_type}
    ...                                       sleep_interval=15 sec
    ...                                       4G_check=${False}
    ...                                       input_attach_cell_index=${1}
    Start L3 Call Data Transfer    ul_data_transfer=250M
    ...                            dl_data_transfer=1500M
    ...                            duration=600
    ...                            need_get_ue_ip=${True}
    ...                            cpif_log_path=${attach_info['cpif_log_path']}
#    ...                            ue_iperf_path=/data/local/tmp/iperf
    @{direction_component_list}    Create List    UL    DL
    Run Keyword And Continue On Failure    Check Tput With Power UE    direction_component_list=@{direction_component_list}
    ...                                                                duration=90
    ...                                                                expect_ul_tput=240
    ...                                                                expect_dl_tput=820
    ...                                                                cellid=${cell_index}
    ...                                                                target_avg_percent=0.9
    ...                                                                ue_type=${ue_type}
    ...                                                                check_source=aasyslog
    ...                                                                min_percent=0
    ...                                                                whether_get_nrcellid=${whether_get_nrcellid}
    [Teardown]    Run keywords     Run Keyword And Ignore Error    COAM Teardown gnb connections    AND
    ...    Run Keyword And Ignore Error    Close the iperf process on android ue    ue_index=${0}    iperf_port=${UL_PORT}  AND
    ...    Run Keyword And Ignore Error    Close the iperf process on APPserver    port=${DL_PORT}   AND
    ...    Run Keyword And Ignore Error    power_ue.UE Detach    ue_type=${ue_type}    ue_index=${0}

SISO Coam Test Setup For 12591
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${gnb_index}=0    ${connection}=GNB_OAM
    log to console    \n*** SISO Coam Test Setup***
    SISO Coam Test Setup
    ${gnb_allowed_fault_Before_Commission}   Create List    4203    1838    4741    4681   7311   7331
    ...                                                     4293    4297    4420    4775   1932   1934    1933
    Set Test Variable    ${gnb_allowed_fault_Before_Commission}
    AlarmWatchdog.add_allow_alarms    fault_id=${gnb_allowed_fault_Before_Commission}
    ${summary_alarm_info}    Get Active Alarms And Save Summary Infomation
    Set Test Variable    ${summary_alarm_info}
    Wait Gnb Ready And Cell On Air For ASOG    gnb_id=${gnb_index}    connection=${connection}
    ${ru0_pa_value}   Create List    25    25    25    25
    Set Test Variable    ${ru0_pa_value}
    ${ru2_pa_value}   Create List    20    20    20    20
    Set Test Variable    ${ru2_pa_value}

SISO Coam Test Teardown For 12591
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    Run Keyword And Continue On Failure    Check Whether New Alarm Happened During Running Case    alarm_info_before=${summary_alarm_info}
    SISO Coam Test Teardown

SISO Coam Suite Setup For 12591
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${gnb_index}=0
    log to console    \n*** SISO Coam Suite Setup***
    run keyword and ignore error    clear vm pid before run case
    set suite variable    ${suite_setup_fail_flag}    ${True}
    ${swconfig_path}    Set Variable    ${CURDIR}/swconfig.txt
    Common_setup_and_teardown.Upload Swconfig File Via LMP    swconfig_path=${swconfig_path}
    Run Keyword And Ignore Error   Add Syslog Flag To Swconfig If Not Exist
    run keyword if     ${if_commissioning}    Run Keyword And Ignore Error   Start Btslog With Path Check
    run keyword if     ${if_commissioning}    CI_interface.Common Suite Setup    gnb_index=${gnb_index}
    robot_common_operations.Common Suite Setup
    ${connection}    set variable if    ${gnb_index}==0    GNB_OAM    GNB_OAM_${gnb_index}
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_index}
    ${Active_SW_version}    Get Active SW Version    connection=${connection}
    set suite variable      ${Active_SW_version}
    ${Golden_SCF_Path}    Get Golden SCF Path    gnb_index=${gnb_index}
    set suite variable      ${Golden_SCF_Path}
    ${gNb_CuType}   Get gNB CU type    connection=${connection}
    set suite variable      ${gNb_CuType}
    run keyword if     ${if_update_swconfig}    update swconfig for gNB    connection=${connection}
    Common_setup_and_teardown.Suite Log Path Create
    set suite variable      ${SAVE LOG DIRECTORY}    ${SUITE_LOG_PATH}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl
    ...    connection=${connection}    gnb_index=${gnb_index}
    ${scf_path}    Download SCF Download Via Rest Api    scf_dir_path=${SAVE LOG DIRECTORY}    connection=${connection}
    set suite variable    ${scf_path}
    ${mrbtsID}    ${nrbtsID}   Get mrbtsID and nrbtsID via SCF for gNB    scf_path=${scf_path}
    log to console  MRBTS_ID:${mrbtsID}, NRBTS_ID:${nrbtsID}
    set suite variable    ${mrbtsID}
    set suite variable    ${nrbtsID}
    ${ue_type}    translate_power_ue_type_from_testline
    Set Suite Variable    ${ue_type}
    run keyword if     '${testline_name}' == 'null'    add fault to the allowed fault list    faultId=${4681}
    set suite variable    ${suite_setup_fail_flag}    ${False}
    run keyword if     ${if_commissioning}    Run Keyword And Ignore Error  Stop Btslog With Path Check    target_dir=${SAVE LOG DIRECTORY}
    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}
    Initial PA Value Setting For All Attenuators