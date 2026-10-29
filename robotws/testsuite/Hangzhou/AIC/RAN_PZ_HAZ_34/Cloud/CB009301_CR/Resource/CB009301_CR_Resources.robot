*** Settings ***
Documentation     author:Wang Bin
...               Group: HGZ_SG1
...               contact: bin.3.wang@nokia-sbell.com

Resource          ../../../../../resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_cu.robot
Resource          ../../../../../resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_vdu.robot
Resource       ../../../../../RRM/RAN_PZ_HAZ_34/5GC000496_C/Resources/L3Call.robot
Resource       taf/rfrl/common_resources/robot/connection_alias_store.robot
Resource       taf/rfrl/cbts/robot/vdu/vdu_operations.robot
Resource       taf/rfrl/cbts/robot/vcu/vcu_operations.robot
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG8/SG08_keywords_cloud.robot
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_ru.robot
Library        taf.transport.ssh    WITH NAME    csn
Library        Process
Library        SeleniumLibrary
Library        SSHLibrary
Library        taf.gnb.oam.coam.vdu.interface.vdu    WITH NAME    vdu
Library        taf.gnb.oam.coam.cu    WITH NAME    coam_vcu
Library        taf.gnb.oam.coam.vdu    WITH NAME    coam_vdu
Library        taf.config.scf    WITH NAME    scf

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
TC.Cell_setup_with_CB009301_enabled
    [Documentation]
    [Arguments]  ${disable_9301.json}=${CFGFILE_PATH}disable_9301.json
    ...          ${enable_9301.json}=${CFGFILE_PATH}enable_9301.json
    ...          ${DU_host}=${CASE_INPUT_CB009301['CB009301']['vDU_host']}
    ...          ${Mo_num}=${CASE_INPUT_CB009301['CB009301']['MO_num']}
    ...          ${RF6.2_Mimo}=${CASE_INPUT_CB009301['CB009301']['RF6.2_Mimo']}
    log to console    Start to disable CB009301
    wait until keyword succeeds     15min    30s    coam_vdu.connect_to
    ...   host=${DU_host}    port=443    username=Nemuadmin    password=Nokia@123    secure=true
    wait until keyword succeeds     15min    30s    coam_vdu.perform_delta_recommissioning
    ...                             delta_file=${disable_9301.json}
    run keyword and ignore error  coam_vdu.disconnect
    log to console    Start to check cell status with CB009301 disabled
    wait until keyword succeeds     15min    30s     CU Verify All Cells Status Are Onair
    wait until keyword succeeds     15min    30s     vDU Verify All Cells Status Should Be Onair
    run keyword and ignore error    KW.check CB009301 Mos should not exist    DU_host=${DU_host}
    log to console    Start to enable CB009301
    wait until keyword succeeds     15min    30s    coam_vdu.connect_to
    ...   host=${DU_host}    port=443    username=Nemuadmin    password=Nokia@123    secure=true
    wait until keyword succeeds     15min    30s    coam_vdu.perform_delta_recommissioning
    ...                             delta_file=${enable_9301.json}
    run keyword and ignore error  coam_vdu.disconnect
    log to console    Start to check cell status with CB009301 enabled
    wait until keyword succeeds     15min    30s     CU Verify All Cells Status Are Onair
    wait until keyword succeeds     15min    30s     vDU Verify All Cells Status Should Be Onair
    wait until keyword succeeds     2min    60s     KW.check CB009301 Mos and results should exist
    ...    DU_host=${DU_host}    Mo_num=${Mo_num}    RF6.2_Mimo=${RF6.2_Mimo}

TC.vDU_reset_with_CB009301_enabled
    [Documentation]   Reset vDU
    [Arguments]  ${loop_times}=${CASE_INPUT_CB009301['vDU_reset']['loop_times']}
    ...          ${duration_target}=${CASE_INPUT_CB009301['vDU_reset']['duration_target']}
    ...          ${DU_host}=${CASE_INPUT_CB009301['CB009301']['vDU_host']}
    ...          ${Mo_num}=${CASE_INPUT_CB009301['CB009301']['MO_num']}
    ...          ${RF6.2_Mimo}=${CASE_INPUT_CB009301['CB009301']['RF6.2_Mimo']}
    ${duration_KPI}      set variable    0
    FOR  ${i}  IN RANGE  1  ${loop_times}+1
        Wait until keyword succeeds   2min   20s    vDU Rest Login
        Log to console    start to  Reset  vDU loop${i}
        ${start_time}    Get Time    epoch
        Wait until keyword succeeds   2min   5s    vdu.reset_vdu
        Sleep  180s
        Run Keyword And Ignore error    vDU Rest Logout
        log to console    check cell status should be on air for du...
        wait until keyword succeeds     10min    5s    Verify All Cells Status Should Be Onair for vDU
        log to console    check cell status should be  enabled for cu...
        wait until keyword succeeds     10min    5s    Verify All Cells Are Enabled for CU
        ${end_time}    Get Time    epoch
        ${duration_tmp}=    Evaluate    ${end_time} - ${start_time}
        Should be true    ${duration_tmp} < ${duration_target}*1.2
        ${duration_KPI}=    Evaluate    ${duration_tmp} + ${duration_KPI}
        Set test Variable    ${duration_KPI}    ${duration_KPI}
        Log to console    start to  check results of CB009301 for loop${i}
        wait until keyword succeeds     1min    20s    KW.check CB009301 Mos and results should exist
        ...    DU_host=${DU_host}    Mo_num=${Mo_num}    RF6.2_Mimo=${RF6.2_Mimo}
    END
    ${duration_KPI}    Evaluate   round(${duration_KPI}/${loop_times}, 2)
    Log to console    The duration of vDU reset is ${duration_KPI}s
    Should be true    ${duration_KPI} < ${duration_target}

TC.CB013940_A_1_RU raises fault 4680 and cancels the fault by timer
    [Documentation]   Check CB013940 Timer could work with Cloud BTS
    [Arguments]  ${command1}=${CASE_INPUT_CB013940['CB013940']['command1']}
    ...          ${command2}=${CASE_INPUT_CB013940['CB013940']['command2']}
    ...          ${ru_index}=${CASE_INPUT_CB013940['CB013940']['ru_index']}
    ...          ${fid}=${CASE_INPUT_CB013940['CB013940']['fid']}
    KW.CB013940 Precondition Preparation    ru_index=${ru_index}
    log to console    Step1: Trigger fault 4680 by command
    Wait Until Keyword Succeeds    2x    1min    KW.Trigger fault 4680 on Cloud RU    command1=${command1}
    ...    command2=${command2}    fid=${fid}    loops=${Unstable_threshold}
    log to console    Step2: Check fault 4680 should be cleared after Timer expired
    wait until keyword succeeds   ${Timer_13940}min    60s    KW.Expect Fault Should Absent On vDU    fault_id=4680    alarm_id=7100
    wait until keyword succeeds     10min    30s    All Cells Should Be Onair For One Specific vDU
    log to console    Fault 4680 cleared and NR cell back to normal!

KW.CB013940 Precondition Preparation
    [Documentation]
    [Arguments]    ${ru_index}
    wait until keyword succeeds     15min    30s     All Cells Should Be Onair For One Specific vDU
    vDU Login
    ${Unstable_threshold_t}    Online Get VDU Parameter Value
    ...    mo_dn=MRBTS-${MRBTSID}/EQM-1/APEQM-1/RMOD-${ru_index}
    ...    para_name=alVoltUnstableThreshold
    Run Keyword If    '${Unstable_threshold_t}' == '0'    Fatal Error    Fault4680 was disabled and test case end
    ${Timer_bts_1}    Online Get VDU Parameter Value
    ...    mo_dn=MRBTS-${MRBTSID}/EQM-1/APEQM-1
    ...    para_name=alVoltUnstableExpirationTimerRU
    ${Timer_bts_2}    Split String    ${Timer_bts_1}    ${SPACE}
    ${Timer_bts_3}    Convert To Integer    ${Timer_bts_2}[0]
    ${Timer_ru_1}    Online Get VDU Parameter Value
    ...    mo_dn=MRBTS-${MRBTSID}/EQM-1/APEQM-1/RMOD-${ru_index}
    ...    para_name=alVoltUnstableExpirationTimer
    ${Timer_ru_2}    Split String    ${Timer_ru_1}    ${SPACE}
    ${Timer_ru_3}    Convert To Integer    ${Timer_ru_2}[0]
    Run Keyword If    ${Timer_ru_3} == 0    Set Suite Variable    ${Timer_13940}    9999
    ...    ELSE IF    ${Timer_ru_3} > 0    Set Suite Variable    ${Timer_13940}    ${Timer_ru_3}
    ...    ELSE IF    ${Timer_bts_3} > 0    Set Suite Variable    ${Timer_13940}    ${Timer_bts_3}
    ...    ELSE    Set Suite Variable    ${Timer_13940}    9999
    Run Keyword If    ${Timer_13940} == 9999    Fatal Error    CB013940 was disabled and test case end
    Log to console    CB013940 Precondition check done
    set test variable    ${Timer_bts}    ${Timer_bts_3}
    set test variable    ${Timer_ru}    ${Timer_ru_3}
    set test variable    ${Unstable_threshold}    ${Unstable_threshold_t}
    ${is_dc_t}    Cloud Get RU Direct Connection Flag
    ${ns_t}    Get Vdu Namespace
    set test variable    ${is_dc}    ${CASE_INPUT_CB013940['CB013940']['is_dc']}
    set test variable    ${ns}    ${ns_t}
    vDU Logout
    [Return]    ${Timer_bts}    ${Timer_ru}    ${Unstable_threshold}    ${is_dc}    ${ns}

KW.Trigger fault 4680 on Cloud RU
    [Documentation]   Connect to RU and execute command
    [Arguments]  ${command1}=1    ${command2}=2    ${fid}=2919    ${alarm_id}=7100    ${loops}=1
    Log to console    Start to trigger fault 4680
    FOR  ${i}  IN RANGE    0  ${loops}
        KW.Set Voltage via Command    cmd=${command1}    is_dc=${is_dc}    ns=${ns}
        Sleep  90s
        Run keyword If    ${i} < ${loops} - 1    KW.Expect Fault Should Present On vDU    fault_id=${fid}    alarm_id=${alarm_id}
            ...    ELSE    KW.Expect Fault Should Present On vDU    fault_id=4680    alarm_id=${alarm_id}
        KW.Set Voltage via Command    cmd=${command2}    is_dc=${is_dc}    ns=${ns}
        Sleep  90s
        Run keyword If    ${i} < ${loops} - 1    Run Keywords    KW.Expect Fault Should Present On vDU    fault_id=${fid}
        ...    alarm_id=${alarm_id}
        ...    AND    Sleep  5min
        ...    AND    KW.Expect Fault Should Absent On vDU    fault_id=${fid}    alarm_id=${alarm_id}
        ...    ELSE    KW.Expect Fault Should Present On vDU    fault_id=4680    alarm_id=${alarm_id}
    END

KW.Set Voltage via Command
    [Documentation]
    [Arguments]    ${cmd}=1    ${is_dc}=0    ${ns}=0
    ...    ${ru_sn}=${CASE_INPUT_CB013940['CB013940']['ru_sn']}
    ...    ${ocp_ip}=${CASE_INPUT_CB013940['CB013940']['ocp_ip']}
    ...    ${ocp_usr}=${CASE_INPUT_CB013940['CB013940']['ocp_usr']}
    ...    ${ocp_psw}=${CASE_INPUT_CB013940['CB013940']['ocp_psw']}
    ...    ${ru_usr}=${CASE_INPUT_CB013940['CB013940']['ru_usr']}
    ...    ${ru_psw}=${CASE_INPUT_CB013940['CB013940']['ru_psw']}
    SSHLibrary.Open Connection    ${ocp_ip}
    SSHLibrary.Login    ${ocp_usr}    ${ocp_psw}
    Sleep  3s
    ${cmd_GetRuIp}   Set Variable
    ...    kubectl exec -it po-oamfh-0 -c ctr-oamfh -n ${ns} -- bash -c "grep "${ru_sn}" /ffs/run/config/FRIps.txt"
    ${output}=    SSHLibrary.Execute Command    ${cmd_GetRuIp}
    ${ru_ip_t}    Split String    ${output}    ;
    ${ru_ip}    Set Variable    ${ru_ip_t}[-3]
    ${cmd_t}    Set Variable    kubectl exec -it po-oamfh-0 -c ctr-oamfh -n
    SSHLibrary.Set Client Configuration    prompt=succesfully for domain 17
    Run Keyword If    '${is_dc}' == '0'
    ...  SSHLibrary.Write  ${cmd_t} ${ns} -- bash -c "ssh -o StrictHostKeyChecking=no ${ru_usr}@${ru_ip}"
    ...  ELSE  SSHLibrary.Write  ${cmd_t} ${ns} -- bash -c "ssh -b 70.70.70.1 -o StrictHostKeyChecking=no ${ru_usr}@${ru_ip}"
    sleep  3s
    ${res}    run keyword and return status    SSHLibrary.Read Until    password:
    run keyword if    '${res}' == 'True'    SSHLibrary.Write    ${ru_psw}
    Sleep  2s
    SSHLibrary.Write    ${cmd}
    Sleep  1s
    ${output}=    SSHLibrary.Read Until Prompt
    SSHLibrary.Close All Connections

KW.Expect Fault Should Present On vDU
    [Arguments]    ${fault_id}    ${alarming_object}=${None}    ${severity}=${None}    ${alarm_id}=${None}
    ...            ${vdu_index}=0    ${alias}=default
    ${fault_id}    Convert To Integer    ${fault_id}
    vDU Login    vdu_index=${vdu_index}
    ${alarms}    vdu.vdu_get_active_alarms    vdu_connection=${alias}
    ${alarm_num}    Get From Dictionary    ${alarms}    total
    Run Keyword If    ${alarm_num}==0    Fail
    ${alarms}    Get From Dictionary    ${alarms}    alarms
    ${present_status}    Set Variable    ${False}
    FOR  ${alarm}  IN  @{alarms}
        ${present_status}    Run Keyword And Return Status    Run Keywords
        ...    Dictionary Should Contain Item    ${alarm}    fault_id    ${fault_id}    AND
        ...    Run Keyword If    '${alarming_object}'!='${None}'
        ...    Should Contain     ${alarm['alarming_object']}    ${alarming_object}    case_insensitive=True    AND
        ...    Run Keyword If    '${severity}'!='${None}'
        ...    Should Contain     ${alarm['severity']}   ${severity}    case_insensitive=True    AND
        ...    Run Keyword If    '${alarmId}'!='${None}'
        ...    Should Be Equal As Strings    ${alarm['alarm_id']}    ${alarm_id}
        Exit For Loop If    ${present_status}
    END
    Run Keyword If    ${present_status}==${False}    Fail
    [Teardown]  Run keyword and ignore error    vDU Rest Logout

KW.Expect Fault Should Absent On vDU
    [Arguments]   ${fault_id}   ${alarming_object}=${None}    ${severity}=${None}    ${alarm_id}=${None}
    ...    ${vdu_index}=0    ${alias}=default
    ${fault_id}    Convert To Integer    ${fault_id}
    vDU Rest Login    vdu_index=${vdu_index}
    ${status}    Run Keyword And Return Status   KW.Expect Fault Should Present On vDU
    ...          fault_id=${fault_id}
    ...          alarming_object=${alarming_object}
    ...          severity=${severity}
    ...          alarm_id=${alarm_id}
    ...          vdu_index=${vdu_index}
    ...          alias=${alias}
    Run Keyword If  ${status}==${True}   Fail
    [Teardown]  Run keyword and ignore error    vDU Rest Logout

KW.check CB009301 Mos should not exist
    [Documentation]   Reset vDU
    [Arguments]  ${DU_host}=1.1.1.1
    wait until keyword succeeds     15min    30s    coam_vdu.connect_to
    ...   host=${DU_host}    port=443    username=Nemuadmin    password=Nokia@123    secure=true
    ${runtime_scf}    wait until keyword succeeds     15min    30s
    ...                             coam_vdu.get_current_plan_file    local_dir_path=${CFGFILE_PATH}    filename=scf.xml
    run keyword and ignore error  coam_vdu.disconnect
    scf.load_scf  ${runtime_scf}
    ${CB009301_results_tmp}    scf.get_all_dist_names_of_specific_class    mo_class=com.nokia.srbts.eqmr:FHLKDLY_R
    ${9301_Mo_num_tmp}    Get Length    ${CB009301_results_tmp}
    Should be true    ${9301_Mo_num_tmp}==0
    Log to console     CB009301 Mos Not created!

KW.check CB009301 Mos and results should exist
    [Documentation]
    [Arguments]   ${DU_host}=1.1.1.1    ${Mo_num}=1    ${RF6.2_Mimo}=False
    wait until keyword succeeds     15min    30s    coam_vdu.connect_to
    ...   host=${DU_host}    port=443    username=Nemuadmin    password=Nokia@123    secure=true
    ${runtime_scf}    wait until keyword succeeds     1min    30s
    ...                             coam_vdu.get_current_plan_file    local_dir_path=${CFGFILE_PATH}    filename=scf.xml
    run keyword and ignore error  coam_vdu.disconnect
    scf.load_scf  ${runtime_scf}
    ${CB009301_results_tmp}    scf.get_all_dist_names_of_specific_class    mo_class=com.nokia.srbts.eqmr:FHLKDLY_R
    ${9301_Mo_num_tmp}    Get Length    ${CB009301_results_tmp}
    run keyword if    ${RF6.2_Mimo}    Should be true    ${9301_Mo_num_tmp} >= ${Mo_num}
    ...    ELSE    Should be true    ${9301_Mo_num_tmp} == ${Mo_num}
    Log to console     CB009301 Mos created!
    FOR  ${item}  IN  @{CB009301_results_tmp}
        ${dlMinDelay}    scf.get_value_from_scf    dist_name=${item}    p_name=dlMinDelay
        Should not be empty    ${dlMinDelay}
        Should be true     ${dlMinDelay} > 0
        ${ulMinDelay}    scf.get_value_from_scf    dist_name=${item}    p_name=ulMinDelay
        Should not be empty    ${ulMinDelay}
        Should be true     ${ulMinDelay} > 0
    END
    Log to console    CB009301 results Not empty and updated!


Setup Suite
    log to console     Suite start
    Create Logs Folder For Test Case
    Import Variables         ${CFGFILE_PATH}/TLConfiguration.py
    set suite variable     ${MRBTS_ID}        ${CASE_INPUT_CB009301['CB009301']['MRBTS_ID']}
    set suite variable     ${NRBTS_ID}        ${CASE_INPUT_CB009301['CB009301']['NRBTS_ID']}
##    gNB.GenerateCaseSCFCUDU     original_cfgfile_CU=${CFGFILE_PATH}/${CU_GoldenSCF}
##      ...    modified_cfgfile_CU=${LOG_PATH}/8914_CU_SCF.xml     original_cfgfile_DU=${CFGFILE_PATH}/${DU_GoldenSCF}
##      ...    modified_cfgfile_DU=${LOG_PATH}/8914_DU_SCF.xml    ResourceFolder=${CURDIR}
##      ...    parameters_to_delete_CU=PARAMS_TO_DELETE_CU    mo_to_add_CU=MOs_TO_ADD_CU
##      ...    parameters_to_modify_CU=PARAMS_TO_MODIFY_CU    list_parameter_to_modify_CU=LIST_PARAMS_TO_MODIFY_CU
##      ...    list_to_add_CU=LIST_TO_ADD_CU
##      ...    parameters_to_delete_DU=PARAMS_TO_DELETE_DU    mo_to_add_DU=MOs_TO_ADD_DU
##      ...    parameters_to_modify_DU=PARAMS_TO_MODIFY_DU    list_parameter_to_modify_DU=LIST_PARAMS_TO_MODIFY
##      ...    list_to_add_DU=LIST_TO_ADD_DU
    KW.Cloud Commission And Check On Air    CU_SCF=${CFGFILE_PATH}CB009301_vCU_base_SCF.xml
      ...                                   CU_host=${CASE_INPUT_CB009301['CB009301']['vCU_host']}
      ...                                   DU_SCF=${CFGFILE_PATH}CB009301_vDU_base_SCF.xml
      ...                                   DU_host=${CASE_INPUT_CB009301['CB009301']['vDU_host']}
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
    [Arguments]    ${CU_SCF}    ${DU_SCF}    ${CU_host}    ${DU_host}
    CB011055 CU Full Commission        path_of_commission_file=${CU_SCF}    host=${CU_host}
    CB011055 vDU Full Commission    path_of_commission_file=${DU_SCF}    host=${DU_host}
    sleep    1min
    wait until keyword succeeds     15min    30s     All Cells Should Be Onair For One Specific vCU
    wait until keyword succeeds     15min    30s     All Cells Should Be Onair For One Specific vDU

CB011055 CU Full Commission
    [Arguments]    ${path_of_commission_file}    ${host}
    [Documentation]   vCU commission
    log to console   \n*** Start vCU commission ***
    wait until keyword succeeds     15min    30s    coam_vcu.connect_to
     ...   host=${host}   port=443    username=Nemuadmin    password=Nokia@123    secure=true
    coam_vcu.perform_commissioning   scf_file=${path_of_commission_file}
    [Teardown]    run keyword and ignore error   coam_vcu.disconnect


CB011055 vDU Full Commission
    [Arguments]     ${path_of_commission_file}    ${host}
    [Documentation]   vCU commission
    log to console   \n*** Start vDU commission ***
    wait until keyword succeeds     15min    30s    coam_vdu.connect_to
     ...   host=${host}   port=443    username=Nemuadmin    password=Nokia@123    secure=true
    coam_vdu.perform_commissioning   scf_file=${path_of_commission_file}
    [Teardown]    run keyword and ignore error   coam_vdu.disconnect

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


KW.Reset VDU
    [Arguments]    ${restapi_version}=cuoam_19b   ${vdu_index}=0
    ${alias}   vDU Rest Login    restapi_version=${restapi_version}     vdu_index=${vdu_index}
    ${out}   vdu.reset_vdu    vdu_connection=${alias}
    ${error_msg}   set variable  ${out["error_message"]}
    should contain  ${error_msg}   No error


KW.block cell
    [Arguments]    ${cell_idx}=2    ${vdu_index}=0    ${restapi_version}=cuoam_19b
    ${alias}   vDU Rest Login    restapi_version=${restapi_version}     vdu_index=${vdu_index}
    Run Keyword And Continue On Failure     vdu.block_cell    cell_id=${cell_idx}    vdu_connection=${alias}
    Run Keyword And Continue On Failure    vDU Logout


KW.unblock cell
    [Arguments]    ${cell_idx}=2    ${vdu_index}=0    ${restapi_version}=cuoam_19b
    ${alias}   vDU Rest Login    restapi_version=${restapi_version}     vdu_index=${vdu_index}
    Run Keyword And Continue On Failure     vdu.unblock_cell    cell_id=${cell_idx}    vdu_connection=${alias}
    Run Keyword And Continue On Failure    vDU Logout

Change The Password Of Serviceuser Account Via Webem
    [Arguments]   ${gnb_index}=0  ${vdu_index}=0  ${serviceuser_new_pwd}=Nokia@123
    Log To Console   Change The Password Of Serviceuser Account Via Webem
    vDU Rest Login    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ${response}    vdu.update_service_account_password     username=serviceuser
    ...                                                    password=${EMPTY}
    ...                                                    new_password=${serviceuser_new_pwd}
    Should Be Equal    ${response['content']}    Success
    [Teardown]       VDU Rest Logout

Active SSH Access and Port for RUs
    [Arguments]
    vDU Rest Login
    Run Keyword And Continue On Failure    vdu.config_ssh_tunnel
    ...    dist_name=MRBTS-37235/EQM-1/APEQM-1/RMOD-1    operation=Enable
    sleep  5s
    Run Keyword And Continue On Failure    vdu.config_ssh_tunnel
    ...    dist_name=MRBTS-37235/EQM-1/APEQM-1/RMOD-2    operation=Enable


    vDU Logout

Login to RUs via SSH
    [Arguments]  ${host}=0.0.0.0
    ...          ${port}=51201
    ...          ${username}=serviceuser
    ...          ${password}=Nokia@123
    wait until keyword succeeds     30s    30s     SSHLibrary.Open Connection
    ...                host=${host}
    ...                port=${port}
    wait until keyword succeeds     2min    30s     SSHLibrary.Login
    ...                username=${username}
    ...                password=${password}

Logout RU
    SSHLibrary.close connection

Get power from RU via FRMON command
    [Arguments]  ${cmd1}=echo "/ action create PsuMeasurements /psum /rf/psu"|frmonShellClient 127.0.0.1 2000
    ...          ${cmd2}=echo "/psum get power_support"|frmonShellClient 127.0.0.1 2000
    ...          ${cmd3}=echo "/psum action measure"|frmonShellClient 127.0.0.1 2000
    Log to console    Start check power via FRMON command
    SSHLibrary.Start Command    ${cmd1}
    Sleep  2s
    SSHLibrary.Start Command    ${cmd2}
    Sleep  2s
    ${power}      set variable    0
    FOR  ${i}   IN RANGE   ${3}
           Sleep    3
           Wait Until Keyword Succeeds  60s   20s    SSHLibrary.Start Command    ${cmd3}
           ${_power_tmp}=    SSHLibrary.Read Command Output
           ${_power_tmp}    Split String    ${_power_tmp}    POWER
           ${_power_tmp}    Get From List    ${_power_tmp}    1
           ${_power_tmp}    Split String    ${_power_tmp}    \n
           ${_power_tmp}    Get From List    ${_power_tmp}    0
           ${power}    Evaluate   int(${_power_tmp})+${power}
    END
    ${power}    Evaluate   round(${power}/${3}, 2)
    [Return]   ${power}




