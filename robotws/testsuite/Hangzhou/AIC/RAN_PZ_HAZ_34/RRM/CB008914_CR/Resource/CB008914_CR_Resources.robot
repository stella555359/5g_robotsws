*** Settings ***
Documentation     author:yajie.li
...               Group: HGZ_SG1
...               contact: yajie.li@nokia-sbell.com

Resource          ../../../../../resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_cu.robot
Resource          ../../../../../resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_state.robot
Resource          ../../../../../resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_vdu.robot

Resource        testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_vcu.robot
Resource        testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_vdu.robot

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

@{du_id}     1
##################define these variable for convenient############################

########################END of alias Define#######################################

*** Keywords ***

####Case Level  Keywords#####
TC.General_SiSo_vDU_Reset
    KW.Reset VDU
    sleep    1min
    wait until keyword succeeds     15min    30s
    ...     All Cells Should Be Onair For One Specific vCU    gnb_index=0
    wait until keyword succeeds     15min    30s     vDU Verify All Cells Status Should Be Onair


TC.General_SiSo_E2E_system_setup_with_data_transfer_conducted
    wait until keyword succeeds     15min    30s
    ...     All Cells Should Be Onair For One Specific vCU    gnb_index=0
    wait until keyword succeeds     15min    30s     vDU Verify All Cells Status Should Be Onair
    Run Keyword And Continue On Failure    KW.block cell
    sleep    30s
    Run Keyword And Continue On Failure    MultiUE.L3Call      UECFG=${UECFG_SA}
    Run Keyword And Continue On Failure     KW.unblock cell
    wait until keyword succeeds     15min    30s     vDU Verify All Cells Status Should Be Onair

TC.General_SiSo_vDU_Lock_Unlock
    KW.CU lock_unlock VDU
    wait until keyword succeeds     15min    30s
    ...     All Cells Should Be Onair For One Specific vCU    gnb_index=0
    wait until keyword succeeds     15min    30s     vDU Verify All Cells Status Should Be Onair
    Run Keyword And Continue On Failure    KW.block cell    cell_idx=1
    Run Keyword And Continue On Failure    KW.block cell    cell_idx=3
    sleep    30s
    Run Keyword And Continue On Failure    MultiUE.L3Call      UECFG=${UECFG_SA}
    Run Keyword And Continue On Failure     KW.unblock cell    cell_idx=1
    Run Keyword And Continue On Failure     KW.unblock cell    cell_idx=3
    wait until keyword succeeds     15min    30s     vDU Verify All Cells Status Should Be Onair


KW.CU lock_unlock VDU
    [Arguments]   ${gnb_index}=0
    CU Login      gnb_index=${gnb_index}    cu_version=cuoam_25r2
    cu.lock_du    du_id=@{du_id}
    sleep    1min
    cu.unlock_du    du_id=@{du_id}
    wait until keyword succeeds     15min    30s
    ...     All Cells Should Be Onair For One Specific vCU    gnb_index=0
    wait until keyword succeeds     15min    30s     vDU Verify All Cells Status Should Be Onair


Setup Suite
    log to console     Suite start
    Create Logs Folder For Test Case
    Import Variables        ${CFGFILE_PATH}TLConfiguration.py
    set suite variable     ${UECFG_SA}         ${TLCommonConfig_SAUE['MultiUECFG']}
    set suite variable     ${MRBTS_ID}        ${CASE_INPUT_CB008914['CB008914']['MRBTS_ID']}
    set suite variable     ${NRBTS_ID}        ${CASE_INPUT_CB008914['CB008914']['NRBTS_ID']}
#    gNB.GenerateCaseSCFCUDU     original_cfgfile_CU=${CFGFILE_PATH}/${CU_GoldenSCF}
#      ...    modified_cfgfile_CU=${LOG_PATH}/8914_CU_SCF.xml     original_cfgfile_DU=${CFGFILE_PATH}/${DU_GoldenSCF}
#      ...    modified_cfgfile_DU=${LOG_PATH}/8914_DU_SCF.xml    ResourceFolder=${CURDIR}
#      ...    parameters_to_delete_CU=PARAMS_TO_DELETE_CU    mo_to_add_CU=MOs_TO_ADD_CU
#      ...    parameters_to_modify_CU=PARAMS_TO_MODIFY_CU    list_parameter_to_modify_CU=LIST_PARAMS_TO_MODIFY_CU
#      ...    list_to_add_CU=LIST_TO_ADD_CU
#      ...    parameters_to_delete_DU=PARAMS_TO_DELETE_DU    mo_to_add_DU=MOs_TO_ADD_DU
#      ...    parameters_to_modify_DU=PARAMS_TO_MODIFY_DU    list_parameter_to_modify_DU=LIST_PARAMS_TO_MODIFY
#      ...    list_to_add_DU=LIST_TO_ADD_DU
#    KW.Cloud Commission And Check On Air    CU_SCF=${LOG_PATH}/8914_CU_SCF.xml    DU_SCF=${LOG_PATH}/8914_DU_SCF.xml
    wait until keyword succeeds     15min    30s
    ...     All Cells Should Be Onair For One Specific vCU    gnb_index=0
    wait until keyword succeeds     3min    30s     vDU Verify All Cells Status Should Be Onair
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
    wait until keyword succeeds     15min    30s
    ...     All Cells Should Be Onair For One Specific vCU    gnb_index=0
    wait until keyword succeeds     15min    30s     vDU Verify All Cells Status Should Be Onair


CU Full Commission Fix Error
    [Arguments]    ${path_of_commission_file}    ${gnb_index}=0
    [Documentation]   vCU commission
    log to console   \n*** Start vCU commission ***
    CU Login  ${gnb_index}      cu_version=cuoam_25r2
    vCU Load And Active SCF   ${path_of_commission_file}
    [Teardown]    run keyword and ignore error   CU Logout


vDU Full Commission SCF Fix Error
    [Arguments]     ${path_of_commission_file}   ${restapi_version}=cuoam_25r2   ${vdu_index}=0
    [Documentation]   vCU commission
    log to console   \n*** Start vDU commission ***
    KW.vDU_Login    ${restapi_version}     ${vdu_index}
    vDU Load And Active SCF   ${path_of_commission_file}
    [Teardown]    run keyword and ignore error   vDU Logout

vCU Load And Active SCF
    [Arguments]     ${path_of_commission_file}    ${wait_active}=${True}
    log to console     ${wait_active}
    log to console   \n*** Start plan upload operation ***
    cu.perform_commissioning      scf_file=${path_of_commission_file}
#    ${upload_operation_info}=   cu.upload_plan_file     ${path_of_commission_file}
#    log to console   \n*** Wait plan upload operation success ***
#    wait until keyword succeeds    60s   5s  CU Check Plan Upload Status Should Be As Expected
#    ...    ${upload_operation_info["action_id"]}    success
#    log to console   \n*** Start plan fix error ***
#    ${fix_err_operation}=   cu.fix_plan_validation_errors    ${upload_operation_info['plan_id']}
#    ...   add_missing_objects=${True}   fix_mandatory_parameters=${True}
#    sleep   60s
#    log to console   \n*** Start plan validate operation ***
#    ${validate_operaition_info}=  cu.plan_validation    ${upload_operation_info["plan_id"]}
#    log to console   \n*** Wait plan validate operation success ***
#    wait until keyword succeeds    60s   5s  CU Check Plan Validate Status Should Be As Expected
#    ...    ${upload_operation_info["plan_id"]}   ${validate_operaition_info["action_id"]}    success
#    log to console   \n*** Start plan activate operation ***
#    ${activate_operaition_info}=  cu.plan_activation   ${upload_operation_info["plan_id"]}
#    run keyword if    ${wait_active}==${True}    log to console   \n*** Wait plan activate operation success in 5 mins ***
#    run keyword if    ${wait_active}==${True}    wait until keyword succeeds    600s   30s  CU Check Plan Activate Status Should Be As #Expected
#    ...    ${upload_operation_info["plan_id"]}  ${activate_operaition_info["id"]}    success

vDU Load And Active SCF
    [Arguments]     ${path_of_commission_file}
    [Documentation]   load SCF and active SCF
    log to console   \n*** Start plan upload operation ***
    vdu.perform_commissioning      scf_file=${path_of_commission_file}
#    ${upload_plan_response}=  vdu.upload_plan    ${path_of_commission_file}
#    wait until keyword succeeds  10s  1s
#    ...    Upload Plan Operation Should Be Successful  ${upload_plan_response['action_id']}
#    log to console   \n*** Start plan fix error ***
#    ${fix_err_response}=   vdu.fix_vdu_staged_plan_error    ${upload_plan_response['plan_id']}
#    wait until keyword succeeds  30s  10s  Fix vDU SCF Validation Errors Should Be Successful
#    ...    ${upload_plan_response['plan_id']}  ${fix_err_response['action_id']}
#    log to console   \n*** Start plan validate operation ***
#    ${validate_plan_response}=  vdu.validate_plan   ${upload_plan_response['plan_id']}
#    wait until keyword succeeds  10s  1s  Validate Plan Operation Should Be Successful
#    ...  ${upload_plan_response['plan_id']}
#    ...  ${validate_plan_response['action_id']}
#    log to console   \n*** Start plan activate operation ***
#    ${activate_plan_response}=  vdu.activate_plan  ${upload_plan_response['plan_id']}
#    wait until keyword succeeds  15m  20s  Activate Plan Operation Should Be Successful
#    ...  ${upload_plan_response['plan_id']}
#    ...  ${activate_plan_response['id']}

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


KW.Reset VDU
    [Arguments]    ${restapi_version}=cuoam_25r2   ${vdu_index}=0
    ${alias}   KW.vDU_Login    restapi_version=${restapi_version}     vdu_index=${vdu_index}
    ${out}   vdu.reset_vdu    vdu_connection=${alias}
    ${error_msg}   set variable  ${out["error_message"]}
    should contain  ${error_msg}   No error


KW.block cell
    [Arguments]    ${cell_idx}=2    ${vdu_index}=0    ${restapi_version}=cuoam_25r2
    ${alias}   KW.vDU_Login    restapi_version=${restapi_version}     vdu_index=${vdu_index}
    Run Keyword And Continue On Failure     vdu.block_cell    cell_id=${cell_idx}    vdu_connection=${alias}
    Run Keyword And Continue On Failure    vDU Logout


KW.unblock cell
    [Arguments]    ${cell_idx}=2    ${vdu_index}=0    ${restapi_version}=cuoam_25r2
    ${alias}   KW.vDU_Login    restapi_version=${restapi_version}     vdu_index=${vdu_index}
    Run Keyword And Continue On Failure     vdu.unblock_cell    cell_id=${cell_idx}    vdu_connection=${alias}
    Run Keyword And Continue On Failure    vDU Logout

KW.vDU_Login
    [Arguments]    ${restapi_version}=cuoam_25r2     ${vdu_index}=0    ${gnb_index}=0
    vdu.connect_to
    ...   host=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.addr}
    ...   port=443
    ...   username=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.username}
    ...   password=${tl.gnbs[${gnb_index}].dus[${vdu_index}].oam_http_connection_details.password}
    ...   vdu_version=${restapi_version}
    ...   secure=true