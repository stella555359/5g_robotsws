*** Settings ***
Documentation    :copyright: Nokia

Library     OperatingSystem
Library     Collections
Library     ute_fsmaccess
Library     ute_wtssim
Library     ta5g_pm_counters
Library     ta5g_admin_operations
Library     ta5g_egate
Library     ta5g_commissioning
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Library     M2M.py
Library     ./resources/resources.py


*** Variables ***

${vdu_ip}     192.168.255.129
${vcu_ip}     192.168.100.129
${vdu_username}     Nemuadmin
${vdu_password}     Nokia@123

*** Keywords ***
Send getCellList Command and check active UEs from each cell
    [Arguments]    ${total_ues}
    ${cells_ues}    Set variable    0
    coam.connect to
    ${a}     coam.get cell list
    coam.teardown
    ${a_list}   Set variable   ${a['cells']['nr']}
    ${length}=   Get Length   ${a_list}
    ${cell_list_counters}=  create list
    ${cell_list_conf}=  create list
    ${get_bts_info}=  create list
    FOR  ${i}   IN RANGE   ${length}
        Append To List   ${cell_list_conf}   ${a_list[${i}]['id']['configuration']}
        Append To List   ${cell_list_counters}   ${a_list[${i}]['counters']['activeUEs']}
        ${cells_ues}=    Evaluate    ${cells_ues} + ${cell_list_counters}[${i}]
    END
    Should Be Equal As Integers     ${cells_ues}    ${total_ues}

Get vDu Cells 1
    ${cells}=   get_vdu_cells   host=${vdu_ip}   username=${vdu_username}     password=${vdu_password}
    log list    ${cells}

    FOR     ${cell}     IN      @{cells}
        ${cell_info}=   get_vdu_cell_with_id	host=${vdu_ip}	cell_id=${cell}[basicCell][id]
        ...     username=${vdu_username}     password=${vdu_password}
        Log Dictionary	${cell_info}
        Log To Console  \ncell_id: ${cell}[basicCell][id], activeUEs: ${cell_info}[activeUEs]
    END

Get vDu Cells nr1
    ${cells}=   get_vdu_cells   host=${vdu_ip}   username=${vdu_username}     password=${vdu_password}
    log list    ${cells}

    ${cell}=    Set Variable    ${cells}[0]
    ${cell_info}=   get_vdu_cell_with_id	host=${vdu_ip}	cell_id=${cell}[basicCell][id]
    ...     username=${vdu_username}     password=${vdu_password}
    Log Dictionary	${cell_info}
    Log To Console  \ncell_id: ${cell}[basicCell][id], activeUEs: ${cell_info}[activeUEs]
    [return]    ${cell}[basicCell][id]    ${cell_info}[activeUEs]


Get vCu Cells 1
    ${cells}  get_cu_cells   host=${vcu_ip}   username=${vdu_username}     password=${vdu_password}
    log list    ${cells}

    FOR     ${cell}     IN      @{cells}
        ${cell_info}=   get_cu_cell_with_id	host=${vcu_ip}	cell_id=${cell}[basicCell][id]
        ...     username=${vdu_username}     password=${vdu_password}
        Log Dictionary	${cell_info}
        Log To Console  \ncell_id: ${cell}[basicCell][id], activeUEs: ${cell_info}[activeUEs]
        [return]    ${cell}[basicCell][id]    ${cell_info}[activeUEs]
    END

Get vCu Cells nr1
    ${cells}=    Get Cu Cells    host=${vcu_ip}    username=${vdu_username}    password=${vdu_password}
    Log List    ${cells}

    ${cell}=    Set Variable    ${cells}[0]
    ${cell_info}=    Get Cu Cell With Id    host=${vcu_ip}    cell_id=${cell}[basicCell][id]
    ...    username=${vdu_username}    password=${vdu_password}
    Log Dictionary    ${cell_info}
    Log To Console    \ncell_id: ${cell}[basicCell][id], activeUEs: ${cell_info}[activeUEs]
    [Return]    ${cell}[basicCell][id]    ${cell_info}[activeUEs]

Change Serial Number And Product Code For Vdu Scf
    [Arguments]    ${vdu_new_plan}    ${target_distname}
    ${vdu_default_scf_path}=    resources.Get Vdu Current Plan File
    ...     vdu_path=${CURDIR}/resources
    resources.Change Serial Number And Product Code From Default Scf
    ...     vdu_default_scf_path=${vdu_default_scf_path}
    ...     vdu_new_plan=${vdu_new_plan}
    ...     target_distname=${target_distname}

Perform Commissioning And Check Availability Of Rmods
    [Arguments]    ${scf_vcu}    ${scf_vdu}
    ta5g_commissioning.Perform Commissioning Vcu Aic      path_to_plan_file=${scf_vcu}
    ta5g_commissioning.Send Full Commissioning Vdu Aic    input_filepath=${scf_vdu}    vdu=1
    ${vdu_rmods_online}=    resources.Get Vdu Rmods Status
    Should Be True    ${vdu_rmods_online}
