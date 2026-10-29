*** Settings ***
Documentation     author:yajie.li
...               Group: HGZ_SG1
...               contact: yajie.li@nokia-sbell.com

Resource          ../../../../../resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_cu.robot
Resource          ../../../../../resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_state.robot
Resource          ../../../../../resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_vdu.robot

#Resource          ../../../../AIC/RAN_PZ_HAZ_34/Resources/aic_common_resources.robot
Resource       ../../../../../RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/L3Call.robot
Resource       taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Library        taf.transport.ssh    WITH NAME    csn
Library        Process


*** Variables ***
${CFGFILE_PATH}       /opt/transformers.dynamic.nsn-net.net/gnb_configuration/Hangzhou/${testline_name}/

${UE_TYPE}                   ${tl.ues[0].capabilities[-1]}
${IMSI1}                     ${tl.ues[0].imsi}

${UTE_IP}                   ${tl.test_pc.default_ssh_connection_details.addr}
${UTE_USERNAME}             ${tl.test_pc.default_ssh_connection_details.username}
${UTE_PASSWORD}             ${tl.test_pc.default_ssh_connection_details.password}

##################define these variable for convenient############################

########################END of alias Define#######################################

*** Keywords ***

####Case Level  Keywords#####
TC.General_SiSo_Cell_block_and_unblock
    KW.Block Cell In vDU
    sleep    30s
    KW.Check DU Alarms    fault_id=${Fault_Id}    fault_name=${Fault_Name}   alarm_id=${Alarm_Id}    alarming_object=${Alarm_Object}
    KW.Unblock Cell In vDU
    sleep    30s
    KW.Check DU Alarms Disappear    fault_id=${Fault_Id}    fault_name=${Fault_Name}   alarm_id=${Alarm_Id}    alarming_object=${Alarm_Object}
    wait until keyword succeeds     15min    30s     CU Verify All Cells Status Are Onair
    wait until keyword succeeds     15min    30s     vDU Verify All Cells Status Should Be Onair



Setup Suite
    log to console     Suite start
    Create Logs Folder For Test Case
    Import Variables        ${CFGFILE_PATH}TLConfiguration.py
    set suite variable     ${MRBTS_ID}        ${CASE_INPUT_CB009835['CB009835']['MRBTS_ID']}
    set suite variable     ${NRBTS_ID}        ${CASE_INPUT_CB009835['CB009835']['NRBTS_ID']}
    set suite variable     ${Alarm_Object}        ${CASE_INPUT_CB009835['CB009835']['alarming_object']}
    set suite variable     ${Alarm_Id}        ${CASE_INPUT_CB009835['CB009835']['alarm_id']}
    set suite variable     ${Fault_Id}        ${CASE_INPUT_CB009835['CB009835']['fault_id']}
    set suite variable     ${Fault_Name}        ${CASE_INPUT_CB009835['CB009835']['fault_name']}
    gNB.GenerateCaseSCFCUDU     original_cfgfile_CU=${CFGFILE_PATH}/${CU_GoldenSCF}
      ...    modified_cfgfile_CU=${LOG_PATH}/9835_CU_SCF.xml     original_cfgfile_DU=${CFGFILE_PATH}/${DU_GoldenSCF}
      ...    modified_cfgfile_DU=${LOG_PATH}/9835_DU_SCF.xml    ResourceFolder=${CURDIR}
      ...    parameters_to_delete_CU=PARAMS_TO_DELETE_CU    mo_to_add_CU=MOs_TO_ADD_CU
      ...    parameters_to_modify_CU=PARAMS_TO_MODIFY_CU    list_parameter_to_modify_CU=LIST_PARAMS_TO_MODIFY_CU
      ...    list_to_add_CU=LIST_TO_ADD_CU
      ...    parameters_to_delete_DU=PARAMS_TO_DELETE_DU    mo_to_add_DU=MOs_TO_ADD_DU
      ...    parameters_to_modify_DU=PARAMS_TO_MODIFY_DU    list_parameter_to_modify_DU=LIST_PARAMS_TO_MODIFY
      ...    list_to_add_DU=LIST_TO_ADD_DU
    KW.Cloud Commission And Check On Air    CU_SCF=${LOG_PATH}/9835_CU_SCF.xml    DU_SCF=${LOG_PATH}/9835_DU_SCF.xml
    Conn.ResetCache


Teardown Suite
    log to console     Suite teardown


Setup case
    log to console     Case Start


Teardown case
    Run Keyword And Ignore Error    run    command=ps -ef|grep firefox|grep -v grep|awk '{print $2}' | xargs kill -9
    Conn.ResetCache
    log to console     Case teardown


KW.Cloud Commission And Check On Air
    [Arguments]    ${CU_SCF}    ${DU_SCF}
    CU Full Commission Fix Error          path_of_commission_file=${CU_SCF}
    vDU Full Commission SCF Fix Error     path_of_commission_file=${DU_SCF}
    sleep    1min
    wait until keyword succeeds     15min    30s     CU Verify All Cells Status Are Onair
    wait until keyword succeeds     15min    30s     vDU Verify All Cells Status Should Be Onair


CU Full Commission Fix Error
    [Arguments]    ${path_of_commission_file}    ${gnb_index}=0
    [Documentation]   vCU commission
    log to console   \n*** Start vCU commission ***
    CU Login  ${gnb_index}
    vCU Load And Active SCF   ${path_of_commission_file}
    [Teardown]    run keyword and ignore error   CU Logout


vDU Full Commission SCF Fix Error
    [Arguments]     ${path_of_commission_file}   ${restapi_version}=cuoam_19b   ${vdu_index}=0
    [Documentation]   vCU commission
    log to console   \n*** Start vDU commission ***
    vDU Rest Login    ${restapi_version}     ${vdu_index}
    vDU Load And Active SCF   ${path_of_commission_file}
    [Teardown]    run keyword and ignore error   vDU Logout

vCU Load And Active SCF
    [Arguments]     ${path_of_commission_file}    ${wait_active}=${True}
    log to console   \n*** Start plan upload operation ***
    ${upload_operation_info}=   cu.upload_plan_file     ${path_of_commission_file}
    log to console   \n*** Wait plan upload operation success ***
    wait until keyword succeeds    60s   5s  CU Check Plan Upload Status Should Be As Expected
    ...    ${upload_operation_info["action_id"]}    success
    log to console   \n*** Start plan fix error ***
    ${fix_err_operation}=   cu.fix_plan_validation_errors    ${upload_operation_info['plan_id']}
    ...   add_missing_objects=${True}   fix_mandatory_parameters=${True}
    sleep   60s
    log to console   \n*** Start plan validate operation ***
    ${validate_operaition_info}=  cu.plan_validation    ${upload_operation_info["plan_id"]}
    log to console   \n*** Wait plan validate operation success ***
    wait until keyword succeeds    60s   5s  CU Check Plan Validate Status Should Be As Expected
    ...    ${upload_operation_info["plan_id"]}   ${validate_operaition_info["action_id"]}    success
    log to console   \n*** Start plan activate operation ***
    ${activate_operaition_info}=  cu.plan_activation   ${upload_operation_info["plan_id"]}
    run keyword if    ${wait_active}==${True}    log to console   \n*** Wait plan activate operation success in 5 mins ***
    run keyword if    ${wait_active}==${True}    wait until keyword succeeds    600s   30s  CU Check Plan Activate Status Should Be As Expected
    ...    ${upload_operation_info["plan_id"]}  ${activate_operaition_info["id"]}    success

vDU Load And Active SCF
    [Arguments]     ${path_of_commission_file}
    [Documentation]   load SCF and active SCF
    log to console   \n*** Start plan upload operation ***
    ${upload_plan_response}=  vdu.upload_plan    ${path_of_commission_file}
    wait until keyword succeeds  10s  1s
    ...    Upload Plan Operation Should Be Successful  ${upload_plan_response['action_id']}
    log to console   \n*** Start plan fix error ***
    ${fix_err_response}=   vdu.fix_vdu_staged_plan_error    ${upload_plan_response['plan_id']}
    wait until keyword succeeds  30s  10s  Fix vDU SCF Validation Errors Should Be Successful
    ...    ${upload_plan_response['plan_id']}  ${fix_err_response['action_id']}
    log to console   \n*** Start plan validate operation ***
    ${validate_plan_response}=  vdu.validate_plan   ${upload_plan_response['plan_id']}
    wait until keyword succeeds  10s  1s  Validate Plan Operation Should Be Successful
    ...  ${upload_plan_response['plan_id']}
    ...  ${validate_plan_response['action_id']}
    log to console   \n*** Start plan activate operation ***
    ${activate_plan_response}=  vdu.activate_plan  ${upload_plan_response['plan_id']}
    wait until keyword succeeds  10m  20s  Activate Plan Operation Should Be Successful
    ...  ${upload_plan_response['plan_id']}
    ...  ${activate_plan_response['id']}

Fix vCU SCF Validation Errors Should Be Successful
    [Arguments]  ${plan_id}  ${action_id}
    ${fix_err_response}=   vdu.get_fix_vdu_staged_plan_operation_status  ${plan_id}  ${action_id}
    should be equal as strings  ${fix_err_response['status']}  success
    log to console    Fix SCF Errors Success

Upload Plan Operation Should Be Successful
     [Arguments]  ${upload_action_id}
    [Documentation]   checking upload plan operation status should be successful
    ...    *AUTHOR*  calla.wang@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | upload_action_id | yes | upload action id, get from upload_plan |
    ...    *RETURN VALUE*
    ...    None
    ${upload_operation_response}=  vdu.get_upload_plan_operation_status  ${upload_action_id}
    should be equal as strings  ${upload_operation_response['status']}  success
    log to console    Upload Plan Success

Validate Plan Operation Should Be Successful
    [Arguments]  ${plan_id}  ${action_id}
    [Documentation]   checking validate plan operation status should be successful
    ${validate_plan_response}=  vdu.get_validate_plan_operation_status  ${plan_id}  ${action_id}
    should be equal as strings  ${validate_plan_response['status']}  success
    log to console    Validate Plan Success

Fix vDU SCF Validation Errors Should Be Successful
    [Arguments]  ${plan_id}  ${action_id}
    ${fix_err_response}=   vdu.get_fix_vdu_staged_plan_operation_status  ${plan_id}  ${action_id}
    should be equal as strings  ${fix_err_response['status']}  success
    log to console    Fix SCF Errors Success


Activate Plan Operation Should Be Successful
    [Arguments]  ${plan_id}  ${action_id}
    [Documentation]   checking activate plan operation status should be successful
    ${activate_plan_response}=  vdu.get_activate_plan_operation_status  ${plan_id}  ${action_id}
    should be equal as strings  ${activate_plan_response['status']}  success
    log to console    Activate Plan Success


KW.Check DU Alarms
    [Arguments]    ${fault_id}    ${fault_name}    ${alarm_id}    ${alarming_object}
    vDU Login
    ${res}    vdu.vdu_get_active_alarms
    ${alarms}    Get From Dictionary    ${res}    alarms

    FOR      ${alarm}    IN    @{alarms}
       ${status}   Run Keyword And Return Status    Run Keywords    Should Be Equal As Strings    ${alarm['fault_id']}    ${fault_id}
        ...    AND    Should Be Equal As Strings    ${alarm['fault_name']}    ${fault_name}
        ...    AND     Should Be Equal As Strings    ${alarm['alarm_id']}    ${alarm_id}
        ...    AND     Should Be Equal As Strings    ${alarm['alarming_object']}    ${alarming_object}
       exit for loop if    '${status}'=='True'
    END
    Run Keyword And Continue On Failure    vDU Logout

KW.Check DU Alarms Disappear
    [Arguments]    ${fault_id}    ${fault_name}    ${alarm_id}    ${alarming_object}
    vDU Login
    ${res}    vdu.vdu_get_active_alarms
    ${alarms}    Get From Dictionary    ${res}    alarms
    FOR      ${alarm}    IN    @{alarms}
       ${status}   Run Keyword And Return Status    Run Keywords    Should Be Equal As Strings    ${alarm['fault_id']}    ${fault_id}
        ...    AND    Should Not Be Equal as Strings   ${alarm['fault_name']}    ${fault_name}
        ...    AND     Should Not Be Equal as Strings    ${alarm['alarm_id']}    ${alarm_id}
        ...    AND     Should Not Be Equal as Strings    ${alarm['alarming_object']}    ${alarming_object}
       exit for loop if    '${status}'=='True'
    END
    Run Keyword And Continue On Failure    vDU Logout


KW.Block Cell In vDU
    [Arguments]    ${cell_id}=1    ${vdu_index}=0    ${alias}=default
    vDU Login    vdu_index=${vdu_index}
    ${cell_id}    convert to string     ${cell_id}
    ${out}    vdu.block_cell    cell_id=${cell_id}    vdu_connection=${alias}
    Wait Until Keyword Succeeds  60   3   KW.Check Block Cell Should Be Expected   operation_id=${out["id"]}
    ...    expected_status=success    vdu_connection=${alias}
    vdu.delete_block_cell_operation    operation_id=${out["id"]}
    [Teardown]    vDU Logout


KW.Unblock Cell In vDU
    [Arguments]    ${cell_id}=1    ${vdu_index}=0    ${alias}=default
    vDU Login    vdu_index=${vdu_index}
    ${cell_id}    convert to string     ${cell_id}
    ${out}    vdu.unblock_cell    cell_id=${cell_id}    vdu_connection=${alias}
    Wait Until Keyword Succeeds  60   3   KW.Check Unblock Cell Should Be Expected   operation_id=${out["id"]}
    ...    expected_status=success    vdu_connection=${alias}
    vdu.delete_unblock_cell_operation   operation_id=${out["id"]}
    [Teardown]    vDU Logout


KW.Check Block Cell Should Be Expected
    [Arguments]    ${operation_id}    ${expected_status}    ${timeout}=${60}    ${vdu_connection}=default
    ${out}    vdu.get_block_cell_operation_status    operation_id=${operation_id}    timeout=${timeout}
    ...    vdu_connection=${vdu_connection}
    Should Be True    "${out["status"]}"=="${expected_status}"

KW.Check Unblock Cell Should Be Expected
    [Arguments]    ${operation_id}    ${expected_status}    ${timeout}=${60}     ${vdu_connection}=default
    ${out}    vdu.get_unblock_cell_operation_status    operation_id=${operation_id}    timeout=${timeout}
    ...    vdu_connection=${vdu_connection}
    Should Be True    "${out["status"]}"=="${expected_status}"