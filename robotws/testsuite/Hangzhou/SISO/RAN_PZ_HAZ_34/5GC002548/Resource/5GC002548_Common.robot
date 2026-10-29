*** Settings ***
Documentation    Author: xiangyue.zhou@nokia-sbell.com
Resource    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_34/5GC001795/Resources/5GC001795_common.robot

*** Variables ***
&{fault_16}       faultId=${16}
&{fault_4298}     faultId=${4298}
&{fault_7300}       faultId=${7300}
&{fault_7319}     faultId=${7319}
&{fault_1900}    faultId=${1900}

*** Keywords ***
2548 Suite Setup
   [Arguments]    ${scf_file_name}=${None}    ${ru_num}=1    ${ru_type}=AEHC    ${scf_path}=/home/ute/SCF
    ...            ${is_pdl_checking_needed}=${False}   ${asik_alais}=ASIK Master
    COAM Create log directory    is_set_to_test_case_level=${False}
    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl
    Run Keyword And Ignore Error    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    ...                                                               file_path=${SUITE_LOG_PATH}
    ${scf_file_name}    Get SCF File Name based on stream version    scf_file_name=${scf_file_name}
    ${Active_SW_version}    Get Active SW Version
#    Set Suite Variable    ${Active_SW_version}
    ${stream}    get stream from version    ${Active_SW_version}
    set suite variable      ${stream}
    Run Keyword If    '${stream}'=='SBTS00'   Set Fiber Switch Into linkup For RU
    ${scf_file}    Join Path    ${scf_path}    ${scf_file_name}
    run keyword if  not '${scf_file_name}'=='${None}'    Recommission With Backup SCF File    backup_scf_file=${scf_file}
    ...                                                   is_pdl_checking_needed=${is_pdl_checking_needed}
    ${status}    ${result}    Run Keyword And Ignore Error     COAM Wait For Gnb Ready And Cell Setup    timeout=25 min
    ${gNbCuType}    Get gNbCuType From SCF
    Set Suite Variable    ${gNbCuType}
    Set Suite Variable    ${SAVE LOG DIRECTORY}    ${SUITE_LOG_PATH}
    Wait Until Keyword Succeeds    300 sec   5 sec     Check Gnb Type Via Webui
    Verify All Used RU Type    ru_num=${ru_num}    ru_type=${ru_type}
    run keyword and ignore error    COAM Teardown gnb connections

2548 Suite Teardown
    run keyword and ignore error    COAM Teardown gnb connections

2548 Case Setup
    [Documentation]  Author:xiangyue.zhou@nokia-sbell.com
    Generate Test Case Log Path
    ${time_stamp}    Get Current Date    result_format=%Y%m%d%H%M%S
    Set Test Variable  ${TS_CASE_LOG_PATH}    ${TS_CASE_LOG_PATH}/${time_stamp}/
    Create Directory   ${TS_CASE_LOG_PATH}
    Set Test Variable    ${SAVE LOG DIRECTORY}    ${TS_CASE_LOG_PATH}
    Wait Until Keyword Succeeds    5 min    5 sec    Connect to Common Unit Master
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    COAM Check GNB cell on air
    Wait Until Keyword Succeeds    300 sec   5 sec     Check Gnb Type Via Webui
    ${exist_fault}    COAM Get active alarms
    Set test variable    ${exist_fault}
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist    allowed_faults=${exist_fault}

2548 Case Teardown
    [Documentation]  Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]     ${gnb_index}=0    ${du_index}=0    ${ru_index}=1
    Run Keyword And Ignore Error     Connect to gnb coam via ssl
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
#    Run Keyword And Continue On Failure    Unexpect History Alarm Should Not Exist
#    ...                                    allowed_faults=@{ALLOWED_HISTORY_FAULT}
    Run Keyword And Ignore Error   csn.disconnect    connection=ABIL Loner
    Run Keyword And Ignore Error   csn.disconnect    connection=RU
    Run Keyword And Ignore Error   csn.disconnect    connection=ABIL Slave
    Run Keyword And Ignore Error   csn.disconnect    connection=ABIL Master
    Run Keyword And Ignore Error   csn.disconnect    connection=ASIK Master
    run keyword and ignore error   COAM Teardown gnb connections
    Run Keyword And Ignore Error    run    command=ps -ef | grep firefox |awk '{print $2}' | xargs kill -9
    CI_interface.Common Case Teardown

Recovery Env If Test Case Failed
    [Documentation]  Author:xiangyue.zhou@nokia-sbell.com
    Run Keyword If Test Failed     Run Keyword And Ignore Error    Run Keywords    Perform BTS Site Reset    AND
    ...                            COAM Wait For Gnb Ready And Cell Setup    timeout=25 min

Restore Parameter If Test Case Failed
    [Documentation]  Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]     ${parameters_to_update_via_webui}=None     ${download_dir}=${TS_CASE_LOG_PATH}
    Run Keyword If Test Failed     Run Keyword And Ignore Error    Run Keyword    COAM Update several parameters via webUI
    ...                            parameters_to_update_via_webui=${parameters_to_update_via_webui}
    ...                            download_dir=${download_dir}
    ...                            is_gnb_restrat_after_online_modify=${True}
    Run Keyword And Ignore Error    COAM Wait For Gnb Ready And Cell Setup    timeout=25 min

Recover Cell If Test Case Failed
    [Arguments]    ${connection}=GNB_OAM
    ${cell_num}    RRH_common_keyword.COAM Get GNB CELL Number    connection=${connection}
    @{cell_list}    Create List
    FOR    ${cell_index}    IN RANGE    1    ${cell_num}+${1}
        Append To List    ${cell_list}    ${cell_index}
    END
    FOR    ${cell_idx}    IN    @{cell_list}
        ${cell_group_idx}    Evaluate    ${cell_idx}-1
        ${subcell_status}    Get Cell Status    cell_idx=${cell_idx}   cell_group_idx= ${cell_group_idx}
        ${subcell_admin_status}    Set Variable    ${subcell_status['administrativeState']}
        Run Keyword If    '${subcell_admin_status}'== 'Locked'    Run keywords
        ...       Perform cell unlock via rest api    cell_idx=${cell_idx}    AND
        ...       Wait Until Keyword Succeeds    600 sec    3 sec    Cell Should Be Unlocked    cell_idx=${cell_idx}
        ...       cell_group_idx=${cell_group_idx}    connection=${connection}
    END
    COAM Wait for gnb ready and cell setup    timeout=10 min    connection=${connection}

Check Btsom Log file on cluster
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]    ${alias}=asik_conn    ${logfolder}=fct-0a_aasyslog  ${filter}=None
    Connect to Common Unit Master     alias=${alias}
    ${status}    Run Keyword And Return Status    csn.assert file exists    /tmp/startup_BTSOM.log    connection=${alias}
    ${command}    Set Variable If    '${status}'=='True'    cat /tmp/startup_BTSOM.log |grep -i '${filter}'
    ...                              '${status}'=='False'    xzcat /ffs/run/logs/${logfolder}/startup_BTSOM.log.xz |grep -i '${filter}'
    ${output}    csn.execute    command=${command}    connection=${alias}
    csn.disconnect    connection=${alias}
    [Return]    ${output}

Check eCPRI Basic configuration via SOAP message
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]    ${alias}=asik_conn
    ${output}    5GC002548_Common.Check Btsom Log file on cluster    filter=API
#    Should Contain    ${output}    Sending API_L1SW_ECPRI_CONFIGURE_LINKS_REQ_MS
#    Should Contain    ${output}    Received API_L1SW_ECPRI_CONFIGURE_LINKS_RESP_MSG
    Should Contain    ${output}    Sending API_INET_VLAN_SET_REQ_MSG
    Should Contain    ${output}    Sending API_START_PTP_REQ_MSG
    Should Contain    ${output}    Received API_START_PTP_RESP_MSG with status EeCpriStatus_NoError

5GC000561_eCPRI_sync_counters
    [Documentation]   Sub-feature:5GC002548-BF
    Run Keyword And Continue On Failure    Wait until keyword succeeds    3X    60 s    Check RU Calibration Status And Power
    ${SyncMsg_Latest_value}    Get Transport Counters    counter_id=M40102C0
    ${status}    Run Keyword And Ignore Error    Should Be True    14398 <= ${SyncMsg_Latest_value} <= 14402
    Run Keyword IF    ${status}==${False}    Should Be True    28798 <= ${SyncMsg_Latest_value} <= 28802
    ${AnnMsg_Latest_value}    Get Transport Counters    counter_id=M40102C1
    ${status}    Run Keyword And Ignore Error    Should Be True    7198 <= ${AnnMsg_Latest_value} <= 7202
    Run Keyword IF    ${status}==${False}    Should Be True    14398 <= ${AnnMsg_Latest_value} <= 14402
    ${DelayRespMsg_Latest_value}    Get Transport Counters    counter_id=M40102C2
    ${DelayReqMsg_Latest_value}    Get Transport Counters    counter_id=M40102C3
    Should Be True    ${DelayRespMsg_Latest_value} == ${DelayReqMsg_Latest_value}
    ${SsmMsg_Latest_value}    Get Transport Counters    counter_id=M40102C4
    ${status}    Run Keyword And Ignore Error    Should Be True    898 <= ${SsmMsg_Latest_value} <= 902
    Run Keyword IF    ${status}==${False}    Should Be True    1798 <= ${SsmMsg_Latest_value} <= 1802

Set parameters via webUI
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]      ${parameters_to_update_via_webui}
    ...              ${download_dir}=${TS_CASE_LOG_PATH}
    ...              ${is_gnb_restrat_after_online_modify}=${False}
    COAM Navigate to login page via webUI    download_dir=${download_dir}
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    FOR  ${cur_para_to_update}  IN  @{parameters_to_update_via_webui}
        selenium_coam.set_parameter_value
        ...    abbr=${cur_para_to_update['abbr']}
        ...    dist_name=${cur_para_to_update['dist_name']}
        ...    filter_param=${cur_para_to_update['filter_param']}
        ...    new_value=${cur_para_to_update['new_value']}
    END

Validate And activate Plan
    [Documentation]     xiangyue.zhou@nokia-sbell.com
    [Arguments]    ${is_need_to_check_validation_errors}=False    ${activate_plan_despite_errors}=True
    selenium_coam.validate_plan
    COAM check validation errors from webui    is_need_to_check_validation_errors=${is_need_to_check_validation_errors}
    selenium_coam.activate_plan    activate_plan_despite_errors=${activate_plan_despite_errors}
    COAM selenium logout

Get Transport Counters
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]    ${counter_id}
    ...            ${download_dir}=${TS_CASE_LOG_PATH}
    COAM Navigate to login page via webUI    download_dir=${download_dir}
    ${counters}    selenium_coam.get_transport_counters    counter_id=${counter_id}
    ${values}    Get Dictionary Values   ${counters}
#    log  The latest one is: ${values[-1]}
    COAM selenium logout
    [Return]    ${values[-1]}

Get Bts Counters Info
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]    ${counter_id}
    ...            ${download_dir}=${TS_CASE_LOG_PATH}
    COAM Navigate to login page via webUI    download_dir=${download_dir}
    ${counters}    wait until keyword succeeds    10min    10s      selenium_coam.get_bts_counters_info    counter_id=${counter_id}
    ${values}    Get Dictionary Values   ${counters}
    COAM selenium logout
    [Return]    ${values[-1]}

Change Configuration and Commission
    [Arguments]    ${scf_file_name}=${None}    ${scf_path}=/home/ute/SCF    ${is_pdl_checking_needed}=${False}    ${asik_alais}=ASIK Master
    ${scf_file}    Join Path    ${scf_path}    ${scf_file_name}
    Wait Until Keyword Succeeds    3 min    5 sec    Connect To Gnb Coam Via SSL
    Connect to Common Unit Master    alias=${asik_alais}
    ${scf_file_name}    Get SCF File Name based on stream version    scf_file_name=${scf_file_name}
    ${scf_file}    Join Path    ${scf_path}    ${scf_file_name}
    Recommission With Backup SCF File    backup_scf_file=${scf_file}    is_pdl_checking_needed=${is_pdl_checking_needed}
    ${status}    ${result}    Run Keyword And Ignore Error     COAM Wait For Gnb Ready And Cell Setup    timeout=25 min

Get Syncin Type in Scf
    [Documentation]  Author:Zhou xiangyue
    [Arguments]   ${connection}=GNB_OAM
    ${sync_source_org}    coam_parameter.get_single_value_from_scf_file    parameter=syncInputType
    ...                           dist_name=MRBTS-${tl.gnbs[0].instance_id}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1
    ...                           connection=${connection}
    [Return]    ${sync_source_org}

Get x2LinkSupervisionTmr Value
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${nr_bts_id}=${tl.gnbs[0].global_bts_id}    ${connection}=GNB_OAM
    ${x2LinkSupervisionTmr}    coam_parameter.get_single_value_from_scf_file    parameter=x2LinkSupervisionTmr    dist_name=NRBTS-${nr_bts_id}
    ...                                                               connection=${connection}
    [Return]  ${x2LinkSupervisionTmr}

Update x2LinkSupervisionTmr Value
    [Documentation]   Auther: xiaoxia.hao@nokia-sbell.com
    [Arguments]    ${x2LinkSupervisionTmr}=1    ${connection}=GNB_OAM
    @{modify_list}    create list
    &{x2LinkSupervisionTmr_value}    Create Dictionary    dist_name=MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${nr_bts_id}
    ...                                                   parameter=x2LinkSupervisionTmr    value=${x2LinkSupervisionTmr}
    Append To List    ${modify_list}    ${x2LinkSupervisionTmr_value}
    COAM Update several parameters via rest api    parameters_to_update_via_api=${modify_list}    timeout=900
    coam wait for gnb ready and cell setup     timeout=15 min

Perform gNB Restart And Check on air via rest api
    [Documentation]    Auther:lei.jia@nokia-sbell.com
    ...                <<Keyword>> is to restart gnb one time and check gnb on air status.
    ...                Recommend to use this keywoed in TEST SETUP.
    [Arguments]    ${timeout}=600   ${connection}=GNB_OAM
    run keyword and ignore error    COAM Teardown gnb connections
    Connect to gnb coam via ssl    connection=${connection}
    coam.reset_site    wait_for_reconnection=${True}    timeout=${timeout}    connection=${connection}
    COAM Wait for gnb ready and cell setup    timeout=20 min

Adjust Attenuation To Trigger Peak Tput
    [Documentation]    Author:lei.jia@nokia-sbell.com
    [Arguments]       ${PA_value}=0
    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    value=${PA_value}   RU_id=0
    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    value=${PA_value}   RU_id=1
    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    value=${PA_value}   RU_id=2
    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    value=${PA_value}   RU_id=3
    gnb_classical_hangzhou.Modify All Attenuation Ports Value For Specific RU    value=${PA_value}   RU_id=4
    Sleep  2sec
