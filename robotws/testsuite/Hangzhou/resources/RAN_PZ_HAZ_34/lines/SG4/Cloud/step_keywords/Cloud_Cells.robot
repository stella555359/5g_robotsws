*** Settings ***
Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Cloud/cloud_vdu.robot

*** Keywords ***
Cloud Cell Status Should as Expect
    [Arguments]  ${cell_id}=${None}    ${vdu_index}=0
    ...    ${operational_state}=${None}    ${availability_status}=${None}    ${administrative_state}=${None}
    ...    ${blocking_state}=${None}    ${procedural_status}=${None}    ${gnb_index}=0    ${vdu_index}=0
    ${conn_alias}    generic_utils.get_unique_id_string
    vdu_gen.login_rest   vdu_index=${vdu_index}   gnb_index=${gnb_index}   alias=${conn_alias}
    ${cells_status}=  vdu.get_vdu_cells_status     vdu_connection=${conn_alias}
    FOR  ${cell}  IN  @{cells_status}
        Run keyword if    '${cell_id}'!='${cell}[id]' and ${cell_id}!=${None}    Continue For Loop
        Cloud Cell Status Check    type=operational_state    status=${operational_state}    cells_status_info=${cell}
        Cloud Cell Status Check    type=availability_status    status=${availability_status}    cells_status_info=${cell}
        Cloud Cell Status Check    type=administrative_state    status=${administrative_state}    cells_status_info=${cell}
        Cloud Cell Status Check    type=blocking_state    status=${blocking_state}    cells_status_info=${cell}
        Cloud Cell Status Check    type=procedural_status    status=${procedural_status}    cells_status_info=${cell}
    END
    [Teardown]    vdu_gen.logout_rest    conn_alias=${conn_alias}

Cloud Cell Status Check
    [Arguments]  ${type}    ${status}    ${cells_status_info}
    Run Keyword If    '${status}'!='${None}'    run keywords
    ...    log to console    cell status ${type} should be ${status} real is ${cells_status_info}[${type}]   AND
    ...    Should Be Equal As Strings   ${cells_status_info}[${type}]     ${status}
    ...    msg=cell status of ${type} is ${cells_status_info}[${type}] not same as ${status}
    ...    ELSE    log    no need to check ${type}
