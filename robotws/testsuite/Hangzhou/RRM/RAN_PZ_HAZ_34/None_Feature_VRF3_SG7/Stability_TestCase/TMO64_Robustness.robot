*** Settings ***
Documentation
...    author: Lei XiaoJian
...    contact: damon.lei@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Suite Setup       Common Suite Setup And Setup BTS env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup        Common Test Setup And Start To Capture Logs
Test Teardown     Common Test Teardown And Stop Capture Logs
Force Tags        release-SBTS25R2    tl-7_5_UTE5G402T2464
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/DevHZ5_resource_ST.robot
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG8/resources/ST_robot/L3_call/DevHZ5_spark_ue.robot
Resource    ./resource/Common.robot
Resource    ./resource/Stability_TestCase_keywords.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot


*** Variables ***
${LOOP}    2
${lock_num}    2
${cell_lock_num}    3
${test_pc_addr}        ${tl.test_pc.default_ssh_connection_details.addr}
${test_pc_username}    ${tl.test_pc.default_ssh_connection_details.username}
${test_pc_password}    ${tl.test_pc.default_ssh_connection_details.password}

${gnb_addr}         ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${gnb_username}     ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${gnb_password}     ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}


*** Test Cases ***
TMO64_Robustness
    [Documentation]
    ...    Description:The purpose of this test case is for stability test
    [Tags]    R01
    FOR    ${id}    IN RANGE    1    ${LOOP}
        AlarmWatchdog.add_allow_alarms    fault_id=7107
        Lock All NG links
        Reset NR RAT
        Unlock All NG links
        Cells Should Be OnAir
        AlarmWatchdog.remove_allow_alarms    fault_id=7107
        Perform BBMOD Reset and Wait Cell OnAir
        Perform Gnb Reset and Wait Cell OnAir
        Perform RMOD Reset and Wait Cell OnAir
        Perform RMOD Lock and Unlock for multi times
        Perform Cell Lock Unlock multi times
    END

    [Teardown]    Run Keywords    Collect Snapshot self
    ...                           Common Test Teardown And Stop Capture Logs

*** Keywords ***
OnlineParamChange
    [Arguments]    ${Online_Param}
    Delta Commission Parameters    ${Online_Param}

Perform Gnb Reset and Wait Cell OnAir
        GNB Reset Site
        Cells Should Be OnAir

GNB Reset Site
    ${coam_conn}    coam.Connect To
    ${smod_info}=    coam.Reset Site    connection=${coam_conn}
    log    ${smod_info}
   [Teardown]    coam.Teardown    ${coam_conn}

Perform BBMOD Reset and Wait Cell OnAir
        Reset BBMODs
        Cells Should Be OnAir

Reset BBMODs
    ${coam_conn}    coam.Connect To
    ${fbb_info}=    coam.Get fbb info    connection=${coam_conn}
    FOR    ${fbb}    IN    @{fbb_info}
        coam.Reset Unit    ${fbb['id']['internal']}    reset_type=Warm    timeout=${300}    connection=${coam_conn}
    END
   [Teardown]    coam.Teardown    ${coam_conn}

Perform RMOD Lock and Unlock for multi times
    FOR    ${id}    IN RANGE    1    ${lock_num}
        Lock RMOD
        Unlock RMOD and cell onair
    END

Lock RMOD
    Delta Commission Parameters    ${DELTA_PARAS_RMOD_Lock}
    sleep    2s

Unlock RMOD and cell onair
    Delta Commission Parameters    ${DELTA_PARAS_RMOD_unlock}
    Cells Should Be OnAir

Perform RMOD Reset and Wait Cell OnAir
    Reset RMODs
    Cells Should Be OnAir

Perform Cell Lock Unlock multi times
    FOR    ${id}    IN RANGE    1    ${cell_lock_num}
        OnlineParamChange    ${DELTA_PARAS_Lock_Cell}
        OnlineParamChange    ${DELTA_PARAS_UnLock_Cell}
        Cells Should Be OnAir
    END

Perform NG link Lock Unlock and Wait Cell OnAir
    OnlineParamChange    ${DELTA_PARAS_Lock_NG_link}
    sleep    5s
    OnlineParamChange    ${DELTA_PARAS_UnLock_NG_link}
    Cells Should Be OnAir

Lock All NG links
    OnlineParamChange    ${DELTA_PARAS_Lock_NG_link}
    sleep    5s

Unlock All NG links
    OnlineParamChange    ${DELTA_PARAS_UnLock_NG_link}
    sleep    5s

Reset RMODs
    ${coam_conn}    coam.Connect To
    Set test variable    ${MRBTS_ID}    ${tl.gnbs[0].instance_id}
    ${ru_index_list}    Get All RU Index    connection=${coam_conn}
    FOR    ${index}    IN    @{ru_index_list}
        log to console    \n***RF Module index ${index} Reset via admin**
        ${RU_index}    Convert To Integer    ${index}
        coam.reset_unit    dist_name=MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-${RU_index}
        ...    force_radio_reset=${True}    timeout=${600}    connection=${coam_conn}
    END
   [Teardown]    coam.Teardown    ${coam_conn}

Collect Snapshot self
    [Arguments]  ${tag}=${EMPTY}
    ${bts_port}  ${use_ssl}  Define Admin Port
    Setup Admin  bts_port=${bts_port}  use_ssl=${use_ssl}  admin_api_log_dir=${SAVE LOG DIRECTORY}/admin_logs
    ...  timeout=120  bts_host=${FTM_IP}    alias=mky
    ${snapshot_dir}  Set Variable If  'startup' in '${tag}'  ${SAVE LOG DIRECTORY}/${tag}_logs
    ...  ${SAVE LOG DIRECTORY}
    Execute Cmd On Pc    df -h ${OUTPUT_DIR}    # 20G is needed for snapshot capturing according to PR722687
    Wait Until Keyword Succeeds    10x    1min    admin.Collect Snapshot  ${snapshot_dir}/snapshot.zip    connection=mky
    Execute Cmd On Pc    df -h ${OUTPUT_DIR}
    teardown_admin   connection=mky

Perform NR RAT Reset and Wait Cell OnAir
    ${coam_conn}    coam.Connect To
    ${smod_info}=    coam.reset_rat     rat_type=NR    connection=${coam_conn}    timeout=600
    Cells Should Be OnAir
    [Teardown]    coam.Teardown    ${coam_conn}

Reset NR RAT
    ${coam_conn}    coam.Connect To
    ${smod_info}=    coam.reset_rat     rat_type=NR    connection=${coam_conn}    timeout=600
    [Teardown]    coam.Teardown    ${coam_conn}
