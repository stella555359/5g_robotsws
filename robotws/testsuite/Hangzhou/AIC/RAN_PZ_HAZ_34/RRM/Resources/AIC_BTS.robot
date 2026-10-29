*** Settings ***
Documentation
...    Author: nana.zhao
...    Contact: nana.zhao@nokia-sbell.com
...    Common KWs related to some operation of AIC NE.
...    Please do not modify the file without notification to author

Library           taf.transport.ssh                     WITH NAME    csn
Library           taf.gnb.oam.coam.cu.interface.cu      WITH NAME    cu
Library           taf.analyzer.pcap                    WITH NAME    cap
Library           taf.config.testline.info.testline_info.TestlineInfo    WITH NAME    testline_info
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/enb_lte.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/cloud/cloud_state.robot

*** Variables ***
${PAGE_NUMBER}    2

*** Keywords ***
#---------------------vDU--------------------------------------------------------------------------


#---------------------vCU--------------------------------------------------------------------------
Preconditions
    [Documentation]   this kw is used for precondition
    ${START_TIME}=    Get time    exclude_millis=yes
    Set Suite Variable    ${START_TIME}

_Check Activating Delta Plan Operation Should Be Successful
    [Arguments]    ${plan_id}    ${operation_id}
    [Documentation]   this kw is used to Check Activating Delta Plan Operation Should Be Successful
    ${res}=    cu.get_operation_state_of_activating_delta_plan    ${plan_id}    ${operation_id}
    should be equal as strings    ${res['status']}    success

_Check Validating Delta Plan Operation Should Be Successful
    [Arguments]    ${plan_id}    ${action_id}
    [Documentation]   this kw is used to Check Validating Delta Plan Operation Should Be Successful
    ${res}=    cu.get_action_state_of_validating_delta_plan   ${plan_id}  ${action_id}
    should be equal as strings  ${res['status']}  success

Validate and Activate Delata Plan For vCU
    [Arguments]    ${delta_plan_id}
    [Documentation]   Online Modify Single Mo Parameters Via Rest In vCU.
    ${validate_res}=    cu.validate_delta_plan    plan_id=${delta_plan_id}
    run keyword and continue on failure    Wait until keyword succeeds    9x    5s
    ...  _Check Validating Delta Plan Operation Should Be Successful    plan_id=${delta_plan_id}
    ...                                                              action_id=${validate_res['action_id']}
    ${active_res}=    cu.activate_delta_plan    plan_id=${delta_plan_id}
    run keyword and continue on failure    Wait until keyword succeeds    9x    30s
    ...  _Check Activating Delta Plan Operation Should Be Successful    plan_id=${delta_plan_id}
    ...                                                                operation_id=${active_res['operation_id']}

_Check Update Parameters Operation Should Be Successful
    [Arguments]    ${plan_id}    ${action_id}
    [Documentation]    this kw is used to Check Update Parameters Operation Should Be Successful
    ${res}=  cu.get_action_state_of_updating_parameters_of_delta_plan  plan_id=${plan_id}  action_id=${action_id}
    should be equal as strings  ${res['status']}  success

_Get Specifical MO UUID via Dn Name In vCU
    [Arguments]   ${plan_id}  ${name}
    [Documentation]  this kw is used to get Specifical MO UUID via Dn Name In vCU
    &{delta_plan_tree}    cu.get_delta_plan_tree_diff    plan_id=${plan_id}
    @{plan_tree}=    set variable    ${delta_plan_tree["created"]}
    FOR    ${mo_info}    IN    @{plan_tree}
       run keyword if    '${mo_info["parent_mo_uuid"]}'=='${parent_mouuid}' and '${mo_info["name"]}'=='${name}'
       ...   run keywords    set test variable    ${parent_mouuid}    ${mo_info["mo_uuid"]}    AND    exit for loop
    END
    [Return]    ${parent_mouuid}

_Get Specifical MO UUID In vCU
    [Arguments]    ${plan_id}    ${mo_dn}
    [Documentation]   _Get Specifical MO UUID In vCU
    @{name_list}=    split_string    ${mo_dn}    /
    set test variable    ${parent_mouuid}    ${EMPTY}
    FOR    ${name}    IN    @{name_list}
        ${mouuid}    _Get Specifical MO UUID via Dn Name In vCU    ${plan_id}    ${name}
    END
    [Return]    ${mouuid}

Online Update Single Mo Parameters Via Rest In vCU
    [Arguments]    ${para_list}    ${mo_dn}    ${delta_plan_id}
    [Documentation]   Online Modify Single Mo Parameters Via Rest In vCU.
    ${uuid}   _Get Specifical MO UUID In vCU    plan_id=${delta_plan_id}    mo_dn=${mo_dn}
    ${update_res}=  cu.update_parameters_of_delta_plan    plan_id=${delta_plan_id}    mo_uuid=${uuid}
    ...   parameter_change_list=${para_list}
    run keyword and continue on failure    Wait until keyword succeeds    9x    5s
    ...  _Check Update Parameters Operation Should Be Successful    plan_id=${delta_plan_id}
    ...                                                            action_id=${update_res['action_id']}

vCU Online modify Simple Parameters Via Rest With Compare
    [Arguments]    ${parameter_name}    ${updated_paras_dict}    ${compare_value}=true
    ...            ${mo_dn}=MRBTS-5460/NRBTS-5460    ${gnb_index}=${0}
    [Documentation]    vCU Online modify Simple Parameters Via Rest With Compare.
    ${para_value}=    Get Parameters Of Current Plan Via Rest    parameter_name=${parameter_name}    gnb_index=${gnb_index}
    ...                                        mo_dn=${mo_dn}
    Run Keyword If    "${para_value}"!="${compare_value}"    Online Modify Single Mo Parameters Via Rest In vCU
    ...                                                            para_list=${updated_paras_dict}
    ...                                                            mo_dn=${mo_dn}

Online Modify Single Mo Parameters Via Rest In vCU
    [Arguments]    ${para_list}    ${mo_dn}    ${delta_plan_name}=delta_plan
    [Documentation]   Online Modify Single Mo Parameters Via Rest In vCU.
    ${delta_plan_id}=    Online Generate Delta Plan Via Rest In vCU    delta_plan_name=${delta_plan_name}
    Online Update Single Mo Parameters Via Rest In vCU    para_list=${para_list}    mo_dn=${mo_dn}
    ...                                                   delta_plan_id=${delta_plan_id}
    Validate and Activate Delata Plan For vCU    delta_plan_id=${delta_plan_id}
	
Online Generate Delta Plan Via Rest In vCU
    [Arguments]    ${delta_plan_name}=delta_plan
    [Documentation]   Online Modify Single Mo Parameters Via Rest In vCU.
    ${delta_plan_list}    cu.get_delta_plan_list
    Run Keyword If    ${delta_plan_list}    cu.delete_delta_plan    ${delta_plan_list[0]['plan_id']}
    ${delta_res}=    cu.generate_delta_plan    plan_name=${delta_plan_name}
    ${delta_plan_id}=    set variable    ${delta_res['plan_id']}
    Set Test Variable    ${delta_plan_id}
    run keyword and continue on failure    Wait until keyword succeeds    6x    2s
    ...  _Check Delta Plan Operation Should Be Successful    ${delta_res['action_id']}
    [Return]    ${delta_plan_id}	

_Check Delta Plan Operation Should Be Successful
    [Arguments]    ${action_id}
    [Documentation]    Check Validating Delta Plan Operation Should Be Successful
    ${res}    cu.get_action_state_of_generating_delta_plan    ${action_id}
    should be equal as strings    ${res['status']}    success

Lock NG Link
    [Arguments]    ${ng_links_list}
    #${ng_links_list}    Create List    1    2
    Lock NG Links In vCU     ng_links_list=${ng_links_list}    gnb_index=${gnb_index}
    ...                      parameter_name=administrativeState
    ...                      mo_dn=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/SERVEDAMF-1
    ...                      expected_value=Locked

Lock NG Links In vCU
    [Arguments]    ${ng_links_list}    ${gnb_index}=0    ${parameter_name}=administrativeState
    ...            ${mo_dn}=MRBTS-${MRBTS_ID}    ${expected_value}=Locked
    #AIC_BTS.CU Rest Login    gnb_index=${gnb_index}
    cloud_cu.CU Login     gnb_index=${gnb_index}    cu_version=cuoam_21b
    cu.lock_ng_links    ng_links_ids=${ng_links_list}    connection=${None}
    wait until keyword succeeds  120s  5s    Check NG link Operation Should Be Successful    parameter_name=${parameter_name}
    ...                         gnb_index=${gnb_index}    mo_dn=${mo_dn}    expected_value=${expected_value}    page_number=${2}
    [Teardown]    Run keyword and ignore error    cloud_cu.CU Logout

UnLock NG Links In vCU
    [Arguments]    ${ng_links_list}    ${gnb_index}=0    ${parameter_name}=administrativeState
    ...            ${mo_dn}=MRBTS-${MRBTS_ID}    ${expected_value}=Unlocked
    #AIC_BTS.CU Rest Login    gnb_index=${gnb_index}
    cloud_cu.CU Login     gnb_index=${gnb_index}    cu_version=cuoam_21b
    cu.unlock_ng_links    ng_links_ids=${ng_links_list}    connection=${None}
	sleep    10s
    FOR    ${page_number}    IN RANGE    ${PAGE_NUMBER} 
        ${status}    run keyword and return status
		...    Check NG link Operation Should Be Successful    parameter_name=${parameter_name}
                ...                         gnb_index=${gnb_index}    mo_dn=${mo_dn}
				...                         expected_value=${expected_value}    page_number=${page_number+1}
		exit for loop if    '${status}'=='True'
    END
    [Teardown]    Run keyword and ignore error    cloud_cu.CU Logout

UnLock NG Link
    [Arguments]    ${ng_links_list}
    #${ng_links_list}    Create List    1    2
    UnLock NG Links In vCU     ng_links_list=${ng_links_list}    gnb_index=${gnb_index}
    ...                      parameter_name=administrativeState
    ...                      mo_dn=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/SERVEDAMF-1
    ...                      expected_value=Unlocked

Check NG link Operation Should Be Successful
   [Arguments]    ${parameter_name}=administrativeState    ${gnb_index}=0    ${mo_dn}=MRBTS-${MRBTS_ID}
   ...            ${expected_value}=Locked    ${page_number}=${2}
   [Documentation]   this kw is used to vCU Online Get Parameters Of Current Plan Via Rest
    ...    Author: zhao nana
    ...    Contact: nana.zhao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | parameter_name | yes | define parameter name |
    ...
    ...    | Return Value | Description |
    ...    | ${para_result} | return parameter result |
    ...
    ...    Example
    ...    | Check NG link Operation Should Be Successful | parameter_name=actIntraFreqHoSA |
    ...
    ${para_value}    Get Parameters Of Current Plan Via Rest    parameter_name=${parameter_name}
    ...              gnb_index=${gnb_index}    mo_dn=${mo_dn}    page_number=${page_number}
    Should Be True    "${para_value}" == "${expected_value}"


Get Parameters Of Current Plan Via Rest
   [Arguments]    ${parameter_name}=administrativeState    ${gnb_index}=0    ${mo_dn}=MRBTS-${MRBTS_ID}    ${page_number}=${1}
   [Documentation]    this kw is used to vCU Online Get Parameters Of Current Plan Via Rest
    ...    Author: zhao nana
    ...    Contact: nana.zhao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | parameter_name | yes | define parameter name |
    ...
    ...    | Return Value | Description |
    ...    | ${para_result} | return parameter result |
    ...
    ...    Example
    ...    | vCU Online Get Parameters Of Current Plan Via Rest | parameter_name=actIntraFreqHoSA |
    ${para_result}    vCU Online Get Parameters Of Current Plan Via Rest    parameter_name=${parameter_name}    page_number=${page_number}
    ${result_length}    get length    ${para_result['items']}
    ${result_fault_length}    Evaluate    ${result_length} - ${1}
    FOR    ${index}    IN RANGE    ${result_length}
        ${distname}    set variable    ${para_result['items'][${index}]['distname']}
        ${para}    set variable    ${para_result['items'][${index}]['parameter_name']}
        Run Keyword If    "${distname}" == "${mo_dn}" and "${para}" == "${parameter_name}"
        ...                Set Test Variable    ${index}    ${index}
        exit for loop if    "${distname}" == "${mo_dn}" and "${para}" == "${parameter_name}"
        Run Keyword If    ${index}==${result_fault_length}    fail    get parameter is failed
    END
    ${para_value}    set variable    ${para_result['items'][${index}]['parameter']['simple_parameter']['value']}
    Set Test variable    ${para_value}
    [Return]    ${para_value}

vCU Online Get Parameters Of Current Plan Via Rest
   [Arguments]    ${parameter_name}    ${page_number}=${1}
   [Documentation]    this kw is used to vCU Online Get Parameters Of Current Plan Via Rest
    ...    Author: zhao nana
    ...    Contact: nana.zhao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | parameter_name | yes | define parameter name |
    ...
    ...    | Return Value | Description |
    ...    | ${para_result} | return parameter result |
    ...
    ...    Example
    ...    | vCU Online Get Parameters Of Current Plan Via Rest | parameter_name=actIntraFreqHoSA |
    ${para_result}=    cu.search_parameters_of_current_plan    parameter_name=${parameter_name}     page_number=${page_number}
    [Return]    ${para_result}

Get DU runtime Status from runtime SCF
    [Arguments]    ${mo_dn}=MRBTS-${MRBTS_ID}
    [Documentation]   Get administrativeState/operationalState/proceduralStatus from runtime SCF
    ...    *AUTHOR* gang.ni@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    |         |  |   |
    ...   *RETURN VALUE*
    ...    administrativeState, operationalState, proceduralStatus
    ...   Example
    ...   | Get RU runtime Status from runtime SCF |  |

    cloud_vdu.vDU Login

    ${timestamp}    Get Timestamp
    ${scf_path}     Get A Directory    scf_${timestamp}

    ${scf_file_with_fullpath}    vdu.Get_Current_Plan_File    local_dir_path=${scf_path}
    ...                                                       filename=scf_${timestamp}.xml
    ...                                                       include_runtime_data=${True}

    scf.Load_Scf    file_path=${scf_file_with_fullpath}

    ${administrativeState}    scf.Get_Value_From_Scf    dist_name=${mo_dn}
    ...                                                 p_name=administrativeState
    Log To Console     ${administrativeState}
    ${operationalState}       scf.Get_Value_From_Scf    dist_name=${mo_dn}
    ...                                                 p_name=operationalState
    Log To Console     ${operationalState}
    

    cloud_vdu.vDU Logout

    [Return]    ${operationalState}


Lock X2 Link
    [Arguments]    ${x2_links_list}
    #${x2_links_list}    Create List    0
    set test variable    ${x2_links_list}
    Lock x2 Links In vCU     x2_links_list=${x2_links_list}    gnb_index=${gnb_index}
    ...                      parameter_name=x2LinkLock
    ...                      expected_value=locked

Lock x2 Links In vCU
    [Arguments]    ${x2_links_list}    ${gnb_index}=0    ${parameter_name}=x2LinkLock
    ...            ${expected_value}=locked
    #AIC_BTS.CU Rest Login    gnb_index=${gnb_index}
    cloud_cu.CU Login     gnb_index=${gnb_index}    cu_version=cuoam_21b
    cu.lock_x2_links    link_ids=${x2_links_list}    connection=${None}
    wait until keyword succeeds  120s  5s    Check X2 link Operation Should Be Successful    expected_value=${expected_value}
    [Teardown]    Run keyword and ignore error    cloud_cu.CU Logout	


Unlock X2 link
    [Arguments]    ${x2_links_list}
    #${x2_links_list}   create list   0
    set test variable    ${x2_links_list}
    #AIC_BTS.CU Rest Login    gnb_index=${gnb_index}
    cloud_cu.CU Login     gnb_index=${gnb_index}    cu_version=cuoam_21b
    UnLock x2 Links In vCU     x2_links_list=${x2_links_list}    gnb_index=${gnb_index}
    ...                      parameter_name=x2LinkLock
    ...                      expected_value=unlocked

UnLock x2 Links In vCU
    [Arguments]    ${x2_links_list}    ${gnb_index}=0    ${parameter_name}=x2LinkLock
    ...            ${expected_value}=unlocked
    #AIC_BTS.CU Rest Login    gnb_index=${gnb_index}
	cloud_cu.CU Login     gnb_index=${gnb_index}    cu_version=cuoam_21b
    cu.unlock_x2_links    link_ids=${x2_links_list}    connection=${None}
    wait until keyword succeeds  120s  5s    Check X2 link Operation Should Be Successful    expected_value=${expected_value}
    [Teardown]    Run keyword and ignore error    cloud_cu.CU Logout

Check X2 link Operation Should Be Successful
   [Arguments]    ${expected_value}=locked
   [Documentation]   this kw is used to vCU Online Get Parameters Of Current Plan Via Rest
    ...    Author: zhao nana
    ...    Contact: nana.zhao@nokia-sbell.com
    ...    | Input Parameters | Man. | Description |
    ...    | parameter_name | yes | define parameter name |
    ...
    ...    | Return Value | Description |
    ...    | ${para_result} | return parameter result |
    ...
    ...    Example
    ...    | Check x2 link Operation Should Be Successful | parameter_name=actIntraFreqHoSA |
    ...
    ${output}    cu.get_x2_links_info    connection=${None}
    should be equal      ${output['created'][0]['x2_link_lock']}    ${expected_value}

Check Parameters equal to expect
    [Arguments]    ${gnb_index}=0    ${mo_dn}=MRBTS-${MRBTS_ID}    ${expect_value}=enabled
	cloud_cu.CU Login     gnb_index=${gnb_index}    cu_version=cuoam_21b
	FOR    ${page_number}    IN RANGE    ${PAGE_NUMBER}
        ${para_value}    Get Parameters Of Current Plan Via Rest
        ...    parameter_name=operationalState    gnb_index=${gnb_index}    mo_dn=${mo_dn}    page_number=${page_number+1}
		should be true    "${para_value}" == "${expect_value}"
        exit for loop if    "${para_value}" == "${expect_value}"
	END
	Run keyword and ignore error    cloud_cu.CU Logout

step1: Prepare UE
    [Documentation]    Author: zhao nana
    ...                This keyword is prepare UE
    [Arguments]    ${ue_index}=${0}    ${ue_type}=samsung_vran20    ${ui_version}=S21UI3.1
    log to console      step1: Prepare UE
    
    power_ue.Prepare UE    ue_index=${ue_index}    ue_type=${ue_type}    ui_version=${ui_version}

Step2: UE Attach
    [Documentation]    Author: zhao nana
    ...                This keyword is attach UE
    [Arguments]    ${ue_index}=${0}    ${ue_type}=samsung_vran20    ${attach_mode}=${attach_mode}     
    log to console      Step2: UE Attach
    ${5Grach_ed_0}    power_ue.UE Attach    ue_index=${ue_index}    ue_type=${ue_type}    log_type=Aasyslog    attach_mode=${attach_mode}
    #power_ue.Verify attach    ue_type=${ue_type}   5Grach_ed=${5Grach_ed_0}    4G_check=False
    
Step3: Start traffic
    [Documentation]    Author: zhao nana
    ...                This keyword is start traffic
    [Arguments]   ${ul_throughput}=100M    ${dl_throughput}=50M    ${protocol}=udp    ${ue_index}=${0}    ${ue_type}=samsung_vran20
    ...           ${duration}=120
    log to console      Step3: Start traffic
    power_ue.Start traffic    ue_index=${ue_index}    direction=ul    throughput=${ul_throughput}    duration=120    ue_type=${ue_type}
    ...    iperf_type=via_command
    ...    protocol=${protocol}
    sleep    1s          
    power_ue.Start traffic    ue_index=${ue_index}    direction=dl    throughput=${dl_throughput}    duration=120    ue_type=${ue_type}
    ...    protocol=${protocol}    buffer_size=1400B    process_num=${3}    seg_size=1350    window=16M
    sleep    2s

Step4: Check throughput
    [Documentation]    Author: zhao nana
    ...                This keyword is check troughput
    [Arguments]    ${ultarget_throughput}   ${dltarget_throughput}    ${ue_type}    ${cells}
    log to console      Step4: Check throughput
    
    ${handle}    vDU Begin K8s Log    ${gnb_index}    ${vdu_index}
    Set test variable    ${handle}
    ${container_prefix}    vDU Get Container Name Prefix
    sleep    80s
    ${log}    vDU End K8s Log      handle=${handle}     pod_abbr=up     container=${container_prefix}l2rt
    ...    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    Set Suite Variable    ${log}
    
    ${all_tp}    Run keyword and continue on failure    power_ue.Check Bi Tput
    ...    ue_type=${ue_type}    log=${log}     cells=${cells}
    ...    ultarget_throughput=${ultarget_throughput}    dltarget_throughput=${dltarget_throughput}
    ...    target_avg_percent=0.95
    Set Test Variable    ${all_tp}    ${all_tp}
    Run keyword and continue on failure    should be true    ${all_tp[1][0]['average']}>=${exp_dl}
    Run keyword and continue on failure    should be true    ${all_tp[0][0]['average']}>=${exp_ul}

Step5: Stop traffic
    [Documentation]    Author: zhao nana
    ...                This keyword is Stop traffic
    [Arguments]    ${ue_index}=${0}    ${ue_type}=samsung_vran20
    log to console      Step5: Stop traffic
    power_ue.Stop traffic    direction=ul    ue_index=${ue_index}    ue_type=${ue_type}    iperf_type=via_command    
    power_ue.Stop traffic    direction=dl    ue_index=${ue_index}    ue_type=${ue_type}

Step6: UE Detach
    [Documentation]    Author: zhao nana
    ...                This keyword is UE Detach
    [Arguments]    ${ue_type}    ${ue_index}=${0}    
    log to console    Step6: UE Detach
    power_ue.UE Detach    ue_index=${ue_index}    ue_type=${ue_type}

Step4: Check ul or dl throughput
    [Documentation]    Author: zhao nana
    ...                This keyword is check troughput
    [Arguments]    ${direction}    ${target_throughput}    ${ue_type}    ${cells}=0    
    log to console      Step4: Check throughput
    
    ${handle}    vDU Begin K8s Log    ${gnb_index}    ${vdu_index}
    Set test variable    ${handle}
    ${container_prefix}    vDU Get Container Name Prefix
    sleep    80s
    ${log}    vDU End K8s Log      handle=${handle}     pod_abbr=up     container=${container_prefix}l2rt
    ...    gnb_index=${gnb_index}    vdu_index=${vdu_index}
    Set Suite Variable    ${log}
    
    ${all_tp}    Run keyword and continue on failure    power_ue.Check Tput
    ...    direction=${direction}    ue_type=${ue_type}    log=${log}     cells=${cells}
    ...    target_throughput=${target_throughput}
    ...    target_avg_percent=0.95    min_percent=0.5
    Set Test Variable    ${all_tp}    ${all_tp}
    Run keyword and continue on failure    log    ${all_tp[0]['average']}

    Run keyword and continue on failure    should be true    ${all_tp[0]['average']}>=${exp_dl}

Check call not release
    [Documentation]    Author: zhao nana
    ...                This keyword is check call release
    [Arguments]    ${list_of_cell_ids}    ${ue_index}    ${throughput}    ${ue_type}    ${target_throughput}=10
    ...            ${protocol}=udp    ${attach_mode}=5G_NSA    ${ui_version}=S21UI3.1    ${direction}=dl
    step1: Prepare UE    ue_index=${ue_index}    ue_type=${tl.ues[${ue_index}].capabilities[1]}    ui_version=${ui_version}
    Step2: UE Attach     ue_index=${ue_index}    ue_type=${tl.ues[${ue_index}].capabilities[1]}    attach_mode=${attach_mode}
    power_ue.Start traffic    ue_index=${ue_index}    direction=dl    throughput=${throughput}    duration=120    ue_type=${ue_type}
                       ...    protocol=${protocol}    buffer_size=1400B    process_num=${3}    seg_size=1350    window=16M
    Step4: Check ul or dl throughput    direction=dl    target_throughput=${target_throughput}    ue_type=${tl.ues[${ue_index}].capabilities[1]}
                                 ...    cells=${list_of_cell_ids}
    Run keyword and ignore error    Step5: Stop traffic    ue_index=${ue_index}    ue_type=${tl.ues[${ue_index}].capabilities[1]}
    Run keyword and ignore error    Step6: UE Detach    ue_index=${ue_index}    ue_type=${tl.ues[${ue_index}].capabilities[1]}

Check call release
    [Documentation]    Author: zhao nana
    ...                This keyword is check all release
    [Arguments]    ${ue_index}=${0}    ${attach_mode}=5G_SA    ${ui_version}=S21UI4.0
    step1: Prepare UE    ue_index=${ue_index}    ue_type=${tl.ues[${ue_index}].capabilities[1]}    ui_version=${ui_version}
    ${status}    Run Keyword And Return Status
    ...    Step2: UE Attach     ue_index=${ue_index}    ue_type=${tl.ues[${ue_index}].capabilities[1]}    attach_mode=${attach_mode}
    should be true    '${status}'=='${False}'

Check NSA call release
    [Documentation]    Author: zhao nana
    ...                This keyword is check NSA call not release
    [Arguments]    ${ue_index}=${1}    ${attach_mode}=5G_NSA    ${ui_version}=S21UI3.1
    step1: Prepare UE    ue_index=${ue_index}    ue_type=${tl.ues[${ue_index}].capabilities[1]}    ui_version=${ui_version}
    ${status}    Run Keyword And Return Status
    ...    Step2: UE Attach     ue_index=${ue_index}    ue_type=${tl.ues[${ue_index}].capabilities[1]}    attach_mode=${attach_mode}
    should be true    '${status}'=='${False}'
#------------------------------------Reporting Portal ----------------------------------------
