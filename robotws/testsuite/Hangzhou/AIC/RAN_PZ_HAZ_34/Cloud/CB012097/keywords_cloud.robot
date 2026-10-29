*** Settings ***
Documentation    This is for keywords for cloud
...              Author: Yang Di
...              Squard: HZ MMW5

Library    json
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/cases/Cloud/Cloud_Setup_and_Teardown.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_ru.robot
Resource   testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_vdu.robot

*** Keywords ***
Modify Nrpm_fail
    [Arguments]    ${ru_index}=1
    ${alias}    Cloud Connect to RU    ru_index=${ru_index}
    ${client}    set variable    frmonShellClient localhost 2000
    log to console    Modify Nrpm_fail...
    ${out}   cloud_ru.Cloud SSH Execute CMD    alias=${alias}
    ...  command=echo '/ action create ConfigAccess /CI/ConfigAccess_Module /module'|${client}
    ...  check_result=${False}  expert_prompt=connection closed
    sleep  1
    log to console    ${out}
    ${cmd}   catenate    echo '/CI/ConfigAccess_Module action fetch DECODED "tcs_parameters.bin"
    ...    "/ram/tcs_parameters.json"'|${client}
    ${out}   cloud_ru.Cloud SSH Execute CMD    alias=${alias}  command=${cmd}  check_result=${False}
    ...  expert_prompt=done ok
    sleep  1
    log to console    ${out}
    ${out}   cloud_ru.Cloud SSH Execute CMD    alias=${alias}  command=cat /ram/tcs_parameters.json | grep -i Nrpm_fail
    ...  check_result=${False}  expert_prompt=/home/rfsw
    sleep  1
    ${pattern}   Set Variable    "Nrpm_fail": .*,
    ${init_value_list}    Get Regexp Matches     ${out}    ${pattern}
    ${init_value_Nrpm_fail}   Set Variable    ${init_value_list}[0]
    ${cmd}   Set Variable    sed -i 's/${init_value_Nrpm_fail}/"Nrpm_fail": 2,/g' /ram/tcs_parameters.json
    ${out}   cloud_ru.Cloud SSH Execute CMD    alias=${alias}  command=${cmd}  check_result=${False}  expert_prompt=$
    sleep  1
    ${cmd}   catenate    echo '/CI/ConfigAccess_Module action store PERMANENT DECODED "tcs_parameters.bin"
    ...    "/ram/tcs_parameters.json"'|${client}
    ${out}   cloud_ru.Cloud SSH Execute CMD    alias=${alias}  command=${cmd}   check_result=${False}
    ...  expert_prompt=done ok
    sleep  1
    ${out}   cloud_ru.Cloud SSH Execute CMD    alias=${alias}  command=cat /ram/tcs_parameters.json | grep -i Nrpm_fail
    ...  check_result=${False}  expert_prompt=$
    sleep  1
    log to console    ${out}
    reset_ru    ru_index=${ru_index}
    Wait until keyword succeeds    10min    30s    Verify All RU Status Should Be Normal on vDU
    wait until keyword succeeds     15min    10s    vDU Verify All Cells Status Should Be Onair
    [Teardown]    run keyword and ignore error    Cloud Disconnect Alais    alias=${alias}

reset_ru
    [Arguments]    ${ru_index}=1
    ${rmod_id_list_new}=  create list
    Append To List    ${rmod_id_list_new}    ${ru_index}
    log to console    ${rmod_id_list_new}
    cloud_ru.Reset Rmod By Rest    rmods_list=${rmod_id_list_new}
    sleep   1min

Modify optionalFansInstalled
    [Arguments]    ${value}
    ${optionalFansInstalled_para}    set variable if    "${value}"=="true"    ${enableop_para}    ${disableop_para}
    VDU Online Change Parameters Activate    updated_paras_list=${optionalFansInstalled_para}

Modify actRadioFanFailureEarlyNotif
    [Arguments]    ${value}
    ${actRadioFanFailureEarlyNotif_para}    set variable if    "${value}"=="true"    ${enableac_para}
    ...    ${disableac_para}
    VDU Online Change Parameters Activate    updated_paras_list=${actRadioFanFailureEarlyNotif_para}

BTS Report Fault on FAN
    [Arguments]    ${faultId}=1933    ${ru_index}=1
    ${fan_list}  Create List  1  2
    FOR    ${index}    IN    @{fan_list}
        Wait Until Keyword Succeeds    5min    30s   Check Expect Fault Present    faultId=${faultId}
        ...    source=MRBTS-${mrbtsID}/EQM_R-1/APEQM_R-1/RMOD_R-${ru_index}/FAN_R-${index}
    END
    log to console    Check fault ${faultId} present on FAN_R
    Wait Until Keyword Succeeds    5min    30s   Check Expect Fault Absent
    ...   faultId=${faultId}  source=MRBTS-${mrbtsID}/EQM_R-1/APEQM_R-1/RMOD_R-${ru_index}

Check Expect Fault Present
    [Arguments]  ${faultId}=1933    ${source}=${None}
    VDU Login
    ${out}    vdu.vdu_get_active_alarms
    ${output_lenth}=    set variable    ${out['total']}
    FOR    ${index}    IN RANGE    ${output_lenth}
        ${fault_id}    Set Variable    ${out['alarms'][${index}]['fault_id']}
        ${status}    Run Keyword And Return Status    Run Keywords    Should Be True    ${fault_id}==${faultId}    AND
        ...    Run Keyword If    '${source}'!='${None}'    Should Be Equal
        ...    ${out['alarms'][${index}]['alarming_object']}    ${source}    case_insensitive=True
        exit for loop if    ${status}
    END
    Run Keyword If    ${status}==${False}    Fail
    ...    faultId ${faultId} reported by source ${source} is not present on gnb.

VDU Online Change Parameters Activate
    [Arguments]    ${updated_paras_list}    ${vdu_index}=0
    [Timeout]    20min
    vDU Login    vdu_index=${vdu_index}
    ${updated_paras_json_str}    evaluate    json.dumps(${updated_paras_list})
    ${response}    vdu.perform_delta_recommissioning    delta_file=${updated_paras_json_str}
    ${status}    set variable    ${response['status']}
    Should be True    'success'=='${status}'
    [Teardown]    Run Keyword And Ignore Error    vDU Logout

Check Expect Fault Absent
    [Arguments]  ${faultId}=1933    ${source}=${None}
    ${status}    Run Keyword And Return Status   Check Expect Fault Present   faultId=${faultId}
    ...                                                                       source=${source}
    Run Keyword If  ${status}==${True}   Fail
    ...   faultId ${faultId} reported by source ${source} is still present on gnb.

Check Fans State
    [Arguments]    ${availabilityStatus}=failed    ${operationalState}=disabled
    ${fan_list}    Create List    1    2
    VDU Rest Login
    FOR  ${item}  IN  @{fan_list}
       ${dist_names}    create list   MRBTS-${mrbts_id}/EQM_R-1/APEQM_R-1/RMOD_R-1/FAN_R-${item}
       ${objects}    vdu.get_current_plan_objects    class_name=FAN_R    dist_names=${dist_names}
       ${fan}    set variable    ${objects['objects']}[0]
       ${json_repr}    json.loads    ${fan['json_repr']}
       ${admi_status}    set variable    ${json_repr['administrativeState']}
       should be equal    ${admi_status}    Unlocked
       ${avai_status}    set variable If  '${availabilityStatus}'!='None'    ${json_repr['availabilityStatus']}
       Run Keyword If  '${availabilityStatus}'!='None'  should be equal    ${avai_status}    ${availabilityStatus}
       ${oper_status}    set variable    ${json_repr['operationalState']}
       should be equal    ${oper_status}    ${operationalState}
    END
    [Teardown]  vDU Rest Logout

