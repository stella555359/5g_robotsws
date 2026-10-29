*** Settings ***
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/basic/coam_check_status.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/coam.robot
Documentation
...    Author: tingting.zhong
...    Contact: tingting.zhong@nokia-sbell.com
...    squad group:SG_04

*** Keywords ***
Run FULL Diagnostic check offline from WebEM Remote tool
    ${before_active_fault_list}    Get Alarm Fault Id List   alarm_type=active
    ${before_history_fault_list}    Get Alarm Fault Id List   alarm_type=history    load_history=${True}
    Prepare for 41-43 Check
    ${diagnostic_result}    coam.run_diagnostic_check    allow_service_impact=${True}    connection=GNB_OAM
    Check All Components Status    operation_component=rmod
    RU Diagnostic Check Report    run_diagnostic_result=${diagnostic_result}
    Check status after run RU diagnostic    before_active_fault_list=${before_active_fault_list}
    ...    before_history_fault_list=${before_history_fault_list}

Prepare for 41-43 Check
    [Documentation]  Prepare object excludedDiagnosticCheckPoints, add CP 1-39
    ${cp_list}    create list
    FOR    ${id}    IN RANGE    1    40
        append to list    ${cp_list}    ${id}
    END
    ${dist_name}    set variable     MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
    coam.perform_parameter_recommissioning    dist_name=${dist_name}
    ...    parameter=excludedDiagnosticCheckPoints    value=${cp_list}    operation=update
    ...    connection=GNB_OAM

RU Diagnostic Check Report
    [Arguments]    ${run_diagnostic_result}    ${connection}=GNB_OAM
    ${checkpointId_list}    create list    41    42    43
    ${get_diagnostic_result}    coam.get_diagnostic_report    connection=${connection}
    ${release}    coam.get_sw_release_name    connection=${connection}
    IF  '${release}'>='SBTS25R1'
        ${checkpoint_key}   Set Variable    checkpoint
        ${lastresult_key}    Set Variable    checkStatus
        ${timestamp_key}    Set Variable    executionTime
    ELSE
        ${checkpoint_key}   Set Variable    checkpointId
        ${lastresult_key}    Set Variable    lastResult
        ${timestamp_key}    Set Variable    timestamp
    END
    Set Test Variable    ${release}
    Set Test Variable    ${checkpoint_key}
    Set Test Variable    ${timestamp_key}
    ${lastresult_list}   create list    OK    Check point successful
    FOR    ${output}    IN    @{run_diagnostic_result}
        ${checkpointId}    convert to string    ${output['${checkpoint_key}']}
        ${status}    run keyword and return status    list should contain value    ${checkpointId_list}    ${checkpointId}
        run keyword if    ${status}    run keywords
        ...    List Should Contain Value    ${lastresult_list}    ${output['${lastresult_key}']}    AND
        ...    Check PointId lastResult    ${output}    ${get_diagnostic_result}    AND
        ...    remove values from list    ${checkpointId_list}    ${checkpointId}
    END
    should be empty    ${checkpointId_list}

Check PointId lastResult
    [Arguments]    ${run_diagnostic_result_single}    ${get_diagnostic_result}
    ${check_result}    set variable    ${False}
    FOR    ${output}    IN    @{get_diagnostic_result}
        ${ru_dist_name}    Set Variable If    '${release}'>='SBTS25R1'    targetDistinguishedName    distName
        ${tmp_ru_dist_name}    Set Variable    ${run_diagnostic_result_single['${ru_dist_name}']}
        ${tmp_checkpoint_key}    Set Variable    ${run_diagnostic_result_single['${checkpoint_key}']}
        run keyword if    "${output['${checkpoint_key}']}"=="${tmp_checkpoint_key}" and "${output['${ru_dist_name}']}"=="${tmp_ru_dist_name}"
        ...    should be equal as strings    ${output['${timestamp_key}']}    ${run_diagnostic_result_single['${timestamp_key}']}
    END

Check status after run RU diagnostic
    [Arguments]    ${before_active_fault_list}   ${before_history_fault_list}    ${connection}=GNB_OAM    ${gnb_type}=${gNb_CuType}
    ${ext_active_allowd_list}    create list
    ${ext_history_allowd_list}    create list    ${7313}    ${4592}
    ${new_activre_fault_list}    combine lists     ${before_active_fault_list}    ${ext_active_allowd_list}
    ${new_history_fault_list}    combine lists     ${before_history_fault_list}    ${ext_history_allowd_list}
    Check status after bts operation
    ...    before_active_fault_list=${new_activre_fault_list}
    ...    before_history_fault_list=${new_history_fault_list}
    ...    operation_component=bbmod
    ...    connection=${connection}
    ...    gnb_type=${gnb_type}
