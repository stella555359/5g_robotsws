*** Settings ***
Documentation     author:hongyan yuan
...               Group: HGZ_SG1
...               contact:

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

${ENB_WEBUI_IP}             ${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}
${ENBWEBUI_URL}             https://${tl.enbs[0].airscale.common_units[0].lmp_connection.addr}

${PA1_INFO}                  ${tl.attenuators[0]}
${PA2_INFO}                  ${tl.attenuators[1]}

##################define these variable for convenient############################

########################END of alias Define#######################################

*** Keywords ***

####Case Level  Keywords#####

TC.ST__Basics__RU_Stability_test_run
    [Arguments]     ${times}=3    ${cells}=1   ${time_length}=300s
    [Documentation]   Make five 3 minutes lasting calls in a row.
    FOR  ${item}  IN RANGE    ${times}
        KW.UE attach with ULDL traffic   cells=${CASE_INPUT_CB009444['CB009444']['cell2']}    time_length=${time_length}
    END

TC.ST__Basics__RF_lock_and_unlock_SA
    [Arguments]   ${rmods}    ${cells}=1
    [Documentation]
    KW.Lock_unlock RU   rmods=${rmods}
    wait until keyword succeeds     15min    30s     CU Verify All Cells Status Are Onair
    wait until keyword succeeds     15min    30s     vDU Verify All Cells Status Should Be Onair
    KW.UE attach with ULDL traffic   cells=${cells}    time_length=60s

TC.ST__Basics__RF_reset_SA
    [Arguments]   ${rmods}    ${cells}=1
    [Documentation]
    KW.Reset RU   rmods=${rmods}
    wait until keyword succeeds     15min    30s     CU Verify All Cells Status Are Onair
    wait until keyword succeeds     15min    30s     vDU Verify All Cells Status Should Be Onair
    KW.UE attach with ULDL traffic   cells=${cells}    time_length=60s

####Case Level Keywords#####
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


KW.PA_Adjust Attenuation Ports To Same Value
    [Arguments]    ${ports}    ${value}    ${attenuator}   ${logging_message}=Adjusting PA values
    log to console    ${logging_message}
    PA_.setup_attenuator    attenuator=${attenuator}
    ${length}    Get Length    ${ports}
    FOR    ${i}    IN RANGE    ${length}
      PA_.set_attenuation     port=${ports[${i}]}    value=${value}
      PA_.read_attenuation    port=${ports[${i}]}
    END


KW.Adjust PA To Default Value
    [Arguments]
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${eNBRU_PA_Ports}
    ...    value=${CASE_INPUT_CB007199['CB007199']['PA_Value_1']}   attenuator=${PA2_INFO}
    ...    logging_message=Setting PA values for eNB default value.
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${5GRU1_PA_Ports}
    ...    value=${CASE_INPUT_CB007199['CB007199']['PA_Value_1']}   attenuator=${PA2_INFO}
    ...    logging_message=Setting PA values for RU1 default value.
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${5GRU2_PA_Ports}
    ...    value=${CASE_INPUT_CB007199['CB007199']['PA_Value_2']}   attenuator=${PA2_INFO}
    ...    logging_message=Setting PA values for RU2 default value.

KW.Adjust PA To Handover Value
    [Arguments]
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${5GRU2_PA_Ports}
    ...    value=${CASE_INPUT_CB007199['CB007199']['PA_Value_4']}   attenuator=${PA2_INFO}
    ...    logging_message=Setting PA values for RU1 default value.
    KW.PA_Adjust Attenuation Ports To Same Value    ports=${5GRU1_PA_Ports}
    ...    value=${CASE_INPUT_CB007199['CB007199']['PA_Value_3']}   attenuator=${PA2_INFO}
    ...    logging_message=Setting PA values for RU2 default value.

KW.Get Stream Version
    [Arguments]  ${build_version}=${AF_PATH}
    ${artifactory_path}   ${package_name}  Split String From Right	  ${build_version} 	/	1
    ${stream_info}  ${remaining}   Split String  ${package_name} 	_	1
    ${remaining}  ${stream_version}   Split String From Right	  ${stream_info}    CNF    1
    ${stream}    set variable if   '${stream_version}'=="00"    Trunk    ${stream_version}
    log to console   The stream to run is ${stream}.
    [Return]    ${stream}

Setup Suite
    log to console     Suite start
    Create Logs Folder For Test Case
    Import Variables        ${CFGFILE_PATH}TLConfiguration.py
    set suite variable     ${MRBTS_ID}        ${CASE_INPUT_CB009444['CB009444']['MRBTS_ID']}
    set suite variable     ${NRBTS_ID}        ${CASE_INPUT_CB009444['CB009444']['NRBTS_ID']}
    ${stream_version}    KW.Get Stream Version
    ${CU_base_SCF}    set variable     ${stream_version}_CU_base_SCF.xml
    ${DU_base_SCF}    set variable     ${stream_version}_DU_base_SCF.xml
    gNB.GenerateCaseSCFCUDU     original_cfgfile_CU=${CFGFILE_PATH}/${CU_base_SCF}
      ...    modified_cfgfile_CU=${LOG_PATH}/9444_CU_SCF.xml     original_cfgfile_DU=${CFGFILE_PATH}/${DU_base_SCF}
      ...    modified_cfgfile_DU=${LOG_PATH}/9444_DU_SCF.xml    ResourceFolder=${CURDIR}
      ...    parameters_to_delete_CU=PARAMS_TO_DELETE_CU    mo_to_add_CU=MOs_TO_ADD_CU
      ...    parameters_to_modify_CU=PARAMS_TO_MODIFY_CU    list_parameter_to_modify_CU=LIST_PARAMS_TO_MODIFY_CU
      ...    list_to_add_CU=LIST_TO_ADD_CU
      ...    parameters_to_delete_DU=PARAMS_TO_DELETE_DU    mo_to_add_DU=MOs_TO_ADD_DU
      ...    parameters_to_modify_DU=PARAMS_TO_MODIFY_DU    list_parameter_to_modify_DU=LIST_PARAMS_TO_MODIFY
      ...    list_to_add_DU=LIST_TO_ADD_DU
    KW.Cloud Commission And Check On Air    CU_SCF=${LOG_PATH}/9444_CU_SCF.xml    DU_SCF=${LOG_PATH}/9444_DU_SCF.xml
    Conn.ResetCache

Teardown Suite
    log to console     Suite teardown

Setup case
    log to console     Case Start

Teardown case
    KW.Check DU Alarms
    KW.Check CU Alarms
    Run Keyword And Ignore Error    run    command=ps -ef|grep firefox|grep -v grep|awk '{print $2}' | xargs kill -9
    Conn.ResetCache
    log to console     Case teardown


KW.UE attach with ULDL traffic
    [Arguments]    ${cells}   ${ue_type}=${UE_TYPE}    ${ue_index}=${0}    ${throughput}=10Mbps/sec   ${duration}=3600
    ...            ${du_index}=0    ${detach_request}=True    ${power_reset}=True   ${time_length}=600s
    ...    ${apn_address}=${TLCommonConfig['MultiUECFG']['0']['apn']}
    Run Keyword And Continue On Failure    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    ...    is_need_to_kill_vysor=${true}    detach_request=${detach_request}    power_reset=${power_reset}
    power_ue.UE Detach    ue_type=${ue_type}     ue_index=${ue_index}   power_reset=${power_reset}
    sleep    10s
    power_ue.UE Attach    ue_type=${ue_type}     ue_index=${ue_index}   power_reset=${power_reset}
    sleep    5s
    Run Keyword And Continue On Failure     power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=dl
    ...    throughput=${throughput}    duration=${duration}   apn_address=${apn_address}
    Run Keyword And Continue On Failure    power_ue.Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=ul
    ...    throughput=${throughput}    duration=${duration}    iperf_type=via_command   apn_address=${apn_address}
    sleep    ${time_length}
    Run Keyword And Ignore Error     KW.Check Tput   cells=${cells}  target_throughput=${throughput}

KW.UE attach with ULDL traffic Huawei
    [Arguments]    ${UECFG}=NULL
    MultiUE.PrepareUE    UECFG=${UECFG}
    MultiUE.Detach       UECFG=${UECFG}
    Run Keyword And Continue On Failure    Huawei_UE.AttachAndStartDLULTrafficAndCheck_tput    UECFG=${UECFG}
    ...    ue_index=${UECFG['ue_index_for_call'][0]}   default_ue_index=${UECFG['ue_index_for_call'][0]}

Huawei_UE.AttachAndStartDLULTrafficAndCheck_tput
    [Arguments]    ${UECFG}=NULL    ${ue_index}=0   ${default_ue_index}=0
    set suite variable    ${UECFG}    ${UECFG}
    set suite variable    ${MultiUEL3Call_${ue_index}_disable_call}    true
    ${res}  run keyword and ignore error   power_ue.Prepare UE
    ...    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    ue_index=${ue_index}
    ...    detach_request=${UECFG['${ue_index}']['detach_request']}
    ...    power_reset=${UECFG['${ue_index}']['power_reset']}
    Run Keyword And Ignore Error    power_ue.UE Detach
    ...    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    ue_index=${ue_index}    power_reset=${UECFG['${ue_index}']['power_reset']}
    Basic.CheckVariableValid    var=MultiUEL3Call_${ue_index}_Result           default_value=Failed
    Run Keyword And Continue On Failure    Huawei_UE.Attach     UECFG=${UECFG}    ue_index=${ue_index}   default_ue_index=${default_ue_index}
    sleep    5s
    Run Keyword And Continue On Failure   Huawei_UE.StartDLTraffic    UECFG=${UECFG}  ue_index=${ue_index}   default_ue_index=${default_ue_index}
    Run Keyword And Continue On Failure   Huawei_UE.StartULTraffic    UECFG=${UECFG}  ue_index=${ue_index}  default_ue_index=${default_ue_index}
    sleep    25s
    MultiUE._CheckOneUEThoughput    UECFG=${UECFG}  ue_index=${ue_index}    ue_index=${ue_index}
    ...    check_tput_on_ue=${UECFG['${ue_index}']['check_tput_on_ue']}

Huawei_UE.Attach
    [Arguments]    ${UECFG}=NULL    ${ue_index}=0   ${default_ue_index}=0
        ${res}  run keyword and ignore error   power_ue.UE Attach
        ...    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    ue_index=${ue_index}
        ...    power_reset=${UECFG['${ue_index}']['power_reset']}

Huawei_UE.StartDLTraffic
    [Arguments]    ${UECFG}=NULL    ${ue_index}=0   ${default_ue_index}=0   ${protocol}=udp
        ${duration}    Evaluate    ${UECFG['${ue_index}']['check_throughput_duration']}+${UEnum}*600
        ${throughput for DL}=    Run Keyword If   '${tl.ues[${ue_index}].capabilities[-1].count('spark')}'=='0'
        ...    Set Variable if    '${tl.ues[${ue_index}].capabilities[-1].count('lte')}'=='0'
        ...    ${UECFG['${ue_index}']['dl']['target_throughput']}M    ${UECFG['${ue_index}']['dl']['target_throughput']}
        ...    ELSE
        ...    Set Variable    ${UECFG['${ue_index}']['dl']['target_throughput']}Mbps/sec
        Run Keyword And Continue On Failure   power_ue.Start traffic
        ...    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    ue_index=${ue_index}    direction=dl
        ...    throughput=${throughput for DL}
        ...    duration=${duration}
        ...    apn_address=${UECFG['${ue_index}']['apn']}
        ...    ue_mode=${UECFG['${ue_index}']['ue_mode']}
        ...    iperf_port=${UECFG['${ue_index}']['iperf_port']}
        ...    multidrb_QoS_dest=${UECFG['${ue_index}']['multidrb_QoS_dest']}
        ...    iperf_type=${UECFG['${ue_index}']['iperf_type']}
        ...    protocol=${UECFG['${ue_index}']['protocol']}

Huawei_UE.StartULTraffic
    [Arguments]    ${UECFG}=NULL    ${ue_index}=0    ${default_ue_index}=0  ${protocol}=udp
        run keyword if  '${UECFG['${ue_index}']['ul']['target_throughput']}'=='0'   Continue For Loop
        ${duration}    Evaluate    ${UECFG['${ue_index}']['check_throughput_duration']}+${UEnum}*600
        ${throughput for UL}    Set Variable if  ${tl.ues[${ue_index}].capabilities[-1].count('lte')}==0
        ...   ${UECFG['${ue_index}']['ul']['target_throughput']}Mbps/sec   ${UECFG['${ue_index}']['ul']['target_throughput']}
        Run Keyword And Continue On Failure   power_ue.Start traffic
        ...    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    ue_index=${ue_index}    direction=ul
        ...    throughput=${throughput for UL}
        ...    duration=${duration}
        ...    apn_address=${UECFG['${ue_index}']['apn']}
        ...    ue_mode=${UECFG['${ue_index}']['ue_mode']}
        ...    iperf_port=${UECFG['${ue_index}']['iperf_port']}
        ...    multidrb_QoS_dest=${UECFG['${ue_index}']['multidrb_QoS_dest']}
        ...    iperf_type=${UECFG['${ue_index}']['iperf_type']}

KW.Detach UE with Stop traffic Huawei
    [Arguments]    ${UECFG}=NULL    ${ue_index}=0   ${default_ue_index}=0
    UE.One_UE_Stop_traffic_and_Detach
        ...    ue_type=${tl.ues[${ue_index}].capabilities[-1]}    ue_index=${ue_index}
        ...    apn_address=${UECFG['${ue_index}']['apn']}
        ...    ue_mode=${UECFG['${ue_index}']['ue_mode']}
        ...    iperf_port=${UECFG['${ue_index}']['iperf_port']}
        ...    power_reset=${UECFG['${ue_index}']['power_reset']}
    Sleep   2s

KW.Check Tput
    [Arguments]    ${ue_type}=${UE_TYPE}    ${cells}=@{cell1_to_check}   ${target_throughput}=5
#    ${tput_log}    Run Keyword And Continue On Failure    power_ue.Collect Tput    ue_type=${ue_type}    du_index=${du_index}    duration=100
    Run Keyword And Continue On Failure     KW.Collect Tput and check result
    Run Keyword And Continue On Failure    power_ue.Check Tput    ue_type=${ue_type}    direction=DL   log=${tput_log}
    ...    cells=${cells}    target_throughput=${target_throughput}
    Run Keyword And Continue On Failure    power_ue.Check Tput    ue_type=${ue_type}    direction=UL   log=${tput_log}
    ...    cells=${cells}    target_throughput=${target_throughput}

KW.Detach UE with Stop traffic
    [Arguments]    ${ue_type}=${UE_TYPE}    ${ue_index}=${0}    ${apn_address}=${NSA_APN}   ${ue_mode}=NSA
    Run Keyword And Continue On Failure     power_ue.Stop traffic    ue_type=${UE_TYPE}    ue_index=${ue_index}    direction=dl
    ...    apn_address=${apn_address}    ue_mode=${ue_mode}
    Run Keyword And Continue On Failure     power_ue.Stop traffic    ue_type=${UE_TYPE}    ue_index=${ue_index}    direction=ul
    ...    apn_address=${apn_address}    ue_mode=${ue_mode}
    Run Keyword And Continue On Failure     power_ue.UE Detach    ue_type=${UE_TYPE}     ue_index=${ue_index}


KW.Wireshark Analyse SPID
    [Arguments]    ${filename}
    Run Keyword And Continue On Failure    Wireshark.ReadLog    filename=${filename}    filter=x2ap
    Run Keyword And Continue On Failure    Wireshark.CheckExpression    expression=x2ap.SubscriberProfileIDforRFP == 12

KW.Wireshark Analyse handover
    [Arguments]    ${filename}
    Run Keyword And Continue On Failure    Wireshark.ReadLog    filename=${filename}    filter=x2ap
    Run Keyword And Continue On Failure    Wireshark.CheckExpression    expression=x2ap.radioNetwork == 0
    Run Keyword And Continue On Failure    Wireshark.ReadLog    filename=${filename}    filter=x2ap
    Run Keyword And Continue On Failure    Wireshark.CheckExpression    expression=x2ap.X2AP_PDU == 1

KW.Check vCU PM Counter Result
    [Arguments]   ${measurement_id}     ${dist_name}    ${counter_id}    ${expected_value}    ${gnb_index}=0    ${how_many}=1
    [Documentation]  For example: M55157C00003, measurement_id is 55157
    ...     CU Login is use cu_version=cuoam_19b, counter check will fail
    CU Login      gnb_index=${gnb_index}    cu_version=cuoam_21b
    ${res}=  cu.get_counter    measurement_id=${measurement_id}     dimension_dist_name=${dist_name}    counter_id=${counter_id}
    ${counter_values}=  set variable    ${res["values"]}
    ${num}=  get length   ${counter_values}
    ${expected_counter_values}=   set variable   ${counter_values[${num}-${how_many}:${num}]}
    ${flag}=   set variable   False
    FOR   ${counter_item}   IN   @{counter_values[${num}-${how_many}:${num}]}
          ${flag}=   set variable if  ${counter_item['value']}>=${expected_value}   True
          exit for loop if    ${counter_item['value']}>=${expected_value}
          should be equal    ${flag}  True   Check counter value failed!
    END
    [Teardown]   CU Logout


KW.Collect Tput and check result
    [Arguments]    ${gnb_index}=0     ${vdu_index}=0
    ${handle}    vDU Begin K8s Log    ${gnb_index}    ${vdu_index}
    Set test variable    ${handle}
    ${container_prefix}    vDU Get Container Name Prefix
	sleep    60s
	${tput_log}    vDU End K8s Log      handle=${handle}     pod_abbr=up     container=${container_prefix}l2rt
    ...    gnb_index=${gnb_index}    vdu_index=${vdu_index}
	Set Suite Variable    ${tput_log}

KW.Reset RU
    [Arguments]    ${rmods}
    vDU Login
    ${rmods_status_before}   vdu.get_rmods_status
    ${result}   vdu.reset_rmods   rmods_list=${rmods}
    vdu.get_reset_rmods_operation_status  operation_id=${result["operation_id"]}
    sleep   300s
    ${rmods_status_after}   vdu.get_rmods_status
    FOR   ${rmod}   IN    ${rmods_status_after}
         should be equal    ${rmod[0]["availability_status"]}    on line
    END
    vDU Logout

KW.Lock_unlock RU
    [Arguments]    ${rmods}
    vDU Login
    ${rmods_status_before}   vdu.get_rmods_status
    ${result_lock}   vdu.lock_rmods   rmod_id_list=${rmods}
#    vdu.get_operation_state_of_locking_rmods  operation_id=${result_lock["id"]}
    sleep    60S
    ${result_unlock}   vdu.unlock_rmods   rmod_id_list=${rmods}
#    vdu.get_operation_state_of_locking_rmods  operation_id=${result_unlock["id"]}
    ${rmods_status_after}   vdu.get_rmods_status
    FOR   ${rmod}   IN    ${rmods_status_after}
         should be equal    ${rmod[0]["availability_status"]}    on line
    END
    vDU Logout

KW.Check DU Alarms
    vDU Login
    vdu.vdu_get_active_alarms
    vDU Logout

KW.Check CU Alarms
    CU Login
    cu.get_active_alarms
    CU Logout
