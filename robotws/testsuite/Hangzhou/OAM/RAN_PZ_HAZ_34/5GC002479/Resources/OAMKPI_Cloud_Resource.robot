*** Settings ***
Resource          OAMKPI_Base_Resource.robot
Documentation
...    Author:
...    Contact:
...    squad
...    Feature
*** Variables ***

${CU_ssh_IP}                ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}
${CU_username}              ${tl.gnbs[0].cu.oam_ssh_connection_details.username}
${CU_password}              ${tl.gnbs[0].cu.oam_ssh_connection_details.password}
${DU_ssh_IP}                ${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.addr}
${DU_username}              ${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.username}
${DU_password}              ${tl.gnbs[0].dus[0].cloud_deployment.cloud_hosting.master_node.ssh_connection_details.password}

${ALIAS_CU}                 CUSSSSSS
${ALIAS_DU}                 DUSSSSSS
${NRBTS_ID}                 ${tl.gnbs[0].cu.global_bts_id}
${MRBTS_ID}                 ${tl.gnbs[0].cu.global_bts_id}
${BTSID}                    ${tl.gnbs[0].cu.global_bts_id}
${TLID}                     ${tl.gnbs[0].cu.instance_id}
@{NRDU-1}=  1
${DeltaJson}        [\
...    {\
...        "distName":"distNameStr",\
...        "operation":"update",\
...        "parameters":[\
...             {\
...                "parameterName":"parmKey",\
...                "value":"parmValue",\
...                "operation":"update"\
...             }\
...          ]\
...       }\
...    ]\

*** Keywords ***
KW.LoopForvDUDeltaPlanWithSiteReset
    #Modify Bts Name by Rest
    [Arguments]     ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    ${vdu_connection}    KW.vDULogin    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ${mo_dn}    set variable    ${MRBTSID}/MNL-1/MNLENT-1/FEATCADM-1
    #${cells}    vdu.get_vdu_cells_status    vdu_connection=${vdu_connection}
    #${mo_dn}   ${cellID}   Split String From Right    string=${cells[0]["dist_names"]["config"]}   separator=/     max_split=1
    ${res}    run keyword and ignore error   KW.vDUGetParmeters    mo_dn=${mo_dn}    parameter=actEcpriDelayMeasurement
    ...    gnb_index=${gnb_index}    vdu_index=${vdu_index}

    ${curValue}    set variable if
    ...    '${res[0]}'=='FAIL'    false
    ...    '${res[1]}'=='true'    true
    ...    false

    ${newValue}    set variable if   '${curValue}'=='true'    false    true

    KW.vDUSetParmeters    mo_dn=${mo_dn}    parameter=actEcpriDelayMeasurement    value=${newValue}
    ...    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    log to console    Done
    Wait Until Keyword Succeeds  20min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}

    Wait Until Keyword Succeeds    5min    5s     KW.vDUCheckParameterAsExpected    mo_dn=${mo_dn}
    ...    parameter=actEcpriDelayMeasurement    value=${newValue}    gnb_index=${gnb_index}    vdu_index=${vdu_index}

    KW.vDUSetParmeters    mo_dn=${mo_dn}    parameter=actEcpriDelayMeasurement    value=${curValue}
    ...    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    log to console    Done
    Wait Until Keyword Succeeds  20min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    Wait Until Keyword Succeeds    5min    5s     KW.vDUCheckParameterAsExpected    mo_dn=${mo_dn}
    ...    parameter=actEcpriDelayMeasurement    value=${curValue}    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    set test variable    ${loopStatus}    pass
    [Teardown]    KW.vDULogout    vdu_connection=${vdu_connection}

KW.LoopForvDUDeltaPlanWithBlocking
    #Modify Bts Name by Rest
    [Arguments]     ${gnb_index}=0    ${vdu_index}=0    ${loop}=${1}
    log to console    ${loop}
    ${vdu_connection}    KW.vDULogin    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ${cells}    vdu.get_vdu_cells_status    vdu_connection=${vdu_connection}
    ${curValue}    KW.vDUGetParmeters    mo_dn=${cells[0]["dist_names"]["config"]}    parameter=pMax
    ...    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ${newValue}=    Evaluate    round((${curValue}-0.1),1)

    ${curSCFValue}=    Evaluate    ${curValue}*10
    ${newSCFValue}    Evaluate    ${newValue}*10
    KW.vDUSetParmeters    mo_dn=${cells[0]["dist_names"]["config"]}    parameter=pMax    value=${newSCFValue}
    ...    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    log to console    Done
    Wait Until Keyword Succeeds    5min    5s     KW.vDUCheckParameterAsExpected    mo_dn=${cells[0]["dist_names"]["config"]}
    ...    parameter=pMax    value=${newValue}    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    Wait Until Keyword Succeeds  15min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}

    KW.vDUSetParmeters    mo_dn=${cells[0]["dist_names"]["config"]}    parameter=pMax    value=${curSCFValue}
    ...    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    log to console    Done
    Wait Until Keyword Succeeds    5min    5s     KW.vDUCheckParameterAsExpected    mo_dn=${cells[0]["dist_names"]["config"]}
    ...    parameter=pMax    value=${curValue}    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    Wait Until Keyword Succeeds  15min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    set test variable    ${loopStatus}    pass
    [Teardown]    KW.vDULogout    vdu_connection=${vdu_connection}

KW.LoopForPowerReset
    [Arguments]    ${loop}=${1}    ${gnb_index}=0    ${vdu_index}=0
    log to console    ${loop}
    KW.PowerOff5GRUs  ${gnb_index}    ${vdu_index}
    sleep    5s
    KW.PowerOn5GRUs  ${gnb_index}    ${vdu_index}
    sleep    180s
    Wait Until Keyword Succeeds  15min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    set test variable    ${loopStatus}    pass

KW.LoopForvDUReset
    [Arguments]    ${vdu_index}=${0}    ${gnb_index}=0    ${loop}=${1}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU
    ...    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    log to console    ${loop}
    ${vdu_connection}    KW.vDULogin    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ${out}    vdu.reset_vdu    vdu_connection=${vdu_connection}
    #${error_msg}    set variable  ${out["error_message"]}
    #should contain    ${error_msg}    No error
    Wait Until Keyword Succeeds    180s   10s   Cloud Check Reset vDU Status Should Be Expected    operation_id=${out["id"]}
    ...    expected_status=ongoing    vdu_connection=${vdu_connection}
    sleep    60s
    Wait Until Keyword Succeeds  15min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    set test variable    ${loopStatus}    pass
    [Teardown]    KW.vDULogout    vdu_connection=${vdu_connection}

KW.LoopForvDURULockUnlock
    [Arguments]     ${vdu_index}=0    ${gnb_index}=0    ${timeout}=${60}    ${loop}=${1}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU
    ...    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    log to console    ${loop}
    ${rmod_id_list}=    Get RMOD ID List By RESTAPI
    ${vdu_connection}    KW.vDULogin    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    #lock all
    ${out}    vdu.lock_rmods    rmod_id_list=${rmod_id_list}    timeout=${timeout}    vdu_connection=${vdu_connection}
    Should Be True    "${out["status"]}"=="ongoing"
    FOR   ${rmod_id}    IN    @{rmod_id_list}
        wait until keyword succeeds    5min    30s    RU Status Should Be Locked    ru_id=${rmod_id}
        ...    vdu_index=${vdu_index}
    END
    #unlock all
    ${out}    vdu.unlock_rmods    rmod_id_list=${rmod_id_list}    timeout=${timeout}    vdu_connection=${vdu_connection}
    Should Be True    "${out["status"]}"=="ongoing"
    FOR   ${rmod_id}    IN    @{rmod_id_list}
        wait until keyword succeeds    5min    30s   RU Status Should Be Unlocked    ru_id=${rmod_id}
        ...    vdu_index=${vdu_index}
    END
    Wait Until Keyword Succeeds  15min   30s    All Cells Should Be Onair For One Specific vCU    gnb_index=${gnb_index}
    set test variable    ${loopStatus}    pass
    [Teardown]    KW.vDULogout    vdu_connection=${vdu_connection}

KW.LoopForvDURUReset
    [Arguments]     ${vdu_index}=0    ${gnb_index}=0    ${timeout}=${60}    ${loop}=${1}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU
    ...    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    log to console    ${loop}
    log to console    ${timeout}
    ${rmod_id_list}=    Get RMOD ID List By RESTAPI
    ${cell_list}    Cloud Get Cells Id List    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${vdu_connection}    KW.vDULogin    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    #reset ru
    vdu.reset_rmods     rmods_list=${rmod_id_list}    vdu_connection=${vdu_connection}
    FOR    ${index}    IN    @{cell_list}
        Wait Until Keyword Succeeds    15min    5s    KW.CheckCellStatus   cell_id=${index}
        ...    operational_state=disabled   availability_status=failed   vdu_connection=${vdu_connection}
    END
    Wait Until Keyword Succeeds  15min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    set test variable    ${loopStatus}    pass
    [Teardown]    KW.vDULogout    vdu_connection=${vdu_connection}

KW.LoopForvDURannicReset
    [Arguments]     ${vdu_index}=0    ${gnb_index}=0    ${timeout}=${60}    ${loop}=${1}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU
    ...    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    log to console    ${loop}
    log to console    ${timeout}
    ${vdu_connection}    KW.vDULogin    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ${rnics}=    vdu.get_rnic_info_from_plan    mrbts_id=${BTSID}    vdu_connection=${vdu_connection}
    log to console    ${rnics}
    FOR    ${rnic}    IN    @{rnics}
        ${output}     vdu.reset_rannic    rannic_r_dn=${rnic['r_nic_mod_dist_name']}   vdu_connection=${vdu_connection}
        Wait Until Keyword Succeeds  300s   10s  KW.CheckRannicStatus   operation_id=${output}[id]
        ...    expected_status=success    vdu_connection=${vdu_connection}
    END
    Wait Until Keyword Succeeds  15min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    set test variable    ${loopStatus}    pass
    [Teardown]    KW.vDULogout    vdu_connection=${vdu_connection}

KW.LoopForvDUALDReset
    [Arguments]     ${vdu_index}=0    ${gnb_index}=0    ${timeout}=${60}    ${loop}=${1}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU
    ...    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    log to console    ${loop}
    log to console    ${timeout}
    ${vdu_connection}    KW.vDULogin    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ${rets}=    vdu.get_rets_information    vdu_connection=${vdu_connection}
    ${ret_dn}    set variable      ${rets[0]['ald']['dist_names']['runtime']}
    log to console    ${ret_dn}
    ${reset_info}     vdu.create_ald_reset    target_dn=${ret_dn}   vdu_connection=${vdu_connection}   reset_type=hard   timeout=30   use_m2m=True
    log to console    ${reset_info}
    sleep   15s
    ${operation_id}     set variable      ${reset_info['id']}
    ${reset_status}     vdu.get_ald_reset_status      operation_id=${operation_id}    timeout=30    use_m2m=True
    ${reset_result}     set variable      ${reset_status['status']}
    should be equal      ${reset_result}      success
    Wait Until Keyword Succeeds  15min   30s    All Cells Should Be Onair For One Specific vCU    gnb_index=${gnb_index}
    set test variable    ${loopStatus}    pass
    [Teardown]    KW.vDULogout    vdu_connection=${vdu_connection}

KW.LoopForvDUCellBlockUnblock
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0   ${loop}=${1}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU
    ...    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    log to console    ${loop}
    ${cell_list}    Cloud Get Cells Id List    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${vdu_connection}    KW.vDULogin    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    FOR    ${index}    IN    @{cell_list}
        ${out}    vdu.block_cell    cell_id=${index}    vdu_connection=${vdu_connection}
        Wait Until Keyword Succeeds    5min    5s    KW.CheckCellStatus    cell_id=${index}
        ...   blocking_state=Blocked    operational_state=disabled    vdu_connection=${vdu_connection}
        ${out}    vdu.unblock_cell    cell_id=${index}    vdu_connection=${vdu_connection}
        Wait Until Keyword Succeeds    5min    5s    KW.CheckCellStatus    cell_id=${index}
        ...   blocking_state=Unblocked    operational_state=enabled  vdu_connection=${vdu_connection}
    END
    Wait Until Keyword Succeeds  15min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    set test variable    ${loopStatus}    pass
    [Teardown]    KW.vDULogout    vdu_connection=${vdu_connection}

KW.LoopForvDUCellLockUnlock
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0   ${loop}=${1}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vDU
    ...    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    log to console    ${loop}
    ${cell_list}    Cloud Get Cells Id List    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${vdu_connection}    KW.vDULogin    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    FOR    ${index}    IN    @{cell_list}
        ${cell_id_list}    create list    ${index}
        vdu.lock_cells    cell_id_list=${cell_id_list}    vdu_connection=${vdu_connection}
        Wait Until Keyword Succeeds    15min    5s    KW.CheckCellStatus    cell_id=${index}
        ...    administrative_state=Locked   operational_state=disabled   blocking_state=Unblocked    vdu_connection=${vdu_connection}

        vdu.unlock_cells    cell_id_list=${cell_id_list}    vdu_connection=${vdu_connection}
        Wait Until Keyword Succeeds    15min    5s    KW.CheckCellStatus    cell_id=${index}
        ...    administrative_state=Unlocked   operational_state=enabled   blocking_state=Unblocked    vdu_connection=${vdu_connection}
    END
    Wait Until Keyword Succeeds  15min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    set test variable    ${loopStatus}    pass
    [Teardown]    KW.vDULogout    vdu_connection=${vdu_connection}

KW.LoopForvDUDeltaPlan
    #Modify Bts Name by Rest
    [Arguments]     ${gnb_index}=0    ${vdu_index}=0     ${bts_name}=TL${TLID}_DU1    ${loop}=${1}
    log to console    ${loop}
    Log To Console   \nModify bts name to ${bts_name}
    ${vdu_connection}    KW.vDULogin    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ${distname}    Set Variable   ${mrbts_id}
    ${timetick}    KW.GetCurrentTimeTick
    ${change}    create dictionary    btsName=${bts_name}${timetick}
    ${timeout}    convert to integer    ${60}

    ${planStr}=     Replace String    ${DeltaJson}    distNameStr    ${distname}
    ${planStr}=     Replace String    ${planStr}      parmKey        btsName
    ${planStr}=     Replace String    ${planStr}      parmValue      ${bts_name}${timetick}
    Create File     ${LOG_PATH}/update.json    ${planStr}
    log to console    Start
    wait until keyword succeeds    5min    1min    vdu.perform_delta_recommissioning
    ...                            delta_file=${LOG_PATH}/update.json    vdu_connection=${vdu_connection}
    log to console    Done
    Wait Until Keyword Succeeds  15min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    set test variable    ${loopStatus}    pass
    [Teardown]    KW.vDULogout    vdu_connection=${vdu_connection}
KW.LoopForvDUFullPlan
    #Modify Bts Name by Rest
    [Arguments]     ${gnb_index}=0    ${vdu_index}=0     ${bts_name}=TL${TLID}_DU1    ${loop}=${1}
    log to console    ${loop}
    Log To Console   \nModify bts name to ${bts_name}
    ${vdu_connection}    KW.vDULogin    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ${distname}    Set Variable   ${mrbts_id}
    ${timetick}    KW.GetCurrentTimeTick
    ${change}    create dictionary    btsName=${bts_name}${timetick}
    ${timeout}    convert to integer    ${60}
    log to console    Start
    vdu.get_current_plan_file    local_dir_path=${LOG_PATH}    filename=${bts_name}${timetick}.xml    vdu_connection=${vdu_connection}

    ${upload_plan_response}=  vdu.upload_plan    path_to_plan_file=${LOG_PATH}/${bts_name}${timetick}.xml    vdu_connection=${vdu_connection}
    Upload Plan Status Should Be Successful  operation_id=${upload_plan_response['action_id']}
    ${out}   Activate Staged Plan By REST   plan_id=${upload_plan_response['plan_id']}
    log to console    Done
    Wait Until Keyword Succeeds  15min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    set test variable    ${loopStatus}    pass
    [Teardown]  run keyword and ignore error    KW.vDULogout    vdu_connection=${vdu_connection}
KW.LoopForvCUDeltaPlan
    #Modify Bts Name by Rest
    [Arguments]     ${gnb_index}=0    ${vdu_index}=0     ${bts_name}=TL${TLID}_CU    ${loop}=${1}
    log to console    ${loop}
    log to console    ${vdu_index}
    Log To Console   \nModify bts name to ${bts_name}
    ${connection}  KW.vCULogin    gnb_index=${gnb_index}
    ${distname}    Set Variable   ${mrbts_id}
    ${timetick}    KW.GetCurrentTimeTick
    ${change}    create dictionary    btsName=${bts_name}${timetick}
    ${timeout}    convert to integer    ${60}

    ${planStr}=     Replace String    ${DeltaJson}    distNameStr    ${distname}
    ${planStr}=     Replace String    ${planStr}      parmKey        btsName
    ${planStr}=     Replace String    ${planStr}      parmValue      ${bts_name}${timetick}
    Create File     ${LOG_PATH}/updatecu.json    ${planStr}
    log to console    Start
    wait until keyword succeeds    5min    1min    cu.perform_delta_recommissioning
    ...                            delta_file=${LOG_PATH}/updatecu.json    connection=${connection}
    log to console    Done
    Wait Until Keyword Succeeds  15min   30s    All Cells Should Be Onair For One Specific vCU    gnb_index=${gnb_index}
    set test variable    ${loopStatus}    pass
    [Teardown]    KW.vCULogout    connection=${connection}
KW.LoopForvCUFullPlan
    #Modify Bts Name by Rest
    [Arguments]     ${gnb_index}=0    ${vdu_index}=0     ${bts_name}=TL${TLID}_CU    ${loop}=${1}
    log to console    ${loop}
    log to console    ${vdu_index}
    Log To Console   \nModify bts name to ${bts_name}
    ${connection}  KW.vCULogin    gnb_index=${gnb_index}
    ${distname}    Set Variable   ${mrbts_id}
    ${timetick}    KW.GetCurrentTimeTick
    ${change}    create dictionary    btsName=${bts_name}${timetick}
    ${timeout}    convert to integer    ${60}
#    ${delta_plan_name}    get unique id    prefix=TA_delta_plan    precise=LOW
#    #Check Maximum Delta Plan Number And Delete One If Reach Maximum Number
#    ${plan_id}    ${action_id}    Generate Delta Plan    plan_name=${delta_plan_name}    plan_description=TA
#    ${out}    Update Delta Plan Parameter    plan_id=${plan_id}    mo_dn=${distname}
#    ...                 updated_paras_dict=${change}    operation=replace
#    ${validation_id}    Validate Delta Plan By REST    plan_id=${plan_id}
#    ${out}   vdu.activate_delta_plan   delta_plan_id=${plan_id}
#     ...   force_reset=${True}   auto_lock_cells=${True}   timeout=${timeout}
#    Activate Delta Plan Status Should Be Successful   operation_id=${out['id']}   plan_id=${plan_id}
    log to console    Start
    cu.get_current_plan_file    path=${LOG_PATH}/${bts_name}${timetick}.xml

    ${upload_operation_info}=   cu.upload_plan_file    path_to_plan_file=${LOG_PATH}/${bts_name}${timetick}.xml
    log to console    1
    wait until keyword succeeds    60s   5s  CU Check Plan Upload Status Should Be As Expected
    ...    ${upload_operation_info["action_id"]}    success
    log to console    2
#    ${validate_operaition_info}=  cu.plan_validation    ${upload_operation_info["plan_id"]}
#    log to console    3
#    wait until keyword succeeds    60s   5s  CU Check Plan Validate Status Should Be As Expected
#    ...    ${upload_operation_info["plan_id"]}   ${validate_operaition_info["action_id"]}    success
#    log to console    4
    ${activate_operaition_info}=  cu.plan_activation   ${upload_operation_info["plan_id"]}
    log to console    5
    wait until keyword succeeds    600s   30s  CU Check Plan Activate Status Should Be As Expected
    ...    ${upload_operation_info["plan_id"]}  ${activate_operaition_info["id"]}    success
    log to console    Done
    Wait Until Keyword Succeeds  15min   30s    All Cells Should Be Onair For One Specific vCU    gnb_index=${gnb_index}
    #perform_commissioning    scf_file
#    ${value}    Online Get VDU Parameter Value    mo_dn=${distname}    para_name=btsName
#    should be equal as strings    ${value}    ${bts_name}${timetick}
    set test variable    ${loopStatus}    pass
    [Teardown]  run keyword and ignore error     KW.vCULogout    connection=${connection}
#----------------------------------
KW.LoopForvCUReset
    [Arguments]    ${gnb_index}=0    ${loop}=${1}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vCU    gnb_index=${gnb_index}
    log to console    ${loop}
    ${connection}  KW.vCULogin    gnb_index=${gnb_index}
    ${out}    cu.reset_cu    connection=${connection}
    #Should Be Equal As Strings    ${out["error_message"]}    ${None}
    Should Be Equal As Strings    ${out["status"]}    ongoing
    sleep    60s
    Wait Until Keyword Succeeds  15min   30s    All Cells Should Be Onair For One Specific vCU    gnb_index=${gnb_index}
    set test variable    ${loopStatus}    pass
    [Teardown]    KW.vCULogout    connection=${connection}

KW.LoopForvCUDULockUnlock
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0   ${loop}=${1}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vCU    gnb_index=${gnb_index}
    log to console    ${loop}
    log to console    ${vdu_index}
    ${connection}  KW.vCULogin    gnb_index=${gnb_index}
    ${du_id_list}    Create List
    ${dus_info}    cu.get_dus_diff    connection=${connection}
    FOR    ${info}    IN    @{dus_info["created"]}
        Append To List    ${du_id_list}    ${info["id"]}
    END
    ${return_info}    cu.lock_du    ${du_id_list}    connection=${connection}
    Wait Until Keyword Succeeds    5min    3s    KW.CheckvCUOpStatus    operation_id=${return_info["id"]}
    ...    expect_result=success    connection=${connection}
    ${return_info}    cu.unlock_du    ${du_id_list}    connection=${connection}
    Wait Until Keyword Succeeds    5min    3s    KW.CheckvCUOpStatus    operation_id=${return_info["id"]}
    ...    expect_result=success    connection=${connection}

    Wait Until Keyword Succeeds  15min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    set test variable    ${loopStatus}    pass
    [Teardown]    KW.vCULogout    connection=${connection}

KW.LoopForvCUX2LockUnlock
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0   ${loop}=${1}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vCU    gnb_index=${gnb_index}
    log to console    ${loop}
    log to console    ${vdu_index}
    ${connection}  KW.vCULogin    gnb_index=${gnb_index}
    ${id_list}    Create List
    ${infos}    cu.get_x2_links_info    connection=${connection}
    log to console   ${infos}
    FOR    ${info}    IN    @{infos["created"]}
        Append To List    ${id_list}    ${info["id"]}
    END
    ${return_info}    cu.lock_x2_links    ${id_list}    connection=${connection}
    Wait Until Keyword Succeeds    5min    3s    KW.CheckvCUOpStatus    operation_id=${return_info["id"]}
    ...    expect_result=success    connection=${connection}
    Wait Until Keyword Succeeds    10min    3s    KW.vCUCheckX2LinkStatus    lockState=locked   availableState=unavailable
    ...    connection=${connection}
    ${return_info}    cu.unlock_x2_links    ${id_list}    connection=${connection}
    Wait Until Keyword Succeeds    5min    3s    KW.CheckvCUOpStatus    operation_id=${return_info["id"]}
    ...    expect_result=success    connection=${connection}
    Wait Until Keyword Succeeds    10min    3s    KW.vCUCheckX2LinkStatus    lockState=unlocked    availableState=available
    ...    connection=${connection}
    Wait Until Keyword Succeeds  15min   30s    All Cells Should Be Onair For One Specific vCU    gnb_index=${gnb_index}
    set test variable    ${loopStatus}    pass
    [Teardown]    KW.vCULogout    connection=${connection}

KW.vCUCheckX2LinkStatus
    [Arguments]   ${lockState}     ${availableState}   ${connection}=none
    ${infos}    cu.get_x2_links_info    connection=${connection}
    FOR    ${info}    IN    @{infos["created"]}
        Should Be True    "${info["x2_link_lock"]}"=="${lockState}"
        Should Be True    "${info["x2_link_status"]}"=="${availableState}"
    END

KW.LoopForvCUNGLockUnlock
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0   ${loop}=${1}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vCU    gnb_index=${gnb_index}
    log to console    ${loop}
    log to console    ${vdu_index}
    ${connection}  KW.vCULogin    gnb_index=${gnb_index}
    ${id_list}    Create List
    ${infos}    cu.get_ng_links_info    connection=${connection}
    log to console   ${infos}
    FOR    ${info}    IN    @{infos}
        Append To List    ${id_list}    ${info["served_amf_id"]}
    END
    ${return_info}    cu.lock_ng_links    ${id_list}    connection=${connection}
    Wait Until Keyword Succeeds    5min    3s    KW.CheckvCUOpStatus    operation_id=${return_info["id"]}
    ...    expect_result=success    connection=${connection}
    Wait Until Keyword Succeeds    10min    3s    KW.vCUCheckNGLinkStatus    lockState=Locked   availableState=Inactive    connection=${connection}
    ${return_info}    cu.unlock_ng_links    ${id_list}    connection=${connection}
    #check vDU locked.

    Wait Until Keyword Succeeds    5min    3s    KW.CheckvCUOpStatus    operation_id=${return_info["id"]}
    ...    expect_result=success    connection=${connection}
    Wait Until Keyword Succeeds    10min    3s    KW.vCUCheckNGLinkStatus    lockState=Unlocked    availableState=Active    connection=${connection}
    Wait Until Keyword Succeeds  15min   30s    All Cells Should Be Onair For One Specific vCU     gnb_index=${gnb_index}
    set test variable    ${loopStatus}    pass
    [Teardown]    KW.vCULogout    connection=${connection}

KW.vCUCheckNGLinkStatus
    [Arguments]   ${lockState}     ${availableState}   ${connection}=none
    ${infos}    cu.get_ng_links_info    connection=${connection}
    FOR    ${info}    IN    @{infos}
        Should Be True    "${info["administrative_state"]}"=="${lockState}"
        Should Be True    "${info["ng_link_status"]}"=="${availableState}"
    END

KW.LoopForvCUCellLockUnlock
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0   ${loop}=${1}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vCU    gnb_index=${gnb_index}
    log to console    ${loop}
    log to console    ${vdu_index}
    ${connection}  KW.vCULogin    gnb_index=${gnb_index}
    ${id_list}    Create List
    ${infos}    cu.get_cu_cells_diff    connection=${connection}
    log to console   ${infos}
    FOR    ${info}    IN    @{infos["created"]}
        Append To List    ${id_list}    ${info["basic_cell"]["id"]}
    END
    ${return_info}    cu.lock_cells    ${id_list}    connection=${connection}
    Wait Until Keyword Succeeds    5min    3s    KW.CheckvCUOpStatus    operation_id=${return_info["id"]}
    ...    expect_result=success    connection=${connection}
    Wait Until Keyword Succeeds    10min    3s    KW.vCUCheckCellStatus    lockState=Locked   availableState=disabled    connection=${connection}
    ${return_info}    cu.unlock_cells    ${id_list}    connection=${connection}
    Wait Until Keyword Succeeds    5min    3s    KW.CheckvCUOpStatus    operation_id=${return_info["id"]}
    ...    expect_result=success    connection=${connection}
    Wait Until Keyword Succeeds    5min    3s    KW.vCUCheckCellStatus    lockState=Unlocked    availableState=enabled    connection=${connection}
    Wait Until Keyword Succeeds  15min   30s    All Cells Should Be Onair For One Specific vCU     gnb_index=${gnb_index}
    set test variable    ${loopStatus}    pass
    [Teardown]    KW.vCULogout    connection=${connection}

KW.LoopForvCUCellReset
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0   ${loop}=${1}
    Wait Until Keyword Succeeds  3min   30s    All Cells Should Be Onair For One Specific vCU    gnb_index=${gnb_index}
    log to console    ${loop}
    log to console    ${vdu_index}
    ${connection}  KW.vCULogin    gnb_index=${gnb_index}
    ${id_list}    Create List
    ${infos}    cu.get_cu_cells_diff    connection=${connection}
    log to console   ${infos}
    FOR    ${info}    IN    @{infos["created"]}
        cu.reset_cells    dist_name=${info["basic_cell"]["dist_names"]["config"]}    timeout=90    connection=${connection}
        Wait Until Keyword Succeeds    5min    3s    KW.vCUCheckCellStatus    lockState=Unlocked    availableState=disabled
        ...    connection=${connection}
        ...    cell_dn=${info["basic_cell"]["dist_names"]["config"]}
    END
    Wait Until Keyword Succeeds  15min   30s    All Cells Should Be Onair For One Specific vCU     gnb_index=${gnb_index}
    set test variable    ${loopStatus}    pass
    [Teardown]    KW.vCULogout    connection=${connection}

#----------------------------------vCU exploring link sctp fail-------------------------
KW.LoopForvCUNGLinkSCTPFail
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0   ${loop}=${1}
    Wait Until Keyword Succeeds  3min   5s    All Cells Should Be Onair For One Specific vCU    gnb_index=${gnb_index}
    log to console    ${loop}
    log to console    ${vdu_index}
#    ${ns}    set variable    ${tl.gnbs[0].cloud_deployment.cloud_hosting.namespace}
    ${connection}  KW.vCULogin    gnb_index=${gnb_index}
    ${id_list}    Create List
    ${ng_ip_list}    Create List
    ${infos}    cu.get_ng_links_info    connection=${connection}
    log to console   ${infos}
    FOR    ${info}    IN    @{infos}
        Append To List    ${id_list}    ${info["served_amf_id"]}
        Append To List    ${ng_ip_list}    ${info["amf_ip_address"]}
    END
    ${length}=      Get Length      ${ng_ip_list}
    FOR    ${i}  IN RANGE   ${length}
#        KW.TriggerLinkSCTPFailure    ip=${ng_ip_list[${i}]}    ns=${ns}
        KW.TriggerLinkSCTPFailure    ip=${ng_ip_list[${i}]}
    END
    ##7107BASE STATION CONNECTIVITY PROBLEM	7304NG SCTP endpoint broken
    Wait Until Keyword Succeeds    5min    3s     KW.vCUCheckActiveAlarm    fault_id=7304
    Wait Until Keyword Succeeds    1min    3s
    ...        KW.vCUCheckNGLinkStatus    lockState=Unlocked    availableState=Inactive    connection=${connection}
    FOR    ${i}  IN RANGE   ${length}
#        KW.TriggerLinkSCTPRecover    ip=${ng_ip_list[${i}]}    ns=${ns}
    KW.TriggerLinkSCTPRecover    ip=${ng_ip_list[${i}]}
    END
    Wait Until Keyword Succeeds    5min    3s
    ...    KW.vCUCheckNGLinkStatus    lockState=Unlocked    availableState=Active    connection=${connection}
    Wait Until Keyword Succeeds  15min   5s    All Cells Should Be Onair For One Specific vCU     gnb_index=${gnb_index}
    set test variable    ${loopStatus}    pass
    KW.NoActiveAlarm
    [Teardown]    KW.vCULogout    connection=${connection}

KW.LoopForvCUX2LinkSCTPFail
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0   ${loop}=${1}
    Wait Until Keyword Succeeds  3min   5s    All Cells Should Be Onair For One Specific vCU    gnb_index=${gnb_index}
    log to console    ${loop}
    log to console    ${vdu_index}
#    ${ns}    set variable    ${tl.gnbs[0].cloud_deployment.cloud_hosting.namespace}
    ${connection}  KW.vCULogin    gnb_index=${gnb_index}
    ${id_list}    Create List
    ${x2_ip_list}    Create List
    ${infos}    cu.get_x2_links_info    connection=${connection}
    log to console   ${infos}
    FOR    ${info}    IN    @{infos["created"]}
        Append To List    ${id_list}    ${info["id"]}
        Append To List    ${x2_ip_list}    ${info["ip_address"]}
    END
    ${length}=      Get Length      ${x2_ip_list}
    FOR    ${i}  IN RANGE   ${length}
#        KW.TriggerLinkSCTPFailure    ip=${x2_ip_list[${i}]}    ns=${ns}
        KW.TriggerLinkSCTPFailure    ip=${x2_ip_list[${i}]}
    END
    ##	7107BASE STATION CONNECTIVITY PROBLEM	7308Transport layer connection failure in X2 interface
    ##	7114CELL SERVICE PROBLEM	7107Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability
    Wait Until Keyword Succeeds    5min    3s     KW.vCUCheckActiveAlarm    fault_id=7308
    Wait Until Keyword Succeeds    1min    3s
    ...      KW.vCUCheckX2LinkStatus    lockState=unlocked    availableState=unavailable    connection=${connection}
    FOR    ${i}  IN RANGE   ${length}
#        KW.TriggerLinkSCTPRecover    ip=${x2_ip_list[${i}]}    ns=${ns}
        KW.TriggerLinkSCTPRecover    ip=${x2_ip_list[${i}]}
    END
    Wait Until Keyword Succeeds    5min    3s
    ...      KW.vCUCheckX2LinkStatus    lockState=unlocked    availableState=available    connection=${connection}
    Wait Until Keyword Succeeds  15min   5s    All Cells Should Be Onair For One Specific vCU     gnb_index=${gnb_index}
    KW.NoActiveAlarm
    set test variable    ${loopStatus}    pass
    ${infos_1}      cu.get_du     du_id=1             connection=${connection}
    ${infos_2}      cu.get_du_state            connection=${connection}
    ${infos_3}      cu.get_dus_diff            connection=${connection}
    log to console    ${infos_1}
    log to console   ${infos_2}
    log to console   ${infos_3}
    [Teardown]    KW.vCULogout    connection=${connection}

KW.LoopForvCUF1LinkSCTPFail
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0   ${loop}=${1}
    Wait Until Keyword Succeeds  3min   5s    All Cells Should Be Onair For One Specific vCU    gnb_index=${gnb_index}
    log to console    ${loop}
    log to console    ${vdu_index}
#    ${ns}    set variable    ${tl.gnbs[0].cloud_deployment.cloud_hosting.namespace}
    ${connection}  KW.vCULogin    gnb_index=${gnb_index}
    ${id_list}    Create List
    ${f1_ip_list}    Create List
    ${infos}    cu.get_parameters       dist_name=${MRBTS_ID}/${NRBTS_ID}/NRDU-1       connection=${connection}
    ${infos}    cu.get_external_interfaces_of_pmtu_discovery    connection=${connection}
    log to console   ${infos}
    FOR    ${info}    IN    @{infos}
        ${status}=  Run Keyword And Return Status    Should Contain    ${info}   F1-C
        Run Keyword if   '${status}' == 'True'    Append To List    ${f1_ip_list}    ${info["ipv4_address"]}
    END
    ${length}=     Get Length     ${f1_ip_list}
    FOR    ${i}  IN RANGE   ${length}
#        KW.TriggerLinkSCTPFailure    ip=${f1_ip_list[${i}]}    ns=${ns}
        KW.TriggerLinkSCTPFailure    ip=${f1_ip_list[${i}]}
    END
    ##	7107BASE STATION CONNECTIVITY PROBLEM	7303F1 SCTP endpoint in CU
    Wait Until Keyword Succeeds    5min    3s     KW.vCUCheckActiveAlarm    fault_id=7303
    Wait Until Keyword Succeeds    1min    3s
    ...     KW.vCUCheckF1LinkStatus     lockState=unlocked    availableState=Unavailable    connection=${connection}
    FOR    ${i}  IN RANGE   ${length}
#        KW.TriggerLinkSCTPRecover    ip=${f1_ip_list[${i}]}    ns=${ns}
        KW.TriggerLinkSCTPRecover    ip=${f1_ip_list[${i}]}
    END
    Wait Until Keyword Succeeds    5min    3s
    ...    KW.vCUCheckF1LinkStatus   lockState=unlocked   availableState=available    connection=${connection}
    Wait Until Keyword Succeeds  15min   5s    All Cells Should Be Onair For One Specific vCU     gnb_index=${gnb_index}
    set test variable    ${loopStatus}    pass
    KW.NoActiveAlarm
    [Teardown]    KW.vCULogout    connection=${connection}

KW.LoopForvCUXNLinkSCTPFail
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0   ${loop}=${1}
    Wait Until Keyword Succeeds  3min   5s    All Cells Should Be Onair For One Specific vCU    gnb_index=${gnb_index}
    log to console    ${loop}
    log to console    ${vdu_index}
#    ${ns}    set variable    ${tl.gnbs[0].cloud_deployment.cloud_hosting.namespace}
    ${connection}  KW.vCULogin    gnb_index=${gnb_index}
    ${id_list}    Create List
    ${xn_ip_list}    Create List
    ${infos}    cu.get_xn_link_status    connection=${connection}
    log to console   ${infos}
    FOR    ${info}    IN    @{infos["created"]}
        Append To List    ${id_list}    ${info["xn_link_id"]}
        Append To List    ${xn_ip_list}    ${info["c_plane_ip_addr"]}
    END
    ${length}=      Get Length      ${xn_ip_list}
    FOR    ${i}  IN RANGE   ${length}
#        KW.TriggerLinkSCTPFailure    ip=${xn_ip_list[${i}]}    ns=${ns}
        KW.TriggerLinkSCTPFailure    ip=${xn_ip_list[${i}]}
    END
    ##7107 BASE STATION CONNECTIVITY PROBLEM 7306 Xn SCTP endpoint broken
	##7107 BASE STATION CONNECTIVITY PROBLEM 7311 No Xn link available
    Wait Until Keyword Succeeds    5min    3s     KW.vCUCheckActiveAlarm    fault_id=7306
    Wait Until Keyword Succeeds    1min    3s
    ...        KW.vCUCheckXNLinkStatus    lockState=Unlocked    availableState=unavailable    connection=${connection}
    FOR    ${i}  IN RANGE   ${length}
#        KW.TriggerLinkSCTPRecover    ip=${xn_ip_list[${i}]}    ns=${ns}
        KW.TriggerLinkSCTPRecover    ip=${xn_ip_list[${i}]}
    END
    Wait Until Keyword Succeeds    5min    3s
    ...    KW.vCUCheckXNLinkStatus    lockState=Unlocked    availableState=available    connection=${connection}
    Wait Until Keyword Succeeds  15min   5s    All Cells Should Be Onair For One Specific vCU     gnb_index=${gnb_index}
    KW.NoActiveAlarm
    set test variable    ${loopStatus}    pass
    [Teardown]    KW.vCULogout    connection=${connection}

KW.TriggerLinkSCTPFailure
#    [Arguments]    ${ip}   ${ns}       ${pod_name}=cpif
     [Arguments]    ${ip}        ${pod_name}=cpif
    ${conn_alias}    KW.connect_CU_server
    ${Command}     Catenate     SEPARATOR=${SPACE}
    ...    ns=${ns} && kubectl get pod -n $ns | grep ${pod_name} |awk '{print $1}'|xargs -I {}
    ...    kubectl exec -it {} -n $ns -c ctr-nwmgmt -- bash -c "ip route add blackhole ${ip}/32"
    ssh.Execute    command=${Command}    connection=${conn_alias}
    KW.disconnect_CU_server  conn_alias=${conn_alias}

KW.TriggerLinkSCTPRecover
#    [Arguments]    ${ip}      ${ns}     ${pod_name}=cpif
    [Arguments]    ${ip}        ${pod_name}=cpif
    ${conn_alias}    KW.connect_CU_server
    ${Command}     Catenate     SEPARATOR=${SPACE}
    ...    ns=${ns} && kubectl get pod -n $ns | grep ${pod_name} |awk '{print $1}'|xargs -I {}
    ...    kubectl exec -it {} -n $ns -c ctr-nwmgmt -- bash -c "ip route del blackhole ${ip}/32"
    ssh.Execute    command=${Command}    connection=${conn_alias}
    KW.disconnect_CU_server  conn_alias=${conn_alias}

KW.vCUCheckActiveAlarm
    [Arguments]   ${fault_id}
    ${fault_id_list}       KW.vCUGetActiveAlarm
    list should contain value      ${fault_id_list}       ${fault_id}

KW.NoActiveAlarm
    ${fault_id_list}       KW.vCUGetActiveAlarm
    should be empty        ${fault_id_list}

KW.vCUCheckF1LinkStatus
    [Arguments]   ${lockState}    ${availableState}   ${connection}=none
    ${dus_info}    cu.get_dus_diff    connection=${connection}
    FOR    ${info}    IN    @{dus_info["created"]}
        Should Be True    "${info["administrative_state"]}"=="${lockState}"
        Should Be True    "${info["f1_link_status"]}"=="${availableState}"
    END

KW.vCUCheckXNLinkStatus
    [Arguments]   ${lockState}     ${availableState}   ${connection}=none
    ${infos}    cu.get_xn_link_status    connection=${connection}
    FOR    ${info}    IN   @{infos["created"]}
        Should Be True    "${info["administrative_state"]}"=="${lockState}"
        Should Be True    "${info["xn_link_status"]}"=="${availableState}"
    END
#----------------------------------vCU exploring link sctp fail-------------------------

KW.vCUCheckCellStatus
    [Arguments]   ${lockState}     ${availableState}   ${connection}=none     ${cell_dn}=all
    ${infos}    cu.get_cu_cells_diff    connection=${connection}
    FOR    ${info}    IN    @{infos["created"]}
        run keyword if    '${cell_dn}'!='all' and '${cell_dn}'!='${info["basic_cell"]["dist_names"]["config"]}'    Continue For Loop
        Should Be True    "${info["basic_cell"]["administrative_state"]}"=="${lockState}"
        Should Be True    "${info["basic_cell"]["operational_state"]}"=="${availableState}"
    END

#----------------------------------resiliency vCU exploring-------------------------
KW.LoopForvCUNRTSexploring
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0   ${loop}=${1}
    Wait Until Keyword Succeeds  3min   5s    All Cells Should Be Onair For One Specific vCU    gnb_index=${gnb_index}
    log to console    ${loop}
    log to console    ${vdu_index}
    log to console    ${gnb_index}
#    ${ns}    set variable    ${tl.gnbs[0].cloud_deployment.cloud_hosting.namespace}
    ${cell}    KW.GetvCUCellsID
#    KW.Check_vCU_pod_restart_exploring        ns=${ns}    id_list=${cell}    pod_name=oamconfig
    KW.Check_vCU_pod_restart_exploring        id_list=${cell}    pod_name=oamconfig

KW.LoopForvCUCPNBexploring
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0   ${loop}=${1}
    Wait Until Keyword Succeeds  3min   5s    All Cells Should Be Onair For One Specific vCU    gnb_index=${gnb_index}
    log to console    ${loop}
    log to console    ${vdu_index}
    log to console    ${gnb_index}
#    ${ns}    set variable    ${tl.gnbs[0].cloud_deployment.cloud_hosting.namespace}
    ${cell}    KW.GetvCUCellsID
#    KW.Check_vCU_pod_restart_exploring        ns=${ns}    id_list=${cell}    pod_name=cpnb
    KW.Check_vCU_pod_restart_exploring        id_list=${cell}    pod_name=cpnb

KW.LoopForvCUCPNRTexploring
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0   ${loop}=${1}
    Wait Until Keyword Succeeds  3min   5s    All Cells Should Be Onair For One Specific vCU    gnb_index=${gnb_index}
    log to console    ${loop}
    log to console    ${vdu_index}
    log to console    ${gnb_index}
#    ${ns}    set variable    ${tl.gnbs[0].cloud_deployment.cloud_hosting.namespace}
    ${cell}    KW.GetvCUCellsID
#    KW.Check_vCU_pod_restart_exploring       ns=${ns}    id_list=${cell}     pod_name=cpnrt
    KW.Check_vCU_pod_restart_exploring       id_list=${cell}     pod_name=cpnrt

KW.LoopForvCUCPIFexploring
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0   ${loop}=${1}
    Wait Until Keyword Succeeds  3min   5s    All Cells Should Be Onair For One Specific vCU    gnb_index=${gnb_index}
    log to console    ${loop}
    log to console    ${vdu_index}
    log to console    ${gnb_index}
#    ${ns}    set variable    ${tl.gnbs[0].cloud_deployment.cloud_hosting.namespace}
    ${cell}    KW.GetvCUCellsID
#    KW.Check_vCU_pod_restart_exploring       ns=${ns}    id_list=${cell}     pod_name=cpif
    KW.Check_vCU_pod_restart_exploring       id_list=${cell}     pod_name=cpif

KW.LoopForvCUCPCLexploring
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0   ${loop}=${1}
    Wait Until Keyword Succeeds  3min   5s    All Cells Should Be Onair For One Specific vCU    gnb_index=${gnb_index}
    log to console    ${loop}
    log to console    ${vdu_index}
    log to console    ${gnb_index}
#    ${ns}    set variable    ${tl.gnbs[0].cloud_deployment.cloud_hosting.namespace}
    ${cell}    KW.GetvCUCellsID
#    KW.Check_vCU_pod_restart_exploring       ns=${ns}    id_list=${cell}     pod_name=cpcl
    KW.Check_vCU_pod_restart_exploring       id_list=${cell}     pod_name=cpcl

KW.LoopForvCUCPUEexploring
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0   ${loop}=${1}
    Wait Until Keyword Succeeds  3min   5s    All Cells Should Be Onair For One Specific vCU    gnb_index=${gnb_index}
    log to console    ${loop}
    log to console    ${vdu_index}
    log to console    ${gnb_index}
#    ${ns}    set variable    ${tl.gnbs[0].cloud_deployment.cloud_hosting.namespace}
    ${cell}    KW.GetvCUCellsID
#    KW.Check_vCU_pod_restart_exploring       ns=${ns}    id_list=${cell}     pod_name=cpue
    KW.Check_vCU_pod_restart_exploring       id_list=${cell}     pod_name=cpue

KW.Check_vCU_pod_restart_exploring
    [Documentation]  Will run 1 case, Check_CPNRT_service_restart and cell lock
    [Arguments]    ${id_list}    ${gnb_index}=0    ${pod_name}=cpnrt
    #-----------Operation_before_pod_restart---------------
    ${connection}  KW.vCULogin    gnb_index=${gnb_index}
    #-----------Cell_Lock--------------
    ${return_info}    cu.lock_cells    ${id_list}    connection=${connection}
    #sleep    5s
    Wait Until Keyword Succeeds    10min    3s    KW.CheckvCUOpStatus    operation_id=${return_info["id"]}
    ...    expect_result=success    connection=${connection}
    Wait Until Keyword Succeeds    10min    3s    KW.vCUCheckCellStatus    lockState=Locked   availableState=disabled    connection=${connection}
    #-----------NG_link_Lock--------------
    ${ng_link_id_list}    Create List
    ${infos}    cu.get_ng_links_info    connection=${connection}
    log to console   ${infos}
    FOR    ${info}    IN    @{infos}
        Append To List    ${ng_link_id_list}    ${info["served_amf_id"]}
    END
    ${return_info}    cu.lock_ng_links    ${ng_link_id_list}    connection=${connection}
    Wait Until Keyword Succeeds    5min    3s    KW.CheckvCUOpStatus    operation_id=${return_info["id"]}
    ...    expect_result=success    connection=${connection}
    Wait Until Keyword Succeeds    10min    3s    KW.vCUCheckNGLinkStatus    lockState=Locked   availableState=Inactive    connection=${connection}
    #-----------pod_restart---------------
    KW.StopService    ${pod_name}
    #-----------Operation_after_pod_restart---------------
    #-----------NG_links_unLock--------------
    ${return_info}    cu.unlock_ng_links    ${ng_link_id_list}    connection=${connection}
    Wait Until Keyword Succeeds    5min    3s    KW.CheckvCUOpStatus    operation_id=${return_info["id"]}
    ...    expect_result=success    connection=${connection}
    Wait Until Keyword Succeeds    10min    3s    KW.vCUCheckNGLinkStatus    lockState=Unlocked    availableState=Inactive    connection=${connection}
    #-----------Cells_unLock--------------
    ${return_info}    cu.unlock_cells    ${id_list}    connection=${connection}
    Wait Until Keyword Succeeds    5min    3s    KW.CheckvCUOpStatus    operation_id=${return_info["id"]}
    ...    expect_result=success    connection=${connection}
    Wait Until Keyword Succeeds    10min    3s    KW.vCUCheckCellStatus    lockState=Unlocked    availableState=enabled    connection=${connection}
    Wait Until Keyword Succeeds    3min    3s    KW.vCUCheckNGLinkStatus    lockState=Unlocked    availableState=Active    connection=${connection}
    #----------Check Onair--------------
    Wait Until Keyword Succeeds    15min   5s    All Cells Should Be Onair For One Specific vCU     gnb_index=${gnb_index}
    sleep    5s
    set test variable    ${loopStatus}    pass
    [Teardown]    KW.vCULogout    connection=${connection}

#----------------------------------resiliency vCU exploring-------------------------

#----------------------------------resiliency vCU-------------------------
KW.LoopForvCUNRTSResiliency
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0   ${loop}=${1}
    Wait Until Keyword Succeeds  3min   5s    All Cells Should Be Onair For One Specific vCU    gnb_index=${gnb_index}
    log to console    ${loop}
    log to console    ${vdu_index}
    log to console    ${gnb_index}
#    ${ns}    set variable    ${tl.gnbs[0].cloud_deployment.cloud_hosting.namespace}
    ${cell}    KW.GetvCUCellsID
#    KW.Check_vCU_pod_restart        ns=${ns}    id_list=${cell}    pod_name=oamconfig
     KW.Check_vCU_pod_restart        id_list=${cell}    pod_name=oamconfig

KW.LoopForvCUCPNBResiliency
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0   ${loop}=${1}
    Wait Until Keyword Succeeds  3min   5s    All Cells Should Be Onair For One Specific vCU    gnb_index=${gnb_index}
    log to console    ${loop}
    log to console    ${vdu_index}
    log to console    ${gnb_index}
#    ${ns}    set variable    ${tl.gnbs[0].cloud_deployment.cloud_hosting.namespace}
    ${cell}    KW.GetvCUCellsID
    KW.Check_vCU_pod_restart        id_list=${cell}    pod_name=cpnb

KW.LoopForvCUCPNRTResiliency
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0   ${loop}=${1}
    Wait Until Keyword Succeeds  3min   5s    All Cells Should Be Onair For One Specific vCU    gnb_index=${gnb_index}
    log to console    ${loop}
    log to console    ${vdu_index}
    log to console    ${gnb_index}
#    ${ns}    set variable    ${tl.gnbs[0].cloud_deployment.cloud_hosting.namespace}
    ${cell}    KW.GetvCUCellsID
    KW.Check_vCU_pod_restart       id_list=${cell}     pod_name=cpnrt

KW.LoopForvCUCPIFResiliency
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0   ${loop}=${1}
    Wait Until Keyword Succeeds  3min   5s    All Cells Should Be Onair For One Specific vCU    gnb_index=${gnb_index}
    log to console    ${loop}
    log to console    ${vdu_index}
    log to console    ${gnb_index}
#    ${ns}    set variable    ${tl.gnbs[0].cloud_deployment.cloud_hosting.namespace}
    ${cell}    KW.GetvCUCellsID
    KW.Check_vCU_pod_restart       id_list=${cell}     pod_name=cpif

KW.LoopForvCUCPCLResiliency
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0   ${loop}=${1}
    Wait Until Keyword Succeeds  3min   5s    All Cells Should Be Onair For One Specific vCU    gnb_index=${gnb_index}
    log to console    ${loop}
    log to console    ${vdu_index}
    log to console    ${gnb_index}
#    ${ns}    set variable    ${tl.gnbs[0].cloud_deployment.cloud_hosting.namespace}
    ${cell}    KW.GetvCUCellsID
    KW.Check_vCU_pod_restart       id_list=${cell}     pod_name=cpcl

KW.LoopForvCUCPUEResiliency
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0   ${loop}=${1}
    Wait Until Keyword Succeeds  3min   5s    All Cells Should Be Onair For One Specific vCU    gnb_index=${gnb_index}
    log to console    ${loop}
    log to console    ${vdu_index}
    log to console    ${gnb_index}
#    ${ns}    set variable    ${tl.gnbs[0].cloud_deployment.cloud_hosting.namespace}
    ${cell}    KW.GetvCUCellsID
    KW.Check_vCU_pod_restart       id_list=${cell}     pod_name=cpue

KW.Check_vCU_pod_restart
    [Documentation]  Will run 1 case, Check_CPNRT_service_restart and cell lock
    [Arguments]    ${id_list}    ${gnb_index}=0    ${pod_name}=cpnrt
    KW.StopService    ${pod_name}
    ${connection}  KW.vCULogin    gnb_index=${gnb_index}
    ${return_info}    cu.lock_cells    ${id_list}    connection=${connection}
    #KW.StopService    ${ns}    ${pod_name}
    #sleep    5s
    Wait Until Keyword Succeeds    10min    3s    KW.CheckvCUOpStatus    operation_id=${return_info["id"]}
    ...    expect_result=success    connection=${connection}
    Wait Until Keyword Succeeds    10min    3s    KW.vCUCheckCellStatus    lockState=Locked   availableState=disabled    connection=${connection}
    ${return_info}    cu.unlock_cells    ${id_list}    connection=${connection}
    Wait Until Keyword Succeeds    5min    3s    KW.CheckvCUOpStatus    operation_id=${return_info["id"]}
    ...    expect_result=success    connection=${connection}
    Wait Until Keyword Succeeds    10min    3s    KW.vCUCheckCellStatus    lockState=Unlocked    availableState=enabled    connection=${connection}
    Wait Until Keyword Succeeds    15min   5s    All Cells Should Be Onair For One Specific vCU     gnb_index=${gnb_index}
    sleep    5s
    set test variable    ${loopStatus}    pass
    [Teardown]    KW.vCULogout    connection=${connection}

KW.Check_vCU_service_restart
    [Documentation]  Will run 1 case, Check_CPNRT_service_restart and cell lock
    [Arguments]    ${id_list}    ${gnb_index}=0    ${pod_name}=oamconfig
    ${connection}  KW.vCULogin    gnb_index=${gnb_index}
    ${return_info}    cu.lock_cells    ${id_list}    connection=${connection}
    sleep    3s
    ${conn_alias}    KW.connect_CU_server
    ${Command}     Catenate     SEPARATOR=${SPACE}
    ...    ns=${ns} && kubectl exec -it po-${pod_name}-0 -c ctr-${pod_name} -n $ns -- pkill ministarter &&
    ...    kubectl exec -it po-$ns-${pod_name}-1 -c ctr-$ns-${pod_name} -n $ns -- pkill ministarter
    ssh.Execute    command=${Command}    connection=${conn_alias}
    KW.disconnect_CU_server    conn_alias=${conn_alias}
    Wait Until Keyword Succeeds    10min    3s    KW.CheckvCUOpStatus    operation_id=${return_info["id"]}
    ...    expect_result=success    connection=${connection}
    Wait Until Keyword Succeeds    10min    3s    KW.vCUCheckCellStatus    lockState=Locked   availableState=disabled    connection=${connection}
    ${return_info}    cu.unlock_cells    ${id_list}    connection=${connection}
    Wait Until Keyword Succeeds    5min    3s    KW.CheckvCUOpStatus    operation_id=${return_info["id"]}
    ...    expect_result=success    connection=${connection}
    Wait Until Keyword Succeeds    10min    3s    KW.vCUCheckCellStatus    lockState=Unlocked    availableState=enabled    connection=${connection}
    Wait Until Keyword Succeeds  15min   5s    All Cells Should Be Onair For One Specific vCU     gnb_index=${gnb_index}
    sleep    5s
    [Teardown]    KW.vCULogout    connection=${connection}

KW.StopService
#    [Arguments]    ${ns}   ${pod_name}=cpnrt
    [Arguments]    ${pod_name}=cpnrt
    ${conn_alias}    KW.connect_CU_server
    ${Command}     Catenate     SEPARATOR=${SPACE}
    ...    ns=${ns} && kubectl get pod -n $ns | grep ${pod_name} |awk '{print $1}'|xargs kubectl delete pod -n $ns
    ssh.Execute    command=${Command}    connection=${conn_alias}
    Wait Until Keyword Succeeds  10min   5s    KW.CheckPodRunning     ${pod_name}    ${conn_alias}
    KW.disconnect_CU_server  conn_alias=${conn_alias}

##----------------------------------process recovery------------------------

KW.VDU.KilProcessIDInContainer
    [Arguments]    ${pod_name}=oamconfig   ${container_name}=oamconfig    ${processpath}=/opt/nokia/SS_OAM/CPCONFIG/CPCONFIG
    Run Keyword And Ignore Error   helm.helm_master_close
    ${conn_alias}    KW.vDUSSHLogin
    ${channel} =    Call Method    ${conn_alias}    invoke_shell
    Call Method    ${channel}   recv      ${65535}
    Call Method    ${channel}
    ...  send   kubectl exec -it -n ${ns} po-${pod_name}-0 -c ctr-${container_name} -- bash\n
    sleep    3s
    ${initial_output}  Call Method    ${channel}    recv      ${65535}
    Call Method    ${channel}    send     ps -ef|grep -i ${processpath}\n
    sleep    3s
    ${process_output_tmp}  Call Method    ${channel}    recv      ${65535}
    ${process_output_tmp}    Convert To String   ${process_output_tmp}
    @{process_output}=    Split String    ${process_output_tmp}   \r\n
    FOR  ${i}  IN  @{process_output}
       ${matches}=         get regexp matches  ${i}          9999
       ${matches_length}=  get length          ${matches}
       @{process_info}  run keyword if  ${matches_length}>0   Split String  ${i}
       Exit For Loop If     ${matches_length}>0
    END
    Call Method    ${channel}    send    date;kill -9 ${process_info[1]}\n
    sleep   15s
    [Return]   ${process_info[1]}
    [Teardown]   Run Keyword And Ignore Error   helm.helm_master_close

KW.vDUSSHLogin
    [Arguments]  ${vdu_index}=0  ${gnb_index}=0
    ${conn}=  helm.helm_master_connect
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.ip_addr}
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.port}
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.username}
    ...  ${tl.gnbs[${gnb_index}].dus[${vdu_index}].cloud_deployment.cloud_hosting.master_node.k8s_connection_details.password}
    [Return]   ${conn}

KW.Check_process_resiliency
    [Documentation]  Will run 1 case, check vDU process recovery and cell lock and unlock
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${pod_name}=oamconfig   ${container_name}=oamconfig
    ...          ${processpath}=/opt/nokia/SS_OAM/CPCONFIG/CPCONFIG
    ${cell_list}     Cloud Get Cells Id List    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.VDU.KilProcessIDInContainer    pod_name=${pod_name}    container_name=${container_name}    processpath=${processpath}
    sleep   30s
    Wait Until Keyword Succeeds  15min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${cell_list}    Cloud Get Cells Id List    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${vdu_connection}    KW.vDULogin    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    FOR    ${index}    IN    @{cell_list}
        ${cell_id_list}    create list    ${index}
        vdu.lock_cells    cell_id_list=${cell_id_list}    vdu_connection=${vdu_connection}
        Wait Until Keyword Succeeds    5min    5s    KW.CheckCellStatus    cell_id=${index}
        ...    administrative_state=Locked   operational_state=disabled   blocking_state=Unblocked    vdu_connection=${vdu_connection}
        sleep   30s
        vdu.unlock_cells    cell_id_list=${cell_id_list}    vdu_connection=${vdu_connection}
        Wait Until Keyword Succeeds    15min    30s    KW.CheckCellStatus    cell_id=${index}
        ...    administrative_state=Unlocked   operational_state=enabled   blocking_state=Unblocked    vdu_connection=${vdu_connection}
        Exit For Loop
    END
    Wait Until Keyword Succeeds  15min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    set test variable    ${loopStatus}    pass
    [Teardown]    KW.vDULogout    vdu_connection=${vdu_connection}

##----------------------------------Container recovery------------------------
KW.vDU.RestartContainer
    [Arguments]    ${pod_name}=oamconfig   ${container_name}=oamconfig
    ${conn_alias}    KW.connect_DU_server
    ${Command}     Catenate     SEPARATOR=${SPACE}
    ...    date;ns=${ns} &&pod=${pod_name} && kubectl exec -it po-$pod-0 -c ctr-${container_name} -n $ns -- pkill ministarter
    ssh.Execute    command=${Command}    connection=${conn_alias}
    sleep   15s
    Wait Until Keyword Succeeds  10min   5s    KW.CheckPodRunning    ${pod_name}    ${conn_alias}
    KW.disconnect_DU_server  conn_alias=${conn_alias}

KW.Check_vDU_container_recovery
    [Documentation]  Will run 1 case, check vDU pod recovery and cell block
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0    ${pod_name}=oamconfig   ${container_name}=oamconfig
    ${cell_list}     Cloud Get Cells Id List    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.vDU.RestartContainer    ${pod_name}    ${container_name}
    sleep   30s
    Wait Until Keyword Succeeds  5min   30s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${cell_list}    Cloud Get Cells Id List    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${vdu_connection}    KW.vDULogin    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    FOR    ${index}    IN    @{cell_list}
        ${cell_id_list}    create list    ${index}
        vdu.lock_cells    cell_id_list=${cell_id_list}    vdu_connection=${vdu_connection}
        Wait Until Keyword Succeeds    5min    10s    KW.CheckCellStatus    cell_id=${index}
        ...    administrative_state=Locked   operational_state=disabled   blocking_state=Unblocked    vdu_connection=${vdu_connection}

        vdu.unlock_cells    cell_id_list=${cell_id_list}    vdu_connection=${vdu_connection}
        Wait Until Keyword Succeeds    15min    15s    KW.CheckCellStatus    cell_id=${index}
        ...    administrative_state=Unlocked   operational_state=enabled   blocking_state=Unblocked    vdu_connection=${vdu_connection}
        Exit For Loop
    END
    Wait Until Keyword Succeeds  10min   5s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    set test variable    ${loopStatus}    pass
    [Teardown]    KW.vDULogout    vdu_connection=${vdu_connection}
#----------------------------------resiliency vDU pod recovery------------------------
KW.StopServicevDU
    [Arguments]    ${pod_name}=oamconfig
    ${conn_alias}    KW.connect_DU_server
    ${Command}     Catenate     SEPARATOR=${SPACE}
    ...    ns=${ns} && kubectl get pod -n $ns | grep ${pod_name} |awk '{print $1}'|xargs kubectl delete pod -n $ns
    ssh.Execute    command=${Command}    connection=${conn_alias}
    Wait Until Keyword Succeeds  10min   5s    KW.CheckPodRunning    ${pod_name}    ${conn_alias}
    KW.disconnect_DU_server  conn_alias=${conn_alias}
KW.CheckPodRunning
    [Arguments]    ${pod_name}=oamconfig    ${conn_alias}=none
    ${result}    ssh.Execute    command=kubectl get pod -n ${ns}|grep po-${pod_name}|awk '{print($3)}'    connection=${conn_alias}
    ${length}	 Get Length	   ${result}
    run keyword if    ${length}==0    Fail    no result output
    ${runningStates}    Split String    ${result}    \r\n
    FOR    ${runningState}    IN    @{runningStates}
        run keyword if    '${runningState}'==''    Continue For Loop
        run keyword if    ${runningState.count('Running')}==0    Fail    pod is not in running state.
    END
KW.Check_vDU_pod_restart
    [Documentation]  Will run 1 case, check vDU pod recovery and cell block
    [Arguments]     ${gnb_index}=0    ${vdu_index}=0    ${pod_name}=oamconfig
    ${cell_list}     Cloud Get Cells Id List    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    KW.StopServicevDU    ${pod_name}
    sleep   30s
    Wait Until Keyword Succeeds  15min   5s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${cell_list}    Cloud Get Cells Id List    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    ${vdu_connection}    KW.vDULogin    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    FOR    ${index}    IN    @{cell_list}
        ${cell_id_list}    create list    ${index}
        vdu.lock_cells    cell_id_list=${cell_id_list}    vdu_connection=${vdu_connection}
        Wait Until Keyword Succeeds    15min    5s    KW.CheckCellStatus    cell_id=${index}
        ...    administrative_state=Locked   operational_state=disabled   blocking_state=Unblocked    vdu_connection=${vdu_connection}
        sleep   30s
        vdu.unlock_cells    cell_id_list=${cell_id_list}    vdu_connection=${vdu_connection}
        Wait Until Keyword Succeeds    15min    5s    KW.CheckCellStatus    cell_id=${index}
        ...    administrative_state=Unlocked   operational_state=enabled   blocking_state=Unblocked    vdu_connection=${vdu_connection}
        Exit For Loop
    END
    Wait Until Keyword Succeeds  15min   5s    All Cells Should Be Onair For One Specific vDU    vdu_index=${vdu_index}    gnb_index=${gnb_index}
    set test variable    ${loopStatus}    pass
    [Teardown]    KW.vDULogout    vdu_connection=${vdu_connection}

#-----------------------------------
KW.GetvCUCellsID
    [Arguments]    ${gnb_index}=0
    ${connection}  KW.vCULogin    gnb_index=${gnb_index}
    ${id_list}    Create List
    ${infos}    cu.get_cu_cells_diff    connection=${connection}
    log to console   ${infos}
    FOR    ${info}    IN    @{infos["created"]}
        Append To List    ${id_list}    ${info["basic_cell"]["id"]}
    END
    [Return]    ${id_list}
    [Teardown]   KW.vCULogout    connection=${connection}

KW.CheckvCUOpStatus
    [Arguments]    ${operation_id}    ${expect_result}    ${connection}=none
    ${opt_info}    cu.get_opeartion_state_of_locking_du    operation_id=${operation_id}    connection=${connection}
    Should Be True    "${opt_info["status"]}"=="${expect_result}"

KW.CheckRannicStatus
    [Arguments]    ${operation_id}    ${expected_status}    ${vdu_connection}=none
    log to console  Check Rannic Reset Operation Status...
    ${operation_info}    vdu.get_rnic_reset_operation    operation_id=${operation_id}    vdu_connection=${vdu_connection}
    Should Be True    "${operation_info}[status]"=="${expected_status}"

KW.vDUCheckParameterAsExpected
    [Arguments]    ${mo_dn}    ${parameter}    ${value}    ${gnb_index}=0    ${vdu_index}=0
    ${parameters}    KW.vDUGetParmeters    mo_dn=${mo_dn}    parameter=${parameter}    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    should be true   '${parameters}'=='${value}'

KW.PowerOff5GRUs
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0
    ${length}=   Get Length     ${tl.gnbs[${gnb_index}].dus[${vdu_index}].rus}
    FOR    ${i}    IN RANGE    ${length}
        Power.OnOff     pdu_ip=${tl.gnbs[${gnb_index}].dus[${vdu_index}].rus[${i}].pdu_port.pdu.addr}
        ...                 Port_Number=${tl.gnbs[${gnb_index}].dus[${vdu_index}].rus[${i}].pdu_port.port_no}
        ...                 Action=power_off
        ...                 model=${tl.gnbs[${gnb_index}].dus[${vdu_index}].rus[${i}].pdu_port.pdu.vendor}
    END

KW.PowerOn5GRUs
    [Arguments]    ${gnb_index}=0    ${vdu_index}=0
    ${length}=   Get Length     ${tl.gnbs[${gnb_index}].dus[${vdu_index}].rus}
    FOR    ${i}    IN RANGE    ${length}
        Power.OnOff     pdu_ip=${tl.gnbs[${gnb_index}].dus[${vdu_index}].rus[${i}].pdu_port.pdu.addr}
        ...                 Port_Number=${tl.gnbs[${gnb_index}].dus[${vdu_index}].rus[${i}].pdu_port.port_no}
        ...                 Action=power_on
        ...                 model=${tl.gnbs[${gnb_index}].dus[${vdu_index}].rus[${i}].pdu_port.pdu.vendor}
    END

TC.BaseLoopOperation
    [Arguments]   ${kpiList}    ${times}    ${func}    ${gnb_index}=0    ${vdu_index}=0
    KW.OAMKPICaseStart    KPIsList=${kpiList}    retry_times=${times}    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    KW.ExecuteFuncWithLoop   function_name=${func}    retry_times=${times}    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    [Teardown]    KW.OAMKPICaseEnd    times=${times}    gnb_index=${gnb_index}    vdu_index=${vdu_index}

KW.ExecuteFuncWithLoop
    [Arguments]    ${function_name}   ${retry_times}=3    ${gnb_index}=0    ${vdu_index}=0
    #GnbReset for reset alarm check
    Set Test Variable    ${GnbReset}    True
    FOR    ${i}    IN RANGE    ${retry_times}
        KW.OAMKPILoopStart    gnb_index=${gnb_index}    vdu_index=${vdu_index}
        #KW.StartLogCollection
        ${res}     Run Keyword and ignore error    ${function_name}    loop=${i+1}
        #${alarm_result}    KW.GetAndCheckAlarm
        #KW.StopLogCollection    isCellOnair=${isCellOnair}    alarm_result=${alarm_result}    loop=${i}
        KW.OAMKPILoopEnd    loop=${i}  isCellOnair=${res[1]}    alarm_result=${true}    gnb_index=${gnb_index}    vdu_index=${vdu_index}
        Run Keyword If   '${res[0]}'=='FAIL'    Fail    loop ${i} failed, please check
    END

KW.SuiteSetup
    [Documentation]
    [Arguments]    ${AdaptConfigurationPath}=${False}
    run keyword if     ${AdaptConfigurationPath}     run keyword and ignore error    UTECloud.ForceAdaptCommissionFiles
    TestSuilt.Start
    Create Log Directories
    set suite variable   ${OAM_TYPE}    COAM
    Conn.ResetCache
    run keyword and ignore error    Import Variables         /home/ute/TAF/cfgfile/2479_Loop_times.py
    run keyword and ignore error    set suite variable    ${REFERENCE_CONFIGURATION_ID}
    ...    ${CASE_INPUT_5GC002479['ID']['REFERENCE_CONFIGURATION_ID']}
    run keyword and ignore error    set suite variable    ${GoldenSCF_PATH}         ${GoldenSCF_ON_GIT}/${GoldenSCF}
    set suite variable    ${ns}    ${tl.gnbs[0].cloud_deployment.cloud_hosting.namespace}
    set suite variable    ${SCFPrepared}    notstart
    set suite variable    ${StopCase}       false
    set suite variable    ${CaseState}      notstart

    Basic.CheckVariableValid    var=CASE_INPUT_OAMKPI_CLOUD['vCUReset']['retry_times']    default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_OAMKPI_CLOUD['vDUReset']['retry_times']    default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_OAMKPI_CLOUD['vDURUReset']['retry_times']    default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_OAMKPI_CLOUD['vCUCellReset']['retry_times']    default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_OAMKPI_CLOUD['vCUX2LockUnlock']['retry_times']    default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_OAMKPI_CLOUD['vCUDULockUnlock']['retry_times']    default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_OAMKPI_CLOUD['vDURULockUnlock']['retry_times']    default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_OAMKPI_CLOUD['vDUCellLockUnlock']['retry_times']    default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_OAMKPI_CLOUD['vDUCellBlockUnblock']['retry_times']    default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_OAMKPI_CLOUD['vDURannicReset']['retry_times']    default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_OAMKPI_CLOUD['vDUALDReset']['retry_times']    default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_OAMKPI_CLOUD['vDUDeltaPlan']['retry_times']    default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_OAMKPI_CLOUD['vDUFullPlan']['retry_times']    default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_OAMKPI_CLOUD['vCUDeltaPlan']['retry_times']    default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_OAMKPI_CLOUD['vCUFullPlan']['retry_times']    default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_OAMKPI_CLOUD['vCUCellLockUnlock']['retry_times']    default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_OAMKPI_CLOUD['vCUNGLockUnlock']['retry_times']    default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_OAMKPI_CLOUD['vDUDeltaPlanWithBlocking']['retry_times']    default_value=1    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_OAMKPI_CLOUD['vDUDeltaPlanWithSiteReset']['retry_times']    default_value=1    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_OAMKPI_CLOUD['vDURUPowerReset']['retry_times']    default_value=1    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUNRTSResiliency']['retry_times']    default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUl2nrtResiliency']['retry_times']    default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUahmResiliency']['retry_times']    default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUoamasmResiliency']['retry_times']    default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUoamcmResiliency']['retry_times']    default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUoamfmResiliency']['retry_times']    default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUoamkpianalyzerResiliency']['retry_times']    default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUoampmResiliency']['retry_times']    default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUoamswmResiliency']['retry_times']    default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUremotestorageResiliency']['retry_times']    default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUsecurestorageResiliency']['retry_times']    default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vCU_Resiliency['vCUCPNBResiliency']['retry_times']    default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vCU_Resiliency['vCUCPNRTResiliency']['retry_times']    default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vCU_Resiliency['vCUNRTSResiliency']['retry_times']    default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vCU_Resiliency['vCUCPIFResiliency']['retry_times']    default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vCU_Resiliency['vCUCPCLResiliency']['retry_times']    default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vCU_Resiliency['vCUCPUEResiliency']['retry_times']    default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vCU_exploring['vCUX2LinkSCTPFail']['retry_times']     default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vCU_exploring['vCUF1LinkSCTPFail']['retry_times']     default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vCU_exploring['vCUNGLinkSCTPFail']['retry_times']     default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vCU_exploring['vCUXNLinkSCTPFail']['retry_times']     default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUoamconfigCPCONFIGProcess']['retry_times']    default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUoamconfigTRSCONFIGProcess']['retry_times']    default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUoamconfigNTSProcess']['retry_times']    default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUoamcofigTASProcess']['retry_times']    default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUoamcofigImsProcess']['retry_times']    default_value=1    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUoamcofigIMSNAPSHOTProcess']['retry_times']    default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUoamcofigFaultServiceExeProcess']['retry_times']    default_value=1    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUoamcofigMEDProcess']['retry_times']    default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUoamfmfmProcess']['retry_times']    default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUoamkpianalyzerProcess']['retry_times']    default_value=1    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUoamswmKPIanalyzerProcess']['retry_times']    default_value=1    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUoamcmCMProcess']['retry_times']    default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUoamcmCMserviceProcess']['retry_times']    default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUoamasmASMProcess']['retry_times']    default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUoamasmFaultServicesExeProcess']['retry_times']    default_value=1    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUoamasmEmsrviceProcess']['retry_times']    default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUoampmPMstatProcess']['retry_times']    default_value=1    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUoampmPMDataseverProcess']['retry_times']    default_value=1    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUoambbIMSNAPSHOTProcess']['retry_times']    default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUoamfhMEDProcess']['retry_times']    default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUoamfhIMSNAPSHOTProcess']['retry_times']    default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUoamfhNETCONFProcess']['retry_times']    default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUoamextoamagentProcess']['retry_times']    default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUoamextTCConfiguratorProcess']['retry_times']    default_value=1    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUoamextTCMasterProcess']['retry_times']    default_value=1    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUoamextne3sadaptProcess']['retry_times']    default_value=1    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUoamextcnumserverProcess']['retry_times']    default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUoamcalcimsnapshotProcess']['retry_times']    default_value=5    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUoamconfigoamconfigcontainer']['retry_times']    default_value=1    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUoamfmContainer']['retry_times']    default_value=1    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUoamkpianalyzerContainer']['retry_times']    default_value=1    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUoamswmContainer']['retry_times']    default_value=1    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUoamcmContainer']['retry_times']    default_value=1    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUoamasmContainer']['retry_times']    default_value=1    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUoamembeContainer']['retry_times']    default_value=1    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUoampmContainer']['retry_times']    default_value=1    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUoamdispatcherContainer']['retry_times']    default_value=1    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUPMDataServerContainer']['retry_times']    default_value=1    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUnwmgmtContainer']['retry_times']    default_value=1    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUsftpserverContainer']['retry_times']    default_value=1    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUnftmgmtContainer']['retry_times']    default_value=1    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUDHCPContainer']['retry_times']    default_value=1    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUTracecontrollerContainer']['retry_times']    default_value=1    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUne3sadaptContainer']['retry_times']    default_value=1    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUnftmgmtContainer']['retry_times']    default_value=1    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUhttpdContainer']['retry_times']    default_value=1    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUlogforwarderContainer']['retry_times']    default_value=1    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUipsecmgmtContainer']['retry_times']    default_value=1    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUcnumserverContainer']['retry_times']    default_value=1    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUoamlssclientContainer']['retry_times']    default_value=1    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUtestportserverContainer']['retry_times']    default_value=1    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUoamdispatcherContainer']['retry_times']    default_value=1    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUipcapturemgmtContainer']['retry_times']    default_value=1    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUcertmanContainer']['retry_times']    default_value=1    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUnftmgmtContainer']['retry_times']    default_value=1    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUhaagentContainer']['retry_times']    default_value=1    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUl2rtContainer']['retry_times']    default_value=1    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUl2hiContainer']['retry_times']    default_value=1    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUipsecmgmtContainer']['retry_times']    default_value=1    is_digit=True
    Basic.CheckVariableValid    var=CASE_INPUT_vDU_Resiliency['vDUl1commproxyContainer']['retry_times']    default_value=1    is_digit=True
    KW.CaseStatusInit    retry_times=${100}
    wait until keyword succeeds    30min    10s    All Cells Should Be Onair For All vDUs

KW.SuiteTeardown
    #TestSuite.Stop
    log to console    SuiteTeardown
