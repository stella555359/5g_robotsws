*** Settings ***
Documentation
...   author: Liu Zheng
...   contact: zheng.4.liu@nokia-sbell.com
...   squad group: SG_04
...   Feature 5GC001596 in 5G19B program

Resource     ./5GC001596_D_Variables.robot
Resource     testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/common_resources.robot
Variables    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/lib/defult_testline_scf.py
Variables    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/lib/NIDD_modify_merge_scf.py

*** Variables ***
&{fault_10}       faultId=${10}    source=RMOD_R-1    severity=Critical    # No connection to unit
&{fault_61524}    faultId=${61524}    #faultId:SSH_ENABLED  source:RU1
&{fault_61652}    faultId=${61652}    #faultId:R&D_SERVICE_PORT_ENABLED  source:RU1
&{fault_9000}    faultId=${9000}    source=SMOD_R-1    #faultId:BTS booted due to software restart  source:RU1
&{fault_7319}    faultId=${7319}     #faultId:EFaultId_X2LinkNotAvailableAl
&{fault_7300}    faultId=${7300}     #faultId:EFaultId_NoneX2LinkAvailableAl
&{fault_4527}    faultId=${4527}    source=RMOD_R-1    #Radio diagnostic files collected
&{fault_4654}    faultId=${4654}    source=SMOD_R-1     #Ethernet port security is disabled
&{fault_4655}    faultId=${4655}    #Service account root access is enabled
&{fault_61649}    faultId=${61649}    source=SMOD       #LMP access via port 443
@{ALLOWED_FAULT_LIST}    &{fault_61524}    &{fault_61652}    &{fault_9000}    &{fault_4527}    &{fault_4654}    &{fault_4655}    &{fault_61649}


*** Keywords ***
Case preparation with btslog collection
    [Documentation]    Author: Liu Zheng
    ...                makesure the log_dir have the correct user name and user group.
    ...                e.g. sudo chown -R ute:ute /tmp
    [Arguments]    ${name}=btslog    ${btslog_path}=/opt/btslog/btslog    ${btslog_launcher_path}=/opt/btslog/btslog_launcher
    ...    ${log_dir}=/tmp/btslog2    ${host}=${tl.test_pc.default_ssh_connection_details.addr}
    ...    ${is_btslog_required}=${True}
    ...    ${is_alias_created}=${True}
    ...    ${if_create_ru_alias_needed}=${False}
    Common case setup    is_btslog_required=${is_btslog_required}    is_alias_created=${is_alias_created}
#    ...    if_create_ru_alias_needed=${if_create_ru_alias_needed}
    run keyword if    ${if_create_ru_alias_needed}    Create alias for case setup temp

Case env recovery with btslog collection
    [Documentation]    Author: Liu Zheng
    [Arguments]    ${operation}=${None}    ${is_need_to_wait_cluster_ready}=${True}
    [Timeout]    15 min
    Collect logs in teardown    is_btslog_required=${True}
    Recovery env if case failed with operations    operation=${operation}    ru_index=${1}    cell_index=${1}    cell_group_index=${0}
    Case env recovery common    is_need_to_wait_cluster_ready=${is_need_to_wait_cluster_ready}    is_all_cells_checking_needed=${True}

Create alias for case setup temp
    [Documentation]  Author: Wang Yixiang
    ...              for case setup
    [Arguments]    ${ru}=${1}    ${connection}=GNB_OAM    ${du_index}=${0}    ${du_alias}=ASIK Master
    Connect to Common Unit Master    du_index=${du_index}    alias=${du_alias}
    run keyword and ignore error
    ...    Connect to Capacity Unit Loner    alias=ABIL Loner_1
    @{RUS_ALIAS}    Create list
    ${ru_index_list}    string2list    ${ru}
    FOR    ${ru_index}    IN    @{ru_index_list}
      Connect to RU With Allocated IP    ru_index=${ru_index}    ru_alias=RU_${ru_index}
      ...    asik_alias=${du_alias}    connection=${connection}
      Append to list    ${RUS_ALIAS}    RU_${ru_index}
    END
    Set suite variable    ${RUS_ALIAS}
    Connect to Capacity Unit Slave

Case preparation with btslog collection for L3call
    [Documentation]    Author: Liu Zheng
    ...                makesure the log_dir have the correct user name and user group.
    ...                e.g. sudo chown -R ute:ute /tmp
    [Arguments]    ${name}=btslog    ${btslog_path}=/opt/btslog/btslog    ${btslog_launcher_path}=/opt/btslog/btslog_launcher
    ...    ${log_dir}=/tmp/btslog2    ${host}=${tl.test_pc.default_ssh_connection_details.addr}    ${is_btslog_required}=${True}
    ...    ${is_alias_created}=${False}
    ...    ${if_create_ru_alias_needed}=${False}
    Common case setup    is_btslog_required=${is_btslog_required}    is_alias_created=${is_alias_created}
#    ...    if_create_ru_alias_needed=${if_create_ru_alias_needed}
    run keyword if    ${if_create_ru_alias_needed}    Create alias for case setup temp
    ${lncelid_enb}    Get lncelid on enb
    Set test variable    ${LNCELID}    ${lncelid_enb}
    Get the ENB actDynTrigLteNrDualConnectivity and defaultLnRelGnbCellId and set them to test variable
    Run keyword and ignore error    Close iperf progress

Case env recovery with btslog collection for L3call
    [Documentation]    Author: Liu Zheng
    [Arguments]    ${operation}=${None}    ${is_need_to_wait_cluster_ready}=${True}    ${para_update_timeout}=${TIMEOUT_MODIFY_PARA}
    ...    ${is_btslog_required}=${True}
    [Timeout]    15 min
    Collect logs in teardown    is_btslog_required=${is_btslog_required}
    Run keyword and ignore error    SISO_Pre.Close iperf progress
    power_ue.UE Detach    ue_type=${UE_TYPE}
    Recovery env for many sectors if case failed with operations    operation=${operation}
    Run keyword if    '${TEST STATUS}' == 'FAIL'    Recover the ENB actDynTrigLteNrDualConnectivity and defaultLnRelGnbCellId back to default
    Case env recovery common    is_need_to_wait_cluster_ready=${is_need_to_wait_cluster_ready}    is_all_cells_checking_needed=${True}
    Run keyword and ignore error    Tear down all SISO connections

Recovery env for many sectors if case failed with operations
    [Documentation]    Author: Liu Zheng
    ...                Description: Intergration all recovery actions if case with operations failed
    ...                ${operation}: Supported values:  cell_group_unlock, cell_unlock, ru_unlock, ru_power_on, site_power_on
    ...                              if filled with other values, then no recovery action is needed
    [Arguments]    ${operation}=${None}
    Connect to gnb coam via ssl
    Run keyword if    '${TEST STATUS}' == 'FAIL' and '${operation}' == 'cell_group_unlock'
    ...        Recovery for all cell groups    operation=${operation}
    ...    ELSE IF    '${TEST STATUS}' == 'FAIL' and '${operation}' == 'cell_unlock'
    ...        Check cells status and recover them if necessary    operation=${operation}
    ...    ELSE IF    '${TEST STATUS}' == 'FAIL' and '${operation}' == 'ru_unlock'
    ...        Check RUs status and recover them if necessary    operation=${operation}
    ...    ELSE IF    '${TEST STATUS}' == 'FAIL' and '${operation}' == 'site_power_on'
    ...        Perform Site Power On
    ...    ELSE    Log to console    No recovery action needed for operation ${operation}
    [Teardown]   coam_gnb_classical.COAM Teardown gnb connections

Recovery for all cell groups
    [Documentation]    Author: Liu Zheng
    [Arguments]    ${operation}=${None}
    FOR    ${cellgrp_index}    IN    @{CELLGRP_INDEX_LIST}
        Recovery env if case failed with operations    operation=${operation}    cell_group_index=${cellgrp_index}
    END

Check cells status and recover them if necessary
    [Documentation]    Author: Liu Zheng
    [Arguments]    ${operation}=${None}
    ${status}    run keyword and return status    Verify all cells should be onair
    run keyword if    ${status}==${False}    Recovery for all cells    operation=${operation}

Recovery for all cells
    [Documentation]    Author: Liu Zheng
    [Arguments]    ${operation}=${None}
    FOR    ${cell_index}    IN    @{CELL_INDEX_LIST}
        Recovery env if case failed with operations    operation=${operation}    cell_index=${cell_index}
    END

Check RUs status and recover them if necessary
    [Documentation]    Author: Liu Zheng
    [Arguments]    ${operation}=${None}
    ${status}    run keyword and return status    COAM Check GNB RU status    connection=GNB_OAM
    run keyword if    ${status}==${False}    Recovery for all RUs    operation=${operation}

Recovery for all RUs
    [Documentation]    Author: Liu Zheng
    [Arguments]    ${operation}=${None}
    FOR    ${ru_index}    IN    @{RU_INDEX_LIST}
        Recovery env if case failed with operations    operation=${operation}    ru_index=${ru_index}
    END

Get the ENB actDynTrigLteNrDualConnectivity and defaultLnRelGnbCellId and set them to test variable
    [Documentation]    Author: Liu Zheng
    [Arguments]    ${alias}=enblte
    Connect to eNB via ssl    connection=${alias}
    ${actDynTrigLteNrDualConnectivity_default}    Get NIDD parameter value    class_name=LNBTS_A    pattern=actDynTrigLteNrDualConnectivity
    ...     connection=${alias}
    ${defaultLnRelGnbCellId_default}    Get NIDD parameter value    class_name=LNCEL_A    pattern=defaultLnRelGnbCellId     connection=${alias}
    ${actDynTrigLteNrDualConnectivity_default}    convert to string    ${actDynTrigLteNrDualConnectivity_default}
    ${actDynTrigLteNrDualConnectivity_default}    convert to lowercase    ${actDynTrigLteNrDualConnectivity_default}
    ${defaultLnRelGnbCellId_default}    convert to string    ${defaultLnRelGnbCellId_default}
    Set test variable    ${ACTDYNTRIGLTENRDUALCONNECTIVITY_DEFAULT}    ${actDynTrigLteNrDualConnectivity_default}
    Set test variable    ${DEFAULTLNRELGNBCELLID_DEGAULT}    ${defaultLnRelGnbCellId_default}
    [Teardown]    Enblte close down    connection=${alias}

Recover the ENB actDynTrigLteNrDualConnectivity and defaultLnRelGnbCellId back to default
    [Documentation]    Author: Liu Zheng
    [Arguments]    ${para_update_timeout}=${TIMEOUT_MODIFY_PARA}    ${alias}=enblte
    Connect to eNB via ssl    connection=${alias}
    &{actDynTrigLteNrDualConnectivity}    Create Dictionary    dist_name=LNBTS-${tl.enbs[0].global_bts_id}
    ...    parameter=actDynTrigLteNrDualConnectivity    value=${ACTDYNTRIGLTENRDUALCONNECTIVITY_DEFAULT}
    @{modify_adtlndc}    Evaluate   [&{actDynTrigLteNrDualConnectivity}]
    &{defaultLnRelGnbCellId}    Create Dictionary    dist_name=LNBTS-${tl.enbs[0].global_bts_id}/LNCEL-${LNCELID}
    ...    parameter=defaultLnRelGnbCellId    value=${DEFAULTLNRELGNBCELLID_DEGAULT}
    @{modify_dlrgci}     Evaluate    [&{defaultLnRelGnbCellId}]
    ${update_status}    COAM Update several parameters via rest api
    ...    connection=${alias}     parameters_to_update_via_api=${modify_adtlndc}    timeout=${para_update_timeout}
    Should be true    '${update_status}'=='PASS'
    ${update_status}    COAM Update several parameters via rest api
    ...    connection=${alias}     parameters_to_update_via_api=${modify_dlrgci}    timeout=${para_update_timeout}
    Should be true    '${update_status}'=='PASS'
    [Teardown]    Enblte close down    connection=${alias}

Case env recovery for update nidd parameters
    [Documentation]    Author: Liu Zheng
    [Arguments]    ${connection}=GNB_OAM    ${timeout}=${TIMEOUT_MODIFY_PARA}    ${is_need_to_wait_cluster_ready}=${True}
    Collect logs in teardown    is_btslog_required=${True}
    Wait Until Keyword Succeeds     ${RECOVERY_TIMEOUT}    2 sec    Connect to gnb coam via ssl    connection=${GNB_COAM_ALIAS}
    Run keyword if    '${TEST STATUS}' == 'FAIL'    Update prachConfigurationIndex back to default    connection=${connection}    timeout=${timeout}
    Case env recovery common    is_need_to_wait_cluster_ready=${is_need_to_wait_cluster_ready}    is_all_cells_checking_needed=${True}

Update prachConfigurationIndex back to default
    [Documentation]    Author: Liu Zheng
    [Arguments]    ${connection}=GNB_OAM    ${timeout}=${TIMEOUT_MODIFY_PARA}    ${prachconindex_default}=${PRACHCONFIGRATIONINDEX_DEFAULT}
    ${cell_list_gnb}    Get cell list for GNB
    ${length}    Get length    ${cell_list_gnb}
    FOR    ${index}    IN RANGE    ${length}
        Update prachConfigurationIndex back to default for cell in cell group    cell_list_in_cellgrp=${cell_list_gnb[${index}]}
        ...    connection=${connection}    timeout_modify_para=${timeout}    prachconindex_default=${prachconindex_default}
    END

Update prachConfigurationIndex back to default for cell in cell group
    [Documentation]    Author: Liu Zheng
    ...    2020-03-10: [Cui Lingxue] add verification for gNB reset
    [Arguments]    ${cell_list_in_cellgrp}    ${connection}=GNB_OAM    ${timeout_modify_para}=${TIMEOUT_MODIFY_PARA}
    ...    ${prachconindex_default}=${PRACHCONFIGRATIONINDEX_DEFAULT}
    FOR  ${cell}  IN   @{cell_list_in_cellgrp}
        &{prachConfigurationIndex_default}    Create Dictionary    dist_name=NRBTS-${tl.gnbs[0].global_bts_id}/${cell}
        ...    parameter=prachConfigurationIndex    value=${prachconindex_default}
        @{modify_prachConfigurationIndex_default}    Evaluate   [&{prachConfigurationIndex_default}]
         ${update_status}    COAM Update several parameters via rest api
        ...    parameters_to_update_via_api=${modify_prachConfigurationIndex_default}    timeout=${timeout_modify_para}
        ...    connection=${connection}
        Run keyword and continue on failure    Should be equal as strings    ${update_status}    PASS
    END
    Perform BTS Site Reset  download_dir=${TS_CASE_LOG_PATH}
    Wait until keyword succeeds    5 min    2 sec    Verify ASIK is disconnected


Update prachConfigurationIndex and check fault 7506 for each cell
    [Documentation]    author: Liu Zheng
    [Arguments]    ${timeout_modify_para}=${TIMEOUT_MODIFY_PARA}    ${prachconindex_default}=${PRACHCONFIGRATIONINDEX_DEFAULT}
    ...    ${cell_list}=${CELL_LIST}
    Update PrachConfigurationIndex for all cells    prachconindex_value=0    timeout_modify_para=${timeout_modify_para}    cell_list=${cell_list}
    Fault 7506 check for all cells    is_present=${True}    is_one_time_check=${False}    cell_list=${cell_list}
    Repeat keyword     2 minutes    Fault 7506 check for all cells    is_present=${True}    is_one_time_check=${True}    cell_list=${cell_list}
    Update PrachConfigurationIndex for all cells    prachconindex_value=${prachconindex_default}    timeout_modify_para=${timeout_modify_para}
    ...    cell_list=${cell_list}
    Perform BTS Site Reset  download_dir=${TS_CASE_LOG_PATH}
    Wait until keyword succeeds    5 min    2 sec    Verify ASIK is disconnected
    Wait until cluster is on cell on air status    timeout=${RECOVERY_TIMEOUT}    is_all_cells_checking_needed=${True}
    ...    gnb_ps_cell_list=${GNB_PS_CELL_INDEX_LIST}
    Fault 7506 check for all cells    is_present=${False}    cell_list=${cell_list}


Update PrachConfigurationIndex for all cells
    [Arguments]    ${prachconindex_value}    ${timeout_modify_para}=${TIMEOUT_MODIFY_PARA}    ${cell_list}=${CELL_LIST}
    @{modify_prachConfigurationIndex}    create list
    FOR  ${cell}  IN   @{cell_list}
        &{prachConfigurationIndex}    Create Dictionary    dist_name=NRBTS-${tl.gnbs[0].global_bts_id}/${cell}
        ...    parameter=prachConfigurationIndex    value=${prachconindex_value}
        append to list   ${modify_prachConfigurationIndex}    ${prachConfigurationIndex}
    END
    ${update_status}    COAM Update several parameters via rest api
    ...    parameters_to_update_via_api=${modify_prachConfigurationIndex}    timeout=${timeout_modify_para}    connection=${GNB_COAM_ALIAS}
    Run keyword and continue on failure    Should be equal as strings    ${update_status}    PASS

Fault 7506 check for all cells
    [Arguments]    ${is_present}=${True}    ${is_one_time_check}=${True}    ${cell_list}=${CELL_LIST}
    FOR  ${cell}  IN   @{cell_list}
        &{fault_7506}     Create Dictionary    faultId=${7506}    alarmId=${7114}    severity=Critical    configObjectName=${cell}
        Run keyword if    '${is_present}' == '${True}' and '${is_one_time_check}' == '${True}'    Run keyword and continue on failure
        ...    Expect Fault Should Present    faultId=${fault_7506['faultId']}    configObjectName=${fault_7506['configObjectName']}
        ...    severity=${fault_7506['severity']}    connection=${GNB_COAM_ALIAS}
        ...    ELSE IF    '${is_present}' == '${True}' and '${is_one_time_check}' == '${False}'    Run keyword and continue on failure
        ...    Wait until keyword succeeds    1 min    1 sec    Expect Fault Should Present
        ...    faultId=${fault_7506['faultId']}    configObjectName=${fault_7506['configObjectName']}
        ...    severity=${fault_7506['severity']}    connection=${GNB_COAM_ALIAS}
        ...    ELSE    Run keyword and continue on failure    Wait until keyword succeeds     1 min    5 sec    Expect Fault Should Absent
        ...    faultId=${fault_7506['faultId']}    connection=${GNB_COAM_ALIAS}
    END

Perform BTS site reset and get the reset time epoch
    [Documentation]   Author: Liu Zheng
    [Arguments]   ${download_dir}=${TS_CASE_LOG_PATH}
    COAM Navigate to login page via webUI   download_dir=${download_dir}
    ${reset_time_epoch}    DateTime.get current date    result_format=epoch    exclude_millis=True
    selenium_coam.reset_site
    ${is_startup_window_exist}=      selenium_coam.start_up_view_window_exists
    Run Keyword If    ${is_startup_window_exist}    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window
    Run Keyword And Ignore Error    selenium_coam.logout
    Wait until keyword succeeds    5 min    2 sec    Verify ASIK is disconnected
    [Teardown]    Run Keyword And Ignore Error    selenium_coam.logout
    [Return]    ${reset_time_epoch}

Perform cell lock unlock and check throughput for many cells many times
    [Documentation]    author: Liu Zheng
    ...   the ${duration time} is traffic time, it can be largr number to make the traffic go on
    ...   because there is kill process if need to stop traffic.
    [Arguments]    ${cell_index_list}=${CELL_INDEX_LIST}    ${repeat_times}=${TEST_REPEAT_TIMES}    ${para_update_timeout}=${TIMEOUT_MODIFY_PARA}
    ...    ${duration_time}=${3000}    ${verify_duration}=${30}    ${ul_exp_tput}=${UL_EXPECT}
    ...    ${dl_exp_tput}=${DL_EXPECT}    ${connection}=GNB_OAM    ${ignore_time}=${30}
    FOR    ${cell_index}    IN    @{cell_index_list}
        Perform cell lock unlock and check throughput for many times    cell_index=${cell_index}    repeat_times=${repeat_times}
        ...    para_update_timeout=${para_update_timeout}    duration_time=${duration_time}    verify_duration=${verify_duration}
        ...    ul_exp_tput=${ul_exp_tput}    dl_exp_tput=${DL_EXPECT}    ignore_time=${ignore_time}
    END

Perform cell lock unlock and check throughput for many times
    [Documentation]    author: Liu Zheng
    ...    ${GNB_PS_CELL_INDEX_LIST} is the cell list which can do attach. it is set in variables.robot.
    [Arguments]    ${cell_index}    ${repeat_times}=${TEST_REPEAT_TIMES}
    ...   ${para_update_timeout}=${TIMEOUT_MODIFY_PARA}
    ...    ${duration_time}=${3000}    ${verify_duration}=${30}    ${ul_exp_tput}=${UL_EXPECT}
    ...    ${dl_exp_tput}=${DL_EXPECT}    ${connection}=GNB_OAM    ${ignore_time}=${30}
    ${cell_mapping}    coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids
    ${cellgrp_idx}    set variable    ${cell_mapping[${cell_index}]['cell_group_id']}
    FOR    ${run_time}    IN RANGE    ${repeat_times}
        Perform cell lock via rest api    cell_idx=${cell_index}
        Wait Until Keyword Succeeds    90 sec    3 sec    Cell Should Be Locked    cell_idx=${cell_index}    cell_group_idx=${cellgrp_idx}
        Perform cell unlock via rest api    cell_idx=${cell_index}
        Wait Until Keyword Succeeds    5 min    3 sec     Cell Should Be Unlocked    cell_idx=${cell_index}        cell_group_idx=${cellgrp_idx}
        Wait until cluster is on cell on air status    timeout=${RECOVERY_TIMEOUT}    is_all_cells_checking_needed=${True}
        ...    gnb_ps_cell_list=${GNB_PS_CELL_INDEX_LIST}
        Run keyword if    '${cell_index}' in @{GNB_PS_CELL_INDEX_LIST}
        ...    Call case with QCOM UE and record throughput info on specific cell for many times    repeat_times=${1}
        ...    gnb_ps_cell_index=${cell_index}    para_update_timeout=${para_update_timeout}    verify_duration=${verify_duration}
        ...    duration_time=${duration_time}    ul_exp_tput=${ul_exp_tput}    dl_exp_tput=${dl_exp_tput}    ignore_time=${ignore_time}
    END

Perform cell group lock unlock and check throughput for many cell group many times
    [Documentation]    author: Liu Zheng
    ...   the ${duration time} is traffic time, it can be largr number to make the traffic go on
    ...   because there is kill process if need to stop traffic.
    [Arguments]    ${cellgrp_index_list}=${CELLGRP_INDEX_LIST}    ${para_update_timeout}=${TIMEOUT_MODIFY_PARA}
    ...    ${duration_time}=${3000}     ${verify_duration}=${30}    ${ul_exp_tput}=${UL_EXPECT}
    ...    ${dl_exp_tput}=${DL_EXPECT}    ${repeat_times}=${TEST_REPEAT_TIMES}    ${connection}=GNB_OAM
    FOR    ${cellgrp_index}    IN    @{cellgrp_index_list}
        Perform cell group lock unlock and check throughput for many times    cellgrp_index=${cellgrp_index}
        ...    para_update_timeout=${para_update_timeout}    duration_time=${duration_time}
        ...    ul_exp_tput=${UL_EXPECT}    dl_exp_tput=${DL_EXPECT}    repeat_times=${repeat_times}    connection=${connection}
        ...    verify_duration=${verify_duration}
    END

Perform cell group lock unlock and check throughput for many times
    [Documentation]    author: Liu Zheng
    [Arguments]    ${cellgrp_index}    ${para_update_timeout}=${TIMEOUT_MODIFY_PARA}    ${duration_time}=${3000}
    ...    ${verify_duration}=${30}    ${ul_exp_tput}=${UL_EXPECT}    ${dl_exp_tput}=${DL_EXPECT}    ${repeat_times}=${TEST_REPEAT_TIMES}
    ...    ${connection}=GNB_OAM
    FOR    ${run_time}    IN RANGE    ${repeat_times}
        Perform cell group lock unlock    cellgrp_index=${cellgrp_index}
        Call case with QCOM UE and record throughput info for many cells many times   para_update_timeout=${para_update_timeout}
        ...    repeat_times=${1}    duration_time=${duration_time}    verify_duration=${verify_duration}
        ...    ul_exp_tput=${ul_exp_tput}    dl_exp_tput=${dl_exp_tput}    cell_index_list=${GNB_PS_CELL_INDEX_LIST}
    END

Perform cell group lock unlock
    [Documentation]    author: Liu Zheng
    ...    when sbts common load branch out, there was no lock unlock cell group button.
    ...    on 2021/9/26, there are only 21B, master and 22R1 regression.
    ...    then not able to check the cellgroup status by checking the button status.
    [Arguments]    ${cellgrp_index}        ${timeout}=${120}
    Perform cell group lock via rest api    cellgrp_idx=${cellgrp_index}
#    Perform Cell Group Lock    cell_group_idx=${cellgrp_index}
#    Run keyword unless    '${PROGRAM}' == 'master' or '${PROGRAM}' == '21B'
#    ...    Wait Until Keyword Succeeds    90 sec    3 sec    Cell Group Should Be Locked    cell_group_idx=${cellgrp_index}    timeout=${timeout}
    Wait Until Keyword Succeeds    3 min    5 sec    Verify cells in specific cell group should be disabled    cellgrp_index=${cellgrp_index}
    Perform cell group unlock via rest api    cellgrp_idx=${cellgrp_index}
#    Perform Cell Group Unlock    cell_group_idx=${cellgrp_index}
#    Run keyword unless    '${PROGRAM}' == 'master' or '${PROGRAM}' == '21B'
#    ...    Wait Until Keyword Succeeds    90 sec    3 sec    Cell Group Should Be Unlocked    cell_group_idx=${cellgrp_index}    timeout=${timeout}
    Wait until cluster is on cell on air status    timeout=${RECOVERY_TIMEOUT}    is_all_cells_checking_needed=${True}
    ...    gnb_ps_cell_list=${GNB_PS_CELL_INDEX_LIST}

Perform ru lock unlock and check throughput for many ru many times
    [Documentation]    author: Liu Zheng
    ...                attach to only one sector, no matter operate on any RU, the call still on the same sector.
    ...   the ${duration time} is traffic time, it can be largr number to make the traffic go on
    ...   because there is kill process if need to stop traffic.
    [Arguments]    ${ru_index_list}=${RU_INDEX_LIST}    ${para_update_timeout}=${TIMEOUT_MODIFY_PARA}     ${duration_time}=${3000}
    ...    ${verify_duration}=${30}    ${ul_exp_tput}=${UL_EXPECT}    ${dl_exp_tput}=${DL_EXPECT}
    ...    ${repeat_times}=${TEST_REPEAT_TIMES}    ${connection}=GNB_OAM
    ...    ${alarm_check_needed}=${False}    ${allowed_fault_list}=${ALLOWED_FAULT_LIST}
    ...    ${ignore_time}=${30}
    FOR    ${ru_index}    IN    @{ru_index_list}
        Perform ru lock unlock and check throughput for many times    ru_index=${ru_index}    para_update_timeout=${para_update_timeout}
        ...    duration_time=${duration_time}    ul_exp_tput=${ul_exp_tput}    dl_exp_tput=${dl_exp_tput}
        ...    repeat_times=${repeat_times}    connection=${connection}    verify_duration=${verify_duration}
        ...    alarm_check_needed=${alarm_check_needed}    allowed_fault_list=${allowed_fault_list}
        ...    ignore_time=${ignore_time}
    END

Perform ru lock unlock and check throughput for many times
    [Documentation]    author: Liu Zheng
    [Arguments]    ${ru_index}   ${para_update_timeout}=${TIMEOUT_MODIFY_PARA}    ${duration_time}=${3000}
    ...    ${verify_duration}=${30}    ${ul_exp_tput}=${UL_EXPECT}    ${dl_exp_tput}=${DL_EXPECT}    ${repeat_times}=${TEST_REPEAT_TIMES}
    ...    ${connection}=GNB_OAM    ${alarm_check_needed}=${False}    ${allowed_fault_list}=${ALLOWED_FAULT_LIST}
    ...    ${ignore_time}=${30}
    FOR    ${run_time}    IN RANGE    ${repeat_times}
        Perform ru lock unlock    ru_index=${ru_index}    alarm_check_needed=${alarm_check_needed}    allowed_fault_list=${allowed_fault_list}
        Call case with QCOM UE and record throughput info for many cells many times   para_update_timeout=${para_update_timeout}
        ...    duration_time=${duration_time}    ul_exp_tput=${ul_exp_tput}    dl_exp_tput=${dl_exp_tput}
        ...    repeat_times=${1}    cell_index_list=${GNB_PS_CELL_INDEX_LIST}    verify_duration=${verify_duration}
        ...    ignore_time=${ignore_time}
    END

Perform ru lock unlock
    [Documentation]    author: Liu Zheng
    [Arguments]    ${ru_index}    ${alarm_check_needed}=${False}    ${allowed_fault_list}=${ALLOWED_FAULT_LIST}
    Run keyword if    ${alarm_check_needed}
    ...    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=${allowed_fault_list}
    ${cellgrp_index}    evaluate    ${ru_index}-1
    Perform RU lock via rest api    ru_idx=${ru_index}
    Wait Until Keyword Succeeds    2 min    3 sec    RU Should Be Locked    ru_index=${ru_index}
    Wait Until Keyword Succeeds    3 min    5 sec    Verify cells in specific cell group should be disabled    cellgrp_index=${cellgrp_index}
    Run keyword if    ${alarm_check_needed}    Alarm check after lock RU    allowed_fault_list=${allowed_fault_list}
    Perform RU unlock via rest api    ru_idx=${ru_index}
    Wait Until Keyword Succeeds    4 min   3 sec     RU Should Be Unlocked    ru_index=${ru_index}
    Wait until cluster is on cell on air status    timeout=${RECOVERY_TIMEOUT}    is_all_cells_checking_needed=${True}
    ...    gnb_ps_cell_list=${GNB_PS_CELL_INDEX_LIST}    enb_index=${ENB_INDEX}
    Run keyword if    ${alarm_check_needed}
    ...    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=${allowed_fault_list}

Verify cells in specific cell group should be disabled
    [Documentation]    Author: Liu Zheng
    [Arguments]    ${cellgrp_index}=0    ${connection}=GNB_OAM
    ${sw_version}     coam.get_sw_version    connection=${connection}
    ${result}    run keyword and return status    should contain any
    ...    ${sw_version}
    ...    12.400    14.400    22R1    22R2    21B
    ${disabled}    Set Variable If    ${result}    Disabled    disabled
    ${cell_info}   coam.get_subcells_status   timeout=20    connection=${connection}
    ${cell_from_cellgrp}    Get from Dictionary    ${cell_info}    NRCELLGRP-${cellgrp_index}
    ${cell_list}    Get Dictionary Keys    ${cell_from_cellgrp}
    FOR  ${cell}  IN   @{cell_list}
        ${eachcell}    Get from Dictionary    ${cell_from_cellgrp}    ${cell}
        Run keyword and continue on failure    Should Be Equal As Strings    ${eachcell['NRCELL_R']['operationalState']}   ${disabled}
    END

Alarm check after lock RU
    [Documentation]    Author: Liu Zheng
    [Arguments]    ${allowed_fault_list}=${ALLOWED_FAULT_LIST}
    Wait For Expect Fault Present   faultId=${fault_7300['faultId']}   timeout=300
    ${allowed_faults}   Create List   @{allowed_fault_list}   ${fault_7319}   ${fault_7300}
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=${allowed_faults}


get nrarfcn for specific cell
    [Arguments]    ${cell_index}=1    ${connection_alias}=GNB_OAM
    &{cell_index_info_mapping}    coam_gnb_classical.get_relation_mapping_between_cell_index_and_cell_info    connection_alias=GNB_OAM
    ${nrarfcn}    set variable    ${cell_index_info_mapping[${cell_index}]['nrarfcn']}
    [Return]    ${nrarfcn}

update nrarfcn should success
    [Arguments]    ${nrarfcn}    ${cell_index}=1
    ${nrarfcn}    convert to string    ${nrarfcn}
    &{nrarfcn_para}    Create Dictionary    dist_name=NRBTS-${tl.gnbs[0].global_bts_id}/NRCELL-${cell_index}
    ...    parameter=nrarfcn    value=${nrarfcn}
    @{modify_nrarfcn}     Evaluate    [&{nrarfcn_para}]
    ${update_status}    COAM Update several parameters via rest api
    ...    parameters_to_update_via_api=${modify_nrarfcn}    timeout=${TIMEOUT_MODIFY_PARA}    connection=${GNB_COAM_ALIAS}
    Run keyword and continue on failure    should contain Any    ${update_status}    PASS    RESET_PASS

Cell number should be as expected
    [Documentation]    Author: Liu Zheng
    [Arguments]    ${expect_cell_number}    ${connection}=GNB_OAM
    ${cell_index_list}    Get all cell index list
    Sort List    ${cell_index_list}
    ${length}    Get length    ${cell_index_list}
    Should be true    ${length}==${expect_cell_number}
    ...    msg=Current cell number is ${length}, but expect ${expect_cell_number}, cell number is not as expected. Please check.

Suite env recovery
    [Documentation]    author: Liu Zheng
    [Timeout]    20 min
    Connect to gnb coam via ssl
    Connect to Common Unit Master    alias=${ASIK_ALIAS}
    Run keyword and continue on failure      swconf.Restore swConfig file on asik and crasign    asik_alias=${ASIK_ALIAS}
#    Run keyword if    '${SUITE STATUS}' == 'FAIL'    COAM Save snapshot via webUI    download_dir=${SUITE_LOG_PATH}
    Run keyword if    '${SUITE STATUS}' == 'FAIL'    COAM Save snapshot via rest api    log_path=${SUITE_LOG_PATH}    timeout=960s
    Tear down all SISO connections
