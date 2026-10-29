*** Settings ***
Documentation
...   Author: ning.du@nokia-sbell.com
...   Contact: ning.du@nokia-sbell.com
...   Description: The file is to store resources for cases

#Resource           ../Resources/Cloud/AIC_Common_Resource.robot



*** Keywords ***
Prepare UE And Attach UE
    [Arguments]    ${ui_version}    ${ue_index}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
	Set Test Variable    ${ue_type}
    Prepare UE    ${ue_type}    ue_index=${ue_index}    ui_version=${ui_version}
    UE Attach    ${ue_type}    ue_index=${ue_index}    verify_attach=${true}

Prepare UE0 And Attach UE0
    [Arguments]    ${ui_version}=MATE40PROUI1.0
    Case_Common_Resource.Prepare UE0    ui_version=${ui_version}
    Case_Common_Resource.Attach UE0

Prepare UE0
    [Arguments]    ${ui_version}=MATE40PROUI1.0
    ${ue0_type}    translate_power_ue_type_from_testline    ue_index=${0}
	Set Test Variable    ${ue0_type}
    Prepare UE    ${ue0_type}    ue_index=${0}    ui_version=${ui_version}

Attach UE0
    UE Attach    ${ue0_type}    ue_index=${0}    verify_attach=${true}

Detach UE0
    UE Detach    ${ue0_type}    ue_index=${0}

Start DL Call For UE0
    [Arguments]    ${Tput}=200M    ${duration}=${6000}
    Log To Console    \nStart the DL TPUT
    Start traffic    ue_type=${ue0_type}    ue_index=${0}    direction=dl    dt_index=${0}
	...              throughput=${Tput}    duration=${duration}

Start UL Call For UE0
    [Arguments]    ${Tput}=100M    ${duration}=${6000}
    Log To Console    \nStart the UL TPUT
    Start traffic    ue_type=${ue0_type}    ue_index=${0}    direction=ul    dt_index=${0}
	...              throughput=${Tput}    duration=${duration}

Stop DL Call for UE0
    Log To Console    \nStop the DL TPUT
    Stop traffic    ${ue0_type}    ue_index=${0}    direction=dl

Stop UL Call for UE0
    Log To Console    \nStop the UL TPUT
    Stop traffic    ${ue0_type}    ue_index=${0}    direction=ul

Start Voice Call For UE0
    Start VONR Call    ue_type=${ue0_type}    ue_index=${0}    vc_alias=VC_1    call_number=006688
    ...            duration=600s    capabilities=huawei1

Stop VONR Call For UE0
    Stop VONR Call    ue_type=${ue0_type}    vc_alias=VC_1

Download K8s Log from vDU
    [Arguments]    ${duration}=${3600}
    ${pod_name}=    set variable    l2rt
    ${local_file_path}    Collect And Download K8s Log In vDU    gnb_index=${0}    vdu_index=${0}    container_name=l2rt
    ...                                    pod_name=${pod_name}   timeout=${10}    duration=${duration}
    Set Test Variable    ${local_file_path}

Get DL Tput By K8s Log
    [Arguments]    ${duration}=${3600}
    Download K8s Log from vDU    duration=${duration}
    ${ave_dl_tput}    ${max_dl_tput}    ${min_dl_tput}    k8s.get_dl_tput_from_k8s_log    ${local_file_path}
    Log To Console    \nAve DL TPUT is: ${ave_dl_tput}
    Log To Console    Max DL TPUT is: ${max_dl_tput}
    Log To Console    Min DL TPUT is: ${min_dl_tput}
    Set Test Variable    ${ave_dl_tput}

Get UL Tput By K8s Log
    [Arguments]    ${duration}=${3600}
    Download K8s Log from vDU    duration=${duration}
    ${ave_ul_tput}    ${max_ul_tput}    ${min_ul_tput}    k8s.get_ul_tput_from_k8s_log    ${local_file_path}
    Log To Console    \nAve UL TPUT is: ${ave_ul_tput}
    Log To Console    Max UL TPUT is: ${max_ul_tput}
    Log To Console    Min UL TPUT is: ${min_ul_tput}
    Set Test Variable    ${ave_ul_tput}

Get DL and UL Tput By K8s Log
    [Arguments]    ${duration}=${3600}
    Download K8s Log from vDU    duration=${duration}
    ${ave_ul_tput}    ${max_ul_tput}    ${min_ul_tput}    k8s.get_ul_tput_from_k8s_log    ${local_file_path}
    Log To Console    \nAve UL TPUT is: ${ave_ul_tput}
    Log To Console    Max UL TPUT is: ${max_ul_tput}
    Log To Console    Min UL TPUT is: ${min_ul_tput}
    Set Test Variable    ${ave_ul_tput}
    ${ave_dl_tput}    ${max_dl_tput}    ${min_dl_tput}    k8s.get_dl_tput_from_k8s_log    ${local_file_path}
    Log To Console    \nAve DL TPUT is: ${ave_dl_tput}
    Log To Console    Max DL TPUT is: ${max_dl_tput}
    Log To Console    Min DL TPUT is: ${min_dl_tput}
    Set Test Variable    ${ave_dl_tput}

Check DL Tput By K8s Log
    [Arguments]    ${required_ave_dl_tput}=5M
    ${required}    Get Tput from string  ${required_ave_dl_tput}
    should be true  ${ave_dl_tput}>=${required}

Check UL Tput By K8s Log
    [Arguments]    ${required_ave_ul_tput}=5M
    ${required}    Get Tput from string  ${required_ave_ul_tput}
    should be true  ${ave_ul_tput}>=${required}

Show Tput report
    ${ul}    Get Tput from string  ${ul_tput}
    ${dl}    Get Tput from string  ${dl_tput}
    ${ul_rate}  Evaluate  ${ave_ul_tput} / ${ul} *100
    ${dl_rate}  Evaluate  ${ave_dl_tput} / ${dl} *100
    ${ul_rounded}  convert to number  ${ul_rate}  2
    ${dl_rounded}  convert to number  ${dl_rate}  2
    Log To Console    \n iperf UL TPUT is: ${ul} \nAve UL TPUT is: ${ave_ul_tput} \nUL TPUT Rate is: ${${ul_rounded}}\%
    Log To Console    \n iperf DL TPUT is: ${dl} \nAve DL TPUT is: ${ave_dl_tput} \nDL TPUT Rate is: ${${dl_rounded}}\%

Get Tput from string
    [Arguments]    ${str}
    ${lst}    Get Regexp Matches    ${str}    (\\d+)\\w+   1
    ${tput}    Convert To Integer  @{lst}[0]
    [Return]    ${tput}

Get TestLine Name
    ${lst}    Get Regexp Matches    ${CONFIGURATION}    \.(\\d{1,3}_\\d{1,3}_UTE\\w+)   1
    [Return]    @{lst}[0]

Get Branch Name
    ${lst}    Get Regexp Matches    ${ENB_BUILD}    vDUCNF[A-Za-z0-9]*_(\\d+\.\\d+)\.\\d+   1
    [Return]    @{lst}[0]

Prepare PA
    run keyword    ${TL_NAME}.Prepare PA

7_5_UTE5GAIC015T005.Prepare PA
    ${attenuation_channels}     Get Attenuation port    RU_id=0    du_id=0
    ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=HBTE    du_id=0
    &{channels_to_modify}    create dictionary   ${attenuation_channels[8]}=15    ${attenuation_channels[9]}=15
    Modify Attenuation Value    ${channels_to_modify}    RU_id=0    du_id=0
    sleep    10s
    Log to console    PA Attenuation Changed.

7_5_UTE5GAIC015T008.Prepare PA
    ${attenuation_channels}     Get Attenuation port    RU_id=0    du_id=0
    ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=HBTE    du_id=0
    &{channels_to_modify}    create dictionary   ${attenuation_channels[3]}=5    ${attenuation_channels[7]}=5
    Modify Attenuation Value    ${channels_to_modify}    RU_id=0    du_id=0
    sleep    10s
    Log to console    PA Attenuation Changed.

Common Suite Setup For AIC For Any Testline
    ${TL_NAME}=    Case_Common_Resource.Get TestLine Name
    ${BRANCH_NAME}=    Get Branch Name
    Set Suite Variable    ${TL_NAME}
    Set Suite Variable    ${BRANCH_NAME}
    Set Suite Variable    ${DEFAULT_SCF_PATH}    ${CURDIR}/../../../../../commissionings/RRM/SRAN_5G/${TL_NAME}
    ${cell_status}=     Run Keyword And Ignore Error    Check All Cells On Air In vCU
    Run Keyword If     '${cell_status}[0]'=='FAIL'    Load Default SCF
    Common Suite Setup For AIC

vDU Load And Active SCF
    [Arguments]     ${path_of_commission_file}    ${vdu_index}=0
    [Documentation]   load scf, fix error and active SCF
    vDU Login By Rest    ${vdu_index}
    log to console   \n*** Start plan upload operation ***
    ${upload_plan_response}=  vdu.upload_plan    ${path_of_commission_file}
    wait until keyword succeeds  10s  1s
    ...    _Check Upload Plan Status Should Be Expected  ${upload_plan_response['action_id']}
    log to console   \n*** Start plan fix error ***
    ${fix_err_response}=   vdu.fix_vdu_staged_plan_error    ${upload_plan_response['plan_id']}
    wait until keyword succeeds  30s  10s  Fix vDU SCF Validation Errors Should Be Successful
    ...    ${upload_plan_response['plan_id']}  ${fix_err_response['action_id']}
    log to console   \n*** Start plan validate operation ***
    ${validate_plan_response}=  vdu.validate_plan   ${upload_plan_response['plan_id']}
    wait until keyword succeeds  10s  1s  _Check Validate Plan Status Should Be Expected
    ...  ${upload_plan_response['plan_id']}
    ...  ${validate_plan_response['action_id']}
    log to console   \n*** Start plan activate operation ***
    ${activate_plan_response}=  vdu.activate_plan  ${upload_plan_response['plan_id']}
     wait until keyword succeeds    10min    20s    _Check Activate Plan Status Should Be Expected
    ...    ${upload_plan_response['plan_id']}
    ...    ${activate_plan_response['id']}
    [Teardown]    vDU Logout By Rest

Fix vDU SCF Validation Errors Should Be Successful
    [Arguments]  ${plan_id}  ${action_id}
    ${fix_err_response}=   vdu.get_fix_vdu_staged_plan_operation_status  ${plan_id}  ${action_id}
    should be equal as strings  ${fix_err_response['status']}  success
    log to console    Fix SCF Errors Success

vCU Load And Active SCF
    [Arguments]    ${path_of_commission_file}   ${plan_name}=TA_delta_plan  ${gnb_index}=0
    [Documentation]   load scf, fix error and active SCF
    Log To Console    ${gnb_index}
    Login To vCU By Rest
    log to console   \n*** Start plan upload operation ***
    ${upload_operation_info}=   cu.upload_plan_file     ${path_of_commission_file}   plan_name=${plan_name}
    log to console   \n*** Wait plan upload operation success ***
    wait until keyword succeeds    60s   5s  CU Check Plan Upload Status Should Be As Expected
    ...    ${upload_operation_info["action_id"]}    success
     log to console   \n*** Start plan fix error ***
    ${fix_err_operation}=   cu.fix_plan_validation_errors    ${upload_operation_info['plan_id']}
    ...   add_missing_objects=${True}   fix_mandatory_parameters=${True}
    wait until keyword succeeds  30s  10s  Fix VCU SCF Validation Errors Should Be Successful
    ...    ${upload_operation_info['plan_id']}  ${fix_err_operation['action_id']}
    log to console   \n*** Start plan validate operation ***
    ${validate_operaition_info}=  cu.plan_validation    ${upload_operation_info["plan_id"]}
    log to console   \n*** Wait plan validate operation success ***
    wait until keyword succeeds    180s   10s  CU Check Plan Validate Status Should Be As Expected
    ...    ${upload_operation_info["plan_id"]}   ${validate_operaition_info["action_id"]}    success
    log to console   \n*** Start plan activate operation ***
    ${activate_operaition_info}=  cu.plan_activation   ${upload_operation_info["plan_id"]}
    log to console   \n*** Wait plan activate operation success in 10 mins ***
    wait until keyword succeeds    600s   30s  CU Check Plan Activate Status Should Be As Expected
    ...    ${upload_operation_info["plan_id"]}  ${activate_operaition_info["id"]}    success
    [Teardown]    run keyword and ignore error    Logout To vCU By Rest

Fix VCU SCF Validation Errors Should Be Successful
    [Arguments]  ${plan_id}  ${action_id}
    ${fix_err_response}=   cu.get_action_state_of_fix_plan  ${plan_id}  ${action_id}
    should be equal as strings  ${fix_err_response['status']}  success
    log to console    Fix SCF Errors Success

Load Default SCF
    [Arguments]  ${default_vcu_scf_path}=${DEFAULT_SCF_PATH}/vCU_SCF_${BRANCH_NAME}.xml
    ...          ${default_vdu_scf_path}=${DEFAULT_SCF_PATH}/vDU_SCF_${BRANCH_NAME}.xml
    vCU Load And Active SCF    ${default_vcu_scf_path}
    vDU Load And Active SCF    ${default_vdu_scf_path}
    wait until keyword succeeds   60min  30s   Check All Cells On Air In vCU

Start L1 Bip Log
    [Arguments]    ${gnb_index}=${0}    ${vdu_index}=${0}
    ...            ${pod_prefix}=po-cran1    ${container_prefix}=ctr-cran1
    ...            ${timeout}=${10}
    ${is_rannic}    Check if vDU Use Rannic
    ${container_to_capture_L1_bip}=   Run Keyword If    '${is_rannic}'=='True'
    ...               set variable    l2rt
    ...       ELSE    set variable    l1hi
    ${port_name}=   Run Keyword If    '${is_rannic}'=='True'
    ...               set variable    l1up
    ...       ELSE    set variable    l1bipl1
    ${pod_to_capture_L1_bip}=    set variable    l2rt
    Set Test Variable    ${is_rannic}
    Set Test Variable    ${pod_to_capture_L1_bip}
    Set Test Variable    ${container_to_capture_L1_bip}
    Start Bip Log    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ...              container_name=${container_to_capture_L1_bip}
    ...              pod_name=${pod_to_capture_L1_bip}    pod_prefix=${pod_prefix}
    ...              container_prefix=${container_prefix}    port_name=${port_name}
    ...              timeout=${timeout}

Stop L1 Bip Log And Download To K8s Master
    [Arguments]    ${gnb_index}=${0}    ${vdu_index}=${0}
    ...            ${pod_prefix}=po-cran1    ${container_prefix}=ctr-cran1    ${timeout}=${10}
    ${l1_bip_local_file_path}=    Stop Bip Log And Download To K8s Master
    ...    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    ...    container_name=${container_to_capture_L1_bip}    pod_name=${pod_to_capture_L1_bip}
    ...    pod_prefix=${pod_prefix}    container_prefix=${container_prefix}
    ...    timeout=${timeout}
    [Return]   ${l1_bip_local_file_path}

Custom Suite Teardown For AIC
    Common Suite Teardown For AIC
    ${cmd}=    Set Variable    find ${SUITE_LOG_DIRECTORY} -type f -size +50M ! -name "*.xml" ! -name "*.html"
    ${result}    Run Process    ${cmd}    shell=True
    log to console    ${result.stdout}

    ${cmd_new}=    Set Variable    ${cmd} -exec rm -f {} \\;
    ${result}    Run Process    ${cmd_new}    shell=True
    log to console    ${result.stdout}
    log to console    ${result.stderr}
    log to console    ${result.rc}
